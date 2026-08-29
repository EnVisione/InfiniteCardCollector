--!strict

local SurfaceState = {}

SurfaceState.version = 1

local definitions = {
	{
		id = "hud",
		title = "Hub",
		description = "Your currencies, collection, and next action.",
		actionId = nil,
		requiresWritable = false,
	},
	{
		id = "binder",
		title = "Binder",
		description = "Browse cards and permanent discovery.",
		actionId = "binder.page",
		requiresWritable = false,
	},
	{
		id = "deck_builder",
		title = "Deck",
		description = "Choose one card for each rank and suit slot.",
		actionId = "deck.equip_card",
		requiresWritable = true,
	},
	{
		id = "card_inspect",
		title = "Inspect",
		description = "Inspect one owned card and its immutable identity.",
		actionId = nil,
		requiresWritable = false,
	},
	{
		id = "arcana_lab",
		title = "Arcana Lab",
		description = "Preview one eligible Arcana transformation.",
		actionId = "arcana.apply",
		requiresWritable = true,
	},
	{
		id = "joker_stage",
		title = "Joker Stage",
		description = "Inspect and equip the five active Joker slots.",
		actionId = "joker.equip",
		requiresWritable = true,
	},
	{
		id = "showcase",
		title = "Showcase",
		description = "Present one selected card with its resolved layers.",
		actionId = nil,
		requiresWritable = false,
	},
	{
		id = "settings",
		title = "Settings",
		description = "Control motion, flash, audio, color, and graphics settings.",
		actionId = nil,
		requiresWritable = false,
	},
	{
		id = "tutorial",
		title = "Tutorial",
		description = "Continue the short guided collection path.",
		actionId = nil,
		requiresWritable = false,
	},
	{
		id = "recovery",
		title = "Recovery",
		description = "Resume pending committed results after a reconnect.",
		actionId = "bootstrap.request",
		requiresWritable = false,
	},
	{
		id = "formation_rush",
		title = "Formation Rush",
		description = "Submit an authoritative formation for a reward.",
		actionId = "formation.submit",
		requiresWritable = true,
	},
	{
		id = "tasks",
		title = "Tasks",
		description = "Task stations are registered and remain unavailable until their service is enabled.",
		actionId = "task.start",
		requiresWritable = false,
		laterService = true,
	},
	{
		id = "friend_clash",
		title = "Friend Clash",
		description = "Friend Clash is registered and remains unavailable until its service is enabled.",
		actionId = "duel.invite",
		requiresWritable = false,
		laterService = true,
	},
	{
		id = "trade",
		title = "Trade",
		description = "Direct trade is registered and remains unavailable until its safety gate passes.",
		actionId = "trade.request",
		requiresWritable = false,
		laterService = true,
	},
}

local byId = {}
for _, definition in definitions do
	assert(byId[definition.id] == nil, "P003-SURFACE-001 duplicate surface")
	byId[definition.id] = definition
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

local function hasPendingRecovery(snapshot: any): boolean
	if type(snapshot) ~= "table" or type(snapshot.pendingPacks) ~= "table" then
		return false
	end
	for _, pending in snapshot.pendingPacks do
		if
			type(pending) == "table"
			and pending.state ~= "claimed"
			and pending.state ~= "cancelled"
		then
			return true
		end
	end
	return false
end

local function ownsCard(snapshot: any, instanceId: string): boolean
	if type(snapshot) ~= "table" or type(snapshot.cards) ~= "table" then
		return false
	end
	for _, card in snapshot.cards do
		if type(card) == "table" and card.instanceId == instanceId then
			return true
		end
	end
	return false
end

local function ownsJoker(snapshot: any, instanceId: string): boolean
	if type(snapshot) ~= "table" or type(snapshot.jokers) ~= "table" then
		return false
	end
	for _, joker in snapshot.jokers do
		if type(joker) == "table" and joker.instanceId == instanceId then
			return true
		end
	end
	return false
end

local function bump(state: any): any
	state.surfaceRevision += 1
	return state
end

local function failure(state: any, code: string): any
	local nextState = copy(state)
	nextState.lastCode = code
	return bump(nextState)
end

function SurfaceState.new(): any
	return {
		version = SurfaceState.version,
		phase = "bootstrapping",
		activeSurfaceId = "hud",
		selectedCardId = nil,
		selectedJokerId = nil,
		snapshot = nil,
		pendingRecovery = false,
		lastCode = "client.bootstrapping",
		surfaceRevision = 0,
	}
end

function SurfaceState.definition(surfaceId: string): any?
	return byId[surfaceId]
end

function SurfaceState.navigate(state: any, surfaceId: string): any
	if byId[surfaceId] == nil then
		return failure(state, "client.surface_unknown")
	end
	local nextState = copy(state)
	nextState.activeSurfaceId = surfaceId
	nextState.lastCode = "client.surface_changed"
	return bump(nextState)
end

function SurfaceState.selectCard(state: any, instanceId: string): any
	if type(instanceId) ~= "string" or not ownsCard(state.snapshot, instanceId) then
		return failure(state, "client.card_unavailable")
	end
	local nextState = copy(state)
	nextState.selectedCardId = instanceId
	nextState.lastCode = "client.card_selected"
	return bump(nextState)
end

function SurfaceState.selectJoker(state: any, instanceId: string): any
	if type(instanceId) ~= "string" or not ownsJoker(state.snapshot, instanceId) then
		return failure(state, "client.joker_unavailable")
	end
	local nextState = copy(state)
	nextState.selectedJokerId = instanceId
	nextState.lastCode = "client.joker_selected"
	return bump(nextState)
end

function SurfaceState.applyMessage(state: any, message: any): any
	if
		type(message) ~= "table"
		or type(message.ok) ~= "boolean"
		or type(message.code) ~= "string"
	then
		return failure(state, "client.invalid_server_message")
	end
	local nextState = copy(state)
	nextState.lastCode = message.code
	if message.ok and type(message.snapshot) == "table" then
		nextState.snapshot = copy(message.snapshot)
		nextState.phase = if message.snapshot.writable == true then "ready" else "read_only"
		nextState.pendingRecovery = hasPendingRecovery(message.snapshot)
		if
			nextState.selectedCardId ~= nil
			and not ownsCard(message.snapshot, nextState.selectedCardId)
		then
			nextState.selectedCardId = nil
		end
		if
			nextState.selectedJokerId ~= nil
			and not ownsJoker(message.snapshot, nextState.selectedJokerId)
		then
			nextState.selectedJokerId = nil
		end
	elseif not message.ok then
		if message.code == "profile.read_only" or message.code == "session.conflict" then
			nextState.phase = "read_only"
		elseif
			message.code == "storage.unavailable"
			or message.code == "profile.malformed"
			or message.code == "profile.not_ready"
		then
			nextState.phase = "maintenance"
		end
	end
	return bump(nextState)
end

function SurfaceState.action(state: any, surfaceId: string): any
	local definition = byId[surfaceId]
	if definition == nil then
		return { ok = false, code = "client.surface_unknown" }
	elseif definition.laterService then
		return { ok = false, code = "client.surface_unavailable", action = definition.actionId }
	elseif definition.actionId == nil then
		return { ok = false, code = "client.surface_read_only" }
	elseif state.snapshot == nil then
		return { ok = false, code = "client.profile_unavailable", action = definition.actionId }
	elseif state.phase == "maintenance" then
		return { ok = false, code = "client.maintenance", action = definition.actionId }
	elseif
		definition.requiresWritable and (state.phase ~= "ready" or state.snapshot.writable ~= true)
	then
		return { ok = false, code = "client.read_only", action = definition.actionId }
	end
	return {
		ok = true,
		code = "client.surface_action_ready",
		action = definition.actionId,
		expectedRevision = state.snapshot.revision,
	}
end

function SurfaceState.project(state: any, surfaceId: string?): any
	local selected = surfaceId or state.activeSurfaceId
	local definition = byId[selected]
	assert(definition ~= nil, "P003-SURFACE-002 projection surface missing")
	local status = state.phase
	if definition.laterService then
		status = "unavailable"
	elseif state.snapshot == nil then
		status = "bootstrapping"
	end
	return {
		id = definition.id,
		title = definition.title,
		description = definition.description,
		status = status,
		actionId = definition.actionId,
		available = not definition.laterService and state.snapshot ~= nil,
		requiresWritable = definition.requiresWritable,
		selectedCardId = state.selectedCardId,
		selectedJokerId = state.selectedJokerId,
		pendingRecovery = state.pendingRecovery,
		revision = state.surfaceRevision,
	}
end

SurfaceState.definitions = table.freeze(definitions)

return table.freeze(SurfaceState)
