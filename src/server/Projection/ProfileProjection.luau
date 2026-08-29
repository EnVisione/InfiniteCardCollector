--!strict

local ProfileProjection = {}

local function copyMap(value: any): any
	return table.clone(value)
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
	local pendingPacks = {}
	for operationId, pending in profile.pendingPacks do
		pendingPacks[operationId] = {
			state = pending.state,
			packId = pending.packId,
			catalogVersion = pending.catalogVersion,
			cardInstanceIds = table.clone(pending.cardInstanceIds),
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
