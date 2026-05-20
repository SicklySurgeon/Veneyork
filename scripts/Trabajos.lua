-- ==========================================
-- AUTO-JOB DELIVERY SYSTEM + PANEL HORIZONTAL (v4 DUAL-GIVER FIX) + ANTI-AFK
-- ==========================================
local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")

local player = Players.LocalPlayer

-- ⚙️ CONFIGURACIÓN DINÁMICA
local moveSpeed = 75               -- Slider: 10 - 150 (Default: 25)
local maxAntiLoopAttempts = 3       -- Slider: 1 - 5
local noclipEnabled = true          -- Toggle: ON por defecto
local promptCooldownEnabled = true  -- Toggle: ON por defecto
local antiAfkEnabled = true         -- Toggle: ON por defecto

local PICKUP_TIMEOUT = 12
local DELIVERY_TIMEOUT = 12
local RETRY_TRIGGER_EVERY = 3
local FAIL_COOLDOWN = 5
local NPC_SPAWN_WAIT = 6

local GIVER_HARDCODED_POS = Vector3.new(151.902512, 40.724411, 512.531128)

-- 🔒 SISTEMA DE BLOQUEO DE GIVER
local lockedGiverPos = GIVER_HARDCODED_POS
local lockedGiverPrompt = nil

local autoJobEnabled = false
local systemPaused = false
local jobThread = nil
local consecutiveFails = 0
local promptFailCount = 0

-- ==========================================
-- 1. GUI HORIZONTAL (PANEL)
-- ==========================================
local existingGui = CoreGui:FindFirstChild("AutoJob_Panel")
if existingGui then existingGui:Destroy() end

local screenGui = Instance.new("ScreenGui", CoreGui)
screenGui.Name = "AutoJob_Panel"
screenGui.ResetOnSpawn = false

local main = Instance.new("Frame", screenGui)
main.Name = "MainPanel"
main.Size = UDim2.new(0, 680, 0, 175)
main.Position = UDim2.new(0.5, -340, 0, 15)
main.BackgroundColor3 = Color3.fromRGB(12, 12, 15)
main.BorderSizePixel = 0
main.Active = true
main.Draggable = true
Instance.new("UICorner", main).CornerRadius = UDim.new(0, 10)
local uiStroke = Instance.new("UIStroke", main)
uiStroke.Color = Color3.fromRGB(0, 162, 255)
uiStroke.Thickness = 1.5

local title = Instance.new("TextLabel", main)
title.Size = UDim2.new(1, 0, 0, 35)
title.Text = "📦 AUTO DELIVERY PANEL"
title.TextColor3 = Color3.fromRGB(0, 162, 255)
title.BackgroundColor3 = Color3.fromRGB(18, 18, 22)
title.Font = Enum.Font.GothamBold
title.TextSize = 15
Instance.new("UICorner", title).CornerRadius = UDim.new(0, 10)

local content = Instance.new("Frame", main)
content.Size = UDim2.new(1, -20, 0, 130)
content.Position = UDim2.new(0, 10, 0, 40)
content.BackgroundTransparency = 1

-- ==========================================
-- HELPERS UI
-- ==========================================
local function createBtn(parent, name, text, pos, size, color)
    local b = Instance.new("TextButton", parent)
    b.Name = name
    b.Size = size or UDim2.new(0, 130, 0, 32)
    b.Position = pos
    b.Text = text
    b.BackgroundColor3 = color
    b.TextColor3 = Color3.new(1, 1, 1)
    b.Font = Enum.Font.GothamBold
    b.TextSize = 12
    Instance.new("UICorner", b).CornerRadius = UDim.new(0, 6)
    return b
end

local function createToggle(parent, name, default, pos)
    local btn = createBtn(parent, name, default and "✅ "..name:upper() or "❌ "..name:upper(), pos, UDim2.new(0, 150, 0, 32), default and Color3.fromRGB(20, 100, 40) or Color3.fromRGB(100, 30, 30))
    local state = default
    local callback = nil
    btn.MouseButton1Click:Connect(function()
        state = not state
        btn.Text = state and "✅ "..name:upper() or "❌ "..name:upper()
        btn.BackgroundColor3 = state and Color3.fromRGB(20, 100, 40) or Color3.fromRGB(100, 30, 30)
        if callback then callback(state) end
    end)
    return {Button = btn, State = function() return state end, SetCallback = function(cb) callback = cb end}
end

local function createSlider(parent, name, min, max, default, pos)
    local frame = Instance.new("Frame", parent)
    frame.Name = name.."_Slider"
    frame.Size = UDim2.new(0, 240, 0, 48)
    frame.Position = pos
    frame.BackgroundTransparency = 1

    local lbl = Instance.new("TextLabel", frame)
    lbl.Size = UDim2.new(1,0,0,16)
    lbl.Text = name..": "..default
    lbl.TextColor3 = Color3.fromRGB(200,200,200)
    lbl.Font = Enum.Font.GothamBold
    lbl.TextSize = 12
    lbl.BackgroundTransparency = 1

    local track = Instance.new("Frame", frame)
    track.Size = UDim2.new(1,-10,0,6)
    track.Position = UDim2.new(0,5,0,22)
    track.BackgroundColor3 = Color3.fromRGB(45,45,50)
    Instance.new("UICorner", track).CornerRadius = UDim.new(0,3)

    local fill = Instance.new("Frame", track)
    fill.Size = UDim2.new((default-min)/(max-min), 0, 1, 0)
    fill.BackgroundColor3 = Color3.fromRGB(0,162,255)
    Instance.new("UICorner", fill).CornerRadius = UDim.new(0,3)

    local handle = Instance.new("TextButton", track)
    handle.Size = UDim2.new(0,12,0,12)
    handle.Position = UDim2.new((default-min)/(max-min), -6, 0.5, -6)
    handle.BackgroundColor3 = Color3.fromRGB(255,255,255)
    Instance.new("UICorner", handle).CornerRadius = UDim.new(1,0)
    handle.Text = ""
    handle.AutoButtonColor = false

    local val = default
    local dragging = false
    local cb = nil
    handle.MouseButton1Down:Connect(function() dragging = true end)
    UIS.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end end)
    UIS.InputChanged:Connect(function(i)
        if dragging and i.UserInputType == Enum.UserInputType.MouseMovement then
            local absX = track.AbsolutePosition.X
            local absW = track.AbsoluteSize.X
            local rel = math.clamp((i.Position.X - absX) / absW, 0, 1)
            val = math.floor(min + rel * (max - min))
            fill.Size = UDim2.new(rel, 0, 1, 0)
            handle.Position = UDim2.new(rel, -6, 0.5, -6)
            lbl.Text = name..": "..val
            if cb then cb(val) end
        end
    end)
    return {GetValue = function() return val end, SetCallback = function(f) cb = f end, Frame = frame}
end

-- ==========================================
-- 2. CONSTRUCCIÓN DE CONTROLES
-- ==========================================
local btnToggle = createBtn(content, "BtnToggle", "🟢 ACTIVAR AUTO-JOB", UDim2.new(0, 0, 0, 0), UDim2.new(0, 160, 0, 32), Color3.fromRGB(20, 100, 40))
local btnHide   = createBtn(content, "BtnHide", "📉 MINIMIZAR", UDim2.new(0, 170, 0, 0), UDim2.new(0, 110, 0, 32), Color3.fromRGB(30, 30, 35))
local btnClose  = createBtn(content, "BtnClose", "❌ CERRAR", UDim2.new(0, 290, 0, 0), UDim2.new(0, 90, 0, 32), Color3.fromRGB(120, 20, 20))

-- ✅ LÍNEA CORREGIDA AQUÍ
local sliderSpeed = createSlider(content, "Velocidad (Studs)", 10, 150, 25, UDim2.new(0, 0, 0, 40))
local sliderAnti  = createSlider(content, "Intentos Anti-Bucle", 1, 5, 3, UDim2.new(0, 250, 0, 40))

local toggleNoclip   = createToggle(content, "Noclip", true, UDim2.new(0, 500, 0, 0))
local toggleCooldown = createToggle(content, "Prompt Cooldown", true, UDim2.new(0, 500, 0, 40))
local toggleAntiAfk  = createToggle(content, "Anti-AFK", true, UDim2.new(0, 350, 0, 80))

local infoLabel = Instance.new("TextLabel", content)
infoLabel.Size = UDim2.new(1, 0, 0, 35)
infoLabel.Position = UDim2.new(0, 0, 0, 100)
infoLabel.BackgroundColor3 = Color3.fromRGB(18, 18, 22)
infoLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
infoLabel.Font = Enum.Font.GothamBold
infoLabel.TextSize = 12
infoLabel.TextWrapped = true
infoLabel.TextYAlignment = "Top"
infoLabel.TextXAlignment = "Left"
Instance.new("UICorner", infoLabel).CornerRadius = UDim.new(0, 6)
infoLabel.Text = "Sistema en espera. Presiona ACTIVAR para iniciar."

local openBtn = Instance.new("TextButton", screenGui)
openBtn.Size = UDim2.new(0, 130, 0, 36)
openBtn.Position = UDim2.new(0.5, -65, 0, 15)
openBtn.Text = "📦 ABRIR PANEL"
openBtn.BackgroundColor3 = Color3.fromRGB(0, 162, 255)
openBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
openBtn.Font = Enum.Font.GothamBold
openBtn.TextSize = 13
openBtn.Visible = false
Instance.new("UICorner", openBtn).CornerRadius = UDim.new(0, 8)
Instance.new("UIStroke", openBtn).Thickness = 1.5

btnHide.MouseButton1Click:Connect(function() main.Visible = false; openBtn.Visible = true end)
openBtn.MouseButton1Click:Connect(function() main.Visible = true; openBtn.Visible = false end)
btnClose.MouseButton1Click:Connect(function() screenGui:Destroy() end)

-- ==========================================
-- 3. SISTEMAS CORE
-- ==========================================
local noclipConn
local function updateNoclip()
    if noclipConn then noclipConn:Disconnect(); noclipConn = nil end
    if noclipEnabled then
        noclipConn = RunService.Stepped:Connect(function()
            if player.Character then
                for _, part in ipairs(player.Character:GetDescendants()) do
                    if part:IsA("BasePart") then part.CanCollide = false end
                end
            end
        end)
    end
end
updateNoclip()

local function runAntiAfk()
    while antiAfkEnabled do
        task.wait(600 + math.random(-30, 30))
        local char = player.Character
        if char and char:FindFirstChild("Humanoid") and char:FindFirstChild("HumanoidRootPart") then
            char.Humanoid.Jump = true
            task.wait(0.1)
            char.Humanoid.Jump = false
        end
    end
end
task.spawn(runAntiAfk)

-- ✅ TELEPORT ROBUSTO (CORREGIDO: Anti-Rubberband y Distancia Real)
local function smoothTeleport(targetPos)
    local char = player.Character
    if not char then return false end
    local root = char:FindFirstChild("HumanoidRootPart")
    local hum = char:FindFirstChild("Humanoid")
    if not root or not hum then return false end

    if (root.Position - targetPos).Magnitude < 3 then return true end

    -- Desactivar físicas que pelean con el teleport
    local oldWalkSpeed = hum.WalkSpeed
    local oldAutoRotate = hum.AutoRotate
    hum.WalkSpeed = 0
    hum.AutoRotate = false

    local step = math.clamp(moveSpeed, 10, 150)
    local maxAttempts = 200 -- Evita bucles infinitos si el servidor bloquea el movimiento

    local attempts = 0
    -- Bucle basado en distancia REAL, no en matemáticas acumulativas
    while (root.Position - targetPos).Magnitude > 3 and attempts < maxAttempts do
        if not player.Character or not player.Character:FindFirstChild("HumanoidRootPart") then 
            break 
        end
        
        root = player.Character.HumanoidRootPart
        local currentPos = root.Position
        local distToTarget = (targetPos - currentPos).Magnitude
        local dir = (targetPos - currentPos).Unit
        
        local move = math.min(step, distToTarget)
        local newCFrame = CFrame.new(currentPos + (dir * move))
        
        -- PivotTo es mucho más estable que modificar CFrame directamente
        player.Character:PivotTo(newCFrame)
        
        -- Limpiar velocidades en CADA paso para evitar que el servidor detecte "caída"
        root.AssemblyLinearVelocity = Vector3.zero
        root.AssemblyAngularVelocity = Vector3.zero
        
        attempts += 1
        task.wait() -- 1 frame (más suave y sincronizado que 0.02)
    end

    -- Restaurar físicas
    if hum and hum.Parent then
        hum.WalkSpeed = oldWalkSpeed
        hum.AutoRotate = oldAutoRotate
    end

    -- Posición final exacta
    if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
        local finalRoot = player.Character.HumanoidRootPart
        player.Character:PivotTo(CFrame.new(targetPos))
        finalRoot.AssemblyLinearVelocity = Vector3.zero
        finalRoot.AssemblyAngularVelocity = Vector3.zero
    end

    -- Pausa de sincronización
    task.wait(0.2)

    local finalRoot = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
    if finalRoot then
        local dist = (finalRoot.Position - targetPos).Magnitude
        -- Corrección de rubberband leve
        if dist > 5 and dist < 30 then
            player.Character:PivotTo(CFrame.new(targetPos))
            task.wait(0.1)
            dist = (player.Character.HumanoidRootPart.Position - targetPos).Magnitude
        end
        
        -- Margen más permisivo (el servidor a veces te mueve verticalmente al suelo)
        if dist > 20 then
            return false
        end
    end
    return true
end

-- 🔒 DETECCIÓN INTELIGENTE DE GIVER
local function getValidGiverPrompt()
    if lockedGiverPrompt and lockedGiverPrompt:IsA("ProximityPrompt") and lockedGiverPrompt.Parent then
        local root = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
        if root and (lockedGiverPrompt.Parent.Position - root.Position).Magnitude < 12 then
            return lockedGiverPrompt
        end
        lockedGiverPrompt = nil
    end

    local root = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
    if not root then return nil end

    local works = Workspace:FindFirstChild("Works")
    if not works then return nil end
    local p = works:FindFirstChild("Arturos")
    if p then p = p:FindFirstChild("Delivery") end
    if p then p = p:FindFirstChild("Giver") end
    if not p then return nil end

    local closest, minDist = nil, math.huge
    for _, d in ipairs(p:GetDescendants()) do
        if d:IsA("ProximityPrompt") and d.Parent:IsA("BasePart") then
            local dist = (d.Parent.Position - root.Position).Magnitude
            if dist < minDist then
                minDist = dist
                closest = d
            end
        end
    end

    if closest and minDist < 10 then
        lockedGiverPrompt = closest
        lockedGiverPos = closest.Parent.Position
        return closest
    end
    return nil
end

local function bypassAndTriggerPrompt(prompt)
    if not prompt or not prompt:IsA("ProximityPrompt") then return false end
    prompt.HoldDuration = 0
    prompt.MaxActivationDistance = math.huge
    prompt.Enabled = true
    if promptCooldownEnabled then task.wait(0.02) end

    if fireproximityprompt then
        fireproximityprompt(prompt)
    else
        prompt:InputHoldBegin()
        if promptCooldownEnabled then task.wait(0.02) end
        prompt:InputHoldEnd()
    end
    return true
end

local function hasChicken()
    local char = player.Character
    if not char then return false end
    return char:FindFirstChild("Fried Chicken") or player.Backpack:FindFirstChild("Fried Chicken")
end

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
-- 4. SISTEMA ANTI-BUCLE
-- ==========================================
local function triggerAntiLoopReset()
    systemPaused = true
    infoLabel.Text = "🔄 Anti-bucle activado. Regenerando..."
    infoLabel.TextColor3 = Color3.fromRGB(255, 165, 0)
    task.wait(0.3)

    pcall(function()
        if player.Character and player.Character:FindFirstChild("Humanoid") then
            player.Character.Humanoid.Health = 0
        end
    end)
    task.wait(0.2)
    pcall(function() player:LoadCharacter() end)

    local waitTime = 0
    repeat
        task.wait(0.2)
        waitTime += 0.2
        if waitTime > 8 then
            infoLabel.Text = "⚠️ Timeout respawn. Reanudando..."
            infoLabel.TextColor3 = Color3.fromRGB(255, 150, 0)
            systemPaused = false
            promptFailCount = 0
            lockedGiverPrompt = nil
            return
        end
    until player.Character and player.Character:FindFirstChild("HumanoidRootPart")

    task.wait(1.2)
    promptFailCount = 0
    lockedGiverPrompt = nil
    systemPaused = false
    infoLabel.Text = "✅ Personaje regenerado. Reanudando..."
    infoLabel.TextColor3 = Color3.fromRGB(0, 255, 150)

    if not jobThread or coroutine.status(jobThread) == "dead" then
        jobThread = task.spawn(runAutoJob)
    end
end

-- ==========================================
-- 5. CICLO PRINCIPAL
-- ==========================================
function runAutoJob()
    while autoJobEnabled do
        if systemPaused then task.wait(0.5); continue end
        
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
            
            if not smoothTeleport(lockedGiverPos) then
                infoLabel.Text = "⚠️ Teleport fallido. Reintentando..."
                infoLabel.TextColor3 = Color3.fromRGB(255, 150, 0)
                task.wait(1)
                continue
            end
            
            local giverPrompt = getValidGiverPrompt()
            if not giverPrompt then
                promptFailCount += 1
                infoLabel.Text = string.format("⚠️ Giver no detectado (%d/%d)", promptFailCount, maxAntiLoopAttempts)
                infoLabel.TextColor3 = Color3.fromRGB(255, 150, 0)
                if promptFailCount >= maxAntiLoopAttempts then triggerAntiLoopReset() end
                task.wait(1.5)
                continue
            end
            
            local promptPart = giverPrompt.Parent
            if (root.Position - promptPart.Position).Magnitude > 4 then
                smoothTeleport(promptPart.Position)
                lockedGiverPos = promptPart.Position
            end
            
            bypassAndTriggerPrompt(giverPrompt)
            promptFailCount = 0
            
            infoLabel.Text = "⏳ Esperando pedido..."
            infoLabel.TextColor3 = Color3.fromRGB(150, 200, 255)
            
            local waitTime = 0
            local pickupSuccess = false
            while waitTime < PICKUP_TIMEOUT and autoJobEnabled and not systemPaused do
                if hasChicken() then pickupSuccess = true; break end
                if waitTime > 0 and math.floor(waitTime) % RETRY_TRIGGER_EVERY == 0 then
                    if lockedGiverPrompt and lockedGiverPrompt:IsA("ProximityPrompt") then
                        bypassAndTriggerPrompt(lockedGiverPrompt)
                    end
                end
                task.wait(promptCooldownEnabled and 0.5 or 0.1)
                waitTime += 0.5
            end
            
            if pickupSuccess then
                consecutiveFails = 0
                infoLabel.Text = "✅ Pedido recibido. Buscando NPC..."
                infoLabel.TextColor3 = Color3.fromRGB(0, 255, 150)
            else
                consecutiveFails += 1
                infoLabel.Text = string.format("⚠️ Timeout recogiendo (%d/3)", consecutiveFails)
                infoLabel.TextColor3 = Color3.fromRGB(255, 150, 0)
                if consecutiveFails >= 3 then
                    infoLabel.Text = "❌ Pausa por fallos..."
                    infoLabel.TextColor3 = Color3.fromRGB(255, 80, 80)
                    task.wait(FAIL_COOLDOWN)
                    consecutiveFails = 0
                    lockedGiverPrompt = nil
                end
                task.wait(1)
                continue
            end
        else
            infoLabel.Text = "🚚 Esperando spawn del NPC..."
            infoLabel.TextColor3 = Color3.fromRGB(0, 162, 255)
            
            local npcPos, npcModel = nil, nil
            local spawnWait = 0
            while spawnWait < NPC_SPAWN_WAIT and autoJobEnabled and not systemPaused do
                npcPos, npcModel = getDeliveryTarget()
                if npcPos and npcModel then break end
                task.wait(0.5)
                spawnWait += 0.5
            end
            
            if npcPos and npcModel then
                infoLabel.Text = string.format("📍 NPC detectado: %.1f, %.1f, %.1f", npcPos.X, npcPos.Y, npcPos.Z)
                infoLabel.TextColor3 = Color3.fromRGB(0, 255, 150)
                
                if not smoothTeleport(npcPos) then
                    infoLabel.Text = "⚠️ Teleport al NPC fallido. Reintentando..."
                    infoLabel.TextColor3 = Color3.fromRGB(255, 150, 0)
                    task.wait(1)
                    continue
                end
                task.wait(promptCooldownEnabled and 0.3 or 0.05)
                
                local hrp = npcModel:FindFirstChild("HumanoidRootPart")
                local npcPrompt = hrp and hrp:FindFirstChildWhichIsA("ProximityPrompt")
                
                if npcPrompt then
                    bypassAndTriggerPrompt(npcPrompt)
                    promptFailCount = 0
                    
                    infoLabel.Text = "⏳ Completando entrega..."
                    infoLabel.TextColor3 = Color3.fromRGB(150, 200, 255)
                    
                    local waitTime = 0
                    local deliverySuccess = false
                    while waitTime < DELIVERY_TIMEOUT and autoJobEnabled and not systemPaused do
                        if not hasChicken() then deliverySuccess = true; break end
                        if waitTime > 0 and math.floor(waitTime) % RETRY_TRIGGER_EVERY == 0 then
                            local rHrp = npcModel:FindFirstChild("HumanoidRootPart")
                            if rHrp then
                                local rPrompt = rHrp:FindFirstChildWhichIsA("ProximityPrompt")
                                if rPrompt then bypassAndTriggerPrompt(rPrompt) end
                            end
                        end
                        task.wait(promptCooldownEnabled and 0.5 or 0.1)
                        waitTime += 0.5
                    end
                    
                    if deliverySuccess then
                        consecutiveFails = 0
                        infoLabel.Text = "✅ ¡Entrega exitosa! Repitiendo..."
                        infoLabel.TextColor3 = Color3.fromRGB(0, 255, 150)
                    else
                        consecutiveFails += 1
                        infoLabel.Text = string.format("⚠️ Timeout entrega (%d/3)", consecutiveFails)
                        infoLabel.TextColor3 = Color3.fromRGB(255, 150, 0)
                        if consecutiveFails >= 3 then
                            infoLabel.Text = "❌ Pausa por fallos..."
                            infoLabel.TextColor3 = Color3.fromRGB(255, 80, 80)
                            task.wait(FAIL_COOLDOWN)
                            consecutiveFails = 0
                        end
                        task.wait(1)
                    end
                else
                    promptFailCount += 1
                    infoLabel.Text = string.format("⚠️ Prompt NPC no detectado (%d/%d)", promptFailCount, maxAntiLoopAttempts)
                    infoLabel.TextColor3 = Color3.fromRGB(255, 150, 0)
                    if promptFailCount >= maxAntiLoopAttempts then triggerAntiLoopReset() end
                    task.wait(1.5)
                end
            else
                infoLabel.Text = "❌ NPC no spawneó. Reintentando..."
                infoLabel.TextColor3 = Color3.fromRGB(255, 80, 80)
                task.wait(2)
            end
        end
        task.wait(promptCooldownEnabled and 1 or 0.2)
    end
    infoLabel.Text = "⏸️ Sistema detenido."
    infoLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
end

-- ==========================================
-- 6. CONEXIONES UI
-- ==========================================
btnToggle.MouseButton1Click:Connect(function()
    autoJobEnabled = not autoJobEnabled
    btnToggle.Text = autoJobEnabled and "🔴 DESACTIVAR AUTO-JOB" or "🟢 ACTIVAR AUTO-JOB"
    btnToggle.BackgroundColor3 = autoJobEnabled and Color3.fromRGB(120, 20, 20) or Color3.fromRGB(20, 100, 40)
    
    if autoJobEnabled then
        infoLabel.Text = "🤖 Sistema activado. Iniciando ciclo..."
        infoLabel.TextColor3 = Color3.fromRGB(0, 255, 150)
        consecutiveFails = 0
        promptFailCount = 0
        systemPaused = false
        lockedGiverPrompt = nil
        if not jobThread or coroutine.status(jobThread) == "dead" then
            jobThread = task.spawn(runAutoJob)
        end
    else
        infoLabel.Text = "⏸️ Deteniendo sistema..."
        infoLabel.TextColor3 = Color3.fromRGB(255, 200, 0)
    end
end)

sliderSpeed.SetCallback(function(v) moveSpeed = v end)
sliderAnti.SetCallback(function(v) maxAntiLoopAttempts = v end)
toggleNoclip.SetCallback(function(v) noclipEnabled = v; updateNoclip() end)
toggleCooldown.SetCallback(function(v) promptCooldownEnabled = v end)
toggleAntiAfk.SetCallback(function(v) antiAfkEnabled = v end)

infoLabel.Text = "Sistema listo. Presiona ACTIVAR para iniciar."