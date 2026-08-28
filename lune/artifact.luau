--!strict

local fs = require("@lune/fs")
local process = require("@lune/process")

local ArtifactCore = require("./lib/artifact-core")
local Common = require("./lib/common")
local ToolVerifier = require("./lib/tool-verifier")

local function removeArtifactWork()
	for _, path in { "build/artifact-a", "build/artifact-b" } do
		Common.removeGeneratedPath(path)
	end
end

local function runRojo(rojoPath: string, arguments: { string })
	local result = Common.runBounded(rojoPath, arguments, 120, { cwd = process.cwd })
	assert(result.ok, "P000-ARTIFACT-007 rojo command failed, " .. result.stderr)
end

Common.main("artifact", function()
	Common.assertRepositoryRoot()
	ToolVerifier.verify(true)
	removeArtifactWork()
	Common.ensureDir("build/artifact-a")
	Common.ensureDir("build/artifact-b")

	local rojoPath = ToolVerifier.actualToolPath("rojo")
	local sourceMapA = "build/artifact-a/infinite-card-collector.sourcemap.json"
	local sourceMapB = "build/artifact-b/infinite-card-collector.sourcemap.json"
	local artifactA = "build/artifact-a/infinite-card-collector.rbxlx"
	local artifactB = "build/artifact-b/infinite-card-collector.rbxlx"

	runRojo(rojoPath, { "sourcemap", "default.project.json", "--output", sourceMapA })
	runRojo(rojoPath, { "sourcemap", "default.project.json", "--output", sourceMapB })
	runRojo(rojoPath, { "build", "default.project.json", "--output", artifactA })
	runRojo(rojoPath, { "build", "default.project.json", "--output", artifactB })

	local sourceMapContentsA = fs.readFile(sourceMapA)
	local sourceMapContentsB = fs.readFile(sourceMapB)
	local artifactContentsA = fs.readFile(artifactA)
	local artifactContentsB = fs.readFile(artifactB)
	assert(sourceMapContentsA == sourceMapContentsB, "P000-ARTIFACT-008 source maps differ")
	assert(artifactContentsA == artifactContentsB, "P000-ARTIFACT-009 project builds differ")

	local mappedPaths = ArtifactCore.validateSourceMap(sourceMapContentsA)
	local inventory = ArtifactCore.instanceInventory(artifactContentsA)
	local inputs, inputDigest = ArtifactCore.sourceInputs()
	local artifactSha256, artifactSha512 = Common.hashContents(artifactContentsA)
	local sourceMapSha256, sourceMapSha512 = Common.hashContents(sourceMapContentsA)
	local projectSha256, projectSha512 = Common.hashFile("default.project.json")
	local inventoryContents = ArtifactCore.canonicalJson(inventory)
	local inventorySha256, inventorySha512 = Common.hashContents(inventoryContents)

	local gitResult = Common.runBounded("git", { "rev-parse", "HEAD" }, 15, { cwd = process.cwd })
	assert(gitResult.ok, "P000-ARTIFACT-010 source commit unavailable")
	local sourceCommit = Common.trim(gitResult.stdout)
	assert(
		sourceCommit:match("^[0-9a-f]+$") ~= nil and #sourceCommit == 40,
		"P000-ARTIFACT-011 source commit malformed"
	)

	local toolResults = ToolVerifier.verify(true)
	local toolVersions = {}
	for _, result in toolResults do
		table.insert(toolVersions, {
			id = result.id,
			version = result.version,
		})
	end

	local manifest = {
		artifact = {
			path = "build/infinite-card-collector.rbxlx",
			sha256 = artifactSha256,
			sha512 = artifactSha512,
			size = #artifactContentsA,
		},
		instance_inventory = {
			entries = inventory,
			sha256 = inventorySha256,
			sha512 = inventorySha512,
		},
		mapped_paths = mappedPaths,
		project = "InfiniteCardCollector",
		project_map = {
			path = "default.project.json",
			sha256 = projectSha256,
			sha512 = projectSha512,
		},
		schema_version = 1,
		source_commit = sourceCommit,
		source_inputs = {
			entries = inputs,
			sha256 = inputDigest,
		},
		source_map = {
			path = "build/infinite-card-collector.sourcemap.json",
			sha256 = sourceMapSha256,
			sha512 = sourceMapSha512,
			size = #sourceMapContentsA,
		},
		tool_versions = toolVersions,
	}
	local manifestContents = ArtifactCore.canonicalJson(manifest) .. "\n"
	ArtifactCore.assertDeterministicManifest(manifestContents)

	fs.writeFile("build/infinite-card-collector.rbxlx", artifactContentsA)
	fs.writeFile("build/infinite-card-collector.sourcemap.json", sourceMapContentsA)
	fs.writeFile("build/artifact-manifest.json", manifestContents)
	fs.writeFile(
		"build/infinite-card-collector.rbxlx.sha256",
		artifactSha256 .. "  build/infinite-card-collector.rbxlx\n"
	)
	fs.writeFile(
		"build/infinite-card-collector.rbxlx.sha512",
		artifactSha512 .. "  build/infinite-card-collector.rbxlx\n"
	)

	removeArtifactWork()
	print("artifact verified, build/infinite-card-collector.rbxlx")
	print("artifact sha256, " .. artifactSha256)
	print("artifact sha512, " .. artifactSha512)
end)
