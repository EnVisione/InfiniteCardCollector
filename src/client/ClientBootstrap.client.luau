--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local BootstrapContract = require(ReplicatedStorage.Shared.BootstrapContract)
local LaunchContract = require(ReplicatedStorage.Shared.LaunchContract)
local Phase001Fixtures = require(ReplicatedStorage.Shared.Fixtures.Phase001Fixtures)

local fixtureResult = LaunchContract.calculate(Phase001Fixtures.crownRun())
local projection = LaunchContract.projectCalculation(fixtureResult)
assert(projection.accepted, "P001-STUDIO-002 client fixture rejected")

script.Parent:SetAttribute("BootstrapContractVersion", BootstrapContract.contractVersion)
script.Parent:SetAttribute("CatalogVersion", LaunchContract.catalogVersion)
script.Parent:SetAttribute("ConfigVersion", LaunchContract.configVersion)
script.Parent:SetAttribute(
	"LaunchIdentityCount",
	#LaunchContract.clientCatalog.ranks
		* #LaunchContract.clientCatalog.suits
		* #LaunchContract.clientCatalog.deckSets
)
script.Parent:SetAttribute(
	"LaunchFormCount",
	#LaunchContract.clientCatalog.ranks
		* #LaunchContract.clientCatalog.suits
		* #LaunchContract.clientCatalog.deckSets
		* #LaunchContract.clientCatalog.editions
)
script.Parent:SetAttribute("Phase001FormationId", projection.formationId)
script.Parent:SetAttribute("Phase001Cash", projection.components.cash)
script.Parent:SetAttribute("Phase001Power", projection.components.power)
script.Parent:SetAttribute("Phase001Guard", projection.components.guard)
script.Parent:SetAttribute("Phase001TraceEntries", #projection.trace)
script.Parent:SetAttribute("BootstrapState", "ready")
