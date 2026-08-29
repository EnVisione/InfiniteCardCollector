--!strict

local fs = require("@lune/fs")
local serde = require("@lune/serde")

local ArtifactCore = require("./lib/artifact-core")
local Common = require("./lib/common")
local Catalog = require("../src/shared/Catalogs/LaunchCatalog")
local Validator = require("../src/shared/Catalogs/LaunchValidator")
local Config = require("../src/shared/Config/LaunchConfig")
local Fixture = require("../src/shared/Fixtures/Phase001Fixtures")
local Detector = require("../src/shared/Math/FormationDetector")
local JokerRegistry = require("../src/shared/Math/JokerRegistry")
local RollContract = require("../src/shared/Math/RollContract")
local SafeNumber = require("../src/shared/Math/SafeNumber")
local ScoreCalculator = require("../src/shared/Math/ScoreCalculator")
local ClientProjection = require("../src/shared/Projection/ClientProjection")

local Phase001Test = {}

local dependencies = {
	catalog = Catalog,
	config = Config,
	formationDetector = Detector,
	jokerRegistry = JokerRegistry,
	safeNumber = SafeNumber,
}

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

local function card(
	instanceId: string,
	rankId: string,
	suitId: string,
	deckSetId: string?,
	editionId: string?,
	gradeId: string?,
	tierId: string?,
	traitId: string?
): any
	return {
		instanceId = instanceId,
		deckSetId = deckSetId or "classic",
		rankId = rankId,
		suitId = suitId,
		editionId = editionId or "normal",
		gradeId = gradeId or "f",
		powerTierId = tierId or "common",
		traitId = traitId,
	}
end

local function scoreInput(cards: { any }, jokers: { string }?): any
	return {
		catalogVersion = Catalog.catalogVersion,
		configVersion = Config.configVersion,
		cards = cards,
		activeJokerIds = jokers or {},
		activeDeckSetCounts = { classic = 52 },
		activeDeckFilledSlots = 52,
		discoveredFormCount = 624,
		formationTarget = nil,
		formationStreak = 3,
		successfulFormationCount = 24,
		criticalTraitInstanceIds = {},
		modeId = "formation_rush",
		personalActiveBoostMultipliers = {},
		serverEventBoostMultipliers = {},
	}
end

local function crownCards(): { any }
	return {
		card("crown_10", "10", "hearts"),
		card("crown_jack", "jack", "diamonds", "classic", "foil", "e", "uncommon", "swift"),
		card("crown_queen", "queen", "clubs", "classic", "steel", "s", "legendary", "guardian"),
		card("crown_king", "king", "spades", "classic", "normal", "a", "mythic"),
		card("crown_ace", "ace", "spades", "classic", "golden", "lr", "infernal", "fortune"),
	}
end

local function candidateIds(result: any): { [string]: boolean }
	local ids = {}
	for _, candidate in result.candidates do
		ids[candidate.id] = true
	end
	return ids
end

local function permutations(values: { any }): { { any } }
	local results = {}
	local used = {}
	local current = {}
	local function visit()
		if #current == #values then
			table.insert(results, table.clone(current))
			return
		end
		for index, value in values do
			if not used[index] then
				used[index] = true
				table.insert(current, value)
				visit()
				table.remove(current)
				used[index] = nil
			end
		end
	end
	visit()
	return results
end

local function hashCanonical(value: any): string
	return serde.hash("sha256", ArtifactCore.canonicalJson(value))
end

local function buildGoldenCorpus(): any
	local jokerResults = {}
	for _, joker in Catalog.jokers do
		if joker.launchEnabled == true then
			local input = scoreInput(crownCards(), { joker.id })
			if joker.id == "balanced_scales" or joker.id == "full_spectrum" then
				input.cards = {
					card("spectrum_2", "2", "hearts"),
					card("spectrum_5", "5", "diamonds"),
					card("spectrum_8", "8", "clubs"),
					card("spectrum_king", "king", "spades"),
				}
			elseif joker.id == "streak_keeper" then
				input.cards = {
					card("miss_2", "2", "hearts"),
					card("miss_3", "3", "clubs"),
				}
			end
			local result = ScoreCalculator.calculate(dependencies, input)
			jokerResults[joker.id] = {
				accepted = result.accepted,
				reasonId = result.reasonId,
				formationId = if result.formation ~= nil then result.formation.id else nil,
				components = result.components,
				stateIntents = result.stateIntents,
				trace = result.trace,
			}
		end
	end
	return jokerResults
end

local function buildPairwiseCorpus(): any
	local enabled = {}
	for _, joker in Catalog.jokers do
		if joker.launchEnabled == true then
			table.insert(enabled, joker.id)
		end
	end
	local results = {}
	for left = 1, #enabled do
		for right = left + 1, #enabled do
			local leftId = enabled[left]
			local rightId = enabled[right]
			local result = ScoreCalculator.calculate(
				dependencies,
				scoreInput(crownCards(), { leftId, rightId })
			)
			table.insert(results, {
				leftId = leftId,
				rightId = rightId,
				accepted = result.accepted,
				reasonId = result.reasonId,
				formationId = if result.formation ~= nil then result.formation.id else nil,
				components = result.components,
				stateIntents = result.stateIntents,
			})
		end
	end
	return results
end

function Phase001Test.register(addTest: any, expectFailure: any)
	addTest("P001-TEST-001-entry-and-versions", function()
		local goalContents = fs.readFile("docs/plan/goal.md")
		assert(
			serde.hash("sha256", goalContents)
				== "fbe125681fc52b42131aa7aa1f4f61902d33c7912adc982ebcb7dbd87cff2f69",
			"P001-ENTRY-001 goal digest changed"
		)
		local handoffContents = fs.readFile("docs/general/plan.handoff.json")
		local handoff = serde.decode("json", handoffContents)
		assert(
			handoff.planSetSha256
				== "4b7b03e8d70b5f5650e265f115d15878329742409825b07cd515079882556b3c",
			"P001-ENTRY-002 plan set mismatch"
		)
		assert(Catalog.catalogVersion == 1, "P001-ENTRY-003 catalog version")
		assert(
			Config.configVersion == 1 and Config.fixtureVersion == 1,
			"P001-ENTRY-004 config version"
		)
	end)

	addTest("P001-TEST-002-catalog-counts-and-keys", function()
		local snapshot = Validator.validate(Catalog, Config)
		assert(snapshot.counts.deckSets == 3, "P001-TEST-002 deck sets")
		assert(snapshot.counts.identities == 156, "P001-TEST-002 identities")
		assert(snapshot.counts.editions == 4, "P001-TEST-002 editions")
		assert(snapshot.counts.forms == 624, "P001-TEST-002 forms")
		assert(snapshot.counts.grades == 11, "P001-TEST-002 grades")
		assert(snapshot.counts.powerTiers == 11, "P001-TEST-002 tiers")
		assert(snapshot.counts.traits == 12, "P001-TEST-002 traits")
		assert(snapshot.counts.jokers == 24, "P001-TEST-002 jokers")
		assert(snapshot.counts.arcana == 12, "P001-TEST-002 arcana")
		assert(snapshot.counts.formations == 12, "P001-TEST-002 formations")
		assert(snapshot.counts.stackableBonuses == 1, "P001-TEST-002 stackable bonuses")
		assert(snapshot.counts.souls == 0, "P001-TEST-002 souls")
		assert(Catalog.slotKey("ace", "spades") == "ace:spades", "P001-TEST-002 slot")
		assert(
			Catalog.baseIdentityKey("radioactive", "ace", "spades") == "radioactive:ace:spades",
			"P001-TEST-002 identity"
		)
		assert(
			Catalog.formKey("radioactive:ace:spades", "golden") == "radioactive:ace:spades:golden",
			"P001-TEST-002 form"
		)
		assert(
			ArtifactCore.canonicalJson(snapshot)
				== ArtifactCore.canonicalJson(Validator.validate(Catalog, Config)),
			"P001-TEST-002 snapshot drift"
		)
	end)

	addTest("P001-TEST-003-card-axes", function()
		assert(
			Catalog.grades[1].id == "f" and Config.balance.grades.f.cumulativeXp == 0,
			"P001-TEST-003 grade start"
		)
		assert(
			Catalog.grades[11].id == "lr" and Config.balance.grades.lr.cumulativeXp == 9600,
			"P001-TEST-003 grade end"
		)
		assert(Catalog.powerTiers[1].id == "common", "P001-TEST-003 tier start")
		assert(Catalog.powerTiers[11].id == "zenith", "P001-TEST-003 tier end")
		assert(Catalog.editions[2].id == "foil", "P001-TEST-003 foil")
		assert(Catalog.editions[3].id == "golden", "P001-TEST-003 golden")
		assert(Catalog.editions[4].id == "steel", "P001-TEST-003 steel")
		for index = 2, #Catalog.grades do
			local current = Config.balance.grades[Catalog.grades[index].balanceId]
			local previous = Config.balance.grades[Catalog.grades[index - 1].balanceId]
			assert(current.cumulativeXp > previous.cumulativeXp, "P001-TEST-003 nonmonotonic grade")
		end
		for _, affinity in Catalog.affinities do
			local balance = Config.balance.affinities[affinity.balanceId]
			assert(table.concat(balance.thresholds, ",") == "13,26,39,52", "P001-TEST-003 affinity")
		end
	end)

	addTest("P001-TEST-004-special-content", function()
		local snapshot = Validator.validate(Catalog, Config)
		assert(#snapshot.enabledIds.jokers == 24, "P001-TEST-004 joker count")
		assert(#snapshot.enabledIds.arcana == 12, "P001-TEST-004 arcana count")
		local rarityCounts = {}
		for _, joker in Catalog.jokers do
			if joker.launchEnabled == true then
				rarityCounts[joker.rarityId] = (rarityCounts[joker.rarityId] or 0) + 1
			end
		end
		assert(
			rarityCounts.common == 8
				and rarityCounts.uncommon == 5
				and rarityCounts.rare == 4
				and rarityCounts.epic == 3
				and rarityCounts.legendary == 2
				and rarityCounts.mythic == 2,
			"P001-TEST-004 rarity distribution"
		)
	end)

	addTest("P001-TEST-005-economy-contract", function()
		local currencyIds = {}
		for _, currency in Config.economy.currencies do
			currencyIds[currency.id] = true
			assert(currency.transferRule == "not_tradable", "P001-TEST-005 transfer")
			if currency.id ~= "soul_fragments" then
				assert(
					#currency.sourceReasonIds > 0 and #currency.sinkReasonIds > 0,
					"P001-TEST-005 coverage"
				)
			end
		end
		for _, requiredId in
			{
				"cash",
				"joker_tickets",
				"arcana_dust",
				"grade_ink",
				"trait_essence",
				"duel_tokens",
				"ascension_fragments",
				"soul_fragments",
			}
		do
			assert(currencyIds[requiredId], "P001-TEST-005 currency missing")
		end
		assert(
			Config.economy.activeBaselinePerMinute * 100
				>= Config.economy.activeBaselinePerMinute
					* Config.economy.passivePercentOfActive
					* 5,
			"P001-TEST-005 ratio"
		)
		assert(Config.economy.packPrices.classic == 500, "P001-TEST-005 classic price")
		assert(Config.economy.packPrices.radioactive == 800, "P001-TEST-005 radioactive price")
		assert(Config.economy.packPrices.astral == 1200, "P001-TEST-005 astral price")
	end)

	addTest("P001-TEST-006-rng-and-pity", function()
		RollContract.validateWeights(Config.odds.powerTiers, 100000)
		RollContract.validateWeights(Config.odds.jokerRarities, 100000)
		assert(Config.odds.traitChanceUnits == 10000, "P001-TEST-006 trait chance")
		local before = RollContract.rollWithPity(
			Config.odds.powerTiers,
			100000,
			"seed_rare_before",
			1,
			18,
			Config.odds.pity.rare,
			1,
			1
		)
		assert(
			before.selectedId == "common" and before.postCommitPity == 19,
			"P001-TEST-006 before pity"
		)
		local at = RollContract.rollWithPity(
			Config.odds.powerTiers,
			100000,
			"seed_rare_at",
			1,
			19,
			Config.odds.pity.rare,
			1,
			1
		)
		assert(at.selectedId == "rare" and at.postCommitPity == 0, "P001-TEST-006 pity boundary")
		assert(
			at.baseSelectedId == "common"
				and at.baseBucketStart == 1
				and at.baseBucketEnd == 66000
				and at.selectedBucketStart == 86001
				and at.selectedBucketEnd == 94000
				and at.pityApplied == true,
			"P001-TEST-006 forced bucket record"
		)
		local naturalAtPity = RollContract.rollWithPity(
			Config.odds.powerTiers,
			100000,
			"seed_natural_rare_at_pity",
			86001,
			19,
			Config.odds.pity.rare,
			1,
			1
		)
		assert(
			naturalAtPity.selectedId == "rare"
				and naturalAtPity.baseSelectedId == "rare"
				and naturalAtPity.pityApplied == false,
			"P001-TEST-006 natural pity roll"
		)
		for _, pityCase in
			{
				{ "tier_legendary", Config.odds.powerTiers, Config.odds.pity.legendary },
				{ "tier_mythic", Config.odds.powerTiers, Config.odds.pity.mythic },
				{ "joker_epic", Config.odds.jokerRarities, Config.odds.pity.jokerEpic },
				{
					"joker_legendary",
					Config.odds.jokerRarities,
					Config.odds.pity.jokerLegendary,
				},
			}
		do
			local rule = pityCase[3]
			local result = RollContract.rollWithPity(
				pityCase[2],
				100000,
				pityCase[1],
				1,
				rule.threshold - 1,
				rule,
				1,
				1
			)
			assert(
				result.baseSelectedId == "common"
					and result.selectedId == rule.minimumId
					and result.pityApplied == true
					and result.postCommitPity == 0,
				"P001-TEST-006 pity class, " .. pityCase[1]
			)
		end
		local lastBucket = RollContract.rollWithPity(
			Config.odds.powerTiers,
			100000,
			"last_bucket",
			100000,
			0,
			Config.odds.pity.mythic,
			1,
			1
		)
		assert(
			lastBucket.selectedId == "zenith"
				and lastBucket.baseBucketStart == 100000
				and lastBucket.baseBucketEnd == 100000,
			"P001-TEST-006 final bucket"
		)
		local repeated = RollContract.rollWithPity(
			Config.odds.powerTiers,
			100000,
			"seed_rare_at",
			1,
			19,
			Config.odds.pity.rare,
			1,
			1
		)
		assert(
			ArtifactCore.canonicalJson(at) == ArtifactCore.canonicalJson(repeated),
			"P001-TEST-006 replay"
		)
		assert(RollContract.minimumMissingTargets(0) == 3, "P001-TEST-006 early protection")
		assert(RollContract.minimumMissingTargets(25) == 3, "P001-TEST-006 before 26")
		assert(RollContract.minimumMissingTargets(26) == 1, "P001-TEST-006 at 26")
		assert(RollContract.minimumMissingTargets(44) == 1, "P001-TEST-006 at 44")
		assert(RollContract.minimumMissingTargets(45) == 0, "P001-TEST-006 at 45")
		expectFailure(function()
			RollContract.rollWithPity(
				Config.odds.powerTiers,
				100000,
				"stale_pity",
				1,
				20,
				Config.odds.pity.rare,
				1,
				1
			)
		end, "P001-RNG-015")
	end)

	addTest("P001-TEST-007-safe-number", function()
		assert(SafeNumber.add(2, 3) == 5, "P001-TEST-007 add")
		assert(SafeNumber.subtract(5, 3) == 2, "P001-TEST-007 subtract")
		assert(SafeNumber.multiply(7, 8) == 56, "P001-TEST-007 multiply")
		assert(
			SafeNumber.scale(5, { numerator = 150, denominator = 100 }) == 8,
			"P001-TEST-007 half up"
		)
		assert(
			SafeNumber.scale(4, { numerator = 125, denominator = 100 }) == 5,
			"P001-TEST-007 exact"
		)
		assert(
			SafeNumber.assertInteger(SafeNumber.MAX_LAUNCH_INTEGER) == SafeNumber.MAX_LAUNCH_INTEGER,
			"P001-TEST-007 max"
		)
		for value = 0, 500 do
			assert(
				SafeNumber.scale(value, { numerator = 1, denominator = 1 }) == value,
				"P001-TEST-007 identity property"
			)
			local numerator = value % 17
			local denominator = (value % 13) + 1
			local expected =
				math.floor((value * numerator + math.floor(denominator / 2)) / denominator)
			assert(
				SafeNumber.scale(value, { numerator = numerator, denominator = denominator })
					== expected,
				"P001-TEST-007 rounding property"
			)
		end
		for left = 0, 50 do
			for right = 0, 50 do
				assert(
					SafeNumber.add(left, right) == SafeNumber.add(right, left)
						and SafeNumber.multiply(left, right) == SafeNumber.multiply(right, left),
					"P001-TEST-007 commutative property"
				)
			end
		end
		expectFailure(function()
			SafeNumber.assertInteger(0 / 0)
		end, "P001-NUMBER-001")
		expectFailure(function()
			SafeNumber.assertInteger(math.huge)
		end, "P001-NUMBER-001")
		expectFailure(function()
			SafeNumber.assertInteger(1.5)
		end, "P001-NUMBER-001")
		expectFailure(function()
			SafeNumber.subtract(0, 1)
		end, "P001-NUMBER-007")
		expectFailure(function()
			SafeNumber.add(SafeNumber.MAX_LAUNCH_INTEGER, 1)
		end, "P001-NUMBER-006")
		expectFailure(function()
			SafeNumber.scale(1, { numerator = 1, denominator = 0 })
		end, "P001-NUMBER-005")
		expectFailure(function()
			SafeNumber.multiply(SafeNumber.MAX_LAUNCH_INTEGER, 2)
		end, "P001-NUMBER-008")
		expectFailure(function()
			SafeNumber.assertRational({ numerator = -1, denominator = 1 })
		end, "P001-NUMBER-002")
		local capped, capTrace = SafeNumber.applyCap(11, "test_cap", 10)
		assert(
			capped == 10
				and capTrace.capId == "test_cap"
				and capTrace.originalValue == 11
				and capTrace.capValue == 10,
			"P001-TEST-007 gameplay cap trace"
		)
		local uncapped, noCapTrace = SafeNumber.applyCap(10, "test_cap", 10)
		assert(uncapped == 10 and noCapTrace == nil, "P001-TEST-007 cap boundary")
	end)

	addTest("P001-TEST-008-formations", function()
		local fixtures = {
			{ "single", { card("s1", "2", "hearts") }, nil },
			{ "twin", { card("t1", "5", "hearts"), card("t2", "5", "clubs") }, nil },
			{
				"twin_pair",
				{
					card("tp1", "5", "hearts"),
					card("tp2", "5", "clubs"),
					card("tp3", "7", "diamonds"),
					card("tp4", "7", "spades"),
				},
				nil,
			},
			{
				"triple",
				{
					card("tr1", "5", "hearts"),
					card("tr2", "5", "clubs"),
					card("tr3", "5", "diamonds"),
				},
				nil,
			},
			{
				"sequence",
				{
					card("sq1", "2", "hearts"),
					card("sq2", "3", "clubs"),
					card("sq3", "4", "diamonds"),
				},
				nil,
			},
			{
				"monosuit",
				{
					card("ms1", "2", "hearts"),
					card("ms2", "5", "hearts"),
					card("ms3", "9", "hearts"),
				},
				nil,
			},
			{
				"court",
				{
					card("ct1", "jack", "hearts"),
					card("ct2", "queen", "clubs"),
					card("ct3", "king", "diamonds"),
				},
				nil,
			},
			{
				"spectrum",
				{
					card("sp1", "2", "hearts"),
					card("sp2", "5", "diamonds"),
					card("sp3", "8", "clubs"),
					card("sp4", "king", "spades"),
				},
				nil,
			},
			{
				"full_cluster",
				{
					card("fc1", "5", "hearts"),
					card("fc2", "5", "diamonds"),
					card("fc3", "5", "clubs"),
					card("fc4", "7", "hearts"),
					card("fc5", "7", "spades"),
				},
				nil,
			},
			{
				"quad",
				{
					card("q1", "5", "hearts"),
					card("q2", "5", "diamonds"),
					card("q3", "5", "clubs"),
					card("q4", "5", "spades"),
				},
				nil,
			},
			{ "crown_run", crownCards(), nil },
			{
				"perfect_sum",
				{
					card("ps1", "2", "hearts"),
					card("ps2", "3", "clubs"),
					card("ps3", "4", "diamonds"),
				},
				9,
			},
		}
		for _, fixture in fixtures do
			local result = Detector.detect(Catalog, Config, fixture[2], fixture[3])
			assert(
				candidateIds(result)[fixture[1]],
				"P001-TEST-008 missing formation, " .. fixture[1]
			)
			for _, permutation in permutations(fixture[2]) do
				local permutedResult = Detector.detect(Catalog, Config, permutation, fixture[3])
				assert(
					ArtifactCore.canonicalJson(candidateIds(permutedResult))
							== ArtifactCore.canonicalJson(candidateIds(result))
						and permutedResult.selected.id == result.selected.id
						and ArtifactCore.canonicalJson(
								permutedResult.selected.stackableBonusIds
							)
							== ArtifactCore.canonicalJson(result.selected.stackableBonusIds),
					"P001-TEST-008 permutation property, " .. fixture[1]
				)
			end
		end
		local nearMiss = Detector.detect(
			Catalog,
			Config,
			{ card("nm1", "2", "hearts"), card("nm2", "4", "clubs") },
			nil
		)
		assert(nearMiss.selected == nil, "P001-TEST-008 near miss accepted")
		expectFailure(function()
			Detector.detect(
				Catalog,
				Config,
				{ card("dup", "2", "hearts"), card("dup", "2", "clubs") },
				nil
			)
		end, "P001-FORMATION-005")
		expectFailure(function()
			Detector.detect(Catalog, Config, {
				card("slot_one", "5", "hearts", "classic"),
				card("slot_two", "5", "hearts", "astral"),
			}, nil)
		end, "P001-FORMATION-019")
		local crown = Detector.detect(Catalog, Config, crownCards(), 60)
		assert(crown.selected.id == "crown_run", "P001-TEST-008 best base")
		assert(candidateIds(crown).perfect_sum, "P001-TEST-008 overlap")
		assert(
			crown.selected.stackableBonusIds[1] == "perfect_sum_accuracy",
			"P001-TEST-008 stackable bonus"
		)
		local crownPermutation = crownCards()
		crownPermutation = {
			crownPermutation[5],
			crownPermutation[3],
			crownPermutation[1],
			crownPermutation[4],
			crownPermutation[2],
		}
		local permuted = Detector.detect(Catalog, Config, crownPermutation, 60)
		assert(
			ArtifactCore.canonicalJson(candidateIds(crown))
					== ArtifactCore.canonicalJson(candidateIds(permuted))
				and permuted.selected.id == crown.selected.id,
			"P001-TEST-008 permutation drift"
		)

		local nearMisses = {
			{ "twin", { card("mt1", "2", "hearts"), card("mt2", "3", "clubs") }, nil },
			{
				"twin_pair",
				{
					card("mtp1", "2", "hearts"),
					card("mtp2", "2", "clubs"),
					card("mtp3", "3", "diamonds"),
					card("mtp4", "4", "spades"),
				},
				nil,
			},
			{
				"triple",
				{
					card("mtr1", "2", "hearts"),
					card("mtr2", "2", "clubs"),
					card("mtr3", "3", "diamonds"),
				},
				nil,
			},
			{
				"sequence",
				{
					card("msq1", "2", "hearts"),
					card("msq2", "3", "clubs"),
					card("msq3", "5", "diamonds"),
				},
				nil,
			},
			{
				"monosuit",
				{
					card("mms1", "2", "hearts"),
					card("mms2", "5", "hearts"),
					card("mms3", "9", "clubs"),
				},
				nil,
			},
			{
				"court",
				{
					card("mct1", "jack", "hearts"),
					card("mct2", "queen", "clubs"),
					card("mct3", "ace", "diamonds"),
				},
				nil,
			},
			{
				"spectrum",
				{
					card("msp1", "2", "hearts"),
					card("msp2", "5", "diamonds"),
					card("msp3", "8", "clubs"),
					card("msp4", "king", "clubs"),
				},
				nil,
			},
			{
				"full_cluster",
				{
					card("mfc1", "2", "hearts"),
					card("mfc2", "2", "diamonds"),
					card("mfc3", "3", "clubs"),
					card("mfc4", "3", "hearts"),
					card("mfc5", "4", "spades"),
				},
				nil,
			},
			{
				"quad",
				{
					card("mq1", "2", "hearts"),
					card("mq2", "2", "diamonds"),
					card("mq3", "2", "clubs"),
					card("mq4", "3", "spades"),
				},
				nil,
			},
			{
				"crown_run",
				{
					card("mcr1", "9", "hearts"),
					card("mcr2", "jack", "diamonds"),
					card("mcr3", "queen", "clubs"),
					card("mcr4", "king", "spades"),
					card("mcr5", "ace", "hearts"),
				},
				nil,
			},
			{
				"perfect_sum",
				{ card("mps1", "2", "hearts"), card("mps2", "3", "clubs") },
				6,
			},
		}
		for _, fixture in nearMisses do
			local result = Detector.detect(Catalog, Config, fixture[2], fixture[3])
			assert(not candidateIds(result)[fixture[1]], "P001-TEST-008 near miss, " .. fixture[1])
		end
		expectFailure(function()
			Detector.detect(Catalog, Config, {}, nil)
		end, "P001-FORMATION-002")
		expectFailure(function()
			Detector.detect(Catalog, Config, {
				card("six1", "2", "hearts"),
				card("six2", "3", "clubs"),
				card("six3", "4", "diamonds"),
				card("six4", "5", "spades"),
				card("six5", "6", "hearts"),
				card("six6", "7", "clubs"),
			}, nil)
		end, "P001-FORMATION-002")
		expectFailure(function()
			Detector.detect(Catalog, Config, { card("bad_rank", "one", "hearts") }, nil)
		end, "P001-FORMATION-007")
		expectFailure(function()
			Detector.detect(Catalog, Config, { card("bad_target", "2", "hearts") }, 2.5)
		end, "P001-FORMATION-011")
		expectFailure(function()
			local blank = { instanceId = "blank", isBlank = true, rankId = "2" }
			Detector.detect(Catalog, Config, { blank }, nil)
		end, "P001-FORMATION-006")
	end)

	addTest("P001-TEST-009-score-and-table-order", function()
		local first = ScoreCalculator.calculate(dependencies, Fixture.crownRun())
		local secondInput = Fixture.crownRun()
		secondInput.activeDeckSetCounts = {}
		secondInput.activeDeckSetCounts.classic = 0
		secondInput.activeDeckSetCounts.radioactive = 52
		secondInput.personalActiveBoostMultipliers = {}
		secondInput.personalActiveBoostMultipliers.personal_output = {
			numerator = 110,
			denominator = 100,
		}
		local second = ScoreCalculator.calculate(dependencies, secondInput)
		assert(first.accepted and second.accepted, "P001-TEST-009 rejected")
		assert(first.formation.id == "crown_run", "P001-TEST-009 selected formation")
		assert(
			ArtifactCore.canonicalJson(first) == ArtifactCore.canonicalJson(second),
			"P001-TEST-009 table order drift"
		)
		assert(first.components.cash > 0, "P001-TEST-009 cash")
		assert(first.components.power > 0, "P001-TEST-009 power")
		assert(first.components.guard > 0, "P001-TEST-009 guard")
		assert(first.components.cash <= Config.gameplayCaps.cash, "P001-TEST-009 cap")
		local boostLeft = Fixture.crownRun()
		boostLeft.personalActiveBoostMultipliers = {
			alpha = { numerator = 105, denominator = 100 },
			beta = { numerator = 110, denominator = 100 },
		}
		local boostRight = Fixture.crownRun()
		boostRight.personalActiveBoostMultipliers = {}
		boostRight.personalActiveBoostMultipliers.beta = { numerator = 110, denominator = 100 }
		boostRight.personalActiveBoostMultipliers.alpha = { numerator = 105, denominator = 100 }
		assert(
			ArtifactCore.canonicalJson(ScoreCalculator.calculate(dependencies, boostLeft))
				== ArtifactCore.canonicalJson(ScoreCalculator.calculate(dependencies, boostRight)),
			"P001-TEST-009 boost map order drift"
		)
	end)

	addTest("P001-TEST-010-joker-registry", function()
		local corpus = buildGoldenCorpus()
		local count = 0
		for jokerId, result in corpus do
			count += 1
			local found = false
			for _, entry in result.trace do
				if entry.reasonId == jokerId then
					found = true
					break
				end
			end
			assert(found, "P001-TEST-010 joker trace missing, " .. jokerId)
		end
		assert(count == 24, "P001-TEST-010 joker count")
		local enabled = {}
		for _, joker in Catalog.jokers do
			if joker.launchEnabled == true then
				table.insert(enabled, joker.id)
			end
		end
		local pairCount = 0
		for left = 1, #enabled do
			for right = left + 1, #enabled do
				local result = ScoreCalculator.calculate(
					dependencies,
					scoreInput(crownCards(), { enabled[left], enabled[right] })
				)
				assert(result.reasonId ~= "calculation_rejected", "P001-TEST-010 pair rejected")
				pairCount += 1
			end
		end
		assert(pairCount == 276, "P001-TEST-010 pair count")
		local five = ScoreCalculator.calculate(dependencies, Fixture.crownRun())
		assert(five.accepted, "P001-TEST-010 five joker build")
		local sixthInput = Fixture.crownRun()
		table.insert(sixthInput.activeJokerIds, "pocket_ledger")
		assert(
			not ScoreCalculator.calculate(dependencies, sixthInput).accepted,
			"P001-TEST-010 sixth slot"
		)
		local unknown = scoreInput(crownCards(), { "unknown_joker" })
		assert(
			not ScoreCalculator.calculate(dependencies, unknown).accepted,
			"P001-TEST-010 unknown joker"
		)
	end)

	addTest("P001-TEST-011-validator-negatives", function()
		local duplicateCatalog = deepCopy(Catalog)
		table.insert(duplicateCatalog.traits, deepCopy(duplicateCatalog.traits[1]))
		expectFailure(function()
			Validator.validate(duplicateCatalog, Config)
		end, "P001-TRAIT-004")

		local missingCatalog = deepCopy(Catalog)
		table.remove(missingCatalog.identities)
		expectFailure(function()
			Validator.validate(missingCatalog, Config)
		end, "P001-CATALOG-012")

		local badHandler = deepCopy(Catalog)
		badHandler.jokers[1].handlerId = "unknown_handler"
		expectFailure(function()
			Validator.validate(badHandler, Config)
		end, "P001-CATALOG-038")

		local badStage = deepCopy(Catalog)
		badStage.jokers[1].stages = { "unknown_stage" }
		expectFailure(function()
			Validator.validate(badStage, Config)
		end, "P001-CATALOG-074")

		local futureEnabled = deepCopy(Catalog)
		futureEnabled.souls[1].launchEnabled = true
		expectFailure(function()
			Validator.validate(futureEnabled, Config)
		end, "P001-CATALOG-014")

		local badWeight = deepCopy(Config)
		badWeight.odds.powerTiers[1].weight -= 1
		expectFailure(function()
			Validator.validate(Catalog, badWeight)
		end, "P001-CONFIG-021")

		local badCurrency = deepCopy(Config)
		badCurrency.economy.currencies[8].cap = 1
		expectFailure(function()
			Validator.validate(Catalog, badCurrency)
		end, "P001-CONFIG-014")

		local badRatio = deepCopy(Config)
		badRatio.economy.passivePercentOfActive = 21
		expectFailure(function()
			Validator.validate(Catalog, badRatio)
		end, "P001-CONFIG-020")

		local badId = deepCopy(Catalog)
		badId.traits[1].id = "Fortune"
		expectFailure(function()
			Validator.validate(badId, Config)
		end, "P001-TRAIT-003")

		local missingAsset = deepCopy(Catalog)
		missingAsset.deckSets[1].assetContractId = nil
		expectFailure(function()
			Validator.validate(missingAsset, Config)
		end, "P001-CATALOG-064")

		local badReference = deepCopy(Catalog)
		badReference.deckSets[1].affinityId = "missing_affinity"
		expectFailure(function()
			Validator.validate(badReference, Config)
		end, "P001-CATALOG-037")

		local badStackableReference = deepCopy(Catalog)
		badStackableReference.formations[1].stackableBonusIds = { "missing_bonus" }
		expectFailure(function()
			Validator.validate(badStackableReference, Config)
		end, "P001-CATALOG-084")

		local unresolvedConflict = deepCopy(Catalog)
		unresolvedConflict.jokers[#unresolvedConflict.jokers].conflicts = {}
		expectFailure(function()
			Validator.validate(unresolvedConflict, Config)
		end, "P001-CATALOG-072")

		local illegalParameter = deepCopy(Config)
		illegalParameter.balance.jokers.pocket_ledger.params.percent = 1.5
		expectFailure(function()
			Validator.validate(Catalog, illegalParameter)
		end, "P001-BALANCE-014")

		local missingCap = deepCopy(Config)
		missingCap.balance.jokers.quick_shuffle.caps.percent = nil
		expectFailure(function()
			Validator.validate(Catalog, missingCap)
		end, "P001-BALANCE-090")

		local missingStackableBalance = deepCopy(Config)
		missingStackableBalance.balance.stackableBonuses.perfect_sum_accuracy = nil
		expectFailure(function()
			Validator.validate(Catalog, missingStackableBalance)
		end, "P001-BALANCE-093")

		local reorderedWeights = deepCopy(Config)
		reorderedWeights.odds.powerTiers[1], reorderedWeights.odds.powerTiers[2] =
			reorderedWeights.odds.powerTiers[2], reorderedWeights.odds.powerTiers[1]
		expectFailure(function()
			Validator.validate(Catalog, reorderedWeights)
		end, "P001-CONFIG-035")

		local staleConfig = deepCopy(Config)
		staleConfig.configVersion = 2
		expectFailure(function()
			Validator.validate(Catalog, staleConfig)
		end, "P001-CONFIG-001")

		local staleFixture = deepCopy(Config)
		staleFixture.fixtureVersion = 2
		expectFailure(function()
			Validator.validate(Catalog, staleFixture)
		end, "P001-CONFIG-069")

		local extraConfig = deepCopy(Config)
		extraConfig.unregistered = true
		expectFailure(function()
			Validator.validate(Catalog, extraConfig)
		end, "P001-CONFIG-070")

		local reorderedStages = deepCopy(Config)
		reorderedStages.calculationStages[1], reorderedStages.calculationStages[2] =
			reorderedStages.calculationStages[2], reorderedStages.calculationStages[1]
		expectFailure(function()
			Validator.validate(Catalog, reorderedStages)
		end, "P001-CONFIG-027")

		local malformedStages = deepCopy(Config)
		malformedStages.calculationStages.injected = "formation_multiplier"
		expectFailure(function()
			Validator.validate(Catalog, malformedStages)
		end, "P001-CONFIG-027")

		local retiredCollision = deepCopy(Catalog)
		table.insert(retiredCollision.retiredIds, "fortune")
		expectFailure(function()
			Validator.validate(retiredCollision, Config)
		end, "P001-CATALOG-081")

		local badCap = deepCopy(Config)
		badCap.gameplayCaps.cash = 0
		expectFailure(function()
			Validator.validate(Catalog, badCap)
		end, "P001-CONFIG-053")

		local badReason = deepCopy(Config)
		badReason.economy.currencies[1].sourceReasonIds[1] = "unknown_reason"
		expectFailure(function()
			Validator.validate(Catalog, badReason)
		end, "P001-CONFIG-015")
	end)

	addTest("P001-TEST-012-client-projection", function()
		local catalogProjection = ClientProjection.catalog(Catalog, Config)
		assert(#catalogProjection.deckSets == 3, "P001-TEST-012 deck sets")
		assert(#catalogProjection.editions == 4, "P001-TEST-012 editions")
		assert(#catalogProjection.jokers == 24, "P001-TEST-012 jokers")
		assert(catalogProjection.ranks[1].id == "2", "P001-TEST-012 rank order")
		assert(catalogProjection.ranks[9].id == "10", "P001-TEST-012 rank ten order")
		assert(
			catalogProjection.deckSets[1].assetContractId == "deck_set_classic",
			"P001-TEST-012 asset contract"
		)
		assert(
			catalogProjection.editions[3].multipliers.cash.numerator == 200,
			"P001-TEST-012 edition balance"
		)
		assert(
			catalogProjection.stackableBonuses[1].id == "perfect_sum_accuracy"
				and catalogProjection.stackableBonuses[1].multiplier.numerator == 110,
			"P001-TEST-012 stackable bonus"
		)
		assert(
			catalogProjection.formations[12].id == "perfect_sum"
				and catalogProjection.formations[12].stackableBonusIds[1]
					== "perfect_sum_accuracy",
			"P001-TEST-012 formation bonus projection"
		)
		assert(catalogProjection.jokers[1].handlerId == nil, "P001-TEST-012 handler leaked")
		assert(catalogProjection.economy.antiAbuse == nil, "P001-TEST-012 anti abuse leaked")
		for _, joker in catalogProjection.jokers do
			assert(joker.id ~= "fifth_law", "P001-TEST-012 future joker leaked")
		end
		assert(table.isfrozen(catalogProjection), "P001-TEST-012 projection mutable")
		assert(table.isfrozen(catalogProjection.jokers), "P001-TEST-012 nested projection mutable")
		expectFailure(function()
			catalogProjection.packPrices = {}
		end, "attempt to modify")
		local input = Fixture.crownRun()
		input.price = 1
		input.reward = 999999999
		local withClientAmounts = ScoreCalculator.calculate(dependencies, input)
		local authoritative = ScoreCalculator.calculate(dependencies, Fixture.crownRun())
		assert(
			ArtifactCore.canonicalJson(withClientAmounts.components)
				== ArtifactCore.canonicalJson(authoritative.components),
			"P001-TEST-012 client amount trusted"
		)
		local projection = ClientProjection.calculation(authoritative)
		assert(
			ArtifactCore.canonicalJson(projection.components)
				== ArtifactCore.canonicalJson(authoritative.components),
			"P001-TEST-012 component projection"
		)
		assert(#projection.trace == #authoritative.trace, "P001-TEST-012 trace projection")
		assert(table.isfrozen(projection.components), "P001-TEST-012 components mutable")
		assert(projection.trace[1].details == nil, "P001-TEST-012 private trace details leaked")
	end)

	addTest("P001-TEST-013-showcase-ordinary-path", function()
		local input = Fixture.crownRun()
		local result = ScoreCalculator.calculate(dependencies, input)
		assert(result.accepted and result.formation.id == "crown_run", "P001-TEST-013 showcase")
		for _, path in Common.listFiles("src/shared") do
			if path:match("%.luau$") and not path:find("/Fixtures/", 1, true) then
				local source = fs.readFile(path)
				assert(
					source:find("fixture_showcase_ace", 1, true) == nil
						and source:find("radioactive:ace:spades", 1, true) == nil,
					"P001-TEST-013 showcase special case, " .. path
				)
			end
		end
	end)

	addTest("P001-TEST-014-calculation-boundaries", function()
		local staleInput = Fixture.crownRun()
		staleInput.catalogVersion = 0
		local staleResult = ScoreCalculator.calculate(dependencies, staleInput)
		assert(
			not staleResult.accepted and staleResult.trace[1].reasonId == "P001-CALC-002",
			"P001-TEST-014 stale version"
		)

		local fractionalInput = Fixture.crownRun()
		fractionalInput.activeDeckFilledSlots = 51.5
		local fractionalResult = ScoreCalculator.calculate(dependencies, fractionalInput)
		assert(
			not fractionalResult.accepted and fractionalResult.components == nil,
			"P001-TEST-014 fractional trusted"
		)

		local nonfiniteInput = Fixture.crownRun()
		nonfiniteInput.formationStreak = math.huge
		assert(
			not ScoreCalculator.calculate(dependencies, nonfiniteInput).accepted,
			"P001-TEST-014 infinity trusted"
		)

		local countMismatch = Fixture.crownRun()
		countMismatch.activeDeckSetCounts.radioactive = 51
		assert(
			ScoreCalculator.calculate(dependencies, countMismatch).trace[1].reasonId
				== "P001-CALC-012",
			"P001-TEST-014 deck count mismatch"
		)

		local jokerMapShape = Fixture.crownRun()
		jokerMapShape.activeJokerIds = { "pocket_ledger" }
		jokerMapShape.activeJokerIds.injected = "paper_shield"
		assert(
			not ScoreCalculator.calculate(dependencies, jokerMapShape).accepted,
			"P001-TEST-014 joker map bypass"
		)

		local cardMapShape = Fixture.crownRun()
		cardMapShape.cards.injected = card("injected", "2", "hearts")
		assert(
			not ScoreCalculator.calculate(dependencies, cardMapShape).accepted,
			"P001-TEST-014 card map bypass"
		)

		local invalidNoMatch = scoreInput({
			card("invalid_set", "2", "hearts", "missing_set"),
			card("valid_set", "4", "clubs"),
		})
		local invalidNoMatchResult = ScoreCalculator.calculate(dependencies, invalidNoMatch)
		assert(
			not invalidNoMatchResult.accepted
				and invalidNoMatchResult.reasonId == "calculation_rejected"
				and invalidNoMatchResult.trace[1].reasonId == "P001-CALC-010",
			"P001-TEST-014 invalid no match state intent"
		)
		local absentDeckSet = scoreInput({ card("absent_set", "2", "hearts") })
		absentDeckSet.activeDeckSetCounts = { radioactive = 52 }
		local absentDeckSetResult = ScoreCalculator.calculate(dependencies, absentDeckSet)
		assert(
			not absentDeckSetResult.accepted
				and absentDeckSetResult.trace[1].reasonId == "P001-CALC-025",
			"P001-TEST-014 absent submitted deck set"
		)

		local overflowInput = Fixture.crownRun()
		overflowInput.personalActiveBoostMultipliers.overflow = {
			numerator = 1000000,
			denominator = 1,
		}
		overflowInput.serverEventBoostMultipliers.overflow = {
			numerator = 1000000,
			denominator = 1,
		}
		local overflowResult = ScoreCalculator.calculate(dependencies, overflowInput)
		assert(
			not overflowResult.accepted and overflowResult.components == nil,
			"P001-TEST-014 overflow trusted"
		)

		local cappedConfig = deepCopy(Config)
		cappedConfig.gameplayCaps.cash = 10
		local cappedDependencies = {
			catalog = Catalog,
			config = cappedConfig,
			formationDetector = Detector,
			jokerRegistry = JokerRegistry,
			safeNumber = SafeNumber,
		}
		local capInput = scoreInput({ card("cap_ace", "ace", "spades") })
		capInput.activeDeckSetCounts = { classic = 1 }
		capInput.activeDeckFilledSlots = 1
		local cappedResult = ScoreCalculator.calculate(cappedDependencies, capInput)
		assert(cappedResult.accepted and cappedResult.components.cash == 10, "P001-TEST-014 cap")
		local foundCapTrace = false
		for _, entry in cappedResult.trace do
			foundCapTrace = foundCapTrace
				or (entry.stageId == "gameplay_cap" and entry.reasonId == "cash")
		end
		assert(foundCapTrace, "P001-TEST-014 cap trace")
	end)

	addTest("P001-TEST-015-stage-and-joker-contracts", function()
		local baseInput = scoreInput({
			card("golden_ace", "ace", "spades", "classic", "golden", "f", "common"),
		})
		baseInput.activeDeckSetCounts = { classic = 1 }
		baseInput.activeDeckFilledSlots = 1
		local base = ScoreCalculator.calculate(dependencies, baseInput)
		local dividendInput = deepCopy(baseInput)
		dividendInput.activeJokerIds = { "golden_dividend" }
		local dividend = ScoreCalculator.calculate(dependencies, dividendInput)
		local unionInput = deepCopy(baseInput)
		unionInput.activeJokerIds = { "golden_dividend", "joker_union" }
		local union = ScoreCalculator.calculate(dependencies, unionInput)
		assert(base.components.cash == 28, "P001-TEST-015 golden base")
		assert(dividend.components.cash == 32, "P001-TEST-015 dividend")
		assert(union.components.cash == 33, "P001-TEST-015 union enhancement")

		local function traitResult(traitId: string, isCritical: boolean?): any
			local input = scoreInput({
				card(
					"trait_" .. traitId,
					"10",
					"hearts",
					"classic",
					"normal",
					"f",
					"common",
					traitId
				),
			})
			if isCritical == true then
				input.criticalTraitInstanceIds["trait_" .. traitId] = true
			end
			return ScoreCalculator.calculate(dependencies, input)
		end

		assert(traitResult("fortune").components.cash == 20, "P001-TEST-015 fortune")
		assert(traitResult("fierce").components.power == 20, "P001-TEST-015 fierce")
		assert(traitResult("guardian").components.guard == 20, "P001-TEST-015 guardian")
		assert(traitResult("lucky").components.packProgress == 12, "P001-TEST-015 lucky")
		assert(traitResult("scholar").components.gradeExperience == 13, "P001-TEST-015 scholar")
		assert(traitResult("critical", true).components.cash == 20, "P001-TEST-015 critical")

		local swift = traitResult("swift")
		assert(
			swift.stateIntents[1].intentId == "trait_draw_resolve_delay_down"
				and swift.stateIntents[1].reductionBasis == 2000,
			"P001-TEST-015 swift"
		)
		assert(
			traitResult("efficient").stateIntents[1].intentId == "trait_task_progress_up",
			"P001-TEST-015 efficient"
		)
		assert(
			traitResult("social").stateIntents[1].intentId == "trait_cooperative_reward_up",
			"P001-TEST-015 social"
		)

		local radiantBase = scoreInput({
			card("radiant_base", "ace", "spades", "radioactive", "normal", "lr", "infernal"),
		})
		radiantBase.activeDeckSetCounts = { radioactive = 52 }
		local radiantTrait = deepCopy(radiantBase)
		radiantTrait.cards[1].instanceId = "radiant_trait"
		radiantTrait.cards[1].traitId = "radiant"
		assert(
			ScoreCalculator.calculate(dependencies, radiantBase).components.cash == 1470
				and ScoreCalculator.calculate(dependencies, radiantTrait).components.cash
					== 1529,
			"P001-TEST-015 radiant"
		)
		local resonatorInput = deepCopy(radiantBase)
		resonatorInput.activeJokerIds = { "set_resonator" }
		assert(
			ScoreCalculator.calculate(dependencies, resonatorInput).components.cash == 1617,
			"P001-TEST-015 resonator dominant maximum"
		)
		local resonatorBelowMaximum = deepCopy(resonatorInput)
		resonatorBelowMaximum.activeDeckSetCounts.radioactive = 39
		resonatorBelowMaximum.activeDeckFilledSlots = 39
		assert(
			ScoreCalculator.calculate(dependencies, resonatorBelowMaximum).components.cash == 1352,
			"P001-TEST-015 resonator below maximum"
		)

		local resilientInput = scoreInput({
			card("resilient_2", "2", "hearts", "classic", "normal", "f", "common", "resilient"),
			card("resilient_4", "4", "clubs"),
		})
		local resilient = ScoreCalculator.calculate(dependencies, resilientInput)
		assert(
			not resilient.accepted
				and resilient.reasonId == "no_formation"
				and resilient.stateIntents[1].intentId == "trait_prevent_streak_loss_once"
				and resilient.stateIntents[1].uses == 1,
			"P001-TEST-015 resilient"
		)

		local adaptiveInput = scoreInput({
			card("adaptive_2", "2", "hearts", "classic", "normal", "f", "common", "adaptive"),
			card("adaptive_4", "4", "diamonds"),
			card("adaptive_5", "5", "clubs"),
		})
		assert(
			not ScoreCalculator.calculate(dependencies, adaptiveInput).accepted,
			"P001-TEST-015 adaptive baseline"
		)
		adaptiveInput.formationRankOverrides = { adaptive_2 = "3" }
		local adaptive = ScoreCalculator.calculate(dependencies, adaptiveInput)
		assert(
			adaptive.accepted
				and adaptive.formation.id == "sequence"
				and adaptive.components.cash == 20
				and adaptive.stateIntents[1].intentId == "trait_adjacent_rank_consumed"
				and adaptive.stateIntents[1].fromRankId == "2"
				and adaptive.stateIntents[1].toRankId == "3",
			"P001-TEST-015 adaptive"
		)
		local illegalAdaptive = deepCopy(adaptiveInput)
		illegalAdaptive.formationRankOverrides.adaptive_2 = "5"
		assert(
			not ScoreCalculator.calculate(dependencies, illegalAdaptive).accepted,
			"P001-TEST-015 illegal adaptive override"
		)

		local overlapCards = {
			card("overlap_10", "10", "hearts"),
			card("overlap_jack", "jack", "diamonds"),
			card("overlap_queen", "queen", "clubs"),
			card("overlap_king", "king", "spades"),
			card("overlap_ace", "ace", "hearts"),
		}
		local overlapBaseInput = scoreInput(overlapCards)
		overlapBaseInput.formationTarget = 60
		local overlapJokerInput = deepCopy(overlapBaseInput)
		overlapJokerInput.activeJokerIds = { "full_spectrum" }
		local overlapBase = ScoreCalculator.calculate(dependencies, overlapBaseInput)
		local overlapJoker = ScoreCalculator.calculate(dependencies, overlapJokerInput)
		assert(
			overlapBase.formation.id == "crown_run"
				and overlapBase.components.cash == 528
				and overlapJoker.components.cash == 950,
			"P001-TEST-015 matched formation joker"
		)

		local astralOverlap = scoreInput({
			card("astral_ace_h", "ace", "hearts", "astral"),
			card("astral_ace_d", "ace", "diamonds", "astral"),
			card("astral_ace_c", "ace", "clubs", "astral"),
			card("astral_ace_s", "ace", "spades", "astral"),
		})
		astralOverlap.activeDeckSetCounts = { astral = 13 }
		astralOverlap.activeDeckFilledSlots = 13
		astralOverlap.formationTarget = 56
		local astralResult = ScoreCalculator.calculate(dependencies, astralOverlap)
		local foundAstralAffinity = false
		for _, entry in astralResult.trace do
			foundAstralAffinity = foundAstralAffinity
				or (entry.stageId == "affinity" and entry.reasonId == "exact_sum_crown")
		end
		assert(
			astralResult.formation.id == "quad" and foundAstralAffinity,
			"P001-TEST-015 matched formation affinity"
		)

		local stageIndex = {}
		for index, stageId in Config.calculationStages do
			stageIndex[stageId] = index
		end
		local goldenCorpus = buildGoldenCorpus()
		for jokerId, jokerResult in goldenCorpus do
			for _, entry in jokerResult.trace do
				assert(
					stageIndex[entry.stageId] ~= nil,
					"P001-TEST-015 undeclared golden stage, " .. jokerId .. ", " .. entry.stageId
				)
			end
		end
		local spectrumSubscriptionIndex = nil
		local spectrumMultiplierIndex = nil
		for index, entry in goldenCorpus.full_spectrum.trace do
			if
				entry.stageId == "before_formation_multiplier"
				and entry.reasonId == "full_spectrum"
			then
				spectrumSubscriptionIndex = index
			elseif entry.stageId == "formation_multiplier" and spectrumMultiplierIndex == nil then
				spectrumMultiplierIndex = index
			end
		end
		assert(
			spectrumSubscriptionIndex ~= nil
				and spectrumMultiplierIndex ~= nil
				and spectrumSubscriptionIndex < spectrumMultiplierIndex,
			"P001-TEST-015 formation multiplier subscription order"
		)
		local previousIndex = 0
		for _, entry in union.trace do
			local index = stageIndex[entry.stageId]
			assert(index ~= nil, "P001-TEST-015 undeclared stage, " .. entry.stageId)
			assert(index >= previousIndex, "P001-TEST-015 stage order, " .. entry.stageId)
			previousIndex = index
		end

		local ordered = Fixture.crownRun()
		local reversed = Fixture.crownRun()
		reversed.activeJokerIds = {
			"archivist",
			"overclock",
			"golden_dividend",
			"joker_union",
			"crown_engine",
		}
		local orderedResult = ScoreCalculator.calculate(dependencies, ordered)
		local reversedResult = ScoreCalculator.calculate(dependencies, reversed)
		assert(
			ArtifactCore.canonicalJson(orderedResult.components)
					== ArtifactCore.canonicalJson(reversedResult.components)
				and ArtifactCore.canonicalJson(orderedResult.stateIntents)
					== ArtifactCore.canonicalJson(reversedResult.stateIntents),
			"P001-TEST-015 slot order changed effects"
		)

		local quickInput = scoreInput({ card("quick_card", "2", "hearts") }, {
			"quick_shuffle",
			"joker_union",
		})
		local quick = ScoreCalculator.calculate(dependencies, quickInput)
		assert(
			quick.stateIntents[1].intentId == "draw_resolve_speed_up"
				and quick.stateIntents[1].basisPoints == 575,
			"P001-TEST-015 typed enhanced intent"
		)

		local staleCounter = scoreInput(crownCards(), { "packstorm" })
		staleCounter.successfulFormationCount = 25
		local staleCounterResult = ScoreCalculator.calculate(dependencies, staleCounter)
		assert(
			not staleCounterResult.accepted
				and staleCounterResult.trace[1].reasonId == "P001-JOKER-009",
			"P001-TEST-015 stale counter accepted"
		)

		local conflictCatalog = deepCopy(Catalog)
		conflictCatalog.jokers[#conflictCatalog.jokers].launchEnabled = true
		local conflictDependencies = {
			catalog = conflictCatalog,
			config = Config,
			formationDetector = Detector,
			jokerRegistry = JokerRegistry,
			safeNumber = SafeNumber,
		}
		local conflictInput = scoreInput(crownCards(), { "joker_union", "fifth_law" })
		local conflict = ScoreCalculator.calculate(conflictDependencies, conflictInput)
		assert(
			not conflict.accepted and conflict.trace[1].reasonId == "P001-JOKER-008",
			"P001-TEST-015 conflict accepted"
		)
	end)

	addTest("P001-TEST-016-golden-reports", function()
		local validation = Validator.validate(Catalog, Config)
		local catalogSnapshot = {
			catalogVersion = validation.catalogVersion,
			configVersion = validation.configVersion,
			fixtureVersion = validation.fixtureVersion,
			counts = validation.counts,
			enabledIds = validation.enabledIds,
		}
		local configSnapshot = ClientProjection.economy(Config, Catalog.catalogVersion)
		local balanceSnapshot = ClientProjection.catalog(Catalog, Config)
		local formationMatrix = {}
		for _, definition in Catalog.formations do
			local multipliers = {}
			for size, multiplier in Config.balance.formations[definition.balanceId].multipliers do
				table.insert(multipliers, {
					size = size,
					multiplier = multiplier,
				})
			end
			table.sort(multipliers, function(left, right)
				return left.size < right.size
			end)
			table.insert(formationMatrix, {
				id = definition.id,
				handlerId = definition.handlerId,
				multipliers = multipliers,
				priority = definition.priority,
				stackableBonusIds = definition.stackableBonusIds,
			})
		end
		local golden = buildGoldenCorpus()
		local pairwise = buildPairwiseCorpus()
		local showcase = ScoreCalculator.calculate(dependencies, Fixture.crownRun())
		local economy = {
			catalogVersion = Catalog.catalogVersion,
			configVersion = Config.configVersion,
			fixtureVersion = Config.fixtureVersion,
			currencies = Config.economy.currencies,
			reasonIds = Config.economy.reasonIds,
			packPrices = Config.economy.packPrices,
			gameplayCaps = Config.gameplayCaps,
			antiAbuse = Config.antiAbuse,
			odds = Config.odds,
		}
		local interactionReport = {
			catalogVersion = Catalog.catalogVersion,
			configVersion = Config.configVersion,
			fixtureVersion = Config.fixtureVersion,
			pairCount = #pairwise,
			pairwise = pairwise,
			fiveSlot = {
				activeJokerIds = Fixture.crownRun().activeJokerIds,
				components = showcase.components,
				stateIntents = showcase.stateIntents,
			},
		}
		local validatorReport = {
			acceptedVersions = {
				catalogVersion = validation.catalogVersion,
				configVersion = validation.configVersion,
				fixtureVersion = validation.fixtureVersion,
			},
			negativeClasses = {
				"bad_cap",
				"bad_conflict",
				"bad_count",
				"bad_grammar",
				"bad_handler",
				"bad_parameter",
				"bad_reference",
				"bad_stage",
				"bad_weight",
				"disabled_content",
				"duplicate_id",
				"extra_config",
				"missing_asset_contract",
				"missing_bonus_balance",
				"missing_bonus_reference",
				"missing_cap",
				"missing_reason",
				"reordered_weight",
				"reordered_stage",
				"retired_id_collision",
				"stale_version",
				"stale_fixture_version",
			},
		}
		local reports = {
			catalog = catalogSnapshot,
			config = configSnapshot,
			balance = balanceSnapshot,
			formations = formationMatrix,
			jokers = golden,
			interactions = interactionReport,
			economy = economy,
			validator = validatorReport,
			showcase = showcase,
			activePassive = {
				catalogVersion = Catalog.catalogVersion,
				configVersion = Config.configVersion,
				fixtureVersion = Config.fixtureVersion,
				activePerMinute = Config.economy.activeBaselinePerMinute,
				passivePercent = Config.economy.passivePercentOfActive,
				ratioNumerator = 100,
				ratioDenominator = Config.economy.passivePercentOfActive,
				passesFiveToOne = Config.economy.passivePercentOfActive <= 20,
			},
		}
		fs.writeDir("build/phase001")
		for id, report in reports do
			fs.writeFile(
				"build/phase001/" .. id .. ".json",
				ArtifactCore.canonicalJson(report) .. "\n"
			)
		end
		local hashes = {
			catalog = hashCanonical(catalogSnapshot),
			config = hashCanonical(configSnapshot),
			balance = hashCanonical(balanceSnapshot),
			formations = hashCanonical(formationMatrix),
			jokers = hashCanonical(golden),
			interactions = hashCanonical(interactionReport),
			economy = hashCanonical(economy),
			validator = hashCanonical(validatorReport),
			showcase = hashCanonical(showcase),
		}
		fs.writeFile("build/phase001/hashes.json", ArtifactCore.canonicalJson(hashes) .. "\n")
		local expectedHashes =
			serde.decode("json", fs.readFile("tests/phase001/expected-hashes.json"))
		assert(
			ArtifactCore.canonicalJson(hashes) == ArtifactCore.canonicalJson(expectedHashes),
			"P001-TEST-016 golden hash drift"
		)
	end)
end

return table.freeze(Phase001Test)
