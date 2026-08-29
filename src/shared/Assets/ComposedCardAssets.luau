--!strict

local ComposedCardAssets = {}

local statusDefinitions = {
	{ id = "locked", symbol = "lock", text = "Locked" },
	{ id = "trade", symbol = "trade", text = "Trade Locked" },
	{ id = "favorite", symbol = "star", text = "Favorite" },
	{ id = "wishlist", symbol = "bookmark", text = "Wishlist" },
	{ id = "new", symbol = "spark", text = "New" },
	{ id = "unavailable", symbol = "warning", text = "Content Unavailable" },
}

local function deepFreeze(value: any): any
	if type(value) == "table" and not table.isfrozen(value) then
		for _, child in value do
			deepFreeze(child)
		end
		table.freeze(value)
	end
	return value
end

local function layerRecords(records: { any }, prefix: string, fallbackPrefix: string): { any }
	local result = {}
	for _, record in records do
		if record.launchEnabled ~= false then
			table.insert(result, {
				id = record.id,
				displayName = record.displayName,
				assetId = "asset." .. prefix .. "." .. record.id,
				fallbackAssetId = "fallback." .. fallbackPrefix .. "." .. record.id,
			})
		end
	end
	return result
end

local function indexById(records: { any }): { [string]: any }
	local result = {}
	for _, record in records do
		result[record.id] = record
	end
	return result
end

local function statusRecords(): { any }
	local result = {}
	for _, status in statusDefinitions do
		table.insert(result, {
			id = status.id,
			symbol = status.symbol,
			text = status.text,
			assetId = "asset.status." .. status.id,
			fallbackAssetId = "fallback.status." .. status.id,
		})
	end
	return result
end

local function baseLayer(assetId: string, fallbackAssetId: string): any
	return {
		assetId = assetId,
		fallbackAssetId = fallbackAssetId,
	}
end

function ComposedCardAssets.build(catalog: any): any
	assert(type(catalog) == "table", "P003-COMPOSE-001 catalog missing")
	assert(type(catalog.deckSets) == "table", "P003-COMPOSE-002 deck sets missing")
	assert(type(catalog.ranks) == "table", "P003-COMPOSE-003 ranks missing")
	assert(type(catalog.suits) == "table", "P003-COMPOSE-004 suits missing")
	assert(type(catalog.editions) == "table", "P003-COMPOSE-005 editions missing")
	assert(type(catalog.grades) == "table", "P003-COMPOSE-006 grades missing")
	assert(type(catalog.powerTiers) == "table", "P003-COMPOSE-007 tiers missing")
	assert(type(catalog.traits) == "table", "P003-COMPOSE-008 traits missing")
	assert(type(catalog.formations) == "table", "P003-COMPOSE-009 formations missing")

	local editions = layerRecords(catalog.editions, "edition", "edition")
	local grades = layerRecords(catalog.grades, "grade", "grade")
	local powerTiers = layerRecords(catalog.powerTiers, "power_tier", "power_tier")
	local traits = layerRecords(catalog.traits, "trait", "trait")
	local formations = layerRecords(catalog.formations, "formation", "formation")
	local forms = {}
	for _, deckSet in catalog.deckSets do
		if deckSet.launchEnabled ~= false then
			for _, rank in catalog.ranks do
				for _, suit in catalog.suits do
					local baseIdentityId = deckSet.id .. ":" .. rank.id .. ":" .. suit.id
					for _, edition in editions do
						local formId = baseIdentityId .. ":" .. edition.id
						table.insert(forms, {
							id = formId,
							baseIdentityId = baseIdentityId,
							editionId = edition.id,
							assetId = "asset.form." .. formId,
							fallbackAssetId = "fallback.form." .. formId,
						})
					end
				end
			end
		end
	end

	local registry = {
		version = "phase-003-composed-1",
		editions = deepFreeze(editions),
		grades = deepFreeze(grades),
		powerTiers = deepFreeze(powerTiers),
		traits = deepFreeze(traits),
		statuses = deepFreeze(statusRecords()),
		formations = deepFreeze(formations),
		forms = deepFreeze(forms),
	}
	local byCategory = {
		edition = indexById(registry.editions),
		grade = indexById(registry.grades),
		power_tier = indexById(registry.powerTiers),
		trait = indexById(registry.traits),
		formation = indexById(registry.formations),
		status = indexById(registry.statuses),
		form = indexById(registry.forms),
	}

	function registry:compose(card: any): any
		assert(type(card) == "table", "P003-COMPOSE-008 card missing")
		local unavailable = false
		local function resolve(category: string, id: any): any
			local record = if type(id) == "string" then byCategory[category][id] else nil
			if record == nil then
				unavailable = true
				return {
					id = "unavailable",
					assetId = "fallback." .. category .. ".unavailable",
					fallbackAssetId = "fallback." .. category .. ".unavailable",
				}
			end
			return record
		end

		local formId = nil
		if
			type(card.deckSetId) == "string"
			and type(card.rankId) == "string"
			and type(card.suitId) == "string"
			and type(card.editionId) == "string"
		then
			formId = card.deckSetId
				.. ":"
				.. card.rankId
				.. ":"
				.. card.suitId
				.. ":"
				.. card.editionId
		end
		local form = resolve("form", formId)
		local edition = resolve("edition", card.editionId)
		local grade = resolve("grade", card.gradeId)
		local powerTier = resolve("power_tier", card.powerTierId)
		local trait = if card.traitId ~= nil then resolve("trait", card.traitId) else nil
		local statuses = {}
		for _, status in statusDefinitions do
			local active = (status.id == "locked" and card.locked == true)
				or (status.id == "trade" and card.tradeLocked == true)
				or (status.id == "favorite" and card.favorite == true)
				or (status.id == "wishlist" and card.wishlist == true)
				or (status.id == "new" and card.isNew == true)
			if active then
				table.insert(statuses, byCategory.status[status.id])
			end
		end
		if unavailable then
			table.insert(statuses, byCategory.status.unavailable)
		end

		return deepFreeze({
			form = form,
			layers = {
				deck_set = baseLayer(
					"asset.frame." .. tostring(card.deckSetId),
					"fallback.frame." .. tostring(card.deckSetId)
				),
				suit = baseLayer(
					"asset.suit." .. tostring(card.suitId),
					"fallback.suit." .. tostring(card.suitId)
				),
				rank = baseLayer(
					"asset.rank." .. tostring(card.rankId),
					"fallback.rank." .. tostring(card.rankId)
				),
				edition = edition,
				grade = grade,
				power_tier = powerTier,
				trait = trait,
				status = statuses,
			},
			unavailable = unavailable,
		})
	end

	return table.freeze(registry)
end

return table.freeze(ComposedCardAssets)
