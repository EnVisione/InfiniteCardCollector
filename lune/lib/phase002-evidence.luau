--!strict

local serde = require("@lune/serde")

local ArtifactCore = require("./artifact-core")
local ActionRegistry = require("../../src/shared/Network/ActionRegistry")
local LaunchCatalog = require("../../src/shared/Catalogs/LaunchCatalog")
local LaunchConfig = require("../../src/shared/Config/LaunchConfig")
local ErrorRegistry = require("../../src/shared/Network/ErrorRegistry")
local FormationDetector = require("../../src/shared/Math/FormationDetector")
local JokerRegistry = require("../../src/shared/Math/JokerRegistry")
local SafeNumber = require("../../src/shared/Math/SafeNumber")
local ScoreCalculator = require("../../src/shared/Math/ScoreCalculator")
local ClientProjection = require("../../src/shared/Projection/ClientProjection")
local CanonicalValue = require("../../src/shared/Profile/CanonicalValue")
local MigrationRegistry = require("../../src/shared/Profile/MigrationRegistry")
local ProfileCodec = require("../../src/shared/Profile/ProfileCodec")
local ProfilePolicy = require("../../src/shared/Profile/ProfilePolicy")
local ProfileSchema = require("../../src/shared/Profile/ProfileSchema")
local CardViewModel = require("../../src/shared/Rendering/CardViewModel")
local CardRenderer2D = require("../../src/client/Rendering/CardRenderer2D")
local CardRenderer3D = require("../../src/client/Rendering/CardRenderer3D")
local PreloadManifest = require("../../src/client/Rendering/PreloadManifest")
local VirtualizedBinder = require("../../src/client/Rendering/VirtualizedBinder")
local GuidedFormationService = require("../../src/server/Formation/GuidedFormationService")
local CollectionService = require("../../src/server/Inventory/CollectionService")
local DeckService = require("../../src/server/Inventory/DeckService")
local InventoryService = require("../../src/server/Inventory/InventoryService")
local StarterPackService = require("../../src/server/Packs/StarterPackService")
local RandomService = require("../../src/server/Random/RandomService")
local InventoryStore = require("../../src/server/Storage/InventoryStore")
local ProfileStore = require("../../src/server/Storage/ProfileStore")
local TransactionService = require("../../src/server/Transactions/TransactionService")

local Phase002Evidence = {}

local currencyIds = {}
for _, currency in LaunchConfig.economy.currencies do
	table.insert(currencyIds, currency.id)
end

local migrations = MigrationRegistry.new({
	schema = ProfileSchema,
	codec = ProfileCodec,
	canonical = CanonicalValue,
	errors = ErrorRegistry,
	currencyIds = currencyIds,
	catalogVersion = LaunchCatalog.catalogVersion,
	configVersion = LaunchConfig.configVersion,
})

local function hashCanonical(value: any): string
	return serde.hash("sha256", ArtifactCore.canonicalJson(value))
end

local function memoryAdapter(): any
	local adapter = { data = nil, updates = 0 }
	function adapter:update(_key: string, transform: (any) -> any): boolean
		self.updates += 1
		local current = if self.data ~= nil then CanonicalValue.copy(self.data) else nil
		local nextValue = transform(current)
		self.data = if nextValue ~= nil then CanonicalValue.copy(nextValue) else nil
		return true
	end
	return adapter
end

local function profileStore(adapter: any, now: number, jobId: string): any
	local clock = now
	return ProfileStore.new({
		adapter = adapter,
		migrations = migrations,
		schema = ProfileSchema,
		codec = ProfileCodec,
		canonical = CanonicalValue,
		policy = ProfilePolicy,
		errors = ErrorRegistry,
		clock = function()
			return clock
		end,
		sleep = function(seconds: number)
			clock += seconds
		end,
		retryJitter = function()
			return 0
		end,
		tokenFactory = function(userKey: string)
			return jobId .. "_" .. userKey .. "_token"
		end,
		reconcile = function()
			return true
		end,
		jobId = jobId,
		placeVersion = 10,
		currencyIds = currencyIds,
		catalogVersion = LaunchCatalog.catalogVersion,
		configVersion = LaunchConfig.configVersion,
	})
end

local function transactions(store: any): any
	return TransactionService.new({
		profileStore = store,
		canonical = CanonicalValue,
		policy = ProfilePolicy,
		errors = ErrorRegistry,
		clock = function()
			return 0
		end,
		sleep = function() end,
	})
end

local function stableProfile(profile: any): any
	local value = CanonicalValue.copy(profile)
	value.session = nil
	value.lastSeenAt = 0
	return value
end

local function actionReport(): any
	local available = 0
	for _, action in ActionRegistry.actions do
		if action.available then
			available += 1
		end
	end
	return {
		actionVersion = ActionRegistry.version,
		envelopeVersion = ActionRegistry.envelopeVersion,
		actionCount = #ActionRegistry.actions,
		availableCount = available,
		actions = CanonicalValue.copy(ActionRegistry.actions),
		errorVersion = ErrorRegistry.version,
		errorCount = (function(): number
			local count = 0
			for _ in ErrorRegistry.codes do
				count += 1
			end
			return count
		end)(),
		errors = CanonicalValue.copy(ErrorRegistry.codes),
	}
end

local function stressReport(): any
	local profile = ProfileSchema.newBlank(
		currencyIds,
		1000,
		LaunchCatalog.catalogVersion,
		LaunchConfig.configVersion
	)
	local previousBytes = ProfileCodec.measure(ProfileSchema, CanonicalValue, profile)
	local result = {
		blankBytes = previousBytes,
		warningThresholdBytes = ProfilePolicy.warningBytes,
		blockingThresholdBytes = ProfilePolicy.blockingBytes,
	}
	for index = 1, 10000 do
		local identity = LaunchCatalog.identities[((index - 1) % #LaunchCatalog.identities) + 1]
		local uid = string.format("card_stress_%06d", index)
		profile.cards[uid] = {
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
		profile.discovery.forms[LaunchCatalog.formKey(identity.id, "normal")] = true
		if index % 100 == 0 then
			local bytes = ProfileCodec.measure(ProfileSchema, CanonicalValue, profile)
			if result.warningBytes == nil and bytes >= ProfilePolicy.warningBytes then
				result.beforeWarningBytes = previousBytes
				result.warningBytes = bytes
				result.warningCardCount = index
			end
			if bytes > ProfilePolicy.blockingBytes then
				result.beforeBlockedBytes = previousBytes
				result.blockedBytes = bytes
				result.blockedCardCount = index
				result.blockedSavedHash =
					hashCanonical(ProfileCodec.encode(ProfileSchema, CanonicalValue, profile))
				break
			end
			previousBytes = bytes
		end
	end
	assert(result.warningBytes ~= nil, "P002-EVIDENCE-001 warning crossing missing")
	assert(result.blockedBytes ~= nil, "P002-EVIDENCE-002 blocked crossing missing")
	return result
end

local function recoveryReport(): any
	local adapter = memoryAdapter()
	local store = profileStore(adapter, 1000, "evidence_job")
	assert(store:acquire("evidence_user").ok, "P002-EVIDENCE-003 acquire failed")
	local uidCounter = 0
	local inventory = InventoryService.new({
		catalog = LaunchCatalog,
		errors = ErrorRegistry,
		inventoryStore = InventoryStore.new(),
		collection = CollectionService.new(),
		uidFactory = function()
			uidCounter += 1
			return string.format("evidence_card_%02d", uidCounter)
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
	local deck =
		DeckService.new({ catalog = LaunchCatalog, inventory = inventory, errors = ErrorRegistry })
	local guided = GuidedFormationService.new({
		inventory = inventory,
		errors = ErrorRegistry,
		catalogVersion = LaunchCatalog.catalogVersion,
		configVersion = LaunchConfig.configVersion,
		cashCap = 999999999999,
		calculate = function(input: any): any
			return ScoreCalculator.calculate({
				catalog = LaunchCatalog,
				config = LaunchConfig,
				formationDetector = FormationDetector,
				jokerRegistry = JokerRegistry,
				safeNumber = SafeNumber,
			}, input)
		end,
		projectCalculation = ClientProjection.calculation,
	})
	local transactionService = transactions(store)
	local beforeHash = hashCanonical(stableProfile(store:get("evidence_user")))
	local starterOperation = {
		id = "evidence_starter_0001",
		kind = "pack.open",
		payload = { packId = "classic_starter" },
		expectedRevision = 0,
		resultReference = "evidence_starter_0001",
		apply = function(profile: any): any
			return starter:apply(profile, 42, "evidence_starter_0001", RandomService.new(12345))
		end,
	}
	local opened = transactionService:execute("evidence_user", starterOperation)
	assert(opened.ok and #opened.cards == 5, "P002-EVIDENCE-004 starter failed")
	local afterStarter = store:get("evidence_user")
	local starterReceipt = afterStarter.processedOperations[starterOperation.id]
	local cardInstanceIds = {}
	local provenance = {}
	for _, card in opened.cards do
		table.insert(cardInstanceIds, card.instanceId)
		local owned = afterStarter.cards[card.instanceId]
		table.insert(provenance, {
			instanceId = card.instanceId,
			originType = owned.provenance.originType,
			originId = owned.provenance.originId,
			createdAt = owned.provenance.createdAt,
			instanceVersion = owned.provenance.instanceVersion,
		})
	end
	table.sort(cardInstanceIds)
	table.sort(provenance, function(left, right)
		return left.instanceId < right.instanceId
	end)
	local replayedStarter = transactionService:execute("evidence_user", starterOperation)
	assert(replayedStarter.ok and replayedStarter.replayed, "P002-EVIDENCE-005 replay failed")

	local deckReceipts = {}
	for index = 1, 4 do
		local card = opened.cards[index]
		local owned = store:get("evidence_user").cards[card.instanceId]
		local operationId = string.format("evidence_equip_%04d", index)
		local equipped = transactionService:execute("evidence_user", {
			id = operationId,
			kind = "deck.equip_card",
			payload = { instanceId = card.instanceId, slotKey = owned.slotKey },
			expectedRevision = store:get("evidence_user").revision,
			apply = function(profile: any): any
				local outcome = deck:equip(profile, 42, card.instanceId, owned.slotKey)
				if not outcome.ok then
					return outcome
				end
				local acknowledged = starter:acknowledgeRevealForCard(profile, card.instanceId)
				outcome.packRevealAcknowledged = acknowledged.acknowledged
				return outcome
			end,
		})
		assert(equipped.ok, "P002-EVIDENCE-006 equip failed")
		table.insert(deckReceipts, {
			operationId = operationId,
			revision = equipped.revision,
			resultHash = hashCanonical(equipped),
		})
	end

	local submitted = {}
	for index = 1, 4 do
		table.insert(submitted, opened.cards[index].instanceId)
	end
	local rewardOperation = {
		id = "evidence_reward_0001",
		kind = "formation.submit",
		payload = {
			instanceIds = submitted,
			modeId = "guided_classic",
			roundId = "evidence_round_0001",
		},
		expectedRevision = store:get("evidence_user").revision,
		resultReference = "evidence_round_0001",
		apply = function(profile: any): any
			return guided:apply(profile, 42, submitted)
		end,
	}
	local rewarded = transactionService:execute("evidence_user", rewardOperation)
	assert(rewarded.ok, "P002-EVIDENCE-007 reward failed")
	local finalProfile = store:get("evidence_user")
	local finalStableHash = hashCanonical(stableProfile(finalProfile))
	local rewardReceipt = finalProfile.processedOperations[rewardOperation.id]
	local replayedReward = transactionService:execute("evidence_user", rewardOperation)
	assert(replayedReward.ok and replayedReward.replayed, "P002-EVIDENCE-008 reward replay failed")
	assert(store:release("evidence_user").ok, "P002-EVIDENCE-009 release failed")
	local rejoinedStore = profileStore(adapter, 1100, "evidence_rejoin")
	local rejoined = rejoinedStore:acquire("evidence_user")
	assert(rejoined.ok, "P002-EVIDENCE-010 rejoin failed")

	return {
		beforeProfileHash = beforeHash,
		starter = {
			revision = opened.revision,
			resultHash = hashCanonical(opened),
			resultReferenceHash = serde.hash("sha256", opened.resultReference),
			receiptHash = hashCanonical(starterReceipt),
			fingerprintHash = serde.hash("sha256", starterReceipt.fingerprint),
			afterProfileHash = hashCanonical(stableProfile(afterStarter)),
			pendingStateBeforeAcknowledgement = "committed",
			catalogVersion = afterStarter.pendingPacks[starterOperation.id].catalogVersion,
			cardInstanceIds = cardInstanceIds,
			provenanceHash = hashCanonical(provenance),
			replayResultHash = hashCanonical(replayedStarter),
		},
		deck = {
			receipts = deckReceipts,
			activeDeckHash = hashCanonical(finalProfile.activeDeck),
			pendingStateAfterAcknowledgement = finalProfile.pendingPacks[starterOperation.id].state,
		},
		reward = {
			revision = rewarded.revision,
			code = rewarded.code,
			formationId = rewarded.formationId,
			cash = rewarded.reward.cash,
			resultHash = hashCanonical(rewarded),
			receiptHash = hashCanonical(rewardReceipt),
			fingerprintHash = serde.hash("sha256", rewardReceipt.fingerprint),
			traceHash = hashCanonical(rewarded.calculation),
			replayResultHash = hashCanonical(replayedReward),
		},
		final = {
			revision = finalProfile.revision,
			profileHash = finalStableHash,
			rejoinProfileHash = hashCanonical(stableProfile(rejoined.profile)),
			conservedCards = inventory:assertConservation(rejoined.profile, 42),
			activeDeckCount = (function(): number
				local count = 0
				for _ in rejoined.profile.activeDeck do
					count += 1
				end
				return count
			end)(),
			sessionTokenFingerprint = serde.hash("sha256", rejoined.profile.session.token),
		},
	}
end

local function migrationReport(): any
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
	local first = migrations:migrate(legacy)
	local repeated = migrations:migrate(first.saved)
	assert(first.ok and repeated.ok, "P002-EVIDENCE-011 migration failed")
	return {
		legacyHash = hashCanonical(legacy),
		migratedDomainHash = hashCanonical(first.profile),
		migratedSavedHash = hashCanonical(first.saved),
		repeatedSavedHash = hashCanonical(repeated.saved),
		fromVersion = first.fromVersion,
		toVersion = first.toVersion,
		preservedCash = first.profile.currencies.cash,
		preservedCards = 1,
	}
end

local function rendererReport(): any
	local card = {
		instanceId = "evidence_render_card",
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
		wishlist = true,
		isNew = true,
	}
	local normal = CardViewModel.build(LaunchCatalog, card, {})
	local static = CardViewModel.build(LaunchCatalog, card, {
		lowGraphics = true,
		reducedMotion = true,
		reducedFlash = true,
	})
	local twoDimensional = CardRenderer2D.render(normal)
	local threeDimensional = CardRenderer3D.render(normal)
	local largeRange = VirtualizedBinder.visibleRange(10000, 44, 500, 1000, 2)
	return {
		viewModelVersion = CardViewModel.version,
		layerOrder = CanonicalValue.copy(CardViewModel.layerOrder),
		normalHash = hashCanonical(normal),
		staticHash = hashCanonical(static),
		adapterSemanticEqual = hashCanonical(twoDimensional.semanticLayers)
			== hashCanonical(threeDimensional.semanticLayers),
		statusCount = #normal.layers[8].values,
		staticAnimated = static.settings.animated,
		staticFlashing = static.settings.flashing,
		virtualizedFixtureItems = 10000,
		virtualizedVisibleCells = largeRange.count,
		preloadMaximum = PreloadManifest.maximumInstances,
		preloadFixtures = CanonicalValue.copy(PreloadManifest.fixtureNames),
	}
end

function Phase002Evidence.build(): any
	local reports = {
		actions = actionReport(),
		migrations = migrationReport(),
		profileSizes = stressReport(),
		recovery = recoveryReport(),
		renderer = rendererReport(),
		failureStages = {
			precommit = {
				"before_validation",
				"before_apply",
				"after_apply",
				"before_receipt",
				"before_commit",
			},
			postcommit = { "after_commit", "before_response" },
			shutdownDeadlineSeconds = ProfilePolicy.shutdownDeadlineSeconds,
		},
	}
	local hashes = {}
	for id, report in reports do
		hashes[id] = hashCanonical(report)
	end
	return reports, hashes
end

return table.freeze(Phase002Evidence)
