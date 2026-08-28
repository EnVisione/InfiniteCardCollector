--!strict

local Common = require("./lib/common")
local ToolVerifier = require("./lib/tool-verifier")

Common.main("verify tools", function()
	ToolVerifier.verify(false)
end)
