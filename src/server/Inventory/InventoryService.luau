--!strict

local InventoryService = {}

local function indexById(records: { any }): { [string]: any }
	local result = {}
	for _, record in records do
		result[record.id] = record
	end
	return result
end

function InventoryService.new(dependencies: any): any
	assert(dependencies.catalog ~= nil, "P002-INVENTORY-001 catalog missing")
	assert(dependencies.errors ~= nil, "P002-INVENTORY-002 errors missing")
	assert(type(dependencies.uidFactory) == "function", "P002-INVENTORY-003 uid factory missing")
	assert(type(dependencies.clock) == "function", "P002-INVENTORY-004 clock missing")
	assert(dependencies.inventoryStore ~= nil, "P002-INVENTORY-008 inventory store missing")
	assert(dependencies.collection ~= nil, "P002-INVENTORY-009 collection service missing")
	local identities = indexById(dependencies.catalog.identities)
	local deckSets = indexById(dependencies.catalog.deckSets)
	local editions = indexById(dependencies.catalog.editions)
	local grades = indexById(dependencies.catalog.grades)
	local powerTiers = indexById(dependencies.catalog.powerTiers)
	local traits = indexById(dependencies.catalog.traits)
	local jokers = indexById(dependencies.catalog.jokers)
	local service = {}

	local function uidInPending(profile: any, uid: string): boolean
		for _, pending in profile.pendingPacks do
			for _, pendingUid in pending.cardInstanceIds or {} do
				if pendingUid == uid then
					return true
				end
			end
		end
		return false
	end

	local function nextUid(profile: any, ownerUserId: number, kind: string): string?
		for attempt = 1, 16 do
			local candidate = dependencies.uidFactory(ownerUserId, kind, attempt)
			if
				type(candidate) == "string"
				and candidate ~= ""
				and not dependencies.inventoryStore:containsUid(profile, candidate)
				and not uidInPending(profile, candidate)
			then
				return candidate
			end
		end
		return nil
	end

	function service:createCard(
		profile: any,
		ownerUserId: number,
		identityId: string,
		options: any,
		provenance: any
	): any
		local identity = identities[identityId]
		if identity == nil then
			return { ok = false, code = dependencies.errors.codes.instanceNotFound }
		end
		local deckSet = deckSets[identity.deckSetId]
		if deckSet == nil or deckSet.launchEnabled == false then
			return { ok = false, code = dependencies.errors.codes.contentDisabled }
		end
		local editionId = options.editionId or "normal"
		local gradeId = options.gradeId or "f"
		local powerTierId = options.powerTierId or "common"
		local traitId = options.traitId
		if
			editions[editionId] == nil
			or grades[gradeId] == nil
			or powerTiers[powerTierId] == nil
			or (traitId ~= nil and traits[traitId] == nil)
		then
			return { ok = false, code = dependencies.errors.codes.contentDisabled }
		end
		local uid = nextUid(profile, ownerUserId, "card")
		if uid == nil then
			return { ok = false, code = dependencies.errors.codes.uidUnavailable }
		end
		local createdAt = dependencies.clock()
		local card = {
			uid = uid,
			ownerUserId = ownerUserId,
			identityId = identity.id,
			deckSetId = identity.deckSetId,
			rankId = identity.rankId,
			suitId = identity.suitId,
			slotKey = identity.slotKey,
			editionId = editionId,
			gradeId = gradeId,
			powerTierId = powerTierId,
			traitId = traitId,
			gradeExperience = 0,
			flags = {
				favorite = false,
				wishlist = false,
			},
			locks = {},
			provenance = {
				originType = provenance.originType,
				originId = provenance.originId,
				createdAt = createdAt,
				instanceVersion = 1,
			},
		}
		assert(
			dependencies.inventoryStore:putCard(profile, card),
			"P002-INVENTORY-010 card uid collision"
		)
		local formId = dependencies.catalog.formKey(identity.id, editionId)
		dependencies.collection:discover(profile, "forms", formId)
		return { ok = true, code = "inventory.card_created", card = card }
	end

	function service:createJoker(
		profile: any,
		ownerUserId: number,
		jokerId: string,
		provenance: any
	): any
		local definition = jokers[jokerId]
		if definition == nil then
			return { ok = false, code = dependencies.errors.codes.instanceNotFound }
		elseif definition.launchEnabled == false then
			return { ok = false, code = dependencies.errors.codes.contentDisabled }
		end
		local uid = nextUid(profile, ownerUserId, "joker")
		if uid == nil then
			return { ok = false, code = dependencies.errors.codes.uidUnavailable }
		end
		local joker = {
			uid = uid,
			ownerUserId = ownerUserId,
			jokerId = jokerId,
			xp = 0,
			level = 1,
			bound = false,
			flags = {
				favorite = false,
				wishlist = false,
			},
			locks = {},
			provenance = {
				originType = provenance.originType,
				originId = provenance.originId,
				createdAt = dependencies.clock(),
				instanceVersion = 1,
			},
		}
		assert(
			dependencies.inventoryStore:putJoker(profile, joker),
			"P002-INVENTORY-011 joker uid collision"
		)
		dependencies.collection:discover(profile, "jokers", jokerId)
		return { ok = true, code = "inventory.joker_created", joker = joker }
	end

	function service:setFlags(profile: any, ownerUserId: number, uid: string, flags: any): any
		local card = dependencies.inventoryStore:getCard(profile, uid)
		if card == nil then
			return { ok = false, code = dependencies.errors.codes.instanceNotFound }
		elseif card.ownerUserId ~= ownerUserId then
			return { ok = false, code = dependencies.errors.codes.foreignInstance }
		end
		if
			(flags.favorite ~= nil and type(flags.favorite) ~= "boolean")
			or (flags.wishlist ~= nil and type(flags.wishlist) ~= "boolean")
			or (flags.locked ~= nil and type(flags.locked) ~= "boolean")
		then
			return { ok = false, code = dependencies.errors.codes.boundsInvalid }
		end
		if flags.favorite ~= nil then
			card.flags.favorite = flags.favorite
		end
		if flags.wishlist ~= nil then
			card.flags.wishlist = flags.wishlist
		end
		if flags.locked ~= nil then
			if flags.locked then
				card.locks.manual = true
			else
				card.locks.manual = nil
			end
		end
		local locked = false
		for _, active in card.locks do
			if active then
				locked = true
				break
			end
		end
		return {
			ok = true,
			code = "inventory.flags_updated",
			instanceId = uid,
			favorite = card.flags.favorite,
			wishlist = card.flags.wishlist,
			locked = locked,
		}
	end

	function service:isEligible(profile: any, ownerUserId: number, uid: string): any
		local card = dependencies.inventoryStore:getCard(profile, uid)
		if card == nil then
			return { ok = false, code = dependencies.errors.codes.instanceNotFound }
		elseif card.ownerUserId ~= ownerUserId then
			return { ok = false, code = dependencies.errors.codes.foreignInstance }
		end
		for _, locked in card.locks do
			if locked then
				return { ok = false, code = dependencies.errors.codes.instanceLocked }
			end
		end
		local deckSet = deckSets[card.deckSetId]
		if deckSet == nil or deckSet.launchEnabled == false then
			return { ok = false, code = dependencies.errors.codes.contentDisabled }
		end
		return { ok = true, code = "ok", card = card }
	end

	function service:getCard(profile: any, uid: string): any?
		return dependencies.inventoryStore:getCard(profile, uid)
	end

	function service:getJoker(profile: any, uid: string): any?
		return dependencies.inventoryStore:getJoker(profile, uid)
	end

	function service:listCards(profile: any): { any }
		return dependencies.inventoryStore:listCards(profile)
	end

	function service:listJokers(profile: any): { any }
		return dependencies.inventoryStore:listJokers(profile)
	end

	function service:removeJoker(profile: any, uid: string): any?
		return dependencies.inventoryStore:removeJoker(profile, uid)
	end

	function service:isProtectedForRemoval(profile: any, ownerUserId: number, uid: string): any
		local eligibility = self:isEligible(profile, ownerUserId, uid)
		if not eligibility.ok then
			return eligibility
		end
		local card = eligibility.card
		for _, pending in profile.pendingPacks do
			for _, pendingUid in pending.cardInstanceIds or {} do
				if pendingUid == uid then
					return { ok = false, code = dependencies.errors.codes.removalProtected }
				end
			end
		end
		if card.flags.favorite or card.flags.wishlist then
			return { ok = false, code = dependencies.errors.codes.removalProtected }
		end
		for _, activeUid in profile.activeDeck do
			if activeUid == uid then
				return { ok = false, code = dependencies.errors.codes.removalProtected }
			end
		end
		local sameIdentity = 0
		for _, owned in dependencies.inventoryStore:listCards(profile) do
			if owned.ownerUserId == ownerUserId and owned.identityId == card.identityId then
				sameIdentity += 1
			end
		end
		if sameIdentity <= 1 then
			return { ok = false, code = dependencies.errors.codes.removalProtected }
		end
		return { ok = true, code = "ok", card = card }
	end

	function service:removeCard(profile: any, ownerUserId: number, uid: string): any
		local protection = self:isProtectedForRemoval(profile, ownerUserId, uid)
		if not protection.ok then
			return protection
		end
		local removed = dependencies.inventoryStore:removeCard(profile, uid)
		if removed == nil then
			return { ok = false, code = dependencies.errors.codes.instanceNotFound }
		end
		return { ok = true, code = "inventory.card_removed", card = removed }
	end

	function service:projectCard(card: any): any
		local locked = false
		for _, active in card.locks do
			if active then
				locked = true
				break
			end
		end
		return {
			instanceId = card.uid,
			deckSetId = card.deckSetId,
			rankId = card.rankId,
			suitId = card.suitId,
			slotKey = card.slotKey,
			editionId = card.editionId,
			gradeId = card.gradeId,
			gradeExperience = card.gradeExperience,
			powerTierId = card.powerTierId,
			traitId = card.traitId,
			favorite = card.flags.favorite,
			wishlist = card.flags.wishlist,
			locked = locked,
			tradeLocked = card.locks.trade == true,
		}
	end

	function service:projectJoker(joker: any): any
		local definition = jokers[joker.jokerId]
		local locked = false
		for _, active in joker.locks do
			if active then
				locked = true
				break
			end
		end
		return {
			instanceId = joker.uid,
			jokerId = joker.jokerId,
			displayName = if definition ~= nil then definition.displayName else joker.jokerId,
			rarityId = if definition ~= nil then definition.rarityId else nil,
			xp = joker.xp,
			level = joker.level,
			bound = joker.bound,
			favorite = joker.flags.favorite,
			locked = locked,
			tradeLocked = joker.locks.trade == true,
		}
	end

	function service:assertConservation(profile: any, ownerUserId: number): number
		local count = 0
		for _, card in dependencies.inventoryStore:listCards(profile) do
			local uid = card.uid
			assert(type(uid) == "string" and uid == card.uid, "P002-INVENTORY-005 uid map mismatch")
			assert(card.ownerUserId == ownerUserId, "P002-INVENTORY-006 owner mismatch")
			assert(identities[card.identityId] ~= nil, "P002-INVENTORY-007 identity missing")
			count += 1
		end
		return count
	end

	function service:assertJokerConservation(profile: any, ownerUserId: number): number
		local count = 0
		for _, joker in dependencies.inventoryStore:listJokers(profile) do
			assert(joker.ownerUserId == ownerUserId, "P002-INVENTORY-012 joker owner mismatch")
			assert(jokers[joker.jokerId] ~= nil, "P002-INVENTORY-013 joker definition missing")
			count += 1
		end
		return count
	end

	return service
end

return table.freeze(InventoryService)
