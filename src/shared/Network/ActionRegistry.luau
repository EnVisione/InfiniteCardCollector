--!strict

local function scalar(kind: string, options: any?): any
	local spec = {
		kind = kind,
		required = true,
	}
	if options ~= nil then
		for key, value in options do
			spec[key] = value
		end
	end
	return spec
end

local function optional(spec: any): any
	spec.required = false
	return spec
end

local function object(fields: { [string]: any }): any
	return {
		kind = "object",
		allowUnknown = false,
		fields = fields,
	}
end

local function array(item: any, minItems: number, maxItems: number): any
	return scalar("array", {
		item = item,
		minItems = minItems,
		maxItems = maxItems,
	})
end

local function stableId(maxLength: number?): any
	return scalar("stable_id", { minLength = 1, maxLength = maxLength or 64 })
end

local function requestReference(): any
	return scalar("request_id", { minLength = 16, maxLength = 64 })
end

local function revision(): any
	return scalar("integer", { min = 0, max = 2147483647 })
end

local function policy(
	id: string,
	mode: string,
	available: boolean,
	handlerId: string?,
	maxPayloadBytes: number,
	capacity: number,
	refillAmount: number,
	refillSeconds: number,
	fields: { [string]: any },
	requiresProfile: boolean?,
	requiresWritable: boolean?
): any
	return {
		id = id,
		mode = mode,
		available = available,
		handlerId = handlerId,
		maxPayloadBytes = maxPayloadBytes,
		maxDepth = 6,
		maxNodes = 128,
		requiresProfile = requiresProfile ~= false,
		requiresWritable = requiresWritable == true,
		rate = {
			capacity = capacity,
			refillAmount = refillAmount,
			refillSeconds = refillSeconds,
		},
		schema = object(fields),
	}
end

local actions = {
	policy("bootstrap.request", "read_only", true, "bootstrap", 512, 4, 1, 3, {
		knownRevision = optional(revision()),
	}, false, false),
	policy("pack.open", "durable_idempotent", true, "starter_pack", 1024, 2, 1, 5, {
		expectedRevision = revision(),
		packId = stableId(),
	}, true, true),
	policy("pack.choose", "durable_idempotent", true, "pack_choose", 1024, 2, 1, 5, {
		choiceIndex = scalar("integer", { min = 1, max = 12 }),
		expectedRevision = revision(),
		packOperationId = requestReference(),
	}, true, true),
	policy("deck.equip_card", "durable_idempotent", true, "deck_equip", 1024, 6, 2, 3, {
		expectedRevision = revision(),
		instanceId = stableId(64),
		slotKey = stableId(32),
	}, true, true),
	policy("deck.unequip_card", "durable_idempotent", true, "deck_unequip", 768, 6, 2, 3, {
		expectedRevision = revision(),
		slotKey = stableId(32),
	}, true, true),
	policy("joker.equip", "durable_idempotent", false, nil, 1024, 4, 1, 4, {
		expectedRevision = revision(),
		instanceId = stableId(64),
		slotIndex = scalar("integer", { min = 1, max = 5 }),
	}, true, true),
	policy("joker.unequip", "durable_idempotent", false, nil, 768, 4, 1, 4, {
		expectedRevision = revision(),
		slotIndex = scalar("integer", { min = 1, max = 5 }),
	}, true, true),
	policy("arcana.apply", "durable_idempotent", false, nil, 1024, 2, 1, 5, {
		arcanaId = stableId(),
		expectedRevision = revision(),
		instanceId = stableId(64),
	}, true, true),
	policy("grade.apply_ink", "durable_idempotent", true, "grade_apply_ink", 1024, 2, 1, 5, {
		amount = scalar("integer", { min = 1, max = 1000000 }),
		expectedRevision = revision(),
		instanceId = stableId(64),
	}, true, true),
	policy("inventory.set_flags", "durable_idempotent", true, "inventory_flags", 1024, 8, 2, 2, {
		expectedRevision = revision(),
		favorite = optional(scalar("boolean")),
		instanceId = stableId(64),
		wishlist = optional(scalar("boolean")),
	}, true, true),
	policy("formation.start", "ephemeral_idempotent", false, nil, 768, 3, 1, 5, {
		expectedRevision = revision(),
		modeId = stableId(),
	}, true, false),
	policy("formation.redraw", "ephemeral_idempotent", false, nil, 1024, 4, 1, 3, {
		expectedHandRevision = revision(),
		instanceIds = array(stableId(64), 1, 4),
		roundId = requestReference(),
	}, true, false),
	policy("formation.submit", "durable_idempotent", true, "guided_formation", 1536, 6, 2, 2, {
		expectedRevision = revision(),
		instanceIds = array(stableId(64), 4, 4),
		modeId = stableId(),
		roundId = requestReference(),
	}, true, true),
	policy("task.start", "ephemeral_idempotent", false, nil, 768, 4, 1, 4, {
		taskId = stableId(),
	}, true, false),
	policy("task.action", "durable_idempotent", false, nil, 1024, 8, 2, 2, {
		actionId = stableId(),
		expectedRevision = revision(),
		taskId = stableId(),
	}, true, true),
	policy("duel.invite", "ephemeral_idempotent", false, nil, 768, 2, 1, 8, {
		targetUserId = scalar("integer", { min = 1, max = 9007199254740991 }),
	}, true, false),
	policy("duel.respond", "ephemeral_idempotent", false, nil, 768, 3, 1, 5, {
		accepted = scalar("boolean"),
		inviteId = requestReference(),
	}, true, false),
	policy("duel.submit", "ephemeral_idempotent", false, nil, 1536, 6, 2, 2, {
		duelId = requestReference(),
		instanceIds = array(stableId(64), 4, 4),
	}, true, false),
	policy("trade.request", "ephemeral_idempotent", false, nil, 768, 2, 1, 8, {
		targetUserId = scalar("integer", { min = 1, max = 9007199254740991 }),
	}, true, false),
	policy("trade.respond", "ephemeral_idempotent", false, nil, 768, 3, 1, 5, {
		accepted = scalar("boolean"),
		tradeId = requestReference(),
	}, true, false),
	policy("trade.set_offer", "ephemeral_idempotent", false, nil, 2048, 4, 1, 2, {
		expectedOfferRevision = revision(),
		instanceIds = array(stableId(64), 0, 20),
		tradeId = requestReference(),
	}, true, false),
	policy("trade.set_ready", "ephemeral_idempotent", false, nil, 768, 4, 1, 2, {
		expectedOfferRevision = revision(),
		ready = scalar("boolean"),
		tradeId = requestReference(),
	}, true, false),
	policy("trade.cancel", "ephemeral_idempotent", false, nil, 512, 4, 1, 2, {
		tradeId = requestReference(),
	}, true, false),
	policy("binder.page", "read_only", true, "binder_page", 1024, 10, 5, 1, {
		cursor = optional(stableId(96)),
		pageSize = scalar("integer", { min = 1, max = 100 }),
		sortId = stableId(32),
	}, true, false),
}

local byId = {}
for _, entry in actions do
	assert(byId[entry.id] == nil, "P002-ACTION-001 duplicate action id")
	assert(entry.id:match("^[a-z][a-z0-9_.]+$") ~= nil, "P002-ACTION-002 malformed action id")
	assert(entry.maxPayloadBytes > 0, "P002-ACTION-003 payload ceiling invalid")
	assert(entry.rate.capacity > 0, "P002-ACTION-004 rate capacity invalid")
	assert(entry.rate.refillAmount > 0, "P002-ACTION-005 refill amount invalid")
	assert(entry.rate.refillSeconds > 0, "P002-ACTION-006 refill window invalid")
	assert(not entry.available or entry.handlerId ~= nil, "P002-ACTION-007 available route missing")
	byId[entry.id] = entry
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

local ActionRegistry = {
	version = 1,
	envelopeVersion = 1,
	requestIdMinLength = 16,
	requestIdMaxLength = 64,
	maxEnvelopeBytes = 4096,
	maxEnvelopeDepth = 8,
	maxEnvelopeNodes = 192,
	globalRate = {
		capacity = 24,
		refillAmount = 12,
		refillSeconds = 1,
	},
	actions = actions,
	byId = byId,
}

return deepFreeze(ActionRegistry)
