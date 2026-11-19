local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

local Catalog = require(script.Parent.BrainrotCatalog)
local WorldBuilder = require(script.Parent.WorldBuilder)

local GameService = {}

local STARTING_CASH = 260
local LOCK_SECONDS = 60
local LOCK_COST = 120
local BASE_REBIRTH_COST = 5000
local UPGRADE_BASE_COST = 450
local MAX_DEFENSE_LEVEL = 4
local MAX_BRAINROTS = 6
local CONVEYOR_REFRESH_SECONDS = 24

-- This table is the sole authoritative store for player, base, inventory, and economy state.
local state = {
	Started = false,
	Players = {},
	Bases = {},
	World = nil,
	ConveyorStock = {},
	CarryFolder = nil,
	Rng = Random.new(),
	LastNpcRaid = 0,
	Remotes = nil,
}

local function getPrompt(parent, name, actionText, objectText, holdDuration)
	local prompt = Instance.new("ProximityPrompt")
	prompt.Name = name
	prompt.ActionText = actionText
	prompt.ObjectText = objectText
	prompt.HoldDuration = holdDuration or 0.15
	prompt.MaxActivationDistance = 11
	prompt.RequiresLineOfSight = false
	prompt.Style = Enum.ProximityPromptStyle.Default
	prompt.KeyboardKeyCode = Enum.KeyCode.E
	prompt.GamepadKeyCode = Enum.KeyCode.ButtonX
	prompt.Parent = parent
	return prompt
end

local function sendState(player)
	local playerState = state.Players[player]
	if not playerState or not state.Remotes then
		return
	end
	local items = {}
	local income = 0
	for _, record in ipairs(playerState.Inventory) do
		local amount = Catalog.GetIncome(record.Item, record.Mutation)
		income += amount
		table.insert(items, {
			Name = record.Item.Name,
			Rarity = record.Item.Rarity,
			Mutation = record.Mutation,
			Income = amount,
		})
	end
	local remaining = math.max(0, math.ceil(playerState.Base.LockedUntil - os.clock()))
	state.Remotes.Update:FireClient(player, {
		Cash = playerState.Cash,
		Income = income * (1 + playerState.Rebirths * 0.25),
		Rebirths = playerState.Rebirths,
		RebirthCost = BASE_REBIRTH_COST * (playerState.Rebirths + 1),
		RebirthTier = playerState.Rebirths,
		Inventory = items,
		Carry = playerState.Carry and {
			Name = playerState.Carry.Item.Name,
			Rarity = playerState.Carry.Item.Rarity,
			Mutation = playerState.Carry.Mutation,
		} or nil,
		LockRemaining = remaining,
		LockCost = LOCK_COST,
		DefenseLevel = playerState.Base.DefenseLevel,
		UpgradeCost = UPGRADE_BASE_COST * (playerState.Base.DefenseLevel + 1),
		SlotsUsed = #playerState.Inventory,
		SlotsMax = MAX_BRAINROTS,
	})
end

local function announce(text)
	if state.Remotes then
		state.Remotes.Announce:FireAllClients(text)
	end
end

local function getFreeBase()
	for _, base in ipairs(state.Bases) do
		if not base.IsNpc and base.OwnerUserId == nil then
			return base
		end
	end
	return nil
end

local function updateGate(base)
	if base.LockedUntil > os.clock() then
		base.Gate.Color = Color3.fromRGB(244, 104, 87)
		base.Gate.Transparency = 0.12
	else
		base.Gate.Color = Color3.fromRGB(96, 188, 153)
		base.Gate.Transparency = 0.35
	end
	base.Gate.CanCollide = false
end

local function findInventoryRecord(base, slot)
	for index, record in ipairs(base.Slots) do
		if record == slot then
			return index
		end
	end
	return nil
end

local function clearRecord(base, record)
	local index = findInventoryRecord(base, record)
	if index then
		table.remove(base.Slots, index)
	end
	if record.Model and record.Model.Parent then
		record.Model:Destroy()
	end
end

local function clearCarry(player, playerState)
	if not playerState.Carry then
		return
	end
	local record = playerState.Carry
	playerState.Carry = nil
	if record.Model and record.Model.Parent then
		record.Model:Destroy()
	end
	local character = player.Character
	local humanoid = character and character:FindFirstChildOfClass("Humanoid")
	if humanoid then
		humanoid.WalkSpeed = 16
	end
	player:SetAttribute("CarryingBrainrot", false)
end

local function detachRecord(base, record)
	local index = findInventoryRecord(base, record)
	if not index then
		return false
	end
	table.remove(base.Slots, index)
	if record.Prompt then
		record.Prompt:Destroy()
		record.Prompt = nil
	end
	return true
end

local function carryRecord(player, playerState, record)
	if playerState.Carry then
		return false
	end
	local model = record.Model
	if not model or not model.Parent then
		model = Catalog.CreateModel(record.Item, record.Mutation, state.CarryFolder)
		record.Model = model
	end
	if not model.PrimaryPart then
		return false
	end
	playerState.Carry = record
	local character = player.Character
	local root = character and character:FindFirstChild("HumanoidRootPart")
	local humanoid = character and character:FindFirstChildOfClass("Humanoid")
	if root then
		model.Parent = state.CarryFolder
		model:PivotTo(root.CFrame * CFrame.new(0, 2.15, -2))
		for _, descendant in ipairs(model:GetDescendants()) do
			if descendant:IsA("BasePart") then
				descendant.Anchored = false
				descendant.CanCollide = false
				descendant.Massless = true
				if descendant ~= model.PrimaryPart then
					local partWeld = Instance.new("WeldConstraint")
					partWeld.Name = "ModelPartWeld"
					partWeld.Part0 = model.PrimaryPart
					partWeld.Part1 = descendant
					partWeld.Parent = model.PrimaryPart
				end
			end
		end
		local weld = Instance.new("WeldConstraint")
		weld.Name = "CarryWeld"
		weld.Part0 = model.PrimaryPart
		weld.Part1 = root
		weld.Parent = model.PrimaryPart
	end
	if humanoid then
		humanoid.WalkSpeed = 11.2
	end
	player:SetAttribute("CarryingBrainrot", true)
	return true
end

local function makeStoredRecord(item, mutation, model)
	return { Item = item, Mutation = mutation, Model = model }
end

local function slotFree(base)
	return #base.Slots < MAX_BRAINROTS
end

local function placeRecordOnBase(base, record)
	if not slotFree(base) then
		return false
	end
	local slotIndex = #base.Slots + 1
	local position = base.SlotPositions[slotIndex]
	if not position then
		return false
	end
	local model = record.Model
	if not model or not model.Parent then
		model = Catalog.CreateModel(record.Item, record.Mutation, state.World.Root)
		record.Model = model
	end
	model.Parent = base.Model
	for _, descendant in ipairs(model:GetDescendants()) do
		if descendant:IsA("BasePart") then
			descendant.Anchored = true
			descendant.CanCollide = false
			descendant.Massless = false
		elseif descendant:IsA("WeldConstraint") and (descendant.Name == "CarryWeld" or descendant.Name == "ModelPartWeld") then
			descendant:Destroy()
		end
	end
	model:PivotTo(CFrame.new(position))
	table.insert(base.Slots, record)
	local prompt = getPrompt(model.PrimaryPart, "BrainrotPrompt", base.IsNpc and "Swipe" or "Swipe", record.Item.Name .. " • " .. record.Item.Rarity, 0.3 + base.DefenseLevel * 1.1)
	prompt.MaxActivationDistance = 10
	record.Prompt = prompt
	prompt.Triggered:Connect(function(player)
		local playerState = state.Players[player]
		if not playerState or playerState.Carry or playerState.Base == base then
			return
		end
		if base.LockedUntil > os.clock() then
			state.Remotes.Announce:FireClient(player, "Base is locked for " .. math.ceil(base.LockedUntil - os.clock()) .. "s!")
			return
		end
		if not findInventoryRecord(base, record) then
			return
		end
		if base.DefenseLevel > 0 and state.Rng:NextNumber() < math.min(0.12 * base.DefenseLevel, 0.48) then
			state.Remotes.Announce:FireClient(player, "Your base defense repelled the swipe!")
			return
		end
		if not detachRecord(base, record) then
			return
		end
		carryRecord(player, playerState, record)
		state.Remotes.Announce:FireClient(player, "Grabbed " .. record.Item.Name .. "! Get it to your DROP ZONE.")
		local owner = base.OwnerUserId and Players:GetPlayerByUserId(base.OwnerUserId)
		if owner then
			state.Remotes.Announce:FireClient(owner, player.DisplayName .. " swiped your " .. record.Item.Name .. "!")
			sendState(owner)
		end
		sendState(player)
	end)
	return true
end

local function setupDeposit(base)
	local prompt = getPrompt(base.DepositPart, "DepositPrompt", "Drop Brainrot", "Your home base deposit zone", 0.15)
	prompt.MaxActivationDistance = 13
	prompt.Triggered:Connect(function(player)
		local playerState = state.Players[player]
		if not playerState or playerState.Base ~= base or not playerState.Carry then
			return
		end
		if not slotFree(base) then
			state.Remotes.Announce:FireClient(player, "Your display is full! Swipe an upgrade or make room.")
			return
		end
		local record = playerState.Carry
		playerState.Carry = nil
		player:SetAttribute("CarryingBrainrot", false)
		local character = player.Character
		local humanoid = character and character:FindFirstChildOfClass("Humanoid")
		if humanoid then
			humanoid.WalkSpeed = 16
		end
		placeRecordOnBase(base, record)
		state.Remotes.Announce:FireClient(player, record.Item.Name .. " is home! It earns $" .. Catalog.GetIncome(record.Item, record.Mutation) .. "/s.")
		sendState(player)
	end)
end

local function setupUpgrade(base)
	local prompt = getPrompt(base.UpgradePart, "DefenseUpgradePrompt", "Upgrade Defense", "Base defense", 0.2)
	prompt.ActionText = "Upgrade · $" .. UPGRADE_BASE_COST
	prompt.ObjectText = "Base defense · level 0"
	prompt.Triggered:Connect(function(player)
		local playerState = state.Players[player]
		if not playerState or playerState.Base ~= base then
			return
		end
		if base.DefenseLevel >= MAX_DEFENSE_LEVEL then
			state.Remotes.Announce:FireClient(player, "Your base defense is already maxed out!")
			return
		end
		local cost = UPGRADE_BASE_COST * (base.DefenseLevel + 1)
		if playerState.Cash < cost then
			state.Remotes.Announce:FireClient(player, "Defense costs $" .. cost .. ". Keep earning!")
			return
		end
		playerState.Cash -= cost
		base.DefenseLevel += 1
		prompt.ActionText = base.DefenseLevel >= MAX_DEFENSE_LEVEL and "MAX DEFENSE" or ("Upgrade · $" .. (UPGRADE_BASE_COST * (base.DefenseLevel + 1)))
		prompt.ObjectText = "Base defense · level " .. base.DefenseLevel
		for _, record in ipairs(base.Slots) do
			if record.Prompt then
				record.Prompt.HoldDuration = 0.3 + base.DefenseLevel * 1.1
			end
		end
		state.Remotes.Announce:FireClient(player, "Defense upgraded to level " .. base.DefenseLevel .. "!")
		sendState(player)
	end)
end

local function refreshConveyor()
	local highestTier = 0
	for _, playerState in pairs(state.Players) do
		highestTier = math.max(highestTier, playerState.Rebirths)
	end
	for index, pad in ipairs(state.World.ConveyorPads) do
		local stockIndex = index
		local previous = state.ConveyorStock[index]
		if previous and previous.Model and previous.Model.Parent then
			previous.Model:Destroy()
		end
		local item, mutation = Catalog.Roll(state.Rng, highestTier)
		local model = Catalog.CreateModel(item, mutation, state.World.Root)
		model:PivotTo(CFrame.new(pad.Position))
		state.ConveyorStock[index] = { Item = item, Mutation = mutation, Model = model }
		local prompt = pad.Part:FindFirstChild("BuyPrompt")
		if not prompt then
			prompt = getPrompt(pad.Part, "BuyPrompt", "Buy", "Brainrot", 0.15)
			prompt.Triggered:Connect(function(player)
				local playerState = state.Players[player]
				local stock = state.ConveyorStock[stockIndex]
				if not playerState or playerState.Carry then
					if playerState then
						state.Remotes.Announce:FireClient(player, "Drop off your carried brainrot first.")
					end
					return
				end
				if not stock or not stock.Model or not stock.Model.Parent then
					state.Remotes.Announce:FireClient(player, "That pick just sold. Wait for the next batch!")
					return
				end
				if playerState.Cash < stock.Item.Cost then
					state.Remotes.Announce:FireClient(player, "You need $" .. stock.Item.Cost .. " for " .. stock.Item.Name .. ".")
					return
				end
				if not slotFree(playerState.Base) then
					state.Remotes.Announce:FireClient(player, "Your display is full!")
					return
				end
				playerState.Cash -= stock.Item.Cost
				state.ConveyorStock[stockIndex] = nil
				local buyPrompt = pad.Part:FindFirstChild("BuyPrompt")
				if buyPrompt then
					buyPrompt.Enabled = false
				end
				stock.Model:Destroy()
				local record = makeStoredRecord(stock.Item, stock.Mutation, nil)
				carryRecord(player, playerState, record)
				state.Remotes.Announce:FireClient(player, "Bought " .. stock.Item.Name .. "! Carry it back to your DROP ZONE (-30% speed).")
				sendState(player)
			end)
		end
		prompt.ObjectText = item.Name .. " • " .. item.Rarity
		prompt.ActionText = "Buy $" .. item.Cost
		prompt.Enabled = true
	end
end

local function setupLockRemote()
	state.Remotes.Action.OnServerEvent:Connect(function(player, action)
		if type(action) ~= "string" then
			return
		end
		local playerState = state.Players[player]
		if not playerState then
			return
		end
		if action == "Lock" then
			if playerState.Base.LockedUntil > os.clock() then
				state.Remotes.Announce:FireClient(player, "Your base is already locked.")
				return
			end
			if playerState.Cash < LOCK_COST then
				state.Remotes.Announce:FireClient(player, "Locking your base costs $" .. LOCK_COST .. ".")
				return
			end
			playerState.Cash -= LOCK_COST
			playerState.Base.LockedUntil = os.clock() + LOCK_SECONDS
			updateGate(playerState.Base)
			state.Remotes.Announce:FireClient(player, "Base locked for 60 seconds!")
			sendState(player)
		elseif action == "Rebirth" then
			local cost = BASE_REBIRTH_COST * (playerState.Rebirths + 1)
			if playerState.Cash < cost then
				state.Remotes.Announce:FireClient(player, "Rebirth needs $" .. cost .. " and at least 1 delivered brainrot.")
				return
			end
			if playerState.Carry then
				state.Remotes.Announce:FireClient(player, "Bring your carried brainrot home before rebirthing.")
				return
			end
			if #playerState.Inventory == 0 then
				state.Remotes.Announce:FireClient(player, "Deliver at least one brainrot to your base before rebirthing.")
				return
			end
			for _, record in ipairs(table.clone(playerState.Inventory)) do
				clearRecord(playerState.Base, record)
			end
			playerState.Cash = STARTING_CASH
			playerState.Rebirths += 1
			playerState.Base.DefenseLevel = 0
			playerState.Base.LockedUntil = 0
			updateGate(playerState.Base)
			state.Remotes.Announce:FireClient(player, "Rebirth " .. playerState.Rebirths .. "! Permanent income +25%; rare stock odds rise.")
			sendState(player)
		end
	end)
end

local function assignPlayer(player)
	local base = getFreeBase()
	if not base then
		player:Kick("All four market bases are full. Please try another server!")
		return
	end
	base.OwnerUserId = player.UserId
	local signPart = base.Model:FindFirstChild("BaseSign")
	if signPart then
		local gui = signPart:FindFirstChild("MarketSign")
		local label = gui and gui:FindFirstChildOfClass("TextLabel")
		if label then
			label.Text = player.DisplayName .. "'S MARKET\nyour brainrot base"
		end
	end
	local playerState = {
		Cash = STARTING_CASH,
		Rebirths = 0,
		Inventory = base.Slots,
		Base = base,
		Carry = nil,
	}
	state.Players[player] = playerState
	player:SetAttribute("CarryingBrainrot", false)
	player.CharacterAdded:Connect(function(character)
		local root = character:WaitForChild("HumanoidRootPart", 10)
		local humanoid = character:WaitForChild("Humanoid", 10)
			if root and humanoid then
				task.wait(0.1)
				character:PivotTo(base.SpawnCFrame)
				if playerState.Carry and playerState.Carry.Model and playerState.Carry.Model.PrimaryPart then
					local model = playerState.Carry.Model
					local previousWeld = model.PrimaryPart:FindFirstChild("CarryWeld")
					if previousWeld then
						previousWeld:Destroy()
					end
					model:PivotTo(root.CFrame * CFrame.new(0, 2.15, -2))
					local weld = Instance.new("WeldConstraint")
					weld.Name = "CarryWeld"
					weld.Part0 = model.PrimaryPart
					weld.Part1 = root
					weld.Parent = model.PrimaryPart
					humanoid.WalkSpeed = 11.2
				else
					humanoid.WalkSpeed = 16
				end
			end
	end)
	if not player.Character then
		player:LoadCharacter()
	elseif player.Character:FindFirstChild("HumanoidRootPart") then
		player.Character:PivotTo(base.SpawnCFrame)
	end
	sendState(player)
end

local function removePlayer(player)
	local playerState = state.Players[player]
	if not playerState then
		return
	end
	clearCarry(player, playerState)
	for _, record in ipairs(table.clone(playerState.Inventory)) do
		clearRecord(playerState.Base, record)
	end
	playerState.Base.OwnerUserId = nil
	playerState.Base.DefenseLevel = 0
	playerState.Base.LockedUntil = 0
	playerState.Base.Name = "Open Player Base"
	updateGate(playerState.Base)
	state.Players[player] = nil
end

local function moveRival(model, destination, duration)
	if not model or not model.Parent then
		return false
	end
	local pivot = model:GetPivot()
	local value = Instance.new("CFrameValue")
	value.Value = pivot
	local connection = value:GetPropertyChangedSignal("Value"):Connect(function()
		if model.Parent then
			model:PivotTo(value.Value)
		end
	end)
	local tween = TweenService:Create(value, TweenInfo.new(duration, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), { Value = destination })
	tween:Play()
	local result = tween.Completed:Wait()
	connection:Disconnect()
	value:Destroy()
	return result == Enum.PlaybackState.Completed and model.Parent ~= nil
end

local function npcRaid()
	local candidates = {}
	for player, playerState in pairs(state.Players) do
		if #playerState.Inventory > 0 and playerState.Base.LockedUntil <= os.clock() and playerState.Base.DefenseLevel < MAX_DEFENSE_LEVEL then
			table.insert(candidates, { Player = player, State = playerState })
		end
	end
	if #candidates == 0 then
		return
	end
	local target = candidates[state.Rng:NextInteger(1, #candidates)]
	local npcBases = {}
	for _, base in ipairs(state.Bases) do
		if base.IsNpc and slotFree(base) then
			table.insert(npcBases, base)
		end
	end
	if #npcBases == 0 then
		return
	end
	local npcBase = npcBases[state.Rng:NextInteger(1, #npcBases)]
	local record = target.State.Inventory[state.Rng:NextInteger(1, #target.State.Inventory)]
	local rival = npcBase.RivalModel
	if not rival then
		return
	end
	local home = rival:GetPivot()
	local base = target.State.Base
	local raidingPosition = Vector3.new(base.Center.X, home.Position.Y, base.Center.Z + base.Front * 23)
	local approach = CFrame.lookAt(raidingPosition, Vector3.new(base.Center.X, home.Position.Y, base.Center.Z))
	task.spawn(function()
		if not moveRival(rival, approach, 2.1) then
			return
		end
		local activePlayerState = state.Players[target.Player]
		if activePlayerState ~= target.State or not findInventoryRecord(base, record) then
			moveRival(rival, home, 2.1)
			return
		end
		if base.LockedUntil > os.clock() then
			state.Remotes.Announce:FireClient(target.Player, npcBase.NpcName .. " tried your locked base and gave up!")
			moveRival(rival, home, 2.1)
			return
		end
		if base.DefenseLevel > 0 and state.Rng:NextNumber() < math.min(0.12 * base.DefenseLevel, 0.48) then
			state.Remotes.Announce:FireClient(target.Player, npcBase.NpcName .. " tried to swipe a brainrot, but your defense stopped them!")
			moveRival(rival, home, 2.1)
			return
		end
		if not detachRecord(base, record) then
			moveRival(rival, home, 2.1)
			return
		end
		placeRecordOnBase(npcBase, makeStoredRecord(record.Item, record.Mutation, nil))
		state.Remotes.Announce:FireClient(target.Player, npcBase.NpcName .. " snuck off with your " .. record.Item.Name .. "! Lock up or upgrade defense.")
		sendState(target.Player)
		moveRival(rival, home, 2.1)
	end)
end

function GameService.Start()
	if state.Started then
		return
	end
	state.Started = true
	Players.CharacterAutoLoads = true
	state.World = WorldBuilder.Build()
	state.Bases = state.World.Bases
	state.CarryFolder = Instance.new("Folder")
	state.CarryFolder.Name = "CarriedBrainrots"
	state.CarryFolder.Parent = workspace
	local remotes = Instance.new("Folder")
	remotes.Name = "PasarRemotes"
	remotes.Parent = ReplicatedStorage
	state.Remotes = {
		Action = Instance.new("RemoteEvent"),
		Update = Instance.new("RemoteEvent"),
		Announce = Instance.new("RemoteEvent"),
	}
	state.Remotes.Action.Name = "Action"
	state.Remotes.Update.Name = "Update"
	state.Remotes.Announce.Name = "Announce"
	for _, remote in pairs(state.Remotes) do
		remote.Parent = remotes
	end
	setupLockRemote()
	for _, base in ipairs(state.Bases) do
		if not base.IsNpc then
			setupDeposit(base)
			setupUpgrade(base)
		end
		updateGate(base)
		if base.IsNpc then
			local starterA = Catalog.Items[1 + (base.Index % 3)]
			local starterB = Catalog.Items[4]
			placeRecordOnBase(base, makeStoredRecord(starterA, nil, nil))
			placeRecordOnBase(base, makeStoredRecord(starterB, nil, nil))
		end
	end
	refreshConveyor()
	Players.PlayerAdded:Connect(assignPlayer)
	Players.PlayerRemoving:Connect(removePlayer)
	for _, player in ipairs(Players:GetPlayers()) do
		task.defer(assignPlayer, player)
	end
	local lastIncome = os.clock()
	local lastRefresh = os.clock()
	RunService.Heartbeat:Connect(function()
		local now = os.clock()
		if now - lastIncome >= 1 then
			local ticks = math.floor(now - lastIncome)
			lastIncome += ticks
			for player, playerState in pairs(state.Players) do
				local income = 0
				for _, record in ipairs(playerState.Inventory) do
					income += Catalog.GetIncome(record.Item, record.Mutation)
				end
				playerState.Cash += income * (1 + playerState.Rebirths * 0.25) * ticks
				sendState(player)
			end
		end
		if now - lastRefresh >= CONVEYOR_REFRESH_SECONDS then
			lastRefresh = now
			refreshConveyor()
		end
		if now - state.LastNpcRaid >= 38 then
			state.LastNpcRaid = now
			if state.Rng:NextNumber() < 0.72 then
				npcRaid()
			end
		end
		for _, base in ipairs(state.Bases) do
			if base.LockedUntil > 0 and base.LockedUntil <= now then
				base.LockedUntil = 0
				updateGate(base)
				local owner = base.OwnerUserId and Players:GetPlayerByUserId(base.OwnerUserId)
				if owner then
					state.Remotes.Announce:FireClient(owner, "Your 60-second base lock just expired.")
					sendState(owner)
				end
			end
		end
	end)
end

return GameService
