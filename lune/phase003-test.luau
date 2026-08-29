--!strict

local fs = require("@lune/fs")
local serde = require("@lune/serde")

local AssetManifest = require("../src/shared/Assets/AssetManifest")
local LaunchCatalog = require("../src/shared/Catalogs/LaunchCatalog")
local LaunchDeckSetAssets = require("../src/shared/Assets/LaunchDeckSetAssets")
local PresentationResolver = require("../src/shared/Assets/PresentationResolver")
local ComposedCardAssets = require("../src/shared/Assets/ComposedCardAssets")
local CardViewModel = require("../src/shared/Rendering/CardViewModel")
local CardRenderer2D = require("../src/client/Rendering/CardRenderer2D")
local CardRenderer3D = require("../src/client/Rendering/CardRenderer3D")

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
