--!strict

local ProfileSchema = {}

ProfileSchema.version = 1

local requiredFields = {
	"schemaVersion",
	"catalogVersion",
	"configVersion",
	"revision",
	"createdAt",
	"lastSeenAt",
	"activeSeconds",
	"currencies",
	"cards",
	"jokers",
	"arcanaStacks",
	"reservedSouls",
	"activeDeck",
	"activeJokers",
	"discovery",
	"bestRecords",
	"pity",
	"pendingPacks",
	"boosts",
	"daily",
	"tutorial",
	"tradeHistory",
	"processedOperations",
	"operationOrder",
	"replayBarrier",
	"settings",
	"moderation",
}

local allowedFields = {
	activeSoul = true,
	session = true,
}
for _, field in requiredFields do
	allowedFields[field] = true
end

local function assertInteger(value: any, minimum: number, id: string)
	assert(type(value) == "number" and value == value and value % 1 == 0 and value >= minimum, id)
end

local function assertString(value: any, id: string)
	assert(type(value) == "string" and value ~= "", id)
end

local function assertOnlyFields(value: any, fields: { [string]: boolean }, id: string)
	assert(type(value) == "table", id)
	for field in value do
		assert(fields[field] == true, id)
	end
end

local function validateDenseStringArray(
	value: any,
	maximum: number?,
	id: string
): { [string]: boolean }
	assert(type(value) == "table", id)
	local length = #value
	local count = 0
	local seen = {}
	for index, child in value do
		assert(type(index) == "number" and index % 1 == 0 and index >= 1 and index <= length, id)
		assertString(child, id)
		assert(not seen[child], id)
		seen[child] = true
		count += 1
	end
	assert(count == length and (maximum == nil or length <= maximum), id)
	return seen
end

local function validateIntegerMap(value: any, id: string)
	assert(type(value) == "table", id)
	for key, count in value do
		assertString(key, id)
		assertInteger(count, 0, id)
	end
end

local function validateBooleanMap(value: any, id: string)
	assert(type(value) == "table", id)
	for key, enabled in value do
		assertString(key, id)
		assert(enabled == true, id)
	end
end

local function validateFlags(value: any, id: string)
	assertOnlyFields(value, { favorite = true, wishlist = true }, id)
	assert(type(value.favorite) == "boolean", id)
	assert(type(value.wishlist) == "boolean", id)
end

local function validateLocks(value: any, id: string)
	assert(type(value) == "table", id)
	for lockId, active in value do
		assertString(lockId, id)
		assert(type(active) == "boolean", id)
	end
end

local function validateProvenance(value: any, id: string)
	assertOnlyFields(value, {
		originType = true,
		originId = true,
		createdAt = true,
		instanceVersion = true,
	}, id)
	assertString(value.originType, id)
	assertString(value.originId, id)
	assertInteger(value.createdAt, 0, id)
	assertInteger(value.instanceVersion, 1, id)
end

local function validateReceiptValue(value: any, depth: number, state: any)
	assert(depth <= 8, "P002-PROFILE-114 receipt result too deep")
	state.nodes += 1
	assert(state.nodes <= 4096, "P002-PROFILE-115 receipt result too complex")
	local valueType = type(value)
	if valueType == "nil" or valueType == "boolean" then
		return
	elseif valueType == "number" then
		assert(
			value == value and value ~= math.huge and value ~= -math.huge,
			"P002-PROFILE-116 receipt result number invalid"
		)
		return
	elseif valueType == "string" then
		assert(#value <= 4096, "P002-PROFILE-117 receipt result string too large")
		return
	end
	assert(valueType == "table", "P002-PROFILE-118 receipt result type invalid")
	assert(not state.seen[value], "P002-PROFILE-119 receipt result cycle")
	state.seen[value] = true
	for key, child in value do
		if type(key) == "string" then
			assert(key ~= "" and #key <= 128, "P002-PROFILE-120 receipt result key invalid")
		else
			assert(
				type(key) == "number" and key % 1 == 0 and key >= 1,
				"P002-PROFILE-120 receipt result key invalid"
			)
		end
		validateReceiptValue(child, depth + 1, state)
	end
	state.seen[value] = nil
end

function ProfileSchema.newBlank(
	currencyIds: { string },
	now: number,
	catalogVersion: number,
	configVersion: number
): any
	assertInteger(now, 0, "P002-PROFILE-001 timestamp invalid")
	assertInteger(catalogVersion, 1, "P002-PROFILE-002 catalog version invalid")
	assertInteger(configVersion, 1, "P002-PROFILE-003 config version invalid")
	local currencies = {}
	for _, currencyId in currencyIds do
		assert(
			type(currencyId) == "string" and currencyId ~= "",
			"P002-PROFILE-004 currency id invalid"
		)
		assert(currencies[currencyId] == nil, "P002-PROFILE-005 duplicate currency id")
		currencies[currencyId] = 0
	end
	return {
		schemaVersion = ProfileSchema.version,
		catalogVersion = catalogVersion,
		configVersion = configVersion,
		revision = 0,
		createdAt = now,
		lastSeenAt = now,
		activeSeconds = 0,
		currencies = currencies,
		cards = {},
		jokers = {},
		arcanaStacks = {},
		reservedSouls = {},
		activeDeck = {},
		activeJokers = {},
		activeSoul = nil,
		discovery = {
			forms = {},
			jokers = {},
			arcana = {},
			souls = {},
		},
		bestRecords = {},
		pity = {},
		pendingPacks = {},
		boosts = {},
		daily = {
			dayKey = "",
			friendClashRewards = 0,
		},
		tutorial = {
			stepId = "not_started",
			completed = false,
			starterPackClaimed = false,
		},
		tradeHistory = {},
		processedOperations = {},
		operationOrder = {},
		replayBarrier = {},
		settings = {
			masterVolume = 100,
			musicVolume = 100,
			effectsVolume = 100,
			revealSound = true,
			reducedMotion = false,
			reducedFlash = false,
			lowGraphics = false,
			packAnimationSpeed = "normal",
			autoReveal = false,
			autoEquip = false,
			tradeRequests = true,
			duelRequests = true,
			rarePullAnnouncements = true,
			colorAssistance = false,
			uiScale = 100,
			tutorialReplay = false,
		},
		moderation = {
			quarantined = false,
			reasonCode = "",
		},
		session = nil,
	}
end

function ProfileSchema.validate(profile: any): any
	assert(type(profile) == "table", "P002-PROFILE-006 profile must be table")
	for field in profile do
		assert(allowedFields[field] == true, "P002-PROFILE-029 unknown field")
	end
	for _, field in requiredFields do
		assert(profile[field] ~= nil, "P002-PROFILE-007 required field missing")
	end
	assertInteger(profile.schemaVersion, 1, "P002-PROFILE-008 schema version invalid")
	assert(profile.schemaVersion == ProfileSchema.version, "P002-PROFILE-009 schema unsupported")
	assertInteger(profile.catalogVersion, 1, "P002-PROFILE-010 catalog version invalid")
	assertInteger(profile.configVersion, 1, "P002-PROFILE-011 config version invalid")
	assertInteger(profile.revision, 0, "P002-PROFILE-012 revision invalid")
	assertInteger(profile.createdAt, 0, "P002-PROFILE-013 created timestamp invalid")
	assertInteger(profile.lastSeenAt, 0, "P002-PROFILE-014 seen timestamp invalid")
	assert(profile.lastSeenAt >= profile.createdAt, "P002-PROFILE-015 timestamp order invalid")
	assertInteger(profile.activeSeconds, 0, "P002-PROFILE-016 active seconds invalid")
	for _, field in
		{
			"currencies",
			"cards",
			"jokers",
			"arcanaStacks",
			"reservedSouls",
			"activeDeck",
			"activeJokers",
			"discovery",
			"bestRecords",
			"pity",
			"pendingPacks",
			"boosts",
			"daily",
			"tutorial",
			"tradeHistory",
			"processedOperations",
			"operationOrder",
			"replayBarrier",
			"settings",
			"moderation",
		}
	do
		assert(type(profile[field]) == "table", "P002-PROFILE-017 table field invalid")
	end
	for currencyId, balance in profile.currencies do
		assert(
			type(currencyId) == "string" and currencyId ~= "",
			"P002-PROFILE-018 currency id invalid"
		)
		assertInteger(balance, 0, "P002-PROFILE-019 currency balance invalid")
	end
	assert(type(profile.discovery.forms) == "table", "P002-PROFILE-020 form discovery invalid")
	assert(type(profile.discovery.jokers) == "table", "P002-PROFILE-021 joker discovery invalid")
	assert(type(profile.discovery.arcana) == "table", "P002-PROFILE-022 arcana discovery invalid")
	assert(type(profile.discovery.souls) == "table", "P002-PROFILE-023 soul discovery invalid")
	validateBooleanMap(profile.discovery.forms, "P002-PROFILE-030 form discovery invalid")
	validateBooleanMap(profile.discovery.jokers, "P002-PROFILE-031 joker discovery invalid")
	validateBooleanMap(profile.discovery.arcana, "P002-PROFILE-032 arcana discovery invalid")
	validateBooleanMap(profile.discovery.souls, "P002-PROFILE-033 soul discovery invalid")
	assertOnlyFields(profile.discovery, {
		forms = true,
		jokers = true,
		arcana = true,
		souls = true,
	}, "P002-PROFILE-084 discovery field invalid")
	validateIntegerMap(profile.arcanaStacks, "P002-PROFILE-085 arcana stack invalid")
	validateIntegerMap(profile.pity, "P002-PROFILE-086 pity invalid")
	for uid, card in profile.cards do
		assertString(uid, "P002-PROFILE-034 card uid invalid")
		assert(type(card) == "table" and card.uid == uid, "P002-PROFILE-035 card map invalid")
		assertOnlyFields(card, {
			uid = true,
			ownerUserId = true,
			identityId = true,
			deckSetId = true,
			rankId = true,
			suitId = true,
			slotKey = true,
			editionId = true,
			gradeId = true,
			powerTierId = true,
			traitId = true,
			gradeExperience = true,
			flags = true,
			locks = true,
			provenance = true,
		}, "P002-PROFILE-087 card field unknown")
		assertInteger(card.ownerUserId, 1, "P002-PROFILE-036 card owner invalid")
		for _, field in
			{
				"identityId",
				"deckSetId",
				"rankId",
				"suitId",
				"slotKey",
				"editionId",
				"gradeId",
				"powerTierId",
			}
		do
			assertString(card[field], "P002-PROFILE-037 card field invalid")
		end
		assert(
			card.slotKey == card.rankId .. ":" .. card.suitId,
			"P002-PROFILE-131 card slot identity mismatch"
		)
		assert(
			card.identityId == card.deckSetId .. ":" .. card.slotKey,
			"P002-PROFILE-132 card content identity mismatch"
		)
		if card.traitId ~= nil then
			assertString(card.traitId, "P002-PROFILE-038 card trait invalid")
		end
		assertInteger(card.gradeExperience, 0, "P002-PROFILE-039 card experience invalid")
		validateFlags(card.flags, "P002-PROFILE-040 card flags invalid")
		validateLocks(card.locks, "P002-PROFILE-041 card locks invalid")
		validateProvenance(card.provenance, "P002-PROFILE-042 card provenance invalid")
	end
	for uid, joker in profile.jokers do
		assertString(uid, "P002-PROFILE-043 joker uid invalid")
		assert(type(joker) == "table" and joker.uid == uid, "P002-PROFILE-044 joker map invalid")
		assertOnlyFields(joker, {
			uid = true,
			ownerUserId = true,
			jokerId = true,
			flags = true,
			locks = true,
			provenance = true,
		}, "P002-PROFILE-088 joker field unknown")
		assertInteger(joker.ownerUserId, 1, "P002-PROFILE-045 joker owner invalid")
		assertString(joker.jokerId, "P002-PROFILE-046 joker id invalid")
		validateFlags(joker.flags, "P002-PROFILE-047 joker flags invalid")
		validateLocks(joker.locks, "P002-PROFILE-048 joker locks invalid")
		validateProvenance(joker.provenance, "P002-PROFILE-049 joker provenance invalid")
	end
	local activeUids = {}
	for slotKey, uid in profile.activeDeck do
		assertString(slotKey, "P002-PROFILE-050 deck slot invalid")
		assertString(uid, "P002-PROFILE-051 deck uid invalid")
		assert(not activeUids[uid], "P002-PROFILE-052 duplicate deck uid")
		assert(profile.cards[uid] ~= nil, "P002-PROFILE-089 deck card missing")
		assert(profile.cards[uid].slotKey == slotKey, "P002-PROFILE-090 deck slot mismatch")
		activeUids[uid] = true
	end
	local activeJokers =
		validateDenseStringArray(profile.activeJokers, 5, "P002-PROFILE-091 active jokers invalid")
	for uid in activeJokers do
		assert(profile.jokers[uid] ~= nil, "P002-PROFILE-092 active joker missing")
	end
	if profile.activeSoul ~= nil then
		assertString(profile.activeSoul, "P002-PROFILE-093 active soul invalid")
		assert(
			profile.reservedSouls[profile.activeSoul] ~= nil,
			"P002-PROFILE-094 active soul missing"
		)
	end
	for uid, soul in profile.reservedSouls do
		assertString(uid, "P002-PROFILE-095 reserved soul uid invalid")
		assert(type(soul) == "table", "P002-PROFILE-096 reserved soul invalid")
	end
	for recordId, value in profile.bestRecords do
		assertString(recordId, "P002-PROFILE-053 record id invalid")
		assert(
			type(value) == "number" and value == value and value >= 0,
			"P002-PROFILE-054 record invalid"
		)
	end
	local pendingCardOwners = {}
	for operationId, pending in profile.pendingPacks do
		assertString(operationId, "P002-PROFILE-055 pending operation invalid")
		assert(type(pending) == "table", "P002-PROFILE-056 pending pack invalid")
		assertOnlyFields(pending, {
			state = true,
			packId = true,
			catalogVersion = true,
			cardInstanceIds = true,
			resultReference = true,
			offerIds = true,
			choiceIndex = true,
			choiceId = true,
			grantedJokerInstanceId = true,
			grantedArcanaId = true,
		}, "P002-PROFILE-097 pending field invalid")
		assert(
			pending.state == "committed"
				or pending.state == "acknowledged"
				or pending.state == "revealed"
				or pending.state == "claimed",
			"P002-PROFILE-057 pending state invalid"
		)
		assertString(pending.packId, "P002-PROFILE-058 pending pack id invalid")
		assertInteger(pending.catalogVersion, 1, "P002-PROFILE-059 pending catalog invalid")
		local pendingUids = validateDenseStringArray(
			pending.cardInstanceIds,
			nil,
			"P002-PROFILE-061 pending card uid invalid"
		)
		for uid in pendingUids do
			assert(profile.cards[uid] ~= nil, "P002-PROFILE-098 pending card missing")
			assert(pendingCardOwners[uid] == nil, "P002-PROFILE-113 duplicate pending card")
			pendingCardOwners[uid] = operationId
		end
		assertString(pending.resultReference, "P002-PROFILE-062 pending result invalid")
		if pending.offerIds ~= nil then
			assert(
				pending.packId == "joker" or pending.packId == "arcana",
				"P003-PACK-028 pending offer pack invalid"
			)
			local offerIds = validateDenseStringArray(
				pending.offerIds,
				3,
				"P003-PACK-015 pending offer ids invalid"
			)
			assert(#pending.offerIds == 3, "P003-PACK-016 pending offer count invalid")
			if pending.choiceIndex ~= nil then
				assertInteger(pending.choiceIndex, 1, "P003-PACK-017 pending choice index invalid")
				assert(
					pending.choiceIndex <= #pending.offerIds,
					"P003-PACK-018 pending choice index invalid"
				)
			end
			if pending.choiceId ~= nil then
				assertString(pending.choiceId, "P003-PACK-019 pending choice id invalid")
				assert(
					offerIds[pending.choiceId] == true,
					"P003-PACK-020 pending choice id invalid"
				)
			end
			assert(
				(pending.choiceIndex == nil) == (pending.choiceId == nil),
				"P003-PACK-027 pending choice fields mismatch"
			)
			if pending.state == "claimed" then
				assert(
					pending.choiceIndex ~= nil and pending.choiceId ~= nil,
					"P003-PACK-021 claimed choice missing"
				)
			end
		else
			assert(
				pending.state ~= "claimed"
					and pending.choiceIndex == nil
					and pending.choiceId == nil
					and pending.grantedJokerInstanceId == nil
					and pending.grantedArcanaId == nil,
				"P003-PACK-029 non offer pending state invalid"
			)
		end
		if pending.grantedJokerInstanceId ~= nil then
			assertString(pending.grantedJokerInstanceId, "P003-PACK-023 granted joker invalid")
			assert(
				profile.jokers[pending.grantedJokerInstanceId] ~= nil,
				"P003-PACK-024 granted joker missing"
			)
		end
		if pending.grantedArcanaId ~= nil then
			assertString(pending.grantedArcanaId, "P003-PACK-025 granted arcana invalid")
			assert(pending.offerIds ~= nil, "P003-PACK-026 granted arcana offers missing")
		end
	end
	for operationId, receipt in profile.processedOperations do
		assertString(operationId, "P002-PROFILE-063 receipt id invalid")
		assert(type(receipt) == "table", "P002-PROFILE-064 receipt invalid")
		assertOnlyFields(receipt, {
			version = true,
			kind = true,
			fingerprint = true,
			result = true,
			resultReference = true,
		}, "P002-PROFILE-099 receipt field invalid")
		assertInteger(receipt.version, 1, "P002-PROFILE-121 receipt version invalid")
		assert(receipt.version == 1, "P002-PROFILE-121 receipt version invalid")
		assertString(receipt.kind, "P002-PROFILE-122 receipt kind invalid")
		assertString(receipt.fingerprint, "P002-PROFILE-065 fingerprint invalid")
		assertString(receipt.resultReference, "P002-PROFILE-123 receipt reference invalid")
		assert(type(receipt.result) == "table", "P002-PROFILE-066 receipt result invalid")
		assert(receipt.result.ok == true, "P002-PROFILE-100 receipt result state invalid")
		assertString(receipt.result.code, "P002-PROFILE-101 receipt result code invalid")
		assertInteger(receipt.result.revision, 1, "P002-PROFILE-124 receipt revision invalid")
		validateReceiptValue(receipt.result, 1, { nodes = 0, seen = {} })
	end
	local orderedOperations = validateDenseStringArray(
		profile.operationOrder,
		256,
		"P002-PROFILE-067 operation order invalid"
	)
	for operationId in orderedOperations do
		assert(
			profile.processedOperations[operationId] ~= nil,
			"P002-PROFILE-069 ordered receipt missing"
		)
	end
	for operationId in profile.processedOperations do
		assert(orderedOperations[operationId], "P002-PROFILE-125 unordered receipt")
	end
	for operationId, barrier in profile.replayBarrier do
		assertString(operationId, "P002-PROFILE-070 barrier id invalid")
		assert(type(barrier) == "table", "P002-PROFILE-071 barrier invalid")
		assertOnlyFields(barrier, {
			version = true,
			kind = true,
			fingerprint = true,
			code = true,
			revision = true,
			resultReference = true,
		}, "P002-PROFILE-102 barrier field invalid")
		assertInteger(barrier.version, 1, "P002-PROFILE-126 barrier version invalid")
		assert(barrier.version == 1, "P002-PROFILE-126 barrier version invalid")
		assertString(barrier.kind, "P002-PROFILE-127 barrier kind invalid")
		assertString(barrier.fingerprint, "P002-PROFILE-072 barrier fingerprint invalid")
		assertString(barrier.code, "P002-PROFILE-073 barrier code invalid")
		assertInteger(barrier.revision, 1, "P002-PROFILE-074 barrier revision invalid")
		assert(barrier.revision <= profile.revision, "P002-PROFILE-128 barrier revision ahead")
		assertString(barrier.resultReference, "P002-PROFILE-075 barrier result invalid")
		local receipt = profile.processedOperations[operationId]
		if receipt ~= nil then
			assert(
				receipt.version == barrier.version
					and receipt.kind == barrier.kind
					and receipt.fingerprint == barrier.fingerprint
					and receipt.result.revision == barrier.revision
					and receipt.resultReference == barrier.resultReference,
				"P002-PROFILE-129 receipt barrier mismatch"
			)
		end
	end
	for operationId in profile.processedOperations do
		assert(
			profile.replayBarrier[operationId] ~= nil,
			"P002-PROFILE-130 receipt barrier missing"
		)
	end
	assertOnlyFields(profile.settings, {
		masterVolume = true,
		musicVolume = true,
		effectsVolume = true,
		revealSound = true,
		reducedMotion = true,
		reducedFlash = true,
		lowGraphics = true,
		packAnimationSpeed = true,
		autoReveal = true,
		autoEquip = true,
		tradeRequests = true,
		duelRequests = true,
		rarePullAnnouncements = true,
		colorAssistance = true,
		uiScale = true,
		tutorialReplay = true,
	}, "P002-PROFILE-103 setting field invalid")
	for _, field in { "masterVolume", "musicVolume", "effectsVolume" } do
		assertInteger(profile.settings[field], 0, "P002-PROFILE-076 setting number invalid")
		assert(profile.settings[field] <= 100, "P002-PROFILE-077 setting number too large")
	end
	assertInteger(profile.settings.uiScale, 0, "P002-PROFILE-076 setting number invalid")
	assert(profile.settings.uiScale <= 200, "P002-PROFILE-077 setting number too large")
	for _, field in
		{
			"revealSound",
			"reducedMotion",
			"reducedFlash",
			"lowGraphics",
			"autoReveal",
			"autoEquip",
			"tradeRequests",
			"duelRequests",
			"rarePullAnnouncements",
			"colorAssistance",
			"tutorialReplay",
		}
	do
		assert(
			type(profile.settings[field]) == "boolean",
			"P002-PROFILE-078 setting boolean invalid"
		)
	end
	assert(
		profile.settings.packAnimationSpeed == "slow"
			or profile.settings.packAnimationSpeed == "normal"
			or profile.settings.packAnimationSpeed == "fast",
		"P002-PROFILE-079 animation speed invalid"
	)
	assertOnlyFields(profile.daily, {
		dayKey = true,
		friendClashRewards = true,
	}, "P002-PROFILE-104 daily field invalid")
	assert(type(profile.daily.dayKey) == "string", "P002-PROFILE-105 daily key invalid")
	assertInteger(profile.daily.friendClashRewards, 0, "P002-PROFILE-106 daily rewards invalid")
	assertOnlyFields(profile.tutorial, {
		stepId = true,
		completed = true,
		starterPackClaimed = true,
	}, "P002-PROFILE-107 tutorial field invalid")
	assertString(profile.tutorial.stepId, "P002-PROFILE-108 tutorial step invalid")
	assert(type(profile.tutorial.completed) == "boolean", "P002-PROFILE-080 tutorial state invalid")
	assert(
		type(profile.tutorial.starterPackClaimed) == "boolean",
		"P002-PROFILE-081 starter state invalid"
	)
	validateDenseStringArray(profile.tradeHistory, nil, "P002-PROFILE-109 trade history invalid")
	for boostId, boost in profile.boosts do
		assertString(boostId, "P002-PROFILE-110 boost id invalid")
		assert(type(boost) == "table", "P002-PROFILE-111 boost invalid")
	end
	assertOnlyFields(profile.moderation, {
		quarantined = true,
		reasonCode = true,
	}, "P002-PROFILE-112 moderation field invalid")
	assert(type(profile.moderation.quarantined) == "boolean", "P002-PROFILE-082 quarantine invalid")
	assert(
		type(profile.moderation.reasonCode) == "string",
		"P002-PROFILE-083 quarantine reason invalid"
	)
	if profile.session ~= nil then
		assertOnlyFields(profile.session, {
			token = true,
			jobId = true,
			placeVersion = true,
			heartbeatAt = true,
		}, "P002-PROFILE-024 session invalid")
		assert(type(profile.session.token) == "string", "P002-PROFILE-025 session token invalid")
		assert(type(profile.session.jobId) == "string", "P002-PROFILE-026 session job invalid")
		assertInteger(profile.session.placeVersion, 0, "P002-PROFILE-027 place version invalid")
		assertInteger(profile.session.heartbeatAt, 0, "P002-PROFILE-028 heartbeat invalid")
	end
	return profile
end

return table.freeze(ProfileSchema)
