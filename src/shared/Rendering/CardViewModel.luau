--!strict

local CardViewModel = {}

CardViewModel.version = 1
CardViewModel.layerOrder = table.freeze({
	"deck_set",
	"suit",
	"rank",
	"edition",
	"grade",
	"power_tier",
	"trait",
	"status",
})

local function indexById(records: { any }): { [string]: any }
	local result = {}
	for _, record in records do
		result[record.id] = record
	end
	return result
end

local function deepFreeze(value: any): any
	if type(value) == "table" and not table.isfrozen(value) then
		for _, child in value do
			deepFreeze(child)
		end
		table.freeze(value)
	end
	return value
end

function CardViewModel.build(catalog: any, card: any, settings: any): any
	local deckSets = indexById(catalog.deckSets)
	local ranks = indexById(catalog.ranks)
	local suits = indexById(catalog.suits)
	local editions = indexById(catalog.editions)
	local grades = indexById(catalog.grades)
	local powerTiers = indexById(catalog.powerTiers)
	local traits = indexById(catalog.traits)
	local deckSet = deckSets[card.deckSetId]
	local rank = ranks[card.rankId]
	local suit = suits[card.suitId]
	local edition = editions[card.editionId]
	local grade = grades[card.gradeId]
	local powerTier = powerTiers[card.powerTierId]
	local trait = if card.traitId ~= nil then traits[card.traitId] else nil
	local unavailable = deckSet == nil
		or deckSet.launchEnabled == false
		or rank == nil
		or suit == nil
		or edition == nil
		or grade == nil
		or powerTier == nil
		or (card.traitId ~= nil and trait == nil)
	deckSet = deckSet or { id = "unavailable", displayName = "Unavailable Deck Set" }
	rank = rank or { id = "unavailable", displayName = "Unavailable Rank" }
	suit = suit or { id = "unavailable", displayName = "Unavailable Suit", color = "neutral" }
	edition = edition or { id = "unavailable", displayName = "Unavailable Edition" }
	grade = grade or { id = "unavailable", displayName = "Unavailable Grade" }
	powerTier = powerTier or { id = "unavailable", displayName = "Unavailable Power Tier" }
	if card.traitId ~= nil and trait == nil then
		trait = { id = "unavailable", displayName = "Unavailable Trait" }
	end
	local statuses = {}
	if card.locked then
		table.insert(statuses, { id = "locked", symbol = "lock", text = "Locked" })
	end
	if card.tradeLocked then
		table.insert(statuses, { id = "trade", symbol = "trade", text = "Trade Locked" })
	end
	if card.favorite then
		table.insert(statuses, { id = "favorite", symbol = "star", text = "Favorite" })
	end
	if card.wishlist then
		table.insert(statuses, { id = "wishlist", symbol = "bookmark", text = "Wishlist" })
	end
	if card.isNew then
		table.insert(statuses, { id = "new", symbol = "spark", text = "New" })
	end
	if unavailable then
		table.insert(statuses, {
			id = "unavailable",
			symbol = "warning",
			text = "Content Unavailable",
		})
	end
	local statusNames = {}
	for _, status in statuses do
		table.insert(statusNames, status.text)
	end
	local statusSuffix = if #statusNames > 0 then ", " .. table.concat(statusNames, ", ") else ""
	local layers = {
		{ id = "deck_set", valueId = deckSet.id, text = deckSet.displayName },
		{ id = "suit", valueId = suit.id, text = suit.displayName, colorId = suit.color },
		{ id = "rank", valueId = rank.id, text = rank.displayName },
		{ id = "edition", valueId = edition.id, text = edition.displayName },
		{ id = "grade", valueId = grade.id, text = grade.displayName },
		{ id = "power_tier", valueId = powerTier.id, text = powerTier.displayName },
		{
			id = "trait",
			valueId = if trait ~= nil then trait.id else "none",
			text = if trait ~= nil then trait.displayName else "No Trait",
		},
		{ id = "status", values = statuses },
	}
	return deepFreeze({
		version = CardViewModel.version,
		instanceId = card.instanceId,
		accessibleName = string.format(
			"%s of %s, %s, grade %s, %s%s",
			rank.displayName,
			suit.displayName,
			edition.displayName,
			grade.displayName,
			powerTier.displayName,
			statusSuffix
		),
		layers = layers,
		settings = {
			lowGraphics = settings.lowGraphics == true,
			reducedMotion = settings.reducedMotion == true,
			reducedFlash = settings.reducedFlash == true,
			animated = settings.lowGraphics ~= true and settings.reducedMotion ~= true,
			flashing = settings.lowGraphics ~= true and settings.reducedFlash ~= true,
		},
	})
end

return table.freeze(CardViewModel)
