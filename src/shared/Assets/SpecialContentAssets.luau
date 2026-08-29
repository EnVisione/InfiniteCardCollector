--!strict

local SpecialContentAssets = {}

local surfaceDefinitions = {
	{ id = "opening_table", displayName = "Opening Table", kind = "interface" },
	{ id = "hub", displayName = "Collection Hub", kind = "interface" },
	{ id = "joker_stage", displayName = "Joker Stage", kind = "interface" },
	{ id = "arcana_lab", displayName = "Arcana Lab", kind = "interface" },
	{ id = "showcase", displayName = "Showcase", kind = "interface" },
	{ id = "settings", displayName = "Settings", kind = "interface" },
	{ id = "recovery", displayName = "Recovery", kind = "interface" },
}

local soundDefinitions = {
	{ id = "reveal.classic", displayName = "Classic Reveal" },
	{ id = "reveal.radioactive", displayName = "Radioactive Reveal" },
	{ id = "reveal.astral", displayName = "Astral Reveal" },
	{ id = "reveal.joker", displayName = "Joker Reveal" },
	{ id = "reveal.arcana", displayName = "Arcana Reveal" },
	{ id = "ui.confirm", displayName = "Confirm" },
	{ id = "ui.warning", displayName = "Warning" },
	{ id = "ui.error", displayName = "Error" },
}

local effectDefinitions = {
	{ id = "pack.reveal", displayName = "Pack Reveal" },
	{ id = "pack.commit", displayName = "Pack Commit" },
	{ id = "card.edition", displayName = "Edition Application" },
	{ id = "card.grade", displayName = "Grade Promotion" },
	{ id = "card.tier", displayName = "Power Tier" },
	{ id = "card.trait", displayName = "Trait Application" },
	{ id = "arcana.target", displayName = "Arcana Target" },
	{ id = "formation.result", displayName = "Formation Result" },
	{ id = "unavailable", displayName = "Unavailable Content" },
}

local packDefinitions = {
	{ id = "classic", displayName = "Classic Pack", category = "deck_set", deckSetId = "classic" },
	{
		id = "radioactive",
		displayName = "Radioactive Pack",
		category = "deck_set",
		deckSetId = "radioactive",
	},
	{ id = "astral", displayName = "Astral Pack", category = "deck_set", deckSetId = "astral" },
	{ id = "joker", displayName = "Joker Pack", category = "joker" },
	{ id = "arcana", displayName = "Arcana Pack", category = "arcana" },
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

local function indexById(records: { any }): { [string]: any }
	local result = {}
	for _, record in records do
		result[record.id] = record
	end
	return result
end

local function enabledRecords(catalog: any, field: string, failureId: string): { any }
	assert(type(catalog[field]) == "table", failureId)
	local result = {}
	for _, record in catalog[field] do
		if record.launchEnabled ~= false then
			table.insert(result, record)
		end
	end
	return result
end

local function references(values: { string }): { string }
	local result = {}
	local seen = {}
	for _, value in values do
		if not seen[value] then
			seen[value] = true
			table.insert(result, value)
		end
	end
	table.sort(result)
	return result
end

local function contentRecord(category: string, record: any, extraReferences: { string }): any
	local referencesList = { category .. "." .. record.id }
	for _, reference in extraReferences do
		table.insert(referencesList, reference)
	end
	return {
		id = record.id,
		displayName = record.displayName,
		assetId = "asset." .. category .. "." .. record.id,
		fallbackAssetId = "fallback." .. category .. "." .. record.id,
		iconAssetId = "asset.icon." .. category .. "." .. record.id,
		thumbnailAssetId = "asset.thumbnail." .. category .. "." .. record.id,
		effectAssetId = "asset.effect." .. category .. "." .. record.id,
		metadataAssetId = "asset.metadata." .. category .. "." .. record.id,
		sourceIdentity = "source." .. category .. "." .. record.id,
		builtIdentity = "assetbundle." .. category .. "." .. record.id,
		references = references(referencesList),
	}
end

local function familyRecord(category: string, definition: any, extraReferences: { string }): any
	local referencesList = { category .. "." .. definition.id }
	for _, reference in extraReferences do
		table.insert(referencesList, reference)
	end
	return {
		id = definition.id,
		displayName = definition.displayName,
		category = definition.category,
		deckSetId = definition.deckSetId,
		assetId = "asset." .. category .. "." .. definition.id,
		fallbackAssetId = "fallback." .. category .. "." .. definition.id,
		iconAssetId = "asset.icon." .. category .. "." .. definition.id,
		thumbnailAssetId = "asset.thumbnail." .. category .. "." .. definition.id,
		effectAssetId = "asset.effect." .. category .. "." .. definition.id,
		metadataAssetId = "asset.metadata." .. category .. "." .. definition.id,
		sourceIdentity = "source." .. category .. "." .. definition.id,
		builtIdentity = "assetbundle." .. category .. "." .. definition.id,
		references = references(referencesList),
	}
end

local function presentationRecord(category: string, definition: any): any
	return {
		id = definition.id,
		displayName = definition.displayName,
		kind = definition.kind,
		assetId = "asset." .. category .. "." .. definition.id,
		fallbackAssetId = "fallback." .. category .. "." .. definition.id,
		sourceIdentity = "source." .. category .. "." .. definition.id,
		builtIdentity = "assetbundle." .. category .. "." .. definition.id,
		references = references({ category .. "." .. definition.id, "surface." .. definition.id }),
	}
end

local function assetFamily(definitions: { any }, category: string): { any }
	local result = {}
	for _, definition in definitions do
		table.insert(result, presentationRecord(category, definition))
	end
	return result
end

function SpecialContentAssets.build(catalog: any): any
	assert(type(catalog) == "table", "P003-SPECIAL-001 catalog missing")
	local jokers = enabledRecords(catalog, "jokers", "P003-SPECIAL-002 jokers missing")
	local arcana = enabledRecords(catalog, "arcana", "P003-SPECIAL-003 arcana missing")
	assert(#jokers == 24, "P003-SPECIAL-004 launch joker count")
	assert(#arcana == 12, "P003-SPECIAL-005 launch arcana count")

	local jokerAssets = {}
	for _, joker in jokers do
		local extraReferences = {
			"rarity." .. joker.rarityId,
			"stage." .. joker.id,
		}
		if type(joker.handlerId) == "string" then
			table.insert(extraReferences, "handler." .. joker.handlerId)
		end
		local asset = contentRecord("joker", joker, extraReferences)
		asset.rarityId = joker.rarityId
		asset.stageIds = if type(joker.stages) == "table" then table.clone(joker.stages) else {}
		if type(joker.handlerId) == "string" then
			asset.handlerId = joker.handlerId
		end
		if type(joker.conflicts) == "table" then
			asset.conflicts = table.clone(joker.conflicts)
		end
		table.insert(jokerAssets, asset)
	end
	local arcanaAssets = {}
	for _, item in arcana do
		local extraReferences = {
			"category." .. item.categoryId,
			"target." .. item.targetId,
		}
		if type(item.handlerId) == "string" then
			table.insert(extraReferences, "handler." .. item.handlerId)
		end
		local asset = contentRecord("arcana", item, extraReferences)
		asset.categoryId = item.categoryId
		asset.targetId = item.targetId
		if type(item.handlerId) == "string" then
			asset.handlerId = item.handlerId
		end
		table.insert(arcanaAssets, asset)
	end

	local packs = {}
	for _, pack in packDefinitions do
		table.insert(
			packs,
			familyRecord("pack", pack, {
				"surface.opening_table",
				if pack.deckSetId ~= nil then "deck_set." .. pack.deckSetId else "pack." .. pack.id,
			})
		)
	end
	local surfaces = assetFamily(surfaceDefinitions, "surface")
	local sounds = assetFamily(soundDefinitions, "sound")
	local effects = assetFamily(effectDefinitions, "effect")
	local icons = {}
	local thumbnails = {}
	local metadata = {}
	for _, family in
		{
			{ category = "joker", records = jokerAssets },
			{ category = "arcana", records = arcanaAssets },
			{ category = "pack", records = packs },
		}
	do
		for _, record in family.records do
			table.insert(icons, {
				id = family.category .. "." .. record.id,
				assetId = record.iconAssetId,
				fallbackAssetId = "fallback.icon." .. family.category .. "." .. record.id,
				sourceIdentity = "source.icon." .. family.category .. "." .. record.id,
				builtIdentity = "assetbundle.icon." .. family.category .. "." .. record.id,
				references = { record.assetId },
			})
			table.insert(thumbnails, {
				id = family.category .. "." .. record.id,
				assetId = record.thumbnailAssetId,
				fallbackAssetId = "fallback.thumbnail." .. family.category .. "." .. record.id,
				sourceIdentity = "source.thumbnail." .. family.category .. "." .. record.id,
				builtIdentity = "assetbundle.thumbnail." .. family.category .. "." .. record.id,
				references = { record.assetId },
			})
			table.insert(metadata, {
				id = family.category .. "." .. record.id,
				assetId = record.metadataAssetId,
				fallbackAssetId = "fallback.metadata." .. family.category .. "." .. record.id,
				sourceIdentity = "source.metadata." .. family.category .. "." .. record.id,
				builtIdentity = "assetbundle.metadata." .. family.category .. "." .. record.id,
				references = { record.assetId, record.fallbackAssetId },
			})
		end
	end

	local registry = {
		version = "phase-003-special-1",
		jokers = deepFreeze(jokerAssets),
		arcana = deepFreeze(arcanaAssets),
		packs = deepFreeze(packs),
		surfaces = deepFreeze(surfaces),
		sounds = deepFreeze(sounds),
		effects = deepFreeze(effects),
		icons = deepFreeze(icons),
		thumbnails = deepFreeze(thumbnails),
		metadata = deepFreeze(metadata),
	}
	local byCategory = {
		joker = indexById(registry.jokers),
		arcana = indexById(registry.arcana),
		pack = indexById(registry.packs),
		surface = indexById(registry.surfaces),
		sound = indexById(registry.sounds),
		effect = indexById(registry.effects),
		icon = indexById(registry.icons),
		thumbnail = indexById(registry.thumbnails),
		metadata = indexById(registry.metadata),
	}

	function registry:get(category: string, id: string): any
		local family = byCategory[category]
		return if family ~= nil then family[id] else nil
	end

	return table.freeze(registry)
end

return table.freeze(SpecialContentAssets)
