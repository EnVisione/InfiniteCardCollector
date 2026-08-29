--!strict

local MemoryProfileAdapter = {}

function MemoryProfileAdapter.new(copy: (any) -> any): any
	local adapter = {
		values = {},
	}

	function adapter:update(key: string, transform: (any) -> any): boolean
		local current = self.values[key]
		local ok, nextValue = pcall(transform, if current ~= nil then copy(current) else nil)
		if not ok then
			return false
		end
		self.values[key] = if nextValue ~= nil then copy(nextValue) else nil
		return true
	end

	return adapter
end

return table.freeze(MemoryProfileAdapter)
