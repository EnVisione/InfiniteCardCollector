--!strict

local FormationDetector = {}

local function indexById(records: { any }): { [string]: any }
	local result = {}
	for _, record in records do
		result[record.id] = record
	end
	return result
end

local function assertDenseArray(
	value: any,
	minimum: number,
	maximum: number,
	failureId: string
): number
	assert(type(value) == "table", failureId)
	local length = #value
	assert(length >= minimum and length <= maximum, failureId)
	local count = 0
	for key in value do
		assert(type(key) == "number" and key % 1 == 0 and key >= 1 and key <= length, failureId)
		count += 1
	end
	assert(count == length, failureId)
	return length
end

local function sortedNumericKeys(counts: { [number]: number }): { number }
	local keys = {}
	for key in counts do
		table.insert(keys, key)
	end
	table.sort(keys)
	return keys
end

local function isConsecutive(values: { number }): boolean
	for index = 2, #values do
		if values[index] ~= values[index - 1] + 1 then
			return false
		end
	end
	return true
end

local function rationalGreater(left: any, right: any): boolean
	return left.numerator * right.denominator > right.numerator * left.denominator
end

local function normalizedCards(catalog: any, cards: any, rankOverrides: any?): ({ any }, any)
	assertDenseArray(cards, 1, 5, "P001-FORMATION-002 illegal submission size")
	assert(
		rankOverrides == nil or type(rankOverrides) == "table",
		"P001-FORMATION-015 overrides invalid"
	)

	local rankById = indexById(catalog.ranks)
	local suitById = indexById(catalog.suits)
	local seenInstances = {}
	local seenSlots = {}
	local seenOverrideInstances = {}
	local normalized = {}
	for index, card in cards do
		assert(type(card) == "table", "P001-FORMATION-003 malformed card")
		assert(
			card.isBlank == nil or type(card.isBlank) == "boolean",
			"P001-FORMATION-014 blank flag invalid"
		)
		assert(
			type(card.instanceId) == "string" and card.instanceId ~= "",
			"P001-FORMATION-004 instance id missing"
		)
		assert(not seenInstances[card.instanceId], "P001-FORMATION-005 duplicate instance")
		seenInstances[card.instanceId] = true
		if card.isBlank == true then
			assert(
				card.deckSetId == nil
					and card.rankId == nil
					and card.suitId == nil
					and card.editionId == nil
					and card.gradeId == nil
					and card.powerTierId == nil
					and card.traitId == nil,
				"P001-FORMATION-006 blank carries scoring fields"
			)
		else
			local rank = rankById[card.rankId]
			local suit = suitById[card.suitId]
			assert(rank ~= nil, "P001-FORMATION-007 invalid rank")
			assert(suit ~= nil, "P001-FORMATION-008 invalid suit")
			local slotKey = card.rankId .. ":" .. card.suitId
			assert(not seenSlots[slotKey], "P001-FORMATION-019 duplicate slot")
			seenSlots[slotKey] = true
			local formationRank = rank
			local formationRankId = card.rankId
			local overrideId = if rankOverrides ~= nil then rankOverrides[card.instanceId] else nil
			if overrideId ~= nil then
				assert(type(overrideId) == "string", "P001-FORMATION-016 override rank invalid")
				local overrideRank = rankById[overrideId]
				assert(
					card.traitId == "adaptive"
						and overrideRank ~= nil
						and math.abs(overrideRank.value - rank.value) == 1,
					"P001-FORMATION-017 illegal adaptive override"
				)
				formationRank = overrideRank
				formationRankId = overrideId
				seenOverrideInstances[card.instanceId] = true
			end
			table.insert(normalized, {
				instanceId = card.instanceId,
				deckSetId = card.deckSetId,
				rankId = card.rankId,
				rankValue = rank.value,
				formationRankId = formationRankId,
				formationRankValue = formationRank.value,
				rankOverrideApplied = overrideId ~= nil,
				suitId = card.suitId,
				suitColor = suit.color,
				editionId = card.editionId,
				gradeId = card.gradeId,
				powerTierId = card.powerTierId,
				traitId = card.traitId,
				submissionIndex = index,
			})
		end
	end
	for instanceId, overrideId in rankOverrides or {} do
		assert(
			type(instanceId) == "string"
				and instanceId ~= ""
				and type(overrideId) == "string"
				and seenOverrideInstances[instanceId] == true,
			"P001-FORMATION-018 unknown adaptive override"
		)
	end
	return normalized, {
		rankById = rankById,
		suitById = suitById,
	}
end

local function matches(id: string, cards: { any }, target: number?): boolean
	local size = #cards
	local rankCounts: { [number]: number } = {}
	local suitCounts: { [string]: number } = {}
	local rankIds: { [string]: boolean } = {}
	local rankSum = 0
	for _, card in cards do
		rankCounts[card.formationRankValue] = (rankCounts[card.formationRankValue] or 0) + 1
		suitCounts[card.suitId] = (suitCounts[card.suitId] or 0) + 1
		rankIds[card.formationRankId] = true
		rankSum += card.formationRankValue
	end

	if id == "single" then
		return size == 1
	elseif id == "twin" then
		return size == 2 and #sortedNumericKeys(rankCounts) == 1
	elseif id == "twin_pair" then
		if size ~= 4 then
			return false
		end
		local counts = {}
		for _, count in rankCounts do
			table.insert(counts, count)
		end
		table.sort(counts)
		return #counts == 2 and counts[1] == 2 and counts[2] == 2
	elseif id == "triple" then
		return size == 3 and #sortedNumericKeys(rankCounts) == 1
	elseif id == "sequence" then
		local values = sortedNumericKeys(rankCounts)
		return size >= 3 and size <= 5 and #values == size and isConsecutive(values)
	elseif id == "monosuit" then
		local count = 0
		for _ in suitCounts do
			count += 1
		end
		return size >= 3 and size <= 5 and count == 1
	elseif id == "court" then
		return size == 3 and rankIds.jack == true and rankIds.queen == true and rankIds.king == true
	elseif id == "spectrum" then
		local count = 0
		for _ in suitCounts do
			count += 1
		end
		return size >= 4 and size <= 5 and count == 4
	elseif id == "full_cluster" then
		if size ~= 5 then
			return false
		end
		local hasTwo = false
		local hasThree = false
		for _, count in rankCounts do
			hasTwo = hasTwo or count == 2
			hasThree = hasThree or count == 3
		end
		return hasTwo and hasThree
	elseif id == "quad" then
		return size == 4 and #sortedNumericKeys(rankCounts) == 1
	elseif id == "crown_run" then
		return size == 5
			and rankIds["10"] == true
			and rankIds.jack == true
			and rankIds.queen == true
			and rankIds.king == true
			and rankIds.ace == true
	elseif id == "perfect_sum" then
		return target ~= nil and target >= 1 and target % 1 == 0 and rankSum == target
	end
	return false
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

function FormationDetector.detect(
	catalog: any,
	config: any,
	cards: any,
	target: number?,
	rankOverrides: any?
): any
	assert(type(catalog) == "table", "P001-FORMATION-009 catalog missing")
	assert(
		type(config) == "table" and type(config.balance) == "table",
		"P001-FORMATION-010 config missing"
	)
	if target ~= nil then
		assert(
			type(target) == "number"
				and target == target
				and target ~= math.huge
				and target ~= -math.huge
				and target % 1 == 0
				and target >= 1
				and target <= 70,
			"P001-FORMATION-011 invalid target"
		)
	end
	local normalized = normalizedCards(catalog, cards, rankOverrides)
	local candidates = {}
	for _, definition in catalog.formations do
		if matches(definition.id, normalized, target) then
			local balance = config.balance.formations[definition.balanceId]
			assert(balance ~= nil, "P001-FORMATION-012 balance missing")
			local multiplier = balance.multipliers[#normalized]
			assert(multiplier ~= nil, "P001-FORMATION-013 multiplier missing for size")
			table.insert(candidates, {
				id = definition.id,
				multiplier = multiplier,
				priority = definition.priority,
				stackableBonusIds = definition.stackableBonusIds,
			})
		end
	end

	table.sort(candidates, function(left, right)
		if rationalGreater(left.multiplier, right.multiplier) then
			return true
		elseif rationalGreater(right.multiplier, left.multiplier) then
			return false
		elseif left.priority ~= right.priority then
			return left.priority > right.priority
		end
		return left.id < right.id
	end)

	local resolvedBonusIds = {}
	local seenBonusIds = {}
	for _, candidate in candidates do
		for _, bonusId in candidate.stackableBonusIds do
			if not seenBonusIds[bonusId] then
				seenBonusIds[bonusId] = true
				table.insert(resolvedBonusIds, bonusId)
			end
		end
	end
	table.sort(resolvedBonusIds)
	local selected = nil
	if candidates[1] ~= nil then
		selected = {
			id = candidates[1].id,
			multiplier = candidates[1].multiplier,
			priority = candidates[1].priority,
			stackableBonusIds = resolvedBonusIds,
		}
	end

	return deepFreeze({
		normalizedCards = normalized,
		candidates = candidates,
		selected = selected,
	})
end

return table.freeze(FormationDetector)
