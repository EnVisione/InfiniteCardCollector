--!strict

local ComponentPool = {}

function ComponentPool.new(
	factory: (string) -> any,
	reset: (any) -> (),
	maximumPerKind: number
): any
	assert(maximumPerKind > 0 and maximumPerKind % 1 == 0, "P002-POOL-001 maximum invalid")
	local pool = {
		available = {},
		active = {},
		created = 0,
	}

	function pool:acquire(kind: string): any
		local bucket = self.available[kind]
		local component
		if bucket ~= nil and #bucket > 0 then
			component = table.remove(bucket)
		else
			component = factory(kind)
			self.created += 1
		end
		assert(self.active[component] == nil, "P002-POOL-002 component already active")
		self.active[component] = kind
		return component
	end

	function pool:release(component: any): boolean
		local kind = self.active[component]
		if kind == nil then
			return false
		end
		self.active[component] = nil
		reset(component)
		local bucket = self.available[kind]
		if bucket == nil then
			bucket = {}
			self.available[kind] = bucket
		end
		if #bucket < maximumPerKind then
			table.insert(bucket, component)
		end
		return true
	end

	return pool
end

return table.freeze(ComponentPool)
