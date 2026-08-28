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

local function validateStudio(studio: any)
	assert(studio.connection == "loopback", "P000-ENV-007 studio connection must be loopback")
	assert(
		type(studio.accepted_routes) == "table"
			and #studio.accepted_routes == 2
			and studio.accepted_routes[1] == "native-supported-platform"
			and studio.accepted_routes[2] == "qualified-vinegar",
		"P000-ENV-009 studio acceptance routes are invalid"
	)
	assert(
		studio.selected_route == studio.accepted_routes[1]
			or studio.selected_route == studio.accepted_routes[2],
		"P000-ENV-010 selected studio route is invalid"
	)
	assert(
		type(studio.vinegar) == "table"
			and studio.vinegar.runtime == "actual-windows-studio-under-wine",
		"P000-ENV-011 vinegar runtime boundary is invalid"
	)
	assert(studio.vinegar.mcp_required == true, "P000-ENV-012 vinegar mcp requirement is missing")
	assert(
		studio.vinegar.native_linux_support == false,
		"P000-ENV-013 native linux studio support cannot be claimed"
	)
end

function Environment.loadAndValidate(): any
	local config = Common.readJson("config/environment.json")
	assert(config.schema_version == 2, "P000-ENV-002 unsupported environment schema")
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
	validateStudio(config.studio)
	assertNoSecretShape(config, "environment")
	return config
end

function Environment.validateFixture(config: any)
	assertNoSecretShape(config, "fixture")
	assert(config.rojo.address == "127.0.0.1", "P000-ENV-008 unsafe fixture address")
	Common.assertSafeRelativePath(config.generated_output.root)
	if config.studio ~= nil then
		validateStudio(config.studio)
	end
end

return Environment
