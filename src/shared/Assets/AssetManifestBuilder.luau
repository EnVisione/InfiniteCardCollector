--!strict

local AssetManifest = if script ~= nil
	then require(script.Parent.AssetManifest)
	else require("./AssetManifest")

local AssetManifestBuilder = {}

local specificationFields = {
	artifactVersion = true,
	catalogVersion = true,
	entries = true,
	poolGroups = true,
	preloadGroups = true,
}

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

local function assertSpecification(specification: any)
	assert(type(specification) == "table", "P003-ASSET-BUILD-001 specification missing")
	for key in specification do
		assert(
			type(key) == "string" and specificationFields[key] == true,
			"P003-ASSET-BUILD-002 unknown specification field"
		)
	end
	assert(
		type(specification.artifactVersion) == "string" and specification.artifactVersion ~= "",
		"P003-ASSET-BUILD-003 artifact version missing"
	)
	assert(
		type(specification.catalogVersion) == "number"
			and specification.catalogVersion % 1 == 0
			and specification.catalogVersion > 0,
		"P003-ASSET-BUILD-004 catalog version invalid"
	)
	assert(type(specification.entries) == "table", "P003-ASSET-BUILD-005 entries missing")
	assert(
		type(specification.preloadGroups) == "table",
		"P003-ASSET-BUILD-006 preload groups missing"
	)
	assert(type(specification.poolGroups) == "table", "P003-ASSET-BUILD-007 pool groups missing")
end

local function sortedEntries(entries: { any }): { any }
	local result = {}
	for _, entry in entries do
		assert(type(entry) == "table", "P003-ASSET-BUILD-010 entry missing")
		assert(
			type(entry.id) == "string" and entry.id ~= "",
			"P003-ASSET-BUILD-011 entry id missing"
		)
		table.insert(result, copy(entry))
	end
	table.sort(result, function(left, right)
		return left.id < right.id
	end)
	return result
end

local function buildInventory(entries: { any }): any
	local totalBytes = 0
	local totalMemoryBytes = 0
	local totalInstances = 0
	local records = {}
	for _, entry in entries do
		totalBytes += entry.byteSize
		totalMemoryBytes += entry.memoryBytes
		totalInstances += entry.instanceCount
		table.insert(
			records,
			table.freeze({
				byteSize = entry.byteSize,
				builtIdentity = entry.builtIdentity,
				builtSha256 = entry.builtSha256,
				fallbackId = entry.fallbackId,
				id = entry.id,
				instanceCount = entry.instanceCount,
				kind = entry.kind,
				memoryBytes = entry.memoryBytes,
				poolGroup = entry.poolGroup,
				preloadGroup = entry.preloadGroup,
				enabled = entry.enabled,
			})
		)
	end
	return table.freeze({
		entries = table.freeze(records),
		totalBytes = totalBytes,
		totalInstances = totalInstances,
		totalMemoryBytes = totalMemoryBytes,
	})
end

function AssetManifestBuilder.build(specification: any): any
	assertSpecification(specification)
	local manifest = AssetManifest.validate({
		artifactVersion = specification.artifactVersion,
		catalogVersion = specification.catalogVersion,
		entries = sortedEntries(specification.entries),
		manifestVersion = AssetManifest.manifestVersion,
		poolGroups = copy(specification.poolGroups),
		preloadGroups = copy(specification.preloadGroups),
		schemaVersion = AssetManifest.schemaVersion,
	})
	return table.freeze({
		inventory = buildInventory(manifest.entries),
		manifest = manifest,
	})
end

function AssetManifestBuilder.invalidationReasons(previous: any, current: any): { string }
	assert(type(previous) == "table", "P003-ASSET-BUILD-008 previous manifest missing")
	assert(type(current) == "table", "P003-ASSET-BUILD-009 current manifest missing")
	return AssetManifest.invalidationReasons(previous, current)
end

return table.freeze(AssetManifestBuilder)
