-- ==========================================
-- AUTO-JOB DELIVERY SYSTEM + TELEPORT SUAVIZADO (GIVER FIX)
-- ==========================================
local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")

local player = Players.LocalPlayer

-- ⚙️ CONFIGURACIÓN
local STEP_SIZE = 15
local STEP_DELAY = 0.01
local PICKUP_TIMEOUT = 12
local DELIVERY_TIMEOUT = 12
local RETRY_TRIGGER_EVERY = 3
local MAX_CONSECUTIVE_FAILS = 3
local FAIL_COOLDOWN = 5
local NPC_SPAWN_WAIT = 6

-- 📍 Posición fija del Giver (tu CFrame)
local GIVER_HARDCODED_POS = Vector3.new(151.902512, 40.724411, 512.531128)
local cachedGiverPos = GIVER_HARDCODED_POS

local autoJobEnabled = false
local jobThread = nil
local consecutiveFails = 0

-- ==========================================
-- 1. GUI (Sin cambios)
-- ==========================================
local existingGui = CoreGui:FindFirstChild("AutoJob_GUI")
if existingGui then existingGui:Destroy() end

local screenGui = Instance.new("ScreenGui", CoreGui)
screenGui.Name = "AutoJob_GUI"
screenGui.ResetOnSpawn = false

local main = Instance.new("Frame", screenGui)
main.Size = UDim2.new(0, 210, 0, 280)
main.Position = UDim2.new(0, 20, 0.5, -140)
main.BackgroundColor3 = Color3.fromRGB(10, 10, 12)
main.BorderSizePixel = 0
main.Active = true
main.Draggable = true

Instance.new("UICorner", main).CornerRadius = UDim.new(0, 12)
local uiStroke = Instance.new("UIStroke", main)
uiStroke.Color = Color3.fromRGB(0, 162, 255)
uiStroke.Thickness = 1.8

local title = Instance.new("TextLabel", main)
title.Size = UDim2.new(1, 0, 0, 45)
title.Text = "AUTO DELIVERY JOB"
title.TextColor3 = Color3.fromRGB(0, 162, 255)
title.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
title.Font = Enum.Font.GothamBold
title.TextSize = 16
Instance.new("UICorner", title).CornerRadius = UDim.new(0, 12)

local function createBtn(name, text, pos, color)
    local b = Instance.new("TextButton", main)
    b.Name = name
    b.Size = UDim2.new(0, 190, 0, 38)
    b.Position = pos
    b.Text = text
    b.BackgroundColor3 = color
    b.TextColor3 = Color3.new(1, 1, 1)
    b.Font = Enum.Font.GothamBold
    b.TextSize = 11
    Instance.new("UICorner", b).CornerRadius = UDim.new(0, 8)
    return b
end

local btnToggle = createBtn("BtnToggle", "🟢 ACTIVAR AUTO-JOB", UDim2.new(0, 10, 0, 55), Color3.fromRGB(20, 100, 40))
local btnHide = createBtn("BtnHide", "MINIMIZAR", UDim2.new(0, 10, 0, 100), Color3.fromRGB(20, 20, 20))
local btnClose = createBtn("BtnClose", "CERRAR GUI", UDim2.new(0, 10, 0, 145), Color3.fromRGB(100, 0, 0))

local infoLabel = Instance.new("TextLabel", main)
infoLabel.Size = UDim2.new(1, -20, 0, 60)
infoLabel.Position = UDim2.new(0, 10, 0, 195)
infoLabel.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
infoLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
infoLabel.Font = Enum.Font.GothamBold
infoLabel.TextSize = 12
infoLabel.TextWrapped = true
infoLabel.TextYAlignment = "Top"
Instance.new("UICorner", infoLabel).CornerRadius = UDim.new(0, 6)
infoLabel.Text = "Sistema en espera.\nPresiona ACTIVAR para iniciar."

local openBtn = Instance.new("TextButton", screenGui)
openBtn.Size = UDim2.new(0, 120, 0, 40)
openBtn.Position = UDim2.new(0, 20, 0.5, -20)
openBtn.Text = "📦 ABRIR JOB"
openBtn.BackgroundColor3 = Color3.fromRGB(0, 162, 255)
openBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
openBtn.Font = Enum.Font.GothamBold
openBtn.TextSize = 14
openBtn.Visible = false
Instance.new("UICorner", openBtn).CornerRadius = UDim.new(0, 10)
Instance.new("UIStroke", openBtn).Thickness = 2

btnHide.MouseButton1Click:Connect(function() main.Visible = false; openBtn.Visible = true end)
openBtn.MouseButton1Click:Connect(function() main.Visible = true; openBtn.Visible = false end)
btnClose.MouseButton1Click:Connect(function() screenGui:Destroy() end)

-- ==========================================
-- 2. TELEPORT SUAVIZADO
-- ==========================================
local function smoothTeleport(targetPos)
    local char = player.Character
    if not char then return false end
    local root = char:FindFirstChild("HumanoidRootPart")
    if not root then return false end

    root.AssemblyLinearVelocity = Vector3.zero
    root.AssemblyAngularVelocity = Vector3.zero
    task.wait(0.02)

    local startPos = root.Position
    local distance = (targetPos - startPos).Magnitude
    local targetCFrame = CFrame.new(targetPos)

    if distance > STEP_SIZE then
        local direction = (targetPos - startPos).Unit
        local remaining = distance
        while remaining > STEP_SIZE do
            if not player.Character or not player.Character:FindFirstChild("HumanoidRootPart") then return false end
            root.CFrame = CFrame.new(root.Position + direction * STEP_SIZE) * root.CFrame.Rotation
            task.wait(STEP_DELAY)
            remaining -= STEP_SIZE
        end
    end

    root.CFrame = targetCFrame
    root.AssemblyLinearVelocity = Vector3.zero
    root.AssemblyAngularVelocity = Vector3.zero
    return true
end

-- ==========================================
-- 3. BYPASS DE PROXIMITYPROMPT
-- ==========================================
local function bypassAndTriggerPrompt(prompt)
    if not prompt or not prompt:IsA("ProximityPrompt") then return false end
    prompt.HoldDuration = 0
    prompt.MaxActivationDistance = math.huge
    prompt.Enabled = true
    task.wait(0.02)

    if fireproximityprompt then
        fireproximityprompt(prompt)
    else
        prompt:InputHoldBegin()
        task.wait(0.02)
        prompt:InputHoldEnd()
    end
    return true
end

-- ==========================================
-- 4. DETECCIÓN GIVER (STREAMING + DUAL FIX)
-- ==========================================
local function hasChicken()
    local char = player.Character
    if not char then return false end
    return char:FindFirstChild("Fried Chicken") or player.Backpack:FindFirstChild("Fried Chicken")
end

-- ✅ Busca SOLO en Works>Arturos>Delivery>Giver y retorna el Prompt MÁS CERCANO
local function findClosestGiverPrompt(targetPos)
    local works = Workspace:FindFirstChild("Works")
    if not works then return nil end
    local p = works:FindFirstChild("Arturos")
    if p then p = p:FindFirstChild("Delivery") end
    if p then p = p:FindFirstChild("Giver") end
    if not p then return nil end

    local closestPrompt = nil
    local minDist = math.huge

    for _, descendant in ipairs(p:GetDescendants()) do
        if descendant:IsA("ProximityPrompt") then
            local part = descendant.Parent
            if part and part:IsA("BasePart") then
                local dist = (part.Position - targetPos).Magnitude
                if dist < minDist then
                    minDist = dist
                    closestPrompt = descendant
                end
            end
        end
    end
    return closestPrompt
end

-- ✅ NPC Delivery (sin cambios, ya funciona con streaming)
local function getDeliveryTarget()
    local works = Workspace:FindFirstChild("Works")
    if not works then return nil, nil end
    local npcFolder = works:FindFirstChild("DeliveryNpcs")
    if not npcFolder then return nil, nil end

    for _, child in ipairs(npcFolder:GetChildren()) do
        if child:IsA("Model") then
            local pos = child.WorldPivot and child.WorldPivot.Position
            if not pos then
                local part = child.PrimaryPart or child:FindFirstChildWhichIsA("BasePart", true)
                if part then pos = part.Position end
            end
            if pos then return pos, child end
        end
    end
    return nil, nil
end

-- ==========================================
-- 5. CICLO AUTOMATIZADO (OPTIMIZADO)
-- ==========================================
local function runAutoJob()
    while autoJobEnabled do
        local char = player.Character
        local root = char and char:FindFirstChild("HumanoidRootPart")
        if not root then
            infoLabel.Text = "⏳ Esperando personaje..."
            infoLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
            task.wait(1)
            continue
        end

        if not hasChicken() then
            infoLabel.Text = "📦 Yendo al Giver..."
            infoLabel.TextColor3 = Color3.fromRGB(255, 200, 0)
            
            -- 📍 Teleport directo a posición cacheada/hardcodeada
            smoothTeleport(cachedGiverPos)
            
            -- ⚡ Polling rápido post-teleport (streaming fix + dual giver fix)
            local giverPrompt = nil
            for _ = 1, 25 do -- 2.5s máximo, revisa cada 0.1s
                giverPrompt = findClosestGiverPrompt(cachedGiverPos)
                if giverPrompt then break end
                task.wait(0.1)
            end
            
            if giverPrompt then
                -- 💾 Actualizar cache con la posición real del giver detectado
                cachedGiverPos = giverPrompt.Parent.Position
                
                bypassAndTriggerPrompt(giverPrompt) -- 🔥 Disparo inmediato, sin cooldowns
                
                infoLabel.Text = "⏳ Esperando pedido..."
                infoLabel.TextColor3 = Color3.fromRGB(150, 200, 255)
                
                local waitTime = 0
                local pickupSuccess = false
                while waitTime < PICKUP_TIMEOUT and autoJobEnabled do
                    if hasChicken() then pickupSuccess = true; break end
                    if waitTime > 0 and math.floor(waitTime) % RETRY_TRIGGER_EVERY == 0 then
                        local retryPrompt = findClosestGiverPrompt(cachedGiverPos)
                        if retryPrompt then bypassAndTriggerPrompt(retryPrompt) end
                    end
                    task.wait(0.5)
                    waitTime += 0.5
                end
                
                if pickupSuccess then
                    consecutiveFails = 0
                    infoLabel.Text = "✅ Pedido recibido. Buscando NPC..."
                    infoLabel.TextColor3 = Color3.fromRGB(0, 255, 150)
                else
                    consecutiveFails += 1
                    infoLabel.Text = string.format("⚠️ Timeout recogiendo (%d/%d)", consecutiveFails, MAX_CONSECUTIVE_FAILS)
                    infoLabel.TextColor3 = Color3.fromRGB(255, 150, 0)
                    if consecutiveFails >= MAX_CONSECUTIVE_FAILS then
                        infoLabel.Text = "❌ Demasiados fallos. Pausando..."
                        infoLabel.TextColor3 = Color3.fromRGB(255, 80, 80)
                        task.wait(FAIL_COOLDOWN)
                        consecutiveFails = 0
                    end
                    task.wait(2)
                    continue
                end
            else
                infoLabel.Text = "⚠️ Giver no cargó a tiempo. Reintentando..."
                infoLabel.TextColor3 = Color3.fromRGB(255, 150, 0)
                task.wait(2)
                continue
            end
        else
            infoLabel.Text = "🚚 Esperando spawn del NPC..."
            infoLabel.TextColor3 = Color3.fromRGB(0, 162, 255)
            
            local npcPos, npcModel = nil, nil
            local spawnWait = 0
            while spawnWait < NPC_SPAWN_WAIT and autoJobEnabled do
                npcPos, npcModel = getDeliveryTarget()
                if npcPos and npcModel then break end
                task.wait(0.5)
                spawnWait += 0.5
            end
            
            if npcPos and npcModel then
                infoLabel.Text = string.format("📍 NPC detectado en:\nX:%.1f Y:%.1f Z:%.1f", npcPos.X, npcPos.Y, npcPos.Z)
                infoLabel.TextColor3 = Color3.fromRGB(0, 255, 150)
                
                smoothTeleport(npcPos)
                task.wait(0.4) -- Breve espera para streaming del NPC
                
                local npcPrompt = npcModel:FindFirstChild("HumanoidRootPart")
                if npcPrompt then npcPrompt = npcPrompt:FindFirstChildWhichIsA("ProximityPrompt") end
                
                if npcPrompt then
                    bypassAndTriggerPrompt(npcPrompt)
                    
                    infoLabel.Text = "⏳ Completando entrega..."
                    infoLabel.TextColor3 = Color3.fromRGB(150, 200, 255)
                    
                    local waitTime = 0
                    local deliverySuccess = false
                    while waitTime < DELIVERY_TIMEOUT and autoJobEnabled do
                        if not hasChicken() then deliverySuccess = true; break end
                        if waitTime > 0 and math.floor(waitTime) % RETRY_TRIGGER_EVERY == 0 then
                            local retryHrp = npcModel:FindFirstChild("HumanoidRootPart")
                            if retryHrp then
                                local retryPrompt = retryHrp:FindFirstChildWhichIsA("ProximityPrompt")
                                if retryPrompt then bypassAndTriggerPrompt(retryPrompt) end
                            end
                        end
                        task.wait(0.5)
                        waitTime += 0.5
                    end
                    
                    if deliverySuccess then
                        consecutiveFails = 0
                        infoLabel.Text = "✅ ¡Entrega exitosa! Repitiendo ciclo..."
                        infoLabel.TextColor3 = Color3.fromRGB(0, 255, 150)
                    else
                        consecutiveFails += 1
                        infoLabel.Text = string.format("⚠️ Timeout entregando (%d/%d)", consecutiveFails, MAX_CONSECUTIVE_FAILS)
                        infoLabel.TextColor3 = Color3.fromRGB(255, 150, 0)
                        if consecutiveFails >= MAX_CONSECUTIVE_FAILS then
                            infoLabel.Text = "❌ Demasiados fallos. Pausando..."
                            infoLabel.TextColor3 = Color3.fromRGB(255, 80, 80)
                            task.wait(FAIL_COOLDOWN)
                            consecutiveFails = 0
                        end
                        task.wait(2)
                    end
                else
                    infoLabel.Text = "⚠️ Prompt del NPC no cargó. Reintentando..."
                    infoLabel.TextColor3 = Color3.fromRGB(255, 150, 0)
                    consecutiveFails += 1
                    task.wait(2)
                end
            else
                infoLabel.Text = "❌ NPC no spawneó a tiempo. Reintentando..."
                infoLabel.TextColor3 = Color3.fromRGB(255, 80, 80)
                consecutiveFails += 1
                task.wait(2)
            end
        end
        task.wait(1)
    end
    infoLabel.Text = "⏸️ Sistema detenido."
    infoLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
end

-- ==========================================
-- 6. TOGGLE
-- ==========================================
btnToggle.MouseButton1Click:Connect(function()
    autoJobEnabled = not autoJobEnabled
    btnToggle.Text = autoJobEnabled and "🔴 DESACTIVAR AUTO-JOB" or "🟢 ACTIVAR AUTO-JOB"
    btnToggle.BackgroundColor3 = autoJobEnabled and Color3.fromRGB(120, 20, 20) or Color3.fromRGB(20, 100, 40)
    
    if autoJobEnabled then
        infoLabel.Text = "🤖 Sistema activado. Iniciando ciclo..."
        infoLabel.TextColor3 = Color3.fromRGB(0, 255, 150)
        consecutiveFails = 0
        if not jobThread or coroutine.status(jobThread) == "dead" then
            jobThread = task.spawn(runAutoJob)
        end
    else
        infoLabel.Text = "⏸️ Deteniendo sistema..."
        infoLabel.TextColor3 = Color3.fromRGB(255, 200, 0)
    end
end)

infoLabel.Text = "Sistema listo.\nPresiona ACTIVAR para iniciar."