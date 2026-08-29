--!strict

local PresentationResolver = {}

local function enabledDeckSet(catalog: any, deckSetId: string): boolean
	if type(catalog) ~= "table" or type(catalog.deckSets) ~= "table" then
		return false
	end
	for _, deckSet in catalog.deckSets do
		if type(deckSet) == "table" and deckSet.id == deckSetId then
			return deckSet.launchEnabled ~= false
		end
	end
	return false
end

function PresentationResolver.card(catalog: any, card: any, assets: any): any
	assert(type(assets) == "table", "P003-PRESENTATION-002 asset registry missing")
	local deckSetId = if type(card) == "table" and type(card.deckSetId) == "string"
		then card.deckSetId
		else nil
	local system = if deckSetId ~= nil then assets.visualSystem(deckSetId) else nil
	local useThemed = system ~= nil and enabledDeckSet(catalog, deckSetId :: string)
	if useThemed then
		return table.freeze({
			deckSetId = deckSetId,
			visualSystemId = system.id,
			fixtureName = system.frameFixtureName,
			framePartName = system.framePartName,
			facePartName = "CardFace",
			rankMarkPartName = "RankMark",
			rankMarkMode = system.style.rankMarkMode,
			fallback = false,
		})
	end

	local fallbackSystem = system or assets.visualSystem("classic")
	assert(fallbackSystem ~= nil, "P003-PRESENTATION-001 classic fallback missing")
	return table.freeze({
		deckSetId = deckSetId,
		visualSystemId = fallbackSystem.id,
		fixtureName = fallbackSystem.fallbackFixtureName,
		framePartName = fallbackSystem.fallbackFramePartName,
		facePartName = "CardFace",
		rankMarkPartName = fallbackSystem.fallbackMarkPartName,
		rankMarkMode = "fallback",
		fallback = true,
	})
end

return table.freeze(PresentationResolver)
