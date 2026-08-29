--!strict

local fs = require("@lune/fs")

local ArtifactCore = require("./lib/artifact-core")
local Common = require("./lib/common")
local Phase002Evidence = require("./lib/phase002-evidence")

Common.main("phase002-evidence", function()
	Common.assertRepositoryRoot()
	local reports, hashes = Phase002Evidence.build()
	Common.ensureDir("build/phase002")
	for id, report in reports do
		fs.writeFile("build/phase002/" .. id .. ".json", ArtifactCore.canonicalJson(report) .. "\n")
	end
	fs.writeFile("build/phase002/hashes.json", ArtifactCore.canonicalJson(hashes) .. "\n")
	print(ArtifactCore.canonicalJson({ hashes = hashes, profileSizes = reports.profileSizes }))
end)
