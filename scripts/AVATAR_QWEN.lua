-- ==========================================
-- MORPH AVATAR PRO - VERSIÓN FINAL (v2.1.9)
-- UI REDESIGN: Modern Flat, High Contrast, Full Theme System
-- ==========================================

-- ==========================================
-- 1. CONFIGURACIÓN Y CONSTANTES
-- ==========================================

local THEMES = {
    Glass = {
        BLACK = Color3.fromRGB(15, 15, 15),
        DARK_GRAY = Color3.fromRGB(35, 35, 35),
        MID_GRAY = Color3.fromRGB(50, 50, 50),
        LIGHT_GRAY = Color3.fromRGB(200, 200, 200),
        WHITE = Color3.fromRGB(255, 255, 255),
        TEXT_MAIN = Color3.fromRGB(255, 255, 255),
        TEXT_DIM = Color3.fromRGB(180, 180, 180),
        RED = Color3.fromRGB(200, 50, 50),
        LIGHT_GREEN = Color3.fromRGB(50, 180, 50),
        BLUE = Color3.fromRGB(50, 120, 200),
        ACCENT = Color3.fromRGB(100, 150, 255),
        YELLOW = Color3.fromRGB(255, 255, 0),
        CARD_BG = Color3.fromRGB(42, 42, 42),
        SURFACE = Color3.fromRGB(28, 28, 28),
        STROKE = Color3.fromRGB(70, 70, 70),
        SCROLLBAR = Color3.fromRGB(100, 150, 255),
        PLACEHOLDER = Color3.fromRGB(120, 120, 120),
        BTN_HOVER = Color3.fromRGB(70, 70, 70),
        BTN_ACTIVE = Color3.fromRGB(90, 90, 90),
        TRANSPARENCY = 0.05
    },
    Dark = {
        BLACK = Color3.fromRGB(20, 20, 25),
        DARK_GRAY = Color3.fromRGB(30, 30, 40),
        MID_GRAY = Color3.fromRGB(55, 55, 70),
        LIGHT_GRAY = Color3.fromRGB(180, 180, 200),
        WHITE = Color3.fromRGB(240, 240, 240),
        TEXT_MAIN = Color3.fromRGB(240, 240, 240),
        TEXT_DIM = Color3.fromRGB(160, 160, 170),
        RED = Color3.fromRGB(200, 50, 50),
        LIGHT_GREEN = Color3.fromRGB(40, 180, 90),
        BLUE = Color3.fromRGB(80, 130, 220),
        ACCENT = Color3.fromRGB(80, 130, 220),
        YELLOW = Color3.fromRGB(255, 200, 50),
        CARD_BG = Color3.fromRGB(40, 40, 52),
        SURFACE = Color3.fromRGB(25, 25, 33),
        STROKE = Color3.fromRGB(75, 75, 95),
        SCROLLBAR = Color3.fromRGB(80, 130, 220),
        PLACEHOLDER = Color3.fromRGB(110, 110, 130),
        BTN_HOVER = Color3.fromRGB(70, 70, 90),
        BTN_ACTIVE = Color3.fromRGB(85, 85, 110),
        TRANSPARENCY = 0.05
    },
    Light = {
        BLACK = Color3.fromRGB(240, 240, 245),
        DARK_GRAY = Color3.fromRGB(220, 220, 230),
        MID_GRAY = Color3.fromRGB(200, 200, 210),
        LIGHT_GRAY = Color3.fromRGB(80, 80, 100),
        WHITE = Color3.fromRGB(20, 20, 25),
        TEXT_MAIN = Color3.fromRGB(20, 20, 25),
        TEXT_DIM = Color3.fromRGB(80, 80, 100),
        RED = Color3.fromRGB(180, 40, 40),
        LIGHT_GREEN = Color3.fromRGB(30, 150, 70),
        BLUE = Color3.fromRGB(60, 120, 200),
        ACCENT = Color3.fromRGB(60, 120, 200),
        YELLOW = Color3.fromRGB(200, 180, 0),
        CARD_BG = Color3.fromRGB(230, 230, 238),
        SURFACE = Color3.fromRGB(245, 245, 250),
        STROKE = Color3.fromRGB(170, 170, 185),
        SCROLLBAR = Color3.fromRGB(60, 120, 200),
        PLACEHOLDER = Color3.fromRGB(140, 140, 160),
        BTN_HOVER = Color3.fromRGB(185, 185, 200),
        BTN_ACTIVE = Color3.fromRGB(170, 170, 188),
        TRANSPARENCY = 0.1
    },
    Cyber = {
        BLACK = Color3.fromRGB(10, 10, 20),
        DARK_GRAY = Color3.fromRGB(25, 25, 45),
        MID_GRAY = Color3.fromRGB(45, 45, 75),
        LIGHT_GRAY = Color3.fromRGB(150, 200, 255),
        WHITE = Color3.fromRGB(255, 255, 255),
        TEXT_MAIN = Color3.fromRGB(255, 255, 255),
        TEXT_DIM = Color3.fromRGB(150, 200, 255),
        RED = Color3.fromRGB(255, 50, 100),
        LIGHT_GREEN = Color3.fromRGB(0, 255, 150),
        BLUE = Color3.fromRGB(0, 200, 255),
        ACCENT = Color3.fromRGB(0, 255, 200),
        YELLOW = Color3.fromRGB(255, 255, 0),
        CARD_BG = Color3.fromRGB(30, 30, 55),
        SURFACE = Color3.fromRGB(15, 15, 32),
        STROKE = Color3.fromRGB(0, 200, 255),
        SCROLLBAR = Color3.fromRGB(0, 255, 200),
        PLACEHOLDER = Color3.fromRGB(100, 150, 200),
        BTN_HOVER = Color3.fromRGB(60, 60, 100),
        BTN_ACTIVE = Color3.fromRGB(70, 70, 120),
        TRANSPARENCY = 0.2
    },
    Sunset = {
        BLACK = Color3.fromRGB(30, 20, 25),
        DARK_GRAY = Color3.fromRGB(50, 35, 40),
        MID_GRAY = Color3.fromRGB(70, 50, 55),
        LIGHT_GRAY = Color3.fromRGB(220, 180, 170),
        WHITE = Color3.fromRGB(255, 240, 230),
        TEXT_MAIN = Color3.fromRGB(255, 240, 230),
        TEXT_DIM = Color3.fromRGB(200, 160, 150),
        RED = Color3.fromRGB(255, 80, 80),
        LIGHT_GREEN = Color3.fromRGB(100, 200, 120),
        BLUE = Color3.fromRGB(255, 150, 100),
        ACCENT = Color3.fromRGB(255, 150, 100),
        YELLOW = Color3.fromRGB(255, 200, 100),
        CARD_BG = Color3.fromRGB(60, 42, 47),
        SURFACE = Color3.fromRGB(38, 26, 30),
        STROKE = Color3.fromRGB(255, 150, 100),
        SCROLLBAR = Color3.fromRGB(255, 150, 100),
        PLACEHOLDER = Color3.fromRGB(160, 120, 110),
        BTN_HOVER = Color3.fromRGB(85, 62, 68),
        BTN_ACTIVE = Color3.fromRGB(100, 72, 80),
        TRANSPARENCY = 0.15
    },
    Ocean = {
        BLACK = Color3.fromRGB(10, 20, 30),
        DARK_GRAY = Color3.fromRGB(20, 40, 60),
        MID_GRAY = Color3.fromRGB(35, 60, 90),
        LIGHT_GRAY = Color3.fromRGB(150, 190, 220),
        WHITE = Color3.fromRGB(230, 245, 255),
        TEXT_MAIN = Color3.fromRGB(230, 245, 255),
        TEXT_DIM = Color3.fromRGB(150, 190, 220),
        RED = Color3.fromRGB(255, 80, 100),
        LIGHT_GREEN = Color3.fromRGB(60, 200, 180),
        BLUE = Color3.fromRGB(50, 180, 255),
        ACCENT = Color3.fromRGB(50, 180, 255),
        YELLOW = Color3.fromRGB(100, 220, 255),
        CARD_BG = Color3.fromRGB(25, 50, 75),
        SURFACE = Color3.fromRGB(13, 26, 40),
        STROKE = Color3.fromRGB(50, 180, 255),
        SCROLLBAR = Color3.fromRGB(50, 180, 255),
        PLACEHOLDER = Color3.fromRGB(100, 145, 180),
        BTN_HOVER = Color3.fromRGB(45, 75, 110),
        BTN_ACTIVE = Color3.fromRGB(55, 90, 130),
        TRANSPARENCY = 0.18
    }
}

local COLORS = THEMES.Glass
local currentThemeName = "Glass"
local themeObjects = {}
local tabButtons = {}

local SERVICES = {
    Players = game:GetService("Players"),
    CoreGui = game:GetService("CoreGui"),
    StarterGui = game:GetService("StarterGui"),
    UserInput = game:GetService("UserInputService"),
    Tween = pcall(function() return game:GetService("TweenService") end) and game:GetService("TweenService") or nil,
    HttpService = game:GetService("HttpService")
}

local CONFIG = {
    MENU_WIDTH = 400,
    MENU_HEIGHT = 480,
    CREATOR_NAME = "Sickly255",
    ANIM_SPEED = 0.18,
    CONFIRM_MORPH = false,
    SORT_MODE = "name",
    MAX_HISTORY = 10,
    COOLDOWN = 5,
    MAX_CACHE_SIZE = 50,
    DEBOUNCE_TIME = 0.3,
    TAB_BUTTON_WIDTH = 88,
    CARD_HEIGHT = 58,
    CARD_MARGIN = 6,
    CORNER_RADIUS = 8,
    PADDING = 10,
    SCROLLBAR_THICKNESS = 5
}

local player = SERVICES.Players.LocalPlayer
local minimized = false
local draggingTitleBar = false
local dragStart, startPos = nil, nil
local currentTab = "info"
local sortMode = CONFIG.SORT_MODE
local favorites = {}
local playerCache = {}
local cacheOrder = {}
local history = {}
local previewFrame = nil
local previewImage = nil
local lastMorphTime = 0
local canUseTween = SERVICES.Tween ~= nil
local canUseWriteFile = pcall(function() return writefile end)
local lastFoundTarget = nil

local connections = {}
local activeTweens = {}

local function connect(signal, callback)
    local conn = signal:Connect(callback)
    table.insert(connections, conn)
    return conn
end

local function cleanupAll()
    for _, conn in ipairs(connections) do conn:Disconnect() end
    for _, tween in ipairs(activeTweens) do tween:Cancel() end
    connections = {}
    activeTweens = {}
end

-- ==========================================
-- SISTEMA DE TEMAS
-- ==========================================

local function registerThemeObj(obj, role, property)
    if not obj or not role then return end
    table.insert(themeObjects, {obj = obj, role = role, property = property or "BackgroundColor3"})
end

local function updateTabHighlights()
    for name, btn in pairs(tabButtons) do
        if btn and btn:IsA("TextButton") then
            if name == currentTab then
                btn.BackgroundColor3 = COLORS.ACCENT
                btn.TextColor3 = COLORS.WHITE
            else
                btn.BackgroundColor3 = COLORS.MID_GRAY
                btn.TextColor3 = COLORS.TEXT_MAIN
            end
        end
    end
end

local frame
local tabsContainer
local infoContent
local playersScrollFrame
local favoritesScrollFrame
local historyScrollFrame
local skinPaletteScroll
local usernameInput
local searchPlayersBox
local hexInput
local contentContainer

local function applyTheme(themeName)
    if not THEMES[themeName] then return end
    COLORS = THEMES[themeName]
    currentThemeName = themeName
    for _, data in ipairs(themeObjects) do
        local obj, role, prop = data.obj, data.role, data.property
        if COLORS[role] then
            pcall(function() obj[prop] = COLORS[role] end)
        end
    end
    if frame then
        frame.BackgroundColor3 = COLORS.BLACK
        frame.BackgroundTransparency = COLORS.TRANSPARENCY
    end
    if tabsContainer then tabsContainer.ScrollBarImageColor3 = COLORS.SCROLLBAR end
    if infoContent then infoContent.ScrollBarImageColor3 = COLORS.SCROLLBAR end
    if playersScrollFrame then playersScrollFrame.ScrollBarImageColor3 = COLORS.SCROLLBAR end
    if favoritesScrollFrame then favoritesScrollFrame.ScrollBarImageColor3 = COLORS.SCROLLBAR end
    if historyScrollFrame then historyScrollFrame.ScrollBarImageColor3 = COLORS.SCROLLBAR end
    if skinPaletteScroll then skinPaletteScroll.ScrollBarImageColor3 = COLORS.SCROLLBAR end
    updateTabHighlights()
    local textboxes = {usernameInput, searchPlayersBox, hexInput}
    for _, tb in ipairs(textboxes) do
        if tb and tb:IsA("TextBox") then
            tb.PlaceholderColor3 = COLORS.PLACEHOLDER
        end
    end
    sendNotification("🎨 Tema", "Cambiado a: " .. themeName, "")
end

local function cycleTheme()
    local themeNames = {"Glass", "Dark", "Light", "Cyber", "Sunset", "Ocean"}
    local currentIndex = 1
    for i, name in ipairs(themeNames) do
        if name == currentThemeName then currentIndex = i break end
    end
    local nextIndex = (currentIndex % #themeNames) + 1
    applyTheme(themeNames[nextIndex])
end

-- ==========================================
-- 2. FUNCIONES DE UTILIDAD
-- ==========================================

local function sendNotification(title, text, icon)
    local success, err = pcall(function()
        SERVICES.StarterGui:SetCore("SendNotification", {
            Title = title, Text = text, Duration = 5, Icon = icon or ""
        })
    end)
    if not success then warn("[sendNotification] Error: " .. tostring(err)) end
end

local function colorToHex(color)
    return string.format("#%02X%02X%02X", color.R * 255, color.G * 255, color.B * 255)
end

local function animateObject(obj, props, time)
    if canUseTween then
        local tInfo = TweenInfo.new(time or CONFIG.ANIM_SPEED, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
        local tween = SERVICES.Tween:Create(obj, tInfo, props)
        table.insert(activeTweens, tween)
        connect(tween.Completed, function()
            for i, t in ipairs(activeTweens) do
                if t == tween then table.remove(activeTweens, i) break end
            end
        end)
        tween:Play()
    else
        for prop, value in pairs(props) do obj[prop] = value end
    end
end

local function flashButton(btn)
    local originalColor = btn.BackgroundColor3
    animateObject(btn, {BackgroundColor3 = COLORS.WHITE}, 0.08)
    task.wait(0.1)
    animateObject(btn, {BackgroundColor3 = originalColor}, 0.18)
end

local function flashCharacter(character)
    local root = character:FindFirstChild("HumanoidRootPart")
    if not root then return end
    local highlight = Instance.new("SelectionBox")
    highlight.Adornee = root
    highlight.Color3 = COLORS.YELLOW
    highlight.LineThickness = 0.1
    highlight.Transparency = 0.5
    highlight.Parent = root
    animateObject(highlight, {Transparency = 1}, 0.5)
    task.wait(0.5)
    highlight:Destroy()
end

local function addUICorner(parent, radius)
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, radius or CONFIG.CORNER_RADIUS)
    corner.Parent = parent
    return corner
end

local function addUIStroke(parent, color, thickness, transparency)
    local stroke = Instance.new("UIStroke")
    stroke.Color = color or COLORS.STROKE
    stroke.Thickness = thickness or 1.5
    stroke.Transparency = transparency or 0
    stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    stroke.Parent = parent
    return stroke
end

local function addUIPadding(parent, top, bottom, left, right)
    local pad = Instance.new("UIPadding")
    pad.PaddingTop = UDim.new(0, top or CONFIG.PADDING)
    pad.PaddingBottom = UDim.new(0, bottom or CONFIG.PADDING)
    pad.PaddingLeft = UDim.new(0, left or CONFIG.PADDING)
    pad.PaddingRight = UDim.new(0, right or CONFIG.PADDING)
    pad.Parent = parent
    return pad
end

local function createButton(parent, props)
    local btn = Instance.new("TextButton")
    btn.Size = props.Size or UDim2.new(0, 100, 0, 34)
    btn.Position = props.Position or UDim2.new(0, 0, 0, 0)
    btn.Text = props.Text or ""
    btn.Font = props.Font or Enum.Font.GothamBold
    btn.TextSize = props.TextSize or 13
    btn.TextColor3 = COLORS.TEXT_MAIN
    btn.BackgroundColor3 = props.Color or COLORS.MID_GRAY
    btn.BorderSizePixel = 0
    btn.AutoButtonColor = false
    btn.Parent = parent
    addUICorner(btn, props.CornerRadius or CONFIG.CORNER_RADIUS)
    local strokeColor = props.StrokeColor or COLORS.STROKE
    local stroke = addUIStroke(btn, strokeColor, 1, 0.6)
    local colorRole = "MID_GRAY"
    if props.Color == COLORS.LIGHT_GREEN then colorRole = "LIGHT_GREEN"
    elseif props.Color == COLORS.RED then colorRole = "RED"
    elseif props.Color == COLORS.BLUE then colorRole = "BLUE"
    elseif props.Color == COLORS.ACCENT then colorRole = "ACCENT"
    elseif props.Color == COLORS.DARK_GRAY then colorRole = "DARK_GRAY"
    elseif props.Color == COLORS.CARD_BG then colorRole = "CARD_BG"
    end
    registerThemeObj(btn, colorRole, "BackgroundColor3")
    registerThemeObj(btn, "TEXT_MAIN", "TextColor3")
    registerThemeObj(stroke, "STROKE", "Color")
    return btn
end

local function createRoundedFrame(parent, size, pos, color, radius, withStroke)
    local f = Instance.new("Frame")
    f.Size = size or UDim2.new(0, 100, 0, 100)
    f.Position = pos or UDim2.new(0, 0, 0, 0)
    f.BackgroundColor3 = color or COLORS.BLACK
    f.BorderSizePixel = 0
    f.Parent = parent
    addUICorner(f, radius or CONFIG.CORNER_RADIUS)
    if withStroke then
        local s = addUIStroke(f, COLORS.STROKE, 1.5, 0)
        registerThemeObj(s, "STROKE", "Color")
    end
    local colorRole = "BLACK"
    if color == COLORS.DARK_GRAY then colorRole = "DARK_GRAY"
    elseif color == COLORS.MID_GRAY then colorRole = "MID_GRAY"
    elseif color == COLORS.CARD_BG then colorRole = "CARD_BG"
    elseif color == COLORS.SURFACE then colorRole = "SURFACE"
    end
    registerThemeObj(f, colorRole, "BackgroundColor3")
    return f
end

local function loadCooldown()
    if not canUseWriteFile then return 0 end
    local success, data = pcall(function() return readfile("MorphCooldown.txt") end)
    if success and data then return tonumber(data) or 0 end
    return 0
end

local function saveCooldown(time)
    if not canUseWriteFile then return end
    pcall(function() writefile("MorphCooldown.txt", tostring(time)) end)
end

local function checkCooldown()
    local now = os.time()
    if now - lastMorphTime < CONFIG.COOLDOWN then
        sendNotification("⏳ Cooldown", "Espera " .. math.ceil(CONFIG.COOLDOWN - (now - lastMorphTime)) .. " segundos", "")
        return false
    end
    lastMorphTime = now
    saveCooldown(lastMorphTime)
    return true
end

local function addToCache(userId, data)
    if playerCache[userId] then
        for i, id in ipairs(cacheOrder) do
            if id == userId then table.remove(cacheOrder, i) break end
        end
    end
    table.insert(cacheOrder, userId)
    playerCache[userId] = data
    while #cacheOrder > CONFIG.MAX_CACHE_SIZE do
        local oldestId = table.remove(cacheOrder, 1)
        playerCache[oldestId] = nil
    end
end

local function getCachedPlayerData(userId, name, displayName)
    if playerCache[userId] then return playerCache[userId] end
    local data = {UserId = userId, Name = name or "Unknown", DisplayName = displayName or name or "Unknown", Thumbnail = "", Description = nil}
    task.spawn(function()
        local thumbSuccess, thumb = pcall(function()
            return SERVICES.Players:GetUserThumbnailAsync(userId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size100x100)
        end)
        if thumbSuccess then data.Thumbnail = thumb end
    end)
    addToCache(userId, data)
    return data
end

local function saveFavorites()
    if not canUseWriteFile then return end
    local data = {}
    for name, info in pairs(favorites) do
        table.insert(data, {Name = name, UserId = info.UserId, DisplayName = info.DisplayName})
    end
    pcall(function() writefile("MorphFavorites.json", SERVICES.HttpService:JSONEncode(data)) end)
end

local function loadFavorites()
    if not canUseWriteFile then return end
    local success, data = pcall(function() return readfile("MorphFavorites.json") end)
    if not success or not data then return end
    local decoded = SERVICES.HttpService:JSONDecode(data)
    if type(decoded) ~= "table" then return end
    for _, item in ipairs(decoded) do
        if type(item) == "table" and item.UserId and type(item.UserId) == "number" then
            favorites[item.Name] = {UserId = item.UserId, DisplayName = item.DisplayName or item.Name}
        end
    end
end

local function addToHistory(userId, name, displayName)
    for i, entry in ipairs(history) do
        if entry.UserId == userId then table.remove(history, i) break end
    end
    table.insert(history, 1, {UserId = userId, Name = name, DisplayName = displayName, Time = os.time()})
    if #history > CONFIG.MAX_HISTORY then table.remove(history) end
end

local function forceAccessoryOrder(character)
    task.wait(0.5)
    local accessories = {}
    for _, child in ipairs(character:GetChildren()) do
        if child:IsA("Accessory") then table.insert(accessories, child) end
    end
    table.sort(accessories, function(a, b) return a.Name < b.Name end)
    for index, accessory in ipairs(accessories) do
        pcall(function() accessory.Order = index end)
    end
end

-- ==========================================
-- 3. LÓGICA PRINCIPAL
-- ==========================================

local function getDistanceToPlayer(targetPlayer)
    local localChar = player.Character
    local targetChar = targetPlayer.Character
    if not localChar or not targetChar then return math.huge end
    local localRoot = localChar:FindFirstChild("HumanoidRootPart")
    local targetRoot = targetChar:FindFirstChild("HumanoidRootPart")
    if not localRoot or not targetRoot then return math.huge end
    return (localRoot.Position - targetRoot.Position).Magnitude
end

local function sanitizeInput(text)
    if not text or type(text) ~= "string" then return "" end
    text = text:gsub("^%s+", ""):gsub("%s+$", "")
    text = text:sub(1, 50)
    text = text:gsub("[<>\"'%;()]", "")
    return text
end

local function applyMorphEffect(character)
    local rootPart = character:FindFirstChild("HumanoidRootPart")
    if not rootPart then return end
    local particleEmitter = Instance.new("ParticleEmitter")
    particleEmitter.Texture = "rbxassetid://243098098"
    particleEmitter.Rate = 50
    particleEmitter.Speed = NumberRange.new(5, 10)
    particleEmitter.Lifetime = NumberRange.new(0.5, 1)
    particleEmitter.SpreadAngle = Vector2.new(360, 360)
    particleEmitter.Color = ColorSequence.new(COLORS.LIGHT_GREEN)
    particleEmitter.Parent = rootPart
    task.spawn(function()
        task.wait(2)
        particleEmitter.Enabled = false
        task.wait(1)
        particleEmitter:Destroy()
    end)
end

local function safeGetHumanoidDescription(userId)
    local success, result = pcall(function() return SERVICES.Players:GetHumanoidDescriptionFromUserId(userId) end)
    if not success or not result then return nil end
    return result
end

local function findPlayerByName(partialName)
    if not partialName or partialName == "" then return nil end
    local searchName = sanitizeInput(partialName):lower()
    local onlineMatch = nil
    for _, v in ipairs(SERVICES.Players:GetPlayers()) do
        local nameLower = v.Name:lower()
        local dNameLower = v.DisplayName:lower()
        if nameLower == searchName or dNameLower == searchName then return v end
        if not onlineMatch and (nameLower:sub(1, #searchName) == searchName or dNameLower:sub(1, #searchName) == searchName) then
            onlineMatch = v
        end
    end
    if onlineMatch then return onlineMatch end
    local success, userId = pcall(function() return SERVICES.Players:GetUserIdFromNameAsync(searchName) end)
    if success and userId then return getCachedPlayerData(userId, searchName) end
    return nil
end

local function findPlayerById(userId)
    if not userId or type(userId) ~= "number" then return nil end
    for _, v in ipairs(SERVICES.Players:GetPlayers()) do
        if v.UserId == userId then return v end
    end
    return getCachedPlayerData(userId)
end

local function validateMorphTarget(target)
    if not target then sendNotification("👤 Morph Avatar", "No target found!", "") return false end
    local userId = target.UserId or (type(target) == "number" and target or target.UserId)
    if userId == player.UserId then sendNotification("👤 Morph Avatar", "Cannot morph to yourself!", "") return false end
    if target.Name and target.Name:lower() == "sickly255" then sendNotification("👤 Morph Avatar", "No se puede morphear a este usuario!", "") return false end
    if not checkCooldown() then return false end
    return true
end

local function getTargetDescription(target, userId)
    local desc = nil
    if typeof(target) == "Instance" and target:IsA("Player") then
        local targetChar = target.Character
        if targetChar then
            local targetHum = targetChar:FindFirstChild("Humanoid")
            if targetHum then pcall(function() desc = targetHum:GetAppliedDescription() end) end
        end
    end
    if not desc then
        local cached = playerCache[userId]
        if cached and cached.Description then
            desc = cached.Description
        else
            desc = safeGetHumanoidDescription(userId)
            if desc and not playerCache[userId] then addToCache(userId, {UserId = userId, Name = target.Name or "Unknown"}) end
            if playerCache[userId] then playerCache[userId].Description = desc end
        end
    end
    return desc
end

local function morphToPlayer(target)
    if not validateMorphTarget(target) then return end
    local userId = target.UserId or (type(target) == "number" and target or target.UserId)
    local targetName = target.Name or "Unknown"
    local character = player.Character or player.CharacterAdded:Wait()
    local humanoid = character:WaitForChild("Humanoid", 10)
    local rootPart = character:FindFirstChild("HumanoidRootPart")
    if not humanoid or not rootPart then sendNotification("👤 Morph Avatar", "Failed to find humanoid!", "") return end

    local savedCFrame = rootPart.CFrame
    local savedAnchor = rootPart.Anchored
    rootPart.Anchored = true
    local desc = getTargetDescription(target, userId)
    if not desc then
        rootPart.Anchored = savedAnchor
        sendNotification("👤 Morph Avatar", "Failed to load avatar data!", "")
        return
    end

    local applySuccess = pcall(function()
        if humanoid.ApplyDescriptionClientServer then humanoid:ApplyDescriptionClientServer(desc)
        else humanoid:ApplyDescription(desc) end
    end)
    rootPart.CFrame = savedCFrame
    rootPart.Anchored = savedAnchor

    if applySuccess then
        applyMorphEffect(character)
        flashCharacter(character)
        addToHistory(userId, targetName, target.DisplayName or targetName)
        sendNotification("👤 Morph Avatar", "Morphed to " .. targetName .. "!", "")
        task.spawn(forceAccessoryOrder, character)
    else
        sendNotification("👤 Morph Avatar", "Failed to apply morph!", "")
    end
end

local function copyBodyObjects(target, options)
    if not target then return end
    local userId = target.UserId or (type(target) == "number" and target or target.UserId)
    if userId == player.UserId then sendNotification("📋 Copy Objects", "Cannot copy from yourself!", "") return end
    if target.Name and target.Name:lower() == "sickly255" then sendNotification("📋 Copy Objects", "No se puede copiar a este usuario!", "") return end

    local character = player.Character or player.CharacterAdded:Wait()
    local humanoid = character:WaitForChild("Humanoid", 10)
    local rootPart = character:FindFirstChild("HumanoidRootPart")
    if not humanoid or not rootPart then return end
    local savedCFrame = rootPart.CFrame

    local targetDesc = nil
    if typeof(target) == "Instance" and target:IsA("Player") and target.Character then
        local tHum = target.Character:FindFirstChild("Humanoid")
        if tHum then pcall(function() targetDesc = tHum:GetAppliedDescription() end) end
    end
    if not targetDesc then
        local cached = playerCache[userId]
        if cached and cached.Description then targetDesc = cached.Description
        else pcall(function() targetDesc = SERVICES.Players:GetHumanoidDescriptionFromUserId(userId) end) end
    end
    if not targetDesc then sendNotification("📋 Copy Objects", "Failed to get target data!", "") return end

    local localDesc = nil
    pcall(function() localDesc = humanoid:GetAppliedDescription() end)
    if localDesc and options then
        if not options.clothes then targetDesc.Shirt = localDesc.Shirt targetDesc.Pants = localDesc.Pants end
        if not options.skin then
            targetDesc.HeadColor = localDesc.HeadColor targetDesc.TorsoColor = localDesc.TorsoColor
            targetDesc.LeftArmColor = localDesc.LeftArmColor targetDesc.RightArmColor = localDesc.RightArmColor
            targetDesc.LeftLegColor = localDesc.LeftLegColor targetDesc.RightLegColor = localDesc.RightLegColor
        end
        if not options.shape then
            targetDesc.BodyTypeScale = localDesc.BodyTypeScale targetDesc.DepthScale = localDesc.DepthScale
            targetDesc.HeadScale = localDesc.HeadScale targetDesc.HeightScale = localDesc.HeightScale
            targetDesc.ProportionScale = localDesc.ProportionScale targetDesc.WidthScale = localDesc.WidthScale
        end
    end

    local applySuccess = pcall(function()
        if humanoid.ApplyDescriptionClientServer then humanoid:ApplyDescriptionClientServer(targetDesc)
        else humanoid:ApplyDescription(targetDesc) end
    end)
    rootPart.CFrame = savedCFrame
    if applySuccess then
        applyMorphEffect(character)
        flashCharacter(character)
        sendNotification("✅ Success", "📦 Body objects copied!", "")
        task.spawn(forceAccessoryOrder, character)
    else
        sendNotification("❌ Error", "Failed to copy objects", "")
    end
end

-- ==========================================
-- 4. CONSTRUCCIÓN DE LA INTERFAZ
-- ==========================================

local guiParent = SERVICES.CoreGui
if not SERVICES.CoreGui or not pcall(function() return SERVICES.CoreGui:FindFirstChild("Dummy") end) then
    guiParent = player:FindFirstChild("PlayerGui")
    if not guiParent then guiParent = Instance.new("ScreenGui", player) end
end

if guiParent:FindFirstChild("MorphAvatarByKuramaMod") then
    guiParent["MorphAvatarByKuramaMod"]:Destroy()
end

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "MorphAvatarByKuramaMod"
screenGui.ResetOnSpawn = false
screenGui.DisplayOrder = 999999
screenGui.Parent = guiParent
screenGui.Enabled = true

-- FRAME PRINCIPAL
frame = Instance.new("Frame")
frame.Size = UDim2.new(0, CONFIG.MENU_WIDTH, 0, CONFIG.MENU_HEIGHT)
frame.Position = UDim2.new(0.5, -(CONFIG.MENU_WIDTH / 2), 0.5, -(CONFIG.MENU_HEIGHT / 2))
frame.BackgroundColor3 = COLORS.BLACK
frame.BackgroundTransparency = COLORS.TRANSPARENCY
frame.BorderSizePixel = 0
frame.Active = true
frame.ClipsDescendants = true
frame.Parent = screenGui
addUICorner(frame, 12)
local frameStroke = addUIStroke(frame, COLORS.STROKE, 2, 0)
registerThemeObj(frameStroke, "STROKE", "Color")
registerThemeObj(frame, "BLACK", "BackgroundColor3")

-- BARRA DE TÍTULO
local titleBar = Instance.new("Frame")
titleBar.Size = UDim2.new(1, 0, 0, 48)
titleBar.Position = UDim2.new(0, 0, 0, 0)
titleBar.BackgroundColor3 = COLORS.SURFACE
titleBar.BorderSizePixel = 0
titleBar.Parent = frame
titleBar.Active = true
addUICorner(titleBar, 12)
registerThemeObj(titleBar, "SURFACE", "BackgroundColor3")

local titleBarBottom = Instance.new("Frame")
titleBarBottom.Size = UDim2.new(1, 0, 0, 12)
titleBarBottom.Position = UDim2.new(0, 0, 1, -12)
titleBarBottom.BackgroundColor3 = COLORS.SURFACE
titleBarBottom.BorderSizePixel = 0
titleBarBottom.Parent = titleBar
registerThemeObj(titleBarBottom, "SURFACE", "BackgroundColor3")

local titleBarDivider = Instance.new("Frame")
titleBarDivider.Size = UDim2.new(1, 0, 0, 1)
titleBarDivider.Position = UDim2.new(0, 0, 1, 0)
titleBarDivider.BackgroundColor3 = COLORS.STROKE
titleBarDivider.BorderSizePixel = 0
titleBarDivider.Parent = titleBar
registerThemeObj(titleBarDivider, "STROKE", "BackgroundColor3")

local titleDot = Instance.new("Frame")
titleDot.Size = UDim2.new(0, 6, 0, 6)
titleDot.Position = UDim2.new(0, 14, 0.5, -3)
titleDot.BackgroundColor3 = COLORS.ACCENT
titleDot.BorderSizePixel = 0
titleDot.Parent = titleBar
addUICorner(titleDot, 3)
registerThemeObj(titleDot, "ACCENT", "BackgroundColor3")

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -180, 1, 0)
title.Position = UDim2.new(0, 28, 0, 0)
title.Text = "Morph Avatar Pro"
title.TextColor3 = COLORS.TEXT_MAIN
title.BackgroundTransparency = 1
title.BorderSizePixel = 0
title.Font = Enum.Font.GothamBold
title.TextSize = 16
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = titleBar
registerThemeObj(title, "TEXT_MAIN", "TextColor3")

local titleVersion = Instance.new("TextLabel")
titleVersion.Size = UDim2.new(0, 60, 0, 16)
titleVersion.Position = UDim2.new(0, 28, 0.5, 4)
titleVersion.Text = "v2.1.9"
titleVersion.TextColor3 = COLORS.TEXT_DIM
titleVersion.BackgroundTransparency = 1
titleVersion.BorderSizePixel = 0
titleVersion.Font = Enum.Font.Gotham
titleVersion.TextSize = 10
titleVersion.TextXAlignment = Enum.TextXAlignment.Left
titleVersion.Parent = titleBar
registerThemeObj(titleVersion, "TEXT_DIM", "TextColor3")

local titleButtonsContainer = Instance.new("Frame")
titleButtonsContainer.Size = UDim2.new(0, 128, 0, 34)
titleButtonsContainer.Position = UDim2.new(1, -136, 0.5, -17)
titleButtonsContainer.BackgroundTransparency = 1
titleButtonsContainer.BorderSizePixel = 0
titleButtonsContainer.Parent = titleBar

local titleButtonsLayout = Instance.new("UIListLayout")
titleButtonsLayout.FillDirection = Enum.FillDirection.Horizontal
titleButtonsLayout.HorizontalAlignment = Enum.HorizontalAlignment.Right
titleButtonsLayout.VerticalAlignment = Enum.VerticalAlignment.Center
titleButtonsLayout.Padding = UDim.new(0, 6)
titleButtonsLayout.Parent = titleButtonsContainer

local themeBtn = createButton(titleButtonsContainer, {
    Size = UDim2.new(0, 34, 0, 32),
    Text = "🎨",
    TextSize = 15,
    Color = COLORS.MID_GRAY
})

local miniBtn = createButton(titleButtonsContainer, {
    Size = UDim2.new(0, 34, 0, 32),
    Text = "−",
    TextSize = 18,
    Color = COLORS.MID_GRAY
})

local closeBtn = createButton(titleButtonsContainer, {
    Size = UDim2.new(0, 34, 0, 32),
    Text = "✕",
    TextSize = 14,
    Color = COLORS.RED
})

-- BARRA DE PESTAÑAS
tabsContainer = Instance.new("ScrollingFrame")
tabsContainer.Size = UDim2.new(1, -20, 0, 38)
tabsContainer.Position = UDim2.new(0, 10, 0, 54)
tabsContainer.BackgroundColor3 = COLORS.SURFACE
tabsContainer.BorderSizePixel = 0
tabsContainer.ScrollBarThickness = CONFIG.SCROLLBAR_THICKNESS
tabsContainer.ScrollBarImageColor3 = COLORS.SCROLLBAR
tabsContainer.ScrollingDirection = Enum.ScrollingDirection.X
tabsContainer.ScrollingEnabled = true
tabsContainer.CanvasSize = UDim2.new(0, 0, 0, 0)
tabsContainer.Parent = frame
addUICorner(tabsContainer, CONFIG.CORNER_RADIUS)
local tabsStroke = addUIStroke(tabsContainer, COLORS.STROKE, 1.5, 0)
registerThemeObj(tabsStroke, "STROKE", "Color")
registerThemeObj(tabsContainer, "SURFACE", "BackgroundColor3")

local tabsLayout = Instance.new("UIListLayout")
tabsLayout.FillDirection = Enum.FillDirection.Horizontal
tabsLayout.HorizontalAlignment = Enum.HorizontalAlignment.Left
tabsLayout.VerticalAlignment = Enum.VerticalAlignment.Center
tabsLayout.Padding = UDim.new(0, 4)
tabsLayout.Parent = tabsContainer

local tabsPadding = Instance.new("UIPadding")
tabsPadding.PaddingLeft = UDim.new(0, 4)
tabsPadding.PaddingRight = UDim.new(0, 4)
tabsPadding.Parent = tabsContainer

local function createTab(name, icon)
    local btn = createButton(tabsContainer, {
        Size = UDim2.new(0, CONFIG.TAB_BUTTON_WIDTH, 0, 30),
        Text = icon .. "  " .. name,
        TextSize = 11,
        Color = (name:lower() == currentTab) and COLORS.ACCENT or COLORS.MID_GRAY,
        CornerRadius = 6
    })
    tabButtons[name:lower()] = btn
    return btn
end

local infoTab     = createTab("Info", "ℹ")
local searchTab   = createTab("Search", "🔍")
local playersTab  = createTab("Players", "👥")
local favoritesTab = createTab("Favorites", "⭐")
local skinTab     = createTab("Skin", "🎨")
local historyTab  = createTab("History", "🕒")

local function updateTabsCanvasSize()
    task.wait()
    tabsContainer.CanvasSize = UDim2.new(0, tabsLayout.AbsoluteContentSize.X + 16, 0, 0)
end
updateTabsCanvasSize()

-- CONTENEDOR PRINCIPAL
contentContainer = Instance.new("Frame")
contentContainer.Size = UDim2.new(1, -20, 1, -108)
contentContainer.Position = UDim2.new(0, 10, 0, 100)
contentContainer.BackgroundTransparency = 1
contentContainer.BorderSizePixel = 0
contentContainer.Parent = frame

-- ==========================================
-- PESTAÑA INFO
-- ==========================================

infoContent = Instance.new("ScrollingFrame")
infoContent.Name = "infoContent"
infoContent.Size = UDim2.new(1, 0, 1, 0)
infoContent.BackgroundColor3 = COLORS.SURFACE
infoContent.BorderSizePixel = 0
infoContent.ScrollBarThickness = CONFIG.SCROLLBAR_THICKNESS
infoContent.ScrollBarImageColor3 = COLORS.SCROLLBAR
infoContent.Visible = true
infoContent.Parent = contentContainer
infoContent.ScrollingDirection = Enum.ScrollingDirection.Y
addUICorner(infoContent, CONFIG.CORNER_RADIUS)
local infoStroke = addUIStroke(infoContent, COLORS.STROKE, 1.5, 0)
registerThemeObj(infoStroke, "STROKE", "Color")
registerThemeObj(infoContent, "SURFACE", "BackgroundColor3")

addUIPadding(infoContent, 14, 14, 14, 14)

local infoContentLabel = Instance.new("TextLabel")
infoContentLabel.Size = UDim2.new(1, -28, 0, 0)
infoContentLabel.AutomaticSize = Enum.AutomaticSize.Y
infoContentLabel.Position = UDim2.new(0, 0, 0, 0)
infoContentLabel.BackgroundTransparency = 1
infoContentLabel.TextColor3 = COLORS.TEXT_MAIN
infoContentLabel.Font = Enum.Font.Gotham
infoContentLabel.TextSize = 12
infoContentLabel.TextWrapped = true
infoContentLabel.TextXAlignment = Enum.TextXAlignment.Left
infoContentLabel.TextYAlignment = Enum.TextYAlignment.Top
infoContentLabel.LineHeight = 1.4
infoContentLabel.Text = [[📝 REGISTRO DE CAMBIOS (v2.1.9)
📅 Fecha: 14 Abril, 2026

🆕 NUEVAS FUNCIONALIDADES
🔍 Nuevo flujo de búsqueda: Search -> Preview -> Morph
🖼️ Tarjeta de resultados con Thumbnail, Username, Display Name e ID
🕒 Historial mejorado: ahora muestra Display Name
⭐ Favoritos guardados automáticamente (si el executor lo permite)
🎨 Sistema de 6 temas visuales (Glass, Dark, Light, Cyber, Sunset, Ocean)
🌈 Paleta de colores de piel con 56 tonos predefinidos
🔢 Entrada hexadecimal funcional con preview en tiempo real
⌨️ Atajos de teclado: Ctrl+M (morfear), Ctrl+F (enfocar búsqueda)
✨ FIX v2.1.5: Orden de Accesorios Forzado

⚡ MEJORAS DE RENDIMIENTO Y UI
📱 Pestañas con scroll horizontal (compatible con móvil)
💡 Feedback visual en botones y personaje al morphear
🔔 Notificaciones nativas de Roblox
🪟 Ventana minimizable, arrastrable y con botón de cierre X
🧹 Limpieza de UI: Eliminados botones redundantes
🔒 Botón de búsqueda anclado al fondo de la pestaña
📝 Registro de cambios con separación visual entre secciones
🎨 Fix visual del input Hexadecimal (espaciado corregido)

🛡️ SEGURIDAD Y ESTABILIDAD
🚫 Protección contra errores de API
✅ Validación de entradas de usuario
⏳ Cooldown anti-spam en botones de morph
🛠️ Fallback automático si CoreGui está bloqueado
🚑 MORPH SEGURO: Previene caídas y clips

🐛 CORRECCIONES DE BUGS (v2.1.9)
✅ FIX CRÍTICO: Botón Morph ya no tapa el estado Online/Offline
✅ FIX CRÍTICO: Display Name ahora se muestra correctamente
✅ FIX CRÍTICO: Tabs se mantienen activos al cambiar de tema
✅ FIX CRÍTICO: Placeholders visibles en todos los temas
✅ Arreglado: Overflow de texto en pestaña Info
✅ Arreglado: Error IsA al buscar jugadores offline
✅ Arreglado: Lista de jugadores se actualiza sin duplicados
✅ Arreglado: Historial no guarda duplicados del mismo usuario
✅ Arreglado: Scroll de pestañas funciona en todas las resoluciones
✅ Arreglado: Cooldown se mantiene entre recargas (si hay writefile)

🤝 SOPORTE
✅ Compatible con R6 y R15
✅ Funciona en la mayoría de executors (PC y móvil)
✅ Actualizaciones automáticas de lista de jugadores

📜 CRÉDITOS
Desarrollo original: @sickly255 (SAGE)
Versión con temas + fixes: v2.1.9
Basado en feedback de la comunidad
]]
infoContentLabel.Parent = infoContent
registerThemeObj(infoContentLabel, "TEXT_MAIN", "TextColor3")

local function updateInfoCanvasSize()
    task.wait(0.1)
    local labelHeight = infoContentLabel.AbsoluteSize.Y
    infoContent.CanvasSize = UDim2.new(0, 0, 0, labelHeight + 32)
end

infoContentLabel:GetPropertyChangedSignal("AbsoluteSize"):Connect(updateInfoCanvasSize)
task.spawn(function()
    for i = 1, 5 do
        task.wait(0.1)
        if infoContentLabel.AbsoluteSize.Y > 0 then updateInfoCanvasSize() break end
    end
end)

-- ==========================================
-- PESTAÑA SEARCH
-- ==========================================

local searchContent = Instance.new("Frame")
searchContent.Name = "searchContent"
searchContent.Size = UDim2.new(1, 0, 1, 0)
searchContent.BackgroundTransparency = 1
searchContent.Parent = contentContainer
searchContent.Visible = false

-- Warning Banner
local searchWarningLabel = Instance.new("TextLabel")
searchWarningLabel.Size = UDim2.new(1, 0, 0, 38)
searchWarningLabel.Position = UDim2.new(0, 0, 0, 0)
searchWarningLabel.BackgroundColor3 = Color3.fromRGB(180, 50, 50)
searchWarningLabel.BackgroundTransparency = 0
searchWarningLabel.BorderSizePixel = 0
searchWarningLabel.Text = "⚠  Bug conocido: Copiar avatares puede enviar al jugador bajo el piso"
searchWarningLabel.TextColor3 = Color3.fromRGB(255, 235, 235)
searchWarningLabel.Font = Enum.Font.GothamBold
searchWarningLabel.TextSize = 11
searchWarningLabel.TextWrapped = true
searchWarningLabel.TextXAlignment = Enum.TextXAlignment.Left
searchWarningLabel.TextYAlignment = Enum.TextYAlignment.Center
searchWarningLabel.Parent = searchContent
addUICorner(searchWarningLabel, 7)
addUIPadding(searchWarningLabel, 0, 0, 10, 10)

local searchLabel = Instance.new("TextLabel")
searchLabel.Size = UDim2.new(1, 0, 0, 20)
searchLabel.Position = UDim2.new(0, 0, 0, 46)
searchLabel.Text = "Username or ID"
searchLabel.TextColor3 = COLORS.TEXT_DIM
searchLabel.BackgroundTransparency = 1
searchLabel.Font = Enum.Font.GothamBold
searchLabel.TextSize = 11
searchLabel.TextXAlignment = Enum.TextXAlignment.Left
searchLabel.Parent = searchContent
registerThemeObj(searchLabel, "TEXT_DIM", "TextColor3")

-- Input Row
local searchInputContainer = Instance.new("Frame")
searchInputContainer.Size = UDim2.new(1, 0, 0, 40)
searchInputContainer.Position = UDim2.new(0, 0, 0, 70)
searchInputContainer.BackgroundColor3 = COLORS.DARK_GRAY
searchInputContainer.BorderSizePixel = 0
searchInputContainer.Parent = searchContent
addUICorner(searchInputContainer, CONFIG.CORNER_RADIUS)
local inputStroke = addUIStroke(searchInputContainer, COLORS.STROKE, 1.5, 0)
registerThemeObj(inputStroke, "STROKE", "Color")
registerThemeObj(searchInputContainer, "DARK_GRAY", "BackgroundColor3")

usernameInput = Instance.new("TextBox")
usernameInput.Size = UDim2.new(1, -16, 1, 0)
usernameInput.Position = UDim2.new(0, 8, 0, 0)
usernameInput.PlaceholderText = "Type username or ID..."
usernameInput.Font = Enum.Font.Gotham
usernameInput.TextSize = 14
usernameInput.Text = ""
usernameInput.TextColor3 = COLORS.TEXT_MAIN
usernameInput.PlaceholderColor3 = COLORS.PLACEHOLDER
usernameInput.BackgroundTransparency = 1
usernameInput.BorderSizePixel = 0
usernameInput.ClearTextOnFocus = false
usernameInput.TextWrapped = false
usernameInput.TextXAlignment = Enum.TextXAlignment.Left
usernameInput.Parent = searchInputContainer
registerThemeObj(usernameInput, "TEXT_MAIN", "TextColor3")

-- Result Card
local searchResultContainer = Instance.new("Frame")
searchResultContainer.Name = "searchResultContainer"
searchResultContainer.Size = UDim2.new(1, 0, 0, 108)
searchResultContainer.Position = UDim2.new(0, 0, 0, 118)
searchResultContainer.BackgroundColor3 = COLORS.CARD_BG
searchResultContainer.BorderSizePixel = 0
searchResultContainer.Visible = false
searchResultContainer.Parent = searchContent
addUICorner(searchResultContainer, CONFIG.CORNER_RADIUS)
local resultStroke = addUIStroke(searchResultContainer, COLORS.STROKE, 1.5, 0)
registerThemeObj(resultStroke, "STROKE", "Color")
registerThemeObj(searchResultContainer, "CARD_BG", "BackgroundColor3")

-- Avatar image with border
local avatarBorderFrame = Instance.new("Frame")
avatarBorderFrame.Size = UDim2.new(0, 72, 0, 72)
avatarBorderFrame.Position = UDim2.new(0, 12, 0.5, -36)
avatarBorderFrame.BackgroundColor3 = COLORS.ACCENT
avatarBorderFrame.BorderSizePixel = 0
avatarBorderFrame.Parent = searchResultContainer
addUICorner(avatarBorderFrame, 9)
registerThemeObj(avatarBorderFrame, "ACCENT", "BackgroundColor3")

local searchResultImage = Instance.new("ImageLabel")
searchResultImage.Size = UDim2.new(1, -4, 1, -4)
searchResultImage.Position = UDim2.new(0, 2, 0, 2)
searchResultImage.BackgroundColor3 = COLORS.DARK_GRAY
searchResultImage.BorderSizePixel = 0
searchResultImage.Image = ""
searchResultImage.Parent = avatarBorderFrame
addUICorner(searchResultImage, 7)
registerThemeObj(searchResultImage, "DARK_GRAY", "BackgroundColor3")

-- Info stack
local resultInfoStack = Instance.new("Frame")
resultInfoStack.Size = UDim2.new(1, -104, 1, 0)
resultInfoStack.Position = UDim2.new(0, 96, 0, 0)
resultInfoStack.BackgroundTransparency = 1
resultInfoStack.BorderSizePixel = 0
resultInfoStack.Parent = searchResultContainer

local searchResultName = Instance.new("TextLabel")
searchResultName.Size = UDim2.new(1, -10, 0, 22)
searchResultName.Position = UDim2.new(0, 0, 0, 10)
searchResultName.Text = ""
searchResultName.TextColor3 = COLORS.TEXT_MAIN
searchResultName.BackgroundTransparency = 1
searchResultName.Font = Enum.Font.GothamBold
searchResultName.TextSize = 15
searchResultName.TextXAlignment = Enum.TextXAlignment.Left
searchResultName.TextTruncate = Enum.TextTruncate.AtEnd
searchResultName.Parent = resultInfoStack
registerThemeObj(searchResultName, "TEXT_MAIN", "TextColor3")

local searchResultDisplayName = Instance.new("TextLabel")
searchResultDisplayName.Size = UDim2.new(1, -10, 0, 17)
searchResultDisplayName.Position = UDim2.new(0, 0, 0, 33)
searchResultDisplayName.Text = ""
searchResultDisplayName.TextColor3 = COLORS.TEXT_DIM
searchResultDisplayName.BackgroundTransparency = 1
searchResultDisplayName.Font = Enum.Font.Gotham
searchResultDisplayName.TextSize = 12
searchResultDisplayName.TextXAlignment = Enum.TextXAlignment.Left
searchResultDisplayName.TextTruncate = Enum.TextTruncate.AtEnd
searchResultDisplayName.Parent = resultInfoStack
registerThemeObj(searchResultDisplayName, "TEXT_DIM", "TextColor3")

local searchResultId = Instance.new("TextLabel")
searchResultId.Size = UDim2.new(1, -10, 0, 15)
searchResultId.Position = UDim2.new(0, 0, 0, 52)
searchResultId.Text = ""
searchResultId.TextColor3 = COLORS.ACCENT
searchResultId.BackgroundTransparency = 1
searchResultId.Font = Enum.Font.Gotham
searchResultId.TextSize = 11
searchResultId.TextXAlignment = Enum.TextXAlignment.Left
searchResultId.Parent = resultInfoStack
registerThemeObj(searchResultId, "ACCENT", "TextColor3")

local searchResultStatus = Instance.new("TextLabel")
searchResultStatus.Size = UDim2.new(0, 80, 0, 17)
searchResultStatus.Position = UDim2.new(1, -88, 0, 10)
searchResultStatus.Text = "🔴 Offline"
searchResultStatus.TextColor3 = COLORS.TEXT_DIM
searchResultStatus.BackgroundTransparency = 1
searchResultStatus.Font = Enum.Font.GothamBold
searchResultStatus.TextSize = 11
searchResultStatus.TextXAlignment = Enum.TextXAlignment.Right
searchResultStatus.Parent = searchResultContainer
registerThemeObj(searchResultStatus, "TEXT_DIM", "TextColor3")

local confirmMorphBtn = createButton(searchResultContainer, {
    Size = UDim2.new(0, 80, 0, 32),
    Position = UDim2.new(1, -92, 1, -42),
    Text = "✅ Morph",
    TextSize = 12,
    Color = COLORS.LIGHT_GREEN,
    CornerRadius = 7
})

-- Search Button anchored to bottom
local searchBtn = createButton(searchContent, {
    Size = UDim2.new(1, 0, 0, 42),
    Position = UDim2.new(0, 0, 1, -46),
    Text = "🔍  Search Player",
    TextSize = 15,
    Color = COLORS.BLUE,
    CornerRadius = CONFIG.CORNER_RADIUS
})

-- ==========================================
-- PESTAÑA PLAYERS
-- ==========================================

local playersContent = Instance.new("Frame")
playersContent.Name = "playersContent"
playersContent.Size = UDim2.new(1, 0, 1, 0)
playersContent.BackgroundTransparency = 1
playersContent.Parent = contentContainer
playersContent.Visible = false

local playersWarningLabel = Instance.new("TextLabel")
playersWarningLabel.Size = UDim2.new(1, 0, 0, 38)
playersWarningLabel.Position = UDim2.new(0, 0, 0, 0)
playersWarningLabel.BackgroundColor3 = Color3.fromRGB(180, 50, 50)
playersWarningLabel.BackgroundTransparency = 0
playersWarningLabel.BorderSizePixel = 0
playersWarningLabel.Text = "⚠  Bug conocido: Copiar avatares puede enviar al jugador bajo el piso"
playersWarningLabel.TextColor3 = Color3.fromRGB(255, 235, 235)
playersWarningLabel.Font = Enum.Font.GothamBold
playersWarningLabel.TextSize = 11
playersWarningLabel.TextWrapped = true
playersWarningLabel.TextXAlignment = Enum.TextXAlignment.Left
playersWarningLabel.TextYAlignment = Enum.TextYAlignment.Center
playersWarningLabel.Parent = playersContent
addUICorner(playersWarningLabel, 7)
addUIPadding(playersWarningLabel, 0, 0, 10, 10)

-- Filter/Sort bar
local playersTopBar = Instance.new("Frame")
playersTopBar.Size = UDim2.new(1, 0, 0, 36)
playersTopBar.Position = UDim2.new(0, 0, 0, 45)
playersTopBar.BackgroundColor3 = COLORS.SURFACE
playersTopBar.BorderSizePixel = 0
playersTopBar.Parent = playersContent
addUICorner(playersTopBar, 7)
local topBarStroke = addUIStroke(playersTopBar, COLORS.STROKE, 1.5, 0)
registerThemeObj(topBarStroke, "STROKE", "Color")
registerThemeObj(playersTopBar, "SURFACE", "BackgroundColor3")

local searchBoxContainer = Instance.new("Frame")
searchBoxContainer.Size = UDim2.new(0.68, -4, 0, 26)
searchBoxContainer.Position = UDim2.new(0, 6, 0.5, -13)
searchBoxContainer.BackgroundColor3 = COLORS.MID_GRAY
searchBoxContainer.BorderSizePixel = 0
searchBoxContainer.Parent = playersTopBar
addUICorner(searchBoxContainer, 6)
local searchBoxStroke = addUIStroke(searchBoxContainer, COLORS.STROKE, 1, 0)
registerThemeObj(searchBoxStroke, "STROKE", "Color")
registerThemeObj(searchBoxContainer, "MID_GRAY", "BackgroundColor3")

searchPlayersBox = Instance.new("TextBox")
searchPlayersBox.Size = UDim2.new(1, -10, 1, 0)
searchPlayersBox.Position = UDim2.new(0, 5, 0, 0)
searchPlayersBox.BackgroundTransparency = 1
searchPlayersBox.TextColor3 = COLORS.TEXT_MAIN
searchPlayersBox.PlaceholderColor3 = COLORS.PLACEHOLDER
searchPlayersBox.PlaceholderText = "🔍  Filter players..."
searchPlayersBox.Font = Enum.Font.Gotham
searchPlayersBox.TextSize = 12
searchPlayersBox.BorderSizePixel = 0
searchPlayersBox.Text = ""
searchPlayersBox.ClearTextOnFocus = true
searchPlayersBox.TextXAlignment = Enum.TextXAlignment.Left
searchPlayersBox.Parent = searchBoxContainer
registerThemeObj(searchPlayersBox, "TEXT_MAIN", "TextColor3")

local sortBtn = createButton(playersTopBar, {
    Size = UDim2.new(0.32, -8, 0, 26),
    Position = UDim2.new(0.68, 2, 0.5, -13),
    Text = "🔤 Name",
    TextSize = 11,
    Color = COLORS.MID_GRAY,
    CornerRadius = 6
})

playersScrollFrame = Instance.new("ScrollingFrame")
playersScrollFrame.Size = UDim2.new(1, 0, 1, -88)
playersScrollFrame.Position = UDim2.new(0, 0, 0, 88)
playersScrollFrame.BackgroundColor3 = COLORS.SURFACE
playersScrollFrame.BorderSizePixel = 0
playersScrollFrame.ScrollBarThickness = CONFIG.SCROLLBAR_THICKNESS
playersScrollFrame.ScrollBarImageColor3 = COLORS.SCROLLBAR
playersScrollFrame.Parent = playersContent
addUICorner(playersScrollFrame, CONFIG.CORNER_RADIUS)
local psStroke = addUIStroke(playersScrollFrame, COLORS.STROKE, 1.5, 0)
registerThemeObj(psStroke, "STROKE", "Color")
registerThemeObj(playersScrollFrame, "SURFACE", "BackgroundColor3")

local playersLayout = Instance.new("UIListLayout")
playersLayout.Padding = UDim.new(0, CONFIG.CARD_MARGIN)
playersLayout.SortOrder = Enum.SortOrder.LayoutOrder
playersLayout.Parent = playersScrollFrame

local playersScrollPadding = Instance.new("UIPadding")
playersScrollPadding.PaddingTop = UDim.new(0, 6)
playersScrollPadding.PaddingBottom = UDim.new(0, 6)
playersScrollPadding.PaddingLeft = UDim.new(0, 6)
playersScrollPadding.PaddingRight = UDim.new(0, 6)
playersScrollPadding.Parent = playersScrollFrame

-- ==========================================
-- PESTAÑA FAVORITES
-- ==========================================

local favoritesContent = Instance.new("Frame")
favoritesContent.Name = "favoritesContent"
favoritesContent.Size = UDim2.new(1, 0, 1, 0)
favoritesContent.BackgroundTransparency = 1
favoritesContent.Parent = contentContainer
favoritesContent.Visible = false

favoritesScrollFrame = Instance.new("ScrollingFrame")
favoritesScrollFrame.Size = UDim2.new(1, 0, 1, 0)
favoritesScrollFrame.BackgroundColor3 = COLORS.SURFACE
favoritesScrollFrame.BorderSizePixel = 0
favoritesScrollFrame.ScrollBarThickness = CONFIG.SCROLLBAR_THICKNESS
favoritesScrollFrame.ScrollBarImageColor3 = COLORS.SCROLLBAR
favoritesScrollFrame.Parent = favoritesContent
addUICorner(favoritesScrollFrame, CONFIG.CORNER_RADIUS)
local fsStroke = addUIStroke(favoritesScrollFrame, COLORS.STROKE, 1.5, 0)
registerThemeObj(fsStroke, "STROKE", "Color")
registerThemeObj(favoritesScrollFrame, "SURFACE", "BackgroundColor3")

local favoritesLayout = Instance.new("UIListLayout")
favoritesLayout.Padding = UDim.new(0, CONFIG.CARD_MARGIN)
favoritesLayout.SortOrder = Enum.SortOrder.Name
favoritesLayout.Parent = favoritesScrollFrame

local favScrollPad = Instance.new("UIPadding")
favScrollPad.PaddingTop = UDim.new(0, 6)
favScrollPad.PaddingBottom = UDim.new(0, 6)
favScrollPad.PaddingLeft = UDim.new(0, 6)
favScrollPad.PaddingRight = UDim.new(0, 6)
favScrollPad.Parent = favoritesScrollFrame

local noFavoritesLabel = Instance.new("TextLabel")
noFavoritesLabel.Size = UDim2.new(1, -20, 0, 70)
noFavoritesLabel.Position = UDim2.new(0, 10, 0.5, -35)
noFavoritesLabel.Text = "⭐  No favorites yet!\nAdd players from the Players tab"
noFavoritesLabel.TextColor3 = COLORS.TEXT_DIM
noFavoritesLabel.BackgroundTransparency = 1
noFavoritesLabel.Font = Enum.Font.Gotham
noFavoritesLabel.TextSize = 13
noFavoritesLabel.LineHeight = 1.5
noFavoritesLabel.Parent = favoritesContent
registerThemeObj(noFavoritesLabel, "TEXT_DIM", "TextColor3")

-- ==========================================
-- PESTAÑA HISTORY
-- ==========================================

local historyContent = Instance.new("Frame")
historyContent.Name = "historyContent"
historyContent.Size = UDim2.new(1, 0, 1, 0)
historyContent.BackgroundTransparency = 1
historyContent.Parent = contentContainer
historyContent.Visible = false

historyScrollFrame = Instance.new("ScrollingFrame")
historyScrollFrame.Size = UDim2.new(1, 0, 1, 0)
historyScrollFrame.BackgroundColor3 = COLORS.SURFACE
historyScrollFrame.BorderSizePixel = 0
historyScrollFrame.ScrollBarThickness = CONFIG.SCROLLBAR_THICKNESS
historyScrollFrame.ScrollBarImageColor3 = COLORS.SCROLLBAR
historyScrollFrame.Parent = historyContent
addUICorner(historyScrollFrame, CONFIG.CORNER_RADIUS)
local hsStroke = addUIStroke(historyScrollFrame, COLORS.STROKE, 1.5, 0)
registerThemeObj(hsStroke, "STROKE", "Color")
registerThemeObj(historyScrollFrame, "SURFACE", "BackgroundColor3")

local historyLayout = Instance.new("UIListLayout")
historyLayout.Padding = UDim.new(0, CONFIG.CARD_MARGIN)
historyLayout.SortOrder = Enum.SortOrder.LayoutOrder
historyLayout.Parent = historyScrollFrame

local histScrollPad = Instance.new("UIPadding")
histScrollPad.PaddingTop = UDim.new(0, 6)
histScrollPad.PaddingBottom = UDim.new(0, 6)
histScrollPad.PaddingLeft = UDim.new(0, 6)
histScrollPad.PaddingRight = UDim.new(0, 6)
histScrollPad.Parent = historyScrollFrame

local noHistoryLabel = Instance.new("TextLabel")
noHistoryLabel.Size = UDim2.new(1, -20, 0, 70)
noHistoryLabel.Position = UDim2.new(0, 10, 0.5, -35)
noHistoryLabel.Text = "🕒  No history yet!\nMorph to someone to see it here"
noHistoryLabel.TextColor3 = COLORS.TEXT_DIM
noHistoryLabel.BackgroundTransparency = 1
noHistoryLabel.Font = Enum.Font.Gotham
noHistoryLabel.TextSize = 13
noHistoryLabel.LineHeight = 1.5
noHistoryLabel.Parent = historyContent
registerThemeObj(noHistoryLabel, "TEXT_DIM", "TextColor3")

-- ==========================================
-- PESTAÑA SKIN
-- ==========================================

local skinContent = Instance.new("Frame")
skinContent.Name = "skinContent"
skinContent.Size = UDim2.new(1, 0, 1, 0)
skinContent.BackgroundTransparency = 1
skinContent.Parent = contentContainer
skinContent.Visible = false

skinPaletteScroll = Instance.new("ScrollingFrame")
skinPaletteScroll.Size = UDim2.new(1, 0, 1, -58)
skinPaletteScroll.Position = UDim2.new(0, 0, 0, 0)
skinPaletteScroll.BackgroundColor3 = COLORS.SURFACE
skinPaletteScroll.BorderSizePixel = 0
skinPaletteScroll.ScrollBarThickness = CONFIG.SCROLLBAR_THICKNESS
skinPaletteScroll.ScrollBarImageColor3 = COLORS.SCROLLBAR
skinPaletteScroll.Parent = skinContent
addUICorner(skinPaletteScroll, CONFIG.CORNER_RADIUS)
local spStroke = addUIStroke(skinPaletteScroll, COLORS.STROKE, 1.5, 0)
registerThemeObj(spStroke, "STROKE", "Color")
registerThemeObj(skinPaletteScroll, "SURFACE", "BackgroundColor3")

local skinGridLayout = Instance.new("UIGridLayout")
skinGridLayout.CellSize = UDim2.new(0, 36, 0, 36)
skinGridLayout.CellPadding = UDim2.new(0, 7, 0, 7)
skinGridLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
skinGridLayout.SortOrder = Enum.SortOrder.LayoutOrder
skinGridLayout.Parent = skinPaletteScroll

local skinPadding = Instance.new("UIPadding")
skinPadding.PaddingTop = UDim.new(0, 10)
skinPadding.PaddingBottom = UDim.new(0, 10)
skinPadding.PaddingLeft = UDim.new(0, 10)
skinPadding.PaddingRight = UDim.new(0, 10)
skinPadding.Parent = skinPaletteScroll

-- Hex container
local hexContainer = Instance.new("Frame")
hexContainer.Size = UDim2.new(1, 0, 0, 52)
hexContainer.Position = UDim2.new(0, 0, 1, -52)
hexContainer.BackgroundColor3 = COLORS.SURFACE
hexContainer.BorderSizePixel = 0
hexContainer.Parent = skinContent
addUICorner(hexContainer, CONFIG.CORNER_RADIUS)
local hexStroke = addUIStroke(hexContainer, COLORS.STROKE, 1.5, 0)
registerThemeObj(hexStroke, "STROKE", "Color")
registerThemeObj(hexContainer, "SURFACE", "BackgroundColor3")

local hexLabel = Instance.new("TextLabel")
hexLabel.Text = "Hex Color:"
hexLabel.Size = UDim2.new(0, 90, 1, 0)
hexLabel.Position = UDim2.new(0, 12, 0, 0)
hexLabel.BackgroundTransparency = 1
hexLabel.TextColor3 = COLORS.TEXT_MAIN
hexLabel.Font = Enum.Font.GothamBold
hexLabel.TextSize = 12
hexLabel.TextXAlignment = Enum.TextXAlignment.Left
hexLabel.Parent = hexContainer
registerThemeObj(hexLabel, "TEXT_MAIN", "TextColor3")

local hexPreviewCircle = Instance.new("Frame")
hexPreviewCircle.Size = UDim2.new(0, 26, 0, 26)
hexPreviewCircle.Position = UDim2.new(0, 104, 0.5, -13)
hexPreviewCircle.BackgroundColor3 = Color3.fromRGB(240, 240, 240)
hexPreviewCircle.BorderSizePixel = 0
hexPreviewCircle.Parent = hexContainer
addUICorner(hexPreviewCircle, 13)
local hexPreviewStroke = addUIStroke(hexPreviewCircle, COLORS.STROKE, 1.5, 0)
registerThemeObj(hexPreviewStroke, "STROKE", "Color")

local hexInputContainer = Instance.new("Frame")
hexInputContainer.Size = UDim2.new(0, 90, 0, 30)
hexInputContainer.Position = UDim2.new(0, 136, 0.5, -15)
hexInputContainer.BackgroundColor3 = COLORS.MID_GRAY
hexInputContainer.BorderSizePixel = 0
hexInputContainer.Parent = hexContainer
addUICorner(hexInputContainer, 6)
local hexInputStroke = addUIStroke(hexInputContainer, COLORS.STROKE, 1, 0)
registerThemeObj(hexInputStroke, "STROKE", "Color")
registerThemeObj(hexInputContainer, "MID_GRAY", "BackgroundColor3")

hexInput = Instance.new("TextBox")
hexInput.Size = UDim2.new(1, -8, 1, 0)
hexInput.Position = UDim2.new(0, 4, 0, 0)
hexInput.BackgroundTransparency = 1
hexInput.TextColor3 = COLORS.TEXT_MAIN
hexInput.PlaceholderColor3 = COLORS.PLACEHOLDER
hexInput.Font = Enum.Font.GothamBold
hexInput.TextSize = 13
hexInput.Text = "#F0F0F0"
hexInput.PlaceholderText = "#RRGGBB"
hexInput.BorderSizePixel = 0
hexInput.ClearTextOnFocus = false
hexInput.TextXAlignment = Enum.TextXAlignment.Center
hexInput.Parent = hexInputContainer
registerThemeObj(hexInput, "TEXT_MAIN", "TextColor3")

local applyHexBtn = createButton(hexContainer, {
    Size = UDim2.new(0, 76, 0, 30),
    Position = UDim2.new(1, -84, 0.5, -15),
    Text = "Apply",
    TextSize = 12,
    Color = COLORS.LIGHT_GREEN,
    CornerRadius = 6
})

local function applyHexColor(text, showNotification)
    if not text or type(text) ~= "string" then
        if showNotification then sendNotification("❌ Error", "Texto inválido", "") end
        return false
    end
    text = text:gsub("^%s+", ""):gsub("%s+$", "")
    if text:sub(1,1) ~= "#" then text = "#" .. text end
    if #text ~= 7 then
        if showNotification then sendNotification("❌ Error", "Formato inválido (usa #RRGGBB)", "") end
        return false
    end
    local hexPart = text:sub(2)
    if not hexPart:match("^%x%x%x%x%x%x$") then
        if showNotification then sendNotification("❌ Error", "Caracteres inválidos (0-9, A-F)", "") end
        return false
    end
    local success, color = pcall(function() return Color3.fromHex(text) end)
    if not success then
        if showNotification then sendNotification("❌ Error", "Color inválido", "") end
        return false
    end
    hexPreviewCircle.BackgroundColor3 = color
    hexInput.Text = text:upper()
    local character = player.Character
    if character then
        local humanoid = character:FindFirstChild("Humanoid")
        if humanoid then
            local desc = humanoid:GetAppliedDescription()
            if desc then
                desc.HeadColor = color desc.TorsoColor = color
                desc.LeftArmColor = color desc.RightArmColor = color
                desc.LeftLegColor = color desc.RightLegColor = color
                local applySuccess = pcall(function()
                    if humanoid.ApplyDescriptionClientServer then humanoid:ApplyDescriptionClientServer(desc)
                    else humanoid:ApplyDescription(desc) end
                end)
                if applySuccess then
                    flashCharacter(character)
                    if showNotification then sendNotification("🎨 Skin", "Color aplicado: " .. text:upper(), "") end
                    return true
                else
                    if showNotification then sendNotification("❌ Error", "No se pudo aplicar el color", "") end
                    return false
                end
            end
        end
    end
    return true
end

hexInput:GetPropertyChangedSignal("Text"):Connect(function()
    local text = hexInput.Text
    if #text >= 6 then
        local testText = text
        if testText:sub(1,1) ~= "#" then testText = "#" .. testText end
        if #testText == 7 and testText:sub(2):match("^%x%x%x%x%x%x$") then
            local success, color = pcall(function() return Color3.fromHex(testText) end)
            if success then hexPreviewCircle.BackgroundColor3 = color end
        end
    end
end)

hexInput.FocusLost:Connect(function(enterPressed)
    local text = hexInput.Text
    if enterPressed or text ~= "" then applyHexColor(text, true)
    else hexInput.Text = colorToHex(hexPreviewCircle.BackgroundColor3) end
end)

connect(applyHexBtn.MouseButton1Click, function()
    flashButton(applyHexBtn)
    applyHexColor(hexInput.Text, true)
end)

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

-- ==========================================
-- 5. FUNCIONES DE ACTUALIZACIÓN DE LISTAS
-- ==========================================

local function createPlayerCard(targetPlayer, isFavorite)
    local card = Instance.new("Frame")
    card.Size = UDim2.new(1, -12, 0, CONFIG.CARD_HEIGHT)
    card.BackgroundColor3 = COLORS.CARD_BG
    card.BorderSizePixel = 0
    addUICorner(card, 8)
    local cardStroke = addUIStroke(card, COLORS.STROKE, 1.5, 0)
    registerThemeObj(cardStroke, "STROKE", "Color")
    registerThemeObj(card, "CARD_BG", "BackgroundColor3")

    -- Avatar border
    local avatarBorder = Instance.new("Frame")
    avatarBorder.Size = UDim2.new(0, 44, 0, 44)
    avatarBorder.Position = UDim2.new(0, 8, 0.5, -22)
    avatarBorder.BackgroundColor3 = COLORS.ACCENT
    avatarBorder.BorderSizePixel = 0
    avatarBorder.Parent = card
    addUICorner(avatarBorder, 7)
    registerThemeObj(avatarBorder, "ACCENT", "BackgroundColor3")

    local profileImage = Instance.new("ImageLabel")
    profileImage.Size = UDim2.new(1, -3, 1, -3)
    profileImage.Position = UDim2.new(0, 1.5, 0, 1.5)
    profileImage.BackgroundColor3 = COLORS.MID_GRAY
    profileImage.BorderSizePixel = 0
    profileImage.Image = ""
    profileImage.Parent = avatarBorder
    addUICorner(profileImage, 6)
    registerThemeObj(profileImage, "MID_GRAY", "BackgroundColor3")

    local userId = targetPlayer.UserId
    local cached = playerCache[userId]
    if cached and cached.Thumbnail ~= "" then
        profileImage.Image = cached.Thumbnail
    else
        profileImage.Image = ""
        task.spawn(function()
            local success, thumb = pcall(function()
                return SERVICES.Players:GetUserThumbnailAsync(userId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size100x100)
            end)
            if success and profileImage and profileImage.Parent then
                profileImage.Image = thumb
                if not playerCache[userId] then
                    addToCache(userId, {UserId = userId, Name = targetPlayer.Name, Thumbnail = thumb})
                else
                    playerCache[userId].Thumbnail = thumb
                end
            end
        end)
    end

    -- Name stack
    local nameStack = Instance.new("Frame")
    nameStack.Size = UDim2.new(1, -190, 1, 0)
    nameStack.Position = UDim2.new(0, 60, 0, 0)
    nameStack.BackgroundTransparency = 1
    nameStack.BorderSizePixel = 0
    nameStack.Parent = card

    local playerName = Instance.new("TextLabel")
    playerName.Size = UDim2.new(1, 0, 0, 22)
    playerName.Position = UDim2.new(0, 0, 0, 8)
    playerName.Text = targetPlayer.Name
    playerName.TextColor3 = COLORS.TEXT_MAIN
    playerName.BackgroundTransparency = 1
    playerName.Font = Enum.Font.GothamBold
    playerName.TextSize = 13
    playerName.TextXAlignment = Enum.TextXAlignment.Left
    playerName.TextTruncate = Enum.TextTruncate.AtEnd
    playerName.Parent = nameStack
    registerThemeObj(playerName, "TEXT_MAIN", "TextColor3")

    local displayName = Instance.new("TextLabel")
    displayName.Size = UDim2.new(1, 0, 0, 16)
    displayName.Position = UDim2.new(0, 0, 0, 30)
    displayName.Text = "@" .. (targetPlayer.DisplayName or targetPlayer.Name)
    displayName.TextColor3 = COLORS.TEXT_DIM
    displayName.TextTransparency = 0.3
    displayName.BackgroundTransparency = 1
    displayName.Font = Enum.Font.Gotham
    displayName.TextSize = 11
    displayName.TextXAlignment = Enum.TextXAlignment.Left
    displayName.TextTruncate = Enum.TextTruncate.AtEnd
    displayName.Parent = nameStack
    registerThemeObj(displayName, "TEXT_DIM", "TextColor3")

    -- Action buttons container
    local actionsContainer = Instance.new("Frame")
    actionsContainer.Size = UDim2.new(0, 124, 0, 34)
    actionsContainer.Position = UDim2.new(1, -130, 0.5, -17)
    actionsContainer.BackgroundTransparency = 1
    actionsContainer.BorderSizePixel = 0
    actionsContainer.Parent = card

    local actionsLayout = Instance.new("UIListLayout")
    actionsLayout.FillDirection = Enum.FillDirection.Horizontal
    actionsLayout.HorizontalAlignment = Enum.HorizontalAlignment.Right
    actionsLayout.VerticalAlignment = Enum.VerticalAlignment.Center
    actionsLayout.Padding = UDim.new(0, 4)
    actionsLayout.Parent = actionsContainer

    if not isFavorite then
        local favBtn = createButton(actionsContainer, {
            Size = UDim2.new(0, 32, 0, 32),
            Text = favorites[targetPlayer.Name] and "⭐" or "☆",
            TextSize = 15,
            Color = COLORS.DARK_GRAY,
            CornerRadius = 6
        })
        connect(favBtn.MouseButton1Click, function()
            if favorites[targetPlayer.Name] then
                favorites[targetPlayer.Name] = nil
                favBtn.Text = "☆"
                sendNotification("⭐ Favorites", "Removed from favorites", "")
            else
                favorites[targetPlayer.Name] = {UserId = targetPlayer.UserId, DisplayName = targetPlayer.DisplayName or targetPlayer.Name}
                favBtn.Text = "⭐"
                sendNotification("⭐ Favorites", "Added to favorites", "")
            end
            updateFavoritesList()
            saveFavorites()
        end)
    else
        local removeBtn = createButton(actionsContainer, {
            Size = UDim2.new(0, 32, 0, 32),
            Text = "🗑",
            TextSize = 15,
            Color = COLORS.RED,
            CornerRadius = 6
        })
        connect(removeBtn.MouseButton1Click, function()
            favorites[targetPlayer.Name] = nil
            sendNotification("⭐ Favorites", "Removed from favorites", "")
            updateFavoritesList()
            saveFavorites()
        end)
    end

    local copyBtn = createButton(actionsContainer, {
        Size = UDim2.new(0, 32, 0, 32),
        Text = "📋",
        TextSize = 14,
        Color = COLORS.DARK_GRAY,
        CornerRadius = 6
    })

    local morphBtn = createButton(actionsContainer, {
        Size = UDim2.new(0, 52, 0, 32),
        Text = "Morph",
        TextSize = 11,
        Color = COLORS.LIGHT_GREEN,
        CornerRadius = 6
    })

    connect(morphBtn.MouseButton1Click, function()
        flashButton(morphBtn)
        morphToPlayer(targetPlayer)
    end)
    connect(copyBtn.MouseButton1Click, function()
        flashButton(copyBtn)
        copyBodyObjects(targetPlayer, {clothes=true, accessories=true, skin=false, shape=false})
    end)

    -- Preview on hover
    connect(card.InputBegan, function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            if not previewFrame then
                previewFrame = Instance.new("Frame")
                previewFrame.Size = UDim2.new(0, 140, 0, 140)
                previewFrame.BackgroundColor3 = COLORS.CARD_BG
                previewFrame.BorderSizePixel = 0
                previewFrame.ZIndex = 20
                previewFrame.Parent = screenGui
                addUICorner(previewFrame, 10)
                addUIStroke(previewFrame, COLORS.STROKE, 2, 0)

                previewImage = Instance.new("ImageLabel")
                previewImage.Size = UDim2.new(1, -8, 1, -8)
                previewImage.Position = UDim2.new(0, 4, 0, 4)
                previewImage.BackgroundTransparency = 1
                previewImage.ZIndex = 21
                previewImage.Parent = previewFrame
                addUICorner(previewImage, 7)
            end
            local uid = targetPlayer.UserId
            local cachedData = playerCache[uid]
            if cachedData and cachedData.Thumbnail ~= "" then
                previewImage.Image = cachedData.Thumbnail
            else
                pcall(function()
                    local thumb = SERVICES.Players:GetUserThumbnailAsync(uid, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size420x420)
                    previewImage.Image = thumb
                    if cachedData then cachedData.Thumbnail = thumb end
                end)
            end
            previewFrame.Position = UDim2.new(0, input.Position.X + 20, 0, input.Position.Y - 75)
            previewFrame.Visible = true
        end
    end)
    connect(card.InputEnded, function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 and previewFrame then
            previewFrame.Visible = false
        end
    end)
    return card
end

local function createHistoryCard(entry)
    local card = Instance.new("Frame")
    card.Size = UDim2.new(1, -12, 0, 52)
    card.BackgroundColor3 = COLORS.CARD_BG
    card.BorderSizePixel = 0
    addUICorner(card, 8)
    local hcStroke = addUIStroke(card, COLORS.STROKE, 1.5, 0)
    registerThemeObj(hcStroke, "STROKE", "Color")
    registerThemeObj(card, "CARD_BG", "BackgroundColor3")

    local nameLabel = Instance.new("TextLabel")
    nameLabel.Size = UDim2.new(1, -130, 0, 20)
    nameLabel.Position = UDim2.new(0, 12, 0, 8)
    nameLabel.Text = entry.Name
    nameLabel.TextColor3 = COLORS.TEXT_MAIN
    nameLabel.BackgroundTransparency = 1
    nameLabel.Font = Enum.Font.GothamBold
    nameLabel.TextSize = 13
    nameLabel.TextXAlignment = Enum.TextXAlignment.Left
    nameLabel.TextTruncate = Enum.TextTruncate.AtEnd
    nameLabel.Parent = card
    registerThemeObj(nameLabel, "TEXT_MAIN", "TextColor3")

    local displayNameLabel = Instance.new("TextLabel")
    displayNameLabel.Size = UDim2.new(1, -130, 0, 15)
    displayNameLabel.Position = UDim2.new(0, 12, 0, 28)
    displayNameLabel.Text = "@" .. (entry.DisplayName or entry.Name)
    displayNameLabel.TextColor3 = COLORS.TEXT_DIM
    displayNameLabel.BackgroundTransparency = 1
    displayNameLabel.Font = Enum.Font.Gotham
    displayNameLabel.TextSize = 11
    displayNameLabel.TextXAlignment = Enum.TextXAlignment.Left
    displayNameLabel.TextTruncate = Enum.TextTruncate.AtEnd
    displayNameLabel.Parent = card
    registerThemeObj(displayNameLabel, "TEXT_DIM", "TextColor3")

    local timeLabel = Instance.new("TextLabel")
    timeLabel.Size = UDim2.new(0, 62, 0, 15)
    timeLabel.Position = UDim2.new(1, -130, 0, 8)
    timeLabel.Text = os.date("%H:%M:%S", entry.Time)
    timeLabel.TextColor3 = COLORS.ACCENT
    timeLabel.BackgroundTransparency = 1
    timeLabel.Font = Enum.Font.Gotham
    timeLabel.TextSize = 11
    timeLabel.TextXAlignment = Enum.TextXAlignment.Right
    timeLabel.Parent = card
    registerThemeObj(timeLabel, "ACCENT", "TextColor3")

    local morphBtn = createButton(card, {
        Size = UDim2.new(0, 58, 0, 30),
        Position = UDim2.new(1, -66, 0.5, -15),
        Text = "Morph",
        TextSize = 11,
        Color = COLORS.LIGHT_GREEN,
        CornerRadius = 6
    })
    connect(morphBtn.MouseButton1Click, function()
        flashButton(morphBtn)
        local target = findPlayerById(entry.UserId) or entry
        morphToPlayer(target)
    end)
    return card
end

local function getSortedPlayers(filterText)
    local playersList = {}
    local distances = {}
    local searchText = filterText:lower():gsub("^%s+", ""):gsub("%s+$", "")
    for _, p in ipairs(SERVICES.Players:GetPlayers()) do
        if p ~= player then
            local playerNameStr = p.Name or ""
            local playerDisplayName = p.DisplayName or p.Name or ""
            local matchesName = playerNameStr:lower():find(searchText) ~= nil
            local matchesDisplayName = playerDisplayName:lower():find(searchText) ~= nil
            if searchText == "" or matchesName or matchesDisplayName then
                table.insert(playersList, p)
                distances[p] = getDistanceToPlayer(p)
            end
        end
    end
    if sortMode == "distance" then
        table.sort(playersList, function(a, b) return (distances[a] or math.huge) < (distances[b] or math.huge) end)
    elseif sortMode == "displayname" then
        table.sort(playersList, function(a, b)
            return (a.DisplayName or a.Name or ""):lower() < (b.DisplayName or b.Name or ""):lower()
        end)
    else
        table.sort(playersList, function(a, b)
            return (a.Name or ""):lower() < (b.Name or ""):lower()
        end)
    end
    return playersList
end

local function updatePlayersList(filterText)
    if not playersScrollFrame or not playersScrollFrame.Parent then return end
    filterText = filterText or ""
    local sorted = getSortedPlayers(filterText)
    for _, child in ipairs(playersScrollFrame:GetChildren()) do
        if child:IsA("Frame") then child:Destroy() end
    end
    for _, targetPlayer in ipairs(sorted) do
        local card = createPlayerCard(targetPlayer, false)
        card.Name = "PlayerCard_" .. targetPlayer.UserId
        card.Parent = playersScrollFrame
    end
    task.wait()
    playersScrollFrame.CanvasSize = UDim2.new(0, 0, 0, playersLayout.AbsoluteContentSize.Y + 14)
end

function updateFavoritesList()
    for _, child in ipairs(favoritesScrollFrame:GetChildren()) do
        if child:IsA("Frame") then child:Destroy() end
    end
    local hasFavorites = false
    for playerName, data in pairs(favorites) do
        hasFavorites = true
        local fakePlayer = {Name = playerName, UserId = data.UserId, DisplayName = data.DisplayName}
        local card = createPlayerCard(fakePlayer, true)
        card.Parent = favoritesScrollFrame
    end
    noFavoritesLabel.Visible = not hasFavorites
    task.wait()
    favoritesScrollFrame.CanvasSize = UDim2.new(0, 0, 0, favoritesLayout.AbsoluteContentSize.Y + 14)
end

function updateHistoryList()
    for _, child in ipairs(historyScrollFrame:GetChildren()) do
        if child:IsA("Frame") then child:Destroy() end
    end
    if #history == 0 then
        noHistoryLabel.Visible = true
    else
        noHistoryLabel.Visible = false
        for _, entry in ipairs(history) do
            local card = createHistoryCard(entry)
            card.Parent = historyScrollFrame
        end
    end
    task.wait()
    historyScrollFrame.CanvasSize = UDim2.new(0, 0, 0, historyLayout.AbsoluteContentSize.Y + 14)
end

local function switchTab(tabName)
    currentTab = tabName
    updateTabHighlights()
    infoContent.Visible       = (tabName == "info")
    searchContent.Visible     = (tabName == "search")
    playersContent.Visible    = (tabName == "players")
    favoritesContent.Visible  = (tabName == "favorites")
    skinContent.Visible       = (tabName == "skin")
    historyContent.Visible    = (tabName == "history")
    if tabName == "players" then updatePlayersList(searchPlayersBox.Text)
    elseif tabName == "favorites" then updateFavoritesList()
    elseif tabName == "history" then updateHistoryList() end
end

-- ==========================================
-- 6. EVENTOS Y CONEXIONES
-- ==========================================

connect(titleBar.InputBegan, function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        draggingTitleBar = true
        dragStart = input.Position
        startPos = frame.Position
    end
end)

connect(SERVICES.UserInput.InputEnded, function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        draggingTitleBar = false
    end
end)

connect(SERVICES.UserInput.InputChanged, function(input)
    if draggingTitleBar and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - dragStart
        frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

connect(miniBtn.MouseButton1Click, function()
    minimized = not minimized
    if minimized then
        animateObject(frame, {Size = UDim2.new(0, CONFIG.MENU_WIDTH, 0, 48)}, CONFIG.ANIM_SPEED)
        miniBtn.Text = "+"
        tabsContainer.Visible = false
        contentContainer.Visible = false
    else
        animateObject(frame, {Size = UDim2.new(0, CONFIG.MENU_WIDTH, 0, CONFIG.MENU_HEIGHT)}, CONFIG.ANIM_SPEED)
        miniBtn.Text = "−"
        tabsContainer.Visible = true
        contentContainer.Visible = true
    end
end)

connect(closeBtn.MouseButton1Click, function()
    cleanupAll()
    screenGui:Destroy()
end)

connect(themeBtn.MouseButton1Click, function()
    flashButton(themeBtn)
    cycleTheme()
end)

connect(infoTab.MouseButton1Click, function() switchTab("info") end)
connect(searchTab.MouseButton1Click, function() switchTab("search") end)
connect(playersTab.MouseButton1Click, function() switchTab("players") end)
connect(favoritesTab.MouseButton1Click, function() switchTab("favorites") end)
connect(skinTab.MouseButton1Click, function() switchTab("skin") end)
connect(historyTab.MouseButton1Click, function() switchTab("history") end)

local searchDebounce = nil
searchPlayersBox:GetPropertyChangedSignal("Text"):Connect(function()
    if searchDebounce then task.cancel(searchDebounce) end
    local searchText = searchPlayersBox.Text
    searchDebounce = task.delay(CONFIG.DEBOUNCE_TIME, function()
        updatePlayersList(searchText)
        searchDebounce = nil
    end)
end)

connect(sortBtn.MouseButton1Click, function()
    flashButton(sortBtn)
    if sortMode == "name" then
        sortMode = "displayname"
        sortBtn.Text = "🔤 @Name"
    elseif sortMode == "displayname" then
        sortMode = "distance"
        sortBtn.Text = "📏 Distance"
    else
        sortMode = "name"
        sortBtn.Text = "🔤 Name"
    end
    task.spawn(function() updatePlayersList(searchPlayersBox.Text) end)
end)

-- ==========================================
-- LÓGICA DE BÚSQUEDA
-- ==========================================

local function showSearchResult(targetPlayer)
    if not targetPlayer then
        searchResultContainer.Visible = false
        return
    end
    lastFoundTarget = targetPlayer

    local userId, playerName, displayName
    local isOnline = false

    if typeof(targetPlayer) == "Instance" then
        userId = targetPlayer.UserId
        playerName = targetPlayer.Name
        displayName = targetPlayer.DisplayName or playerName
        isOnline = true
    elseif typeof(targetPlayer) == "table" then
        userId = targetPlayer.UserId
        playerName = targetPlayer.Name or "Unknown"
        displayName = targetPlayer.DisplayName or playerName
        isOnline = false
    else return end

    searchResultName.Text = playerName
    searchResultDisplayName.Text = "@" .. displayName
    searchResultId.Text = "ID: " .. tostring(userId)
    searchResultStatus.Text = isOnline and "🟢 Online" or "🔴 Offline"
    searchResultStatus.TextColor3 = isOnline and COLORS.LIGHT_GREEN or COLORS.TEXT_DIM

    local cached = playerCache[userId]
    if cached and cached.Thumbnail ~= "" then
        searchResultImage.Image = cached.Thumbnail
    else
        searchResultImage.Image = ""
        task.spawn(function()
            local success, thumb = pcall(function()
                return SERVICES.Players:GetUserThumbnailAsync(userId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size420x420)
            end)
            if success and searchResultImage then
                searchResultImage.Image = thumb
                if not playerCache[userId] then
                    addToCache(userId, {UserId = userId, Name = playerName, Thumbnail = thumb})
                else
                    playerCache[userId].Thumbnail = thumb
                end
            end
        end)
    end

    searchResultContainer.Visible = true
    animateObject(searchResultContainer, {BackgroundTransparency = 0}, CONFIG.ANIM_SPEED)
end

connect(searchBtn.MouseButton1Click, function()
    flashButton(searchBtn)
    local inputText = sanitizeInput(usernameInput.Text)
    if inputText == "" then
        sendNotification("🔍 Search", "Please enter a username!", "")
        searchResultContainer.Visible = false
        return
    end
    local target = findPlayerByName(inputText)
    if target then
        showSearchResult(target)
    else
        sendNotification("🔍 Search", "Player not found!", "")
        searchResultContainer.Visible = false
    end
end)

connect(confirmMorphBtn.MouseButton1Click, function()
    if lastFoundTarget then
        flashButton(confirmMorphBtn)
        morphToPlayer(lastFoundTarget)
    else
        sendNotification("❌ Error", "No target selected", "")
    end
end)

connect(usernameInput.FocusLost, function(enterPressed)
    if enterPressed then
        local inputText = sanitizeInput(usernameInput.Text)
        if inputText == "" then searchResultContainer.Visible = false return end
        local target = findPlayerByName(inputText)
        if not target then
            local id = tonumber(inputText)
            if id then target = findPlayerById(id) end
        end
        if target then
            showSearchResult(target)
            usernameInput.Text = target.Name or inputText
        else
            sendNotification("🔍 Search", "Player not found!", "")
            searchResultContainer.Visible = false
        end
    end
end)

connect(SERVICES.UserInput.InputBegan, function(input, gameProcessed)
    if gameProcessed then return end
    local isCtrlHeld = SERVICES.UserInput:IsKeyDown(Enum.KeyCode.LeftControl) or SERVICES.UserInput:IsKeyDown(Enum.KeyCode.RightControl)
    if isCtrlHeld then
        if input.KeyCode == Enum.KeyCode.M then
            local inputText = sanitizeInput(usernameInput.Text)
            if inputText ~= "" then
                local target = findPlayerByName(inputText) or findPlayerById(tonumber(inputText))
                if target then morphToPlayer(target)
                else sendNotification("⌨️ Atajo", "Jugador no encontrado.", "") end
            else sendNotification("⌨️ Atajo", "Ingresa un nombre primero.", "") end
        elseif input.KeyCode == Enum.KeyCode.F then
            if currentTab ~= "search" then switchTab("search") end
            usernameInput:CaptureFocus()
        end
    end
end)

connect(SERVICES.Players.PlayerAdded, function()
    if currentTab == "players" then updatePlayersList(searchPlayersBox.Text) end
end)
connect(SERVICES.Players.PlayerRemoving, function()
    if currentTab == "players" then updatePlayersList(searchPlayersBox.Text) end
end)

-- ==========================================
-- 7. PALETA DE COLORES
-- ==========================================

local function applySkinColor(color)
    local character = player.Character
    if not character then return end
    local humanoid = character:FindFirstChild("Humanoid")
    if not humanoid then return end
    hexPreviewCircle.BackgroundColor3 = color
    hexInput.Text = colorToHex(color)
    local bodyColors = character:FindFirstChild("BodyColors") or character:FindFirstChildOfClass("BodyColors")
    if not bodyColors then
        bodyColors = Instance.new("BodyColors")
        bodyColors.Name = "BodyColors"
        bodyColors.Parent = character
    end
    bodyColors.HeadColor3 = color bodyColors.LeftArmColor3 = color
    bodyColors.RightArmColor3 = color bodyColors.LeftLegColor3 = color
    bodyColors.RightLegColor3 = color bodyColors.TorsoColor3 = color
    pcall(function()
        local desc = humanoid:GetAppliedDescription()
        desc.HeadColor = color desc.LeftArmColor = color desc.RightArmColor = color
        desc.LeftLegColor = color desc.RightLegColor = color desc.TorsoColor = color
        if humanoid.ApplyDescriptionClientServer then humanoid:ApplyDescriptionClientServer(desc)
        else humanoid:ApplyDescription(desc) end
    end)
end

for i, color in ipairs(skinColors) do
    local colorBtn = Instance.new("ImageButton")
    colorBtn.Name = "Color_" .. i
    colorBtn.BackgroundColor3 = color
    colorBtn.BorderSizePixel = 0
    colorBtn.AutoButtonColor = false
    colorBtn.Parent = skinPaletteScroll
    addUICorner(colorBtn, 18)
    local btnStroke = Instance.new("UIStroke")
    btnStroke.Color = COLORS.WHITE
    btnStroke.Thickness = 2.5
    btnStroke.Transparency = 1
    btnStroke.Parent = colorBtn
    connect(colorBtn.MouseEnter, function() animateObject(btnStroke, {Transparency = 0}, 0.08) end)
    connect(colorBtn.MouseLeave, function() animateObject(btnStroke, {Transparency = 1}, 0.15) end)
    connect(colorBtn.MouseButton1Click, function() applySkinColor(color) end)
end

local function updateSkinCanvas()
    task.wait()
    local contentSize = skinGridLayout.AbsoluteContentSize
    skinPaletteScroll.CanvasSize = UDim2.new(0, contentSize.X + 10, 0, contentSize.Y + 10)
end

updateSkinCanvas()
connect(skinGridLayout:GetPropertyChangedSignal("AbsoluteContentSize"), updateSkinCanvas)

-- ==========================================
-- 8. CARGA INICIAL
-- ==========================================

lastMorphTime = loadCooldown()
loadFavorites()
switchTab("info")
sendNotification("🎭 Morph Avatar Pro", "By @sickly255 (SAGE) ✨ v2.1.9 | Modern UI Redesign", "")