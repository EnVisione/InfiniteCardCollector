--!strict

export type StableCode = string

export type FieldSpec = {
	kind: string,
	required: boolean?,
	min: number?,
	max: number?,
	minLength: number?,
	maxLength: number?,
	minItems: number?,
	maxItems: number?,
	values: { string }?,
	item: FieldSpec?,
	fields: { [string]: FieldSpec }?,
}

export type ObjectSchema = {
	kind: "object",
	fields: { [string]: FieldSpec },
	allowUnknown: boolean,
}

export type TokenBucketPolicy = {
	capacity: number,
	refillAmount: number,
	refillSeconds: number,
}

export type ActionPolicy = {
	id: string,
	mode: "read_only" | "ephemeral_idempotent" | "durable_idempotent",
	available: boolean,
	handlerId: string?,
	maxPayloadBytes: number,
	maxDepth: number,
	maxNodes: number,
	requiresProfile: boolean,
	requiresWritable: boolean,
	rate: TokenBucketPolicy,
	schema: ObjectSchema,
}

export type ValidationFailure = {
	accepted: false,
	code: StableCode,
}

export type ValidationSuccess = {
	accepted: true,
	policy: ActionPolicy,
	requestId: string,
}

export type ValidationResult = ValidationFailure | ValidationSuccess

return nil
