--!strict

local fs = require("@lune/fs")
local serde = require("@lune/serde")

local AssetManifest = require("../src/shared/Assets/AssetManifest")
local LaunchCatalog = require("../src/shared/Catalogs/LaunchCatalog")
local LaunchDeckSetAssets = require("../src/shared/Assets/LaunchDeckSetAssets")

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
	end)
end

return table.freeze(Phase003Test)
