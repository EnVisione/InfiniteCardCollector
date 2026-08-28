--!strict

local fs = require("@lune/fs")
local process = require("@lune/process")
local serde = require("@lune/serde")
local stdio = require("@lune/stdio")

local Common = {}

local function escapePattern(value: string): string
	return value:gsub("([^%w])", "%%%1")
end

function Common.trim(value: string): string
	return value:match("^%s*(.-)%s*$") or ""
end

function Common.normalizePath(path: string): string
	local normalized = path:gsub("\\", "/"):gsub("/+", "/")
	if #normalized > 1 then
		normalized = normalized:gsub("/$", "")
	end
	return normalized
end

function Common.isAbsolutePath(path: string): boolean
	local normalized = Common.normalizePath(path)
	return normalized:sub(1, 1) == "/" or normalized:match("^%a:/") ~= nil
end

function Common.assertSafeRelativePath(path: string): string
	local normalized = Common.normalizePath(path)
	assert(normalized ~= "", "P000-PATH-001 empty path")
	assert(not Common.isAbsolutePath(normalized), "P000-PATH-002 absolute path")
	for segment in normalized:gmatch("[^/]+") do
		assert(segment ~= "..", "P000-PATH-003 path escape")
		assert(segment ~= ".", "P000-PATH-004 ambiguous path")
	end
	return normalized
end

function Common.join(...: string): string
	local parts = { ... }
	return Common.normalizePath(table.concat(parts, "/"))
end

function Common.readJson(path: string): any
	return serde.decode("json", fs.readFile(Common.assertSafeRelativePath(path)))
end

function Common.hashContents(contents: string): (string, string)
	return serde.hash("sha256", contents), serde.hash("sha512", contents)
end

function Common.hashFile(path: string): (string, string)
	return Common.hashContents(fs.readFile(path))
end

function Common.sortedKeys(value: { [string]: any }): { string }
	local keys = {}
	for key in value do
		table.insert(keys, key)
	end
	table.sort(keys)
	return keys
end

function Common.listFiles(root: string, excludedNames: { [string]: boolean }?): { string }
	local safeRoot = Common.assertSafeRelativePath(root)
	local results = {}
	local excluded = excludedNames or {}

	local function visit(path: string)
		local names = fs.readDir(path)
		table.sort(names)
		for _, name in names do
			if not excluded[name] then
				local child = Common.join(path, name)
				local metadata = fs.metadata(child)
				assert(
					metadata.kind ~= "symlink",
					"P000-PATH-005 symlink is not allowed, " .. child
				)
				if metadata.kind == "dir" then
					visit(child)
				elseif metadata.kind == "file" then
					table.insert(results, child)
				end
			end
		end
	end

	visit(safeRoot)
	table.sort(results)
	return results
end

function Common.removeGeneratedPath(path: string)
	local safePath = Common.assertSafeRelativePath(path)
	assert(
		safePath == "build"
			or safePath:sub(1, 6) == "build/"
			or safePath == "coverage"
			or safePath:sub(1, 9) == "coverage/",
		"P000-PATH-006 removal outside generated roots"
	)
	if fs.isDir(safePath) then
		fs.removeDir(safePath)
	elseif fs.isFile(safePath) then
		fs.removeFile(safePath)
	end
end

function Common.ensureDir(path: string)
	local safePath = Common.assertSafeRelativePath(path)
	if not fs.isDir(safePath) then
		fs.writeDir(safePath)
	end
end

function Common.sanitize(value: string): string
	local sanitized = value:gsub("[%z\1-\8\11\12\14-\31\127]", "?")
	local replacements = {
		{ process.cwd, "$REPOSITORY" },
		{ process.env.ROKIT_ROOT, "$ROKIT_ROOT" },
		{ process.env.HOME, "$USER_HOME" },
		{ process.env.USERPROFILE, "$USER_HOME" },
	}
	for _, replacement in replacements do
		local source = replacement[1]
		if source ~= nil and source ~= "" then
			sanitized = sanitized:gsub(
				escapePattern(Common.normalizePath(source)),
				replacement[2] :: string
			)
			sanitized = sanitized:gsub(escapePattern(source), replacement[2] :: string)
		end
	end
	return sanitized
end

function Common.runBounded(
	program: string,
	params: { string },
	timeoutSeconds: number,
	options: any?
): any
	assert(timeoutSeconds > 0 and timeoutSeconds <= 600, "P000-PROCESS-001 invalid timeout")

	local supervisor: string
	local supervisorParams: { string }
	if process.os == "linux" then
		supervisor = if fs.isFile("/usr/bin/timeout") then "/usr/bin/timeout" else "/bin/timeout"
		assert(fs.isFile(supervisor), "P000-PROCESS-002 timeout supervisor is missing")
		supervisorParams = {
			"--foreground",
			"--signal=TERM",
			"--kill-after=5s",
			tostring(timeoutSeconds) .. "s",
			program,
		}
		for _, param in params do
			table.insert(supervisorParams, param)
		end
	elseif process.os == "windows" then
		local windowsRoot = process.env.WINDIR or "C:/Windows"
		supervisor = Common.join(windowsRoot, "System32/WindowsPowerShell/v1.0/powershell.exe")
		assert(fs.isFile(supervisor), "P000-PROCESS-003 powershell supervisor is missing")
		local payload = serde.encode("json", {
			program = program,
			arguments = params,
			timeout_seconds = timeoutSeconds,
		})
		supervisorParams = {
			"-NoLogo",
			"-NoProfile",
			"-NonInteractive",
			"-ExecutionPolicy",
			"Bypass",
			"-File",
			"scripts/run-bounded.ps1",
			"-Payload",
			payload,
		}
	else
		error("P000-PROCESS-004 unsupported process supervisor")
	end

	local execOk, result = pcall(function()
		return process.exec(supervisor, supervisorParams, options)
	end)
	if not execOk then
		return {
			ok = false,
			code = -1,
			stdout = "",
			stderr = Common.sanitize(tostring(result)),
			timedOut = false,
		}
	end
	local timedOut = result.code == 124 or result.code == 137
	return {
		ok = result.ok and not timedOut,
		code = result.code,
		rawStderr = result.stderr,
		rawStdout = result.stdout,
		stdout = Common.sanitize(result.stdout),
		stderr = Common.sanitize(result.stderr),
		timedOut = timedOut,
	}
end

function Common.getRokitRoot(): string
	local configured = process.env.ROKIT_ROOT
	if configured ~= nil and configured ~= "" then
		return Common.normalizePath(configured)
	end
	local userHome = if process.os == "windows" then process.env.USERPROFILE else process.env.HOME
	assert(userHome ~= nil and userHome ~= "", "P000-TOOLS-001 user home is unavailable")
	return Common.join(Common.normalizePath(userHome), ".rokit")
end

function Common.assertRepositoryRoot()
	assert(fs.isFile("default.project.json"), "P000-REPOSITORY-001 default.project.json is missing")
	assert(fs.isFile("config/tool-artifacts.json"), "P000-REPOSITORY-002 tool registry is missing")
	assert(fs.isFile("rokit.toml"), "P000-REPOSITORY-003 rokit.toml is missing")
end

function Common.main(label: string, callback: () -> ())
	local ok, result = pcall(callback)
	if not ok then
		stdio.ewrite(label .. " failed, " .. Common.sanitize(tostring(result)) .. "\n")
		process.exit(1)
	end
end

return Common
