--!strict

local TransactionService = {}

local function failure(code: string): any
	return {
		ok = false,
		code = code,
	}
end

function TransactionService.new(dependencies: any): any
	assert(dependencies.profileStore ~= nil, "P002-TRANSACTION-001 profile store missing")
	assert(dependencies.canonical ~= nil, "P002-TRANSACTION-002 canonical codec missing")
	assert(dependencies.policy ~= nil, "P002-TRANSACTION-003 policy missing")
	assert(dependencies.errors ~= nil, "P002-TRANSACTION-004 errors missing")
	assert(type(dependencies.clock) == "function", "P002-TRANSACTION-005 clock missing")
	assert(type(dependencies.sleep) == "function", "P002-TRANSACTION-006 sleep missing")

	local service = {
		active = {},
		closing = false,
	}

	local function inject(stage: string, operation: any?): boolean
		if dependencies.failureInjector == nil then
			return true
		end
		local operationTable = if type(operation) == "table" then operation else nil
		local ok, shouldContinue = pcall(dependencies.failureInjector, stage, {
			operationId = if operationTable ~= nil then operationTable.id else nil,
			kind = if operationTable ~= nil then operationTable.kind else nil,
			expectedRevision = if operationTable ~= nil
				then operationTable.expectedRevision
				else nil,
		})
		return ok and shouldContinue ~= false
	end

	function service:execute(userKey: string, operation: any): any
		if self.closing then
			return failure(dependencies.errors.codes.profileReadOnly)
		elseif not inject("before_validation", operation) then
			return failure(dependencies.errors.codes.internalFailClosed)
		end
		if
			type(operation) ~= "table"
			or type(operation.id) ~= "string"
			or operation.id == ""
			or type(operation.kind) ~= "string"
			or operation.kind == ""
			or type(operation.payload) ~= "table"
			or type(operation.expectedRevision) ~= "number"
			or operation.expectedRevision % 1 ~= 0
			or type(operation.apply) ~= "function"
		then
			return failure(dependencies.errors.codes.operationInvalid)
		end
		if self.active[userKey] then
			return failure(dependencies.errors.codes.operationBusy)
		end
		local profile = dependencies.profileStore:get(userKey)
		if profile == nil then
			return failure(dependencies.errors.codes.profileNotReady)
		end
		local fingerprint = dependencies.canonical.encode({
			kind = operation.kind,
			payload = operation.payload,
		})
		local receipt = profile.processedOperations[operation.id]
		if receipt ~= nil then
			if receipt.fingerprint ~= fingerprint then
				return failure(dependencies.errors.codes.replayConflict)
			end
			local replayed = dependencies.canonical.copy(receipt.result)
			replayed.replayed = true
			return replayed
		end
		local barrier = profile.replayBarrier[operation.id]
		if barrier ~= nil then
			if barrier.fingerprint ~= fingerprint then
				return failure(dependencies.errors.codes.replayConflict)
			end
			return {
				ok = true,
				code = barrier.code,
				revision = barrier.revision,
				resultReference = barrier.resultReference,
				replayed = true,
				compacted = true,
			}
		end
		if operation.expectedRevision ~= profile.revision then
			return failure(dependencies.errors.codes.staleState)
		end
		self.active[userKey] = true
		if not inject("before_apply", operation) then
			self.active[userKey] = nil
			return failure(dependencies.errors.codes.internalFailClosed)
		end
		local nextProfile = dependencies.canonical.copy(profile)
		local applyOk, applyResult = pcall(operation.apply, nextProfile)
		if not applyOk then
			self.active[userKey] = nil
			return failure(dependencies.errors.codes.operationApplyFailed)
		elseif
			type(applyResult) ~= "table"
			or type(applyResult.ok) ~= "boolean"
			or type(applyResult.code) ~= "string"
		then
			self.active[userKey] = nil
			return failure(dependencies.errors.codes.operationResultInvalid)
		end
		if not applyResult.ok then
			self.active[userKey] = nil
			return applyResult
		end
		if not inject("after_apply", operation) then
			self.active[userKey] = nil
			return failure(dependencies.errors.codes.internalFailClosed)
		end
		nextProfile.revision = profile.revision + 1
		applyResult.revision = nextProfile.revision
		applyResult.replayed = false
		if not inject("before_receipt", operation) then
			self.active[userKey] = nil
			return failure(dependencies.errors.codes.internalFailClosed)
		end
		local resultCopyOk, storedResult = pcall(dependencies.canonical.copy, applyResult)
		if not resultCopyOk or type(storedResult) ~= "table" then
			self.active[userKey] = nil
			return failure(dependencies.errors.codes.operationResultInvalid)
		end
		local resultReference = operation.resultReference or operation.id
		nextProfile.processedOperations[operation.id] = {
			version = 1,
			kind = operation.kind,
			fingerprint = fingerprint,
			result = storedResult,
			resultReference = resultReference,
		}
		table.insert(nextProfile.operationOrder, operation.id)
		nextProfile.replayBarrier[operation.id] = {
			version = 1,
			kind = operation.kind,
			fingerprint = fingerprint,
			code = applyResult.code,
			revision = nextProfile.revision,
			resultReference = resultReference,
		}
		while #nextProfile.operationOrder > dependencies.policy.receiptRetention do
			local compactedId = table.remove(nextProfile.operationOrder, 1)
			nextProfile.processedOperations[compactedId] = nil
		end
		if not inject("before_commit", operation) then
			self.active[userKey] = nil
			return failure(dependencies.errors.codes.internalFailClosed)
		end
		local commitOk, committed = pcall(function(): any
			return dependencies.profileStore:commit(userKey, profile.revision, nextProfile)
		end)
		self.active[userKey] = nil
		if not commitOk or type(committed) ~= "table" or type(committed.ok) ~= "boolean" then
			return failure(dependencies.errors.codes.internalFailClosed)
		elseif not committed.ok then
			return committed
		end
		if not inject("after_commit", operation) or not inject("before_response", operation) then
			return {
				ok = false,
				code = dependencies.errors.codes.internalFailClosed,
				committed = true,
				operationId = operation.id,
			}
		end
		return applyResult
	end

	function service:beginShutdown()
		self.closing = true
	end

	function service:drain(timeoutSeconds: number): any
		assert(timeoutSeconds >= 0, "P002-TRANSACTION-007 timeout invalid")
		self:beginShutdown()
		local deadline = dependencies.clock() + timeoutSeconds
		while next(self.active) ~= nil and dependencies.clock() < deadline do
			dependencies.sleep(0.05)
		end
		local remaining = 0
		for _ in self.active do
			remaining += 1
		end
		return {
			ok = remaining == 0,
			code = if remaining == 0 then "ok" else dependencies.errors.codes.storageUnavailable,
			remaining = remaining,
		}
	end

	return service
end

return table.freeze(TransactionService)
