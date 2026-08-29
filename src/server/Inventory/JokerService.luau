--!strict

local JokerService = {}

local MAX_SLOTS = 5
local MAX_XP = 1000000
local XP_PER_DUPLICATE = 10

local function indexById(records: { any }): { [string]: any }
	local result = {}
	for _, record in records do
		result[record.id] = record
	end
	return result
end

local function copy(value: any): any
	if type(value) ~= "table" then
		return value
	end
	local result = {}
	for key, child in value do
		result[key] = copy(child)
	end
	return result
end

local function isLocked(joker: any): boolean
	for _, active in joker.locks do
		if active then
			return true
		end
	end
	return false
end

local function levelForXp(xp: number): number
	return math.min(100, math.floor(xp / 100) + 1)
end

local function rationalText(numerator: number, denominator: number): string
	if numerator % denominator == 0 then
		return string.format("%dx", numerator / denominator)
	end
	return string.format("%.2fx", numerator / denominator)
end

local function explanation(definition: any, balance: any): string
	local params = balance.params
	local handlerId = definition.handlerId
	if handlerId == "joker_component_add" then
		return string.format("+%d%% %s output", params.percent, params.componentId)
	elseif handlerId == "joker_state_modifier" then
		return string.format("+%d%% %s", params.percent, params.modifierId)
	elseif handlerId == "joker_card_color_add" then
		return string.format("matching %s cards gain +%d%% output", params.color, params.percent)
	elseif handlerId == "joker_number_card_add" then
		return string.format("number cards gain +%d%% output", params.percent)
	elseif handlerId == "joker_filled_slots_add" then
		return string.format(
			"a full %d slot deck gains +%d%% output",
			params.requiredSlots,
			params.percent
		)
	elseif handlerId == "joker_balanced_colors_add" then
		return string.format("equal red and black cards gain +%d%% output", params.percent)
	elseif handlerId == "joker_rank_group_add" then
		return string.format("%s cards together gain +%d%% output", params.groupId, params.percent)
	elseif handlerId == "joker_deck_set_threshold_add" then
		return string.format(
			"%d cards from one deck set gain +%d%% output",
			params.threshold,
			params.percent
		)
	elseif handlerId == "joker_golden_cash_enhance" then
		return string.format("golden cash is %d%% stronger", params.percent)
	elseif handlerId == "joker_streak_loss_intent" then
		return string.format("the first miss reduces the streak by %d", params.reduction)
	elseif handlerId == "joker_formation_multiplier" then
		return string.format(
			"matching %s formations gain %s output",
			params.formationId,
			rationalText(params.numerator, params.denominator)
		)
	elseif handlerId == "joker_affinity_threshold" then
		return string.format(
			"deck set affinity thresholds require %d fewer cards",
			params.reduction
		)
	elseif handlerId == "joker_card_count_multiplier" then
		return string.format(
			"exactly %d cards gain %s output",
			params.cardCount,
			rationalText(params.numerator, params.denominator)
		)
	elseif handlerId == "joker_affinity_strength" then
		return string.format("maximum deck set affinity gains +%d%% strength", params.percent)
	elseif handlerId == "joker_output_tradeoff" then
		return string.format(
			"draw and resolve speed gains %d%% while guard loses %d%%",
			params.speedPercent,
			params.guardPenaltyPercent
		)
	elseif handlerId == "joker_other_effect_enhance" then
		return string.format("other equipped Joker effects gain +%d%%", params.percent)
	elseif handlerId == "joker_success_counter_intent" then
		return string.format(
			"every %d successful formations starts %d reward packs",
			params.threshold,
			params.packCount
		)
	elseif handlerId == "joker_filled_slots_multiplier" then
		return string.format(
			"a full %d slot deck gains %s output",
			params.requiredSlots,
			rationalText(params.numerator, params.denominator)
		)
	elseif handlerId == "joker_collection_add" then
		return string.format(
			"every %d discovered forms adds %s output, capped at %d%%",
			params.formsPerStep,
			string.format("%.1f%%", params.percentPerStep / params.percentScale),
			params.maxPercent
		)
	end
	return "registered Joker effect"
end

function JokerService.new(dependencies: any): any
	assert(dependencies.catalog ~= nil, "P003-JOKER-001 catalog missing")
	assert(dependencies.config ~= nil, "P003-JOKER-002 config missing")
	assert(dependencies.inventory ~= nil, "P003-JOKER-003 inventory missing")
	assert(dependencies.errors ~= nil, "P003-JOKER-004 errors missing")
	local definitions = indexById(dependencies.catalog.jokers)
	local service = {}

	local function featureEnabled(): boolean
		return dependencies.config.features.jokersEnabled == true
	end

	local function validateSlot(slotIndex: number): boolean
		return type(slotIndex) == "number"
			and slotIndex % 1 == 0
			and slotIndex >= 1
			and slotIndex <= MAX_SLOTS
	end

	local function validateOwned(profile: any, ownerUserId: number, uid: string): any
		local joker = dependencies.inventory:getJoker(profile, uid)
		if joker == nil then
			return { ok = false, code = dependencies.errors.codes.instanceNotFound }
		elseif joker.ownerUserId ~= ownerUserId then
			return { ok = false, code = dependencies.errors.codes.foreignInstance }
		end
		local definition = definitions[joker.jokerId]
		if definition == nil or definition.launchEnabled ~= true then
			return { ok = false, code = dependencies.errors.codes.contentDisabled }
		end
		return { ok = true, joker = joker, definition = definition }
	end

	local function project(joker: any, definition: any?): any
		local resolved = definition or definitions[joker.jokerId]
		return {
			instanceId = joker.uid,
			jokerId = joker.jokerId,
			displayName = if resolved ~= nil then resolved.displayName else joker.jokerId,
			rarityId = if resolved ~= nil then resolved.rarityId else nil,
			xp = joker.xp,
			level = joker.level,
			bound = joker.bound,
			favorite = joker.flags.favorite,
			locked = isLocked(joker),
			tradeLocked = joker.locks.trade == true,
		}
	end

	function service:projectJoker(joker: any): any
		return project(joker)
	end

	function service:activeIds(profile: any): { string }
		local result = {}
		for _, uid in profile.activeJokers do
			local joker = dependencies.inventory:getJoker(profile, uid)
			assert(joker ~= nil, "P003-JOKER-005 active joker missing")
			local definition = definitions[joker.jokerId]
			assert(
				definition ~= nil and definition.launchEnabled == true,
				"P003-JOKER-006 active joker unavailable"
			)
			table.insert(result, joker.jokerId)
		end
		return result
	end

	function service:projectLoadout(profile: any): any
		local slots = {}
		for slotIndex = 1, MAX_SLOTS do
			local uid = profile.activeJokers[slotIndex]
			slots[slotIndex] = if uid ~= nil
				then project(dependencies.inventory:getJoker(profile, uid))
				else nil
		end
		return {
			slots = slots,
			activeIds = self:activeIds(profile),
			count = #profile.activeJokers,
		}
	end

	function service:inspect(profile: any, ownerUserId: number, uid: string): any
		local owned = validateOwned(profile, ownerUserId, uid)
		if not owned.ok then
			return owned
		end
		local balance = dependencies.config.balance.jokers[owned.definition.balanceId]
		assert(balance ~= nil, "P003-JOKER-007 balance missing")
		return {
			ok = true,
			code = "joker.inspect_ready",
			joker = project(owned.joker, owned.definition),
			definition = {
				id = owned.definition.id,
				displayName = owned.definition.displayName,
				rarityId = owned.definition.rarityId,
				handlerId = owned.definition.handlerId,
				stages = copy(owned.definition.stages),
				conflicts = copy(owned.definition.conflicts),
				params = copy(balance.params),
				caps = copy(balance.caps),
				explanation = explanation(owned.definition, balance),
				explanationReasonId = owned.definition.id,
			},
		}
	end

	function service:equip(profile: any, ownerUserId: number, uid: string, slotIndex: number): any
		if not featureEnabled() then
			return { ok = false, code = dependencies.errors.codes.featureUnavailable }
		elseif not validateSlot(slotIndex) then
			return { ok = false, code = dependencies.errors.codes.slotInvalid }
		elseif slotIndex > #profile.activeJokers + 1 then
			return { ok = false, code = dependencies.errors.codes.slotInvalid }
		end
		local owned = validateOwned(profile, ownerUserId, uid)
		if not owned.ok then
			return owned
		elseif isLocked(owned.joker) then
			return { ok = false, code = dependencies.errors.codes.instanceLocked }
		end
		for activeSlot, activeUid in profile.activeJokers do
			if activeUid == uid then
				return {
					ok = false,
					code = dependencies.errors.codes.duplicateInstance,
					slotIndex = activeSlot,
				}
			end
			local activeJoker = dependencies.inventory:getJoker(profile, activeUid)
			if activeJoker ~= nil and activeJoker.jokerId == owned.joker.jokerId then
				return {
					ok = false,
					code = dependencies.errors.codes.duplicateInstance,
					slotIndex = activeSlot,
				}
			end
		end
		local previousUid = profile.activeJokers[slotIndex]
		if previousUid ~= nil then
			local previous = dependencies.inventory:getJoker(profile, previousUid)
			if previous ~= nil and isLocked(previous) then
				return { ok = false, code = dependencies.errors.codes.instanceLocked }
			end
		end
		profile.activeJokers[slotIndex] = uid
		owned.joker.bound = true
		return {
			ok = true,
			code = "joker.equipped",
			instanceId = uid,
			jokerId = owned.joker.jokerId,
			slotIndex = slotIndex,
			previousInstanceId = previousUid,
			bound = true,
			loadout = self:projectLoadout(profile),
		}
	end

	function service:unequip(profile: any, ownerUserId: number, slotIndex: number): any
		if not featureEnabled() then
			return { ok = false, code = dependencies.errors.codes.featureUnavailable }
		elseif not validateSlot(slotIndex) then
			return { ok = false, code = dependencies.errors.codes.slotInvalid }
		end
		local uid = profile.activeJokers[slotIndex]
		if uid == nil then
			return { ok = false, code = dependencies.errors.codes.instanceNotFound }
		end
		local owned = validateOwned(profile, ownerUserId, uid)
		if not owned.ok then
			return owned
		elseif isLocked(owned.joker) then
			return { ok = false, code = dependencies.errors.codes.instanceLocked }
		end
		table.remove(profile.activeJokers, slotIndex)
		return {
			ok = true,
			code = "joker.unequipped",
			instanceId = uid,
			slotIndex = slotIndex,
			loadout = self:projectLoadout(profile),
		}
	end

	function service:awardExperience(
		profile: any,
		ownerUserId: number,
		uid: string,
		amount: number
	): any
		if type(amount) ~= "number" or amount % 1 ~= 0 or amount <= 0 then
			return { ok = false, code = dependencies.errors.codes.boundsInvalid }
		end
		local owned = validateOwned(profile, ownerUserId, uid)
		if not owned.ok then
			return owned
		end
		local beforeXp = owned.joker.xp
		owned.joker.xp = math.min(MAX_XP, beforeXp + amount)
		owned.joker.level = levelForXp(owned.joker.xp)
		return {
			ok = true,
			code = "joker.experience_committed",
			instanceId = uid,
			xpBefore = beforeXp,
			xpAfter = owned.joker.xp,
			level = owned.joker.level,
		}
	end

	function service:awardActiveExperience(
		profile: any,
		ownerUserId: number,
		amount: number
	): { any }
		local progress = {}
		for _, uid in profile.activeJokers do
			local result = self:awardExperience(profile, ownerUserId, uid, amount)
			if result.ok then
				table.insert(progress, result)
			end
		end
		return progress
	end

	function service:bindDuplicate(
		profile: any,
		ownerUserId: number,
		sourceUid: string,
		targetUid: string
	): any
		if not featureEnabled() then
			return { ok = false, code = dependencies.errors.codes.featureUnavailable }
		elseif sourceUid == targetUid then
			return { ok = false, code = dependencies.errors.codes.duplicateInstance }
		end
		local source = validateOwned(profile, ownerUserId, sourceUid)
		local target = validateOwned(profile, ownerUserId, targetUid)
		if not source.ok then
			return source
		elseif not target.ok then
			return target
		elseif source.joker.jokerId ~= target.joker.jokerId then
			return { ok = false, code = dependencies.errors.codes.boundsInvalid }
		elseif source.joker.bound or isLocked(source.joker) or source.joker.flags.favorite then
			return { ok = false, code = dependencies.errors.codes.removalProtected }
		elseif isLocked(target.joker) then
			return { ok = false, code = dependencies.errors.codes.instanceLocked }
		end
		for _, activeUid in profile.activeJokers do
			if activeUid == sourceUid then
				return { ok = false, code = dependencies.errors.codes.removalProtected }
			end
		end
		local removed = dependencies.inventory:removeJoker(profile, sourceUid)
		if removed == nil then
			return { ok = false, code = dependencies.errors.codes.instanceNotFound }
		end
		target.joker.bound = true
		local progress = self:awardExperience(profile, ownerUserId, targetUid, XP_PER_DUPLICATE)
		if not progress.ok then
			return progress
		end
		progress.code = "joker.duplicate_bound"
		progress.sourceInstanceId = sourceUid
		progress.targetInstanceId = targetUid
		progress.xpAwarded = XP_PER_DUPLICATE
		return progress
	end

	return service
end

return table.freeze(JokerService)
