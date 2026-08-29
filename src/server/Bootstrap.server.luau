--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local BootstrapContract = require(ReplicatedStorage.Shared.BootstrapContract)
local LaunchContract = require(ReplicatedStorage.Shared.LaunchContract)
local Phase001Fixtures = require(ReplicatedStorage.Shared.Fixtures.Phase001Fixtures)

local serverRoot = ServerScriptService.Server
serverRoot:SetAttribute("BootstrapContractVersion", BootstrapContract.contractVersion)
serverRoot:SetAttribute("CatalogVersion", LaunchContract.catalogVersion)
serverRoot:SetAttribute("ConfigVersion", LaunchContract.configVersion)
serverRoot:SetAttribute("LaunchIdentityCount", LaunchContract.validation.counts.identities)
serverRoot:SetAttribute("LaunchFormCount", LaunchContract.validation.counts.forms)

local fixtureResult = LaunchContract.calculate(Phase001Fixtures.crownRun())
assert(fixtureResult.accepted, "P001-STUDIO-001 server fixture rejected")
serverRoot:SetAttribute("Phase001FormationId", fixtureResult.formation.id)
serverRoot:SetAttribute("Phase001Cash", fixtureResult.components.cash)
serverRoot:SetAttribute("Phase001Power", fixtureResult.components.power)
serverRoot:SetAttribute("Phase001Guard", fixtureResult.components.guard)
serverRoot:SetAttribute("Phase001TraceEntries", #fixtureResult.trace)
serverRoot:SetAttribute("BootstrapState", "ready")
