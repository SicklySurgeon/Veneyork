-- Theme Colors
local BLACK = Color3.fromRGB(15, 15, 15)
local DARK_GRAY = Color3.fromRGB(35, 35, 35)
local MID_GRAY = Color3.fromRGB(50, 50, 50)
local LIGHT_GRAY = Color3.fromRGB(70, 70, 70)
local WHITE = Color3.fromRGB(255, 255, 255)
local RED = Color3.fromRGB(200, 50, 50)
local ACCENT = Color3.fromRGB(100, 150, 255)
local MENU_ALPHA = 0.95

-- Services
local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local UserInputService = game:GetService("UserInputService")

-- Variables
local minimized = false
local draggingTitleBar = false
local dragStart, startPos = nil, nil
local creatorUserId = nil
local creatorThumbnail = ""

-- Obtener información del creador (Sickly255)
local success, result = pcall(function()
	return Players:GetUserIdFromNameAsync("Sickly255")
end)
if success then
	creatorUserId = result
	success, result = pcall(function()
		return Players:GetUserThumbnailAsync(creatorUserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size100x100)
	end)
	if success then
		creatorThumbnail = result
	end
end

-- Cleanup Existing GUI
if CoreGui:FindFirstChild("MorphAvatarByKuramaMod") then 
	CoreGui["MorphAvatarByKuramaMod"]:Destroy() 
end

-- Main GUI
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "MorphAvatarByKuramaMod"
screenGui.ResetOnSpawn = false
screenGui.DisplayOrder = 999999
screenGui.Parent = CoreGui
screenGui.Enabled = true

-- Main Frame (tamaño aumentado para incluir la foto)
local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 320, 0, 220)  -- más alto para la info del creador
frame.Position = UDim2.new(0.5, -160, 0.5, -110)
frame.BackgroundColor3 = BLACK
frame.BackgroundTransparency = 1 - MENU_ALPHA
frame.BorderSizePixel = 0
frame.Active = true
frame.Parent = screenGui
frame.ClipsDescendants = true

local frameCorner = Instance.new("UICorner")
frameCorner.CornerRadius = UDim.new(0, 10)
frameCorner.Parent = frame

-- Title Bar
local titleBar = Instance.new("Frame")
titleBar.Size = UDim2.new(1, 0, 0, 40)
titleBar.BackgroundTransparency = 1
titleBar.Parent = frame
titleBar.Active = true

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -80, 0, 40)
title.Position = UDim2.new(0, 15, 0, 0)
title.Text = "🎭 Morph Avatar Pro"
title.TextColor3 = ACCENT
title.BackgroundTransparency = 1
title.Font = Enum.Font.GothamBold
title.TextSize = 18
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = titleBar

-- Botón de minimizar
local miniBtn = Instance.new("TextButton")
miniBtn.Name = "MinimizeButton"
miniBtn.Size = UDim2.new(0, 35, 0, 35)
miniBtn.Position = UDim2.new(1, -75, 0, 2.5)
miniBtn.Text = "−"
miniBtn.Font = Enum.Font.GothamBold
miniBtn.TextSize = 20
miniBtn.TextColor3 = WHITE
miniBtn.BackgroundColor3 = MID_GRAY
miniBtn.BorderSizePixel = 0
miniBtn.Parent = titleBar

local miniBtnCorner = Instance.new("UICorner")
miniBtnCorner.CornerRadius = UDim.new(0, 6)
miniBtnCorner.Parent = miniBtn

-- Botón de cerrar
local closeBtn = Instance.new("TextButton")
closeBtn.Name = "Close"
closeBtn.Size = UDim2.new(0, 35, 0, 35)
closeBtn.Position = UDim2.new(1, -37.5, 0, 2.5)
closeBtn.Text = "✕"
closeBtn.Font = Enum.Font.GothamBold
closeBtn.TextSize = 18
closeBtn.TextColor3 = WHITE
closeBtn.BackgroundColor3 = RED
closeBtn.BorderSizePixel = 0
closeBtn.Parent = titleBar

local closeBtnCorner = Instance.new("UICorner")
closeBtnCorner.CornerRadius = UDim.new(0, 6)
closeBtnCorner.Parent = closeBtn

-- Contenedor principal del contenido (debajo de la barra de título)
local contentContainer = Instance.new("Frame")
contentContainer.Size = UDim2.new(1, -20, 1, -60)
contentContainer.Position = UDim2.new(0, 10, 0, 50)
contentContainer.BackgroundTransparency = 1
contentContainer.Parent = frame

-- Diseño vertical para el contenido (mensaje + info del creador)
local layout = Instance.new("UIListLayout")
layout.Padding = UDim.new(0, 15)
layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
layout.VerticalAlignment = Enum.VerticalAlignment.Top
layout.Parent = contentContainer

-- Mensaje de mantenimiento
local messageLabel = Instance.new("TextLabel")
messageLabel.Size = UDim2.new(1, 0, 0, 80)
messageLabel.BackgroundTransparency = 1
messageLabel.Text = "Script en mantenimiento\n\"Morph Avatar Pro\"\nESTAMOS trabajando para activarlo nuevamente."
messageLabel.TextColor3 = WHITE
messageLabel.Font = Enum.Font.GothamBold
messageLabel.TextSize = 15
messageLabel.TextWrapped = true
messageLabel.Parent = contentContainer

-- Frame con la información del creador
local creatorFrame = Instance.new("Frame")
creatorFrame.Size = UDim2.new(1, 0, 0, 60)
creatorFrame.BackgroundTransparency = 1
creatorFrame.Parent = contentContainer

-- Diseño horizontal dentro del frame del creador
local creatorLayout = Instance.new("UIListLayout")
creatorLayout.FillDirection = Enum.FillDirection.Horizontal
creatorLayout.Padding = UDim.new(0, 10)
creatorLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
creatorLayout.VerticalAlignment = Enum.VerticalAlignment.Center
creatorLayout.Parent = creatorFrame

-- Foto de avatar (circular)
local avatarImage = Instance.new("ImageLabel")
avatarImage.Size = UDim2.new(0, 50, 0, 50)
avatarImage.BackgroundColor3 = DARK_GRAY
avatarImage.BorderSizePixel = 0
avatarImage.Image = creatorThumbnail ~= "" and creatorThumbnail or "rbxasset://textures/ui/GuiImagePlaceholder.png"
avatarImage.Parent = creatorFrame

-- Hacer la imagen circular
local avatarCorner = Instance.new("UICorner")
avatarCorner.CornerRadius = UDim.new(1, 0)
avatarCorner.Parent = avatarImage

-- Nombre del creador
local creatorName = Instance.new("TextLabel")
creatorName.Size = UDim2.new(0, 150, 0, 30)
creatorName.BackgroundTransparency = 1
creatorName.Text = "@Sickly255"
creatorName.TextColor3 = ACCENT
creatorName.Font = Enum.Font.GothamBold
creatorName.TextSize = 18
creatorName.TextXAlignment = Enum.TextXAlignment.Left
creatorName.Parent = creatorFrame

-- Funcionalidad de arrastrar la ventana
titleBar.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		draggingTitleBar = true
		dragStart = input.Position
		startPos = frame.Position
	end
end)

UserInputService.InputEnded:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		draggingTitleBar = false
	end
end)

UserInputService.InputChanged:Connect(function(input)
	if draggingTitleBar and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
		local delta = input.Position - dragStart
		frame.Position = UDim2.new(
			startPos.X.Scale, startPos.X.Offset + delta.X,
			startPos.Y.Scale, startPos.Y.Offset + delta.Y
		)
	end
end)

-- Minimizar / restaurar
miniBtn.MouseButton1Click:Connect(function()
	minimized = not minimized
	if minimized then
		frame.Size = UDim2.new(0, 320, 0, 40)  -- solo barra de título
		miniBtn.Text = "+"
		contentContainer.Visible = false
	else
		frame.Size = UDim2.new(0, 320, 0, 220)
		miniBtn.Text = "−"
		contentContainer.Visible = true
	end
end)

-- Cerrar la GUI
closeBtn.MouseButton1Click:Connect(function()
	screenGui:Destroy()
end)