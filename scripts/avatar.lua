-- Theme Colors
local BLACK = Color3.fromRGB(15, 15, 15)
local DARK_GRAY = Color3.fromRGB(35, 35, 35)
local MID_GRAY = Color3.fromRGB(50, 50, 50)
local LIGHT_GRAY = Color3.fromRGB(70, 70, 70)
local WHITE = Color3.fromRGB(255, 255, 255)
local RED = Color3.fromRGB(200, 50, 50)
local LIGHT_GREEN = Color3.fromRGB(50, 180, 50)
local BLUE = Color3.fromRGB(50, 120, 200)
local ACCENT = Color3.fromRGB(100, 150, 255)
local MENU_ALPHA = 0.95

-- Services
local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")
local StarterGui = game:GetService("StarterGui")
local UserInputService = game:GetService("UserInputService")
local player = Players.LocalPlayer

-- Variables
local creatorUserId = nil
local creatorThumbnail = ""
local minimized = false
local draggingTitleBar = false
local dragStart, startPos = nil, nil
local currentTab = "search"
local favorites = {}
local playerCache = {}

-- Creator Info
local success, result = pcall(function()
	return Players:GetUserIdFromNameAsync("akuramaa_xd")
end)
if success then
	creatorUserId = result
	success, result = pcall(function()
		return Players:GetUserThumbnailAsync(creatorUserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size100x100)
	end)
	if success then
		creatorThumbnail = result
	end
end

-- Cleanup Existing GUI
if CoreGui:FindFirstChild("MorphAvatarByKuramaMod") then 
	CoreGui["MorphAvatarByKuramaMod"]:Destroy() 
end

-- Main GUI
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "MorphAvatarByKuramaMod"
screenGui.ResetOnSpawn = false
screenGui.DisplayOrder = 999999
screenGui.Parent = CoreGui
screenGui.Enabled = true

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 380, 0, 450)
frame.Position = UDim2.new(0.5, -190, 0.5, -225)
frame.BackgroundColor3 = BLACK
frame.BackgroundTransparency = 1 - MENU_ALPHA
frame.BorderSizePixel = 0
frame.Active = false
frame.Parent = screenGui
frame.Visible = true
frame.ClipsDescendants = true

local frameCorner = Instance.new("UICorner")
frameCorner.CornerRadius = UDim.new(0, 10)
frameCorner.Parent = frame

-- Title Bar
local titleBar = Instance.new("Frame")
titleBar.Size = UDim2.new(1, 0, 0, 40)
titleBar.Position = UDim2.new(0, 0, 0, 0)
titleBar.BackgroundTransparency = 1
titleBar.Parent = frame
titleBar.Active = true

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -80, 0, 40)
title.Position = UDim2.new(0, 15, 0, 0)
title.Text = "🎭 Morph Avatar Pro"
title.TextColor3 = ACCENT
title.BackgroundTransparency = 1
title.BorderSizePixel = 0
title.Font = Enum.Font.GothamBold
title.TextSize = 18
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = titleBar

-- Buttons
local miniBtn = Instance.new("TextButton")
miniBtn.Name = "MinimizeButton"
miniBtn.Size = UDim2.new(0, 35, 0, 35)
miniBtn.Position = UDim2.new(1, -75, 0, 2.5)
miniBtn.Text = "−"
miniBtn.Font = Enum.Font.GothamBold
miniBtn.TextSize = 20
miniBtn.TextColor3 = WHITE
miniBtn.BackgroundColor3 = MID_GRAY
miniBtn.BorderSizePixel = 0
miniBtn.Parent = titleBar

local miniBtnCorner = Instance.new("UICorner")
miniBtnCorner.CornerRadius = UDim.new(0, 6)
miniBtnCorner.Parent = miniBtn

local closeBtn = Instance.new("TextButton")
closeBtn.Name = "Close"
closeBtn.Size = UDim2.new(0, 35, 0, 35)
closeBtn.Position = UDim2.new(1, -37.5, 0, 2.5)
closeBtn.Text = "✕"
closeBtn.Font = Enum.Font.GothamBold
closeBtn.TextSize = 18
closeBtn.TextColor3 = WHITE
closeBtn.BackgroundColor3 = RED
closeBtn.BorderSizePixel = 0
closeBtn.Parent = titleBar
closeBtn.ZIndex = 2

local closeBtnCorner = Instance.new("UICorner")
closeBtnCorner.CornerRadius = UDim.new(0, 6)
closeBtnCorner.Parent = closeBtn

-- Tabs Container
local tabsContainer = Instance.new("Frame")
tabsContainer.Size = UDim2.new(1, -20, 0, 35)
tabsContainer.Position = UDim2.new(0, 10, 0, 50)
tabsContainer.BackgroundColor3 = DARK_GRAY
tabsContainer.BorderSizePixel = 0
tabsContainer.Parent = frame

local tabsCorner = Instance.new("UICorner")
tabsCorner.CornerRadius = UDim.new(0, 8)
tabsCorner.Parent = tabsContainer

local tabsLayout = Instance.new("UIListLayout")
tabsLayout.FillDirection = Enum.FillDirection.Horizontal
tabsLayout.HorizontalAlignment = Enum.HorizontalAlignment.Left
tabsLayout.VerticalAlignment = Enum.VerticalAlignment.Center
tabsLayout.Padding = UDim.new(0, 4)
tabsLayout.Parent = tabsContainer

-- Tab Buttons Logic
local function createTab(name, icon, widthScale)
	local tab = Instance.new("TextButton")
	tab.Name = name .. "Tab"
	tab.Size = UDim2.new(widthScale, -3, 1, -6)
	tab.Position = UDim2.new(0, 3, 0, 3)
	tab.Text = icon .. " " .. name
	tab.Font = Enum.Font.GothamBold
	tab.TextSize = 12
	tab.TextColor3 = WHITE
	tab.BackgroundColor3 = (name:lower() == currentTab) and ACCENT or MID_GRAY
	tab.BorderSizePixel = 0
	tab.Parent = tabsContainer

	local tabCorner = Instance.new("UICorner")
	tabCorner.CornerRadius = UDim.new(0, 6)
	tabCorner.Parent = tab

	return tab
end

local searchTab = createTab("Search", "🔍", 0.25)
local playersTab = createTab("Players", "👥", 0.25)
local favoritesTab = createTab("Favorites", "⭐", 0.25)
local skinTab = createTab("Skin", "🎨", 0.25)

-- Content Container
local contentContainer = Instance.new("Frame")
contentContainer.Size = UDim2.new(1, -20, 1, -105)
contentContainer.Position = UDim2.new(0, 10, 0, 95)
contentContainer.BackgroundTransparency = 1
contentContainer.BorderSizePixel = 0
contentContainer.Parent = frame

-- Search Content
local searchContent = Instance.new("Frame")
searchContent.Name = "SearchContent"
searchContent.Size = UDim2.new(1, 0, 1, 0)
searchContent.BackgroundTransparency = 1
searchContent.Parent = contentContainer
searchContent.Visible = true

local searchLabel = Instance.new("TextLabel")
searchLabel.Size = UDim2.new(1, 0, 0, 25)
searchLabel.Position = UDim2.new(0, 0, 0, 5)
searchLabel.Text = "Enter Username to Morph"
searchLabel.TextColor3 = LIGHT_GRAY
searchLabel.BackgroundTransparency = 1
searchLabel.Font = Enum.Font.Gotham
searchLabel.TextSize = 12
searchLabel.TextXAlignment = Enum.TextXAlignment.Left
searchLabel.Parent = searchContent

local usernameInput = Instance.new("TextBox")
usernameInput.Size = UDim2.new(1, 0, 0, 40)
usernameInput.Position = UDim2.new(0, 0, 0, 35)
usernameInput.PlaceholderText = "Type username here..."
usernameInput.Font = Enum.Font.Gotham
usernameInput.TextSize = 15
usernameInput.Text = ""
usernameInput.TextColor3 = WHITE
usernameInput.PlaceholderColor3 = LIGHT_GRAY
usernameInput.BackgroundColor3 = DARK_GRAY
usernameInput.BorderSizePixel = 0
usernameInput.ClearTextOnFocus = false
usernameInput.TextWrapped = true
usernameInput.Parent = searchContent

local inputCorner = Instance.new("UICorner")
inputCorner.CornerRadius = UDim.new(0, 8)
inputCorner.Parent = usernameInput

local morphBtn = Instance.new("TextButton")
morphBtn.Size = UDim2.new(1, 0, 0, 45)
morphBtn.Position = UDim2.new(0, 0, 0, 85)
morphBtn.Text = "🎭 MORPH NOW"
morphBtn.Font = Enum.Font.GothamBold
morphBtn.TextSize = 16
morphBtn.TextColor3 = WHITE
morphBtn.BackgroundColor3 = LIGHT_GREEN
morphBtn.BorderSizePixel = 0
morphBtn.Parent = searchContent

local morphBtnCorner = Instance.new("UICorner")
morphBtnCorner.CornerRadius = UDim.new(0, 8)
morphBtnCorner.Parent = morphBtn

local resetBtn = Instance.new("TextButton")
resetBtn.Size = UDim2.new(1, 0, 0, 40)
resetBtn.Position = UDim2.new(0, 0, 0, 140)
resetBtn.Text = "🔄 Reset to Original"
resetBtn.Font = Enum.Font.GothamBold
resetBtn.TextSize = 14
resetBtn.TextColor3 = WHITE
resetBtn.BackgroundColor3 = MID_GRAY
resetBtn.BorderSizePixel = 0
resetBtn.Parent = searchContent

local resetBtnCorner = Instance.new("UICorner")
resetBtnCorner.CornerRadius = UDim.new(0, 8)
resetBtnCorner.Parent = resetBtn

local infoLabel = Instance.new("TextLabel")
infoLabel.Size = UDim2.new(1, 0, 0, 80)
infoLabel.Position = UDim2.new(0, 0, 1, -85)
infoLabel.Text = "💡 Tips:\n• Enter partial username\n• Works with offline players\n• Press Enter to morph"
infoLabel.TextColor3 = LIGHT_GRAY
infoLabel.BackgroundTransparency = 1
infoLabel.Font = Enum.Font.Gotham
infoLabel.TextSize = 11
infoLabel.TextXAlignment = Enum.TextXAlignment.Left
infoLabel.TextYAlignment = Enum.TextYAlignment.Top
infoLabel.Parent = searchContent

-- Players Content
local playersContent = Instance.new("Frame")
playersContent.Name = "PlayersContent"
playersContent.Size = UDim2.new(1, 0, 1, 0)
playersContent.BackgroundTransparency = 1
playersContent.Parent = contentContainer
playersContent.Visible = false

local playersScrollFrame = Instance.new("ScrollingFrame")
playersScrollFrame.Size = UDim2.new(1, 0, 1, 0)
playersScrollFrame.BackgroundColor3 = DARK_GRAY
playersScrollFrame.BorderSizePixel = 0
playersScrollFrame.ScrollBarThickness = 6
playersScrollFrame.ScrollBarImageColor3 = ACCENT
playersScrollFrame.Parent = playersContent

local playersCorner = Instance.new("UICorner")
playersCorner.CornerRadius = UDim.new(0, 8)
playersCorner.Parent = playersScrollFrame

local playersLayout = Instance.new("UIListLayout")
playersLayout.Padding = UDim.new(0, 5)
playersLayout.SortOrder = Enum.SortOrder.Name
playersLayout.Parent = playersScrollFrame

-- Favorites Content
local favoritesContent = Instance.new("Frame")
favoritesContent.Name = "FavoritesContent"
favoritesContent.Size = UDim2.new(1, 0, 1, 0)
favoritesContent.BackgroundTransparency = 1
favoritesContent.Parent = contentContainer
favoritesContent.Visible = false

local favoritesScrollFrame = Instance.new("ScrollingFrame")
favoritesScrollFrame.Size = UDim2.new(1, 0, 1, 0)
favoritesScrollFrame.BackgroundColor3 = DARK_GRAY
favoritesScrollFrame.BorderSizePixel = 0
favoritesScrollFrame.ScrollBarThickness = 6
favoritesScrollFrame.ScrollBarImageColor3 = ACCENT
favoritesScrollFrame.Parent = favoritesContent

local favoritesCorner = Instance.new("UICorner")
favoritesCorner.CornerRadius = UDim.new(0, 8)
favoritesCorner.Parent = favoritesScrollFrame

local favoritesLayout = Instance.new("UIListLayout")
favoritesLayout.Padding = UDim.new(0, 5)
favoritesLayout.SortOrder = Enum.SortOrder.Name
favoritesLayout.Parent = favoritesScrollFrame

local noFavoritesLabel = Instance.new("TextLabel")
noFavoritesLabel.Size = UDim2.new(1, -20, 0, 60)
noFavoritesLabel.Position = UDim2.new(0, 10, 0.5, -30)
noFavoritesLabel.Text = "⭐ No favorites yet!\n\nAdd players from the Players tab"
noFavoritesLabel.TextColor3 = LIGHT_GRAY
noFavoritesLabel.BackgroundTransparency = 1
noFavoritesLabel.Font = Enum.Font.Gotham
noFavoritesLabel.TextSize = 13
noFavoritesLabel.Parent = favoritesContent

-- ==========================================
-- SKIN CONTENT SECTION
-- ==========================================
local skinContent = Instance.new("Frame")
skinContent.Name = "SkinContent"
skinContent.Size = UDim2.new(1, 0, 1, 0)
skinContent.BackgroundTransparency = 1
skinContent.Parent = contentContainer
skinContent.Visible = false

-- Area superior (Paleta Scroll)
local skinPaletteScroll = Instance.new("ScrollingFrame")
skinPaletteScroll.Size = UDim2.new(1, 0, 1, -50)
skinPaletteScroll.BackgroundColor3 = DARK_GRAY
skinPaletteScroll.BorderSizePixel = 0
skinPaletteScroll.ScrollBarThickness = 6
skinPaletteScroll.ScrollBarImageColor3 = ACCENT
skinPaletteScroll.Parent = skinContent

local skinPaletteCorner = Instance.new("UICorner")
skinPaletteCorner.CornerRadius = UDim.new(0, 8)
skinPaletteCorner.Parent = skinPaletteScroll

local skinGridLayout = Instance.new("UIGridLayout")
skinGridLayout.CellSize = UDim2.new(0, 38, 0, 38)
skinGridLayout.CellPadding = UDim2.new(0, 8, 0, 8)
skinGridLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
skinGridLayout.SortOrder = Enum.SortOrder.LayoutOrder
skinGridLayout.Parent = skinPaletteScroll

local skinPalettePadding = Instance.new("UIPadding")
skinPalettePadding.PaddingTop = UDim.new(0, 10)
skinPalettePadding.PaddingBottom = UDim.new(0, 10)
skinPalettePadding.PaddingLeft = UDim.new(0, 10)
skinPalettePadding.PaddingRight = UDim.new(0, 10)
skinPalettePadding.Parent = skinPaletteScroll

-- Area inferior (Hex Input)
local hexContainer = Instance.new("Frame")
hexContainer.Size = UDim2.new(1, 0, 0, 40)
hexContainer.Position = UDim2.new(0, 0, 1, -40)
hexContainer.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
hexContainer.BorderSizePixel = 0
hexContainer.Parent = skinContent

local hexCorner = Instance.new("UICorner")
hexCorner.CornerRadius = UDim.new(0, 8)
hexCorner.Parent = hexContainer

local hexLabel = Instance.new("TextLabel")
hexLabel.Text = "Color hexadecimal"
hexLabel.Size = UDim2.new(0, 110, 1, 0)
hexLabel.Position = UDim2.new(0, 10, 0, 0)
hexLabel.BackgroundTransparency = 1
hexLabel.TextColor3 = LIGHT_GRAY
hexLabel.Font = Enum.Font.Gotham
hexLabel.TextSize = 12
hexLabel.TextXAlignment = Enum.TextXAlignment.Left
hexLabel.Parent = hexContainer

local hexPreviewCircle = Instance.new("Frame")
hexPreviewCircle.Size = UDim2.new(0, 24, 0, 24)
hexPreviewCircle.Position = UDim2.new(1, -34, 0.5, -12)
hexPreviewCircle.BackgroundColor3 = Color3.fromRGB(240, 240, 240)
hexPreviewCircle.BorderSizePixel = 0
hexPreviewCircle.Parent = hexContainer

local hexPreviewCorner = Instance.new("UICorner")
hexPreviewCorner.CornerRadius = UDim.new(1, 0)
hexPreviewCorner.Parent = hexPreviewCircle

local hexInput = Instance.new("TextBox")
hexInput.Size = UDim2.new(0, 80, 0, 26)
hexInput.Position = UDim2.new(1, -125, 0.5, -13)
hexInput.BackgroundColor3 = DARK_GRAY
hexInput.TextColor3 = WHITE
hexInput.Font = Enum.Font.GothamBold
hexInput.TextSize = 13
hexInput.Text = "#F0F0F0"
hexInput.PlaceholderText = "#HEX"
hexInput.BorderSizePixel = 0
hexInput.Parent = hexContainer

local hexInputCorner = Instance.new("UICorner")
hexInputCorner.CornerRadius = UDim.new(0, 6)
hexInputCorner.Parent = hexInput

-- Paleta de Colores
local skinColors = {
	Color3.fromHex("382318"), Color3.fromHex("462E20"), Color3.fromHex("5A3A29"), Color3.fromHex("6F4835"),
	Color3.fromHex("855B45"), Color3.fromHex("9B6F55"), Color3.fromHex("B28368"), Color3.fromHex("C69477"),
	Color3.fromHex("D8A98E"), Color3.fromHex("EAC0A5"), Color3.fromHex("F5D4BB"), Color3.fromHex("FFE7D1"),
	Color3.fromHex("FFD700"), Color3.fromHex("FFFF00"), Color3.fromHex("FCEEB5"), Color3.fromHex("FFFDD0"),
	Color3.fromHex("234F1E"), Color3.fromHex("006400"), Color3.fromHex("2E8B57"), Color3.fromHex("32CD32"),
	Color3.fromHex("90EE90"), Color3.fromHex("98FB98"), Color3.fromHex("CCFF00"), Color3.fromHex("ADFF2F"),
	Color3.fromHex("000080"), Color3.fromHex("0000FF"), Color3.fromHex("1E90FF"), Color3.fromHex("00BFFF"),
	Color3.fromHex("87CEEB"), Color3.fromHex("B0E0E6"), Color3.fromHex("E0FFFF"), Color3.fromHex("5F9EA0"),
	Color3.fromHex("4B0082"), Color3.fromHex("800080"), Color3.fromHex("9932CC"), Color3.fromHex("DA70D6"),
	Color3.fromHex("FF00FF"), Color3.fromHex("FF1493"), Color3.fromHex("FF69B4"), Color3.fromHex("FFB6C1"),
	Color3.fromHex("800000"), Color3.fromHex("B22222"), Color3.fromHex("FF0000"), Color3.fromHex("FF4500"),
	Color3.fromHex("FF8C00"), Color3.fromHex("FFA500"), Color3.fromHex("FF7F50"), Color3.fromHex("FA8072"),
	Color3.fromHex("1C1C1C"), Color3.fromHex("363636"), Color3.fromHex("555555"), Color3.fromHex("808080"),
	Color3.fromHex("A9A9A9"), Color3.fromHex("C0C0C0"), Color3.fromHex("D3D3D3"), Color3.fromHex("F5F5F5")
}

-- Functions
local function applyMorphEffect(character)
	local rootPart = character:FindFirstChild("HumanoidRootPart")
	if not rootPart then return end

	local particleEmitter = Instance.new("ParticleEmitter")
	particleEmitter.Texture = "rbxassetid://243098098"
	particleEmitter.Rate = 50
	particleEmitter.Speed = NumberRange.new(5, 10)
	particleEmitter.Lifetime = NumberRange.new(0.5, 1)
	particleEmitter.SpreadAngle = Vector2.new(360, 360)
	particleEmitter.Color = ColorSequence.new(LIGHT_GREEN)
	particleEmitter.Parent = rootPart

	local explosion = Instance.new("Explosion")
	explosion.BlastRadius = 5
	explosion.BlastPressure = 0
	explosion.Position = rootPart.Position
	explosion.Visible = true
	explosion.Parent = workspace
	explosion.ExplosionType = Enum.ExplosionType.NoCraters

	task.spawn(function()
		task.wait(2)
		particleEmitter.Enabled = false
		task.wait(1)
		particleEmitter:Destroy()
		explosion:Destroy()
	end)
end

local function findPlayerByName(partialName)
	if not partialName or partialName == "" then return nil end
	local searchName = partialName:lower()

	local localPlayer = nil
	for _, v in ipairs(Players:GetPlayers()) do
		local nameLower = v.Name:lower()
		local dNameLower = v.DisplayName:lower()

		if nameLower == searchName or dNameLower == searchName then
			return v
		end

		if nameLower:sub(1, #searchName) == searchName or dNameLower:sub(1, #searchName) == searchName then
			localPlayer = v
		end
	end

	if not localPlayer then
		local success, userId = pcall(function()
			return Players:GetUserIdFromNameAsync(searchName)
		end)
		if success and userId then
			return {UserId = userId, Name = searchName, IsOffline = true}
		end
	end

	return localPlayer
end

local function sendNotif(titleT, textT, image)
	local success, err = pcall(function()
		StarterGui:SetCore("SendNotification", {
			Title = titleT,
			Text = textT,
			Duration = 5,
			Icon = image or ""
		})
	end)
	if not success then
		warn("[sendNotif] Failed to send notification: " .. tostring(err))
	end
end

-- ==========================================
-- SKIN LOGIC FUNCTIONS (CORREGIDO PARA GUARDADO)
-- ==========================================
local function colorToHex(color)
	return string.format("#%02X%02X%02X", color.R * 255, color.G * 255, color.B * 255)
end

local function applySkinColor(color)
	local character = player.Character
	if not character then return end
	
	local humanoid = character:FindFirstChild("Humanoid")
	if not humanoid then return end

	-- 1. Actualizar UI
	hexPreviewCircle.BackgroundColor3 = color
	hexInput.Text = colorToHex(color)
	
	-- 2. Actualizar visualmente (BodyColors) para respuesta inmediata
	local bodyColors = character:FindFirstChild("BodyColors") or character:FindFirstChildOfClass("BodyColors")
	if not bodyColors then
		bodyColors = Instance.new("BodyColors")
		bodyColors.Name = "BodyColors"
		bodyColors.Parent = character
	end
	
	bodyColors.HeadColor3 = color
	bodyColors.LeftArmColor3 = color
	bodyColors.RightArmColor3 = color
	bodyColors.LeftLegColor3 = color
	bodyColors.RightLegColor3 = color
	bodyColors.TorsoColor3 = color
	
	-- 3. Actualizar HumanoidDescription (IMPORTANTE PARA GUARDAR)
	-- Esto asegura que el sistema de guardado del juego detecte el cambio
	pcall(function()
		local desc = humanoid:GetAppliedDescription()
		desc.HeadColor = color
		desc.LeftArmColor = color
		desc.RightArmColor = color
		desc.LeftLegColor = color
		desc.RightLegColor = color
		desc.TorsoColor = color
		
		-- Aplicar la descripción actualizada
		if humanoid.ApplyDescriptionClientServer then
			humanoid:ApplyDescriptionClientServer(desc)
		else
			humanoid:ApplyDescription(desc)
		end
	end)
end

-- Generar botones de paleta
for i, color in ipairs(skinColors) do
	local colorBtn = Instance.new("ImageButton")
	colorBtn.Name = "Color_" .. i
	colorBtn.BackgroundColor3 = color
	colorBtn.BorderSizePixel = 0
	colorBtn.AutoButtonColor = false
	colorBtn.Parent = skinPaletteScroll
	
	local btnCorner = Instance.new("UICorner")
	btnCorner.CornerRadius = UDim.new(1, 0)
	btnCorner.Parent = colorBtn
	
	local stroke = Instance.new("UIStroke")
	stroke.Color = WHITE
	stroke.Thickness = 2
	stroke.Transparency = 1
	stroke.Parent = colorBtn
	
	colorBtn.MouseEnter:Connect(function()
		stroke.Transparency = 0
	end)
	
	colorBtn.MouseLeave:Connect(function()
		stroke.Transparency = 1
	end)
	
	colorBtn.MouseButton1Click:Connect(function()
		applySkinColor(color)
	end)
end

hexInput.FocusLost:Connect(function(enterPressed)
	local text = hexInput.Text:gsub("#", "")
	if #text == 6 then
		local success, newColor = pcall(function()
			return Color3.fromHex(text)
		end)
		
		if success then
			applySkinColor(newColor)
		else
			hexInput.Text = colorToHex(hexPreviewCircle.BackgroundColor3)
		end
	else
		hexInput.Text = colorToHex(hexPreviewCircle.BackgroundColor3)
	end
end)

local function morphToPlayer(target)
	if not target then 
		sendNotif("Morph Avatar", "No target found!", "")
		return 
	end

	local userId = target.UserId or (type(target) == "number" and target or target.UserId)
	local targetName = target.Name or "Unknown"

	if userId == player.UserId then
		sendNotif("Morph Avatar", "Cannot morph to yourself!", "")
		return
	end

	local character = player.Character or player.CharacterAdded:Wait()
	local humanoid = character:WaitForChild("Humanoid", 10)
	if not humanoid then 
		sendNotif("Morph Avatar", "Failed to find humanoid!", "")
		return 
	end

	local desc = nil

	if typeof(target) == "Instance" and target:IsA("Player") then
		local targetChar = target.Character
		if targetChar then
			local targetHum = targetChar:FindFirstChild("Humanoid")
			if targetHum then
				local success, result = pcall(function()
					return targetHum:GetAppliedDescription()
				end)
				if success then
					desc = result
				end
			end
		end
	end

	if not desc then
		local success, result = pcall(function()
			return Players:GetHumanoidDescriptionFromUserId(userId)
		end)
		if success then
			desc = result
		end
	end

	if not desc then
		sendNotif("Morph Avatar", "Failed to load avatar data!", "")
		return
	end

	local targetThumbnail = ""
	local thumbSuccess, thumbResult = pcall(function()
		return Players:GetUserThumbnailAsync(userId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size100x100)
	end)
	if thumbSuccess then
		targetThumbnail = thumbResult
	end

	for _, obj in ipairs(character:GetChildren()) do
		if obj:IsA("Shirt") or obj:IsA("Pants") or obj:IsA("ShirtGraphic") or
			obj:IsA("Accessory") or obj:IsA("BodyColors") then
			obj:Destroy()
		end
	end
	local head = character:FindFirstChild("Head")
	if head then
		for _, decal in ipairs(head:GetChildren()) do
			if decal:IsA("Decal") then decal:Destroy() end
		end
	end

	local applySuccess = pcall(function()
		if humanoid.ApplyDescriptionClientServer then
			humanoid:ApplyDescriptionClientServer(desc)
		else
			humanoid:ApplyDescription(desc)
		end
	end)

	if applySuccess then
		applyMorphEffect(character)
		sendNotif("Morph Avatar", "Morphed to " .. targetName .. "!", targetThumbnail)
	else
		sendNotif("Morph Avatar", "Failed to apply morph!", "")
	end
end

local function createPlayerCard(targetPlayer, isFavorite)
	local card = Instance.new("Frame")
	card.Size = UDim2.new(1, -10, 0, 50)
	card.BackgroundColor3 = MID_GRAY
	card.BorderSizePixel = 0

	local cardCorner = Instance.new("UICorner")
	cardCorner.CornerRadius = UDim.new(0, 6)
	cardCorner.Parent = card

	local playerName = Instance.new("TextLabel")
	playerName.Size = UDim2.new(1, -100, 0, 25)
	playerName.Position = UDim2.new(0, 10, 0, 5)
	playerName.Text = targetPlayer.Name
	playerName.TextColor3 = WHITE
	playerName.BackgroundTransparency = 1
	playerName.Font = Enum.Font.GothamBold
	playerName.TextSize = 14
	playerName.TextXAlignment = Enum.TextXAlignment.Left
	playerName.Parent = card

	local displayName = Instance.new("TextLabel")
	displayName.Size = UDim2.new(1, -100, 0, 20)
	displayName.Position = UDim2.new(0, 10, 0, 25)
	displayName.Text = "@" .. targetPlayer.DisplayName
	displayName.TextColor3 = LIGHT_GRAY
	displayName.BackgroundTransparency = 1
	displayName.Font = Enum.Font.Gotham
	displayName.TextSize = 11
	displayName.TextXAlignment = Enum.TextXAlignment.Left
	displayName.Parent = card

	local morphPlayerBtn = Instance.new("TextButton")
	morphPlayerBtn.Size = UDim2.new(0, 60, 0, 35)
	morphPlayerBtn.Position = UDim2.new(1, -65, 0, 7.5)
	morphPlayerBtn.Text = "Morph"
	morphPlayerBtn.Font = Enum.Font.GothamBold
	morphPlayerBtn.TextSize = 12
	morphPlayerBtn.TextColor3 = WHITE
	morphPlayerBtn.BackgroundColor3 = LIGHT_GREEN
	morphPlayerBtn.BorderSizePixel = 0
	morphPlayerBtn.Parent = card

	local morphPlayerBtnCorner = Instance.new("UICorner")
	morphPlayerBtnCorner.CornerRadius = UDim.new(0, 5)
	morphPlayerBtnCorner.Parent = morphPlayerBtn

	if not isFavorite then
		local favBtn = Instance.new("TextButton")
		favBtn.Size = UDim2.new(0, 30, 0, 35)
		favBtn.Position = UDim2.new(1, -130, 0, 7.5)
		favBtn.Text = favorites[targetPlayer.Name] and "⭐" or "☆"
		favBtn.Font = Enum.Font.GothamBold
		favBtn.TextSize = 16
		favBtn.TextColor3 = WHITE
		favBtn.BackgroundColor3 = DARK_GRAY
		favBtn.BorderSizePixel = 0
		favBtn.Parent = card

		local favBtnCorner = Instance.new("UICorner")
		favBtnCorner.CornerRadius = UDim.new(0, 5)
		favBtnCorner.Parent = favBtn

		favBtn.MouseButton1Click:Connect(function()
			if favorites[targetPlayer.Name] then
				favorites[targetPlayer.Name] = nil
				favBtn.Text = "☆"
				sendNotif("Favorites", "Removed from favorites", "")
			else
				favorites[targetPlayer.Name] = {UserId = targetPlayer.UserId, DisplayName = targetPlayer.DisplayName}
				favBtn.Text = "⭐"
				sendNotif("Favorites", "Added to favorites", "")
			end
			updateFavoritesList()
		end)
	else
		local removeBtn = Instance.new("TextButton")
		removeBtn.Size = UDim2.new(0, 30, 0, 35)
		removeBtn.Position = UDim2.new(1, -130, 0, 7.5)
		removeBtn.Text = "✕"
		removeBtn.Font = Enum.Font.GothamBold
		removeBtn.TextSize = 16
		removeBtn.TextColor3 = WHITE
		removeBtn.BackgroundColor3 = RED
		removeBtn.BorderSizePixel = 0
		removeBtn.Parent = removeBtn

		local removeBtnCorner = Instance.new("UICorner")
		removeBtnCorner.CornerRadius = UDim.new(0, 5)
		removeBtnCorner.Parent = removeBtn

		removeBtn.MouseButton1Click:Connect(function()
			favorites[targetPlayer.Name] = nil
			sendNotif("Favorites", "Removed from favorites", "")
			updateFavoritesList()
		end)
	end

	morphPlayerBtn.MouseButton1Click:Connect(function()
		morphToPlayer(targetPlayer)
	end)

	return card
end

function updatePlayersList()
	for _, child in ipairs(playersScrollFrame:GetChildren()) do
		if child:IsA("Frame") then
			child:Destroy()
		end
	end

	for _, targetPlayer in ipairs(Players:GetPlayers()) do
		if targetPlayer ~= player then
			local card = createPlayerCard(targetPlayer, false)
			card.Parent = playersScrollFrame
		end
	end

	playersScrollFrame.CanvasSize = UDim2.new(0, 0, 0, playersLayout.AbsoluteContentSize.Y + 10)
end

function updateFavoritesList()
	for _, child in ipairs(favoritesScrollFrame:GetChildren()) do
		if child:IsA("Frame") then
			child:Destroy()
		end
	end

	local hasFavorites = false
	for playerName, data in pairs(favorites) do
		hasFavorites = true
		local fakePlayer = {Name = playerName, UserId = data.UserId, DisplayName = data.DisplayName}
		local card = createPlayerCard(fakePlayer, true)
		card.Parent = favoritesScrollFrame
	end

	noFavoritesLabel.Visible = not hasFavorites
	favoritesScrollFrame.CanvasSize = UDim2.new(0, 0, 0, favoritesLayout.AbsoluteContentSize.Y + 10)
end

local function switchTab(tabName)
	currentTab = tabName

	searchTab.BackgroundColor3 = (tabName == "search") and ACCENT or MID_GRAY
	playersTab.BackgroundColor3 = (tabName == "players") and ACCENT or MID_GRAY
	favoritesTab.BackgroundColor3 = (tabName == "favorites") and ACCENT or MID_GRAY
	skinTab.BackgroundColor3 = (tabName == "skin") and ACCENT or MID_GRAY

	searchContent.Visible = (tabName == "search")
	playersContent.Visible = (tabName == "players")
	favoritesContent.Visible = (tabName == "favorites")
	skinContent.Visible = (tabName == "skin")

	if tabName == "players" then
		updatePlayersList()
	elseif tabName == "favorites" then
		updateFavoritesList()
	end
end

-- Events
titleBar.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		draggingTitleBar = true
		dragStart = input.Position
		startPos = frame.Position
	end
end)

UserInputService.InputEnded:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		draggingTitleBar = false
	end
end)

UserInputService.InputChanged:Connect(function(input)
	if draggingTitleBar and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
		local delta = input.Position - dragStart
		frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
	end
end)

miniBtn.MouseButton1Click:Connect(function()
	minimized = not minimized
	if minimized then
		frame.Size = UDim2.new(0, 350, 0, 40)
		miniBtn.Text = "+"
		tabsContainer.Visible = false
		contentContainer.Visible = false
	else
		frame.Size = UDim2.new(0, 380, 0, 450)
		miniBtn.Text = "−"
		tabsContainer.Visible = true
		contentContainer.Visible = true
	end
end)

closeBtn.MouseButton1Click:Connect(function()
	screenGui:Destroy()
end)

searchTab.MouseButton1Click:Connect(function()
	switchTab("search")
end)

playersTab.MouseButton1Click:Connect(function()
	switchTab("players")
end)

favoritesTab.MouseButton1Click:Connect(function()
	switchTab("favorites")
end)

skinTab.MouseButton1Click:Connect(function()
	switchTab("skin")
end)

morphBtn.MouseButton1Click:Connect(function()
	local inputText = usernameInput.Text
	if inputText == "" then 
		sendNotif("Morph Avatar", "Please enter a username!", "")
		return 
	end

	local target = findPlayerByName(inputText)
	if target then
		morphToPlayer(target)
	else
		sendNotif("Morph Avatar", "Player not found!", "")
	end
end)

usernameInput.FocusLost:Connect(function(enterPressed)
	if enterPressed then
		local inputText = usernameInput.Text
		if inputText == "" then 
			sendNotif("Morph Avatar", "Please enter a username!", "")
			return 
		end

		local target = findPlayerByName(inputText)
		if target then
			usernameInput.Text = target.Name or inputText
			morphToPlayer(target)
		else
			sendNotif("Morph Avatar", "Player not found!", "")
		end
	end
end)

resetBtn.MouseButton1Click:Connect(function()
	local character = player.Character
	if not character then return end

	local humanoid = character:FindFirstChild("Humanoid")
	if not humanoid then return end

	local success, desc = pcall(function()
		return Players:GetHumanoidDescriptionFromUserId(player.UserId)
	end)

	if success and desc then
		for _, obj in ipairs(character:GetChildren()) do
			if obj:IsA("Shirt") or obj:IsA("Pants") or obj:IsA("ShirtGraphic") or
				obj:IsA("Accessory") or obj:IsA("BodyColors") then
				obj:Destroy()
			end
		end

		pcall(function()
			humanoid:ApplyDescription(desc)
		end)

		sendNotif("Morph Avatar", "Reset to original avatar!", "")
	end
end)

Players.PlayerAdded:Connect(function()
	if currentTab == "players" then
		updatePlayersList()
	end
end)

Players.PlayerRemoving:Connect(function()
	if currentTab == "players" then
		updatePlayersList()
	end
end)

-- Initial Notification
sendNotif("Morph Avatar Pro", "Skin Saving Fixed! 🎨", creatorThumbnail)