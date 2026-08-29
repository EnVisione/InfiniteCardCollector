--!strict

local ClientState = {}

local function withoutMutationAuthority(snapshot: any): any
	if type(snapshot) ~= "table" then
		return snapshot
	end
	local restricted = table.clone(snapshot)
	restricted.writable = false
	return restricted
end

function ClientState.new(): any
	return {
		phase = "bootstrapping",
		lastCode = "client.bootstrapping",
		snapshot = nil,
	}
end

function ClientState.applyMessage(state: any, message: any): any
	if
		type(message) ~= "table"
		or type(message.ok) ~= "boolean"
		or type(message.code) ~= "string"
	then
		return {
			phase = "maintenance",
			lastCode = "client.invalid_server_message",
			snapshot = withoutMutationAuthority(state.snapshot),
		}
	end
	local nextState = {
		phase = state.phase,
		lastCode = message.code,
		snapshot = state.snapshot,
	}
	if message.ok and type(message.snapshot) == "table" then
		local currentRevision = if state.snapshot ~= nil then state.snapshot.revision else nil
		local nextRevision = message.snapshot.revision
		if
			currentRevision == nil
			or (type(nextRevision) == "number" and nextRevision >= currentRevision)
		then
			nextState.snapshot = message.snapshot
			nextState.phase = if message.snapshot.writable then "ready" else "read_only"
		end
	elseif not message.ok then
		if message.code == "profile.read_only" or message.code == "session.conflict" then
			nextState.phase = "read_only"
			nextState.snapshot = withoutMutationAuthority(state.snapshot)
		elseif
			message.code == "storage.unavailable"
			or message.code == "profile.malformed"
			or message.code == "profile.not_ready"
		then
			nextState.phase = "maintenance"
			nextState.snapshot = withoutMutationAuthority(state.snapshot)
		end
	end
	return nextState
end

return table.freeze(ClientState)
