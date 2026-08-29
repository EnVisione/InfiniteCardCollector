--!strict

local PackService = {}

local packDefinitions = {
	classic = {
		currencyId = "cash",
		deckSetId = "classic",
	},
	radioactive = {
		currencyId = "cash",
		deckSetId = "radioactive",
	},
	astral = {
		currencyId = "cash",
		deckSetId = "astral",
	},
}

local offerPackDefinitions = {
	joker = {
		currencyId = "joker_tickets",
		pityKey = "pack.joker",
		pityRuleId = "jokerEpic",
	},
	arcana = {
		currencyId = "arcana_dust",
		pityKey = nil,
		pityRuleId = nil,
	},
}

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

local function selectedSlotSet(
	inventory: any,
	profile: any,
	deckSetId: string
): { [string]: boolean }
	local result = {}
	for _, card in inventory:listCards(profile) do
		if card.deckSetId == deckSetId then
			result[card.slotKey] = true
		end
	end
	return result
end

local function candidates(
	catalog: any,
	deckSetId: string,
	selectedIds: { [string]: boolean },
	ownedSlots: { [string]: boolean },
	preferNew: boolean
): { any }
	local result = {}
	for _, identity in catalog.identities do
		if
			identity.deckSetId == deckSetId
			and selectedIds[identity.id] ~= true
			and (not preferNew or ownedSlots[identity.slotKey] ~= true)
		then
			table.insert(result, identity)
		end
	end
	return result
end

local function enabledRecords(catalog: any, field: string): { any }
	local result = {}
	for _, record in catalog[field] do
		if record.launchEnabled ~= false then
			table.insert(result, record)
		end
	end
	return result
end

local function ownedJokerSet(profile: any): { [string]: boolean }
	local result = {}
	for _, joker in profile.jokers do
		result[joker.jokerId] = true
	end
	return result
end

local function discoveredArcanaSet(profile: any): { [string]: boolean }
	local result = {}
	for arcanaId, discovered in profile.discovery.arcana do
		if discovered then
			result[arcanaId] = true
		end
	end
	return result
end

local function setSize(values: { [string]: boolean }): number
	local count = 0
	for _ in values do
		count += 1
	end
	return count
end

local function offerCandidates(
	records: { any },
	selectedIds: { [string]: boolean },
	ownedIds: { [string]: boolean },
	preferUnowned: boolean,
	rarityId: string?
): { any }
	local result = {}
	for _, record in records do
		if
			selectedIds[record.id] ~= true
			and (rarityId == nil or record.rarityId == rarityId)
			and (not preferUnowned or ownedIds[record.id] ~= true)
		then
			table.insert(result, record)
		end
	end
	return result
end

local function projectOffer(kind: string, record: any): any
	if kind == "joker" then
		return {
			id = record.id,
			displayName = record.displayName,
			rarityId = record.rarityId,
		}
	end
	return {
		id = record.id,
		displayName = record.displayName,
		categoryId = record.categoryId,
		targetId = record.targetId,
	}
end

function PackService.new(dependencies: any): any
	assert(dependencies.catalog ~= nil, "P003-PACK-001 catalog missing")
	assert(dependencies.config ~= nil, "P003-PACK-002 config missing")
	assert(dependencies.inventory ~= nil, "P003-PACK-003 inventory missing")
	assert(dependencies.collection ~= nil, "P003-PACK-004 collection missing")
	assert(dependencies.canonical ~= nil, "P003-PACK-005 canonical codec missing")
	assert(dependencies.errors ~= nil, "P003-PACK-006 errors missing")
	assert(dependencies.rollContract ~= nil, "P003-PACK-007 roll contract missing")
	local definitions = {}
	for id, definition in packDefinitions do
		local configuredPrice = dependencies.config.economy.packPrices[id]
		assert(
			type(configuredPrice) == "number" and configuredPrice % 1 == 0 and configuredPrice > 0,
			"P003-PACK-008 pack price invalid"
		)
		local catalogDeckSet = nil
		for _, deckSet in dependencies.catalog.deckSets do
			if deckSet.id == definition.deckSetId then
				catalogDeckSet = deckSet
				break
			end
		end
		assert(
			catalogDeckSet ~= nil and catalogDeckSet.launchEnabled ~= false,
			"P003-PACK-009 deck set disabled"
		)
		definitions[id] = {
			currencyId = definition.currencyId,
			deckSetId = definition.deckSetId,
			price = configuredPrice,
		}
	end
	local offerDefinitions = {}
	for id, definition in offerPackDefinitions do
		local configuredPrice = dependencies.config.economy.packPrices[id]
		assert(
			type(configuredPrice) == "number" and configuredPrice % 1 == 0 and configuredPrice > 0,
			"P003-PACK-010 offer pack price invalid"
		)
		local currencyFound = false
		for _, currency in dependencies.config.economy.currencies do
			if currency.id == definition.currencyId and currency.launchEnabled ~= false then
				currencyFound = true
				break
			end
		end
		assert(currencyFound, "P003-PACK-011 offer currency unavailable")
		local records = enabledRecords(dependencies.catalog, id == "joker" and "jokers" or "arcana")
		assert(#records >= 3, "P003-PACK-012 offer pool too small")
		offerDefinitions[id] = {
			currencyId = definition.currencyId,
			pityKey = definition.pityKey,
			pityRuleId = definition.pityRuleId,
			price = configuredPrice,
			records = records,
		}
	end

	local service = {}

	function service:open(
		profile: any,
		ownerUserId: number,
		operationId: string,
		packId: string,
		random: any
	): any
		local definition = definitions[packId]
		if definition == nil then
			return { ok = false, code = dependencies.errors.codes.packInvalid }
		end
		if type(operationId) ~= "string" or operationId == "" then
			return { ok = false, code = dependencies.errors.codes.operationInvalid }
		end
		if profile.pendingPacks[operationId] ~= nil then
			return { ok = false, code = dependencies.errors.codes.replayConflict }
		end
		local balance = profile.currencies[definition.currencyId]
		if type(balance) ~= "number" or balance < definition.price then
			return { ok = false, code = dependencies.errors.codes.insufficientCurrency }
		end
		local pityKey = "pack." .. packId
		local inputPity = profile.pity[pityKey] or 0
		local pityRule = dependencies.config.odds.pity.rare
		local ownedSlots = selectedSlotSet(dependencies.inventory, profile, definition.deckSetId)
		local filledSlots = 0
		for _ in profile.activeDeck do
			filledSlots += 1
		end
		local protectedTargets = dependencies.rollContract.minimumMissingTargets(filledSlots)
		local selectedIds = {}
		local selected = {}
		local tierRolls = {}
		local pity = inputPity
		for index = 1, 5 do
			local preferNew = protectedTargets > 0
			local pool = candidates(
				dependencies.catalog,
				definition.deckSetId,
				selectedIds,
				ownedSlots,
				preferNew
			)
			if #pool == 0 then
				pool = candidates(
					dependencies.catalog,
					definition.deckSetId,
					selectedIds,
					ownedSlots,
					false
				)
			end
			assert(#pool > 0, "P003-PACK-009 identity pool empty")
			local identity = pool[random:nextInteger(#pool)]
			selectedIds[identity.id] = true
			table.insert(selected, identity)
			ownedSlots[identity.slotKey] = true
			if preferNew then
				protectedTargets -= 1
			end
			local roll = dependencies.rollContract.rollWithPity(
				dependencies.config.odds.powerTiers,
				dependencies.config.odds.weightTotal,
				operationId .. ":" .. tostring(index),
				random:nextInteger(dependencies.config.odds.weightTotal),
				pity,
				pityRule,
				dependencies.catalog.catalogVersion,
				dependencies.config.configVersion
			)
			pity = roll.postCommitPity
			table.insert(tierRolls, roll)
		end

		profile.currencies[definition.currencyId] -= definition.price
		local cards = {}
		local cardInstanceIds = {}
		for index, identity in selected do
			local created = dependencies.inventory:createCard(
				profile,
				ownerUserId,
				identity.id,
				{ powerTierId = tierRolls[index].selectedId },
				{ originType = "pack", originId = operationId }
			)
			if not created.ok then
				return created
			end
			table.insert(cardInstanceIds, created.card.uid)
			table.insert(cards, dependencies.inventory:projectCard(created.card))
		end
		profile.pity[pityKey] = pity
		local resultReference = dependencies.canonical.encode({
			cardInstanceIds = cardInstanceIds,
			catalogVersion = dependencies.catalog.catalogVersion,
			packId = packId,
			pityAfter = pity,
		})
		profile.pendingPacks[operationId] = {
			state = "committed",
			packId = packId,
			catalogVersion = dependencies.catalog.catalogVersion,
			cardInstanceIds = cardInstanceIds,
			resultReference = resultReference,
		}
		return {
			ok = true,
			code = "pack.deck_set_committed",
			packId = packId,
			catalogVersion = dependencies.catalog.catalogVersion,
			currencyId = definition.currencyId,
			price = definition.price,
			cards = cards,
			tierRolls = copy(tierRolls),
			pityBefore = inputPity,
			pityAfter = pity,
			resultReference = resultReference,
		}
	end

	function service:openOffers(
		profile: any,
		_ownerUserId: number,
		operationId: string,
		packId: string,
		random: any
	): any
		local definition = offerDefinitions[packId]
		if definition == nil then
			return { ok = false, code = dependencies.errors.codes.packInvalid }
		end
		if type(operationId) ~= "string" or operationId == "" then
			return { ok = false, code = dependencies.errors.codes.operationInvalid }
		end
		if profile.pendingPacks[operationId] ~= nil then
			return { ok = false, code = dependencies.errors.codes.replayConflict }
		end
		local balance = profile.currencies[definition.currencyId]
		if type(balance) ~= "number" or balance < definition.price then
			return { ok = false, code = dependencies.errors.codes.insufficientCurrency }
		end

		local selectedIds = {}
		local selected = {}
		local rolls = {}
		local pityBefore = 0
		local pityAfter = 0
		if packId == "joker" then
			local pityKey = definition.pityKey :: string
			pityBefore = profile.pity[pityKey] or 0
			pityAfter = pityBefore
			local owned = ownedJokerSet(profile)
			local pityRule = dependencies.config.odds.pity[definition.pityRuleId :: string]
			for index = 1, 3 do
				local roll = dependencies.rollContract.rollWithPity(
					dependencies.config.odds.jokerRarities,
					dependencies.config.odds.weightTotal,
					operationId .. ":joker:" .. tostring(index),
					random:nextInteger(dependencies.config.odds.weightTotal),
					pityAfter,
					pityRule,
					dependencies.catalog.catalogVersion,
					dependencies.config.configVersion
				)
				pityAfter = roll.postCommitPity
				table.insert(rolls, roll)
				local pool =
					offerCandidates(definition.records, selectedIds, owned, true, roll.selectedId)
				if #pool == 0 then
					pool = offerCandidates(
						definition.records,
						selectedIds,
						owned,
						false,
						roll.selectedId
					)
				end
				if #pool == 0 then
					pool = offerCandidates(definition.records, selectedIds, owned, true, nil)
				end
				if #pool == 0 then
					pool = offerCandidates(definition.records, selectedIds, owned, false, nil)
				end
				assert(#pool > 0, "P003-PACK-013 joker offer pool empty")
				local record = pool[random:nextInteger(#pool)]
				selectedIds[record.id] = true
				table.insert(selected, record)
			end
			profile.pity[pityKey] = pityAfter
		else
			local discovered = discoveredArcanaSet(profile)
			local protectedCount =
				dependencies.config.odds.earlyProtection.arcanaUniqueProtectionCount
			local preferUndiscovered = setSize(discovered) < protectedCount
			for _ = 1, 3 do
				local pool = offerCandidates(
					definition.records,
					selectedIds,
					discovered,
					preferUndiscovered,
					nil
				)
				if #pool == 0 then
					pool = offerCandidates(definition.records, selectedIds, discovered, false, nil)
				end
				assert(#pool > 0, "P003-PACK-014 arcana offer pool empty")
				local record = pool[random:nextInteger(#pool)]
				selectedIds[record.id] = true
				table.insert(selected, record)
			end
		end

		profile.currencies[definition.currencyId] -= definition.price
		local offerIds = {}
		local offers = {}
		for _, record in selected do
			table.insert(offerIds, record.id)
			table.insert(offers, projectOffer(packId, record))
		end
		local itemOdds = nil
		if packId == "arcana" then
			itemOdds = {}
			for _, record in definition.records do
				table.insert(itemOdds, { id = record.id, weight = 1 })
			end
		end
		local resultReference = dependencies.canonical.encode({
			catalogVersion = dependencies.catalog.catalogVersion,
			itemOdds = itemOdds,
			offerIds = offerIds,
			packId = packId,
			pityAfter = pityAfter,
			pityBefore = pityBefore,
			rarityOdds = if packId == "joker"
				then copy(dependencies.config.odds.jokerRarities)
				else nil,
			rolls = copy(rolls),
		})
		profile.pendingPacks[operationId] = {
			state = "committed",
			packId = packId,
			catalogVersion = dependencies.catalog.catalogVersion,
			cardInstanceIds = {},
			resultReference = resultReference,
			offerIds = offerIds,
		}
		return {
			ok = true,
			code = "pack.offers_committed",
			packId = packId,
			catalogVersion = dependencies.catalog.catalogVersion,
			currencyId = definition.currencyId,
			price = definition.price,
			offers = offers,
			offerIds = offerIds,
			rarityOdds = if packId == "joker"
				then copy(dependencies.config.odds.jokerRarities)
				else nil,
			itemOdds = itemOdds,
			rarityRolls = copy(rolls),
			pityBefore = pityBefore,
			pityAfter = pityAfter,
			resultReference = resultReference,
		}
	end

	function service:chooseOffer(
		profile: any,
		ownerUserId: number,
		operationId: string,
		packOperationId: string,
		choiceIndex: number
	): any
		if type(operationId) ~= "string" or operationId == "" then
			return { ok = false, code = dependencies.errors.codes.operationInvalid }
		end
		if
			type(packOperationId) ~= "string"
			or packOperationId == ""
			or operationId == packOperationId
		then
			return { ok = false, code = dependencies.errors.codes.packChoiceInvalid }
		end
		local pending = profile.pendingPacks[packOperationId]
		if pending == nil or offerDefinitions[pending.packId] == nil then
			return { ok = false, code = dependencies.errors.codes.packChoiceUnavailable }
		end
		if pending.state == "claimed" then
			return { ok = false, code = dependencies.errors.codes.replayConflict }
		end
		if pending.state ~= "committed" and pending.state ~= "revealed" then
			return { ok = false, code = dependencies.errors.codes.packChoiceUnavailable }
		end
		if
			type(choiceIndex) ~= "number"
			or choiceIndex % 1 ~= 0
			or choiceIndex < 1
			or choiceIndex > #pending.offerIds
		then
			return { ok = false, code = dependencies.errors.codes.packChoiceInvalid }
		end
		local chosenId = pending.offerIds[choiceIndex]
		local definition = offerDefinitions[pending.packId]
		local chosen = nil
		for _, record in definition.records do
			if record.id == chosenId then
				chosen = record
				break
			end
		end
		if chosen == nil then
			return { ok = false, code = dependencies.errors.codes.packChoiceInvalid }
		end

		local grant = nil
		if pending.packId == "joker" then
			local created = dependencies.inventory:createJoker(
				profile,
				ownerUserId,
				chosen.id,
				{ originType = "joker_pack", originId = packOperationId }
			)
			if not created.ok then
				return created
			end
			pending.grantedJokerInstanceId = created.joker.uid
			grant = {
				instanceId = created.joker.uid,
				jokerId = created.joker.jokerId,
			}
		else
			local nextCount = (profile.arcanaStacks[chosen.id] or 0) + 1
			profile.arcanaStacks[chosen.id] = nextCount
			dependencies.collection:discover(profile, "arcana", chosen.id)
			pending.grantedArcanaId = chosen.id
			grant = {
				arcanaId = chosen.id,
				stackCount = nextCount,
			}
		end
		pending.state = "claimed"
		pending.choiceIndex = choiceIndex
		pending.choiceId = chosen.id
		local resultReference = dependencies.canonical.encode({
			catalogVersion = pending.catalogVersion,
			choiceId = chosen.id,
			choiceIndex = choiceIndex,
			grantedArcanaId = pending.grantedArcanaId,
			grantedJokerInstanceId = pending.grantedJokerInstanceId,
			offerIds = copy(pending.offerIds),
			packId = pending.packId,
		})
		pending.resultReference = resultReference
		return {
			ok = true,
			code = "pack.choice_committed",
			packId = pending.packId,
			packOperationId = packOperationId,
			catalogVersion = pending.catalogVersion,
			choiceIndex = choiceIndex,
			choiceId = chosen.id,
			grant = grant,
			resultReference = resultReference,
		}
	end

	function service:definition(packId: string): any?
		return definitions[packId]
	end

	function service:offerDefinition(packId: string): any?
		return offerDefinitions[packId]
	end

	return service
end

return table.freeze(PackService)
