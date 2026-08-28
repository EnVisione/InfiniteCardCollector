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
	"docs/troubleshooting/toolchain.md",
	"docs/verification/phase-000-foundation.md",
	"docs/verification/phase-000-tool-provenance.md",
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
			"conditional compatibility",
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

	local overview = fs.readFile("docs/general/documentation.md")
	assert(
		overview:find("Implemented Foundation", 1, true) ~= nil,
		"P000-DOCS-009 overview status stale"
	)
	assert(
		overview:find("There are no valid build or test commands yet", 1, true) == nil,
		"P000-DOCS-010 obsolete overview claim"
	)

	local paths = markdownPaths()
	for _, path in paths do
		validateLinks(path, fs.readFile(path))
	end
	return paths
end

return DocsValidator
