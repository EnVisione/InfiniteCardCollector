--!strict

local fs = require("@lune/fs")
local serde = require("@lune/serde")

local ArtifactCore = require("./lib/artifact-core")
local Phase002Evidence = require("./lib/phase002-evidence")
local ActionRegistry = require("../src/shared/Network/ActionRegistry")
local LaunchCatalog = require("../src/shared/Catalogs/LaunchCatalog")
local LaunchConfig = require("../src/shared/Config/LaunchConfig")
local EnvelopeValidator = require("../src/shared/Network/EnvelopeValidator")
local ErrorRegistry = require("../src/shared/Network/ErrorRegistry")
local FormationDetector = require("../src/shared/Math/FormationDetector")
local JokerRegistry = require("../src/shared/Math/JokerRegistry")
local SafeNumber = require("../src/shared/Math/SafeNumber")
local ScoreCalculator = require("../src/shared/Math/ScoreCalculator")
local ClientProjection = require("../src/shared/Projection/ClientProjection")
local CanonicalValue = require("../src/shared/Profile/CanonicalValue")
local MigrationRegistry = require("../src/shared/Profile/MigrationRegistry")
local ProfileCodec = require("../src/shared/Profile/ProfileCodec")
local ProfilePolicy = require("../src/shared/Profile/ProfilePolicy")
local ProfileSchema = require("../src/shared/Profile/ProfileSchema")
local CardViewModel = require("../src/shared/Rendering/CardViewModel")
local CardRenderer2D = require("../src/client/Rendering/CardRenderer2D")
local CardRenderer3D = require("../src/client/Rendering/CardRenderer3D")
local ComponentPool = require("../src/client/Rendering/ComponentPool")
local PreloadManifest = require("../src/client/Rendering/PreloadManifest")
local VirtualizedBinder = require("../src/client/Rendering/VirtualizedBinder")
local ClientState = require("../src/client/State/ClientState")
local GuidedFormationService = require("../src/server/Formation/GuidedFormationService")
local NetworkGateway = require("../src/server/Network/NetworkGateway")
local CollectionService = require("../src/server/Inventory/CollectionService")
local DeckService = require("../src/server/Inventory/DeckService")
local InventoryService = require("../src/server/Inventory/InventoryService")
local StarterPackService = require("../src/server/Packs/StarterPackService")
local RandomService = require("../src/server/Random/RandomService")
local ProfileProjection = require("../src/server/Projection/ProfileProjection")
local InventoryStore = require("../src/server/Storage/InventoryStore")
local ProfileStore = require("../src/server/Storage/ProfileStore")
local TokenBuckets = require("../src/server/Network/TokenBuckets")
local TransactionService = require("../src/server/Transactions/TransactionService")

local Phase002Test = {}

local function newInventoryService(dependencies: any): any
	dependencies.inventoryStore = InventoryStore.new()
	dependencies.collection = CollectionService.new()
	return InventoryService.new(dependencies)
end

local function newTransactionService(dependencies: any): any
	dependencies.clock = dependencies.clock or os.clock
	dependencies.sleep = dependencies.sleep or function() end
	return TransactionService.new(dependencies)
end

local currencyIds = {}
for _, currency in LaunchConfig.economy.currencies do
	table.insert(currencyIds, currency.id)
end

local migrationRegistry = MigrationRegistry.new({
	schema = ProfileSchema,
	codec = ProfileCodec,
	canonical = CanonicalValue,
	errors = ErrorRegistry,
	currencyIds = currencyIds,
	catalogVersion = 1,
	configVersion = 1,
})

local function newMemoryAdapter(initial: any?): any
	local adapter = {
		data = initial,
		failNext = false,
		failuresRemaining = 0,
		updates = 0,
	}
	function adapter:update(_key: string, transform: (any) -> any): boolean
		self.updates += 1
		if self.failNext or self.failuresRemaining > 0 then
			self.failNext = false
			self.failuresRemaining = math.max(0, self.failuresRemaining - 1)
			return false
		end
		local current = if self.data ~= nil then CanonicalValue.copy(self.data) else nil
		local nextValue = transform(current)
		self.data = if nextValue ~= nil then CanonicalValue.copy(nextValue) else nil
		return true
	end
	return adapter
end

local function newProfileStore(adapter: any, environment: any): any
	return ProfileStore.new({
		adapter = adapter,
		migrations = migrationRegistry,
		schema = ProfileSchema,
		codec = ProfileCodec,
		canonical = CanonicalValue,
		policy = ProfilePolicy,
		errors = ErrorRegistry,
		clock = function()
			return environment.now
		end,
		sleep = function(seconds: number)
			environment.retryDelaysMilliseconds = environment.retryDelaysMilliseconds or {}
			table.insert(environment.retryDelaysMilliseconds, math.floor(seconds * 1000 + 0.5))
			if environment.advanceClockOnSleep then
				environment.now += seconds
			end
		end,
		retryJitter = environment.retryJitter or function()
			return 0
		end,
		tokenFactory = function(userKey: string)
			environment.tokens += 1
			return environment.jobId .. "_" .. userKey .. "_token_" .. tostring(environment.tokens)
		end,
		reconcile = environment.reconcile or function()
			return true
		end,
		jobId = environment.jobId,
		placeVersion = environment.placeVersion,
		currencyIds = currencyIds,
		catalogVersion = 1,
		configVersion = 1,
	})
end

local function envelope(action: string, payload: any): any
	return {
		version = 1,
		action = action,
		requestId = "request_00000001",
		payload = payload,
	}
end

local function expectCode(value: any, code: string)
	local result = EnvelopeValidator.validate(ActionRegistry, ErrorRegistry, value)
	assert(not result.accepted, "P002-TEST-001 invalid envelope accepted")
	assert(result.code == code, "P002-TEST-002 wrong validation code")
end

local function validValue(spec: any): any
	if spec.kind == "boolean" then
		return true
	elseif spec.kind == "integer" then
		return spec.min or 0
	elseif spec.kind == "stable_id" then
		return "fixture_id"
	elseif spec.kind == "request_id" then
		return "request_reference_0001"
	elseif spec.kind == "array" then
		local result = {}
		for index = 1, spec.minItems do
			local value = validValue(spec.item)
			if type(value) == "string" then
				value ..= "_" .. tostring(index)
			end
			table.insert(result, value)
		end
		return result
	end
	error("P002-TEST-177 unsupported schema kind")
end

local function validPayload(action: any): any
	local payload = {}
	for name, spec in action.schema.fields do
		if spec.required ~= false then
			payload[name] = validValue(spec)
		end
	end
	return payload
end

local function newGateway(
	profileState: ((string) -> any)?,
	authorize: ((string, string, any) -> boolean)?,
	routes: any?
): any
	local now = 0
	local limiter = TokenBuckets.new(ActionRegistry, function()
		return now
	end)
	return NetworkGateway.new({
		registry = ActionRegistry,
		errors = ErrorRegistry,
		validator = EnvelopeValidator,
		limiter = limiter,
		profileState = profileState or function()
			return { ready = true, writable = true }
		end,
		authorize = authorize or function()
			return true
		end,
		routes = routes or {},
	})
end

function Phase002Test.register(addTest: (string, () -> ()) -> (), expectFailure: any)
	addTest("P002-TEST-001-action-and-error-registries", function()
		assert(ActionRegistry.version == 1, "P002-TEST-003 action registry version")
		assert(ActionRegistry.envelopeVersion == 1, "P002-TEST-004 envelope version")
		assert(#ActionRegistry.actions == 24, "P002-TEST-005 action count")
		local seenHandlers = {}
		for _, action in ActionRegistry.actions do
			assert(ActionRegistry.byId[action.id] == action, "P002-TEST-006 lookup mismatch")
			assert(table.isfrozen(action), "P002-TEST-007 action mutable")
			assert(table.isfrozen(action.schema), "P002-TEST-008 schema mutable")
			assert(table.isfrozen(action.schema.fields), "P002-TEST-009 fields mutable")
			if action.available then
				assert(action.handlerId ~= nil, "P002-TEST-010 available handler missing")
				seenHandlers[action.handlerId] = true
			end
		end
		for _, required in
			{
				"bootstrap",
				"starter_pack",
				"deck_equip",
				"deck_unequip",
				"inventory_flags",
				"guided_formation",
				"binder_page",
			}
		do
			assert(seenHandlers[required], "P002-TEST-011 phase route missing")
		end
		for _, code in ErrorRegistry.codes do
			assert(ErrorRegistry.isDeclared(code), "P002-TEST-012 error lookup missing")
		end
		expectFailure(function()
			ActionRegistry.actions[1].id = "changed"
		end, "readonly")
	end)

	addTest("P002-TEST-002-envelope-happy-paths", function()
		local fixtures = {
			envelope("bootstrap.request", {}),
			envelope("bootstrap.request", { knownRevision = 0 }),
			envelope("pack.open", { expectedRevision = 0, packId = "classic_starter" }),
			envelope("deck.equip_card", {
				expectedRevision = 1,
				instanceId = "card_00000001",
				slotKey = "ace:hearts",
			}),
			envelope("formation.submit", {
				expectedRevision = 2,
				instanceIds = { "card_1", "card_2", "card_3", "card_4" },
				modeId = "guided_classic",
				roundId = "round_0000000001",
			}),
			envelope("binder.page", { pageSize = 100, sortId = "newest" }),
		}
		for _, fixture in fixtures do
			local result = EnvelopeValidator.validate(ActionRegistry, ErrorRegistry, fixture)
			assert(result.accepted, "P002-TEST-013 valid envelope rejected")
			assert(result.policy.id == fixture.action, "P002-TEST-014 wrong policy")
			assert(result.requestId == fixture.requestId, "P002-TEST-015 request identity changed")
		end
	end)

	addTest("P002-TEST-003-envelope-and-schema-rejection", function()
		expectCode(nil, ErrorRegistry.codes.envelopeInvalid)
		expectCode({}, ErrorRegistry.codes.envelopeInvalid)
		expectCode({
			version = 2,
			action = "bootstrap.request",
			requestId = "request_00000001",
			payload = {},
		}, ErrorRegistry.codes.versionUnsupported)
		expectCode({
			version = 1,
			action = "bootstrap.request",
			requestId = "short",
			payload = {},
		}, ErrorRegistry.codes.requestIdInvalid)
		expectCode(envelope("unknown.action", {}), ErrorRegistry.codes.actionUnknown)
		expectCode(envelope("pack.open", {}), ErrorRegistry.codes.payloadInvalid)
		expectCode(
			envelope("pack.open", {
				expectedRevision = 0,
				packId = "classic_starter",
				unexpected = true,
			}),
			ErrorRegistry.codes.unknownField
		)
		expectCode(
			envelope("pack.open", {
				expectedRevision = "zero",
				packId = "classic_starter",
			}),
			ErrorRegistry.codes.typeInvalid
		)
		expectCode(
			envelope("pack.open", {
				expectedRevision = -1,
				packId = "classic_starter",
			}),
			ErrorRegistry.codes.boundsInvalid
		)
		expectCode(
			envelope("pack.open", {
				expectedRevision = 0 / 0,
				packId = "classic_starter",
			}),
			ErrorRegistry.codes.numberNonfinite
		)
		expectCode(
			envelope("pack.open", {
				expectedRevision = 0,
				packId = "Classic Starter",
			}),
			ErrorRegistry.codes.boundsInvalid
		)
		expectCode(
			envelope("formation.submit", {
				expectedRevision = 0,
				instanceIds = { "card_1", "card_2", "card_3" },
				modeId = "guided_classic",
				roundId = "round_0000000001",
			}),
			ErrorRegistry.codes.boundsInvalid
		)
	end)

	addTest("P002-TEST-004-envelope-resource-limits", function()
		local oversized = envelope("binder.page", {
			cursor = string.rep("a", 5000),
			pageSize = 10,
			sortId = "newest",
		})
		expectCode(oversized, ErrorRegistry.codes.payloadTooLarge)

		local deep: any = {}
		local cursor = deep
		for _ = 1, 10 do
			cursor.next = {}
			cursor = cursor.next
		end
		expectCode(envelope("bootstrap.request", deep), ErrorRegistry.codes.payloadTooDeep)

		local cyclic: any = {}
		cyclic.self = cyclic
		expectCode(envelope("bootstrap.request", cyclic), ErrorRegistry.codes.payloadInvalid)

		local complex: any = {}
		for index = 1, 200 do
			complex["field" .. tostring(index)] = index
		end
		expectCode(envelope("bootstrap.request", complex), ErrorRegistry.codes.payloadTooComplex)
	end)

	addTest("P002-TEST-005-token-bucket-boundaries", function()
		local now = 0
		local limiter = TokenBuckets.new(ActionRegistry, function()
			return now
		end)
		for _ = 1, 4 do
			local allowed = limiter:consume("user_1", "bootstrap.request")
			assert(allowed, "P002-TEST-016 token below capacity rejected")
		end
		local denied, retryAfter = limiter:consume("user_1", "bootstrap.request")
		assert(not denied, "P002-TEST-017 token above capacity accepted")
		assert(retryAfter == 3000, "P002-TEST-018 retry window mismatch")
		now = 3
		local refilled = limiter:consume("user_1", "bootstrap.request")
		assert(refilled, "P002-TEST-019 refill rejected")
		limiter:removeUser("user_1")
		local reset = limiter:consume("user_1", "bootstrap.request")
		assert(reset, "P002-TEST-020 removed user not reset")
	end)

	addTest("P002-TEST-006-gateway-order-and-fail-closed", function()
		local bootstrapGateway = newGateway(nil, nil, {
			bootstrap = function(_userKey: string, _payload: any, _requestId: string)
				return { ok = true, code = "ok" }
			end,
		})
		local bootstrap = bootstrapGateway:handle("user_1", envelope("bootstrap.request", {}))
		assert(bootstrap.ok, "P002-TEST-021 bootstrap route failed")
		assert(bootstrap.requestId == "request_00000001", "P002-TEST-174 request identity")
		assert(bootstrap.action == "bootstrap.request", "P002-TEST-175 action identity")
		local rejected = bootstrapGateway:handle(
			"user_1",
			envelope("deck.unequip_card", {
				expectedRevision = 0,
				instanceId = "card_00000001",
				slotKey = "ace:hearts",
			})
		)
		assert(rejected.code == ErrorRegistry.codes.unknownField, "P002-TEST-224 rejection code")
		assert(rejected.requestId == "request_00000001", "P002-TEST-225 rejection request identity")
		assert(rejected.action == "deck.unequip_card", "P002-TEST-226 rejection action identity")

		local unavailable = bootstrapGateway:handle(
			"user_1",
			envelope("task.start", {
				taskId = "starter_task",
			})
		)
		assert(
			unavailable.code == ErrorRegistry.codes.featureUnavailable,
			"P002-TEST-022 unavailable route"
		)

		local notReadyGateway = newGateway(function()
			return { ready = false, writable = false }
		end)
		local notReady = notReadyGateway:handle(
			"user_1",
			envelope("pack.open", {
				expectedRevision = 0,
				packId = "classic_starter",
			})
		)
		assert(
			notReady.code == ErrorRegistry.codes.profileNotReady,
			"P002-TEST-023 readiness order"
		)

		local readOnlyGateway = newGateway(function()
			return { ready = true, writable = false }
		end)
		local readOnly = readOnlyGateway:handle(
			"user_1",
			envelope("pack.open", {
				expectedRevision = 0,
				packId = "classic_starter",
			})
		)
		assert(readOnly.code == ErrorRegistry.codes.profileReadOnly, "P002-TEST-024 writable order")

		local deniedGateway = newGateway(nil, function()
			return false
		end)
		local denied = deniedGateway:handle(
			"user_1",
			envelope("binder.page", {
				pageSize = 10,
				sortId = "newest",
			})
		)
		assert(
			denied.code == ErrorRegistry.codes.permissionDenied,
			"P002-TEST-025 authorization order"
		)

		local missingRouteGateway = newGateway()
		local missingRoute = missingRouteGateway:handle(
			"user_1",
			envelope("binder.page", {
				pageSize = 10,
				sortId = "newest",
			})
		)
		assert(
			missingRoute.code == ErrorRegistry.codes.internalFailClosed,
			"P002-TEST-026 missing route"
		)

		local failedRouteGateway = newGateway(nil, nil, {
			binder_page = function()
				error("fixture route failure")
			end,
		})
		local failedRoute = failedRouteGateway:handle(
			"user_1",
			envelope("binder.page", {
				pageSize = 10,
				sortId = "newest",
			})
		)
		assert(
			failedRoute.code == ErrorRegistry.codes.internalFailClosed,
			"P002-TEST-027 route error leaked"
		)
	end)

	addTest("P002-TEST-007-profile-blank-round-trip-and-size", function()
		local blank = ProfileSchema.newBlank(currencyIds, 1000, 1, 1)
		assert(blank.schemaVersion == 1, "P002-TEST-028 blank schema version")
		assert(blank.revision == 0, "P002-TEST-029 blank revision")
		local currencyCount = 0
		for currencyId, balance in blank.currencies do
			currencyCount += 1
			assert(balance == 0, "P002-TEST-030 blank currency balance")
			assert(type(currencyId) == "string", "P002-TEST-031 blank currency id")
		end
		assert(currencyCount == 8, "P002-TEST-032 blank currency count")

		local saved = ProfileCodec.encode(ProfileSchema, CanonicalValue, blank)
		assert(saved.v == 1 and saved.r == 0, "P002-TEST-033 saved profile header")
		assert(saved.schemaVersion == nil, "P002-TEST-034 readable key leaked")
		local restored = ProfileCodec.decode(ProfileSchema, CanonicalValue, saved)
		assert(
			CanonicalValue.encode(restored) == CanonicalValue.encode(blank),
			"P002-TEST-035 profile round trip changed"
		)
		local bytes = ProfileCodec.measure(ProfileSchema, CanonicalValue, blank)
		assert(bytes > 0 and bytes < 10000, "P002-TEST-036 blank profile size")
		assert(ProfilePolicy.classifyBytes(bytes) == "healthy", "P002-TEST-037 blank size class")
		assert(ProfilePolicy.classifyBytes(1000000) == "warning", "P002-TEST-038 warning boundary")
		assert(
			ProfilePolicy.classifyBytes(1500000) == "warning",
			"P002-TEST-039 block lower boundary"
		)
		assert(ProfilePolicy.classifyBytes(1500001) == "blocked", "P002-TEST-040 block boundary")
		local unknownProfileField = CanonicalValue.copy(blank)
		unknownProfileField.unknown = true
		expectFailure(function()
			ProfileSchema.validate(unknownProfileField)
		end, "P002-PROFILE-029")
		local falseDiscovery = CanonicalValue.copy(blank)
		falseDiscovery.discovery.forms.invalid_form = false
		expectFailure(function()
			ProfileSchema.validate(falseDiscovery)
		end, "P002-PROFILE-030")
		local invalidVolume = CanonicalValue.copy(blank)
		invalidVolume.settings.masterVolume = 101
		expectFailure(function()
			ProfileSchema.validate(invalidVolume)
		end, "P002-PROFILE-077")
		local missingDeckCard = CanonicalValue.copy(blank)
		missingDeckCard.activeDeck["ace:hearts"] = "card_missing"
		expectFailure(function()
			ProfileSchema.validate(missingDeckCard)
		end, "P002-PROFILE-089")
		local missingActiveJoker = CanonicalValue.copy(blank)
		missingActiveJoker.activeJokers = { "joker_missing" }
		expectFailure(function()
			ProfileSchema.validate(missingActiveJoker)
		end, "P002-PROFILE-092")
		local unsortedDiscovery = ProfileCodec.encode(ProfileSchema, CanonicalValue, blank)
		unsortedDiscovery.x.f = { "z_form", "a_form" }
		expectFailure(function()
			ProfileCodec.decode(ProfileSchema, CanonicalValue, unsortedDiscovery)
		end, "P002-CODEC-011")

		local stress = ProfileSchema.newBlank(currencyIds, 1000, 1, 1)
		local previousBytes = ProfileCodec.measure(ProfileSchema, CanonicalValue, stress)
		local belowWarningBytes = nil
		local warningBytes = nil
		local belowBlockedBytes = nil
		local blockedBytes = nil
		for index = 1, 10000 do
			local identity = LaunchCatalog.identities[((index - 1) % #LaunchCatalog.identities) + 1]
			local uid = string.format("card_stress_%06d", index)
			stress.cards[uid] = {
				uid = uid,
				ownerUserId = 42,
				identityId = identity.id,
				deckSetId = identity.deckSetId,
				rankId = identity.rankId,
				suitId = identity.suitId,
				slotKey = identity.slotKey,
				editionId = "normal",
				gradeId = "f",
				powerTierId = "common",
				gradeExperience = 0,
				flags = { favorite = false, wishlist = false },
				locks = {},
				provenance = {
					originType = "stress_fixture",
					originId = string.format("size_fixture_%06d", index),
					createdAt = 1000 + index,
					instanceVersion = 1,
				},
			}
			stress.discovery.forms[LaunchCatalog.formKey(identity.id, "normal")] = true
			if index % 100 == 0 then
				local currentBytes = ProfileCodec.measure(ProfileSchema, CanonicalValue, stress)
				if warningBytes == nil and currentBytes >= ProfilePolicy.warningBytes then
					belowWarningBytes = previousBytes
					warningBytes = currentBytes
				end
				if currentBytes > ProfilePolicy.blockingBytes then
					belowBlockedBytes = previousBytes
					blockedBytes = currentBytes
					break
				end
				previousBytes = currentBytes
			end
		end
		assert(
			belowWarningBytes ~= nil and warningBytes ~= nil,
			"P002-TEST-227 warning fixture missing"
		)
		assert(
			belowBlockedBytes ~= nil and blockedBytes ~= nil,
			"P002-TEST-228 blocked fixture missing"
		)
		assert(
			ProfilePolicy.classifyBytes(belowWarningBytes) == "healthy"
				and ProfilePolicy.classifyBytes(warningBytes) == "warning",
			"P002-TEST-229 realistic warning crossing"
		)
		assert(
			ProfilePolicy.classifyBytes(belowBlockedBytes) == "warning"
				and ProfilePolicy.classifyBytes(blockedBytes) == "blocked",
			"P002-TEST-230 realistic block crossing"
		)
		local restoredStress = ProfileCodec.decode(
			ProfileSchema,
			CanonicalValue,
			ProfileCodec.encode(ProfileSchema, CanonicalValue, stress)
		)
		assert(
			ProfileCodec.measure(ProfileSchema, CanonicalValue, restoredStress) == blockedBytes,
			"P002-TEST-231 stress round trip changed"
		)
		local cardUid, cardFixture = next(stress.cards)
		local malformedCardProfile = ProfileSchema.newBlank(currencyIds, 1000, 1, 1)
		malformedCardProfile.cards[cardUid] = CanonicalValue.copy(cardFixture)
		malformedCardProfile.cards[cardUid].unknown = true
		expectFailure(function()
			ProfileSchema.validate(malformedCardProfile)
		end, "P002-PROFILE-087")
		malformedCardProfile.cards[cardUid].unknown = nil
		malformedCardProfile.cards[cardUid].provenance.createdAt = -1
		expectFailure(function()
			ProfileSchema.validate(malformedCardProfile)
		end, "P002-PROFILE-042")
		local mismatchedSlotProfile = ProfileSchema.newBlank(currencyIds, 1000, 1, 1)
		mismatchedSlotProfile.cards[cardUid] = CanonicalValue.copy(cardFixture)
		mismatchedSlotProfile.cards[cardUid].slotKey = "ace:spades"
		expectFailure(function()
			ProfileSchema.validate(mismatchedSlotProfile)
		end, "P002-PROFILE-131")
		local mismatchedIdentityProfile = ProfileSchema.newBlank(currencyIds, 1000, 1, 1)
		mismatchedIdentityProfile.cards[cardUid] = CanonicalValue.copy(cardFixture)
		mismatchedIdentityProfile.cards[cardUid].identityId = "classic:ace:spades"
		expectFailure(function()
			ProfileSchema.validate(mismatchedIdentityProfile)
		end, "P002-PROFILE-132")

		local adapter = newMemoryAdapter()
		local environment = {
			now = 1000,
			tokens = 0,
			jobId = "size_job",
			placeVersion = 10,
		}
		local store = newProfileStore(adapter, environment)
		assert(store:acquire("size_user").ok, "P002-TEST-232 size store acquire")
		local durableBefore = CanonicalValue.encode(adapter.data)
		stress.revision = 1
		local blockedCommit = store:commit("size_user", 0, stress)
		assert(
			not blockedCommit.ok and blockedCommit.code == ErrorRegistry.codes.profileTooLarge,
			"P002-TEST-233 oversized commit accepted"
		)
		assert(
			CanonicalValue.encode(adapter.data) == durableBefore,
			"P002-TEST-234 oversized durable write"
		)
		assert(
			store:state("size_user").revision == 0 and store:state("size_user").writable,
			"P002-TEST-235 oversized session mutation"
		)
	end)

	addTest("P002-TEST-008-profile-migrations-repeat-and-preserve", function()
		local legacy = {
			version = 0,
			createdAt = 100,
			lastSeenAt = 200,
			money = 345,
			ownedCards = {
				{
					uid = "card_legacy_1",
					ownerUserId = 42,
					deckSetId = "classic",
					rankId = "ace",
					suitId = "hearts",
				},
			},
		}
		local first = migrationRegistry:migrate(legacy)
		assert(first.ok, "P002-TEST-041 legacy migration failed")
		assert(first.fromVersion == 0 and first.toVersion == 1, "P002-TEST-042 migration versions")
		assert(first.profile.currencies.cash == 345, "P002-TEST-043 migration currency loss")
		assert(
			first.profile.cards.card_legacy_1.uid == "card_legacy_1",
			"P002-TEST-044 migration card loss"
		)
		local second = migrationRegistry:migrate(first.saved)
		assert(second.ok, "P002-TEST-045 current normalization failed")
		assert(
			second.fromVersion == 1 and second.toVersion == 1,
			"P002-TEST-046 normalization versions"
		)
		assert(second.canonical == first.canonical, "P002-TEST-047 migration not repeatable")
		assert(
			CanonicalValue.encode(second.saved) == CanonicalValue.encode(first.saved),
			"P002-TEST-048 saved drift"
		)

		local malformed = migrationRegistry:migrate({ version = 0, money = 1 })
		assert(not malformed.ok, "P002-TEST-049 malformed migration accepted")
		assert(
			malformed.code == ErrorRegistry.codes.profileMalformed,
			"P002-TEST-050 malformed code"
		)
		local future = migrationRegistry:migrate({ v = 2 })
		assert(not future.ok, "P002-TEST-051 future schema accepted")
		assert(
			future.code == ErrorRegistry.codes.profileUnsupportedSchema,
			"P002-TEST-052 future schema code"
		)
	end)

	addTest("P002-TEST-009-canonical-value-determinism", function()
		local left = { zebra = 1, alpha = 2, nested = { right = true, left = false } }
		local right = { nested = { left = false, right = true }, alpha = 2, zebra = 1 }
		assert(
			CanonicalValue.encode(left) == CanonicalValue.encode(right),
			"P002-TEST-053 map order changed"
		)
		local copied = CanonicalValue.copy(left)
		copied.nested.left = true
		assert(left.nested.left == false, "P002-TEST-054 copy shared state")
		expectFailure(function()
			CanonicalValue.encode({ value = 0 / 0 })
		end, "P002-CANONICAL-001")
		local cyclic: any = {}
		cyclic.self = cyclic
		expectFailure(function()
			CanonicalValue.encode(cyclic)
		end, "P002-CANONICAL-003")
	end)

	addTest("P002-TEST-010-profile-session-lifecycle", function()
		local adapter = newMemoryAdapter()
		local firstEnvironment = {
			now = 1000,
			tokens = 0,
			jobId = "job_one",
			placeVersion = 10,
		}
		local firstStore = newProfileStore(adapter, firstEnvironment)
		local acquired = firstStore:acquire("user_1")
		assert(acquired.ok, "P002-TEST-055 blank acquisition failed")
		assert(acquired.profile.revision == 0, "P002-TEST-056 acquired revision")
		assert(firstStore:state("user_1").writable, "P002-TEST-057 acquired not writable")

		local secondEnvironment = {
			now = 1001,
			tokens = 0,
			jobId = "job_two",
			placeVersion = 10,
		}
		local secondStore = newProfileStore(adapter, secondEnvironment)
		local collision = secondStore:acquire("user_1")
		assert(not collision.ok, "P002-TEST-058 healthy collision acquired")
		assert(
			collision.code == ErrorRegistry.codes.sessionConflict,
			"P002-TEST-059 collision code"
		)

		firstEnvironment.now = 1030
		local heartbeat = firstStore:heartbeat("user_1")
		assert(heartbeat.ok, "P002-TEST-060 heartbeat failed")
		secondEnvironment.now = 1151
		local recovered = secondStore:acquire("user_1")
		assert(recovered.ok, "P002-TEST-061 expired session recovery failed")
		local lost = firstStore:heartbeat("user_1")
		assert(not lost.ok, "P002-TEST-062 replaced writer retained session")
		assert(lost.code == ErrorRegistry.codes.sessionConflict, "P002-TEST-063 lost session code")
		assert(not firstStore:state("user_1").writable, "P002-TEST-064 lost session writable")

		local released = secondStore:release("user_1")
		assert(released.ok, "P002-TEST-065 release failed")
		local decoded = ProfileCodec.decode(ProfileSchema, CanonicalValue, adapter.data)
		assert(decoded.session == nil, "P002-TEST-066 released session persisted")
	end)

	addTest("P002-TEST-011-profile-quarantine-and-storage-failure", function()
		local malformed = { v = 1, r = 0, unexpected = "preserve" }
		local adapter = newMemoryAdapter(malformed)
		local environment = {
			now = 1000,
			tokens = 0,
			jobId = "job_one",
			placeVersion = 10,
		}
		local store = newProfileStore(adapter, environment)
		local before = CanonicalValue.encode(adapter.data)
		local quarantined = store:acquire("user_1")
		assert(not quarantined.ok, "P002-TEST-067 malformed profile acquired")
		assert(
			quarantined.code == ErrorRegistry.codes.profileMalformed,
			"P002-TEST-068 quarantine code"
		)
		assert(
			CanonicalValue.encode(adapter.data) == before,
			"P002-TEST-069 quarantine overwrote bytes"
		)

		local unavailableAdapter = newMemoryAdapter()
		unavailableAdapter.failuresRemaining = ProfilePolicy.maxRetries + 1
		local unavailableStore = newProfileStore(unavailableAdapter, environment)
		local unavailable = unavailableStore:acquire("user_2")
		assert(not unavailable.ok, "P002-TEST-070 failed storage acquired")
		assert(
			unavailable.code == ErrorRegistry.codes.storageUnavailable,
			"P002-TEST-071 storage code"
		)
		assert(unavailableAdapter.data == nil, "P002-TEST-072 failed storage wrote profile")
	end)

	addTest("P002-TEST-012-idempotent-transaction-and-rejoin", function()
		local adapter = newMemoryAdapter()
		local environment = {
			now = 1000,
			tokens = 0,
			jobId = "job_one",
			placeVersion = 10,
		}
		local store = newProfileStore(adapter, environment)
		assert(store:acquire("user_1").ok, "P002-TEST-073 transaction acquisition")
		local transactions = newTransactionService({
			profileStore = store,
			canonical = CanonicalValue,
			policy = ProfilePolicy,
			errors = ErrorRegistry,
		})
		local operation = {
			id = "operation_00000001",
			kind = "fixture.reward",
			payload = { amount = 5 },
			expectedRevision = 0,
			resultReference = "reward_00000001",
			apply = function(profile: any): any
				profile.currencies.cash += 5
				return { ok = true, code = "reward.committed", amount = 5 }
			end,
		}
		local committed = transactions:execute("user_1", operation)
		assert(committed.ok and not committed.replayed, "P002-TEST-074 transaction commit")
		assert(committed.revision == 1, "P002-TEST-075 transaction revision")
		assert(store:get("user_1").currencies.cash == 5, "P002-TEST-076 transaction balance")

		local replayed = transactions:execute("user_1", operation)
		assert(replayed.ok and replayed.replayed, "P002-TEST-077 replay failed")
		assert(replayed.revision == committed.revision, "P002-TEST-078 replay revision")
		assert(store:get("user_1").currencies.cash == 5, "P002-TEST-079 replay mutated")

		local conflicting = CanonicalValue.copy(operation)
		conflicting.payload.amount = 6
		local conflict = transactions:execute("user_1", conflicting)
		assert(not conflict.ok, "P002-TEST-080 conflicting replay accepted")
		assert(
			conflict.code == ErrorRegistry.codes.replayConflict,
			"P002-TEST-081 replay conflict code"
		)

		local stale = transactions:execute("user_1", {
			id = "operation_00000002",
			kind = "fixture.reward",
			payload = { amount = 1 },
			expectedRevision = 0,
			apply = operation.apply,
		})
		assert(
			not stale.ok and stale.code == ErrorRegistry.codes.staleState,
			"P002-TEST-082 stale commit"
		)

		assert(store:release("user_1").ok, "P002-TEST-083 release after commit")
		environment.now = 1100
		local rejoinedStore = newProfileStore(adapter, environment)
		local rejoined = rejoinedStore:acquire("user_1")
		assert(rejoined.ok, "P002-TEST-084 rejoin failed")
		assert(rejoined.profile.revision == 1, "P002-TEST-085 rejoin revision")
		assert(rejoined.profile.currencies.cash == 5, "P002-TEST-086 rejoin balance")
		assert(
			rejoined.profile.processedOperations[operation.id] ~= nil,
			"P002-TEST-087 receipt missing"
		)
		local wrongReceiptVersion = CanonicalValue.copy(rejoined.profile)
		wrongReceiptVersion.processedOperations[operation.id].version = 2
		expectFailure(function()
			ProfileSchema.validate(wrongReceiptVersion)
		end, "P002-PROFILE-121")
		local mismatchedBarrier = CanonicalValue.copy(rejoined.profile)
		mismatchedBarrier.replayBarrier[operation.id].kind = "different.kind"
		expectFailure(function()
			ProfileSchema.validate(mismatchedBarrier)
		end, "P002-PROFILE-129")
	end)

	addTest("P002-TEST-013-transaction-failure-and-compaction", function()
		local adapter = newMemoryAdapter()
		local environment = {
			now = 1000,
			tokens = 0,
			jobId = "job_one",
			placeVersion = 10,
		}
		local store = newProfileStore(adapter, environment)
		assert(store:acquire("user_1").ok, "P002-TEST-088 compaction acquisition")
		local transactions = newTransactionService({
			profileStore = store,
			canonical = CanonicalValue,
			policy = { receiptRetention = 2 },
			errors = ErrorRegistry,
		})
		local function operation(index: number): any
			return {
				id = "operation_0000000" .. tostring(index),
				kind = "fixture.reward",
				payload = { amount = index },
				expectedRevision = index - 1,
				resultReference = "reward_" .. tostring(index),
				apply = function(profile: any): any
					profile.currencies.cash += index
					return { ok = true, code = "reward.committed", amount = index }
				end,
			}
		end
		for index = 1, 3 do
			assert(
				transactions:execute("user_1", operation(index)).ok,
				"P002-TEST-089 compact commit"
			)
		end
		local profile = store:get("user_1")
		assert(#profile.operationOrder == 2, "P002-TEST-090 receipt retention")
		assert(
			profile.processedOperations.operation_00000001 == nil,
			"P002-TEST-091 receipt not compacted"
		)
		assert(
			profile.replayBarrier.operation_00000001 ~= nil,
			"P002-TEST-092 replay barrier missing"
		)
		local old = operation(1)
		old.expectedRevision = 0
		local compactedReplay = transactions:execute("user_1", old)
		assert(compactedReplay.ok and compactedReplay.compacted, "P002-TEST-093 compact replay")
		assert(
			compactedReplay.resultReference == "reward_1",
			"P002-TEST-094 compact result reference"
		)
		assert(store:get("user_1").currencies.cash == 6, "P002-TEST-095 compact replay mutated")

		local before = CanonicalValue.encode(store:get("user_1"))
		local failed = transactions:execute("user_1", {
			id = "operation_00000004",
			kind = "fixture.failure",
			payload = {},
			expectedRevision = 3,
			apply = function()
				error("fixture apply failure")
			end,
		})
		assert(not failed.ok, "P002-TEST-096 failed apply committed")
		assert(
			failed.code == ErrorRegistry.codes.operationApplyFailed,
			"P002-TEST-097 apply failure code"
		)
		assert(
			CanonicalValue.encode(store:get("user_1")) == before,
			"P002-TEST-098 failed apply mutated"
		)

		local cyclicResult = { ok = true, code = "fixture.invalid_result" }
		cyclicResult.cycle = cyclicResult
		local invalidResult = transactions:execute("user_1", {
			id = "operation_00000005",
			kind = "fixture.invalid_result",
			payload = {},
			expectedRevision = 3,
			apply = function(): any
				return cyclicResult
			end,
		})
		assert(
			not invalidResult.ok
				and invalidResult.code == ErrorRegistry.codes.operationResultInvalid,
			"P002-TEST-241 cyclic result not rejected"
		)
		assert(
			CanonicalValue.encode(store:get("user_1")) == before,
			"P002-TEST-242 cyclic result mutated"
		)

		local invalidProfile = transactions:execute("user_1", {
			id = "operation_00000006",
			kind = "fixture.invalid_profile",
			payload = {},
			expectedRevision = 3,
			apply = function(mutableProfile: any): any
				mutableProfile.cards.invalid = {}
				return { ok = true, code = "fixture.invalid_profile" }
			end,
		})
		assert(
			not invalidProfile.ok and invalidProfile.code == ErrorRegistry.codes.internalFailClosed,
			"P002-TEST-244 invalid profile commit not contained"
		)
		assert(
			CanonicalValue.encode(store:get("user_1")) == before,
			"P002-TEST-245 invalid profile commit mutated"
		)

		local recovered = transactions:execute("user_1", {
			id = "operation_00000007",
			kind = "fixture.recovery",
			payload = { amount = 4 },
			expectedRevision = 3,
			apply = function(mutableProfile: any): any
				mutableProfile.currencies.cash += 4
				return { ok = true, code = "reward.committed", amount = 4 }
			end,
		})
		assert(recovered.ok and recovered.revision == 4, "P002-TEST-243 lane did not recover")
	end)

	addTest("P002-TEST-014-inventory-provenance-and-deck-invariants", function()
		local profile = ProfileSchema.newBlank(currencyIds, 1000, 1, 1)
		local uidCandidates = {
			"card_collision",
			"card_collision",
			"card_unique",
			"card_same_slot",
		}
		local uidIndex = 0
		local inventory = newInventoryService({
			catalog = LaunchCatalog,
			errors = ErrorRegistry,
			uidFactory = function()
				uidIndex += 1
				return uidCandidates[uidIndex]
			end,
			clock = function()
				return 1000
			end,
		})
		local firstIdentity = LaunchCatalog.identities[1]
		local secondIdentity = LaunchCatalog.identities[2]
		local sameSlotIdentity = LaunchCatalog.identities[53]
		local first = inventory:createCard(profile, 42, firstIdentity.id, {}, {
			originType = "fixture",
			originId = "fixture_1",
		})
		assert(first.ok and first.card.uid == "card_collision", "P002-TEST-099 first uid")
		local second = inventory:createCard(profile, 42, secondIdentity.id, {}, {
			originType = "fixture",
			originId = "fixture_2",
		})
		assert(second.ok and second.card.uid == "card_unique", "P002-TEST-100 collision retry")
		assert(inventory:assertConservation(profile, 42) == 2, "P002-TEST-101 inventory count")

		local provenance = CanonicalValue.encode(first.card.provenance)
		local flags = inventory:setFlags(profile, 42, first.card.uid, { favorite = true })
		assert(flags.ok and first.card.flags.favorite, "P002-TEST-102 flag update")
		assert(
			CanonicalValue.encode(first.card.provenance) == provenance,
			"P002-TEST-103 provenance changed"
		)
		local foreign = inventory:isEligible(profile, 43, first.card.uid)
		assert(
			not foreign.ok and foreign.code == ErrorRegistry.codes.foreignInstance,
			"P002-TEST-104 foreign owner"
		)
		first.card.locks.trade = true
		local locked = inventory:isEligible(profile, 42, first.card.uid)
		assert(
			not locked.ok and locked.code == ErrorRegistry.codes.instanceLocked,
			"P002-TEST-105 lock ignored"
		)
		first.card.locks.trade = nil

		local deck = DeckService.new({
			catalog = LaunchCatalog,
			inventory = inventory,
			errors = ErrorRegistry,
		})
		assert(#deck.slotKeys == 52, "P002-TEST-106 deck slots")
		local wrong = deck:equip(profile, 42, first.card.uid, second.card.slotKey)
		assert(
			not wrong.ok and wrong.code == ErrorRegistry.codes.slotMismatch,
			"P002-TEST-107 wrong slot"
		)
		local equipped = deck:equip(profile, 42, first.card.uid, first.card.slotKey)
		assert(equipped.ok, "P002-TEST-108 equip failed")
		local duplicate = deck:equip(profile, 42, first.card.uid, first.card.slotKey)
		assert(
			not duplicate.ok and duplicate.code == ErrorRegistry.codes.duplicateInstance,
			"P002-TEST-109 duplicate equip"
		)

		local sameSlot = inventory:createCard(profile, 42, sameSlotIdentity.id, {}, {
			originType = "fixture",
			originId = "fixture_3",
		})
		assert(sameSlot.ok, "P002-TEST-110 same slot card creation")
		local occupied = deck:equip(profile, 42, sameSlot.card.uid, sameSlot.card.slotKey)
		assert(
			not occupied.ok and occupied.code == ErrorRegistry.codes.slotOccupied,
			"P002-TEST-111 occupied slot"
		)
		assert(deck:unequip(profile, 42, first.card.slotKey).ok, "P002-TEST-112 unequip failed")

		local discoveredForm = LaunchCatalog.formKey(first.card.identityId, first.card.editionId)
		profile.cards[first.card.uid] = nil
		assert(profile.discovery.forms[discoveredForm], "P002-TEST-113 discovery regressed")
	end)

	addTest("P002-TEST-015-starter-pack-atomic-recovery", function()
		local adapter = newMemoryAdapter()
		local environment = {
			now = 1000,
			tokens = 0,
			jobId = "job_one",
			placeVersion = 10,
		}
		local store = newProfileStore(adapter, environment)
		assert(store:acquire("user_1").ok, "P002-TEST-114 starter acquisition")
		local uidCounter = 0
		local inventory = newInventoryService({
			catalog = LaunchCatalog,
			errors = ErrorRegistry,
			uidFactory = function()
				uidCounter += 1
				return "starter_card_" .. tostring(uidCounter)
			end,
			clock = function()
				return environment.now
			end,
		})
		local starter = StarterPackService.new({
			catalog = LaunchCatalog,
			inventory = inventory,
			canonical = CanonicalValue,
			errors = ErrorRegistry,
		})
		local transactions = newTransactionService({
			profileStore = store,
			canonical = CanonicalValue,
			policy = ProfilePolicy,
			errors = ErrorRegistry,
		})
		local operation = {
			id = "starter_000000001",
			kind = "pack.open",
			payload = { packId = "classic_starter" },
			expectedRevision = 0,
			resultReference = "starter_000000001",
			apply = function(profile: any): any
				return starter:apply(profile, 42, "starter_000000001", RandomService.new(12345))
			end,
		}
		local opened = transactions:execute("user_1", operation)
		assert(opened.ok and #opened.cards == 5, "P002-TEST-115 starter open")
		local profile = store:get("user_1")
		assert(inventory:assertConservation(profile, 42) == 5, "P002-TEST-116 starter conservation")
		assert(
			profile.pendingPacks[operation.id].state == "committed",
			"P002-TEST-117 pending state"
		)
		assert(
			profile.pendingPacks[operation.id].catalogVersion == LaunchCatalog.catalogVersion,
			"P002-TEST-178 pending catalog version"
		)
		assert(
			profile.pendingPacks[operation.id].resultReference == opened.resultReference,
			"P002-TEST-179 pending result reference"
		)
		local duplicatePending = CanonicalValue.copy(profile)
		duplicatePending.pendingPacks.starter_duplicate_0001 =
			CanonicalValue.copy(duplicatePending.pendingPacks[operation.id])
		expectFailure(function()
			ProfileSchema.validate(duplicatePending)
		end, "P002-PROFILE-113")
		local slots = {}
		for _, card in opened.cards do
			local owned = profile.cards[card.instanceId]
			assert(owned ~= nil, "P002-TEST-118 starter ownership")
			assert(not slots[owned.slotKey], "P002-TEST-119 starter duplicate slot")
			slots[owned.slotKey] = true
		end
		local replayed = transactions:execute("user_1", operation)
		assert(replayed.ok and replayed.replayed, "P002-TEST-120 starter replay")
		assert(
			inventory:assertConservation(store:get("user_1"), 42) == 5,
			"P002-TEST-121 replay duplicated"
		)

		local secondClaim = transactions:execute("user_1", {
			id = "starter_000000002",
			kind = "pack.open",
			payload = { packId = "classic_starter" },
			expectedRevision = 1,
			apply = function(nextProfile: any): any
				return starter:apply(nextProfile, 42, "starter_000000002", RandomService.new(12345))
			end,
		})
		assert(not secondClaim.ok, "P002-TEST-122 second starter claimed")
		assert(
			secondClaim.code == ErrorRegistry.codes.starterAlreadyClaimed,
			"P002-TEST-123 starter claim code"
		)
		assert(store:get("user_1").revision == 1, "P002-TEST-124 rejected starter advanced")
		assert(store:release("user_1").ok, "P002-TEST-180 committed reveal release")
		environment.now = 1050
		local reopeningStore = newProfileStore(adapter, environment)
		local reopened = reopeningStore:acquire("user_1")
		assert(reopened.ok and reopened.profile.revision == 1, "P002-TEST-181 reveal rejoin")
		assert(
			reopened.profile.pendingPacks[operation.id].state == "committed",
			"P002-TEST-182 committed reveal not reopened"
		)

		local deck = DeckService.new({
			catalog = LaunchCatalog,
			inventory = inventory,
			errors = ErrorRegistry,
		})
		local reopeningTransactions = newTransactionService({
			profileStore = reopeningStore,
			canonical = CanonicalValue,
			policy = ProfilePolicy,
			errors = ErrorRegistry,
		})
		local filled = reopeningTransactions:execute("user_1", {
			id = "deck_fill_0000001",
			kind = "deck.autofill",
			payload = { maximum = 5 },
			expectedRevision = 1,
			apply = function(nextProfile: any): any
				local outcome = deck:autoFill(nextProfile, 42, 5)
				if not outcome.ok then
					return outcome
				end
				local acknowledged =
					starter:acknowledgeRevealForCard(nextProfile, outcome.instanceIds[1])
				assert(acknowledged.ok, "P002-TEST-183 reveal acknowledgement")
				outcome.packRevealAcknowledged = acknowledged.acknowledged
				return outcome
			end,
		})
		assert(filled.ok and #filled.instanceIds == 5, "P002-TEST-125 starter auto fill")
		assert(filled.packRevealAcknowledged, "P002-TEST-184 reveal result")
		assert(
			reopeningStore:get("user_1").pendingPacks[operation.id].state == "acknowledged",
			"P002-TEST-185 acknowledged state"
		)
		assert(reopeningStore:release("user_1").ok, "P002-TEST-126 starter release")
		environment.now = 1100
		local rejoinedStore = newProfileStore(adapter, environment)
		local rejoined = rejoinedStore:acquire("user_1")
		assert(rejoined.ok and rejoined.profile.revision == 2, "P002-TEST-127 starter rejoin")
		assert(
			inventory:assertConservation(rejoined.profile, 42) == 5,
			"P002-TEST-128 rejoin conservation"
		)
		local deckCount = 0
		for _ in rejoined.profile.activeDeck do
			deckCount += 1
		end
		assert(deckCount == 5, "P002-TEST-129 rejoin deck")
		assert(
			rejoined.profile.pendingPacks[operation.id].state == "acknowledged",
			"P002-TEST-186 acknowledged reveal rejoin"
		)
		assert(
			rejoined.profile.pendingPacks[operation.id].catalogVersion
				== LaunchCatalog.catalogVersion,
			"P002-TEST-187 acknowledged catalog version"
		)
	end)

	addTest("P002-TEST-016-random-determinism", function()
		local first = RandomService.new(12345)
		local second = RandomService.new(12345)
		for _ = 1, 20 do
			assert(first:nextInteger(52) == second:nextInteger(52), "P002-TEST-130 random drift")
		end
		assert(first.draws == 20 and second.draws == 20, "P002-TEST-131 draw count")
	end)

	addTest("P002-TEST-017-renderer-layers-and-accessible-fallbacks", function()
		local viewModel = CardViewModel.build(LaunchCatalog, {
			instanceId = "card_render_1",
			deckSetId = "classic",
			rankId = "ace",
			suitId = "hearts",
			editionId = "foil",
			gradeId = "a",
			powerTierId = "legendary",
			traitId = "fortune",
			locked = true,
			tradeLocked = true,
			favorite = true,
			wishlist = false,
			isNew = true,
		}, {
			lowGraphics = true,
			reducedMotion = true,
			reducedFlash = true,
		})
		assert(
			viewModel.version == 1 and table.isfrozen(viewModel),
			"P002-TEST-132 view model version"
		)
		assert(#viewModel.layers == #CardViewModel.layerOrder, "P002-TEST-133 layer count")
		for index, layerId in CardViewModel.layerOrder do
			assert(viewModel.layers[index].id == layerId, "P002-TEST-134 layer order")
		end
		assert(not viewModel.settings.animated, "P002-TEST-135 low graphics animation")
		assert(not viewModel.settings.flashing, "P002-TEST-136 reduced flash")
		local statuses = viewModel.layers[8].values
		assert(#statuses == 4, "P002-TEST-137 status count")
		for _, status in statuses do
			assert(status.text ~= "" and status.symbol ~= "", "P002-TEST-138 inaccessible status")
		end

		local twoDimensional = CardRenderer2D.render(viewModel)
		local threeDimensional = CardRenderer3D.render(viewModel)
		assert(twoDimensional.className == "CardFrame2D", "P002-TEST-139 2d adapter")
		assert(threeDimensional.className == "CardModel3D", "P002-TEST-140 3d adapter")
		assert(
			CanonicalValue.encode(twoDimensional.semanticLayers)
				== CanonicalValue.encode(threeDimensional.semanticLayers),
			"P002-TEST-141 adapter semantics differ"
		)
		assert(
			twoDimensional.accessibleName == threeDimensional.accessibleName,
			"P002-TEST-142 adapter label"
		)
		assert(
			string.find(twoDimensional.accessibleName, "Trade Locked", 1, true) ~= nil,
			"P002-TEST-216 trade status inaccessible"
		)
		local fallback = CardViewModel.build(LaunchCatalog, {
			instanceId = "card_render_missing",
			deckSetId = "missing",
			rankId = "missing",
			suitId = "missing",
			editionId = "missing",
			gradeId = "missing",
			powerTierId = "missing",
			traitId = "missing",
		}, {})
		assert(
			fallback.layers[1].valueId == "unavailable"
				and fallback.layers[8].values[1].id == "unavailable",
			"P002-TEST-217 renderer fallback"
		)
	end)

	addTest("P002-TEST-018-renderer-pooling-and-virtualization", function()
		local nextId = 0
		local resetCount = 0
		local pool = ComponentPool.new(function(kind: string): any
			nextId += 1
			return { id = nextId, kind = kind, dirty = false }
		end, function(component: any)
			component.dirty = false
			resetCount += 1
		end, 2)
		local first = pool:acquire("card")
		first.dirty = true
		assert(pool:release(first), "P002-TEST-143 pool release")
		local reused = pool:acquire("card")
		assert(reused == first, "P002-TEST-144 pool did not reuse")
		assert(not reused.dirty and resetCount == 1, "P002-TEST-145 pool did not reset")
		assert(not pool:release({}), "P002-TEST-146 pool accepted foreign component")

		local range = VirtualizedBinder.visibleRange(10000, 100, 500, 1000, 2)
		assert(
			range.first == 9 and range.last == 17 and range.count == 9,
			"P002-TEST-147 visible range"
		)
		local items = {}
		for index = 1, 10000 do
			items[index] = "card_" .. tostring(index)
		end
		local visible = VirtualizedBinder.project(items, range)
		assert(#visible == 9, "P002-TEST-148 virtual cell count")
		assert(visible[1].index == 9 and visible[9].index == 17, "P002-TEST-149 virtual indices")
		local empty = VirtualizedBinder.visibleRange(0, 100, 500, 0, 2)
		assert(empty.count == 0, "P002-TEST-150 empty virtualization")
		assert(
			#PreloadManifest.fixtureNames == 2
				and #PreloadManifest.fixtureNames <= PreloadManifest.maximumInstances,
			"P002-TEST-218 preload bound"
		)
	end)

	addTest("P002-TEST-019-guided-formation-authority-and-reward", function()
		local profile = ProfileSchema.newBlank(currencyIds, 1000, 1, 1)
		local uidCounter = 0
		local inventory = newInventoryService({
			catalog = LaunchCatalog,
			errors = ErrorRegistry,
			uidFactory = function()
				uidCounter += 1
				return "guided_card_" .. tostring(uidCounter)
			end,
			clock = function()
				return 1000
			end,
		})
		local starter = StarterPackService.new({
			catalog = LaunchCatalog,
			inventory = inventory,
			canonical = CanonicalValue,
			errors = ErrorRegistry,
		})
		local opened = starter:apply(profile, 42, "guided_starter_1", RandomService.new(9001))
		assert(opened.ok and #opened.cards == 5, "P002-TEST-151 guided starter")
		local deck = DeckService.new({
			catalog = LaunchCatalog,
			inventory = inventory,
			errors = ErrorRegistry,
		})
		for _, card in opened.cards do
			local owned = profile.cards[card.instanceId]
			assert(
				deck:equip(profile, 42, card.instanceId, owned.slotKey).ok,
				"P002-TEST-152 guided equip"
			)
		end
		local calculationDependencies = {
			catalog = LaunchCatalog,
			config = LaunchConfig,
			formationDetector = FormationDetector,
			jokerRegistry = JokerRegistry,
			safeNumber = SafeNumber,
		}
		local guided = GuidedFormationService.new({
			inventory = inventory,
			errors = ErrorRegistry,
			catalogVersion = 1,
			configVersion = 1,
			cashCap = 999999999999,
			calculate = function(input: any): any
				return ScoreCalculator.calculate(calculationDependencies, input)
			end,
			projectCalculation = ClientProjection.calculation,
		})
		local submitted = {
			opened.cards[1].instanceId,
			opened.cards[2].instanceId,
			opened.cards[3].instanceId,
			opened.cards[4].instanceId,
		}
		local rewarded = guided:apply(profile, 42, submitted)
		assert(rewarded.ok, "P002-TEST-153 guided submission failed")
		assert(rewarded.formationId == "monosuit", "P002-TEST-154 guided formation")
		assert(rewarded.reward.cash > 0, "P002-TEST-155 guided reward")
		assert(profile.currencies.cash == rewarded.reward.cash, "P002-TEST-156 reward not applied")
		assert(rewarded.calculation.accepted, "P002-TEST-157 calculation projection")

		local duplicate = guided:apply(profile, 42, {
			submitted[1],
			submitted[1],
			submitted[3],
			submitted[4],
		})
		assert(not duplicate.ok, "P002-TEST-158 duplicate guided card")
		assert(
			duplicate.code == ErrorRegistry.codes.formationInvalid,
			"P002-TEST-159 duplicate code"
		)
		profile.activeDeck[profile.cards[submitted[4]].slotKey] = nil
		local inactive = guided:apply(profile, 42, submitted)
		assert(not inactive.ok, "P002-TEST-160 inactive card submitted")
		assert(inactive.code == ErrorRegistry.codes.formationInvalid, "P002-TEST-161 inactive code")
	end)

	addTest("P002-TEST-020-projection-privacy-and-client-authority", function()
		local profile = ProfileSchema.newBlank(currencyIds, 1000, 1, 1)
		profile.session = {
			token = "private_session_token",
			jobId = "private_job",
			placeVersion = 10,
			heartbeatAt = 1000,
		}
		profile.processedOperations.private_operation = {
			fingerprint = "private_fingerprint",
			result = { ok = true, code = "ok" },
		}
		local inventory = newInventoryService({
			catalog = LaunchCatalog,
			errors = ErrorRegistry,
			uidFactory = function()
				return "projection_card_1"
			end,
			clock = function()
				return 1000
			end,
		})
		assert(
			inventory:createCard(profile, 42, LaunchCatalog.identities[1].id, {}, {
				originType = "private_origin",
				originId = "private_origin_id",
			}).ok,
			"P002-TEST-162 projection card"
		)
		local snapshot = ProfileProjection.snapshot(profile, inventory, true, "isolated_data_store")
		assert(snapshot.revision == 0 and snapshot.writable, "P002-TEST-163 snapshot header")
		assert(snapshot.session == nil, "P002-TEST-164 session leaked")
		assert(snapshot.processedOperations == nil, "P002-TEST-165 receipt leaked")
		assert(snapshot.cards[1].provenance == nil, "P002-TEST-166 provenance leaked")
		local encoded = CanonicalValue.encode(snapshot)
		assert(not encoded:find("private_session_token", 1, true), "P002-TEST-167 token leaked")
		assert(not encoded:find("private_fingerprint", 1, true), "P002-TEST-168 fingerprint leaked")
		local page = ProfileProjection.binderPage(profile, inventory, nil, 1)
		assert(#page.cards == 1 and page.total == 1, "P002-TEST-169 binder projection")

		local state = ClientState.new()
		local ready = ClientState.applyMessage(
			state,
			{ ok = true, code = "bootstrap.ready", snapshot = snapshot }
		)
		assert(ready.phase == "ready" and ready.snapshot == snapshot, "P002-TEST-170 client ready")
		local rejected = ClientState.applyMessage(ready, { ok = false, code = "state.stale" })
		assert(rejected.snapshot == snapshot, "P002-TEST-171 rejection invented state")
		local malformed = ClientState.applyMessage(ready, { ok = "yes", code = "ok" })
		assert(malformed.phase == "maintenance", "P002-TEST-172 malformed server message")
		assert(
			malformed.snapshot ~= snapshot and not malformed.snapshot.writable,
			"P002-TEST-173 malformed message retained mutation authority"
		)
		local readOnly = ClientState.applyMessage(ready, { ok = false, code = "profile.read_only" })
		assert(
			readOnly.phase == "read_only" and not readOnly.snapshot.writable and snapshot.writable,
			"P002-TEST-249 read only authority"
		)
		local unavailable =
			ClientState.applyMessage(ready, { ok = false, code = "storage.unavailable" })
		assert(
			unavailable.phase == "maintenance" and not unavailable.snapshot.writable,
			"P002-TEST-250 maintenance authority"
		)
		local staleSnapshot = table.clone(snapshot)
		staleSnapshot.revision = snapshot.revision - 1
		local stale = ClientState.applyMessage(
			ready,
			{ ok = true, code = "bootstrap.ready", snapshot = staleSnapshot }
		)
		assert(stale.snapshot == snapshot, "P002-TEST-176 stale snapshot replaced current state")
		local duplicate = ClientState.applyMessage(ready, {
			ok = true,
			code = "bootstrap.ready",
			snapshot = snapshot,
		})
		assert(
			duplicate.phase == ready.phase and duplicate.snapshot == snapshot,
			"P002-TEST-251 duplicate response changed state"
		)
	end)

	addTest("P002-TEST-021-complete-action-hostile-and-rate-matrix", function()
		local now = 0
		local limiter = TokenBuckets.new(ActionRegistry, function()
			return now
		end)
		for actionIndex, action in ActionRegistry.actions do
			local payload = validPayload(action)
			local accepted = EnvelopeValidator.validate(
				ActionRegistry,
				ErrorRegistry,
				envelope(action.id, payload)
			)
			assert(accepted.accepted, "P002-TEST-178 generated valid payload rejected")

			local unknown = CanonicalValue.copy(payload)
			unknown.unexpected = true
			expectCode(envelope(action.id, unknown), ErrorRegistry.codes.unknownField)

			for name, spec in action.schema.fields do
				if spec.required ~= false then
					local missing = CanonicalValue.copy(payload)
					missing[name] = nil
					expectCode(envelope(action.id, missing), ErrorRegistry.codes.payloadInvalid)
				end
				local wrongType = CanonicalValue.copy(payload)
				wrongType[name] = if spec.kind == "boolean" then "true" else false
				expectCode(envelope(action.id, wrongType), ErrorRegistry.codes.typeInvalid)

				if spec.kind == "integer" then
					local fractional = CanonicalValue.copy(payload)
					fractional[name] = (spec.min or 0) + 0.5
					expectCode(envelope(action.id, fractional), ErrorRegistry.codes.boundsInvalid)
					local nonfinite = CanonicalValue.copy(payload)
					nonfinite[name] = math.huge
					expectCode(envelope(action.id, nonfinite), ErrorRegistry.codes.numberNonfinite)
					local above = CanonicalValue.copy(payload)
					above[name] = spec.max + 1
					expectCode(envelope(action.id, above), ErrorRegistry.codes.boundsInvalid)
				elseif spec.kind == "stable_id" or spec.kind == "request_id" then
					local above = CanonicalValue.copy(payload)
					above[name] = string.rep("a", spec.maxLength + 1)
					expectCode(envelope(action.id, above), ErrorRegistry.codes.boundsInvalid)
				elseif spec.kind == "array" then
					local above = CanonicalValue.copy(payload)
					local values = {}
					for index = 1, spec.maxItems + 1 do
						local value = validValue(spec.item)
						if type(value) == "string" then
							value ..= "_" .. tostring(index)
						end
						table.insert(values, value)
					end
					above[name] = values
					expectCode(envelope(action.id, above), ErrorRegistry.codes.boundsInvalid)
				end
			end

			local userKey = "rate_user_" .. tostring(actionIndex)
			for _ = 1, action.rate.capacity do
				assert(limiter:consume(userKey, action.id), "P002-TEST-179 action rate rejected")
			end
			assert(not limiter:consume(userKey, action.id), "P002-TEST-180 action rate exceeded")
		end

		local globalUser = "global_rate_user"
		for _, action in ActionRegistry.actions do
			assert(limiter:consume(globalUser, action.id), "P002-TEST-181 global capacity rejected")
		end
		assert(
			not limiter:consume(globalUser, "bootstrap.request"),
			"P002-TEST-182 global burst exceeded"
		)
		now = 1
		assert(
			limiter:consume(globalUser, "bootstrap.request"),
			"P002-TEST-183 global refill failed"
		)
	end)

	addTest("P002-TEST-022-profile-retry-dirty-flush-and-shutdown", function()
		local adapter = newMemoryAdapter()
		adapter.failuresRemaining = 2
		local environment = {
			now = 1000,
			tokens = 0,
			jobId = "job_retry",
			placeVersion = 10,
		}
		local store = newProfileStore(adapter, environment)
		local acquired = store:acquire("user_retry")
		assert(acquired.ok and acquired.attempts == 3, "P002-TEST-184 retry acquisition")
		assert(
			CanonicalValue.encode(environment.retryDelaysMilliseconds) == "a2[d250;d500;]",
			"P002-TEST-185 retry schedule"
		)
		environment.retryDelaysMilliseconds = {}
		environment.now = 1001
		adapter.failuresRemaining = 2
		local heartbeat = store:heartbeat("user_retry")
		assert(heartbeat.ok and heartbeat.attempts == 3, "P002-TEST-236 heartbeat retry")
		assert(store:state("user_retry").writable, "P002-TEST-237 heartbeat closed writable state")
		assert(
			CanonicalValue.encode(environment.retryDelaysMilliseconds) == "a2[d250;d500;]",
			"P002-TEST-238 heartbeat retry schedule"
		)

		local stagedProfile = CanonicalValue.copy(store:get("user_retry"))
		stagedProfile.revision = 1
		stagedProfile.settings.lowGraphics = true
		assert(store:stage("user_retry", 0, stagedProfile).ok, "P002-TEST-186 stage failed")
		local pending = store:flush("user_retry", false)
		assert(pending.ok and pending.pending, "P002-TEST-187 early flush not deferred")
		environment.now = 1031
		local flushed = store:flush("user_retry", false)
		assert(flushed.ok and flushed.flushed, "P002-TEST-188 timed flush failed")
		local stored = ProfileCodec.decode(ProfileSchema, CanonicalValue, adapter.data)
		assert(stored.revision == 1 and stored.settings.lowGraphics, "P002-TEST-189 flush drift")

		local shutdownProfile = CanonicalValue.copy(store:get("user_retry"))
		shutdownProfile.revision = 2
		shutdownProfile.settings.reducedMotion = true
		assert(store:stage("user_retry", 1, shutdownProfile).ok, "P002-TEST-190 shutdown stage")
		local shutdown = store:shutdown()
		assert(shutdown.ok and shutdown.released == 1, "P002-TEST-191 shutdown release")
		stored = ProfileCodec.decode(ProfileSchema, CanonicalValue, adapter.data)
		assert(stored.revision == 2 and stored.session == nil, "P002-TEST-192 shutdown persistence")
		assert(
			store:acquire("user_after_shutdown").code == ErrorRegistry.codes.profileReadOnly,
			"P002-TEST-193 shutdown accepted acquire"
		)

		local failureAdapter = newMemoryAdapter()
		local failureEnvironment = {
			now = 2000,
			tokens = 0,
			jobId = "job_flush_failure",
			placeVersion = 10,
		}
		local failureStore = newProfileStore(failureAdapter, failureEnvironment)
		assert(failureStore:acquire("user_flush_failure").ok, "P002-TEST-239 failure acquire")
		local failureProfile = CanonicalValue.copy(failureStore:get("user_flush_failure"))
		failureProfile.revision = 1
		failureProfile.settings.reducedFlash = true
		assert(
			failureStore:stage("user_flush_failure", 0, failureProfile).ok,
			"P002-TEST-240 failure stage"
		)
		local durableBeforeFailure = CanonicalValue.encode(failureAdapter.data)
		failureAdapter.failuresRemaining = ProfilePolicy.maxRetries + 1
		local failedFlush = failureStore:flush("user_flush_failure", true)
		assert(
			not failedFlush.ok
				and failedFlush.code == ErrorRegistry.codes.storageUnavailable
				and failedFlush.attempts == ProfilePolicy.maxRetries + 1,
			"P002-TEST-241 flush exhaustion"
		)
		assert(
			CanonicalValue.encode(failureAdapter.data) == durableBeforeFailure,
			"P002-TEST-242 failed flush changed durable state"
		)
		local failedState = failureStore:state("user_flush_failure")
		assert(
			failedState.ready and not failedState.writable and failedState.dirty,
			"P002-TEST-243 failed flush safe mode"
		)
		local prohibited = CanonicalValue.copy(failureStore:get("user_flush_failure"))
		prohibited.revision = 2
		assert(
			failureStore:stage("user_flush_failure", 1, prohibited).code
				== ErrorRegistry.codes.profileReadOnly,
			"P002-TEST-244 safe mode accepted mutation"
		)
		local failedShutdown = failureStore:shutdown()
		assert(
			not failedShutdown.ok and failedShutdown.remaining == 1,
			"P002-TEST-245 failed session released"
		)

		local deadlineAdapter = newMemoryAdapter()
		local deadlineEnvironment = {
			now = 3000,
			tokens = 0,
			jobId = "job_deadline",
			placeVersion = 10,
			advanceClockOnSleep = true,
		}
		local deadlineStore = newProfileStore(deadlineAdapter, deadlineEnvironment)
		assert(deadlineStore:acquire("user_deadline").ok, "P002-TEST-246 deadline acquire")
		deadlineAdapter.failuresRemaining = ProfilePolicy.maxRetries + 1
		local deadlineShutdown = deadlineStore:shutdown(deadlineEnvironment.now + 0.2)
		assert(
			not deadlineShutdown.ok
				and deadlineShutdown.deadlineExceeded
				and deadlineShutdown.remaining == 1
				and deadlineShutdown.outcomes.user_deadline.deadlineExceeded,
			"P002-TEST-247 shutdown deadline"
		)
	end)

	addTest("P002-TEST-023-transaction-stage-failure-and-response-recovery", function()
		local drainClock = 0
		local draining = newTransactionService({
			profileStore = {},
			canonical = {},
			policy = ProfilePolicy,
			errors = ErrorRegistry,
			clock = function()
				return drainClock
			end,
			sleep = function(seconds: number)
				drainClock += seconds
			end,
		})
		draining.active.user_drain = true
		local drainOutcome = draining:drain(0.1)
		assert(
			not drainOutcome.ok and drainOutcome.remaining == 1 and drainClock == 0.1,
			"P002-TEST-248 transaction drain deadline"
		)

		local precommitStages = {
			"before_validation",
			"before_apply",
			"after_apply",
			"before_receipt",
			"before_commit",
		}
		local function operation(): any
			return {
				id = "operation_stage_0001",
				kind = "fixture.reward",
				payload = { amount = 5 },
				expectedRevision = 0,
				resultReference = "reward_stage_0001",
				apply = function(profile: any): any
					profile.currencies.cash += 5
					return { ok = true, code = "reward.committed", amount = 5 }
				end,
			}
		end
		for _, failedStage in precommitStages do
			local adapter = newMemoryAdapter()
			local store = newProfileStore(adapter, {
				now = 1000,
				tokens = 0,
				jobId = "job_" .. failedStage,
				placeVersion = 10,
			})
			assert(store:acquire("user_stage").ok, "P002-TEST-194 stage acquisition")
			local transactions = newTransactionService({
				profileStore = store,
				canonical = CanonicalValue,
				policy = ProfilePolicy,
				errors = ErrorRegistry,
				failureInjector = function(stage: string): boolean
					return stage ~= failedStage
				end,
			})
			local failed = transactions:execute("user_stage", operation())
			assert(not failed.ok, "P002-TEST-195 injected stage succeeded")
			local profile = store:get("user_stage")
			assert(
				profile.revision == 0
					and profile.currencies.cash == 0
					and profile.processedOperations.operation_stage_0001 == nil,
				"P002-TEST-196 precommit stage mutated"
			)
		end

		for _, failedStage in { "after_commit", "before_response" } do
			local adapter = newMemoryAdapter()
			local store = newProfileStore(adapter, {
				now = 1000,
				tokens = 0,
				jobId = "job_" .. failedStage,
				placeVersion = 10,
			})
			assert(store:acquire("user_response").ok, "P002-TEST-197 response acquisition")
			local interrupted = newTransactionService({
				profileStore = store,
				canonical = CanonicalValue,
				policy = ProfilePolicy,
				errors = ErrorRegistry,
				failureInjector = function(stage: string): boolean
					return stage ~= failedStage
				end,
			})
			local lost = interrupted:execute("user_response", operation())
			assert(not lost.ok and lost.committed, "P002-TEST-198 response loss not committed")
			local replayed = newTransactionService({
				profileStore = store,
				canonical = CanonicalValue,
				policy = ProfilePolicy,
				errors = ErrorRegistry,
			}):execute("user_response", operation())
			assert(replayed.ok and replayed.replayed, "P002-TEST-199 response replay failed")
			assert(
				store:get("user_response").currencies.cash == 5
					and store:get("user_response").revision == 1,
				"P002-TEST-200 response replay duplicated"
			)
		end
	end)

	addTest("P002-TEST-024-collection-joker-and-removal-protection", function()
		local profile = ProfileSchema.newBlank(currencyIds, 1000, 1, 1)
		local collection = CollectionService.new()
		local inventoryStore = InventoryStore.new()
		local candidates = { "card_one", "card_one", "joker_one", "card_two" }
		local candidateIndex = 0
		local inventory = InventoryService.new({
			catalog = LaunchCatalog,
			errors = ErrorRegistry,
			inventoryStore = inventoryStore,
			collection = collection,
			uidFactory = function()
				candidateIndex += 1
				return candidates[candidateIndex]
			end,
			clock = function()
				return 1000
			end,
		})
		local first = inventory:createCard(profile, 42, LaunchCatalog.identities[1].id, {}, {
			originType = "fixture",
			originId = "fixture_card_one",
		})
		assert(first.ok and first.card.uid == "card_one", "P002-TEST-201 first card")
		local joker = inventory:createJoker(profile, 42, LaunchCatalog.jokers[1].id, {
			originType = "fixture",
			originId = "fixture_joker_one",
		})
		assert(joker.ok and joker.joker.uid == "joker_one", "P002-TEST-202 joker collision")
		assert(
			collection:isDiscovered(profile, "jokers", LaunchCatalog.jokers[1].id),
			"P002-TEST-203 joker discovery"
		)
		assert(collection:recordBest(profile, "guided_cash", 10), "P002-TEST-204 best record")
		assert(not collection:recordBest(profile, "guided_cash", 9), "P002-TEST-205 best regressed")
		assert(collection:recordBest(profile, "guided_cash", 11), "P002-TEST-206 best not improved")

		assert(
			not inventory:isProtectedForRemoval(profile, 42, first.card.uid).ok,
			"P002-TEST-207 last copy removable"
		)
		local second = inventory:createCard(profile, 42, LaunchCatalog.identities[1].id, {}, {
			originType = "fixture",
			originId = "fixture_card_two",
		})
		assert(second.ok and second.card.uid == "card_two", "P002-TEST-208 second card")
		assert(
			inventory:isProtectedForRemoval(profile, 42, first.card.uid).ok,
			"P002-TEST-209 duplicate copy protected"
		)
		first.card.flags.favorite = true
		assert(
			not inventory:isProtectedForRemoval(profile, 42, first.card.uid).ok,
			"P002-TEST-210 favorite removable"
		)
		first.card.flags.favorite = false
		profile.activeDeck[first.card.slotKey] = first.card.uid
		assert(
			not inventory:isProtectedForRemoval(profile, 42, first.card.uid).ok,
			"P002-TEST-211 equipped removable"
		)
		first.card.locks.trade = true
		local projected = inventory:projectCard(first.card)
		assert(projected.locked and projected.tradeLocked, "P002-TEST-219 trade projection")

		local saved = ProfileCodec.encode(ProfileSchema, CanonicalValue, profile)
		assert(
			type(saved.x.f) == "table" and type(saved.x.j) == "table",
			"P002-TEST-212 compact discovery"
		)
		local decoded = ProfileCodec.decode(ProfileSchema, CanonicalValue, saved)
		assert(
			CanonicalValue.encode(decoded.discovery) == CanonicalValue.encode(profile.discovery),
			"P002-TEST-213 discovery round trip"
		)
		assert(inventory:assertConservation(decoded, 42) == 2, "P002-TEST-214 card conservation")
		assert(
			inventory:assertJokerConservation(decoded, 42) == 1,
			"P002-TEST-215 joker conservation"
		)
	end)

	addTest("P002-TEST-025-deterministic-evidence-packet", function()
		local reports, hashes = Phase002Evidence.build()
		local expected = serde.decode("json", fs.readFile("tests/phase002/expected-hashes.json"))
		assert(
			ArtifactCore.canonicalJson(hashes) == ArtifactCore.canonicalJson(expected),
			"P002-TEST-249 evidence hash drift"
		)
		assert(
			reports.recovery.final.profileHash == reports.recovery.final.rejoinProfileHash,
			"P002-TEST-250 rejoin state drift"
		)
		assert(
			reports.profileSizes.warningBytes >= ProfilePolicy.warningBytes
				and reports.profileSizes.blockedBytes > ProfilePolicy.blockingBytes,
			"P002-TEST-251 size evidence boundary"
		)
	end)
end

return table.freeze(Phase002Test)
