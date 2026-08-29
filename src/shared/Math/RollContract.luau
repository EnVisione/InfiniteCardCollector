--!strict

local RollContract = {}

function RollContract.validateWeights(weights: any, expectedTotal: number)
	assert(type(weights) == "table" and #weights > 0, "P001-RNG-001 weights missing")
	assert(type(expectedTotal) == "number" and expectedTotal % 1 == 0, "P001-RNG-002 total invalid")
	local total = 0
	local seen = {}
	for _, entry in weights do
		assert(type(entry.id) == "string" and entry.id ~= "", "P001-RNG-003 id missing")
		assert(not seen[entry.id], "P001-RNG-004 duplicate bucket")
		seen[entry.id] = true
		assert(
			type(entry.weight) == "number" and entry.weight % 1 == 0 and entry.weight > 0,
			"P001-RNG-005 weight invalid"
		)
		total += entry.weight
	end
	assert(total == expectedTotal, "P001-RNG-006 weight total mismatch")
end

local function bucketForRoll(weights: { any }, rollUnit: number): (any, number, number, number)
	local cursor = 1
	for index, entry in weights do
		local bucketEnd = cursor + entry.weight - 1
		if rollUnit >= cursor and rollUnit <= bucketEnd then
			return entry, index, cursor, bucketEnd
		end
		cursor = bucketEnd + 1
	end
	error("P001-RNG-007 roll outside buckets")
end

local function bucketBounds(weights: { any }, targetIndex: number): (number, number)
	local cursor = 1
	for index, entry in weights do
		local bucketEnd = cursor + entry.weight - 1
		if index == targetIndex then
			return cursor, bucketEnd
		end
		cursor = bucketEnd + 1
	end
	error("P001-RNG-014 bucket index outside weights")
end

function RollContract.rollWithPity(
	weights: { any },
	expectedTotal: number,
	seedId: string,
	rollUnit: number,
	inputPity: number,
	pityRule: any,
	catalogVersion: number,
	configVersion: number
): any
	RollContract.validateWeights(weights, expectedTotal)
	assert(type(seedId) == "string" and seedId ~= "", "P001-RNG-008 seed id missing")
	assert(
		type(rollUnit) == "number"
			and rollUnit % 1 == 0
			and rollUnit >= 1
			and rollUnit <= expectedTotal,
		"P001-RNG-009 roll unit invalid"
	)
	assert(
		type(inputPity) == "number" and inputPity % 1 == 0 and inputPity >= 0,
		"P001-RNG-010 pity invalid"
	)
	assert(
		type(pityRule) == "table"
			and type(pityRule.threshold) == "number"
			and pityRule.threshold % 1 == 0
			and pityRule.threshold > 0,
		"P001-RNG-011 pity rule invalid"
	)
	assert(
		type(pityRule.minimumId) == "string" and pityRule.minimumId ~= "",
		"P001-RNG-016 pity minimum invalid"
	)
	assert(inputPity < pityRule.threshold, "P001-RNG-015 stale pity")
	assert(
		type(catalogVersion) == "number"
			and catalogVersion % 1 == 0
			and catalogVersion > 0
			and type(configVersion) == "number"
			and configVersion % 1 == 0
			and configVersion > 0,
		"P001-RNG-017 version invalid"
	)

	local selected, selectedIndex, bucketStart, bucketEnd = bucketForRoll(weights, rollUnit)
	local baseSelectedId = selected.id
	local baseBucketStart = bucketStart
	local baseBucketEnd = bucketEnd
	local minimumIndex = nil
	for index, entry in weights do
		if entry.id == pityRule.minimumId then
			minimumIndex = index
			break
		end
	end
	assert(minimumIndex ~= nil, "P001-RNG-012 pity minimum missing")

	local pityDue = inputPity + 1 >= pityRule.threshold
	local pityApplied = pityDue and selectedIndex < minimumIndex
	if pityApplied then
		selected = weights[minimumIndex]
		selectedIndex = minimumIndex
		bucketStart, bucketEnd = bucketBounds(weights, minimumIndex)
	end
	local qualified = selectedIndex >= minimumIndex
	local postCommitPity = if qualified then 0 else inputPity + 1

	return table.freeze({
		seedId = seedId,
		rollUnit = rollUnit,
		inputPity = inputPity,
		baseSelectedId = baseSelectedId,
		baseBucketStart = baseBucketStart,
		baseBucketEnd = baseBucketEnd,
		selectedId = selected.id,
		selectedBucketStart = bucketStart,
		selectedBucketEnd = bucketEnd,
		postCommitPity = postCommitPity,
		pityApplied = pityApplied,
		catalogVersion = catalogVersion,
		configVersion = configVersion,
	})
end

function RollContract.minimumMissingTargets(filledSlots: number): number
	assert(
		type(filledSlots) == "number"
			and filledSlots % 1 == 0
			and filledSlots >= 0
			and filledSlots <= 52,
		"P001-RNG-013 filled slot count invalid"
	)
	if filledSlots < 26 then
		return 3
	elseif filledSlots <= 44 then
		return 1
	end
	return 0
end

return table.freeze(RollContract)
