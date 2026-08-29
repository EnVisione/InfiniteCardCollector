--!strict

local RobloxProfileAdapter = {}

function RobloxProfileAdapter.new(dataStore: any): any
	local adapter = {}

	function adapter:update(key: string, transform: (any) -> any): boolean
		local ok = pcall(function()
			dataStore:UpdateAsync(key, transform)
		end)
		return ok
	end

	return adapter
end

return table.freeze(RobloxProfileAdapter)
