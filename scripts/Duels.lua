-- ==========================================
-- HITBOX EXPANDER PRO - v2.3.1 (AUTO-CLEANUP + ATTRIBUTE TEAMS)
-- ==========================================
-- By @sickly255 (SAGE) | Hitbox + Highlights
-- FIX: Auto-destroys previous running version
-- Uses GetAttribute("team") = "TeamRed" / "TeamBlue"
-- ==========================================

local SCRIPT_ID = "HitboxExpanderSAGE"
local SCRIPT_VERSION = "v2.3.1"

-- ==========================================
-- 🔧 SISTEMA DE AUTO-LIMPIEZA DE VERSIÓN ANTERIOR
-- Si hay un script anterior ejecutándose, lo destruye completamente
-- ==========================================
local function destroyPreviousVersion()
    if not _G[SCRIPT_ID] then return false end
    
    local prev = _G[SCRIPT_ID]
    local cleaned = false
    
    pcall(function()
        -- 1. Detener el loop de hitbox
        if prev.state then
            prev.state.hitboxLoopActive = false
            prev.state.hitboxEnabled = false
            prev.state.highlightEnabled = false
        end
        
        -- 2. Desconectar TODAS las conexiones de la versión anterior
        if prev.connections then
            for _, conn in ipairs(prev.connections) do
                pcall(function() conn:Disconnect() end)
            end
            cleaned = true
        end
        
        -- 3. Cancelar TODOS los tweens activos
        if prev.tweens then
            for _, tween in ipairs(prev.tweens) do
                pcall(function() tween:Cancel() end)
            end
            cleaned = true
        end
        
        -- 4. Destruir hitboxes residuales en TODOS los jugadores
        if prev.hitboxParts then
            for _, part in pairs(prev.hitboxParts) do
                pcall(function()
                    if part and part.Parent then part:Destroy() end
                end)
            end
            cleaned = true
        end
        
        -- 5. Destruir highlights residuales en TODOS los jugadores
        if prev.highlightTargets then
            for _, targetPlayer in pairs(prev.highlightTargets) do
                pcall(function()
                    if targetPlayer and targetPlayer.Character then
                        local hl = targetPlayer.Character:FindFirstChild("Highlight_SAGE")
                        if hl then hl:Destroy() end
                    end
                end)
            end
            cleaned = true
        end
        
        -- 6. Destruir la GUI anterior (incluye toasts)
        if prev.guis then
            for _, gui in ipairs(prev.guis) do
                pcall(function()
                    if gui and gui.Parent then gui:Destroy() end
                end)
            end
            cleaned = true
        end
        
        -- 7. Limpiar referencias globales
        _G[SCRIPT_ID] = nil
    end)
    
    return cleaned
end

local wasPreviousDestroyed = destroyPreviousVersion()

-- ==========================================
-- CONFIGURACIÓN
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

local SERVICES = {
    Players = game:GetService("Players"),
    CoreGui = game:GetService("CoreGui"),
    StarterGui = game:GetService("StarterGui"),
    UserInput = game:GetService("UserInputService"),
    RunService = game:GetService("RunService"),
    Tween = pcall(function() return game:GetService("TweenService") end) and game:GetService("TweenService") or nil,
}

local CONFIG = {
    MENU_WIDTH = 380,
    MENU_HEIGHT = 560,
    CREATOR_NAME = "Sickly255",
    ANIM_SPEED = 0.2,
    HITBOX_EXPANDER_NAME = "HitboxExpander_SAGE",
    HIGHLIGHT_NAME = "Highlight_SAGE",
    TEAM_COLORS = {
        teamred  = Color3.fromRGB(255, 50, 50),
        teamblue = Color3.fromRGB(50, 120, 255)
    },
    NO_TEAM_COLOR = Color3.fromRGB(255, 255, 255),
    RESPAWN_DELAY = 0.8,
    TEAM_ATTR_NAME = "team"
}

local player = SERVICES.Players.LocalPlayer
local draggingTitleBar = false
local dragStart, startPos = nil, nil
local canUseTween = SERVICES.Tween ~= nil

-- 🔧 Tablas de estado globales (se registrarán en _G al final)
local connections = {}
local activeTweens = {}
local hitboxTargets = {}
local hitboxParts = {}
local highlightTargets = {}

local hitboxEnabled = false
local hitboxVisible = true
local hitboxSize = 8
local hitboxLoopActive = false
local highlightEnabled = false

local toastContainer
local toastGui
local frame
local screenGui
local titleBar
local mainContent
local toggleKey = Enum.KeyCode.RightShift
local isListeningForKey = false
local configBtn
local hitboxStatusLabel
local highlightStatusLabel
local enemiesCountLabel
local mainToggleBtn
local highlightToggleBtn
local visibilityBtn

-- ==========================================
-- FUNCIONES BASE
-- ==========================================

local function connect(signal, callback)
    local conn = signal:Connect(callback)
    table.insert(connections, conn)
    return conn
end

local function cleanupAll()
    -- Detener loop
    hitboxLoopActive = false
    hitboxEnabled = false
    highlightEnabled = false
    
    -- Desconectar señales
    for _, conn in ipairs(connections) do
        pcall(function() conn:Disconnect() end)
    end
    connections = {}
    
    -- Cancelar tweens
    for _, tween in ipairs(activeTweens) do
        pcall(function() tween:Cancel() end)
    end
    activeTweens = {}
    
    -- Destruir hitboxes
    for _, part in pairs(hitboxParts) do
        pcall(function() if part and part.Parent then part:Destroy() end end)
    end
    hitboxParts = {}
    hitboxTargets = {}
    
    -- Destruir highlights
    for _, targetPlayer in pairs(highlightTargets) do
        pcall(function()
            if targetPlayer and targetPlayer.Character then
                local hl = targetPlayer.Character:FindFirstChild(CONFIG.HIGHLIGHT_NAME)
                if hl then hl:Destroy() end
            end
        end)
    end
    -- Barrido adicional por seguridad
    for _, p in ipairs(SERVICES.Players:GetPlayers()) do
        pcall(function()
            if p.Character then
                local hl = p.Character:FindFirstChild(CONFIG.HIGHLIGHT_NAME)
                if hl then hl:Destroy() end
                local hb = p.Character:FindFirstChild(CONFIG.HITBOX_EXPANDER_NAME)
                if hb then hb:Destroy() end
            end
        end)
    end
    highlightTargets = {}
    
    -- Destruir GUIs
    if screenGui and screenGui.Parent then pcall(function() screenGui:Destroy() end) end
    if toastGui and toastGui.Parent then pcall(function() toastGui:Destroy() end) end
    
    -- Liberar registro global
    if _G[SCRIPT_ID] and _G[SCRIPT_ID].version == SCRIPT_VERSION then
        _G[SCRIPT_ID] = nil
    end
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

local function registerThemeObj(obj, role, property)
    if not obj or not role then return end
    table.insert(themeObjects, {obj = obj, role = role, property = property or "BackgroundColor3"})
end

-- ==========================================
-- SISTEMA DE TOASTS
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
    toast.Size = UDim2.new(0, 320, 0, 70)
    toast.BackgroundColor3 = COLORS.BG_PANEL
    toast.BorderSizePixel = 0
    toast.BackgroundTransparency = 1
    toast.Parent = toastContainer
    toast.ClipsDescendants = true
    toast.ZIndex = 1000000

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 10)
    corner.Parent = toast

    local stroke = Instance.new("UIStroke")
    stroke.Thickness = 2
    stroke.Color = indicatorColor
    stroke.Transparency = 1
    stroke.Parent = toast

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

    local existingToasts = {}
    for _, child in ipairs(toastContainer:GetChildren()) do
        if child:IsA("Frame") and child ~= toast then
            table.insert(existingToasts, child)
        end
    end
    local toastIndex = #existingToasts
    local finalY = 20 + toastIndex * 80

    toast.Position = UDim2.new(0.5, -160, 0, -90)

    animateObject(toast, {
        Position = UDim2.new(0.5, -160, 0, finalY),
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
            Position = UDim2.new(0.5, -160, 0, -90),
            BackgroundTransparency = 1
        }, 0.35)
        animateObject(stroke, {Transparency = 1}, 0.3)
        animateObject(indicator, {BackgroundTransparency = 1}, 0.3)
        task.wait(0.4)
        if toast and toast.Parent then toast:Destroy() end
    end)
end

-- ==========================================
-- UTILIDADES UI
-- ==========================================

local function flashButton(btn)
    if not btn or not btn.Parent then return end
    local originalColor = btn.BackgroundColor3
    animateObject(btn, {BackgroundColor3 = COLORS.TEXT_PRIMARY}, 0.1)
    task.wait(0.1)
    animateObject(btn, {BackgroundColor3 = originalColor}, 0.2)
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

local function createSlider(parent, props)
    local container = Instance.new("Frame")
    container.Size = props.Size or UDim2.new(1, 0, 0, 40)
    container.Position = props.Position or UDim2.new(0,0,0,0)
    container.BackgroundTransparency = 1
    container.Parent = parent

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0, 100, 1, 0)
    label.BackgroundTransparency = 1
    label.Text = props.Label or "Value"
    label.TextColor3 = COLORS.TEXT_PRIMARY
    label.Font = Enum.Font.GothamBold
    label.TextSize = 12
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = container
    registerThemeObj(label, "TEXT_PRIMARY", "TextColor3")

    local valueLabel = Instance.new("TextLabel")
    valueLabel.Size = UDim2.new(0, 50, 1, 0)
    valueLabel.Position = UDim2.new(1, -50, 0, 0)
    valueLabel.BackgroundTransparency = 1
    valueLabel.Text = tostring(props.Default or props.Min or 1)
    valueLabel.TextColor3 = COLORS.ACCENT
    valueLabel.Font = Enum.Font.GothamBold
    valueLabel.TextSize = 12
    valueLabel.TextXAlignment = Enum.TextXAlignment.Right
    valueLabel.Parent = container
    registerThemeObj(valueLabel, "ACCENT", "TextColor3")

    local sliderTrack = Instance.new("Frame")
    sliderTrack.Size = UDim2.new(1, -160, 0, 6)
    sliderTrack.Position = UDim2.new(0, 105, 0.5, -3)
    sliderTrack.BackgroundColor3 = COLORS.BG_INPUT
    sliderTrack.BorderSizePixel = 0
    sliderTrack.Parent = container
    registerThemeObj(sliderTrack, "BG_INPUT", "BackgroundColor3")

    local trackCorner = Instance.new("UICorner")
    trackCorner.CornerRadius = UDim.new(1, 0)
    trackCorner.Parent = sliderTrack

    local sliderFill = Instance.new("Frame")
    sliderFill.Size = UDim2.new(0.5, 0, 1, 0)
    sliderFill.BackgroundColor3 = COLORS.ACCENT
    sliderFill.BorderSizePixel = 0
    sliderFill.Parent = sliderTrack
    registerThemeObj(sliderFill, "ACCENT", "BackgroundColor3")

    local fillCorner = Instance.new("UICorner")
    fillCorner.CornerRadius = UDim.new(1, 0)
    fillCorner.Parent = sliderFill

    local sliderKnob = Instance.new("Frame")
    sliderKnob.Size = UDim2.new(0, 16, 0, 16)
    sliderKnob.AnchorPoint = Vector2.new(0.5, 0.5)
    sliderKnob.BackgroundColor3 = COLORS.ACCENT
    sliderKnob.BorderSizePixel = 0
    sliderKnob.Parent = sliderTrack
    registerThemeObj(sliderKnob, "ACCENT", "BackgroundColor3")

    local knobCorner = Instance.new("UICorner")
    knobCorner.CornerRadius = UDim.new(1, 0)
    knobCorner.Parent = sliderKnob

    local currentValue = props.Default or props.Min or 1
    local minValue = props.Min or 1
    local maxValue = props.Max or 20

    local function updateSlider(inputX)
        local absPos = sliderTrack.AbsolutePosition.X
        local absSize = sliderTrack.AbsoluteSize.X
        local rel = math.clamp((inputX - absPos) / absSize, 0, 1)
        currentValue = minValue + (maxValue - minValue) * rel
        currentValue = math.floor(currentValue * 10) / 10
        sliderFill.Size = UDim2.new(rel, 0, 1, 0)
        sliderKnob.Position = UDim2.new(rel, 0, 0.5, 0)
        valueLabel.Text = tostring(currentValue)
        if props.OnChange then props.OnChange(currentValue) end
    end

    local dragging = false
    connect(sliderKnob.InputBegan, function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
        end
    end)
    connect(sliderTrack.InputBegan, function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            updateSlider(input.Position.X)
        end
    end)
    connect(SERVICES.UserInput.InputEnded, function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)
    connect(SERVICES.UserInput.InputChanged, function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            updateSlider(input.Position.X)
        end
    end)

    local initialRel = (currentValue - minValue) / (maxValue - minValue)
    sliderFill.Size = UDim2.new(initialRel, 0, 1, 0)
    sliderKnob.Position = UDim2.new(initialRel, 0, 0.5, 0)
    valueLabel.Text = tostring(currentValue)

    return container, function(newVal)
        currentValue = newVal
        local rel = (currentValue - minValue) / (maxValue - minValue)
        sliderFill.Size = UDim2.new(rel, 0, 1, 0)
        sliderKnob.Position = UDim2.new(rel, 0, 0.5, 0)
        valueLabel.Text = tostring(currentValue)
    end
end

-- ==========================================
-- OBTENER COLOR DEL EQUIPO (ATRIBUTO "team")
-- ==========================================

local function getTeamColor(targetPlayer)
    if not targetPlayer then return CONFIG.NO_TEAM_COLOR end
    
    local teamAttr = targetPlayer:GetAttribute(CONFIG.TEAM_ATTR_NAME)
    
    if teamAttr and typeof(teamAttr) == "string" then
        local teamName = teamAttr:lower()
        if CONFIG.TEAM_COLORS[teamName] then
            return CONFIG.TEAM_COLORS[teamName]
        end
    end
    
    return CONFIG.NO_TEAM_COLOR
end

local function isEnemy(targetPlayer)
    if not targetPlayer or targetPlayer == player then return false end
    
    local myTeam = player:GetAttribute(CONFIG.TEAM_ATTR_NAME)
    local theirTeam = targetPlayer:GetAttribute(CONFIG.TEAM_ATTR_NAME)
    
    if not myTeam or not theirTeam then return true end
    
    return myTeam ~= theirTeam
end

local function getEnemies()
    local enemies = {}
    for _, p in ipairs(SERVICES.Players:GetPlayers()) do
        if isEnemy(p) and p.Character then
            table.insert(enemies, p)
        end
    end
    return enemies
end

-- ==========================================
-- LÓGICA: HIGHLIGHT
-- ==========================================

local function applyHighlightToPlayer(targetPlayer)
    if not targetPlayer or not targetPlayer.Parent then return false end
    local character = targetPlayer.Character
    if not character then return false end

    local existing = character:FindFirstChild(CONFIG.HIGHLIGHT_NAME)
    local color = getTeamColor(targetPlayer)
    
    if existing then
        existing.FillColor = color
        existing.OutlineColor = color
        existing.Enabled = true
        highlightTargets[targetPlayer.UserId] = targetPlayer
        return true
    end

    local highlight = Instance.new("Highlight")
    highlight.Name = CONFIG.HIGHLIGHT_NAME
    highlight.FillColor = color
    highlight.OutlineColor = color
    highlight.FillTransparency = 0.5
    highlight.OutlineTransparency = 0
    highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    highlight.Adornee = character
    highlight.Parent = character
    
    highlightTargets[targetPlayer.UserId] = targetPlayer
    return true
end

local function removeHighlightFromPlayer(targetPlayer)
    if not targetPlayer then return end
    local character = targetPlayer.Character
    if character then
        local existing = character:FindFirstChild(CONFIG.HIGHLIGHT_NAME)
        if existing then existing:Destroy() end
    end
    highlightTargets[targetPlayer.UserId] = nil
end

local function applyHighlightToAllEnemies()
    local enemies = getEnemies()
    local applied = 0
    for _, enemy in ipairs(enemies) do
        if applyHighlightToPlayer(enemy) then
            applied = applied + 1
        end
    end
    return applied, #enemies
end

local function removeAllHighlights()
    for userId, targetPlayer in pairs(highlightTargets) do
        if targetPlayer and targetPlayer.Character then
            local hl = targetPlayer.Character:FindFirstChild(CONFIG.HIGHLIGHT_NAME)
            if hl then hl:Destroy() end
        end
    end
    for _, p in ipairs(SERVICES.Players:GetPlayers()) do
        if p.Character then
            local hl = p.Character:FindFirstChild(CONFIG.HIGHLIGHT_NAME)
            if hl then hl:Destroy() end
        end
    end
    highlightTargets = {}
end

local function updateHighlightColors()
    for userId, targetPlayer in pairs(highlightTargets) do
        if targetPlayer and targetPlayer.Parent and targetPlayer.Character then
            local hl = targetPlayer.Character:FindFirstChild(CONFIG.HIGHLIGHT_NAME)
            if hl then
                local color = getTeamColor(targetPlayer)
                hl.FillColor = color
                hl.OutlineColor = color
            end
        end
    end
end

local function toggleHighlight()
    highlightEnabled = not highlightEnabled
    if highlightEnabled then
        local applied, total = applyHighlightToAllEnemies()
        sendNotification("✨ Highlight Activado", string.format("Aplicado a %d/%d enemigos", applied, total), "SUCCESS")
    else
        removeAllHighlights()
        sendNotification("✨ Highlight Desactivado", "Todos los highlights removidos.", "WARNING")
    end
    return highlightEnabled
end

-- ==========================================
-- LÓGICA: HITBOX
-- ==========================================

local function applyHitboxToPlayer(targetPlayer)
    if not targetPlayer or not targetPlayer.Parent then return false end
    local character = targetPlayer.Character
    if not character then return false end
    local rootPart = character:FindFirstChild("HumanoidRootPart")
    if not rootPart then return false end

    local teamColor = getTeamColor(targetPlayer)

    local existing = character:FindFirstChild(CONFIG.HITBOX_EXPANDER_NAME)
    if existing then
        existing.Size = Vector3.new(hitboxSize, hitboxSize, hitboxSize)
        existing.Transparency = hitboxVisible and 0.6 or 1
        existing.Color = teamColor
        hitboxParts[targetPlayer.UserId] = existing
        hitboxTargets[targetPlayer.UserId] = targetPlayer
        return true
    end

    local hitbox = Instance.new("Part")
    hitbox.Name = CONFIG.HITBOX_EXPANDER_NAME
    hitbox.Size = Vector3.new(hitboxSize, hitboxSize, hitboxSize)
    hitbox.Transparency = hitboxVisible and 0.6 or 1
    hitbox.CanCollide = false
    hitbox.Anchored = true
    hitbox.Massless = true
    hitbox.CastShadow = false
    hitbox.Material = Enum.Material.ForceField
    hitbox.Color = teamColor
    hitbox.CFrame = rootPart.CFrame
    hitbox.Parent = character
    
    hitboxParts[targetPlayer.UserId] = hitbox
    hitboxTargets[targetPlayer.UserId] = targetPlayer
    return true
end

local function removeHitboxFromPlayer(targetPlayer)
    if not targetPlayer then return end
    hitboxParts[targetPlayer.UserId] = nil
    hitboxTargets[targetPlayer.UserId] = nil
    local character = targetPlayer.Character
    if character then
        local existing = character:FindFirstChild(CONFIG.HITBOX_EXPANDER_NAME)
        if existing then existing:Destroy() end
    end
end

local function applyHitboxToAllEnemies()
    local enemies = getEnemies()
    local applied = 0
    for _, enemy in ipairs(enemies) do
        if applyHitboxToPlayer(enemy) then
            applied = applied + 1
        end
    end
    return applied, #enemies
end

local function removeAllHitboxes()
    for userId, hitbox in pairs(hitboxParts) do
        if hitbox and hitbox.Parent then
            hitbox:Destroy()
        end
    end
    hitboxParts = {}
    hitboxTargets = {}
end

local function updateHitboxSizes()
    for userId, hitbox in pairs(hitboxParts) do
        if hitbox and hitbox.Parent then
            hitbox.Size = Vector3.new(hitboxSize, hitboxSize, hitboxSize)
            hitbox.Transparency = hitboxVisible and 0.6 or 1
        end
    end
end

local function updateHitboxColors()
    for userId, hitbox in pairs(hitboxParts) do
        if hitbox and hitbox.Parent then
            local targetPlayer = hitboxTargets[userId]
            if targetPlayer then
                hitbox.Color = getTeamColor(targetPlayer)
            end
        end
    end
end

local function startHitboxLoop()
    if hitboxLoopActive then return end
    hitboxLoopActive = true
    task.spawn(function()
        local lastScan = os.clock()
        local lastUpdate = 0
        
        while hitboxEnabled and hitboxLoopActive do
            local now = os.clock()
            
            if now - lastUpdate >= 0.03 then
                lastUpdate = now
                
                for userId, hitbox in pairs(hitboxParts) do
                    if hitbox and hitbox.Parent then
                        local character = hitbox.Parent
                        local root = character:FindFirstChild("HumanoidRootPart")
                        if root then
                            hitbox.CFrame = root.CFrame
                        else
                            hitbox:Destroy()
                            hitboxParts[userId] = nil
                        end
                    else
                        hitboxParts[userId] = nil
                    end
                end
            end
            
            if now - lastScan >= 2 then
                lastScan = now
                pcall(applyHitboxToAllEnemies)
            end
            
            SERVICES.RunService.Heartbeat:Wait()
        end
        hitboxLoopActive = false
    end)
end

local function stopHitboxLoop()
    hitboxLoopActive = false
end

local function toggleHitbox()
    hitboxEnabled = not hitboxEnabled
    if hitboxEnabled then
        local applied, total = applyHitboxToAllEnemies()
        sendNotification("🎯 Hitbox Activada", string.format("Aplicada a %d/%d enemigos (tamaño: %d)", applied, total, hitboxSize), "SUCCESS")
        startHitboxLoop()
    else
        removeAllHitboxes()
        stopHitboxLoop()
        sendNotification("🎯 Hitbox Desactivada", "Todas las hitboxes removidas.", "WARNING")
    end
    return hitboxEnabled
end

local function setHitboxSize(newSize)
    hitboxSize = math.max(1, math.min(50, newSize))
    if hitboxEnabled then
        updateHitboxSizes()
    end
end

local function toggleHitboxVisibility()
    hitboxVisible = not hitboxVisible
    if hitboxEnabled then
        updateHitboxSizes()
    end
    return hitboxVisible
end

-- ==========================================
-- SISTEMA DE RESPAWN + CAMBIO DE EQUIPO
-- ==========================================

local connectedPlayers = {}

local function onPlayerRespawn(targetPlayer, character)
    task.wait(CONFIG.RESPAWN_DELAY)
    
    if not targetPlayer or not targetPlayer.Parent then return end
    if not character or not character.Parent then return end
    
    if not isEnemy(targetPlayer) then return end
    
    if highlightEnabled then
        pcall(function() applyHighlightToPlayer(targetPlayer) end)
    end
    
    if hitboxEnabled then
        pcall(function() applyHitboxToPlayer(targetPlayer) end)
    end
    
    updateStatusUI()
end

local function setupPlayerConnections(targetPlayer)
    if not targetPlayer or targetPlayer == player then return end
    if connectedPlayers[targetPlayer.UserId] then return end
    connectedPlayers[targetPlayer.UserId] = true
    
    connect(targetPlayer.CharacterAdded, function(character)
        onPlayerRespawn(targetPlayer, character)
    end)
    
    connect(targetPlayer:GetAttributeChangedSignal(CONFIG.TEAM_ATTR_NAME), function()
        task.delay(0.2, function()
            if not targetPlayer or not targetPlayer.Parent then return end
            
            if highlightEnabled then
                if isEnemy(targetPlayer) then
                    applyHighlightToPlayer(targetPlayer)
                else
                    removeHighlightFromPlayer(targetPlayer)
                end
                updateHighlightColors()
            end
            
            if hitboxEnabled then
                if isEnemy(targetPlayer) then
                    applyHitboxToPlayer(targetPlayer)
                else
                    removeHitboxFromPlayer(targetPlayer)
                end
                updateHitboxColors()
            end
            
            updateStatusUI()
        end)
    end)
end

-- ==========================================
-- SISTEMA DE TEMAS
-- ==========================================

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

if guiParent:FindFirstChild("HitboxExpanderSAGE") then
    guiParent["HitboxExpanderSAGE"]:Destroy()
end
if guiParent:FindFirstChild("HitboxToasts") then
    guiParent["HitboxToasts"]:Destroy()
end

screenGui = Instance.new("ScreenGui")
screenGui.Name = "HitboxExpanderSAGE"
screenGui.ResetOnSpawn = false
screenGui.DisplayOrder = 999999
screenGui.Parent = guiParent
screenGui.Enabled = true

toastGui = Instance.new("ScreenGui")
toastGui.Name = "HitboxToasts"
toastGui.ResetOnSpawn = false
toastGui.DisplayOrder = 9999999
toastGui.IgnoreGuiInset = true
toastGui.Parent = guiParent

toastContainer = Instance.new("Frame")
toastContainer.Size = UDim2.new(1, 0, 1, 0)
toastContainer.Position = UDim2.new(0, 0, 0, 0)
toastContainer.BackgroundTransparency = 1
toastContainer.Active = false
toastContainer.ZIndex = 1000000
toastContainer.Parent = toastGui

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
mainPadding.PaddingTop = UDim.new(0, 10)
mainPadding.PaddingBottom = UDim.new(0, 10)
mainPadding.PaddingLeft = UDim.new(0, 10)
mainPadding.PaddingRight = UDim.new(0, 10)
mainPadding.Parent = frame

titleBar = Instance.new("Frame")
titleBar.Size = UDim2.new(1, 0, 0, 40)
titleBar.Position = UDim2.new(0, 0, 0, 0)
titleBar.BackgroundTransparency = 1
titleBar.Parent = frame
titleBar.Active = true

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -120, 0, 40)
title.Position = UDim2.new(0, 8, 0, 0)
title.Text = "🎯 Hitbox Expander " .. SCRIPT_VERSION
title.TextColor3 = COLORS.ACCENT
title.BackgroundTransparency = 1
title.BorderSizePixel = 0
title.Font = Enum.Font.GothamBold
title.TextSize = 15
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

mainContent = Instance.new("ScrollingFrame")
mainContent.Size = UDim2.new(1, 0, 1, -50)
mainContent.Position = UDim2.new(0, 0, 0, 50)
mainContent.BackgroundColor3 = COLORS.BG_PANEL
mainContent.BorderSizePixel = 0
mainContent.ScrollBarThickness = 5
mainContent.ScrollBarImageColor3 = COLORS.SCROLL_THUMB
mainContent.Parent = frame
mainContent.AutomaticCanvasSize = Enum.AutomaticSize.Y
mainContent.ScrollingDirection = Enum.ScrollingDirection.Y
mainContent.ClipsDescendants = true
registerThemeObj(mainContent, "BG_PANEL", "BackgroundColor3")

local contentCorner = Instance.new("UICorner")
contentCorner.CornerRadius = UDim.new(0, 8)
contentCorner.Parent = mainContent

local contentStroke = Instance.new("UIStroke")
contentStroke.Thickness = 1.5
contentStroke.Color = COLORS.BORDER
contentStroke.Parent = mainContent
registerThemeObj(contentStroke, "BORDER", "Color")

local contentPadding = Instance.new("UIPadding")
contentPadding.PaddingTop = UDim.new(0, 10)
contentPadding.PaddingBottom = UDim.new(0, 10)
contentPadding.PaddingLeft = UDim.new(0, 10)
contentPadding.PaddingRight = UDim.new(0, 10)
contentPadding.Parent = mainContent

local contentLayout = Instance.new("UIListLayout")
contentLayout.Padding = UDim.new(0, 8)
contentLayout.SortOrder = Enum.SortOrder.LayoutOrder
contentLayout.Parent = mainContent

-- ==========================================
-- WIDGETS DEL CONTENIDO
-- ==========================================

local statusCard = createRoundedFrame(mainContent, UDim2.new(1, 0, 0, 60), nil, COLORS.BG_CARD, 8)

local statusIcon = Instance.new("TextLabel")
statusIcon.Size = UDim2.new(0, 40, 1, 0)
statusIcon.BackgroundTransparency = 1
statusIcon.Text = "🎯"
statusIcon.TextSize = 28
statusIcon.Parent = statusCard

enemiesCountLabel = Instance.new("TextLabel")
enemiesCountLabel.Size = UDim2.new(1, -50, 0, 20)
enemiesCountLabel.Position = UDim2.new(0, 45, 0, 8)
enemiesCountLabel.BackgroundTransparency = 1
enemiesCountLabel.Text = "Enemigos detectados: 0"
enemiesCountLabel.TextColor3 = COLORS.TEXT_PRIMARY
enemiesCountLabel.Font = Enum.Font.GothamBold
enemiesCountLabel.TextSize = 12
enemiesCountLabel.TextXAlignment = Enum.TextXAlignment.Left
enemiesCountLabel.Parent = statusCard
registerThemeObj(enemiesCountLabel, "TEXT_PRIMARY", "TextColor3")

local statusInfoLabel = Instance.new("TextLabel")
statusInfoLabel.Size = UDim2.new(1, -50, 0, 18)
statusInfoLabel.Position = UDim2.new(0, 45, 0, 30)
statusInfoLabel.BackgroundTransparency = 1
statusInfoLabel.Text = "Colores por atributo 'team' + Auto-cleanup"
statusInfoLabel.TextColor3 = COLORS.TEXT_SECONDARY
statusInfoLabel.Font = Enum.Font.Gotham
statusInfoLabel.TextSize = 10
statusInfoLabel.TextXAlignment = Enum.TextXAlignment.Left
statusInfoLabel.Parent = statusCard
registerThemeObj(statusInfoLabel, "TEXT_SECONDARY", "TextColor3")

-- Sección HITBOX
local hitboxSection = createRoundedFrame(mainContent, UDim2.new(1, 0, 0, 170), nil, COLORS.BG_CARD, 8)

local hitboxSectionTitle = Instance.new("TextLabel")
hitboxSectionTitle.Size = UDim2.new(1, -10, 0, 24)
hitboxSectionTitle.Position = UDim2.new(0, 10, 0, 5)
hitboxSectionTitle.BackgroundTransparency = 1
hitboxSectionTitle.Text = "🎯 HITBOX"
hitboxSectionTitle.TextColor3 = COLORS.ACCENT
hitboxSectionTitle.Font = Enum.Font.GothamBold
hitboxSectionTitle.TextSize = 13
hitboxSectionTitle.TextXAlignment = Enum.TextXAlignment.Left
hitboxSectionTitle.Parent = hitboxSection
registerThemeObj(hitboxSectionTitle, "ACCENT", "TextColor3")

hitboxStatusLabel = Instance.new("TextLabel")
hitboxStatusLabel.Size = UDim2.new(1, -10, 0, 18)
hitboxStatusLabel.Position = UDim2.new(0, 10, 0, 28)
hitboxStatusLabel.BackgroundTransparency = 1
hitboxStatusLabel.Text = "Estado: DESACTIVADO"
hitboxStatusLabel.TextColor3 = COLORS.DANGER
hitboxStatusLabel.Font = Enum.Font.GothamBold
hitboxStatusLabel.TextSize = 11
hitboxStatusLabel.TextXAlignment = Enum.TextXAlignment.Left
hitboxStatusLabel.Parent = hitboxSection
registerThemeObj(hitboxStatusLabel, "DANGER", "TextColor3")

mainToggleBtn = createButton(hitboxSection, {
    Size = UDim2.new(1, -20, 0, 36),
    Position = UDim2.new(0, 10, 0, 50),
    Text = "🚀 ACTIVAR HITBOX",
    TextSize = 13,
    Color = COLORS.SUCCESS,
    CornerRadius = 8
})

local sliderContainer = createSlider(hitboxSection, {
    Size = UDim2.new(1, -20, 0, 34),
    Position = UDim2.new(0, 10, 0, 92),
    Label = "Tamaño:",
    Min = 3,
    Max = 30,
    Default = 8,
    OnChange = function(val) setHitboxSize(val) end
})

visibilityBtn = createButton(hitboxSection, {
    Size = UDim2.new(1, -20, 0, 32),
    Position = UDim2.new(0, 10, 0, 128),
    Text = "👁️ Hitbox Visible: SÍ",
    TextSize = 12,
    Color = COLORS.BG_PANEL,
    CornerRadius = 8
})

-- Sección HIGHLIGHT
local highlightSection = createRoundedFrame(mainContent, UDim2.new(1, 0, 0, 120), nil, COLORS.BG_CARD, 8)

local highlightSectionTitle = Instance.new("TextLabel")
highlightSectionTitle.Size = UDim2.new(1, -10, 0, 24)
highlightSectionTitle.Position = UDim2.new(0, 10, 0, 5)
highlightSectionTitle.BackgroundTransparency = 1
highlightSectionTitle.Text = "✨ HIGHLIGHT (ESP)"
highlightSectionTitle.TextColor3 = COLORS.ACCENT
highlightSectionTitle.Font = Enum.Font.GothamBold
highlightSectionTitle.TextSize = 13
highlightSectionTitle.TextXAlignment = Enum.TextXAlignment.Left
highlightSectionTitle.Parent = highlightSection
registerThemeObj(highlightSectionTitle, "ACCENT", "TextColor3")

highlightStatusLabel = Instance.new("TextLabel")
highlightStatusLabel.Size = UDim2.new(1, -10, 0, 18)
highlightStatusLabel.Position = UDim2.new(0, 10, 0, 28)
highlightStatusLabel.BackgroundTransparency = 1
highlightStatusLabel.Text = "Estado: DESACTIVADO"
highlightStatusLabel.TextColor3 = COLORS.DANGER
highlightStatusLabel.Font = Enum.Font.GothamBold
highlightStatusLabel.TextSize = 11
highlightStatusLabel.TextXAlignment = Enum.TextXAlignment.Left
highlightStatusLabel.Parent = highlightSection
registerThemeObj(highlightStatusLabel, "DANGER", "TextColor3")

highlightToggleBtn = createButton(highlightSection, {
    Size = UDim2.new(1, -20, 0, 36),
    Position = UDim2.new(0, 10, 0, 50),
    Text = "✨ ACTIVAR HIGHLIGHT",
    TextSize = 13,
    Color = COLORS.SUCCESS,
    CornerRadius = 8
})

local teamColorsInfo = Instance.new("TextLabel")
teamColorsInfo.Size = UDim2.new(1, -20, 0, 32)
teamColorsInfo.Position = UDim2.new(0, 10, 0, 88)
teamColorsInfo.BackgroundTransparency = 1
teamColorsInfo.Text = "🔴 attr team='TeamRed': Rojo\n🔵 attr team='TeamBlue': Azul  |  ⚪ Sin team: Blanco"
teamColorsInfo.TextColor3 = COLORS.TEXT_SECONDARY
teamColorsInfo.Font = Enum.Font.Gotham
teamColorsInfo.TextSize = 10
teamColorsInfo.TextXAlignment = Enum.TextXAlignment.Left
teamColorsInfo.TextYAlignment = Enum.TextYAlignment.Center
teamColorsInfo.TextWrapped = true
teamColorsInfo.Parent = highlightSection
registerThemeObj(teamColorsInfo, "TEXT_SECONDARY", "TextColor3")

-- Info final
local infoCard = createRoundedFrame(mainContent, UDim2.new(1, 0, 0, 80), nil, COLORS.BG_CARD, 8)

local infoLabel = Instance.new("TextLabel")
infoLabel.Size = UDim2.new(1, -16, 1, -10)
infoLabel.Position = UDim2.new(0, 8, 0, 5)
infoLabel.BackgroundTransparency = 1
infoLabel.Text = [[⚡ ]] .. SCRIPT_VERSION .. [[ - AUTO-CLEANUP + ATTRIBUTE TEAMS
• Auto-destroys previous version (via _G)
• Colores por atributo "team" (TeamRed/TeamBlue)
• Persiste al respawn + Escucha AttributeChanged
• Anchored = true (no deforma ni cae)]]
infoLabel.TextColor3 = COLORS.TEXT_SECONDARY
infoLabel.Font = Enum.Font.Gotham
infoLabel.TextSize = 10
infoLabel.TextXAlignment = Enum.TextXAlignment.Left
infoLabel.TextYAlignment = Enum.TextYAlignment.Top
infoLabel.TextWrapped = true
infoLabel.Parent = infoCard
registerThemeObj(infoLabel, "TEXT_SECONDARY", "TextColor3")

-- ==========================================
-- ACTUALIZAR UI
-- ==========================================

function updateStatusUI()
    local enemies = getEnemies()
    enemiesCountLabel.Text = string.format("Enemigos detectados: %d", #enemies)

    if hitboxEnabled then
        hitboxStatusLabel.Text = string.format("Estado: ACTIVO (%d hitboxes)", #hitboxParts)
        hitboxStatusLabel.TextColor3 = COLORS.SUCCESS
        mainToggleBtn.Text = "⛔ DESACTIVAR HITBOX"
        mainToggleBtn.BackgroundColor3 = COLORS.DANGER
    else
        hitboxStatusLabel.Text = "Estado: DESACTIVADO"
        hitboxStatusLabel.TextColor3 = COLORS.DANGER
        mainToggleBtn.Text = "🚀 ACTIVAR HITBOX"
        mainToggleBtn.BackgroundColor3 = COLORS.SUCCESS
    end

    if highlightEnabled then
        highlightStatusLabel.Text = string.format("Estado: ACTIVO (%d highlights)", #highlightTargets)
        highlightStatusLabel.TextColor3 = COLORS.SUCCESS
        highlightToggleBtn.Text = "⛔ DESACTIVAR HIGHLIGHT"
        highlightToggleBtn.BackgroundColor3 = COLORS.DANGER
    else
        highlightStatusLabel.Text = "Estado: DESACTIVADO"
        highlightStatusLabel.TextColor3 = COLORS.DANGER
        highlightToggleBtn.Text = "✨ ACTIVAR HIGHLIGHT"
        highlightToggleBtn.BackgroundColor3 = COLORS.SUCCESS
    end
end

-- ==========================================
-- EVENTOS
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
        frame.Position = UDim2.new(
            startPos.X.Scale, startPos.X.Offset + delta.X,
            startPos.Y.Scale, startPos.Y.Offset + delta.Y
        )
    end
end)

-- 🔧 Close button ahora usa cleanupAll (que limpia TODO)
connect(closeBtn.MouseButton1Click, function()
    cleanupAll()
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

connect(mainToggleBtn.MouseButton1Click, function()
    flashButton(mainToggleBtn)
    toggleHitbox()
    updateStatusUI()
end)

connect(highlightToggleBtn.MouseButton1Click, function()
    flashButton(highlightToggleBtn)
    toggleHighlight()
    updateStatusUI()
end)

connect(visibilityBtn.MouseButton1Click, function()
    flashButton(visibilityBtn)
    local vis = toggleHitboxVisibility()
    visibilityBtn.Text = vis and "👁️ Hitbox Visible: SÍ" or "👁️ Hitbox Visible: NO"
    sendNotification("👁️ Visibilidad", vis and "Hitboxes ahora son visibles" or "Hitboxes ocultas", "INFO")
end)

connect(SERVICES.UserInput.InputBegan, function(input, gameProcessed)
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

    if input.KeyCode == toggleKey and not gameProcessed then
        screenGui.Enabled = not screenGui.Enabled
        if not screenGui.Enabled then
            sendNotification("👁️ GUI Oculta", "Presiona [" .. toggleKey.Name .. "] para volver a mostrar.", "INFO")
        else
            sendNotification("👁️ GUI Visible", "Bienvenido de vuelta.", "SUCCESS")
        end
        return
    end
end)

connect(SERVICES.Players.PlayerAdded, function(newPlayer)
    setupPlayerConnections(newPlayer)
    
    task.delay(1, function()
        if newPlayer and newPlayer.Parent and isEnemy(newPlayer) then
            if highlightEnabled then applyHighlightToPlayer(newPlayer) end
            if hitboxEnabled then applyHitboxToPlayer(newPlayer) end
        end
        updateStatusUI()
    end)
end)

connect(SERVICES.Players.PlayerRemoving, function(p)
    connectedPlayers[p.UserId] = nil
    hitboxTargets[p.UserId] = nil
    highlightTargets[p.UserId] = nil
    hitboxParts[p.UserId] = nil
    updateStatusUI()
end)

connect(player:GetAttributeChangedSignal(CONFIG.TEAM_ATTR_NAME), function()
    task.delay(0.3, function()
        removeAllHighlights()
        removeAllHitboxes()
        
        if highlightEnabled then applyHighlightToAllEnemies() end
        if hitboxEnabled then applyHitboxToAllEnemies() end
        
        local myTeam = player:GetAttribute(CONFIG.TEAM_ATTR_NAME) or "Ninguno"
        sendNotification("👥 Equipo Cambiado", "Tu atributo team = " .. myTeam, "INFO")
        updateStatusUI()
    end)
end)

for _, p in ipairs(SERVICES.Players:GetPlayers()) do
    if p ~= player then
        setupPlayerConnections(p)
    end
end

task.spawn(function()
    while screenGui and screenGui.Parent do
        updateStatusUI()
        task.wait(2)
    end
end)

-- ==========================================
-- 🔧 REGISTRAR INSTANCIA ACTUAL EN _G
-- Esto permite que la próxima ejecución pueda limpiarla
-- ==========================================
_G[SCRIPT_ID] = {
    version = SCRIPT_VERSION,
    connections = connections,
    tweens = activeTweens,
    hitboxParts = hitboxParts,
    hitboxTargets = hitboxTargets,
    highlightTargets = highlightTargets,
    state = {
        hitboxLoopActive = hitboxLoopActive,
        hitboxEnabled = hitboxEnabled,
        highlightEnabled = highlightEnabled
    },
    guis = {screenGui, toastGui},
    cleanup = cleanupAll
}

-- ==========================================
-- INICIALIZACIÓN
-- ==========================================

updateStatusUI()
if wasPreviousDestroyed then
    sendNotification("♻️ Auto-cleanup", "Versión anterior destruida completamente", "WARNING")
    task.wait(0.3)
end
sendNotification("🎯 Hitbox Expander " .. SCRIPT_VERSION, "By @sickly255 (SAGE) ✨ Auto-cleanup", "INFO")
task.wait(0.3)
sendNotification("🔴🔵 Colores", "Atributo 'team' = TeamRed (🔴) o TeamBlue (🔵)", "INFO")
task.wait(0.3)
sendNotification("✅ Registered in _G", "La próxima ejecución limpiará esta versión", "SUCCESS")