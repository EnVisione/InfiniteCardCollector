--!strict

local TokenBuckets = {}

local function refill(bucket: any, policy: any, now: number): number
	local elapsed = math.max(0, now - bucket.updatedAt)
	local tokens = math.min(
		policy.capacity,
		bucket.tokens + elapsed * policy.refillAmount / policy.refillSeconds
	)
	return tokens
end

local function retryAfterMilliseconds(tokens: number, policy: any): number
	local missing = math.max(0, 1 - tokens)
	return math.ceil(missing * policy.refillSeconds * 1000 / policy.refillAmount)
end

function TokenBuckets.new(registry: any, clock: () -> number): any
	local state = {
		registry = registry,
		clock = clock,
		users = {},
	}

	function state:consume(userKey: string, actionId: string): (boolean, number)
		local action = self.registry.byId[actionId]
		if action == nil then
			return false, 0
		end
		local now = self.clock()
		local user = self.users[userKey]
		if user == nil then
			user = {
				global = {
					tokens = self.registry.globalRate.capacity,
					updatedAt = now,
				},
				actions = {},
			}
			self.users[userKey] = user
		end
		local actionBucket = user.actions[actionId]
		if actionBucket == nil then
			actionBucket = {
				tokens = action.rate.capacity,
				updatedAt = now,
			}
			user.actions[actionId] = actionBucket
		end
		local globalTokens = refill(user.global, self.registry.globalRate, now)
		local actionTokens = refill(actionBucket, action.rate, now)
		user.global.tokens = globalTokens
		user.global.updatedAt = now
		actionBucket.tokens = actionTokens
		actionBucket.updatedAt = now
		if globalTokens < 1 or actionTokens < 1 then
			local globalRetry = retryAfterMilliseconds(globalTokens, self.registry.globalRate)
			local actionRetry = retryAfterMilliseconds(actionTokens, action.rate)
			return false, math.max(globalRetry, actionRetry)
		end
		user.global.tokens -= 1
		actionBucket.tokens -= 1
		return true, 0
	end

	function state:removeUser(userKey: string)
		self.users[userKey] = nil
	end

	return state
end

return table.freeze(TokenBuckets)
