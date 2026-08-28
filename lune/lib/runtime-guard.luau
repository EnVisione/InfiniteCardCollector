--!strict

local fs = require("@lune/fs")
local serde = require("@lune/serde")

local Common = require("./common")

local RuntimeGuard = {}

local forbiddenRepositoryEntries = {
	["Packages"] = true,
	["Vendor"] = true,
	["aftman.toml"] = true,
	["default.project.lua"] = true,
	["foreman.toml"] = true,
	["package-lock.json"] = true,
	["pesde.lock"] = true,
	["pesde.toml"] = true,
	["wally.lock"] = true,
	["wally.toml"] = true,
}

local forbiddenRuntimeFragments = {
	"@lune/",
	"game:httpget",
	"httpservice",
	"insertservice",
	"loadasset",
	"loadstring",
	"process.exec",
	"tests/",
	"tool-storage",
}

local boundaryFragments = {
	shared = {
		"datastoreservice",
		"players",
		"serverscriptservice",
		"serverstorage",
		"startergui",
		"starterplayer",
	},
	server = {
		"playergui",
		"playerscripts",
		"startergui",
		"starterplayerscripts",
	},
	client = {
		"datastoreservice",
		"serverscriptservice",
		"serverstorage",
	},
}

local function collectMappedPaths(node: any, mapped: { string })
	if type(node) ~= "table" then
		return
	end
	if type(node["$path"]) == "string" then
		table.insert(mapped, Common.assertSafeRelativePath(node["$path"]))
	end
	for key, child in node do
		if key ~= "$properties" and key ~= "$path" and type(child) == "table" then
			collectMappedPaths(child, mapped)
		end
	end
end

function RuntimeGuard.validateProject(project: any): { string }
	assert(project.name == "InfiniteCardCollector", "P000-PROJECT-001 project name mismatch")
	assert(project.serveAddress == "127.0.0.1", "P000-PROJECT-002 project serve address is unsafe")
	assert(project.tree["$className"] == "DataModel", "P000-PROJECT-003 root class mismatch")
	assert(
		project.tree.ReplicatedStorage.Shared["$path"] == "src/shared",
		"P000-PROJECT-004 shared mapping mismatch"
	)
	assert(
		project.tree.ServerScriptService.Server["$path"] == "src/server",
		"P000-PROJECT-005 server mapping mismatch"
	)
	assert(
		project.tree.StarterPlayer.StarterPlayerScripts.Client["$path"] == "src/client",
		"P000-PROJECT-006 client mapping mismatch"
	)
	assert(
		project.tree.ServerStorage.Assets["$className"] == "Folder",
		"P000-PROJECT-007 asset boundary missing"
	)
	assert(
		project.tree.StarterGui.App["$className"] == "ScreenGui"
			and project.tree.StarterGui.App.AppRoot["$className"] == "Frame",
		"P000-PROJECT-008 gui boundary missing"
	)

	local mapped = {}
	collectMappedPaths(project.tree, mapped)
	table.sort(mapped)
	local seen = {}
	for _, path in mapped do
		assert(not seen[path], "P000-PROJECT-009 duplicate source mapping, " .. path)
		seen[path] = true
		assert(
			fs.isDir(path) or fs.isFile(path),
			"P000-PROJECT-010 mapped source missing, " .. path
		)
	end
	assert(#mapped == 3, "P000-RUNTIME-005 unexpected mapped source count")
	assert(mapped[1] == "src/client", "P000-RUNTIME-006 client mapping missing")
	assert(mapped[2] == "src/server", "P000-RUNTIME-007 server mapping missing")
	assert(mapped[3] == "src/shared", "P000-RUNTIME-008 shared mapping missing")
	return mapped
end

function RuntimeGuard.validateContent(boundary: string, path: string, contents: string)
	local lowered = contents:lower()
	for _, fragment in forbiddenRuntimeFragments do
		assert(
			not lowered:find(fragment, 1, true),
			"P000-RUNTIME-001 forbidden runtime capability, " .. path
		)
	end
	assert(
		lowered:match("require%s*%(%s*%d+") == nil,
		"P000-RUNTIME-002 remote asset require, " .. path
	)
	assert(lowered:match("https?://") == nil, "P000-RUNTIME-003 remote url, " .. path)
	for _, fragment in boundaryFragments[boundary] or {} do
		assert(
			not lowered:find(fragment, 1, true),
			"P000-BOUNDARY-001 forbidden dependency, " .. path
		)
	end
end

function RuntimeGuard.validateStrictFile(path: string, contents: string)
	assert(contents:sub(1, 10) == "--!strict\n", "P000-STRICT-001 strict header missing, " .. path)
end

function RuntimeGuard.validateRepository()
	for name in forbiddenRepositoryEntries do
		assert(
			not fs.isFile(name) and not fs.isDir(name),
			"P000-RUNTIME-004 external runtime package, " .. name
		)
	end

	local project = serde.decode("json", fs.readFile("default.project.json"))
	RuntimeGuard.validateProject(project)

	local allFiles = {}
	for _, root in { "src", "lune" } do
		for _, path in Common.listFiles(root) do
			table.insert(allFiles, path)
		end
	end
	table.sort(allFiles)

	for _, path in allFiles do
		if path:match("%.luau$") then
			local contents = fs.readFile(path)
			RuntimeGuard.validateStrictFile(path, contents)
			if path:sub(1, 11) == "src/shared/" then
				RuntimeGuard.validateContent("shared", path, contents)
			elseif path:sub(1, 11) == "src/server/" then
				RuntimeGuard.validateContent("server", path, contents)
			elseif path:sub(1, 11) == "src/client/" then
				RuntimeGuard.validateContent("client", path, contents)
			end
		end
		local bytes = fs.readFile(path)
		assert(bytes:sub(1, 4) ~= "\127ELF", "P000-RUNTIME-009 elf executable tracked, " .. path)
		assert(bytes:sub(1, 2) ~= "MZ", "P000-RUNTIME-010 pe executable tracked, " .. path)
	end
end

return RuntimeGuard
