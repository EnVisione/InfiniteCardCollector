--!strict

local GuidedFormationService = {}

function GuidedFormationService.new(dependencies: any): any
	assert(dependencies.inventory ~= nil, "P002-GUIDED-001 inventory missing")
	assert(type(dependencies.calculate) == "function", "P002-GUIDED-002 calculator missing")
	assert(
		type(dependencies.projectCalculation) == "function",
		"P002-GUIDED-003 projection missing"
	)
	assert(dependencies.errors ~= nil, "P002-GUIDED-004 errors missing")
	assert(type(dependencies.cashCap) == "number", "P002-GUIDED-005 cash cap missing")
	local service = {}

	function service:apply(profile: any, ownerUserId: number, instanceIds: { string }): any
		if type(instanceIds) ~= "table" or #instanceIds ~= 4 then
			return { ok = false, code = dependencies.errors.codes.formationInvalid }
		end
		local active = {}
		local activeDeckSetCounts = {}
		local activeDeckFilledSlots = 0
		for _, uid in profile.activeDeck do
			active[uid] = true
			local card = dependencies.inventory:getCard(profile, uid)
			if card ~= nil then
				activeDeckSetCounts[card.deckSetId] = (activeDeckSetCounts[card.deckSetId] or 0) + 1
				activeDeckFilledSlots += 1
			end
		end
		local cards = {}
		local seen = {}
		for index, uid in instanceIds do
			if type(uid) ~= "string" or seen[uid] or not active[uid] then
				return { ok = false, code = dependencies.errors.codes.formationInvalid }
			end
			seen[uid] = true
			local eligibility = dependencies.inventory:isEligible(profile, ownerUserId, uid)
			if not eligibility.ok then
				return eligibility
			end
			cards[index] = dependencies.inventory:projectCard(eligibility.card)
		end
		local discoveredFormCount = 0
		for _, discovered in profile.discovery.forms do
			if discovered then
				discoveredFormCount += 1
			end
		end
		local calculationOk, calculation = pcall(dependencies.calculate, {
			catalogVersion = dependencies.catalogVersion,
			configVersion = dependencies.configVersion,
			cards = cards,
			activeJokerIds = {},
			activeDeckSetCounts = activeDeckSetCounts,
			activeDeckFilledSlots = activeDeckFilledSlots,
			discoveredFormCount = discoveredFormCount,
			formationTarget = nil,
			formationRankOverrides = nil,
			formationStreak = 0,
			successfulFormationCount = profile.bestRecords.guidedSuccesses or 0,
			criticalTraitInstanceIds = {},
			modeId = "formation_rush",
			personalActiveBoostMultipliers = {},
			serverEventBoostMultipliers = {},
		})
		if not calculationOk or not calculation.accepted then
			return { ok = false, code = dependencies.errors.codes.formationInvalid }
		elseif calculation.formation == nil or calculation.components == nil then
			return { ok = false, code = dependencies.errors.codes.formationNoMatch }
		end
		local rewardCash = calculation.components.cash
		profile.currencies.cash =
			math.min(dependencies.cashCap, profile.currencies.cash + rewardCash)
		profile.bestRecords.guidedSuccesses = (profile.bestRecords.guidedSuccesses or 0) + 1
		profile.bestRecords.bestGuidedCash =
			math.max(profile.bestRecords.bestGuidedCash or 0, rewardCash)
		return {
			ok = true,
			code = "formation.reward_committed",
			formationId = calculation.formation.id,
			reward = { cash = rewardCash },
			calculation = dependencies.projectCalculation(calculation),
		}
	end

	return service
end

return table.freeze(GuidedFormationService)
