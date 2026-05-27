-- ==========================================
-- AUTO-JOB DELIVERY SYSTEM + PANEL HORIZONTAL
-- v12 ULTRA-STABLE + FPS FIX + ZERO LEAKS
-- ==========================================
local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")

local player = Players.LocalPlayer

-- ⚙️ CONFIGURACIÓN DINÁMICA
local moveSpeed = 500
local maxAntiLoopAttempts = 3
local noclipEnabled = true
local promptCooldownEnabled = true
local antiAfkEnabled = true

-- SLIDERS DE TIEMPO (segundos)
local waitOnArrival = 0.15
local waitAfterPrompt = 0.30
local waitBetweenNpcs = 0.30

local RETRY_PROMPT_INTERVAL = 1.5

local PICKUP_TIMEOUT = 8
local DELIVERY_TIMEOUT = 8
local FAIL_COOLDOWN = 5
local NPC_SPAWN_WAIT = 6

local GIVER_HARDCODED_POS = Vector3.new(151.902512, 40.724411, 512.531128)

local lockedGiverPos = GIVER_HARDCODED_POS
local lockedGiverPrompt = nil

local autoJobEnabled = false
local systemPaused = false
local jobThread = nil
local consecutiveFails = 0
local promptFailCount = 0
local currentCycleId = 0 -- 🆕 Sistema para matar hilos viejos

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
main.Size = UDim2.new(0, 720, 0, 245)
main.Position = UDim2.new(0.5, -360, 0, 15)
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
content.Size = UDim2.new(1, -20, 0, 200)
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
    frame.Size = UDim2.new(0, 220, 0, 56)
    frame.Position = pos
    frame.BackgroundTransparency = 1

    local lbl = Instance.new("TextLabel", frame)
    lbl.Size = UDim2.new(1, 0, 0, 18)
    lbl.Text = name..": "..default
    lbl.TextColor3 = Color3.fromRGB(200, 200, 200)
    lbl.Font = Enum.Font.GothamBold
    lbl.TextSize = 12
    lbl.BackgroundTransparency = 1
    lbl.TextXAlignment = Enum.TextXAlignment.Left

    local touchZone = Instance.new("TextButton", frame)
    touchZone.Name = "TouchZone"
    touchZone.Size = UDim2.new(1, 0, 0, 36)
    touchZone.Position = UDim2.new(0, 0, 0, 18)
    touchZone.BackgroundTransparency = 1
    touchZone.Text = ""
    touchZone.AutoButtonColor = false
    touchZone.Active = true

    local track = Instance.new("Frame", touchZone)
    track.Name = "Track"
    track.Size = UDim2.new(1, -20, 0, 8)
    track.Position = UDim2.new(0, 10, 0.5, -4)
    track.BackgroundColor3 = Color3.fromRGB(45, 45, 50)
    track.Active = false
    Instance.new("UICorner", track).CornerRadius = UDim.new(0, 4)

    local fill = Instance.new("Frame", track)
    fill.Name = "Fill"
    fill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
    fill.BackgroundColor3 = Color3.fromRGB(0, 162, 255)
    fill.Active = false
    Instance.new("UICorner", fill).CornerRadius = UDim.new(0, 4)

    local handle = Instance.new("Frame", track)
    handle.Name = "Handle"
    handle.Size = UDim2.new(0, 22, 0, 22)
    handle.Position = UDim2.new((default - min) / (max - min), -11, 0.5, -11)
    handle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    handle.Active = false
    Instance.new("UICorner", handle).CornerRadius = UDim.new(1, 0)
    local hStroke = Instance.new("UIStroke", handle)
    hStroke.Color = Color3.fromRGB(0, 162, 255)
    hStroke.Thickness = 2

    local val = default
    local dragging = false
    local cb = nil

    local function updateFromX(absX)
        local trackAbsX = track.AbsolutePosition.X
        local trackAbsW = track.AbsoluteSize.X
        if trackAbsW <= 0 then return end
        local rel = math.clamp((absX - trackAbsX) / trackAbsW, 0, 1)
        val = math.floor(min + rel * (max - min) + 0.5)
        fill.Size = UDim2.new(rel, 0, 1, 0)
        handle.Position = UDim2.new(rel, -11, 0.5, -11)
        lbl.Text = name..": "..val
        if cb then cb(val) end
    end

    local function isRelevantInput(i)
        return i.UserInputType == Enum.UserInputType.MouseButton1
            or i.UserInputType == Enum.UserInputType.Touch
    end

    touchZone.InputBegan:Connect(function(i, processed)
        if processed then return end
        if isRelevantInput(i) then
            dragging = true
            updateFromX(i.Position.X)
        end
    end)

    UIS.InputChanged:Connect(function(i)
        if not dragging then return end
        if i.UserInputType == Enum.UserInputType.MouseMovement
        or i.UserInputType == Enum.UserInputType.Touch then
            updateFromX(i.Position.X)
        end
    end)

    UIS.InputEnded:Connect(function(i)
        if isRelevantInput(i) then
            dragging = false
        end
    end)

    return {
        GetValue = function() return val end,
        SetCallback = function(f) cb = f end,
        Frame = frame,
    }
end

local function createSliderFloat(parent, name, min, max, default, step, pos)
    step = step or 0.05
    local frame = Instance.new("Frame", parent)
    frame.Name = name.."_Slider"
    frame.Size = UDim2.new(0, 220, 0, 56)
    frame.Position = pos
    frame.BackgroundTransparency = 1

    local lbl = Instance.new("TextLabel", frame)
    lbl.Size = UDim2.new(1, 0, 0, 18)
    lbl.Text = name..": "..string.format("%.2fs", default)
    lbl.TextColor3 = Color3.fromRGB(200, 200, 200)
    lbl.Font = Enum.Font.GothamBold
    lbl.TextSize = 12
    lbl.BackgroundTransparency = 1
    lbl.TextXAlignment = Enum.TextXAlignment.Left

    local touchZone = Instance.new("TextButton", frame)
    touchZone.Name = "TouchZone"
    touchZone.Size = UDim2.new(1, 0, 0, 36)
    touchZone.Position = UDim2.new(0, 0, 0, 18)
    touchZone.BackgroundTransparency = 1
    touchZone.Text = ""
    touchZone.AutoButtonColor = false
    touchZone.Active = true

    local track = Instance.new("Frame", touchZone)
    track.Name = "Track"
    track.Size = UDim2.new(1, -20, 0, 8)
    track.Position = UDim2.new(0, 10, 0.5, -4)
    track.BackgroundColor3 = Color3.fromRGB(45, 45, 50)
    track.Active = false
    Instance.new("UICorner", track).CornerRadius = UDim.new(0, 4)

    local fill = Instance.new("Frame", track)
    fill.Name = "Fill"
    fill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
    fill.BackgroundColor3 = Color3.fromRGB(255, 140, 0)
    fill.Active = false
    Instance.new("UICorner", fill).CornerRadius = UDim.new(0, 4)

    local handle = Instance.new("Frame", track)
    handle.Name = "Handle"
    handle.Size = UDim2.new(0, 22, 0, 22)
    handle.Position = UDim2.new((default - min) / (max - min), -11, 0.5, -11)
    handle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    handle.Active = false
    Instance.new("UICorner", handle).CornerRadius = UDim.new(1, 0)
    local hStroke = Instance.new("UIStroke", handle)
    hStroke.Color = Color3.fromRGB(255, 140, 0)
    hStroke.Thickness = 2

    local val = default
    local dragging = false
    local cb = nil

    local function updateFromX(absX)
        local trackAbsX = track.AbsolutePosition.X
        local trackAbsW = track.AbsoluteSize.X
        if trackAbsW <= 0 then return end
        local rel = math.clamp((absX - trackAbsX) / trackAbsW, 0, 1)
        local raw = min + rel * (max - min)
        val = math.floor(raw / step + 0.5) * step
        val = math.clamp(val, min, max)
        local newRel = (val - min) / (max - min)
        fill.Size = UDim2.new(newRel, 0, 1, 0)
        handle.Position = UDim2.new(newRel, -11, 0.5, -11)
        lbl.Text = name..": "..string.format("%.2fs", val)
        if cb then cb(val) end
    end

    local function isRelevantInput(i)
        return i.UserInputType == Enum.UserInputType.MouseButton1
            or i.UserInputType == Enum.UserInputType.Touch
    end

    touchZone.InputBegan:Connect(function(i, processed)
        if processed then return end
        if isRelevantInput(i) then
            dragging = true
            updateFromX(i.Position.X)
        end
    end)

    UIS.InputChanged:Connect(function(i)
        if not dragging then return end
        if i.UserInputType == Enum.UserInputType.MouseMovement
        or i.UserInputType == Enum.UserInputType.Touch then
            updateFromX(i.Position.X)
        end
    end)

    UIS.InputEnded:Connect(function(i)
        if isRelevantInput(i) then
            dragging = false
        end
    end)

    return {
        GetValue = function() return val end,
        SetCallback = function(f) cb = f end,
        Frame = frame,
    }
end

-- ==========================================
-- 2. CONSTRUCCIÓN DE CONTROLES
-- ==========================================
local btnToggle = createBtn(content, "BtnToggle", "🟢 ACTIVAR AUTO-JOB", UDim2.new(0, 0, 0, 0), UDim2.new(0, 160, 0, 32), Color3.fromRGB(20, 100, 40))
local btnHide   = createBtn(content, "BtnHide", "📉 MINIMIZAR", UDim2.new(0, 170, 0, 0), UDim2.new(0, 110, 0, 32), Color3.fromRGB(30, 30, 35))
local btnClose  = createBtn(content, "BtnClose", "❌ CERRAR", UDim2.new(0, 290, 0, 0), UDim2.new(0, 90, 0, 32), Color3.fromRGB(120, 20, 20))

local sliderSpeed = createSlider(content, "Velocidad", 50, 5000, 500, UDim2.new(0, 0, 0, 40))
local sliderAnti  = createSlider(content, "Anti-Bucle", 1, 5, 3, UDim2.new(0, 230, 0, 40))

local sliderWaitArrival = createSliderFloat(content, "Espera al llegar", 0.05, 1.00, 0.15, 0.05, UDim2.new(0, 0, 0, 100))
local sliderWaitPrompt  = createSliderFloat(content, "Espera tras prompt", 0.05, 2.00, 0.30, 0.05, UDim2.new(0, 230, 0, 100))
local sliderWaitNpc     = createSliderFloat(content, "Espera entre NPCs", 0.10, 1.00, 0.30, 0.05, UDim2.new(0, 460, 0, 100))

local toggleNoclip   = createToggle(content, "Noclip", true, UDim2.new(0, 460, 0, 40))
local toggleCooldown = createToggle(content, "Prompt CD", true, UDim2.new(0, 390, 0, 0))
local toggleAntiAfk  = createToggle(content, "Anti-AFK", true, UDim2.new(0, 540, 0, 0))

local infoLabel = Instance.new("TextLabel", content)
infoLabel.Size = UDim2.new(1, 0, 0, 35)
infoLabel.Position = UDim2.new(0, 0, 0, 165)
infoLabel.BackgroundColor3 = Color3.fromRGB(18, 18, 22)
infoLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
infoLabel.Font = Enum.Font.GothamBold
infoLabel.TextSize = 12
infoLabel.TextWrapped = true
infoLabel.TextYAlignment = Enum.TextYAlignment.Top
infoLabel.TextXAlignment = Enum.TextXAlignment.Left
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
-- 3. SISTEMAS CORE OPTIMIZADOS
-- ==========================================
local noclipConn
local function updateNoclip()
    if noclipConn then noclipConn:Disconnect(); noclipConn = nil end
    if noclipEnabled then
        -- 🆕 Noclip optimizado: GetChildren en vez de GetDescendants
        noclipConn = RunService.Stepped:Connect(function()
            local char = player.Character
            if char then
                for _, child in ipairs(char:GetChildren()) do
                    if child:IsA("BasePart") then
                        child.CanCollide = false
                    elseif child:IsA("Accessory") or child:IsA("Tool") then
                        local handle = child:FindFirstChildWhichIsA("BasePart")
                        if handle then handle.CanCollide = false end
                    end
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

local function forceCameraLookAt(targetPos)
    local camera = Workspace.CurrentCamera
    if not camera then return end
    local camPos = camera.CFrame.Position
    local lookAt = CFrame.lookAt(camPos, targetPos)
    pcall(function() camera.CFrame = lookAt end)
    task.wait(0.08)
end

local function simulateScreenTap()
    local camera = Workspace.CurrentCamera
    local center = (camera and camera.ViewportSize and Vector2.new(camera.ViewportSize.X / 2, camera.ViewportSize.Y / 2)) or Vector2.new(500, 500)
    local ok1, VIM = pcall(function() return game:GetService("VirtualInputManager") end)
    if ok1 and VIM then
        pcall(function()
            VIM:SendTouchEvent(0, 0, {center})
            task.wait(0.04)
            VIM:SendTouchEvent(0, 2, {center})
        end)
        task.wait(0.05); return
    end
    local ok2, VU = pcall(function() return game:GetService("VirtualUser") end)
    if ok2 and VU then
        pcall(function()
            VU:Button1Down(center)
            task.wait(0.04)
            VU:Button1Up(center)
        end)
        task.wait(0.05)
    end
end

local function refreshPromptVisibility(targetPos)
    if targetPos then forceCameraLookAt(targetPos) end
    simulateScreenTap()
    task.wait(0.1)
end

-- 🆕 TELEPORT SEGURO: No puede colgarse ni fugarse
local function smoothTeleport(targetPos)
    local char = player.Character
    if not char then return false end
    local root = char:FindFirstChild("HumanoidRootPart")
    local hum = char:FindFirstChild("Humanoid")
    if not root or not hum then return false end

    if (root.Position - targetPos).Magnitude < 3 then 
        pcall(function()
            root.AssemblyLinearVelocity = Vector3.zero
            root.AssemblyAngularVelocity = Vector3.zero
        end)
        return true 
    end

    local oldWalkSpeed = hum.WalkSpeed
    local oldAutoRotate = hum.AutoRotate
    hum.WalkSpeed = 0
    hum.AutoRotate = false

    local speed = math.clamp(moveSpeed, 50, 5000)
    local conn
    local doneEvent = Instance.new("BindableEvent")
    local success = false
    local elapsed = 0
    local fired = false

    local function fireDone(res)
        if fired then return end
        fired = true
        success = res
        if conn then pcall(function() conn:Disconnect() end); conn = nil end
        doneEvent:Fire()
    end

    conn = RunService.Heartbeat:Connect(function(dt)
        elapsed += dt
        if elapsed > 6 then fireDone(false); return end -- Seguro anti-cuelgue
        if not player.Character or not player.Character:FindFirstChild("HumanoidRootPart") then
            fireDone(false); return
        end
        local r = player.Character.HumanoidRootPart
        local dist = (targetPos - r.Position).Magnitude

        if dist <= 3 then fireDone(true); return end

        local move = math.min(speed * dt, dist)
        local dir = (targetPos - r.Position).Unit
        pcall(function()
            r.CFrame = CFrame.new(r.Position + dir * move)
            r.AssemblyLinearVelocity = Vector3.zero
            r.AssemblyAngularVelocity = Vector3.zero
        end)
    end)

    -- Seguro si el evento nunca dispara
    task.delay(6.5, function() fireDone(false) end)

    doneEvent.Event:Wait()
    doneEvent:Destroy()

    if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
        pcall(function()
            player.Character:PivotTo(CFrame.new(targetPos))
            player.Character.HumanoidRootPart.AssemblyLinearVelocity = Vector3.zero
            player.Character.HumanoidRootPart.AssemblyAngularVelocity = Vector3.zero
        end)
    end

    if hum and hum.Parent then
        hum.WalkSpeed = oldWalkSpeed
        hum.AutoRotate = oldAutoRotate
    end

    task.wait(waitOnArrival)
    return success
end

local function getValidGiverPrompt()
    local works = Workspace:FindFirstChild("Works")
    if not works then return nil, lockedGiverPos end
    local p = works:FindFirstChild("Arturos")
    if p then p = p:FindFirstChild("Delivery") end
    if p then p = p:FindFirstChild("Giver") end
    if not p then return nil, lockedGiverPos end

    if lockedGiverPrompt and lockedGiverPrompt:IsA("ProximityPrompt") and lockedGiverPrompt.Parent then
        return lockedGiverPrompt, lockedGiverPrompt.Parent.Position
    end

    local closest, bestPos, minDist = nil, lockedGiverPos, math.huge
    for _, d in ipairs(p:GetDescendants()) do
        if d:IsA("ProximityPrompt") and d.Parent:IsA("BasePart") then
            local dist = (d.Parent.Position - lockedGiverPos).Magnitude
            if dist < minDist then minDist = dist; closest = d; bestPos = d.Parent.Position end
        end
    end

    if closest then
        lockedGiverPrompt = closest
        lockedGiverPos = bestPos
        return closest, bestPos
    end
    return nil, lockedGiverPos
end

local function bypassAndTriggerPrompt(prompt, targetPos)
    if not prompt or not prompt:IsA("ProximityPrompt") then return false end
    pcall(function()
        prompt.HoldDuration = 0
        prompt.MaxActivationDistance = math.huge
        prompt.RequiresLineOfSight = false
        prompt.Enabled = true
        prompt.ClickablePrompt = true
    end)

    if targetPos then refreshPromptVisibility(targetPos) end
    task.wait(waitAfterPrompt * 0.1)

    if fireproximityprompt then
        pcall(fireproximityprompt, prompt)
    else
        pcall(function() prompt:InputHoldBegin() end)
        task.wait(waitAfterPrompt * 0.1)
        pcall(function() prompt:InputHoldEnd() end)
    end

    task.wait(waitAfterPrompt)
    pcall(function() prompt:InputHoldBegin() end)
    task.wait(0.02)
    pcall(function() prompt:InputHoldEnd() end)
    return true
end

local function quickTriggerPrompt(prompt, targetPos)
    if not prompt or not prompt:IsA("ProximityPrompt") then return false end
    pcall(function()
        prompt.HoldDuration = 0
        prompt.MaxActivationDistance = math.huge
        prompt.RequiresLineOfSight = false
        prompt.Enabled = true
    end)

    if targetPos then pcall(forceCameraLookAt, targetPos); simulateScreenTap() end

    if fireproximityprompt then
        pcall(fireproximityprompt, prompt)
    else
        pcall(function() prompt:InputHoldBegin() end)
        task.wait(0.02)
        pcall(function() prompt:InputHoldEnd() end)
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
-- 🚀 SISTEMA REACTIVO SEGURO (ANTI-LEAKS)
-- ==========================================
local function waitForChickenAcquired(timeout)
    if hasChicken() then return true end

    local acquiredEvent = Instance.new("BindableEvent")
    local conns = {}
    local fired = false

    local function fire()
        if fired then return end; fired = true; acquiredEvent:Fire()
    end

    local function check(obj)
        if obj.Name == "Fried Chicken" then fire() end
    end

    table.insert(conns, player.Backpack.ChildAdded:Connect(check))

    local char = player.Character
    if char then
        table.insert(conns, char.ChildAdded:Connect(check))
        local hum = char:FindFirstChild("Humanoid")
        if hum then table.insert(conns, hum.Died:Connect(fire)) end
    end

    local charAddedConn = player.CharacterAdded:Connect(function(newChar)
        if fired then return end
        table.insert(conns, newChar.ChildAdded:Connect(check))
        local hum = newChar:WaitForChild("Humanoid", 2)
        if hum then table.insert(conns, hum.Died:Connect(fire)) end
    end)
    table.insert(conns, charAddedConn)

    task.delay(timeout, fire)

    acquiredEvent.Event:Wait()

    for _, c in ipairs(conns) do pcall(function() c:Disconnect() end) end
    acquiredEvent:Destroy()

    return hasChicken()
end

local function waitForChickenDelivered(timeout)
    if not hasChicken() then return true end

    local deliveredEvent = Instance.new("BindableEvent")
    local conns = {}
    local fired = false

    local function fire()
        if fired then return end; fired = true; deliveredEvent:Fire()
    end

    local function check()
        if not hasChicken() then fire() end
    end

    local char = player.Character
    local trackedChicken = char and char:FindFirstChild("Fried Chicken") or player.Backpack:FindFirstChild("Fried Chicken")

    if trackedChicken then
        table.insert(conns, trackedChicken.AncestryChanged:Connect(function() task.wait(0.02); check() end))
    end

    table.insert(conns, player.Backpack.ChildRemoved:Connect(function(obj)
        if obj.Name == "Fried Chicken" then task.wait(0.02); check() end
    end))

    if char then
        table.insert(conns, char.ChildRemoved:Connect(function(obj)
            if obj.Name == "Fried Chicken" then task.wait(0.02); check() end
        end))
        local hum = char:FindFirstChild("Humanoid")
        if hum then table.insert(conns, hum.Died:Connect(fire)) end
    end

    task.delay(timeout, fire)

    deliveredEvent.Event:Wait()

    for _, c in ipairs(conns) do pcall(function() c:Disconnect() end) end
    deliveredEvent:Destroy()

    return not hasChicken()
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
        task.wait(0.2); waitTime += 0.2
        if waitTime > 8 then
            systemPaused = false; promptFailCount = 0; lockedGiverPrompt = nil
            infoLabel.Text = "⚠️ Timeout respawn. Reanudando..."
            infoLabel.TextColor3 = Color3.fromRGB(255, 150, 0); return
        end
    until player.Character and player.Character:FindFirstChild("HumanoidRootPart")

    task.wait(1.2)
    promptFailCount = 0; lockedGiverPrompt = nil; systemPaused = false
    infoLabel.Text = "✅ Personaje regenerado. Reanudando..."
    infoLabel.TextColor3 = Color3.fromRGB(0, 255, 150)

    if not jobThread or coroutine.status(jobThread) == "dead" then
        jobThread = task.spawn(runAutoJob)
    end
end

-- ==========================================
-- 5. CICLO PRINCIPAL (CICLOLIMPIO + PCALL)
-- ==========================================
function runAutoJob()
    while autoJobEnabled do
        local ok, err = pcall(function()
            if systemPaused then task.wait(0.5); return end
            local char = player.Character
            local root = char and char:FindFirstChild("HumanoidRootPart")
            if not root then
                infoLabel.Text = "⏳ Esperando personaje..."
                infoLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
                task.wait(1); return
            end

            currentCycleId = currentCycleId + 1
            local myCycleId = currentCycleId

            if not hasChicken() then
                -- ============ FASE 1 ============
                infoLabel.Text = "📦 Yendo al Giver..."
                infoLabel.TextColor3 = Color3.fromRGB(255, 200, 0)
                
                local giverPrompt, exactGiverPos = getValidGiverPrompt()
                local targetPos = exactGiverPos or lockedGiverPos
                
                if not smoothTeleport(targetPos) then
                    infoLabel.Text = "⚠️ Teleport fallido. Reintentando..."
                    infoLabel.TextColor3 = Color3.fromRGB(255, 150, 0)
                    task.wait(1); return
                end
                
                if not giverPrompt then giverPrompt, exactGiverPos = getValidGiverPrompt() end
                if not giverPrompt then
                    promptFailCount += 1
                    infoLabel.Text = string.format("⚠️ Giver no detectado (%d/%d)", promptFailCount, maxAntiLoopAttempts)
                    infoLabel.TextColor3 = Color3.fromRGB(255, 150, 0)
                    if promptFailCount >= maxAntiLoopAttempts then triggerAntiLoopReset() end
                    task.wait(1.5); return
                end
                
                bypassAndTriggerPrompt(giverPrompt, exactGiverPos or targetPos)
                promptFailCount = 0
                infoLabel.Text = "⚡ Esperando pollo (auto-retry)..."
                infoLabel.TextColor3 = Color3.fromRGB(150, 200, 255)

                -- 🆕 HILO PARALELO SEGURO CON CYCLE ID
                task.spawn(function()
                    local retryCount = 0
                    while myCycleId == currentCycleId and autoJobEnabled and not systemPaused do
                        task.wait(RETRY_PROMPT_INTERVAL)
                        if myCycleId ~= currentCycleId or not autoJobEnabled or systemPaused then break end
                        if hasChicken() then break end
                        
                        local currentPrompt = getValidGiverPrompt()
                        if currentPrompt then
                            retryCount += 1
                            infoLabel.Text = string.format("🔄 Reintento #%d del Giver...", retryCount)
                            infoLabel.TextColor3 = Color3.fromRGB(255, 200, 100)
                            quickTriggerPrompt(currentPrompt, currentPrompt.Parent and currentPrompt.Parent.Position)
                        end
                    end
                end)

                local pickupSuccess = waitForChickenAcquired(PICKUP_TIMEOUT)

                if pickupSuccess then
                    consecutiveFails = 0
                    infoLabel.Text = "✅ Pollo recibido. Buscando NPC..."
                    infoLabel.TextColor3 = Color3.fromRGB(0, 255, 150)
                else
                    consecutiveFails += 1
                    infoLabel.Text = string.format("⚠️ Timeout recogida (%d/3)", consecutiveFails)
                    infoLabel.TextColor3 = Color3.fromRGB(255, 150, 0)
                    if consecutiveFails >= 3 then
                        infoLabel.Text = "❌ Pausa por fallos..."
                        infoLabel.TextColor3 = Color3.fromRGB(255, 80, 80)
                        task.wait(FAIL_COOLDOWN); consecutiveFails = 0; lockedGiverPrompt = nil
                    end
                    task.wait(1); return
                end
            else
                -- ============ FASE 2 ============
                infoLabel.Text = "🚚 Esperando spawn del NPC..."
                infoLabel.TextColor3 = Color3.fromRGB(0, 162, 255)
                local npcPos, npcModel = nil, nil
                local spawnWait = 0
                while spawnWait < NPC_SPAWN_WAIT and autoJobEnabled and not systemPaused do
                    npcPos, npcModel = getDeliveryTarget()
                    if npcPos and npcModel then break end
                    task.wait(0.1); spawnWait += 0.1
                end

                if npcPos and npcModel then
                    infoLabel.Text = string.format("📍 NPC detectado: %.1f, %.1f, %.1f", npcPos.X, npcPos.Y, npcPos.Z)
                    infoLabel.TextColor3 = Color3.fromRGB(0, 255, 150)
                    if not smoothTeleport(npcPos) then
                        infoLabel.Text = "⚠️ Teleport al NPC fallido. Reintentando..."
                        infoLabel.TextColor3 = Color3.fromRGB(255, 150, 0)
                        task.wait(1); return
                    end

                    local hrp = npcModel:FindFirstChild("HumanoidRootPart")
                    local finalTarget = (hrp and hrp.Position) or npcPos
                    refreshPromptVisibility(finalTarget)
                    task.wait(0.1)

                    local npcPrompt = hrp and hrp:FindFirstChildWhichIsA("ProximityPrompt")
                    if not npcPrompt then npcPrompt = npcModel:FindFirstChildWhichIsA("ProximityPrompt", true) end

                    if npcPrompt then
                        bypassAndTriggerPrompt(npcPrompt, finalTarget)
                        promptFailCount = 0
                        infoLabel.Text = "⚡ Entregando (auto-retry)..."
                        infoLabel.TextColor3 = Color3.fromRGB(150, 200, 255)

                        -- 🆕 HILO PARALELO SEGURO
                        task.spawn(function()
                            local retryCount = 0
                            while myCycleId == currentCycleId and autoJobEnabled and not systemPaused do
                                task.wait(RETRY_PROMPT_INTERVAL)
                                if myCycleId ~= currentCycleId or not autoJobEnabled or systemPaused or not hasChicken() then break end
                                if not npcModel or not npcModel.Parent then break end
                                
                                local rHrp = npcModel:FindFirstChild("HumanoidRootPart")
                                local rPrompt = rHrp and rHrp:FindFirstChildWhichIsA("ProximityPrompt")
                                if not rPrompt then rPrompt = npcModel:FindFirstChildWhichIsA("ProximityPrompt", true) end
                                
                                if rPrompt then
                                    retryCount += 1
                                    infoLabel.Text = string.format("🔄 Reintento #%d al NPC...", retryCount)
                                    infoLabel.TextColor3 = Color3.fromRGB(255, 200, 100)
                                    quickTriggerPrompt(rPrompt, (rHrp and rHrp.Position) or finalTarget)
                                end
                            end
                        end)

                        local deliverySuccess = waitForChickenDelivered(DELIVERY_TIMEOUT)

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
                                task.wait(FAIL_COOLDOWN); consecutiveFails = 0
                            end
                            task.wait(1)
                        end
                    else
                        simulateScreenTap()
                        task.wait(0.3)
                        local retryPrompt = npcModel:FindFirstChildWhichIsA("ProximityPrompt", true)
                        if retryPrompt then
                            bypassAndTriggerPrompt(retryPrompt, finalTarget)
                            promptFailCount = 0
                        else
                            promptFailCount += 1
                            infoLabel.Text = string.format("⚠️ Prompt NPC no detectado (%d/%d)", promptFailCount, maxAntiLoopAttempts)
                            infoLabel.TextColor3 = Color3.fromRGB(255, 150, 0)
                            if promptFailCount >= maxAntiLoopAttempts then triggerAntiLoopReset() end
                            task.wait(1.5)
                        end
                    end
                else
                    infoLabel.Text = "❌ NPC no spawneó. Reintentando..."
                    infoLabel.TextColor3 = Color3.fromRGB(255, 80, 80)
                    task.wait(2)
                end
            end
            task.wait(waitBetweenNpcs)
        end)

        -- Si hubo un error de script, lo muestra y espera en vez de crashear el loop
        if not ok then
            warn("AutoJob Error Capturado: " .. tostring(err))
            infoLabel.Text = "⚠️ Error recuperándose... Reanudando."
            task.wait(2)
        end
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
        consecutiveFails = 0; promptFailCount = 0; systemPaused = false; lockedGiverPrompt = nil
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
sliderWaitArrival.SetCallback(function(v) waitOnArrival = v end)
sliderWaitPrompt.SetCallback(function(v) waitAfterPrompt = v end)
sliderWaitNpc.SetCallback(function(v) waitBetweenNpcs = v end)

toggleNoclip.SetCallback(function(v) noclipEnabled = v; updateNoclip() end)
toggleCooldown.SetCallback(function(v) promptCooldownEnabled = v end)
toggleAntiAfk.SetCallback(function(v) antiAfkEnabled = v end)

infoLabel.Text = "Sistema listo. Presiona ACTIVAR para iniciar."