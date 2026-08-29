--!strict

local PackRevealController = {}

PackRevealController.version = 1

local allowedPacks = {
	classic_starter = true,
	classic = true,
	radioactive = true,
	astral = true,
	joker = true,
	arcana = true,
}

local classifications = {
	new = true,
	upgrade = true,
	duplicate = true,
	wishlist = true,
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

local function bump(state: any): any
	state.surfaceRevision += 1
	return state
end

local function failure(state: any, code: string, phase: string?): any
	local nextState = copy(state)
	nextState.lastCode = code
	nextState.phase = phase or "error"
	return bump(nextState)
end

local function settingsFrom(value: any): any
	return {
		reducedMotion = type(value) == "table" and value.reducedMotion == true,
		reducedFlash = type(value) == "table" and value.reducedFlash == true,
		mutedAudio = type(value) == "table" and value.mutedAudio == true,
		lowGraphics = type(value) == "table" and value.lowGraphics == true,
	}
end

local function contentId(kind: string, value: any): string?
	if type(value) ~= "table" then
		return nil
	end
	if kind == "card" then
		return if type(value.instanceId) == "string" then value.instanceId else nil
	end
	return if type(value.id) == "string" then value.id else nil
end

local function validContents(kind: string, values: any): boolean
	local expectedCount = if kind == "card" then 5 else 3
	if type(values) ~= "table" or #values ~= expectedCount then
		return false
	end
	local seen = {}
	for _, value in values do
		local id = contentId(kind, value)
		if id == nil or seen[id] then
			return false
		end
		seen[id] = true
	end
	return true
end

local function validClassification(value: any): boolean
	return type(value) == "string" and classifications[value] == true
end

local function classificationsFor(
	kind: string,
	message: any,
	pending: any,
	contents: { any }
): { string }?
	if kind ~= "card" then
		return nil
	end
	local values = if type(message.classifications) == "table"
		then copy(message.classifications)
		elseif type(pending.classifications) == "table" then copy(pending.classifications)
		else {}
	if #values == 0 then
		if message.packId ~= "classic_starter" then
			return nil
		end
		for _, card in contents do
			if card.classification == nil then
				return nil
			end
			table.insert(values, card.classification)
		end
	end
	if #values ~= #contents then
		return nil
	end
	for _, value in values do
		if not validClassification(value) then
			return nil
		end
	end
	return copy(values)
end

local function matchesPending(kind: string, contents: { any }, pending: any): boolean
	local ids = if kind == "card" then pending.cardInstanceIds else pending.offerIds
	if type(ids) ~= "table" or #ids ~= #contents then
		return false
	end
	for index, id in ids do
		if type(id) ~= "string" or contentId(kind, contents[index]) ~= id then
			return false
		end
	end
	return true
end

local function total(state: any): number
	return #state.contents
end

local function revealAllInternal(state: any, skipped: boolean): any
	local nextState = copy(state)
	if nextState.phase ~= "revealing" and nextState.phase ~= "complete" then
		return failure(nextState, "client.pack.reveal_unavailable")
	end
	nextState.revealed = {}
	for index = 1, total(nextState) do
		nextState.revealed[index] = true
	end
	nextState.revealedCount = total(nextState)
	nextState.phase = "complete"
	nextState.revealAll = not skipped
	nextState.skipped = skipped
	nextState.effectCue = if nextState.settings.reducedMotion or nextState.settings.lowGraphics
		then "pack.static"
		else "pack.reveal_complete"
	nextState.audioCue = if nextState.settings.mutedAudio then nil else "pack.reveal_complete"
	nextState.lastCode = if skipped then "pack.reveal_skipped" else "pack.reveal_all"
	return bump(nextState)
end

function PackRevealController.new(settings: any?): any
	return {
		version = PackRevealController.version,
		phase = "idle",
		lastCode = "client.pack_idle",
		packId = nil,
		operationId = nil,
		packOperationId = nil,
		catalogVersion = nil,
		currencyId = nil,
		price = nil,
		contents = {},
		kind = nil,
		classifications = nil,
		rarityOdds = nil,
		itemOdds = nil,
		pityBefore = nil,
		pityAfter = nil,
		revealed = {},
		revealedCount = 0,
		revealAll = false,
		skipped = false,
		choiceIndex = nil,
		choiceId = nil,
		grant = nil,
		pendingState = nil,
		pendingRecovery = false,
		audioCue = nil,
		effectCue = nil,
		settings = settingsFrom(settings),
		surfaceRevision = 0,
	}
end

function PackRevealController.openRequest(state: any, snapshot: any, packId: string): any
	if type(snapshot) ~= "table" or snapshot.writable ~= true then
		return { ok = false, code = "profile.read_only" }
	end
	if not allowedPacks[packId] then
		return { ok = false, code = "pack.invalid" }
	end
	if type(snapshot.revision) ~= "number" or snapshot.revision % 1 ~= 0 then
		return { ok = false, code = "state.stale" }
	end
	if state.phase == "revealing" or (state.phase == "complete" and state.kind == "offer") then
		return { ok = false, code = "pack.reveal_unavailable" }
	end
	return {
		ok = true,
		payload = {
			expectedRevision = snapshot.revision,
			packId = packId,
		},
	}
end

function PackRevealController.choiceRequest(state: any, snapshot: any, choiceIndex: number): any
	if type(snapshot) ~= "table" or snapshot.writable ~= true then
		return { ok = false, code = "profile.read_only" }
	end
	if state.phase ~= "complete" or state.kind ~= "offer" or state.packOperationId == nil then
		return { ok = false, code = "pack.choice_unavailable" }
	end
	if
		type(choiceIndex) ~= "number"
		or choiceIndex % 1 ~= 0
		or choiceIndex < 1
		or choiceIndex > #state.contents
	then
		return { ok = false, code = "pack.choice_invalid" }
	end
	return {
		ok = true,
		payload = {
			choiceIndex = choiceIndex,
			expectedRevision = snapshot.revision,
			packOperationId = state.packOperationId,
		},
	}
end

function PackRevealController.applyMessage(state: any, message: any): any
	if type(message) ~= "table" or type(message.code) ~= "string" then
		return failure(state, "client.invalid_server_message", "maintenance")
	end
	if message.action == "pack.open" then
		if not message.ok then
			return failure(state, message.code, "error")
		end
		if
			type(message.requestId) ~= "string"
			or type(message.snapshot) ~= "table"
			or type(message.snapshot.pendingPacks) ~= "table"
			or type(message.packId) ~= "string"
		then
			return failure(state, "client.pack_missing_commit", "maintenance")
		end
		local pending = message.snapshot.pendingPacks[message.requestId]
		if
			type(pending) ~= "table"
			or (pending.state ~= "committed" and pending.state ~= "acknowledged" and pending.state ~= "revealed" and pending.state ~= "claimed")
			or pending.packId ~= message.packId
		then
			return failure(state, "client.pack_missing_commit", "maintenance")
		end
		local cards = if type(message.cards) == "table" then message.cards else nil
		local offers = if type(message.offers) == "table" then message.offers else nil
		if cards ~= nil and offers ~= nil then
			return failure(state, "client.pack_ambiguous_contents", "maintenance")
		end
		local kind = if cards ~= nil then "card" elseif offers ~= nil then "offer" else nil
		local contents = if cards ~= nil then cards else offers
		if
			kind == nil
			or contents == nil
			or not validContents(kind, contents)
			or not matchesPending(kind, contents, pending)
		then
			return failure(state, "client.pack_missing_contents", "maintenance")
		end
		local nextState = PackRevealController.new(state.settings)
		nextState.phase = "revealing"
		nextState.lastCode = message.code
		nextState.packId = message.packId
		nextState.operationId = message.requestId
		nextState.packOperationId = message.requestId
		nextState.catalogVersion = message.catalogVersion
		nextState.currencyId = message.currencyId
		nextState.price = message.price
		nextState.contents = copy(contents)
		nextState.kind = kind
		nextState.classifications = classificationsFor(kind, message, pending, contents)
		if
			kind == "card"
			and message.packId ~= "classic_starter"
			and nextState.classifications == nil
		then
			return failure(state, "client.pack_missing_classifications", "maintenance")
		end
		nextState.rarityOdds = copy(message.rarityOdds)
		nextState.itemOdds = copy(message.itemOdds)
		nextState.pityBefore = message.pityBefore
		nextState.pityAfter = message.pityAfter
		nextState.pendingState = pending.state
		nextState.pendingRecovery = true
		nextState.audioCue = if nextState.settings.mutedAudio then nil else "pack.open"
		nextState.effectCue = if nextState.settings.reducedMotion
				or nextState.settings.lowGraphics
			then "pack.static"
			else "pack.reveal_start"
		nextState.surfaceRevision = state.surfaceRevision + 1
		return nextState
	elseif message.action == "pack.choose" then
		if not message.ok then
			return failure(state, message.code, "choice_error")
		end
		if
			state.kind ~= "offer"
			or state.packOperationId ~= message.packOperationId
			or type(message.snapshot) ~= "table"
			or type(message.snapshot.pendingPacks) ~= "table"
			or type(message.choiceIndex) ~= "number"
			or message.choiceIndex % 1 ~= 0
			or message.choiceIndex < 1
			or message.choiceIndex > #state.contents
			or type(message.choiceId) ~= "string"
			or state.contents[message.choiceIndex] == nil
			or state.contents[message.choiceIndex].id ~= message.choiceId
			or type(message.snapshot.pendingPacks[state.packOperationId]) ~= "table"
			or message.snapshot.pendingPacks[state.packOperationId].state ~= "claimed"
			or message.snapshot.pendingPacks[state.packOperationId].choiceIndex ~= message.choiceIndex
			or message.snapshot.pendingPacks[state.packOperationId].choiceId ~= message.choiceId
		then
			return failure(state, "client.pack_choice_mismatch", "maintenance")
		end
		local nextState = copy(state)
		nextState.phase = "claimed"
		nextState.lastCode = message.code
		nextState.choiceIndex = message.choiceIndex
		nextState.choiceId = message.choiceId
		nextState.grant = copy(message.grant)
		nextState.pendingState = "claimed"
		nextState.pendingRecovery = false
		return bump(nextState)
	end
	return state
end

function PackRevealController.revealNext(state: any): any
	if state.phase ~= "revealing" then
		return failure(state, "client.pack.reveal_unavailable")
	end
	local nextState = copy(state)
	local nextIndex = nextState.revealedCount + 1
	if nextIndex > total(nextState) then
		return failure(nextState, "client.pack.reveal_unavailable")
	end
	nextState.revealed[nextIndex] = true
	nextState.revealedCount = nextIndex
	nextState.lastCode = "pack.reveal_next"
	nextState.audioCue = if nextState.settings.mutedAudio then nil else "pack.reveal_card"
	nextState.effectCue = if nextState.settings.reducedMotion or nextState.settings.lowGraphics
		then "pack.static"
		else "pack.reveal_card"
	if nextIndex == total(nextState) then
		nextState.phase = "complete"
		nextState.effectCue = if nextState.settings.reducedMotion
				or nextState.settings.lowGraphics
			then "pack.static"
			else "pack.reveal_complete"
	end
	return bump(nextState)
end

function PackRevealController.revealAll(state: any): any
	return revealAllInternal(state, false)
end

function PackRevealController.skip(state: any): any
	return revealAllInternal(state, true)
end

function PackRevealController.setSettings(state: any, settings: any): any
	local nextState = copy(state)
	nextState.settings = settingsFrom(settings)
	nextState.audioCue = if nextState.settings.mutedAudio then nil else nextState.audioCue
	nextState.effectCue = if nextState.settings.reducedMotion or nextState.settings.lowGraphics
		then "pack.static"
		else nextState.effectCue
	return bump(nextState)
end

function PackRevealController.hydrateSnapshot(state: any, snapshot: any): any
	if type(snapshot) ~= "table" or type(snapshot.pendingPacks) ~= "table" then
		return failure(state, "client.pack_recovery_unavailable", "maintenance")
	end
	local operationIds = {}
	for id in snapshot.pendingPacks do
		if type(id) == "string" then
			table.insert(operationIds, id)
		end
	end
	table.sort(operationIds)
	local operationId = nil
	local pending = nil
	for _, id in operationIds do
		local candidate = snapshot.pendingPacks[id]
		if
			type(candidate) == "table"
			and (
				candidate.state == "committed"
				or candidate.state == "acknowledged"
				or candidate.state == "revealed"
				or candidate.state == "claimed"
			)
		then
			operationId = id
			pending = candidate
			break
		end
	end
	if pending == nil then
		return state
	end
	local nextState = PackRevealController.new(snapshot.settings)
	nextState.packId = pending.packId
	nextState.operationId = operationId
	nextState.packOperationId = operationId
	nextState.catalogVersion = pending.catalogVersion
	nextState.pendingState = pending.state
	nextState.pendingRecovery = true
	if pending.offerIds ~= nil then
		nextState.kind = "offer"
		nextState.contents = {}
		for _, id in pending.offerIds do
			table.insert(nextState.contents, { id = id })
		end
	else
		nextState.kind = "card"
		local byId = {}
		for _, card in snapshot.cards or {} do
			byId[card.instanceId] = card
		end
		for _, id in pending.cardInstanceIds or {} do
			if byId[id] == nil then
				return failure(state, "client.pack_recovery_unavailable", "maintenance")
			end
			table.insert(nextState.contents, copy(byId[id]))
		end
		nextState.classifications = copy(pending.classifications)
	end
	if #nextState.contents == 0 then
		return failure(state, "client.pack_recovery_unavailable", "maintenance")
	end
	nextState.phase = if pending.state == "claimed" then "claimed" else "revealing"
	nextState.revealed = if nextState.phase == "claimed"
		then table.create(#nextState.contents, true)
		else {}
	nextState.revealedCount = if nextState.phase == "claimed" then #nextState.contents else 0
	nextState.choiceIndex = pending.choiceIndex
	nextState.choiceId = pending.choiceId
	nextState.surfaceRevision = state.surfaceRevision + 1
	return nextState
end

function PackRevealController.display(state: any): any
	local contents = {}
	for index, content in state.contents do
		contents[index] = {
			item = copy(content),
			revealed = state.revealed[index] == true,
			classification = if state.classifications ~= nil
				then state.classifications[index]
				else content.classification,
		}
	end
	return {
		version = state.version,
		phase = state.phase,
		packId = state.packId,
		kind = state.kind,
		contents = contents,
		revealedCount = state.revealedCount,
		totalCount = #contents,
		revealAll = state.revealAll,
		skipped = state.skipped,
		choiceIndex = state.choiceIndex,
		choiceId = state.choiceId,
		grant = copy(state.grant),
		rarityOdds = copy(state.rarityOdds),
		itemOdds = copy(state.itemOdds),
		pityBefore = state.pityBefore,
		pityAfter = state.pityAfter,
		pendingState = state.pendingState,
		pendingRecovery = state.pendingRecovery,
		settings = copy(state.settings),
		lastCode = state.lastCode,
		surfaceRevision = state.surfaceRevision,
	}
end

return table.freeze(PackRevealController)
