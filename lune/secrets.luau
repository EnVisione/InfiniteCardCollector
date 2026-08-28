--!strict

local Common = require("./lib/common")
local SecretScanner = require("./lib/secret-scanner")

Common.main("secrets", function()
	local paths = SecretScanner.scan()
	print(string.format("secrets verified, %d repository paths", #paths))
end)
