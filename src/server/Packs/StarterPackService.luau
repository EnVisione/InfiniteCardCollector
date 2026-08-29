--!strict

local StarterPackService = {}

function StarterPackService.new(dependencies: any): any
	assert(dependencies.catalog ~= nil, "P002-STARTER-001 catalog missing")
	assert(dependencies.inventory ~= nil, "P002-STARTER-002 inventory missing")
	assert(dependencies.canonical ~= nil, "P002-STARTER-003 canonical codec missing")
	assert(dependencies.errors ~= nil, "P002-STARTER-004 errors missing")
	local classicIdentities = {}
	local classicBySlot = {}
	for _, identity in dependencies.catalog.identities do
		if identity.deckSetId == "classic" then
			table.insert(classicIdentities, identity)
			classicBySlot[identity.slotKey] = identity
		end
	end
	assert(#classicIdentities == 52, "P002-STARTER-005 classic identity count invalid")
	local service = {}

	function service:apply(profile: any, ownerUserId: number, operationId: string, random: any): any
		if profile.tutorial.starterPackClaimed == true then
			return { ok = false, code = dependencies.errors.codes.starterAlreadyClaimed }
		end
		local selected = {}
		local suit = dependencies.catalog.suits[random:nextInteger(#dependencies.catalog.suits)]
		local startIndex = random:nextInteger(#dependencies.catalog.ranks - 4)
		for offset = 0, 4 do
			local rank = dependencies.catalog.ranks[startIndex + offset]
			local identity = classicBySlot[dependencies.catalog.slotKey(rank.id, suit.id)]
			assert(identity ~= nil, "P002-STARTER-007 guided identity missing")
			table.insert(selected, identity)
		end
		local cards = {}
		local cardInstanceIds = {}
		local slotKeys = {}
		for _, identity in selected do
			assert(not slotKeys[identity.slotKey], "P002-STARTER-006 duplicate starter slot")
			slotKeys[identity.slotKey] = true
			local created = dependencies.inventory:createCard(
				profile,
				ownerUserId,
				identity.id,
				{},
				{ originType = "starter_pack", originId = operationId }
			)
			if not created.ok then
				return created
			end
			table.insert(cardInstanceIds, created.card.uid)
			table.insert(cards, dependencies.inventory:projectCard(created.card))
		end
		local resultReference = dependencies.canonical.encode({
			catalogVersion = dependencies.catalog.catalogVersion,
			cardInstanceIds = cardInstanceIds,
		})
		profile.pendingPacks[operationId] = {
			state = "committed",
			packId = "classic_starter",
			catalogVersion = dependencies.catalog.catalogVersion,
			cardInstanceIds = cardInstanceIds,
			resultReference = resultReference,
		}
		profile.tutorial.starterPackClaimed = true
		return {
			ok = true,
			code = "pack.starter_committed",
			packId = "classic_starter",
			catalogVersion = dependencies.catalog.catalogVersion,
			cards = cards,
			resultReference = resultReference,
		}
	end

	function service:acknowledgeRevealForCard(profile: any, cardInstanceId: string): any
		local matchedOperationId = nil
		for operationId, pending in profile.pendingPacks do
			for _, pendingCardInstanceId in pending.cardInstanceIds do
				if pendingCardInstanceId == cardInstanceId then
					if matchedOperationId ~= nil and matchedOperationId ~= operationId then
						return { ok = false, code = dependencies.errors.codes.operationInvalid }
					end
					matchedOperationId = operationId
				end
			end
		end
		if matchedOperationId == nil then
			return { ok = true, code = "pack.reveal_not_pending", acknowledged = false }
		end
		local pending = profile.pendingPacks[matchedOperationId]
		if pending.state == "committed" then
			pending.state = "acknowledged"
		end
		return {
			ok = true,
			code = "pack.reveal_acknowledged",
			acknowledged = true,
			packOperationId = matchedOperationId,
		}
	end

	return service
end

return table.freeze(StarterPackService)
