--!strict

local DeckService = {}

function DeckService.new(dependencies: any): any
	assert(dependencies.catalog ~= nil, "P002-DECK-001 catalog missing")
	assert(dependencies.inventory ~= nil, "P002-DECK-002 inventory missing")
	assert(dependencies.errors ~= nil, "P002-DECK-003 errors missing")
	local validSlots = {}
	local slotKeys = {}
	for _, rank in dependencies.catalog.ranks do
		for _, suit in dependencies.catalog.suits do
			local slotKey = dependencies.catalog.slotKey(rank.id, suit.id)
			validSlots[slotKey] = true
			table.insert(slotKeys, slotKey)
		end
	end
	table.sort(slotKeys)
	assert(#slotKeys == 52, "P002-DECK-004 slot count invalid")
	local service = {
		slotKeys = table.freeze(slotKeys),
	}

	function service:equip(profile: any, ownerUserId: number, uid: string, slotKey: string): any
		if not validSlots[slotKey] then
			return { ok = false, code = dependencies.errors.codes.slotInvalid }
		end
		local eligibility = dependencies.inventory:isEligible(profile, ownerUserId, uid)
		if not eligibility.ok then
			return eligibility
		end
		local card = eligibility.card
		if card.slotKey ~= slotKey then
			return { ok = false, code = dependencies.errors.codes.slotMismatch }
		end
		local occupied = profile.activeDeck[slotKey]
		if occupied ~= nil then
			return {
				ok = false,
				code = if occupied == uid
					then dependencies.errors.codes.duplicateInstance
					else dependencies.errors.codes.slotOccupied,
			}
		end
		for activeSlot, activeUid in profile.activeDeck do
			if activeUid == uid then
				return {
					ok = false,
					code = dependencies.errors.codes.duplicateInstance,
					slotKey = activeSlot,
				}
			end
		end
		profile.activeDeck[slotKey] = uid
		return { ok = true, code = "deck.card_equipped", instanceId = uid, slotKey = slotKey }
	end

	function service:unequip(profile: any, ownerUserId: number, slotKey: string): any
		if not validSlots[slotKey] then
			return { ok = false, code = dependencies.errors.codes.slotInvalid }
		end
		local uid = profile.activeDeck[slotKey]
		if uid == nil then
			return { ok = false, code = dependencies.errors.codes.instanceNotFound }
		end
		local eligibility = dependencies.inventory:isEligible(profile, ownerUserId, uid)
		if not eligibility.ok and eligibility.code ~= dependencies.errors.codes.instanceLocked then
			return eligibility
		end
		profile.activeDeck[slotKey] = nil
		return { ok = true, code = "deck.card_unequipped", instanceId = uid, slotKey = slotKey }
	end

	function service:autoFill(profile: any, ownerUserId: number, maximum: number): any
		local equipped = {}
		for _, card in dependencies.inventory:listCards(profile) do
			if #equipped >= maximum then
				break
			end
			if profile.activeDeck[card.slotKey] == nil then
				local outcome = self:equip(profile, ownerUserId, card.uid, card.slotKey)
				if outcome.ok then
					table.insert(equipped, card.uid)
				end
			end
		end
		return { ok = true, code = "deck.auto_filled", instanceIds = equipped }
	end

	return service
end

return table.freeze(DeckService)
