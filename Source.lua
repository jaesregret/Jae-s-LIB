local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local LocalPlayer = game:GetService("Players").LocalPlayer
local Mouse = LocalPlayer:GetMouse()
local HttpService = game:GetService("HttpService")

local OrionLib = {
	Elements = {},
	ThemeObjects = {},
	Connections = {},
	Flags = {},
	Themes = {
		Default = {
			Main = Color3.fromRGB(16, 16, 20),
			Second = Color3.fromRGB(22, 22, 28),
			Stroke = Color3.fromRGB(40, 40, 50),
			Divider = Color3.fromRGB(30, 30, 38),
			Text = Color3.fromRGB(240, 240, 245),
			TextDark = Color3.fromRGB(130, 130, 145),
			Accent = Color3.fromRGB(88, 101, 242)
		},
		Dark = {
			Main = Color3.fromRGB(12, 12, 14),
			Second = Color3.fromRGB(18, 18, 22),
			Stroke = Color3.fromRGB(36, 36, 44),
			Divider = Color3.fromRGB(28, 28, 34),
			Text = Color3.fromRGB(235, 235, 240),
			TextDark = Color3.fromRGB(120, 120, 135),
			Accent = Color3.fromRGB(100, 110, 255)
		},
		Midnight = {
			Main = Color3.fromRGB(10, 12, 20),
			Second = Color3.fromRGB(14, 16, 26),
			Stroke = Color3.fromRGB(28, 32, 48),
			Divider = Color3.fromRGB(22, 26, 40),
			Text = Color3.fromRGB(230, 235, 250),
			TextDark = Color3.fromRGB(110, 120, 150),
			Accent = Color3.fromRGB(70, 130, 255)
		},
		Purple = {
			Main = Color3.fromRGB(16, 12, 22),
			Second = Color3.fromRGB(22, 16, 30),
			Stroke = Color3.fromRGB(44, 34, 56),
			Divider = Color3.fromRGB(36, 28, 46),
			Text = Color3.fromRGB(240, 235, 250),
			TextDark = Color3.fromRGB(140, 125, 160),
			Accent = Color3.fromRGB(160, 100, 255)
		},
		Green = {
			Main = Color3.fromRGB(12, 16, 14),
			Second = Color3.fromRGB(16, 22, 18),
			Stroke = Color3.fromRGB(32, 44, 36),
			Divider = Color3.fromRGB(26, 36, 30),
			Text = Color3.fromRGB(235, 245, 240),
			TextDark = Color3.fromRGB(120, 145, 130),
			Accent = Color3.fromRGB(70, 200, 120)
		}
	},
	SelectedTheme = "Default",
	Folder = nil,
	SaveCfg = false
}

local Icons = {}
pcall(function()
	Icons = HttpService:JSONDecode(game:HttpGetAsync("https://raw.githubusercontent.com/evoincorp/lucideblox/master/src/modules/util/icons.json")).icons
end)

local function GetIcon(IconName)
	return Icons[IconName]
end

local Orion = Instance.new("ScreenGui")
Orion.Name = "Orion"
if syn then
	syn.protect_gui(Orion)
	Orion.Parent = game.CoreGui
else
	Orion.Parent = gethui and gethui() or game.CoreGui
end

for _, Interface in ipairs((gethui and gethui() or game.CoreGui):GetChildren()) do
	if Interface.Name == Orion.Name and Interface ~= Orion then
		Interface:Destroy()
	end
end

function OrionLib:IsRunning()
	return Orion.Parent ~= nil
end

local function AddConnection(Signal, Function)
	if not OrionLib:IsRunning() then return end
	local Conn = Signal:Connect(Function)
	table.insert(OrionLib.Connections, Conn)
	return Conn
end

task.spawn(function()
	while OrionLib:IsRunning() do task.wait(1) end
	for _, Conn in next, OrionLib.Connections do
		Conn:Disconnect()
	end
end)

local function Create(Name, Properties, Children)
	local Object = Instance.new(Name)
	for i, v in next, Properties or {} do
		Object[i] = v
	end
	for _, v in next, Children or {} do
		v.Parent = Object
	end
	return Object
end

local function CreateElement(ElementName, ElementFunction)
	OrionLib.Elements[ElementName] = function(...)
		return ElementFunction(...)
	end
end

local function MakeElement(ElementName, ...)
	return OrionLib.Elements[ElementName](...)
end

local function SetProps(Element, Props)
	for Property, Value in next, Props do
		Element[Property] = Value
	end
	return Element
end

local function SetChildren(Element, Children)
	for _, Child in next, Children do
		Child.Parent = Element
	end
	return Element
end

local function Round(Number, Factor)
	local Result = math.floor(Number / Factor + (math.sign(Number) * 0.5)) * Factor
	if Result < 0 then Result = Result + Factor end
	return Result
end

local function ReturnProperty(Object)
	if Object:IsA("Frame") or Object:IsA("TextButton") then
		return "BackgroundColor3"
	elseif Object:IsA("ScrollingFrame") then
		return "ScrollBarImageColor3"
	elseif Object:IsA("UIStroke") then
		return "Color"
	elseif Object:IsA("TextLabel") or Object:IsA("TextBox") then
		return "TextColor3"
	elseif Object:IsA("ImageLabel") or Object:IsA("ImageButton") then
		return "ImageColor3"
	end
end

local function AddThemeObject(Object, Type)
	if not OrionLib.ThemeObjects[Type] then
		OrionLib.ThemeObjects[Type] = {}
	end
	table.insert(OrionLib.ThemeObjects[Type], Object)
	local Theme = OrionLib.Themes[OrionLib.SelectedTheme]
	if Theme[Type] then
		Object[ReturnProperty(Object)] = Theme[Type]
	end
	return Object
end

local function SetTheme()
	local Theme = OrionLib.Themes[OrionLib.SelectedTheme]
	for Name, Objects in pairs(OrionLib.ThemeObjects) do
		if Theme[Name] then
			for _, Object in pairs(Objects) do
				local Prop = ReturnProperty(Object)
				if Prop then
					TweenService:Create(Object, TweenInfo.new(0.65, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
						[Prop] = Theme[Name]
					}):Play()
				end
			end
		end
	end
end

function OrionLib:SetTheme(ThemeName)
	if OrionLib.Themes[ThemeName] then
		OrionLib.SelectedTheme = ThemeName
		SetTheme()
	end
end

function OrionLib:CreateTheme(Name, Colors)
	OrionLib.Themes[Name] = Colors
end

function OrionLib:ChangeThemeColor(ColorType, NewColor)
	local Theme = OrionLib.Themes[OrionLib.SelectedTheme]
	if Theme[ColorType] then
		Theme[ColorType] = NewColor
		SetTheme()
	end
end

local function PackColor(Color)
	return {R = Color.R * 255, G = Color.G * 255, B = Color.B * 255}
end

local function UnpackColor(Color)
	return Color3.fromRGB(Color.R, Color.G, Color.B)
end

local function LoadCfg(Config)
	local Data = HttpService:JSONDecode(Config)
	for a, b in pairs(Data) do
		if OrionLib.Flags[a] then
			task.spawn(function()
				if OrionLib.Flags[a].Type == "Colorpicker" then
					OrionLib.Flags[a]:Set(UnpackColor(b))
				else
					OrionLib.Flags[a]:Set(b)
				end
			end)
		end
	end
end

local function SaveCfg(Name)
	if not OrionLib.SaveCfg then return end
	local Data = {}
	for i, v in pairs(OrionLib.Flags) do
		if v.Save then
			Data[i] = v.Type == "Colorpicker" and PackColor(v.Value) or v.Value
		end
	end
	writefile(OrionLib.Folder .. "/" .. Name .. ".txt", HttpService:JSONEncode(Data))
end

local WhitelistedMouse = {Enum.UserInputType.MouseButton1, Enum.UserInputType.MouseButton2, Enum.UserInputType.MouseButton3}
local BlacklistedKeys = {Enum.KeyCode.Unknown, Enum.KeyCode.W, Enum.KeyCode.A, Enum.KeyCode.S, Enum.KeyCode.D, Enum.KeyCode.Up, Enum.KeyCode.Left, Enum.KeyCode.Down, Enum.KeyCode.Right, Enum.KeyCode.Slash, Enum.KeyCode.Tab, Enum.KeyCode.Backspace, Enum.KeyCode.Escape}

local function CheckKey(Table, Key)
	for _, v in next, Table do
		if v == Key then return true end
	end
	return false
end

CreateElement("Corner", function(Scale, Offset)
	return Create("UICorner", {CornerRadius = UDim.new(Scale or 0, Offset or 8)})
end)

CreateElement("Stroke", function(Color, Thickness)
	return Create("UIStroke", {
		Color = Color or Color3.fromRGB(255, 255, 255),
		Thickness = Thickness or 1
	})
end)

CreateElement("List", function(Scale, Offset)
	return Create("UIListLayout", {
		SortOrder = Enum.SortOrder.LayoutOrder,
		Padding = UDim.new(Scale or 0, Offset or 0)
	})
end)

CreateElement("Padding", function(Bottom, Left, Right, Top)
	return Create("UIPadding", {
		PaddingBottom = UDim.new(0, Bottom or 4),
		PaddingLeft = UDim.new(0, Left or 4),
		PaddingRight = UDim.new(0, Right or 4),
		PaddingTop = UDim.new(0, Top or 4)
	})
end)

CreateElement("TFrame", function()
	return Create("Frame", {BackgroundTransparency = 1})
end)

CreateElement("Frame", function(Color)
	return Create("Frame", {
		BackgroundColor3 = Color or Color3.fromRGB(255, 255, 255),
		BorderSizePixel = 0
	})
end)

CreateElement("RoundFrame", function(Color, Scale, Offset)
	return Create("Frame", {
		BackgroundColor3 = Color or Color3.fromRGB(255, 255, 255),
		BorderSizePixel = 0
	}, {
		Create("UICorner", {CornerRadius = UDim.new(Scale or 0, Offset or 8)})
	})
end)

CreateElement("Button", function()
	return Create("TextButton", {
		Text = "",
		AutoButtonColor = false,
		BackgroundTransparency = 1,
		BorderSizePixel = 0
	})
end)

CreateElement("ScrollFrame", function(Color, Width)
	return Create("ScrollingFrame", {
		BackgroundTransparency = 1,
		MidImage = "rbxassetid://7445543667",
		BottomImage = "rbxassetid://7445543667",
		TopImage = "rbxassetid://7445543667",
		ScrollBarImageColor3 = Color,
		BorderSizePixel = 0,
		ScrollBarThickness = Width,
		CanvasSize = UDim2.new(0, 0, 0, 0)
	})
end)

CreateElement("Image", function(ImageID)
	local Img = Create("ImageLabel", {
		Image = ImageID,
		BackgroundTransparency = 1
	})
	local Icon = GetIcon(ImageID)
	if Icon then Img.Image = Icon end
	return Img
end)

CreateElement("Label", function(Text, TextSize, Transparency)
	return Create("TextLabel", {
		Text = Text or "",
		TextColor3 = Color3.fromRGB(240, 240, 245),
		TextTransparency = Transparency or 0,
		TextSize = TextSize or 14,
		Font = Enum.Font.Gotham,
		RichText = true,
		BackgroundTransparency = 1,
		TextXAlignment = Enum.TextXAlignment.Left
	})
end)

local function AddDraggingFunctionality(DragPoint, Main)
	local Dragging, DragInput, MousePos, FramePos
	DragPoint.InputBegan:Connect(function(Input)
		if Input.UserInputType == Enum.UserInputType.MouseButton1 then
			Dragging = true
			MousePos = Input.Position
			FramePos = Main.Position
			Input.Changed:Connect(function()
				if Input.UserInputState == Enum.UserInputState.End then
					Dragging = false
				end
			end)
		end
	end)
	DragPoint.InputChanged:Connect(function(Input)
		if Input.UserInputType == Enum.UserInputType.MouseMovement then
			DragInput = Input
		end
	end)
	UserInputService.InputChanged:Connect(function(Input)
		if Input == DragInput and Dragging then
			local Delta = Input.Position - MousePos
			TweenService:Create(Main, TweenInfo.new(0.35, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
				Position = UDim2.new(FramePos.X.Scale, FramePos.X.Offset + Delta.X, FramePos.Y.Scale, FramePos.Y.Offset + Delta.Y)
			}):Play()
		end
	end)
end

local function AddResizeFunctionality(Main, MinSize)
	MinSize = MinSize or Vector2.new(480, 280)

	local ResizeHandle = SetProps(MakeElement("Image", "rbxassetid://6031094670"), {
		Size = UDim2.new(0, 16, 0, 16),
		Position = UDim2.new(1, -20, 1, -20),
		BackgroundTransparency = 1,
		ImageColor3 = Color3.fromRGB(160, 160, 175),
		ImageTransparency = 0.4,
		ZIndex = 15,
		Parent = Main
	})

	local Resizing = false
	local StartMouse, StartSize

	ResizeHandle.MouseEnter:Connect(function()
		TweenService:Create(ResizeHandle, TweenInfo.new(0.2), {
			ImageTransparency = 0,
			ImageColor3 = Color3.fromRGB(230, 230, 240)
		}):Play()
	end)

	ResizeHandle.MouseLeave:Connect(function()
		if not Resizing then
			TweenService:Create(ResizeHandle, TweenInfo.new(0.2), {
				ImageTransparency = 0.4,
				ImageColor3 = Color3.fromRGB(160, 160, 175)
			}):Play()
		end
	end)

	ResizeHandle.InputBegan:Connect(function(Input)
		if Input.UserInputType == Enum.UserInputType.MouseButton1 then
			Resizing = true
			StartMouse = Input.Position
			StartSize = Main.AbsoluteSize
			Input.Changed:Connect(function()
				if Input.UserInputState == Enum.UserInputState.End then
					Resizing = false
					TweenService:Create(ResizeHandle, TweenInfo.new(0.2), {
						ImageTransparency = 0.4,
						ImageColor3 = Color3.fromRGB(160, 160, 175)
					}):Play()
				end
			end)
		end
	end)

	UserInputService.InputChanged:Connect(function(Input)
		if Resizing and Input.UserInputType == Enum.UserInputType.MouseMovement then
			local Delta = Input.Position - StartMouse
			local NewX = math.max(MinSize.X, StartSize.X + Delta.X)
			local NewY = math.max(MinSize.Y, StartSize.Y + Delta.Y)
			Main.Size = UDim2.new(0, NewX, 0, NewY)
		end
	end)
end

local NotificationHolder = SetProps(SetChildren(MakeElement("TFrame"), {
	SetProps(MakeElement("List"), {
		HorizontalAlignment = Enum.HorizontalAlignment.Center,
		SortOrder = Enum.SortOrder.LayoutOrder,
		VerticalAlignment = Enum.VerticalAlignment.Bottom,
		Padding = UDim.new(0, 6)
	})
}), {
	Position = UDim2.new(1, -25, 1, -25),
	Size = UDim2.new(0, 300, 1, -25),
	AnchorPoint = Vector2.new(1, 1),
	Parent = Orion
})

function OrionLib:MakeNotification(NotificationConfig)
	task.spawn(function()
		NotificationConfig.Name = NotificationConfig.Name or "Notification"
		NotificationConfig.Content = NotificationConfig.Content or "Test"
		NotificationConfig.Image = NotificationConfig.Image or "rbxassetid://4384403532"
		NotificationConfig.Time = NotificationConfig.Time or 5

		local NotificationParent = SetProps(MakeElement("TFrame"), {
			Size = UDim2.new(1, 0, 0, 0),
			AutomaticSize = Enum.AutomaticSize.Y,
			Parent = NotificationHolder
		})

		local NotificationFrame = SetChildren(SetProps(MakeElement("RoundFrame", Color3.fromRGB(18, 18, 24), 0, 8), {
			Parent = NotificationParent,
			Size = UDim2.new(1, 0, 0, 0),
			Position = UDim2.new(1, -50, 0, 0),
			AutomaticSize = Enum.AutomaticSize.Y
		}), {
			MakeElement("Stroke", Color3.fromRGB(45, 45, 55), 1),
			MakeElement("Padding", 12, 12, 12, 12),
			SetProps(MakeElement("Image", NotificationConfig.Image), {
				Size = UDim2.new(0, 18, 0, 18),
				ImageColor3 = Color3.fromRGB(240, 240, 245),
				Name = "Icon"
			}),
			SetProps(MakeElement("Label", NotificationConfig.Name, 14), {
				Size = UDim2.new(1, -28, 0, 18),
				Position = UDim2.new(0, 28, 0, 0),
				Font = Enum.Font.GothamBold,
				Name = "Title"
			}),
			SetProps(MakeElement("Label", NotificationConfig.Content, 13), {
				Size = UDim2.new(1, 0, 0, 0),
				Position = UDim2.new(0, 0, 0, 22),
				Font = Enum.Font.Gotham,
				Name = "Content",
				AutomaticSize = Enum.AutomaticSize.Y,
				TextColor3 = Color3.fromRGB(180, 180, 195),
				TextWrapped = true
			})
		})

		TweenService:Create(NotificationFrame, TweenInfo.new(0.4, Enum.EasingStyle.Quint), {Position = UDim2.new(0, 0, 0, 0)}):Play()
		task.wait(NotificationConfig.Time - 0.7)
		TweenService:Create(NotificationFrame, TweenInfo.new(0.5, Enum.EasingStyle.Quint), {BackgroundTransparency = 0.7}):Play()
		TweenService:Create(NotificationFrame.Icon, TweenInfo.new(0.4, Enum.EasingStyle.Quint), {ImageTransparency = 1}):Play()
		TweenService:Create(NotificationFrame.Title, TweenInfo.new(0.4, Enum.EasingStyle.Quint), {TextTransparency = 0.5}):Play()
		TweenService:Create(NotificationFrame.Content, TweenInfo.new(0.4, Enum.EasingStyle.Quint), {TextTransparency = 0.6}):Play()
		task.wait(0.2)
		NotificationFrame:TweenPosition(UDim2.new(1, 20, 0, 0), "In", "Quint", 0.55, true)
		task.wait(0.7)
		NotificationFrame:Destroy()
	end)
end

function OrionLib:Init()
	if OrionLib.SaveCfg then
		pcall(function()
			if isfile(OrionLib.Folder .. "/" .. game.GameId .. ".txt") then
				LoadCfg(readfile(OrionLib.Folder .. "/" .. game.GameId .. ".txt"))
				OrionLib:MakeNotification({
					Name = "Configuration",
					Content = "Config loaded for game " .. game.GameId,
					Time = 4
				})
			end
		end)
	end
end

function OrionLib:MakeWindow(WindowConfig)
	local FirstTab = true
	local Minimized = false
	local UIHidden = false
	local CurrentSize = UDim2.new(0, 615, 0, 420)

	WindowConfig = WindowConfig or {}
	WindowConfig.Name = WindowConfig.Name or "Orion Library"
	WindowConfig.ConfigFolder = WindowConfig.ConfigFolder or WindowConfig.Name
	WindowConfig.SaveConfig = WindowConfig.SaveConfig or false
	WindowConfig.HidePremium = WindowConfig.HidePremium or false
	WindowConfig.IntroEnabled = WindowConfig.IntroEnabled ~= false
	WindowConfig.IntroText = WindowConfig.IntroText or "Orion Library"
	WindowConfig.CloseCallback = WindowConfig.CloseCallback or function() end
	WindowConfig.ShowIcon = WindowConfig.ShowIcon or false
	WindowConfig.Icon = WindowConfig.Icon or "rbxassetid://8834748103"
	WindowConfig.IntroIcon = WindowConfig.IntroIcon or "rbxassetid://8834748103"
	OrionLib.Folder = WindowConfig.ConfigFolder
	OrionLib.SaveCfg = WindowConfig.SaveConfig
	WindowConfig.Background = WindowConfig.Background or nil
	WindowConfig.BackgroundTransparency = WindowConfig.BackgroundTransparency or 0.4

	if WindowConfig.SaveConfig and not isfolder(WindowConfig.ConfigFolder) then
		makefolder(WindowConfig.ConfigFolder)
	end

	local TabHolder = AddThemeObject(SetChildren(SetProps(MakeElement("ScrollFrame", Color3.fromRGB(255, 255, 255), 3), {
		Size = UDim2.new(1, 0, 1, -50),
		CanvasSize = UDim2.new(0, 0, 0, 0),
		ScrollBarThickness = 2,
		ScrollBarImageColor3 = Color3.fromRGB(60, 60, 75)
	}), {
		MakeElement("List", 0, 2),
		MakeElement("Padding", 4, 6, 6, 4)
	}), "Divider")

	AddConnection(TabHolder.UIListLayout:GetPropertyChangedSignal("AbsoluteContentSize"), function()
		TabHolder.CanvasSize = UDim2.new(0, 0, 0, TabHolder.UIListLayout.AbsoluteContentSize.Y + 16)
	end)

	local CloseBtn = SetChildren(SetProps(MakeElement("Button"), {
		Size = UDim2.new(0.5, 0, 1, 0),
		Position = UDim2.new(0.5, 0, 0, 0),
		BackgroundTransparency = 1
	}), {
		AddThemeObject(SetProps(MakeElement("Image", "rbxassetid://7072725342"), {
			Position = UDim2.new(0, 9, 0, 6),
			Size = UDim2.new(0, 16, 0, 16)
		}), "Text")
	})

	local MinimizeBtn = SetChildren(SetProps(MakeElement("Button"), {
		Size = UDim2.new(0.5, 0, 1, 0),
		BackgroundTransparency = 1
	}), {
		AddThemeObject(SetProps(MakeElement("Image", "rbxassetid://7072719338"), {
			Position = UDim2.new(0, 9, 0, 6),
			Size = UDim2.new(0, 16, 0, 16),
			Name = "Ico"
		}), "Text")
	})

	local DragPoint = SetProps(MakeElement("TFrame"), {
		Size = UDim2.new(1, 0, 0, 44)
	})

	local WindowStuff = AddThemeObject(SetChildren(SetProps(MakeElement("RoundFrame", Color3.fromRGB(255, 255, 255), 0, 6), {
		Size = UDim2.new(0, 160, 1, -44),
		Position = UDim2.new(0, 0, 0, 44),
		BackgroundTransparency = 0.35
	}), {
		AddThemeObject(SetProps(MakeElement("Frame"), {
			Size = UDim2.new(1, 0, 0, 6),
			Position = UDim2.new(0, 0, 0, 0),
			BackgroundTransparency = 0.35
		}), "Second"),
		AddThemeObject(SetProps(MakeElement("Frame"), {
			Size = UDim2.new(0, 6, 1, 0),
			Position = UDim2.new(1, -6, 0, 0),
			BackgroundTransparency = 0.35
		}), "Second"),
		AddThemeObject(SetProps(MakeElement("Frame"), {
			Size = UDim2.new(0, 1, 1, 0),
			Position = UDim2.new(1, -1, 0, 0)
		}), "Stroke"),
		TabHolder,
		SetChildren(SetProps(MakeElement("TFrame"), {
			Size = UDim2.new(1, 0, 0, 44),
			Position = UDim2.new(0, 0, 1, -44)
		}), {
			AddThemeObject(SetProps(MakeElement("Frame"), {
				Size = UDim2.new(1, 0, 0, 1)
			}), "Stroke"),
			AddThemeObject(SetChildren(SetProps(MakeElement("Frame"), {
				AnchorPoint = Vector2.new(0, 0.5),
				Size = UDim2.new(0, 28, 0, 28),
				Position = UDim2.new(0, 8, 0.5, 0)
			}), {
				SetProps(MakeElement("Image", "https://www.roblox.com/headshot-thumbnail/image?userId=" .. LocalPlayer.UserId .. "&width=420&height=420&format=png"), {
					Size = UDim2.new(1, 0, 1, 0)
				}),
				AddThemeObject(SetProps(MakeElement("Image", "rbxassetid://4031889928"), {
					Size = UDim2.new(1, 0, 1, 0)
				}), "Second"),
				MakeElement("Corner", 1)
			}), "Divider"),
			AddThemeObject(SetProps(MakeElement("Label", LocalPlayer.DisplayName, 12), {
				Size = UDim2.new(1, -44, 0, 12),
				Position = UDim2.new(0, 44, 0, 14),
				Font = Enum.Font.GothamSemibold,
				ClipsDescendants = true
			}), "Text"),
			AddThemeObject(SetProps(MakeElement("Label", "Player", 10), {
				Size = UDim2.new(1, -44, 0, 10),
				Position = UDim2.new(0, 44, 0, 28),
				Visible = not WindowConfig.HidePremium
			}), "TextDark")
		})
	}), "Second")

	local WindowName = AddThemeObject(SetProps(MakeElement("Label", WindowConfig.Name, 15), {
		Size = UDim2.new(1, -30, 2, 0),
		Position = UDim2.new(0, 16, 0, -20),
		Font = Enum.Font.GothamBlack,
		TextSize = 17
	}), "Text")

	local WindowTopBarLine = AddThemeObject(SetProps(MakeElement("Frame"), {
		Size = UDim2.new(1, 0, 0, 1),
		Position = UDim2.new(0, 0, 1, -1)
	}), "Stroke")

	local MainWindow = AddThemeObject(SetChildren(SetProps(MakeElement("RoundFrame", Color3.fromRGB(255, 255, 255), 0, 8), {
	Parent = Orion,
	Position = UDim2.new(0.5, -307, 0.5, -210),
	Size = CurrentSize,
	ClipsDescendants = true,
	BackgroundTransparency = 0.05
}), {
	SetChildren(SetProps(MakeElement("TFrame"), {
		Size = UDim2.new(1, 0, 0, 44),
		Name = "TopBar",
		BackgroundTransparency = 1
	}), {
		AddThemeObject(SetProps(MakeElement("Frame"), {
			Size = UDim2.new(1, 0, 0, 1),
			Position = UDim2.new(0, 0, 1, 0)
		}), "Stroke"),
		WindowName,
		WindowTopBarLine,
		AddThemeObject(SetChildren(SetProps(MakeElement("RoundFrame", Color3.fromRGB(255, 255, 255), 0, 6), {
			Size = UDim2.new(0, 64, 0, 26),
			Position = UDim2.new(1, -76, 0, 9)
		}), {
			AddThemeObject(MakeElement("Stroke"), "Stroke"),
			AddThemeObject(SetProps(MakeElement("Frame"), {
				Size = UDim2.new(0, 1, 1, 0),
				Position = UDim2.new(0.5, 0, 0, 0)
			}), "Stroke"),
			CloseBtn,
			MinimizeBtn
		}), "Second")
	}),
	DragPoint,
	WindowStuff
}), "Main")

	if WindowConfig.ShowIcon then
		WindowName.Position = UDim2.new(0, 44, 0, -20)
		local WindowIcon = SetProps(MakeElement("Image", WindowConfig.Icon), {
			Size = UDim2.new(0, 16, 0, 16),
			Position = UDim2.new(0, 16, 0, 14)
		})
		WindowIcon.Parent = MainWindow.TopBar
	end

	AddDraggingFunctionality(DragPoint, MainWindow)
	AddResizeFunctionality(MainWindow, Vector2.new(480, 320))

		if WindowConfig.Background then
		SetProps(MakeElement("Image", WindowConfig.Background), {
			Size = UDim2.new(1, 0, 1, 0),
			Position = UDim2.new(0, 0, 0, 0),
			BackgroundTransparency = 1,
			ImageTransparency = WindowConfig.BackgroundTransparency,
			ScaleType = Enum.ScaleType.Crop,
			ZIndex = 0,
			Parent = MainWindow
		})
	end

	AddConnection(CloseBtn.MouseButton1Up, function()
		MainWindow.Visible = false
		UIHidden = true
		OrionLib:MakeNotification({
			Name = "Interface Hidden",
			Content = "Press RightShift to reopen",
			Time = 4
		})
		WindowConfig.CloseCallback()
	end)

	AddConnection(UserInputService.InputBegan, function(Input)
		if Input.KeyCode == Enum.KeyCode.RightShift and UIHidden then
			MainWindow.Visible = true
			UIHidden = false
		end
	end)

	AddConnection(MinimizeBtn.MouseButton1Up, function()
		if Minimized then
			TweenService:Create(MainWindow, TweenInfo.new(0.4, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
				Size = CurrentSize
			}):Play()
			MinimizeBtn.Ico.Image = "rbxassetid://7072719338"
			task.wait(0.02)
			MainWindow.ClipsDescendants = false
			WindowStuff.Visible = true
			WindowTopBarLine.Visible = true
		else
			CurrentSize = MainWindow.Size
			MainWindow.ClipsDescendants = true
			WindowTopBarLine.Visible = false
			MinimizeBtn.Ico.Image = "rbxassetid://7072720870"
			TweenService:Create(MainWindow, TweenInfo.new(0.4, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
				Size = UDim2.new(0, WindowName.TextBounds.X + 130, 0, 44)
			}):Play()
			task.wait(0.08)
			WindowStuff.Visible = false
		end
		Minimized = not Minimized
	end)

	local function LoadSequence()
		MainWindow.Visible = false
		local Logo = SetProps(MakeElement("Image", WindowConfig.IntroIcon), {
			Parent = Orion,
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.new(0.5, 0, 0.42, 0),
			Size = UDim2.new(0, 26, 0, 26),
			ImageTransparency = 1
		})
		local Text = SetProps(MakeElement("Label", WindowConfig.IntroText, 14), {
			Parent = Orion,
			Size = UDim2.new(1, 0, 1, 0),
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.new(0.5, 18, 0.5, 0),
			TextXAlignment = Enum.TextXAlignment.Center,
			Font = Enum.Font.GothamBold,
			TextTransparency = 1
		})
		TweenService:Create(Logo, TweenInfo.new(0.3, Enum.EasingStyle.Quad), {ImageTransparency = 0, Position = UDim2.new(0.5, 0, 0.5, 0)}):Play()
		task.wait(0.7)
		TweenService:Create(Logo, TweenInfo.new(0.3, Enum.EasingStyle.Quad), {Position = UDim2.new(0.5, -(Text.TextBounds.X / 2), 0.5, 0)}):Play()
		task.wait(0.25)
		TweenService:Create(Text, TweenInfo.new(0.3, Enum.EasingStyle.Quad), {TextTransparency = 0}):Play()
		task.wait(1.6)
		TweenService:Create(Text, TweenInfo.new(0.3, Enum.EasingStyle.Quad),
