--!strict

local fs = require("@lune/fs")
local process = require("@lune/process")
local serde = require("@lune/serde")
local stdio = require("@lune/stdio")
local task = require("@lune/task")

local ArtifactCore = require("./lib/artifact-core")
local Common = require("./lib/common")
local DocsValidator = require("./lib/docs-validator")
local Environment = require("./lib/environment")
local Phase001Test = require("./phase001-test")
local RuntimeGuard = require("./lib/runtime-guard")
local SecretScanner = require("./lib/secret-scanner")
local ToolVerifier = require("./lib/tool-verifier")

type TestCase = {
	id: string,
	run: () -> (),
}

local function expectFailure(callback: () -> (), expectedId: string)
	local ok, result = pcall(callback)
	assert(not ok, "P000-HARNESS-001 expected failure did not occur")
	assert(tostring(result):find(expectedId, 1, true) ~= nil, "P000-HARNESS-002 wrong failure id")
end

local function fixtureMode(): string?
	for index, argument in process.args do
		if argument == "--fixture" then
			return process.args[index + 1]
		end
	end
	return nil
end

local function runFixture(mode: string)
	if mode == "fail" then
		stdio.ewrite("P000-HARNESS-FIXTURE-FAIL\n")
		process.exit(17)
	elseif mode == "crash" then
		error("P000-HARNESS-FIXTURE-CRASH")
	elseif mode == "timeout" then
		task.wait(5)
	elseif mode == "path-escape" then
		Common.assertSafeRelativePath("../outside")
	elseif mode == "network-attempt" then
		RuntimeGuard.validateContent(
			"shared",
			"network-attempt",
			fs.readFile("tests/fixtures/network-attempt.txt")
		)
	else
		error("P000-HARNESS-FIXTURE-UNKNOWN")
	end
end

local selectedFixture = fixtureMode()
if selectedFixture ~= nil then
	Common.main("test fixture", function()
		runFixture(selectedFixture)
	end)
	process.exit(0)
end

local tests: { TestCase } = {}

local function addTest(id: string, callback: () -> ())
	table.insert(tests, {
		id = id,
		run = callback,
	})
end

Phase001Test.register(addTest, expectFailure)

addTest("P000-TEST-001-project-map", function()
	local project = serde.decode("json", fs.readFile("default.project.json"))
	RuntimeGuard.validateProject(project)

	local duplicate =
		serde.decode("json", fs.readFile("tests/fixtures/project-duplicate-source.json"))
	expectFailure(function()
		RuntimeGuard.validateProject(duplicate)
	end, "P000-PROJECT-009")
end)

addTest("P000-TEST-002-strict-boundaries", function()
	RuntimeGuard.validateRepository()
	expectFailure(function()
		RuntimeGuard.validateStrictFile("non-strict", fs.readFile("tests/fixtures/non-strict.txt"))
	end, "P000-STRICT-001")
	for _, fixture in
		{
			{ "shared", "tests/fixtures/forbidden-shared.txt" },
			{ "server", "tests/fixtures/forbidden-server.txt" },
			{ "client", "tests/fixtures/forbidden-client.txt" },
		}
	do
		expectFailure(function()
			RuntimeGuard.validateContent(fixture[1], fixture[2], fs.readFile(fixture[2]))
		end, "P000-BOUNDARY-001")
	end
end)

addTest("P000-TEST-003-environment", function()
	local environment = Environment.loadAndValidate()
	local unsafe = serde.decode("json", fs.readFile("tests/fixtures/environment-unsafe.json"))
	expectFailure(function()
		Environment.validateFixture(unsafe)
	end, "P000-ENV-008")
	expectFailure(function()
		Environment.validateFixture({
			generated_output = { root = "build" },
			rojo = { address = "127.0.0.1" },
			["to" .. "ken"] = "fixture-value",
		})
	end, "P000-ENV-001")

	environment.studio.selected_route = "unsupported"
	expectFailure(function()
		Environment.validateFixture(environment)
	end, "P000-ENV-010")
end)

addTest("P000-TEST-004-source-map", function()
	local workPath = "build/test-work/source-map.json"
	local rojoPath = ToolVerifier.actualToolPath("rojo")
	local result = Common.runBounded(
		rojoPath,
		{ "sourcemap", "default.project.json", "--output", workPath },
		30,
		{ cwd = process.cwd }
	)
	assert(result.ok, "P000-TEST-004 source map command failed")
	ArtifactCore.validateSourceMap(fs.readFile(workPath))
	expectFailure(function()
		ArtifactCore.validateSourceMap(fs.readFile("tests/fixtures/source-map-absolute.json"))
	end, "P000-PATH-002")
	local missingResult = Common.runBounded(rojoPath, {
		"sourcemap",
		"tests/fixtures/project-missing-source.json",
		"--output",
		"build/test-work/missing.json",
	}, 30, { cwd = process.cwd })
	assert(not missingResult.ok, "P000-TEST-004 missing source was accepted")
end)

addTest("P000-TEST-005-tool-clean-path", function()
	local root = Common.getRokitRoot()
	local bin = Common.join(root, "bin")
	local separator = if process.os == "windows" then ";" else ":"
	local lunePath = ToolVerifier.actualToolPath("lune")
	local result = Common.runBounded(lunePath, { "run", "verify-tools" }, 30, {
		cwd = process.cwd,
		env = {
			PATH = bin .. separator,
			ROKIT_ROOT = root,
		},
	})
	assert(result.ok, "P000-TEST-005 clean path verification failed")
end)

addTest("P000-TEST-006-tool-shadow", function()
	local root = Common.getRokitRoot()
	local bin = Common.join(root, "bin")
	local suffix = if process.os == "windows" then ".exe" else ""
	local shadowDir = "build/test-work/shadow"
	Common.ensureDir(shadowDir)
	fs.copy(ToolVerifier.actualToolPath("rojo"), Common.join(shadowDir, "rojo" .. suffix), true)

	local lunePath = ToolVerifier.actualToolPath("lune")
	local separator = if process.os == "windows" then ";" else ":"
	local result = Common.runBounded(lunePath, { "run", "verify-tools" }, 30, {
		cwd = process.cwd,
		env = {
			PATH = shadowDir .. separator .. bin,
			ROKIT_ROOT = root,
		},
	})
	assert(not result.ok, "P000-TEST-006 shadowed executable was accepted")
	assert(
		result.stderr:find("P000-TOOLS-025", 1, true) ~= nil,
		"P000-TEST-006 wrong shadow failure"
	)
end)

addTest("P000-TEST-007-format-lint-negatives", function()
	local formatPath = "build/test-work/format-invalid.luau"
	local lintPath = "build/test-work/lint-invalid.luau"
	local sentinelPath = "build/test-work/sentinel.txt"
	fs.writeFile(formatPath, fs.readFile("tests/fixtures/format-invalid.txt"))
	fs.writeFile(lintPath, fs.readFile("tests/fixtures/lint-invalid.txt"))
	fs.writeFile(sentinelPath, "unchanged\n")

	local formatCheck = Common.runBounded(
		ToolVerifier.actualToolPath("stylua"),
		{ "--check", formatPath },
		30,
		{ cwd = process.cwd }
	)
	assert(not formatCheck.ok, "P000-TEST-007 malformed formatting was accepted")
	local formatFix = Common.runBounded(
		ToolVerifier.actualToolPath("stylua"),
		{ formatPath },
		30,
		{ cwd = process.cwd }
	)
	assert(formatFix.ok, "P000-TEST-007 formatter recovery failed")
	assert(
		fs.readFile(sentinelPath) == "unchanged\n",
		"P000-TEST-007 formatter changed unrelated file"
	)

	local lintCheck = Common.runBounded(
		ToolVerifier.actualToolPath("selene"),
		{ "--no-exclude", "--config", "selene.toml", lintPath },
		30,
		{ cwd = process.cwd }
	)
	assert(not lintCheck.ok, "P000-TEST-007 lint violation was accepted")
	assert(
		lintCheck.stdout:find("unscoped_variables", 1, true) ~= nil,
		"P000-TEST-007 lint id missing"
	)
end)

addTest("P000-TEST-008-artifact-normalization", function()
	local left = { beta = 2, alpha = { "a", "b" } }
	local right = {}
	right.alpha = { "a", "b" }
	right.beta = 2
	assert(
		ArtifactCore.canonicalJson(left) == ArtifactCore.canonicalJson(right),
		"P000-TEST-008 canonical ordering differs"
	)
	expectFailure(function()
		ArtifactCore.assertDeterministicManifest('{"generated_at":"variable"}')
	end, "P000-ARTIFACT-003")
end)

addTest("P000-TEST-009-harness-failures", function()
	local lunePath = ToolVerifier.actualToolPath("lune")
	for _, fixture in
		{
			{ "fail", "P000-HARNESS-FIXTURE-FAIL" },
			{ "crash", "P000-HARNESS-FIXTURE-CRASH" },
			{ "path-escape", "P000-PATH-003" },
			{ "network-attempt", "P000-RUNTIME-001" },
		}
	do
		local result = Common.runBounded(
			lunePath,
			{ "run", "test", "--fixture", fixture[1] },
			10,
			{ cwd = process.cwd }
		)
		assert(not result.ok, "P000-TEST-009 negative fixture passed, " .. fixture[1])
		assert(
			(result.stderr .. result.stdout):find(fixture[2], 1, true) ~= nil,
			"P000-TEST-009 negative fixture lost its id, " .. fixture[1]
		)
	end

	local timeoutResult = Common.runBounded(
		lunePath,
		{ "run", "test", "--fixture", "timeout" },
		1,
		{ cwd = process.cwd }
	)
	assert(timeoutResult.timedOut, "P000-TEST-009 timeout fixture was not terminated")
end)

addTest("P000-TEST-010-mandatory-gate-negatives", function()
	expectFailure(function()
		DocsValidator.validateCommandInventory("```console\nlune run ci\n```")
	end, "P000-DOCS-005")
	expectFailure(function()
		SecretScanner.validateFixture("gh" .. "p_" .. string.rep("a", 36))
	end, "P000-SECRETS-002")

	local validContents = "artifact fixture"
	local sha256, sha512 = Common.hashContents(validContents)
	ArtifactCore.assertHashes(validContents, sha256, sha512)
	ArtifactCore.assertNoToolBoundary({
		{ class_name = "Folder", path = "ReplicatedStorage/Shared/Config" },
		{ class_name = "ModuleScript", path = "ReplicatedStorage/Shared/Config/LaunchConfig" },
	})
	expectFailure(function()
		ArtifactCore.assertNoToolBoundary({
			{ class_name = "Folder", path = "ReplicatedStorage/Shared/Tests" },
		})
	end, "P000-ARTIFACT-002")
	expectFailure(function()
		ArtifactCore.assertNoToolBoundary({
			{ class_name = "Folder", path = "ServerStorage/Config" },
		})
	end, "P000-ARTIFACT-002")
	expectFailure(function()
		ArtifactCore.assertHashes(validContents .. " corrupted", sha256, sha512)
	end, "P000-ARTIFACT-030")
end)

addTest("P000-TEST-011-ci-policy", function()
	local workflowPath = ".github/workflows/foundation.yml"
	local contents = fs.readFile(workflowPath)
	local workflow = serde.decode("yaml", contents)
	assert(workflow.permissions.contents == "read", "P000-CI-POLICY-001 contents permission drift")
	assert(workflow.jobs.linux["runs-on"] == "ubuntu-24.04", "P000-CI-POLICY-002 linux image drift")
	assert(
		workflow.jobs.windows["runs-on"] == "windows-2025",
		"P000-CI-POLICY-003 windows image drift"
	)
	for _, jobName in { "linux", "windows" } do
		local job = workflow.jobs[jobName]
		assert(job["timeout-minutes"] == 20, "P000-CI-POLICY-004 timeout drift")
		for _, step in job.steps do
			if step.uses ~= nil then
				assert(
					step.uses:match("^[%w%-]+/[%w%-]+@[0-9a-f]+$") ~= nil
						and #step.uses:match("@([0-9a-f]+)$") == 40,
					"P000-CI-POLICY-005 action is not commit pinned"
				)
			end
			if step.with ~= nil and step.with["retention-days"] ~= nil then
				assert(step.with["retention-days"] == 3, "P000-CI-POLICY-006 retention drift")
			end
		end
	end
	local lowered = contents:lower()
	assert(not lowered:find("pull_request_target", 1, true), "P000-CI-POLICY-007 unsafe trigger")
	assert(not lowered:find("self-hosted", 1, true), "P000-CI-POLICY-008 paid or trusted runner")
	assert(not lowered:find("secrets.", 1, true), "P000-CI-POLICY-009 external secret reference")
	assert(
		lowered:find("cancel-in-progress: true", 1, true) ~= nil,
		"P000-CI-POLICY-010 cancellation missing"
	)
	assert(
		lowered:find("hashfiles('rokit.toml'", 1, true) ~= nil,
		"P000-CI-POLICY-011 cache digest missing"
	)
end)

table.sort(tests, function(left, right)
	return left.id < right.id
end)

Common.main("test", function()
	Common.assertRepositoryRoot()
	ToolVerifier.verify(true)
	Common.removeGeneratedPath("build/test-work")
	Common.ensureDir("build/test-work")

	local passed = 0
	for _, testCase in tests do
		local ok, result = pcall(testCase.run)
		if not ok then
			error(testCase.id .. ", " .. Common.sanitize(tostring(result)))
		end
		passed += 1
		print("test passed, " .. testCase.id)
	end

	Common.removeGeneratedPath("build/test-work")
	print(string.format("test summary, %d passed, 0 failed", passed))
end)
