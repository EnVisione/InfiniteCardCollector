--!strict

local fs = require("@lune/fs")

local Common = require("./common")

local DocsValidator = {}

local requiredDocuments = {
	"README.md",
	"docs/README.md",
	"docs/general/documentation.md",
	"docs/operations/development-setup.md",
	"docs/test/phase-000-toolchain.md",
	"docs/test/phase-001-calculation-contracts.md",
	"docs/implementation/phase-002-runtime.md",
	"docs/test/phase-002-network-and-security.md",
	"docs/test/phase-002-profile-and-transactions.md",
	"docs/test/phase-002-inventory-and-rendering.md",
	"docs/test/phase-002-recovery-workflow.md",
	"docs/troubleshooting/toolchain.md",
	"docs/troubleshooting/profile-and-recovery.md",
	"docs/verification/phase-000-foundation.md",
	"docs/verification/phase-000-tool-provenance.md",
	"docs/verification/phase-001-calculation-contracts.md",
	"docs/verification/phase-002-recoverable-vertical-slice.md",
}

local exactCommands = {
	"rokit install",
	"lune run verify-tools",
	"stylua .",
	"stylua --check .",
	"selene .",
	"lune run test",
	"rojo sourcemap default.project.json --output build/infinite-card-collector.sourcemap.json",
	"rojo build default.project.json --output build/infinite-card-collector.rbxlx",
	"rojo serve default.project.json --address 127.0.0.1 --port 34872",
	"lune run artifact",
	"lune run docs",
	"lune run secrets",
	"lune run ci",
}

local function directoryOf(path: string): string
	return path:match("^(.*)/[^/]+$") or ""
end

local function resolveLink(sourcePath: string, target: string): string
	local cleanTarget = target:gsub("^<", ""):gsub(">$", "")
	cleanTarget = cleanTarget:match("^[^#?]+") or ""
	if cleanTarget == "" then
		return sourcePath
	end
	assert(not Common.isAbsolutePath(cleanTarget), "P000-DOCS-001 absolute local link")

	local segments = {}
	local sourceDirectory = directoryOf(sourcePath)
	for segment in sourceDirectory:gmatch("[^/]+") do
		table.insert(segments, segment)
	end
	for segment in Common.normalizePath(cleanTarget):gmatch("[^/]+") do
		if segment == ".." then
			assert(#segments > 0, "P000-DOCS-002 link escapes repository")
			table.remove(segments)
		elseif segment ~= "." and segment ~= "" then
			table.insert(segments, segment)
		end
	end
	return table.concat(segments, "/")
end

local function markdownPaths(): { string }
	local paths = { "README.md" }
	for _, path in Common.listFiles("docs") do
		if path:match("%.md$") then
			table.insert(paths, path)
		end
	end
	table.sort(paths)
	return paths
end

local function validateLinks(path: string, contents: string)
	for target in contents:gmatch("%[[^%]]*%]%(([^%)]+)%)") do
		local lowered = target:lower()
		if not lowered:match("^https?://") and not lowered:match("^mailto:") then
			local resolved = resolveLink(path, target)
			assert(fs.isFile(resolved), "P000-DOCS-003 broken link, " .. path .. ", " .. resolved)
		end
	end
end

function DocsValidator.validateCommandInventory(contents: string)
	local fencedCommands = {}
	for block in contents:gmatch("```[%w]*\n(.-)```") do
		table.insert(fencedCommands, block)
	end
	local commandText = table.concat(fencedCommands, "\n")
	for _, command in exactCommands do
		assert(
			commandText:find(command, 1, true) ~= nil,
			"P000-DOCS-005 command missing, " .. command
		)
	end
end

function DocsValidator.validate()
	for _, path in requiredDocuments do
		assert(fs.isFile(path), "P000-DOCS-004 required document missing, " .. path)
	end

	local setup = fs.readFile("docs/operations/development-setup.md")
	DocsValidator.validateCommandInventory(setup)

	for _, phrase in
		{
			"Linux x86_64",
			"Windows x86_64",
			"native Roblox Studio",
			"qualified Vinegar Studio route",
			"actual Windows Roblox Studio binary",
			"no official native Linux Studio support",
			"build/infinite-card-collector.rbxlx",
			"config/environment.local.json",
			"docs/general/plan.md",
			"docs/plan/goal.md",
		}
	do
		assert(
			setup:find(phrase, 1, true) ~= nil,
			"P000-DOCS-006 setup contract missing, " .. phrase
		)
	end

	local readme = fs.readFile("README.md")
	assert(
		readme:find("reproducible foundation toolchain", 1, true) ~= nil,
		"P000-DOCS-007 readme status stale"
	)
	assert(
		readme:find("No Roblox place, Luau source tree, executable build toolchain", 1, true) == nil,
		"P000-DOCS-008 obsolete readme claim"
	)
	for _, phrase in
		{
			"Phase 000, Phase 001, and Phase 002 are integrated and signed",
			"Phase 003 is active",
			"Phase 003 entry evidence",
			"qualified Vinegar route",
		}
	do
		assert(
			readme:find(phrase, 1, true) ~= nil,
			"P001-DOCS-001 readme contract missing, " .. phrase
		)
	end

	local overview = fs.readFile("docs/general/documentation.md")
	assert(
		overview:find("Implemented Foundation", 1, true) ~= nil,
		"P000-DOCS-009 overview status stale"
	)
	assert(
		overview:find("There are no valid build or test commands yet", 1, true) == nil,
		"P000-DOCS-010 obsolete overview claim"
	)
	for _, phrase in
		{
			"Implemented Phase 001 Shared Contracts",
			"catalogVersion = 1",
			"configVersion = 1",
			"perfect_sum_accuracy",
			"half up rounding",
			"client safe launch projection",
		}
	do
		assert(
			overview:find(phrase, 1, true) ~= nil,
			"P001-DOCS-002 overview contract missing, " .. phrase
		)
	end

	local phase001Test = fs.readFile("docs/test/phase-001-calculation-contracts.md")
	for _, phrase in
		{
			"test summary, 27 passed, 0 failed",
			"tests/phase001/expected-hashes.json",
			"rojo serve default.project.json --address 127.0.0.1 --port 34872",
			"Phase001FormationId",
			"Evidence Invalidation and Recovery",
		}
	do
		assert(
			phase001Test:find(phrase, 1, true) ~= nil,
			"P001-DOCS-003 test contract missing, " .. phrase
		)
	end

	local phase001Evidence = fs.readFile("docs/verification/phase-001-calculation-contracts.md")
	for _, phrase in
		{
			"27 tests",
			"276 Joker pairs",
			"5.55 to 1",
			"Studio comparison",
			"Candidate and Integration Closure",
		}
	do
		assert(
			phase001Evidence:find(phrase, 1, true) ~= nil,
			"P001-DOCS-004 evidence contract missing, " .. phrase
		)
	end

	local staleStudioClaims = {
		"native Roblox Studio on a Roblox supported operating system remains a mandatory Phase 000 gate",
		"Vinegar cannot replace native Studio evidence",
		"never replaces native Roblox Studio acceptance",
		"The native Studio procedure remains pending",
		"never substitutes for the native Studio gate",
		"Vinegar is conditional Linux compatibility",
	}
	for _, path in requiredDocuments do
		local contents = fs.readFile(path):lower()
		for _, claim in staleStudioClaims do
			assert(
				contents:find(claim:lower(), 1, true) == nil,
				"P000-DOCS-011 obsolete studio claim, " .. path
			)
		end
	end

	for _, phrase in
		{
			"Implemented Phase 002 Runtime",
			"24 action registry",
			"receipt version 1",
			"1,000,000 encoded bytes",
			"1,500,000 bytes",
			"62 tests",
		}
	do
		assert(
			overview:find(phrase, 1, true) ~= nil,
			"P002-DOCS-001 overview contract missing, " .. phrase
		)
	end

	local phase002Evidence =
		fs.readFile("docs/verification/phase-002-recoverable-vertical-slice.md")
	for _, phrase in
		{
			"52 tests with 0 failures",
			"c8bef331e4681bf350cdf51eceb8425b87b4452679ba8183f9142d620d4e2e8a",
			"request.replay_conflict",
			"Static low graphics",
			"The isolated Roblox gate is now exercised",
		}
	do
		assert(
			phase002Evidence:find(phrase, 1, true) ~= nil,
			"P002-DOCS-002 evidence contract missing, " .. phrase
		)
	end

	local paths = markdownPaths()
	for _, path in paths do
		validateLinks(path, fs.readFile(path))
	end
	return paths
end

return DocsValidator
