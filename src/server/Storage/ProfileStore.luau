--!strict

local ProfileStore = {}

local function result(ok: boolean, code: string, extra: any?): any
	local value = {
		ok = ok,
		code = code,
	}
	if extra ~= nil then
		for key, child in extra do
			value[key] = child
		end
	end
	return value
end

function ProfileStore.new(dependencies: any): any
	assert(dependencies.adapter ~= nil, "P002-STORE-001 adapter missing")
	assert(dependencies.migrations ~= nil, "P002-STORE-002 migrations missing")
	assert(dependencies.schema ~= nil, "P002-STORE-003 schema missing")
	assert(dependencies.codec ~= nil, "P002-STORE-004 codec missing")
	assert(dependencies.canonical ~= nil, "P002-STORE-005 canonical codec missing")
	assert(dependencies.policy ~= nil, "P002-STORE-006 policy missing")
	assert(dependencies.errors ~= nil, "P002-STORE-007 errors missing")
	assert(type(dependencies.clock) == "function", "P002-STORE-008 clock missing")
	assert(type(dependencies.tokenFactory) == "function", "P002-STORE-009 token factory missing")
	assert(type(dependencies.reconcile) == "function", "P002-STORE-010 reconciler missing")
	assert(type(dependencies.jobId) == "string", "P002-STORE-011 job id missing")
	assert(type(dependencies.placeVersion) == "number", "P002-STORE-012 place version missing")
	assert(type(dependencies.sleep) == "function", "P002-STORE-014 sleep missing")
	assert(type(dependencies.retryJitter) == "function", "P002-STORE-015 jitter missing")

	local store = {
		sessions = {},
		closing = false,
	}

	local function key(userKey: string): string
		return "profile_v1:" .. userKey
	end

	local function encodeChecked(profile: any): (any?, string?)
		local bytes =
			dependencies.codec.measure(dependencies.schema, dependencies.canonical, profile)
		if dependencies.policy.classifyBytes(bytes) == "blocked" then
			return nil, dependencies.errors.codes.profileTooLarge
		end
		return dependencies.codec.encode(dependencies.schema, dependencies.canonical, profile), nil
	end

	local function updateWithRetry(
		storeKey: string,
		transform: (any) -> any,
		deadline: number?
	): any
		local delays = {}
		for attempt = 1, dependencies.policy.maxRetries + 1 do
			if deadline ~= nil and dependencies.clock() >= deadline then
				return {
					ok = false,
					attempts = attempt - 1,
					delays = delays,
					deadlineExceeded = true,
				}
			end
			if dependencies.adapter:update(storeKey, transform) then
				return { ok = true, attempts = attempt, delays = delays }
			end
			if attempt <= dependencies.policy.maxRetries then
				local baseMilliseconds = math.min(
					dependencies.policy.retryBaseMilliseconds * 2 ^ (attempt - 1),
					dependencies.policy.retryMaxMilliseconds
				)
				local jitterMilliseconds =
					dependencies.retryJitter(storeKey, attempt, baseMilliseconds)
				assert(
					type(jitterMilliseconds) == "number"
						and jitterMilliseconds >= 0
						and jitterMilliseconds % 1 == 0
						and jitterMilliseconds <= baseMilliseconds,
					"P002-STORE-016 jitter invalid"
				)
				local delayMilliseconds = math.min(
					baseMilliseconds + jitterMilliseconds,
					dependencies.policy.retryMaxMilliseconds
				)
				if
					deadline ~= nil
					and dependencies.clock() + delayMilliseconds / 1000 > deadline
				then
					return {
						ok = false,
						attempts = attempt,
						delays = delays,
						deadlineExceeded = true,
					}
				end
				table.insert(delays, delayMilliseconds)
				dependencies.sleep(delayMilliseconds / 1000)
			end
		end
		return {
			ok = false,
			attempts = dependencies.policy.maxRetries + 1,
			delays = delays,
		}
	end

	local function persistProfile(
		userKey: string,
		session: any,
		nextProfile: any,
		deadline: number?
	): any
		local encoded, sizeCode = encodeChecked(nextProfile)
		if encoded == nil then
			return result(false, sizeCode)
		end
		local matched = false
		local retry = updateWithRetry(key(userKey), function(current: any): any
			matched = false
			local migrated = dependencies.migrations:migrate(current)
			if not migrated.ok then
				return current
			end
			local storedProfile = migrated.profile
			if
				storedProfile.session == nil
				or storedProfile.session.token ~= session.token
				or storedProfile.revision ~= session.persistedRevision
			then
				return current
			end
			matched = true
			return encoded
		end, deadline)
		if not retry.ok then
			session.writable = false
			return result(false, dependencies.errors.codes.storageUnavailable, {
				attempts = retry.attempts,
				retryDelaysMilliseconds = retry.delays,
				deadlineExceeded = retry.deadlineExceeded == true,
			})
		elseif not matched then
			session.writable = false
			return result(false, dependencies.errors.codes.sessionConflict, {
				attempts = retry.attempts,
				retryDelaysMilliseconds = retry.delays,
			})
		end
		return result(true, "ok", {
			attempts = retry.attempts,
			retryDelaysMilliseconds = retry.delays,
		})
	end

	function store:state(userKey: string): any
		local session = self.sessions[userKey]
		if session == nil then
			return { ready = false, writable = false }
		end
		return {
			ready = true,
			writable = session.writable and not self.closing,
			revision = session.profile.revision,
			persistedRevision = session.persistedRevision,
			dirty = session.dirty,
		}
	end

	function store:get(userKey: string): any?
		local session = self.sessions[userKey]
		return if session ~= nil then session.profile else nil
	end

	function store:acquire(userKey: string): any
		if self.closing then
			return result(false, dependencies.errors.codes.profileReadOnly)
		elseif self.sessions[userKey] ~= nil then
			return result(false, dependencies.errors.codes.sessionConflict)
		end
		local now = dependencies.clock()
		local token = dependencies.tokenFactory(userKey)
		assert(type(token) == "string" and token ~= "", "P002-STORE-013 token invalid")
		local selectedProfile = nil
		local blockedCode = nil
		local retry = updateWithRetry(key(userKey), function(current: any): any
			selectedProfile = nil
			blockedCode = nil
			local profile
			if current == nil then
				profile = dependencies.schema.newBlank(
					dependencies.currencyIds,
					now,
					dependencies.catalogVersion,
					dependencies.configVersion
				)
			else
				local migrated = dependencies.migrations:migrate(current)
				if not migrated.ok then
					blockedCode = migrated.code
					return current
				end
				profile = migrated.profile
			end
			local existing = profile.session
			if
				existing ~= nil
				and existing.token ~= token
				and now - existing.heartbeatAt < dependencies.policy.sessionExpirySeconds
			then
				blockedCode = dependencies.errors.codes.sessionConflict
				return current
			end
			if existing ~= nil and existing.token ~= token then
				local reconciled, reconciliationCode = dependencies.reconcile(profile)
				if not reconciled then
					blockedCode = reconciliationCode or dependencies.errors.codes.profileReadOnly
					return current
				end
			end
			profile.session = {
				token = token,
				jobId = dependencies.jobId,
				placeVersion = dependencies.placeVersion,
				heartbeatAt = now,
			}
			profile.lastSeenAt = math.max(profile.lastSeenAt, now)
			local encoded, sizeCode = encodeChecked(profile)
			if encoded == nil then
				blockedCode = sizeCode
				return current
			end
			selectedProfile = dependencies.canonical.copy(profile)
			return encoded
		end)
		if not retry.ok then
			return result(false, dependencies.errors.codes.storageUnavailable, {
				attempts = retry.attempts,
				retryDelaysMilliseconds = retry.delays,
			})
		elseif blockedCode ~= nil then
			return result(false, blockedCode)
		elseif selectedProfile == nil then
			return result(false, dependencies.errors.codes.internalFailClosed)
		end
		self.sessions[userKey] = {
			profile = selectedProfile,
			token = token,
			persistedRevision = selectedProfile.revision,
			writable = true,
			dirty = false,
		}
		return result(true, "ok", {
			profile = dependencies.canonical.copy(selectedProfile),
			attempts = retry.attempts,
			retryDelaysMilliseconds = retry.delays,
			sessionFingerprint = dependencies.canonical.encode({
				jobId = dependencies.jobId,
				placeVersion = dependencies.placeVersion,
				heartbeatAt = now,
			}),
		})
	end

	function store:heartbeat(userKey: string): any
		local session = self.sessions[userKey]
		if session == nil then
			return result(false, dependencies.errors.codes.profileNotReady)
		end
		if not session.writable then
			return result(false, dependencies.errors.codes.profileReadOnly)
		end
		local now = dependencies.clock()
		local matched = false
		local retry = updateWithRetry(key(userKey), function(current: any): any
			matched = false
			local migrated = dependencies.migrations:migrate(current)
			if not migrated.ok then
				return current
			end
			local profile = migrated.profile
			if profile.session == nil or profile.session.token ~= session.token then
				return current
			end
			profile.session.heartbeatAt = now
			matched = true
			return dependencies.codec.encode(dependencies.schema, dependencies.canonical, profile)
		end)
		if not retry.ok then
			session.writable = false
			return result(false, dependencies.errors.codes.storageUnavailable, {
				attempts = retry.attempts,
				retryDelaysMilliseconds = retry.delays,
			})
		elseif not matched then
			session.writable = false
			return result(false, dependencies.errors.codes.sessionConflict)
		end
		session.profile.session.heartbeatAt = now
		return result(true, "ok", {
			attempts = retry.attempts,
			retryDelaysMilliseconds = retry.delays,
		})
	end

	function store:commit(userKey: string, expectedRevision: number, nextProfile: any): any
		local session = self.sessions[userKey]
		if session == nil then
			return result(false, dependencies.errors.codes.profileNotReady)
		elseif self.closing or not session.writable then
			return result(false, dependencies.errors.codes.profileReadOnly)
		elseif expectedRevision ~= session.profile.revision then
			return result(false, dependencies.errors.codes.staleState)
		end
		if nextProfile.revision ~= expectedRevision + 1 then
			return result(false, dependencies.errors.codes.operationInvalid)
		end
		nextProfile.session = dependencies.canonical.copy(session.profile.session)
		local persisted = persistProfile(userKey, session, nextProfile)
		if not persisted.ok then
			return persisted
		end
		session.profile = dependencies.canonical.copy(nextProfile)
		session.persistedRevision = nextProfile.revision
		session.dirty = false
		return result(true, "ok", {
			profile = dependencies.canonical.copy(nextProfile),
			attempts = persisted.attempts,
			retryDelaysMilliseconds = persisted.retryDelaysMilliseconds,
		})
	end

	function store:stage(userKey: string, expectedRevision: number, nextProfile: any): any
		local session = self.sessions[userKey]
		if session == nil then
			return result(false, dependencies.errors.codes.profileNotReady)
		elseif self.closing or not session.writable then
			return result(false, dependencies.errors.codes.profileReadOnly)
		elseif expectedRevision ~= session.profile.revision then
			return result(false, dependencies.errors.codes.staleState)
		elseif nextProfile.revision ~= expectedRevision + 1 then
			return result(false, dependencies.errors.codes.operationInvalid)
		end
		nextProfile.session = dependencies.canonical.copy(session.profile.session)
		local encoded, sizeCode = encodeChecked(nextProfile)
		if encoded == nil then
			return result(false, sizeCode)
		end
		assert(encoded ~= nil, "P002-STORE-017 staged profile missing")
		session.profile = dependencies.canonical.copy(nextProfile)
		session.dirty = true
		session.dirtySince = session.dirtySince or dependencies.clock()
		return result(true, "ok", { profile = dependencies.canonical.copy(nextProfile) })
	end

	function store:flush(userKey: string, force: boolean?, deadline: number?): any
		local session = self.sessions[userKey]
		if session == nil then
			return result(false, dependencies.errors.codes.profileNotReady)
		elseif not session.writable then
			return result(false, dependencies.errors.codes.profileReadOnly)
		elseif not session.dirty then
			return result(true, "ok", { flushed = false })
		elseif
			force ~= true
			and dependencies.clock() - session.dirtySince < dependencies.policy.dirtySaveSeconds
		then
			return result(true, "ok", { flushed = false, pending = true })
		end
		local persisted = persistProfile(userKey, session, session.profile, deadline)
		if not persisted.ok then
			return persisted
		end
		session.persistedRevision = session.profile.revision
		session.dirty = false
		session.dirtySince = nil
		return result(true, "ok", {
			flushed = true,
			attempts = persisted.attempts,
			retryDelaysMilliseconds = persisted.retryDelaysMilliseconds,
		})
	end

	function store:release(userKey: string, deadline: number?): any
		local session = self.sessions[userKey]
		if session == nil then
			return result(true, "ok")
		end
		if session.dirty then
			local flushed = self:flush(userKey, true, deadline)
			if not flushed.ok then
				return flushed
			end
		end
		local matched = false
		local retry = updateWithRetry(key(userKey), function(current: any): any
			matched = false
			local migrated = dependencies.migrations:migrate(current)
			if not migrated.ok then
				return current
			end
			local profile = migrated.profile
			if profile.session == nil or profile.session.token ~= session.token then
				return current
			end
			profile.session = nil
			matched = true
			return dependencies.codec.encode(dependencies.schema, dependencies.canonical, profile)
		end, deadline)
		if not retry.ok then
			session.writable = false
			return result(false, dependencies.errors.codes.storageUnavailable, {
				attempts = retry.attempts,
				retryDelaysMilliseconds = retry.delays,
				deadlineExceeded = retry.deadlineExceeded == true,
			})
		elseif not matched then
			session.writable = false
			return result(false, dependencies.errors.codes.sessionConflict)
		end
		self.sessions[userKey] = nil
		return result(true, "ok", {
			attempts = retry.attempts,
			retryDelaysMilliseconds = retry.delays,
		})
	end

	function store:beginShutdown()
		self.closing = true
	end

	function store:shutdown(deadline: number?): any
		self:beginShutdown()
		local shutdownDeadline = deadline
			or dependencies.clock() + dependencies.policy.shutdownDeadlineSeconds
		local userKeys = {}
		for userKey in self.sessions do
			table.insert(userKeys, userKey)
		end
		table.sort(userKeys)
		local outcomes = {}
		local released = 0
		local deadlineExceeded = false
		for _, userKey in userKeys do
			local outcome
			if dependencies.clock() >= shutdownDeadline then
				deadlineExceeded = true
				outcome = result(false, dependencies.errors.codes.storageUnavailable, {
					deadlineExceeded = true,
				})
			else
				outcome = self:release(userKey, shutdownDeadline)
			end
			deadlineExceeded = deadlineExceeded or outcome.deadlineExceeded == true
			outcomes[userKey] = outcome
			if outcome.ok then
				released += 1
			end
		end
		return {
			ok = released == #userKeys,
			code = if released == #userKeys
				then "ok"
				else dependencies.errors.codes.storageUnavailable,
			released = released,
			total = #userKeys,
			remaining = #userKeys - released,
			deadlineExceeded = deadlineExceeded or dependencies.clock() >= shutdownDeadline,
			outcomes = outcomes,
		}
	end

	return store
end

return table.freeze(ProfileStore)
