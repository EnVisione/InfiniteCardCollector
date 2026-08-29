--!strict

local LaunchDeckSetAssets = {}

local visualSystems = {
	{
		id = "classic",
		displayName = "Classic",
		frameAssetId = "frame.classic",
		frameFixtureName = "ClassicFrameFixture",
		packAssetId = "pack.classic",
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
		},
	},
	{
		id = "radioactive",
		displayName = "Radioactive",
		frameAssetId = "frame.radioactive",
		frameFixtureName = "RadioactiveFrameFixture",
		packAssetId = "pack.radioactive",
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
		},
	},
	{
		id = "astral",
		displayName = "Astral",
		frameAssetId = "frame.astral",
		frameFixtureName = "AstralFrameFixture",
		packAssetId = "pack.astral",
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
		},
	},
}

local visualSystemsById = {}
for _, system in visualSystems do
	visualSystemsById[system.id] = system
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
						packAssetId = system.packAssetId,
						revealSoundAssetId = system.revealSoundAssetId,
						binderPageAssetId = system.binderPageAssetId,
						masteryAssetId = system.masteryAssetId,
						affinityCueAssetId = system.affinityCueAssetId,
						fallbackAssetId = system.fallbackAssetId,
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

return table.freeze(LaunchDeckSetAssets)
