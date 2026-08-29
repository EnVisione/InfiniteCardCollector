--!strict

local Catalogs = script.Parent.Catalogs
local Config = script.Parent.Config
local Math = script.Parent.Math
local Projection = script.Parent.Projection

local LaunchCatalog = require(Catalogs.LaunchCatalog)
local LaunchValidator = require(Catalogs.LaunchValidator)
local LaunchConfig = require(Config.LaunchConfig)
local FormationDetector = require(Math.FormationDetector)
local JokerRegistry = require(Math.JokerRegistry)
local SafeNumber = require(Math.SafeNumber)
local ScoreCalculator = require(Math.ScoreCalculator)
local ClientProjection = require(Projection.ClientProjection)

local validation = LaunchValidator.validate(LaunchCatalog, LaunchConfig)

local dependencies = {
	catalog = LaunchCatalog,
	config = LaunchConfig,
	formationDetector = FormationDetector,
	jokerRegistry = JokerRegistry,
	safeNumber = SafeNumber,
}

local LaunchContract = {
	catalogVersion = LaunchCatalog.catalogVersion,
	configVersion = LaunchConfig.configVersion,
	fixtureVersion = LaunchConfig.fixtureVersion,
	validation = validation,
	clientCatalog = ClientProjection.catalog(LaunchCatalog, LaunchConfig),
}

function LaunchContract.calculate(input: any): any
	return ScoreCalculator.calculate(dependencies, input)
end

function LaunchContract.projectCalculation(result: any): any
	return ClientProjection.calculation(result)
end

return table.freeze(LaunchContract)
