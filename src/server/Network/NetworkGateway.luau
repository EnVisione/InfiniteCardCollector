--!strict

local NetworkGateway = {}

local function response(
	ok: boolean,
	code: string,
	requestId: string?,
	retryAfterMs: number?,
	action: string?
): any
	return {
		ok = ok,
		code = code,
		requestId = requestId,
		retryAfterMs = retryAfterMs,
		action = action,
	}
end

local function safeCorrelation(registry: any, envelope: any): (string?, string?)
	if type(envelope) ~= "table" then
		return nil, nil
	end
	local requestId = envelope.requestId
	if
		type(requestId) ~= "string"
		or #requestId < registry.requestIdMinLength
		or #requestId > registry.requestIdMaxLength
		or requestId:match("^[A-Za-z0-9_]+$") == nil
	then
		requestId = nil
	end
	local action = envelope.action
	if
		type(action) ~= "string"
		or #action < 1
		or #action > 64
		or action:match("^[a-z0-9][a-z0-9_.:]*$") == nil
	then
		action = nil
	end
	return requestId, action
end

function NetworkGateway.new(dependencies: any): any
	assert(dependencies.registry ~= nil, "P002-GATEWAY-001 registry missing")
	assert(dependencies.errors ~= nil, "P002-GATEWAY-002 errors missing")
	assert(dependencies.validator ~= nil, "P002-GATEWAY-003 validator missing")
	assert(dependencies.limiter ~= nil, "P002-GATEWAY-004 limiter missing")
	assert(type(dependencies.profileState) == "function", "P002-GATEWAY-005 profile state missing")
	assert(type(dependencies.authorize) == "function", "P002-GATEWAY-006 authorize missing")

	local gateway = {}

	function gateway:handle(userKey: string, envelope: any): any
		local validation =
			dependencies.validator.validate(dependencies.registry, dependencies.errors, envelope)
		if not validation.accepted then
			local requestId, action = safeCorrelation(dependencies.registry, envelope)
			return response(false, validation.code, requestId, nil, action)
		end
		local policy = validation.policy
		local allowed, retryAfterMs = dependencies.limiter:consume(userKey, policy.id)
		if not allowed then
			return response(
				false,
				dependencies.errors.codes.rateLimited,
				validation.requestId,
				retryAfterMs,
				policy.id
			)
		end
		if not policy.available then
			return response(
				false,
				dependencies.errors.codes.featureUnavailable,
				validation.requestId,
				nil,
				policy.id
			)
		end
		local profile = dependencies.profileState(userKey)
		if policy.requiresProfile and not profile.ready then
			return response(
				false,
				dependencies.errors.codes.profileNotReady,
				validation.requestId,
				nil,
				policy.id
			)
		end
		if policy.requiresWritable and not profile.writable then
			return response(
				false,
				dependencies.errors.codes.profileReadOnly,
				validation.requestId,
				nil,
				policy.id
			)
		end
		if not dependencies.authorize(userKey, policy.id, envelope.payload) then
			return response(
				false,
				dependencies.errors.codes.permissionDenied,
				validation.requestId,
				nil,
				policy.id
			)
		end
		local route = dependencies.routes[policy.handlerId]
		if type(route) ~= "function" then
			return response(
				false,
				dependencies.errors.codes.internalFailClosed,
				validation.requestId,
				nil,
				policy.id
			)
		end
		local ok, result = pcall(route, userKey, envelope.payload, validation.requestId, policy)
		if not ok or type(result) ~= "table" or type(result.ok) ~= "boolean" then
			return response(
				false,
				dependencies.errors.codes.internalFailClosed,
				validation.requestId,
				nil,
				policy.id
			)
		end
		local normalizedResult = table.clone(result)
		if normalizedResult.requestId == nil then
			normalizedResult.requestId = validation.requestId
		end
		if normalizedResult.action == nil then
			normalizedResult.action = policy.id
		end
		return normalizedResult
	end

	return gateway
end

return table.freeze(NetworkGateway)
