--!strict

local ArcanaService = {}

local function indexById(records: { any }): { [string]: any }
	local result = {}
	for _, record in records do
		result[record.id] = record
	end
	return result
end

local function copyState(card: any): any
	return {
		identityId = card.identityId,
		editionId = card.editionId,
		gradeId = card.gradeId,
		gradeExperience = card.gradeExperience,
		powerTierId = card.powerTierId,
		traitId = card.traitId,
	}
end

local function integer(value: any): boolean
	return type(value) == "number"
		and value == value
		and value ~= math.huge
		and value ~= -math.huge
		and value % 1 == 0
end

function ArcanaService.new(dependencies: any): any
	assert(dependencies.catalog ~= nil, "P003-ARCANA-001 catalog missing")
	assert(dependencies.config ~= nil, "P003-ARCANA-002 config missing")
	assert(dependencies.inventory ~= nil, "P003-ARCANA-003 inventory missing")
	assert(dependencies.collection ~= nil, "P003-ARCANA-004 collection missing")
	assert(dependencies.errors ~= nil, "P003-ARCANA-005 errors missing")
	local catalog = dependencies.catalog
	local errors = dependencies.errors.codes
	local arcanaById = indexById(catalog.arcana)
	local rankById = indexById(catalog.ranks)
	local editionById = indexById(catalog.editions)
	local gradeById = indexById(catalog.grades)
	local traitById = indexById(catalog.traits)
	local service = {}

	local function findIdentity(deckSetId: string, rankId: string, suitId: string): any?
		for _, identity in catalog.identities do
			if
				identity.deckSetId == deckSetId
				and identity.rankId == rankId
				and identity.suitId == suitId
			then
				return identity
			end
		end
		return nil
	end

	local function identityOwned(profile: any, identityId: string): boolean
		for _, card in dependencies.inventory:listCards(profile) do
			if card.identityId == identityId then
				return true
			end
		end
		return false
	end

	local function eligible(profile: any, ownerUserId: number, instanceId: string): any
		local result = dependencies.inventory:isEligible(profile, ownerUserId, instanceId)
		if not result.ok then
			return result
		end
		if result.card.flags.favorite == true then
			return { ok = false, code = errors.instanceLocked }
		end
		return result
	end

	local function stackCount(profile: any, arcanaId: string): number
		local count = profile.arcanaStacks[arcanaId]
		return if integer(count) and count > 0 then count else 0
	end

	local function nextRankId(rankId: string, delta: number): string
		local rank = rankById[rankId]
		assert(rank ~= nil, "P003-ARCANA-006 rank missing")
		local nextOrder = ((rank.order - 1 + delta) % #catalog.ranks) + 1
		for _, candidate in catalog.ranks do
			if candidate.order == nextOrder then
				return candidate.id
			end
		end
		assert(false, "P003-ARCANA-007 rank order missing")
		return rankId
	end

	local function gradeChoices(card: any): { string }
		local currentIndex = 1
		for index, grade in catalog.grades do
			if grade.id == card.gradeId then
				currentIndex = index
				break
			end
		end
		local result = {}
		for index = currentIndex, math.min(#catalog.grades, currentIndex + 2) do
			table.insert(result, catalog.grades[index].id)
		end
		return result
	end

	local function traitChoices(card: any): { string }
		local result = {}
		for _, trait in catalog.traits do
			if trait.launchEnabled ~= false and trait.id ~= card.traitId then
				table.insert(result, trait.id)
				if #result == 3 then
					break
				end
			end
		end
		return result
	end

	local function targetFor(card: any, definition: any): any?
		if definition.handlerId == "arcana_unlock_suit" then
			return findIdentity(card.deckSetId, card.rankId, definition.targetId)
		elseif definition.handlerId == "arcana_unlock_next_rank" then
			return findIdentity(card.deckSetId, nextRankId(card.rankId, 1), card.suitId)
		end
		return nil
	end

	local function trace(operation: string, before: any, after: any, details: any): any
		return {
			stageId = "arcana",
			handlerId = "arcana_service",
			operation = operation,
			input = before,
			output = after,
			reasonId = "arcana_application",
			details = details,
		}
	end

	local function choiceFrom(options: any): string?
		if type(options) == "string" then
			return options
		elseif type(options) == "table" and type(options.choiceId) == "string" then
			return options.choiceId
		end
		return nil
	end

	function service:preview(
		profile: any,
		ownerUserId: number,
		instanceId: string,
		arcanaId: string
	): any
		local definition = arcanaById[arcanaId]
		if definition == nil or definition.launchEnabled == false then
			return { ok = false, code = errors.contentDisabled }
		end
		if dependencies.config.features.arcanaEnabled == false then
			return { ok = false, code = errors.featureUnavailable }
		end
		local access = eligible(profile, ownerUserId, instanceId)
		if not access.ok then
			return access
		end
		local card = access.card
		local preview: any = {
			ok = true,
			code = "arcana.preview_ready",
			arcanaId = arcanaId,
			instanceId = instanceId,
			stackCount = stackCount(profile, arcanaId),
			definition = {
				categoryId = definition.categoryId,
				handlerId = definition.handlerId,
				targetId = definition.targetId,
			},
			before = copyState(card),
			catalogVersion = catalog.catalogVersion,
			configVersion = dependencies.config.configVersion,
		}
		local target = targetFor(card, definition)
		if target ~= nil then
			preview.targetIdentityId = target.id
			preview.targetFormId = catalog.formKey(target.id, card.editionId)
			preview.alreadyOwned = identityOwned(profile, target.id)
		elseif definition.handlerId == "arcana_unlock_edition" then
			preview.targetEditionId = definition.targetId
			preview.targetFormId = catalog.formKey(card.identityId, definition.targetId)
			preview.alreadyUnlocked = profile.discovery.forms[preview.targetFormId] == true
		elseif definition.handlerId == "arcana_raise_grade" then
			local choices = gradeChoices(card)
			preview.targetGradeId = choices[math.min(2, #choices)]
		elseif definition.handlerId == "arcana_choose_nonregressing_grade" then
			preview.choiceIds = gradeChoices(card)
		elseif
			definition.handlerId == "arcana_choose_trait"
			or definition.handlerId == "arcana_replace_trait"
		then
			preview.choiceIds = traitChoices(card)
			preview.choiceRequired = true
		end
		return preview
	end

	function service:apply(
		profile: any,
		ownerUserId: number,
		instanceId: string,
		arcanaId: string,
		options: any?
	): any
		local definition = arcanaById[arcanaId]
		if definition == nil or definition.launchEnabled == false then
			return { ok = false, code = errors.contentDisabled }
		end
		if dependencies.config.features.arcanaEnabled == false then
			return { ok = false, code = errors.featureUnavailable }
		end
		if stackCount(profile, arcanaId) < 1 then
			return { ok = false, code = errors.arcanaUnavailable }
		end
		local access = eligible(profile, ownerUserId, instanceId)
		if not access.ok then
			return access
		end
		local card = access.card
		local before = copyState(card)
		local choiceId = choiceFrom(options)
		local operationId = if type(options) == "table" then options.operationId else nil
		local target = targetFor(card, definition)
		local changed = false
		local targetIdentityId = nil
		local targetInstanceId = instanceId

		if definition.handlerId == "arcana_unlock_edition" then
			if editionById[definition.targetId] == nil then
				return { ok = false, code = errors.contentDisabled }
			end
			local formId = catalog.formKey(card.identityId, definition.targetId)
			dependencies.collection:discover(profile, "forms", formId)
			if card.editionId ~= definition.targetId then
				card.editionId = definition.targetId
				changed = true
			end
		elseif
			definition.handlerId == "arcana_unlock_suit"
			or definition.handlerId == "arcana_unlock_next_rank"
		then
			if target == nil or target.launchEnabled == false then
				return { ok = false, code = errors.contentDisabled }
			end
			targetIdentityId = target.id
			if not identityOwned(profile, target.id) then
				local created = dependencies.inventory:createCard(profile, ownerUserId, target.id, {
					editionId = card.editionId,
					gradeId = card.gradeId,
					powerTierId = card.powerTierId,
					traitId = card.traitId,
				}, {
					originType = "arcana",
					originId = if type(operationId) == "string" then operationId else arcanaId,
				})
				if not created.ok then
					return created
				end
				created.card.gradeExperience = card.gradeExperience
				targetInstanceId = created.card.uid
				changed = true
			end
		elseif
			definition.handlerId == "arcana_raise_grade"
			or definition.handlerId == "arcana_choose_nonregressing_grade"
		then
			local choices = gradeChoices(card)
			local selected = if definition.handlerId == "arcana_raise_grade"
				then choices[math.min(2, #choices)]
				else choiceId
			if selected == nil then
				return { ok = false, code = errors.arcanaChoiceRequired }
			end
			local selectedIndex = nil
			for index, candidate in choices do
				if candidate == selected then
					selectedIndex = index
					break
				end
			end
			if selectedIndex == nil then
				return { ok = false, code = errors.arcanaChoiceInvalid }
			end
			local currentIndex = 1
			for index, grade in catalog.grades do
				if grade.id == card.gradeId then
					currentIndex = index
					break
				end
			end
			local nextGrade = gradeById[selected]
			if nextGrade == nil or currentIndex + selectedIndex - 1 < currentIndex then
				return { ok = false, code = errors.arcanaChoiceInvalid }
			end
			local currentBalance = dependencies.config.balance.grades[card.gradeId]
			local nextBalance = dependencies.config.balance.grades[nextGrade.id]
			card.gradeId = nextGrade.id
			if currentBalance ~= nil and nextBalance ~= nil then
				card.gradeExperience = math.max(card.gradeExperience, nextBalance.cumulativeXp)
			end
			changed = before.gradeId ~= card.gradeId
				or before.gradeExperience ~= card.gradeExperience
		elseif
			definition.handlerId == "arcana_choose_trait"
			or definition.handlerId == "arcana_replace_trait"
		then
			if definition.handlerId == "arcana_choose_trait" and card.traitId ~= nil then
				return { ok = false, code = errors.arcanaTargetIneligible }
			elseif definition.handlerId == "arcana_replace_trait" and card.traitId == nil then
				return { ok = false, code = errors.arcanaTargetIneligible }
			end
			local choices = traitChoices(card)
			if choiceId == nil then
				return { ok = false, code = errors.arcanaChoiceRequired }
			end
			local validChoice = false
			for _, candidate in choices do
				if candidate == choiceId and traitById[candidate] ~= nil then
					validChoice = true
					break
				end
			end
			if not validChoice then
				return { ok = false, code = errors.arcanaChoiceInvalid }
			end
			card.traitId = choiceId
			changed = before.traitId ~= card.traitId
		else
			return { ok = false, code = errors.featureUnavailable }
		end

		local remaining = stackCount(profile, arcanaId) - 1
		if remaining > 0 then
			profile.arcanaStacks[arcanaId] = remaining
		else
			profile.arcanaStacks[arcanaId] = nil
		end
		local after = copyState(card)
		return {
			ok = true,
			code = "arcana.applied",
			arcanaId = arcanaId,
			instanceId = instanceId,
			targetInstanceId = targetInstanceId,
			targetIdentityId = targetIdentityId,
			changed = changed,
			consumed = 1,
			stackAfter = remaining,
			before = before,
			after = after,
			preservedSource = targetInstanceId ~= instanceId,
			trace = {
				trace(definition.handlerId, before, after, {
					arcanaId = arcanaId,
					targetInstanceId = targetInstanceId,
					targetIdentityId = targetIdentityId,
					changed = changed,
				}),
			},
			versions = {
				catalogVersion = catalog.catalogVersion,
				configVersion = dependencies.config.configVersion,
			},
		}
	end

	service.applyArcana = service.apply
	service.previewArcana = service.preview
	return service
end

return table.freeze(ArcanaService)
