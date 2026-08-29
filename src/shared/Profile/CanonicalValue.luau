--!strict

local CanonicalValue = {}

local function isFinite(value: number): boolean
	return value == value and value ~= math.huge and value ~= -math.huge
end

local function denseArrayLength(value: { [any]: any }): number?
	local length = #value
	local count = 0
	for key in value do
		if type(key) ~= "number" or key % 1 ~= 0 or key < 1 or key > length then
			return nil
		end
		count += 1
	end
	return if count == length then length else nil
end

local function encodeValue(value: any, seen: { [any]: boolean }): string
	local valueType = type(value)
	if valueType == "nil" then
		return "n"
	elseif valueType == "boolean" then
		return if value then "t" else "f"
	elseif valueType == "number" then
		assert(isFinite(value), "P002-CANONICAL-001 nonfinite number")
		return "d" .. string.format("%.17g", value) .. ";"
	elseif valueType == "string" then
		return "s" .. tostring(#value) .. ":" .. value
	elseif valueType ~= "table" then
		error("P002-CANONICAL-002 unsupported value")
	end
	assert(not seen[value], "P002-CANONICAL-003 cyclic value")
	seen[value] = true
	local length = denseArrayLength(value)
	local pieces = {}
	if length ~= nil then
		table.insert(pieces, "a" .. tostring(length) .. "[")
		for index = 1, length do
			table.insert(pieces, encodeValue(value[index], seen))
		end
	else
		local keys = {}
		for key in value do
			assert(type(key) == "string", "P002-CANONICAL-004 map key must be string")
			table.insert(keys, key)
		end
		table.sort(keys)
		table.insert(pieces, "m" .. tostring(#keys) .. "{")
		for _, key in keys do
			table.insert(pieces, encodeValue(key, seen))
			table.insert(pieces, encodeValue(value[key], seen))
		end
	end
	table.insert(pieces, if length ~= nil then "]" else "}")
	seen[value] = nil
	return table.concat(pieces)
end

function CanonicalValue.encode(value: any): string
	return encodeValue(value, {})
end

function CanonicalValue.size(value: any): number
	return #CanonicalValue.encode(value)
end

function CanonicalValue.copy(value: any, seen: { [any]: any }?): any
	if type(value) ~= "table" then
		return value
	end
	local copies = seen or {}
	assert(copies[value] == nil, "P002-CANONICAL-005 cyclic copy")
	local result = {}
	copies[value] = result
	for key, child in value do
		result[CanonicalValue.copy(key, copies)] = CanonicalValue.copy(child, copies)
	end
	copies[value] = nil
	return result
end

return table.freeze(CanonicalValue)
