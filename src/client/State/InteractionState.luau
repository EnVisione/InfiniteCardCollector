--!strict

local InteractionState = {}

InteractionState.version = 1

local breakpoints = {
	{ id = "phone", maxWidth = 599, scale = 0.9 },
	{ id = "tablet", maxWidth = 1023, scale = 0.96 },
	{ id = "desktop", maxWidth = math.huge, scale = 1 },
}

local inputActions = {
	activate = {
		keyboard = { "Return", "Space" },
		mouse = { "MouseLeftButton" },
		touch = { "Tap" },
		controller = { "ButtonA" },
	},
	back = {
		keyboard = { "Escape" },
		mouse = { "MouseRightButton" },
		touch = { "SwipeRight" },
		controller = { "ButtonB" },
	},
	next = {
		keyboard = { "Right", "Down" },
		mouse = { "MouseWheelDown" },
		touch = { "SwipeLeft" },
		controller = { "DPadRight", "DPadDown" },
	},
	previous = {
		keyboard = { "Left", "Up" },
		mouse = { "MouseWheelUp" },
		touch = { "SwipeDown" },
		controller = { "DPadLeft", "DPadUp" },
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

local function finiteNumber(value: any): boolean
	return type(value) == "number" and value == value and value ~= math.huge and value ~= -math.huge
end

local function findBreakpoint(width: number): any
	for _, breakpoint in breakpoints do
		if width <= breakpoint.maxWidth then
			return breakpoint
		end
	end
	return breakpoints[#breakpoints]
end

local function settingBoolean(settings: any, key: string, fallback: boolean): boolean
	return if type(settings) == "table" and type(settings[key]) == "boolean"
		then settings[key]
		else fallback
end

local function settingsFrom(settings: any): any
	return {
		reducedMotion = settingBoolean(settings, "reducedMotion", false),
		reducedFlash = settingBoolean(settings, "reducedFlash", false),
		lowGraphics = settingBoolean(settings, "lowGraphics", false),
		colorAssistance = settingBoolean(settings, "colorAssistance", false),
		revealSound = settingBoolean(settings, "revealSound", true),
		mutedAudio = settingBoolean(settings, "mutedAudio", false),
		uiScale = if type(settings) == "table" and finiteNumber(settings.uiScale)
			then math.clamp(settings.uiScale, 50, 150)
			else 100,
	}
end

local function bump(state: any): any
	state.revision += 1
	return state
end

local function failure(state: any, code: string): any
	local nextState = copy(state)
	nextState.lastCode = code
	return bump(nextState)
end

function InteractionState.new(settings: any?): any
	local breakpoint = breakpoints[#breakpoints]
	return {
		version = InteractionState.version,
		phase = "bootstrapping",
		device = "mouse",
		viewport = { width = 1280, height = 720 },
		breakpoint = breakpoint.id,
		uiScale = breakpoint.scale,
		focusOrder = {},
		focusedId = nil,
		settings = settingsFrom(settings),
		lastCode = "client.input_bootstrapping",
		revision = 0,
	}
end

function InteractionState.setDevice(state: any, device: string): any
	if
		device ~= "touch"
		and device ~= "mouse"
		and device ~= "keyboard"
		and device ~= "controller"
	then
		return failure(state, "client.input_device_invalid")
	end
	local nextState = copy(state)
	nextState.device = device
	nextState.lastCode = "client.input_device_changed"
	return bump(nextState)
end

function InteractionState.setViewport(state: any, width: number, height: number): any
	if not finiteNumber(width) or not finiteNumber(height) or width <= 0 or height <= 0 then
		return failure(state, "client.viewport_invalid")
	end
	local breakpoint = findBreakpoint(width)
	local nextState = copy(state)
	nextState.viewport = { width = width, height = height }
	nextState.breakpoint = breakpoint.id
	nextState.uiScale = breakpoint.scale * (nextState.settings.uiScale / 100)
	nextState.lastCode = "client.viewport_changed"
	return bump(nextState)
end

function InteractionState.setSettings(state: any, settings: any): any
	if type(settings) ~= "table" then
		return failure(state, "client.settings_invalid")
	end
	local nextState = copy(state)
	nextState.settings = settingsFrom(settings)
	local breakpoint = findBreakpoint(nextState.viewport.width)
	nextState.uiScale = breakpoint.scale * (nextState.settings.uiScale / 100)
	nextState.lastCode = "client.settings_applied"
	return bump(nextState)
end

function InteractionState.setFocusOrder(state: any, focusOrder: { string }): any
	if type(focusOrder) ~= "table" then
		return failure(state, "client.focus_order_invalid")
	end
	local nextState = copy(state)
	nextState.focusOrder = {}
	local seen = {}
	for _, id in focusOrder do
		if type(id) ~= "string" or id == "" or seen[id] then
			return failure(state, "client.focus_order_invalid")
		end
		seen[id] = true
		table.insert(nextState.focusOrder, id)
	end
	if nextState.focusedId == nil or not seen[nextState.focusedId] then
		nextState.focusedId = nextState.focusOrder[1]
	end
	nextState.lastCode = "client.focus_order_applied"
	return bump(nextState)
end

function InteractionState.moveFocus(state: any, direction: number): any
	if
		type(direction) ~= "number"
		or direction % 1 ~= 0
		or (direction ~= 1 and direction ~= -1)
	then
		return failure(state, "client.focus_direction_invalid")
	end
	if #state.focusOrder == 0 then
		return failure(state, "client.focus_unavailable")
	end
	local currentIndex = 1
	for index, id in state.focusOrder do
		if id == state.focusedId then
			currentIndex = index
			break
		end
	end
	local nextIndex = ((currentIndex - 1 + direction) % #state.focusOrder) + 1
	local nextState = copy(state)
	nextState.focusedId = state.focusOrder[nextIndex]
	nextState.lastCode = "client.focus_moved"
	return bump(nextState)
end

function InteractionState.resolveAction(device: string, input: string): string?
	for actionId, devices in inputActions do
		local values = devices[device]
		if values ~= nil then
			for _, value in values do
				if value == input then
					return actionId
				end
			end
		end
	end
	return nil
end

function InteractionState.applyMessage(state: any, message: any): any
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
		nextState.phase = if message.snapshot.writable == true then "ready" else "read_only"
		if type(message.snapshot.settings) == "table" then
			nextState.settings = settingsFrom(message.snapshot.settings)
			local breakpoint = findBreakpoint(nextState.viewport.width)
			nextState.uiScale = breakpoint.scale * (nextState.settings.uiScale / 100)
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

function InteractionState.project(state: any): any
	return {
		version = state.version,
		phase = state.phase,
		device = state.device,
		breakpoint = state.breakpoint,
		viewport = copy(state.viewport),
		uiScale = state.uiScale,
		focusedId = state.focusedId,
		settings = copy(state.settings),
		lastCode = state.lastCode,
		revision = state.revision,
	}
end

InteractionState.breakpoints = table.freeze(breakpoints)

return table.freeze(InteractionState)
