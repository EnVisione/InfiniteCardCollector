--!strict

export type StableId = string

export type Rational = {
	numerator: number,
	denominator: number,
}

export type VersionPair = {
	catalogVersion: number,
	configVersion: number,
}

export type RankDefinition = {
	id: StableId,
	displayName: string,
	value: number,
	order: number,
}

export type SuitDefinition = {
	id: StableId,
	displayName: string,
	color: "red" | "black",
	order: number,
}

export type DeckSetDefinition = {
	id: StableId,
	displayName: string,
	affinityId: StableId,
	launchEnabled: boolean,
	assetContractId: StableId,
}

export type BalancedDefinition = {
	id: StableId,
	displayName: string,
	balanceId: StableId,
}

export type EditionDefinition = BalancedDefinition & {
	handlerId: StableId,
	launchEnabled: boolean,
	assetContractId: StableId,
}

export type GradeDefinition = BalancedDefinition

export type PowerTierDefinition = BalancedDefinition

export type TraitDefinition = BalancedDefinition & {
	handlerId: StableId,
}

export type AffinityDefinition = {
	id: StableId,
	balanceId: StableId,
	handlerId: StableId,
	launchEnabled: boolean,
}

export type FormationDefinition = BalancedDefinition & {
	handlerId: StableId,
	priority: number,
	stackableBonusIds: { StableId },
	assetContractId: StableId,
}

export type StackableBonusDefinition = BalancedDefinition

export type JokerDefinition = BalancedDefinition & {
	rarityId: StableId,
	handlerId: StableId,
	stages: { StableId },
	conflicts: { StableId },
	launchEnabled: boolean,
	assetContractId: StableId,
}

export type ArcanaDefinition = {
	id: StableId,
	displayName: string,
	categoryId: StableId,
	handlerId: StableId,
	targetId: StableId,
	launchEnabled: boolean,
	assetContractId: StableId,
}

export type CardIdentity = {
	id: StableId,
	deckSetId: StableId,
	rankId: StableId,
	suitId: StableId,
	slotKey: StableId,
}

export type CardForm = {
	id: StableId,
	baseIdentityId: StableId,
	editionId: StableId,
	launchEnabled: boolean,
}

export type CardView = {
	instanceId: string,
	deckSetId: StableId,
	rankId: StableId?,
	suitId: StableId?,
	editionId: StableId?,
	gradeId: StableId?,
	powerTierId: StableId?,
	traitId: StableId?,
	isBlank: boolean?,
}

export type NormalizedCardView = CardView & {
	rankValue: number,
	suitColor: "red" | "black",
	formationRankId: StableId,
	formationRankValue: number,
	rankOverrideApplied: boolean,
	submissionIndex: number,
}

export type FormationCandidate = {
	id: StableId,
	multiplier: Rational,
	priority: number,
	stackableBonusIds: { StableId },
}

export type FormationResult = {
	normalizedCards: { NormalizedCardView },
	candidates: { FormationCandidate },
	selected: FormationCandidate?,
}

export type ScoreComponents = {
	cash: number,
	power: number,
	guard: number,
	packProgress: number,
	gradeExperience: number,
}

export type TraceEntry = {
	stageId: StableId,
	handlerId: StableId,
	componentId: StableId?,
	operation: StableId,
	input: number?,
	numerator: number?,
	denominator: number?,
	output: number?,
	reasonId: StableId?,
	details: { [string]: any }?,
}

export type StateIntent = {
	intentId: StableId,
	sourceId: StableId,
	basisPoints: number?,
	reductionBasis: number?,
	uses: number?,
	packCount: number?,
	resetCounterTo: number?,
	fromRankId: StableId?,
	toRankId: StableId?,
}

export type CalculationInput = {
	catalogVersion: number,
	configVersion: number,
	cards: { CardView },
	activeJokerIds: { StableId },
	activeDeckSetCounts: { [StableId]: number },
	activeDeckFilledSlots: number,
	discoveredFormCount: number,
	formationTarget: number?,
	formationRankOverrides: { [string]: StableId }?,
	formationStreak: number,
	successfulFormationCount: number,
	criticalTraitInstanceIds: { [string]: boolean }?,
	modeId: StableId,
	personalActiveBoostMultipliers: { [StableId]: Rational }?,
	serverEventBoostMultipliers: { [StableId]: Rational }?,
}

export type CalculationResult = {
	accepted: boolean,
	reasonId: StableId,
	formation: FormationCandidate?,
	components: ScoreComponents?,
	stateIntents: { StateIntent },
	trace: { TraceEntry },
	versions: VersionPair,
}

export type RollRecord = {
	seedId: string,
	rollUnit: number,
	inputPity: number,
	baseSelectedId: StableId,
	baseBucketStart: number,
	baseBucketEnd: number,
	selectedId: StableId,
	selectedBucketStart: number,
	selectedBucketEnd: number,
	postCommitPity: number,
	pityApplied: boolean,
	catalogVersion: number,
	configVersion: number,
}

local LaunchTypes = {
	catalogVersion = 1,
	configVersion = 1,
	fixtureVersion = 1,
}

return table.freeze(LaunchTypes)
