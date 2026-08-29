--!strict

local ProgressionService = {}

local DEFAULT_COSTS = {
	gradeInkPerExperience = 1,
	traitChoice = 1,
	traitReplacement = 1,
	traitRemovalRefund = 1,
}

local function indexById(records: { any }): { [string]: any }
	local result = {}
	for _, record in records do
		result[record.id] = record
	end
	return result
end

local function integer(value: any): boolean
	return type(value) == "number"
		and value == value
		and value ~= math.huge
		and value ~= -math.huge
		and value % 1 == 0
end

local function copyState(card: any): any
	return {
		editionId = card.editionId,
		gradeExperience = card.gradeExperience,
		gradeId = card.gradeId,
		powerTierId = card.powerTierId,
		traitId = card.traitId,
	}
end

function ProgressionService.new(dependencies: any): any
	assert(dependencies.catalog ~= nil, "P003-PROGRESSION-001 catalog missing")
	assert(dependencies.config ~= nil, "P003-PROGRESSION-002 config missing")
	assert(dependencies.inventory ~= nil, "P003-PROGRESSION-003 inventory missing")
	assert(dependencies.errors ~= nil, "P003-PROGRESSION-004 errors missing")

	local grades = indexById(dependencies.catalog.grades)
	local traits = indexById(dependencies.catalog.traits)
	local gradeOrder = table.clone(dependencies.catalog.grades)
	local costs = table.clone(DEFAULT_COSTS)
	for key, value in dependencies.costs or {} do
		if integer(value) and value > 0 then
			costs[key] = value
		end
	end
	local gradeCap = dependencies.config.gameplayCaps.grade_experience

	local function gradeBalance(grade: any): any?
		if grade == nil then
			return nil
		end
		return dependencies.config.balance.grades[grade.balanceId or grade.id]
	end

	local function thresholdGradeIndex(experience: number): number
		local result = 1
		for index, grade in gradeOrder do
			local balance = gradeBalance(grade)
			if balance ~= nil and experience >= balance.cumulativeXp then
				result = index
			else
				break
			end
		end
		return result
	end

	local function currentGradeIndex(card: any): number
		local index = 1
		for candidateIndex, grade in gradeOrder do
			if grade.id == card.gradeId then
				index = candidateIndex
				break
			end
		end
		return index
	end

	local function normalizedState(card: any): any
		local previous = copyState(card)
		local experience = math.min(math.max(card.gradeExperience or 0, 0), gradeCap)
		local nextIndex = math.max(currentGradeIndex(card), thresholdGradeIndex(experience))
		return {
			changed = previous.gradeId ~= gradeOrder[nextIndex].id
				or previous.gradeExperience ~= experience,
			previous = previous,
			current = {
				editionId = card.editionId,
				gradeExperience = experience,
				gradeId = gradeOrder[nextIndex].id,
				powerTierId = card.powerTierId,
				traitId = card.traitId,
			},
		}
	end

	local function normalizeCard(card: any, state: any)
		card.gradeExperience = state.current.gradeExperience
		card.gradeId = state.current.gradeId
	end

	local function eligible(profile: any, ownerUserId: number, instanceId: string): any
		local result = dependencies.inventory:isEligible(profile, ownerUserId, instanceId)
		if not result.ok then
			return result
		end
		local card = result.card
		if card.flags.favorite == true then
			return { ok = false, code = dependencies.errors.codes.instanceLocked }
		end
		return { ok = true, code = "ok", card = card }
	end

	local function trace(
		stageId: string,
		operation: string,
		input: number?,
		output: number?,
		details: any
	): any
		return {
			stageId = stageId,
			handlerId = "progression_service",
			operation = operation,
			input = input,
			output = output,
			reasonId = if stageId == "grade" then "grade_progress" else "trait_choice",
			details = details,
		}
	end

	local service = {}

	function service:project(card: any): any
		local normalized = copyState(card)
		local grade = grades[normalized.gradeId]
		local balance = gradeBalance(grade)
		return {
			editionId = normalized.editionId,
			gradeExperience = normalized.gradeExperience,
			gradeId = normalized.gradeId,
			gradeThreshold = if balance ~= nil then balance.cumulativeXp else nil,
			powerTierId = normalized.powerTierId,
			traitId = normalized.traitId,
			traitLocked = card.locks.trait == true,
		}
	end

	function service:eligibleTraitIds(profile: any, ownerUserId: number, instanceId: string): any
		local access = eligible(profile, ownerUserId, instanceId)
		if not access.ok then
			return access
		end
		local result = {}
		for _, trait in dependencies.catalog.traits do
			if trait.launchEnabled ~= false and trait.id ~= access.card.traitId then
				table.insert(result, trait.id)
			end
		end
		return {
			ok = true,
			code = "progression.trait_choices_ready",
			instanceId = instanceId,
			currentTraitId = access.card.traitId,
			traitIds = result,
			cost = if access.card.traitId == nil then costs.traitChoice else costs.traitReplacement,
			configVersion = dependencies.config.configVersion,
		}
	end

	function service:applyGradeInk(
		profile: any,
		ownerUserId: number,
		instanceId: string,
		amount: number
	): any
		if not integer(amount) or amount < 1 then
			return { ok = false, code = dependencies.errors.codes.boundsInvalid }
		end
		local access = eligible(profile, ownerUserId, instanceId)
		if not access.ok then
			return access
		end
		local card = access.card
		local reconciliation = normalizedState(card)
		local beforeInk = profile.currencies.grade_ink
		if type(beforeInk) ~= "number" or beforeInk < 0 then
			return { ok = false, code = dependencies.errors.codes.insufficientCurrency }
		end
		local availableExperience = math.max(0, gradeCap - reconciliation.current.gradeExperience)
		local spendable = math.min(amount, availableExperience / costs.gradeInkPerExperience)
		if spendable < 1 then
			if reconciliation.changed then
				normalizeCard(card, reconciliation)
				return {
					ok = true,
					code = "progression.grade_reconciled",
					instanceId = instanceId,
					before = reconciliation.previous,
					after = reconciliation.current,
					powerTierId = card.powerTierId,
					traitId = card.traitId,
					trace = {
						trace(
							"grade",
							"reconcile",
							reconciliation.previous.gradeExperience,
							card.gradeExperience,
							{}
						),
					},
					versions = {
						catalogVersion = dependencies.catalog.catalogVersion,
						configVersion = dependencies.config.configVersion,
					},
				}
			end
			return { ok = false, code = dependencies.errors.codes.gradeAtCap }
		end
		spendable = math.floor(spendable)
		local requiredInk = spendable * costs.gradeInkPerExperience
		if beforeInk < requiredInk then
			return { ok = false, code = dependencies.errors.codes.insufficientCurrency }
		end
		local before = reconciliation.previous
		local beforeExperience = reconciliation.previous.gradeExperience
		normalizeCard(card, reconciliation)
		profile.currencies.grade_ink -= requiredInk
		card.gradeExperience += spendable * costs.gradeInkPerExperience
		local afterNormalization = normalizedState(card)
		normalizeCard(card, afterNormalization)
		return {
			ok = true,
			code = "progression.grade_applied",
			instanceId = instanceId,
			gradeId = card.gradeId,
			gradeBefore = before.gradeId,
			gradeAfter = card.gradeId,
			gradeExperienceBefore = beforeExperience,
			gradeExperienceAfter = card.gradeExperience,
			powerTierId = card.powerTierId,
			traitId = card.traitId,
			inkSpent = requiredInk,
			balanceBefore = beforeInk,
			balanceAfter = profile.currencies.grade_ink,
			promoted = before.gradeId ~= card.gradeId,
			trace = {
				trace("grade", "apply_ink", beforeExperience, card.gradeExperience, {
					amount = requiredInk,
					gradeBefore = before.gradeId,
					gradeAfter = card.gradeId,
				}),
			},
			versions = {
				catalogVersion = dependencies.catalog.catalogVersion,
				configVersion = dependencies.config.configVersion,
			},
			reconciled = reconciliation.changed or afterNormalization.changed,
		}
	end

	function service:chooseTrait(
		profile: any,
		ownerUserId: number,
		instanceId: string,
		traitId: string,
		options: any?
	): any
		if type(traitId) ~= "string" then
			return { ok = false, code = dependencies.errors.codes.contentDisabled }
		end
		local access = eligible(profile, ownerUserId, instanceId)
		if not access.ok then
			return access
		end
		local card = access.card
		local trait = traits[traitId]
		if trait == nil or trait.launchEnabled == false then
			return { ok = false, code = dependencies.errors.codes.contentDisabled }
		end
		local currentTraitId = card.traitId
		local replacement = currentTraitId ~= nil
		local replaceConfirmed = false
		local expectedTraitId = nil
		if type(options) == "boolean" then
			replaceConfirmed = options
		elseif type(options) == "table" then
			replaceConfirmed = options.replace == true or options.confirmed == true
			expectedTraitId = options.expectedTraitId
		end
		if replacement and not replaceConfirmed then
			return { ok = false, code = dependencies.errors.codes.traitReplacementRequired }
		end
		if expectedTraitId ~= nil and expectedTraitId ~= currentTraitId then
			return { ok = false, code = dependencies.errors.codes.staleState }
		end
		if currentTraitId == traitId then
			return { ok = false, code = dependencies.errors.codes.traitUnchanged }
		end
		local cost = if replacement then costs.traitReplacement else costs.traitChoice
		local balance = profile.currencies.trait_essence
		if type(balance) ~= "number" or balance < cost then
			return { ok = false, code = dependencies.errors.codes.insufficientCurrency }
		end
		local before = copyState(card)
		profile.currencies.trait_essence -= cost
		card.traitId = traitId
		return {
			ok = true,
			code = if replacement then "progression.trait_replaced" else "progression.trait_chosen",
			instanceId = instanceId,
			traitBefore = before.traitId,
			traitAfter = traitId,
			traitId = traitId,
			cost = cost,
			balanceBefore = balance,
			balanceAfter = profile.currencies.trait_essence,
			gradeId = card.gradeId,
			gradeExperience = card.gradeExperience,
			powerTierId = card.powerTierId,
			trace = {
				trace(
					"trait",
					if replacement then "replace" else "choose",
					nil,
					nil,
					{ traitBefore = before.traitId, traitAfter = traitId }
				),
			},
			versions = {
				catalogVersion = dependencies.catalog.catalogVersion,
				configVersion = dependencies.config.configVersion,
			},
		}
	end

	function service:removeTrait(profile: any, ownerUserId: number, instanceId: string): any
		local access = eligible(profile, ownerUserId, instanceId)
		if not access.ok then
			return access
		end
		local card = access.card
		if card.traitId == nil then
			return { ok = false, code = dependencies.errors.codes.traitUnset }
		end
		local cap = nil
		for _, currency in dependencies.config.economy.currencies do
			if currency.id == "trait_essence" then
				cap = currency.cap
				break
			end
		end
		local before = card.traitId
		card.traitId = nil
		local balance = profile.currencies.trait_essence
		local refund = math.min(costs.traitRemovalRefund, math.max(0, cap or balance))
		profile.currencies.trait_essence = math.min(balance + refund, cap or balance + refund)
		return {
			ok = true,
			code = "progression.trait_removed",
			instanceId = instanceId,
			traitBefore = before,
			traitAfter = nil,
			refund = refund,
			balanceAfter = profile.currencies.trait_essence,
			trace = {
				trace("trait", "remove", nil, nil, { traitBefore = before, refund = refund }),
			},
			versions = {
				catalogVersion = dependencies.catalog.catalogVersion,
				configVersion = dependencies.config.configVersion,
			},
		}
	end

	service.traitChoices = service.eligibleTraitIds
	service.setTrait = service.chooseTrait

	return service
end

return table.freeze(ProgressionService)
