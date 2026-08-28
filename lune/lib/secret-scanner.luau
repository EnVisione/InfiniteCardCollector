--!strict

local fs = require("@lune/fs")
local process = require("@lune/process")

local Common = require("./common")

local SecretScanner = {}

local protectedPathPrefixes = {
	"docs/general/phases/",
}

local protectedExactPaths = {
	["docs/general/plan.handoff.json"] = true,
	["docs/general/plan.index.json"] = true,
	["docs/general/plan.md"] = true,
	["docs/plan/goal.md"] = true,
}

local function permitsCreationPath(path: string): boolean
	if protectedExactPaths[path] then
		return true
	end
	for _, prefix in protectedPathPrefixes do
		if path:sub(1, #prefix) == prefix then
			return true
		end
	end
	return false
end

local function trackedCandidatePaths(): { string }
	local result = Common.runBounded(
		"git",
		{ "ls-files", "--cached", "--others", "--exclude-standard", "-z" },
		20,
		{ cwd = process.cwd }
	)
	assert(result.ok, "P000-SECRETS-001 tracked inventory unavailable")
	local paths = {}
	for path in result.rawStdout:gmatch("([^%z]+)%z") do
		table.insert(paths, Common.normalizePath(path))
	end
	table.sort(paths)
	return paths
end

local function assertNoSecret(path: string, contents: string)
	local lowered = contents:lower()
	local githubClassicPrefix = "gh" .. "p_"
	local githubFinePrefix = "github" .. "_pat_"
	local robloxCookieMarker = ".roblox" .. "security"
	local privateKeyStart = "-----be" .. "gin "
	local privateKeyEnd = "private" .. " key-----"

	assert(
		not lowered:find(githubClassicPrefix, 1, true),
		"P000-SECRETS-002 credential pattern, " .. path
	)
	assert(
		not lowered:find(githubFinePrefix, 1, true),
		"P000-SECRETS-003 credential pattern, " .. path
	)
	assert(
		not lowered:find(robloxCookieMarker, 1, true),
		"P000-SECRETS-004 credential pattern, " .. path
	)
	assert(
		not (lowered:find(privateKeyStart, 1, true) and lowered:find(privateKeyEnd, 1, true)),
		"P000-SECRETS-005 private key pattern, " .. path
	)
	local awsPrefix = "AK" .. "IA"
	assert(
		contents:match(awsPrefix .. string.rep("[A-Z0-9]", 16)) == nil,
		"P000-SECRETS-006 credential pattern, " .. path
	)
	assert(
		lowered:match("password%s*[:=]%s*[%\"'][^%\"']+[%\"']") == nil,
		"P000-SECRETS-007 password assignment, " .. path
	)

	if not permitsCreationPath(path) then
		assert(not lowered:find("/" .. "home/", 1, true), "P000-SECRETS-008 machine path, " .. path)
		local macUserPrefix = "/" .. "users/"
		assert(
			lowered:sub(1, #macUserPrefix) ~= macUserPrefix
				and not lowered:find("\n" .. macUserPrefix, 1, true),
			"P000-SECRETS-009 machine path, " .. path
		)
		assert(
			lowered:match("%a:[\\/]users[\\/]") == nil,
			"P000-SECRETS-010 machine path, " .. path
		)
	end
end

function SecretScanner.scan()
	local paths = trackedCandidatePaths()
	assert(#paths > 0, "P000-SECRETS-011 tracked inventory is empty")
	for _, path in paths do
		assert(not path:find("[%z\1-\31\127]"), "P000-SECRETS-012 control character in path")
		assert(path ~= "config/environment.local.json", "P000-SECRETS-013 local override tracked")
		assert(not path:match("%.log$"), "P000-SECRETS-014 log file tracked")
		if fs.isFile(path) then
			assertNoSecret(path, fs.readFile(path))
		end
	end

	for _, artifactPath in
		{
			"build/artifact-manifest.json",
			"build/infinite-card-collector.rbxlx",
			"build/infinite-card-collector.sourcemap.json",
		}
	do
		if fs.isFile(artifactPath) then
			assertNoSecret(artifactPath, fs.readFile(artifactPath))
		end
	end
	return paths
end

function SecretScanner.validateFixture(contents: string)
	assertNoSecret("fixture", contents)
end

return SecretScanner
