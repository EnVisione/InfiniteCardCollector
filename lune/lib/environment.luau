--!strict

local Common = require("./common")

local Environment = {}

local forbiddenKeyFragments = {
	"credential",
	"cookie",
	"password",
	"private",
	"secret",
	"token",
}

local function assertNoSecretShape(value: any, path: string)
	if type(value) ~= "table" then
		return
	end
	for key, child in value do
		local keyText = tostring(key):lower()
		for _, fragment in forbiddenKeyFragments do
			assert(not keyText:find(fragment, 1, true), "P000-ENV-001 secret-like key, " .. path)
		end
		assertNoSecretShape(child, path .. "." .. keyText)
	end
end

function Environment.loadAndValidate(): any
	local config = Common.readJson("config/environment.json")
	assert(config.schema_version == 1, "P000-ENV-002 unsupported environment schema")
	assert(config.rojo.address == "127.0.0.1", "P000-ENV-003 rojo address must be loopback")
	assert(
		type(config.rojo.port) == "number"
			and config.rojo.port % 1 == 0
			and config.rojo.port >= 1024
			and config.rojo.port <= 65535,
		"P000-ENV-004 rojo port is invalid"
	)
	assert(config.generated_output.root == "build", "P000-ENV-005 generated root must be build")
	assert(
		config.local_override == "config/environment.local.json",
		"P000-ENV-006 local override path is invalid"
	)
	assert(
		config.studio.connection == "loopback",
		"P000-ENV-007 studio connection must be loopback"
	)
	assertNoSecretShape(config, "environment")
	return config
end

function Environment.validateFixture(config: any)
	assertNoSecretShape(config, "fixture")
	assert(config.rojo.address == "127.0.0.1", "P000-ENV-008 unsafe fixture address")
	Common.assertSafeRelativePath(config.generated_output.root)
end

return Environment
