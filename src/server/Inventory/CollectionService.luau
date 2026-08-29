--!strict

local CollectionService = {}

local function collection(profile: any, kind: string): any
	local target = profile.discovery[kind]
	assert(type(target) == "table", "P002-COLLECTION-001 discovery kind missing")
	return target
end

function CollectionService.new(): any
	local service = {}

	function service:discover(profile: any, kind: string, stableId: string): boolean
		assert(type(stableId) == "string" and stableId ~= "", "P002-COLLECTION-002 id invalid")
		local target = collection(profile, kind)
		local wasNew = target[stableId] ~= true
		target[stableId] = true
		return wasNew
	end

	function service:isDiscovered(profile: any, kind: string, stableId: string): boolean
		return collection(profile, kind)[stableId] == true
	end

	function service:recordBest(profile: any, recordId: string, value: number): boolean
		assert(
			type(recordId) == "string" and recordId ~= "",
			"P002-COLLECTION-003 record id invalid"
		)
		assert(
			type(value) == "number" and value == value and value >= 0,
			"P002-COLLECTION-004 value invalid"
		)
		local previous = profile.bestRecords[recordId]
		if previous ~= nil and previous >= value then
			return false
		end
		profile.bestRecords[recordId] = value
		return true
	end

	return service
end

return table.freeze(CollectionService)
