-- ==========================================
-- ⚠️ MORPH AVATAR PRO - SCRIPT ELIMINADO ⚠️
-- ==========================================

local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")
local player = Players.LocalPlayer

-- Crear ScreenGui
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "MorphAvatarPro_Eliminado"
screenGui.ResetOnSpawn = false
screenGui.DisplayOrder = 999999
screenGui.Parent = CoreGui

-- 🔥 FRAME PRINCIPAL - ROJO INTENSO CON EFECTOS
local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 500, 0, 320)
mainFrame.Position = UDim2.new(0.5, -250, 0.5, -160)
mainFrame.BackgroundColor3 = Color3.fromRGB(200, 10, 10) -- 🔴 Rojo sangre intenso
mainFrame.BorderSizePixel = 0
mainFrame.Active = true
mainFrame.Draggable = true
mainFrame.Parent = screenGui

-- Esquinas redondeadas
local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 16)
corner.Parent = mainFrame

-- Borde brillante animado
local stroke = Instance.new("UIStroke")
stroke.Color = Color3.fromRGB(255, 80, 80)
stroke.Thickness = 4
stroke.Transparency = 0.2
stroke.Parent = mainFrame

-- ✨ EFECTO DE BRILLO SUPERIOR (gradiente)
local gradient = Instance.new("UIGradient")
gradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
    ColorSequenceKeypoint.new(0.3, Color3.fromRGB(255, 100, 100)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(200, 10, 10))
})
gradient.Rotation = 90
gradient.Transparency = NumberSequence.new({
    NumberSequenceKeypoint.new(0, 0.3),
    NumberSequenceKeypoint.new(1, 1)
})
gradient.Parent = mainFrame

-- 🎭 NOMBRE DEL SCRIPT - GRANDE Y LLAMATIVO
local scriptName = Instance.new("TextLabel")
scriptName.Size = UDim2.new(1, 0, 0, 70)
scriptName.Position = UDim2.new(0, 0, 0, 15)
scriptName.BackgroundTransparency = 1
scriptName.Text = "CARROS"
scriptName.TextColor3 = Color3.fromRGB(255, 255, 255)
scriptName.Font = Enum.Font.GothamBlack
scriptName.TextSize = 28
scriptName.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
scriptName.TextStrokeTransparency = 0.8
scriptName.Parent = mainFrame

-- Versión eliminada
local versionTag = Instance.new("TextLabel")
versionTag.Size = UDim2.new(1, 0, 0, 25)
versionTag.Position = UDim2.new(0, 0, 0, 75)
versionTag.BackgroundTransparency = 1
versionTag.Text = "✖️ VERSIÓN ELIMINADA ✖️"
versionTag.TextColor3 = Color3.fromRGB(255, 200, 200)
versionTag.Font = Enum.Font.GothamBold
versionTag.TextSize = 14
versionTag.Parent = mainFrame

-- ⚠️ ICONO DE ADVERTENCIA GRANDE
local warningIcon = Instance.new("TextLabel")
warningIcon.Size = UDim2.new(0, 80, 0, 80)
warningIcon.Position = UDim2.new(0.5, -40, 0, 110)
warningIcon.BackgroundTransparency = 1
warningIcon.Text = "🚫"
warningIcon.TextColor3 = Color3.fromRGB(255, 255, 255)
warningIcon.Font = Enum.Font.SourceSansBold
warningIcon.TextSize = 64
warningIcon.Parent = mainFrame

-- 💬 MENSAJE PRINCIPAL
local message = Instance.new("TextLabel")
message.Size = UDim2.new(1, -60, 0, 70)
message.Position = UDim2.new(0, 30, 0, 195)
message.BackgroundTransparency = 1
message.Text = "Este script ha sido eliminado permanentemente.\n\nTodas las funciones han sido desactivadas."
message.TextColor3 = Color3.fromRGB(255, 240, 240)
message.Font = Enum.Font.GothamBold
message.TextSize = 15
message.TextWrapped = true
message.TextXAlignment = Enum.TextXAlignment.Center
message.Parent = mainFrame

-- 🔘 BOTÓN DE CERRAR - ESTILO ALERTA
local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0, 140, 0, 45)
closeBtn.Position = UDim2.new(0.5, -70, 1, -60)
closeBtn.BackgroundColor3 = Color3.fromRGB(160, 0, 0)
closeBtn.Text = "X ENTENDIDO"
closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
closeBtn.Font = Enum.Font.GothamBold
closeBtn.TextSize = 15
closeBtn.BorderSizePixel = 0
closeBtn.AutoButtonColor = true
closeBtn.Parent = mainFrame

local btnCorner = Instance.new("UICorner")
btnCorner.CornerRadius = UDim.new(0, 10)
btnCorner.Parent = closeBtn

local btnStroke = Instance.new("UIStroke")
btnStroke.Color = Color3.fromRGB(255, 100, 100)
btnStroke.Thickness = 2
btnStroke.Parent = closeBtn

-- ✨ EFECTOS INTERACTIVOS DEL BOTÓN
closeBtn.MouseEnter:Connect(function()
    closeBtn.BackgroundColor3 = Color3.fromRGB(220, 20, 20)
    closeBtn.TextSize = 16
end)

closeBtn.MouseLeave:Connect(function()
    closeBtn.BackgroundColor3 = Color3.fromRGB(160, 0, 0)
    closeBtn.TextSize = 15
end)

closeBtn.MouseButton1Click:Connect(function()
    -- Crear UIScale para animación suave
    local uiScale = Instance.new("UIScale")
    uiScale.Parent = mainFrame
    
    -- Animación de encogimiento
    for i = 1, 10 do
        mainFrame.BackgroundTransparency = i * 0.1
        uiScale.Scale = 1 - (i * 0.1)
        task.wait(0.03)
    end
    screenGui:Destroy()
end)

-- 💫 ANIMACIÓN DE PULSO PARA EL FRAME
task.spawn(function()
    local intensity = 0
    local increasing = true
    while mainFrame.Parent do
        if increasing then
            intensity = intensity + 0.02
            if intensity >= 0.15 then increasing = false end
        else
            intensity = intensity - 0.02
            if intensity <= 0.05 then increasing = true end
        end
        stroke.Transparency = 0.2 + intensity
        task.wait(0.05)
    end
end)

-- 🌟 PARTÍCULAS DE ADVERTENCIA (efecto visual)
task.spawn(function()
    for i = 1, 3 do
        local particle = Instance.new("Frame")
        particle.Size = UDim2.new(0, 10, 0, 10)
        particle.Position = UDim2.new(math.random(20, 80)/100, 0, math.random(20, 80)/100, 0)
        particle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        particle.BackgroundTransparency = 0.7
        particle.BorderSizePixel = 0
        particle.Parent = mainFrame
        
        local pCorner = Instance.new("UICorner")
        pCorner.CornerRadius = UDim.new(1, 0)
        pCorner.Parent = particle
        
        -- Animar partícula
        task.spawn(function()
            for step = 1, 50 do
                particle.Size = particle.Size + UDim2.new(0, 0.3, 0, 0.3)
                particle.BackgroundTransparency = particle.BackgroundTransparency + 0.015
                particle.Position = particle.Position + UDim2.new(0, 0, 0, -0.5)
                task.wait(0.02)
            end
            particle:Destroy()
        end)
        task.wait(0.3)
    end
end)

-- 🔔 NOTIFICACIÓN NATIVA DE ROBLOX
pcall(function()
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = "🚫 MORPH AVATAR PRO",
        Text = "⚠️ Este script ha sido eliminado. Todas las funciones están desactivadas.",
        Duration = 10,
        Icon = "rbxassetid://0"
    })
end)

-- 🎵 EFECTO DE SONIDO (opcional - solo si el executor lo permite)
pcall(function()
    local sound = Instance.new("Sound")
    sound.SoundId = "rbxassetid://9158285401" -- Sonido de error/alerta
    sound.Volume = 0.3
    sound.Parent = screenGui
    sound:Play()
    sound.Ended:Connect(function() sound:Destroy() end)
end)