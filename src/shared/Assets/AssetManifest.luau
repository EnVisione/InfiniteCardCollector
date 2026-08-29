--!strict

local AssetManifest = {}

local allowedKinds = {
	audio = true,
	effect = true,
	fallback = true,
	image = true,
	interface = true,
	metadata = true,
	model = true,
	world = true,
}

local reviewStates = {
	pending = true,
	quarantined = true,
	reviewed = true,
}

local entryFields = {
	assetVersion = true,
	builtIdentity = true,
	builtSha256 = true,
	builtSha512 = true,
	byteBudget = true,
	byteSize = true,
	dimensions = true,
	durationSeconds = true,
	enabled = true,
	fallbackId = true,
	instanceBudget = true,
	instanceCount = true,
	id = true,
	kind = true,
	memoryBudgetBytes = true,
	memoryBytes = true,
	poolGroup = true,
	preloadGroup = true,
	provenance = true,
	references = true,
	sourceIdentity = true,
	sourceSha256 = true,
	sourceSha512 = true,
}

local manifestFields = {
	artifactVersion = true,
	catalogVersion = true,
	entries = true,
	manifestVersion = true,
	poolGroups = true,
	preloadGroups = true,
	schemaVersion = true,
}

local groupFields = {
	id = true,
	maxBytes = true,
	maxInstances = true,
}

local provenanceFields = {
	license = true,
	origin = true,
	reviewState = true,
	reviewedAt = true,
	reviewedBy = true,
}

local dimensionFields = {
	height = true,
	width = true,
}

AssetManifest.schemaVersion = 1
AssetManifest.manifestVersion = 1
AssetManifest.allowedKinds = table.freeze({
	"audio",
	"effect",
	"fallback",
	"image",
	"interface",
	"metadata",
	"model",
	"world",
})
AssetManifest.requiredEntryFields = table.freeze({
	"assetVersion",
	"builtIdentity",
	"builtSha256",
	"builtSha512",
	"byteBudget",
	"byteSize",
	"enabled",
	"fallbackId",
	"instanceBudget",
	"instanceCount",
	"id",
	"kind",
	"memoryBudgetBytes",
	"memoryBytes",
	"poolGroup",
	"preloadGroup",
	"provenance",
	"references",
	"sourceIdentity",
	"sourceSha256",
	"sourceSha512",
})
AssetManifest.budgets = table.freeze({
	maximumEntryBytes = 4 * 1024 * 1024,
	maximumEntryMemoryBytes = 16 * 1024 * 1024,
	maximumEntryInstances = 128,
	maximumPreloadBytes = 8 * 1024 * 1024,
	maximumPreloadInstances = 256,
})

local function isFinite(value: number): boolean
	return value == value and value < math.huge and value > -math.huge
end

local function isInteger(value: any): boolean
	return type(value) == "number" and isFinite(value) and value % 1 == 0
end

local function assertString(value: any, failureId: string)
	assert(type(value) == "string" and value ~= "", failureId)
end

local function assertStableId(value: any, failureId: string)
	assertString(value, failureId)
	assert(value:match("^[a-z0-9][a-z0-9_.:]*$") ~= nil, failureId)
end

local function assertIdentity(value: any, failureId: string)
	assertString(value, failureId)
	assert(value:match("^[%w][%w_./:%-]*$") ~= nil, failureId)
end

local function assertHash(value: any, length: number, failureId: string)
	assert(type(value) == "string" and #value == length, failureId)
	assert(value:match("^[0-9a-f]+$") ~= nil, failureId)
end

local function assertNonnegativeInteger(value: any, failureId: string)
	assert(isInteger(value) and value >= 0, failureId)
end

local function assertPositiveInteger(value: any, failureId: string)
	assert(isInteger(value) and value > 0, failureId)
end

local function assertNoUnknownFields(value: any, fields: { [string]: boolean }, failureId: string)
	assert(type(value) == "table", failureId)
	for key in value do
		assert(type(key) == "string" and fields[key] == true, failureId)
	end
end

local function assertDenseArray(value: any, failureId: string)
	assert(type(value) == "table", failureId)
	for index = 1, #value do
		assert(value[index] ~= nil, failureId)
	end
	for key in value do
		assert(type(key) == "number" and key % 1 == 0 and key >= 1 and key <= #value, failureId)
	end
end

local function assertSortedUniqueIds(values: { string }, failureId: string)
	local previous: string? = nil
	for _, value in values do
		assertStableId(value, failureId)
		if previous ~= nil then
			assert(previous < value, failureId)
		end
		previous = value
	end
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

local function deepFreeze(value: any): any
	if type(value) == "table" and not table.isfrozen(value) then
		for _, child in value do
			deepFreeze(child)
		end
		table.freeze(value)
	end
	return value
end

local function validateGroups(groups: any, kind: string): { any }
	assertDenseArray(groups, "P003-ASSET-001 " .. kind .. " groups must be dense")
	local ids = {}
	local previous: string? = nil
	for _, group in groups do
		assertNoUnknownFields(group, groupFields, "P003-ASSET-002 " .. kind .. " group fields")
		assertStableId(group.id, "P003-ASSET-003 " .. kind .. " group id")
		if previous ~= nil then
			assert(previous < group.id, "P003-ASSET-004 " .. kind .. " groups must be sorted")
		end
		previous = group.id
		assert(ids[group.id] == nil, "P003-ASSET-005 duplicate " .. kind .. " group")
		ids[group.id] = true
		assertNonnegativeInteger(group.maxBytes, "P003-ASSET-006 " .. kind .. " group bytes")
		assertNonnegativeInteger(
			group.maxInstances,
			"P003-ASSET-007 " .. kind .. " group instances"
		)
		if kind == "preload" then
			assert(
				group.maxBytes <= AssetManifest.budgets.maximumPreloadBytes,
				"P003-ASSET-008 preload bytes"
			)
			assert(
				group.maxInstances <= AssetManifest.budgets.maximumPreloadInstances,
				"P003-ASSET-009 preload instances"
			)
		end
	end
	return ids
end

local function validateDimensions(value: any, failureId: string)
	assertNoUnknownFields(value, dimensionFields, failureId)
	assertPositiveInteger(value.width, failureId)
	assertPositiveInteger(value.height, failureId)
end

local function validateProvenance(value: any, enabled: boolean)
	assertNoUnknownFields(value, provenanceFields, "P003-ASSET-020 provenance fields")
	assertStableId(value.origin, "P003-ASSET-021 provenance origin")
	assertString(value.license, "P003-ASSET-022 provenance license")
	assert(reviewStates[value.reviewState] == true, "P003-ASSET-023 provenance review state")
	if enabled then
		assert(value.reviewState == "reviewed", "P003-ASSET-024 enabled asset is not reviewed")
	end
	if value.reviewState == "reviewed" then
		assertString(value.reviewedBy, "P003-ASSET-025 reviewer missing")
		assertString(value.reviewedAt, "P003-ASSET-026 review date missing")
	end
end

local function validateReferences(value: any): { string }
	assertDenseArray(value, "P003-ASSET-030 references must be dense")
	assert(#value > 0, "P003-ASSET-031 references missing")
	local result = {}
	for _, reference in value do
		assertStableId(reference, "P003-ASSET-032 reference id")
		table.insert(result, reference)
	end
	assertSortedUniqueIds(result, "P003-ASSET-033 references must be sorted")
	return result
end

local function validateEntry(
	entry: any,
	preloadGroups: { [string]: boolean },
	poolGroups: { [string]: boolean }
)
	assertNoUnknownFields(entry, entryFields, "P003-ASSET-040 entry fields")
	assertStableId(entry.id, "P003-ASSET-041 asset id")
	assert(allowedKinds[entry.kind] == true, "P003-ASSET-042 asset kind")
	assert(type(entry.enabled) == "boolean", "P003-ASSET-043 enabled flag")
	assertIdentity(entry.sourceIdentity, "P003-ASSET-044 source identity")
	assertIdentity(entry.builtIdentity, "P003-ASSET-045 built identity")
	assertHash(entry.sourceSha256, 64, "P003-ASSET-046 source sha256")
	assertHash(entry.sourceSha512, 128, "P003-ASSET-047 source sha512")
	assertHash(entry.builtSha256, 64, "P003-ASSET-048 built sha256")
	assertHash(entry.builtSha512, 128, "P003-ASSET-049 built sha512")
	assertString(entry.assetVersion, "P003-ASSET-050 asset version")
	validateProvenance(entry.provenance, entry.enabled)
	validateReferences(entry.references)
	assertStableId(entry.fallbackId, "P003-ASSET-051 fallback id")
	assert(preloadGroups[entry.preloadGroup] == true, "P003-ASSET-052 preload group")
	assert(poolGroups[entry.poolGroup] == true, "P003-ASSET-053 pool group")
	assertPositiveInteger(entry.byteSize, "P003-ASSET-054 byte size")
	assertPositiveInteger(entry.byteBudget, "P003-ASSET-055 byte budget")
	assert(entry.byteSize <= entry.byteBudget, "P003-ASSET-056 byte budget exceeded")
	assert(
		entry.byteBudget <= AssetManifest.budgets.maximumEntryBytes,
		"P003-ASSET-057 byte budget maximum"
	)
	assertPositiveInteger(entry.memoryBytes, "P003-ASSET-058 memory size")
	assertPositiveInteger(entry.memoryBudgetBytes, "P003-ASSET-059 memory budget")
	assert(entry.memoryBytes <= entry.memoryBudgetBytes, "P003-ASSET-060 memory budget exceeded")
	assert(
		entry.memoryBudgetBytes <= AssetManifest.budgets.maximumEntryMemoryBytes,
		"P003-ASSET-061 memory budget maximum"
	)
	assertPositiveInteger(entry.instanceCount, "P003-ASSET-062 instance count")
	assertPositiveInteger(entry.instanceBudget, "P003-ASSET-063 instance budget")
	assert(entry.instanceCount <= entry.instanceBudget, "P003-ASSET-064 instance budget exceeded")
	assert(
		entry.instanceBudget <= AssetManifest.budgets.maximumEntryInstances,
		"P003-ASSET-065 instance budget maximum"
	)
	if entry.dimensions ~= nil then
		validateDimensions(entry.dimensions, "P003-ASSET-066 dimensions")
	end
	if entry.durationSeconds ~= nil then
		assert(
			type(entry.durationSeconds) == "number"
				and isFinite(entry.durationSeconds)
				and entry.durationSeconds >= 0,
			"P003-ASSET-067 duration"
		)
	end
	assert(
		entry.dimensions ~= nil or entry.durationSeconds ~= nil,
		"P003-ASSET-068 dimensions or duration missing"
	)
end

local function mapEntries(entries: { any }): { [string]: any }
	local result = {}
	local previous: string? = nil
	for _, entry in entries do
		if previous ~= nil then
			assert(previous < entry.id, "P003-ASSET-069 entries must be sorted")
		end
		previous = entry.id
		assert(result[entry.id] == nil, "P003-ASSET-070 duplicate asset id")
		result[entry.id] = entry
	end
	return result
end

function AssetManifest.validate(manifest: any): any
	assertNoUnknownFields(manifest, manifestFields, "P003-ASSET-080 manifest fields")
	assert(manifest.schemaVersion == AssetManifest.schemaVersion, "P003-ASSET-081 schema version")
	assert(
		manifest.manifestVersion == AssetManifest.manifestVersion,
		"P003-ASSET-082 manifest version"
	)
	assertPositiveInteger(manifest.catalogVersion, "P003-ASSET-083 catalog version")
	assertString(manifest.artifactVersion, "P003-ASSET-084 artifact version")
	local preloadGroups = validateGroups(manifest.preloadGroups, "preload")
	local poolGroups = validateGroups(manifest.poolGroups, "pool")
	assertDenseArray(manifest.entries, "P003-ASSET-085 entries must be dense")
	for _, entry in manifest.entries do
		validateEntry(entry, preloadGroups, poolGroups)
	end
	local entries = copy(manifest.entries)
	local index = mapEntries(entries)
	local builtHashes = {}
	local preloadTotals: { [string]: { bytes: number, instances: number } } = {}
	local poolTotals: { [string]: number } = {}
	for _, entry in entries do
		local existingHash = builtHashes[entry.builtSha256]
		assert(existingHash == nil, "P003-ASSET-086 duplicate built hash")
		builtHashes[entry.builtSha256] = entry.id
		local fallback = index[entry.fallbackId]
		if fallback == nil then
			assert(entry.enabled == false, "P003-ASSET-087 enabled fallback missing")
		else
			if entry.enabled then
				assert(
					fallback.provenance.reviewState == "reviewed",
					"P003-ASSET-088 fallback not reviewed"
				)
				assert(fallback.kind == "fallback", "P003-ASSET-093 fallback kind")
			end
		end
		if entry.id == entry.fallbackId then
			assert(entry.kind == "fallback", "P003-ASSET-089 nonfallback self reference")
		end
		local preload = preloadTotals[entry.preloadGroup]
		if preload == nil then
			preload = { bytes = 0, instances = 0 }
			preloadTotals[entry.preloadGroup] = preload
		end
		preload.bytes += entry.byteSize
		preload.instances += entry.instanceCount
		poolTotals[entry.poolGroup] = (poolTotals[entry.poolGroup] or 0) + entry.instanceCount
	end
	for _, group in manifest.preloadGroups do
		local totals = preloadTotals[group.id] or { bytes = 0, instances = 0 }
		assert(totals.bytes <= group.maxBytes, "P003-ASSET-090 preload bytes exceeded")
		assert(totals.instances <= group.maxInstances, "P003-ASSET-091 preload instances exceeded")
	end
	for _, group in manifest.poolGroups do
		assert(
			(poolTotals[group.id] or 0) <= group.maxInstances,
			"P003-ASSET-092 pool instances exceeded"
		)
	end
	return deepFreeze({
		artifactVersion = manifest.artifactVersion,
		catalogVersion = manifest.catalogVersion,
		entries = entries,
		manifestVersion = manifest.manifestVersion,
		poolGroups = copy(manifest.poolGroups),
		preloadGroups = copy(manifest.preloadGroups),
		schemaVersion = manifest.schemaVersion,
	})
end

local function sameArray(left: { any }, right: { any }): boolean
	if #left ~= #right then
		return false
	end
	for index, value in left do
		if value ~= right[index] then
			return false
		end
	end
	return true
end

local function sameProvenance(left: any, right: any): boolean
	return left.origin == right.origin
		and left.license == right.license
		and left.reviewState == right.reviewState
		and left.reviewedBy == right.reviewedBy
		and left.reviewedAt == right.reviewedAt
end

local function sameEntry(left: any, right: any): { string }
	local reasons = {}
	local presentationChanged = left.kind ~= right.kind
	if
		left.sourceIdentity ~= right.sourceIdentity
		or left.sourceSha256 ~= right.sourceSha256
		or left.sourceSha512 ~= right.sourceSha512
	then
		table.insert(reasons, "source_changed")
	end
	if
		left.builtIdentity ~= right.builtIdentity
		or left.builtSha256 ~= right.builtSha256
		or left.builtSha512 ~= right.builtSha512
	then
		table.insert(reasons, "built_changed")
	end
	if left.enabled ~= right.enabled then
		table.insert(reasons, "enabled_state_changed")
	end
	if left.fallbackId ~= right.fallbackId then
		table.insert(reasons, "fallback_changed")
	end
	if left.assetVersion ~= right.assetVersion then
		table.insert(reasons, "asset_version_changed")
	end
	if not sameArray(left.references, right.references) then
		table.insert(reasons, "references_changed")
	end
	if not sameProvenance(left.provenance, right.provenance) then
		table.insert(reasons, "provenance_changed")
	end
	local leftDimensions = left.dimensions
	local rightDimensions = right.dimensions
	if
		(leftDimensions == nil) ~= (rightDimensions == nil)
		or (leftDimensions ~= nil and rightDimensions ~= nil and (leftDimensions.width ~= rightDimensions.width or leftDimensions.height ~= rightDimensions.height))
		or left.durationSeconds ~= right.durationSeconds
	then
		presentationChanged = true
	end
	if presentationChanged then
		table.insert(reasons, "presentation_changed")
	end
	if
		left.byteSize ~= right.byteSize
		or left.byteBudget ~= right.byteBudget
		or left.memoryBytes ~= right.memoryBytes
		or left.memoryBudgetBytes ~= right.memoryBudgetBytes
		or left.instanceCount ~= right.instanceCount
		or left.instanceBudget ~= right.instanceBudget
		or left.preloadGroup ~= right.preloadGroup
		or left.poolGroup ~= right.poolGroup
	then
		table.insert(reasons, "budget_changed")
	end
	return reasons
end

local function sameGroups(left: { any }, right: { any }): boolean
	if #left ~= #right then
		return false
	end
	for index, group in left do
		local other = right[index]
		if
			group.id ~= other.id
			or group.maxBytes ~= other.maxBytes
			or group.maxInstances ~= other.maxInstances
		then
			return false
		end
	end
	return true
end

function AssetManifest.invalidationReasons(previousManifest: any, currentManifest: any): { string }
	local previous = AssetManifest.validate(previousManifest)
	local current = AssetManifest.validate(currentManifest)
	local previousEntries = mapEntries(previous.entries)
	local currentEntries = mapEntries(current.entries)
	local ids = {}
	for id in previousEntries do
		ids[id] = true
	end
	for id in currentEntries do
		ids[id] = true
	end
	local orderedIds = {}
	for id in ids do
		table.insert(orderedIds, id)
	end
	table.sort(orderedIds)
	local reasons = {}
	if previous.schemaVersion ~= current.schemaVersion then
		table.insert(reasons, "manifest_schema_changed")
	end
	if previous.manifestVersion ~= current.manifestVersion then
		table.insert(reasons, "manifest_version_changed")
	end
	if previous.catalogVersion ~= current.catalogVersion then
		table.insert(reasons, "catalog_version_changed")
	end
	if previous.artifactVersion ~= current.artifactVersion then
		table.insert(reasons, "artifact_version_changed")
	end
	if not sameGroups(previous.preloadGroups, current.preloadGroups) then
		table.insert(reasons, "preload_budget_changed")
	end
	if not sameGroups(previous.poolGroups, current.poolGroups) then
		table.insert(reasons, "pool_budget_changed")
	end
	for _, id in orderedIds do
		local left = previousEntries[id]
		local right = currentEntries[id]
		if left == nil then
			table.insert(reasons, "entry_added:" .. id)
		elseif right == nil then
			table.insert(reasons, "entry_removed:" .. id)
		else
			for _, reason in sameEntry(left, right) do
				table.insert(reasons, reason .. ":" .. id)
			end
		end
	end
	return table.freeze(reasons)
end

function AssetManifest.empty(catalogVersion: number, artifactVersion: string): any
	return AssetManifest.validate({
		artifactVersion = artifactVersion,
		catalogVersion = catalogVersion,
		entries = {},
		manifestVersion = AssetManifest.manifestVersion,
		poolGroups = {
			{ id = "card", maxBytes = 0, maxInstances = 0 },
		},
		preloadGroups = {
			{ id = "opening_table", maxBytes = 0, maxInstances = 0 },
		},
		schemaVersion = AssetManifest.schemaVersion,
	})
end

return table.freeze(AssetManifest)
