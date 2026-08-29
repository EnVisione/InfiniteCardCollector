--!strict

local ProfileCodec = {}

ProfileCodec.version = 1

local domainToSaved = {
	schemaVersion = "v",
	catalogVersion = "cv",
	configVersion = "fv",
	revision = "r",
	createdAt = "ca",
	lastSeenAt = "la",
	activeSeconds = "as",
	currencies = "c",
	cards = "ci",
	jokers = "ji",
	arcanaStacks = "aa",
	reservedSouls = "rs",
	activeDeck = "d",
	activeJokers = "j",
	activeSoul = "s",
	discovery = "x",
	bestRecords = "b",
	pity = "p",
	pendingPacks = "pp",
	boosts = "bo",
	daily = "dy",
	tutorial = "tu",
	tradeHistory = "th",
	processedOperations = "op",
	operationOrder = "oo",
	replayBarrier = "rb",
	settings = "se",
	moderation = "m",
	session = "ss",
}

local savedToDomain = {}
for domainKey, savedKey in domainToSaved do
	savedToDomain[savedKey] = domainKey
end

local function sortedPairs(map: { [string]: number }): { any }
	local keys = {}
	for key in map do
		table.insert(keys, key)
	end
	table.sort(keys)
	local result = {}
	for _, key in keys do
		table.insert(result, { key, map[key] })
	end
	return result
end

local function restorePairs(entries: { any }): { [string]: number }
	local result = {}
	for _, entry in entries do
		assert(type(entry) == "table" and #entry == 2, "P002-CODEC-001 pair invalid")
		assert(type(entry[1]) == "string", "P002-CODEC-002 pair key invalid")
		assert(result[entry[1]] == nil, "P002-CODEC-003 pair duplicate")
		result[entry[1]] = entry[2]
	end
	return result
end

local function sortedFlags(map: { [string]: boolean }): { string }
	local result = {}
	for stableId, discovered in map do
		assert(type(stableId) == "string" and stableId ~= "", "P002-CODEC-007 flag key invalid")
		assert(discovered == true, "P002-CODEC-008 flag value invalid")
		table.insert(result, stableId)
	end
	table.sort(result)
	return result
end

local function restoreFlags(entries: { any }): { [string]: boolean }
	assert(type(entries) == "table", "P002-CODEC-009 flag list invalid")
	local result = {}
	local previous = nil
	for _, stableId in entries do
		assert(type(stableId) == "string" and stableId ~= "", "P002-CODEC-010 flag id invalid")
		assert(previous == nil or previous < stableId, "P002-CODEC-011 flag order invalid")
		result[stableId] = true
		previous = stableId
	end
	return result
end

function ProfileCodec.encode(schema: any, canonical: any, profile: any): any
	schema.validate(profile)
	local saved = {}
	for domainKey, savedKey in domainToSaved do
		local value = profile[domainKey]
		if value ~= nil then
			saved[savedKey] = canonical.copy(value)
		end
	end
	saved.c = sortedPairs(profile.currencies)
	saved.x = {
		f = sortedFlags(profile.discovery.forms),
		j = sortedFlags(profile.discovery.jokers),
		a = sortedFlags(profile.discovery.arcana),
		s = sortedFlags(profile.discovery.souls),
	}
	return saved
end

function ProfileCodec.decode(schema: any, canonical: any, saved: any): any
	assert(type(saved) == "table", "P002-CODEC-004 saved profile invalid")
	local profile = {}
	for savedKey, value in saved do
		local domainKey = savedToDomain[savedKey]
		assert(domainKey ~= nil, "P002-CODEC-005 unknown saved field")
		if savedKey ~= "x" then
			profile[domainKey] = canonical.copy(value)
		end
	end
	assert(type(saved.c) == "table", "P002-CODEC-006 currency pairs missing")
	profile.currencies = restorePairs(saved.c)
	assert(type(saved.x) == "table", "P002-CODEC-012 discovery missing")
	for key in saved.x do
		assert(
			key == "f" or key == "j" or key == "a" or key == "s",
			"P002-CODEC-013 discovery field invalid"
		)
	end
	profile.discovery = {
		forms = restoreFlags(saved.x.f),
		jokers = restoreFlags(saved.x.j),
		arcana = restoreFlags(saved.x.a),
		souls = restoreFlags(saved.x.s),
	}
	return schema.validate(profile)
end

function ProfileCodec.canonicalSaved(schema: any, canonical: any, profile: any): string
	return canonical.encode(ProfileCodec.encode(schema, canonical, profile))
end

function ProfileCodec.measure(schema: any, canonical: any, profile: any): number
	return #ProfileCodec.canonicalSaved(schema, canonical, profile)
end

return table.freeze(ProfileCodec)
