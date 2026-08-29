--!strict

local PreloadManifest = {
	version = 1,
	maximumInstances = 2,
	fixtureNames = table.freeze({
		"ClassicFrameFixture",
		"ClassicStarterPackFixture",
	}),
}

function PreloadManifest.resolve(root: Instance): { Instance }
	local instances = {}
	for _, name in PreloadManifest.fixtureNames do
		local fixture = root:FindFirstChild(name)
		assert(fixture ~= nil, "P002-PRELOAD-001 fixture missing")
		table.insert(instances, fixture)
	end
	assert(#instances <= PreloadManifest.maximumInstances, "P002-PRELOAD-002 bound exceeded")
	return instances
end

return table.freeze(PreloadManifest)
