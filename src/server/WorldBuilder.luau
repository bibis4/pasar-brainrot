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

local function signSurface(board, title, subtitle, face, background, textColor, name)
	local surface = Instance.new("SurfaceGui")
	surface.Name = name or "MarketSign"
	surface.Adornee = board
	surface.Face = face
	surface.SizingMode = Enum.SurfaceGuiSizingMode.PixelsPerStud
	surface.PixelsPerStud = 40
	surface.AlwaysOnTop = true
	surface.LightInfluence = 0
	surface.Parent = board

	local label = Instance.new("TextLabel")
	label.Name = "SignText"
	label.Size = UDim2.fromScale(1, 1)
	label.BackgroundColor3 = background
	label.BackgroundTransparency = 0.06
	label.BorderSizePixel = 0
	label.Font = Enum.Font.GothamBlack
	label.Text = title .. "\n" .. subtitle
	label.TextColor3 = textColor
	label.TextScaled = true
	label.TextWrapped = true
	label.TextStrokeColor3 = Color3.fromRGB(32, 43, 48)
	label.TextStrokeTransparency = 0.72
	label.Parent = surface
	local sizeLimit = Instance.new("UITextSizeConstraint")
	sizeLimit.MinTextSize = 12
	sizeLimit.MaxTextSize = 38
	sizeLimit.Parent = label
	return surface
end

local function facingSurface(front)
	return front == 1 and Enum.NormalId.Back or Enum.NormalId.Front
end

local function makeLamp(parent, x, z, tint)
	part(parent, "LampPost", Vector3.new(0.75, 9, 0.75), Vector3.new(x, 5.5, z), Color3.fromRGB(75, 92, 83), Enum.Material.Metal, Enum.PartType.Cylinder)
	part(parent, "LampCap", Vector3.new(1.8, 0.45, 1.8), Vector3.new(x, 10.1, z), Color3.fromRGB(77, 85, 75), Enum.Material.Metal)
	local lantern = part(parent, "MarketLantern", Vector3.new(1.65, 1.65, 1.65), Vector3.new(x, 9.15, z), tint, Enum.Material.Neon, Enum.PartType.Ball)
	local light = Instance.new("PointLight")
	light.Color = tint
	light.Brightness = 1.05
	light.Range = 17
	light.Parent = lantern
end

local function makeStall(parent, index, x, side, palette, title)
	local z = side * 19
	local stall = Instance.new("Model")
	stall.Name = "MarketStall" .. index
	stall.Parent = parent

	part(stall, "Counter", Vector3.new(14, 2.4, 6), Vector3.new(x, 2.2, z), palette[1], Enum.Material.WoodPlanks)
	part(stall, "CounterTop", Vector3.new(14.6, 0.35, 6.6), Vector3.new(x, 3.55, z), Color3.fromRGB(246, 226, 183), Enum.Material.Wood)
	part(stall, "Awning", Vector3.new(15.5, 0.85, 8.5), Vector3.new(x, 6.25, z), palette[2], Enum.Material.Fabric)
	for _, dx in ipairs({ -6.7, 6.7 }) do
		for _, dz in ipairs({ -3.55, 3.55 }) do
			part(stall, "AwningPost", Vector3.new(0.55, 5.4, 0.55), Vector3.new(x + dx, 3.85, z + dz), Color3.fromRGB(247, 232, 196), Enum.Material.Wood)
		end
	end
	for stripe = -2, 2 do
		part(stall, "CanopyStripe", Vector3.new(2.7, 0.12, 8.3), Vector3.new(x + stripe * 3, 6.74, z), stripe % 2 == 0 and palette[1] or palette[2], Enum.Material.Fabric)
	end
	local signZ = z - side * 4.45
	local signPart = part(stall, "StallName", Vector3.new(9.5, 1.8, 0.55), Vector3.new(x, 5.05, signZ), palette[2], Enum.Material.Wood)
	signSurface(signPart, title, "FRESH PICKS", side == -1 and Enum.NormalId.Back or Enum.NormalId.Front, palette[1], Color3.fromRGB(255, 250, 228), "StallSign")
	part(stall, "CounterFoot", Vector3.new(12, 0.32, 5.5), Vector3.new(x, 1.23, z), Color3.fromRGB(103, 75, 58), Enum.Material.Wood)
end

local function makeRival(parent, baseId, at, tint, npcName, front)
	local rival = Instance.new("Model")
	rival.Name = baseId .. "Rival"
	rival.Parent = parent
	local torso = part(rival, "Torso", Vector3.new(2.5, 2.8, 1.35), at + Vector3.new(0, 1.55, 0), tint, Enum.Material.SmoothPlastic)
	local head = part(rival, "Head", Vector3.new(2.1, 2.1, 2.1), at + Vector3.new(0, 3.65, 0), Color3.fromRGB(255, 218, 176), Enum.Material.SmoothPlastic, Enum.PartType.Ball)
	part(rival, "Apron", Vector3.new(2.45, 1.8, 0.18), at + Vector3.new(0, 1.55, -0.73), Color3.fromRGB(250, 239, 198), Enum.Material.Fabric)
	for _, side in ipairs({ -1, 1 }) do
		local arm = part(rival, side < 0 and "ArmLeft" or "ArmRight", Vector3.new(0.72, 2.45, 0.72), at + Vector3.new(side * 1.55, 1.6, 0), tint:Lerp(Color3.new(1, 1, 1), 0.18), Enum.Material.SmoothPlastic, Enum.PartType.Cylinder)
		arm.CFrame *= CFrame.Angles(0, 0, math.rad(90))
		part(rival, side < 0 and "EyeLeft" or "EyeRight", Vector3.new(0.43, 0.5, 0.18), at + Vector3.new(side * 0.45, 3.75, -0.94), Color3.fromRGB(255, 255, 245), Enum.Material.SmoothPlastic, Enum.PartType.Ball)
		part(rival, side < 0 and "PupilLeft" or "PupilRight", Vector3.new(0.18, 0.24, 0.1), at + Vector3.new(side * 0.45, 3.73, -1.08), Color3.fromRGB(42, 49, 54), Enum.Material.SmoothPlastic, Enum.PartType.Ball)
	end
	part(rival, "Smile", Vector3.new(0.42, 0.12, 0.12), at + Vector3.new(0, 3.18, -1.02), Color3.fromRGB(151, 73, 74), Enum.Material.SmoothPlastic)
	rival.PrimaryPart = torso
	rival:PivotTo(CFrame.lookAt(torso.Position, torso.Position + Vector3.new(0, 0, front)))
	return rival, head, npcName
end

local function buildBase(root, index, spec)
	local model = Instance.new("Model")
	model.Name = spec.Id
	model.Parent = root
	local cx, cz = spec.Position.X, spec.Position.Z
	local tint = spec.Color
	local paleTint = tint:Lerp(Color3.fromRGB(255, 245, 218), 0.52)
	local roofZ = cz - spec.Front * 7.5

	part(model, "BaseFloor", Vector3.new(50, 0.9, 44), Vector3.new(cx, FLOOR_Y + 0.55, cz), paleTint, Enum.Material.Sand)
	part(model, "BackWall", Vector3.new(50, 8.4, 1.5), Vector3.new(cx, FLOOR_Y + 4.7, cz - spec.Front * 21), tint, Enum.Material.WoodPlanks)
	for _, side in ipairs({ -1, 1 }) do
		part(model, "SideWall", Vector3.new(1.5, 6.2, 36), Vector3.new(cx + side * 24.2, FLOOR_Y + 3.6, cz - spec.Front * 1.5), tint:Lerp(Color3.new(0, 0, 0), 0.12), Enum.Material.WoodPlanks)
		part(model, "WallTrim", Vector3.new(1.9, 0.45, 36), Vector3.new(cx + side * 24.2, FLOOR_Y + 6.95, cz - spec.Front * 1.5), Color3.fromRGB(255, 224, 153), Enum.Material.Wood)
		part(model, "RoofSupport", Vector3.new(0.85, 8.2, 0.85), Vector3.new(cx + side * 23, FLOOR_Y + 4.6, roofZ), tint, Enum.Material.Wood)
	end
	part(model, "BaseRoof", Vector3.new(53, 0.9, 23), Vector3.new(cx, FLOOR_Y + 9.1, roofZ), tint, Enum.Material.WoodPlanks)
	part(model, "RoofFascia", Vector3.new(53, 0.75, 1.1), Vector3.new(cx, FLOOR_Y + 8.55, cz + spec.Front * 4.1), tint:Lerp(Color3.new(1, 1, 1), 0.22), Enum.Material.Wood)
	for stripe = -4, 4 do
		part(model, "RoofColorStripe", Vector3.new(3.2, 0.12, 22), Vector3.new(cx + stripe * 5.7, FLOOR_Y + 9.62, roofZ), stripe % 2 == 0 and paleTint or tint:Lerp(Color3.new(1, 1, 1), 0.28), Enum.Material.SmoothPlastic)
	end

	local frontSign = part(model, "BaseSign", Vector3.new(26, 2.6, 0.75), Vector3.new(cx, FLOOR_Y + 9.1, cz + spec.Front * 4.5), tint, Enum.Material.Wood)
	signSurface(frontSign, spec.Name, spec.IsNpc and "RIVAL MARKET" or "YOUR BRAINROT BASE", facingSurface(spec.Front), Color3.fromRGB(35, 54, 58), Color3.fromRGB(255, 242, 196))
	local gate = part(model, "BaseGate", Vector3.new(16, 7.2, 1.1), Vector3.new(cx, FLOOR_Y + 4.15, cz + spec.Front * 21.5), Color3.fromRGB(96, 188, 153), Enum.Material.Glass)
	gate.Transparency = 0.38
	gate.CanCollide = false
	local spawnPoint = part(model, "PlayerSpawn", Vector3.new(5, 0.3, 5), Vector3.new(cx, FLOOR_Y + 1.3, cz - spec.Front * 11), Color3.fromRGB(255, 255, 255), Enum.Material.Neon)
	spawnPoint.Transparency = 1
	spawnPoint.CanCollide = false

	local depositPart = part(model, "DepositDock", Vector3.new(7, 0.8, 7), Vector3.new(cx, FLOOR_Y + 1.45, cz + spec.Front * 11), Color3.fromRGB(62, 211, 148), Enum.Material.Neon, Enum.PartType.Cylinder)
	depositPart.CanCollide = true
	for _, angle in ipairs({ 0, 90 }) do
		local ring = part(model, "DockRing", Vector3.new(7.8, 0.15, 7.8), Vector3.new(cx, FLOOR_Y + 1.08, cz + spec.Front * 11), Color3.fromRGB(45, 153, 117), Enum.Material.Metal, Enum.PartType.Cylinder)
		ring.Orientation = Vector3.new(0, angle, 0)
	end
	local dockLabel = part(model, "DockLabel", Vector3.new(9, 1.4, 0.5), Vector3.new(cx, FLOOR_Y + 3.5, cz + spec.Front * 7.7), Color3.fromRGB(43, 126, 91), Enum.Material.Wood)
	signSurface(dockLabel, "DROP ZONE", "DELIVER TO EARN", facingSurface(spec.Front), Color3.fromRGB(35, 81, 65), Color3.fromRGB(220, 255, 232), "DockSign")
	local upgradePart = part(model, "UpgradeStand", Vector3.new(4.5, 3, 4.5), Vector3.new(cx + 18, FLOOR_Y + 2.5, cz - spec.Front * 8), Color3.fromRGB(255, 198, 71), Enum.Material.Neon)
	part(model, "UpgradeTop", Vector3.new(5.5, 0.6, 5.5), upgradePart.Position + Vector3.new(0, 1.8, 0), Color3.fromRGB(255, 232, 151), Enum.Material.SmoothPlastic)

	local slots = {}
	for row = 1, 2 do
		for column = 1, 3 do
			local xOffset = (column - 2) * 12
			local zOffset = spec.Front * (row == 1 and -4 or -12)
			local slot = Vector3.new(cx + xOffset, FLOOR_Y + 2.9, cz + zOffset)
			local pad = part(model, "DisplayPad" .. (#slots + 1), Vector3.new(8.3, 0.45, 8.3), Vector3.new(slot.X, FLOOR_Y + 1.45, slot.Z), Color3.fromRGB(255, 226, 154), Enum.Material.SmoothPlastic, Enum.PartType.Cylinder)
			pad.CanCollide = false
			part(model, "DisplayTrim", Vector3.new(8.7, 0.12, 8.7), Vector3.new(slot.X, FLOOR_Y + 1.15, slot.Z), Color3.fromRGB(186, 142, 86), Enum.Material.Wood, Enum.PartType.Cylinder)
			table.insert(slots, slot)
		end
	end

	local rivalModel = nil
	if spec.IsNpc then
		local rivalAt = Vector3.new(cx + 18, FLOOR_Y + 0.8, cz - spec.Front * 12)
		rivalModel = makeRival(model, spec.Id, rivalAt, tint, spec.Name, spec.Front)
	end
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

local function makeTree(parent, x, z, leafColor)
	part(parent, "TreeTrunk", Vector3.new(1.5, 7, 1.5), Vector3.new(x, 4.5, z), Color3.fromRGB(125, 86, 58), Enum.Material.Wood, Enum.PartType.Cylinder)
	for _, offset in ipairs({ Vector3.new(0, 8, 0), Vector3.new(-1.5, 7.4, 0.4), Vector3.new(1.4, 7.5, -0.5) }) do
		part(parent, "TreeCanopy", Vector3.new(4.4, 4.2, 4.4), Vector3.new(x + offset.X, 1 + offset.Y, z + offset.Z), leafColor, Enum.Material.Grass, Enum.PartType.Ball)
	end
	part(parent, "TreePlanter", Vector3.new(4.2, 0.65, 4.2), Vector3.new(x, 1.35, z), Color3.fromRGB(179, 125, 83), Enum.Material.Wood, Enum.PartType.Cylinder)
end

local function makeCrate(parent, x, z, tint)
	part(parent, "MarketCrate", Vector3.new(3.4, 2.8, 3.2), Vector3.new(x, 2.5, z), tint, Enum.Material.WoodPlanks)
	part(parent, "CrateLid", Vector3.new(3.65, 0.35, 3.45), Vector3.new(x, 4.05, z), Color3.fromRGB(218, 178, 120), Enum.Material.Wood)
	part(parent, "CrateBand", Vector3.new(0.32, 2.9, 3.3), Vector3.new(x, 2.5, z), Color3.fromRGB(113, 83, 59), Enum.Material.Wood)
end

local function makeBarrel(parent, x, z, tint)
	part(parent, "MarketBarrel", Vector3.new(2.7, 3.3, 2.7), Vector3.new(x, 2.65, z), tint, Enum.Material.WoodPlanks, Enum.PartType.Cylinder)
	for _, y in ipairs({ 1.8, 3.4 }) do
		part(parent, "BarrelHoop", Vector3.new(2.9, 0.22, 2.9), Vector3.new(x, y, z), Color3.fromRGB(92, 76, 64), Enum.Material.Metal, Enum.PartType.Cylinder)
	end
end

local function makePlanter(parent, x, z, leafColor)
	part(parent, "FlowerPot", Vector3.new(2.5, 1.9, 2.5), Vector3.new(x, 1.95, z), Color3.fromRGB(192, 116, 87), Enum.Material.SmoothPlastic, Enum.PartType.Cylinder)
	part(parent, "PotRim", Vector3.new(2.9, 0.35, 2.9), Vector3.new(x, 2.9, z), Color3.fromRGB(228, 166, 117), Enum.Material.SmoothPlastic, Enum.PartType.Cylinder)
	for _, offset in ipairs({ Vector3.new(0, 3.9, 0), Vector3.new(-0.75, 3.55, 0.1), Vector3.new(0.75, 3.55, -0.1) }) do
		part(parent, "PlanterLeaves", Vector3.new(1.35, 1.65, 1.35), Vector3.new(x + offset.X, offset.Y, z + offset.Z), leafColor, Enum.Material.Grass, Enum.PartType.Ball)
	end
end

local function makeEntrance(root)
	local gate = Instance.new("Model")
	gate.Name = "MarketEntrance"
	gate.Parent = root
	local z = -75
	for _, x in ipairs({ -23, 23 }) do
		part(gate, "GatePillar", Vector3.new(2.8, 12, 3.2), Vector3.new(x, 7, z), Color3.fromRGB(112, 83, 59), Enum.Material.WoodPlanks)
		part(gate, "GateBase", Vector3.new(4, 1, 4.2), Vector3.new(x, 1.55, z), Color3.fromRGB(224, 177, 104), Enum.Material.Wood)
		part(gate, "GateLantern", Vector3.new(2.3, 2.3, 2.3), Vector3.new(x, 13, z), Color3.fromRGB(255, 214, 102), Enum.Material.Neon, Enum.PartType.Ball)
	end
	part(gate, "GateHeader", Vector3.new(49, 2.6, 3.6), Vector3.new(0, 13, z), Color3.fromRGB(89, 131, 105), Enum.Material.WoodPlanks)
	local signBoard = part(gate, "EntranceSign", Vector3.new(37, 5.4, 1.25), Vector3.new(0, 10.35, z - 1.8), Color3.fromRGB(43, 75, 69), Enum.Material.Wood)
	signSurface(signBoard, "PASAR BRAINROT", "BUY  •  CARRY  •  EARN  •  REBIRTH", Enum.NormalId.Front, Color3.fromRGB(43, 75, 69), Color3.fromRGB(255, 229, 132), "EntranceSignFront")
	signSurface(signBoard, "PASAR BRAINROT", "BUY  •  CARRY  •  EARN  •  REBIRTH", Enum.NormalId.Back, Color3.fromRGB(43, 75, 69), Color3.fromRGB(255, 229, 132), "EntranceSignBack")
	for _, x in ipairs({ -13, 0, 13 }) do
		part(gate, "HeaderTrim", Vector3.new(0.34, 1.9, 0.18), Vector3.new(x, 13, z - 1.93), Color3.fromRGB(255, 210, 117), Enum.Material.Metal)
	end
end

local function makeBunting(root)
	local colors = {
		Color3.fromRGB(244, 128, 111),
		Color3.fromRGB(255, 211, 100),
		Color3.fromRGB(103, 194, 160),
		Color3.fromRGB(112, 170, 225),
		Color3.fromRGB(194, 137, 219),
	}
	for _, side in ipairs({ -1, 1 }) do
		local z = side * 27
		part(root, "BuntingLine", Vector3.new(137, 0.12, 0.12), Vector3.new(0, 11.4, z), Color3.fromRGB(107, 84, 69), Enum.Material.Fabric)
		for index, x in ipairs({ -63, -45, -27, -9, 9, 27, 45, 63 }) do
			local flag = part(root, "MarketFlag", Vector3.new(3.2, 2.2, 0.22), Vector3.new(x, 10.15, z), colors[(index - 1) % #colors + 1], Enum.Material.Fabric, Enum.PartType.Wedge)
			if side == 1 then
				flag.Orientation = Vector3.new(0, 180, 0)
			end
		end
	end
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
	part(root, "CentralMarketLane", Vector3.new(190, 0.22, 78), Vector3.new(0, 1.12, 0), Color3.fromRGB(255, 248, 217), Enum.Material.SmoothPlastic)
	for x = -88, 88, 22 do
		part(root, "MarketTile", Vector3.new(10, 0.08, 6), Vector3.new(x, 1.28, 0), Color3.fromRGB(237, 191, 115), Enum.Material.SmoothPlastic)
	end

	part(root, "ConveyorFrame", Vector3.new(151, 1.55, 17), Vector3.new(0, 2.33, 0), Color3.fromRGB(48, 70, 76), Enum.Material.Metal)
	part(root, "ConveyorBelt", Vector3.new(146, 0.42, 13.2), Vector3.new(0, 3.28, 0), Color3.fromRGB(54, 107, 109), Enum.Material.DiamondPlate)
	for _, side in ipairs({ -1, 1 }) do
		part(root, "ConveyorRail", Vector3.new(147, 1.1, 0.9), Vector3.new(0, 4.02, side * 7.15), Color3.fromRGB(92, 126, 120), Enum.Material.Metal)
		part(root, "RailCap", Vector3.new(147, 0.18, 1.15), Vector3.new(0, 4.64, side * 7.15), Color3.fromRGB(255, 209, 105), Enum.Material.Metal)
	end
	for x = -68, 68, 8 do
		part(root, "BeltStripe", Vector3.new(0.55, 0.09, 11), Vector3.new(x, 3.55, 0), Color3.fromRGB(255, 216, 113), Enum.Material.Neon)
	end
	for _, x in ipairs({ -58, -29, 0, 29, 58 }) do
		for _, side in ipairs({ -1, 1 }) do
			part(root, "ConveyorSupport", Vector3.new(1.35, 1.7, 1.35), Vector3.new(x, 1.95, side * 6.25), Color3.fromRGB(82, 91, 82), Enum.Material.Metal)
		end
		part(root, "SupportFoot", Vector3.new(3.1, 0.35, 16), Vector3.new(x, 1.2, 0), Color3.fromRGB(109, 99, 78), Enum.Material.Metal)
	end

	local stallPalettes = {
		{ Color3.fromRGB(212, 143, 95), Color3.fromRGB(96, 185, 155) },
		{ Color3.fromRGB(194, 127, 112), Color3.fromRGB(184, 124, 219) },
		{ Color3.fromRGB(198, 154, 101), Color3.fromRGB(244, 177, 82) },
		{ Color3.fromRGB(151, 136, 202), Color3.fromRGB(88, 164, 217) },
		{ Color3.fromRGB(169, 133, 96), Color3.fromRGB(238, 126, 121) },
		{ Color3.fromRGB(114, 164, 147), Color3.fromRGB(255, 200, 102) },
		{ Color3.fromRGB(180, 130, 103), Color3.fromRGB(120, 174, 225) },
	}
	local stallNames = { "POLLEN PANTRY", "MALLOW CORNER", "SPROCKET SHED", "MOONMELON CART", "BELL & BASKET", "SUNRISE GOODS", "TURNIP TRADERS" }
	for index, x in ipairs({ -60, -40, -20, 0, 20, 40, 60 }) do
		local palette = stallPalettes[index]
		makeStall(root, index, x, -1, palette, stallNames[index])
		makeStall(root, index + 7, x, 1, { palette[2], palette[1] }, stallNames[8 - index])
	end

	makeEntrance(root)
	makeBunting(root)
	for _, spot in ipairs({ { -84, -48 }, { 84, -48 }, { -84, 48 }, { 84, 48 }, { -78, 0 }, { 78, 0 }, { 0, 66 }, { 0, -62 } }) do
		makeLamp(root, spot[1], spot[2], Color3.fromRGB(255, 226, 129))
	end
	makeCrate(root, -79, -17, Color3.fromRGB(183, 128, 84))
	makeCrate(root, 79, 17, Color3.fromRGB(179, 132, 85))
	makeBarrel(root, -80, 18, Color3.fromRGB(157, 111, 78))
	makeBarrel(root, 80, -18, Color3.fromRGB(160, 116, 84))
	makePlanter(root, -82, 4, Color3.fromRGB(93, 177, 106))
	makePlanter(root, 82, -4, Color3.fromRGB(113, 188, 103))
	makeTree(root, -88, -78, Color3.fromRGB(83, 166, 103))
	makeTree(root, 88, 78, Color3.fromRGB(89, 173, 111))
	makeTree(root, -88, 78, Color3.fromRGB(105, 177, 103))
	makeTree(root, 88, -78, Color3.fromRGB(99, 168, 96))

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
		local pad = part(root, "ConveyorDisplay" .. index, Vector3.new(11, 0.55, 11), Vector3.new(x, 3.83, 0), Color3.fromRGB(255, 237, 177), Enum.Material.SmoothPlastic, Enum.PartType.Cylinder)
		pad.CanCollide = false
		table.insert(conveyorPads, { Part = pad, Position = Vector3.new(x, 5.15, 0) })
	end
	return { Root = root, Bases = bases, ConveyorPads = conveyorPads }
end

return WorldBuilder
