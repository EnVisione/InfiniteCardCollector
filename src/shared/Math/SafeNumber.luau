--!strict

local SafeNumber = {}

SafeNumber.MAX_LAUNCH_INTEGER = 999999999999999
SafeNumber.MAX_RATIONAL_COMPONENT = 1000000

local function isFinite(value: number): boolean
	return value == value and value ~= math.huge and value ~= -math.huge
end

function SafeNumber.isInteger(value: any): boolean
	return type(value) == "number" and isFinite(value) and value % 1 == 0
end

function SafeNumber.assertInteger(value: any, maximum: number?): number
	assert(SafeNumber.isInteger(value), "P001-NUMBER-001 expected finite integer")
	assert(value >= 0, "P001-NUMBER-002 negative integer")
	local limit = maximum or SafeNumber.MAX_LAUNCH_INTEGER
	assert(value <= limit, "P001-NUMBER-003 integer exceeds bound")
	return value
end

function SafeNumber.assertRational(value: any): { numerator: number, denominator: number }
	assert(type(value) == "table", "P001-NUMBER-004 rational missing")
	local numerator = SafeNumber.assertInteger(value.numerator, SafeNumber.MAX_RATIONAL_COMPONENT)
	local denominator =
		SafeNumber.assertInteger(value.denominator, SafeNumber.MAX_RATIONAL_COMPONENT)
	assert(denominator > 0, "P001-NUMBER-005 zero denominator")
	return { numerator = numerator, denominator = denominator }
end

function SafeNumber.add(left: number, right: number): number
	left = SafeNumber.assertInteger(left)
	right = SafeNumber.assertInteger(right)
	assert(left <= SafeNumber.MAX_LAUNCH_INTEGER - right, "P001-NUMBER-006 addition overflow")
	return left + right
end

function SafeNumber.subtract(left: number, right: number): number
	left = SafeNumber.assertInteger(left)
	right = SafeNumber.assertInteger(right)
	assert(left >= right, "P001-NUMBER-007 subtraction underflow")
	return left - right
end

function SafeNumber.multiply(left: number, right: number): number
	left = SafeNumber.assertInteger(left)
	right = SafeNumber.assertInteger(right)
	if left == 0 or right == 0 then
		return 0
	end
	assert(
		left <= math.floor(SafeNumber.MAX_LAUNCH_INTEGER / right),
		"P001-NUMBER-008 multiplication overflow"
	)
	return left * right
end

function SafeNumber.scale(value: number, multiplier: any): number
	value = SafeNumber.assertInteger(value)
	local rational = SafeNumber.assertRational(multiplier)
	local product = SafeNumber.multiply(value, rational.numerator)
	local quotient = math.floor(product / rational.denominator)
	local remainder = product - quotient * rational.denominator
	local rounded = quotient
	if remainder * 2 >= rational.denominator then
		rounded = SafeNumber.add(quotient, 1)
	end
	return SafeNumber.assertInteger(rounded)
end

function SafeNumber.percent(value: number, percent: number): number
	percent = SafeNumber.assertInteger(percent, SafeNumber.MAX_RATIONAL_COMPONENT - 100)
	return SafeNumber.scale(value, { numerator = 100 + percent, denominator = 100 })
end

function SafeNumber.reducePercent(value: number, percent: number): number
	percent = SafeNumber.assertInteger(percent, 100)
	return SafeNumber.scale(value, { numerator = 100 - percent, denominator = 100 })
end

function SafeNumber.applyCap(value: number, capId: string, cap: number): (number, any?)
	value = SafeNumber.assertInteger(value)
	cap = SafeNumber.assertInteger(cap)
	assert(type(capId) == "string" and capId ~= "", "P001-NUMBER-009 cap id missing")
	if value <= cap then
		return value, nil
	end
	return cap, {
		capId = capId,
		originalValue = value,
		capValue = cap,
		result = cap,
	}
end

return table.freeze(SafeNumber)
