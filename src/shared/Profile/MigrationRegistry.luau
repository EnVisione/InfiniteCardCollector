--!strict

local MigrationRegistry = {}

MigrationRegistry.version = 1

local function migrateZero(dependencies: any, saved: any): any
	assert(type(saved.createdAt) == "number", "P002-MIGRATION-001 created timestamp missing")
	assert(type(saved.lastSeenAt) == "number", "P002-MIGRATION-002 seen timestamp missing")
	assert(type(saved.money) == "number", "P002-MIGRATION-003 money missing")
	assert(type(saved.ownedCards) == "table", "P002-MIGRATION-004 cards missing")
	local profile = dependencies.schema.newBlank(
		dependencies.currencyIds,
		saved.createdAt,
		dependencies.catalogVersion,
		dependencies.configVersion
	)
	profile.lastSeenAt = saved.lastSeenAt
	profile.currencies.cash = saved.money
	for _, card in saved.ownedCards do
		assert(
			type(card) == "table"
				and type(card.uid) == "string"
				and type(card.ownerUserId) == "number"
				and type(card.deckSetId) == "string"
				and type(card.rankId) == "string"
				and type(card.suitId) == "string",
			"P002-MIGRATION-009 card invalid"
		)
		assert(profile.cards[card.uid] == nil, "P002-MIGRATION-010 duplicate card uid")
		local slotKey = card.rankId .. ":" .. card.suitId
		local identityId = card.deckSetId .. ":" .. slotKey
		profile.cards[card.uid] = {
			uid = card.uid,
			ownerUserId = card.ownerUserId,
			identityId = identityId,
			deckSetId = card.deckSetId,
			rankId = card.rankId,
			suitId = card.suitId,
			slotKey = slotKey,
			editionId = card.editionId or "normal",
			gradeId = card.gradeId or "f",
			powerTierId = card.powerTierId or "common",
			traitId = card.traitId,
			gradeExperience = card.gradeExperience or 0,
			flags = dependencies.canonical.copy(card.flags or {
				favorite = false,
				wishlist = false,
			}),
			locks = dependencies.canonical.copy(card.locks or {}),
			provenance = dependencies.canonical.copy(card.provenance or {
				originType = "schema_v0_migration",
				originId = "profile_v0",
				createdAt = saved.createdAt,
				instanceVersion = 1,
			}),
		}
		profile.discovery.forms[identityId .. ":" .. (card.editionId or "normal")] = true
	end
	return profile
end

function MigrationRegistry.new(dependencies: any): any
	assert(dependencies.schema ~= nil, "P002-MIGRATION-005 schema missing")
	assert(dependencies.codec ~= nil, "P002-MIGRATION-006 codec missing")
	assert(dependencies.canonical ~= nil, "P002-MIGRATION-007 canonical codec missing")
	assert(dependencies.errors ~= nil, "P002-MIGRATION-008 errors missing")
	local registry = {
		currentVersion = dependencies.schema.version,
		supportedVersions = table.freeze({ 0, 1 }),
	}

	function registry:migrate(saved: any): any
		if type(saved) ~= "table" then
			return { ok = false, code = dependencies.errors.codes.profileMalformed }
		end
		local version = saved.v
		if version == nil then
			version = saved.version
		end
		if type(version) ~= "number" or version % 1 ~= 0 or version < 0 then
			return { ok = false, code = dependencies.errors.codes.profileMalformed }
		end
		if version > self.currentVersion then
			return { ok = false, code = dependencies.errors.codes.profileUnsupportedSchema }
		end
		local ok, profile = pcall(function()
			if version == 0 then
				return migrateZero(dependencies, saved)
			end
			return dependencies.codec.decode(dependencies.schema, dependencies.canonical, saved)
		end)
		if not ok then
			return { ok = false, code = dependencies.errors.codes.profileMalformed }
		end
		local encoded =
			dependencies.codec.encode(dependencies.schema, dependencies.canonical, profile)
		return {
			ok = true,
			fromVersion = version,
			toVersion = self.currentVersion,
			profile = profile,
			saved = encoded,
			canonical = dependencies.canonical.encode(encoded),
		}
	end

	return registry
end

return table.freeze(MigrationRegistry)
