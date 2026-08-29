--!strict

local ContentProvider = game:GetService("ContentProvider")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ClientState = require(script.Parent.Parent.State.ClientState)
local SurfaceState = require(script.Parent.Parent.State.SurfaceState)
local PackRevealController = require(script.Parent.Parent.State.PackRevealController)
local CardRenderer2D = require(script.Parent.Parent.Rendering.CardRenderer2D)
local CardRenderer3D = require(script.Parent.Parent.Rendering.CardRenderer3D)
local ComponentPool = require(script.Parent.Parent.Rendering.ComponentPool)
local PreloadManifest = require(script.Parent.Parent.Rendering.PreloadManifest)
local VirtualizedBinder = require(script.Parent.Parent.Rendering.VirtualizedBinder)
local LaunchDeckSetAssets = require(ReplicatedStorage.Shared.Assets.LaunchDeckSetAssets)
local PresentationResolver = require(ReplicatedStorage.Shared.Assets.PresentationResolver)
local ComposedCardAssets = require(ReplicatedStorage.Shared.Assets.ComposedCardAssets)
local SpecialContentAssets = require(ReplicatedStorage.Shared.Assets.SpecialContentAssets)
local CardViewModel = require(ReplicatedStorage.Shared.Rendering.CardViewModel)

local ClientApp = {}

local function makeText(parent: Instance, name: string, text: string, size: UDim2): TextLabel
	local label = Instance.new("TextLabel")
	label.Name = name
	label.BackgroundTransparency = 1
	label.Size = size
	label.Font = Enum.Font.Gotham
	label.Text = text
	label.TextColor3 = Color3.fromRGB(232, 236, 245)
	label.TextSize = 16
	label.TextWrapped = true
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.Parent = parent
	return label
end

local function makeButton(parent: Instance, name: string, text: string): TextButton
	local button = Instance.new("TextButton")
	button.Name = name
	button.AutoButtonColor = true
	button.BackgroundColor3 = Color3.fromRGB(55, 87, 138)
	button.BorderSizePixel = 0
	button.Font = Enum.Font.GothamMedium
	button.Size = UDim2.fromOffset(190, 44)
	button.Text = text
	button.TextColor3 = Color3.fromRGB(255, 255, 255)
	button.TextSize = 15
	button.Parent = parent
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 8)
	corner.Parent = button
	return button
end

local function setEnabled(button: TextButton, enabled: boolean)
	button.Active = enabled
	button.AutoButtonColor = enabled
	button.BackgroundColor3 = if enabled
		then Color3.fromRGB(55, 87, 138)
		else Color3.fromRGB(56, 61, 72)
	button.TextTransparency = if enabled then 0 else 0.35
end

function ClientApp.start(launchContract: any)
	local player = Players.LocalPlayer
	local playerGui = player:WaitForChild("PlayerGui")
	local app = playerGui:WaitForChild("App", 30)
	assert(app ~= nil and app:IsA("ScreenGui"), "P002-CLIENT-001 app missing")
	local rootValue = app:WaitForChild("AppRoot", 30)
	assert(rootValue ~= nil and rootValue:IsA("Frame"), "P002-CLIENT-002 root missing")
	local root = rootValue :: Frame
	root:ClearAllChildren()
	local presentationAssets = ReplicatedStorage:WaitForChild("PresentationAssets", 30)
	assert(presentationAssets ~= nil, "P002-CLIENT-004 presentation assets missing")
	local preloadInstances = PreloadManifest.resolve(presentationAssets)
	local composedCardAssets = ComposedCardAssets.build(launchContract.clientCatalog)
	local specialContentAssets = SpecialContentAssets.build(launchContract.clientCatalog)
	app:SetAttribute("SpecialAssetRegistryVersion", specialContentAssets.version)
	app:SetAttribute("SpecialAssetJokerCount", #specialContentAssets.jokers)
	app:SetAttribute("SpecialAssetArcanaCount", #specialContentAssets.arcana)
	task.spawn(function()
		local ok = pcall(function()
			ContentProvider:PreloadAsync(preloadInstances)
		end)
		app:SetAttribute("PreloadState", if ok then "ready" else "degraded")
		if not ok then
			warn("P002-CLIENT-005 bounded fixture preload failed")
		end
	end)

	local background = Instance.new("Frame")
	background.Name = "FoundationPanel"
	background.AnchorPoint = Vector2.new(0.5, 0.5)
	background.BackgroundColor3 = Color3.fromRGB(18, 23, 34)
	background.BorderSizePixel = 0
	background.Position = UDim2.fromScale(0.5, 0.5)
	background.Size = UDim2.new(1, -32, 1, -32)
	background.Parent = root
	local panelCorner = Instance.new("UICorner")
	panelCorner.CornerRadius = UDim.new(0, 12)
	panelCorner.Parent = background

	local padding = Instance.new("UIPadding")
	padding.PaddingTop = UDim.new(0, 18)
	padding.PaddingBottom = UDim.new(0, 18)
	padding.PaddingLeft = UDim.new(0, 18)
	padding.PaddingRight = UDim.new(0, 18)
	padding.Parent = background

	local layout = Instance.new("UIListLayout")
	layout.Padding = UDim.new(0, 10)
	layout.SortOrder = Enum.SortOrder.LayoutOrder
	layout.Parent = background

	local title = makeText(background, "Title", "Infinite Card Collector", UDim2.new(1, 0, 0, 34))
	title.Font = Enum.Font.GothamBold
	title.TextSize = 24
	title.LayoutOrder = 1

	local surfaceNavigation = Instance.new("ScrollingFrame")
	surfaceNavigation.Name = "SurfaceNavigation"
	surfaceNavigation.BackgroundTransparency = 1
	surfaceNavigation.BorderSizePixel = 0
	surfaceNavigation.CanvasSize = UDim2.fromOffset(0, 0)
	surfaceNavigation.AutomaticCanvasSize = Enum.AutomaticSize.X
	surfaceNavigation.ScrollBarThickness = 4
	surfaceNavigation.Size = UDim2.new(1, 0, 0, 44)
	surfaceNavigation.LayoutOrder = 2
	surfaceNavigation.Parent = background
	local surfaceNavigationLayout = Instance.new("UIListLayout")
	surfaceNavigationLayout.FillDirection = Enum.FillDirection.Horizontal
	surfaceNavigationLayout.Padding = UDim.new(0, 6)
	surfaceNavigationLayout.SortOrder = Enum.SortOrder.LayoutOrder
	surfaceNavigationLayout.Parent = surfaceNavigation
	local surfaceButtons = {}
	for _, definition in SurfaceState.definitions do
		local button = makeButton(surfaceNavigation, "Surface_" .. definition.id, definition.title)
		button.Size = UDim2.fromOffset(132, 40)
		surfaceButtons[definition.id] = button
	end

	local status =
		makeText(background, "Status", "Connecting to the server.", UDim2.new(1, 0, 0, 42))
	status.LayoutOrder = 3
	local summary = makeText(background, "Summary", "No profile loaded.", UDim2.new(1, 0, 0, 42))
	summary.LayoutOrder = 4

	local actions = Instance.new("Frame")
	actions.Name = "Actions"
	actions.BackgroundTransparency = 1
	actions.Size = UDim2.new(1, 0, 0, 44)
	actions.LayoutOrder = 5
	actions.Parent = background
	local actionLayout = Instance.new("UIListLayout")
	actionLayout.FillDirection = Enum.FillDirection.Horizontal
	actionLayout.Padding = UDim.new(0, 8)
	actionLayout.SortOrder = Enum.SortOrder.LayoutOrder
	actionLayout.Parent = actions

	local openButton = makeButton(actions, "OpenStarter", "Open Starter Pack")
	local equipButton = makeButton(actions, "EquipNext", "Equip Next Card")
	local scoreButton = makeButton(actions, "SubmitGuided", "Submit Guided Formation")
	local refreshButton = makeButton(actions, "Refresh", "Refresh")

	local packSelector = Instance.new("ScrollingFrame")
	packSelector.Name = "PackSelector"
	packSelector.BackgroundTransparency = 1
	packSelector.BorderSizePixel = 0
	packSelector.CanvasSize = UDim2.fromOffset(0, 0)
	packSelector.AutomaticCanvasSize = Enum.AutomaticSize.X
	packSelector.ScrollBarThickness = 4
	packSelector.Size = UDim2.new(1, 0, 0, 44)
	packSelector.LayoutOrder = 6
	packSelector.Parent = background
	local packSelectorLayout = Instance.new("UIListLayout")
	packSelectorLayout.FillDirection = Enum.FillDirection.Horizontal
	packSelectorLayout.Padding = UDim.new(0, 8)
	packSelectorLayout.SortOrder = Enum.SortOrder.LayoutOrder
	packSelectorLayout.Parent = packSelector
	local packButtons = {}
	for _, definition in
		{
			{ id = "classic", text = "Classic" },
			{ id = "radioactive", text = "Radioactive" },
			{ id = "astral", text = "Astral" },
			{ id = "joker", text = "Joker" },
			{ id = "arcana", text = "Arcana" },
		}
	do
		local button = makeButton(packSelector, "Pack_" .. definition.id, definition.text)
		button.Size = UDim2.fromOffset(124, 40)
		packButtons[definition.id] = button
	end

	local revealActions = Instance.new("ScrollingFrame")
	revealActions.Name = "RevealActions"
	revealActions.BackgroundTransparency = 1
	revealActions.BorderSizePixel = 0
	revealActions.CanvasSize = UDim2.fromOffset(0, 0)
	revealActions.AutomaticCanvasSize = Enum.AutomaticSize.X
	revealActions.ScrollBarThickness = 4
	revealActions.Size = UDim2.new(1, 0, 0, 44)
	revealActions.LayoutOrder = 7
	revealActions.Parent = background
	local revealLayout = Instance.new("UIListLayout")
	revealLayout.FillDirection = Enum.FillDirection.Horizontal
	revealLayout.Padding = UDim.new(0, 8)
	revealLayout.SortOrder = Enum.SortOrder.LayoutOrder
	revealLayout.Parent = revealActions
	local revealNextButton = makeButton(revealActions, "RevealNext", "Reveal Next")
	local revealAllButton = makeButton(revealActions, "RevealAll", "Reveal All")
	local skipButton = makeButton(revealActions, "SkipReveal", "Skip")
	for _, button in { revealNextButton, revealAllButton, skipButton } do
		button.Size = UDim2.fromOffset(124, 40)
	end
	local choiceButtons = {}
	for index = 1, 3 do
		local button =
			makeButton(revealActions, "Choice" .. tostring(index), "Choice " .. tostring(index))
		button.Size = UDim2.fromOffset(170, 40)
		button.Visible = false
		table.insert(choiceButtons, button)
	end

	local preview = Instance.new("Frame")
	preview.Name = "CardPreview"
	preview.BackgroundColor3 = Color3.fromRGB(25, 31, 45)
	preview.BorderSizePixel = 0
	preview.Size = UDim2.new(1, 0, 0, 150)
	preview.LayoutOrder = 8
	preview.Parent = background
	local previewCorner = Instance.new("UICorner")
	previewCorner.CornerRadius = UDim.new(0, 8)
	previewCorner.Parent = preview

	local viewport = Instance.new("ViewportFrame")
	viewport.Name = "ThreeDimensionalCard"
	viewport.BackgroundColor3 = Color3.fromRGB(14, 18, 27)
	viewport.BorderSizePixel = 0
	viewport.Position = UDim2.fromOffset(8, 8)
	viewport.Size = UDim2.fromOffset(120, 134)
	viewport.Ambient = Color3.fromRGB(180, 180, 180)
	viewport.LightColor = Color3.fromRGB(255, 255, 255)
	viewport.LightDirection = Vector3.new(-1, -1, -1)
	viewport.Parent = preview
	local viewportCorner = Instance.new("UICorner")
	viewportCorner.CornerRadius = UDim.new(0, 6)
	viewportCorner.Parent = viewport
	local camera = Instance.new("Camera")
	camera.CFrame = CFrame.lookAt(Vector3.new(0, 0, 9), Vector3.zero)
	camera.FieldOfView = 42
	camera.Parent = viewport
	viewport.CurrentCamera = camera
	local previewWorld = Instance.new("WorldModel")
	previewWorld.Name = "CardWorld"
	previewWorld.Parent = viewport
	local previewText = makeText(
		preview,
		"PreviewDescription",
		"The authoritative 3D card preview appears after opening the Starter Pack.",
		UDim2.new(1, -152, 1, -16)
	)
	previewText.Position = UDim2.fromOffset(144, 8)
	previewText.TextYAlignment = Enum.TextYAlignment.Center
	local cardFixtureParts = {}
	for _, system in LaunchDeckSetAssets.visualSystems do
		cardFixtureParts[system.frameFixtureName] = {
			framePartName = system.framePartName,
			facePartName = "CardFace",
			rankMarkPartName = "RankMark",
		}
		cardFixtureParts[system.fallbackFixtureName] = {
			framePartName = system.fallbackFramePartName,
			facePartName = "CardFace",
			rankMarkPartName = system.fallbackMarkPartName,
		}
	end

	local previewPool = ComponentPool.new(function(kind: string): Model
		local fixtureName = if string.sub(kind, 1, 5) == "card:"
			then string.sub(kind, 6)
			elseif kind == "pack:radioactive" then "RadioactivePackFixture"
			elseif kind == "pack:astral" then "AstralPackFixture"
			else "ClassicStarterPackFixture"
		assert(
			string.sub(kind, 1, 5) == "card:" or string.sub(kind, 1, 5) == "pack:",
			"P002-CLIENT-003 preview kind invalid"
		)
		local template = presentationAssets:FindFirstChild(fixtureName)
		assert(template ~= nil and template:IsA("Model"), "P002-CLIENT-006 fixture invalid")
		local model = template:Clone()
		if string.sub(kind, 1, 5) == "card:" then
			local parts = cardFixtureParts[fixtureName]
			assert(parts ~= nil, "P003-CLIENT-007 card fixture contract missing")
			local frame = model:FindFirstChild(parts.framePartName) :: Part
			local face = model:FindFirstChild(parts.facePartName) :: Part
			local rankMark = model:FindFirstChild(parts.rankMarkPartName) :: Part
			assert(
				frame ~= nil and face ~= nil and rankMark ~= nil,
				"P003-CLIENT-008 card fixture parts missing"
			)
			model.PrimaryPart = frame
			face.CFrame = CFrame.new(0, 0, 0.18)
			rankMark.CFrame = CFrame.new(-1.35, 2.05, 0.3)
		else
			local body = model:FindFirstChild("PackBody") :: Part
			local seal = model:FindFirstChild("PackSeal") :: Part
			assert(body ~= nil and seal ~= nil, "P002-CLIENT-007 pack fixture parts missing")
			model.PrimaryPart = body
			seal.CFrame = CFrame.new(0, 0, 0.28)
		end
		return model
	end, function(model: Model)
		model.Parent = nil
	end, 2)
	local activePreview: Model? = nil

	local cards = Instance.new("ScrollingFrame")
	cards.Name = "Cards"
	cards.AutomaticCanvasSize = Enum.AutomaticSize.Y
	cards.BackgroundColor3 = Color3.fromRGB(25, 31, 45)
	cards.BorderSizePixel = 0
	cards.CanvasSize = UDim2.fromOffset(0, 0)
	cards.AutomaticCanvasSize = Enum.AutomaticSize.None
	cards.ScrollBarThickness = 6
	cards.Size = UDim2.new(1, 0, 1, -526)
	cards.LayoutOrder = 9
	cards.Parent = background
	local cardsCorner = Instance.new("UICorner")
	cardsCorner.CornerRadius = UDim.new(0, 8)
	cardsCorner.Parent = cards
	local cardsPadding = Instance.new("UIPadding")
	cardsPadding.PaddingTop = UDim.new(0, 8)
	cardsPadding.PaddingBottom = UDim.new(0, 8)
	cardsPadding.PaddingLeft = UDim.new(0, 8)
	cardsPadding.PaddingRight = UDim.new(0, 8)
	cardsPadding.Parent = cards
	local network = ReplicatedStorage:WaitForChild("Network")
	local clientAction = network:WaitForChild("ClientAction") :: RemoteEvent
	local serverMessage = network:WaitForChild("ServerMessage") :: RemoteEvent
	local state = ClientState.new()
	local surfaceState = SurfaceState.new()
	local revealState = PackRevealController.new()
	local selectedPackId = "classic"
	local requestRandom = Random.new()

	local function requestId(prefix: string): string
		return string.format(
			"request_%s_%d_%d",
			prefix,
			requestRandom:NextInteger(0, 2147483646),
			requestRandom:NextInteger(0, 2147483646)
		)
	end

	local function send(actionId: string, payload: any, prefix: string): string
		local request = requestId(prefix)
		clientAction:FireServer({
			version = 1,
			action = actionId,
			requestId = request,
			payload = payload,
		})
		return request
	end

	local function clearCardRows()
		for _, child in cards:GetChildren() do
			if child:IsA("TextLabel") then
				child:Destroy()
			end
		end
	end

	local function clearPreview()
		if activePreview ~= nil then
			previewPool:release(activePreview)
			activePreview = nil
		end
	end

	local function renderPreview(card: any, snapshot: any)
		clearPreview()
		local viewModel = CardViewModel.build(
			launchContract.clientCatalog,
			card,
			snapshot.settings,
			composedCardAssets
		)
		local descriptor = CardRenderer3D.render(viewModel)
		local presentation =
			PresentationResolver.card(launchContract.clientCatalog, card, LaunchDeckSetAssets)
		local model = previewPool:acquire("card:" .. presentation.fixtureName) :: Model
		model.Name = "CardModel3D"
		model:SetAttribute("AdapterVersion", descriptor.adapterVersion)
		model:SetAttribute("AccessibleName", descriptor.accessibleName)
		model:SetAttribute("InstanceId", descriptor.instanceId)
		model:SetAttribute("SemanticLayerCount", #descriptor.semanticLayers)
		model:SetAttribute("Animated", viewModel.settings.animated)
		model:SetAttribute("Flashing", viewModel.settings.flashing)
		model:SetAttribute("VisualSystemId", presentation.visualSystemId)
		model:SetAttribute("StaticFallback", presentation.fallback)
		local frame = model:FindFirstChild(presentation.framePartName) :: Part
		local face = model:FindFirstChild(presentation.facePartName) :: Part
		local rankMark = model:FindFirstChild(presentation.rankMarkPartName) :: Part
		assert(
			frame ~= nil and face ~= nil and rankMark ~= nil,
			"P003-CLIENT-009 resolved card parts missing"
		)
		if viewModel.settings.lowGraphics then
			frame.Color = Color3.fromRGB(92, 98, 112)
		end
		if presentation.rankMarkMode == "suit" then
			rankMark.Color = if card.suitId == "hearts" or card.suitId == "diamonds"
				then Color3.fromRGB(190, 56, 67)
				else Color3.fromRGB(40, 45, 55)
		end
		model.Parent = previewWorld
		activePreview = model
		previewText.Text = string.format(
			"3D Preview\n%s\nSystem: %s%s\nLayers: %d    Motion: %s    Flash: %s",
			descriptor.accessibleName,
			presentation.visualSystemId,
			if presentation.fallback then " fallback" else "",
			#descriptor.semanticLayers,
			if viewModel.settings.animated then "on" else "static",
			if viewModel.settings.flashing then "on" else "static"
		)
	end

	local function renderPackPreview(packId: string)
		clearPreview()
		local model = previewPool:acquire("pack:" .. packId) :: Model
		local packAsset = specialContentAssets:get("pack", packId)
		assert(packAsset ~= nil, "P003-CLIENT-010 pack asset missing")
		model.Name = "PackModel3D"
		model:SetAttribute("AccessibleName", packAsset.displayName)
		model:SetAttribute("AssetId", packAsset.assetId)
		model:SetAttribute("FallbackAssetId", packAsset.fallbackAssetId)
		model:SetAttribute("StaticFallback", true)
		model.Parent = previewWorld
		activePreview = model
		previewText.Text = string.format(
			"%s\nThe server commits ownership before this reveal.",
			packAsset.displayName
		)
	end

	local function activeIds(snapshot: any): { string }
		local values = {}
		for _, uid in snapshot.activeDeck do
			table.insert(values, uid)
		end
		table.sort(values)
		return values
	end

	local function starterRevealState(snapshot: any): string?
		for _, pending in snapshot.pendingPacks do
			if pending.packId == "classic_starter" then
				return pending.state
			end
		end
		return nil
	end

	local function buildActiveLookup(snapshot: any): { [string]: boolean }
		local lookup = {}
		for _, uid in snapshot.activeDeck do
			lookup[uid] = true
		end
		return lookup
	end

	local function renderCardRows(snapshot: any, lookup: { [string]: boolean })
		clearCardRows()
		local viewportHeight = math.max(cards.AbsoluteWindowSize.Y, 300)
		local range = VirtualizedBinder.visibleRange(
			#snapshot.cards,
			44,
			viewportHeight,
			math.max(0, cards.CanvasPosition.Y),
			2
		)
		for _, visible in VirtualizedBinder.project(snapshot.cards, range) do
			local index = visible.index
			local card = visible.item
			local viewModel = CardViewModel.build(
				launchContract.clientCatalog,
				card,
				snapshot.settings,
				composedCardAssets
			)
			local descriptor = CardRenderer2D.render(viewModel)
			local row = makeText(
				cards,
				"Card" .. tostring(index),
				string.format(
					"%s    %s",
					descriptor.accessibleName,
					if lookup[card.instanceId] then "Equipped" else "Binder"
				),
				UDim2.new(1, -16, 0, 38)
			)
			row.Position = UDim2.fromOffset(8, (index - 1) * 44 + 8)
			row.BackgroundColor3 = Color3.fromRGB(32, 40, 57)
			row.BackgroundTransparency = 0
			row.BorderSizePixel = 0
			local rowCorner = Instance.new("UICorner")
			rowCorner.CornerRadius = UDim.new(0, 6)
			rowCorner.Parent = row
		end
		cards.CanvasSize = UDim2.fromOffset(0, #snapshot.cards * 44 + 16)
		cards:SetAttribute("VisibleCellCount", range.count)
		cards:SetAttribute("TotalItemCount", #snapshot.cards)
	end

	local function oddsText(values: any): string
		if type(values) ~= "table" or #values == 0 then
			return ""
		end
		local parts = {}
		for _, value in values do
			if type(value) == "table" and type(value.id) == "string" then
				table.insert(parts, value.id .. " " .. tostring(value.weight))
			end
		end
		return table.concat(parts, ", ")
	end

	local function render()
		local snapshot = state.snapshot
		local reveal = PackRevealController.display(revealState)
		local activeSurface = SurfaceState.project(surfaceState)
		app:SetAttribute("ActiveSurfaceId", activeSurface.id)
		app:SetAttribute("SurfaceState", activeSurface.status)
		app:SetAttribute("SurfaceRevision", activeSurface.revision)
		app:SetAttribute("SurfacePendingRecovery", activeSurface.pendingRecovery)
		for surfaceId, button in surfaceButtons do
			local surface = SurfaceState.project(surfaceState, surfaceId)
			button:SetAttribute("SurfaceId", surface.id)
			button:SetAttribute("SurfaceStatus", surface.status)
			button:SetAttribute("SurfaceAvailable", surface.available)
			button.BackgroundColor3 = if surfaceId == activeSurface.id
				then Color3.fromRGB(73, 111, 174)
				else Color3.fromRGB(43, 56, 78)
		end
		status.Text = string.format(
			"%s. %s. %s. %s. Reveal %s %d of %d.",
			state.phase,
			state.lastCode,
			activeSurface.title,
			activeSurface.description,
			reveal.packId or "none",
			reveal.revealedCount,
			reveal.totalCount
		)
		clearCardRows()
		if snapshot == nil then
			clearPreview()
			previewText.Text =
				"The authoritative 3D card preview appears after opening the Starter Pack."
			summary.Text = string.format(
				"%s. No authoritative profile snapshot is available.",
				activeSurface.description
			)
			setEnabled(openButton, false)
			setEnabled(equipButton, false)
			setEnabled(scoreButton, false)
			setEnabled(refreshButton, true)
			for _packId, button in packButtons do
				setEnabled(button, false)
			end
			setEnabled(revealNextButton, false)
			setEnabled(revealAllButton, false)
			setEnabled(skipButton, false)
			return
		end
		local active = activeIds(snapshot)
		summary.Text = string.format(
			"Cash: %d    Cards: %d    Equipped: %d    Revision: %d    Storage: %s%s",
			snapshot.currencies.cash or 0,
			#snapshot.cards,
			#active,
			snapshot.revision,
			snapshot.storageMode,
			if reveal.packId ~= nil
				then string.format(
					"    Pack price: %s %s",
					tostring(reveal.price),
					tostring(reveal.currencyId)
				)
				else ""
		)
		local lookup = buildActiveLookup(snapshot)
		renderCardRows(snapshot, lookup)
		local revealedCard = nil
		local revealedCardIndex = nil
		if reveal.kind == "card" then
			for index, item in reveal.contents do
				if item.revealed then
					revealedCard = item.item
					revealedCardIndex = index
					break
				end
			end
		end
		if revealedCard ~= nil then
			renderPreview(revealedCard, snapshot)
			previewText.Text = string.format(
				"%s\nClassification: %s\nRevealed %d of %d",
				previewText.Text,
				tostring(reveal.contents[revealedCardIndex].classification or "unclassified"),
				reveal.revealedCount,
				reveal.totalCount
			)
		elseif reveal.totalCount > 0 then
			clearPreview()
			local odds = oddsText(reveal.rarityOdds or reveal.itemOdds)
			previewText.Text = string.format(
				"%s\nRevealed %d of %d.\n%s%s",
				tostring(reveal.packId),
				reveal.revealedCount,
				reveal.totalCount,
				if odds ~= "" then "Exact odds weights: " .. odds .. "." else "",
				if reveal.pityBefore ~= nil
					then string.format(" Pity %d to %d.", reveal.pityBefore, reveal.pityAfter)
					else ""
			)
		elseif snapshot.cards[1] ~= nil then
			renderPreview(snapshot.cards[1], snapshot)
			local starterState = starterRevealState(snapshot)
			if starterState == "committed" then
				previewText.Text = "Starter Pack Reveal Pending\n" .. previewText.Text
			elseif starterState == "acknowledged" then
				previewText.Text = "Starter Pack Reveal Acknowledged\n" .. previewText.Text
			end
		else
			renderPackPreview(selectedPackId)
		end
		local unequipped = false
		for _, card in snapshot.cards do
			if not lookup[card.instanceId] then
				unequipped = true
				break
			end
		end
		setEnabled(openButton, snapshot.writable and #snapshot.cards == 0)
		setEnabled(equipButton, snapshot.writable and unequipped)
		setEnabled(scoreButton, snapshot.writable and #active >= 4)
		setEnabled(refreshButton, true)
		local packBlocked = reveal.phase == "revealing"
			or (reveal.phase == "complete" and reveal.kind == "offer")
		for _packId, button in packButtons do
			setEnabled(button, snapshot.writable and not packBlocked)
		end
		setEnabled(revealNextButton, reveal.phase == "revealing")
		setEnabled(revealAllButton, reveal.phase == "revealing")
		setEnabled(skipButton, reveal.phase == "revealing")
		for index, button in choiceButtons do
			local item = reveal.contents[index]
			button.Visible = reveal.kind == "offer" and item ~= nil
			if item ~= nil then
				button.Text = string.format(
					"Choose %d. %s",
					index,
					tostring(item.item.displayName or item.item.id)
				)
			end
			setEnabled(button, reveal.phase == "complete")
		end
	end

	local function applyLocalFailure(action: string, code: string)
		revealState = PackRevealController.applyMessage(revealState, {
			action = action,
			code = code,
			ok = false,
		})
		render()
	end

	local function openPack(packId: string)
		local snapshot = state.snapshot
		if snapshot == nil then
			return
		end
		local request = PackRevealController.openRequest(revealState, snapshot, packId)
		if not request.ok then
			applyLocalFailure("pack.open", request.code)
			return
		end
		selectedPackId = packId
		send("pack.open", request.payload, "pack")
	end

	cards:GetPropertyChangedSignal("CanvasPosition"):Connect(function()
		local snapshot = state.snapshot
		if snapshot ~= nil then
			renderCardRows(snapshot, buildActiveLookup(snapshot))
		end
	end)

	for packId, button in packButtons do
		button.Activated:Connect(function()
			openPack(packId)
		end)
	end

	revealNextButton.Activated:Connect(function()
		revealState = PackRevealController.revealNext(revealState)
		render()
	end)

	revealAllButton.Activated:Connect(function()
		revealState = PackRevealController.revealAll(revealState)
		render()
	end)

	skipButton.Activated:Connect(function()
		revealState = PackRevealController.skip(revealState)
		render()
	end)

	for index, button in choiceButtons do
		button.Activated:Connect(function()
			local snapshot = state.snapshot
			if snapshot == nil then
				return
			end
			local request = PackRevealController.choiceRequest(revealState, snapshot, index)
			if not request.ok then
				applyLocalFailure("pack.choose", request.code)
				return
			end
			send("pack.choose", request.payload, "choice")
		end)
	end

	openButton.Activated:Connect(function()
		local snapshot = state.snapshot
		if snapshot ~= nil and snapshot.writable then
			send("pack.open", {
				expectedRevision = snapshot.revision,
				packId = "classic_starter",
			}, "starter")
		end
	end)

	equipButton.Activated:Connect(function()
		local snapshot = state.snapshot
		if snapshot == nil or not snapshot.writable then
			return
		end
		local active = {}
		for _, uid in snapshot.activeDeck do
			active[uid] = true
		end
		for _, card in snapshot.cards do
			if not active[card.instanceId] then
				send("deck.equip_card", {
					expectedRevision = snapshot.revision,
					instanceId = card.instanceId,
					slotKey = card.slotKey,
				}, "equip")
				break
			end
		end
	end)

	scoreButton.Activated:Connect(function()
		local snapshot = state.snapshot
		if snapshot == nil or not snapshot.writable then
			return
		end
		local active = activeIds(snapshot)
		if #active >= 4 then
			send("formation.submit", {
				expectedRevision = snapshot.revision,
				instanceIds = { active[1], active[2], active[3], active[4] },
				modeId = "guided_classic",
				roundId = requestId("round"),
			}, "score")
		end
	end)

	refreshButton.Activated:Connect(function()
		send("bootstrap.request", {
			knownRevision = if state.snapshot ~= nil then state.snapshot.revision else nil,
		}, "bootstrap")
	end)

	serverMessage.OnClientEvent:Connect(function(message: any)
		revealState = PackRevealController.applyMessage(revealState, message)
		state = ClientState.applyMessage(state, message)
		surfaceState = SurfaceState.applyMessage(surfaceState, message)
		if
			message.action == "bootstrap.request"
			and message.ok
			and type(message.snapshot) == "table"
		then
			revealState = PackRevealController.setSettings(revealState, message.snapshot.settings)
			revealState = PackRevealController.hydrateSnapshot(revealState, message.snapshot)
		end
		render()
	end)

	for surfaceId, button in surfaceButtons do
		button.Activated:Connect(function()
			surfaceState = SurfaceState.navigate(surfaceState, surfaceId)
			render()
		end)
	end

	render()
	send("bootstrap.request", {}, "bootstrap")
end

return table.freeze(ClientApp)
