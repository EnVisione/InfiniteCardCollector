--!strict

local ClientProjection = {}

local function deepCopy(value: any): any
	if type(value) ~= "table" then
		return value
	end
	local result = {}
	for key, child in value do
		result[deepCopy(key)] = deepCopy(child)
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

local function copyArray(
	records: { any },
	fields: { string },
	enabledOnly: boolean,
	sortById: boolean,
	balances: any?
): { any }
	local result = {}
	for _, record in records do
		if not enabledOnly or record.launchEnabled ~= false then
			local projected = {}
			for _, field in fields do
				projected[field] = deepCopy(record[field])
			end
			if balances ~= nil then
				local balance = balances[record.balanceId]
				assert(balance ~= nil, "P001-PROJECTION-001 balance missing")
				for field, value in balance do
					projected[field] = deepCopy(value)
				end
			end
			table.insert(result, projected)
		end
	end
	if sortById then
		table.sort(result, function(left, right)
			return left.id < right.id
		end)
	end
	return result
end

function ClientProjection.catalog(catalog: any, config: any): any
	return deepFreeze({
		catalogVersion = catalog.catalogVersion,
		configVersion = config.configVersion,
		fixtureVersion = config.fixtureVersion,
		deckSets = copyArray(
			catalog.deckSets,
			{ "id", "displayName", "affinityId", "assetContractId" },
			true,
			false,
			nil
		),
		ranks = copyArray(
			catalog.ranks,
			{ "id", "displayName", "value", "order" },
			false,
			false,
			nil
		),
		suits = copyArray(
			catalog.suits,
			{ "id", "displayName", "color", "order" },
			false,
			false,
			nil
		),
		editions = copyArray(
			catalog.editions,
			{ "id", "displayName", "assetContractId" },
			true,
			false,
			config.balance.editions
		),
		grades = copyArray(
			catalog.grades,
			{ "id", "displayName" },
			false,
			false,
			config.balance.grades
		),
		powerTiers = copyArray(
			catalog.powerTiers,
			{ "id", "displayName" },
			false,
			false,
			config.balance.powerTiers
		),
		traits = copyArray(
			catalog.traits,
			{ "id", "displayName" },
			false,
			false,
			config.balance.traits
		),
		jokers = copyArray(
			catalog.jokers,
			{ "id", "displayName", "rarityId", "stages", "assetContractId" },
			true,
			false,
			config.balance.jokers
		),
		arcana = copyArray(
			catalog.arcana,
			{ "id", "displayName", "categoryId", "targetId", "assetContractId" },
			true,
			false,
			nil
		),
		formations = copyArray(
			catalog.formations,
			{ "id", "displayName", "priority", "stackableBonusIds", "assetContractId" },
			false,
			false,
			config.balance.formations
		),
		stackableBonuses = copyArray(
			catalog.stackableBonuses,
			{ "id", "displayName" },
			false,
			false,
			config.balance.stackableBonuses
		),
		economy = ClientProjection.economy(config, catalog.catalogVersion),
	})
end

function ClientProjection.economy(config: any, catalogVersion: number): any
	assert(
		type(catalogVersion) == "number" and catalogVersion % 1 == 0 and catalogVersion > 0,
		"P001-PROJECTION-002 catalog version invalid"
	)
	local currencyCaps = {}
	for _, currency in config.economy.currencies do
		if currency.launchEnabled ~= false then
			currencyCaps[currency.id] = currency.cap
		end
	end
	local tierOdds = {}
	for _, entry in config.odds.powerTiers do
		table.insert(tierOdds, { id = entry.id, weight = entry.weight })
	end
	local jokerOdds = {}
	for _, entry in config.odds.jokerRarities do
		table.insert(jokerOdds, { id = entry.id, weight = entry.weight })
	end
	return deepFreeze({
		catalogVersion = catalogVersion,
		configVersion = config.configVersion,
		fixtureVersion = config.fixtureVersion,
		packPrices = deepCopy(config.economy.packPrices),
		currencyCaps = currencyCaps,
		weightTotal = config.odds.weightTotal,
		powerTierOdds = tierOdds,
		jokerRarityOdds = jokerOdds,
		traitChanceUnits = config.odds.traitChanceUnits,
		pity = deepCopy(config.odds.pity),
		earlyProtection = deepCopy(config.odds.earlyProtection),
		activeBaselinePerMinute = config.economy.activeBaselinePerMinute,
		passivePercentOfActive = config.economy.passivePercentOfActive,
	})
end

function ClientProjection.calculation(result: any): any
	local projectedTrace = {}
	for _, entry in result.trace do
		table.insert(projectedTrace, {
			stageId = entry.stageId,
			handlerId = entry.handlerId,
			componentId = entry.componentId,
			operation = entry.operation,
			input = entry.input,
			numerator = entry.numerator,
			denominator = entry.denominator,
			output = entry.output,
			reasonId = entry.reasonId,
		})
	end
	return deepFreeze({
		accepted = result.accepted,
		reasonId = result.reasonId,
		formationId = if result.formation ~= nil then result.formation.id else nil,
		components = deepCopy(result.components),
		stateIntents = deepCopy(result.stateIntents),
		trace = projectedTrace,
		versions = deepCopy(result.versions),
	})
end

return table.freeze(ClientProjection)
