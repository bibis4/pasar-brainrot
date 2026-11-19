local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer
local remotes = ReplicatedStorage:WaitForChild("PasarRemotes")
local updateRemote = remotes:WaitForChild("Update")
local announceRemote = remotes:WaitForChild("Announce")
local actionRemote = remotes:WaitForChild("Action")

local palette = {
	Ink = Color3.fromRGB(34, 49, 57),
	Cream = Color3.fromRGB(255, 249, 225),
	Paper = Color3.fromRGB(255, 254, 247),
	Mint = Color3.fromRGB(70, 176, 137),
	Gold = Color3.fromRGB(255, 203, 79),
	Coral = Color3.fromRGB(243, 125, 103),
	SoftBlue = Color3.fromRGB(222, 241, 246),
}

local rarityColors = {
	Common = Color3.fromRGB(177, 191, 170),
	Rare = Color3.fromRGB(75, 158, 220),
	Epic = Color3.fromRGB(164, 101, 214),
	Legendary = Color3.fromRGB(235, 155, 42),
	Mythic = Color3.fromRGB(228, 74, 119),
}

local function round(instance, radius)
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, radius or 14)
	corner.Parent = instance
	return corner
end

local function outline(instance, color, thickness, transparency)
	local stroke = Instance.new("UIStroke")
	stroke.Color = color or Color3.fromRGB(228, 215, 178)
	stroke.Thickness = thickness or 1
	stroke.Transparency = transparency or 0.15
	stroke.Parent = instance
	return stroke
end

local function label(parent, name, text, size, color, font, alignment)
	local item = Instance.new("TextLabel")
	item.Name = name
	item.BackgroundTransparency = 1
	item.Text = text
	item.TextColor3 = color or palette.Ink
	item.TextSize = size or 16
	item.Font = font or Enum.Font.GothamMedium
	item.TextXAlignment = alignment or Enum.TextXAlignment.Left
	item.TextYAlignment = Enum.TextYAlignment.Center
	item.Parent = parent
	return item
end

local function button(parent, name, text, fill)
	local item = Instance.new("TextButton")
	item.Name = name
	item.Text = text
	item.TextColor3 = palette.Ink
	item.TextSize = 16
	item.Font = Enum.Font.GothamBold
	item.AutoButtonColor = true
	item.BackgroundColor3 = fill
	item.BorderSizePixel = 0
	item.Parent = parent
	round(item, 13)
	outline(item, Color3.fromRGB(255, 255, 255), 1, 0.35)
	return item
end

local gui = Instance.new("ScreenGui")
gui.Name = "PasarHUD"
gui.ResetOnSpawn = false
gui.DisplayOrder = 20
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
gui.Parent = player:WaitForChild("PlayerGui")

local top = Instance.new("Frame")
top.Name = "MarketHeader"
top.AnchorPoint = Vector2.new(0.5, 0)
top.Position = UDim2.new(0.5, 0, 0, 14)
top.Size = UDim2.new(0.78, 0, 0, 78)
top.BackgroundColor3 = palette.Cream
top.BorderSizePixel = 0
top.Parent = gui
round(top, 20)
outline(top, Color3.fromRGB(255, 255, 255), 2, 0.1)
local topConstraint = Instance.new("UISizeConstraint")
topConstraint.MinSize = Vector2.new(330, 72)
topConstraint.MaxSize = Vector2.new(850, 82)
topConstraint.Parent = top

local title = label(top, "Title", "🥭  PASAR BRAINROT", 21, palette.Ink, Enum.Font.GothamBlack)
title.Position = UDim2.new(0, 18, 0, 7)
title.Size = UDim2.new(0.45, -18, 0, 28)
local subtitle = label(top, "Subtitle", "REBUT • REBUT • REBIRTH", 10, Color3.fromRGB(117, 133, 131), Enum.Font.GothamBold)
subtitle.Position = UDim2.new(0, 20, 0, 38)
subtitle.Size = UDim2.new(0.45, -20, 0, 19)

local cashValue = label(top, "CashValue", "$260", 25, Color3.fromRGB(52, 139, 103), Enum.Font.GothamBlack, Enum.TextXAlignment.Right)
cashValue.AnchorPoint = Vector2.new(1, 0)
cashValue.Position = UDim2.new(0.71, -12, 0, 7)
cashValue.Size = UDim2.new(0.25, 0, 0, 32)
local incomeValue = label(top, "IncomeValue", "$0 / sec", 13, palette.Ink, Enum.Font.GothamSemibold, Enum.TextXAlignment.Right)
incomeValue.AnchorPoint = Vector2.new(1, 0)
incomeValue.Position = UDim2.new(0.71, -12, 0, 41)
incomeValue.Size = UDim2.new(0.25, 0, 0, 21)

local carryPill = Instance.new("TextLabel")
carryPill.Name = "CarryPill"
carryPill.AnchorPoint = Vector2.new(0.5, 0)
carryPill.Position = UDim2.new(0.5, 0, 0, 104)
carryPill.Size = UDim2.new(0.53, 0, 0, 35)
carryPill.BackgroundColor3 = palette.Gold
carryPill.BorderSizePixel = 0
carryPill.Font = Enum.Font.GothamBold
carryPill.TextColor3 = palette.Ink
carryPill.TextSize = 14
carryPill.Text = ""
carryPill.Visible = false
carryPill.Parent = gui
round(carryPill, 14)
local carryConstraint = Instance.new("UISizeConstraint")
carryConstraint.MinSize = Vector2.new(250, 35)
carryConstraint.MaxSize = Vector2.new(520, 38)
carryConstraint.Parent = carryPill

local helpCard = Instance.new("Frame")
helpCard.Name = "HowToPlay"
helpCard.Position = UDim2.new(0, 18, 0.36, 0)
helpCard.Size = UDim2.new(0, 218, 0, 207)
helpCard.BackgroundColor3 = palette.Paper
helpCard.BackgroundTransparency = 0.08
helpCard.BorderSizePixel = 0
helpCard.Parent = gui
round(helpCard, 16)
outline(helpCard, Color3.fromRGB(255, 255, 255), 1, 0.25)
local helpTitle = label(helpCard, "HelpTitle", "YOUR MARKET RUN", 15, palette.Ink, Enum.Font.GothamBlack)
helpTitle.Position = UDim2.new(0, 14, 0, 12)
helpTitle.Size = UDim2.new(1, -28, 0, 22)
local helpText = label(helpCard, "HelpText", "MOVE: WASD / thumbstick\n① Pick from the belt\n② Carry it home (slower!)\n③ Earn cash at your base\n④ Swipe rivals; gold stand upgrades defense\n⑤ Rebirth for permanent income", 13, Color3.fromRGB(73, 91, 95), Enum.Font.GothamMedium)
helpText.Position = UDim2.new(0, 14, 0, 43)
helpText.Size = UDim2.new(1, -25, 1, -54)
helpText.TextYAlignment = Enum.TextYAlignment.Top
helpText.TextWrapped = true

local inventoryCard = Instance.new("Frame")
inventoryCard.Name = "InventoryPanel"
inventoryCard.AnchorPoint = Vector2.new(1, 0.5)
inventoryCard.Position = UDim2.new(1, -18, 0.5, 0)
inventoryCard.Size = UDim2.new(0, 250, 0, 262)
inventoryCard.BackgroundColor3 = palette.Paper
inventoryCard.BackgroundTransparency = 0.08
inventoryCard.BorderSizePixel = 0
inventoryCard.Parent = gui
round(inventoryCard, 16)
outline(inventoryCard, Color3.fromRGB(255, 255, 255), 1, 0.25)
local inventoryTitle = label(inventoryCard, "InventoryTitle", "🧺  YOUR DISPLAY", 15, palette.Ink, Enum.Font.GothamBlack)
inventoryTitle.Position = UDim2.new(0, 14, 0, 12)
inventoryTitle.Size = UDim2.new(1, -28, 0, 25)
local inventoryCount = label(inventoryCard, "InventoryCount", "0 / 6 brainrots", 12, Color3.fromRGB(123, 139, 132), Enum.Font.GothamMedium)
inventoryCount.Position = UDim2.new(0, 15, 0, 39)
inventoryCount.Size = UDim2.new(1, -28, 0, 20)
local inventoryList = Instance.new("ScrollingFrame")
inventoryList.Name = "InventoryList"
inventoryList.Position = UDim2.new(0, 12, 0, 64)
inventoryList.Size = UDim2.new(1, -24, 1, -76)
inventoryList.BackgroundTransparency = 1
inventoryList.BorderSizePixel = 0
inventoryList.ScrollBarThickness = 4
inventoryList.ScrollBarImageColor3 = Color3.fromRGB(183, 196, 171)
inventoryList.AutomaticCanvasSize = Enum.AutomaticSize.Y
inventoryList.CanvasSize = UDim2.new()
inventoryList.Parent = inventoryCard
local inventoryLayout = Instance.new("UIListLayout")
inventoryLayout.Padding = UDim.new(0, 6)
inventoryLayout.SortOrder = Enum.SortOrder.LayoutOrder
inventoryLayout.Parent = inventoryList

local actionBar = Instance.new("Frame")
actionBar.Name = "ActionBar"
actionBar.AnchorPoint = Vector2.new(0.5, 1)
actionBar.Position = UDim2.new(0.5, 0, 1, -16)
actionBar.Size = UDim2.new(0, 476, 0, 62)
actionBar.BackgroundColor3 = palette.Cream
actionBar.BackgroundTransparency = 0.02
actionBar.BorderSizePixel = 0
actionBar.Parent = gui
round(actionBar, 18)
outline(actionBar, Color3.fromRGB(255, 255, 255), 2, 0.14)
local barLayout = Instance.new("UIListLayout")
barLayout.FillDirection = Enum.FillDirection.Horizontal
barLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
barLayout.VerticalAlignment = Enum.VerticalAlignment.Center
barLayout.Padding = UDim.new(0, 10)
barLayout.Parent = actionBar
local lockButton = button(actionBar, "LockBaseButton", "🔒  LOCK BASE · $120", Color3.fromRGB(186, 222, 202))
lockButton.Size = UDim2.new(0, 218, 0, 46)
local rebirthButton = button(actionBar, "RebirthButton", "♻  REBIRTH · $5K", Color3.fromRGB(255, 208, 120))
rebirthButton.Size = UDim2.new(0, 218, 0, 46)

local toast = Instance.new("TextLabel")
toast.Name = "MarketAnnouncement"
toast.AnchorPoint = Vector2.new(0.5, 0)
toast.Position = UDim2.new(0.5, 0, 0, 148)
toast.Size = UDim2.new(0.62, 0, 0, 48)
toast.BackgroundColor3 = palette.Ink
toast.BackgroundTransparency = 1
toast.BorderSizePixel = 0
toast.Font = Enum.Font.GothamBold
toast.TextColor3 = palette.Cream
toast.TextSize = 15
toast.TextTransparency = 1
toast.TextWrapped = true
toast.Visible = false
toast.Parent = gui
round(toast, 14)
local toastConstraint = Instance.new("UISizeConstraint")
toastConstraint.MinSize = Vector2.new(270, 44)
toastConstraint.MaxSize = Vector2.new(620, 54)
toastConstraint.Parent = toast
local activeToastTween

local function showToast(message)
	toast.Text = message
	toast.Visible = true
	if activeToastTween then
		activeToastTween:Cancel()
	end
	toast.BackgroundTransparency = 1
	toast.TextTransparency = 1
	activeToastTween = TweenService:Create(toast, TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
		BackgroundTransparency = 0.08,
		TextTransparency = 0,
	})
	activeToastTween:Play()
	local messageAt = os.clock()
	task.delay(3.6, function()
		if not toast.Parent or toast.Text ~= message or os.clock() - messageAt < 3.5 then
			return
		end
		local fade = TweenService:Create(toast, TweenInfo.new(0.28), { BackgroundTransparency = 1, TextTransparency = 1 })
		activeToastTween = fade
		fade:Play()
		fade.Completed:Wait()
		if toast.Text == message then
			toast.Visible = false
		end
	end)
end

local function renderInventory(inventory)
	for _, child in ipairs(inventoryList:GetChildren()) do
		if child:IsA("Frame") then
			child:Destroy()
		end
	end
	for index, item in ipairs(inventory) do
		local row = Instance.new("Frame")
		row.Name = "InventoryRow" .. index
		row.LayoutOrder = index
		row.Size = UDim2.new(1, -6, 0, 37)
		row.BackgroundColor3 = Color3.fromRGB(248, 244, 226)
		row.BorderSizePixel = 0
		row.Parent = inventoryList
		round(row, 10)
		local stripe = Instance.new("Frame")
		stripe.Name = "RarityStripe"
		stripe.Size = UDim2.new(0, 5, 1, -8)
		stripe.Position = UDim2.new(0, 5, 0, 4)
		stripe.BackgroundColor3 = rarityColors[item.Rarity] or palette.Mint
		stripe.BorderSizePixel = 0
		stripe.Parent = row
		round(stripe, 4)
		local nameText = item.Name
		if item.Mutation then
			nameText = item.Mutation .. " " .. nameText
		end
		local nameLabel = label(row, "ItemName", nameText, 12, palette.Ink, Enum.Font.GothamBold)
		nameLabel.Position = UDim2.new(0, 16, 0, 2)
		nameLabel.Size = UDim2.new(0.67, -16, 0.5, 0)
		local rarity = label(row, "Rarity", item.Rarity, 10, rarityColors[item.Rarity], Enum.Font.GothamMedium)
		rarity.Position = UDim2.new(0, 16, 0.5, -1)
		rarity.Size = UDim2.new(0.67, -16, 0.5, 0)
		local income = label(row, "Income", "+$" .. item.Income .. "/s", 11, Color3.fromRGB(53, 137, 98), Enum.Font.GothamBold, Enum.TextXAlignment.Right)
		income.Position = UDim2.new(0.67, 0, 0, 0)
		income.Size = UDim2.new(0.3, -8, 1, 0)
	end
end

updateRemote.OnClientEvent:Connect(function(data)
	cashValue.Text = "$" .. string.format("%d", data.Cash or 0)
	incomeValue.Text = "+$" .. string.format("%d", data.Income or 0) .. " / sec   •   rebirth " .. tostring(data.Rebirths or 0)
	inventoryCount.Text = tostring(data.SlotsUsed or 0) .. " / " .. tostring(data.SlotsMax or 6) .. " brainrots"
	lockButton.Text = data.LockRemaining and data.LockRemaining > 0 and ("🔒  LOCKED · " .. data.LockRemaining .. "s") or ("🔒  LOCK BASE · $" .. (data.LockCost or 120))
	lockButton.BackgroundColor3 = data.LockRemaining and data.LockRemaining > 0 and Color3.fromRGB(251, 168, 143) or Color3.fromRGB(186, 222, 202)
	rebirthButton.Text = "♻  REBIRTH · $" .. tostring(data.RebirthCost or 5000)
	helpTitle.Text = (data.DefenseLevel or 0) > 0 and ("YOUR MARKET RUN  🛡" .. tostring(data.DefenseLevel)) or "YOUR MARKET RUN"
	renderInventory(data.Inventory or {})
	if data.Carry then
		local carryName = data.Carry.Mutation and (data.Carry.Mutation .. " " .. data.Carry.Name) or data.Carry.Name
		carryPill.Text = "📦  CARRYING " .. carryName .. "  →  RUN TO YOUR DROP ZONE"
		carryPill.Visible = true
	else
		carryPill.Visible = false
	end
end)

announceRemote.OnClientEvent:Connect(showToast)
lockButton.Activated:Connect(function()
	actionRemote:FireServer("Lock")
end)
rebirthButton.Activated:Connect(function()
	actionRemote:FireServer("Rebirth")
end)

local function updateResponsiveLayout()
	local camera = workspace.CurrentCamera
	if not camera then
		return
	end
	local view = camera.ViewportSize
	top.Size = UDim2.new(0.78, 0, 0, 78)
	lockButton.Size = UDim2.new(0, 218, 0, 46)
	rebirthButton.Size = UDim2.new(0, 218, 0, 46)
	lockButton.TextSize = 16
	rebirthButton.TextSize = 16
	title.TextSize = 21
	inventoryCard.Size = UDim2.new(0, 250, 0, 262)
	inventoryTitle.TextSize = 15
	inventoryCount.TextSize = 12
	actionBar.Size = UDim2.new(0, 476, 0, 62)
	carryPill.Position = UDim2.new(0.5, 0, 0, 104)
	carryPill.Size = UDim2.new(0.53, 0, 0, 35)
	carryPill.TextSize = 14
	if view.X < 850 then
		helpCard.Visible = false
		inventoryCard.Size = UDim2.new(0, 205, 0, 205)
		inventoryCard.Position = UDim2.new(1, -10, 0.49, 0)
		actionBar.Size = UDim2.new(0, 420, 0, 58)
		lockButton.Size = UDim2.new(0, 190, 0, 42)
		rebirthButton.Size = UDim2.new(0, 190, 0, 42)
		lockButton.TextSize = 14
		rebirthButton.TextSize = 14
		top.Size = UDim2.new(0.96, 0, 0, 76)
		if view.X < 560 then
			inventoryCard.Size = UDim2.new(0, 182, 0, 158)
			inventoryCard.Position = UDim2.new(1, -8, 0.56, 0)
			actionBar.Size = UDim2.new(0, 338, 0, 56)
			lockButton.Size = UDim2.new(0, 153, 0, 40)
			rebirthButton.Size = UDim2.new(0, 153, 0, 40)
			lockButton.TextSize = 11
			rebirthButton.TextSize = 11
			title.TextSize = 16
			inventoryTitle.TextSize = 12
			inventoryCount.TextSize = 10
			carryPill.Position = UDim2.new(0.45, 0, 0, 98)
			carryPill.Size = UDim2.new(0.7, 0, 0, 35)
			carryPill.TextSize = 11
		end
	else
		helpCard.Visible = true
		inventoryCard.Size = UDim2.new(0, 250, 0, 262)
		inventoryCard.Position = UDim2.new(1, -18, 0.5, 0)
		actionBar.Size = UDim2.new(0, 476, 0, 62)
		lockButton.Size = UDim2.new(0, 218, 0, 46)
		rebirthButton.Size = UDim2.new(0, 218, 0, 46)
		lockButton.TextSize = 16
		rebirthButton.TextSize = 16
		inventoryTitle.TextSize = 15
		inventoryCount.TextSize = 12
		carryPill.Position = UDim2.new(0.5, 0, 0, 104)
		carryPill.Size = UDim2.new(0.53, 0, 0, 35)
		carryPill.TextSize = 14
	end
end

if workspace.CurrentCamera then
	workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(updateResponsiveLayout)
end
updateResponsiveLayout()
