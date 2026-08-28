--!strict

local Common = require("./lib/common")
local DocsValidator = require("./lib/docs-validator")

Common.main("docs", function()
	local paths = DocsValidator.validate()
	print(string.format("docs verified, %d markdown files", #paths))
end)
