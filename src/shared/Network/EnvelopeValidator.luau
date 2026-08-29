--!strict

local EnvelopeValidator = {}

local function failure(code: string): any
	return {
		accepted = false,
		code = code,
	}
end

local function isFinite(value: number): boolean
	return value == value and value ~= math.huge and value ~= -math.huge
end

local function isDenseArray(value: { [any]: any }): (boolean, number)
	local length = #value
	local count = 0
	for key in value do
		if
			type(key) ~= "number"
			or not isFinite(key)
			or key % 1 ~= 0
			or key < 1
			or key > length
		then
			return false, 0
		end
		count += 1
	end
	return count == length, length
end

local function measure(
	value: any,
	depth: number,
	maxDepth: number,
	state: {
		bytes: number,
		nodes: number,
		maxNodes: number,
		seen: { [any]: boolean },
	}
): string?
	if depth > maxDepth then
		return "depth"
	end
	state.nodes += 1
	if state.nodes > state.maxNodes then
		return "nodes"
	end
	local valueType = type(value)
	if valueType == "nil" then
		state.bytes += 4
	elseif valueType == "boolean" then
		state.bytes += 5
	elseif valueType == "number" then
		if not isFinite(value) then
			return "nonfinite"
		end
		state.bytes += 24
	elseif valueType == "string" then
		state.bytes += #value + 2
	elseif valueType == "table" then
		if state.seen[value] then
			return "cycle"
		end
		state.seen[value] = true
		state.bytes += 2
		for key, child in value do
			local keyType = type(key)
			if keyType ~= "string" and keyType ~= "number" then
				return "key"
			end
			local keyFailure = measure(key, depth + 1, maxDepth, state)
			if keyFailure ~= nil then
				return keyFailure
			end
			local childFailure = measure(child, depth + 1, maxDepth, state)
			if childFailure ~= nil then
				return childFailure
			end
		end
		state.seen[value] = nil
	else
		return "type"
	end
	return nil
end

local function validateStableId(value: string, spec: any): boolean
	if #value < (spec.minLength or 1) or #value > (spec.maxLength or 64) then
		return false
	end
	return value:match("^[a-z0-9][a-z0-9_.:]*$") ~= nil
end

local function validateRequestId(value: string, spec: any): boolean
	if #value < (spec.minLength or 16) or #value > (spec.maxLength or 64) then
		return false
	end
	return value:match("^[A-Za-z0-9_]+$") ~= nil
end

local validateValue: (any, any, any) -> string?

validateValue = function(value: any, spec: any, errors: any): string?
	local kind = spec.kind
	if kind == "boolean" then
		return if type(value) == "boolean" then nil else errors.codes.typeInvalid
	elseif kind == "string" then
		if type(value) ~= "string" then
			return errors.codes.typeInvalid
		end
		if #value < (spec.minLength or 0) or #value > (spec.maxLength or math.huge) then
			return errors.codes.boundsInvalid
		end
		return nil
	elseif kind == "stable_id" then
		if type(value) ~= "string" then
			return errors.codes.typeInvalid
		end
		return if validateStableId(value, spec) then nil else errors.codes.boundsInvalid
	elseif kind == "request_id" then
		if type(value) ~= "string" then
			return errors.codes.typeInvalid
		end
		return if validateRequestId(value, spec) then nil else errors.codes.boundsInvalid
	elseif kind == "integer" then
		if type(value) ~= "number" then
			return errors.codes.typeInvalid
		end
		if not isFinite(value) then
			return errors.codes.numberNonfinite
		end
		if
			value % 1 ~= 0
			or value < (spec.min or -math.huge)
			or value > (spec.max or math.huge)
		then
			return errors.codes.boundsInvalid
		end
		return nil
	elseif kind == "enum" then
		if type(value) ~= "string" then
			return errors.codes.typeInvalid
		end
		for _, allowed in spec.values do
			if value == allowed then
				return nil
			end
		end
		return errors.codes.boundsInvalid
	elseif kind == "array" then
		if type(value) ~= "table" then
			return errors.codes.typeInvalid
		end
		local dense, length = isDenseArray(value)
		if not dense then
			return errors.codes.payloadInvalid
		end
		if length < spec.minItems or length > spec.maxItems then
			return errors.codes.boundsInvalid
		end
		for _, child in value do
			local childError = validateValue(child, spec.item, errors)
			if childError ~= nil then
				return childError
			end
		end
		return nil
	end
	return errors.codes.internalFailClosed
end

local function validateObject(value: any, schema: any, errors: any): string?
	if type(value) ~= "table" then
		return errors.codes.typeInvalid
	end
	for key in value do
		if type(key) ~= "string" then
			return errors.codes.payloadInvalid
		end
		if schema.fields[key] == nil and not schema.allowUnknown then
			return errors.codes.unknownField
		end
	end
	local names = {}
	for name in schema.fields do
		table.insert(names, name)
	end
	table.sort(names)
	for _, name in names do
		local spec = schema.fields[name]
		local child = value[name]
		if child == nil then
			if spec.required ~= false then
				return errors.codes.payloadInvalid
			end
		else
			local childError = validateValue(child, spec, errors)
			if childError ~= nil then
				return childError
			end
		end
	end
	return nil
end

function EnvelopeValidator.validate(registry: any, errors: any, envelope: any): any
	if type(envelope) ~= "table" then
		return failure(errors.codes.envelopeInvalid)
	end
	for key in envelope do
		if key ~= "version" and key ~= "action" and key ~= "requestId" and key ~= "payload" then
			return failure(errors.codes.envelopeInvalid)
		end
	end
	if type(envelope.version) ~= "number" or envelope.version % 1 ~= 0 then
		return failure(errors.codes.envelopeInvalid)
	end
	if envelope.version ~= registry.envelopeVersion then
		return failure(errors.codes.versionUnsupported)
	end
	if type(envelope.action) ~= "string" then
		return failure(errors.codes.envelopeInvalid)
	end
	if
		type(envelope.requestId) ~= "string"
		or not validateRequestId(envelope.requestId, {
			minLength = registry.requestIdMinLength,
			maxLength = registry.requestIdMaxLength,
		})
	then
		return failure(errors.codes.requestIdInvalid)
	end
	if type(envelope.payload) ~= "table" then
		return failure(errors.codes.payloadInvalid)
	end
	local envelopeState = {
		bytes = 0,
		nodes = 0,
		maxNodes = registry.maxEnvelopeNodes,
		seen = {},
	}
	local envelopeFailure = measure(envelope, 1, registry.maxEnvelopeDepth, envelopeState)
	if envelopeFailure == "depth" then
		return failure(errors.codes.payloadTooDeep)
	elseif envelopeFailure == "nodes" then
		return failure(errors.codes.payloadTooComplex)
	elseif envelopeFailure == "nonfinite" then
		return failure(errors.codes.numberNonfinite)
	elseif envelopeFailure ~= nil then
		return failure(errors.codes.payloadInvalid)
	elseif envelopeState.bytes > registry.maxEnvelopeBytes then
		return failure(errors.codes.payloadTooLarge)
	end
	local action = registry.byId[envelope.action]
	if action == nil then
		return failure(errors.codes.actionUnknown)
	end
	local payloadState = {
		bytes = 0,
		nodes = 0,
		maxNodes = action.maxNodes,
		seen = {},
	}
	local payloadFailure = measure(envelope.payload, 1, action.maxDepth, payloadState)
	if payloadFailure == "depth" then
		return failure(errors.codes.payloadTooDeep)
	elseif payloadFailure == "nodes" then
		return failure(errors.codes.payloadTooComplex)
	elseif payloadFailure == "nonfinite" then
		return failure(errors.codes.numberNonfinite)
	elseif payloadFailure ~= nil then
		return failure(errors.codes.payloadInvalid)
	elseif payloadState.bytes > action.maxPayloadBytes then
		return failure(errors.codes.payloadTooLarge)
	end
	local schemaError = validateObject(envelope.payload, action.schema, errors)
	if schemaError ~= nil then
		return failure(schemaError)
	end
	return {
		accepted = true,
		policy = action,
		requestId = envelope.requestId,
	}
end

return table.freeze(EnvelopeValidator)
