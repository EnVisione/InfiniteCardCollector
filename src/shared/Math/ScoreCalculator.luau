--!strict

local ScoreCalculator = {}

local componentIds = { "cash", "power", "guard", "packProgress", "gradeExperience" }

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

local function copyComponents(components: any): any
	return {
		cash = components.cash,
		power = components.power,
		guard = components.guard,
		packProgress = components.packProgress,
		gradeExperience = components.gradeExperience,
	}
end

local function sortStateIntents(intents: { any })
	table.sort(intents, function(left, right)
		if left.intentId == right.intentId then
			return left.sourceId < right.sourceId
		end
		return left.intentId < right.intentId
	end)
end

local function hasStage(stages: { string }, expectedId: string): boolean
	for _, stageId in stages do
		if stageId == expectedId then
			return true
		end
	end
	return false
end

local function appendStateIntentTrace(trace: { any }, intents: { any }, stageId: string)
	for _, intent in intents do
		table.insert(trace, {
			stageId = stageId,
			handlerId = "state_intent",
			operation = "emit_intent",
			reasonId = intent.sourceId,
			details = intent,
		})
	end
end

local function traceScale(
	trace: { any },
	stageId: string,
	handlerId: string,
	componentId: string,
	before: number,
	multiplier: any,
	after: number,
	reasonId: string?
)
	table.insert(trace, {
		stageId = stageId,
		handlerId = handlerId,
		componentId = componentId,
		operation = "multiply_rational",
		input = before,
		numerator = multiplier.numerator,
		denominator = multiplier.denominator,
		output = after,
		reasonId = reasonId,
	})
end

local function scaleComponents(
	safeNumber: any,
	components: any,
	multiplier: any,
	stageId: string,
	handlerId: string,
	trace: { any },
	reasonId: string?,
	selectedIds: { [string]: boolean }?
): any
	local result = copyComponents(components)
	for _, componentId in componentIds do
		if selectedIds == nil or selectedIds[componentId] == true then
			local before = result[componentId]
			result[componentId] = safeNumber.scale(before, multiplier)
			traceScale(
				trace,
				stageId,
				handlerId,
				componentId,
				before,
				multiplier,
				result[componentId],
				reasonId
			)
		end
	end
	return result
end

local function applyEdition(
	safeNumber: any,
	jokerRegistry: any,
	jokerContext: any,
	edition: any,
	editionBalance: any,
	card: any,
	components: any,
	trace: { any }
): any
	local result = copyComponents(components)
	local allMultiplier = editionBalance.multipliers.all
	if allMultiplier ~= nil then
		result = scaleComponents(
			safeNumber,
			result,
			allMultiplier,
			"edition",
			edition.handlerId,
			trace,
			edition.id,
			nil
		)
	end
	local keyMap = {
		cash = "cash",
		power = "power",
		guard = "guard",
		pack_progress = "packProgress",
		grade_experience = "gradeExperience",
	}
	for sourceId, targetId in keyMap do
		local multiplier = editionBalance.multipliers[sourceId]
		if multiplier ~= nil then
			multiplier = jokerRegistry.editionMultiplier(
				jokerContext,
				safeNumber,
				card,
				targetId,
				multiplier,
				trace
			)
			local before = result[targetId]
			result[targetId] = safeNumber.scale(before, multiplier)
			traceScale(
				trace,
				"edition",
				edition.handlerId,
				targetId,
				before,
				multiplier,
				result[targetId],
				edition.id
			)
		end
	end
	return result
end

local function applyTrait(
	safeNumber: any,
	trait: any?,
	traitBalance: any?,
	card: any,
	input: any,
	components: any,
	trace: { any },
	stateIntents: { any }
): any
	if trait == nil then
		return components
	end
	assert(type(traitBalance) == "table", "P001-CALC-018 trait balance missing")
	local result = copyComponents(components)
	local handlerId = trait.handlerId
	local params = traitBalance.params
	local selected = nil
	local multiplier = nil
	if handlerId == "trait_cash_multiplier" then
		selected = { cash = true }
		multiplier = { numerator = 100 + params.percent, denominator = 100 }
	elseif handlerId == "trait_power_multiplier" then
		selected = { power = true }
		multiplier = { numerator = 100 + params.percent, denominator = 100 }
	elseif handlerId == "trait_guard_multiplier" then
		selected = { guard = true }
		multiplier = { numerator = 100 + params.percent, denominator = 100 }
	elseif handlerId == "trait_pack_progress" then
		selected = { packProgress = true }
		multiplier = { numerator = 100 + params.percent, denominator = 100 }
	elseif handlerId == "trait_grade_experience" then
		selected = { gradeExperience = true }
		multiplier = { numerator = 100 + params.percent, denominator = 100 }
	elseif
		handlerId == "trait_server_critical"
		and input.criticalTraitInstanceIds ~= nil
		and input.criticalTraitInstanceIds[card.instanceId] == true
	then
		multiplier = { numerator = 100 + params.percent, denominator = 100 }
	elseif handlerId == "trait_draw_speed" then
		table.insert(stateIntents, {
			intentId = "trait_draw_resolve_delay_down",
			sourceId = card.instanceId,
			reductionBasis = params.percent * 100,
		})
	elseif handlerId == "trait_adjacent_rank" and card.rankOverrideApplied == true then
		table.insert(stateIntents, {
			intentId = "trait_adjacent_rank_consumed",
			sourceId = card.instanceId,
			uses = params.usesPerRound,
			fromRankId = card.rankId,
			toRankId = card.formationRankId,
		})
	elseif handlerId == "trait_task_progress" then
		table.insert(stateIntents, {
			intentId = "trait_task_progress_up",
			sourceId = card.instanceId,
			basisPoints = params.percent * 100,
		})
	elseif handlerId == "trait_cooperative_reward" then
		table.insert(stateIntents, {
			intentId = "trait_cooperative_reward_up",
			sourceId = card.instanceId,
			basisPoints = params.percent * 100,
		})
	end
	if multiplier ~= nil then
		result = scaleComponents(
			safeNumber,
			result,
			multiplier,
			"trait",
			handlerId,
			trace,
			trait.id,
			selected
		)
	end
	return result
end

local function traitFailureIntents(
	traitById: { [string]: any },
	config: any,
	cards: { any }
): { any }
	local intents = {}
	for _, card in cards do
		if card.traitId ~= nil then
			local trait = traitById[card.traitId]
			assert(trait ~= nil, "P001-CALC-011 invalid trait")
			local balance = config.balance.traits[trait.balanceId]
			assert(balance ~= nil, "P001-CALC-013 trait balance missing")
			if trait.handlerId == "trait_streak_guard" then
				table.insert(intents, {
					intentId = "trait_prevent_streak_loss_once",
					sourceId = card.instanceId,
					uses = balance.params.usesPerRound,
				})
			end
		end
	end
	return intents
end

local function balancedColors(cards: { any }): boolean
	local red = 0
	local black = 0
	for _, card in cards do
		if card.suitColor == "red" then
			red += 1
		else
			black += 1
		end
	end
	return red > 0 and red == black
end

local function affinityBasis(
	safeNumber: any,
	affinityBalance: any,
	count: number,
	thresholdReductionBasis: number,
	strengthBasis: number
): number
	local basis = 0
	for index, threshold in affinityBalance.thresholds do
		local effectiveThresholdBasis = math.max(100, threshold * 100 - thresholdReductionBasis)
		if count * 100 >= effectiveThresholdBasis then
			basis = affinityBalance.percents[index] * 100
		end
	end
	local maximumBasis = affinityBalance.percents[#affinityBalance.percents] * 100
	if basis == maximumBasis and strengthBasis > 0 then
		basis = safeNumber.scale(basis, {
			numerator = 10000 + strengthBasis,
			denominator = 10000,
		})
	end
	return basis
end

local function applyAffinity(
	safeNumber: any,
	affinity: any,
	affinityBalance: any,
	card: any,
	input: any,
	formationMatches: { [string]: boolean },
	allCards: { any },
	modifiers: any,
	components: any,
	trace: { any }
): any
	local count = input.activeDeckSetCounts[card.deckSetId] or 0
	local basis = affinityBasis(
		safeNumber,
		affinityBalance,
		count,
		modifiers.thresholdReductionBasis,
		if card.deckSetId == modifiers.strengthDeckSetId then modifiers.strengthBasis else 0
	)
	if card.traitId == "radiant" and basis > 0 then
		basis = safeNumber.scale(basis, { numerator = 120, denominator = 100 })
	end
	local applies = false
	local selected = nil
	if affinity.handlerId == "affinity_balanced_formation" then
		applies = balancedColors(allCards)
	elseif affinity.handlerId == "affinity_streak_cash" then
		applies = input.formationStreak > 0
		selected = { cash = true }
	elseif affinity.handlerId == "affinity_exact_sum_crown" then
		applies = formationMatches.perfect_sum == true or formationMatches.crown_run == true
	end
	if not applies or basis <= 0 then
		return components
	end
	return scaleComponents(
		safeNumber,
		components,
		{ numerator = 10000 + basis, denominator = 10000 },
		"affinity",
		affinity.handlerId,
		trace,
		affinity.id,
		selected
	)
end

local function calculateInner(dependencies: any, input: any): any
	local catalog = dependencies.catalog
	local config = dependencies.config
	local safeNumber = dependencies.safeNumber
	local detector = dependencies.formationDetector
	local jokerRegistry = dependencies.jokerRegistry
	assert(type(input) == "table", "P001-CALC-001 input missing")
	assert(input.catalogVersion == catalog.catalogVersion, "P001-CALC-002 stale catalog version")
	assert(input.configVersion == config.configVersion, "P001-CALC-003 stale config version")
	local deckSetById = indexById(catalog.deckSets)
	safeNumber.assertInteger(input.activeDeckFilledSlots, 52)
	safeNumber.assertInteger(input.discoveredFormCount, #catalog.forms)
	safeNumber.assertInteger(input.formationStreak, 1000000)
	safeNumber.assertInteger(input.successfulFormationCount, 1000000)
	assert(type(input.activeDeckSetCounts) == "table", "P001-CALC-004 deck counts missing")
	local deckSetCountTotal = 0
	for deckSetId, count in input.activeDeckSetCounts do
		assert(
			type(deckSetId) == "string"
				and deckSetById[deckSetId] ~= nil
				and deckSetById[deckSetId].launchEnabled == true,
			"P001-CALC-005 deck set count id"
		)
		safeNumber.assertInteger(count, 52)
		deckSetCountTotal = safeNumber.add(deckSetCountTotal, count)
	end
	assert(
		deckSetCountTotal == input.activeDeckFilledSlots,
		"P001-CALC-012 deck count total mismatch"
	)
	local modeMultiplier = config.modeMultipliers[input.modeId]
	assert(modeMultiplier ~= nil, "P001-CALC-006 invalid mode")
	assert(
		input.criticalTraitInstanceIds == nil or type(input.criticalTraitInstanceIds) == "table",
		"P001-CALC-019 critical outcomes invalid"
	)
	for instanceId, outcome in input.criticalTraitInstanceIds or {} do
		assert(
			type(instanceId) == "string" and instanceId ~= "" and type(outcome) == "boolean",
			"P001-CALC-020 critical outcome invalid"
		)
	end
	for _, multipliers in
		{
			input.personalActiveBoostMultipliers or {},
			input.serverEventBoostMultipliers or {},
		}
	do
		assert(type(multipliers) == "table", "P001-CALC-021 boost map invalid")
		for boostId, multiplier in multipliers do
			assert(type(boostId) == "string" and boostId ~= "", "P001-CALC-022 boost id invalid")
			safeNumber.assertRational(multiplier)
		end
	end

	local trace = {
		{
			stageId = "validate_input",
			handlerId = "calculation_contract",
			operation = "accept_versions",
			details = {
				catalogVersion = input.catalogVersion,
				configVersion = input.configVersion,
			},
		},
	}
	local stateIntents = {}
	local jokerContext = jokerRegistry.context(catalog, config, input)
	local activeJokerIds = {}
	for _, active in jokerContext.slotOrder do
		table.insert(activeJokerIds, active.definition.id)
		table.insert(trace, {
			stageId = "joker_registry",
			handlerId = active.definition.handlerId,
			operation = "activate",
			reasonId = active.definition.id,
			details = { slot = active.slot },
		})
	end
	table.insert(trace, {
		stageId = "before_formation_detection",
		handlerId = "joker_registry",
		operation = "resolve_active_effects",
		details = { activeJokerIds = activeJokerIds },
	})
	local formationResult = detector.detect(
		catalog,
		config,
		input.cards,
		input.formationTarget,
		input.formationRankOverrides
	)
	local normalizedCardIds = {}
	for _, card in formationResult.normalizedCards do
		table.insert(normalizedCardIds, card.instanceId)
	end
	local candidateIds = {}
	local formationMatches = {}
	for _, candidate in formationResult.candidates do
		table.insert(candidateIds, candidate.id)
		formationMatches[candidate.id] = true
	end
	local editionById = indexById(catalog.editions)
	local gradeById = indexById(catalog.grades)
	local tierById = indexById(catalog.powerTiers)
	local traitById = indexById(catalog.traits)
	local affinityById = indexById(catalog.affinities)
	for _, card in formationResult.normalizedCards do
		local edition = editionById[card.editionId]
		local grade = gradeById[card.gradeId]
		local tier = tierById[card.powerTierId]
		local deckSet = deckSetById[card.deckSetId]
		assert(edition ~= nil and edition.launchEnabled == true, "P001-CALC-007 invalid edition")
		assert(grade ~= nil, "P001-CALC-008 invalid grade")
		assert(tier ~= nil, "P001-CALC-009 invalid tier")
		assert(deckSet ~= nil and deckSet.launchEnabled == true, "P001-CALC-010 invalid deck set")
		assert(
			(input.activeDeckSetCounts[card.deckSetId] or 0) > 0,
			"P001-CALC-025 submitted deck set absent"
		)
		assert(affinityById[deckSet.affinityId] ~= nil, "P001-CALC-024 invalid affinity")
		if card.traitId ~= nil then
			local trait = traitById[card.traitId]
			assert(trait ~= nil, "P001-CALC-011 invalid trait")
			assert(
				config.balance.traits[trait.balanceId] ~= nil,
				"P001-CALC-013 trait balance missing"
			)
		end
	end
	local selectedFormation = formationResult.selected
	table.insert(trace, {
		stageId = "formation_detection",
		handlerId = "formation_detector",
		operation = if selectedFormation == nil then "no_match" else "select_best_base",
		reasonId = if selectedFormation == nil then "no_formation" else selectedFormation.id,
		details = {
			candidateCount = #formationResult.candidates,
			candidateIds = candidateIds,
			normalizedCardIds = normalizedCardIds,
			priority = if selectedFormation == nil then 0 else selectedFormation.priority,
		},
	})
	if selectedFormation == nil then
		local failureIntents = jokerRegistry.stateIntents(jokerContext, safeNumber, input, false)
		for _, intent in traitFailureIntents(traitById, config, formationResult.normalizedCards) do
			table.insert(failureIntents, intent)
		end
		sortStateIntents(failureIntents)
		appendStateIntentTrace(trace, failureIntents, "after_formation_reward")
		return {
			accepted = false,
			reasonId = "no_formation",
			formation = nil,
			components = nil,
			stateIntents = failureIntents,
			trace = trace,
			versions = {
				catalogVersion = catalog.catalogVersion,
				configVersion = config.configVersion,
			},
		}
	end
	table.insert(trace, {
		stageId = "after_formation_detected",
		handlerId = "formation_detector",
		operation = "resolve_stackable_bonuses",
		reasonId = selectedFormation.id,
		details = { stackableBonusCount = #selectedFormation.stackableBonusIds },
	})

	local affinityModifiers =
		jokerRegistry.affinityModifiers(jokerContext, safeNumber, input.activeDeckSetCounts, trace)
	local total = { cash = 0, power = 0, guard = 0, packProgress = 0, gradeExperience = 0 }
	for _, card in formationResult.normalizedCards do
		local edition = editionById[card.editionId]
		local grade = gradeById[card.gradeId]
		local tier = tierById[card.powerTierId]
		local deckSet = deckSetById[card.deckSetId]
		assert(edition ~= nil and edition.launchEnabled == true, "P001-CALC-007 invalid edition")
		assert(grade ~= nil, "P001-CALC-008 invalid grade")
		assert(tier ~= nil, "P001-CALC-009 invalid tier")
		assert(deckSet ~= nil and deckSet.launchEnabled == true, "P001-CALC-010 invalid deck set")
		local trait = nil
		local traitBalance = nil
		if card.traitId ~= nil then
			trait = traitById[card.traitId]
			assert(trait ~= nil, "P001-CALC-011 invalid trait")
			traitBalance = config.balance.traits[trait.balanceId]
			assert(traitBalance ~= nil, "P001-CALC-013 trait balance missing")
		end
		local editionBalance = config.balance.editions[edition.balanceId]
		local gradeBalance = config.balance.grades[grade.balanceId]
		local tierBalance = config.balance.powerTiers[tier.balanceId]
		local affinity = affinityById[deckSet.affinityId]
		local affinityBalance = config.balance.affinities[affinity.balanceId]
		assert(editionBalance ~= nil, "P001-CALC-014 edition balance missing")
		assert(gradeBalance ~= nil, "P001-CALC-015 grade balance missing")
		assert(tierBalance ~= nil, "P001-CALC-016 tier balance missing")
		assert(affinityBalance ~= nil, "P001-CALC-017 affinity balance missing")
		local components = {
			cash = card.rankValue,
			power = card.rankValue,
			guard = card.rankValue,
			packProgress = card.rankValue,
			gradeExperience = card.rankValue,
		}
		for _, active in jokerContext.active do
			if hasStage(active.definition.stages, "before_card_contribution") then
				table.insert(trace, {
					stageId = "before_card_contribution",
					handlerId = active.definition.handlerId,
					operation = "subscribe",
					reasonId = active.definition.id,
					details = { instanceId = card.instanceId },
				})
			end
		end
		table.insert(trace, {
			stageId = "face_value",
			handlerId = "rank_value",
			operation = "initialize_components",
			input = card.rankValue,
			output = card.rankValue,
			reasonId = card.rankId,
			details = { instanceId = card.instanceId },
		})
		components = applyEdition(
			safeNumber,
			jokerRegistry,
			jokerContext,
			edition,
			editionBalance,
			card,
			components,
			trace
		)
		components = scaleComponents(
			safeNumber,
			components,
			gradeBalance.multiplier,
			"grade",
			"grade_multiplier",
			trace,
			grade.id,
			nil
		)
		components = scaleComponents(
			safeNumber,
			components,
			tierBalance.multiplier,
			"power_tier",
			"power_tier_multiplier",
			trace,
			tier.id,
			nil
		)
		components = applyTrait(
			safeNumber,
			trait,
			traitBalance,
			card,
			input,
			components,
			trace,
			stateIntents
		)
		components = applyAffinity(
			safeNumber,
			affinity,
			affinityBalance,
			card,
			input,
			formationMatches,
			formationResult.normalizedCards,
			affinityModifiers,
			components,
			trace
		)
		components = jokerRegistry.applyCard(jokerContext, safeNumber, card, components, trace)
		table.insert(trace, {
			stageId = "after_card_contribution",
			handlerId = "card_contribution",
			operation = "finalize_card",
			reasonId = card.instanceId,
			details = copyComponents(components),
		})
		for _, componentId in componentIds do
			total[componentId] = safeNumber.add(total[componentId], components[componentId])
		end
	end

	for _, active in jokerContext.active do
		if hasStage(active.definition.stages, "before_formation_multiplier") then
			table.insert(trace, {
				stageId = "before_formation_multiplier",
				handlerId = active.definition.handlerId,
				operation = "subscribe",
				reasonId = active.definition.id,
			})
		end
	end
	total = scaleComponents(
		safeNumber,
		total,
		selectedFormation.multiplier,
		"formation_multiplier",
		"formation_multiplier",
		trace,
		selectedFormation.id,
		nil
	)
	for _, bonusId in selectedFormation.stackableBonusIds do
		local bonus = config.balance.stackableBonuses[bonusId]
		assert(bonus ~= nil, "P001-CALC-023 stackable bonus missing")
		total = scaleComponents(
			safeNumber,
			total,
			bonus.multiplier,
			"formation_multiplier",
			"stackable_bonus",
			trace,
			bonusId,
			nil
		)
	end
	total = jokerRegistry.applyDeck(
		jokerContext,
		safeNumber,
		input,
		formationMatches,
		formationResult.normalizedCards,
		total,
		trace
	)

	for _, boostGroup in
		{
			{
				stageId = "personal_active_boost",
				multipliers = input.personalActiveBoostMultipliers or {},
			},
			{
				stageId = "server_event_boost",
				multipliers = input.serverEventBoostMultipliers or {},
			},
		}
	do
		local boostIds = {}
		for boostId in boostGroup.multipliers do
			table.insert(boostIds, boostId)
		end
		table.sort(boostIds)
		for _, boostId in boostIds do
			total = scaleComponents(
				safeNumber,
				total,
				boostGroup.multipliers[boostId],
				boostGroup.stageId,
				"boost_multiplier",
				trace,
				boostId,
				nil
			)
		end
	end
	total = scaleComponents(
		safeNumber,
		total,
		modeMultiplier,
		"mode_modifier",
		"mode_multiplier",
		trace,
		input.modeId,
		nil
	)

	local capMap = {
		cash = "cash",
		power = "power",
		guard = "guard",
		packProgress = "pack_progress",
		gradeExperience = "grade_experience",
	}
	for _, componentId in componentIds do
		local capId = capMap[componentId]
		local capped, capTrace =
			safeNumber.applyCap(total[componentId], capId, config.gameplayCaps[capId])
		if capTrace ~= nil then
			table.insert(trace, {
				stageId = "gameplay_cap",
				handlerId = "named_cap",
				componentId = componentId,
				operation = "clamp",
				input = capTrace.originalValue,
				output = capped,
				reasonId = capTrace.capId,
			})
		end
		total[componentId] = capped
	end
	for _, intent in jokerRegistry.stateIntents(jokerContext, safeNumber, input, true) do
		table.insert(stateIntents, intent)
	end
	sortStateIntents(stateIntents)
	appendStateIntentTrace(trace, stateIntents, "after_formation_reward")
	table.insert(trace, {
		stageId = "after_formation_reward",
		handlerId = "calculation_contract",
		operation = "emit_state_intents",
		output = #stateIntents,
	})
	table.insert(trace, {
		stageId = "finalize_result",
		handlerId = "calculation_contract",
		operation = "accept_result",
		details = copyComponents(total),
	})
	return {
		accepted = true,
		reasonId = "calculation_accepted",
		formation = selectedFormation,
		components = total,
		stateIntents = stateIntents,
		trace = trace,
		versions = {
			catalogVersion = catalog.catalogVersion,
			configVersion = config.configVersion,
		},
	}
end

function ScoreCalculator.calculate(dependencies: any, input: any): any
	local ok, result = pcall(calculateInner, dependencies, input)
	if ok then
		return deepFreeze(result)
	end
	local failureId = tostring(result):match("(P001%-%u+%-%d+)") or "P001-CALC-999"
	return deepFreeze({
		accepted = false,
		reasonId = "calculation_rejected",
		formation = nil,
		components = nil,
		stateIntents = {},
		trace = {
			{
				stageId = "validation_failure",
				handlerId = "calculation_contract",
				operation = "reject",
				reasonId = failureId,
			},
		},
		versions = {
			catalogVersion = dependencies.catalog.catalogVersion,
			configVersion = dependencies.config.configVersion,
		},
	})
end

return table.freeze(ScoreCalculator)
