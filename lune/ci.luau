--!strict

local process = require("@lune/process")

local ArtifactCore = require("./lib/artifact-core")
local Common = require("./lib/common")
local ToolVerifier = require("./lib/tool-verifier")

type Gate = {
	id: string,
	program: string,
	arguments: { string },
	timeout: number,
}

local function runGate(gate: Gate)
	local result = Common.runBounded(gate.program, gate.arguments, gate.timeout, {
		cwd = process.cwd,
	})
	assert(result.ok, gate.id .. ", exit " .. tostring(result.code) .. ", " .. result.stderr)
	print("ci gate passed, " .. gate.id)
end

Common.main("ci", function()
	Common.assertRepositoryRoot()
	ToolVerifier.verify(true)
	print("ci gate passed, P000-CI-001-tools")

	Common.ensureDir("build")
	local lunePath = ToolVerifier.actualToolPath("lune")
	local gates: { Gate } = {
		{
			id = "P000-CI-002-format",
			program = ToolVerifier.actualToolPath("stylua"),
			arguments = { "--check", "." },
			timeout = 60,
		},
		{
			id = "P000-CI-003-lint",
			program = ToolVerifier.actualToolPath("selene"),
			arguments = { "." },
			timeout = 60,
		},
		{
			id = "P000-CI-004-tests",
			program = lunePath,
			arguments = { "run", "test" },
			timeout = 180,
		},
		{
			id = "P000-CI-005-source-map",
			program = ToolVerifier.actualToolPath("rojo"),
			arguments = {
				"sourcemap",
				"default.project.json",
				"--output",
				"build/infinite-card-collector.sourcemap.json",
			},
			timeout = 60,
		},
		{
			id = "P000-CI-006-artifact",
			program = lunePath,
			arguments = { "run", "artifact" },
			timeout = 240,
		},
		{
			id = "P000-CI-007-docs",
			program = lunePath,
			arguments = { "run", "docs" },
			timeout = 60,
		},
		{
			id = "P000-CI-008-secrets",
			program = lunePath,
			arguments = { "run", "secrets" },
			timeout = 60,
		},
	}

	for _, gate in gates do
		runGate(gate)
	end
	ArtifactCore.inspectPacket()
	print("ci gate passed, P000-CI-009-artifact-inspection")
	print("ci summary, 9 passed, 0 failed")
end)
