--!strict

local ProfilePolicy = {
	version = 1,
	currentSchemaVersion = 1,
	warningBytes = 1000000,
	blockingBytes = 1500000,
	heartbeatSeconds = 30,
	sessionExpirySeconds = 120,
	dirtySaveSeconds = 30,
	immediateSaveTimeoutSeconds = 10,
	shutdownDeadlineSeconds = 25,
	maxRetries = 5,
	retryBaseMilliseconds = 250,
	retryMaxMilliseconds = 4000,
	receiptRetention = 256,
}

function ProfilePolicy.classifyBytes(bytes: number): string
	assert(bytes >= 0 and bytes % 1 == 0, "P002-POLICY-001 byte count invalid")
	if bytes > ProfilePolicy.blockingBytes then
		return "blocked"
	elseif bytes >= ProfilePolicy.warningBytes then
		return "warning"
	end
	return "healthy"
end

return table.freeze(ProfilePolicy)
