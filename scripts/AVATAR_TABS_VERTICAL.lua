-- ==========================================
-- MORPH AVATAR PRO - VERSIÓN FINAL (v2.3.0)
-- ==========================================

-- ==========================================
-- 1. CONFIGURACIÓN Y CONSTANTES
-- ==========================================

local THEMES = {
    Glass = { BG_MAIN = Color3.fromRGB(15, 15, 15), BG_PANEL = Color3.fromRGB(25, 25, 25), BG_CARD = Color3.fromRGB(35, 35, 35), BG_INPUT = Color3.fromRGB(45, 45, 45), TEXT_PRIMARY = Color3.fromRGB(255, 255, 255), TEXT_SECONDARY = Color3.fromRGB(180, 180, 180), ACCENT = Color3.fromRGB(100, 150, 255), SUCCESS = Color3.fromRGB(50, 180, 50), DANGER = Color3.fromRGB(200, 50, 50), WARNING = Color3.fromRGB(230, 180, 50), INFO = Color3.fromRGB(100, 150, 255), BORDER = Color3.fromRGB(80, 80, 80), SCROLL_THUMB = Color3.fromRGB(100, 150, 255), TRANSPARENCY = 0.05 },
    Dark = { BG_MAIN = Color3.fromRGB(20, 20, 25), BG_PANEL = Color3.fromRGB(30, 30, 40), BG_CARD = Color3.fromRGB(45, 45, 60), BG_INPUT = Color3.fromRGB(55, 55, 70), TEXT_PRIMARY = Color3.fromRGB(240, 240, 240), TEXT_SECONDARY = Color3.fromRGB(160, 160, 170), ACCENT = Color3.fromRGB(80, 130, 220), SUCCESS = Color3.fromRGB(40, 180, 90), DANGER = Color3.fromRGB(200, 50, 50), WARNING = Color3.fromRGB(230, 180, 50), INFO = Color3.fromRGB(80, 130, 220), BORDER = Color3.fromRGB(70, 70, 90), SCROLL_THUMB = Color3.fromRGB(80, 130, 220), TRANSPARENCY = 0.05 },
    Light = { BG_MAIN = Color3.fromRGB(240, 240, 245), BG_PANEL = Color3.fromRGB(220, 220, 230), BG_CARD = Color3.fromRGB(200, 200, 210), BG_INPUT = Color3.fromRGB(230, 230, 235), TEXT_PRIMARY = Color3.fromRGB(20, 20, 25), TEXT_SECONDARY = Color3.fromRGB(60, 60, 70), ACCENT = Color3.fromRGB(60, 120, 200), SUCCESS = Color3.fromRGB(30, 150, 70), DANGER = Color3.fromRGB(180, 40, 40), WARNING = Color3.fromRGB(200, 150, 30), INFO = Color3.fromRGB(60, 120, 200), BORDER = Color3.fromRGB(150, 150, 160), SCROLL_THUMB = Color3.fromRGB(60, 120, 200), TRANSPARENCY = 0.1 },
    Cyber = { BG_MAIN = Color3.fromRGB(10, 10, 20), BG_PANEL = Color3.fromRGB(20, 20, 35), BG_CARD = Color3.fromRGB(30, 30, 55), BG_INPUT = Color3.fromRGB(40, 40, 70), TEXT_PRIMARY = Color3.fromRGB(255, 255, 255), TEXT_SECONDARY = Color3.fromRGB(150, 200, 255), ACCENT = Color3.fromRGB(0, 255, 200), SUCCESS = Color3.fromRGB(0, 255, 150), DANGER = Color3.fromRGB(255, 50, 100), WARNING = Color3.fromRGB(255, 220, 0), INFO = Color3.fromRGB(0, 255, 200), BORDER = Color3.fromRGB(0, 200, 255), SCROLL_THUMB = Color3.fromRGB(0, 255, 200), TRANSPARENCY = 0.2 },
    Sunset = { BG_MAIN = Color3.fromRGB(30, 20, 25), BG_PANEL = Color3.fromRGB(45, 30, 35), BG_CARD = Color3.fromRGB(60, 40, 45), BG_INPUT = Color3.fromRGB(75, 50, 55), TEXT_PRIMARY = Color3.fromRGB(255, 240, 230), TEXT_SECONDARY = Color3.fromRGB(200, 160, 150), ACCENT = Color3.fromRGB(255, 150, 100), SUCCESS = Color3.fromRGB(100, 200, 120), DANGER = Color3.fromRGB(255, 80, 80), WARNING = Color3.fromRGB(255, 200, 80), INFO = Color3.fromRGB(255, 150, 100), BORDER = Color3.fromRGB(120, 80, 70), SCROLL_THUMB = Color3.fromRGB(255, 150, 100), TRANSPARENCY = 0.15 },
    Ocean = { BG_MAIN = Color3.fromRGB(10, 20, 30), BG_PANEL = Color3.fromRGB(15, 30, 45), BG_CARD = Color3.fromRGB(25, 45, 65), BG_INPUT = Color3.fromRGB(35, 55, 80), TEXT_PRIMARY = Color3.fromRGB(230, 245, 255), TEXT_SECONDARY = Color3.fromRGB(150, 190, 220), ACCENT = Color3.fromRGB(50, 180, 255), SUCCESS = Color3.fromRGB(60, 200, 180), DANGER = Color3.fromRGB(255, 80, 100), WARNING = Color3.fromRGB(255, 200, 80), INFO = Color3.fromRGB(50, 180, 255), BORDER = Color3.fromRGB(40, 90, 130), SCROLL_THUMB = Color3.fromRGB(50, 180, 255), TRANSPARENCY = 0.18 }
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
    MENU_WIDTH = 420, MENU_HEIGHT = 520, CREATOR_NAME = "Sickly255", ANIM_SPEED = 0.2, CONFIRM_MORPH = false,
    SORT_MODE = "name", COOLDOWN = 5, MAX_CACHE_SIZE = 50, DEBOUNCE_TIME = 0.3,
    TAB_BUTTON_WIDTH = 90, CARD_HEIGHT = 56, CARD_MARGIN = 5
}

local player = SERVICES.Players.LocalPlayer
local draggingTitleBar = false
local dragStart, startPos = nil, nil
local currentTab = "info"
local playerCache = {}
local cacheOrder = {}
local previewFrame = nil
local previewImage = nil
local lastMorphTime = 0
local canUseTween = SERVICES.Tween ~= nil
local canUseWriteFile = pcall(function() return writefile end)
local lastFoundTarget = nil
local sortMode = CONFIG.SORT_MODE
local toggleKey = Enum.KeyCode.RightShift
local isListeningForKey = false

local connections = {}
local activeTweens = {}

-- ==========================================
-- DECLARACIÓN ANTICIPADA DE VARIABLES DE GUI
-- ==========================================
local toastContainer
local toastGui
local frame
local screenGui
local tabsContainer
local infoContent
local playersScrollFrame
local skinPaletteScroll
local usernameInput
local searchPlayersBox
local hexInput
local configBtn
local hexPreviewCircle
local searchResultContainer
local searchResultImage
local searchResultName
local searchResultDisplayName
local searchResultId
local searchResultStatus
local confirmMorphBtn
local searchBtn
local regenBtn
local sortBtn
local infoContentLabel
local contentContainer
local sidebarFrame
local playersContent
local skinContent
local searchContent
local skinGridLayout
local playersLayout
local tabsLayout

-- ==========================================
-- FUNCIONES BASE (sin dependencias de GUI)
-- ==========================================

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

local function animateObject(obj, props, time)
    if canUseTween and SERVICES.Tween then
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
        for prop, value in pairs(props) do
            pcall(function() obj[prop] = value end)
        end
    end
end

local function colorToHex(color)
    return string.format("#%02X%02X%02X", color.R * 255, color.G * 255, color.B * 255)
end

local function registerThemeObj(obj, role, property)
    if not obj or not role then return end
    table.insert(themeObjects, {obj = obj, role = role, property = property or "BackgroundColor3"})
end

-- ==========================================
-- SISTEMA DE TOASTS (después de animateObject)
-- ==========================================

local function sendNotification(title, text, notifType)
    if not toastContainer then return end

    notifType = notifType or "INFO"
    local indicatorColor = COLORS.INFO
    if notifType == "SUCCESS" then indicatorColor = COLORS.SUCCESS
    elseif notifType == "DANGER" or notifType == "ERROR" then indicatorColor = COLORS.DANGER
    elseif notifType == "WARNING" then indicatorColor = COLORS.WARNING
    elseif notifType == "PROGRESS" then indicatorColor = COLORS.ACCENT
    end

    local toast = Instance.new("Frame")
    toast.Size = UDim2.new(0, 340, 0, 70)
    toast.BackgroundColor3 = COLORS.BG_PANEL
    toast.BorderSizePixel = 0
    toast.BackgroundTransparency = 1
    toast.Parent = toastContainer
    toast.ClipsDescendants = true
    toast.ZIndex = 1000000

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 10)
    corner.Parent = toast

    -- BORDE CON COLOR DEL TIPO DE NOTIFICACIÓN (en vez de barrita lateral)
    local stroke = Instance.new("UIStroke")
    stroke.Thickness = 2
    stroke.Color = indicatorColor
    stroke.Transparency = 1
    stroke.Parent = toast

    -- INDICADOR PEQUEÑO REDONDEADO (dentro del padding, no se sale)
    local indicator = Instance.new("Frame")
    indicator.Size = UDim2.new(0, 4, 0, 40)
    indicator.Position = UDim2.new(0, 10, 0.5, -20)
    indicator.BackgroundColor3 = indicatorColor
    indicator.BorderSizePixel = 0
    indicator.ZIndex = 1000001
    indicator.Parent = toast

    local indCorner = Instance.new("UICorner")
    indCorner.CornerRadius = UDim.new(0, 3)
    indCorner.Parent = indicator

    local titleLabel = Instance.new("TextLabel")
    titleLabel.Size = UDim2.new(1, -36, 0, 22)
    titleLabel.Position = UDim2.new(0, 24, 0, 12)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = title
    titleLabel.TextColor3 = indicatorColor
    titleLabel.TextTransparency = 1
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.TextSize = 14
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.ZIndex = 1000001
    titleLabel.Parent = toast

    local textLabel = Instance.new("TextLabel")
    textLabel.Size = UDim2.new(1, -36, 0, 28)
    textLabel.Position = UDim2.new(0, 24, 0, 34)
    textLabel.BackgroundTransparency = 1
    textLabel.Text = text
    textLabel.TextColor3 = COLORS.TEXT_PRIMARY
    textLabel.TextTransparency = 1
    textLabel.Font = Enum.Font.Gotham
    textLabel.TextSize = 12
    textLabel.TextXAlignment = Enum.TextXAlignment.Left
    textLabel.TextWrapped = true
    textLabel.ZIndex = 1000001
    textLabel.Parent = toast

    -- Calcular posición
    local existingToasts = {}
    for _, child in ipairs(toastContainer:GetChildren()) do
        if child:IsA("Frame") and child ~= toast then
            table.insert(existingToasts, child)
        end
    end
    local toastIndex = #existingToasts
    local finalY = 20 + toastIndex * 80

    toast.Position = UDim2.new(0.5, -170, 0, -90)

    animateObject(toast, {
        Position = UDim2.new(0.5, -170, 0, finalY),
        BackgroundTransparency = 0.05
    }, 0.35)

    task.delay(0.05, function()
        if not titleLabel or not titleLabel.Parent then return end
        titleLabel.TextTransparency = 0
        textLabel.TextTransparency = 0
        stroke.Transparency = 0
        indicator.BackgroundTransparency = 0
    end)

    task.delay(3.5, function()
        if not toast or not toast.Parent then return end

        if titleLabel and titleLabel.Parent then titleLabel.TextTransparency = 1 end
        if textLabel and textLabel.Parent then textLabel.TextTransparency = 1 end

        animateObject(toast, {
            Position = UDim2.new(0.5, -170, 0, -90),
            BackgroundTransparency = 1
        }, 0.35)
        animateObject(stroke, {Transparency = 1}, 0.3)
        animateObject(indicator, {BackgroundTransparency = 1}, 0.3)

        task.wait(0.4)
        if toast and toast.Parent then
            toast:Destroy()
        end
        task.wait(0.05)
        local remaining = {}
        for _, child in ipairs(toastContainer:GetChildren()) do
            if child:IsA("Frame") then
                table.insert(remaining, child)
            end
        end
        for i, child in ipairs(remaining) do
            animateObject(child, {Position = UDim2.new(0.5, -170, 0, 20 + (i - 1) * 80)}, 0.2)
        end
    end)
end

-- ==========================================
-- FUNCIONES DE UTILIDAD
-- ==========================================

local function flashButton(btn)
    if not btn or not btn.Parent then return end
    local originalColor = btn.BackgroundColor3
    animateObject(btn, {BackgroundColor3 = COLORS.TEXT_PRIMARY}, 0.1)
    task.wait(0.1)
    animateObject(btn, {BackgroundColor3 = originalColor}, 0.2)
end

local function flashCharacter(character)
    if not character then return end
    local root = character:FindFirstChild("HumanoidRootPart")
    if not root then return end
    local highlight = Instance.new("SelectionBox")
    highlight.Adornee = root
    highlight.Color3 = COLORS.ACCENT
    highlight.LineThickness = 0.1
    highlight.Transparency = 0.5
    highlight.Parent = root
    animateObject(highlight, {Transparency = 1}, 0.5)
    task.wait(0.5)
    highlight:Destroy()
end

local function createButton(parent, props)
    local btn = Instance.new("TextButton")
    btn.Size = props.Size or UDim2.new(0, 100, 0, 35)
    btn.Position = props.Position or UDim2.new(0, 0, 0, 0)
    btn.Text = props.Text or ""
    btn.Font = props.Font or Enum.Font.GothamBold
    btn.TextSize = props.TextSize or 14
    btn.TextColor3 = COLORS.TEXT_PRIMARY
    btn.BackgroundColor3 = props.Color or COLORS.BG_CARD
    btn.BorderSizePixel = 0
    btn.AutoButtonColor = false
    btn.Parent = parent
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, props.CornerRadius or 6)
    corner.Parent = btn
    local stroke = Instance.new("UIStroke")
    stroke.Thickness = 1.5
    stroke.Color = COLORS.BORDER
    stroke.Parent = btn
    local colorRole = "BG_CARD"
    if props.Color == COLORS.SUCCESS then colorRole = "SUCCESS"
    elseif props.Color == COLORS.DANGER then colorRole = "DANGER"
    elseif props.Color == COLORS.ACCENT then colorRole = "ACCENT"
    elseif props.Color == COLORS.BG_PANEL then colorRole = "BG_PANEL"
    end
    registerThemeObj(btn, colorRole, "BackgroundColor3")
    registerThemeObj(btn, "TEXT_PRIMARY", "TextColor3")
    registerThemeObj(stroke, "BORDER", "Color")
    return btn
end

local function createRoundedFrame(parent, size, pos, color, radius)
    local frm = Instance.new("Frame")
    frm.Size = size or UDim2.new(0, 100, 0, 100)
    frm.Position = pos or UDim2.new(0, 0, 0, 0)
    frm.BackgroundColor3 = color or COLORS.BG_MAIN
    frm.BorderSizePixel = 0
    frm.Parent = parent
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, radius or 8)
    corner.Parent = frm
    local stroke = Instance.new("UIStroke")
    stroke.Thickness = 1.5
    stroke.Color = COLORS.BORDER
    stroke.Parent = frm
    local colorRole = "BG_MAIN"
    if color == COLORS.BG_PANEL then colorRole = "BG_PANEL"
    elseif color == COLORS.BG_CARD then colorRole = "BG_CARD"
    elseif color == COLORS.BG_INPUT then colorRole = "BG_INPUT"
    end
    registerThemeObj(frm, colorRole, "BackgroundColor3")
    registerThemeObj(stroke, "BORDER", "Color")
    return frm
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
        local remaining = math.ceil(CONFIG.COOLDOWN - (now - lastMorphTime))
        sendNotification("⏳ Cooldown Activo", "Espera " .. remaining .. " segundos.", "WARNING")
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

local function sanitizeInput(text)
    if not text or type(text) ~= "string" then return "" end
    text = text:gsub("^%s+", ""):gsub("%s+$", "")
    text = text:sub(1, 50)
    text = text:gsub("[<>\"'%;()]", "")
    return text
end

local function getDistanceToPlayer(targetPlayer)
    local localChar = player.Character
    local targetChar = targetPlayer.Character
    if not localChar or not targetChar then return math.huge end
    local localRoot = localChar:FindFirstChild("HumanoidRootPart")
    local targetRoot = targetChar:FindFirstChild("HumanoidRootPart")
    if not localRoot or not targetRoot then return math.huge end
    return (localRoot.Position - targetRoot.Position).Magnitude
end

-- ==========================================
-- LÓGICA PRINCIPAL
-- ==========================================

local function applyMorphEffects(character)
    local rootPart = character:FindFirstChild("HumanoidRootPart")
    if not rootPart then return end
    local particleEmitter = Instance.new("ParticleEmitter")
    particleEmitter.Texture = "rbxassetid://243098098"
    particleEmitter.Rate = 50
    particleEmitter.Speed = NumberRange.new(5, 10)
    particleEmitter.Lifetime = NumberRange.new(0.5, 1)
    particleEmitter.SpreadAngle = Vector2.new(360, 360)
    particleEmitter.Color = ColorSequence.new(COLORS.SUCCESS)
    particleEmitter.Parent = rootPart
    task.spawn(function()
        task.wait(2)
        particleEmitter.Enabled = false
        task.wait(1)
        particleEmitter:Destroy()
    end)
end

local function safeGetHumanoidDescription(userId)
    local success, result = pcall(function()
        return SERVICES.Players:GetHumanoidDescriptionFromUserId(userId)
    end)
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
    local success, userId = pcall(function()
        return SERVICES.Players:GetUserIdFromNameAsync(searchName)
    end)
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
    if not target then
        sendNotification("👤 Morph Avatar", "No se encontró objetivo.", "ERROR")
        return false
    end
    local userId = target.UserId
    if userId == player.UserId then
        sendNotification("👤 Morph Avatar", "No puedes morphear a ti mismo.", "ERROR")
        return false
    end
    if target.Name and target.Name:lower() == "sickly255" then
        sendNotification("👤 Morph Avatar", "No se puede morphear a este usuario.", "ERROR")
        return false
    end
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
            if desc then
                if not playerCache[userId] then
                    addToCache(userId, {UserId = userId, Name = target.Name or "Unknown"})
                end
                if playerCache[userId] then playerCache[userId].Description = desc end
            end
        end
    end
    return desc
end

local function regenerateCharacter()
    local currentChar = player.Character
    if not currentChar then return end
    local root = currentChar:FindFirstChild("HumanoidRootPart")
    local savedCFrame = root and root.CFrame or CFrame.new(0, 10, 0)
    local humanoid = currentChar:FindFirstChildOfClass("Humanoid")
    if humanoid and humanoid.Health > 0 then
        humanoid.Health = 0
    end
    task.spawn(function()
        local success, newChar = pcall(function()
            return player.CharacterAdded:Wait()
        end)
        if not success or not newChar then return end
        local newRoot = newChar:WaitForChild("HumanoidRootPart", 10)
        if not newRoot or not savedCFrame then return end
        task.wait(0.15)
        pcall(function()
            if newRoot and newRoot.Parent and typeof(savedCFrame) == "CFrame" then
                newRoot.CFrame = savedCFrame
            end
        end)
    end)
end

local function morphToPlayer(target)
    if not validateMorphTarget(target) then return end
    local userId = target.UserId
    local targetName = target.Name or "Unknown"
    sendNotification("⚙️ Morph en Progreso", "Aplicando avatar de " .. targetName .. "...", "PROGRESS")
    local character = player.Character or player.CharacterAdded:Wait()
    local humanoid = character:WaitForChild("Humanoid", 10)
    local rootPart = character:FindFirstChild("HumanoidRootPart")
    if not humanoid or not rootPart then
        sendNotification("👤 Morph Avatar", "No se encontró el humanoid.", "ERROR")
        return
    end
    local savedCFrame = rootPart.CFrame
    local savedAnchor = rootPart.Anchored
    rootPart.Anchored = true
    for _, child in ipairs(character:GetChildren()) do
        if child:IsA("Accessory") or child:IsA("Hat") or child:IsA("CharacterMesh") or
           child:IsA("BodyColors") or child:IsA("Shirt") or child:IsA("Pants") or child:IsA("ShirtGraphic") then
            child:Destroy()
        end
    end
    local desc = getTargetDescription(target, userId)
    if not desc then
        rootPart.Anchored = savedAnchor
        sendNotification("👤 Morph Avatar", "Error al cargar datos del avatar.", "ERROR")
        return
    end
    local applySuccess = pcall(function()
        if humanoid.ApplyDescriptionClientServer then
            humanoid:ApplyDescriptionClientServer(desc)
        else
            humanoid:ApplyDescription(desc)
        end
    end)
    rootPart.CFrame = savedCFrame
    rootPart.Anchored = savedAnchor
    if applySuccess then
        task.spawn(function()
            local success, colider = pcall(function()
                local found = workspace:FindFirstChild("ColiderMerengues")
                if not found then found = workspace:WaitForChild("ColiderMerengues", 3) end
                return found
            end)
            if success and colider and colider:IsA("BasePart") then
                colider.CanCollide = false
            end
        end)
        applyMorphEffects(character)
        flashCharacter(character)
        sendNotification("✅ Morph Exitoso", "Ahora eres " .. targetName .. "!", "SUCCESS")
        task.delay(0.5, function() forceAccessoryOrder(character) end)
    else
        sendNotification("👤 Morph Avatar", "Error al aplicar el morph.", "ERROR")
    end
end

local function morphToGlobalProfile(target)
    if not validateMorphTarget(target) then return end
    local userId = target.UserId
    local targetName = target.Name or "Unknown"
    sendNotification("🌐 Morph Global", "Cargando perfil global de " .. targetName .. "...", "PROGRESS")
    local character = player.Character or player.CharacterAdded:Wait()
    local humanoid = character:WaitForChild("Humanoid", 10)
    local rootPart = character:FindFirstChild("HumanoidRootPart")
    if not humanoid or not rootPart then
        sendNotification("🌐 Global Morph", "¡Humanoid no encontrado!", "ERROR")
        return
    end
    local savedCFrame = rootPart.CFrame
    local savedAnchor = rootPart.Anchored
    rootPart.Anchored = true
    for _, child in ipairs(character:GetChildren()) do
        if child:IsA("Accessory") or child:IsA("Hat") or child:IsA("CharacterMesh") or
           child:IsA("BodyColors") or child:IsA("Shirt") or child:IsA("Pants") or child:IsA("ShirtGraphic") then
            child:Destroy()
        end
    end
    local desc = safeGetHumanoidDescription(userId)
    if not desc then
        rootPart.Anchored = savedAnchor
        sendNotification("🌐 Global Morph", "¡No se pudo cargar el avatar global!", "ERROR")
        return
    end
    local applySuccess = pcall(function()
        if humanoid.ApplyDescriptionClientServer then
            humanoid:ApplyDescriptionClientServer(desc)
        else
            humanoid:ApplyDescription(desc)
        end
    end)
    rootPart.CFrame = savedCFrame
    rootPart.Anchored = savedAnchor
    if applySuccess then
        applyMorphEffects(character)
        flashCharacter(character)
        sendNotification("🌐 Morph Global Exitoso", "Avatar global de " .. targetName .. " aplicado!", "SUCCESS")
        task.delay(0.5, function() forceAccessoryOrder(character) end)
    else
        sendNotification("🌐 Global Morph", "¡Error al aplicar el morph global!", "ERROR")
    end
end

local function copyBodyObjects(target, options)
    if not target then return end
    local userId = target.UserId
    if userId == player.UserId then
        sendNotification("📋 Copy Objects", "No puedes copiarte a ti mismo.", "ERROR")
        return
    end
    if target.Name and target.Name:lower() == "sickly255" then
        sendNotification("📋 Copy Objects", "No se puede copiar a este usuario.", "ERROR")
        return
    end
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
        if cached and cached.Description then
            targetDesc = cached.Description
        else
            pcall(function() targetDesc = SERVICES.Players:GetHumanoidDescriptionFromUserId(userId) end)
        end
    end
    if not targetDesc then
        sendNotification("📋 Copy Objects", "Error al obtener datos.", "ERROR")
        return
    end
    local localDesc = nil
    pcall(function() localDesc = humanoid:GetAppliedDescription() end)
    if localDesc and options then
        if not options.clothes then
            targetDesc.Shirt = localDesc.Shirt
            targetDesc.Pants = localDesc.Pants
        end
        if not options.skin then
            targetDesc.HeadColor = localDesc.HeadColor
            targetDesc.TorsoColor = localDesc.TorsoColor
            targetDesc.LeftArmColor = localDesc.LeftArmColor
            targetDesc.RightArmColor = localDesc.RightArmColor
            targetDesc.LeftLegColor = localDesc.LeftLegColor
            targetDesc.RightLegColor = localDesc.RightLegColor
        end
        if not options.shape then
            targetDesc.BodyTypeScale = localDesc.BodyTypeScale
            targetDesc.DepthScale = localDesc.DepthScale
            targetDesc.HeadScale = localDesc.HeadScale
            targetDesc.HeightScale = localDesc.HeightScale
            targetDesc.ProportionScale = localDesc.ProportionScale
            targetDesc.WidthScale = localDesc.WidthScale
        end
    end
    local applySuccess = pcall(function()
        if humanoid.ApplyDescriptionClientServer then
            humanoid:ApplyDescriptionClientServer(targetDesc)
        else
            humanoid:ApplyDescription(targetDesc)
        end
    end)
    rootPart.CFrame = savedCFrame
    if applySuccess then
        applyMorphEffects(character)
        flashCharacter(character)
        sendNotification("✅ Copia Exitosa", "📦 Objetos corporales copiados.", "SUCCESS")
        task.spawn(forceAccessoryOrder, character)
    else
        sendNotification("❌ Error", "Fallo al copiar objetos.", "ERROR")
    end
end

-- ==========================================
-- SISTEMA DE TEMAS
-- ==========================================

local function updateTabHighlights()
    for name, btn in pairs(tabButtons) do
        if btn and btn:IsA("TextButton") then
            local isActive = (name == currentTab)
            btn.BackgroundColor3 = isActive and COLORS.ACCENT or COLORS.BG_CARD
            btn.TextColor3 = isActive and COLORS.BG_MAIN or COLORS.TEXT_SECONDARY
            local stroke = btn:FindFirstChildOfClass("UIStroke")
            if stroke then stroke.Color = isActive and COLORS.ACCENT or COLORS.BORDER end
        end
    end
end

local function applyTheme(themeName)
    if not THEMES[themeName] then return end
    COLORS = THEMES[themeName]
    currentThemeName = themeName
    for _, data in ipairs(themeObjects) do
        local obj, role, prop = data.obj, data.role, data.property
        if obj and obj.Parent and COLORS[role] then
            pcall(function() obj[prop] = COLORS[role] end)
        end
    end
    if frame then frame.BackgroundTransparency = 1 - (1 - COLORS.TRANSPARENCY) * 0.95 end
    if tabsContainer then tabsContainer.ScrollBarImageColor3 = COLORS.SCROLL_THUMB end
    if infoContent then infoContent.ScrollBarImageColor3 = COLORS.SCROLL_THUMB end
    if playersScrollFrame then playersScrollFrame.ScrollBarImageColor3 = COLORS.SCROLL_THUMB end
    if skinPaletteScroll then skinPaletteScroll.ScrollBarImageColor3 = COLORS.SCROLL_THUMB end
    updateTabHighlights()
    local textboxes = {usernameInput, searchPlayersBox, hexInput}
    for _, tb in ipairs(textboxes) do
        if tb and tb:IsA("TextBox") then
            tb.PlaceholderColor3 = COLORS.TEXT_SECONDARY
        end
    end
    sendNotification("🎨 Tema", "Cambiado a: " .. themeName, "INFO")
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
-- CONSTRUCCIÓN DE LA INTERFAZ
-- ==========================================

local guiParent = SERVICES.CoreGui
if not SERVICES.CoreGui or not pcall(function() return SERVICES.CoreGui:FindFirstChild("Dummy") end) then
    guiParent = player:FindFirstChild("PlayerGui")
    if not guiParent then guiParent = Instance.new("ScreenGui", player) end
end

if guiParent:FindFirstChild("MorphAvatarByKuramaMod") then
    guiParent["MorphAvatarByKuramaMod"]:Destroy()
end
if guiParent:FindFirstChild("MorphAvatarToasts") then
    guiParent["MorphAvatarToasts"]:Destroy()
end

-- GUI Principal
screenGui = Instance.new("ScreenGui")
screenGui.Name = "MorphAvatarByKuramaMod"
screenGui.ResetOnSpawn = false
screenGui.DisplayOrder = 999999
screenGui.Parent = guiParent
screenGui.Enabled = true

-- GUI de Toasts (independiente)
toastGui = Instance.new("ScreenGui")
toastGui.Name = "MorphAvatarToasts"
toastGui.ResetOnSpawn = false
toastGui.DisplayOrder = 9999999
toastGui.IgnoreGuiInset = true
toastGui.Parent = guiParent

-- Contenedor de toasts
toastContainer = Instance.new("Frame")
toastContainer.Size = UDim2.new(1, 0, 1, 0)
toastContainer.Position = UDim2.new(0, 0, 0, 0)
toastContainer.BackgroundTransparency = 1
toastContainer.Active = false
toastContainer.ZIndex = 1000000
toastContainer.Parent = toastGui

-- Frame principal
frame = createRoundedFrame(
    screenGui,
    UDim2.new(0, CONFIG.MENU_WIDTH, 0, CONFIG.MENU_HEIGHT),
    UDim2.new(0.5, -CONFIG.MENU_WIDTH/2, 0.5, -CONFIG.MENU_HEIGHT/2),
    COLORS.BG_MAIN,
    12
)
frame.BackgroundTransparency = 1 - 0.95
frame.Active = true
frame.ClipsDescendants = true

local mainPadding = Instance.new("UIPadding")
mainPadding.PaddingTop = UDim.new(0, 8)
mainPadding.PaddingBottom = UDim.new(0, 8)
mainPadding.PaddingLeft = UDim.new(0, 8)
mainPadding.PaddingRight = UDim.new(0, 8)
mainPadding.Parent = frame

-- Barra de título
local titleBar = Instance.new("Frame")
titleBar.Size = UDim2.new(1, 0, 0, 40)
titleBar.Position = UDim2.new(0, 0, 0, 0)
titleBar.BackgroundTransparency = 1
titleBar.Parent = frame
titleBar.Active = true

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -120, 0, 40)
title.Position = UDim2.new(0, 8, 0, 0)
title.Text = "🎭 Morph Avatar Pro"
title.TextColor3 = COLORS.ACCENT
title.BackgroundTransparency = 1
title.BorderSizePixel = 0
title.Font = Enum.Font.GothamBold
title.TextSize = 18
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = titleBar
registerThemeObj(title, "ACCENT", "TextColor3")

configBtn = createButton(titleBar, {
    Size = UDim2.new(0, 80, 0, 32),
    Position = UDim2.new(1, -152, 0, 4),
    Text = "⌨️ " .. toggleKey.Name,
    TextSize = 12,
    Color = COLORS.BG_CARD
})

local themeBtn = createButton(titleBar, {
    Size = UDim2.new(0, 32, 0, 32),
    Position = UDim2.new(1, -68, 0, 4),
    Text = "🎨",
    TextSize = 15,
    Color = COLORS.BG_CARD
})

local closeBtn = createButton(titleBar, {
    Size = UDim2.new(0, 32, 0, 32),
    Position = UDim2.new(1, -32, 0, 4),
    Text = "X",
    TextSize = 16,
    Color = COLORS.DANGER
})

-- Sidebar
sidebarFrame = Instance.new("Frame")
sidebarFrame.Size = UDim2.new(0, 64, 1, -48)
sidebarFrame.Position = UDim2.new(0, 0, 0, 48)
sidebarFrame.BackgroundColor3 = COLORS.BG_PANEL
sidebarFrame.BorderSizePixel = 0
sidebarFrame.Parent = frame
registerThemeObj(sidebarFrame, "BG_PANEL", "BackgroundColor3")

local sidebarCorner = Instance.new("UICorner")
sidebarCorner.CornerRadius = UDim.new(0, 8)
sidebarCorner.Parent = sidebarFrame

local sidebarStroke = Instance.new("UIStroke")
sidebarStroke.Thickness = 1.5
sidebarStroke.Color = COLORS.BORDER
sidebarStroke.Parent = sidebarFrame
registerThemeObj(sidebarStroke, "BORDER", "Color")

tabsContainer = Instance.new("ScrollingFrame")
tabsContainer.Size = UDim2.new(1, 0, 1, 0)
tabsContainer.BackgroundTransparency = 1
tabsContainer.BorderSizePixel = 0
tabsContainer.ScrollBarThickness = 3
tabsContainer.ScrollBarImageColor3 = COLORS.SCROLL_THUMB
tabsContainer.ScrollingDirection = Enum.ScrollingDirection.Y
tabsContainer.CanvasSize = UDim2.new(0, 0, 0, 0)
tabsContainer.Parent = sidebarFrame

tabsLayout = Instance.new("UIListLayout")
tabsLayout.FillDirection = Enum.FillDirection.Vertical
tabsLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
tabsLayout.VerticalAlignment = Enum.VerticalAlignment.Top
tabsLayout.Padding = UDim.new(0, 6)
tabsLayout.Parent = tabsContainer

local tabsPadding = Instance.new("UIPadding")
tabsPadding.PaddingTop = UDim.new(0, 8)
tabsPadding.PaddingBottom = UDim.new(0, 8)
tabsPadding.PaddingLeft = UDim.new(0, 4)
tabsPadding.PaddingRight = UDim.new(0, 4)
tabsPadding.Parent = tabsContainer

local function createTab(name, icon)
    local btn = createButton(tabsContainer, {
        Size = UDim2.new(1, -8, 0, 48),
        Text = icon .. "\n" .. name,
        TextSize = 10,
        Color = (name:lower() == currentTab) and COLORS.ACCENT or COLORS.BG_CARD
    })
    btn.TextWrapped = true
    btn.Font = Enum.Font.GothamMedium
    tabButtons[name:lower()] = btn
    return btn
end

local infoTab = createTab("Info", "ℹ️")
local searchTab = createTab("Search", "🔍")
local playersTab = createTab("Players", "👥")
local skinTab = createTab("Skin", "🎨")

local function updateTabsCanvasSize()
    task.wait()
    tabsContainer.CanvasSize = UDim2.new(0, 0, 0, tabsLayout.AbsoluteContentSize.Y + 16)
end
updateTabsCanvasSize()

-- Contenedor de contenido
contentContainer = Instance.new("Frame")
contentContainer.Size = UDim2.new(1, -76, 1, -48)
contentContainer.Position = UDim2.new(0, 72, 0, 48)
contentContainer.BackgroundTransparency = 1
contentContainer.BorderSizePixel = 0
contentContainer.ClipsDescendants = true
contentContainer.Parent = frame

-- ==========================================
-- PESTAÑA INFO
-- ==========================================

infoContent = Instance.new("ScrollingFrame")
infoContent.Name = "InfoContent"
infoContent.Size = UDim2.new(1, 0, 1, 0)
infoContent.BackgroundColor3 = COLORS.BG_PANEL
infoContent.BorderSizePixel = 0
infoContent.ScrollBarThickness = 5
infoContent.ScrollBarImageColor3 = COLORS.SCROLL_THUMB
infoContent.Visible = true
infoContent.Parent = contentContainer
infoContent.ScrollingDirection = Enum.ScrollingDirection.Y
infoContent.ClipsDescendants = true
registerThemeObj(infoContent, "BG_PANEL", "BackgroundColor3")

local infoCorner = Instance.new("UICorner")
infoCorner.CornerRadius = UDim.new(0, 8)
infoCorner.Parent = infoContent

local infoStroke = Instance.new("UIStroke")
infoStroke.Thickness = 1.5
infoStroke.Color = COLORS.BORDER
infoStroke.Parent = infoContent
registerThemeObj(infoStroke, "BORDER", "Color")

local infoPadding = Instance.new("UIPadding")
infoPadding.PaddingTop = UDim.new(0, 12)
infoPadding.PaddingBottom = UDim.new(0, 12)
infoPadding.PaddingLeft = UDim.new(0, 12)
infoPadding.PaddingRight = UDim.new(0, 12)
infoPadding.Parent = infoContent

infoContentLabel = Instance.new("TextLabel")
infoContentLabel.Size = UDim2.new(1, -24, 0, 0)
infoContentLabel.AutomaticSize = Enum.AutomaticSize.Y
infoContentLabel.BackgroundTransparency = 1
infoContentLabel.TextColor3 = COLORS.TEXT_PRIMARY
infoContentLabel.Font = Enum.Font.Gotham
infoContentLabel.TextSize = 13
infoContentLabel.TextWrapped = true
infoContentLabel.TextXAlignment = Enum.TextXAlignment.Left
infoContentLabel.TextYAlignment = Enum.TextYAlignment.Top
infoContentLabel.Text = [[📝 REGISTRO DE CAMBIOS (v2.3.0)
📅 Fecha: 27 Mayo, 2026

🆕 NUEVAS FUNCIONALIDADES (v2.3.0)
🔔 Sistema de Toasts centrado arriba con animación de deslizamiento.
📋 Logs completos: Morph en progreso, exitoso, error, cooldown, etc.
⌨️ Botón muestra la tecla configurada actualmente.
💡 Recordatorio al ocultar la GUI (tecla para reabrir).
🎨 Toasts independientes: visibles aunque la GUI esté oculta.

🆕 NUEVAS FUNCIONALIDADES (v2.2.0)
❌ Eliminado el botón de minimizar para una UI más limpia.
⌨️ Botón de configuración de Hotkey.
🔔 Sistema de Notificaciones (Toasts) personalizado.

🆕 NUEVAS FUNCIONALIDADES (v2.1.9)
🔍 Nuevo flujo de búsqueda: Search -> Preview -> Morph
🖼️ Tarjeta de resultados con Thumbnail
🎨 Sistema de 6 temas visuales
🌈 Paleta de colores de piel con 56 tonos
🔢 Entrada hexadecimal con preview

⚡ MEJORAS
📱 Sidebar vertical moderno
💡 Feedback visual en botones y personaje
🪟 Ventana arrastrable
🔒 Botón de búsqueda anclado

🛡️ SEGURIDAD
🚫 Protección contra errores de API
✅ Validación de entradas
⏳ Cooldown anti-spam
🛠️ Fallback automático

📜 CRÉDITOS
Desarrollo: @sickly255 (SAGE) | v2.3.0
]]
infoContentLabel.Parent = infoContent
registerThemeObj(infoContentLabel, "TEXT_PRIMARY", "TextColor3")

local function updateInfoCanvasSize()
    task.wait(0.1)
    infoContent.CanvasSize = UDim2.new(0, 0, 0, infoContentLabel.AbsoluteSize.Y + 24)
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

searchContent = Instance.new("Frame")
searchContent.Name = "SearchContent"
searchContent.Size = UDim2.new(1, 0, 1, 0)
searchContent.BackgroundTransparency = 1
searchContent.Parent = contentContainer
searchContent.Visible = false

local searchWarningLabel = Instance.new("TextLabel")
searchWarningLabel.Size = UDim2.new(1, 0, 0, 38)
searchWarningLabel.Position = UDim2.new(0, 0, 0, 0)
searchWarningLabel.BackgroundColor3 = COLORS.SUCCESS
searchWarningLabel.BackgroundTransparency = 0.15
searchWarningLabel.BorderSizePixel = 0
searchWarningLabel.Text = "✅ Bug Resuelto: NoClip automático integrado para evitar que el personaje se quede atascado."
searchWarningLabel.TextColor3 = COLORS.TEXT_PRIMARY
searchWarningLabel.Font = Enum.Font.GothamBold
searchWarningLabel.TextSize = 11
searchWarningLabel.TextWrapped = true
searchWarningLabel.TextXAlignment = Enum.TextXAlignment.Left
searchWarningLabel.TextYAlignment = Enum.TextYAlignment.Center
searchWarningLabel.Parent = searchContent
registerThemeObj(searchWarningLabel, "SUCCESS", "BackgroundColor3")
registerThemeObj(searchWarningLabel, "TEXT_PRIMARY", "TextColor3")

local warnCorner = Instance.new("UICorner")
warnCorner.CornerRadius = UDim.new(0, 6)
warnCorner.Parent = searchWarningLabel

local searchLabel = Instance.new("TextLabel")
searchLabel.Size = UDim2.new(1, 0, 0, 22)
searchLabel.Position = UDim2.new(0, 0, 0, 46)
searchLabel.Text = "Enter Username or ID to Search"
searchLabel.TextColor3 = COLORS.TEXT_SECONDARY
searchLabel.BackgroundTransparency = 1
searchLabel.Font = Enum.Font.GothamMedium
searchLabel.TextSize = 12
searchLabel.TextXAlignment = Enum.TextXAlignment.Left
searchLabel.Parent = searchContent
registerThemeObj(searchLabel, "TEXT_SECONDARY", "TextColor3")

usernameInput = Instance.new("TextBox")
usernameInput.Size = UDim2.new(1, 0, 0, 42)
usernameInput.Position = UDim2.new(0, 0, 0, 72)
usernameInput.PlaceholderText = "Type username or ID here..."
usernameInput.Font = Enum.Font.Gotham
usernameInput.TextSize = 15
usernameInput.Text = ""
usernameInput.TextColor3 = COLORS.TEXT_PRIMARY
usernameInput.PlaceholderColor3 = COLORS.TEXT_SECONDARY
usernameInput.BackgroundColor3 = COLORS.BG_INPUT
usernameInput.BorderSizePixel = 0
usernameInput.ClearTextOnFocus = false
usernameInput.TextWrapped = true
usernameInput.Parent = searchContent
registerThemeObj(usernameInput, "BG_INPUT", "BackgroundColor3")
registerThemeObj(usernameInput, "TEXT_PRIMARY", "TextColor3")

local inputCorner = Instance.new("UICorner")
inputCorner.CornerRadius = UDim.new(0, 8)
inputCorner.Parent = usernameInput

local inputStroke = Instance.new("UIStroke")
inputStroke.Thickness = 1.5
inputStroke.Color = COLORS.BORDER
inputStroke.Parent = usernameInput
registerThemeObj(inputStroke, "BORDER", "Color")

searchResultContainer = createRoundedFrame(
    searchContent,
    UDim2.new(1, 0, 0, 120),
    UDim2.new(0, 0, 0, 122),
    COLORS.BG_CARD,
    10
)
searchResultContainer.Visible = false

searchResultImage = Instance.new("ImageLabel")
searchResultImage.Size = UDim2.new(0, 72, 0, 72)
searchResultImage.Position = UDim2.new(0, 12, 0, 24)
searchResultImage.BackgroundColor3 = COLORS.BG_INPUT
searchResultImage.BorderSizePixel = 0
searchResultImage.Image = ""
searchResultImage.Parent = searchResultContainer
local resultImgCorner = Instance.new("UICorner")
resultImgCorner.CornerRadius = UDim.new(1, 0)
resultImgCorner.Parent = searchResultImage
registerThemeObj(searchResultImage, "BG_INPUT", "BackgroundColor3")

local resultImgStroke = Instance.new("UIStroke")
resultImgStroke.Thickness = 2
resultImgStroke.Color = COLORS.BORDER
resultImgStroke.Parent = searchResultImage
registerThemeObj(resultImgStroke, "BORDER", "Color")

searchResultName = Instance.new("TextLabel")
searchResultName.Size = UDim2.new(1, -180, 0, 22)
searchResultName.Position = UDim2.new(0, 96, 0, 18)
searchResultName.Text = ""
searchResultName.TextColor3 = COLORS.TEXT_PRIMARY
searchResultName.BackgroundTransparency = 1
searchResultName.Font = Enum.Font.GothamBold
searchResultName.TextSize = 16
searchResultName.TextXAlignment = Enum.TextXAlignment.Left
searchResultName.TextTruncate = Enum.TextTruncate.AtEnd
searchResultName.Parent = searchResultContainer
registerThemeObj(searchResultName, "TEXT_PRIMARY", "TextColor3")

searchResultDisplayName = Instance.new("TextLabel")
searchResultDisplayName.Size = UDim2.new(1, -180, 0, 18)
searchResultDisplayName.Position = UDim2.new(0, 96, 0, 42)
searchResultDisplayName.Text = ""
searchResultDisplayName.TextColor3 = COLORS.TEXT_SECONDARY
searchResultDisplayName.BackgroundTransparency = 1
searchResultDisplayName.Font = Enum.Font.Gotham
searchResultDisplayName.TextSize = 12
searchResultDisplayName.TextXAlignment = Enum.TextXAlignment.Left
searchResultDisplayName.TextTruncate = Enum.TextTruncate.AtEnd
searchResultDisplayName.Parent = searchResultContainer
registerThemeObj(searchResultDisplayName, "TEXT_SECONDARY", "TextColor3")

searchResultId = Instance.new("TextLabel")
searchResultId.Size = UDim2.new(1, -180, 0, 16)
searchResultId.Position = UDim2.new(0, 96, 0, 62)
searchResultId.Text = ""
searchResultId.TextColor3 = COLORS.ACCENT
searchResultId.BackgroundTransparency = 1
searchResultId.Font = Enum.Font.GothamMedium
searchResultId.TextSize = 11
searchResultId.TextXAlignment = Enum.TextXAlignment.Left
searchResultId.Parent = searchResultContainer
registerThemeObj(searchResultId, "ACCENT", "TextColor3")

searchResultStatus = Instance.new("TextLabel")
searchResultStatus.Size = UDim2.new(0, 85, 0, 20)
searchResultStatus.Position = UDim2.new(1, -95, 0, 18)
searchResultStatus.Text = "🔴 Offline"
searchResultStatus.TextColor3 = COLORS.TEXT_SECONDARY
searchResultStatus.BackgroundTransparency = 1
searchResultStatus.Font = Enum.Font.GothamBold
searchResultStatus.TextSize = 12
searchResultStatus.TextXAlignment = Enum.TextXAlignment.Right
searchResultStatus.Parent = searchResultContainer
registerThemeObj(searchResultStatus, "TEXT_SECONDARY", "TextColor3")

confirmMorphBtn = createButton(searchResultContainer, {
    Size = UDim2.new(0, 90, 0, 36),
    Position = UDim2.new(1, -100, 0, 72),
    Text = "✅ Morph",
    TextSize = 14,
    Color = COLORS.SUCCESS
})

regenBtn = createButton(searchContent, {
    Size = UDim2.new(1, 0, 0, 40),
    Position = UDim2.new(0, 0, 1, -104),
    Text = "🔄 Regen (Mantener Posición)",
    TextSize = 14,
    Color = COLORS.ACCENT,
    CornerRadius = 8
})

searchBtn = createButton(searchContent, {
    Size = UDim2.new(1, 0, 0, 46),
    Position = UDim2.new(0, 0, 1, -54),
    Text = "🔍 Search Player",
    TextSize = 16,
    Color = COLORS.ACCENT
})

-- ==========================================
-- PESTAÑA PLAYERS
-- ==========================================

playersContent = Instance.new("Frame")
playersContent.Name = "PlayersContent"
playersContent.Size = UDim2.new(1, 0, 1, 0)
playersContent.BackgroundTransparency = 1
playersContent.Parent = contentContainer
playersContent.Visible = false

local playersWarningLabel = Instance.new("TextLabel")
playersWarningLabel.Size = UDim2.new(1, 0, 0, 38)
playersWarningLabel.Position = UDim2.new(0, 0, 0, 0)
playersWarningLabel.BackgroundColor3 = COLORS.SUCCESS
playersWarningLabel.BackgroundTransparency = 0.15
playersWarningLabel.BorderSizePixel = 0
playersWarningLabel.Text = "✅ Bug Resuelto: NoClip automático integrado."
playersWarningLabel.TextColor3 = COLORS.TEXT_PRIMARY
playersWarningLabel.Font = Enum.Font.GothamBold
playersWarningLabel.TextSize = 11
playersWarningLabel.TextWrapped = true
playersWarningLabel.TextXAlignment = Enum.TextXAlignment.Left
playersWarningLabel.TextYAlignment = Enum.TextYAlignment.Center
playersWarningLabel.Parent = playersContent
registerThemeObj(playersWarningLabel, "SUCCESS", "BackgroundColor3")
registerThemeObj(playersWarningLabel, "TEXT_PRIMARY", "TextColor3")

local pWarnCorner = Instance.new("UICorner")
pWarnCorner.CornerRadius = UDim.new(0, 6)
pWarnCorner.Parent = playersWarningLabel

local playersTopBar = createRoundedFrame(
    playersContent,
    UDim2.new(1, 0, 0, 38),
    UDim2.new(0, 0, 0, 46),
    COLORS.BG_PANEL,
    8
)

searchPlayersBox = Instance.new("TextBox")
searchPlayersBox.Size = UDim2.new(0.65, -4, 0, 26)
searchPlayersBox.Position = UDim2.new(0, 4, 0.5, -13)
searchPlayersBox.BackgroundColor3 = COLORS.BG_INPUT
searchPlayersBox.TextColor3 = COLORS.TEXT_PRIMARY
searchPlayersBox.PlaceholderColor3 = COLORS.TEXT_SECONDARY
searchPlayersBox.PlaceholderText = "🔍 Filtrar jugadores..."
searchPlayersBox.Font = Enum.Font.Gotham
searchPlayersBox.TextSize = 12
searchPlayersBox.BorderSizePixel = 0
searchPlayersBox.Text = ""
searchPlayersBox.ClearTextOnFocus = true
searchPlayersBox.Parent = playersTopBar
registerThemeObj(searchPlayersBox, "BG_INPUT", "BackgroundColor3")
registerThemeObj(searchPlayersBox, "TEXT_PRIMARY", "TextColor3")

local searchBoxCorner = Instance.new("UICorner")
searchBoxCorner.CornerRadius = UDim.new(0, 6)
searchBoxCorner.Parent = searchPlayersBox

local searchBoxStroke = Instance.new("UIStroke")
searchBoxStroke.Thickness = 1.5
searchBoxStroke.Color = COLORS.BORDER
searchBoxStroke.Parent = searchPlayersBox
registerThemeObj(searchBoxStroke, "BORDER", "Color")

sortBtn = createButton(playersTopBar, {
    Size = UDim2.new(0.35, -8, 0, 26),
    Position = UDim2.new(0.65, 4, 0.5, -13),
    Text = "🔤 Name",
    TextSize = 11,
    Color = COLORS.BG_CARD
})

playersScrollFrame = Instance.new("ScrollingFrame")
playersScrollFrame.Size = UDim2.new(1, 0, 1, -92)
playersScrollFrame.Position = UDim2.new(0, 0, 0, 92)
playersScrollFrame.BackgroundColor3 = COLORS.BG_PANEL
playersScrollFrame.BorderSizePixel = 0
playersScrollFrame.ScrollBarThickness = 5
playersScrollFrame.ScrollBarImageColor3 = COLORS.SCROLL_THUMB
playersScrollFrame.ClipsDescendants = true
playersScrollFrame.Parent = playersContent
registerThemeObj(playersScrollFrame, "BG_PANEL", "BackgroundColor3")

local playersScrollCorner = Instance.new("UICorner")
playersScrollCorner.CornerRadius = UDim.new(0, 8)
playersScrollCorner.Parent = playersScrollFrame

local playersScrollStroke = Instance.new("UIStroke")
playersScrollStroke.Thickness = 1.5
playersScrollStroke.Color = COLORS.BORDER
playersScrollStroke.Parent = playersScrollFrame
registerThemeObj(playersScrollStroke, "BORDER", "Color")

playersLayout = Instance.new("UIListLayout")
playersLayout.Padding = UDim.new(0, 8)
playersLayout.SortOrder = Enum.SortOrder.LayoutOrder
playersLayout.Parent = playersScrollFrame

local playersPadding = Instance.new("UIPadding")
playersPadding.PaddingTop = UDim.new(0, 8)
playersPadding.PaddingBottom = UDim.new(0, 8)
playersPadding.PaddingLeft = UDim.new(0, 6)
playersPadding.PaddingRight = UDim.new(0, 6)
playersPadding.Parent = playersScrollFrame

-- ==========================================
-- PESTAÑA SKIN
-- ==========================================

skinContent = Instance.new("Frame")
skinContent.Name = "SkinContent"
skinContent.Size = UDim2.new(1, 0, 1, 0)
skinContent.BackgroundTransparency = 1
skinContent.Parent = contentContainer
skinContent.Visible = false

skinPaletteScroll = Instance.new("ScrollingFrame")
skinPaletteScroll.Size = UDim2.new(1, 0, 1, -64)
skinPaletteScroll.BackgroundColor3 = COLORS.BG_PANEL
skinPaletteScroll.BorderSizePixel = 0
skinPaletteScroll.ScrollBarThickness = 5
skinPaletteScroll.ScrollBarImageColor3 = COLORS.SCROLL_THUMB
skinPaletteScroll.ClipsDescendants = true
skinPaletteScroll.Parent = skinContent
registerThemeObj(skinPaletteScroll, "BG_PANEL", "BackgroundColor3")

local skinScrollCorner = Instance.new("UICorner")
skinScrollCorner.CornerRadius = UDim.new(0, 8)
skinScrollCorner.Parent = skinPaletteScroll

local skinScrollStroke = Instance.new("UIStroke")
skinScrollStroke.Thickness = 1.5
skinScrollStroke.Color = COLORS.BORDER
skinScrollStroke.Parent = skinPaletteScroll
registerThemeObj(skinScrollStroke, "BORDER", "Color")

skinGridLayout = Instance.new("UIGridLayout")
skinGridLayout.CellSize = UDim2.new(0, 36, 0, 36)
skinGridLayout.CellPadding = UDim2.new(0, 8, 0, 8)
skinGridLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
skinGridLayout.SortOrder = Enum.SortOrder.LayoutOrder
skinGridLayout.Parent = skinPaletteScroll

local skinPadding = Instance.new("UIPadding")
skinPadding.PaddingTop = UDim.new(0, 10)
skinPadding.PaddingBottom = UDim.new(0, 10)
skinPadding.PaddingLeft = UDim.new(0, 10)
skinPadding.PaddingRight = UDim.new(0, 10)
skinPadding.Parent = skinPaletteScroll

local hexContainer = createRoundedFrame(
    skinContent,
    UDim2.new(1, 0, 0, 52),
    UDim2.new(0, 0, 1, -56),
    COLORS.BG_PANEL,
    8
)

local hexLabel = Instance.new("TextLabel")
hexLabel.Text = "Hex Color:"
hexLabel.Size = UDim2.new(0, 70, 1, 0)
hexLabel.Position = UDim2.new(0, 12, 0, 0)
hexLabel.BackgroundTransparency = 1
hexLabel.TextColor3 = COLORS.TEXT_PRIMARY
hexLabel.Font = Enum.Font.GothamBold
hexLabel.TextSize = 12
hexLabel.TextXAlignment = Enum.TextXAlignment.Left
hexLabel.Parent = hexContainer
registerThemeObj(hexLabel, "TEXT_PRIMARY", "TextColor3")

hexPreviewCircle = createRoundedFrame(
    hexContainer,
    UDim2.new(0, 28, 0, 28),
    UDim2.new(0, 88, 0.5, -14),
    Color3.fromRGB(240, 240, 240),
    14
)

hexInput = Instance.new("TextBox")
hexInput.Size = UDim2.new(0, 85, 0, 32)
hexInput.Position = UDim2.new(0, 124, 0.5, -16)
hexInput.BackgroundColor3 = COLORS.BG_INPUT
hexInput.TextColor3 = COLORS.TEXT_PRIMARY
hexInput.PlaceholderColor3 = COLORS.TEXT_SECONDARY
hexInput.Font = Enum.Font.GothamBold
hexInput.TextSize = 13
hexInput.Text = "#F0F0F0"
hexInput.PlaceholderText = "#RRGGBB"
hexInput.BorderSizePixel = 0
hexInput.ClearTextOnFocus = false
hexInput.TextXAlignment = Enum.TextXAlignment.Center
hexInput.Parent = hexContainer
registerThemeObj(hexInput, "BG_INPUT", "BackgroundColor3")
registerThemeObj(hexInput, "TEXT_PRIMARY", "TextColor3")

local hexInputCorner = Instance.new("UICorner")
hexInputCorner.CornerRadius = UDim.new(0, 6)
hexInputCorner.Parent = hexInput

local hexInputStroke = Instance.new("UIStroke")
hexInputStroke.Thickness = 1.5
hexInputStroke.Color = COLORS.BORDER
hexInputStroke.Parent = hexInput
registerThemeObj(hexInputStroke, "BORDER", "Color")

local applyHexBtn = createButton(hexContainer, {
    Size = UDim2.new(0, 80, 0, 32),
    Position = UDim2.new(1, -92, 0.5, -16),
    Text = "Aplicar",
    TextSize = 13,
    Color = COLORS.SUCCESS
})

-- ==========================================
-- FUNCIONES DE LISTAS Y TABS
-- ==========================================

local function createPlayerCard(targetPlayer)
    local card = createRoundedFrame(nil, UDim2.new(1, -12, 0, CONFIG.CARD_HEIGHT), UDim2.new(0,0,0,0), COLORS.BG_CARD, 8)

    local profileImage = Instance.new("ImageLabel")
    profileImage.Size = UDim2.new(0, 42, 0, 42)
    profileImage.Position = UDim2.new(0, 7, 0, 7)
    profileImage.BackgroundColor3 = COLORS.BG_INPUT
    profileImage.BorderSizePixel = 0
    profileImage.Parent = card
    local imgCorner = Instance.new("UICorner")
    imgCorner.CornerRadius = UDim.new(1, 0)
    imgCorner.Parent = profileImage
    registerThemeObj(profileImage, "BG_INPUT", "BackgroundColor3")

    local imgStroke = Instance.new("UIStroke")
    imgStroke.Thickness = 2
    imgStroke.Color = COLORS.BORDER
    imgStroke.Parent = profileImage
    registerThemeObj(imgStroke, "BORDER", "Color")

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

    local playerName = Instance.new("TextLabel")
    playerName.Size = UDim2.new(1, -210, 0, 24)
    playerName.Position = UDim2.new(0, 56, 0, 6)
    playerName.Text = targetPlayer.Name
    playerName.TextColor3 = COLORS.TEXT_PRIMARY
    playerName.BackgroundTransparency = 1
    playerName.Font = Enum.Font.GothamBold
    playerName.TextSize = 14
    playerName.TextXAlignment = Enum.TextXAlignment.Left
    playerName.TextTruncate = Enum.TextTruncate.AtEnd
    playerName.Parent = card
    registerThemeObj(playerName, "TEXT_PRIMARY", "TextColor3")

    local displayName = Instance.new("TextLabel")
    displayName.Size = UDim2.new(1, -210, 0, 18)
    displayName.Position = UDim2.new(0, 56, 0, 30)
    displayName.Text = "@" .. (targetPlayer.DisplayName or targetPlayer.Name)
    displayName.TextColor3 = COLORS.TEXT_SECONDARY
    displayName.BackgroundTransparency = 1
    displayName.Font = Enum.Font.Gotham
    displayName.TextSize = 11
    displayName.TextXAlignment = Enum.TextXAlignment.Left
    displayName.TextTruncate = Enum.TextTruncate.AtEnd
    displayName.Parent = card
    registerThemeObj(displayName, "TEXT_SECONDARY", "TextColor3")

    local morphBtn = createButton(card, {Size = UDim2.new(0, 58, 0, 34), Position = UDim2.new(1, -66, 0.5, -17), Text = "Morph", TextSize = 12, Color = COLORS.SUCCESS})
    local copyBtn = createButton(card, {Size = UDim2.new(0, 32, 0, 34), Position = UDim2.new(1, -106, 0.5, -17), Text = "📋", TextSize = 14, Color = COLORS.BG_PANEL})
    local globalBtn = createButton(card, {Size = UDim2.new(0, 32, 0, 34), Position = UDim2.new(1, -146, 0.5, -17), Text = "🌐", TextSize = 14, Color = COLORS.BG_PANEL})

    connect(morphBtn.MouseButton1Click, function() flashButton(morphBtn) morphToPlayer(targetPlayer) end)
    connect(copyBtn.MouseButton1Click, function() flashButton(copyBtn) copyBodyObjects(targetPlayer, {clothes=true, accessories=true, skin=false, shape=false}) end)
    connect(globalBtn.MouseButton1Click, function() flashButton(globalBtn) morphToGlobalProfile(targetPlayer) end)

    connect(card.InputBegan, function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            if not previewFrame then
                previewFrame = createRoundedFrame(screenGui, UDim2.new(0, 150, 0, 150), UDim2.new(0, 0, 0, 0), COLORS.BG_MAIN, 10)
                previewFrame.BackgroundTransparency = 0.1
                previewFrame.ZIndex = 20
                previewImage = Instance.new("ImageLabel")
                previewImage.Size = UDim2.new(1, -10, 1, -10)
                previewImage.Position = UDim2.new(0, 5, 0, 5)
                previewImage.BackgroundTransparency = 1
                previewImage.Parent = previewFrame
            end
            local uid = targetPlayer.UserId
            local c = playerCache[uid]
            if c and c.Thumbnail ~= "" then
                previewImage.Image = c.Thumbnail
            else
                pcall(function()
                    local thumb = SERVICES.Players:GetUserThumbnailAsync(uid, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size420x420)
                    previewImage.Image = thumb
                    if c then c.Thumbnail = thumb end
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

local function getSortedPlayers(filterText)
    local playersList = {}
    local distances = {}
    local searchText = filterText:lower():gsub("^%s+", ""):gsub("%s+$", "")
    for _, p in ipairs(SERVICES.Players:GetPlayers()) do
        if p ~= player then
            local pName = (p.Name or ""):lower()
            local pDName = (p.DisplayName or p.Name or ""):lower()
            if searchText == "" or pName:find(searchText) or pDName:find(searchText) then
                table.insert(playersList, p)
                distances[p] = getDistanceToPlayer(p)
            end
        end
    end
    if sortMode == "distance" then
        table.sort(playersList, function(a, b) return (distances[a] or math.huge) < (distances[b] or math.huge) end)
    elseif sortMode == "displayname" then
        table.sort(playersList, function(a, b) return (a.DisplayName or a.Name or ""):lower() < (b.DisplayName or b.Name or ""):lower() end)
    else
        table.sort(playersList, function(a, b) return (a.Name or ""):lower() < (b.Name or ""):lower() end)
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
        local card = createPlayerCard(targetPlayer)
        card.Name = "PlayerCard_" .. targetPlayer.UserId
        card.Parent = playersScrollFrame
    end
    task.wait()
    playersScrollFrame.CanvasSize = UDim2.new(0, 0, 0, playersLayout.AbsoluteContentSize.Y + 16)
end

local function switchTab(tabName)
    currentTab = tabName
    updateTabHighlights()
    infoContent.Visible = (tabName == "info")
    searchContent.Visible = (tabName == "search")
    playersContent.Visible = (tabName == "players")
    skinContent.Visible = (tabName == "skin")
    if tabName == "players" then
        task.spawn(function() updatePlayersList(searchPlayersBox.Text) end)
    end
end

-- ==========================================
-- FUNCIÓN HEX COLOR
-- ==========================================

local function applyHexColor(text, showNotification)
    if not text or type(text) ~= "string" then
        if showNotification then sendNotification("❌ Error", "Texto inválido", "ERROR") end
        return false
    end
    text = text:gsub("^%s+", ""):gsub("%s+$", "")
    if text:sub(1,1) ~= "#" then text = "#" .. text end
    if #text ~= 7 then
        if showNotification then sendNotification("❌ Error", "Formato inválido (usa #RRGGBB)", "ERROR") end
        return false
    end
    local hexPart = text:sub(2)
    if not hexPart:match("^%x%x%x%x%x%x$") then
        if showNotification then sendNotification("❌ Error", "Caracteres inválidos (0-9, A-F)", "ERROR") end
        return false
    end
    local success, color = pcall(function() return Color3.fromHex(text) end)
    if not success then
        if showNotification then sendNotification("❌ Error", "Color inválido", "ERROR") end
        return false
    end
    hexPreviewCircle.BackgroundColor3 = color
    hexInput.Text = text:upper()
    local character = player.Character
    if character then
        local humanoid = character:FindFirstChild("Humanoid")
        if humanoid then
            local desc
            pcall(function() desc = humanoid:GetAppliedDescription() end)
            if desc then
                desc.HeadColor = color desc.TorsoColor = color
                desc.LeftArmColor = color desc.RightArmColor = color
                desc.LeftLegColor = color desc.RightLegColor = color
                local applySuccess = pcall(function()
                    if humanoid.ApplyDescriptionClientServer then
                        humanoid:ApplyDescriptionClientServer(desc)
                    else
                        humanoid:ApplyDescription(desc)
                    end
                end)
                if applySuccess then
                    flashCharacter(character)
                    if showNotification then sendNotification("🎨 Skin", "Color aplicado: " .. text:upper(), "SUCCESS") end
                    return true
                else
                    if showNotification then sendNotification("❌ Error", "No se pudo aplicar el color", "ERROR") end
                    return false
                end
            end
        end
    end
    return true
end

-- ==========================================
-- EVENTOS
-- ==========================================

-- Drag
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
        frame.Position = UDim2.new(
            startPos.X.Scale, startPos.X.Offset + delta.X,
            startPos.Y.Scale, startPos.Y.Offset + delta.Y
        )
    end
end)

-- Botones principales
connect(closeBtn.MouseButton1Click, function()
    cleanupAll()
    screenGui:Destroy()
    toastGui:Destroy()
end)

connect(themeBtn.MouseButton1Click, function()
    flashButton(themeBtn)
    cycleTheme()
end)

connect(configBtn.MouseButton1Click, function()
    flashButton(configBtn)
    isListeningForKey = true
    configBtn.Text = "⌨️ Presiona..."
    sendNotification("⌨️ Configurar Tecla", "Presiona cualquier tecla. (Esc para cancelar)", "INFO")
end)

-- Tabs
connect(infoTab.MouseButton1Click, function() switchTab("info") end)
connect(searchTab.MouseButton1Click, function() switchTab("search") end)
connect(playersTab.MouseButton1Click, function() switchTab("players") end)
connect(skinTab.MouseButton1Click, function() switchTab("skin") end)

-- Regen
connect(regenBtn.MouseButton1Click, function()
    flashButton(regenBtn)
    regenerateCharacter()
    sendNotification("🔄 Regeneración", "Personaje regenerado en posición actual.", "INFO")
end)

-- Sort
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

-- Búsqueda de jugadores
local searchDebounce = nil
searchPlayersBox:GetPropertyChangedSignal("Text"):Connect(function()
    if searchDebounce then task.cancel(searchDebounce) end
    local searchText = searchPlayersBox.Text
    searchDebounce = task.delay(CONFIG.DEBOUNCE_TIME, function()
        updatePlayersList(searchText)
        searchDebounce = nil
    end)
end)

-- Mostrar resultado de búsqueda
local function showSearchResult(targetPlayer)
    if not targetPlayer then
        searchResultContainer.Visible = false
        return
    end
    lastFoundTarget = targetPlayer

    local userId, playerName, displayName, isOnline

    if typeof(targetPlayer) == "Instance" and targetPlayer:IsA("Player") then
        userId = targetPlayer.UserId
        playerName = targetPlayer.Name
        displayName = targetPlayer.DisplayName or playerName
        isOnline = true
    elseif typeof(targetPlayer) == "table" then
        userId = targetPlayer.UserId
        playerName = targetPlayer.Name or "Unknown"
        displayName = targetPlayer.DisplayName or playerName
        isOnline = false
    else
        return
    end

    searchResultName.Text = playerName
    searchResultDisplayName.Text = "@" .. displayName
    searchResultId.Text = "ID: " .. tostring(userId)
    searchResultStatus.Text = isOnline and "🟢 Online" or "🔴 Offline"
    searchResultStatus.TextColor3 = isOnline and COLORS.SUCCESS or COLORS.TEXT_SECONDARY

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
end

-- Search button
connect(searchBtn.MouseButton1Click, function()
    flashButton(searchBtn)
    local inputText = sanitizeInput(usernameInput.Text)
    if inputText == "" then
        sendNotification("🔍 Search", "Por favor ingresa un nombre.", "WARNING")
        searchResultContainer.Visible = false
        return
    end
    sendNotification("🔍 Buscando...", "Buscando jugador: " .. inputText, "PROGRESS")
    local target = findPlayerByName(inputText)
    if not target then
        local id = tonumber(inputText)
        if id then target = findPlayerById(id) end
    end
    if target then
        showSearchResult(target)
        sendNotification("✅ Jugador Encontrado", (target.Name or inputText), "SUCCESS")
    else
        sendNotification("🔍 Search", "Jugador no encontrado.", "ERROR")
        searchResultContainer.Visible = false
    end
end)

connect(confirmMorphBtn.MouseButton1Click, function()
    if lastFoundTarget then
        flashButton(confirmMorphBtn)
        morphToPlayer(lastFoundTarget)
    else
        sendNotification("❌ Error", "No hay objetivo seleccionado.", "ERROR")
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
            sendNotification("✅ Jugador Encontrado", (target.Name or inputText), "SUCCESS")
        else
            sendNotification("🔍 Search", "Jugador no encontrado.", "ERROR")
            searchResultContainer.Visible = false
        end
    end
end)

-- Hex input
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
    if enterPressed or text ~= "" then
        applyHexColor(text, true)
    else
        hexInput.Text = colorToHex(hexPreviewCircle.BackgroundColor3)
    end
end)

connect(applyHexBtn.MouseButton1Click, function()
    flashButton(applyHexBtn)
    applyHexColor(hexInput.Text, true)
end)

-- Input global (hotkey + atajos)
connect(SERVICES.UserInput.InputBegan, function(input, gameProcessed)
    -- Configurar tecla
    if isListeningForKey then
        if input.KeyCode == Enum.KeyCode.Escape then
            isListeningForKey = false
            configBtn.Text = "⌨️ " .. toggleKey.Name
            sendNotification("❌ Cancelado", "Configuración de tecla cancelada.", "WARNING")
            return
        end
        if input.UserInputType == Enum.UserInputType.Keyboard then
            toggleKey = input.KeyCode
            isListeningForKey = false
            configBtn.Text = "⌨️ " .. toggleKey.Name
            sendNotification("✅ Tecla Configurada", "Nueva tecla: " .. toggleKey.Name, "SUCCESS")
        end
        return
    end

    -- Toggle GUI
    if input.KeyCode == toggleKey and not gameProcessed then
        screenGui.Enabled = not screenGui.Enabled
        if not screenGui.Enabled then
            sendNotification("👁️ GUI Oculta", "Presiona [" .. toggleKey.Name .. "] para volver a mostrar.", "INFO")
        else
            sendNotification("👁️ GUI Visible", "Bienvenido de vuelta.", "SUCCESS")
        end
        return
    end

    if gameProcessed then return end

    local isCtrlHeld = SERVICES.UserInput:IsKeyDown(Enum.KeyCode.LeftControl) or
                       SERVICES.UserInput:IsKeyDown(Enum.KeyCode.RightControl)
    if isCtrlHeld then
        if input.KeyCode == Enum.KeyCode.M then
            local inputText = sanitizeInput(usernameInput.Text)
            if inputText ~= "" then
                local target = findPlayerByName(inputText) or findPlayerById(tonumber(inputText))
                if target then morphToPlayer(target)
                else sendNotification("⌨️ Atajo", "Jugador no encontrado.", "ERROR") end
            else
                sendNotification("⌨️ Atajo", "Ingresa un nombre primero.", "WARNING")
            end
        elseif input.KeyCode == Enum.KeyCode.F then
            if currentTab ~= "search" then switchTab("search") end
            usernameInput:CaptureFocus()
        end
    end
end)

-- Actualizar lista cuando entran/salen jugadores
connect(SERVICES.Players.PlayerAdded, function()
    if currentTab == "players" then
        task.spawn(function() updatePlayersList(searchPlayersBox.Text) end)
    end
end)
connect(SERVICES.Players.PlayerRemoving, function()
    if currentTab == "players" then
        task.spawn(function() updatePlayersList(searchPlayersBox.Text) end)
    end
end)

-- ==========================================
-- PALETA DE COLORES DE PIEL
-- ==========================================

local function applySkinColor(color)
    local character = player.Character
    if not character then return end
    local humanoid = character:FindFirstChild("Humanoid")
    if not humanoid then return end
    hexPreviewCircle.BackgroundColor3 = color
    hexInput.Text = colorToHex(color)
    local bodyColors = character:FindFirstChildOfClass("BodyColors")
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
    pcall(function()
        local desc = humanoid:GetAppliedDescription()
        desc.HeadColor = color desc.LeftArmColor = color desc.RightArmColor = color
        desc.LeftLegColor = color desc.RightLegColor = color desc.TorsoColor = color
        if humanoid.ApplyDescriptionClientServer then
            humanoid:ApplyDescriptionClientServer(desc)
        else
            humanoid:ApplyDescription(desc)
        end
    end)
end

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
    stroke.Color = COLORS.BORDER
    stroke.Thickness = 2
    stroke.Transparency = 1
    stroke.Parent = colorBtn
    registerThemeObj(stroke, "BORDER", "Color")
    connect(colorBtn.MouseEnter, function() animateObject(stroke, {Transparency = 0}, 0.1) end)
    connect(colorBtn.MouseLeave, function() animateObject(stroke, {Transparency = 1}, 0.2) end)
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
-- INICIALIZACIÓN FINAL
-- ==========================================

lastMorphTime = loadCooldown()

-- Ahora sí, toastContainer existe → los toasts funcionan
sendNotification("🎭 Morph Avatar Pro", "By @sickly255 (SAGE) ✨ v2.3.0", "INFO")
task.wait(0.3)
sendNotification("💡 Consejo", "Presiona [" .. toggleKey.Name .. "] para ocultar/mostrar la GUI.", "INFO")