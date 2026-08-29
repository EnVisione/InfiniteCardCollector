--!strict

local ContentProvider = game:GetService("ContentProvider")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ClientState = require(script.Parent.Parent.State.ClientState)
local CardRenderer2D = require(script.Parent.Parent.Rendering.CardRenderer2D)
local CardRenderer3D = require(script.Parent.Parent.Rendering.CardRenderer3D)
local ComponentPool = require(script.Parent.Parent.Rendering.ComponentPool)
local PreloadManifest = require(script.Parent.Parent.Rendering.PreloadManifest)
local VirtualizedBinder = require(script.Parent.Parent.Rendering.VirtualizedBinder)
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

	local status =
		makeText(background, "Status", "Connecting to the server.", UDim2.new(1, 0, 0, 42))
	status.LayoutOrder = 2
	local summary = makeText(background, "Summary", "No profile loaded.", UDim2.new(1, 0, 0, 42))
	summary.LayoutOrder = 3

	local actions = Instance.new("Frame")
	actions.Name = "Actions"
	actions.BackgroundTransparency = 1
	actions.Size = UDim2.new(1, 0, 0, 44)
	actions.LayoutOrder = 4
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

	local preview = Instance.new("Frame")
	preview.Name = "CardPreview"
	preview.BackgroundColor3 = Color3.fromRGB(25, 31, 45)
	preview.BorderSizePixel = 0
	preview.Size = UDim2.new(1, 0, 0, 150)
	preview.LayoutOrder = 5
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

	local previewPool = ComponentPool.new(function(kind: string): Model
		local fixtureName = if kind == "card"
			then "ClassicFrameFixture"
			else "ClassicStarterPackFixture"
		assert(kind == "card" or kind == "pack", "P002-CLIENT-003 preview kind invalid")
		local template = presentationAssets:FindFirstChild(fixtureName)
		assert(template ~= nil and template:IsA("Model"), "P002-CLIENT-006 fixture invalid")
		local model = template:Clone()
		if kind == "card" then
			local frame = model:FindFirstChild("ClassicFrame") :: Part
			local face = model:FindFirstChild("CardFace") :: Part
			local rankMark = model:FindFirstChild("RankMark") :: Part
			model.PrimaryPart = frame
			face.CFrame = CFrame.new(0, 0, 0.18)
			rankMark.CFrame = CFrame.new(-1.35, 2.05, 0.3)
		else
			local body = model:FindFirstChild("PackBody") :: Part
			local seal = model:FindFirstChild("PackSeal") :: Part
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
	cards.Size = UDim2.new(1, 0, 1, -364)
	cards.LayoutOrder = 6
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
	local requestRandom = Random.new()

	local function requestId(prefix: string): string
		return string.format(
			"request_%s_%d_%d",
			prefix,
			requestRandom:NextInteger(0, 2147483646),
			requestRandom:NextInteger(0, 2147483646)
		)
	end

	local function send(actionId: string, payload: any, prefix: string)
		clientAction:FireServer({
			version = 1,
			action = actionId,
			requestId = requestId(prefix),
			payload = payload,
		})
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
		local viewModel = CardViewModel.build(launchContract.clientCatalog, card, snapshot.settings)
		local descriptor = CardRenderer3D.render(viewModel)
		local model = previewPool:acquire("card") :: Model
		model.Name = "CardModel3D"
		model:SetAttribute("AdapterVersion", descriptor.adapterVersion)
		model:SetAttribute("AccessibleName", descriptor.accessibleName)
		model:SetAttribute("InstanceId", descriptor.instanceId)
		model:SetAttribute("SemanticLayerCount", #descriptor.semanticLayers)
		model:SetAttribute("Animated", viewModel.settings.animated)
		model:SetAttribute("Flashing", viewModel.settings.flashing)
		local frame = model:FindFirstChild("ClassicFrame") :: Part
		local face = model:FindFirstChild("CardFace") :: Part
		local rankMark = model:FindFirstChild("RankMark") :: Part
		frame.Color = if viewModel.settings.lowGraphics
			then Color3.fromRGB(92, 98, 112)
			else Color3.fromRGB(164, 132, 66)
		face.Color = Color3.fromRGB(235, 232, 220)
		rankMark.Color = if card.suitId == "hearts" or card.suitId == "diamonds"
			then Color3.fromRGB(190, 56, 67)
			else Color3.fromRGB(40, 45, 55)
		model.Parent = previewWorld
		activePreview = model
		previewText.Text = string.format(
			"3D Preview\n%s\nLayers: %d    Motion: %s    Flash: %s",
			descriptor.accessibleName,
			#descriptor.semanticLayers,
			if viewModel.settings.animated then "on" else "static",
			if viewModel.settings.flashing then "on" else "static"
		)
	end

	local function renderPackPreview()
		clearPreview()
		local model = previewPool:acquire("pack") :: Model
		model.Name = "PackModel3D"
		model:SetAttribute("AccessibleName", "Classic Starter Pack")
		model:SetAttribute("StaticFallback", true)
		model.Parent = previewWorld
		activePreview = model
		previewText.Text =
			"Classic Starter Pack\nFive unique Classic cards. The server commits ownership before this reveal."
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
			local viewModel =
				CardViewModel.build(launchContract.clientCatalog, card, snapshot.settings)
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

	local function render()
		local snapshot = state.snapshot
		status.Text = string.format("%s. %s.", state.phase, state.lastCode)
		clearCardRows()
		if snapshot == nil then
			clearPreview()
			previewText.Text =
				"The authoritative 3D card preview appears after opening the Starter Pack."
			summary.Text = "No authoritative profile snapshot is available."
			setEnabled(openButton, false)
			setEnabled(equipButton, false)
			setEnabled(scoreButton, false)
			setEnabled(refreshButton, true)
			return
		end
		local active = activeIds(snapshot)
		summary.Text = string.format(
			"Cash: %d    Cards: %d    Equipped: %d    Revision: %d    Storage: %s",
			snapshot.currencies.cash,
			#snapshot.cards,
			#active,
			snapshot.revision,
			snapshot.storageMode
		)
		local lookup = buildActiveLookup(snapshot)
		renderCardRows(snapshot, lookup)
		if snapshot.cards[1] ~= nil then
			renderPreview(snapshot.cards[1], snapshot)
			local revealState = starterRevealState(snapshot)
			if revealState == "committed" then
				previewText.Text = "Starter Pack Reveal Pending\n" .. previewText.Text
			elseif revealState == "acknowledged" then
				previewText.Text = "Starter Pack Reveal Acknowledged\n" .. previewText.Text
			end
		else
			renderPackPreview()
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
	end

	cards:GetPropertyChangedSignal("CanvasPosition"):Connect(function()
		local snapshot = state.snapshot
		if snapshot ~= nil then
			renderCardRows(snapshot, buildActiveLookup(snapshot))
		end
	end)

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
		state = ClientState.applyMessage(state, message)
		render()
	end)

	render()
	send("bootstrap.request", {}, "bootstrap")
end

return table.freeze(ClientApp)
