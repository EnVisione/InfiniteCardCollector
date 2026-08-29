--!strict

local fs = require("@lune/fs")
local serde = require("@lune/serde")

local AssetManifest = require("../src/shared/Assets/AssetManifest")
local AssetManifestBuilder = require("../src/shared/Assets/AssetManifestBuilder")
local LaunchCatalog = require("../src/shared/Catalogs/LaunchCatalog")
local LaunchDeckSetAssets = require("../src/shared/Assets/LaunchDeckSetAssets")
local PresentationResolver = require("../src/shared/Assets/PresentationResolver")
local ComposedCardAssets = require("../src/shared/Assets/ComposedCardAssets")
local SpecialContentAssets = require("../src/shared/Assets/SpecialContentAssets")
local PackService = require("../src/server/Packs/PackService")
local InventoryService = require("../src/server/Inventory/InventoryService")
local InventoryStore = require("../src/server/Storage/InventoryStore")
local CollectionService = require("../src/server/Inventory/CollectionService")
local ProfileSchema = require("../src/shared/Profile/ProfileSchema")
local CanonicalValue = require("../src/shared/Profile/CanonicalValue")
local ErrorRegistry = require("../src/shared/Network/ErrorRegistry")
local RollContract = require("../src/shared/Math/RollContract")
local LaunchConfig = require("../src/shared/Config/LaunchConfig")
local RandomService = require("../src/server/Random/RandomService")
local CardViewModel = require("../src/shared/Rendering/CardViewModel")
local CardRenderer2D = require("../src/client/Rendering/CardRenderer2D")
local CardRenderer3D = require("../src/client/Rendering/CardRenderer3D")
local PackRevealController = require("../src/client/State/PackRevealController")
local ProgressionService = require("../src/server/Progression/ProgressionService")

local Phase003Test = {}

local function hash(char: string, length: number): string
	return string.rep(char, length)
end

local function copy(value: any): any
	if type(value) ~= "table" then
		return value
	end
	local result = {}
	for key, child in value do
		result[key] = copy(child)
	end
	return result
end

local function validManifest(): any
	return {
		artifactVersion = "phase-003-fixture",
		catalogVersion = 1,
		entries = {
			{
				assetVersion = "fixture-1",
				builtIdentity = "ServerStorage.Assets.CardFrames.ClassicFrameFixture",
				builtSha256 = hash("a", 64),
				builtSha512 = hash("b", 128),
				byteBudget = 4096,
				byteSize = 1024,
				dimensions = { height = 256, width = 256 },
				enabled = true,
				fallbackId = "fallback.classic.frame",
				instanceBudget = 8,
				instanceCount = 1,
				id = "card.classic.frame",
				kind = "model",
				memoryBudgetBytes = 65536,
				memoryBytes = 16384,
				poolGroup = "card",
				preloadGroup = "opening.table",
				provenance = {
					license = "all_rights_reserved",
					origin = "original",
					reviewState = "reviewed",
					reviewedAt = "2026-08-29",
					reviewedBy = "maintainer",
				},
				references = { "deck_set_classic", "surface_opening_table" },
				sourceIdentity = "source.classic.frame",
				sourceSha256 = hash("c", 64),
				sourceSha512 = hash("d", 128),
			},
			{
				assetVersion = "fixture-1",
				builtIdentity = "ServerStorage.Assets.CardFrames.ClassicFrameFallback",
				builtSha256 = hash("e", 64),
				builtSha512 = hash("f", 128),
				byteBudget = 4096,
				byteSize = 512,
				dimensions = { height = 256, width = 256 },
				enabled = false,
				fallbackId = "fallback.classic.frame",
				instanceBudget = 8,
				instanceCount = 1,
				id = "fallback.classic.frame",
				kind = "fallback",
				memoryBudgetBytes = 65536,
				memoryBytes = 8192,
				poolGroup = "card",
				preloadGroup = "opening.table",
				provenance = {
					license = "all_rights_reserved",
					origin = "original",
					reviewState = "reviewed",
					reviewedAt = "2026-08-29",
					reviewedBy = "maintainer",
				},
				references = { "fallback.classic.frame", "surface_opening_table" },
				sourceIdentity = "source.classic.frame.fallback",
				sourceSha256 = hash("1", 64),
				sourceSha512 = hash("2", 128),
			},
		},
		manifestVersion = 1,
		poolGroups = {
			{ id = "card", maxBytes = 0, maxInstances = 8 },
		},
		preloadGroups = {
			{ id = "opening.table", maxBytes = 4096, maxInstances = 8 },
		},
		schemaVersion = 1,
	}
end

function Phase003Test.register(addTest: any, expectFailure: any)
	addTest("P003-TEST-001-asset-schema-and-budget", function()
		local source = validManifest()
		local sourceReferences = source.entries[1].references
		local manifest = AssetManifest.validate(source)
		assert(manifest.schemaVersion == 1, "P003-TEST-001 schema version")
		assert(manifest.manifestVersion == 1, "P003-TEST-001 manifest version")
		assert(#manifest.entries == 2, "P003-TEST-001 entry count")
		assert(
			table.isfrozen(manifest) and table.isfrozen(manifest.entries),
			"P003-TEST-001 immutable result"
		)
		assert(manifest.entries[1].byteSize == 1024, "P003-TEST-001 byte size")
		assert(
			manifest.entries[1].provenance.reviewState == "reviewed",
			"P003-TEST-001 review state"
		)
		assert(source.entries[1].references == sourceReferences, "P003-TEST-001 source immutable")
	end)

	addTest("P003-TEST-002-asset-negative-fixtures", function()
		local missingHash = validManifest()
		missingHash.entries[1].builtSha256 = "not-a-hash"
		expectFailure(function()
			AssetManifest.validate(missingHash)
		end, "P003-ASSET-048")

		local overBudget = validManifest()
		overBudget.entries[1].byteSize = 8192
		expectFailure(function()
			AssetManifest.validate(overBudget)
		end, "P003-ASSET-056")

		local missingFallback = validManifest()
		missingFallback.entries[1].fallbackId = "fallback.missing"
		expectFailure(function()
			AssetManifest.validate(missingFallback)
		end, "P003-ASSET-087")

		local unreviewed = validManifest()
		unreviewed.entries[1].provenance.reviewState = "pending"
		expectFailure(function()
			AssetManifest.validate(unreviewed)
		end, "P003-ASSET-024")

		local wrongFallbackKind = validManifest()
		wrongFallbackKind.entries[2].kind = "model"
		expectFailure(function()
			AssetManifest.validate(wrongFallbackKind)
		end, "P003-ASSET-093")
	end)

	addTest("P003-TEST-003-invalidation-reasons", function()
		local previous = validManifest()
		local current = copy(previous)
		current.entries[1].builtSha256 = hash("9", 64)
		current.entries[1].byteSize = 2048
		local reasons = AssetManifest.invalidationReasons(previous, current)
		assert(#reasons == 2, "P003-TEST-003 reason count")
		assert(reasons[1] == "built_changed:card.classic.frame", "P003-TEST-003 built reason")
		assert(reasons[2] == "budget_changed:card.classic.frame", "P003-TEST-003 budget reason")

		local dimensions = copy(previous)
		dimensions.entries[1].dimensions.width = 512
		local dimensionReasons = AssetManifest.invalidationReasons(previous, dimensions)
		assert(#dimensionReasons == 1, "P003-TEST-003 dimensions count")
		assert(
			dimensionReasons[1] == "presentation_changed:card.classic.frame",
			"P003-TEST-003 dimensions reason"
		)

		local preloadBudget = copy(previous)
		preloadBudget.preloadGroups[1].maxBytes = 8192
		local preloadReasons = AssetManifest.invalidationReasons(previous, preloadBudget)
		assert(#preloadReasons == 1, "P003-TEST-003 preload count")
		assert(preloadReasons[1] == "preload_budget_changed", "P003-TEST-003 preload reason")

		local noChange = AssetManifest.invalidationReasons(previous, previous)
		assert(#noChange == 0, "P003-TEST-003 no change")
	end)

	addTest("P003-TEST-004-empty-launch-contract", function()
		local empty = AssetManifest.empty(1, "phase-003-contract")
		local snapshot =
			serde.decode("json", fs.readFile("docs/verification/phase-003-asset-manifest.json"))
		assert(
			empty.catalogVersion == 1 and empty.artifactVersion == "phase-003-contract",
			"P003-TEST-004 identity"
		)
		assert(#empty.entries == 0, "P003-TEST-004 entries")
		assert(#empty.preloadGroups == 1 and #empty.poolGroups == 1, "P003-TEST-004 groups")
		assert(
			snapshot.schemaVersion == AssetManifest.schemaVersion,
			"P003-TEST-004 snapshot schema"
		)
		assert(
			snapshot.manifestVersion == AssetManifest.manifestVersion,
			"P003-TEST-004 snapshot manifest"
		)
		assert(snapshot.catalogVersion == empty.catalogVersion, "P003-TEST-004 snapshot catalog")
		assert(snapshot.artifactVersion == empty.artifactVersion, "P003-TEST-004 snapshot artifact")
		assert(
			#snapshot.allowedKinds == #AssetManifest.allowedKinds,
			"P003-TEST-004 snapshot kinds"
		)
		for index, kind in AssetManifest.allowedKinds do
			assert(snapshot.allowedKinds[index] == kind, "P003-TEST-004 snapshot kind order")
		end
		assert(
			#snapshot.requiredEntryFields == #AssetManifest.requiredEntryFields,
			"P003-TEST-004 snapshot fields"
		)
		for index, field in AssetManifest.requiredEntryFields do
			assert(
				snapshot.requiredEntryFields[index] == field,
				"P003-TEST-004 snapshot field order"
			)
		end
		assert(
			snapshot.budgets.maximumEntryBytes == AssetManifest.budgets.maximumEntryBytes
				and snapshot.budgets.maximumEntryMemoryBytes == AssetManifest.budgets.maximumEntryMemoryBytes
				and snapshot.budgets.maximumEntryInstances == AssetManifest.budgets.maximumEntryInstances
				and snapshot.budgets.maximumPreloadBytes == AssetManifest.budgets.maximumPreloadBytes
				and snapshot.budgets.maximumPreloadInstances
					== AssetManifest.budgets.maximumPreloadInstances,
			"P003-TEST-004 snapshot budgets"
		)
	end)

	addTest("P003-TEST-007-asset-build-inventory", function()
		local source = validManifest()
		local built = AssetManifestBuilder.build({
			artifactVersion = source.artifactVersion,
			catalogVersion = source.catalogVersion,
			entries = { source.entries[2], source.entries[1] },
			poolGroups = source.poolGroups,
			preloadGroups = source.preloadGroups,
		})
		assert(
			table.isfrozen(built) and table.isfrozen(built.inventory),
			"P003-TEST-007 immutable result"
		)
		assert(table.isfrozen(built.inventory.entries[1]), "P003-TEST-007 entry immutable")
		assert(built.manifest.entries[1].id == "card.classic.frame", "P003-TEST-007 sorted entries")
		assert(built.inventory.totalBytes == 1536, "P003-TEST-007 byte inventory")
		assert(built.inventory.totalMemoryBytes == 24576, "P003-TEST-007 memory inventory")
		assert(built.inventory.totalInstances == 2, "P003-TEST-007 instance inventory")
		assert(
			built.inventory.entries[1].builtSha256 == hash("a", 64),
			"P003-TEST-007 hash inventory"
		)
		local duplicateEntry = copy(source.entries[1])
		duplicateEntry.builtSha256 = hash("9", 64)
		local duplicate = {
			artifactVersion = source.artifactVersion,
			catalogVersion = source.catalogVersion,
			entries = { source.entries[1], duplicateEntry, source.entries[2] },
			poolGroups = source.poolGroups,
			preloadGroups = source.preloadGroups,
		}
		expectFailure(function()
			AssetManifestBuilder.build(duplicate)
		end, "P003-ASSET-069")
	end)

	addTest("P003-TEST-008-deckset-pack-service", function()
		local collection = CollectionService.new()
		local currencyIds = {}
		for _, currency in LaunchConfig.economy.currencies do
			table.insert(currencyIds, currency.id)
		end
		local profile = ProfileSchema.newBlank(
			currencyIds,
			100,
			LaunchCatalog.catalogVersion,
			LaunchConfig.configVersion
		)
		profile.currencies.cash = 5000
		local uidCounter = 0
		local inventory = InventoryService.new({
			catalog = LaunchCatalog,
			errors = ErrorRegistry,
			inventoryStore = InventoryStore.new(),
			collection = collection,
			uidFactory = function(_ownerUserId: number, kind: string): string
				uidCounter += 1
				return kind .. "_pack_" .. tostring(uidCounter)
			end,
			clock = function(): number
				return 100
			end,
		})
		local packs = PackService.new({
			catalog = LaunchCatalog,
			config = LaunchConfig,
			inventory = inventory,
			collection = collection,
			canonical = CanonicalValue,
			errors = ErrorRegistry,
			rollContract = RollContract,
		})
		local result =
			packs:open(profile, 42, "pack_request_00000001", "classic", RandomService.new(17))
		assert(result.ok and #result.cards == 5, "P003-TEST-008 five card result")
		assert(profile.currencies.cash == 4500, "P003-TEST-008 price deduction")
		assert(
			profile.pendingPacks.pack_request_00000001.state == "committed",
			"P003-TEST-008 pending result"
		)
		assert(
			profile.pendingPacks.pack_request_00000001.packId == "classic",
			"P003-TEST-008 pending pack id"
		)
		assert(#result.tierRolls == 5, "P003-TEST-008 tier roll count")
		assert(result.rarityOdds ~= nil and #result.rarityOdds == 11, "P003-TEST-008 rarity odds")
		assert(#result.classifications == 5, "P003-TEST-008 classification count")
		for _, classification in result.classifications do
			assert(classification == "new", "P003-TEST-008 new classification")
		end
		assert(
			#profile.pendingPacks.pack_request_00000001.classifications == 5,
			"P003-TEST-008 saved classifications"
		)
		assert(
			result.pityBefore == 0 and result.pityAfter == profile.pity["pack.classic"],
			"P003-TEST-008 pity state"
		)
		local slots = {}
		for _, card in result.cards do
			assert(card.deckSetId == "classic", "P003-TEST-008 deck set identity")
			assert(slots[card.slotKey] == nil, "P003-TEST-008 duplicate slot")
			slots[card.slotKey] = true
		end
		for _, card in inventory:listCards(profile) do
			assert(card.provenance.originType == "pack", "P003-TEST-008 provenance type")
			assert(
				card.provenance.originId == "pack_request_00000001",
				"P003-TEST-008 provenance id"
			)
		end
		ProfileSchema.validate(profile)
		local replayBefore = CanonicalValue.encode(profile)
		local replayed =
			packs:open(profile, 42, "pack_request_00000001", "classic", RandomService.new(17))
		assert(
			not replayed.ok and replayed.code == ErrorRegistry.codes.replayConflict,
			"P003-TEST-008 pending replay"
		)
		assert(CanonicalValue.encode(profile) == replayBefore, "P003-TEST-008 replay mutation")
		local before = CanonicalValue.encode(profile)
		local insufficient = ProfileSchema.newBlank(
			currencyIds,
			100,
			LaunchCatalog.catalogVersion,
			LaunchConfig.configVersion
		)
		local insufficientBefore = CanonicalValue.encode(insufficient)
		local rejected =
			packs:open(insufficient, 42, "pack_request_00000002", "astral", RandomService.new(17))
		assert(
			not rejected.ok and rejected.code == ErrorRegistry.codes.insufficientCurrency,
			"P003-TEST-008 insufficient currency"
		)
		assert(
			CanonicalValue.encode(insufficient) == insufficientBefore,
			"P003-TEST-008 rejected mutation"
		)
		local radioactive =
			packs:open(profile, 42, "pack_request_00000003", "radioactive", RandomService.new(23))
		assert(
			radioactive.ok and radioactive.cards[1].deckSetId == "radioactive",
			"P003-TEST-008 second deck set"
		)
		assert(CanonicalValue.encode(profile) ~= before, "P003-TEST-008 committed mutation")
	end)

	addTest("P003-TEST-009-offer-pack-service", function()
		local collection = CollectionService.new()
		local currencyIds = {}
		for _, currency in LaunchConfig.economy.currencies do
			table.insert(currencyIds, currency.id)
		end
		local profile = ProfileSchema.newBlank(
			currencyIds,
			100,
			LaunchCatalog.catalogVersion,
			LaunchConfig.configVersion
		)
		profile.currencies.joker_tickets = 20
		profile.currencies.arcana_dust = 700
		local uidCounter = 0
		local inventory = InventoryService.new({
			catalog = LaunchCatalog,
			errors = ErrorRegistry,
			inventoryStore = InventoryStore.new(),
			collection = collection,
			uidFactory = function(_ownerUserId: number, kind: string): string
				uidCounter += 1
				return kind .. "_offer_" .. tostring(uidCounter)
			end,
			clock = function(): number
				return 100
			end,
		})
		local packs = PackService.new({
			catalog = LaunchCatalog,
			config = LaunchConfig,
			inventory = inventory,
			collection = collection,
			canonical = CanonicalValue,
			errors = ErrorRegistry,
			rollContract = RollContract,
		})
		local jokerResult =
			packs:openOffers(profile, 42, "joker_pack_request_0001", "joker", RandomService.new(31))
		assert(jokerResult.ok and #jokerResult.offers == 3, "P003-TEST-009 joker offer count")
		assert(profile.currencies.joker_tickets == 10, "P003-TEST-009 joker price")
		assert(
			jokerResult.rarityOdds ~= nil and #jokerResult.rarityOdds == 6,
			"P003-TEST-009 rarity odds"
		)
		assert(jokerResult.pityBefore == 0, "P003-TEST-009 pity before")
		local offerIds = {}
		for _, offer in jokerResult.offers do
			assert(offerIds[offer.id] == nil, "P003-TEST-009 duplicate joker offer")
			offerIds[offer.id] = true
		end
		local pending = profile.pendingPacks.joker_pack_request_0001
		assert(
			pending.state == "committed" and #pending.offerIds == 3,
			"P003-TEST-009 saved joker offers"
		)
		ProfileSchema.validate(profile)
		local chosen = jokerResult.offerIds[2]
		local choice = packs:chooseOffer(
			profile,
			42,
			"joker_choice_request_0001",
			"joker_pack_request_0001",
			2
		)
		assert(choice.ok and choice.choiceId == chosen, "P003-TEST-009 joker choice")
		assert(
			profile.pendingPacks.joker_pack_request_0001.state == "claimed",
			"P003-TEST-009 joker claimed"
		)
		assert(
			profile.pendingPacks.joker_pack_request_0001.grantedJokerInstanceId ~= nil,
			"P003-TEST-009 joker grant"
		)
		assert(
			profile.jokers[profile.pendingPacks.joker_pack_request_0001.grantedJokerInstanceId].jokerId
				== chosen,
			"P003-TEST-009 chosen joker owned"
		)
		ProfileSchema.validate(profile)
		local replayBefore = CanonicalValue.encode(profile)
		local replay = packs:chooseOffer(
			profile,
			42,
			"joker_choice_request_0002",
			"joker_pack_request_0001",
			2
		)
		assert(
			not replay.ok and replay.code == ErrorRegistry.codes.replayConflict,
			"P003-TEST-009 choice replay"
		)
		assert(
			CanonicalValue.encode(profile) == replayBefore,
			"P003-TEST-009 choice replay mutation"
		)

		local arcanaResult = packs:openOffers(
			profile,
			42,
			"arcana_pack_request_0001",
			"arcana",
			RandomService.new(41)
		)
		assert(arcanaResult.ok and #arcanaResult.offers == 3, "P003-TEST-009 arcana offer count")
		assert(
			arcanaResult.itemOdds ~= nil and #arcanaResult.itemOdds == 12,
			"P003-TEST-009 arcana item odds"
		)
		local arcanaIds = {}
		for _, offer in arcanaResult.offers do
			assert(arcanaIds[offer.id] == nil, "P003-TEST-009 duplicate arcana offer")
			arcanaIds[offer.id] = true
		end
		local invalidBefore = CanonicalValue.encode(profile)
		local invalidChoice = packs:chooseOffer(
			profile,
			42,
			"arcana_choice_request_0001",
			"arcana_pack_request_0001",
			4
		)
		assert(
			not invalidChoice.ok and invalidChoice.code == ErrorRegistry.codes.packChoiceInvalid,
			"P003-TEST-009 invalid arcana choice"
		)
		assert(
			CanonicalValue.encode(profile) == invalidBefore,
			"P003-TEST-009 invalid choice mutation"
		)
		local arcanaChoice = packs:chooseOffer(
			profile,
			42,
			"arcana_choice_request_0002",
			"arcana_pack_request_0001",
			1
		)
		assert(
			arcanaChoice.ok and arcanaChoice.grant.stackCount == 1,
			"P003-TEST-009 arcana choice"
		)
		assert(profile.arcanaStacks[arcanaChoice.choiceId] == 1, "P003-TEST-009 arcana stack")
		ProfileSchema.validate(profile)
		for index = 2, 6 do
			local operationId = "arcana_pack_request_000" .. tostring(index)
			local opened =
				packs:openOffers(profile, 42, operationId, "arcana", RandomService.new(41 + index))
			assert(opened.ok and #opened.offers == 3, "P003-TEST-009 protected arcana offer count")
			for _, offer in opened.offers do
				assert(
					profile.discovery.arcana[offer.id] ~= true,
					"P003-TEST-009 protected arcana duplicate"
				)
			end
			local selectedId = opened.offerIds[1]
			local selected = packs:chooseOffer(
				profile,
				42,
				"arcana_choice_request_000" .. tostring(index + 1),
				operationId,
				1
			)
			assert(
				selected.ok and selected.choiceId == selectedId,
				"P003-TEST-009 protected arcana choice"
			)
		end
		local discoveredArcanaCount = 0
		for _ in profile.discovery.arcana do
			discoveredArcanaCount += 1
		end
		assert(discoveredArcanaCount == 6, "P003-TEST-009 arcana protection threshold")
		ProfileSchema.validate(profile)
	end)

	addTest("P003-TEST-010-pack-reveal-controller", function()
		local initial = PackRevealController.new()
		local snapshot = {
			revision = 4,
			writable = true,
			pendingPacks = {},
		}
		local request = PackRevealController.openRequest(initial, snapshot, "classic")
		assert(request.ok and request.payload.expectedRevision == 4, "P003-TEST-010 open request")
		local invalidPack = PackRevealController.openRequest(initial, snapshot, "unknown")
		assert(
			not invalidPack.ok and invalidPack.code == "pack.invalid",
			"P003-TEST-010 invalid pack"
		)
		local readOnly = PackRevealController.openRequest(initial, {
			revision = 4,
			writable = false,
			pendingPacks = {},
		}, "classic")
		assert(not readOnly.ok and readOnly.code == "profile.read_only", "P003-TEST-010 read only")

		local cards = {}
		local cardClassifications = {}
		for index = 1, 5 do
			local instanceId = "card_reveal_" .. tostring(index)
			table.insert(cards, {
				instanceId = instanceId,
				deckSetId = "classic",
				rankId = "rank_" .. tostring(index),
				suitId = "hearts",
			})
			table.insert(cardClassifications, "new")
		end
		local openMessage = {
			action = "pack.open",
			cards = cards,
			catalogVersion = 1,
			classifications = cardClassifications,
			code = "pack.deck_set_committed",
			currencyId = "cash",
			itemOdds = {},
			ok = true,
			packId = "classic",
			pityAfter = 1,
			pityBefore = 0,
			price = 500,
			requestId = "pack_reveal_0001",
			snapshot = {
				pendingPacks = {
					pack_reveal_0001 = {
						cardInstanceIds = {
							"card_reveal_1",
							"card_reveal_2",
							"card_reveal_3",
							"card_reveal_4",
							"card_reveal_5",
						},
						classifications = cardClassifications,
						packId = "classic",
						state = "committed",
					},
				},
			},
		}
		local revealing = PackRevealController.applyMessage(initial, openMessage)
		assert(revealing.phase == "revealing", "P003-TEST-010 revealing phase")
		assert(
			revealing.pendingRecovery and revealing.revealedCount == 0,
			"P003-TEST-010 recovery state"
		)
		local one = PackRevealController.revealNext(revealing)
		assert(one.revealedCount == 1 and one.phase == "revealing", "P003-TEST-010 one at a time")
		local reduced = PackRevealController.setSettings(one, {
			lowGraphics = true,
			mutedAudio = true,
			reducedMotion = true,
		})
		local reducedNext = PackRevealController.revealNext(reduced)
		assert(
			reducedNext.audioCue == nil and reducedNext.effectCue == "pack.static",
			"P003-TEST-010 reduced effects"
		)
		local all = PackRevealController.revealAll(revealing)
		assert(
			all.phase == "complete" and all.revealedCount == 5 and all.revealAll,
			"P003-TEST-010 reveal all"
		)
		local stepped = revealing
		for _ = 1, 5 do
			stepped = PackRevealController.revealNext(stepped)
		end
		assert(
			stepped.phase == "complete" and stepped.revealedCount == all.revealedCount,
			"P003-TEST-010 input parity"
		)
		local shown = PackRevealController.display(all)
		assert(
			shown.contents[1].classification == "new" and shown.pityAfter == 1,
			"P003-TEST-010 display metadata"
		)

		local offersMessage = {
			action = "pack.open",
			code = "pack.offers_committed",
			offers = {
				{ id = "joker.one", displayName = "one", rarityId = "common" },
				{ id = "joker.two", displayName = "two", rarityId = "rare" },
				{ id = "joker.three", displayName = "three", rarityId = "epic" },
			},
			ok = true,
			packId = "joker",
			packOperationId = "offer_reveal_0001",
			requestId = "offer_reveal_0001",
			snapshot = {
				pendingPacks = {
					offer_reveal_0001 = {
						offerIds = { "joker.one", "joker.two", "joker.three" },
						packId = "joker",
						state = "revealed",
					},
				},
			},
		}
		local offers = PackRevealController.applyMessage(PackRevealController.new(), offersMessage)
		local revealedOffers = PackRevealController.revealAll(offers)
		local choiceRequest = PackRevealController.choiceRequest(revealedOffers, snapshot, 2)
		assert(
			choiceRequest.ok and choiceRequest.payload.choiceIndex == 2,
			"P003-TEST-010 choice request"
		)
		local claimed = PackRevealController.applyMessage(revealedOffers, {
			action = "pack.choose",
			code = "pack.choice_claimed",
			choiceId = "joker.two",
			choiceIndex = 2,
			grant = { instanceId = "joker_instance_1", jokerId = "joker.two" },
			ok = true,
			packOperationId = "offer_reveal_0001",
			snapshot = {
				revision = 5,
				pendingPacks = {
					offer_reveal_0001 = {
						choiceId = "joker.two",
						choiceIndex = 2,
						state = "claimed",
					},
				},
			},
		})
		assert(
			claimed.phase == "claimed" and claimed.choiceId == "joker.two",
			"P003-TEST-010 choice claim"
		)
		local malformed = PackRevealController.applyMessage(PackRevealController.new(), {
			action = "pack.open",
			code = "pack.deck_set_committed",
			ok = true,
			requestId = "missing",
			snapshot = { pendingPacks = {} },
		})
		assert(
			malformed.phase == "maintenance" and #malformed.contents == 0,
			"P003-TEST-010 malformed safety"
		)
		local recovered = PackRevealController.hydrateSnapshot(PackRevealController.new(), {
			cards = cards,
			pendingPacks = {
				pack_reveal_0001 = {
					cardInstanceIds = {
						"card_reveal_1",
						"card_reveal_2",
						"card_reveal_3",
						"card_reveal_4",
						"card_reveal_5",
					},
					classifications = cardClassifications,
					packId = "classic",
					state = "committed",
				},
			},
		})
		assert(
			recovered.phase == "revealing" and recovered.pendingRecovery,
			"P003-TEST-010 card recovery"
		)
	end)

	addTest("P003-TEST-011-progression-service", function()
		local collection = CollectionService.new()
		local currencyIds = {}
		for _, currency in LaunchConfig.economy.currencies do
			table.insert(currencyIds, currency.id)
		end
		local profile = ProfileSchema.newBlank(
			currencyIds,
			100,
			LaunchCatalog.catalogVersion,
			LaunchConfig.configVersion
		)
		profile.currencies.grade_ink = 20000
		profile.currencies.trait_essence = 10
		local uidCounter = 0
		local inventory = InventoryService.new({
			catalog = LaunchCatalog,
			errors = ErrorRegistry,
			inventoryStore = InventoryStore.new(),
			collection = collection,
			uidFactory = function(_ownerUserId: number, kind: string): string
				uidCounter += 1
				return kind .. "_progression_" .. tostring(uidCounter)
			end,
			clock = function(): number
				return 100
			end,
		})
		local created = inventory:createCard(
			profile,
			42,
			"classic:ace:hearts",
			{ powerTierId = "zenith" },
			{ originType = "fixture", originId = "progression" }
		)
		assert(created.ok, "P003-TEST-011 card created")
		local progression = ProgressionService.new({
			catalog = LaunchCatalog,
			config = LaunchConfig,
			inventory = inventory,
			errors = ErrorRegistry,
		})
		local card = created.card
		local thresholds = { 0, 10, 30, 70, 150, 300, 600, 1200, 2400, 4800, 9600 }
		local previousGradeIndex = 1
		for index, threshold in thresholds do
			local current = card.gradeExperience
			local amount = math.max(1, threshold - current)
			if threshold == 0 then
				assert(current == 0 and card.gradeId == "f", "P003-TEST-011 zero threshold")
			else
				local result = progression:applyGradeInk(profile, 42, card.uid, amount)
				assert(result.ok, "P003-TEST-011 threshold result " .. tostring(index))
			end
			assert(
				card.gradeExperience >= threshold,
				"P003-TEST-011 threshold xp " .. tostring(index)
			)
			assert(card.gradeId ~= nil, "P003-TEST-011 threshold grade " .. tostring(index))
			local gradeIndex = index
			for candidateIndex, grade in LaunchCatalog.grades do
				if grade.id == card.gradeId then
					gradeIndex = candidateIndex
				end
			end
			assert(gradeIndex >= previousGradeIndex, "P003-TEST-011 grade monotonic")
			previousGradeIndex = gradeIndex
		end
		assert(card.gradeId == "lr", "P003-TEST-011 lr promotion")
		assert(card.powerTierId == "zenith", "P003-TEST-011 tier preserved")
		assert(card.gradeExperience == 9600, "P003-TEST-011 lr xp")
		card.gradeExperience = LaunchConfig.gameplayCaps.grade_experience
		local atCap = progression:applyGradeInk(profile, 42, card.uid, 1)
		assert(
			not atCap.ok and atCap.code == ErrorRegistry.codes.gradeAtCap,
			"P003-TEST-011 grade cap"
		)
		assert(profile.currencies.grade_ink == 10400, "P003-TEST-011 capped spend")

		card.gradeId = "f"
		card.gradeExperience = 0
		local choices = progression:eligibleTraitIds(profile, 42, card.uid)
		assert(choices.ok and #choices.traitIds == 12, "P003-TEST-011 trait choices")
		local chosen = progression:chooseTrait(profile, 42, card.uid, "fortune")
		assert(chosen.ok and card.traitId == "fortune", "P003-TEST-011 trait choice")
		assert(
			chosen.cost == 1 and profile.currencies.trait_essence == 9,
			"P003-TEST-011 trait cost"
		)
		local unconfirmed = progression:chooseTrait(profile, 42, card.uid, "fierce")
		assert(
			not unconfirmed.ok and unconfirmed.code == ErrorRegistry.codes.traitReplacementRequired,
			"P003-TEST-011 replacement confirmation"
		)
		local replaced = progression:chooseTrait(profile, 42, card.uid, "fierce", {
			replace = true,
			expectedTraitId = "fortune",
		})
		assert(replaced.ok and card.traitId == "fierce", "P003-TEST-011 trait replacement")
		assert(
			card.powerTierId == "zenith" and card.gradeExperience == 0,
			"P003-TEST-011 replacement preservation"
		)
		local stale = progression:chooseTrait(profile, 42, card.uid, "guardian", {
			replace = true,
			expectedTraitId = "fortune",
		})
		assert(
			not stale.ok and stale.code == ErrorRegistry.codes.staleState,
			"P003-TEST-011 stale trait"
		)
		card.locks.progression = true
		local beforeLocked = CanonicalValue.encode(profile)
		local locked = progression:applyGradeInk(profile, 42, card.uid, 1)
		assert(
			not locked.ok and locked.code == ErrorRegistry.codes.instanceLocked,
			"P003-TEST-011 locked grade"
		)
		local lockedTrait = progression:chooseTrait(profile, 42, card.uid, "guardian", true)
		assert(
			not lockedTrait.ok and lockedTrait.code == ErrorRegistry.codes.instanceLocked,
			"P003-TEST-011 locked trait"
		)
		assert(CanonicalValue.encode(profile) == beforeLocked, "P003-TEST-011 locked no mutation")
		card.locks.progression = nil
		ProfileSchema.validate(profile)
	end)

	addTest("P003-TEST-005-deckset-identity-assets", function()
		local records = LaunchDeckSetAssets.buildIdentityRecords(LaunchCatalog)
		assert(#records == 156, "P003-TEST-005 identity count")
		assert(
			table.isfrozen(records) and table.isfrozen(records[1]),
			"P003-TEST-005 immutable records"
		)
		local deckSetCounts = {}
		local slotCounts = {}
		for _, record in records do
			deckSetCounts[record.deckSetId] = (deckSetCounts[record.deckSetId] or 0) + 1
			slotCounts[record.slotKey] = (slotCounts[record.slotKey] or 0) + 1
			assert(record.launchEnabled == true, "P003-TEST-005 enabled identity")
			assert(record.assetContractId == "identity." .. record.id, "P003-TEST-005 asset id")
			assert(record.visualSystemId == record.deckSetId, "P003-TEST-005 visual system")
			assert(record.rankAssetId == "rank." .. record.rankId, "P003-TEST-005 rank asset")
			assert(record.suitAssetId == "suit." .. record.suitId, "P003-TEST-005 suit asset")
			assert(
				record.fallbackAssetId == "fallback.frame." .. record.deckSetId,
				"P003-TEST-005 fallback"
			)
			assert(record.provenance.origin == "original", "P003-TEST-005 provenance origin")
			assert(record.provenance.reviewState == "reviewed", "P003-TEST-005 review state")
			assert(#record.references == 5, "P003-TEST-005 reference count")
			for index = 2, #record.references do
				assert(
					record.references[index - 1] < record.references[index],
					"P003-TEST-005 reference order"
				)
			end
		end
		assert(deckSetCounts.classic == 52, "P003-TEST-005 classic count")
		assert(deckSetCounts.radioactive == 52, "P003-TEST-005 radioactive count")
		assert(deckSetCounts.astral == 52, "P003-TEST-005 astral count")
		for _, count in slotCounts do
			assert(count == 3, "P003-TEST-005 slot coverage")
		end
		assert(#LaunchDeckSetAssets.visualSystems == 3, "P003-TEST-005 visual system count")
		assert(
			table.isfrozen(LaunchDeckSetAssets.visualSystems),
			"P003-TEST-005 visual systems immutable"
		)
		assert(
			LaunchDeckSetAssets.visualSystem("classic").style.framePattern == "ivory_stock",
			"P003-TEST-005 classic style"
		)
		assert(
			LaunchDeckSetAssets.visualSystem("radioactive").style.framePattern == "hazard_stripes",
			"P003-TEST-005 radioactive style"
		)
		assert(
			LaunchDeckSetAssets.visualSystem("astral").style.framePattern == "star_maps",
			"P003-TEST-005 astral style"
		)
		assert(
			LaunchDeckSetAssets.visualSystem("radioactive").framePartName == "RadioactiveFrame",
			"P003-TEST-005 registered frame part"
		)
		assert(
			LaunchDeckSetAssets.visualSystem("astral").packFixtureName == "AstralPackFixture",
			"P003-TEST-005 registered pack fixture"
		)
		assert(LaunchDeckSetAssets.visualSystem("future") == nil, "P003-TEST-005 unknown style")
		assert(
			#LaunchDeckSetAssets.rankPresentations == 13,
			"P003-TEST-005 rank presentation count"
		)
		assert(#LaunchDeckSetAssets.suitPresentations == 4, "P003-TEST-005 suit presentation count")
		for index, presentation in LaunchDeckSetAssets.rankPresentations do
			assert(
				LaunchDeckSetAssets.rankPresentation(presentation.id:sub(6)) == presentation,
				"P003-TEST-005 rank presentation lookup"
			)
			assert(
				presentation.assetId == "asset." .. presentation.id,
				"P003-TEST-005 rank presentation asset"
			)
			assert(
				presentation.fallbackAssetId == "fallback." .. presentation.id,
				"P003-TEST-005 rank presentation fallback"
			)
			assert(
				presentation.id
					== "rank."
						.. (
							if index <= 9
								then tostring(index + 1)
								else ({ "10", "jack", "queen", "king", "ace" })[index - 8]
						),
				"P003-TEST-005 rank presentation order"
			)
		end
		for _, presentation in LaunchDeckSetAssets.suitPresentations do
			assert(
				LaunchDeckSetAssets.suitPresentation(presentation.id:sub(6)) == presentation,
				"P003-TEST-005 suit presentation lookup"
			)
			assert(
				presentation.assetId == "asset." .. presentation.id,
				"P003-TEST-005 suit presentation asset"
			)
			assert(
				presentation.fallbackAssetId == "fallback." .. presentation.id,
				"P003-TEST-005 suit presentation fallback"
			)
		end
		local radioactive = PresentationResolver.card(LaunchCatalog, {
			deckSetId = "radioactive",
		}, LaunchDeckSetAssets)
		assert(
			radioactive.fixtureName == "RadioactiveFrameFixture",
			"P003-TEST-005 resolver fixture"
		)
		assert(radioactive.framePartName == "RadioactiveFrame", "P003-TEST-005 resolver frame")
		assert(radioactive.rankMarkMode == "asset", "P003-TEST-005 resolver rank mode")
		assert(not radioactive.fallback, "P003-TEST-005 resolver themed")
		local unknown =
			PresentationResolver.card(LaunchCatalog, { deckSetId = "future" }, LaunchDeckSetAssets)
		assert(
			unknown.fixtureName == "ClassicFallbackFixture",
			"P003-TEST-005 resolver unknown fallback"
		)
		assert(
			unknown.fallback and unknown.rankMarkPartName == "FallbackMark",
			"P003-TEST-005 resolver fallback"
		)
		local disabled = PresentationResolver.card(
			{ deckSets = { { id = "astral", launchEnabled = false } } },
			{
				deckSetId = "astral",
			},
			LaunchDeckSetAssets
		)
		assert(
			disabled.fixtureName == "AstralFallbackFixture",
			"P003-TEST-005 resolver disabled fallback"
		)
		assert(disabled.fallback, "P003-TEST-005 resolver disabled state")
		local composed = ComposedCardAssets.build(LaunchCatalog)
		assert(#composed.editions == 4, "P003-TEST-005 edition asset count")
		assert(#composed.grades == 11, "P003-TEST-005 grade asset count")
		assert(#composed.powerTiers == 11, "P003-TEST-005 tier asset count")
		assert(#composed.traits == 12, "P003-TEST-005 trait asset count")
		assert(#composed.formations == 12, "P003-TEST-005 formation asset count")
		assert(#composed.statuses == 6, "P003-TEST-005 status asset count")
		assert(#composed.forms == 624, "P003-TEST-005 form asset count")
		local composedFormIds = {}
		for _, form in composed.forms do
			assert(composedFormIds[form.id] == nil, "P003-TEST-005 duplicate form asset")
			composedFormIds[form.id] = true
			assert(form.assetId == "asset.form." .. form.id, "P003-TEST-005 form asset id")
			assert(
				form.fallbackAssetId == "fallback.form." .. form.id,
				"P003-TEST-005 form fallback id"
			)
		end
		for _, form in LaunchCatalog.forms do
			assert(composedFormIds[form.id] == true, "P003-TEST-005 form reachability")
		end
		local composedCard = composed:compose({
			deckSetId = "classic",
			rankId = "ace",
			suitId = "hearts",
			editionId = "foil",
			gradeId = "a",
			powerTierId = "legendary",
			traitId = "fortune",
			locked = true,
		})
		assert(composedCard.form.id == "classic:ace:hearts:foil", "P003-TEST-005 form composition")
		assert(
			composedCard.layers.edition.assetId == "asset.edition.foil",
			"P003-TEST-005 edition composition"
		)
		assert(
			composedCard.layers.power_tier.assetId == "asset.power_tier.legendary",
			"P003-TEST-005 tier composition"
		)
		assert(
			#composedCard.layers.status == 1 and not composedCard.unavailable,
			"P003-TEST-005 status composition"
		)
		local special = SpecialContentAssets.build(LaunchCatalog)
		assert(table.isfrozen(special), "P003-TEST-005 special registry immutable")
		assert(#special.jokers == 24, "P003-TEST-005 special joker count")
		assert(#special.arcana == 12, "P003-TEST-005 special arcana count")
		assert(#special.packs == 5, "P003-TEST-005 special pack count")
		assert(#special.surfaces == 7, "P003-TEST-005 special surface count")
		assert(#special.sounds == 8, "P003-TEST-005 special sound count")
		assert(#special.effects == 9, "P003-TEST-005 special effect count")
		assert(#special.icons == 41, "P003-TEST-005 special icon count")
		assert(#special.thumbnails == 41, "P003-TEST-005 special thumbnail count")
		assert(#special.metadata == 41, "P003-TEST-005 special metadata count")
		local jokerAsset = special:get("joker", "packstorm")
		assert(
			jokerAsset ~= nil
				and jokerAsset.assetId == "asset.joker.packstorm"
				and jokerAsset.fallbackAssetId == "fallback.joker.packstorm",
			"P003-TEST-005 special joker asset"
		)
		assert(
			jokerAsset.rarityId == "legendary"
				and jokerAsset.handlerId == "joker_success_counter_intent"
				and #jokerAsset.stageIds == 1,
			"P003-TEST-005 special joker metadata"
		)
		local arcanaAsset = special:get("arcana", "regrader")
		assert(
			arcanaAsset ~= nil
				and arcanaAsset.assetId == "asset.arcana.regrader"
				and arcanaAsset.fallbackAssetId == "fallback.arcana.regrader",
			"P003-TEST-005 special arcana asset"
		)
		assert(
			arcanaAsset.categoryId == "grade"
				and arcanaAsset.targetId == "choice"
				and arcanaAsset.handlerId == "arcana_choose_nonregressing_grade",
			"P003-TEST-005 special arcana metadata"
		)
		local packAsset = special:get("pack", "astral")
		assert(
			packAsset ~= nil
				and packAsset.assetId == "asset.pack.astral"
				and packAsset.fallbackAssetId == "fallback.pack.astral",
			"P003-TEST-005 special pack asset"
		)
		assert(
			packAsset.category == "deck_set" and packAsset.deckSetId == "astral",
			"P003-TEST-005 special pack metadata"
		)
		local iconAsset = special:get("icon", "joker.packstorm")
		assert(
			iconAsset ~= nil
				and iconAsset.assetId == "asset.icon.joker.packstorm"
				and iconAsset.builtIdentity == "assetbundle.icon.joker.packstorm",
			"P003-TEST-005 special icon metadata"
		)
		assert(special:get("joker", "fifth_law") == nil, "P003-TEST-005 disabled joker hidden")
		assert(special:get("joker", "missing") == nil, "P003-TEST-005 unknown joker hidden")
		local viewModel = CardViewModel.build(LaunchCatalog, {
			instanceId = "composed_card",
			deckSetId = "classic",
			rankId = "ace",
			suitId = "hearts",
			editionId = "foil",
			gradeId = "a",
			powerTierId = "legendary",
			locked = true,
		}, {}, composed)
		assert(
			viewModel.layers[1].formAssetId == "asset.form.classic:ace:hearts:foil",
			"P003-TEST-005 view model form asset"
		)
		assert(
			viewModel.layers[4].assetId == "asset.edition.foil",
			"P003-TEST-005 view model edition asset"
		)
		assert(
			viewModel.layers[8].values[1].assetId == "asset.status.locked",
			"P003-TEST-005 view model status asset"
		)
		local twoDimensional = CardRenderer2D.render(viewModel)
		local threeDimensional = CardRenderer3D.render(viewModel)
		assert(
			twoDimensional.children[4].assetId == "asset.edition.foil",
			"P003-TEST-005 2d asset reference"
		)
		assert(
			threeDimensional.children[1].formAssetId == "asset.form.classic:ace:hearts:foil",
			"P003-TEST-005 3d form reference"
		)
		local incompleteCard = composed:compose({
			deckSetId = "classic",
			rankId = "ace",
			suitId = "hearts",
			editionId = "foil",
			gradeId = "missing",
			powerTierId = "legendary",
		})
		assert(composedCard.unavailable == false, "P003-TEST-005 complete composition")
		assert(
			incompleteCard.unavailable and #incompleteCard.layers.status == 1,
			"P003-TEST-005 unavailable composition"
		)
	end)

	addTest("P003-TEST-006-deckset-fixture-project", function()
		local project = serde.decode("json", fs.readFile("default.project.json"))
		local assets = project.tree.ServerStorage.Assets
		local cardFrames = assets.CardFrames
		local expectedFrames = {
			{ "ClassicFrameFixture", "ClassicFrame" },
			{ "RadioactiveFrameFixture", "RadioactiveFrame" },
			{ "AstralFrameFixture", "AstralFrame" },
		}
		for _, fixture in expectedFrames do
			local model = cardFrames[fixture[1]]
			assert(model["$className"] == "Model", "P003-TEST-006 frame model")
			assert(model[fixture[2]]["$className"] == "Part", "P003-TEST-006 frame part")
			assert(model.CardFace["$className"] == "Part", "P003-TEST-006 face part")
			assert(model.RankMark["$className"] == "Part", "P003-TEST-006 rank part")
		end
		for _, fixtureName in
			{ "ClassicFallbackFixture", "RadioactiveFallbackFixture", "AstralFallbackFixture" }
		do
			local model = cardFrames[fixtureName]
			assert(model["$className"] == "Model", "P003-TEST-006 fallback model")
			assert(model.FallbackFrame["$className"] == "Part", "P003-TEST-006 fallback frame")
			assert(model.FallbackMark["$className"] == "Part", "P003-TEST-006 fallback mark")
		end
		local packModels = assets.PackModels
		for _, fixtureName in
			{ "ClassicStarterPackFixture", "RadioactivePackFixture", "AstralPackFixture" }
		do
			local model = packModels[fixtureName]
			assert(model["$className"] == "Model", "P003-TEST-006 pack model")
			assert(model.PackBody["$className"] == "Part", "P003-TEST-006 pack body")
			assert(model.PackSeal["$className"] == "Part", "P003-TEST-006 pack seal")
		end
	end)
end

return table.freeze(Phase003Test)
