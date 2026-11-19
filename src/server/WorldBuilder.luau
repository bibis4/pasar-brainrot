local WorldBuilder = {}

local FLOOR_Y = 1

local function part(parent, name, size, position, color, material, shape)
	local instance = Instance.new("Part")
	instance.Name = name
	instance.Size = size
	instance.Position = position
	instance.Color = color
	instance.Material = material or Enum.Material.SmoothPlastic
	instance.Shape = shape or Enum.PartType.Block
	instance.Anchored = true
	instance.TopSurface = Enum.SurfaceType.Smooth
	instance.BottomSurface = Enum.SurfaceType.Smooth
	instance.Parent = parent
	return instance
end

local function sign(parent, adornee, title, subtitle, tint, width)
	local board = Instance.new("BillboardGui")
	board.Name = "MarketSign"
	board.Adornee = adornee
	board.Size = UDim2.fromOffset(width or 260, 84)
	board.StudsOffset = Vector3.new(0, 3, 0)
	board.AlwaysOnTop = true
	board.MaxDistance = 180
	board.Parent = adornee
	local label = Instance.new("TextLabel")
	label.Size = UDim2.fromScale(1, 1)
	label.BackgroundColor3 = Color3.fromRGB(28, 43, 54)
	label.BackgroundTransparency = 0.12
	label.BorderSizePixel = 0
	label.Font = Enum.Font.GothamBlack
	label.Text = title .. "\n" .. subtitle
	label.TextColor3 = tint
	label.TextScaled = true
	label.TextStrokeTransparency = 0.8
	label.Parent = board
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 12)
	corner.Parent = label
end

local function makeLamp(parent, x, z, tint)
	local post = part(parent, "LampPost", Vector3.new(8, 0.7, 0.7), Vector3.new(x, 5, z), Color3.fromRGB(63, 91, 96), Enum.Material.Metal, Enum.PartType.Cylinder)
	post.CFrame *= CFrame.Angles(0, 0, math.rad(90))
	local lantern = part(parent, "MarketLantern", Vector3.new(2.3, 1, 2.3), Vector3.new(x, 9, z), tint, Enum.Material.Neon, Enum.PartType.Ball)
	local light = Instance.new("PointLight")
	light.Color = tint
	light.Brightness = 1.2
	light.Range = 18
	light.Parent = lantern
end

local function makeStall(parent, x, z, palette, labelText)
	local stall = Instance.new("Model")
	stall.Name = labelText:gsub(" ", "") .. "Stall"
	stall.Parent = parent
	part(stall, "Counter", Vector3.new(12, 3, 7), Vector3.new(x, 2.5, z), palette[1], Enum.Material.WoodPlanks)
	part(stall, "Awning", Vector3.new(13, 1, 8), Vector3.new(x, 6, z), palette[2], Enum.Material.Fabric)
	for _, dx in ipairs({ -5, 5 }) do
		part(stall, "CanopyPost", Vector3.new(0.55, 5, 0.55), Vector3.new(x + dx, 4, z), Color3.fromRGB(247, 231, 196), Enum.Material.Wood)
	end
	local signPart = part(stall, "StallName", Vector3.new(8, 1.2, 0.35), Vector3.new(x, 4.7, z - 4.2), palette[2], Enum.Material.SmoothPlastic)
	sign(stall, signPart, labelText, "fresh from the conveyor", Color3.fromRGB(255, 255, 255), 220)
end

local function makeRival(parent, baseId, at, tint, npcName)
	local rival = Instance.new("Model")
	rival.Name = baseId .. "Rival"
	rival.Parent = parent
	local torso = part(rival, "Torso", Vector3.new(2.1, 2.5, 1.15), at + Vector3.new(0, 1.3, 0), tint, Enum.Material.SmoothPlastic)
	part(rival, "Head", Vector3.new(1.8, 1.8, 1.8), at + Vector3.new(0, 2.8, 0), Color3.fromRGB(255, 215, 169), Enum.Material.SmoothPlastic, Enum.PartType.Ball)
	part(rival, "Apron", Vector3.new(2.15, 1.6, 0.16), at + Vector3.new(0, 1.3, -0.61), Color3.fromRGB(250, 239, 198), Enum.Material.Fabric)
	local leftArm = part(rival, "ArmLeft", Vector3.new(2.1, 0.65, 0.65), at + Vector3.new(-1.35, 1.35, 0), tint:Lerp(Color3.new(1, 1, 1), 0.18), Enum.Material.SmoothPlastic, Enum.PartType.Cylinder)
	leftArm.CFrame *= CFrame.Angles(0, 0, math.rad(90))
	local rightArm = part(rival, "ArmRight", Vector3.new(2.1, 0.65, 0.65), at + Vector3.new(1.35, 1.35, 0), tint:Lerp(Color3.new(1, 1, 1), 0.18), Enum.Material.SmoothPlastic, Enum.PartType.Cylinder)
	rightArm.CFrame *= CFrame.Angles(0, 0, math.rad(90))
	local nameTag = part(rival, "NameTagAnchor", Vector3.new(0.1, 0.1, 0.1), at + Vector3.new(0, 4.4, 0), tint)
	nameTag.Transparency = 1
	nameTag.CanCollide = false
	sign(rival, nameTag, npcName, "rival market keeper", Color3.fromRGB(255, 240, 154), 220)
	rival.PrimaryPart = torso
end

local function buildBase(root, index, spec)
	local model = Instance.new("Model")
	model.Name = spec.Id
	model.Parent = root
	local cx, cz = spec.Position.X, spec.Position.Z
	local tint = spec.Color
	local frontSign = part(model, "BaseSign", Vector3.new(12, 1.4, 0.45), Vector3.new(cx, FLOOR_Y + 7, cz + spec.Front * 17), tint, Enum.Material.Neon)
	sign(model, frontSign, spec.Name, spec.IsNpc and "NPC rival base" or "your brainrot market", Color3.fromRGB(255, 255, 255), 250)
	part(model, "BaseFloor", Vector3.new(48, 1.2, 38), Vector3.new(cx, FLOOR_Y + 0.1, cz), tint:Lerp(Color3.fromRGB(250, 248, 229), 0.65), Enum.Material.Sand)
	part(model, "BackWall", Vector3.new(48, 9, 1.5), Vector3.new(cx, FLOOR_Y + 4.6, cz - spec.Front * 18.2), tint, Enum.Material.WoodPlanks)
	for _, side in ipairs({ -1, 1 }) do
		part(model, "SideWall", Vector3.new(1.5, 7, 38), Vector3.new(cx + side * 23.2, FLOOR_Y + 3.7, cz), tint:Lerp(Color3.new(0, 0, 0), 0.12), Enum.Material.WoodPlanks)
		part(model, "WallTrim", Vector3.new(1.8, 0.5, 38), Vector3.new(cx + side * 23.2, FLOOR_Y + 7.5, cz), Color3.fromRGB(255, 225, 144), Enum.Material.Wood)
	end
	local gate = part(model, "BaseGate", Vector3.new(15, 7, 1.1), Vector3.new(cx, FLOOR_Y + 3.7, cz + spec.Front * 18), Color3.fromRGB(96, 188, 153), Enum.Material.Glass)
	gate.Transparency = 0.35
	gate.CanCollide = false
	local spawnPoint = part(model, "PlayerSpawn", Vector3.new(5, 0.3, 5), Vector3.new(cx, FLOOR_Y + 1.3, cz - spec.Front * 11), Color3.fromRGB(255, 255, 255), Enum.Material.Neon)
	spawnPoint.Transparency = 1
	spawnPoint.CanCollide = false
	local depositPart = part(model, "DepositDock", Vector3.new(0.8, 6, 6), Vector3.new(cx, FLOOR_Y + 0.95, cz + spec.Front * 11), Color3.fromRGB(62, 211, 148), Enum.Material.Neon, Enum.PartType.Cylinder)
	depositPart.CFrame *= CFrame.Angles(0, 0, math.rad(90))
	local depositLabel = part(model, "DockLabel", Vector3.new(7, 0.35, 0.35), depositPart.Position + Vector3.new(0, 1.2, 0), Color3.fromRGB(31, 119, 87), Enum.Material.SmoothPlastic)
	sign(model, depositLabel, "DROP ZONE", "bring your brainrot here", Color3.fromRGB(206, 255, 228), 210)
	local upgradePart = part(model, "UpgradeStand", Vector3.new(4, 3, 4), Vector3.new(cx + 17, FLOOR_Y + 2.5, cz - spec.Front * 8), Color3.fromRGB(255, 198, 71), Enum.Material.Neon)
	part(model, "UpgradeTop", Vector3.new(5, 0.6, 5), upgradePart.Position + Vector3.new(0, 1.8, 0), Color3.fromRGB(255, 232, 151), Enum.Material.SmoothPlastic)
	local slots = {}
	for row = 1, 2 do
		for column = 1, 3 do
			local xOffset = (column - 2) * 12
			local zOffset = spec.Front * (row == 1 and -4 or -12)
			local slot = Vector3.new(cx + xOffset, FLOOR_Y + 2.2, cz + zOffset)
			local pad = part(model, "DisplayPad" .. (#slots + 1), Vector3.new(0.45, 7.5, 7.5), Vector3.new(slot.X, FLOOR_Y + 0.95, slot.Z), Color3.fromRGB(255, 226, 154), Enum.Material.SmoothPlastic, Enum.PartType.Cylinder)
			pad.CFrame *= CFrame.Angles(0, 0, math.rad(90))
			pad.CanCollide = false
			table.insert(slots, slot)
		end
	end
	if spec.IsNpc then
		makeRival(model, spec.Id, Vector3.new(cx, FLOOR_Y + 0.7, cz - spec.Front * 10), tint, spec.Name)
	end
	local rivalModel = spec.IsNpc and model:FindFirstChild(spec.Id .. "Rival") or nil
	return {
		Id = spec.Id,
		Index = index,
		Name = spec.Name,
		IsNpc = spec.IsNpc,
		NpcName = spec.IsNpc and spec.Name or nil,
		Color = tint,
		Center = Vector3.new(cx, FLOOR_Y, cz),
		Front = spec.Front,
		SpawnCFrame = CFrame.lookAt(spawnPoint.Position + Vector3.new(0, 2, 0), Vector3.new(0, spawnPoint.Position.Y + 2, 0)),
		Gate = gate,
		DepositPart = depositPart,
		UpgradePart = upgradePart,
		SlotPositions = slots,
		Slots = {},
		Model = model,
		RivalModel = rivalModel,
		OwnerUserId = nil,
		LockedUntil = 0,
		DefenseLevel = 0,
	}
end

function WorldBuilder.Build()
	local previous = workspace:FindFirstChild("PasarWorld")
	if previous then
		previous:Destroy()
	end
	local root = Instance.new("Folder")
	root.Name = "PasarWorld"
	root.Parent = workspace
	part(root, "SunlitMarketFloor", Vector3.new(360, 2, 360), Vector3.new(0, 0, 0), Color3.fromRGB(242, 227, 176), Enum.Material.Sand)
	part(root, "CentralMarketLane", Vector3.new(170, 0.2, 38), Vector3.new(0, 1.1, 0), Color3.fromRGB(255, 248, 217), Enum.Material.SmoothPlastic)
	part(root, "ConveyorBelt", Vector3.new(145, 1.1, 15), Vector3.new(0, 2.1, 0), Color3.fromRGB(49, 75, 84), Enum.Material.Metal)
	part(root, "BeltSurface", Vector3.new(139, 0.25, 12), Vector3.new(0, 2.78, 0), Color3.fromRGB(60, 114, 117), Enum.Material.DiamondPlate)
	for x = -68, 68, 8 do
		part(root, "BeltStripe", Vector3.new(0.55, 0.08, 9), Vector3.new(x, 2.95, 0), Color3.fromRGB(255, 216, 113), Enum.Material.Neon)
	end
	local marquee = part(root, "MarketMarquee", Vector3.new(23, 3, 1), Vector3.new(0, 9, -13), Color3.fromRGB(78, 119, 112), Enum.Material.WoodPlanks)
	sign(root, marquee, "PASAR BRAINROT", "buy • carry • earn • rebirth", Color3.fromRGB(255, 229, 127), 350)
	makeStall(root, -49, -30, { Color3.fromRGB(227, 165, 104), Color3.fromRGB(91, 184, 162) }, "Pollen Pantry")
	makeStall(root, 49, -30, { Color3.fromRGB(207, 141, 112), Color3.fromRGB(184, 124, 219) }, "Mallow Corner")
	makeStall(root, -49, 30, { Color3.fromRGB(198, 154, 101), Color3.fromRGB(242, 172, 84) }, "Sprocket Shed")
	makeStall(root, 49, 30, { Color3.fromRGB(151, 136, 202), Color3.fromRGB(88, 164, 217) }, "Moonmelon Cart")
	for _, spot in ipairs({ { -84, -40 }, { 84, -40 }, { -84, 40 }, { 84, 40 }, { 0, -76 }, { 0, 76 } }) do
		makeLamp(root, spot[1], spot[2], Color3.fromRGB(255, 226, 129))
	end
	for x = -154, 154, 22 do
		part(root, "MarketTile", Vector3.new(10, 0.08, 5), Vector3.new(x, 1.08, 0), Color3.fromRGB(237, 191, 115), Enum.Material.SmoothPlastic)
	end

	local specs = {
		{ Id = "PlayerBase1", Name = "PLAYER 1", Position = Vector3.new(-112, 0, -100), Front = 1, Color = Color3.fromRGB(82, 177, 161) },
		{ Id = "PlayerBase2", Name = "PLAYER 2", Position = Vector3.new(112, 0, -100), Front = 1, Color = Color3.fromRGB(112, 156, 220) },
		{ Id = "PlayerBase3", Name = "PLAYER 3", Position = Vector3.new(-112, 0, 100), Front = -1, Color = Color3.fromRGB(224, 142, 133) },
		{ Id = "PlayerBase4", Name = "PLAYER 4", Position = Vector3.new(112, 0, 100), Front = -1, Color = Color3.fromRGB(207, 173, 86) },
		{ Id = "RivalBase1", Name = "Auntie Pollen", Position = Vector3.new(0, 0, -151), Front = 1, Color = Color3.fromRGB(206, 124, 108), IsNpc = true },
		{ Id = "RivalBase2", Name = "Uncle Moon", Position = Vector3.new(0, 0, 151), Front = -1, Color = Color3.fromRGB(125, 124, 207), IsNpc = true },
	}
	local bases = {}
	for index, spec in ipairs(specs) do
		table.insert(bases, buildBase(root, index, spec))
	end

	local conveyorPads = {}
	for index, x in ipairs({ -52, -26, 0, 26, 52 }) do
		local pad = part(root, "ConveyorDisplay" .. index, Vector3.new(0.55, 11, 11), Vector3.new(x, 3.18, 0), Color3.fromRGB(255, 237, 177), Enum.Material.SmoothPlastic, Enum.PartType.Cylinder)
		pad.CFrame *= CFrame.Angles(0, 0, math.rad(90))
		pad.CanCollide = false
		table.insert(conveyorPads, { Part = pad, Position = Vector3.new(x, 4.55, 0) })
	end
	return { Root = root, Bases = bases, ConveyorPads = conveyorPads }
end

return WorldBuilder
