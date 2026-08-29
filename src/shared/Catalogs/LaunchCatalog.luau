--!strict

local ranks = {
	{ id = "2", displayName = "2", value = 2, order = 1 },
	{ id = "3", displayName = "3", value = 3, order = 2 },
	{ id = "4", displayName = "4", value = 4, order = 3 },
	{ id = "5", displayName = "5", value = 5, order = 4 },
	{ id = "6", displayName = "6", value = 6, order = 5 },
	{ id = "7", displayName = "7", value = 7, order = 6 },
	{ id = "8", displayName = "8", value = 8, order = 7 },
	{ id = "9", displayName = "9", value = 9, order = 8 },
	{ id = "10", displayName = "10", value = 10, order = 9 },
	{ id = "jack", displayName = "Jack", value = 11, order = 10 },
	{ id = "queen", displayName = "Queen", value = 12, order = 11 },
	{ id = "king", displayName = "King", value = 13, order = 12 },
	{ id = "ace", displayName = "Ace", value = 14, order = 13 },
}

local suits = {
	{ id = "hearts", displayName = "Hearts", color = "red", order = 1 },
	{ id = "diamonds", displayName = "Diamonds", color = "red", order = 2 },
	{ id = "clubs", displayName = "Clubs", color = "black", order = 3 },
	{ id = "spades", displayName = "Spades", color = "black", order = 4 },
}

local deckSets = {
	{
		id = "classic",
		displayName = "Classic",
		affinityId = "balanced_formations",
		launchEnabled = true,
	},
	{
		id = "radioactive",
		displayName = "Radioactive",
		affinityId = "successful_streak_cash",
		launchEnabled = true,
	},
	{
		id = "astral",
		displayName = "Astral",
		affinityId = "exact_sum_crown",
		launchEnabled = true,
	},
}

local editions = {
	{
		id = "normal",
		displayName = "Normal",
		handlerId = "edition_normal",
		launchEnabled = true,
	},
	{
		id = "foil",
		displayName = "Foil",
		handlerId = "edition_component_multiplier",
		launchEnabled = true,
	},
	{
		id = "golden",
		displayName = "Golden",
		handlerId = "edition_component_multiplier",
		launchEnabled = true,
	},
	{
		id = "steel",
		displayName = "Steel",
		handlerId = "edition_component_multiplier",
		launchEnabled = true,
	},
}

local grades = {
	{ id = "f", displayName = "F" },
	{ id = "e", displayName = "E" },
	{ id = "d", displayName = "D" },
	{ id = "c", displayName = "C" },
	{ id = "b", displayName = "B" },
	{ id = "a", displayName = "A" },
	{ id = "s", displayName = "S" },
	{ id = "ss", displayName = "SS" },
	{ id = "sr", displayName = "SR" },
	{ id = "ur", displayName = "UR" },
	{ id = "lr", displayName = "LR" },
}

local powerTiers = {
	{ id = "common", displayName = "Common" },
	{ id = "uncommon", displayName = "Uncommon" },
	{ id = "rare", displayName = "Rare" },
	{ id = "epic", displayName = "Epic" },
	{ id = "legendary", displayName = "Legendary" },
	{ id = "mythic", displayName = "Mythic" },
	{ id = "secret", displayName = "Secret" },
	{ id = "infernal", displayName = "Infernal" },
	{ id = "celestial", displayName = "Celestial" },
	{ id = "chaos", displayName = "Chaos" },
	{ id = "zenith", displayName = "Zenith" },
}

local traits = {
	{
		id = "fortune",
		displayName = "Fortune",
		handlerId = "trait_cash_multiplier",
	},
	{
		id = "fierce",
		displayName = "Fierce",
		handlerId = "trait_power_multiplier",
	},
	{
		id = "guardian",
		displayName = "Guardian",
		handlerId = "trait_guard_multiplier",
	},
	{
		id = "swift",
		displayName = "Swift",
		handlerId = "trait_draw_speed",
	},
	{
		id = "lucky",
		displayName = "Lucky",
		handlerId = "trait_pack_progress",
	},
	{
		id = "scholar",
		displayName = "Scholar",
		handlerId = "trait_grade_experience",
	},
	{
		id = "critical",
		displayName = "Critical",
		handlerId = "trait_server_critical",
	},
	{
		id = "resilient",
		displayName = "Resilient",
		handlerId = "trait_streak_guard",
	},
	{
		id = "radiant",
		displayName = "Radiant",
		handlerId = "trait_affinity_contribution",
	},
	{
		id = "adaptive",
		displayName = "Adaptive",
		handlerId = "trait_adjacent_rank",
	},
	{
		id = "efficient",
		displayName = "Efficient",
		handlerId = "trait_task_progress",
	},
	{
		id = "social",
		displayName = "Social",
		handlerId = "trait_cooperative_reward",
	},
}

local affinities = {
	{
		id = "balanced_formations",
		handlerId = "affinity_balanced_formation",
		launchEnabled = true,
	},
	{
		id = "successful_streak_cash",
		handlerId = "affinity_streak_cash",
		launchEnabled = true,
	},
	{
		id = "exact_sum_crown",
		handlerId = "affinity_exact_sum_crown",
		launchEnabled = true,
	},
}

local formations = {
	{
		id = "single",
		displayName = "Single",
		handlerId = "formation_single",
		priority = 1,
	},
	{
		id = "twin",
		displayName = "Twin",
		handlerId = "formation_twin",
		priority = 2,
	},
	{
		id = "twin_pair",
		displayName = "Twin Pair",
		handlerId = "formation_twin_pair",
		priority = 3,
	},
	{
		id = "triple",
		displayName = "Triple",
		handlerId = "formation_triple",
		priority = 4,
	},
	{
		id = "sequence",
		displayName = "Sequence",
		handlerId = "formation_sequence",
		priority = 5,
	},
	{
		id = "monosuit",
		displayName = "Monosuit",
		handlerId = "formation_monosuit",
		priority = 6,
	},
	{
		id = "court",
		displayName = "Court",
		handlerId = "formation_court",
		priority = 7,
	},
	{
		id = "spectrum",
		displayName = "Spectrum",
		handlerId = "formation_spectrum",
		priority = 8,
	},
	{
		id = "full_cluster",
		displayName = "Full Cluster",
		handlerId = "formation_full_cluster",
		priority = 9,
	},
	{
		id = "quad",
		displayName = "Quad",
		handlerId = "formation_quad",
		priority = 10,
	},
	{
		id = "crown_run",
		displayName = "Crown Run",
		handlerId = "formation_crown_run",
		priority = 11,
	},
	{
		id = "perfect_sum",
		displayName = "Perfect Sum",
		handlerId = "formation_perfect_sum",
		priority = 12,
	},
}

local stackableBonuses = {
	{
		id = "perfect_sum_accuracy",
		displayName = "Perfect Sum Accuracy",
		balanceId = "perfect_sum_accuracy",
	},
}

for _, formation in formations do
	formation.stackableBonusIds = if formation.id == "perfect_sum"
		then { "perfect_sum_accuracy" }
		else {}
end

local jokers = {
	{
		id = "pocket_ledger",
		displayName = "Pocket Ledger",
		rarityId = "common",
		handlerId = "joker_component_add",
		stages = { "before_formation_multiplier" },
		conflicts = {},
		launchEnabled = true,
	},
	{
		id = "painted_pip",
		displayName = "Painted Pip",
		rarityId = "common",
		handlerId = "joker_component_add",
		stages = { "before_formation_multiplier" },
		conflicts = {},
		launchEnabled = true,
	},
	{
		id = "paper_shield",
		displayName = "Paper Shield",
		rarityId = "common",
		handlerId = "joker_component_add",
		stages = { "before_formation_multiplier" },
		conflicts = {},
		launchEnabled = true,
	},
	{
		id = "quick_shuffle",
		displayName = "Quick Shuffle",
		rarityId = "common",
		handlerId = "joker_state_modifier",
		stages = { "after_formation_reward" },
		conflicts = {},
		launchEnabled = true,
	},
	{
		id = "red_ribbon",
		displayName = "Red Ribbon",
		rarityId = "common",
		handlerId = "joker_card_color_add",
		stages = { "before_card_contribution" },
		conflicts = {},
		launchEnabled = true,
	},
	{
		id = "black_thread",
		displayName = "Black Thread",
		rarityId = "common",
		handlerId = "joker_card_color_add",
		stages = { "before_card_contribution" },
		conflicts = {},
		launchEnabled = true,
	},
	{
		id = "number_cruncher",
		displayName = "Number Cruncher",
		rarityId = "common",
		handlerId = "joker_number_card_add",
		stages = { "before_card_contribution" },
		conflicts = {},
		launchEnabled = true,
	},
	{
		id = "full_binder",
		displayName = "Full Binder",
		rarityId = "common",
		handlerId = "joker_filled_slots_add",
		stages = { "before_formation_multiplier" },
		conflicts = {},
		launchEnabled = true,
	},
	{
		id = "balanced_scales",
		displayName = "Balanced Scales",
		rarityId = "uncommon",
		handlerId = "joker_balanced_colors_add",
		stages = { "before_formation_multiplier" },
		conflicts = {},
		launchEnabled = true,
	},
	{
		id = "royal_chorus",
		displayName = "Royal Chorus",
		rarityId = "uncommon",
		handlerId = "joker_rank_group_add",
		stages = { "before_formation_multiplier" },
		conflicts = {},
		launchEnabled = true,
	},
	{
		id = "set_purist",
		displayName = "Set Purist",
		rarityId = "uncommon",
		handlerId = "joker_deck_set_threshold_add",
		stages = { "before_formation_multiplier" },
		conflicts = {},
		launchEnabled = true,
	},
	{
		id = "golden_dividend",
		displayName = "Golden Dividend",
		rarityId = "uncommon",
		handlerId = "joker_golden_cash_enhance",
		stages = { "before_card_contribution" },
		conflicts = {},
		launchEnabled = true,
	},
	{
		id = "streak_keeper",
		displayName = "Streak Keeper",
		rarityId = "uncommon",
		handlerId = "joker_streak_loss_intent",
		stages = { "on_formation_failure" },
		conflicts = {},
		launchEnabled = true,
	},
	{
		id = "full_spectrum",
		displayName = "Full Spectrum",
		rarityId = "rare",
		handlerId = "joker_formation_multiplier",
		stages = { "before_formation_multiplier" },
		conflicts = {},
		launchEnabled = true,
	},
	{
		id = "set_architect",
		displayName = "Set Architect",
		rarityId = "rare",
		handlerId = "joker_affinity_threshold",
		stages = { "before_card_contribution" },
		conflicts = {},
		launchEnabled = true,
	},
	{
		id = "fivefold",
		displayName = "Fivefold",
		rarityId = "rare",
		handlerId = "joker_card_count_multiplier",
		stages = { "before_formation_multiplier" },
		conflicts = {},
		launchEnabled = true,
	},
	{
		id = "arcana_adept",
		displayName = "Arcana Adept",
		rarityId = "rare",
		handlerId = "joker_state_modifier",
		stages = { "on_task_complete" },
		conflicts = {},
		launchEnabled = true,
	},
	{
		id = "crown_engine",
		displayName = "Crown Engine",
		rarityId = "epic",
		handlerId = "joker_formation_multiplier",
		stages = { "before_formation_multiplier" },
		conflicts = {},
		launchEnabled = true,
	},
	{
		id = "set_resonator",
		displayName = "Set Resonator",
		rarityId = "epic",
		handlerId = "joker_affinity_strength",
		stages = { "before_card_contribution" },
		conflicts = {},
		launchEnabled = true,
	},
	{
		id = "overclock",
		displayName = "Overclock",
		rarityId = "epic",
		handlerId = "joker_output_tradeoff",
		stages = { "before_formation_multiplier", "after_formation_reward" },
		conflicts = {},
		launchEnabled = true,
	},
	{
		id = "joker_union",
		displayName = "Joker Union",
		rarityId = "legendary",
		handlerId = "joker_other_effect_enhance",
		stages = { "before_formation_detection" },
		conflicts = { "fifth_law" },
		launchEnabled = true,
	},
	{
		id = "packstorm",
		displayName = "Packstorm",
		rarityId = "legendary",
		handlerId = "joker_success_counter_intent",
		stages = { "on_formation_success" },
		conflicts = {},
		launchEnabled = true,
	},
	{
		id = "house_of_fifty_two",
		displayName = "House of Fifty Two",
		rarityId = "mythic",
		handlerId = "joker_filled_slots_multiplier",
		stages = { "before_formation_multiplier" },
		conflicts = {},
		launchEnabled = true,
	},
	{
		id = "archivist",
		displayName = "The Archivist",
		rarityId = "mythic",
		handlerId = "joker_collection_add",
		stages = { "before_formation_multiplier" },
		conflicts = {},
		launchEnabled = true,
	},
	{
		id = "fifth_law",
		displayName = "The Fifth Law",
		rarityId = "mythic",
		handlerId = "joker_other_effect_enhance",
		stages = { "before_formation_detection" },
		conflicts = { "joker_union" },
		launchEnabled = false,
	},
}

local arcana = {
	{
		id = "polisher",
		displayName = "The Polisher",
		categoryId = "edition",
		handlerId = "arcana_unlock_edition",
		targetId = "foil",
		launchEnabled = true,
	},
	{
		id = "treasury",
		displayName = "The Treasury",
		categoryId = "edition",
		handlerId = "arcana_unlock_edition",
		targetId = "golden",
		launchEnabled = true,
	},
	{
		id = "forge",
		displayName = "The Forge",
		categoryId = "edition",
		handlerId = "arcana_unlock_edition",
		targetId = "steel",
		launchEnabled = true,
	},
	{
		id = "heart",
		displayName = "The Heart",
		categoryId = "suit",
		handlerId = "arcana_unlock_suit",
		targetId = "hearts",
		launchEnabled = true,
	},
	{
		id = "gem",
		displayName = "The Gem",
		categoryId = "suit",
		handlerId = "arcana_unlock_suit",
		targetId = "diamonds",
		launchEnabled = true,
	},
	{
		id = "clover",
		displayName = "The Clover",
		categoryId = "suit",
		handlerId = "arcana_unlock_suit",
		targetId = "clubs",
		launchEnabled = true,
	},
	{
		id = "spear",
		displayName = "The Spear",
		categoryId = "suit",
		handlerId = "arcana_unlock_suit",
		targetId = "spades",
		launchEnabled = true,
	},
	{
		id = "stair",
		displayName = "The Stair",
		categoryId = "rank",
		handlerId = "arcana_unlock_next_rank",
		targetId = "next",
		launchEnabled = true,
	},
	{
		id = "examiner",
		displayName = "The Examiner",
		categoryId = "grade",
		handlerId = "arcana_raise_grade",
		targetId = "next",
		launchEnabled = true,
	},
	{
		id = "regrader",
		displayName = "The Regrader",
		categoryId = "grade",
		handlerId = "arcana_choose_nonregressing_grade",
		targetId = "choice",
		launchEnabled = true,
	},
	{
		id = "voice",
		displayName = "The Voice",
		categoryId = "trait",
		handlerId = "arcana_choose_trait",
		targetId = "empty",
		launchEnabled = true,
	},
	{
		id = "mask",
		displayName = "The Mask",
		categoryId = "trait",
		handlerId = "arcana_replace_trait",
		targetId = "choice",
		launchEnabled = true,
	},
}

local souls = {
	{
		id = "soul_reserved",
		displayName = "Reserved Soul Contract",
		handlerId = "soul_neutral",
		launchEnabled = false,
	},
}

for _, records in { editions, grades, powerTiers, traits, affinities, formations, jokers } do
	for _, record in records do
		record.balanceId = record.id
	end
end

for categoryId, records in
	{
		deck_set = deckSets,
		edition = editions,
		joker = jokers,
		arcana = arcana,
		formation = formations,
	}
do
	for _, record in records do
		record.assetContractId = categoryId .. "_" .. record.id
	end
end

local function slotKey(rankId: string, suitId: string): string
	return rankId .. ":" .. suitId
end

local function baseIdentityKey(deckSetId: string, rankId: string, suitId: string): string
	return deckSetId .. ":" .. slotKey(rankId, suitId)
end

local function formKey(baseIdentityId: string, editionId: string): string
	return baseIdentityId .. ":" .. editionId
end

local identities = {}

for _, deckSet in deckSets do
	for _, rank in ranks do
		for _, suit in suits do
			local key = baseIdentityKey(deckSet.id, rank.id, suit.id)
			table.insert(identities, {
				id = key,
				deckSetId = deckSet.id,
				rankId = rank.id,
				suitId = suit.id,
				slotKey = slotKey(rank.id, suit.id),
			})
		end
	end
end

local forms = {}

for _, identity in identities do
	for _, edition in editions do
		table.insert(forms, {
			id = formKey(identity.id, edition.id),
			baseIdentityId = identity.id,
			editionId = edition.id,
			launchEnabled = edition.launchEnabled,
		})
	end
end

local LaunchCatalog = {
	catalogVersion = 1,
	ranks = ranks,
	suits = suits,
	deckSets = deckSets,
	identities = identities,
	editions = editions,
	forms = forms,
	grades = grades,
	powerTiers = powerTiers,
	traits = traits,
	affinities = affinities,
	jokers = jokers,
	arcana = arcana,
	souls = souls,
	formations = formations,
	stackableBonuses = stackableBonuses,
	retiredIds = {},
	slotKey = slotKey,
	baseIdentityKey = baseIdentityKey,
	formKey = formKey,
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

return deepFreeze(LaunchCatalog)
