--!strict

local DataStoreService = game:GetService("DataStoreService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local ServerStorage = game:GetService("ServerStorage")

local Shared = ReplicatedStorage.Shared
local Server = script.Parent

local LaunchCatalog = require(Shared.Catalogs.LaunchCatalog)
local LaunchConfig = require(Shared.Config.LaunchConfig)
local LaunchContract = require(Shared.LaunchContract)
local ActionRegistry = require(Shared.Network.ActionRegistry)
local EnvelopeValidator = require(Shared.Network.EnvelopeValidator)
local ErrorRegistry = require(Shared.Network.ErrorRegistry)
local RollContract = require(Shared.Math.RollContract)
local CanonicalValue = require(Shared.Profile.CanonicalValue)
local MigrationRegistry = require(Shared.Profile.MigrationRegistry)
local ProfileCodec = require(Shared.Profile.ProfileCodec)
local ProfilePolicy = require(Shared.Profile.ProfilePolicy)
local ProfileSchema = require(Shared.Profile.ProfileSchema)

local GuidedFormationService = require(Server.Formation.GuidedFormationService)
local CollectionService = require(Server.Inventory.CollectionService)
local DeckService = require(Server.Inventory.DeckService)
local InventoryService = require(Server.Inventory.InventoryService)
local NetworkGateway = require(Server.Network.NetworkGateway)
local TokenBuckets = require(Server.Network.TokenBuckets)
local PackService = require(Server.Packs.PackService)
local StarterPackService = require(Server.Packs.StarterPackService)
local ProfileProjection = require(Server.Projection.ProfileProjection)
local RandomService = require(Server.Random.RandomService)
local MemoryProfileAdapter = require(Server.Storage.MemoryProfileAdapter)
local InventoryStore = require(Server.Storage.InventoryStore)
local ProfileStore = require(Server.Storage.ProfileStore)
local RobloxProfileAdapter = require(Server.Storage.RobloxProfileAdapter)
local TransactionService = require(Server.Transactions.TransactionService)

local Phase002Runtime = {}

local function ensureChild(parent: Instance, className: string, name: string): Instance
	local child = parent:FindFirstChild(name)
	if child == nil then
		child = Instance.new(className)
		child.Name = name
		child.Parent = parent
	end
	assert(child.ClassName == className, "P002-RUNTIME-001 network class mismatch")
	return child
end

local function publishPresentationFixtures()
	local assets = ServerStorage:WaitForChild("Assets")
	local cardFrames = assets:WaitForChild("CardFrames")
	local packModels = assets:WaitForChild("PackModels")
	local presentation = ensureChild(ReplicatedStorage, "Folder", "PresentationAssets")
	for _, fixture in
		{
			cardFrames:WaitForChild("ClassicFrameFixture"),
			cardFrames:WaitForChild("RadioactiveFrameFixture"),
			cardFrames:WaitForChild("AstralFrameFixture"),
			cardFrames:WaitForChild("ClassicFallbackFixture"),
			cardFrames:WaitForChild("RadioactiveFallbackFixture"),
			cardFrames:WaitForChild("AstralFallbackFixture"),
			packModels:WaitForChild("ClassicStarterPackFixture"),
			packModels:WaitForChild("RadioactivePackFixture"),
			packModels:WaitForChild("AstralPackFixture"),
		}
	do
		local existing = presentation:FindFirstChild(fixture.Name)
		if existing ~= nil then
			existing:Destroy()
		end
		fixture:Clone().Parent = presentation
	end
end

local function currencyIds(): { string }
	local result = {}
	for _, currency in LaunchConfig.economy.currencies do
		table.insert(result, currency.id)
	end
	return result
end

local function cashCap(): number
	for _, currency in LaunchConfig.economy.currencies do
		if currency.id == "cash" then
			return currency.cap
		end
	end
	error("P002-RUNTIME-002 cash currency missing")
end

local function seedFor(userId: number, requestId: string): number
	local seed = math.abs(userId) * 7919 + LaunchCatalog.catalogVersion * 104729
	for index = 1, #requestId do
		seed = (seed + string.byte(requestId, index) * index) % 2147483646
	end
	return seed + 1
end

local function retryJitter(storeKey: string, attempt: number, baseMilliseconds: number): number
	local hash = attempt * 131
	for index = 1, #storeKey do
		hash = (hash * 33 + string.byte(storeKey, index)) % 2147483647
	end
	return hash % (math.floor(baseMilliseconds / 4) + 1)
end

function Phase002Runtime.start(serverRoot: Instance)
	publishPresentationFixtures()
	local network = ensureChild(ReplicatedStorage, "Folder", "Network")
	local clientAction = ensureChild(network, "RemoteEvent", "ClientAction") :: RemoteEvent
	local serverMessage = ensureChild(network, "RemoteEvent", "ServerMessage") :: RemoteEvent

	local storageMode: string
	local adapter: any
	if RunService:IsStudio() and game.GameId == 0 then
		storageMode = "local_memory"
		adapter = MemoryProfileAdapter.new(CanonicalValue.copy)
	else
		storageMode = "isolated_data_store"
		adapter = RobloxProfileAdapter.new(
			DataStoreService:GetDataStore("infinite_card_collector_profile_v1")
		)
	end

	local migrations = MigrationRegistry.new({
		schema = ProfileSchema,
		codec = ProfileCodec,
		canonical = CanonicalValue,
		errors = ErrorRegistry,
		currencyIds = currencyIds(),
		catalogVersion = LaunchCatalog.catalogVersion,
		configVersion = LaunchConfig.configVersion,
	})
	local tokenCounter = 0
	local profileStore = ProfileStore.new({
		adapter = adapter,
		migrations = migrations,
		schema = ProfileSchema,
		codec = ProfileCodec,
		canonical = CanonicalValue,
		policy = ProfilePolicy,
		errors = ErrorRegistry,
		clock = os.time,
		sleep = task.wait,
		retryJitter = retryJitter,
		tokenFactory = function(userKey: string): string
			tokenCounter += 1
			return string.format(
				"session_%s_%s_%d_%d",
				if game.JobId ~= "" then string.gsub(game.JobId, "[^A-Za-z0-9_]", "") else "studio",
				userKey,
				os.time(),
				tokenCounter
			)
		end,
		reconcile = function(profile: any): (boolean, string?)
			for _, pending in profile.pendingPacks do
				if pending.state ~= "committed" and pending.state ~= "acknowledged" then
					return false, ErrorRegistry.codes.profileReadOnly
				end
			end
			return true, nil
		end,
		jobId = if game.JobId ~= "" then game.JobId else "studio_edit",
		placeVersion = game.PlaceVersion,
		currencyIds = currencyIds(),
		catalogVersion = LaunchCatalog.catalogVersion,
		configVersion = LaunchConfig.configVersion,
	})

	local uidCounter = 0
	local inventoryStore = InventoryStore.new()
	local collection = CollectionService.new()
	local inventory = InventoryService.new({
		catalog = LaunchCatalog,
		errors = ErrorRegistry,
		inventoryStore = inventoryStore,
		collection = collection,
		uidFactory = function(ownerUserId: number, kind: string): string
			uidCounter += 1
			return string.format("%s_%d_%d_%d", kind, math.abs(ownerUserId), os.time(), uidCounter)
		end,
		clock = os.time,
	})
	local deck =
		DeckService.new({ catalog = LaunchCatalog, inventory = inventory, errors = ErrorRegistry })
	local starterPack = StarterPackService.new({
		catalog = LaunchCatalog,
		inventory = inventory,
		canonical = CanonicalValue,
		errors = ErrorRegistry,
	})
	local packService = PackService.new({
		catalog = LaunchCatalog,
		config = LaunchConfig,
		inventory = inventory,
		canonical = CanonicalValue,
		errors = ErrorRegistry,
		rollContract = RollContract,
	})
	local guidedFormation = GuidedFormationService.new({
		inventory = inventory,
		errors = ErrorRegistry,
		catalogVersion = LaunchCatalog.catalogVersion,
		configVersion = LaunchConfig.configVersion,
		cashCap = cashCap(),
		calculate = LaunchContract.calculate,
		projectCalculation = LaunchContract.projectCalculation,
	})
	local transactions = TransactionService.new({
		profileStore = profileStore,
		canonical = CanonicalValue,
		policy = ProfilePolicy,
		errors = ErrorRegistry,
		clock = os.clock,
		sleep = task.wait,
	})
	local limiter = TokenBuckets.new(ActionRegistry, os.clock)
	local playersByKey = {}
	local runtimeClosing = false

	local function playerKey(player: Player): string
		return tostring(player.UserId)
	end

	local function acquire(player: Player): any
		local userKey = playerKey(player)
		if profileStore:state(userKey).ready then
			return { ok = true, code = "ok" }
		end
		local outcome = profileStore:acquire(userKey)
		player:SetAttribute("ProfileState", if outcome.ok then "ready" else "maintenance")
		return outcome
	end

	local function snapshot(userKey: string): any?
		local profile = profileStore:get(userKey)
		if profile == nil then
			return nil
		end
		return ProfileProjection.snapshot(
			profile,
			inventory,
			profileStore:state(userKey).writable,
			storageMode
		)
	end

	local function withSnapshot(userKey: string, outcome: any, action: string): any
		local response = table.clone(outcome)
		response.action = action
		if outcome.ok then
			response.snapshot = snapshot(userKey)
		end
		return response
	end

	local routes = {}

	routes.bootstrap = function(userKey: string): any
		local player = playersByKey[userKey]
		if player == nil then
			return { ok = false, code = ErrorRegistry.codes.permissionDenied }
		end
		local acquired = acquire(player)
		if not acquired.ok then
			return { ok = false, code = acquired.code, action = "bootstrap.request" }
		end
		return {
			ok = true,
			code = "bootstrap.ready",
			action = "bootstrap.request",
			snapshot = snapshot(userKey),
		}
	end

	routes.starter_pack = function(userKey: string, payload: any, requestId: string): any
		local player = playersByKey[userKey]
		if player == nil then
			return { ok = false, code = ErrorRegistry.codes.permissionDenied, action = "pack.open" }
		end
		if
			payload.packId ~= "classic_starter"
			and packService:definition(payload.packId) == nil
		then
			return { ok = false, code = ErrorRegistry.codes.packInvalid, action = "pack.open" }
		end
		local outcome = transactions:execute(userKey, {
			id = requestId,
			kind = "pack.open",
			payload = payload,
			expectedRevision = payload.expectedRevision,
			resultReference = requestId,
			apply = function(profile: any): any
				if payload.packId ~= "classic_starter" then
					return packService:open(
						profile,
						player.UserId,
						requestId,
						payload.packId,
						RandomService.new(seedFor(player.UserId, requestId))
					)
				end
				return starterPack:apply(
					profile,
					player.UserId,
					requestId,
					RandomService.new(seedFor(player.UserId, requestId))
				)
			end,
		})
		return withSnapshot(userKey, outcome, "pack.open")
	end

	routes.deck_equip = function(userKey: string, payload: any, requestId: string): any
		local player = playersByKey[userKey]
		if player == nil then
			return {
				ok = false,
				code = ErrorRegistry.codes.permissionDenied,
				action = "deck.equip_card",
			}
		end
		local outcome = transactions:execute(userKey, {
			id = requestId,
			kind = "deck.equip_card",
			payload = payload,
			expectedRevision = payload.expectedRevision,
			apply = function(profile: any): any
				local equipped =
					deck:equip(profile, player.UserId, payload.instanceId, payload.slotKey)
				if not equipped.ok then
					return equipped
				end
				local acknowledged =
					starterPack:acknowledgeRevealForCard(profile, payload.instanceId)
				if not acknowledged.ok then
					return acknowledged
				end
				equipped.packRevealAcknowledged = acknowledged.acknowledged
				equipped.packOperationId = acknowledged.packOperationId
				return equipped
			end,
		})
		return withSnapshot(userKey, outcome, "deck.equip_card")
	end

	routes.deck_unequip = function(userKey: string, payload: any, requestId: string): any
		local player = playersByKey[userKey]
		if player == nil then
			return {
				ok = false,
				code = ErrorRegistry.codes.permissionDenied,
				action = "deck.unequip_card",
			}
		end
		local outcome = transactions:execute(userKey, {
			id = requestId,
			kind = "deck.unequip_card",
			payload = payload,
			expectedRevision = payload.expectedRevision,
			apply = function(profile: any): any
				return deck:unequip(profile, player.UserId, payload.slotKey)
			end,
		})
		return withSnapshot(userKey, outcome, "deck.unequip_card")
	end

	routes.inventory_flags = function(userKey: string, payload: any, requestId: string): any
		local player = playersByKey[userKey]
		if player == nil then
			return {
				ok = false,
				code = ErrorRegistry.codes.permissionDenied,
				action = "inventory.set_flags",
			}
		elseif payload.favorite == nil and payload.wishlist == nil then
			return {
				ok = false,
				code = ErrorRegistry.codes.operationInvalid,
				action = "inventory.set_flags",
			}
		end
		local outcome = transactions:execute(userKey, {
			id = requestId,
			kind = "inventory.set_flags",
			payload = payload,
			expectedRevision = payload.expectedRevision,
			apply = function(profile: any): any
				return inventory:setFlags(profile, player.UserId, payload.instanceId, payload)
			end,
		})
		return withSnapshot(userKey, outcome, "inventory.set_flags")
	end

	routes.guided_formation = function(userKey: string, payload: any, requestId: string): any
		local player = playersByKey[userKey]
		if player == nil then
			return {
				ok = false,
				code = ErrorRegistry.codes.permissionDenied,
				action = "formation.submit",
			}
		elseif payload.modeId ~= "guided_classic" then
			return {
				ok = false,
				code = ErrorRegistry.codes.formationInvalid,
				action = "formation.submit",
			}
		end
		local outcome = transactions:execute(userKey, {
			id = requestId,
			kind = "formation.submit",
			payload = payload,
			expectedRevision = payload.expectedRevision,
			resultReference = payload.roundId,
			apply = function(profile: any): any
				return guidedFormation:apply(profile, player.UserId, payload.instanceIds)
			end,
		})
		return withSnapshot(userKey, outcome, "formation.submit")
	end

	routes.binder_page = function(userKey: string, payload: any): any
		local profile = profileStore:get(userKey)
		if profile == nil then
			return { ok = false, code = ErrorRegistry.codes.profileNotReady, action = "binder.page" }
		elseif payload.sortId ~= "newest" then
			return { ok = false, code = ErrorRegistry.codes.boundsInvalid, action = "binder.page" }
		end
		return {
			ok = true,
			code = "binder.page_ready",
			action = "binder.page",
			page = ProfileProjection.binderPage(
				profile,
				inventory,
				payload.cursor,
				payload.pageSize
			),
			snapshot = snapshot(userKey),
		}
	end

	local gateway = NetworkGateway.new({
		registry = ActionRegistry,
		errors = ErrorRegistry,
		validator = EnvelopeValidator,
		limiter = limiter,
		profileState = function(userKey: string): any
			return profileStore:state(userKey)
		end,
		authorize = function(userKey: string): boolean
			local player = playersByKey[userKey]
			return player ~= nil and player.Parent == Players
		end,
		routes = routes,
	})

	local function onPlayerAdded(player: Player)
		local userKey = playerKey(player)
		playersByKey[userKey] = player
		acquire(player)
	end

	local function onPlayerRemoving(player: Player)
		local userKey = playerKey(player)
		profileStore:release(userKey)
		limiter:removeUser(userKey)
		playersByKey[userKey] = nil
	end

	Players.PlayerAdded:Connect(onPlayerAdded)
	Players.PlayerRemoving:Connect(onPlayerRemoving)
	for _, player in Players:GetPlayers() do
		task.spawn(onPlayerAdded, player)
	end

	clientAction.OnServerEvent:Connect(function(player: Player, envelope: any)
		local userKey = playerKey(player)
		if playersByKey[userKey] ~= player then
			return
		end
		local response = gateway:handle(userKey, envelope)
		serverMessage:FireClient(player, response)
	end)

	task.spawn(function()
		while not runtimeClosing do
			task.wait(ProfilePolicy.heartbeatSeconds)
			if runtimeClosing then
				break
			end
			for userKey, player in playersByKey do
				local heartbeat = profileStore:heartbeat(userKey)
				if not heartbeat.ok then
					player:SetAttribute("ProfileState", "read_only")
					serverMessage:FireClient(player, {
						ok = false,
						code = heartbeat.code,
						action = "profile.heartbeat",
					})
				end
			end
		end
	end)

	game:BindToClose(function()
		runtimeClosing = true
		local storageDeadline = os.time() + ProfilePolicy.shutdownDeadlineSeconds
		local drained = transactions:drain(math.max(0, storageDeadline - os.time()))
		local released = profileStore:shutdown(storageDeadline)
		serverRoot:SetAttribute(
			"Phase002ShutdownState",
			if drained.ok and released.ok then "complete" else "incomplete"
		)
		serverRoot:SetAttribute("Phase002ShutdownTransactionsRemaining", drained.remaining)
		serverRoot:SetAttribute("Phase002ShutdownProfilesRemaining", released.remaining)
	end)

	serverRoot:SetAttribute("Phase002ActionRegistryVersion", ActionRegistry.version)
	serverRoot:SetAttribute("Phase002ProfileSchemaVersion", ProfileSchema.version)
	serverRoot:SetAttribute("Phase002RendererVersion", 1)
	serverRoot:SetAttribute("Phase002StorageMode", storageMode)
	serverRoot:SetAttribute("Phase002RuntimeState", "ready")
end

return table.freeze(Phase002Runtime)
