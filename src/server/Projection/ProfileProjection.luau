--!strict

local ProfileProjection = {}

local function copyMap(value: any): any
	return table.clone(value)
end

local function collectionProjection(profile: any, inventory: any): any
	local ownedIdentityCounts = {}
	for _, card in inventory:listCards(profile) do
		ownedIdentityCounts[card.identityId] = (ownedIdentityCounts[card.identityId] or 0) + 1
	end
	return {
		ownedIdentityCounts = ownedIdentityCounts,
		discoveredForms = copyMap(profile.discovery.forms),
		discoveredJokers = copyMap(profile.discovery.jokers),
		discoveredArcana = copyMap(profile.discovery.arcana),
		discoveredSouls = copyMap(profile.discovery.souls),
		bestRecords = copyMap(profile.bestRecords),
	}
end

function ProfileProjection.snapshot(
	profile: any,
	inventory: any,
	writable: boolean,
	storageMode: string
): any
	local cards = {}
	for _, card in inventory:listCards(profile) do
		table.insert(cards, inventory:projectCard(card))
	end
	table.sort(cards, function(left, right)
		return left.instanceId < right.instanceId
	end)
	local jokers = {}
	for _, joker in inventory:listJokers(profile) do
		table.insert(jokers, inventory:projectJoker(joker))
	end
	table.sort(jokers, function(left, right)
		return left.instanceId < right.instanceId
	end)
	local jokerSlots = {}
	for slotIndex = 1, 5 do
		local uid = profile.activeJokers[slotIndex]
		local joker = if uid ~= nil then inventory:getJoker(profile, uid) else nil
		jokerSlots[slotIndex] = if joker ~= nil then inventory:projectJoker(joker) else nil
	end
	local pendingPacks = {}
	for operationId, pending in profile.pendingPacks do
		pendingPacks[operationId] = {
			state = pending.state,
			packId = pending.packId,
			catalogVersion = pending.catalogVersion,
			cardInstanceIds = table.clone(pending.cardInstanceIds),
			classifications = if pending.classifications ~= nil
				then table.clone(pending.classifications)
				else nil,
			offerIds = if pending.offerIds ~= nil then table.clone(pending.offerIds) else nil,
			choiceIndex = pending.choiceIndex,
			choiceId = pending.choiceId,
			grantedJokerInstanceId = pending.grantedJokerInstanceId,
			grantedArcanaId = pending.grantedArcanaId,
			resultReference = pending.resultReference,
		}
	end
	return {
		profileSchemaVersion = profile.schemaVersion,
		catalogVersion = profile.catalogVersion,
		configVersion = profile.configVersion,
		revision = profile.revision,
		writable = writable,
		storageMode = storageMode,
		currencies = copyMap(profile.currencies),
		cards = cards,
		jokers = jokers,
		activeJokers = table.clone(profile.activeJokers),
		jokerStage = {
			slots = jokerSlots,
			count = #profile.activeJokers,
		},
		collection = collectionProjection(profile, inventory),
		discovery = {
			forms = copyMap(profile.discovery.forms),
			jokers = copyMap(profile.discovery.jokers),
			arcana = copyMap(profile.discovery.arcana),
			souls = copyMap(profile.discovery.souls),
		},
		bestRecords = copyMap(profile.bestRecords),
		activeDeck = copyMap(profile.activeDeck),
		pendingPacks = pendingPacks,
		settings = copyMap(profile.settings),
	}
end

function ProfileProjection.binderPage(
	profile: any,
	inventory: any,
	cursor: string?,
	pageSize: number
): any
	local cards = {}
	for _, card in inventory:listCards(profile) do
		table.insert(cards, inventory:projectCard(card))
	end
	table.sort(cards, function(left, right)
		return left.instanceId < right.instanceId
	end)
	local startIndex = 1
	if cursor ~= nil then
		for index, card in cards do
			if card.instanceId == cursor then
				startIndex = index + 1
				break
			end
		end
	end
	local page = {}
	local lastIndex = math.min(#cards, startIndex + pageSize - 1)
	for index = startIndex, lastIndex do
		table.insert(page, cards[index])
	end
	local nextCursor = nil
	if lastIndex < #cards and page[#page] ~= nil then
		nextCursor = page[#page].instanceId
	end
	return {
		cards = page,
		nextCursor = nextCursor,
		total = #cards,
	}
end

return table.freeze(ProfileProjection)
