--!strict

local JokerRegistry = {}

local componentIds = { "cash", "power", "guard", "packProgress", "gradeExperience" }

local function copyComponents(components: any): any
	return {
		cash = components.cash,
		power = components.power,
		guard = components.guard,
		packProgress = components.packProgress,
		gradeExperience = components.gradeExperience,
	}
end

local function indexById(records: { any }): { [string]: any }
	local result = {}
	for _, record in records do
		result[record.id] = record
	end
	return result
end

local function assertDenseArray(value: any, maximum: number, failureId: string): number
	assert(type(value) == "table", failureId)
	local length = #value
	assert(length <= maximum, failureId)
	local count = 0
	for key in value do
		assert(type(key) == "number" and key % 1 == 0 and key >= 1 and key <= length, failureId)
		count += 1
	end
	assert(count == length, failureId)
	return length
end

local function prepare(catalog: any, config: any, input: any): any
	assertDenseArray(input.activeJokerIds, 5, "P001-JOKER-002 invalid active joker slots")
	assert(
		type(config) == "table"
			and type(config.balance) == "table"
			and type(config.balance.jokers) == "table",
		"P001-JOKER-006 config missing"
	)
	local byId = indexById(catalog.jokers)
	local active = {}
	local slotOrder = {}
	local seen = {}
	for slot, id in input.activeJokerIds do
		assert(type(id) == "string", "P001-JOKER-003 invalid active id")
		assert(not seen[id], "P001-JOKER-004 duplicate active joker")
		seen[id] = true
		local definition = byId[id]
		assert(
			definition ~= nil and definition.launchEnabled == true,
			"P001-JOKER-005 unavailable joker"
		)
		local balance = config.balance.jokers[definition.balanceId]
		assert(balance ~= nil, "P001-JOKER-007 balance missing")
		local entry = { slot = slot, definition = definition, balance = balance }
		table.insert(active, entry)
		table.insert(slotOrder, entry)
	end
	for _, entry in active do
		for _, conflictId in entry.definition.conflicts do
			assert(not seen[conflictId], "P001-JOKER-008 conflicting active jokers")
		end
		if entry.definition.handlerId == "joker_success_counter_intent" then
			local count = input.successfulFormationCount
			assert(
				type(count) == "number"
					and count == count
					and count % 1 == 0
					and count >= 0
					and count < entry.balance.params.threshold,
				"P001-JOKER-009 stale counter"
			)
		end
	end
	table.sort(active, function(left, right)
		if left.definition.handlerId == right.definition.handlerId then
			return left.definition.id < right.definition.id
		end
		return left.definition.handlerId < right.definition.handlerId
	end)
	return {
		active = active,
		slotOrder = slotOrder,
		unionPercent = if seen.joker_union
			then config.balance.jokers.joker_union.params.percent
			else 0,
		seen = seen,
	}
end

local function enhancedBasis(safeNumber: any, basis: number, context: any, jokerId: string): number
	if context.unionPercent == 0 or jokerId == "joker_union" then
		return basis
	end
	return safeNumber.scale(basis, { numerator = 100 + context.unionPercent, denominator = 100 })
end

local function applyAdditiveBasis(
	safeNumber: any,
	components: any,
	basisByComponent: any,
	stageId: string,
	trace: { any }
): any
	local result = copyComponents(components)
	for _, componentId in componentIds do
		local basis = basisByComponent[componentId] or 0
		if basis > 0 then
			local before = result[componentId]
			result[componentId] = safeNumber.scale(before, {
				numerator = 10000 + basis,
				denominator = 10000,
			})
			table.insert(trace, {
				stageId = stageId,
				handlerId = "joker_additive_group",
				componentId = componentId,
				operation = "multiply_rational",
				input = before,
				numerator = 10000 + basis,
				denominator = 10000,
				output = result[componentId],
			})
		end
	end
	return result
end

function JokerRegistry.context(catalog: any, config: any, input: any): any
	return prepare(catalog, config, input)
end

function JokerRegistry.affinityModifiers(
	context: any,
	safeNumber: any,
	activeDeckSetCounts: { [string]: number },
	trace: { any }
): any
	local thresholdReduction = 0
	local strengthBasis = 0
	local strengthDeckSetId = nil
	local dominantCount = -1
	for deckSetId, count in activeDeckSetCounts do
		if count > dominantCount or (count == dominantCount and deckSetId < strengthDeckSetId) then
			dominantCount = count
			strengthDeckSetId = deckSetId
		end
	end
	for _, active in context.active do
		local joker = active.definition
		local params = active.balance.params
		if joker.handlerId == "joker_affinity_threshold" then
			local reductionBasis =
				enhancedBasis(safeNumber, params.reduction * 100, context, joker.id)
			thresholdReduction = math.max(thresholdReduction, reductionBasis)
			table.insert(trace, {
				stageId = "before_card_contribution",
				handlerId = joker.handlerId,
				operation = "reduce_affinity_threshold",
				output = reductionBasis,
				reasonId = joker.id,
			})
		elseif joker.handlerId == "joker_affinity_strength" then
			local addedBasis = enhancedBasis(safeNumber, params.percent * 100, context, joker.id)
			strengthBasis = safeNumber.add(strengthBasis, addedBasis)
			table.insert(trace, {
				stageId = "before_card_contribution",
				handlerId = joker.handlerId,
				operation = "increase_affinity_strength",
				output = addedBasis,
				reasonId = joker.id,
				details = { deckSetId = strengthDeckSetId },
			})
		end
	end
	return {
		thresholdReductionBasis = thresholdReduction,
		strengthBasis = strengthBasis,
		strengthDeckSetId = strengthDeckSetId,
	}
end

function JokerRegistry.editionMultiplier(
	context: any,
	safeNumber: any,
	card: any,
	componentId: string,
	multiplier: any,
	trace: { any }
): any
	if card.editionId ~= "golden" or componentId ~= "cash" then
		return multiplier
	end
	for _, active in context.active do
		local joker = active.definition
		if joker.handlerId == "joker_golden_cash_enhance" then
			local originalBonusNumerator = multiplier.numerator - multiplier.denominator
			assert(originalBonusNumerator >= 0, "P001-JOKER-010 invalid edition bonus")
			local originalBonusBasis = safeNumber.scale(originalBonusNumerator, {
				numerator = 10000,
				denominator = multiplier.denominator,
			})
			local enhancementBasis =
				enhancedBasis(safeNumber, active.balance.params.percent * 100, context, joker.id)
			local enhancedBonusBasis = safeNumber.scale(originalBonusBasis, {
				numerator = 10000 + enhancementBasis,
				denominator = 10000,
			})
			table.insert(trace, {
				stageId = "edition",
				handlerId = joker.handlerId,
				componentId = "cash",
				operation = "enhance_edition_effect",
				input = originalBonusBasis,
				numerator = 10000 + enhancementBasis,
				denominator = 10000,
				output = enhancedBonusBasis,
				reasonId = joker.id,
			})
			return { numerator = 10000 + enhancedBonusBasis, denominator = 10000 }
		end
	end
	return multiplier
end

function JokerRegistry.applyCard(
	context: any,
	safeNumber: any,
	card: any,
	components: any,
	trace: { any }
): any
	local basisByComponent = {
		cash = 0,
		power = 0,
		guard = 0,
		packProgress = 0,
		gradeExperience = 0,
	}
	for _, active in context.active do
		local joker = active.definition
		local params = active.balance.params
		local basis = 0
		if
			(joker.handlerId == "joker_card_color_add" and card.suitColor == params.color)
			or (
				joker.handlerId == "joker_number_card_add"
				and card.rankValue >= 2
				and card.rankValue <= 10
			)
		then
			basis = params.percent * 100
		end
		if basis > 0 then
			basis = enhancedBasis(safeNumber, basis, context, joker.id)
			for _, componentId in componentIds do
				basisByComponent[componentId] = safeNumber.add(basisByComponent[componentId], basis)
			end
			table.insert(trace, {
				stageId = "card_joker_additive",
				handlerId = joker.handlerId,
				operation = "additive_group_member",
				reasonId = joker.id,
				output = basis,
			})
		end
	end
	return applyAdditiveBasis(
		safeNumber,
		components,
		basisByComponent,
		"card_joker_additive",
		trace
	)
end

local function hasAllCourtRanks(cards: { any }): boolean
	local seen = {}
	for _, card in cards do
		seen[card.rankId] = true
	end
	return seen.jack == true and seen.queen == true and seen.king == true
end

local function isBalancedColors(cards: { any }): boolean
	local red = 0
	local black = 0
	for _, card in cards do
		if card.suitColor == "red" then
			red += 1
		elseif card.suitColor == "black" then
			black += 1
		end
	end
	return red > 0 and red == black
end

local function hasDeckSetThreshold(counts: any, threshold: number): boolean
	for _, count in counts do
		if count >= threshold then
			return true
		end
	end
	return false
end

function JokerRegistry.applyDeck(
	context: any,
	safeNumber: any,
	input: any,
	formationMatches: { [string]: boolean },
	cards: { any },
	components: any,
	trace: { any }
): any
	local basisByComponent = {
		cash = 0,
		power = 0,
		guard = 0,
		packProgress = 0,
		gradeExperience = 0,
	}
	local multiplicative = {}
	local guardPenaltyBasis = 0
	for _, active in context.active do
		local joker = active.definition
		local params = active.balance.params
		local additiveBasis = 0
		local componentId = nil
		if joker.handlerId == "joker_component_add" then
			additiveBasis = params.percent * 100
			componentId = params.componentId
		elseif
			(
				joker.handlerId == "joker_filled_slots_add"
				and input.activeDeckFilledSlots >= params.requiredSlots
			)
			or (joker.handlerId == "joker_balanced_colors_add" and isBalancedColors(cards))
			or (joker.handlerId == "joker_rank_group_add" and params.groupId == "court" and hasAllCourtRanks(
				cards
			))
			or (
				joker.handlerId == "joker_deck_set_threshold_add"
				and hasDeckSetThreshold(input.activeDeckSetCounts, params.threshold)
			)
		then
			additiveBasis = params.percent * 100
		elseif joker.handlerId == "joker_collection_add" then
			local steps = math.floor(input.discoveredFormCount / params.formsPerStep)
			local tenths =
				math.min(steps * params.percentPerStep, params.maxPercent * params.percentScale)
			additiveBasis = tenths * 10
		elseif
			(
				joker.handlerId == "joker_formation_multiplier"
				and formationMatches[params.formationId] == true
			)
			or (joker.handlerId == "joker_card_count_multiplier" and #cards == params.cardCount)
			or (
				joker.handlerId == "joker_filled_slots_multiplier"
				and input.activeDeckFilledSlots >= params.requiredSlots
			)
		then
			local bonusBasis = safeNumber.scale(params.numerator - params.denominator, {
				numerator = 10000,
				denominator = params.denominator,
			})
			table.insert(multiplicative, {
				jokerId = joker.id,
				bonusBasis = bonusBasis,
			})
		elseif joker.handlerId == "joker_output_tradeoff" then
			guardPenaltyBasis = math.max(
				guardPenaltyBasis,
				enhancedBasis(safeNumber, params.guardPenaltyPercent * 100, context, joker.id)
			)
		end

		if additiveBasis > 0 then
			additiveBasis = enhancedBasis(safeNumber, additiveBasis, context, joker.id)
			if componentId ~= nil then
				local mappedId = if componentId == "pack_progress"
					then "packProgress"
					elseif componentId == "grade_experience" then "gradeExperience"
					else componentId
				basisByComponent[mappedId] =
					safeNumber.add(basisByComponent[mappedId], additiveBasis)
			else
				for _, id in componentIds do
					basisByComponent[id] = safeNumber.add(basisByComponent[id], additiveBasis)
				end
			end
			table.insert(trace, {
				stageId = "deck_joker_additive",
				handlerId = joker.handlerId,
				operation = "additive_group_member",
				reasonId = joker.id,
				output = additiveBasis,
			})
		end
	end

	local result =
		applyAdditiveBasis(safeNumber, components, basisByComponent, "deck_joker_additive", trace)
	for _, effect in multiplicative do
		local bonusBasis = enhancedBasis(safeNumber, effect.bonusBasis, context, effect.jokerId)
		for _, componentId in componentIds do
			local before = result[componentId]
			result[componentId] = safeNumber.scale(before, {
				numerator = 10000 + bonusBasis,
				denominator = 10000,
			})
			table.insert(trace, {
				stageId = "deck_joker_multiplicative",
				handlerId = "joker_multiplier",
				componentId = componentId,
				operation = "multiply_rational",
				input = before,
				numerator = 10000 + bonusBasis,
				denominator = 10000,
				output = result[componentId],
				reasonId = effect.jokerId,
			})
		end
	end
	if guardPenaltyBasis > 0 then
		local before = result.guard
		result.guard = safeNumber.scale(result.guard, {
			numerator = 10000 - guardPenaltyBasis,
			denominator = 10000,
		})
		table.insert(trace, {
			stageId = "deck_joker_multiplicative",
			handlerId = "joker_output_tradeoff",
			componentId = "guard",
			operation = "reduce_percent",
			input = before,
			numerator = 10000 - guardPenaltyBasis,
			denominator = 10000,
			output = result.guard,
			reasonId = "overclock",
		})
	end
	return result
end

function JokerRegistry.stateIntents(
	context: any,
	safeNumber: any,
	input: any,
	formationSucceeded: boolean
): { any }
	local intents = {}
	for _, active in context.active do
		local joker = active.definition
		local params = active.balance.params
		if joker.handlerId == "joker_state_modifier" then
			table.insert(intents, {
				intentId = params.modifierId .. "_up",
				sourceId = joker.id,
				basisPoints = enhancedBasis(safeNumber, params.percent * 100, context, joker.id),
			})
		elseif joker.handlerId == "joker_output_tradeoff" then
			table.insert(intents, {
				intentId = "draw_resolve_speed_up",
				sourceId = joker.id,
				basisPoints = enhancedBasis(
					safeNumber,
					params.speedPercent * 100,
					context,
					joker.id
				),
			})
		elseif joker.handlerId == "joker_streak_loss_intent" and not formationSucceeded then
			table.insert(intents, {
				intentId = "reduce_streak_loss_once",
				sourceId = joker.id,
				reductionBasis = enhancedBasis(
					safeNumber,
					params.reduction * 100,
					context,
					joker.id
				),
				uses = params.usesPerRound,
			})
		elseif
			joker.handlerId == "joker_success_counter_intent"
			and formationSucceeded
			and input.successfulFormationCount + 1 == params.threshold
		then
			table.insert(intents, {
				intentId = "start_packstorm",
				sourceId = joker.id,
				packCount = safeNumber.scale(params.packCount, {
					numerator = 100 + context.unionPercent,
					denominator = 100,
				}),
				resetCounterTo = 0,
			})
		end
	end
	table.sort(intents, function(left, right)
		if left.intentId == right.intentId then
			return left.sourceId < right.sourceId
		end
		return left.intentId < right.intentId
	end)
	return intents
end

return table.freeze(JokerRegistry)
