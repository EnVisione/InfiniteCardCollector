--!strict

local Phase001Fixtures = {}

function Phase001Fixtures.crownRun(): any
	return {
		catalogVersion = 1,
		configVersion = 1,
		cards = {
			{
				instanceId = "fixture_10_hearts",
				deckSetId = "radioactive",
				rankId = "10",
				suitId = "hearts",
				editionId = "normal",
				gradeId = "f",
				powerTierId = "common",
				traitId = nil,
			},
			{
				instanceId = "fixture_jack_diamonds",
				deckSetId = "radioactive",
				rankId = "jack",
				suitId = "diamonds",
				editionId = "foil",
				gradeId = "e",
				powerTierId = "uncommon",
				traitId = "swift",
			},
			{
				instanceId = "fixture_queen_clubs",
				deckSetId = "radioactive",
				rankId = "queen",
				suitId = "clubs",
				editionId = "steel",
				gradeId = "s",
				powerTierId = "legendary",
				traitId = "guardian",
			},
			{
				instanceId = "fixture_king_spades",
				deckSetId = "radioactive",
				rankId = "king",
				suitId = "spades",
				editionId = "normal",
				gradeId = "a",
				powerTierId = "mythic",
				traitId = nil,
			},
			{
				instanceId = "fixture_showcase_ace",
				deckSetId = "radioactive",
				rankId = "ace",
				suitId = "spades",
				editionId = "golden",
				gradeId = "lr",
				powerTierId = "infernal",
				traitId = "fortune",
			},
		},
		activeJokerIds = {
			"crown_engine",
			"joker_union",
			"golden_dividend",
			"overclock",
			"archivist",
		},
		activeDeckSetCounts = { radioactive = 52 },
		activeDeckFilledSlots = 52,
		discoveredFormCount = 624,
		formationTarget = 60,
		formationStreak = 4,
		successfulFormationCount = 24,
		criticalTraitInstanceIds = {},
		modeId = "formation_rush",
		personalActiveBoostMultipliers = {
			personal_output = { numerator = 110, denominator = 100 },
		},
		serverEventBoostMultipliers = {},
	}
end

return table.freeze(Phase001Fixtures)
