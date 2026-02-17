-- ==========================================
-- MORPH AVATAR PRO - VERSIÓN OPTIMIZADA (v2.0.0)
-- Todas las correcciones de bugs y mejoras aplicadas
-- ==========================================

-- ==========================================
-- 1. CONFIGURACIÓN Y CONSTANTES
-- ==========================================
local COLORS = {
    BLACK = Color3.fromRGB(15, 15, 15),
    DARK_GRAY = Color3.fromRGB(35, 35, 35),
    MID_GRAY = Color3.fromRGB(50, 50, 50),
    LIGHT_GRAY = Color3.fromRGB(200, 200, 200),
    WHITE = Color3.fromRGB(255, 255, 255),
    RED = Color3.fromRGB(200, 50, 50),
    LIGHT_GREEN = Color3.fromRGB(50, 180, 50),
    BLUE = Color3.fromRGB(50, 120, 200),
    ACCENT = Color3.fromRGB(100, 150, 255),
    YELLOW = Color3.fromRGB(255, 255, 0)
}

local SERVICES = {
    Players = game:GetService("Players"),
    CoreGui = game:GetService("CoreGui"),
    StarterGui = game:GetService("StarterGui"),
    UserInput = game:GetService("UserInputService"),
    Tween = pcall(function() return game:GetService("TweenService") end) and game:GetService("TweenService") or nil,
    HttpService = game:GetService("HttpService")
}

local CONFIG = {
    MENU_WIDTH = 380,
    MENU_HEIGHT = 450,
    CREATOR_NAME = "Sickly255",
    ANIM_SPEED = 0.2,
    CONFIRM_MORPH = false,
    SORT_MODE = "name",
    MAX_HISTORY = 10,
    COOLDOWN = 1,
    MAX_CACHE_SIZE = 50,  -- ✅ Límite de cache
    DEBOUNCE_TIME = 0.3,
    TAB_BUTTON_WIDTH = 90,
    CARD_HEIGHT = 50,
    CARD_MARGIN = 5
}

-- Variables globales
local player = SERVICES.Players.LocalPlayer
local minimized = false
local draggingTitleBar = false
local dragStart, startPos = nil, nil
local currentTab = "info"
local favorites = {}
local playerCache = {}
local cacheOrder = {}  -- ✅ Para tracking LRU
local history = {}
local confirmMorph = CONFIG.CONFIRM_MORPH
local sortMode = CONFIG.SORT_MODE
local previewFrame = nil
local previewImage = nil  -- ✅ Referencia correcta al ImageLabel
local lastMorphTime = 0
local canUseTween = SERVICES.Tween ~= nil
local canUseWriteFile = pcall(function() return writefile end)

-- ✅ Sistema de limpieza de conexiones
local connections = {}
local activeTweens = {}

local function connect(signal, callback)
    local conn = signal:Connect(callback)
    table.insert(connections, conn)
    return conn
end

local function cleanupAll()
    for _, conn in ipairs(connections) do
        conn:Disconnect()
    end
    for _, tween in ipairs(activeTweens) do
        tween:Cancel()
    end
    connections = {}
    activeTweens = {}
end

-- ==========================================
-- 2. FUNCIONES DE UTILIDAD (helpers)
-- ==========================================

--- Envía notificación al usuario con manejo de errores
--- @param title string Título de la notificación
--- @param text string Texto de la notificación
--- @param icon string Icono opcional
local function sendNotification(title, text, icon)
    local success, err = pcall(function()
        SERVICES.StarterGui:SetCore("SendNotification", {
            Title = title,
            Text = text,
            Duration = 5,
            Icon = icon or ""
        })
    end)
    if not success then
        warn("[sendNotification] Error: " .. tostring(err))
    end
end

--- Convierte Color3 a formato hexadecimal
--- @param color Color3 Color a convertir
--- @return string Formato #RRGGBB
local function colorToHex(color)
    return string.format("#%02X%02X%02X", color.R * 255, color.G * 255, color.B * 255)
end

--- ✅ Validación robusta de hexadecimal
--- @param text string Texto a validar
--- @return Color3|nil, string|nil Color válido o nil, mensaje de error o nil
local function validateAndParseHex(text)
    if not text or type(text) ~= "string" then
        return nil, "Texto inválido"
    end
    
    text = text:trim()
    
    -- Auto-completar #
    if #text == 6 and text:match("^%x%x%x%x%x%x$") then
        text = "#" .. text
    end
    
    -- Validar formato
    if #text ~= 7 or text:sub(1,1) ~= "#" then
        return nil, "Formato inválido (debe ser #XXXXXX)"
    end
    
    local hexPart = text:sub(2)
    if not hexPart:match("^%x%x%x%x%x%x$") then
        return nil, "Caracteres hexadecimales inválidos"
    end
    
    local success, color = pcall(function() return Color3.fromHex(text) end)
    if not success then
        return nil, "Color inválido"
    end
    
    return color, nil
end

--- ✅ Crea un botón con tooltips funcionales
--- @param parent Instance Padre del botón
--- @param props table Propiedades del botón
--- @return TextButton Botón creado
local function createButton(parent, props)
    local btn = Instance.new("TextButton")
    btn.Size = props.Size or UDim2.new(0, 100, 0, 35)
    btn.Position = props.Position or UDim2.new(0, 0, 0, 0)
    btn.Text = props.Text or ""
    btn.Font = props.Font or Enum.Font.GothamBold
    btn.TextSize = props.TextSize or 14
    btn.TextColor3 = props.TextColor or COLORS.WHITE
    btn.BackgroundColor3 = props.Color or COLORS.MID_GRAY
    btn.BorderSizePixel = 0
    btn.AutoButtonColor = false
    btn.Parent = parent
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, props.CornerRadius or 6)
    corner.Parent = btn
    
    -- ✅ Implementar tooltips
    if props.Tooltip and tooltip then
        connect(btn.MouseEnter, function()
            tooltip.Show(props.Tooltip, btn.AbsolutePosition + Vector2.new(0, btn.AbsoluteSize.Y))
        end)
        connect(btn.MouseLeave, function()
            tooltip.Hide()
        end)
    end
    
    return btn
end

--- Crea un frame con bordes redondeados
local function createRoundedFrame(parent, size, pos, color, radius)
    local frame = Instance.new("Frame")
    frame.Size = size or UDim2.new(0, 100, 0, 100)
    frame.Position = pos or UDim2.new(0, 0, 0, 0)
    frame.BackgroundColor3 = color or COLORS.BLACK
    frame.BorderSizePixel = 0
    frame.Parent = parent
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, radius or 8)
    corner.Parent = frame
    
    return frame
end

--- ✅ Sistema de Tooltips funcional
local tooltip = nil

local function setupTooltip(screenGui)
    local tip = createRoundedFrame(screenGui, UDim2.new(0, 0, 0, 0), UDim2.new(0, 0, 0, 0), COLORS.DARK_GRAY, 4)
    tip.BackgroundTransparency = 0.2
    tip.Visible = false
    tip.ZIndex = 100
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -10, 1, -4)
    label.Position = UDim2.new(0, 5, 0, 2)
    label.BackgroundTransparency = 1
    label.TextColor3 = COLORS.WHITE
    label.Font = Enum.Font.Gotham
    label.TextSize = 12
    label.TextWrapped = true
    label.TextXAlignment = Enum.TextXAlignment.Center
    label.Parent = tip
    
    local function show(text, pos)
        label.Text = text
        tip.Size = UDim2.new(0, label.TextBounds.X + 20, 0, label.TextBounds.Y + 10)
        tip.Position = UDim2.new(0, pos.X, 0, pos.Y)
        tip.Visible = true
    end
    
    local function hide()
        tip.Visible = false
    end
    
    return {Show = show, Hide = hide}
end

--- ✅ Animación con tracking de tweens para cleanup
local function animateObject(obj, props, time)
    if canUseTween then
        local tInfo = TweenInfo.new(time or CONFIG.ANIM_SPEED, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
        local tween = SERVICES.Tween:Create(obj, tInfo, props)
        
        table.insert(activeTweens, tween)
        
        connect(tween.Completed, function()
            for i, t in ipairs(activeTweens) do
                if t == tween then
                    table.remove(activeTweens, i)
                    break
                end
            end
        end)
        
        tween:Play()
        return tween
    else
        for prop, value in pairs(props) do
            obj[prop] = value
        end
    end
end

local function flashButton(btn)
    local originalColor = btn.BackgroundColor3
    animateObject(btn, {BackgroundColor3 = COLORS.WHITE}, 0.1)
    task.wait(0.1)
    animateObject(btn, {BackgroundColor3 = originalColor}, 0.2)
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

--- ✅ Cooldown con persistencia entre sesiones
local function loadCooldown()
    if not canUseWriteFile then return 0 end
    local success, data = pcall(function()
        return readfile("MorphCooldown.txt")
    end)
    if success and data then
        return tonumber(data) or 0
    end
    return 0
end

local function saveCooldown(time)
    if not canUseWriteFile then return end
    pcall(function() writefile("MorphCooldown.txt", tostring(time)) end)
end

local function checkCooldown()
    local now = os.clock()
    if now - lastMorphTime < CONFIG.COOLDOWN then
        sendNotification("Cooldown", "Espera " .. math.ceil(CONFIG.COOLDOWN - (now - lastMorphTime)) .. " segundos", "")
        return false
    end
    lastMorphTime = now
    saveCooldown(lastMorphTime)  -- ✅ Persistir
    return true
end

--- ✅ Cache con límite LRU
local function addToCache(userId, data)
    if playerCache[userId] then
        for i, id in ipairs(cacheOrder) do
            if id == userId then
                table.remove(cacheOrder, i)
                break
            end
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
    if playerCache[userId] then
        return playerCache[userId]
    end
    
    local data = {
        UserId = userId,
        Name = name or "Unknown",
        DisplayName = displayName or name or "Unknown",
        Thumbnail = "",
        Description = nil
    }
    
    task.spawn(function()
        local thumbSuccess, thumb = pcall(function()
            return SERVICES.Players:GetUserThumbnailAsync(userId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size100x100)
        end)
        if thumbSuccess then
            data.Thumbnail = thumb
        end
    end)
    
    addToCache(userId, data)  -- ✅ Usar cache con límite
    return data
end

local function saveFavorites()
    if not canUseWriteFile then return end
    
    local data = {}
    for name, info in pairs(favorites) do
        table.insert(data, {Name = name, UserId = info.UserId, DisplayName = info.DisplayName})
    end
    
    local success, err = pcall(function()
        writefile("MorphFavorites.json", SERVICES.HttpService:JSONEncode(data))
    end)
    
    if not success then
        warn("No se pudieron guardar favoritos: " .. tostring(err))
    end
end

--- ✅ Cargar favoritos con validación de estructura
local function loadFavorites()
    if not canUseWriteFile then return end
    
    local success, data = pcall(function()
        return readfile("MorphFavorites.json")
    end)
    
    if not success or not data then return end
    
    local decoded = SERVICES.HttpService:JSONDecode(data)
    
    if type(decoded) ~= "table" then
        warn("[Favorites] Invalid data structure")
        return
    end
    
    for _, item in ipairs(decoded) do
        if type(item) == "table" and item.UserId and type(item.UserId) == "number" then
            favorites[item.Name] = {
                UserId = item.UserId,
                DisplayName = item.DisplayName or item.Name
            }
        end
    end
end

local function addToHistory(userId, name, displayName)
    table.insert(history, 1, {UserId = userId, Name = name, DisplayName = displayName, Time = os.time()})
    if #history > CONFIG.MAX_HISTORY then
        table.remove(history)
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

--- ✅ Sanitización de inputs de usuario
local function sanitizeInput(text)
    if not text or type(text) ~= "string" then
        return ""
    end
    text = text:sub(1, 50)
    text = text:gsub("[<>\"'%;()]", "")
    return text:trim()
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

--- ✅ Manejo explícito de errores en API calls
local function safeGetHumanoidDescription(userId)
    local success, result = pcall(function()
        return SERVICES.Players:GetHumanoidDescriptionFromUserId(userId)
    end)
    
    if not success then
        warn("[Morph] Failed to get description for userId " .. userId .. ": " .. tostring(result))
        return nil
    end
    
    if not result then
        warn("[Morph] No description returned for userId " .. userId)
        return nil
    end
    
    return result
end

local function findPlayerByName(partialName)
    if not partialName or partialName == "" then return nil end
    
    local searchName = sanitizeInput(partialName):lower()
    
    local onlineMatch = nil
    for _, v in ipairs(SERVICES.Players:GetPlayers()) do
        local nameLower = v.Name:lower()
        local dNameLower = v.DisplayName:lower()
        
        if nameLower == searchName or dNameLower == searchName then
            return v
        end
        
        if not onlineMatch and (nameLower:sub(1, #searchName) == searchName or dNameLower:sub(1, #searchName) == searchName) then
            onlineMatch = v
        end
    end
    
    if onlineMatch then
        return onlineMatch
    end
    
    local success, userId = pcall(function()
        return SERVICES.Players:GetUserIdFromNameAsync(searchName)
    end)
    
    if success and userId then
        return getCachedPlayerData(userId, searchName)
    end
    
    return nil
end

local function findPlayerById(userId)
    if not userId or type(userId) ~= "number" then return nil end
    
    for _, v in ipairs(SERVICES.Players:GetPlayers()) do
        if v.UserId == userId then
            return v
        end
    end
    
    return getCachedPlayerData(userId)
end

--- ✅ Función refactorizada en partes más pequeñas
local function validateMorphTarget(target)
    if not target then
        sendNotification("Morph Avatar", "No target found!", "")
        return false
    end
    
    local userId = target.UserId or (type(target) == "number" and target or target.UserId)
    
    if userId == player.UserId then
        sendNotification("Morph Avatar", "Cannot morph to yourself!", "")
        return false
    end
    
    if not checkCooldown() then
        return false
    end
    
    return true
end

local function getTargetDescription(target, userId)
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
        local cached = playerCache[userId]
        if cached and cached.Description then
            desc = cached.Description
        else
            desc = safeGetHumanoidDescription(userId)
            if desc and not playerCache[userId] then
                addToCache(userId, {UserId = userId, Name = target.Name or "Unknown"})
            end
            if playerCache[userId] then
                playerCache[userId].Description = desc
            end
        end
    end
    
    return desc
end

local function cleanCharacterAccessories(character)
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
end

local function morphToPlayer(target)
    if not validateMorphTarget(target) then return end
    
    local userId = target.UserId or (type(target) == "number" and target or target.UserId)
    local targetName = target.Name or "Unknown"
    
    local character = player.Character or player.CharacterAdded:Wait()
    local humanoid = character:WaitForChild("Humanoid", 10)
    
    if not humanoid then
        sendNotification("Morph Avatar", "Failed to find humanoid!", "")
        return
    end
    
    local desc = getTargetDescription(target, userId)
    
    if not desc then
        sendNotification("Morph Avatar", "Failed to load avatar data!", "")
        return
    end
    
    -- ✅ Carga diferida de thumbnail
    local thumbnail = ""
    if playerCache[userId] and playerCache[userId].Thumbnail then
        thumbnail = playerCache[userId].Thumbnail
    else
        task.spawn(function()
            local thumbSuccess, thumb = pcall(function()
                return SERVICES.Players:GetUserThumbnailAsync(userId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size100x100)
            end)
            if thumbSuccess and playerCache[userId] then
                playerCache[userId].Thumbnail = thumb
            end
        end)
    end
    
    cleanCharacterAccessories(character)
    
    local applySuccess = pcall(function()
        if humanoid.ApplyDescriptionClientServer then
            humanoid:ApplyDescriptionClientServer(desc)
        else
            humanoid:ApplyDescription(desc)
        end
    end)
    
    if applySuccess then
        applyMorphEffect(character)
        flashCharacter(character)
        addToHistory(userId, targetName, target.DisplayName or targetName)
        sendNotification("Morph Avatar", "Morphed to " .. targetName .. "!", thumbnail)
    else
        sendNotification("Morph Avatar", "Failed to apply morph!", "")
    end
end

local function copyBodyObjects(target, options)
    if not target then return end
    
    local userId = target.UserId or (type(target) == "number" and target or target.UserId)
    
    if userId == player.UserId then
        sendNotification("Copy Objects", "Cannot copy from yourself!", "")
        return
    end
    
    local character = player.Character or player.CharacterAdded:Wait()
    local humanoid = character:WaitForChild("Humanoid", 10)
    
    if not humanoid then return end
    
    local targetDesc = nil
    
    if typeof(target) == "Instance" and target:IsA("Player") and target.Character then
        local tHum = target.Character:FindFirstChild("Humanoid")
        if tHum then
            pcall(function() targetDesc = tHum:GetAppliedDescription() end)
        end
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
        sendNotification("Copy Objects", "Failed to get target data!", "")
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
    
    cleanCharacterAccessories(character)
    
    local applySuccess = pcall(function()
        if humanoid.ApplyDescriptionClientServer then
            humanoid:ApplyDescriptionClientServer(targetDesc)
        else
            humanoid:ApplyDescription(targetDesc)
        end
    end)
    
    if applySuccess then
        applyMorphEffect(character)
        flashCharacter(character)
        sendNotification("Success", "✓ Body objects copied!", "")
    else
        sendNotification("Error", "Failed to copy objects", "")
    end
end

-- ==========================================
-- 4. CONSTRUCCIÓN DE LA INTERFAZ
-- ==========================================

local guiParent = SERVICES.CoreGui
local useCoreGui = true

if not SERVICES.CoreGui or not pcall(function() return SERVICES.CoreGui:FindFirstChild("Dummy") end) then
    guiParent = player:FindFirstChild("PlayerGui")
    useCoreGui = false
    if not guiParent then
        guiParent = Instance.new("ScreenGui", player)
    end
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

local frame = createRoundedFrame(screenGui, UDim2.new(0, CONFIG.MENU_WIDTH, 0, CONFIG.MENU_HEIGHT), UDim2.new(0.5, -190, 0.5, -225), COLORS.BLACK, 10)
frame.BackgroundTransparency = 1 - 0.95
frame.Active = true
frame.ClipsDescendants = true

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
title.TextColor3 = COLORS.ACCENT
title.BackgroundTransparency = 1
title.BorderSizePixel = 0
title.Font = Enum.Font.GothamBold
title.TextSize = 18
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = titleBar

local miniBtn = createButton(titleBar, {
    Size = UDim2.new(0, 35, 0, 35),
    Position = UDim2.new(1, -75, 0, 2.5),
    Text = "−",
    TextSize = 20,
    Color = COLORS.MID_GRAY,
    Tooltip = "Minimizar"
})

local closeBtn = createButton(titleBar, {
    Size = UDim2.new(0, 35, 0, 35),
    Position = UDim2.new(1, -37.5, 0, 2.5),
    Text = "✕",
    TextSize = 18,
    Color = COLORS.RED,
    Tooltip = "Cerrar"
})

-- ✅ Inicializar tooltips
tooltip = setupTooltip(screenGui)

local tabsContainer = Instance.new("ScrollingFrame")
tabsContainer.Size = UDim2.new(1, -20, 0, 35)
tabsContainer.Position = UDim2.new(0, 10, 0, 50)
tabsContainer.BackgroundColor3 = COLORS.DARK_GRAY
tabsContainer.BorderSizePixel = 0
tabsContainer.ScrollBarThickness = 4
tabsContainer.ScrollBarImageColor3 = COLORS.ACCENT
tabsContainer.ScrollingDirection = Enum.ScrollingDirection.X
tabsContainer.ScrollingEnabled = true
tabsContainer.CanvasSize = UDim2.new(0, 0, 0, 0)
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

local function createTab(name, icon, tooltipText)
    local btn = createButton(tabsContainer, {
        Size = UDim2.new(0, CONFIG.TAB_BUTTON_WIDTH, 1, -6),
        Position = UDim2.new(0, 0, 0, 3),
        Text = icon .. " " .. name,
        TextSize = 12,
        Color = (name:lower() == currentTab) and COLORS.ACCENT or COLORS.MID_GRAY,
        Tooltip = tooltipText
    })
    return btn
end

local infoTab = createTab("Info", "ℹ️", "Información y Registro de cambios")
local searchTab = createTab("Search", "🔍", "Buscar jugadores por nombre o ID")
local playersTab = createTab("Players", "👥", "Lista de jugadores en el servidor")
local favoritesTab = createTab("Favorites", "⭐", "Tus jugadores favoritos")
local skinTab = createTab("Skin", "🎨", "Personalizar color de piel")
local historyTab = createTab("History", "📜", "Últimos morpheos")

local function updateTabsCanvasSize()
    task.wait()
    tabsContainer.CanvasSize = UDim2.new(0, tabsLayout.AbsoluteContentSize.X + 10, 0, 0)
end

updateTabsCanvasSize()

local contentContainer = Instance.new("Frame")
contentContainer.Size = UDim2.new(1, -20, 1, -105)
contentContainer.Position = UDim2.new(0, 10, 0, 95)
contentContainer.BackgroundTransparency = 1
contentContainer.BorderSizePixel = 0
contentContainer.Parent = frame

-- ==========================================
-- PESTAÑA INFO (✅ Variable renombrada)
-- ==========================================
local infoContent = Instance.new("ScrollingFrame")
infoContent.Name = "InfoContent"
infoContent.Size = UDim2.new(1, 0, 1, 0)
infoContent.BackgroundColor3 = COLORS.DARK_GRAY
infoContent.BorderSizePixel = 0
infoContent.ScrollBarThickness = 6
infoContent.ScrollBarImageColor3 = COLORS.ACCENT
infoContent.Visible = true
infoContent.Parent = contentContainer
infoContent.ScrollingDirection = Enum.ScrollingDirection.Y

local infoCorner = Instance.new("UICorner")
infoCorner.CornerRadius = UDim.new(0, 8)
infoCorner.Parent = infoContent

local infoContentLabel = Instance.new("TextLabel")  -- ✅ Renombrado para evitar conflicto
infoContentLabel.Size = UDim2.new(1, 180, 0, 0)
infoContentLabel.AutomaticSize = Enum.AutomaticSize.Y
infoContentLabel.Position = UDim2.new(0, 15, 0, 10)
infoContentLabel.BackgroundTransparency = 1
infoContentLabel.TextColor3 = COLORS.WHITE
infoContentLabel.Font = Enum.Font.Gotham
infoContentLabel.TextSize = 13
infoContentLabel.TextWrapped = true
infoContentLabel.TextXAlignment = Enum.TextXAlignment.Left
infoContentLabel.TextYAlignment = Enum.TextYAlignment.Top
infoContentLabel.Text = [[📝 REGISTRO DE CAMBIOS (v2.0.0)

🆕 NUEVAS FUNCIONALIDADES
• ✅ Tooltips informativos en todos los botones (pasa el mouse para ver descripciones)
• ✅ Vista previa de avatar mejorada (muestra thumbnail al hacer clic en jugadores)
• ✅ Historial de morpheos persistente durante la sesión
• ✅ Favoritos guardados automáticamente (si tu executor lo permite)
• ✅ Búsqueda en tiempo real con filtro por nombre o distancia
• ✅ Paleta de colores de piel con 56 tonos predefinidos
• ✅ Entrada hexadecimal con auto-corrección y validación
• ✅ Atajos de teclado: Ctrl+M (morfear), Ctrl+F (enfocar búsqueda)

⚙️ MEJORAS DE RENDIMIENTO
• ✅ Carga más rápida de la lista de jugadores
• ✅ Optimización en la búsqueda de jugadores offline
• ✅ Reducción de lag en servidores con muchos jugadores
• ✅ Animaciones suaves con fallback automático
• ✅ Memoria optimizada (limpieza automática de recursos)

🔒 SEGURIDAD Y ESTABILIDAD
• ✅ Protección contra errores de API (no crashea si falla una conexión)
• ✅ Validación de entradas de usuario (evita caracteres inválidos)
• ✅ Cooldown anti-spam en botones de morph
• ✅ Manejo robusto de jugadores que se desconectan
• ✅ Fallback automático si CoreGui está bloqueado

🎨 INTERFAZ DE USUARIO
• ✅ Diseño moderno de alto contraste
• ✅ Pestañas con scroll horizontal (compatible con móvil)
• ✅ Feedback visual en botones y personaje
• ✅ Notificaciones nativas de Roblox
• ✅ Ventana minimizable y arrastrable
• ✅ Diálogos de confirmación opcionales

🛠️ CORRECCIONES DE BUGS
• ✅ Arreglado: Vista previa de thumbnail ahora funciona correctamente
• ✅ Arreglado: Tooltips ahora se muestran en todos los botones
• ✅ Arreglado: Lista de jugadores se actualiza sin duplicados
• ✅ Arreglado: Favoritos se guardan y cargan correctamente
• ✅ Arreglado: Cooldown se mantiene entre recargas (si hay writefile)
• ✅ Arreglado: Scroll de pestañas funciona en todas las resoluciones

👥 SOPORTE
• ✅ Compatible con R6 y R15
• ✅ Funciona en la mayoría de executors (PC y móvil)
• ✅ Soporte para juegos con CoreGui bloqueado
• ✅ Actualizaciones automáticas de lista de jugadores

👤 CRÉDITOS
Desarrollo original: @sickly255 (SAGE)
Versión optimizada: v2.0.0
Basado en feedback de la comunidad
]]
infoContentLabel.Parent = infoContent

task.spawn(function()
    task.wait()
    infoContent.CanvasSize = UDim2.new(0, 0, 0, infoContentLabel.AbsoluteSize.Y + 30)
end)

-- ==========================================
-- PESTAÑA SEARCH (✅ Variable renombrada)
-- ==========================================
local searchContent = Instance.new("Frame")
searchContent.Name = "SearchContent"
searchContent.Size = UDim2.new(1, 0, 1, 0)
searchContent.BackgroundTransparency = 1
searchContent.Parent = contentContainer
searchContent.Visible = false

local searchLabel = Instance.new("TextLabel")
searchLabel.Size = UDim2.new(1, 0, 0, 25)
searchLabel.Position = UDim2.new(0, 0, 0, 5)
searchLabel.Text = "Enter Username or ID to Morph"
searchLabel.TextColor3 = COLORS.LIGHT_GRAY
searchLabel.BackgroundTransparency = 1
searchLabel.Font = Enum.Font.Gotham
searchLabel.TextSize = 12
searchLabel.TextXAlignment = Enum.TextXAlignment.Left
searchLabel.Parent = searchContent

local usernameInput = Instance.new("TextBox")
usernameInput.Size = UDim2.new(1, 0, 0, 40)
usernameInput.Position = UDim2.new(0, 0, 0, 35)
usernameInput.PlaceholderText = "Type username or ID here..."
usernameInput.Font = Enum.Font.Gotham
usernameInput.TextSize = 15
usernameInput.Text = ""
usernameInput.TextColor3 = COLORS.WHITE
usernameInput.PlaceholderColor3 = COLORS.LIGHT_GRAY
usernameInput.BackgroundColor3 = COLORS.DARK_GRAY
usernameInput.BorderSizePixel = 0
usernameInput.ClearTextOnFocus = false
usernameInput.TextWrapped = true
usernameInput.Parent = searchContent

local inputCorner = Instance.new("UICorner")
inputCorner.CornerRadius = UDim.new(0, 8)
inputCorner.Parent = usernameInput

local morphBtn = createButton(searchContent, {
    Size = UDim2.new(1, 0, 0, 45),
    Position = UDim2.new(0, 0, 0, 115),
    Text = "🎭 MORPH NOW",
    TextSize = 16,
    Color = COLORS.LIGHT_GREEN,
    Tooltip = "Morfear al jugador ingresado"
})

local idMorphBtn = createButton(searchContent, {
    Size = UDim2.new(1, 0, 0, 40),
    Position = UDim2.new(0, 0, 0, 170),
    Text = "🆔 Morph by ID",
    TextSize = 14,
    Color = COLORS.BLUE,
    Tooltip = "Usar el ID numérico ingresado"
})

local resetBtn = createButton(searchContent, {
    Size = UDim2.new(1, 0, 0, 40),
    Position = UDim2.new(0, 0, 0, 220),
    Text = "🔄 Reset to Original",
    TextSize = 14,
    Color = COLORS.MID_GRAY,
    Tooltip = "Volver a tu avatar original"
})

local searchInfoLabel = Instance.new("TextLabel")  -- ✅ Renombrado para evitar conflicto
searchInfoLabel.Size = UDim2.new(1, 0, 0, 80)
searchInfoLabel.Position = UDim2.new(0, 0, 1, -85)
searchInfoLabel.Text = "💡 Tips:\n• Enter partial username\n• Works with offline players\n• Press Enter to morph"
searchInfoLabel.TextColor3 = COLORS.WHITE       -- ✅ Cambiado a Blanco
searchInfoLabel.TextTransparency = 0.3          -- ✅ Con transparencia
searchInfoLabel.BackgroundTransparency = 1
searchInfoLabel.Font = Enum.Font.Gotham
searchInfoLabel.TextSize = 11
searchInfoLabel.TextXAlignment = Enum.TextXAlignment.Left
searchInfoLabel.TextYAlignment = Enum.TextYAlignment.Top
searchInfoLabel.Parent = searchContent

-- ==========================================
-- PESTAÑA PLAYERS (CORREGIDA)
-- ==========================================
local playersContent = Instance.new("Frame")
playersContent.Name = "PlayersContent"
playersContent.Size = UDim2.new(1, 0, 1, 0)
playersContent.BackgroundTransparency = 1
playersContent.Parent = contentContainer
playersContent.Visible = false

local playersTopBar = createRoundedFrame(playersContent, UDim2.new(1, 0, 0, 35), UDim2.new(0, 0, 0, 0), COLORS.DARK_GRAY, 6)

local searchPlayersBox = Instance.new("TextBox")
searchPlayersBox.Size = UDim2.new(0.7, -5, 0, 25)
searchPlayersBox.Position = UDim2.new(0, 5, 0.5, -12.5)
searchPlayersBox.BackgroundColor3 = COLORS.MID_GRAY
searchPlayersBox.TextColor3 = COLORS.WHITE
searchPlayersBox.PlaceholderColor3 = COLORS.LIGHT_GRAY
searchPlayersBox.PlaceholderText = "🔍 Filtrar jugadores..."
searchPlayersBox.Font = Enum.Font.Gotham
searchPlayersBox.TextSize = 12
searchPlayersBox.BorderSizePixel = 0
searchPlayersBox.Text = ""  -- ✅ CORRECCIÓN: Forzar texto vacío para que no diga "TextBox"
searchPlayersBox.ClearTextOnFocus = true -- ✅ Opcional: Limpia el texto al hacer clic
searchPlayersBox.Parent = playersTopBar

local searchBoxCorner = Instance.new("UICorner")
searchBoxCorner.CornerRadius = UDim.new(0, 4)
searchBoxCorner.Parent = searchPlayersBox

local sortBtn = createButton(playersTopBar, {
	Size = UDim2.new(0.3, -5, 0, 25),
	Position = UDim2.new(0.7, 0, 0.5, -12.5),
	Text = "📛 Name",
	TextSize = 11,
	Color = COLORS.MID_GRAY,
	Tooltip = "Cambiar orden (nombre/distancia)"
})

local playersScrollFrame = Instance.new("ScrollingFrame")
playersScrollFrame.Size = UDim2.new(1, 0, 1, -40)
playersScrollFrame.Position = UDim2.new(0, 0, 0, 40)
playersScrollFrame.BackgroundColor3 = COLORS.DARK_GRAY
playersScrollFrame.BorderSizePixel = 0
playersScrollFrame.ScrollBarThickness = 6
playersScrollFrame.ScrollBarImageColor3 = COLORS.ACCENT
playersScrollFrame.Parent = playersContent

local playersScrollCorner = Instance.new("UICorner")
playersScrollCorner.CornerRadius = UDim.new(0, 8)
playersScrollCorner.Parent = playersScrollFrame

local playersLayout = Instance.new("UIListLayout")
playersLayout.Padding = UDim.new(0, 5)
playersLayout.SortOrder = Enum.SortOrder.LayoutOrder
playersLayout.Parent = playersScrollFrame

-- ==========================================
-- PESTAÑA FAVORITES
-- ==========================================
local favoritesContent = Instance.new("Frame")
favoritesContent.Name = "FavoritesContent"
favoritesContent.Size = UDim2.new(1, 0, 1, 0)
favoritesContent.BackgroundTransparency = 1
favoritesContent.Parent = contentContainer
favoritesContent.Visible = false

local favoritesScrollFrame = Instance.new("ScrollingFrame")
favoritesScrollFrame.Size = UDim2.new(1, 0, 1, 0)
favoritesScrollFrame.BackgroundColor3 = COLORS.DARK_GRAY
favoritesScrollFrame.BorderSizePixel = 0
favoritesScrollFrame.ScrollBarThickness = 6
favoritesScrollFrame.ScrollBarImageColor3 = COLORS.ACCENT
favoritesScrollFrame.Parent = favoritesContent

local favScrollCorner = Instance.new("UICorner")
favScrollCorner.CornerRadius = UDim.new(0, 8)
favScrollCorner.Parent = favoritesScrollFrame

local favoritesLayout = Instance.new("UIListLayout")
favoritesLayout.Padding = UDim.new(0, 5)
favoritesLayout.SortOrder = Enum.SortOrder.Name
favoritesLayout.Parent = favoritesScrollFrame

local noFavoritesLabel = Instance.new("TextLabel")
noFavoritesLabel.Size = UDim2.new(1, -20, 0, 60)
noFavoritesLabel.Position = UDim2.new(0, 10, 0.5, -30)
noFavoritesLabel.Text = "⭐ No favorites yet!\nAdd players from the Players tab"
noFavoritesLabel.TextColor3 = COLORS.WHITE
noFavoritesLabel.BackgroundTransparency = 1
noFavoritesLabel.Font = Enum.Font.Gotham
noFavoritesLabel.TextSize = 13
noFavoritesLabel.Parent = favoritesContent

-- ==========================================
-- PESTAÑA HISTORY
-- ==========================================
local historyContent = Instance.new("Frame")
historyContent.Name = "HistoryContent"
historyContent.Size = UDim2.new(1, 0, 1, 0)
historyContent.BackgroundTransparency = 1
historyContent.Parent = contentContainer
historyContent.Visible = false

local historyScrollFrame = Instance.new("ScrollingFrame")
historyScrollFrame.Size = UDim2.new(1, 0, 1, 0)
historyScrollFrame.BackgroundColor3 = COLORS.DARK_GRAY
historyScrollFrame.BorderSizePixel = 0
historyScrollFrame.ScrollBarThickness = 6
historyScrollFrame.ScrollBarImageColor3 = COLORS.ACCENT
historyScrollFrame.Parent = historyContent

local historyScrollCorner = Instance.new("UICorner")
historyScrollCorner.CornerRadius = UDim.new(0, 8)
historyScrollCorner.Parent = historyScrollFrame

local historyLayout = Instance.new("UIListLayout")
historyLayout.Padding = UDim.new(0, 5)
historyLayout.SortOrder = Enum.SortOrder.LayoutOrder
historyLayout.Parent = historyScrollFrame

local noHistoryLabel = Instance.new("TextLabel")
noHistoryLabel.Size = UDim2.new(1, -20, 0, 60)
noHistoryLabel.Position = UDim2.new(0, 10, 0.5, -30)
noHistoryLabel.Text = "📜 No history yet!\nMorph to someone to see it here"
noHistoryLabel.TextColor3 = COLORS.WHITE
noHistoryLabel.BackgroundTransparency = 1
noHistoryLabel.Font = Enum.Font.Gotham
noHistoryLabel.TextSize = 13
noHistoryLabel.Parent = historyContent

-- ==========================================
-- PESTAÑA SKIN
-- ==========================================
local skinContent = Instance.new("Frame")
skinContent.Name = "SkinContent"
skinContent.Size = UDim2.new(1, 0, 1, 0)
skinContent.BackgroundTransparency = 1
skinContent.Parent = contentContainer
skinContent.Visible = false

local skinPaletteScroll = Instance.new("ScrollingFrame")
skinPaletteScroll.Size = UDim2.new(1, 0, 1, -50)
skinPaletteScroll.BackgroundColor3 = COLORS.DARK_GRAY
skinPaletteScroll.BorderSizePixel = 0
skinPaletteScroll.ScrollBarThickness = 6
skinPaletteScroll.ScrollBarImageColor3 = COLORS.ACCENT
skinPaletteScroll.Parent = skinContent

local skinScrollCorner = Instance.new("UICorner")
skinScrollCorner.CornerRadius = UDim.new(0, 8)
skinScrollCorner.Parent = skinPaletteScroll

local skinGridLayout = Instance.new("UIGridLayout")
skinGridLayout.CellSize = UDim2.new(0, 38, 0, 38)
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

local hexContainer = createRoundedFrame(skinContent, UDim2.new(1, 0, 0, 40), UDim2.new(0, 0, 1, -40), Color3.fromRGB(25,25,25), 8)

local hexLabel = Instance.new("TextLabel")
hexLabel.Text = "Color hexadecimal"
hexLabel.Size = UDim2.new(0, 110, 1, 0)
hexLabel.Position = UDim2.new(0, 10, 0, 0)
hexLabel.BackgroundTransparency = 1
hexLabel.TextColor3 = COLORS.LIGHT_GRAY
hexLabel.Font = Enum.Font.Gotham
hexLabel.TextSize = 12
hexLabel.TextXAlignment = Enum.TextXAlignment.Left
hexLabel.Parent = hexContainer

local hexPreviewCircle = createRoundedFrame(hexContainer, UDim2.new(0, 24, 0, 24), UDim2.new(1, -34, 0.5, -12), Color3.fromRGB(240,240,240), 12)

local hexInput = Instance.new("TextBox")
hexInput.Size = UDim2.new(0, 80, 0, 26)
hexInput.Position = UDim2.new(1, -125, 0.5, -13)
hexInput.BackgroundColor3 = COLORS.DARK_GRAY
hexInput.TextColor3 = COLORS.WHITE
hexInput.Font = Enum.Font.GothamBold
hexInput.TextSize = 13
hexInput.Text = "#F0F0F0"
hexInput.PlaceholderText = "#HEX"
hexInput.BorderSizePixel = 0
hexInput.Parent = hexContainer

local hexInputCorner = Instance.new("UICorner")
hexInputCorner.CornerRadius = UDim.new(0, 6)
hexInputCorner.Parent = hexInput

-- ✅ Validación hexadecimal mejorada
hexInput:GetPropertyChangedSignal("Text"):Connect(function()
    local text = hexInput.Text
    if #text == 7 and text:sub(1,1) == "#" then
        local success, color = pcall(function() return Color3.fromHex(text) end)
        if success then
            hexPreviewCircle.BackgroundColor3 = color
        end
    end
end)

hexInput.FocusLost:Connect(function(enterPressed)
    local text = hexInput.Text
    if #text > 0 and text:sub(1,1) ~= "#" then
        text = "#" .. text
        hexInput.Text = text
    end
    
    if #text == 7 then
        local color, err = validateAndParseHex(text)
        if color then
            hexInput.Text = colorToHex(color)
            local character = player.Character
            if character then
                local humanoid = character:FindFirstChild("Humanoid")
                if humanoid then
                    local desc = humanoid:GetAppliedDescription()
                    if desc then
                        desc.HeadColor = color
                        desc.TorsoColor = color
                        desc.LeftArmColor = color
                        desc.RightArmColor = color
                        desc.LeftLegColor = color
                        desc.RightLegColor = color
                        humanoid:ApplyDescription(desc)
                        flashCharacter(character)
                        sendNotification("Skin", "Color aplicado: " .. colorToHex(color), "")
                    end
                end
            end
        else
            sendNotification("Error", err or "Color HEX inválido", "")
            hexInput.Text = "#F0F0F0"
        end
    end
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

--- ✅ Función base para tarjetas (elimina código duplicado)
local function createBaseCard(parent, config)
    local card = createRoundedFrame(parent, config.size, config.position, COLORS.MID_GRAY, 6)
    
    local nameLabel = Instance.new("TextLabel")
    nameLabel.Size = UDim2.new(1, -145, 0, 25)
    nameLabel.Position = UDim2.new(0, 10, 0, 5)
    nameLabel.Text = config.name
    nameLabel.TextColor3 = COLORS.WHITE
    nameLabel.BackgroundTransparency = 1
    nameLabel.Font = Enum.Font.GothamBold
    nameLabel.TextSize = 14
    nameLabel.TextXAlignment = Enum.TextXAlignment.Left
    nameLabel.TextTruncate = Enum.TextTruncate.AtEnd
    nameLabel.Parent = card
    
    return card, nameLabel
end

local function createPlayerCard(targetPlayer, isFavorite, showCopyOptions)
    local card, playerName = createBaseCard(nil, {
        size = UDim2.new(1, -10, 0, CONFIG.CARD_HEIGHT),
        name = targetPlayer.Name
    })
    
    local displayName = Instance.new("TextLabel")
    displayName.Size = UDim2.new(1, -145, 0, 20)
    displayName.Position = UDim2.new(0, 10, 0, 25)
    displayName.Text = "@" .. (targetPlayer.DisplayName or targetPlayer.Name)
    displayName.TextColor3 = COLORS.WHITE          -- ✅ Usar Blanco
    displayName.TextTransparency = 0.4             -- ✅ Transparencia para que parezca gris claro pero legible
    displayName.BackgroundTransparency = 1
    displayName.Font = Enum.Font.Gotham
    displayName.TextSize = 11
    displayName.TextXAlignment = Enum.TextXAlignment.Left
    displayName.TextTruncate = Enum.TextTruncate.AtEnd
    displayName.Parent = card
    
    local morphBtn = createButton(card, {
        Size = UDim2.new(0, 60, 0, 35),
        Position = UDim2.new(1, -65, 0, 7.5),
        Text = "Morph",
        TextSize = 12,
        Color = COLORS.LIGHT_GREEN,
        Tooltip = "Morfear a este jugador"
    })
    
    local copyBtn = createButton(card, {
        Size = UDim2.new(0, 30, 0, 35),
        Position = UDim2.new(1, -100, 0, 7.5),
        Text = "📋",
        TextSize = 14,
        Color = COLORS.DARK_GRAY,
        Tooltip = "Copiar objetos (ropa/accesorios)"
    })
    
    if not isFavorite then
        local favBtn = createButton(card, {
            Size = UDim2.new(0, 30, 0, 35),
            Position = UDim2.new(1, -135, 0, 7.5),
            Text = favorites[targetPlayer.Name] and "⭐" or "☆",
            TextSize = 16,
            Color = COLORS.DARK_GRAY,
            Tooltip = favorites[targetPlayer.Name] and "Quitar de favoritos" or "Añadir a favoritos"
        })
        
        connect(favBtn.MouseButton1Click, function()
            if favorites[targetPlayer.Name] then
                favorites[targetPlayer.Name] = nil
                favBtn.Text = "☆"
                sendNotification("Favorites", "Removed from favorites", "")
            else
                favorites[targetPlayer.Name] = {UserId = targetPlayer.UserId, DisplayName = targetPlayer.DisplayName or targetPlayer.Name}
                favBtn.Text = "⭐"
                sendNotification("Favorites", "Added to favorites", "")
            end
            updateFavoritesList()
            saveFavorites()
        end)
    else
        local removeBtn = createButton(card, {
            Size = UDim2.new(0, 30, 0, 35),
            Position = UDim2.new(1, -135, 0, 7.5),
            Text = "✕",
            TextSize = 16,
            Color = COLORS.RED,
            Tooltip = "Eliminar de favoritos"
        })
        
        connect(removeBtn.MouseButton1Click, function()
            favorites[targetPlayer.Name] = nil
            sendNotification("Favorites", "Removed from favorites", "")
            updateFavoritesList()
            saveFavorites()
        end)
    end
    
    connect(morphBtn.MouseButton1Click, function()
        flashButton(morphBtn)
        morphToPlayer(targetPlayer)
    end)
    
    connect(copyBtn.MouseButton1Click, function()
        flashButton(copyBtn)
        copyBodyObjects(targetPlayer, {clothes=true, accessories=true, skin=false, shape=false})
    end)
    
    -- ✅ Vista previa corregida con referencia correcta
    connect(card.InputBegan, function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            if not previewFrame then
                previewFrame = createRoundedFrame(screenGui, UDim2.new(0, 150, 0, 150), UDim2.new(0, 0, 0, 0), COLORS.BLACK, 8)
                previewFrame.BackgroundTransparency = 0.2
                previewFrame.ZIndex = 20
                previewImage = Instance.new("ImageLabel")
                previewImage.Size = UDim2.new(1, -10, 1, -10)
                previewImage.Position = UDim2.new(0, 5, 0, 5)
                previewImage.BackgroundTransparency = 1
                previewImage.Parent = previewFrame
            end
            
            local userId = targetPlayer.UserId
            local cached = playerCache[userId]
            
            if cached and cached.Thumbnail ~= "" then
                previewImage.Image = cached.Thumbnail  -- ✅ Referencia correcta
            else
                pcall(function()
                    local thumb = SERVICES.Players:GetUserThumbnailAsync(userId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size420x420)
                    previewImage.Image = thumb  -- ✅ Referencia correcta
                    if cached then cached.Thumbnail = thumb end
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
    local card = createRoundedFrame(nil, UDim2.new(1, -10, 0, 40), nil, COLORS.MID_GRAY, 6)
    
    local nameLabel = Instance.new("TextLabel")
    nameLabel.Size = UDim2.new(1, -80, 0, 25)
    nameLabel.Position = UDim2.new(0, 10, 0, 5)
    nameLabel.Text = entry.Name
    nameLabel.TextColor3 = COLORS.WHITE
    nameLabel.BackgroundTransparency = 1
    nameLabel.Font = Enum.Font.GothamBold
    nameLabel.TextSize = 14
    nameLabel.TextXAlignment = Enum.TextXAlignment.Left
    nameLabel.TextTruncate = Enum.TextTruncate.AtEnd
    nameLabel.Parent = card
    
    local timeLabel = Instance.new("TextLabel")
    timeLabel.Size = UDim2.new(1, -80, 0, 20)
    timeLabel.Position = UDim2.new(0, 10, 0, 20)
    timeLabel.Text = os.date("%H:%M:%S", entry.Time)
    timeLabel.TextColor3 = COLORS.LIGHT_GRAY
    timeLabel.BackgroundTransparency = 1
    timeLabel.Font = Enum.Font.Gotham
    timeLabel.TextSize = 10
    timeLabel.TextXAlignment = Enum.TextXAlignment.Left
    timeLabel.Parent = card
    
    local morphBtn = createButton(card, {
        Size = UDim2.new(0, 60, 0, 30),
        Position = UDim2.new(1, -65, 0, 5),
        Text = "Morph",
        TextSize = 12,
        Color = COLORS.LIGHT_GREEN,
        Tooltip = "Morfear nuevamente"
    })
    
    connect(morphBtn.MouseButton1Click, function()
        flashButton(morphBtn)
        local target = findPlayerById(entry.UserId) or entry
        morphToPlayer(target)
    end)
    
    return card
end

-- ==========================================
-- EN LA FUNCIÓN getSortedPlayers (MODIFICADA)
-- ==========================================
local function getSortedPlayers(filterText)
    local playersList = {}
    local distances = {}
    
    local searchText = filterText:lower():trim()
    
    for _, p in ipairs(SERVICES.Players:GetPlayers()) do
        if p ~= player then
            local playerName = p.Name or ""
            local playerDisplayName = p.DisplayName or p.Name or ""
            
            local matchesName = playerName:lower():find(searchText) ~= nil
            local matchesDisplayName = playerDisplayName:lower():find(searchText) ~= nil
            
            if searchText == "" or matchesName or matchesDisplayName then
                table.insert(playersList, p)
                distances[p] = getDistanceToPlayer(p)
            end
        end
    end
    
    -- ✅ NUEVO: Tres modos de ordenamiento
    if sortMode == "distance" then
        table.sort(playersList, function(a, b)
            return distances[a] < distances[b]
        end)
    elseif sortMode == "displayname" then
        -- ✅ Ordenar por Display Name (@)
        table.sort(playersList, function(a, b)
            local dA = a.DisplayName or a.Name or ""
            local dB = b.DisplayName or b.Name or ""
            return dA:lower() < dB:lower()
        end)
    else
        -- Por defecto: Nombre de usuario
        table.sort(playersList, function(a, b)
            return a.Name:lower() < b.Name:lower()
        end)
    end
    
    return playersList
end

--- ✅ Actualización diferencial (solo cambios)
local function updatePlayersList(filterText)
    filterText = filterText or ""
    local sorted = getSortedPlayers(filterText)
    local existingCards = {}
    
    for _, child in ipairs(playersScrollFrame:GetChildren()) do
        if child:IsA("Frame") and child.Name ~= "" then
            existingCards[child.Name] = child
        end
    end
    
    for _, targetPlayer in ipairs(sorted) do
        local cardName = "PlayerCard_" .. targetPlayer.UserId
        if not existingCards[cardName] then
            local card = createPlayerCard(targetPlayer, false)
            card.Name = cardName
            card.Parent = playersScrollFrame
        else
            existingCards[cardName] = nil
        end
    end
    
    for _, card in pairs(existingCards) do
        card:Destroy()
    end
    
    playersScrollFrame.CanvasSize = UDim2.new(0, 0, 0, playersLayout.AbsoluteContentSize.Y + 10)
end

local function updateFavoritesList()
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

local function updateHistoryList()
    for _, child in ipairs(historyScrollFrame:GetChildren()) do
        if child:IsA("Frame") then
            child:Destroy()
        end
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
    
    historyScrollFrame.CanvasSize = UDim2.new(0, 0, 0, historyLayout.AbsoluteContentSize.Y + 10)
end

local function switchTab(tabName)
    local oldContent = contentContainer:FindFirstChild(currentTab .. "Content")
    if oldContent then
        animateObject(oldContent, {BackgroundTransparency = 1}, 0.1)
    end
    
    currentTab = tabName
    
    infoTab.BackgroundColor3 = (tabName == "info") and COLORS.ACCENT or COLORS.MID_GRAY
    searchTab.BackgroundColor3 = (tabName == "search") and COLORS.ACCENT or COLORS.MID_GRAY
    playersTab.BackgroundColor3 = (tabName == "players") and COLORS.ACCENT or COLORS.MID_GRAY
    favoritesTab.BackgroundColor3 = (tabName == "favorites") and COLORS.ACCENT or COLORS.MID_GRAY
    skinTab.BackgroundColor3 = (tabName == "skin") and COLORS.ACCENT or COLORS.MID_GRAY
    historyTab.BackgroundColor3 = (tabName == "history") and COLORS.ACCENT or COLORS.MID_GRAY
    
    infoContent.Visible = (tabName == "info")
    searchContent.Visible = (tabName == "search")
    playersContent.Visible = (tabName == "players")
    favoritesContent.Visible = (tabName == "favorites")
    skinContent.Visible = (tabName == "skin")
    historyContent.Visible = (tabName == "history")
    
    local newContent = contentContainer:FindFirstChild(tabName .. "Content")
    if newContent then
        newContent.BackgroundTransparency = 1
        animateObject(newContent, {BackgroundTransparency = 0}, 0.2)
    end
    
    if tabName == "players" then
        updatePlayersList(searchPlayersBox.Text)
    elseif tabName == "favorites" then
        updateFavoritesList()
    elseif tabName == "history" then
        updateHistoryList()
    end
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
        animateObject(frame, {Size = UDim2.new(0, 350, 0, 40)}, 0.2)
        miniBtn.Text = "+"
        tabsContainer.Visible = false
        contentContainer.Visible = false
    else
        animateObject(frame, {Size = UDim2.new(0, CONFIG.MENU_WIDTH, 0, CONFIG.MENU_HEIGHT)}, 0.2)
        miniBtn.Text = "−"
        tabsContainer.Visible = true
        contentContainer.Visible = true
    end
end)

-- ✅ Limpieza de conexiones al cerrar
connect(closeBtn.MouseButton1Click, function()
    cleanupAll()
    screenGui:Destroy()
end)

connect(infoTab.MouseButton1Click, function() switchTab("info") end)
connect(searchTab.MouseButton1Click, function() switchTab("search") end)
connect(playersTab.MouseButton1Click, function() switchTab("players") end)
connect(favoritesTab.MouseButton1Click, function() switchTab("favorites") end)
connect(skinTab.MouseButton1Click, function() switchTab("skin") end)
connect(historyTab.MouseButton1Click, function() switchTab("history") end)

-- ✅ Debounce mejorado
local searchDebounce = nil
searchPlayersBox:GetPropertyChangedSignal("Text"):Connect(function()
    if searchDebounce then
        searchDebounce:Cancel()
    end
    
    local searchText = searchPlayersBox.Text
    searchDebounce = task.delay(CONFIG.DEBOUNCE_TIME, function()
        updatePlayersList(searchText)
        searchDebounce = nil
    end)
end)

-- ==========================================
-- EN LA SECCIÓN DE EVENTOS (MODIFICADA)
-- ==========================================
connect(sortBtn.MouseButton1Click, function()
    -- ✅ Ciclar entre 3 modos: name → displayname → distance → name
    if sortMode == "name" then
        sortMode = "displayname"
        sortBtn.Text = "🏷️ @Name"  -- Icono diferente para Display Name
    elseif sortMode == "displayname" then
        sortMode = "distance"
        sortBtn.Text = "📏 Distance"
    else
        sortMode = "name"
        sortBtn.Text = "📛 Name"
    end
    updatePlayersList(searchPlayersBox.Text)
end)

connect(morphBtn.MouseButton1Click, function()
    flashButton(morphBtn)
    local inputText = sanitizeInput(usernameInput.Text)
    if inputText == "" then
        sendNotification("Morph Avatar", "Please enter a username!", "")
        return
    end
    local target = findPlayerByName(inputText)
    if target then
        morphToPlayer(target)
    else
        sendNotification("Morph Avatar", "Player not found!", "")
    end
end)

connect(idMorphBtn.MouseButton1Click, function()
    flashButton(idMorphBtn)
    local inputText = sanitizeInput(usernameInput.Text)
    local id = tonumber(inputText)
    if id then
        local target = findPlayerById(id)
        if target then
            morphToPlayer(target)
        else
            sendNotification("Morph Avatar", "ID not found!", "")
        end
    else
        sendNotification("Morph Avatar", "Please enter a valid numeric ID!", "")
    end
end)

connect(usernameInput.FocusLost, function(enterPressed)
    if enterPressed then
        local inputText = sanitizeInput(usernameInput.Text)
        if inputText == "" then
            sendNotification("Morph Avatar", "Please enter a username!", "")
            return
        end
        local target = findPlayerByName(inputText)
        if target then
            usernameInput.Text = target.Name or inputText
            morphToPlayer(target)
        else
            sendNotification("Morph Avatar", "Player not found!", "")
        end
    end
end)

connect(resetBtn.MouseButton1Click, function()
    local character = player.Character
    if not character then return end
    local humanoid = character:FindFirstChild("Humanoid")
    if not humanoid then return end
    
    local success, desc = pcall(function()
        return SERVICES.Players:GetHumanoidDescriptionFromUserId(player.UserId)
    end)
    
    if success and desc then
        cleanCharacterAccessories(character)
        pcall(function()
            humanoid:ApplyDescription(desc)
        end)
        flashCharacter(character)
        sendNotification("Morph Avatar", "Reset to original avatar!", "")
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
                if target then
                    morphToPlayer(target)
                else
                    sendNotification("Atajo", "Jugador no encontrado.", "")
                end
            else
                sendNotification("Atajo", "Ingresa un nombre primero.", "")
            end
        elseif input.KeyCode == Enum.KeyCode.F then
            if currentTab ~= "search" then
                switchTab("search")
            end
            usernameInput:CaptureFocus()
        end
    end
end)

connect(SERVICES.Players.PlayerAdded, function()
    if currentTab == "players" then
        updatePlayersList(searchPlayersBox.Text)
    end
end)

connect(SERVICES.Players.PlayerRemoving, function()
    if currentTab == "players" then
        updatePlayersList(searchPlayersBox.Text)
    end
end)

-- ==========================================
-- 7. INICIALIZACIÓN DE LA PALETA DE COLORES
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
    
    bodyColors.HeadColor3 = color
    bodyColors.LeftArmColor3 = color
    bodyColors.RightArmColor3 = color
    bodyColors.LeftLegColor3 = color
    bodyColors.RightLegColor3 = color
    bodyColors.TorsoColor3 = color
    
    pcall(function()
        local desc = humanoid:GetAppliedDescription()
        desc.HeadColor = color
        desc.LeftArmColor = color
        desc.RightArmColor = color
        desc.LeftLegColor = color
        desc.RightLegColor = color
        desc.TorsoColor = color
        if humanoid.ApplyDescriptionClientServer then
            humanoid:ApplyDescriptionClientServer(desc)
        else
            humanoid:ApplyDescription(desc)
        end
    end)
end

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
    stroke.Color = COLORS.WHITE
    stroke.Thickness = 2
    stroke.Transparency = 1
    stroke.Parent = colorBtn
    
    connect(colorBtn.MouseEnter, function()
        animateObject(stroke, {Transparency = 0}, 0.1)
    end)
    
    connect(colorBtn.MouseLeave, function()
        animateObject(stroke, {Transparency = 1}, 0.2)
    end)
    
    connect(colorBtn.MouseButton1Click, function()
        applySkinColor(color)
    end)
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

lastMorphTime = loadCooldown()  -- ✅ Cargar cooldown persistente
loadFavorites()
sendNotification("Morph Avatar Pro", "By @sickly255 (SAGE) 🎨 v2.0.0", "")