-- ==========================================
-- MORPH AVATAR PRO - VERSIÓN OPTIMIZADA PARA EXECUTOR
-- ==========================================
-- Características incluidas:
-- • Tooltips informativos
-- • Animaciones suaves (con fallback si no hay TweenService)
-- • Confirmación opcional antes de morphear
-- • Vista previa de thumbnail (con manejo de errores)
-- • Búsqueda y ordenamiento en pestaña Players
-- • Feedback visual (flash en botones y personaje)
-- • Historial de últimos morpheos
-- • Copiado selectivo de objetos
-- • Atajos de teclado (Ctrl+M, Ctrl+F)
-- • Persistencia de favoritos usando writefile (si el executor lo soporta)
-- • Fallback a PlayerGui si CoreGui está bloqueado
-- • Cooldown en botones para evitar spam
-- • Validación de hexadecimal
-- • Soporte R6/R15
-- • Modularización con helpers
-- ==========================================

-- ==========================================
-- 1. CONFIGURACIÓN Y CONSTANTES
-- ==========================================
local COLORS = {
	BLACK = Color3.fromRGB(15, 15, 15),
	DARK_GRAY = Color3.fromRGB(35, 35, 35),
	MID_GRAY = Color3.fromRGB(50, 50, 50),
	LIGHT_GRAY = Color3.fromRGB(70, 70, 70),
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
	Tween = pcall(function() return game:GetService("TweenService") end) and game:GetService("TweenService") or nil
}

local CONFIG = {
	MENU_WIDTH = 380,
	MENU_HEIGHT = 450,
	CREATOR_NAME = "Sickly255",
	ANIM_SPEED = 0.2,
	CONFIRM_MORPH = false,
	SORT_MODE = "name",
	MAX_HISTORY = 10,
	COOLDOWN = 1 -- segundos entre morphs
}

-- Variables globales
local player = SERVICES.Players.LocalPlayer
local minimized = false
local draggingTitleBar = false
local dragStart, startPos = nil, nil
local currentTab = "info"
local favorites = {}
local playerCache = {}          -- [userId] = {name, displayName, thumbnail, description}
local history = {}              -- últimos morpheos (tabla con userId, name, timestamp)
local confirmMorph = CONFIG.CONFIRM_MORPH
local sortMode = CONFIG.SORT_MODE
local previewFrame = nil
local lastMorphTime = 0
local canUseTween = SERVICES.Tween ~= nil
local canUseWriteFile = pcall(function() return writefile end) -- detecta si el executor tiene writefile

-- ==========================================
-- 2. FUNCIONES DE UTILIDAD (helpers)
-- ==========================================

-- Notificaciones con protección
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

-- Conversión Color3 -> Hex
local function colorToHex(color)
	return string.format("#%02X%02X%02X", color.R * 255, color.G * 255, color.B * 255)
end

-- Crea un botón con estilo estándar (SIN TOOLTIPS)
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

    return btn
end

-- Crea un frame con bordes redondeados
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

-- Función auxiliar para crear diálogos de confirmación simples
local function showConfirmationDialog(title, message, onConfirm)
    -- Crear interfaz del diálogo
    local dialogFrame = createRoundedFrame(screenGui, UDim2.new(0, 300, 0, 150), UDim2.new(0.5, -150, 0.5, -75), COLORS.BLACK, 8)
    dialogFrame.ZIndex = 100
    dialogFrame.Name = "ConfirmationDialog"

    local titleLabel = Instance.new("TextLabel")
    titleLabel.Size = UDim2.new(1, 0, 0, 40)
    titleLabel.Text = title
    titleLabel.TextColor3 = COLORS.WHITE
    titleLabel.BackgroundTransparency = 1
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.TextSize = 18
    titleLabel.Parent = dialogFrame

    local msgLabel = Instance.new("TextLabel")
    msgLabel.Size = UDim2.new(1, -20, 0, 40)
    msgLabel.Position = UDim2.new(0, 10, 0, 45)
    msgLabel.Text = message
    msgLabel.TextColor3 = COLORS.LIGHT_GRAY
    msgLabel.BackgroundTransparency = 1
    msgLabel.Font = Enum.Font.Gotham
    msgLabel.TextSize = 14
    msgLabel.TextWrapped = true
    msgLabel.Parent = dialogFrame

    local yesBtn = createButton(dialogFrame, {
        Size = UDim2.new(0.5, -10, 0, 35),
        Position = UDim2.new(0, 5, 1, -40),
        Text = "Sí",
        Color = COLORS.LIGHT_GREEN
    })
    yesBtn.ZIndex = 101

    local noBtn = createButton(dialogFrame, {
        Size = UDim2.new(0.5, -10, 0, 35),
        Position = UDim2.new(0.5, 5, 1, -40),
        Text = "No",
        Color = COLORS.RED
    })
    noBtn.ZIndex = 101

    -- Conexiones
    yesBtn.MouseButton1Click:Connect(function()
        dialogFrame:Destroy()
        onConfirm()
    end)

    noBtn.MouseButton1Click:Connect(function()
        dialogFrame:Destroy()
    end)
end

-- Sistema de Tooltips (un solo tooltip flotante)
local function setupTooltip(screenGui)
	local tip = createRoundedFrame(screenGui, UDim2.new(0, 0, 0, 0), UDim2.new(0, 0, 0, 0), COLORS.DARK_GRAY, 4)
	tip.BackgroundTransparency = 0.2
	tip.Visible = false
	tip.ZIndex = 10

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

-- Animación con o sin Tween
local function animateObject(obj, props, time)
	if canUseTween then
		local tInfo = TweenInfo.new(time or CONFIG.ANIM_SPEED, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
		local tween = SERVICES.Tween:Create(obj, tInfo, props)
		tween:Play()
		return tween
	else
		-- Fallback: cambio instantáneo
		for prop, value in pairs(props) do
			obj[prop] = value
		end
	end
end

-- Efecto de flash en un botón
local function flashButton(btn)
	local originalColor = btn.BackgroundColor3
	animateObject(btn, {BackgroundColor3 = COLORS.WHITE}, 0.1)
	task.wait(0.1)
	animateObject(btn, {BackgroundColor3 = originalColor}, 0.2)
end

-- Efecto de destello en el personaje
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

-- Cooldown para evitar spam
local function checkCooldown()
	local now = os.clock()
	if now - lastMorphTime < CONFIG.COOLDOWN then
		sendNotification("Cooldown", "Espera " .. math.ceil(CONFIG.COOLDOWN - (now - lastMorphTime)) .. " segundos", "")
		return false
	end
	lastMorphTime = now
	return true
end

-- Guardar favoritos (si el executor lo permite)
local function saveFavorites()
	if not canUseWriteFile then return end
	local data = {}
	for name, info in pairs(favorites) do
		table.insert(data, {Name = name, UserId = info.UserId, DisplayName = info.DisplayName})
	end
	local success, err = pcall(function()
		writefile("MorphFavorites.json", game:GetService("HttpService"):JSONEncode(data))
	end)
	if not success then
		warn("No se pudieron guardar favoritos: " .. tostring(err))
	end
end

-- Cargar favoritos
local function loadFavorites()
	if not canUseWriteFile then return end
	local success, data = pcall(function()
		return readfile("MorphFavorites.json")
	end)
	if success and data then
		local decoded = game:GetService("HttpService"):JSONDecode(data)
		for _, item in ipairs(decoded) do
			favorites[item.Name] = {UserId = item.UserId, DisplayName = item.DisplayName}
		end
	end
end

-- Añadir a historial
local function addToHistory(userId, name, displayName)
	table.insert(history, 1, {UserId = userId, Name = name, DisplayName = displayName, Time = os.time()})
	if #history > CONFIG.MAX_HISTORY then
		table.remove(history)
	end
end

-- ==========================================
-- 3. LÓGICA PRINCIPAL (con protecciones)
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
	-- Intentar cargar thumbnail (puede fallar, se maneja con pcall)
	task.spawn(function()
		local thumbSuccess, thumb = pcall(function()
			return SERVICES.Players:GetUserThumbnailAsync(userId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size100x100)
		end)
		if thumbSuccess then
			data.Thumbnail = thumb
		end
	end)
	playerCache[userId] = data
	return data
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

local function findPlayerByName(partialName)
	if not partialName or partialName == "" then return nil end
	local searchName = partialName:lower()

	-- Buscar online
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

	-- Buscar offline (puede fallar, se maneja con pcall)
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

local function morphToPlayer(target)
    if not target then
        sendNotification("Morph Avatar", "No target found!", "")
        return
    end

    if not checkCooldown() then return end

    local userId = target.UserId or (type(target) == "number" and target or target.UserId)
    local targetName = target.Name or "Unknown"

    if userId == player.UserId then
        sendNotification("Morph Avatar", "Cannot morph to yourself!", "")
        return
    end

    local character = player.Character or player.CharacterAdded:Wait()
    local humanoid = character:WaitForChild("Humanoid", 10)
    if not humanoid then
        sendNotification("Morph Avatar", "Failed to find humanoid!", "")
        return
    end

    local desc = nil

    -- Intentar obtener descripción del objetivo (online)
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

    -- Si no, usar caché o API
    if not desc then
        local cached = playerCache[userId]
        if cached and cached.Description then
            desc = cached.Description
        else
            local success, result = pcall(function()
                return SERVICES.Players:GetHumanoidDescriptionFromUserId(userId)
            end)
            if success then
                desc = result
                if not playerCache[userId] then
                    playerCache[userId] = {UserId = userId, Name = targetName}
                end
                playerCache[userId].Description = desc
            end
        end
    end

    if not desc then
        sendNotification("Morph Avatar", "Failed to load avatar data!", "")
        return
    end

    -- Obtener thumbnail (puede fallar, no crítico)
    local thumbnail = ""
    if playerCache[userId] and playerCache[userId].Thumbnail then
        thumbnail = playerCache[userId].Thumbnail
    else
        local thumbSuccess, thumb = pcall(function()
            return SERVICES.Players:GetUserThumbnailAsync(userId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size100x100)
        end)
        if thumbSuccess then
            thumbnail = thumb
            if playerCache[userId] then
                playerCache[userId].Thumbnail = thumbnail
            end
        end
    end

    -- Limpiar accesorios/ropa actual
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

    -- Aplicar descripción
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

-- Copiar objetos del cuerpo (con opciones selectivas)
local function copyBodyObjects(target, options)
	-- options: {clothes=true, accessories=true, skin=false, shape=false}
	if not target then return end

	local userId = target.UserId or (type(target) == "number" and target or target.UserId)
	if userId == player.UserId then
		sendNotification("Copy Objects", "Cannot copy from yourself!", "")
		return
	end

	local character = player.Character or player.CharacterAdded:Wait()
	local humanoid = character:WaitForChild("Humanoid", 10)
	if not humanoid then return end

	-- Obtener descripción del objetivo
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

	-- Obtener descripción local (para preservar lo no copiado)
	local localDesc = nil
	pcall(function() localDesc = humanoid:GetAppliedDescription() end)

	if localDesc then
		-- Aplicar opciones selectivas
		if options then
			if not options.clothes then
				-- Si no se copia ropa, restaurar la ropa local (IDs de shirt/pants)
				targetDesc.Shirt = localDesc.Shirt
				targetDesc.Pants = localDesc.Pants
			end
			if not options.accessories then
				-- Las descripciones no tienen accesorios directamente; habría que manejarlos aparte
				-- Por simplicidad, omitimos esta opción por ahora
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
		else
			-- Por defecto, copiar todo excepto forma y color (como antes)
			targetDesc.BodyTypeScale = localDesc.BodyTypeScale
			targetDesc.DepthScale = localDesc.DepthScale
			targetDesc.HeadScale = localDesc.HeadScale
			targetDesc.HeightScale = localDesc.HeightScale
			targetDesc.ProportionScale = localDesc.ProportionScale
			targetDesc.WidthScale = localDesc.WidthScale
			targetDesc.HeadColor = localDesc.HeadColor
			targetDesc.TorsoColor = localDesc.TorsoColor
			targetDesc.LeftArmColor = localDesc.LeftArmColor
			targetDesc.RightArmColor = localDesc.RightArmColor
			targetDesc.LeftLegColor = localDesc.LeftLegColor
			targetDesc.RightLegColor = localDesc.RightLegColor
		end
	end

	-- Limpiar objetos visuales existentes
	for _, obj in ipairs(character:GetChildren()) do
		if obj:IsA("Shirt") or obj:IsA("Pants") or obj:IsA("ShirtGraphic") or obj:IsA("Accessory") then
			obj:Destroy()
		end
	end

	local head = character:FindFirstChild("Head")
	if head then
		for _, decal in ipairs(head:GetChildren()) do
			if decal:IsA("Decal") then decal:Destroy() end
		end
	end

	-- Aplicar descripción modificada
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
-- 4. CONSTRUCCIÓN DE LA INTERFAZ (con fallback a PlayerGui)
-- ==========================================

-- Determinar el padre de la GUI (CoreGui o PlayerGui)
local guiParent = SERVICES.CoreGui
local useCoreGui = true
if not SERVICES.CoreGui or not pcall(function() return SERVICES.CoreGui:FindFirstChild("Dummy") end) then
	-- CoreGui no accesible, usar PlayerGui
	guiParent = player:FindFirstChild("PlayerGui")
	useCoreGui = false
	if not guiParent then
		-- Si no hay PlayerGui, crear uno (raro)
		guiParent = Instance.new("ScreenGui", player)
	end
end

-- Limpiar GUI anterior
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

-- ==========================================
-- TABS CON SCROLL HORIZONTAL (reemplazar esta sección)
-- ==========================================

-- Contenedor de pestañas (ahora ScrollingFrame)
local tabsContainer = Instance.new("ScrollingFrame")
tabsContainer.Size = UDim2.new(1, -20, 0, 35)
tabsContainer.Position = UDim2.new(0, 10, 0, 50)
tabsContainer.BackgroundColor3 = COLORS.DARK_GRAY
tabsContainer.BorderSizePixel = 0
tabsContainer.ScrollBarThickness = 4
tabsContainer.ScrollBarImageColor3 = COLORS.ACCENT
tabsContainer.ScrollingDirection = Enum.ScrollingDirection.X
tabsContainer.ScrollingEnabled = true
tabsContainer.CanvasSize = UDim2.new(0, 0, 0, 0) -- se calculará después
tabsContainer.Parent = frame

-- Bordes redondeados (aplicar después de crear)
local tabsCorner = Instance.new("UICorner")
tabsCorner.CornerRadius = UDim.new(0, 8)
tabsCorner.Parent = tabsContainer

-- Layout horizontal
local tabsLayout = Instance.new("UIListLayout")
tabsLayout.FillDirection = Enum.FillDirection.Horizontal
tabsLayout.HorizontalAlignment = Enum.HorizontalAlignment.Left
tabsLayout.VerticalAlignment = Enum.VerticalAlignment.Center
tabsLayout.Padding = UDim.new(0, 4)
tabsLayout.Parent = tabsContainer

-- Función para crear pestaña con ancho fijo (90px)
local function createTab(name, icon, tooltipText)
	local btn = createButton(tabsContainer, {
		Size = UDim2.new(0, 90, 1, -6),  -- ancho fijo 90px, alto con margen
		Position = UDim2.new(0, 0, 0, 3), -- el layout se encarga de la posición
		Text = icon .. " " .. name,
		TextSize = 12,
		Color = (name:lower() == currentTab) and COLORS.ACCENT or COLORS.MID_GRAY,
		Tooltip = tooltipText
	})
	return btn
end

-- Crear las pestañas (mismo orden)
-- Insertar esto antes de 'local searchTab = ...'
local infoTab = createTab("Info", "ℹ️", "Información y Registro de cambios")
local searchTab = createTab("Search", "🔍", "Buscar jugadores por nombre o ID")
local playersTab = createTab("Players", "👥", "Lista de jugadores en el servidor")
local favoritesTab = createTab("Favorites", "⭐", "Tus jugadores favoritos")
local skinTab = createTab("Skin", "🎨", "Personalizar color de piel")
local historyTab = createTab("History", "📜", "Últimos morpheos")

-- Calcular el CanvasSize después de crear las pestañas (para que el scroll funcione)
local function updateTabsCanvasSize()
	-- Suma el ancho de cada botón (90) + padding entre ellos (4) + un pequeño margen extra
	local totalWidth = (#tabsContainer:GetChildren() - 1) * 90 + (tabsLayout.AbsoluteContentSize.X) 
	-- Alternativa más simple: usar AbsoluteContentSize del layout después de un frame
	task.wait() -- esperar un frame para que el layout calcule
	tabsContainer.CanvasSize = UDim2.new(0, tabsLayout.AbsoluteContentSize.X + 10, 0, 0)
end

updateTabsCanvasSize()

-- Si se añadieran o quitaran pestañas dinámicamente, llamarías a esta función de nuevo.

local contentContainer = Instance.new("Frame")
contentContainer.Size = UDim2.new(1, -20, 1, -105)
contentContainer.Position = UDim2.new(0, 10, 0, 95)
contentContainer.BackgroundTransparency = 1
contentContainer.BorderSizePixel = 0
contentContainer.Parent = frame

-- ==========================================
-- PESTAÑA INFO (NUEVA - CORREGIDA)
-- ==========================================
local infoContent = Instance.new("ScrollingFrame")
infoContent.Name = "InfoContent"
infoContent.Size = UDim2.new(1, 0, 1, 0)
infoContent.BackgroundColor3 = COLORS.DARK_GRAY
infoContent.BorderSizePixel = 0
infoContent.ScrollBarThickness = 6
infoContent.ScrollBarImageColor3 = COLORS.ACCENT
infoContent.Visible = true -- Visible por defecto
infoContent.Parent = contentContainer
infoContent.ScrollingDirection = Enum.ScrollingDirection.Y -- Asegurar scroll vertical

local infoCorner = Instance.new("UICorner")
infoCorner.CornerRadius = UDim.new(0, 8)
infoCorner.Parent = infoContent

local infoLabel = Instance.new("TextLabel")
infoLabel.Size = UDim2.new(1, -30, 0, 0) 
infoLabel.AutomaticSize = Enum.AutomaticSize.Y
infoLabel.Position = UDim2.new(0, 15, 0, 10)
infoLabel.BackgroundTransparency = 1
infoLabel.TextColor3 = COLORS.WHITE
infoLabel.Font = Enum.Font.Gotham
infoLabel.TextSize = 13
infoLabel.TextWrapped = true
infoLabel.TextXAlignment = Enum.TextXAlignment.Left
infoLabel.TextYAlignment = Enum.TextYAlignment.Top
infoLabel.Text = [[📝 REGISTRO DE CAMBIOS (v1.0.0 Beta)

🆕 CARACTERÍSTICAS PRINCIPALES
• Búsqueda de jugadores por Nombre o ID.
• Lista de jugadores en el servidor (ordenar por nombre/distancia).
• Historial de los últimos 10 morpheos.
• Lista de Favoritos (se guardan automáticamente si el executor lo permite).
• Paleta de colores para piel con entrada HEX validada.

⚙️ FUNCIONES AVANZADAS
• Copiado Inteligente (📋): Copia ropa y accesorios de otros jugadores, pero conserva tu color de piel y forma corporal (Complexión) automáticamente.
• Validación HEX: El campo de color corrige errores y auto-completa el formato.
• Atajos de Teclado:
   - Ctrl + M: Morfear al nombre/ID ingresado inmediatamente.
   - Ctrl + F: Enfocar automáticamente la barra de búsqueda.
• Animaciones suaves y feedback visual (destellos).
• Cooldown anti-spam y protección contra errores de API.

🎨 INTERFAZ
• Diseño limpio y oscuro de alto contraste.
• Soporte para scroll horizontal en pestañas (móvil).
• Vista previa de avatar al hacer clic en una tarjeta.

👤 CRÉDITOS
Desarrollo original: @sickly255 (SAGE)
Adaptación y correcciones: Basado en feedback de la comunidad.
]]
infoLabel.Parent = infoContent

-- Ajustar tamaño del canvas automáticamente al contenido
task.spawn(function()
    task.wait() -- Esperar un frame para que AutomaticSize calcule
    -- Usamos AbsoluteSize.Y que ahora tendrá el valor real del texto
    infoContent.CanvasSize = UDim2.new(0, 0, 0, infoLabel.AbsoluteSize.Y + 30)
end)

-- ==========================================
-- PESTAÑA SEARCH
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

local infoLabel = Instance.new("TextLabel")
infoLabel.Size = UDim2.new(1, 0, 0, 80)
infoLabel.Position = UDim2.new(0, 0, 1, -85)
infoLabel.Text = "💡 Tips:\n• Enter partial username\n• Works with offline players\n• Press Enter to morph"
infoLabel.TextColor3 = COLORS.LIGHT_GRAY
infoLabel.BackgroundTransparency = 1
infoLabel.Font = Enum.Font.Gotham
infoLabel.TextSize = 11
infoLabel.TextXAlignment = Enum.TextXAlignment.Left
infoLabel.TextYAlignment = Enum.TextYAlignment.Top
infoLabel.Parent = searchContent

-- ==========================================
-- PESTAÑA PLAYERS
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
noFavoritesLabel.Text = "⭐ No favorites yet!\n\nAdd players from the Players tab"
noFavoritesLabel.TextColor3 = COLORS.LIGHT_GRAY
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
noHistoryLabel.Text = "📜 No history yet!\n\nMorph to someone to see it here"
noHistoryLabel.TextColor3 = COLORS.LIGHT_GRAY
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
-- Validación y lógica del Input Hexadecimal
-- Lógica simplificada del Input Hexadecimal (SIN BUGS)
hexInput:GetPropertyChangedSignal("Text"):Connect(function()
    local text = hexInput.Text
    
    -- 1. Vista previa en tiempo real (sin bloquear escritura)
    -- Solo actualizamos el círculo de vista previa, no modificamos el texto activo
    if #text == 7 and text:sub(1,1) == "#" then
        local success, color = pcall(function() return Color3.fromHex(text) end)
        if success then
            hexPreviewCircle.BackgroundColor3 = color
        end
    end
end)

hexInput.FocusLost:Connect(function(enterPressed)
    local text = hexInput.Text
    
    -- 2. Auto-corrección al terminar de escribir
    -- Si falta el #, lo ponemos
    if #text > 0 and text:sub(1,1) ~= "#" then
        text = "#" .. text
        hexInput.Text = text
    end
    
    -- 3. Validar y aplicar
    if #text == 7 then
        local success, color = pcall(function() return Color3.fromHex(text) end)
        if success and color then
            -- Aplicar color
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
                        sendNotification("Skin", "Color aplicado: " .. text, "")
                    end
                end
            end
        else
            sendNotification("Error", "Color HEX inválido", "")
        end
    end
end)

-- Generar botones de paleta (ESTO FALTABA O ESTABA INCOMPLETO)
hexInputCorner.CornerRadius = UDim.new(0, 6)
hexInputCorner.Parent = hexInput

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

local function createPlayerCard(targetPlayer, isFavorite, showCopyOptions)
	-- showCopyOptions: si es true, muestra un menú para copiado selectivo (simplificado)
	local card = createRoundedFrame(nil, UDim2.new(1, -10, 0, 50), nil, COLORS.MID_GRAY, 6)

	local playerName = Instance.new("TextLabel")
	playerName.Size = UDim2.new(1, -145, 0, 25)
	playerName.Position = UDim2.new(0, 10, 0, 5)
	playerName.Text = targetPlayer.Name
	playerName.TextColor3 = COLORS.WHITE
	playerName.BackgroundTransparency = 1
	playerName.Font = Enum.Font.GothamBold
	playerName.TextSize = 14
	playerName.TextXAlignment = Enum.TextXAlignment.Left
	playerName.TextTruncate = Enum.TextTruncate.AtEnd
	playerName.Parent = card

	local displayName = Instance.new("TextLabel")
	displayName.Size = UDim2.new(1, -145, 0, 20)
	displayName.Position = UDim2.new(0, 10, 0, 25)
	displayName.Text = "@" .. targetPlayer.DisplayName
	displayName.TextColor3 = COLORS.LIGHT_GRAY
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

		favBtn.MouseButton1Click:Connect(function()
			if favorites[targetPlayer.Name] then
				favorites[targetPlayer.Name] = nil
				favBtn.Text = "☆"
				sendNotification("Favorites", "Removed from favorites", "")
			else
				favorites[targetPlayer.Name] = {UserId = targetPlayer.UserId, DisplayName = targetPlayer.DisplayName}
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
		removeBtn.MouseButton1Click:Connect(function()
			favorites[targetPlayer.Name] = nil
			sendNotification("Favorites", "Removed from favorites", "")
			updateFavoritesList()
			saveFavorites()
		end)
	end

	morphBtn.MouseButton1Click:Connect(function()
		flashButton(morphBtn)
		morphToPlayer(targetPlayer)
	end)

	copyBtn.MouseButton1Click:Connect(function()
		flashButton(copyBtn)
		-- Por defecto copia todo excepto forma y color (como antes)
		copyBodyObjects(targetPlayer, {clothes=true, accessories=true, skin=false, shape=false})
	end)

	-- Vista previa al hacer clic en la tarjeta
	card.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			if not previewFrame then
				previewFrame = createRoundedFrame(screenGui, UDim2.new(0, 150, 0, 150), UDim2.new(0, 0, 0, 0), COLORS.BLACK, 8)
				previewFrame.BackgroundTransparency = 0.2
				previewFrame.ZIndex = 20
				local previewImage = Instance.new("ImageLabel")
				previewImage.Size = UDim2.new(1, -10, 1, -10)
				previewImage.Position = UDim2.new(0, 5, 0, 5)
				previewImage.BackgroundTransparency = 1
				previewImage.Parent = previewFrame
			end
			local userId = targetPlayer.UserId
			local cached = playerCache[userId]
			if cached and cached.Thumbnail ~= "" then
				previewFrame.ImageLabel.Image = cached.Thumbnail
			else
				pcall(function()
					local thumb = SERVICES.Players:GetUserThumbnailAsync(userId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size420x420)
					previewFrame.ImageLabel.Image = thumb
					if cached then cached.Thumbnail = thumb end
				end)
			end
			previewFrame.Position = UDim2.new(0, input.Position.X + 20, 0, input.Position.Y - 75)
			previewFrame.Visible = true
		end
	end)

	card.InputEnded:Connect(function(input)
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

	morphBtn.MouseButton1Click:Connect(function()
		flashButton(morphBtn)
		local target = findPlayerById(entry.UserId) or entry
		morphToPlayer(target)
	end)

	return card
end

local function getSortedPlayers(filterText)
	local playersList = {}
	for _, p in ipairs(SERVICES.Players:GetPlayers()) do
		if p ~= player then
			if filterText == "" or p.Name:lower():find(filterText:lower()) or p.DisplayName:lower():find(filterText:lower()) then
				table.insert(playersList, p)
			end
		end
	end

	if sortMode == "distance" then
		table.sort(playersList, function(a, b)
			return getDistanceToPlayer(a) < getDistanceToPlayer(b)
		end)
	else
		table.sort(playersList, function(a, b)
			return a.Name:lower() < b.Name:lower()
		end)
	end

	return playersList
end

local function updatePlayersList(filterText)
	filterText = filterText or ""
	for _, child in ipairs(playersScrollFrame:GetChildren()) do
		if child:IsA("Frame") then
			child:Destroy()
		end
	end

	local sorted = getSortedPlayers(filterText)
	for _, targetPlayer in ipairs(sorted) do
		local card = createPlayerCard(targetPlayer, false)
		card.Parent = playersScrollFrame
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

    -- Actualizar colores de botones (Añadir infoTab aquí)
    infoTab.BackgroundColor3 = (tabName == "info") and COLORS.ACCENT or COLORS.MID_GRAY
    searchTab.BackgroundColor3 = (tabName == "search") and COLORS.ACCENT or COLORS.MID_GRAY
    playersTab.BackgroundColor3 = (tabName == "players") and COLORS.ACCENT or COLORS.MID_GRAY
    favoritesTab.BackgroundColor3 = (tabName == "favorites") and COLORS.ACCENT or COLORS.MID_GRAY
    skinTab.BackgroundColor3 = (tabName == "skin") and COLORS.ACCENT or COLORS.MID_GRAY
    historyTab.BackgroundColor3 = (tabName == "history") and COLORS.ACCENT or COLORS.MID_GRAY

    -- Actualizar visibilidad (Añadir infoContent aquí)
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

titleBar.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		draggingTitleBar = true
		dragStart = input.Position
		startPos = frame.Position
	end
end)

SERVICES.UserInput.InputEnded:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		draggingTitleBar = false
	end
end)

SERVICES.UserInput.InputChanged:Connect(function(input)
	if draggingTitleBar and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
		local delta = input.Position - dragStart
		frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
	end
end)

miniBtn.MouseButton1Click:Connect(function()
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

closeBtn.MouseButton1Click:Connect(function()
	screenGui:Destroy()
end)

-- Insertar junto a las otras conexiones de pestañas
infoTab.MouseButton1Click:Connect(function() switchTab("info") end)
searchTab.MouseButton1Click:Connect(function() switchTab("search") end)
playersTab.MouseButton1Click:Connect(function() switchTab("players") end)
favoritesTab.MouseButton1Click:Connect(function() switchTab("favorites") end)
skinTab.MouseButton1Click:Connect(function() switchTab("skin") end)
historyTab.MouseButton1Click:Connect(function() switchTab("history") end)

-- Debounce en búsqueda
local searchDebounce
searchPlayersBox:GetPropertyChangedSignal("Text"):Connect(function()
	if searchDebounce then searchDebounce:Cancel() end
	searchDebounce = task.delay(0.3, function()
		updatePlayersList(searchPlayersBox.Text)
	end)
end)

sortBtn.MouseButton1Click:Connect(function()
	sortMode = sortMode == "name" and "distance" or "name"
	sortBtn.Text = sortMode == "name" and "📛 Name" or "📏 Distance"
	updatePlayersList(searchPlayersBox.Text)
end)

morphBtn.MouseButton1Click:Connect(function()
	flashButton(morphBtn)
	local inputText = usernameInput.Text
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

idMorphBtn.MouseButton1Click:Connect(function()
	flashButton(idMorphBtn)
	local inputText = usernameInput.Text
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

usernameInput.FocusLost:Connect(function(enterPressed)
	if enterPressed then
		local inputText = usernameInput.Text
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

resetBtn.MouseButton1Click:Connect(function()
	local character = player.Character
	if not character then return end

	local humanoid = character:FindFirstChild("Humanoid")
	if not humanoid then return end

	local success, desc = pcall(function()
		return SERVICES.Players:GetHumanoidDescriptionFromUserId(player.UserId)
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

		flashCharacter(character)
		sendNotification("Morph Avatar", "Reset to original avatar!", "")
	end
end)

-- Atajos de teclado (Ctrl+M para morfear, Ctrl+F para buscar)
SERVICES.UserInput.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end -- No activar si el usuario está escribiendo en una caja de texto

    local isCtrlHeld = SERVICES.UserInput:IsKeyDown(Enum.KeyCode.LeftControl) or SERVICES.UserInput:IsKeyDown(Enum.KeyCode.RightControl)

    if isCtrlHeld then
        if input.KeyCode == Enum.KeyCode.M then
            -- Ctrl+M: Morfear al nombre/ID ingresado
            local inputText = usernameInput.Text
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
            -- Ctrl+F: Enfocar campo de búsqueda
            if currentTab ~= "search" then
                switchTab("search")
            end
            usernameInput:CaptureFocus()
        end
    end
end)

SERVICES.Players.PlayerAdded:Connect(function()
	if currentTab == "players" then
		updatePlayersList(searchPlayersBox.Text)
	end
end)

SERVICES.Players.PlayerRemoving:Connect(function()
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

	colorBtn.MouseEnter:Connect(function()
		animateObject(stroke, {Transparency = 0}, 0.1)
	end)
	colorBtn.MouseLeave:Connect(function()
		animateObject(stroke, {Transparency = 1}, 0.2)
	end)

	colorBtn.MouseButton1Click:Connect(function()
		applySkinColor(color)
	end)
end

-- ==========================================
-- 🔹 NUEVO: Ajustar canvas size de la paleta
-- ==========================================
local function updateSkinCanvas()
	-- Esperar un frame para que el grid layout calcule sus dimensiones
	task.wait()
	local contentSize = skinGridLayout.AbsoluteContentSize
	skinPaletteScroll.CanvasSize = UDim2.new(0, contentSize.X + 10, 0, contentSize.Y + 10)
end

updateSkinCanvas()

-- Opcional: si el grid cambia (por ejemplo, si añades más colores), se ajusta automáticamente
skinGridLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(updateSkinCanvas)

-- ==========================================
-- 8. CARGA INICIAL DE FAVORITOS Y NOTIFICACIÓN
-- ==========================================
loadFavorites()
sendNotification("Morph Avatar Pro", "By @sickly255 (SAGE) 🎨", "")