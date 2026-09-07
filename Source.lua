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
	SaveCfg = false,
	Version = "2.0"
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
		pcall(function() Conn:Disconnect() end)
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

function OrionLib:GetTheme(ThemeName)
	return OrionLib.Themes[ThemeName or OrionLib.SelectedTheme]
end

function OrionLib:GetThemeColor(ColorType)
	return OrionLib.Themes[OrionLib.SelectedTheme][ColorType]
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

local function SaveCfgData(Name)
	if not OrionLib.SaveCfg then return end
	local Data = {}
	for i, v in pairs(OrionLib.Flags) do
		if v.Save then
			Data[i] = v.Type == "Colorpicker" and PackColor(v.Value) or v.Value
		end
	end
	pcall(function()
		writefile(OrionLib.Folder .. "/" .. Name .. ".txt", HttpService:JSONEncode(Data))
	end)
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
	local CurrentSize = UDim2.new(0, 615, 0, 344)

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
		Size = UDim2.new(1, 0, 1, -50)
	}), {
		MakeElement("List"),
		MakeElement("Padding", 8, 6, 6, 8)
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
		Size = UDim2.new(1, 0, 0, 48)
	})

	local WindowStuff = AddThemeObject(SetChildren(SetProps(MakeElement("RoundFrame", Color3.fromRGB(255, 255, 255), 0, 8), {
		Size = UDim2.new(0, 150, 1, -48),
		Position = UDim2.new(0, 0, 0, 48),
		BackgroundTransparency = 0.35
	}), {
		AddThemeObject(SetProps(MakeElement("Frame"), {
			Size = UDim2.new(1, 0, 0, 8),
			Position = UDim2.new(0, 0, 0, 0),
			BackgroundTransparency = 0.35
		}), "Second"),
		AddThemeObject(SetProps(MakeElement("Frame"), {
			Size = UDim2.new(0, 8, 1, 0),
			Position = UDim2.new(1, -8, 0, 0),
			BackgroundTransparency = 0.35
		}), "Second"),
		AddThemeObject(SetProps(MakeElement("Frame"), {
			Size = UDim2.new(0, 1, 1, 0),
			Position = UDim2.new(1, -1, 0, 0)
		}), "Stroke"),
		TabHolder,
		SetChildren(SetProps(MakeElement("TFrame"), {
			Size = UDim2.new(1, 0, 0, 48),
			Position = UDim2.new(0, 0, 1, -48)
		}), {
			AddThemeObject(SetProps(MakeElement("Frame"), {
				Size = UDim2.new(1, 0, 0, 1)
			}), "Stroke"),
			AddThemeObject(SetChildren(SetProps(MakeElement("Frame"), {
				AnchorPoint = Vector2.new(0, 0.5),
				Size = UDim2.new(0, 30, 0, 30),
				Position = UDim2.new(0, 10, 0.5, 0)
			}), {
				SetProps(MakeElement("Image", "https://www.roblox.com/headshot-thumbnail/image?userId=" .. LocalPlayer.UserId .. "&width=420&height=420&format=png"), {
					Size = UDim2.new(1, 0, 1, 0)
				}),
				AddThemeObject(SetProps(MakeElement("Image", "rbxassetid://4031889928"), {
					Size = UDim2.new(1, 0, 1, 0)
				}), "Second"),
				MakeElement("Corner", 1)
			}), "Divider"),
			SetChildren(SetProps(MakeElement("TFrame"), {
				AnchorPoint = Vector2.new(0, 0.5),
				Size = UDim2.new(0, 30, 0, 30),
				Position = UDim2.new(0, 10, 0.5, 0)
			}), {
				AddThemeObject(MakeElement("Stroke"), "Stroke"),
				MakeElement("Corner", 1)
			}),
			AddThemeObject(SetProps(MakeElement("Label", LocalPlayer.DisplayName, WindowConfig.HidePremium and 13 or 12), {
				Size = UDim2.new(1, -55, 0, 13),
				Position = WindowConfig.HidePremium and UDim2.new(0, 48, 0, 17) or UDim2.new(0, 48, 0, 11),
				Font = Enum.Font.GothamBold,
				ClipsDescendants = true
			}), "Text"),
			AddThemeObject(SetProps(MakeElement("Label", "", 11), {
				Size = UDim2.new(1, -55, 0, 11),
				Position = UDim2.new(0, 48, 1, -22),
				Visible = not WindowConfig.HidePremium
			}), "TextDark")
		})
	}), "Second")

	local WindowName = AddThemeObject(SetProps(MakeElement("Label", WindowConfig.Name, 15), {
		Size = UDim2.new(1, -30, 2, 0),
		Position = UDim2.new(0, 22, 0, -22),
		Font = Enum.Font.GothamBlack,
		TextSize = 18
	}), "Text")

	local WindowTopBarLine = AddThemeObject(SetProps(MakeElement("Frame"), {
		Size = UDim2.new(1, 0, 0, 1),
		Position = UDim2.new(0, 0, 1, -1)
	}), "Stroke")

	local MainWindow = AddThemeObject(SetChildren(SetProps(MakeElement("RoundFrame", Color3.fromRGB(255, 255, 255), 0, 8), {
		Parent = Orion,
		Position = UDim2.new(0.5, -307, 0.5, -172),
		Size = CurrentSize,
		ClipsDescendants = true
	}), {
		SetChildren(SetProps(MakeElement("TFrame"), {
			Size = UDim2.new(1, 0, 0, 48),
			Name = "TopBar"
		}), {
			WindowName,
			WindowTopBarLine,
			AddThemeObject(SetChildren(SetProps(MakeElement("RoundFrame", Color3.fromRGB(255, 255, 255), 0, 6), {
				Size = UDim2.new(0, 64, 0, 28),
				Position = UDim2.new(1, -82, 0, 10)
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
		WindowName.Position = UDim2.new(0, 48, 0, -22)
		local WindowIcon = SetProps(MakeElement("Image", WindowConfig.Icon), {
			Size = UDim2.new(0, 18, 0, 18),
			Position = UDim2.new(0, 22, 0, 15)
		})
		WindowIcon.Parent = MainWindow.TopBar
	end

	AddDraggingFunctionality(DragPoint, MainWindow)
	AddResizeFunctionality(MainWindow, Vector2.new(480, 280))

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
				Size = UDim2.new(0, WindowName.TextBounds.X + 130, 0, 48)
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
		TweenService:Create(Text, TweenInfo.new(0.3, Enum.EasingStyle.Quad), {TextTransparency = 1}):Play()
		TweenService:Create(Logo, TweenInfo.new(0.3, Enum.EasingStyle.Quad), {ImageTransparency = 1}):Play()
		task.wait(0.3)
		MainWindow.Visible = true
		Logo:Destroy()
		Text:Destroy()
	end

	if WindowConfig.IntroEnabled then
		LoadSequence()
	end

	local TabFunction = {}
	function TabFunction:MakeTab(TabConfig)
		TabConfig = TabConfig or {}
		TabConfig.Name = TabConfig.Name or "Tab"
		TabConfig.Icon = TabConfig.Icon or ""
		TabConfig.PremiumOnly = TabConfig.PremiumOnly or false

		local TabFrame = SetChildren(SetProps(MakeElement("Button"), {
			Size = UDim2.new(1, 0, 0, 32),
			Parent = TabHolder
		}), {
			AddThemeObject(SetProps(MakeElement("Image", TabConfig.Icon), {
				AnchorPoint = Vector2.new(0, 0.5),
				Size = UDim2.new(0, 16, 0, 16),
				Position = UDim2.new(0, 10, 0.5, 0),
				ImageTransparency = 0.45,
				Name = "Ico"
			}), "Text"),
			AddThemeObject(SetProps(MakeElement("Label", TabConfig.Name, 13), {
				Size = UDim2.new(1, -32, 1, 0),
				Position = UDim2.new(0, 32, 0, 0),
				Font = Enum.Font.GothamSemibold,
				TextTransparency = 0.45,
				Name = "Title"
			}), "Text")
		})

		local Icon = GetIcon(TabConfig.Icon)
		if Icon then TabFrame.Ico.Image = Icon end

		local Container = AddThemeObject(SetChildren(SetProps(MakeElement("ScrollFrame", Color3.fromRGB(255, 255, 255), 4), {
			Size = UDim2.new(1, -150, 1, -48),
			Position = UDim2.new(0, 150, 0, 48),
			Parent = MainWindow,
			Visible = false,
			Name = "ItemContainer"
		}), {
			MakeElement("List", 0, 6),
			MakeElement("Padding", 14, 10, 10, 14)
		}), "Divider")

		AddConnection(Container.UIListLayout:GetPropertyChangedSignal("AbsoluteContentSize"), function()
			Container.CanvasSize = UDim2.new(0, 0, 0, Container.UIListLayout.AbsoluteContentSize.Y + 28)
		end)

		if FirstTab then
			FirstTab = false
			TabFrame.Ico.ImageTransparency = 0
			TabFrame.Title.TextTransparency = 0
			TabFrame.Title.Font = Enum.Font.GothamBold
			Container.Visible = true
		end

		AddConnection(TabFrame.MouseButton1Click, function()
			for _, Tab in next, TabHolder:GetChildren() do
				if Tab:IsA("TextButton") then
					Tab.Title.Font = Enum.Font.GothamSemibold
					TweenService:Create(Tab.Ico, TweenInfo.new(0.22, Enum.EasingStyle.Quint), {ImageTransparency = 0.45}):Play()
					TweenService:Create(Tab.Title, TweenInfo.new(0.22, Enum.EasingStyle.Quint), {TextTransparency = 0.45}):Play()
				end
			end
			for _, Item in next, MainWindow:GetChildren() do
				if Item.Name == "ItemContainer" then
					Item.Visible = false
				end
			end
			TweenService:Create(TabFrame.Ico, TweenInfo.new(0.22, Enum.EasingStyle.Quint), {ImageTransparency = 0}):Play()
			TweenService:Create(TabFrame.Title, TweenInfo.new(0.22, Enum.EasingStyle.Quint), {TextTransparency = 0}):Play()
			TabFrame.Title.Font = Enum.Font.GothamBold
			Container.Visible = true
		end)

		local ElementFunction = {}

		function ElementFunction:AddLabel(Text)
			local LabelFrame = AddThemeObject(SetChildren(SetProps(MakeElement("RoundFrame", Color3.fromRGB(255, 255, 255), 0, 6), {
				Size = UDim2.new(1, 0, 0, 28),
				BackgroundTransparency = 0.75,
				Parent = Container
			}), {
				AddThemeObject(SetProps(MakeElement("Label", Text, 13), {
					Size = UDim2.new(1, -12, 1, 0),
					Position = UDim2.new(0, 12, 0, 0),
					Font = Enum.Font.GothamBold,
					Name = "Content"
				}), "Text"),
				AddThemeObject(MakeElement("Stroke"), "Stroke")
			}), "Second")

			local Func = {}
			function Func:Set(ToChange)
				LabelFrame.Content.Text = ToChange
			end
			return Func
		end

		function ElementFunction:AddParagraph(Text, Content)
			Text = Text or "Text"
			Content = Content or "Content"

			local ParagraphFrame = AddThemeObject(SetChildren(SetProps(MakeElement("RoundFrame", Color3.fromRGB(255, 255, 255), 0, 6), {
				Size = UDim2.new(1, 0, 0, 28),
				BackgroundTransparency = 0.75,
				Parent = Container
			}), {
				AddThemeObject(SetProps(MakeElement("Label", Text, 13), {
					Size = UDim2.new(1, -12, 0, 14),
					Position = UDim2.new(0, 12, 0, 8),
					Font = Enum.Font.GothamBold,
					Name = "Title"
				}), "Text"),
				AddThemeObject(SetProps(MakeElement("Label", "", 12), {
					Size = UDim2.new(1, -24, 0, 0),
					Position = UDim2.new(0, 12, 0, 24),
					Font = Enum.Font.Gotham,
					Name = "Content",
					TextWrapped = true
				}), "TextDark"),
				AddThemeObject(MakeElement("Stroke"), "Stroke")
			}), "Second")

			AddConnection(ParagraphFrame.Content:GetPropertyChangedSignal("Text"), function()
				ParagraphFrame.Content.Size = UDim2.new(1, -24, 0, ParagraphFrame.Content.TextBounds.Y)
				ParagraphFrame.Size = UDim2.new(1, 0, 0, ParagraphFrame.Content.TextBounds.Y + 32)
			end)

			ParagraphFrame.Content.Text = Content

			local Func = {}
			function Func:Set(ToChange)
				ParagraphFrame.Content.Text = ToChange
			end
			return Func
		end

		function ElementFunction:AddButton(ButtonConfig)
			ButtonConfig = ButtonConfig or {}
			ButtonConfig.Name = ButtonConfig.Name or "Button"
			ButtonConfig.Callback = ButtonConfig.Callback or function() end
			ButtonConfig.Icon = ButtonConfig.Icon or "rbxassetid://3944703587"

			local Click = SetProps(MakeElement("Button"), {Size = UDim2.new(1, 0, 1, 0)})

			local ButtonFrame = AddThemeObject(SetChildren(SetProps(MakeElement("RoundFrame", Color3.fromRGB(255, 255, 255), 0, 6), {
				Size = UDim2.new(1, 0, 0, 32),
				Parent = Container
			}), {
				AddThemeObject(SetProps(MakeElement("Label", ButtonConfig.Name, 13), {
					Size = UDim2.new(1, -12, 1, 0),
					Position = UDim2.new(0, 12, 0, 0),
					Font = Enum.Font.GothamBold,
					Name = "Content"
				}), "Text"),
				AddThemeObject(SetProps(MakeElement("Image", ButtonConfig.Icon), {
					Size = UDim2.new(0, 16, 0, 16),
					Position = UDim2.new(1, -28, 0, 8)
				}), "TextDark"),
				AddThemeObject(MakeElement("Stroke"), "Stroke"),
				Click
			}), "Second")

			local function GetSecond()
				return OrionLib.Themes[OrionLib.SelectedTheme].Second
			end

			AddConnection(Click.MouseEnter, function()
				local S = GetSecond()
				TweenService:Create(ButtonFrame, TweenInfo.new(0.2, Enum.EasingStyle.Quint), {
					BackgroundColor3 = Color3.fromRGB(S.R * 255 + 5, S.G * 255 + 5, S.B * 255 + 5)
				}):Play()
			end)

			AddConnection(Click.MouseLeave, function()
				TweenService:Create(ButtonFrame, TweenInfo.new(0.2, Enum.EasingStyle.Quint), {
					BackgroundColor3 = GetSecond()
				}):Play()
			end)

			AddConnection(Click.MouseButton1Up, function()
				task.spawn(ButtonConfig.Callback)
			end)

			local Func = {}
			function Func:Set(ButtonText)
				ButtonFrame.Content.Text = ButtonText
			end
			return Func
		end

		function ElementFunction:AddToggle(ToggleConfig)
			ToggleConfig = ToggleConfig or {}
			ToggleConfig.Name = ToggleConfig.Name or "Toggle"
			ToggleConfig.Default = ToggleConfig.Default or false
			ToggleConfig.Callback = ToggleConfig.Callback or function() end
			ToggleConfig.Flag = ToggleConfig.Flag or nil
			ToggleConfig.Save = ToggleConfig.Save or false

			local Toggled = ToggleConfig.Default

			local Click = SetProps(MakeElement("Button"), {Size = UDim2.new(1, 0, 1, 0)})

			local ToggleIndicator = SetChildren(SetProps(MakeElement("RoundFrame", Color3.fromRGB(255, 255, 255), 0, 4), {
				Size = UDim2.new(0, 18, 0, 18),
				Position = UDim2.new(1, -26, 0.5, -9)
			}), {
				AddThemeObject(MakeElement("Stroke"), "Stroke"),
				SetProps(MakeElement("Image", "rbxassetid://6031094670"), {
					Size = UDim2.new(1, 0, 1, 0),
					ImageTransparency = 1
				})
			})

			local ToggleFrame = AddThemeObject(SetChildren(SetProps(MakeElement("RoundFrame", Color3.fromRGB(255, 255, 255), 0, 6), {
				Size = UDim2.new(1, 0, 0, 32),
				Parent = Container
			}), {
				AddThemeObject(SetProps(MakeElement("Label", ToggleConfig.Name, 13), {
					Size = UDim2.new(1, -45, 1, 0),
					Position = UDim2.new(0, 12, 0, 0),
					Font = Enum.Font.GothamBold,
					Name = "Content"
				}), "Text"),
				AddThemeObject(MakeElement("Stroke"), "Stroke"),
				ToggleIndicator,
				Click
			}), "Second")

			local function UpdateToggle(Instant)
				local AccentColor = OrionLib.Themes[OrionLib.SelectedTheme].Accent
				if Toggled then
					if Instant then
						ToggleIndicator.BackgroundColor3 = AccentColor
					else
						TweenService:Create(ToggleIndicator, TweenInfo.new(0.2), {BackgroundColor3 = AccentColor}):Play()
					end
				else
					local SecColor = OrionLib.Themes[OrionLib.SelectedTheme].Second
					if Instant then
						ToggleIndicator.BackgroundColor3 = SecColor
					else
						TweenService:Create(ToggleIndicator, TweenInfo.new(0.2), {BackgroundColor3 = SecColor}):Play()
					end
				end
			end

			UpdateToggle(true)

			AddConnection(Click.MouseButton1Up, function()
				Toggled = not Toggled
				UpdateToggle(false)
				task.spawn(ToggleConfig.Callback, Toggled)
				if ToggleConfig.Flag then
					OrionLib.Flags[ToggleConfig.Flag].Value = Toggled
					SaveCfgData(game.GameId)
				end
			end)

			local Func = {Value = Toggled, Type = "Toggle", Save = ToggleConfig.Save}
			function Func:Set(Value)
				Toggled = Value
				UpdateToggle(false)
				task.spawn(ToggleConfig.Callback, Toggled)
				if ToggleConfig.Flag then
					OrionLib.Flags[ToggleConfig.Flag].Value = Toggled
					SaveCfgData(game.GameId)
				end
			end

			if ToggleConfig.Flag then
				OrionLib.Flags[ToggleConfig.Flag] = Func
			end

			return Func
		end

		function ElementFunction:AddSlider(SliderConfig)
			SliderConfig = SliderConfig or {}
			SliderConfig.Name = SliderConfig.Name or "Slider"
			SliderConfig.Min = SliderConfig.Min or 0
			SliderConfig.Max = SliderConfig.Max or 100
			SliderConfig.Default = SliderConfig.Default or 50
			SliderConfig.Increment = SliderConfig.Increment or 1
			SliderConfig.Callback = SliderConfig.Callback or function() end
			SliderConfig.Flag = SliderConfig.Flag or nil
			SliderConfig.Save = SliderConfig.Save or false

			local Value = SliderConfig.Default
			local Sliding = false

			local SliderBar = AddThemeObject(SetChildren(SetProps(MakeElement("RoundFrame", Color3.fromRGB(255, 255, 255), 0, 4), {
				Size = UDim2.new(1, -24, 0, 6),
				Position = UDim2.new(0, 12, 0, 30)
			}), {
				AddThemeObject(MakeElement("Stroke"), "Stroke"),
				SetChildren(SetProps(MakeElement("RoundFrame", Color3.fromRGB(255, 255, 255), 0, 4), {
					Size = UDim2.new((Value - SliderConfig.Min) / (SliderConfig.Max - SliderConfig.Min), 0, 1, 0),
					Name = "Fill"
				}), {
					AddThemeObject(SetProps(MakeElement("Frame", Color3.fromRGB(255, 255, 255)), {}), "Accent")
				})
			}), "Second")

			local SliderFrame = AddThemeObject(SetChildren(SetProps(MakeElement("RoundFrame", Color3.fromRGB(255, 255, 255), 0, 6), {
				Size = UDim2.new(1, 0, 0, 48),
				Parent = Container
			}), {
				AddThemeObject(SetProps(MakeElement("Label", SliderConfig.Name, 13), {
					Size = UDim2.new(1, -12, 0, 18),
					Position = UDim2.new(0, 12, 0, 6),
					Font = Enum.Font.GothamBold,
					Name = "Title"
				}), "Text"),
				AddThemeObject(SetProps(MakeElement("Label", tostring(Value), 12), {
					Size = UDim2.new(1, -12, 0, 18),
					Position = UDim2.new(0, -12, 0, 6),
					Font = Enum.Font.GothamSemibold,
					TextXAlignment = Enum.TextXAlignment.Right,
					Name = "Value"
				}), "TextDark"),
				AddThemeObject(MakeElement("Stroke"), "Stroke"),
				SliderBar
			}), "Second")

			local function UpdateSlider(Input)
				local SizeX = math.clamp((Input.Position.X - SliderBar.AbsolutePosition.X) / SliderBar.AbsoluteSize.X, 0, 1)
				local CalculatedValue = Round(SliderConfig.Min + ((SliderConfig.Max - SliderConfig.Min) * SizeX), SliderConfig.Increment)
				Value = CalculatedValue
				SliderBar.Fill.Size = UDim2.new((Value - SliderConfig.Min) / (SliderConfig.Max - SliderConfig.Min), 0, 1, 0)
				SliderFrame.Value.Text = tostring(Value)
				task.spawn(SliderConfig.Callback, Value)
				if SliderConfig.Flag then
					OrionLib.Flags[SliderConfig.Flag].Value = Value
					SaveCfgData(game.GameId)
				end
			end

			AddConnection(SliderBar.InputBegan, function(Input)
				if Input.UserInputType == Enum.UserInputType.MouseButton1 then
					Sliding = true
					UpdateSlider(Input)
				end
			end)

			AddConnection(UserInputService.InputEnded, function(Input)
				if Input.UserInputType == Enum.UserInputType.MouseButton1 then
					Sliding = false
				end
			end)

			AddConnection(UserInputService.InputChanged, function(Input)
				if Sliding and Input.UserInputType == Enum.UserInputType.MouseMovement then
					UpdateSlider(Input)
				end
			end)

			local Func = {Value = Value, Type = "Slider", Save = SliderConfig.Save}
			function Func:Set(ToSet)
				Value = math.clamp(ToSet, SliderConfig.Min, SliderConfig.Max)
				SliderBar.Fill.Size = UDim2.new((Value - SliderConfig.Min) / (SliderConfig.Max - SliderConfig.Min), 0, 1, 0)
				SliderFrame.Value.Text = tostring(Value)
				task.spawn(SliderConfig.Callback, Value)
				if SliderConfig.Flag then
					OrionLib.Flags[SliderConfig.Flag].Value = Value
					SaveCfgData(game.GameId)
				end
			end

			if SliderConfig.Flag then
				OrionLib.Flags[SliderConfig.Flag] = Func
			end

			return Func
		end

		function ElementFunction:AddDropdown(DropdownConfig)
			DropdownConfig = DropdownConfig or {}
			DropdownConfig.Name = DropdownConfig.Name or "Dropdown"
			DropdownConfig.Options = DropdownConfig.Options or {}
			DropdownConfig.Default = DropdownConfig.Default or DropdownConfig.Options[1]
			DropdownConfig.Callback = DropdownConfig.Callback or function() end
			DropdownConfig.Flag = DropdownConfig.Flag or nil
			DropdownConfig.Save = DropdownConfig.Save or false

			local Value = DropdownConfig.Default
			local Dropped = false
			local ItemFrames = {}

			local Click = SetProps(MakeElement("Button"), {Size = UDim2.new(1, 0, 0, 32)})

			local DropdownList = SetChildren(SetProps(MakeElement("TFrame"), {
				Size = UDim2.new(1, 0, 0, 0),
				Position = UDim2.new(0, 0, 0, 32),
				Visible = false
			}), {
				MakeElement("List", 0, 2),
				MakeElement("Padding", 4, 4, 4, 4)
			})

			local DropdownFrame = AddThemeObject(SetChildren(SetProps(MakeElement("RoundFrame", Color3.fromRGB(255, 255, 255), 0, 6), {
				Size = UDim2.new(1, 0, 0, 32),
				ClipsDescendants = true,
				Parent = Container
			}), {
				AddThemeObject(SetProps(MakeElement("Label", DropdownConfig.Name, 13), {
					Size = UDim2.new(1, -30, 0, 32),
					Position = UDim2.new(0, 12, 0, 0),
					Font = Enum.Font.GothamBold,
					Name = "Title"
				}), "Text"),
				AddThemeObject(SetProps(MakeElement("Label", tostring(Value), 12), {
					Size = UDim2.new(1, -30, 0, 32),
					Position = UDim2.new(0, -12, 0, 0),
					Font = Enum.Font.GothamSemibold,
					TextXAlignment = Enum.TextXAlignment.Right,
					Name = "Value"
				}), "TextDark"),
				AddThemeObject(SetProps(MakeElement("Image", "rbxassetid://7072706743"), {
					Size = UDim2.new(0, 16, 0, 16),
					Position = UDim2.new(1, -24, 0, 8),
					Name = "Arrow"
				}), "TextDark"),
				AddThemeObject(MakeElement("Stroke"), "Stroke"),
				Click,
				DropdownList
			}), "Second")

			local function RefreshDropdown(Options)
				for _, v in next, ItemFrames do
					v:Destroy()
				end
				ItemFrames = {}
				for _, Option in next, Options do
					local OptionClick = SetProps(MakeElement("Button"), {Size = UDim2.new(1, 0, 1, 0)})
					local OptionFrame = AddThemeObject(SetChildren(SetProps(MakeElement("RoundFrame", Color3.fromRGB(255, 255, 255), 0, 4), {
						Size = UDim2.new(1, 0, 0, 24),
						Parent = DropdownList
					}), {
						AddThemeObject(SetProps(MakeElement("Label", Option, 12), {
							Size = UDim2.new(1, -12, 1, 0),
							Position = UDim2.new(0, 8, 0, 0),
							Font = Enum.Font.GothamSemibold
						}), "Text"),
						OptionClick
					}), "Divider")

					AddConnection(OptionClick.MouseButton1Up, function()
						Value = Option
						DropdownFrame.Value.Text = tostring(Value)
						Dropped = false
						TweenService:Create(DropdownFrame.Arrow, TweenInfo.new(0.2), {Rotation = 0}):Play()
						TweenService:Create(DropdownFrame, TweenInfo.new(0.2), {Size = UDim2.new(1, 0, 0, 32)}):Play()
						DropdownList.Visible = false
						task.spawn(DropdownConfig.Callback, Value)
						if DropdownConfig.Flag then
							OrionLib.Flags[DropdownConfig.Flag].Value = Value
							SaveCfgData(game.GameId)
						end
					end)
					table.insert(ItemFrames, OptionFrame)
				end
			end

			RefreshDropdown(DropdownConfig.Options)

			AddConnection(Click.MouseButton1Up, function()
				Dropped = not Dropped
				DropdownList.Visible = true
				local TargetSize = Dropped and (36 + (#DropdownConfig.Options * 26)) or 32
				TweenService:Create(DropdownFrame.Arrow, TweenInfo.new(0.2), {Rotation = Dropped and 180 or 0}):Play()
				TweenService:Create(DropdownFrame, TweenInfo.new(0.2), {Size = UDim2.new(1, 0, 0, TargetSize)}):Play()
				if not Dropped then
					task.wait(0.2)
					DropdownList.Visible = false
				end
			end)

			local Func = {Value = Value, Type = "Dropdown", Save = DropdownConfig.Save}
			function Func:Set(ToSet)
				Value = ToSet
				DropdownFrame.Value.Text = tostring(Value)
				task.spawn(DropdownConfig.Callback, Value)
				if DropdownConfig.Flag then
					OrionLib.Flags[DropdownConfig.Flag].Value = Value
					SaveCfgData(game.GameId)
				end
			end

			function Func:Refresh(NewOptions)
				DropdownConfig.Options = NewOptions
				RefreshDropdown(NewOptions)
			end

			if DropdownConfig.Flag then
				OrionLib.Flags[DropdownConfig.Flag] = Func
			end

			return Func
		end

		function ElementFunction:AddTextbox(TextboxConfig)
			TextboxConfig = TextboxConfig or {}
			TextboxConfig.Name = TextboxConfig.Name or "Textbox"
			TextboxConfig.Default = TextboxConfig.Default or ""
			TextboxConfig.TextDisappear = TextboxConfig.TextDisappear or false
			TextboxConfig.Callback = TextboxConfig.Callback or function() end
			TextboxConfig.Flag = TextboxConfig.Flag or nil
			TextboxConfig.Save = TextboxConfig.Save or false

			local Value = TextboxConfig.Default

			local Box = SetProps(MakeElement("TextBox"), {
				Size = UDim2.new(0, 120, 0, 24),
				Position = UDim2.new(1, -128, 0.5, -12),
				BackgroundTransparency = 1,
				Text = Value,
				TextColor3 = Color3.fromRGB(240, 240, 245),
				TextSize = 12,
				Font = Enum.Font.GothamSemibold,
				ClearTextOnFocus = TextboxConfig.TextDisappear
			})

			local TextboxFrame = AddThemeObject(SetChildren(SetProps(MakeElement("RoundFrame", Color3.fromRGB(255, 255, 255), 0, 6), {
				Size = UDim2.new(1, 0, 0, 32),
				Parent = Container
			}), {
				AddThemeObject(SetProps(MakeElement("Label", TextboxConfig.Name, 13), {
					Size = UDim2.new(1, -135, 1, 0),
					Position = UDim2.new(0, 12, 0, 0),
					Font = Enum.Font.GothamBold
				}), "Text"),
				AddThemeObject(SetChildren(SetProps(MakeElement("RoundFrame", Color3.fromRGB(255, 255, 255), 0, 4), {
					Size = UDim2.new(0, 130, 0, 26),
					Position = UDim2.new(1, -136, 0.5, -13)
				}), {
					AddThemeObject(MakeElement("Stroke"), "Stroke")
				}), "Divider"),
				AddThemeObject(MakeElement("Stroke"), "Stroke"),
				Box
			}), "Second")

			AddConnection(Box.FocusLost, function(EnterPressed)
				Value = Box.Text
				task.spawn(TextboxConfig.Callback, Value)
				if TextboxConfig.Flag then
					OrionLib.Flags[TextboxConfig.Flag].Value = Value
					SaveCfgData(game.GameId)
				end
			end)

			local Func = {Value = Value, Type = "Textbox", Save = TextboxConfig.Save}
			function Func:Set(ToSet)
				Value = ToSet
				Box.Text = ToSet
				task.spawn(TextboxConfig.Callback, Value)
				if TextboxConfig.Flag then
					OrionLib.Flags[TextboxConfig.Flag].Value = Value
					SaveCfgData(game.GameId)
				end
			end

			if TextboxConfig.Flag then
				OrionLib.Flags[TextboxConfig.Flag] = Func
			end

			return Func
		end

		function ElementFunction:AddColorpicker(ColorpickerConfig)
			ColorpickerConfig = ColorpickerConfig or {}
			ColorpickerConfig.Name = ColorpickerConfig.Name or "Colorpicker"
			ColorpickerConfig.Default = ColorpickerConfig.Default or Color3.fromRGB(255, 255, 255)
			ColorpickerConfig.Callback = ColorpickerConfig.Callback or function() end
			ColorpickerConfig.Flag = ColorpickerConfig.Flag or nil
			ColorpickerConfig.Save = ColorpickerConfig.Save or false

			local Value = ColorpickerConfig.Default
			local Open = false

			local Click = SetProps(MakeElement("Button"), {Size = UDim2.new(1, 0, 1, 0)})

			local ColorDisplay = SetChildren(SetProps(MakeElement("RoundFrame", Value, 0, 4), {
				Size = UDim2.new(0, 24, 0, 16),
				Position = UDim2.new(1, -32, 0.5, -8)
			}), {
				AddThemeObject(MakeElement("Stroke"), "Stroke")
			})

			local ColorpickerFrame = AddThemeObject(SetChildren(SetProps(MakeElement("RoundFrame", Color3.fromRGB(255, 255, 255), 0, 6), {
				Size = UDim2.new(1, 0, 0, 32),
				Parent = Container
			}), {
				AddThemeObject(SetProps(MakeElement("Label", ColorpickerConfig.Name, 13), {
					Size = UDim2.new(1, -40, 1, 0),
					Position = UDim2.new(0, 12, 0, 0),
					Font = Enum.Font.GothamBold
				}), "Text"),
				AddThemeObject(MakeElement("Stroke"), "Stroke"),
				ColorDisplay,
				Click
			}), "Second")

			AddConnection(Click.MouseButton1Up, function()
				Open = not Open
				OrionLib:MakeNotification({
					Name = "Colorpicker",
					Content = "Colorpickers are fully integrated with flags and save data.",
					Time = 3
				})
			end)

			local Func = {Value = Value, Type = "Colorpicker", Save = ColorpickerConfig.Save}
			function Func:Set(ToSet)
				Value = ToSet
				ColorDisplay.BackgroundColor3 = ToSet
				task.spawn(ColorpickerConfig.Callback, Value)
				if ColorpickerConfig.Flag then
					OrionLib.Flags[ColorpickerConfig.Flag].Value = Value
					SaveCfgData(game.GameId)
				end
			end

			if ColorpickerConfig.Flag then
				OrionLib.Flags[ColorpickerConfig.Flag] = Func
			end

			return Func
		end

		function ElementFunction:AddBind(BindConfig)
			BindConfig = BindConfig or {}
			BindConfig.Name = BindConfig.Name or "Bind"
			BindConfig.Default = BindConfig.Default or Enum.KeyCode.E
			BindConfig.Hold = BindConfig.Hold or false
			BindConfig.Callback = BindConfig.Callback or function() end
			BindConfig.Flag = BindConfig.Flag or nil
			BindConfig.Save = BindConfig.Save or false

			local Value = BindConfig.Default
			local Binding = false

			local Click = SetProps(MakeElement("Button"), {Size = UDim2.new(1, 0, 1, 0)})

			local BindDisplay = AddThemeObject(SetChildren(SetProps(MakeElement("RoundFrame", Color3.fromRGB(255, 255, 255), 0, 4), {
				Size = UDim2.new(0, 40, 0, 20),
				Position = UDim2.new(1, -48, 0.5, -10)
			}), {
				AddThemeObject(MakeElement("Stroke"), "Stroke"),
				AddThemeObject(SetProps(MakeElement("Label", typeof(Value) == "EnumItem" and Value.Name or tostring(Value), 11), {
					Size = UDim2.new(1, 0, 1, 0),
					TextXAlignment = Enum.TextXAlignment.Center,
					Font = Enum.Font.GothamBold,
					Name = "Content"
				}), "Text")
			}), "Divider")

			local BindFrame = AddThemeObject(SetChildren(SetProps(MakeElement("RoundFrame", Color3.fromRGB(255, 255, 255), 0, 6), {
				Size = UDim2.new(1, 0, 0, 32),
				Parent = Container
			}), {
				AddThemeObject(SetProps(MakeElement("Label", BindConfig.Name, 13), {
					Size = UDim2.new(1, -60, 1, 0),
					Position = UDim2.new(0, 12, 0, 0),
					Font = Enum.Font.GothamBold
				}), "Text"),
				AddThemeObject(MakeElement("Stroke"), "Stroke"),
				BindDisplay,
				Click
			}), "Second")

			AddConnection(Click.MouseButton1Up, function()
				Binding = true
				BindDisplay.Content.Text = "..."
			end)

			AddConnection(UserInputService.InputBegan, function(Input, GameProcessed)
				if Binding then
					if Input.UserInputType == Enum.UserInputType.Keyboard and not CheckKey(BlacklistedKeys, Input.KeyCode) then
						Value = Input.KeyCode
						Binding = false
						BindDisplay.Content.Text = Value.Name
						if BindConfig.Flag then
							OrionLib.Flags[BindConfig.Flag].Value = Value
							SaveCfgData(game.GameId)
						end
					end
				elseif not GameProcessed then
					if Input.KeyCode == Value then
						task.spawn(BindConfig.Callback, Value)
					end
				end
			end)

			local Func = {Value = Value, Type = "Bind", Save = BindConfig.Save}
			function Func:Set(ToSet)
				Value = ToSet
				BindDisplay.Content.Text = typeof(ToSet) == "EnumItem" and ToSet.Name or tostring(ToSet)
				if BindConfig.Flag then
					OrionLib.Flags[BindConfig.Flag].Value = Value
					SaveCfgData(game.GameId)
				end
			end

			if BindConfig.Flag then
				OrionLib.Flags[BindConfig.Flag] = Func
			end

			return Func
		end

		return ElementFunction
	end

	return TabFunction
end

return OrionLib
