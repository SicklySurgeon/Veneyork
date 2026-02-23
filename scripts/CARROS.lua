-- SERVICIOS
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local lplayer = Players.LocalPlayer
local camera = workspace.CurrentCamera

task.wait(0.5)

-- ==========================================
-- VARIABLES GLOBALES & ESTADO
-- ==========================================
local currentTargetSeat = nil -- Para el sistema de Raycast
local currentHighlight = nil -- Para el feedback visual
local maxRange = 50 -- Rango máximo para mantener el highlight

-- ==========================================
-- INTERFAZ (NEGRO Y AZUL ELÉCTRICO)
-- ==========================================
local screenGui = Instance.new("ScreenGui", game:GetService("CoreGui"))
screenGui.Name = "Bycode_GUI_System"
screenGui.ResetOnSpawn = false

-- Ajustado altura para acomodar botón de cerrar
local main = Instance.new("Frame", screenGui)
main.Size = UDim2.new(0, 210, 0, 540) 
main.Position = UDim2.new(0, 20, 0.5, -270) 
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

-- BOTONES ACTIVOS (Posiciones Ajustadas)
local btnSinConductor = createBtn("BtnSinConductor", "ABORDAR (VACÍO)", UDim2.new(0, 10, 0, 55), Color3.fromRGB(20, 25, 35))
local btnConConductor = createBtn("BtnConConductor", "ABORDAR (CONDUCTOR)", UDim2.new(0, 10, 0, 100), Color3.fromRGB(0, 50, 100))
local btnCarFling = createBtn("BtnFling", "EXPULSAR VEHÍCULO", UDim2.new(0, 10, 0, 145), Color3.fromRGB(0, 80, 150))

-- ==========================================
-- NUEVAS FUNCIONALIDADES: INFO & LISTA
-- ==========================================

-- 1. Dynamic Info TextLabel
local infoLabel = Instance.new("TextLabel", main)
infoLabel.Size = UDim2.new(1, -20, 0, 40)
infoLabel.Position = UDim2.new(0, 10, 0, 190)
infoLabel.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
infoLabel.TextColor3 = Color3.fromRGB(0, 162, 255)
infoLabel.Font = Enum.Font.GothamBold
infoLabel.TextSize = 12
infoLabel.TextWrapped = true
infoLabel.TextYAlignment = "Top"
Instance.new("UICorner", infoLabel).CornerRadius = UDim.new(0, 6)
infoLabel.Text = "Sin vehículo en rango"

-- 2. Vehicle List (ScrollingFrame)
local listFrame = Instance.new("ScrollingFrame", main)
listFrame.Size = UDim2.new(1, -20, 0, 150)
listFrame.Position = UDim2.new(0, 10, 0, 240)
listFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
listFrame.BorderSizePixel = 0
listFrame.ScrollBarThickness = 4
listFrame.ScrollBarImageColor3 = Color3.fromRGB(0, 162, 255)
Instance.new("UICorner", listFrame).CornerRadius = UDim.new(0, 6)

local listLayout = Instance.new("UIListLayout", listFrame)
listLayout.Padding = UDim.new(0, 5)
listLayout.SortOrder = Enum.SortOrder.LayoutOrder

-- Helper: Obtener el Modelo Principal del Vehículo (VehicleName)
local function getVehicleModelFromSeat(seat)
    if not seat then return nil end
    -- Jerarquía esperada: Workspace > VehicleName > Chassis > Seat
    local chassis = seat.Parent
    if chassis and chassis.Parent and chassis.Parent:IsA("Model") then
        return chassis.Parent -- Retorna VehicleName
    elseif chassis and chassis:IsA("Model") then
        return chassis
    end
    return nil
end

local function populateVehicleList()
    -- Limpiar lista anterior
    for _, child in pairs(listFrame:GetChildren()) do
        if child:IsA("TextButton") or child:IsA("TextLabel") then child:Destroy() end
    end

    local count = 0
    -- Escanear Workspace para la lista
    for _, obj in pairs(Workspace:GetDescendants()) do
        if obj:IsA("VehicleSeat") then
            local model = getVehicleModelFromSeat(obj)
            if model then
                count = count + 1
                local btn = Instance.new("TextButton", listFrame)
                btn.Size = UDim2.new(1, 0, 0, 30)
                btn.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
                btn.TextColor3 = Color3.new(1, 1, 1)
                -- Mostrar nombre del vehículo (Padre del Chasis)
                btn.Text = model.Name 
                btn.Font = Enum.Font.Gotham
                btn.TextSize = 12
                Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 4)
                
                btn.MouseButton1Click:Connect(function()
                    currentTargetSeat = obj
                    infoLabel.Text = "Seleccionado: " .. model.Name
                    -- El highlight se manejará en el Heartbeat para persistencia
                end)
            end
        end
    end
    
    if count == 0 then
        local lbl = Instance.new("TextLabel", listFrame)
        lbl.Size = UDim2.new(1, 0, 0, 30)
        lbl.BackgroundTransparency = 1
        lbl.Text = "No se encontraron vehículos"
        lbl.TextColor3 = Color3.fromRGB(150, 150, 150)
    end
end

-- Botón para refrescar lista
local btnRefreshList = createBtn("BtnRefreshList", "ACTUALIZAR LISTA", UDim2.new(0, 10, 0, 400), Color3.fromRGB(20, 25, 35))
btnRefreshList.MouseButton1Click:Connect(populateVehicleList)

local btnHide = createBtn("BtnHide", "MINIMIZAR", UDim2.new(0, 10, 0, 445), Color3.fromRGB(20, 20, 20))
local btnClose = createBtn("BtnClose", "CERRAR GUI", UDim2.new(0, 10, 0, 490), Color3.fromRGB(100, 0, 0))

-- ==========================================
-- LÓGICA DE SELECCIÓN (RAYCAST) & HIGHLIGHT PERSISTENTE
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
    local direction = camera.CFrame.LookVector * 200 -- Max Range 200
    
    local params = RaycastParams.new()
    params.FilterDescendantsInstances = {lplayer.Character}
    params.FilterType = Enum.RaycastFilterType.Exclude
    
    local result = Workspace:Raycast(origin, direction, params)
    
    if result then
        local hitPart = result.Instance
        local model = hitPart:FindFirstAncestorOfClass("Model")
        
        if model and isValidVehicleModel(model) then
            -- Buscar el VehicleSeat dentro del modelo
            for _, child in pairs(model:GetDescendants()) do
                if child:IsA("VehicleSeat") then
                    return child, model
                end
            end
        end
    end
    return nil, nil
end

-- Loop para actualizar InfoLabel y Highlight Persistente
RunService.Heartbeat:Connect(function()
    if not lplayer.Character then return end
    
    local charRoot = lplayer.Character:FindFirstChild("HumanoidRootPart")
    if not charRoot then return end

    -- Determinar objetivo actual (Raycast o Selección Manual)
    local seat, model = getRaycastVehicle()
    
    -- Si no hay raycast activo, usamos la selección manual si está válida
    if not seat and currentTargetSeat and currentTargetSeat.Parent then
        seat = currentTargetSeat
        model = getVehicleModelFromSeat(seat)
    end

    -- Validar distancia y existencia
    local isValid = false
    if seat and seat.Parent and model then
        local dist = (charRoot.Position - seat.Position).Magnitude
        if dist <= maxRange then
            isValid = true
            -- Actualizar InfoLabel solo si es selección por raycast o si cambia la info
            if seat == currentTargetSeat or not currentTargetSeat then
                 infoLabel.Text = string.format("%s\nDistancia: %d studs", model.Name, math.floor(dist))
                 infoLabel.TextColor3 = Color3.fromRGB(0, 162, 255)
            end
        end
    end

    -- Gestionar Highlight
    if isValid and currentTargetSeat == seat then
        -- Asegurar que el highlight existe en el modelo correcto
        if not currentHighlight or currentHighlight.Parent ~= model then
            if currentHighlight then currentHighlight:Destroy() end
            currentHighlight = Instance.new("Highlight")
            currentHighlight.Parent = model
            currentHighlight.OutlineColor = Color3.fromRGB(0, 162, 255)
            currentHighlight.FillTransparency = 0.8
            currentHighlight.OutlineTransparency = 0
        end
    else
        -- Destruir highlight si no es válido o cambia el objetivo
        if currentHighlight then 
            currentHighlight:Destroy() 
            currentHighlight = nil 
        end
        if not isValid and currentTargetSeat == seat then
             infoLabel.Text = "Fuera de rango"
             infoLabel.TextColor3 = Color3.fromRGB(150, 150, 150)
        end
    end
end)

-- Limpieza de Highlight al sentarse
lplayer.CharacterAdded:Connect(function(char)
    local hum = char:WaitForChild("Humanoid")
    hum.Seated:Connect(function(active, seatPart)
        if not active and currentHighlight then
            currentHighlight:Destroy()
            currentHighlight = nil
        end
    end)
end)

-- ==========================================
-- LÓGICA DE ABORDAJE (SMART FILTERING)
-- ==========================================
local function subirAlPiloto(targetSeat, forzarRobo)
    local character = lplayer.Character
    if not character then return end
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    if humanoid and targetSeat then
        -- Destruir highlight al abordar
        if currentHighlight then currentHighlight:Destroy() currentHighlight = nil end
        
        humanoid.Jump = true 
        humanoid.Sit = false
        task.wait(0.1)
        
        if targetSeat.Occupant and forzarRobo then
            for _, child in pairs(targetSeat.Parent:GetDescendants()) do
                if child:IsA("ClickDetector") then fireclickdetector(child)
                elseif child:IsA("ProximityPrompt") then fireproximityprompt(child) end
            end
            local currentDriver = targetSeat.Occupant
            if currentDriver and currentDriver:IsA("Humanoid") then currentDriver.Sit = false end
            task.wait(0.2) 
        end
        targetSeat:Sit(humanoid)
    end
end

btnSinConductor.MouseButton1Click:Connect(function()
    -- Smart Filtering: Solo si no hay ocupante
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
    -- Smart Filtering: Solo si hay ocupante
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
-- BOTONES DE ACCIÓN & OCULTAR/CERRAR
-- ==========================================

-- BOTÓN DE REAPERTURA (Minimizado)
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

-- CERRAR GUI COMPLETAMENTE
btnClose.MouseButton1Click:Connect(function()
    screenGui:Destroy()
end)

-- VELOCITY FLING (Mantenido)
btnCarFling.MouseButton1Click:Connect(function()
    local hum = lplayer.Character and lplayer.Character:FindFirstChildOfClass("Humanoid")
    local seat = hum and hum.SeatPart
    if seat and seat:IsA("VehicleSeat") then
        seat.AssemblyLinearVelocity = Vector3.new(0, 2000, 0) 
        seat.AssemblyAngularVelocity = Vector3.new(5000, 5000, 5000)
        task.wait(0.1)
        hum.Sit = false
    end
end)

-- Inicializar lista al inicio
populateVehicleList()