--!strict

local fs = require("@lune/fs")
local process = require("@lune/process")
local serde = require("@lune/serde")

local Common = require("./common")

local ToolVerifier = {}

local function platformId(): string
	assert(process.arch == "x86_64", "P000-TOOLS-002 unsupported architecture")
	if process.os == "linux" then
		return "linux-x86_64"
	elseif process.os == "windows" then
		return "windows-x86_64"
	end
	error("P000-TOOLS-003 unsupported operating system")
end

local function executableSuffix(): string
	return if process.os == "windows" then ".exe" else ""
end

local function pathsEqual(left: string, right: string): boolean
	local normalizedLeft = Common.normalizePath(left)
	local normalizedRight = Common.normalizePath(right)
	if process.os == "windows" then
		return normalizedLeft:lower() == normalizedRight:lower()
	end
	return normalizedLeft == normalizedRight
end

local function resolveOnPath(name: string): string?
	local pathValue = process.env.PATH or ""
	local separator = if process.os == "windows" then ";" else ":"
	local suffix = executableSuffix()
	for directory in (pathValue .. separator):gmatch("(.-)" .. separator) do
		assert(directory ~= "", "P000-TOOLS-004 empty path entry")
		local candidate = Common.join(directory, name .. suffix)
		if fs.isFile(candidate) then
			return candidate
		end
	end
	return nil
end

local function selectedArtifact(tool: any, selectedPlatform: string): any
	local result = nil
	for _, artifact in tool.artifacts do
		if artifact.platform == selectedPlatform then
			assert(result == nil, "P000-TOOLS-005 duplicate platform artifact")
			result = artifact
		end
	end
	assert(result ~= nil, "P000-TOOLS-006 selected artifact missing")
	return result
end

local function validateProvenance(tool: any, artifact: any)
	for _, field in
		{
			"id",
			"version",
			"source_repository",
			"release_url",
			"tag",
			"source_commit",
			"release_build_run",
			"release_build_disposition",
			"release_note_review",
		}
	do
		assert(
			type(tool[field]) == "string" and tool[field] ~= "",
			"P000-TOOLS-007 missing tool field, " .. field
		)
	end
	assert(type(tool.license.spdx) == "string", "P000-TOOLS-008 license identity missing")
	assert(
		type(tool.license.sha256) == "string" and #tool.license.sha256 == 64,
		"P000-TOOLS-009 license sha256 missing"
	)
	assert(
		type(tool.license.sha512) == "string" and #tool.license.sha512 == 128,
		"P000-TOOLS-010 license sha512 missing"
	)
	assert(type(tool.security_findings) == "table", "P000-TOOLS-011 security disposition missing")
	for _, field in
		{
			"platform",
			"filename",
			"url",
			"sha256",
			"sha512",
			"executable",
			"executable_sha256",
			"executable_sha512",
			"version_output",
			"version_probe",
		}
	do
		assert(
			type(artifact[field]) == "string" and artifact[field] ~= "",
			"P000-TOOLS-012 missing artifact field, " .. field
		)
	end
	assert(
		type(artifact.size) == "number" and artifact.size > 0,
		"P000-TOOLS-013 artifact size missing"
	)
	assert(
		type(artifact.executable_size) == "number" and artifact.executable_size > 0,
		"P000-TOOLS-014 executable size missing"
	)
	assert(
		#artifact.sha256 == 64 and #artifact.sha512 == 128,
		"P000-TOOLS-015 archive hash malformed"
	)
	assert(
		#artifact.executable_sha256 == 64 and #artifact.executable_sha512 == 128,
		"P000-TOOLS-016 executable hash malformed"
	)
end

local function managedPath(root: string, tool: any): string
	if tool.id == "rokit" then
		return Common.join(root, "bin", "rokit" .. executableSuffix())
	end
	local author, name, version = tool.rokit_spec:match("^([^/]+)/([^@]+)@(.+)$")
	assert(
		author ~= nil and name ~= nil and version ~= nil,
		"P000-TOOLS-017 invalid rokit specification"
	)
	return Common.join(
		root,
		"tool-storage",
		author:lower(),
		name:lower(),
		version,
		name:lower() .. executableSuffix()
	)
end

function ToolVerifier.actualToolPath(id: string): string
	local registry = Common.readJson("config/tool-artifacts.json")
	local root = Common.getRokitRoot()
	for _, tool in registry.tools do
		if tool.id == id then
			return managedPath(root, tool)
		end
	end
	error("P000-TOOLS-018 unknown tool, " .. id)
end

function ToolVerifier.verify(quiet: boolean?): { any }
	Common.assertRepositoryRoot()
	local registry = Common.readJson("config/tool-artifacts.json")
	assert(registry.schema_version == 1, "P000-TOOLS-019 artifact schema mismatch")
	assert(
		registry.security_review.result == "accepted_with_enforced_constraints",
		"P000-TOOLS-020 review is not accepted"
	)

	local manifest = serde.decode("toml", fs.readFile("rokit.toml"))
	local selectedPlatform = platformId()
	local root = Common.getRokitRoot()
	local results = {}
	local seen = {}

	for _, tool in registry.tools do
		assert(not seen[tool.id], "P000-TOOLS-021 duplicate tool id")
		seen[tool.id] = true
		local artifact = selectedArtifact(tool, selectedPlatform)
		validateProvenance(tool, artifact)

		if tool.id == "rokit" then
			assert(
				tool.rokit_alias == nil and tool.rokit_spec == nil,
				"P000-TOOLS-022 rokit must not manage itself"
			)
		else
			assert(
				manifest.tools[tool.rokit_alias] == tool.rokit_spec,
				"P000-TOOLS-023 manifest drift, " .. tool.id
			)
		end

		local alias = tool.rokit_alias or "rokit"
		local expectedAlias = Common.join(root, "bin", alias .. executableSuffix())
		local resolvedAlias = resolveOnPath(alias)
		assert(resolvedAlias ~= nil, "P000-TOOLS-024 tool missing from path, " .. tool.id)
		assert(
			pathsEqual(resolvedAlias, expectedAlias),
			"P000-TOOLS-025 shadowed executable, " .. tool.id
		)

		local actualPath = managedPath(root, tool)
		assert(fs.isFile(actualPath), "P000-TOOLS-026 managed executable missing, " .. tool.id)
		local executableBytes = fs.readFile(actualPath)
		assert(
			#executableBytes == artifact.executable_size,
			"P000-TOOLS-027 executable size mismatch, " .. tool.id
		)
		local sha256, sha512 = Common.hashContents(executableBytes)
		assert(
			sha256 == artifact.executable_sha256,
			"P000-TOOLS-028 executable sha256 mismatch, " .. tool.id
		)
		assert(
			sha512 == artifact.executable_sha512,
			"P000-TOOLS-029 executable sha512 mismatch, " .. tool.id
		)

		local versionResult = Common.runBounded(
			actualPath,
			{ "--version" },
			10,
			{ cwd = process.cwd }
		)
		assert(versionResult.ok, "P000-TOOLS-030 version probe failed, " .. tool.id)
		local versionOutput = Common.trim(versionResult.stdout)
		assert(
			versionOutput == artifact.version_output,
			"P000-TOOLS-031 version mismatch, " .. tool.id
		)

		local result = {
			id = tool.id,
			path = "$ROKIT_ROOT/" .. Common.normalizePath(actualPath):sub(#root + 2),
			platform = selectedPlatform,
			version = versionOutput,
			artifact = artifact.filename,
			integrity = "sha256:" .. artifact.executable_sha256,
		}
		table.insert(results, result)
	end

	assert(#results == 5, "P000-TOOLS-032 tool count mismatch")
	table.sort(results, function(left, right)
		return left.id < right.id
	end)
	if not quiet then
		for _, result in results do
			print(
				string.format(
					"tool verified, %s, %s, %s, %s, %s, %s",
					result.id,
					result.path,
					result.version,
					result.platform,
					result.artifact,
					result.integrity
				)
			)
		end
	end
	return results
end

return ToolVerifier
