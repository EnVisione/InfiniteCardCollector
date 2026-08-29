--!strict

local fs = require("@lune/fs")
local roblox = require("@lune/roblox")
local serde = require("@lune/serde")

local Common = require("./common")

local ArtifactCore = {}

local function isArray(value: { [any]: any }): boolean
	local count = 0
	local highest = 0
	for key in value do
		if type(key) ~= "number" or key < 1 or key % 1 ~= 0 then
			return false
		end
		count += 1
		highest = math.max(highest, key)
	end
	return count == highest
end

function ArtifactCore.canonicalJson(value: any): string
	local valueType = type(value)
	if value == nil then
		return "null"
	elseif valueType == "string" or valueType == "number" or valueType == "boolean" then
		return serde.encode("json", value)
	elseif valueType ~= "table" then
		error("P000-ARTIFACT-001 unsupported canonical value")
	end

	if isArray(value) then
		local encoded = {}
		for index = 1, #value do
			table.insert(encoded, ArtifactCore.canonicalJson(value[index]))
		end
		return "[" .. table.concat(encoded, ",") .. "]"
	end

	local encoded = {}
	for _, key in Common.sortedKeys(value) do
		table.insert(
			encoded,
			serde.encode("json", key) .. ":" .. ArtifactCore.canonicalJson(value[key])
		)
	end
	return "{" .. table.concat(encoded, ",") .. "}"
end

function ArtifactCore.sourceInputs(): ({ any }, string)
	local paths = { "default.project.json" }
	for _, path in Common.listFiles("src") do
		table.insert(paths, path)
	end
	table.sort(paths)

	local inputs = {}
	local digestMaterial = {}
	for _, path in paths do
		local contents = fs.readFile(path)
		local sha256, sha512 = Common.hashContents(contents)
		table.insert(inputs, {
			path = path,
			sha256 = sha256,
			sha512 = sha512,
			size = #contents,
		})
		table.insert(digestMaterial, path .. "\0" .. tostring(#contents) .. "\0" .. contents)
	end
	return inputs, serde.hash("sha256", table.concat(digestMaterial, "\0"))
end

function ArtifactCore.validateSourceMap(contents: string): { string }
	local sourceMap = serde.decode("json", contents)
	local paths = {}

	local function visit(node: any)
		assert(
			type(node.name) == "string" and node.name ~= "",
			"P000-SOURCEMAP-001 node name missing"
		)
		assert(
			type(node.className) == "string" and node.className ~= "",
			"P000-SOURCEMAP-002 class missing"
		)
		if node.filePaths ~= nil then
			for _, path in node.filePaths do
				assert(type(path) == "string", "P000-SOURCEMAP-003 path is not a string")
				assert(
					path == Common.normalizePath(path),
					"P000-SOURCEMAP-004 path is not normalized"
				)
				Common.assertSafeRelativePath(path)
				assert(fs.isFile(path), "P000-SOURCEMAP-005 mapped file missing, " .. path)
				table.insert(paths, path)
			end
		end
		for _, child in node.children or {} do
			visit(child)
		end
	end

	visit(sourceMap)
	table.sort(paths)
	assert(paths[1] == "default.project.json", "P000-SOURCEMAP-006 project mapping missing")
	local expectedPaths = { "default.project.json" }
	for _, path in Common.listFiles("src") do
		if path:match("%.luau$") then
			table.insert(expectedPaths, path)
		end
	end
	table.sort(expectedPaths)
	assert(#paths == #expectedPaths, "P000-SOURCEMAP-007 mapped file count mismatch")
	for index, path in expectedPaths do
		assert(paths[index] == path, "P000-SOURCEMAP-008 mapped file inventory mismatch")
	end
	return paths
end

function ArtifactCore.instanceInventory(contents: string): { any }
	local dataModel = roblox.deserializePlace(contents)
	local inventory = {}

	local function visit(instance: any, parentPath: string)
		local path = if parentPath == "" then instance.Name else parentPath .. "/" .. instance.Name
		table.insert(inventory, {
			class_name = instance.ClassName,
			path = path,
		})
		local children = instance:GetChildren()
		table.sort(children, function(left, right)
			if left.Name == right.Name then
				return left.ClassName < right.ClassName
			end
			return left.Name < right.Name
		end)
		for _, child in children do
			visit(child, path)
		end
	end

	local children = dataModel:GetChildren()
	table.sort(children, function(left, right)
		if left.Name == right.Name then
			return left.ClassName < right.ClassName
		end
		return left.Name < right.Name
	end)
	for _, child in children do
		visit(child, "")
	end

	ArtifactCore.assertNoToolBoundary(inventory)
	return inventory
end

function ArtifactCore.assertNoToolBoundary(inventory: { any })
	local forbiddenSegments = {
		[".github"] = true,
		github = true,
		lune = true,
		provenance = true,
		tests = true,
		["tool-storage"] = true,
	}
	local allowedConfigPath = "replicatedstorage/shared/config"
	for _, entry in inventory do
		assert(type(entry.path) == "string", "P000-ARTIFACT-002 tool boundary leak")
		local loweredPath = entry.path:lower()
		for segment in loweredPath:gmatch("[^/]+") do
			assert(not forbiddenSegments[segment], "P000-ARTIFACT-002 tool boundary leak")
			if segment == "config" then
				assert(
					loweredPath == allowedConfigPath
						or loweredPath:sub(1, #allowedConfigPath + 1)
							== allowedConfigPath .. "/",
					"P000-ARTIFACT-002 tool boundary leak"
				)
			end
		end
	end
end

function ArtifactCore.assertDeterministicManifest(contents: string)
	local lowered = contents:lower()
	assert(not lowered:find("generated_at", 1, true), "P000-ARTIFACT-003 timestamp field")
	assert(not lowered:find("/" .. "home/", 1, true), "P000-ARTIFACT-004 linux absolute path")
	assert(not lowered:match("%a:[\\/]users[\\/]"), "P000-ARTIFACT-005 windows absolute path")
	assert(not lowered:find("\\", 1, true), "P000-ARTIFACT-006 nonportable separator")
end

function ArtifactCore.assertHashes(contents: string, expectedSha256: string, expectedSha512: string)
	local sha256, sha512 = Common.hashContents(contents)
	assert(sha256 == expectedSha256, "P000-ARTIFACT-030 sha256 mismatch")
	assert(sha512 == expectedSha512, "P000-ARTIFACT-031 sha512 mismatch")
end

function ArtifactCore.inspectPacket()
	local manifestPath = "build/artifact-manifest.json"
	local artifactPath = "build/infinite-card-collector.rbxlx"
	local sourceMapPath = "build/infinite-card-collector.sourcemap.json"
	assert(fs.isFile(manifestPath), "P000-ARTIFACT-012 manifest missing")
	assert(fs.isFile(artifactPath), "P000-ARTIFACT-013 project artifact missing")
	assert(fs.isFile(sourceMapPath), "P000-ARTIFACT-014 source map missing")

	local manifestContents = fs.readFile(manifestPath)
	local manifest = serde.decode("json", manifestContents)
	assert(
		ArtifactCore.canonicalJson(manifest) .. "\n" == manifestContents,
		"P000-ARTIFACT-015 manifest is not canonical"
	)
	ArtifactCore.assertDeterministicManifest(manifestContents)

	local artifactContents = fs.readFile(artifactPath)
	local sourceMapContents = fs.readFile(sourceMapPath)
	local artifactSha256, artifactSha512 = Common.hashContents(artifactContents)
	local sourceMapSha256, sourceMapSha512 = Common.hashContents(sourceMapContents)
	ArtifactCore.assertHashes(artifactContents, manifest.artifact.sha256, manifest.artifact.sha512)
	ArtifactCore.assertHashes(
		sourceMapContents,
		manifest.source_map.sha256,
		manifest.source_map.sha512
	)
	assert(manifest.artifact.sha256 == artifactSha256, "P000-ARTIFACT-016 artifact sha256 drift")
	assert(manifest.artifact.sha512 == artifactSha512, "P000-ARTIFACT-017 artifact sha512 drift")
	assert(manifest.artifact.size == #artifactContents, "P000-ARTIFACT-018 artifact size drift")
	assert(
		manifest.source_map.sha256 == sourceMapSha256,
		"P000-ARTIFACT-019 source map sha256 drift"
	)
	assert(
		manifest.source_map.sha512 == sourceMapSha512,
		"P000-ARTIFACT-020 source map sha512 drift"
	)
	ArtifactCore.validateSourceMap(sourceMapContents)

	local inventory = ArtifactCore.instanceInventory(artifactContents)
	local inventoryContents = ArtifactCore.canonicalJson(inventory)
	local inventorySha256, inventorySha512 = Common.hashContents(inventoryContents)
	assert(
		manifest.instance_inventory.sha256 == inventorySha256,
		"P000-ARTIFACT-021 inventory sha256 drift"
	)
	assert(
		manifest.instance_inventory.sha512 == inventorySha512,
		"P000-ARTIFACT-022 inventory sha512 drift"
	)
	assert(
		ArtifactCore.canonicalJson(manifest.instance_inventory.entries) == inventoryContents,
		"P000-ARTIFACT-023 inventory entries drift"
	)

	local inputs, inputDigest = ArtifactCore.sourceInputs()
	assert(manifest.source_inputs.sha256 == inputDigest, "P000-ARTIFACT-024 source input drift")
	assert(
		ArtifactCore.canonicalJson(manifest.source_inputs.entries)
			== ArtifactCore.canonicalJson(inputs),
		"P000-ARTIFACT-025 source input entries drift"
	)
	local projectSha256, projectSha512 = Common.hashFile("default.project.json")
	assert(
		manifest.project_map.sha256 == projectSha256,
		"P000-ARTIFACT-026 project map sha256 drift"
	)
	assert(
		manifest.project_map.sha512 == projectSha512,
		"P000-ARTIFACT-027 project map sha512 drift"
	)

	assert(
		fs.readFile("build/infinite-card-collector.rbxlx.sha256")
			== artifactSha256 .. "  build/infinite-card-collector.rbxlx\n",
		"P000-ARTIFACT-028 sha256 file drift"
	)
	assert(
		fs.readFile("build/infinite-card-collector.rbxlx.sha512")
			== artifactSha512 .. "  build/infinite-card-collector.rbxlx\n",
		"P000-ARTIFACT-029 sha512 file drift"
	)
end

return ArtifactCore
