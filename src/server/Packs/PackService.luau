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

function PackService.new(dependencies: any): any
	assert(dependencies.catalog ~= nil, "P003-PACK-001 catalog missing")
	assert(dependencies.config ~= nil, "P003-PACK-002 config missing")
	assert(dependencies.inventory ~= nil, "P003-PACK-003 inventory missing")
	assert(dependencies.canonical ~= nil, "P003-PACK-004 canonical codec missing")
	assert(dependencies.errors ~= nil, "P003-PACK-005 errors missing")
	assert(dependencies.rollContract ~= nil, "P003-PACK-006 roll contract missing")
	local definitions = {}
	for id, definition in packDefinitions do
		local configuredPrice = dependencies.config.economy.packPrices[id]
		assert(
			type(configuredPrice) == "number" and configuredPrice % 1 == 0 and configuredPrice > 0,
			"P003-PACK-007 pack price invalid"
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
			"P003-PACK-008 deck set disabled"
		)
		definitions[id] = {
			currencyId = definition.currencyId,
			deckSetId = definition.deckSetId,
			price = configuredPrice,
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

	function service:definition(packId: string): any?
		return definitions[packId]
	end

	return service
end

return table.freeze(PackService)
