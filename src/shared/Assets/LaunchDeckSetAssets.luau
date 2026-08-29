--!strict

local LaunchDeckSetAssets = {}

local rankSymbols = {
	["2"] = "2",
	["3"] = "3",
	["4"] = "4",
	["5"] = "5",
	["6"] = "6",
	["7"] = "7",
	["8"] = "8",
	["9"] = "9",
	["10"] = "10",
	jack = "J",
	queen = "Q",
	king = "K",
	ace = "A",
}
local rankOrder = { "2", "3", "4", "5", "6", "7", "8", "9", "10", "jack", "queen", "king", "ace" }

local suitSymbols = {
	hearts = { symbol = "heart", color = "red" },
	diamonds = { symbol = "diamond", color = "red" },
	clubs = { symbol = "club", color = "black" },
	spades = { symbol = "spade", color = "black" },
}
local suitOrder = { "hearts", "diamonds", "clubs", "spades" }

local visualSystems = {
	{
		id = "classic",
		displayName = "Classic",
		frameAssetId = "frame.classic",
		frameFixtureName = "ClassicFrameFixture",
		framePartName = "ClassicFrame",
		fallbackFixtureName = "ClassicFallbackFixture",
		fallbackFramePartName = "FallbackFrame",
		fallbackMarkPartName = "FallbackMark",
		rankAssetPrefix = "rank.",
		suitAssetPrefix = "suit.",
		packAssetId = "pack.classic",
		packFixtureName = "ClassicStarterPackFixture",
		revealSoundAssetId = "sound.reveal.classic",
		binderPageAssetId = "surface.binder.classic",
		masteryAssetId = "surface.mastery.classic",
		affinityCueAssetId = "cue.affinity.balanced_formations",
		fallbackAssetId = "fallback.frame.classic",
		style = {
			framePattern = "ivory_stock",
			accentPattern = "red_black_ink",
			material = "paper",
			contrast = "warm",
			rankMarkMode = "suit",
		},
	},
	{
		id = "radioactive",
		displayName = "Radioactive",
		frameAssetId = "frame.radioactive",
		frameFixtureName = "RadioactiveFrameFixture",
		framePartName = "RadioactiveFrame",
		fallbackFixtureName = "RadioactiveFallbackFixture",
		fallbackFramePartName = "FallbackFrame",
		fallbackMarkPartName = "FallbackMark",
		rankAssetPrefix = "rank.",
		suitAssetPrefix = "suit.",
		packAssetId = "pack.radioactive",
		packFixtureName = "RadioactivePackFixture",
		revealSoundAssetId = "sound.reveal.radioactive",
		binderPageAssetId = "surface.binder.radioactive",
		masteryAssetId = "surface.mastery.radioactive",
		affinityCueAssetId = "cue.affinity.successful_streak_cash",
		fallbackAssetId = "fallback.frame.radioactive",
		style = {
			framePattern = "hazard_stripes",
			accentPattern = "green_warning_stamps",
			material = "industrial",
			contrast = "neon",
			rankMarkMode = "asset",
		},
	},
	{
		id = "astral",
		displayName = "Astral",
		frameAssetId = "frame.astral",
		frameFixtureName = "AstralFrameFixture",
		framePartName = "AstralFrame",
		fallbackFixtureName = "AstralFallbackFixture",
		fallbackFramePartName = "FallbackFrame",
		fallbackMarkPartName = "FallbackMark",
		rankAssetPrefix = "rank.",
		suitAssetPrefix = "suit.",
		packAssetId = "pack.astral",
		packFixtureName = "AstralPackFixture",
		revealSoundAssetId = "sound.reveal.astral",
		binderPageAssetId = "surface.binder.astral",
		masteryAssetId = "surface.mastery.astral",
		affinityCueAssetId = "cue.affinity.exact_sum_crown",
		fallbackAssetId = "fallback.frame.astral",
		style = {
			framePattern = "star_maps",
			accentPattern = "violet_nebula_silver_constellations",
			material = "celestial",
			contrast = "cool",
			rankMarkMode = "asset",
		},
	},
}

local visualSystemsById = {}
for _, system in visualSystems do
	visualSystemsById[system.id] = system
end

local function buildRankPresentations(): { any }
	local result = {}
	for _, rankId in rankOrder do
		table.insert(result, {
			id = "rank." .. rankId,
			assetId = "asset.rank." .. rankId,
			fallbackAssetId = "fallback.rank." .. rankId,
			symbol = rankSymbols[rankId],
		})
	end
	return result
end

local function buildSuitPresentations(): { any }
	local result = {}
	for _, suitId in suitOrder do
		local definition = suitSymbols[suitId]
		table.insert(result, {
			id = "suit." .. suitId,
			assetId = "asset.suit." .. suitId,
			fallbackAssetId = "fallback.suit." .. suitId,
			symbol = definition.symbol,
			color = definition.color,
		})
	end
	return result
end

local rankPresentations = buildRankPresentations()
local suitPresentations = buildSuitPresentations()
local rankPresentationsById = {}
for _, presentation in rankPresentations do
	rankPresentationsById[presentation.id] = presentation
end
local suitPresentationsById = {}
for _, presentation in suitPresentations do
	suitPresentationsById[presentation.id] = presentation
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

local function sortedReferences(deckSet: any, rank: any, suit: any, system: any): { string }
	local references = {
		"asset.frame." .. deckSet.id,
		"asset.rank." .. rank.id,
		"asset.suit." .. suit.id,
		system.binderPageAssetId,
		system.masteryAssetId,
	}
	table.sort(references)
	return references
end

function LaunchDeckSetAssets.buildIdentityRecords(catalog: any): { any }
	assert(type(catalog) == "table", "P003-DECK-ASSET-001 catalog missing")
	assert(type(catalog.deckSets) == "table", "P003-DECK-ASSET-002 deck sets missing")
	assert(type(catalog.ranks) == "table", "P003-DECK-ASSET-003 ranks missing")
	assert(type(catalog.suits) == "table", "P003-DECK-ASSET-004 suits missing")
	local records = {}
	local seen = {}
	local enabledDeckSetCount = 0
	for _, deckSet in catalog.deckSets do
		if deckSet.launchEnabled ~= false then
			enabledDeckSetCount += 1
			local system = visualSystemsById[deckSet.id]
			assert(system ~= nil, "P003-DECK-ASSET-005 visual system missing")
			for _, rank in catalog.ranks do
				for _, suit in catalog.suits do
					local id = deckSet.id .. ":" .. rank.id .. ":" .. suit.id
					assert(seen[id] == nil, "P003-DECK-ASSET-006 duplicate identity")
					seen[id] = true
					table.insert(records, {
						id = id,
						assetContractId = "identity." .. id,
						assetVersion = "phase-003-deck-sets-1",
						deckSetId = deckSet.id,
						rankId = rank.id,
						suitId = suit.id,
						slotKey = rank.id .. ":" .. suit.id,
						launchEnabled = true,
						visualSystemId = system.id,
						frameAssetId = system.frameAssetId,
						frameFixtureName = system.frameFixtureName,
						framePartName = system.framePartName,
						rankAssetId = system.rankAssetPrefix .. rank.id,
						suitAssetId = system.suitAssetPrefix .. suit.id,
						rankPresentationId = "rank." .. rank.id,
						suitPresentationId = "suit." .. suit.id,
						packAssetId = system.packAssetId,
						packFixtureName = system.packFixtureName,
						revealSoundAssetId = system.revealSoundAssetId,
						binderPageAssetId = system.binderPageAssetId,
						masteryAssetId = system.masteryAssetId,
						affinityCueAssetId = system.affinityCueAssetId,
						fallbackAssetId = system.fallbackAssetId,
						fallbackFixtureName = system.fallbackFixtureName,
						fallbackFramePartName = system.fallbackFramePartName,
						fallbackMarkPartName = system.fallbackMarkPartName,
						sourceIdentity = "source.identity." .. id,
						builtIdentity = "asset.frame." .. deckSet.id,
						provenance = {
							origin = "original",
							license = "all_rights_reserved",
							reviewState = "reviewed",
							reviewedBy = "maintainer",
							reviewedAt = "2026-08-29",
						},
						references = sortedReferences(deckSet, rank, suit, system),
					})
				end
			end
		end
	end
	assert(enabledDeckSetCount == #visualSystems, "P003-DECK-ASSET-007 deck set coverage")
	assert(
		#records == enabledDeckSetCount * #catalog.ranks * #catalog.suits,
		"P003-DECK-ASSET-008 identity count"
	)
	return deepFreeze(records)
end

LaunchDeckSetAssets.visualSystems = deepFreeze(visualSystems)
LaunchDeckSetAssets.rankPresentations = deepFreeze(rankPresentations)
LaunchDeckSetAssets.suitPresentations = deepFreeze(suitPresentations)

function LaunchDeckSetAssets.visualSystem(deckSetId: string): any
	return visualSystemsById[deckSetId]
end

function LaunchDeckSetAssets.rankPresentation(rankId: string): any
	return rankPresentationsById["rank." .. rankId]
end

function LaunchDeckSetAssets.suitPresentation(suitId: string): any
	return suitPresentationsById["suit." .. suitId]
end

return table.freeze(LaunchDeckSetAssets)
