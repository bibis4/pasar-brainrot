local Catalog = {}

local MODEL_SCALE = 1.22

Catalog.Rarities = {
	Common = { Color = Color3.fromRGB(194, 205, 184), Weight = 48, Multiplier = 1 },
	Rare = { Color = Color3.fromRGB(75, 174, 235), Weight = 27, Multiplier = 1.7 },
	Epic = { Color = Color3.fromRGB(180, 104, 231), Weight = 15, Multiplier = 3 },
	Legendary = { Color = Color3.fromRGB(255, 169, 55), Weight = 8, Multiplier = 6 },
	Mythic = { Color = Color3.fromRGB(255, 83, 137), Weight = 2, Multiplier = 12 },
}

Catalog.Mutations = {
	Gold = { Multiplier = 1.5, Color = Color3.fromRGB(255, 211, 61) },
	Diamond = { Multiplier = 2.25, Color = Color3.fromRGB(111, 245, 255) },
	Rainbow = { Multiplier = 3.5, Color = Color3.fromRGB(255, 112, 209) },
}

Catalog.Items = {
	{ Name = "Puddleplop", Rarity = "Common", Income = 3, Cost = 60, Form = "Blob", Color = Color3.fromRGB(84, 205, 192) },
	{ Name = "Kettlekin", Rarity = "Common", Income = 4, Cost = 85, Form = "Kettle", Color = Color3.fromRGB(243, 146, 105) },
	{ Name = "Crumbug", Rarity = "Common", Income = 5, Cost = 110, Form = "Crate", Color = Color3.fromRGB(205, 163, 104) },
	{ Name = "Turnip Tumbler", Rarity = "Rare", Income = 9, Cost = 260, Form = "Turnip", Color = Color3.fromRGB(185, 119, 220) },
	{ Name = "Mallow Mite", Rarity = "Rare", Income = 12, Cost = 340, Form = "Mallow", Color = Color3.fromRGB(255, 153, 188) },
	{ Name = "Saffron Sprocket", Rarity = "Epic", Income = 25, Cost = 900, Form = "Sprocket", Color = Color3.fromRGB(250, 192, 73) },
	{ Name = "Belltower Bloop", Rarity = "Epic", Income = 32, Cost = 1250, Form = "Belltower", Color = Color3.fromRGB(98, 164, 234) },
	{ Name = "Lantern Llama", Rarity = "Legendary", Income = 75, Cost = 4200, Form = "Lantern", Color = Color3.fromRGB(255, 135, 76) },
	{ Name = "Moonmelon Manta", Rarity = "Legendary", Income = 110, Cost = 6500, Form = "Manta", Color = Color3.fromRGB(131, 119, 255) },
	{ Name = "Solar Chestnut", Rarity = "Mythic", Income = 260, Cost = 18000, Form = "Chestnut", Color = Color3.fromRGB(242, 108, 57) },
}

local function makePart(parent, name, size, color, shape, offset, material)
	local part = Instance.new("Part")
	part.Name = name
	part.Size = size * MODEL_SCALE
	part.Color = color
	part.Shape = shape or Enum.PartType.Block
	part.Material = material or Enum.Material.SmoothPlastic
	part.Anchored = true
	part.CanCollide = false
	part.TopSurface = Enum.SurfaceType.Smooth
	part.BottomSurface = Enum.SurfaceType.Smooth
	part.CFrame = CFrame.new(offset * MODEL_SCALE)
	part.Parent = parent
	return part
end

local function addFace(model)
	for _, side in ipairs({ -1, 1 }) do
		makePart(model, side < 0 and "EyeWhiteLeft" or "EyeWhiteRight", Vector3.new(0.53, 0.62, 0.28), Color3.fromRGB(255, 255, 246), Enum.PartType.Ball, Vector3.new(side * 0.46, 1.65, -0.96))
		makePart(model, side < 0 and "EyePupilLeft" or "EyePupilRight", Vector3.new(0.22, 0.29, 0.14), Color3.fromRGB(44, 52, 58), Enum.PartType.Ball, Vector3.new(side * 0.46, 1.63, -1.13))
		makePart(model, side < 0 and "EyeShineLeft" or "EyeShineRight", Vector3.new(0.09, 0.11, 0.07), Color3.fromRGB(255, 255, 255), Enum.PartType.Ball, Vector3.new(side * 0.46 - 0.035, 1.7, -1.21))
	end
	makePart(model, "Smile", Vector3.new(0.35, 0.12, 0.1), Color3.fromRGB(146, 71, 77), Enum.PartType.Ball, Vector3.new(0, 1.18, -1.04))
	if model.Name:find("Puddleplop") then
		for _, side in ipairs({ -1, 1 }) do
			makePart(model, side < 0 and "CheekLeft" or "CheekRight", Vector3.new(0.32, 0.2, 0.1), Color3.fromRGB(255, 139, 167), Enum.PartType.Ball, Vector3.new(side * 0.82, 1.25, -0.85))
		end
	end
end

function Catalog.GetByName(name)
	for _, item in ipairs(Catalog.Items) do
		if item.Name == name then
			return item
		end
	end
	return nil
end

function Catalog.GetIncome(item, mutation)
	local rarity = Catalog.Rarities[item.Rarity]
	local mutationData = mutation and Catalog.Mutations[mutation]
	return math.floor(item.Income * rarity.Multiplier * (mutationData and mutationData.Multiplier or 1) + 0.5)
end

function Catalog.Roll(rng, rebirthTier)
	local eligible = {}
	local totalWeight = 0
	for _, item in ipairs(Catalog.Items) do
		local rarity = Catalog.Rarities[item.Rarity]
		local tierBoost = item.Rarity == "Legendary" and rebirthTier >= 1 or item.Rarity == "Mythic" and rebirthTier >= 2
		local weight = rarity.Weight * (tierBoost and 2.5 or 1)
		table.insert(eligible, { Item = item, Weight = weight })
		totalWeight += weight
	end
	local roll = rng:NextNumber(0, totalWeight)
	for _, entry in ipairs(eligible) do
		roll -= entry.Weight
		if roll <= 0 then
			local mutationRoll = rng:NextNumber()
			local mutation = nil
			if mutationRoll < 0.012 then
				mutation = "Rainbow"
			elseif mutationRoll < 0.042 then
				mutation = "Diamond"
			elseif mutationRoll < 0.10 then
				mutation = "Gold"
			end
			return entry.Item, mutation
		end
	end
	return Catalog.Items[1], nil
end

function Catalog.CreateModel(item, mutation, parent)
	local model = Instance.new("Model")
	model.Name = item.Name .. (mutation and (" - " .. mutation) or "")
	local accent = item.Color
	if mutation and Catalog.Mutations[mutation] then
		accent = Catalog.Mutations[mutation].Color
	end
	local body
	if item.Form == "Kettle" then
		body = makePart(model, "Body", Vector3.new(2.2, 2.1, 2.2), accent, Enum.PartType.Cylinder, Vector3.new(0, 1.45, 0))
		body.CFrame *= CFrame.Angles(0, 0, math.rad(90))
		makePart(model, "Lid", Vector3.new(1.35, 0.35, 1.35), accent:Lerp(Color3.new(1, 1, 1), 0.35), Enum.PartType.Cylinder, Vector3.new(0, 2.65, 0))
		makePart(model, "Spout", Vector3.new(1.1, 0.5, 0.5), accent, Enum.PartType.Wedge, Vector3.new(1.2, 1.85, 0))
		makePart(model, "Handle", Vector3.new(0.35, 1.5, 1.4), Color3.fromRGB(99, 73, 67), Enum.PartType.Block, Vector3.new(-1.15, 1.55, 0))
	elseif item.Form == "Crate" then
		body = makePart(model, "Body", Vector3.new(2.25, 1.8, 1.8), accent, Enum.PartType.Block, Vector3.new(0, 1.25, 0))
		makePart(model, "Strap", Vector3.new(0.28, 1.9, 1.88), Color3.fromRGB(255, 221, 146), Enum.PartType.Block, Vector3.new(0, 1.25, 0))
		makePart(model, "TopKnot", Vector3.new(0.9, 0.45, 0.9), Color3.fromRGB(244, 202, 100), Enum.PartType.Ball, Vector3.new(0, 2.35, 0))
	elseif item.Form == "Turnip" then
		body = makePart(model, "Body", Vector3.new(2, 2.3, 2), accent, Enum.PartType.Ball, Vector3.new(0, 1.35, 0))
		makePart(model, "LeafLeft", Vector3.new(0.45, 1.15, 0.35), Color3.fromRGB(96, 190, 111), Enum.PartType.Wedge, Vector3.new(-0.45, 2.65, 0))
		makePart(model, "LeafRight", Vector3.new(0.45, 1.05, 0.35), Color3.fromRGB(120, 211, 118), Enum.PartType.Wedge, Vector3.new(0.45, 2.65, 0))
	elseif item.Form == "Mallow" then
		body = makePart(model, "Body", Vector3.new(2.2, 1.8, 2), accent, Enum.PartType.Ball, Vector3.new(0, 1.25, 0))
		makePart(model, "EarLeft", Vector3.new(0.55, 1, 0.55), accent:Lerp(Color3.new(1, 1, 1), 0.15), Enum.PartType.Ball, Vector3.new(-0.65, 2.45, 0))
		makePart(model, "EarRight", Vector3.new(0.55, 1, 0.55), accent:Lerp(Color3.new(1, 1, 1), 0.15), Enum.PartType.Ball, Vector3.new(0.65, 2.45, 0))
	elseif item.Form == "Sprocket" then
		body = makePart(model, "Body", Vector3.new(0.75, 2.35, 2.35), accent, Enum.PartType.Cylinder, Vector3.new(0, 1.25, 0))
		body.CFrame *= CFrame.Angles(0, 0, math.rad(90))
		local hub = makePart(model, "Hub", Vector3.new(1.05, 1.05, 1.05), Color3.fromRGB(255, 226, 132), Enum.PartType.Cylinder, Vector3.new(0, 1.25, 0))
		hub.CFrame *= CFrame.Angles(0, 0, math.rad(90))
		for index = 1, 6 do
			local angle = math.pi * 2 * (index - 1) / 6
			makePart(model, "Tooth" .. index, Vector3.new(0.55, 0.42, 0.55), accent, Enum.PartType.Block, Vector3.new(math.cos(angle) * 1.15, 1.25, math.sin(angle) * 1.15))
		end
	elseif item.Form == "Belltower" then
		body = makePart(model, "Body", Vector3.new(2.25, 1.55, 1.55), accent, Enum.PartType.Cylinder, Vector3.new(0, 1.55, 0))
		body.CFrame *= CFrame.Angles(0, 0, math.rad(90))
		makePart(model, "Roof", Vector3.new(2.1, 0.9, 2.1), Color3.fromRGB(255, 217, 112), Enum.PartType.Wedge, Vector3.new(0, 3, 0))
		makePart(model, "Bell", Vector3.new(0.8, 0.75, 0.8), Color3.fromRGB(255, 232, 165), Enum.PartType.Ball, Vector3.new(0, 0.55, 0))
	elseif item.Form == "Lantern" then
		body = makePart(model, "Body", Vector3.new(1.6, 1.6, 1.6), accent, Enum.PartType.Ball, Vector3.new(0, 1.65, 0), Enum.Material.Neon)
		makePart(model, "FrameTop", Vector3.new(2, 0.2, 2), Color3.fromRGB(108, 75, 57), Enum.PartType.Block, Vector3.new(0, 2.65, 0))
		makePart(model, "FrameBottom", Vector3.new(2, 0.2, 2), Color3.fromRGB(108, 75, 57), Enum.PartType.Block, Vector3.new(0, 0.75, 0))
		for _, x in ipairs({ -0.85, 0.85 }) do
			for _, z in ipairs({ -0.85, 0.85 }) do
				makePart(model, "LanternRail", Vector3.new(0.16, 1.8, 0.16), Color3.fromRGB(108, 75, 57), Enum.PartType.Block, Vector3.new(x, 1.65, z))
			end
		end
	elseif item.Form == "Manta" then
		body = makePart(model, "Body", Vector3.new(1.8, 1.35, 2.2), accent, Enum.PartType.Ball, Vector3.new(0, 1.55, 0))
		makePart(model, "FinLeft", Vector3.new(1.8, 0.25, 1.25), accent:Lerp(Color3.new(1, 1, 1), 0.22), Enum.PartType.Wedge, Vector3.new(-1.2, 1.45, 0.1))
		makePart(model, "FinRight", Vector3.new(1.8, 0.25, 1.25), accent:Lerp(Color3.new(1, 1, 1), 0.22), Enum.PartType.Wedge, Vector3.new(1.2, 1.45, 0.1))
		makePart(model, "Tail", Vector3.new(0.35, 1.15, 0.35), accent, Enum.PartType.Wedge, Vector3.new(0, 0.55, 1.15))
	elseif item.Form == "Chestnut" then
		body = makePart(model, "Body", Vector3.new(2.25, 2.2, 2.1), accent, Enum.PartType.Ball, Vector3.new(0, 1.4, 0))
		makePart(model, "Shell", Vector3.new(2.4, 1.05, 2.25), Color3.fromRGB(124, 71, 49), Enum.PartType.Ball, Vector3.new(0, 2.05, -0.12))
		makePart(model, "SunLeaf", Vector3.new(0.5, 1.25, 0.45), Color3.fromRGB(112, 194, 91), Enum.PartType.Wedge, Vector3.new(0.2, 3.05, 0))
	else
		body = makePart(model, "Body", Vector3.new(2.1, 1.85, 2.1), accent, Enum.PartType.Ball, Vector3.new(0, 1.3, 0))
		local foot = makePart(model, "PuddleFoot", Vector3.new(0.35, 2.8, 2.4), accent:Lerp(Color3.new(1, 1, 1), 0.28), Enum.PartType.Cylinder, Vector3.new(0, 0.35, 0))
		foot.CFrame *= CFrame.Angles(0, 0, math.rad(90))
	end
	model.PrimaryPart = body
	addFace(model)
	local rarity = Catalog.Rarities[item.Rarity]
	local tag = Instance.new("BillboardGui")
	tag.Name = "NameTag"
	tag.Size = UDim2.fromOffset(138, 38)
	tag.StudsOffset = Vector3.new(0, 2.7, 0)
	tag.AlwaysOnTop = true
	tag.MaxDistance = 68
	tag.Parent = body
	local text = Instance.new("TextLabel")
	text.Size = UDim2.fromScale(1, 1)
	text.BackgroundTransparency = 1
	text.Font = Enum.Font.GothamBold
	text.Text = (mutation and (mutation .. " ") or "") .. item.Name .. "\n" .. item.Rarity .. "  •  $" .. Catalog.GetIncome(item, mutation) .. "/s"
	text.TextColor3 = rarity.Color
	text.TextStrokeColor3 = Color3.fromRGB(35, 39, 51)
	text.TextStrokeTransparency = 0.15
	text.TextScaled = true
	text.Parent = tag
	local textConstraint = Instance.new("UITextSizeConstraint")
	textConstraint.MinTextSize = 10
	textConstraint.MaxTextSize = 22
	textConstraint.Parent = text
	if mutation == "Rainbow" then
		local colorIndex = 0
		for _, descendant in ipairs(model:GetDescendants()) do
			if descendant:IsA("BasePart") and not descendant.Name:find("Eye") and descendant.Name ~= "Smile" and not descendant.Name:find("Cheek") then
				colorIndex += 1
				descendant.Color = Color3.fromHSV((colorIndex * 0.17) % 1, 0.72, 1)
			end
		end
		local highlight = Instance.new("Highlight")
		highlight.Name = "RainbowGlow"
		highlight.FillColor = Color3.fromRGB(255, 105, 213)
		highlight.OutlineColor = Color3.fromRGB(102, 236, 255)
		highlight.FillTransparency = 0.68
		highlight.Parent = model
	end
	model.Parent = parent
	return model
end

return Catalog
