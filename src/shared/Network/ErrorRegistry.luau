--!strict

local ErrorRegistry = {}

ErrorRegistry.version = 1
ErrorRegistry.codes = table.freeze({
	envelopeInvalid = "network.envelope_invalid",
	versionUnsupported = "network.version_unsupported",
	requestIdInvalid = "network.request_id_invalid",
	actionUnknown = "network.action_unknown",
	payloadInvalid = "network.payload_invalid",
	payloadTooDeep = "network.payload_too_deep",
	payloadTooLarge = "network.payload_too_large",
	payloadTooComplex = "network.payload_too_complex",
	unknownField = "network.unknown_field",
	typeInvalid = "network.type_invalid",
	boundsInvalid = "network.bounds_invalid",
	numberNonfinite = "network.number_nonfinite",
	rateLimited = "network.rate_limited",
	profileNotReady = "profile.not_ready",
	profileReadOnly = "profile.read_only",
	profileMalformed = "profile.malformed",
	profileUnsupportedSchema = "profile.unsupported_schema",
	profileTooLarge = "profile.too_large",
	permissionDenied = "permission.denied",
	foreignInstance = "ownership.foreign_instance",
	instanceNotFound = "ownership.instance_not_found",
	instanceLocked = "ownership.instance_locked",
	removalProtected = "ownership.removal_protected",
	duplicateInstance = "ownership.duplicate_instance",
	slotInvalid = "deck.slot_invalid",
	slotMismatch = "deck.slot_mismatch",
	slotOccupied = "deck.slot_occupied",
	contentDisabled = "content.disabled",
	uidUnavailable = "inventory.uid_unavailable",
	starterAlreadyClaimed = "pack.starter_already_claimed",
	packInvalid = "pack.invalid",
	insufficientCurrency = "pack.insufficient_currency",
	packChoiceInvalid = "pack.choice_invalid",
	packChoiceUnavailable = "pack.choice_unavailable",
	gradeAtCap = "progression.grade_at_cap",
	traitReplacementRequired = "progression.trait_replacement_required",
	traitUnchanged = "progression.trait_unchanged",
	traitUnset = "progression.trait_unset",
	formationInvalid = "formation.invalid",
	formationNoMatch = "formation.no_match",
	staleState = "state.stale",
	replayConflict = "request.replay_conflict",
	operationInvalid = "transaction.invalid_operation",
	operationApplyFailed = "transaction.apply_failed",
	operationResultInvalid = "transaction.result_invalid",
	operationBusy = "transaction.busy",
	sessionConflict = "session.conflict",
	storageUnavailable = "storage.unavailable",
	featureUnavailable = "feature.unavailable",
	internalFailClosed = "internal.fail_closed",
})

local declared = {}
for _, code in ErrorRegistry.codes do
	assert(declared[code] == nil, "P002-ERROR-001 duplicate error code")
	assert(code:match("^[a-z][a-z0-9_.]+$") ~= nil, "P002-ERROR-002 malformed error code")
	declared[code] = true
end

function ErrorRegistry.isDeclared(code: string): boolean
	return declared[code] == true
end

return table.freeze(ErrorRegistry)
