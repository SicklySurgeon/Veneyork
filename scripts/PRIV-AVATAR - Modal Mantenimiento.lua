-- ==========================================
-- MORPH AVATAR PRO - EN MANTENIMIENTO
-- Versión: 2.0.0
-- Desarrollador: @sickly255 (SAGE)
-- ==========================================

local SERVICES = {
	Players = game:GetService("Players"),
	CoreGui = game:GetService("CoreGui"),
}

local player = SERVICES.Players.LocalPlayer
local COLORS = {
	DARK_GRAY = Color3.fromRGB(35, 35, 35),
	WHITE = Color3.fromRGB(255, 255, 255),
	RED = Color3.fromRGB(200, 50, 50),
	ACCENT = Color3.fromRGB(100, 150, 255),
}

-- Determinar dónde poner la GUI
local guiParent = SERVICES.CoreGui
if not SERVICES.CoreGui or not pcall(function() return SERVICES.CoreGui:FindFirstChild("Dummy") end) then
	guiParent = player:FindFirstChild("PlayerGui")
	if not guiParent then
		guiParent = Instance.new("ScreenGui", player)
	end
end

-- Limpiar GUI anterior si existe
local existingGui = guiParent:FindFirstChild("MorphAvatarByKuramaMod")
if existingGui then
	existingGui:Destroy()
end

-- Crear nueva GUI
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "MorphAvatarByKuramaMod"
screenGui.ResetOnSpawn = false
screenGui.DisplayOrder = 999999
screenGui.Parent = guiParent

-- Marco Principal
local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 450, 0, 250)
frame.Position = UDim2.new(0.5, -225, 0.5, -125)
frame.BackgroundColor3 = COLORS.DARK_GRAY
frame.BorderSizePixel = 0
frame.Parent = screenGui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 12)
corner.Parent = frame

-- Barra de título con color de acento
local titleBar = Instance.new("Frame")
titleBar.Size = UDim2.new(1, 0, 0, 50)
titleBar.Position = UDim2.new(0, 0, 0, 0)
titleBar.BackgroundColor3 = COLORS.ACCENT
titleBar.BorderSizePixel = 0
titleBar.Parent = frame

local titleCorner = Instance.new("UICorner")
titleCorner.CornerRadius = UDim.new(0, 12)
titleCorner.Parent = titleBar

-- Título del Script
local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -80, 0, 50)
title.Position = UDim2.new(0, 15, 0, 0)
title.Text = "🎭 Morph Avatar Pro"
title.TextColor3 = COLORS.WHITE
title.BackgroundTransparency = 1
title.Font = Enum.Font.GothamBold
title.TextSize = 26
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = titleBar

-- Versión
local version = Instance.new("TextLabel")
version.Size = UDim2.new(1, -80, 0, 20)
version.Position = UDim2.new(0, 15, 0, 28)
version.Text = "Versión 2.0.0 - En Mantenimiento"
version.TextColor3 = COLORS.WHITE
version.TextTransparency = 0.3
version.BackgroundTransparency = 1
version.Font = Enum.Font.Gotham
version.TextSize = 14
version.TextXAlignment = Enum.TextXAlignment.Left
version.Parent = titleBar

-- Botón de Cerrar
local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0, 35, 0, 35)
closeBtn.Position = UDim2.new(1, -40, 0, 7.5)
closeBtn.Text = "X"
closeBtn.TextColor3 = COLORS.WHITE
closeBtn.BackgroundColor3 = COLORS.RED
closeBtn.BorderSizePixel = 0
closeBtn.Font = Enum.Font.GothamBold
closeBtn.TextSize = 18
closeBtn.Parent = titleBar

local btnCorner = Instance.new("UICorner")
btnCorner.CornerRadius = UDim.new(0, 6)
btnCorner.Parent = closeBtn

closeBtn.MouseButton1Click:Connect(function()
	screenGui:Destroy()
end)

-- Icono de mantenimiento
local maintenanceIcon = Instance.new("TextLabel")
maintenanceIcon.Size = UDim2.new(0, 80, 0, 80)
maintenanceIcon.Position = UDim2.new(0.5, -40, 0, 65)
maintenanceIcon.Text = "🚧"
maintenanceIcon.TextColor3 = COLORS.WHITE
maintenanceIcon.BackgroundTransparency = 1
maintenanceIcon.Font = Enum.Font.GothamBold
maintenanceIcon.TextSize = 60
maintenanceIcon.Parent = frame

-- Mensaje principal
local message = Instance.new("TextLabel")
message.Size = UDim2.new(1, -40, 0, 50)
message.Position = UDim2.new(0, 20, 0, 150)
message.Text = "El script está siendo actualizado.\nVuelve más tarde."
message.TextColor3 = COLORS.WHITE
message.TextTransparency = 0.2
message.BackgroundTransparency = 1
message.Font = Enum.Font.Gotham
message.TextSize = 18
message.TextWrapped = true
message.TextXAlignment = Enum.TextXAlignment.Center
message.Parent = frame

-- Créditos
local credits = Instance.new("TextLabel")
credits.Size = UDim2.new(1, -40, 0, 30)
credits.Position = UDim2.new(0, 20, 1, -35)
credits.Text = "Desarrollado por: @sickly255 (SAGE)"
credits.TextColor3 = COLORS.WHITE
credits.TextTransparency = 0.5
credits.BackgroundTransparency = 1
credits.Font = Enum.Font.Gotham
credits.TextSize = 12
credits.TextXAlignment = Enum.TextXAlignment.Center
credits.Parent = frame

-- Notificación inicial
pcall(function()
	game:GetService("StarterGui"):SetCore("SendNotification", {
		Title = "🎭 Morph Avatar Pro",
		Text = "Estado: En Mantenimiento | v2.0.0",
		Duration = 5
	})
end)