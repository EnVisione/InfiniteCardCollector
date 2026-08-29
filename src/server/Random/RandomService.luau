--!strict

local RandomService = {}

local modulus = 2147483647
local multiplier = 48271

function RandomService.new(seed: number): any
	assert(
		type(seed) == "number" and seed == seed and seed % 1 == 0,
		"P002-RANDOM-001 seed invalid"
	)
	local initial = seed % modulus
	if initial <= 0 then
		initial += modulus - 1
	end
	local generator = {
		state = initial,
		draws = 0,
	}

	function generator:nextInteger(maximum: number): number
		assert(maximum > 0 and maximum % 1 == 0, "P002-RANDOM-002 maximum invalid")
		self.state = self.state * multiplier % modulus
		self.draws += 1
		return (self.state - 1) % maximum + 1
	end

	return generator
end

return table.freeze(RandomService)
