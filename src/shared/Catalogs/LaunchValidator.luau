--!strict

local LaunchValidator = {}

local function deepFreeze(value: any): any
	if type(value) == "table" and not table.isfrozen(value) then
		for _, child in value do
			deepFreeze(child)
		end
		table.freeze(value)
	end
	return value
end

local expectedJokers = {
	"arcana_adept",
	"archivist",
	"balanced_scales",
	"black_thread",
	"crown_engine",
	"fivefold",
	"full_binder",
	"full_spectrum",
	"golden_dividend",
	"house_of_fifty_two",
	"joker_union",
	"number_cruncher",
	"overclock",
	"packstorm",
	"painted_pip",
	"paper_shield",
	"pocket_ledger",
	"quick_shuffle",
	"red_ribbon",
	"royal_chorus",
	"set_architect",
	"set_purist",
	"set_resonator",
	"streak_keeper",
}

local expectedArcana = {
	"clover",
	"examiner",
	"forge",
	"gem",
	"heart",
	"mask",
	"polisher",
	"regrader",
	"spear",
	"stair",
	"treasury",
	"voice",
}

local expectedIds = {
	deckSets = { "classic", "radioactive", "astral" },
	ranks = { "2", "3", "4", "5", "6", "7", "8", "9", "10", "jack", "queen", "king", "ace" },
	suits = { "hearts", "diamonds", "clubs", "spades" },
	editions = { "normal", "foil", "golden", "steel" },
	grades = { "f", "e", "d", "c", "b", "a", "s", "ss", "sr", "ur", "lr" },
	powerTiers = {
		"common",
		"uncommon",
		"rare",
		"epic",
		"legendary",
		"mythic",
		"secret",
		"infernal",
		"celestial",
		"chaos",
		"zenith",
	},
	traits = {
		"fortune",
		"fierce",
		"guardian",
		"swift",
		"lucky",
		"scholar",
		"critical",
		"resilient",
		"radiant",
		"adaptive",
		"efficient",
		"social",
	},
	affinities = { "balanced_formations", "successful_streak_cash", "exact_sum_crown" },
	formations = {
		"single",
		"twin",
		"twin_pair",
		"triple",
		"sequence",
		"monosuit",
		"court",
		"spectrum",
		"full_cluster",
		"quad",
		"crown_run",
		"perfect_sum",
	},
	stackableBonuses = { "perfect_sum_accuracy" },
}

local expectedJokerRarities = { "common", "uncommon", "rare", "epic", "legendary", "mythic" }

local expectedJokerOrder = {
	"pocket_ledger",
	"painted_pip",
	"paper_shield",
	"quick_shuffle",
	"red_ribbon",
	"black_thread",
	"number_cruncher",
	"full_binder",
	"balanced_scales",
	"royal_chorus",
	"set_purist",
	"golden_dividend",
	"streak_keeper",
	"full_spectrum",
	"set_architect",
	"fivefold",
	"arcana_adept",
	"crown_engine",
	"set_resonator",
	"overclock",
	"joker_union",
	"packstorm",
	"house_of_fifty_two",
	"archivist",
}

local expectedArcanaOrder = {
	"polisher",
	"treasury",
	"forge",
	"heart",
	"gem",
	"clover",
	"spear",
	"stair",
	"examiner",
	"regrader",
	"voice",
	"mask",
}

local expectedCalculationStages = {
	"validate_input",
	"joker_registry",
	"before_formation_detection",
	"formation_detection",
	"after_formation_detected",
	"before_card_contribution",
	"face_value",
	"edition",
	"grade",
	"power_tier",
	"trait",
	"affinity",
	"card_joker_additive",
	"card_joker_multiplicative",
	"after_card_contribution",
	"before_formation_multiplier",
	"formation_multiplier",
	"deck_joker_additive",
	"deck_joker_multiplicative",
	"personal_active_boost",
	"server_event_boost",
	"mode_modifier",
	"gameplay_cap",
	"after_formation_reward",
	"finalize_result",
}

local allowedJokerStages = {
	before_formation_detection = true,
	before_card_contribution = true,
	before_formation_multiplier = true,
	after_formation_reward = true,
	on_formation_success = true,
	on_formation_failure = true,
	on_task_complete = true,
}

local handlers = {
	edition = {
		edition_normal = true,
		edition_component_multiplier = true,
	},
	trait = {
		trait_cash_multiplier = true,
		trait_power_multiplier = true,
		trait_guard_multiplier = true,
		trait_draw_speed = true,
		trait_pack_progress = true,
		trait_grade_experience = true,
		trait_server_critical = true,
		trait_streak_guard = true,
		trait_affinity_contribution = true,
		trait_adjacent_rank = true,
		trait_task_progress = true,
		trait_cooperative_reward = true,
	},
	affinity = {
		affinity_balanced_formation = true,
		affinity_streak_cash = true,
		affinity_exact_sum_crown = true,
	},
	formation = {
		formation_single = true,
		formation_twin = true,
		formation_twin_pair = true,
		formation_triple = true,
		formation_sequence = true,
		formation_monosuit = true,
		formation_court = true,
		formation_spectrum = true,
		formation_full_cluster = true,
		formation_quad = true,
		formation_crown_run = true,
		formation_perfect_sum = true,
	},
	joker = {
		joker_component_add = true,
		joker_state_modifier = true,
		joker_card_color_add = true,
		joker_number_card_add = true,
		joker_filled_slots_add = true,
		joker_balanced_colors_add = true,
		joker_rank_group_add = true,
		joker_deck_set_threshold_add = true,
		joker_golden_cash_enhance = true,
		joker_streak_loss_intent = true,
		joker_formation_multiplier = true,
		joker_affinity_threshold = true,
		joker_card_count_multiplier = true,
		joker_affinity_strength = true,
		joker_output_tradeoff = true,
		joker_other_effect_enhance = true,
		joker_success_counter_intent = true,
		joker_filled_slots_multiplier = true,
		joker_collection_add = true,
	},
	arcana = {
		arcana_unlock_edition = true,
		arcana_unlock_suit = true,
		arcana_unlock_next_rank = true,
		arcana_raise_grade = true,
		arcana_choose_nonregressing_grade = true,
		arcana_choose_trait = true,
		arcana_replace_trait = true,
	},
	soul = {
		soul_neutral = true,
	},
}

local function assertStableId(id: any, failureId: string)
	assert(
		type(id) == "string"
			and id:match("^[a-z0-9_]+$") ~= nil
			and id:sub(1, 1) ~= "_"
			and id:sub(-1) ~= "_"
			and id:find("__", 1, true) == nil,
		failureId
	)
end

local function indexUnique(records: any, failurePrefix: string): { [string]: any }
	assert(type(records) == "table", failurePrefix .. "-001 records missing")
	local result = {}
	for _, record in records do
		assert(type(record) == "table", failurePrefix .. "-002 malformed record")
		assertStableId(record.id, failurePrefix .. "-003 invalid id")
		assert(result[record.id] == nil, failurePrefix .. "-004 duplicate id")
		result[record.id] = record
	end
	return result
end

local function assertRational(value: any, failureId: string)
	assert(type(value) == "table", failureId)
	assert(
		type(value.numerator) == "number"
			and value.numerator == value.numerator
			and value.numerator % 1 == 0
			and value.numerator >= 0
			and value.numerator <= 1000000,
		failureId
	)
	assert(
		type(value.denominator) == "number"
			and value.denominator == value.denominator
			and value.denominator % 1 == 0
			and value.denominator > 0
			and value.denominator <= 1000000,
		failureId
	)
end

local function enabledIds(records: { any }): { string }
	local ids = {}
	for _, record in records do
		if record.launchEnabled ~= false then
			table.insert(ids, record.id)
		end
	end
	table.sort(ids)
	return ids
end

local function assertExactIds(actual: { string }, expected: { string }, failureId: string)
	assert(type(actual) == "table", failureId)
	local count = 0
	for key in actual do
		assert(type(key) == "number" and key % 1 == 0 and key >= 1 and key <= #actual, failureId)
		count += 1
	end
	assert(count == #actual, failureId)
	assert(#actual == #expected, failureId)
	for index, id in expected do
		assert(actual[index] == id, failureId)
	end
end

local function recordIds(records: { any }): { string }
	local ids = {}
	for _, record in records do
		table.insert(ids, record.id)
	end
	return ids
end

local function enabledRecordIds(records: { any }): { string }
	local ids = {}
	for _, record in records do
		if record.launchEnabled ~= false then
			table.insert(ids, record.id)
		end
	end
	return ids
end

local function sortedMapKeys(records: any): { string }
	assert(type(records) == "table", "P001-CONFIG-025 balance map missing")
	local ids = {}
	for id in records do
		assert(type(id) == "string" and id ~= "", "P001-CONFIG-026 invalid balance id")
		table.insert(ids, id)
	end
	table.sort(ids)
	return ids
end

local function sortedCopy(values: { string }): { string }
	local result = {}
	for _, value in values do
		table.insert(result, value)
	end
	table.sort(result)
	return result
end

local function assertExactMapKeys(records: any, expected: { string }, failureId: string)
	assertExactIds(sortedMapKeys(records), sortedCopy(expected), failureId)
end

local function assertInteger(
	value: any,
	minimum: number,
	maximum: number,
	failureId: string
): number
	assert(
		type(value) == "number"
			and value == value
			and value ~= math.huge
			and value ~= -math.huge
			and value % 1 == 0
			and value >= minimum
			and value <= maximum,
		failureId
	)
	return value
end

local function assertAssetContract(record: any, categoryId: string, failureId: string)
	assert(record.assetContractId == categoryId .. "_" .. record.id, failureId)
end

local function assertBalanceReference(record: any, balances: any, failureId: string)
	assert(record.balanceId == record.id and balances[record.balanceId] ~= nil, failureId)
end

local function validateCatalog(catalog: any): any
	assert(type(catalog) == "table" and catalog.catalogVersion == 1, "P001-CATALOG-001 version")
	assertExactMapKeys(catalog, {
		"catalogVersion",
		"ranks",
		"suits",
		"deckSets",
		"identities",
		"editions",
		"forms",
		"grades",
		"powerTiers",
		"traits",
		"affinities",
		"jokers",
		"arcana",
		"souls",
		"formations",
		"stackableBonuses",
		"retiredIds",
		"slotKey",
		"baseIdentityKey",
		"formKey",
	}, "P001-CATALOG-086 schema")
	local rankById = indexUnique(catalog.ranks, "P001-RANK")
	local suitById = indexUnique(catalog.suits, "P001-SUIT")
	local deckSetById = indexUnique(catalog.deckSets, "P001-DECKSET")
	local editionById = indexUnique(catalog.editions, "P001-EDITION")
	local gradeById = indexUnique(catalog.grades, "P001-GRADE")
	local tierById = indexUnique(catalog.powerTiers, "P001-TIER")
	local traitById = indexUnique(catalog.traits, "P001-TRAIT")
	local affinityById = indexUnique(catalog.affinities, "P001-AFFINITY")
	local jokerById = indexUnique(catalog.jokers, "P001-JOKER")
	local arcanaById = indexUnique(catalog.arcana, "P001-ARCANA")
	local soulById = indexUnique(catalog.souls, "P001-SOUL")
	local formationById = indexUnique(catalog.formations, "P001-FORMATION-CATALOG")
	local stackableBonusById = indexUnique(catalog.stackableBonuses, "P001-STACKABLE-BONUS")

	assert(#catalog.ranks == 13, "P001-CATALOG-002 rank count")
	assert(#catalog.suits == 4, "P001-CATALOG-003 suit count")
	assert(#enabledIds(catalog.deckSets) == 3, "P001-CATALOG-004 deck set count")
	assert(#enabledIds(catalog.editions) == 4, "P001-CATALOG-005 edition count")
	assert(#catalog.grades == 11, "P001-CATALOG-006 grade count")
	assert(#catalog.powerTiers == 11, "P001-CATALOG-007 tier count")
	assert(#catalog.traits == 12, "P001-CATALOG-008 trait count")
	assert(#enabledIds(catalog.jokers) == 24, "P001-CATALOG-009 joker count")
	assert(#enabledIds(catalog.arcana) == 12, "P001-CATALOG-010 arcana count")
	assert(#catalog.formations == 12, "P001-CATALOG-011 formation count")
	assert(#catalog.identities == 156, "P001-CATALOG-012 identity count")
	assert(#catalog.forms == 624, "P001-CATALOG-013 form count")
	assert(#enabledIds(catalog.souls) == 0, "P001-CATALOG-014 soul enabled")

	assertExactIds(enabledIds(catalog.jokers), expectedJokers, "P001-CATALOG-015 selected jokers")
	assertExactIds(enabledIds(catalog.arcana), expectedArcana, "P001-CATALOG-016 selected arcana")
	assertExactIds(
		recordIds(catalog.deckSets),
		expectedIds.deckSets,
		"P001-CATALOG-051 deck set order"
	)
	assertExactIds(recordIds(catalog.ranks), expectedIds.ranks, "P001-CATALOG-052 rank order")
	assertExactIds(recordIds(catalog.suits), expectedIds.suits, "P001-CATALOG-053 suit order")
	assertExactIds(
		recordIds(catalog.editions),
		expectedIds.editions,
		"P001-CATALOG-054 edition order"
	)
	assertExactIds(recordIds(catalog.grades), expectedIds.grades, "P001-CATALOG-055 grade order")
	assertExactIds(
		recordIds(catalog.powerTiers),
		expectedIds.powerTiers,
		"P001-CATALOG-056 tier order"
	)
	assertExactIds(recordIds(catalog.traits), expectedIds.traits, "P001-CATALOG-057 trait order")
	assertExactIds(
		recordIds(catalog.affinities),
		expectedIds.affinities,
		"P001-CATALOG-058 affinity order"
	)
	assertExactIds(
		recordIds(catalog.formations),
		expectedIds.formations,
		"P001-CATALOG-059 formation order"
	)
	assertExactIds(
		recordIds(catalog.stackableBonuses),
		expectedIds.stackableBonuses,
		"P001-CATALOG-082 stackable bonus order"
	)
	assertExactIds(
		enabledRecordIds(catalog.jokers),
		expectedJokerOrder,
		"P001-CATALOG-060 joker order"
	)
	assertExactIds(
		enabledRecordIds(catalog.arcana),
		expectedArcanaOrder,
		"P001-CATALOG-061 arcana order"
	)
	for index, rank in catalog.ranks do
		assert(rank.order == index and rank.value == index + 1, "P001-CATALOG-062 rank value")
	end
	for index, suit in catalog.suits do
		assert(suit.order == index, "P001-CATALOG-063 suit order value")
	end
	for _, deckSet in catalog.deckSets do
		assertAssetContract(deckSet, "deck_set", "P001-CATALOG-064 deck set asset")
	end
	for _, edition in catalog.editions do
		assertAssetContract(edition, "edition", "P001-CATALOG-065 edition asset")
	end
	for _, joker in catalog.jokers do
		assertAssetContract(joker, "joker", "P001-CATALOG-066 joker asset")
	end
	for _, entry in catalog.arcana do
		assertAssetContract(entry, "arcana", "P001-CATALOG-067 arcana asset")
	end
	for _, formation in catalog.formations do
		assertAssetContract(formation, "formation", "P001-CATALOG-068 formation asset")
	end

	local identityIds = {}
	for _, identity in catalog.identities do
		assert(type(identity.id) == "string", "P001-CATALOG-017 identity id")
		assert(identityIds[identity.id] == nil, "P001-CATALOG-018 duplicate identity")
		identityIds[identity.id] = true
		assert(deckSetById[identity.deckSetId] ~= nil, "P001-CATALOG-019 identity deck set")
		assert(rankById[identity.rankId] ~= nil, "P001-CATALOG-020 identity rank")
		assert(suitById[identity.suitId] ~= nil, "P001-CATALOG-021 identity suit")
		assert(
			identity.slotKey == catalog.slotKey(identity.rankId, identity.suitId),
			"P001-CATALOG-022 slot key"
		)
		assert(
			identity.id
				== catalog.baseIdentityKey(identity.deckSetId, identity.rankId, identity.suitId),
			"P001-CATALOG-023 identity key"
		)
	end

	local formIds = {}
	for _, form in catalog.forms do
		assert(formIds[form.id] == nil, "P001-CATALOG-024 duplicate form")
		formIds[form.id] = true
		assert(identityIds[form.baseIdentityId], "P001-CATALOG-025 form identity")
		assert(editionById[form.editionId] ~= nil, "P001-CATALOG-026 form edition")
		assert(
			form.id == catalog.formKey(form.baseIdentityId, form.editionId),
			"P001-CATALOG-027 form key"
		)
	end

	for _, grade in catalog.grades do
		assert(grade.balanceId == grade.id, "P001-CATALOG-028 grade balance id")
	end
	for _, tier in catalog.powerTiers do
		assert(tier.balanceId == tier.id, "P001-CATALOG-030 tier balance id")
	end
	for _, edition in catalog.editions do
		assert(handlers.edition[edition.handlerId], "P001-CATALOG-031 edition handler")
		assert(edition.balanceId == edition.id, "P001-CATALOG-032 edition balance id")
	end
	for _, trait in catalog.traits do
		assert(handlers.trait[trait.handlerId], "P001-CATALOG-033 trait handler")
		assert(trait.balanceId == trait.id, "P001-CATALOG-069 trait balance id")
	end
	for _, affinity in catalog.affinities do
		assert(handlers.affinity[affinity.handlerId], "P001-CATALOG-034 affinity handler")
		assert(affinity.balanceId == affinity.id, "P001-CATALOG-035 affinity balance id")
	end
	for _, deckSet in catalog.deckSets do
		assert(affinityById[deckSet.affinityId] ~= nil, "P001-CATALOG-037 affinity reference")
	end

	local rarityCounts = {}
	for _, joker in catalog.jokers do
		assert(handlers.joker[joker.handlerId], "P001-CATALOG-038 joker handler")
		assert(joker.balanceId == joker.id, "P001-CATALOG-039 joker balance id")
		assert(type(joker.stages) == "table" and #joker.stages > 0, "P001-CATALOG-040 joker stages")
		local seenStages = {}
		for _, stageId in joker.stages do
			assertStableId(stageId, "P001-CATALOG-041 joker stage id")
			assert(allowedJokerStages[stageId], "P001-CATALOG-074 unsupported joker stage")
			assert(not seenStages[stageId], "P001-CATALOG-070 duplicate joker stage")
			seenStages[stageId] = true
		end
		assert(type(joker.conflicts) == "table", "P001-CATALOG-071 joker conflicts")
		for _, conflictId in joker.conflicts do
			local conflict = jokerById[conflictId]
			assert(conflict ~= nil and conflictId ~= joker.id, "P001-CATALOG-042 joker conflict")
			local reciprocal = false
			for _, reciprocalId in conflict.conflicts do
				reciprocal = reciprocal or reciprocalId == joker.id
			end
			assert(reciprocal, "P001-CATALOG-072 unresolved joker conflict")
			assert(
				not (joker.launchEnabled == true and conflict.launchEnabled == true),
				"P001-CATALOG-073 enabled joker conflict"
			)
		end
		if joker.launchEnabled ~= false then
			local rarityKnown = false
			for _, rarityId in expectedJokerRarities do
				rarityKnown = rarityKnown or rarityId == joker.rarityId
			end
			assert(rarityKnown, "P001-CATALOG-075 joker rarity")
			rarityCounts[joker.rarityId] = (rarityCounts[joker.rarityId] or 0) + 1
		end
	end
	assert(
		rarityCounts.common == 8
			and rarityCounts.uncommon == 5
			and rarityCounts.rare == 4
			and rarityCounts.epic == 3
			and rarityCounts.legendary == 2
			and rarityCounts.mythic == 2,
		"P001-CATALOG-043 joker rarity distribution"
	)

	local formationPriorities = {}
	for index, definition in catalog.formations do
		assert(handlers.formation[definition.handlerId], "P001-CATALOG-044 formation handler")
		assert(
			type(definition.priority) == "number"
				and definition.priority == index
				and formationPriorities[definition.priority] == nil,
			"P001-CATALOG-045 formation priority"
		)
		formationPriorities[definition.priority] = true
		assert(definition.balanceId == definition.id, "P001-CATALOG-046 formation balance id")
		assert(type(definition.stackableBonusIds) == "table", "P001-CATALOG-083 stackable bonuses")
		for _, bonusId in definition.stackableBonusIds do
			assert(stackableBonusById[bonusId] ~= nil, "P001-CATALOG-084 stackable bonus reference")
		end
	end
	assert(
		#formationById.perfect_sum.stackableBonusIds == 1
			and formationById.perfect_sum.stackableBonusIds[1] == "perfect_sum_accuracy",
		"P001-CATALOG-085 perfect sum bonus"
	)

	for _, entry in catalog.arcana do
		assert(handlers.arcana[entry.handlerId], "P001-CATALOG-047 arcana handler")
		if entry.categoryId == "edition" then
			assert(editionById[entry.targetId] ~= nil, "P001-CATALOG-048 arcana edition target")
		elseif entry.categoryId == "suit" then
			assert(suitById[entry.targetId] ~= nil, "P001-CATALOG-049 arcana suit target")
		elseif entry.categoryId == "rank" then
			assert(entry.targetId == "next", "P001-CATALOG-076 arcana rank target")
		elseif entry.categoryId == "grade" then
			assert(
				entry.targetId == "next" or entry.targetId == "choice",
				"P001-CATALOG-077 arcana grade target"
			)
		elseif entry.categoryId == "trait" then
			assert(
				entry.targetId == "empty" or entry.targetId == "choice",
				"P001-CATALOG-078 arcana trait target"
			)
		else
			error("P001-CATALOG-079 arcana category")
		end
	end
	for _, entry in catalog.souls do
		assert(handlers.soul[entry.handlerId], "P001-CATALOG-050 soul handler")
	end
	assert(type(catalog.retiredIds) == "table", "P001-CATALOG-080 retired ids missing")
	local currentIds = {}
	for _, records in
		{
			catalog.ranks,
			catalog.suits,
			catalog.deckSets,
			catalog.editions,
			catalog.grades,
			catalog.powerTiers,
			catalog.traits,
			catalog.affinities,
			catalog.jokers,
			catalog.arcana,
			catalog.souls,
			catalog.formations,
			catalog.stackableBonuses,
			catalog.identities,
			catalog.forms,
		}
	do
		for _, record in records do
			currentIds[record.id] = true
		end
	end
	local seenRetired = {}
	for _, retiredId in catalog.retiredIds do
		assert(
			type(retiredId) == "string"
				and retiredId:match("^[a-z0-9_:]+$") ~= nil
				and not currentIds[retiredId]
				and not seenRetired[retiredId],
			"P001-CATALOG-081 retired id collision"
		)
		seenRetired[retiredId] = true
	end

	return {
		rankById = rankById,
		suitById = suitById,
		deckSetById = deckSetById,
		editionById = editionById,
		gradeById = gradeById,
		tierById = tierById,
		traitById = traitById,
		affinityById = affinityById,
		jokerById = jokerById,
		arcanaById = arcanaById,
		soulById = soulById,
		formationById = formationById,
		stackableBonusById = stackableBonusById,
	}
end

local function validateFormationBalance(definition: any, balance: any)
	assert(
		type(balance) == "table" and type(balance.multipliers) == "table",
		"P001-BALANCE-001 formation"
	)
	local expectedSizes = {
		single = { [1] = true },
		twin = { [2] = true },
		twin_pair = { [4] = true },
		triple = { [3] = true },
		sequence = { [3] = true, [4] = true, [5] = true },
		monosuit = { [3] = true, [4] = true, [5] = true },
		court = { [3] = true },
		spectrum = { [4] = true, [5] = true },
		full_cluster = { [5] = true },
		quad = { [4] = true },
		crown_run = { [5] = true },
		perfect_sum = { [1] = true, [2] = true, [3] = true, [4] = true, [5] = true },
	}
	local expected = expectedSizes[definition.id]
	local count = 0
	for size, multiplier in balance.multipliers do
		assert(expected[size] == true, "P001-BALANCE-002 formation size")
		assertRational(multiplier, "P001-BALANCE-003 formation multiplier")
		count += 1
	end
	local expectedCount = 0
	for _ in expected do
		expectedCount += 1
	end
	assert(count == expectedCount, "P001-BALANCE-004 formation size missing")
end

local function validateTraitBalance(definition: any, balance: any)
	assert(type(balance) == "table" and type(balance.params) == "table", "P001-BALANCE-005 trait")
	local params = balance.params
	local paramSchemas = {
		trait_cash_multiplier = { "percent" },
		trait_power_multiplier = { "percent" },
		trait_guard_multiplier = { "percent" },
		trait_draw_speed = { "percent" },
		trait_pack_progress = { "percent" },
		trait_grade_experience = { "percent" },
		trait_server_critical = { "chanceUnits", "percent" },
		trait_streak_guard = { "usesPerRound" },
		trait_affinity_contribution = { "percent" },
		trait_adjacent_rank = { "usesPerRound" },
		trait_task_progress = { "percent" },
		trait_cooperative_reward = { "percent" },
	}
	assertExactMapKeys(
		params,
		paramSchemas[definition.handlerId],
		"P001-BALANCE-091 trait param schema"
	)
	for _, value in params do
		assertInteger(value, 0, 1000000, "P001-BALANCE-007 trait param")
	end
	local handlerId = definition.handlerId
	if handlerId == "trait_server_critical" then
		assertInteger(params.chanceUnits, 1, 100000, "P001-BALANCE-008 critical chance")
		assertInteger(params.percent, 1, 1000000, "P001-BALANCE-009 critical percent")
	elseif handlerId == "trait_streak_guard" or handlerId == "trait_adjacent_rank" then
		assertInteger(params.usesPerRound, 1, 100, "P001-BALANCE-010 trait uses")
	else
		assertInteger(params.percent, 1, 1000000, "P001-BALANCE-011 trait percent")
	end
end

local function validateJokerBalance(definition: any, balance: any, indexes: any)
	assert(
		type(balance) == "table"
			and type(balance.params) == "table"
			and type(balance.caps) == "table",
		"P001-BALANCE-012 joker"
	)
	local params = balance.params
	local paramSchemas = {
		joker_component_add = { "componentId", "percent" },
		joker_state_modifier = { "modifierId", "percent" },
		joker_card_color_add = { "color", "percent" },
		joker_number_card_add = { "percent" },
		joker_filled_slots_add = { "requiredSlots", "percent" },
		joker_balanced_colors_add = { "percent" },
		joker_rank_group_add = { "groupId", "percent" },
		joker_deck_set_threshold_add = { "threshold", "percent" },
		joker_golden_cash_enhance = { "percent" },
		joker_streak_loss_intent = { "reduction", "usesPerRound" },
		joker_formation_multiplier = { "formationId", "numerator", "denominator" },
		joker_affinity_threshold = { "reduction", "floor" },
		joker_card_count_multiplier = { "cardCount", "numerator", "denominator" },
		joker_affinity_strength = { "percent" },
		joker_output_tradeoff = { "speedPercent", "guardPenaltyPercent" },
		joker_other_effect_enhance = { "percent" },
		joker_success_counter_intent = { "threshold", "packCount" },
		joker_filled_slots_multiplier = { "requiredSlots", "numerator", "denominator" },
		joker_collection_add = { "formsPerStep", "percentPerStep", "percentScale", "maxPercent" },
	}
	local capSchemas = {
		joker_component_add = {},
		joker_state_modifier = { "percent" },
		joker_card_color_add = {},
		joker_number_card_add = {},
		joker_filled_slots_add = { "requiredSlots" },
		joker_balanced_colors_add = {},
		joker_rank_group_add = {},
		joker_deck_set_threshold_add = { "thresholdFloor" },
		joker_golden_cash_enhance = {},
		joker_streak_loss_intent = { "usesPerRound" },
		joker_formation_multiplier = {},
		joker_affinity_threshold = { "floor" },
		joker_card_count_multiplier = {},
		joker_affinity_strength = { "percent" },
		joker_output_tradeoff = { "speedPercent", "guardPenaltyPercent" },
		joker_other_effect_enhance = { "percent" },
		joker_success_counter_intent = { "threshold", "packCount" },
		joker_filled_slots_multiplier = { "requiredSlots" },
		joker_collection_add = { "maxPercent" },
	}
	assert(paramSchemas[definition.handlerId] ~= nil, "P001-BALANCE-088 joker param schema")
	assertExactMapKeys(
		params,
		paramSchemas[definition.handlerId],
		"P001-BALANCE-089 joker param schema"
	)
	assertExactMapKeys(
		balance.caps,
		capSchemas[definition.handlerId],
		"P001-BALANCE-090 joker cap schema"
	)
	local expectedStages = {
		joker_component_add = { "before_formation_multiplier" },
		joker_card_color_add = { "before_card_contribution" },
		joker_number_card_add = { "before_card_contribution" },
		joker_filled_slots_add = { "before_formation_multiplier" },
		joker_balanced_colors_add = { "before_formation_multiplier" },
		joker_rank_group_add = { "before_formation_multiplier" },
		joker_deck_set_threshold_add = { "before_formation_multiplier" },
		joker_golden_cash_enhance = { "before_card_contribution" },
		joker_streak_loss_intent = { "on_formation_failure" },
		joker_formation_multiplier = { "before_formation_multiplier" },
		joker_affinity_threshold = { "before_card_contribution" },
		joker_card_count_multiplier = { "before_formation_multiplier" },
		joker_affinity_strength = { "before_card_contribution" },
		joker_output_tradeoff = { "before_formation_multiplier", "after_formation_reward" },
		joker_other_effect_enhance = { "before_formation_detection" },
		joker_success_counter_intent = { "on_formation_success" },
		joker_filled_slots_multiplier = { "before_formation_multiplier" },
		joker_collection_add = { "before_formation_multiplier" },
	}
	if definition.handlerId == "joker_state_modifier" then
		expectedStages.joker_state_modifier = if params.modifierId == "draw_resolve_speed"
			then { "after_formation_reward" }
			else { "on_task_complete" }
	end
	assertExactIds(
		definition.stages,
		expectedStages[definition.handlerId],
		"P001-BALANCE-092 joker stage schema"
	)
	for _, value in params do
		if type(value) == "number" then
			assertInteger(value, 0, 1000000, "P001-BALANCE-014 joker param")
		else
			assertStableId(value, "P001-BALANCE-015 joker param value")
		end
	end
	for _, value in balance.caps do
		assertInteger(value, 0, 1000000, "P001-BALANCE-017 joker cap")
	end

	local handlerId = definition.handlerId
	if handlerId == "joker_component_add" then
		assert(
			params.componentId == "cash"
				or params.componentId == "power"
				or params.componentId == "guard",
			"P001-BALANCE-018 component id"
		)
		assertInteger(params.percent, 1, 1000000, "P001-BALANCE-019 percent")
	elseif handlerId == "joker_state_modifier" then
		assert(
			params.modifierId == "draw_resolve_speed" or params.modifierId == "arcana_task_reward",
			"P001-BALANCE-020 modifier id"
		)
		assertInteger(params.percent, 1, 1000000, "P001-BALANCE-021 state percent")
		assert(balance.caps.percent == params.percent, "P001-BALANCE-022 state cap")
	elseif handlerId == "joker_card_color_add" then
		assert(params.color == "red" or params.color == "black", "P001-BALANCE-023 color")
		assertInteger(params.percent, 1, 1000000, "P001-BALANCE-024 color percent")
	elseif handlerId == "joker_number_card_add" or handlerId == "joker_balanced_colors_add" then
		assertInteger(params.percent, 1, 1000000, "P001-BALANCE-025 additive percent")
	elseif handlerId == "joker_filled_slots_add" or handlerId == "joker_deck_set_threshold_add" then
		local threshold = params.requiredSlots or params.threshold
		assertInteger(threshold, 1, 52, "P001-BALANCE-026 slot threshold")
		assertInteger(params.percent, 1, 1000000, "P001-BALANCE-027 threshold percent")
		assert(next(balance.caps) ~= nil, "P001-BALANCE-028 threshold cap")
	elseif handlerId == "joker_rank_group_add" then
		assert(params.groupId == "court", "P001-BALANCE-029 rank group")
		assertInteger(params.percent, 1, 1000000, "P001-BALANCE-030 rank percent")
	elseif handlerId == "joker_golden_cash_enhance" then
		assertInteger(params.percent, 1, 1000000, "P001-BALANCE-031 golden percent")
	elseif handlerId == "joker_streak_loss_intent" then
		assertInteger(params.reduction, 1, 100, "P001-BALANCE-032 streak reduction")
		assertInteger(params.usesPerRound, 1, 100, "P001-BALANCE-033 streak uses")
		assert(balance.caps.usesPerRound == params.usesPerRound, "P001-BALANCE-034 streak cap")
	elseif handlerId == "joker_formation_multiplier" then
		assert(
			indexes.formationById[params.formationId] ~= nil,
			"P001-BALANCE-035 formation reference"
		)
		assertRational(params, "P001-BALANCE-036 formation rational")
	elseif handlerId == "joker_affinity_threshold" then
		assertInteger(params.reduction, 1, 51, "P001-BALANCE-037 threshold reduction")
		assertInteger(params.floor, 1, 52, "P001-BALANCE-038 threshold floor")
		assert(balance.caps.floor == params.floor, "P001-BALANCE-039 threshold cap")
	elseif handlerId == "joker_card_count_multiplier" then
		assertInteger(params.cardCount, 1, 5, "P001-BALANCE-040 card count")
		assertRational(params, "P001-BALANCE-041 card count rational")
	elseif handlerId == "joker_affinity_strength" then
		assertInteger(params.percent, 1, 1000000, "P001-BALANCE-042 affinity percent")
		assert(balance.caps.percent == params.percent, "P001-BALANCE-043 affinity cap")
	elseif handlerId == "joker_output_tradeoff" then
		assertInteger(params.speedPercent, 1, 100, "P001-BALANCE-044 speed percent")
		assertInteger(params.guardPenaltyPercent, 1, 86, "P001-BALANCE-045 guard penalty")
		assert(
			balance.caps.speedPercent == params.speedPercent
				and balance.caps.guardPenaltyPercent == params.guardPenaltyPercent,
			"P001-BALANCE-046 tradeoff caps"
		)
	elseif handlerId == "joker_other_effect_enhance" then
		assertInteger(params.percent, 1, 1000000, "P001-BALANCE-047 enhance percent")
		assert(balance.caps.percent == params.percent, "P001-BALANCE-048 enhance cap")
	elseif handlerId == "joker_success_counter_intent" then
		assertInteger(params.threshold, 1, 1000000, "P001-BALANCE-049 counter threshold")
		assertInteger(params.packCount, 1, 100, "P001-BALANCE-050 pack count")
		assert(
			balance.caps.threshold == params.threshold
				and balance.caps.packCount == params.packCount,
			"P001-BALANCE-051 counter caps"
		)
	elseif handlerId == "joker_filled_slots_multiplier" then
		assertInteger(params.requiredSlots, 1, 52, "P001-BALANCE-052 filled slots")
		assertRational(params, "P001-BALANCE-053 filled rational")
		assert(balance.caps.requiredSlots == params.requiredSlots, "P001-BALANCE-054 filled cap")
	elseif handlerId == "joker_collection_add" then
		assertInteger(params.formsPerStep, 1, 624, "P001-BALANCE-055 forms step")
		assertInteger(params.percentPerStep, 1, 1000000, "P001-BALANCE-056 step percent")
		assertInteger(params.percentScale, 1, 1000, "P001-BALANCE-057 percent scale")
		assertInteger(params.maxPercent, 1, 1000000, "P001-BALANCE-058 collection max")
		assert(balance.caps.maxPercent == params.maxPercent, "P001-BALANCE-059 collection cap")
	else
		error("P001-BALANCE-060 unsupported joker handler")
	end
end

local function validateBalance(config: any, catalog: any, indexes: any)
	assert(type(config.balance) == "table", "P001-BALANCE-061 balance missing")
	assertExactMapKeys(config.balance, {
		"editions",
		"grades",
		"powerTiers",
		"traits",
		"affinities",
		"formations",
		"stackableBonuses",
		"jokers",
	}, "P001-BALANCE-097 schema")
	assertExactMapKeys(
		config.balance.editions,
		recordIds(catalog.editions),
		"P001-BALANCE-062 editions"
	)
	assertExactMapKeys(config.balance.grades, recordIds(catalog.grades), "P001-BALANCE-063 grades")
	assertExactMapKeys(
		config.balance.powerTiers,
		recordIds(catalog.powerTiers),
		"P001-BALANCE-064 tiers"
	)
	assertExactMapKeys(config.balance.traits, recordIds(catalog.traits), "P001-BALANCE-065 traits")
	assertExactMapKeys(
		config.balance.affinities,
		recordIds(catalog.affinities),
		"P001-BALANCE-066 affinities"
	)
	assertExactMapKeys(
		config.balance.formations,
		recordIds(catalog.formations),
		"P001-BALANCE-067 formations"
	)
	assertExactMapKeys(
		config.balance.stackableBonuses,
		recordIds(catalog.stackableBonuses),
		"P001-BALANCE-093 stackable bonuses"
	)
	assertExactMapKeys(config.balance.jokers, recordIds(catalog.jokers), "P001-BALANCE-068 jokers")

	for _, edition in catalog.editions do
		local balance = config.balance.editions[edition.balanceId]
		assertBalanceReference(
			edition,
			config.balance.editions,
			"P001-BALANCE-069 edition reference"
		)
		assert(type(balance.multipliers) == "table", "P001-BALANCE-070 edition multipliers")
		for componentId, multiplier in balance.multipliers do
			assert(
				componentId == "all"
					or componentId == "cash"
					or componentId == "power"
					or componentId == "guard"
					or componentId == "pack_progress"
					or componentId == "grade_experience",
				"P001-BALANCE-071 edition component"
			)
			assertRational(multiplier, "P001-BALANCE-072 edition multiplier")
		end
	end

	local previousXp = -1
	for _, grade in catalog.grades do
		assertBalanceReference(grade, config.balance.grades, "P001-BALANCE-073 grade reference")
		local balance = config.balance.grades[grade.balanceId]
		assertRational(balance.multiplier, "P001-BALANCE-074 grade multiplier")
		assertInteger(balance.cumulativeXp, 0, 1000000, "P001-BALANCE-075 grade xp")
		assert(balance.cumulativeXp > previousXp, "P001-BALANCE-076 grade progression")
		previousXp = balance.cumulativeXp
	end
	for _, tier in catalog.powerTiers do
		assertBalanceReference(tier, config.balance.powerTiers, "P001-BALANCE-077 tier reference")
		assertRational(
			config.balance.powerTiers[tier.balanceId].multiplier,
			"P001-BALANCE-078 tier multiplier"
		)
	end
	for _, trait in catalog.traits do
		assertBalanceReference(trait, config.balance.traits, "P001-BALANCE-079 trait reference")
		validateTraitBalance(trait, config.balance.traits[trait.balanceId])
	end
	for _, affinity in catalog.affinities do
		assertBalanceReference(
			affinity,
			config.balance.affinities,
			"P001-BALANCE-080 affinity reference"
		)
		local balance = config.balance.affinities[affinity.balanceId]
		assert(#balance.thresholds == 4 and #balance.percents == 4, "P001-BALANCE-081 affinity")
		local previousThreshold = 0
		local previousPercent = 0
		for index, threshold in balance.thresholds do
			assertInteger(threshold, 1, 52, "P001-BALANCE-082 affinity threshold")
			assert(threshold > previousThreshold, "P001-BALANCE-083 affinity threshold order")
			local percent =
				assertInteger(balance.percents[index], 1, 100, "P001-BALANCE-084 affinity percent")
			assert(percent >= previousPercent, "P001-BALANCE-085 affinity percent order")
			previousThreshold = threshold
			previousPercent = percent
		end
	end
	for _, formation in catalog.formations do
		assertBalanceReference(
			formation,
			config.balance.formations,
			"P001-BALANCE-086 formation reference"
		)
		validateFormationBalance(formation, config.balance.formations[formation.balanceId])
	end
	for _, bonus in catalog.stackableBonuses do
		assertBalanceReference(
			bonus,
			config.balance.stackableBonuses,
			"P001-BALANCE-094 stackable bonus reference"
		)
		local balance = config.balance.stackableBonuses[bonus.balanceId]
		assertExactMapKeys(balance, { "multiplier" }, "P001-BALANCE-095 stackable bonus schema")
		assertRational(balance.multiplier, "P001-BALANCE-096 stackable bonus multiplier")
	end
	for _, joker in catalog.jokers do
		assertBalanceReference(joker, config.balance.jokers, "P001-BALANCE-087 joker reference")
		validateJokerBalance(joker, config.balance.jokers[joker.balanceId], indexes)
	end
end

local function validateWeights(entries: any, total: number, failureId: string)
	local sum = 0
	local seen = {}
	for _, entry in entries do
		assertStableId(entry.id, failureId)
		assert(not seen[entry.id], failureId)
		seen[entry.id] = true
		assert(
			type(entry.weight) == "number" and entry.weight % 1 == 0 and entry.weight > 0,
			failureId
		)
		sum += entry.weight
	end
	assert(sum == total, failureId)
end

local function validateConfig(config: any, indexes: any, catalog: any)
	assert(type(config) == "table" and config.configVersion == 1, "P001-CONFIG-001 version")
	assert(config.fixtureVersion == 1, "P001-CONFIG-069 fixture version")
	assertExactMapKeys(config, {
		"configVersion",
		"fixtureVersion",
		"calculationStages",
		"features",
		"limits",
		"balance",
		"economy",
		"odds",
		"antiAbuse",
		"modeMultipliers",
		"gameplayCaps",
	}, "P001-CONFIG-070 schema")
	assertExactIds(
		config.calculationStages,
		expectedCalculationStages,
		"P001-CONFIG-027 calculation stage order"
	)
	assertExactMapKeys(config.features, {
		"deckSets",
		"packsEnabled",
		"jokersEnabled",
		"arcanaEnabled",
		"traitsEnabled",
		"salvageEnabled",
		"formationsEnabled",
		"passiveRewardsEnabled",
		"friendClashRewardsEnabled",
		"tradeEnabled",
		"soulsEnabled",
	}, "P001-CONFIG-062 feature keys")
	assert(config.features.tradeEnabled == false, "P001-CONFIG-002 trade enabled early")
	assert(config.features.soulsEnabled == false, "P001-CONFIG-003 souls enabled")
	assertExactMapKeys(
		config.features.deckSets,
		expectedIds.deckSets,
		"P001-CONFIG-054 deck set features"
	)
	for _, deckSetId in expectedIds.deckSets do
		assert(config.features.deckSets[deckSetId] == true, "P001-CONFIG-055 deck set disabled")
	end
	for _, featureId in
		{
			"packsEnabled",
			"jokersEnabled",
			"arcanaEnabled",
			"traitsEnabled",
			"salvageEnabled",
			"formationsEnabled",
			"passiveRewardsEnabled",
			"friendClashRewardsEnabled",
		}
	do
		assert(config.features[featureId] == true, "P001-CONFIG-056 launch feature disabled")
	end
	assert(config.limits.launchNumberMax == 999999999999999, "P001-CONFIG-004 launch bound")
	assert(config.limits.activeDeckSlots == 52, "P001-CONFIG-005 deck slots")
	assert(config.limits.activeJokerSlots == 5, "P001-CONFIG-006 joker slots")
	assert(config.limits.activeSoulSlots == 0, "P001-CONFIG-007 soul slots")
	assert(
		config.limits.serverCapacity == 8
			and config.limits.formationHandSize == 8
			and config.limits.formationSubmissionMin == 1
			and config.limits.formationSubmissionMax == 5
			and config.limits.offlineSeconds == 14400
			and config.limits.rationalComponentMax == 1000000,
		"P001-CONFIG-067 limit values"
	)
	assertExactMapKeys(config.limits, {
		"launchNumberMax",
		"activeDeckSlots",
		"activeJokerSlots",
		"activeSoulSlots",
		"serverCapacity",
		"formationHandSize",
		"formationSubmissionMin",
		"formationSubmissionMax",
		"offlineSeconds",
		"rationalComponentMax",
	}, "P001-CONFIG-063 limit keys")
	for _, value in config.limits do
		assertInteger(value, 0, 999999999999999, "P001-CONFIG-029 limit value")
	end
	validateBalance(config, catalog, indexes)
	assertExactMapKeys(config.economy, {
		"startingBalances",
		"packPrices",
		"salvage",
		"currencies",
		"reasonIds",
		"activeBaselinePerMinute",
		"passivePercentOfActive",
	}, "P001-CONFIG-071 economy schema")
	assertExactMapKeys(config.economy.salvage, {
		"gradeInkByGrade",
		"traitEssence",
		"ascensionFragmentsByTier",
	}, "P001-CONFIG-072 salvage schema")
	assertExactMapKeys(config.economy.salvage.gradeInkByGrade, {
		"f",
		"e",
		"d",
		"c",
		"b",
		"a",
		"s",
		"ss",
		"sr",
		"ur",
		"lr",
	}, "P001-CONFIG-073 grade salvage keys")
	assertExactMapKeys(config.economy.salvage.ascensionFragmentsByTier, {
		"common",
		"uncommon",
		"rare",
		"epic",
		"legendary",
		"mythic",
		"secret",
		"infernal",
		"celestial",
		"chaos",
		"zenith",
	}, "P001-CONFIG-074 tier salvage keys")
	for _, amount in config.economy.salvage.gradeInkByGrade do
		assertInteger(amount, 0, 999999999999999, "P001-CONFIG-075 grade salvage amount")
	end
	assertInteger(
		config.economy.salvage.traitEssence,
		0,
		999999999999999,
		"P001-CONFIG-076 trait salvage amount"
	)
	for _, amount in config.economy.salvage.ascensionFragmentsByTier do
		assertInteger(amount, 0, 999999999999999, "P001-CONFIG-077 tier salvage amount")
	end

	local reasons = {}
	for _, reasonId in config.economy.reasonIds do
		assertStableId(reasonId, "P001-CONFIG-008 reason id")
		assert(not reasons[reasonId], "P001-CONFIG-009 duplicate reason")
		reasons[reasonId] = true
	end
	local currencies = indexUnique(config.economy.currencies, "P001-CURRENCY")
	assertExactIds(recordIds(config.economy.currencies), {
		"cash",
		"joker_tickets",
		"arcana_dust",
		"grade_ink",
		"trait_essence",
		"duel_tokens",
		"ascension_fragments",
		"soul_fragments",
	}, "P001-CONFIG-064 currency order")
	assertExactMapKeys(config.economy.startingBalances, {
		"cash",
		"joker_tickets",
		"arcana_dust",
		"grade_ink",
		"trait_essence",
		"duel_tokens",
		"ascension_fragments",
		"soul_fragments",
	}, "P001-CONFIG-030 starting balances")
	for _, currency in config.economy.currencies do
		assert(
			type(currency.cap) == "number" and currency.cap % 1 == 0 and currency.cap >= 0,
			"P001-CONFIG-010 currency cap"
		)
		assert(currency.transferRule == "not_tradable", "P001-CONFIG-011 transfer rule")
		if currency.id ~= "soul_fragments" then
			assert(#currency.sourceReasonIds > 0, "P001-CONFIG-012 currency source")
			assert(#currency.sinkReasonIds > 0, "P001-CONFIG-013 currency sink")
		else
			assert(
				currency.cap == 0 and currency.launchEnabled == false,
				"P001-CONFIG-014 soul currency"
			)
		end
		for _, reasonId in currency.sourceReasonIds do
			assert(reasons[reasonId], "P001-CONFIG-015 source reason")
		end
		for _, reasonId in currency.sinkReasonIds do
			assert(reasons[reasonId], "P001-CONFIG-016 sink reason")
		end
		assert(
			config.economy.startingBalances[currency.id] == 0,
			"P001-CONFIG-031 starting balance"
		)
	end
	assert(currencies.soul_fragments ~= nil, "P001-CONFIG-017 reserved soul currency")

	for deckSetId, price in config.economy.packPrices do
		if deckSetId ~= "joker" and deckSetId ~= "arcana" then
			assert(indexes.deckSetById[deckSetId] ~= nil, "P001-CONFIG-018 pack deck set")
		end
		assert(
			type(price) == "number" and price % 1 == 0 and price > 0,
			"P001-CONFIG-019 pack price"
		)
	end
	assertExactMapKeys(
		config.economy.packPrices,
		{ "classic", "radioactive", "astral", "joker", "arcana" },
		"P001-CONFIG-032 pack price keys"
	)
	assertInteger(
		config.economy.activeBaselinePerMinute,
		1,
		999999999999999,
		"P001-CONFIG-033 active baseline"
	)
	assertInteger(config.economy.passivePercentOfActive, 0, 100, "P001-CONFIG-034 passive percent")
	assert(
		config.economy.activeBaselinePerMinute * 100
			>= config.economy.activeBaselinePerMinute
				* config.economy.passivePercentOfActive
				* 5,
		"P001-CONFIG-020 active passive ratio"
	)
	validateWeights(config.odds.powerTiers, config.odds.weightTotal, "P001-CONFIG-021 tier weights")
	validateWeights(
		config.odds.jokerRarities,
		config.odds.weightTotal,
		"P001-CONFIG-022 joker weights"
	)
	for _, entry in config.odds.powerTiers do
		assert(indexes.tierById[entry.id] ~= nil, "P001-CONFIG-023 tier weight reference")
	end
	assert(config.odds.weightTotal == 100000, "P001-CONFIG-057 weight total")
	assertExactMapKeys(config.odds, {
		"weightTotal",
		"powerTiers",
		"jokerRarities",
		"traitChanceUnits",
		"pity",
		"earlyProtection",
	}, "P001-CONFIG-072 odds schema")
	assertExactIds(
		recordIds(config.odds.powerTiers),
		expectedIds.powerTiers,
		"P001-CONFIG-035 tier weight order"
	)
	assertExactIds(
		recordIds(config.odds.jokerRarities),
		expectedJokerRarities,
		"P001-CONFIG-036 joker weight order"
	)
	local expectedTierWeights = { 66000, 20000, 8000, 3500, 1500, 650, 250, 80, 15, 4, 1 }
	for index, entry in config.odds.powerTiers do
		assert(entry.weight == expectedTierWeights[index], "P001-CONFIG-037 tier weight value")
	end
	local expectedJokerWeights = { 55000, 25000, 12000, 5000, 2500, 500 }
	for index, entry in config.odds.jokerRarities do
		assert(entry.weight == expectedJokerWeights[index], "P001-CONFIG-038 joker weight value")
	end
	assert(
		type(config.odds.traitChanceUnits) == "number"
			and config.odds.traitChanceUnits % 1 == 0
			and config.odds.traitChanceUnits >= 0
			and config.odds.traitChanceUnits <= config.odds.weightTotal,
		"P001-CONFIG-024 trait chance"
	)
	assert(config.odds.traitChanceUnits == 10000, "P001-CONFIG-058 trait chance value")
	assert(type(config.odds.pity) == "table", "P001-CONFIG-039 pity missing")
	assertExactMapKeys(
		config.odds.pity,
		{ "rare", "legendary", "mythic", "jokerEpic", "jokerLegendary" },
		"P001-CONFIG-059 pity keys"
	)
	for pityId, rule in config.odds.pity do
		assert(type(pityId) == "string" and pityId ~= "", "P001-CONFIG-040 pity id")
		assertInteger(rule.threshold, 1, 1000000, "P001-CONFIG-041 pity threshold")
		assertStableId(rule.minimumId, "P001-CONFIG-042 pity minimum")
	end
	assert(
		config.odds.pity.rare.threshold == 20
			and config.odds.pity.rare.minimumId == "rare"
			and config.odds.pity.legendary.threshold == 100
			and config.odds.pity.legendary.minimumId == "legendary"
			and config.odds.pity.mythic.threshold == 500
			and config.odds.pity.mythic.minimumId == "mythic"
			and config.odds.pity.jokerEpic.threshold == 20
			and config.odds.pity.jokerEpic.minimumId == "epic"
			and config.odds.pity.jokerLegendary.threshold == 100
			and config.odds.pity.jokerLegendary.minimumId == "legendary",
		"P001-CONFIG-060 pity values"
	)
	for _, value in config.odds.earlyProtection do
		assertInteger(value, 0, 1000000, "P001-CONFIG-044 early protection value")
	end
	assertExactMapKeys(config.odds.earlyProtection, {
		"starterUniqueSlots",
		"minimumEmptyTargetsBelow26",
		"minimumEmptyTargetsFrom26Through44",
		"arcanaUniqueProtectionCount",
	}, "P001-CONFIG-073 early protection schema")
	assert(
		config.odds.earlyProtection.starterUniqueSlots == 5
			and config.odds.earlyProtection.minimumEmptyTargetsBelow26 == 3
			and config.odds.earlyProtection.minimumEmptyTargetsFrom26Through44 == 1
			and config.odds.earlyProtection.arcanaUniqueProtectionCount == 6,
		"P001-CONFIG-061 early protection values"
	)
	for _, value in config.antiAbuse do
		if type(value) == "number" then
			assertInteger(value, 0, 1000000, "P001-CONFIG-046 anti abuse value")
		else
			assertStableId(value, "P001-CONFIG-047 anti abuse value")
		end
	end
	assertExactMapKeys(config.antiAbuse, {
		"duplicateOperationBehavior",
		"socialDailyRewardCap",
		"sameOpponentFullRewardCount",
		"sameOpponentReducedRewardCount",
		"sameOpponentReducedPercent",
		"sameOpponentCutoffCount",
		"friendClashRequestCooldownSeconds",
		"formationRewardCadenceSeconds",
	}, "P001-CONFIG-065 anti abuse keys")
	assert(
		config.antiAbuse.sameOpponentFullRewardCount
				< config.antiAbuse.sameOpponentReducedRewardCount
			and config.antiAbuse.sameOpponentReducedRewardCount
				< config.antiAbuse.sameOpponentCutoffCount,
		"P001-CONFIG-048 anti abuse boundaries"
	)
	assert(
		config.antiAbuse.sameOpponentReducedPercent > 0
			and config.antiAbuse.sameOpponentReducedPercent < 100,
		"P001-CONFIG-068 anti abuse reduction"
	)
	for modeId, multiplier in config.modeMultipliers do
		assertStableId(modeId, "P001-CONFIG-049 mode id")
		assertRational(multiplier, "P001-CONFIG-050 mode multiplier")
	end
	assertExactMapKeys(
		config.modeMultipliers,
		{ "formation_rush", "friend_clash_power", "friend_clash_fair" },
		"P001-CONFIG-066 mode keys"
	)
	assertExactMapKeys(
		config.gameplayCaps,
		{ "cash", "power", "guard", "pack_progress", "grade_experience" },
		"P001-CONFIG-051 gameplay cap keys"
	)
	for capId, cap in config.gameplayCaps do
		assertStableId(capId, "P001-CONFIG-052 gameplay cap id")
		assertInteger(cap, 1, config.limits.launchNumberMax, "P001-CONFIG-053 gameplay cap")
	end
end

function LaunchValidator.validate(catalog: any, config: any): any
	local indexes = validateCatalog(catalog)
	validateConfig(config, indexes, catalog)
	return deepFreeze({
		catalogVersion = catalog.catalogVersion,
		configVersion = config.configVersion,
		fixtureVersion = config.fixtureVersion,
		counts = {
			deckSets = #enabledIds(catalog.deckSets),
			identities = #catalog.identities,
			editions = #enabledIds(catalog.editions),
			forms = #catalog.forms,
			grades = #catalog.grades,
			powerTiers = #catalog.powerTiers,
			traits = #catalog.traits,
			jokers = #enabledIds(catalog.jokers),
			arcana = #enabledIds(catalog.arcana),
			formations = #catalog.formations,
			stackableBonuses = #catalog.stackableBonuses,
			souls = #enabledIds(catalog.souls),
		},
		enabledIds = {
			deckSets = enabledIds(catalog.deckSets),
			editions = enabledIds(catalog.editions),
			jokers = enabledIds(catalog.jokers),
			arcana = enabledIds(catalog.arcana),
			formations = enabledIds(catalog.formations),
			stackableBonuses = recordIds(catalog.stackableBonuses),
		},
	})
end

return table.freeze(LaunchValidator)
