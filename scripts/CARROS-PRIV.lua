-- SERVICIOS
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local CoreGui = game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")

local lplayer = Players.LocalPlayer
local camera = workspace.CurrentCamera

task.wait(0.5)

-- ==========================================
-- VARIABLES GLOBALES & ESTADO
-- ==========================================
local currentTargetSeat = nil
local currentHighlight = nil
local maxRange = 50
local selectedButton = nil
local lastDeselectTime = 0
local deselectCooldown = 1.5
local lastBoardingCFrame = nil -- ✅ NUEVO: Guarda posición antes de sentarse

-- ==========================================
-- 2. SISTEMA ANTI-DUPLICACIÓN
-- ==========================================
local existingGui = CoreGui:FindFirstChild("Bycode_GUI_System")
if existingGui then
    existingGui:Destroy()
end

local screenGui = Instance.new("ScreenGui", CoreGui)
screenGui.Name = "Bycode_GUI_System"
screenGui.ResetOnSpawn = false

local main = Instance.new("Frame", screenGui)
main.Size = UDim2.new(0, 210, 0, 560) 
main.Position = UDim2.new(0, 20, 0.5, -280) 
main.BackgroundColor3 = Color3.fromRGB(10, 10, 12)
main.BorderSizePixel = 0
main.Active = true
main.Draggable = true 

local uiCorner = Instance.new("UICorner", main)
uiCorner.CornerRadius = UDim.new(0, 12)

local uiStroke = Instance.new("UIStroke", main)
uiStroke.Color = Color3.fromRGB(0, 162, 255)
uiStroke.Thickness = 1.8

-- TÍTULO
local title = Instance.new("TextLabel", main)
title.Size = UDim2.new(1, 0, 0, 45)
title.Text = "SISTEMA VEHICULAR"
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

-- BOTONES
local btnSinConductor = createBtn("BtnSinConductor", "ABORDAR (VACÍO)", UDim2.new(0, 10, 0, 55), Color3.fromRGB(20, 25, 35))
local btnConConductor = createBtn("BtnConConductor", "ABORDAR (CONDUCTOR)", UDim2.new(0, 10, 0, 100), Color3.fromRGB(0, 50, 100))
local btnCarJump = createBtn("BtnJump", "SALTO VERTICAL", UDim2.new(0, 10, 0, 145), Color3.fromRGB(0, 80, 150))
local btnDeselect = createBtn("BtnDeselect", "DESELECCIONAR", UDim2.new(0, 10, 0, 190), Color3.fromRGB(40, 40, 45))

-- ==========================================
-- INFO & LISTA
-- ==========================================
local infoLabel = Instance.new("TextLabel", main)
infoLabel.Size = UDim2.new(1, -20, 0, 40)
infoLabel.Position = UDim2.new(0, 10, 0, 235)
infoLabel.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
infoLabel.TextColor3 = Color3.fromRGB(0, 162, 255)
infoLabel.Font = Enum.Font.GothamBold
infoLabel.TextSize = 12
infoLabel.TextWrapped = true
infoLabel.TextYAlignment = "Top"
Instance.new("UICorner", infoLabel).CornerRadius = UDim.new(0, 6)
infoLabel.Text = "Sin vehículo en rango"

local listFrame = Instance.new("ScrollingFrame", main)
listFrame.Size = UDim2.new(1, -20, 0, 120)
listFrame.Position = UDim2.new(0, 10, 0, 285)
listFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
listFrame.BorderSizePixel = 0
listFrame.ScrollBarThickness = 4
listFrame.ScrollBarImageColor3 = Color3.fromRGB(0, 162, 255)
Instance.new("UICorner", listFrame).CornerRadius = UDim.new(0, 6)

local listLayout = Instance.new("UIListLayout", listFrame)
listLayout.Padding = UDim.new(0, 5)
listLayout.SortOrder = Enum.SortOrder.LayoutOrder

listLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    listFrame.CanvasSize = UDim2.new(0, 0, 0, listLayout.AbsoluteContentSize.Y + 5)
end)

local function getVehicleModelFromSeat(seat)
    if not seat then return nil end
    local chassis = seat.Parent
    if chassis and chassis.Parent and chassis.Parent:IsA("Model") then
        return chassis.Parent
    elseif chassis and chassis:IsA("Model") then
        return chassis
    end
    return nil
end

-- ==========================================
-- HIGHLIGHT REUTILIZABLE
-- ==========================================
local selectionHighlight = Instance.new("Highlight")
selectionHighlight.FillTransparency = 0.8
selectionHighlight.OutlineTransparency = 0
selectionHighlight.OutlineColor = Color3.fromRGB(0, 162, 255)
selectionHighlight.Enabled = false
selectionHighlight.Parent = game:GetService("Lighting")

-- ==========================================
-- FUNCIÓN DESELECCIONAR
-- ==========================================
local function deselectVehicle()
    currentTargetSeat = nil
    selectionHighlight.Enabled = false
    lastDeselectTime = os.clock()
    
    infoLabel.Text = "Sin vehículo seleccionado"
    infoLabel.TextColor3 = Color3.fromRGB(150, 150, 150)

    if selectedButton then
        selectedButton.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
        selectedButton = nil
    end
end

-- ==========================================
-- LISTA ORDENADA POR DISTANCIA
-- ==========================================
local function populateVehicleList()
    for _, child in pairs(listFrame:GetChildren()) do
        if child:IsA("TextButton") or child:IsA("TextLabel") then child:Destroy() end
    end
    selectedButton = nil

    local vehicleTable = {}
    local charRoot = lplayer.Character and lplayer.Character:FindFirstChild("HumanoidRootPart")

    for _, obj in pairs(Workspace:GetDescendants()) do
        if obj:IsA("VehicleSeat") then
            local model = getVehicleModelFromSeat(obj)
            if model then
                local dist = charRoot and (charRoot.Position - obj.Position).Magnitude or 9999
                if dist < 300 then
                    table.insert(vehicleTable, {seat = obj, model = model, distance = dist})
                end
            end
        end
    end

    table.sort(vehicleTable, function(a, b) return a.distance < b.distance end)

    local count = 0
    for _, v in ipairs(vehicleTable) do
        count = count + 1
        local btn = Instance.new("TextButton", listFrame)
        btn.Size = UDim2.new(1, 0, 0, 30)
        btn.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
        btn.TextColor3 = Color3.new(1, 1, 1)
        btn.Text = string.format("%s (%.1f m)", v.model.Name, v.distance) 
        btn.Font = Enum.Font.Gotham
        btn.TextSize = 12
        Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 4)
        
        btn.MouseButton1Click:Connect(function()
            if currentTargetSeat == v.seat then
                deselectVehicle()
                return
            end
            
            if selectedButton then
                selectedButton.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
            end
            
            currentTargetSeat = v.seat
            selectedButton = btn
            btn.BackgroundColor3 = Color3.fromRGB(0, 80, 160)
            infoLabel.Text = "Seleccionado: " .. v.model.Name
            infoLabel.TextColor3 = Color3.fromRGB(0, 162, 255)
        end)
    end
    
    if count == 0 then
        local lbl = Instance.new("TextLabel", listFrame)
        lbl.Size = UDim2.new(1, 0, 0, 30)
        lbl.BackgroundTransparency = 1
        lbl.Text = "No se encontraron vehículos"
        lbl.TextColor3 = Color3.fromRGB(150, 150, 150)
    end
end

local btnRefreshList = createBtn("BtnRefreshList", "ACTUALIZAR LISTA", UDim2.new(0, 10, 0, 415), Color3.fromRGB(20, 25, 35))
local btnHide = createBtn("BtnHide", "MINIMIZAR", UDim2.new(0, 10, 0, 460), Color3.fromRGB(20, 20, 20))
local btnClose = createBtn("BtnClose", "CERRAR GUI", UDim2.new(0, 10, 0, 505), Color3.fromRGB(100, 0, 0))

-- ==========================================
-- LÓGICA DE SELECCIÓN & HIGHLIGHT PERSISTENTE
-- ==========================================
local function isValidVehicleModel(model)
    if not model then return false end
    local name = model.Name:lower()
    if name:find("car") or name:find("vehicle") then return true end
    if model:IsA("Model") then return true end
    return false
end

local function getRaycastVehicle()
    local origin = camera.CFrame.Position
    local direction = camera.CFrame.LookVector * 200
    local params = RaycastParams.new()
    params.FilterDescendantsInstances = {lplayer.Character}
    params.FilterType = Enum.RaycastFilterType.Exclude
    local result = Workspace:Raycast(origin, direction, params)
    
    if result then
        local hitPart = result.Instance
        local model = hitPart:FindFirstAncestorOfClass("Model")
        if model and isValidVehicleModel(model) then
            for _, child in pairs(model:GetDescendants()) do
                if child:IsA("VehicleSeat") then
                    return child, model
                end
            end
        end
    end
    return nil, nil
end

RunService.Heartbeat:Connect(function()
    if os.clock() - lastDeselectTime < deselectCooldown then
        selectionHighlight.Enabled = false
        return
    end

    if not lplayer.Character then return end
    local charRoot = lplayer.Character:FindFirstChild("HumanoidRootPart")
    if not charRoot then return end

    local seat, model = getRaycastVehicle()
    if not seat and currentTargetSeat and currentTargetSeat.Parent then
        seat = currentTargetSeat
        model = getVehicleModelFromSeat(seat)
    end

    local isValid = false
    if seat and seat.Parent and model then
        local dist = (charRoot.Position - seat.Position).Magnitude
        if dist <= maxRange then
            isValid = true
            if seat == currentTargetSeat or not currentTargetSeat then
                 infoLabel.Text = string.format("%s\nDistancia: %d studs", model.Name, math.floor(dist))
                 infoLabel.TextColor3 = Color3.fromRGB(0, 162, 255)
            end
        end
    end

    if isValid and currentTargetSeat == seat then
        selectionHighlight.Adornee = model
        selectionHighlight.Enabled = true
    else
        selectionHighlight.Enabled = false
        if not isValid and currentTargetSeat == seat then
             infoLabel.Text = "Fuera de rango"
             infoLabel.TextColor3 = Color3.fromRGB(150, 150, 150)
        end
    end
end)

-- ==========================================
-- LÓGICA DE ABORDAJE (CORREGIDA)
-- ==========================================
local function subirAlPiloto(targetSeat, forzarRobo)
    local character = lplayer.Character
    if not character then return end
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    if not humanoid or not targetSeat then return end

    selectionHighlight.Enabled = false
    humanoid.Jump = true 
    humanoid.Sit = false
    task.wait(0.1)
    
    if forzarRobo and targetSeat.Occupant then
        local currentDriver = targetSeat.Occupant
        if currentDriver:IsA("Humanoid") then 
            currentDriver.Sit = false 
            local root = currentDriver.Parent:FindFirstChild("HumanoidRootPart")
            if root then 
                root.CFrame = root.CFrame * CFrame.new(0, 2.5, 0)
                root.AssemblyLinearVelocity = Vector3.new(0, 25, 0) 
            end
        end
        
        local timeout = 0
        while targetSeat.Occupant ~= nil and timeout < 1.5 do
            task.wait(0.05)
            timeout += 0.05
        end
    end
    
    if targetSeat.Occupant == nil then
        -- ✅ GUARDAR POSICIÓN EXACTA ANTES DE SENTARSE
        local rootPart = character:FindFirstChild("HumanoidRootPart")
        if rootPart then
            lastBoardingCFrame = rootPart.CFrame
        end
        targetSeat:Sit(humanoid)
    else
        infoLabel.Text = "No se pudo liberar el asiento"
        infoLabel.TextColor3 = Color3.fromRGB(255, 50, 50)
    end
end

btnSinConductor.MouseButton1Click:Connect(function()
    if currentTargetSeat and currentTargetSeat.Parent then
        if not currentTargetSeat.Occupant then
            subirAlPiloto(currentTargetSeat, false)
        else
            infoLabel.Text = "¡El vehículo tiene conductor!"
            infoLabel.TextColor3 = Color3.fromRGB(255, 50, 50)
        end
    else
        infoLabel.Text = "Sin objetivo seleccionado"
    end
end)

btnConConductor.MouseButton1Click:Connect(function()
    if currentTargetSeat and currentTargetSeat.Parent then
        if currentTargetSeat.Occupant then
            subirAlPiloto(currentTargetSeat, true)
        else
            infoLabel.Text = "¡El vehículo está vacío!"
            infoLabel.TextColor3 = Color3.fromRGB(255, 50, 50)
        end
    else
        infoLabel.Text = "Sin objetivo seleccionado"
    end
end)

-- ==========================================
-- SALTO VERTICAL CON RETORNO A POSICIÓN DE ABORDAJE
-- ==========================================
btnCarJump.MouseButton1Click:Connect(function()
    local hum = lplayer.Character and lplayer.Character:FindFirstChildOfClass("Humanoid")
    local seat = hum and hum.SeatPart
    if seat and seat:IsA("VehicleSeat") then
        local vehicleModel = seat:FindFirstAncestorWhichIsA("Model")
        local targetPart = vehicleModel and vehicleModel.PrimaryPart or seat
        local root = lplayer.Character:FindFirstChild("HumanoidRootPart")
        if not root then return end

        -- ✅ USAR POSICIÓN GUARDADA AL ABORDAR (O ACTUAL SI NO HAY)
        local savedCFrame = lastBoardingCFrame or root.CFrame
        local savedPos = savedCFrame.Position
        
        local launchPower = 9999
        targetPart.AssemblyLinearVelocity = Vector3.new(0, launchPower, 0)
        targetPart.AssemblyAngularVelocity = Vector3.new(0, 0, 0)
        
        task.wait(0.15)
        hum.Sit = false
        
        task.spawn(function()
            task.wait(0.05)
            if not lplayer.Character or not lplayer.Character:FindFirstChild("HumanoidRootPart") then return end
            local currentRoot = lplayer.Character.HumanoidRootPart
            
            currentRoot.AssemblyLinearVelocity = Vector3.zero
            currentRoot.AssemblyAngularVelocity = Vector3.zero
            task.wait(0.02)
            
            local currentPos = currentRoot.Position
            local dist = (currentPos - savedPos).Magnitude
            local maxSafeStep = 15
            
            if dist > maxSafeStep then
                local direction = (savedPos - currentPos).Unit
                local remaining = dist
                
                while remaining > maxSafeStep do
                    if not lplayer.Character or not lplayer.Character:FindFirstChild("HumanoidRootPart") then return end
                    currentRoot.CFrame = CFrame.new(currentRoot.Position + direction * maxSafeStep) * savedCFrame.Rotation
                    task.wait(0.01)
                    remaining -= maxSafeStep
                end
            end
            
            currentRoot.CFrame = savedCFrame
            currentRoot.AssemblyLinearVelocity = Vector3.zero
            currentRoot.AssemblyAngularVelocity = Vector3.zero
            
            infoLabel.Text = "¡Retorno activado! Posición restaurada."
            infoLabel.TextColor3 = Color3.fromRGB(0, 255, 150)
        end)
        
        infoLabel.Text = "¡Salto vertical activado!"
        infoLabel.TextColor3 = Color3.fromRGB(0, 255, 150)
    else
        infoLabel.Text = "Debes estar en un vehículo"
        infoLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
    end
end)

-- ==========================================
-- BOTÓN DESELECCIONAR & MINIMIZAR/CERRAR
-- ==========================================
btnDeselect.MouseButton1Click:Connect(deselectVehicle)

local openBtn = Instance.new("TextButton", screenGui)
openBtn.Size = UDim2.new(0, 100, 0, 40)
openBtn.Position = UDim2.new(0, 20, 0.5, -20)
openBtn.Text = "ABRIR GUI" 
openBtn.BackgroundColor3 = Color3.fromRGB(0, 162, 255)
openBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
openBtn.Font = Enum.Font.GothamBold
openBtn.TextSize = 16
openBtn.Visible = false
Instance.new("UICorner", openBtn).CornerRadius = UDim.new(0, 10)
Instance.new("UIStroke", openBtn).Thickness = 2

btnHide.MouseButton1Click:Connect(function() main.Visible = false; openBtn.Visible = true end)
openBtn.MouseButton1Click:Connect(function() main.Visible = true; openBtn.Visible = false end)

btnClose.MouseButton1Click:Connect(function()
    screenGui:Destroy()
end)

-- Limpieza al sentarse / reaparecer
lplayer.CharacterAdded:Connect(function(char)
    lastBoardingCFrame = nil -- ✅ Limpiar coordenadas antiguas al respawn
    local hum = char:WaitForChild("Humanoid")
    hum.Seated:Connect(function(active)
        if active then
            selectionHighlight.Enabled = false
            currentTargetSeat = nil
            if selectedButton then
                selectedButton.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
                selectedButton = nil
            end
        end
    end)
end)

btnRefreshList.MouseButton1Click:Connect(populateVehicleList)
populateVehicleList()