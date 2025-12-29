-- https://discord.gg/nNYyfcsfR8

local GuiLibrary = {}
GuiLibrary.__index = GuiLibrary

GuiLibrary.KeyClass = {}
GuiLibrary.KeyClass.__index = GuiLibrary.KeyClass

GuiLibrary.WindowClass = {}
GuiLibrary.WindowClass.__index = GuiLibrary.WindowClass

GuiLibrary.TabClass = {}
GuiLibrary.TabClass.__index = GuiLibrary.TabClass

GuiLibrary.ElementsClass = {}
GuiLibrary.ElementsClass.__index = GuiLibrary.ElementsClass

GuiLibrary.ToggleClass = {}
GuiLibrary.ToggleClass.__index = GuiLibrary.ToggleClass
setmetatable(GuiLibrary.ToggleClass, {__index = GuiLibrary.ElementsClass})

GuiLibrary.ListClass = {}
GuiLibrary.ListClass.__index = GuiLibrary.ListClass
setmetatable(GuiLibrary.ListClass, {__index = GuiLibrary.ElementsClass})

GuiLibrary.ButtonClass = {}
GuiLibrary.ButtonClass.__index = GuiLibrary.ButtonClass
setmetatable(GuiLibrary.ButtonClass, {__index = GuiLibrary.ElementsClass})

GuiLibrary.SliderClass = {}
GuiLibrary.SliderClass.__index = GuiLibrary.SliderClass
setmetatable(GuiLibrary.SliderClass, {__index = GuiLibrary.ElementsClass})

GuiLibrary.ElementClass = {}
GuiLibrary.ElementClass.__index = GuiLibrary.ElementClass
setmetatable(GuiLibrary.ElementClass, {__index = GuiLibrary.ElementsClass})

GuiLibrary.InputClass = {}
GuiLibrary.InputClass.__index = GuiLibrary.InputClass
setmetatable(GuiLibrary.InputClass, {__index = GuiLibrary.ElementsClass})

local label_fix = true

local Signal = {}
Signal.__index = Signal
function Signal.new()
	return setmetatable({_callbacks = {}}, Signal)
end
function Signal:Connect(callback)
	table.insert(self._callbacks, callback)
end
function Signal:Fire(...)
	for _, callback in ipairs(self._callbacks) do
		callback(...)
	end
end

local function bubbleSort(t)
	local n = 0
	local list = {}
	
	for i, v in pairs(t) do
		table.insert(list, {['index'] = v, ['part'] = i})
		n += 1
	end
	
	for i = 1, n - 1 do
		for j = 1, n - i do
			if list[j]['index'] > list[j + 1]['index'] then
				list[j], list[j + 1] = list[j + 1], list[j]
			end
		end
	end
	
	return list
end

local function Element_Template(self, idx, obj, index, prop)
	obj.Part = Instance.new("Frame")
	obj.Part.Name = index
	obj.Part.BackgroundTransparency = 1
	obj.Part.LayoutOrder = index
	obj.Part.Size = UDim2.fromScale(0.97, 0.15)
	obj.Part.Parent = self[idx].Frame.Part

	local UIAspectRatio = Instance.new('UIAspectRatioConstraint')
	UIAspectRatio.AspectRatio = 6.65
	UIAspectRatio.Parent = obj.Part

	local UICorner = Instance.new("UICorner")
	UICorner.CornerRadius = UDim.new(0, 16)
	UICorner.Parent = obj.Part

	local UIStroke = Instance.new("UIStroke")
	UIStroke.Parent = obj.Part
	UIStroke.Color = Color3.fromRGB(170, 0, 225)

	obj.Label = {}
	
	obj.Label.Part = Instance.new("TextLabel")
	obj.Label.Part.BackgroundTransparency = 1
	obj.Label.Part.Size = UDim2.fromScale(0.7, 1)
	obj.Label.Part.Position = UDim2.fromScale(0.05, 0)
	obj.Label.Part.TextColor3 = Color3.fromRGB(255, 255, 255)
	obj.Label.Part.Font = Enum.Font.FredokaOne
	obj.Label.Part.TextSize = 16
	obj.Label.Part.TextXAlignment = Enum.TextXAlignment.Left
	obj.Label.Part.Parent = obj.Part
	obj.Label.Part.Name = 'Label'
	
	obj.Name = prop.LabelText or index
	obj.Label.Part.Text = prop.LabelText or ''
end

local function update_tabs_buttons(Window)
	local check = {}
	for _, v in ipairs(Window.TabsFrame.Part:GetChildren()) do
		table.insert(check, v.Name)
	end
	
	for i, v in ipairs(Window.Tabs.Part:GetChildren()) do	
		if not table.find(check, v.Name) then
			local obj = {}
			obj.Part = Instance.new('TextButton')
			obj.Part.Name = i
			obj.Part.BackgroundTransparency = 1
			obj.Part.Size = UDim2.fromScale(1/#Window.Tabs.Part:GetChildren() - 0.015, 0.7)
			obj.Part.Text = v:GetAttribute('name')
			obj.Part.TextScaled = true
			obj.Part.Font = Enum.Font.SourceSans
			obj.Part.TextColor3 = Color3.fromRGB(255, 255, 255)
			obj.Part.Parent = Window.TabsFrame.Part
	
			local UICorner = Instance.new('UICorner')
			UICorner.CornerRadius = UDim.new(1, 0)
			UICorner.Parent = obj.Part
	
			local UIStroke = Instance.new('UIStroke')
			UIStroke.Color = Color3.fromRGB(170, 0, 255)
			UIStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
			UIStroke.Parent = obj.Part
	
			local LocalScript = Instance.new("LocalScript")
			LocalScript.Parent = obj.Part
			coroutine.wrap(function()
				local script = LocalScript
	
				script.Parent.MouseButton1Click:Connect(function()
					pcall(function()
						for _, v in ipairs(script.Parent.Parent.Parent.TabsFolder:GetChildren()) do
							v.Visible = false
						end
					end)
					script.Parent.Parent.Parent.TabsFolder:FindFirstChild(script.Parent.Name).Visible = true
				end)
			end)()
	
			table.insert(Window.TabsFrame, obj)
		else
			Window.TabsFrame.Part[v.Name].Size = UDim2.fromScale(1/#Window.Tabs.Part:GetChildren() - 0.015, 0.7)
		end
	end
end

function GuiLibrary:KeySystem(prop)
	local obj = {}
	
	setmetatable(obj, GuiLibrary.KeyClass)
	
	if prop.KeylessOption then obj.KeyLess = Signal.new() end
	obj.KeySignal = Signal.new()
	obj.Verify = Signal.new()
	obj.Get = Signal.new()
	obj.Auto = Signal.new()
	
	makefolder('ZLP_KEYSYSTEM')
	if not prop.Name then return error('Name required!') end
	
	local filename = 'ZLP_KEYSYSTEM/' .. tostring(game.PlaceId) .. '_' .. tostring(prop.Name)
	
	if not isfile(filename) then
		writefile(filename, '')
	end
	
	task.spawn(function()
		task.wait(1)
		obj.Auto:Fire(readfile(filename))
	end)
	
	local Frame = Instance.new("Frame")
	local UICorner = Instance.new("UICorner")
	local UIAspectRatioConstraint = Instance.new("UIAspectRatioConstraint")
	local Label = Instance.new("TextLabel")
	local UIPadding = Instance.new("UIPadding")
	local UICorner_2 = Instance.new("UICorner")
	local Label_2 = Instance.new("TextLabel")
	local Input = Instance.new("Frame")
	local UICorner_3 = Instance.new("UICorner")
	local TextBox = Instance.new("TextBox")
	local UIAspectRatioConstraint_2 = Instance.new("UIAspectRatioConstraint")
	local UIListLayout = Instance.new("UIListLayout")
	local GetKey = Instance.new("Frame")
	local UICorner_4 = Instance.new("UICorner")
	local Label_3 = Instance.new("TextLabel")
	local TextButton = Instance.new("TextButton")
	local btn = Instance.new("TextLabel")
	local UIAspectRatioConstraint_3 = Instance.new("UIAspectRatioConstraint")
	local VerifyKey = Instance.new("Frame")
	local UICorner_5 = Instance.new("UICorner")
	local Label_4 = Instance.new("TextLabel")
	local TextButton_2 = Instance.new("TextButton")
	local btn_2 = Instance.new("TextLabel")
	local UIAspectRatioConstraint_4 = Instance.new("UIAspectRatioConstraint")
	local VerifyKey_2 = Instance.new("Frame")
	local UICorner_6 = Instance.new("UICorner")
	local Label_5 = Instance.new("TextLabel")
	local TextButton_3 = Instance.new("TextButton")
	local btn_3 = Instance.new("TextLabel")
	local UIAspectRatioConstraint_5 = Instance.new("UIAspectRatioConstraint")
	local UIStroke = Instance.new('UIStroke')
	local UIStroke1 = Instance.new('UIStroke')
	local UIStroke2 = Instance.new('UIStroke')
	local UIStroke3 = Instance.new('UIStroke')
	local UIStroke4 = Instance.new('UIStroke')
	local UIStroke5 = Instance.new('UIStroke')
	local UIFlex = Instance.new('UIFlexItem')
	local UIFlex1 = Instance.new('UIFlexItem')
	local UIFlex2 = Instance.new('UIFlexItem')
	local UIFlex3 = Instance.new('UIFlexItem')
	local Canvas1 = Instance.new('CanvasGroup')
	local Canvas2 = Instance.new('CanvasGroup')
	local Canvas3 = Instance.new('CanvasGroup')
	
	local UICorner1 = Instance.new("UICorner")
	local Effect1 = Instance.new("Frame")
	local UIAspectRatioConstraint1 = Instance.new("UIAspectRatioConstraint")
	local UICorner1_2 = Instance.new("UICorner")
	local UICorner2 = Instance.new("UICorner")
	local Effect2 = Instance.new("Frame")
	local UIAspectRatioConstraint2 = Instance.new("UIAspectRatioConstraint")
	local UICorner2_2 = Instance.new("UICorner")
	local UICorner3 = Instance.new("UICorner")
	local Effect3 = Instance.new("Frame")
	local UIAspectRatioConstraint3 = Instance.new("UIAspectRatioConstraint")
	local UICorner3_2 = Instance.new("UICorner")
	
	local CloseUI = Instance.new("TextButton")
	local UIAspectRatioConstraint42 = Instance.new("UIAspectRatioConstraint")

	obj.ScreenGUI = Instance.new("ScreenGui")
	obj.ScreenGUI.Name = "ZLP_KEYSYSTEM"
	--obj.ScreenGUI.Parent = game:GetService("CoreGui")
	obj.ScreenGUI.Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui")
	obj.ScreenGUI.IgnoreGuiInset = true
	obj.ScreenGUI.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	obj.ScreenGUI.SafeAreaCompatibility = Enum.SafeAreaCompatibility.None
	obj.ScreenGUI.ScreenInsets = Enum.ScreenInsets.None
	obj.ScreenGUI.ResetOnSpawn = false

	Frame.Parent = obj.ScreenGUI
	Frame.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
	Frame.BorderColor3 = Color3.fromRGB(0, 0, 0)
	Frame.BorderSizePixel = 0
	Frame.Position = UDim2.new(0.35, 0, 0.25, 0)
	Frame.Size = UDim2.new(0.3, 0, 0.5, 0)

	UICorner.CornerRadius = UDim.new(0, 16)
	UICorner.Parent = Frame
	
	UIStroke.Color = Color3.fromRGB(170, 0, 255)
	UIStroke.Thickness = 4
	UIStroke.Parent = Frame

	UIAspectRatioConstraint.Parent = Frame
	UIAspectRatioConstraint.AspectRatio = 1.698

	Label.Name = "Label"
	Label.Parent = Frame
	Label.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	Label.BackgroundTransparency = 1.000
	Label.BorderColor3 = Color3.fromRGB(0, 0, 0)
	Label.BorderSizePixel = 0
	Label.Position = UDim2.new(0, 0, 0.0250000004, 0)
	Label.Size = UDim2.new(1, 0, 0.129999995, 0)
	Label.Font = Enum.Font.FredokaOne
	Label.Text = "    key system 🔑"
	Label.TextColor3 = Color3.fromRGB(255, 255, 255)
	Label.TextScaled = true
	Label.TextSize = 14.000
	Label.TextWrapped = true
	
	coroutine.wrap(function()
		local LocalScript = Instance.new('LocalScript')
		LocalScript.Parent = Label
		
		local script = LocalScript
		
		local UserInputService = game:GetService("UserInputService")

		local gui = script.Parent

		local dragging
		local dragInput
		local dragStart
		local startPos

		local function update(input)
			local delta = input.Position - dragStart
			gui.Parent.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
		end

		gui.InputBegan:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
				dragging = true
				dragStart = input.Position
				startPos = gui.Parent.Position

				input.Changed:Connect(function()
					if input.UserInputState == Enum.UserInputState.End then
						dragging = false
					end
				end)
			end
		end)

		gui.InputChanged:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
				dragInput = input
			end
		end)

		UserInputService.InputChanged:Connect(function(input)
			if input == dragInput and dragging then
				update(input)
			end
		end)
	end)()

	UIPadding.Parent = Label
	UIPadding.PaddingTop = UDim.new(0, 4)
	
	CloseUI.Name = "CloseUI"
	CloseUI.Parent = Label
	CloseUI.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	CloseUI.BackgroundTransparency = 1.000
	CloseUI.BorderColor3 = Color3.fromRGB(0, 0, 0)
	CloseUI.BorderSizePixel = 0
	CloseUI.Position = UDim2.new(0.920000017, 0, 0, 0)
	CloseUI.Size = UDim2.new(1, 0, 0.899999976, 0)
	CloseUI.Font = Enum.Font.FredokaOne
	CloseUI.Text = "X"
	CloseUI.TextColor3 = Color3.fromRGB(255, 255, 255)
	CloseUI.TextScaled = true
	CloseUI.TextSize = 14.000
	CloseUI.TextWrapped = true

	UIAspectRatioConstraint42.Parent = CloseUI

	local function UQYFOHY_fake_script() 
		local script = Instance.new('LocalScript', CloseUI)

		script.Parent.MouseButton1Click:Connect(function()
			script.Parent.Parent.Parent.Parent:Destroy()
		end)

	end
	coroutine.wrap(UQYFOHY_fake_script)()
	
	obj.Key = Instance.new('Frame')
	obj.Key.Name = "KeyINPUT"
	obj.Key.Parent = Frame
	obj.Key.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	obj.Key.BackgroundTransparency = 1.000
	obj.Key.BorderColor3 = Color3.fromRGB(0, 0, 0)
	obj.Key.BorderSizePixel = 0
	obj.Key.LayoutOrder = 1
	obj.Key.Position = UDim2.new(0, 0, 0.0820000023, 0)
	obj.Key.Size = UDim2.new(0.970000029, 0, 0.150000006, 0)
	obj.Key.ZIndex = 2

	UICorner_2.CornerRadius = UDim.new(0, 16)
	UICorner_2.Parent = obj.Key
	
	UIFlex.ItemLineAlignment = Enum.ItemLineAlignment.Center
	UIFlex.Parent = obj.Key
	
	UIStroke1.Color = Color3.fromRGB(170, 0, 255)
	UIStroke1.Thickness = 1
	UIStroke1.Parent = obj.Key

	Label_2.Name = "Label"
	Label_2.Parent = obj.Key
	Label_2.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	Label_2.BackgroundTransparency = 1.000
	Label_2.BorderColor3 = Color3.fromRGB(0, 0, 0)
	Label_2.BorderSizePixel = 0
	Label_2.Position = UDim2.new(0.0500000007, 0, 0.300000012, 0)
	Label_2.Size = UDim2.new(0.150000006, 0, 0.42899999, 0)
	Label_2.ZIndex = 2
	Label_2.Font = Enum.Font.FredokaOne
	Label_2.Text = "Key:"
	Label_2.TextColor3 = Color3.fromRGB(255, 255, 255)
	Label_2.TextScaled = true
	Label_2.TextSize = 16.000
	Label_2.TextWrapped = true
	Label_2.TextXAlignment = Enum.TextXAlignment.Left

	Input.Name = "Input"
	Input.Parent = obj.Key
	Input.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	Input.BackgroundTransparency = 1.000
	Input.BorderColor3 = Color3.fromRGB(0, 0, 0)
	Input.BorderSizePixel = 0
	Input.Position = UDim2.new(0.219999999, 0, 0.125, 0)
	Input.Size = UDim2.new(0.75, 0, 0.75, 0)
	Input.ZIndex = 2
	
	UIStroke5.Color = Color3.fromRGB(170, 0, 255)
	UIStroke5.Thickness = 0.5
	UIStroke5.Parent = Input

	UICorner_3.Parent = Input

	TextBox.Parent = Input
	TextBox.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	TextBox.BackgroundTransparency = 1.000
	TextBox.BorderColor3 = Color3.fromRGB(0, 0, 0)
	TextBox.BorderSizePixel = 0
	TextBox.Size = UDim2.new(1, 0, 1, 0)
	TextBox.ClearTextOnFocus = false
	TextBox.Font = Enum.Font.FredokaOne
	TextBox.PlaceholderText = "Key"
	TextBox.Text = ""
	TextBox.TextColor3 = Color3.fromRGB(255, 255, 255)
	TextBox.TextSize = 14.000

	UIAspectRatioConstraint_2.Parent = obj.Key
	UIAspectRatioConstraint_2.AspectRatio = 10.980

	UIListLayout.Parent = Frame
	UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
	UIListLayout.Padding = UDim.new(0, 6)

	GetKey.Name = "GetKey"
	GetKey.Parent = Frame
	GetKey.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	GetKey.BackgroundTransparency = 1.000
	GetKey.BorderColor3 = Color3.fromRGB(0, 0, 0)
	GetKey.BorderSizePixel = 0
	GetKey.LayoutOrder = 2
	GetKey.Size = UDim2.new(0.970000029, 0, 0.150000006, 0)

	UICorner_4.CornerRadius = UDim.new(0, 16)
	UICorner_4.Parent = GetKey
	
	UIStroke2.Color = Color3.fromRGB(170, 0, 255)
	UIStroke2.Thickness = 1
	UIStroke2.Parent = GetKey
	
	UIFlex1.ItemLineAlignment = Enum.ItemLineAlignment.Center
	UIFlex1.Parent = GetKey

	Label_3.Name = "Label"
	Label_3.Parent = GetKey
	Label_3.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	Label_3.BackgroundTransparency = 1.000
	Label_3.BorderColor3 = Color3.fromRGB(0, 0, 0)
	Label_3.BorderSizePixel = 0
	Label_3.Position = UDim2.new(0.0500000007, 0, 0.300000012, 0)
	Label_3.Size = UDim2.new(0.699999988, 0, 0.42899999, 0)
	Label_3.ZIndex = 2
	Label_3.Font = Enum.Font.FredokaOne
	Label_3.Text = "Get key"
	Label_3.TextColor3 = Color3.fromRGB(255, 255, 255)
	Label_3.TextScaled = true
	Label_3.TextSize = 16.000
	Label_3.TextWrapped = true
	Label_3.TextXAlignment = Enum.TextXAlignment.Left

	TextButton.Parent = GetKey
	TextButton.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	TextButton.BackgroundTransparency = 1.000
	TextButton.BorderColor3 = Color3.fromRGB(0, 0, 0)
	TextButton.BorderSizePixel = 0
	TextButton.ClipsDescendants = true
	TextButton.Size = UDim2.new(1, 0, 1, 0)
	TextButton.Font = Enum.Font.SourceSans
	TextButton.Text = ""
	TextButton.TextColor3 = Color3.fromRGB(0, 0, 0)
	TextButton.TextSize = 14.000
	
	Canvas1.Parent = TextButton
	Canvas1.BackgroundTransparency = 1
	Canvas1.Size = UDim2.fromScale(1, 1)
	
	UICorner1.CornerRadius = UDim.new(0, 16)
	UICorner1.Parent = Canvas1

	Effect1.Name = "Effect"
	Effect1.Parent = Canvas1
	Effect1.AnchorPoint = Vector2.new(0.5, 0.5)
	Effect1.BackgroundColor3 = Color3.fromRGB(170, 0, 255)
	Effect1.BackgroundTransparency = 1.000
	Effect1.BorderColor3 = Color3.fromRGB(0, 0, 0)
	Effect1.BorderSizePixel = 0
	Effect1.Size = UDim2.new(0.400000006, 0, 0.400000006, 0)

	UIAspectRatioConstraint1.Parent = Effect1

	UICorner1_2.CornerRadius = UDim.new(1, 0)
	UICorner1_2.Parent = Effect1

	btn.Name = "btn"
	btn.Parent = GetKey
	btn.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	btn.BackgroundTransparency = 1.000
	btn.BorderColor3 = Color3.fromRGB(0, 0, 0)
	btn.BorderSizePixel = 0
	btn.Position = UDim2.new(0.699999988, 0, 0.25, 0)
	btn.Size = UDim2.new(0.25, 0, 0.5, 0)
	btn.Font = Enum.Font.FredokaOne
	btn.Text = "click"
	btn.TextColor3 = Color3.fromRGB(170, 0, 255)
	btn.TextSize = 14.000

	UIAspectRatioConstraint_3.Parent = GetKey
	UIAspectRatioConstraint_3.AspectRatio = 10.980

	VerifyKey.Name = "VerifyKey"
	VerifyKey.Parent = Frame
	VerifyKey.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	VerifyKey.BackgroundTransparency = 1.000
	VerifyKey.BorderColor3 = Color3.fromRGB(0, 0, 0)
	VerifyKey.BorderSizePixel = 0
	VerifyKey.LayoutOrder = 3
	VerifyKey.Size = UDim2.new(0.970000029, 0, 0.150000006, 0)

	UICorner_5.CornerRadius = UDim.new(0, 16)
	UICorner_5.Parent = VerifyKey
	
	UIStroke3.Color = Color3.fromRGB(217, 0, 255)
	UIStroke3.Thickness = 1
	UIStroke3.Parent = VerifyKey
	
	UIFlex2.ItemLineAlignment = Enum.ItemLineAlignment.Center
	UIFlex2.Parent = VerifyKey

	Label_4.Name = "Label"
	Label_4.Parent = VerifyKey
	Label_4.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	Label_4.BackgroundTransparency = 1.000
	Label_4.BorderColor3 = Color3.fromRGB(0, 0, 0)
	Label_4.BorderSizePixel = 0
	Label_4.Position = UDim2.new(0.0500000007, 0, 0.300000012, 0)
	Label_4.Size = UDim2.new(0.699999988, 0, 0.42899999, 0)
	Label_4.ZIndex = 2
	Label_4.Font = Enum.Font.FredokaOne
	Label_4.Text = "Verify key"
	Label_4.TextColor3 = Color3.fromRGB(255, 255, 255)
	Label_4.TextScaled = true
	Label_4.TextSize = 16.000
	Label_4.TextWrapped = true
	Label_4.TextXAlignment = Enum.TextXAlignment.Left

	TextButton_2.Parent = VerifyKey
	TextButton_2.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	TextButton_2.BackgroundTransparency = 1.000
	TextButton_2.BorderColor3 = Color3.fromRGB(0, 0, 0)
	TextButton_2.BorderSizePixel = 0
	TextButton_2.ClipsDescendants = true
	TextButton_2.Size = UDim2.new(1, 0, 1, 0)
	TextButton_2.Font = Enum.Font.SourceSans
	TextButton_2.Text = ""
	TextButton_2.TextColor3 = Color3.fromRGB(0, 0, 0)
	TextButton_2.TextSize = 14.000
	
	Canvas2.Parent = TextButton_2
	Canvas2.BackgroundTransparency = 1
	Canvas2.Size = UDim2.fromScale(1, 1)

	UICorner2.CornerRadius = UDim.new(0, 16)
	UICorner2.Parent = Canvas2

	Effect2.Name = "Effect"
	Effect2.Parent = Canvas2
	Effect2.AnchorPoint = Vector2.new(0.5, 0.5)
	Effect2.BackgroundColor3 = Color3.fromRGB(170, 0, 255)
	Effect2.BackgroundTransparency = 1.000
	Effect2.BorderColor3 = Color3.fromRGB(0, 0, 0)
	Effect2.BorderSizePixel = 0
	Effect2.Size = UDim2.new(0.400000006, 0, 0.400000006, 0)

	UIAspectRatioConstraint2.Parent = Effect2

	UICorner2_2.CornerRadius = UDim.new(1, 0)
	UICorner2_2.Parent = Effect2

	btn_2.Name = "btn"
	btn_2.Parent = VerifyKey
	btn_2.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	btn_2.BackgroundTransparency = 1.000
	btn_2.BorderColor3 = Color3.fromRGB(0, 0, 0)
	btn_2.BorderSizePixel = 0
	btn_2.Position = UDim2.new(0.699999988, 0, 0.25, 0)
	btn_2.Size = UDim2.new(0.25, 0, 0.5, 0)
	btn_2.Font = Enum.Font.FredokaOne
	btn_2.Text = "click"
	btn_2.TextColor3 = Color3.fromRGB(217, 0, 255)
	btn_2.TextSize = 14.000

	UIAspectRatioConstraint_4.Parent = VerifyKey
	UIAspectRatioConstraint_4.AspectRatio = 10.980
	
	if prop.KeylessOption then
		VerifyKey_2.Name = "KeyLess"
		VerifyKey_2.Parent = Frame
		VerifyKey_2.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		VerifyKey_2.BackgroundTransparency = 1.000
		VerifyKey_2.BorderColor3 = Color3.fromRGB(0, 0, 0)
		VerifyKey_2.BorderSizePixel = 0
		VerifyKey_2.LayoutOrder = 4
		VerifyKey_2.Size = UDim2.new(0.5, 0, 0.150000006, 0)
	
		UICorner_6.CornerRadius = UDim.new(0, 16)
		UICorner_6.Parent = VerifyKey_2
		
		UIStroke4.Color = Color3.fromRGB(111, 0, 166)
		UIStroke4.Thickness = 1
		UIStroke4.Parent = VerifyKey_2
	
		UIFlex3.ItemLineAlignment = Enum.ItemLineAlignment.Center
		UIFlex3.Parent = VerifyKey_2
	
		Label_5.Name = "Label"
		Label_5.Parent = VerifyKey_2
		Label_5.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		Label_5.BackgroundTransparency = 1.000
		Label_5.BorderColor3 = Color3.fromRGB(0, 0, 0)
		Label_5.BorderSizePixel = 0
		Label_5.Position = UDim2.new(0.0500000007, 0, 0.300000012, 0)
		Label_5.Size = UDim2.new(0.699999988, 0, 0.42899999, 0)
		Label_5.ZIndex = 2
		Label_5.Font = Enum.Font.FredokaOne
		Label_5.Text = "Keyless script"
		Label_5.TextColor3 = Color3.fromRGB(255, 255, 255)
		Label_5.TextScaled = true
		Label_5.TextSize = 16.000
		Label_5.TextWrapped = true
		Label_5.TextXAlignment = Enum.TextXAlignment.Left
	
		TextButton_3.Parent = VerifyKey_2
		TextButton_3.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		TextButton_3.BackgroundTransparency = 1.000
		TextButton_3.BorderColor3 = Color3.fromRGB(0, 0, 0)
		TextButton_3.BorderSizePixel = 0
		TextButton_3.ClipsDescendants = true
		TextButton_3.Size = UDim2.new(1, 0, 1, 0)
		TextButton_3.Font = Enum.Font.SourceSans
		TextButton_3.Text = ""
		TextButton_3.TextColor3 = Color3.fromRGB(0, 0, 0)
		TextButton_3.TextSize = 14.000
		
		Canvas3.Parent = TextButton_3
		Canvas3.BackgroundTransparency = 1
		Canvas3.Size = UDim2.fromScale(1, 1)
	
		UICorner3.CornerRadius = UDim.new(0, 16)
		UICorner3.Parent = Canvas3
	
		Effect3.Name = "Effect"
		Effect3.Parent = Canvas3
		Effect3.AnchorPoint = Vector2.new(0.5, 0.5)
		Effect3.BackgroundColor3 = Color3.fromRGB(170, 0, 255)
		Effect3.BackgroundTransparency = 1.000
		Effect3.BorderColor3 = Color3.fromRGB(0, 0, 0)
		Effect3.BorderSizePixel = 0
		Effect3.Size = UDim2.new(0.400000006, 0, 0.400000006, 0)
	
		UIAspectRatioConstraint3.Parent = Effect3
	
		UICorner3_2.CornerRadius = UDim.new(1, 0)
		UICorner3_2.Parent = Effect3
	
		btn_3.Name = "btn"
		btn_3.Parent = VerifyKey_2
		btn_3.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		btn_3.BackgroundTransparency = 1.000
		btn_3.BorderColor3 = Color3.fromRGB(0, 0, 0)
		btn_3.BorderSizePixel = 0
		btn_3.Position = UDim2.new(0.699999988, 0, 0.25, 0)
		btn_3.Size = UDim2.new(0.25, 0, 0.5, 0)
		btn_3.Font = Enum.Font.FredokaOne
		btn_3.Text = "click"
		btn_3.TextColor3 = Color3.fromRGB(111, 0, 166)
		btn_3.TextSize = 14.000
	
		UIAspectRatioConstraint_5.Parent = VerifyKey_2
		UIAspectRatioConstraint_5.AspectRatio = 5.660
	end


	local function GSSLKZC_fake_script() -- KeyINPUT.INPUT 
		local script = Instance.new('LocalScript', obj.Key)

		local Tween = game:GetService("TweenService")

		local colortweeninfo = TweenInfo.new(0.25, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, 0, false, 0)

		script.Parent:GetAttributeChangedSignal("disabled"):Connect(function()
			if script.Parent:GetAttribute('disabled') then
				Tween:Create(script.Parent.UIStroke, colortweeninfo, {Color = Color3.fromRGB(130, 130, 130)}):Play()
				Tween:Create(script.Parent.Input.UIStroke, colortweeninfo, {Color = Color3.fromRGB(130, 130, 130)}):Play()
				script.Parent.Input.TextBox.TextEditable = false
			else
				Tween:Create(script.Parent.UIStroke, colortweeninfo, {Color = Color3.fromRGB(170, 0, 255)}):Play()
				Tween:Create(script.Parent.Input.UIStroke, colortweeninfo, {Color = Color3.fromRGB(170, 0, 255)}):Play()
				script.Parent.Input.TextBox.TextEditable = true
			end
		end)

		script.Parent.Input.TextBox:GetPropertyChangedSignal("Text"):Connect(function()
			script.Parent:SetAttribute('value', script.Parent.Input.TextBox.Text)
			obj.KeySignal:Fire(script.Parent.Input.TextBox.Text)
			writefile(filename, script.Parent.Input.TextBox.Text)
		end)
	end
	coroutine.wrap(GSSLKZC_fake_script)()
	local function JAPOLUT_fake_script() -- TextButton.BUTTON 
		local script = Instance.new('LocalScript', TextButton)

		local Tween = game:GetService("TweenService")

		local ScreenGUI = script.Parent.Parent.Parent.Parent
		local Effect = script.Parent.CanvasGroup.Effect 

		local pressed = script.Parent.Parent:GetAttribute("state")
		local animation = false

		local tweeninfo1 = TweenInfo.new(0.25, Enum.EasingStyle.Sine, Enum.EasingDirection.In, 0, true, 0)
		local colortweeninfo = TweenInfo.new(0.25, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, 0, false, 0)

		script.Parent.MouseEnter:Connect(function(x, y)
			if not animation and not script.Parent.Parent:GetAttribute("disabled") then
				Effect.Position = UDim2.new(0, -(Effect.AbsolutePosition.X - Effect.Position.X.Offset - x + Effect.AbsoluteSize.X / 2), 0, -(Effect.AbsolutePosition.Y - Effect.Position.Y.Offset - y - ScreenGUI.AbsolutePosition.Y + Effect.AbsoluteSize.Y / 2))
			end
		end)

		script.Parent.MouseMoved:Connect(function(x, y)
			if not animation and not script.Parent.Parent:GetAttribute("disabled") then
				Effect.Position = UDim2.new(0, -(Effect.AbsolutePosition.X - Effect.Position.X.Offset - x + Effect.AbsoluteSize.X / 2), 0, -(Effect.AbsolutePosition.Y - Effect.Position.Y.Offset - y - ScreenGUI.AbsolutePosition.Y + Effect.AbsoluteSize.Y / 2))
			end
		end)

		script.Parent.MouseLeave:Connect(function()
			if not animation and not script.Parent.Parent:GetAttribute("disabled") then
				Effect.BackgroundTransparency = 1
			end
		end)

		script.Parent.MouseButton1Click:Connect(function()
			wait()
			if not animation and not script.Parent.Parent:GetAttribute("disabled") then
				script.Parent.Parent:SetAttribute("state", true)
				animation = true
				obj.Get:Fire()
				local multiplier_radius = 2 - (script.Parent.AbsoluteSize.X / 2 / math.max(math.abs(script.Parent.AbsolutePosition.X - Effect.AbsolutePosition.X + Effect.AbsoluteSize.X / 2), math.abs(math.abs(script.Parent.AbsolutePosition.X - Effect.AbsolutePosition.X + Effect.AbsoluteSize.X / 2) - script.Parent.AbsoluteSize.X)))
				local size = script.Parent.AbsolutePosition.X * (multiplier_radius - 0.4) / Effect.AbsoluteSize.X * Effect.Size.X.Scale
				Tween:Create(Effect, tweeninfo1, {Transparency = 0}):Play()
				local move = Tween:Create(Effect, tweeninfo1, {Size = UDim2.new(size, 0, size, 0)})
				move:Play()
				move.Completed:Wait()

				Effect.Transparency = 1
				Effect.Size = UDim2.new(0.4, 0, 0.4, 0)

				animation = false
				script.Parent.Parent:SetAttribute("state", false)
			end
		end)

		script.Parent.Parent:GetAttributeChangedSignal("disabled"):Connect(function()
			if script.Parent.Parent:GetAttribute("disabled") then
				Tween:Create(script.Parent.Parent.UIStroke, colortweeninfo, {Color = Color3.fromRGB(130, 130, 130)}):Play()
				Tween:Create(script.Parent.Parent.btn, colortweeninfo, {TextTransparency = 1}):Play()
			else
				Tween:Create(script.Parent.Parent.UIStroke, colortweeninfo, {Color = Color3.fromRGB(170, 0, 255)}):Play()
				Tween:Create(script.Parent.Parent.btn, colortweeninfo, {TextTransparency = 0}):Play()
			end
		end)
	end
	coroutine.wrap(JAPOLUT_fake_script)()
	local function ADCNTNH_fake_script() -- TextButton_2.BUTTON 
		local script = Instance.new('LocalScript', TextButton_2)

		local Tween = game:GetService("TweenService")

		local ScreenGUI = script.Parent.Parent.Parent.Parent
		local Effect = script.Parent.CanvasGroup.Effect 

		local pressed = script.Parent.Parent:GetAttribute("state")
		local animation = false

		local tweeninfo1 = TweenInfo.new(0.25, Enum.EasingStyle.Sine, Enum.EasingDirection.In, 0, true, 0)
		local colortweeninfo = TweenInfo.new(0.25, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, 0, false, 0)

		script.Parent.MouseEnter:Connect(function(x, y)
			if not animation and not script.Parent.Parent:GetAttribute("disabled") then
				Effect.Position = UDim2.new(0, -(Effect.AbsolutePosition.X - Effect.Position.X.Offset - x + Effect.AbsoluteSize.X / 2), 0, -(Effect.AbsolutePosition.Y - Effect.Position.Y.Offset - y - ScreenGUI.AbsolutePosition.Y + Effect.AbsoluteSize.Y / 2))
			end
		end)

		script.Parent.MouseMoved:Connect(function(x, y)
			if not animation and not script.Parent.Parent:GetAttribute("disabled") then
				Effect.Position = UDim2.new(0, -(Effect.AbsolutePosition.X - Effect.Position.X.Offset - x + Effect.AbsoluteSize.X / 2), 0, -(Effect.AbsolutePosition.Y - Effect.Position.Y.Offset - y - ScreenGUI.AbsolutePosition.Y + Effect.AbsoluteSize.Y / 2))
			end
		end)

		script.Parent.MouseLeave:Connect(function()
			if not animation and not script.Parent.Parent:GetAttribute("disabled") then
				Effect.BackgroundTransparency = 1
			end
		end)

		script.Parent.MouseButton1Click:Connect(function()
			wait()
			if not animation and not script.Parent.Parent:GetAttribute("disabled") then
				script.Parent.Parent:SetAttribute("state", true)
				animation = true
				obj.Verify:Fire()
				local multiplier_radius = 2 - (script.Parent.AbsoluteSize.X / 2 / math.max(math.abs(script.Parent.AbsolutePosition.X - Effect.AbsolutePosition.X + Effect.AbsoluteSize.X / 2), math.abs(math.abs(script.Parent.AbsolutePosition.X - Effect.AbsolutePosition.X + Effect.AbsoluteSize.X / 2) - script.Parent.AbsoluteSize.X)))
				local size = script.Parent.AbsolutePosition.X * (multiplier_radius - 0.4) / Effect.AbsoluteSize.X * Effect.Size.X.Scale
				Tween:Create(Effect, tweeninfo1, {Transparency = 0}):Play()
				local move = Tween:Create(Effect, tweeninfo1, {Size = UDim2.new(size, 0, size, 0)})
				move:Play()
				move.Completed:Wait()

				Effect.Transparency = 1
				Effect.Size = UDim2.new(0.4, 0, 0.4, 0)

				animation = false
				script.Parent.Parent:SetAttribute("state", false)
			end
		end)

		script.Parent.Parent:GetAttributeChangedSignal("disabled"):Connect(function()
			if script.Parent.Parent:GetAttribute("disabled") then
				Tween:Create(script.Parent.Parent.UIStroke, colortweeninfo, {Color = Color3.fromRGB(130, 130, 130)}):Play()
				Tween:Create(script.Parent.Parent.btn, colortweeninfo, {TextTransparency = 1}):Play()
			else
				Tween:Create(script.Parent.Parent.UIStroke, colortweeninfo, {Color = Color3.fromRGB(170, 0, 255)}):Play()
				Tween:Create(script.Parent.Parent.btn, colortweeninfo, {TextTransparency = 0}):Play()
			end
		end)
	end
	coroutine.wrap(ADCNTNH_fake_script)()
	local function KUWEGDY_fake_script()
		local script = Instance.new('LocalScript', TextButton_3)

		local Tween = game:GetService("TweenService")

		local ScreenGUI = script.Parent.Parent.Parent.Parent
		local Effect = script.Parent.CanvasGroup.Effect 

		local pressed = script.Parent.Parent:GetAttribute("state")
		local animation = false

		local tweeninfo1 = TweenInfo.new(0.25, Enum.EasingStyle.Sine, Enum.EasingDirection.In, 0, true, 0)
		local colortweeninfo = TweenInfo.new(0.25, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, 0, false, 0)

		script.Parent.MouseEnter:Connect(function(x, y)
			if not animation and not script.Parent.Parent:GetAttribute("disabled") then
				Effect.Position = UDim2.new(0, -(Effect.AbsolutePosition.X - Effect.Position.X.Offset - x + Effect.AbsoluteSize.X / 2), 0, -(Effect.AbsolutePosition.Y - Effect.Position.Y.Offset - y - ScreenGUI.AbsolutePosition.Y + Effect.AbsoluteSize.Y / 2))
			end
		end)

		script.Parent.MouseMoved:Connect(function(x, y)
			if not animation and not script.Parent.Parent:GetAttribute("disabled") then
				Effect.Position = UDim2.new(0, -(Effect.AbsolutePosition.X - Effect.Position.X.Offset - x + Effect.AbsoluteSize.X / 2), 0, -(Effect.AbsolutePosition.Y - Effect.Position.Y.Offset - y - ScreenGUI.AbsolutePosition.Y + Effect.AbsoluteSize.Y / 2))
			end
		end)

		script.Parent.MouseLeave:Connect(function()
			if not animation and not script.Parent.Parent:GetAttribute("disabled") then
				Effect.BackgroundTransparency = 1
			end
		end)

		script.Parent.MouseButton1Click:Connect(function()
			wait()
			if not animation and not script.Parent.Parent:GetAttribute("disabled") then
				script.Parent.Parent:SetAttribute("state", true)
				animation = true
				obj.KeyLess:Fire()
				local multiplier_radius = 2 - (script.Parent.AbsoluteSize.X / 2 / math.max(math.abs(script.Parent.AbsolutePosition.X - Effect.AbsolutePosition.X + Effect.AbsoluteSize.X / 2), math.abs(math.abs(script.Parent.AbsolutePosition.X - Effect.AbsolutePosition.X + Effect.AbsoluteSize.X / 2) - script.Parent.AbsoluteSize.X)))
				local size = script.Parent.AbsolutePosition.X * (multiplier_radius - 0.4) / Effect.AbsoluteSize.X * Effect.Size.X.Scale
				Tween:Create(Effect, tweeninfo1, {Transparency = 0}):Play()
				local move = Tween:Create(Effect, tweeninfo1, {Size = UDim2.new(size, 0, size, 0)})
				move:Play()
				move.Completed:Wait()

				Effect.Transparency = 1
				Effect.Size = UDim2.new(0.4, 0, 0.4, 0)

				animation = false
				script.Parent.Parent:SetAttribute("state", false)
			end
		end)

		script.Parent.Parent:GetAttributeChangedSignal("disabled"):Connect(function()
			if script.Parent.Parent:GetAttribute("disabled") then
				Tween:Create(script.Parent.Parent.UIStroke, colortweeninfo, {Color = Color3.fromRGB(130, 130, 130)}):Play()
				Tween:Create(script.Parent.Parent.btn, colortweeninfo, {TextTransparency = 1}):Play()
			else
				Tween:Create(script.Parent.Parent.UIStroke, colortweeninfo, {Color = Color3.fromRGB(170, 0, 255)}):Play()
				Tween:Create(script.Parent.Parent.btn, colortweeninfo, {TextTransparency = 0}):Play()
			end
		end)
	end
	if prop.KeylessOption then coroutine.wrap(KUWEGDY_fake_script)() end
	
	return obj
end

function GuiLibrary:NewWindow(properties)
	local obj = {}
	setmetatable(obj, GuiLibrary.WindowClass)
	
	obj.ScreenGUI = Instance.new("ScreenGui")
	obj.ScreenGUI.Name = "https://discord.gg/nNYyfcsfR8"
	obj.ScreenGUI.Parent = game:GetService("CoreGui")
	if not properties.CoreGUI then obj.ScreenGUI.Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui") end
	obj.ScreenGUI.IgnoreGuiInset = true
	obj.ScreenGUI.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	obj.ScreenGUI.SafeAreaCompatibility = Enum.SafeAreaCompatibility.None
	obj.ScreenGUI.ScreenInsets = Enum.ScreenInsets.None
	obj.ScreenGUI.ResetOnSpawn = false
	
	obj.Window = {}
	obj.Window.Part = Instance.new("Frame")
	obj.Window.Part.Name = "Main"
	obj.Window.Part.Parent = obj.ScreenGUI
	obj.Window.Part.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
	obj.Window.Part.BorderColor3 = Color3.fromRGB(0, 0, 0)
	obj.Window.Part.BorderSizePixel = 0
	obj.Window.Part.Position = UDim2.new(0.419, 0, 0.1, 0)
	obj.Window.Part.Size = UDim2.new(0.8, 0, 0.8, 0)
	obj.Window.Part.Parent = obj.ScreenGUI
	
	local UIAspectRatioConstraint = Instance.new("UIAspectRatioConstraint")
	UIAspectRatioConstraint.Parent = obj.Window.Part
	UIAspectRatioConstraint.AspectRatio = 0.800

	local UICorner = Instance.new("UICorner")
	UICorner.CornerRadius = UDim.new(0, 16)
	UICorner.Parent = obj.Window.Part
	
	obj.Window.UIStroke = Instance.new("UIStroke")
	obj.Window.UIStroke.Color = Color3.fromRGB(170, 0, 255)
	obj.Window.UIStroke.Thickness = 4
	obj.Window.UIStroke.Parent = obj.Window.Part
	
	obj.Window.Upper = {}
	obj.Window.Upper.Part = Instance.new('Frame')
	obj.Window.Upper.Part.Name = "Upper"
	obj.Window.Upper.Part.Parent = obj.Window.Part
	obj.Window.Upper.Part.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	obj.Window.Upper.Part.BackgroundTransparency = 1.000
	obj.Window.Upper.Part.BorderColor3 = Color3.fromRGB(0, 0, 0)
	obj.Window.Upper.Part.BorderSizePixel = 0
	obj.Window.Upper.Part.Size = UDim2.new(1, 0, 0.12, 0)
	
	obj.Window.Tabs = {}
	obj.Window.Tabs.Part = Instance.new('Folder')
	obj.Window.Tabs.Part.Name = "TabsFolder"
	obj.Window.Tabs.Part.Parent = obj.Window.Part
	
	-- Upper
	
	obj.Window.Upper.Label = {}
	obj.Window.Upper.Label.Part = Instance.new("TextLabel")
	obj.Window.Upper.Label.Part.Name = "Label"
	obj.Window.Upper.Label.Part.Parent = obj.Window.Upper.Part
	obj.Window.Upper.Label.Part.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	obj.Window.Upper.Label.Part.BackgroundTransparency = 1.000
	obj.Window.Upper.Label.Part.BorderColor3 = Color3.fromRGB(0, 0, 0)
	obj.Window.Upper.Label.Part.BorderSizePixel = 0
	obj.Window.Upper.Label.Part.Position = UDim2.new(0.0399999991, 0, 0, 0)
	obj.Window.Upper.Label.Part.Size = UDim2.new(0.959999979, 0, 1, 0)
	obj.Window.Upper.Label.Part.Font = Enum.Font.FredokaOne
	obj.Window.Upper.Label.Part.Text = properties.Name or "ZALUPA GUI"
	obj.Window.Upper.Label.Part.TextColor3 = Color3.fromRGB(255, 255, 255)
	obj.Window.Upper.Label.Part.TextSize = 24.000
	obj.Window.Upper.Label.Part.TextWrapped = true
	obj.Window.Upper.Label.Part.TextXAlignment = Enum.TextXAlignment.Left

	local UITextSizeConstraint = Instance.new("UITextSizeConstraint")
	UITextSizeConstraint.Parent = obj.Window.Upper.Label.Part

	local CloseUI = Instance.new("TextButton")
	CloseUI.Name = "CloseUI"
	CloseUI.Parent = obj.Window.Upper.Part
	CloseUI.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	CloseUI.BackgroundTransparency = 1.000
	CloseUI.BorderColor3 = Color3.fromRGB(0, 0, 0)
	CloseUI.BorderSizePixel = 0
	CloseUI.Position = UDim2.new(0.870000005, 0, 0.100000001, 0)
	CloseUI.Size = UDim2.new(1, 0, 0.800000012, 0)
	CloseUI.Font = Enum.Font.FredokaOne
	CloseUI.Text = "X"
	CloseUI.TextColor3 = Color3.fromRGB(255, 255, 255)
	CloseUI.TextScaled = true
	CloseUI.TextSize = 14.000
	CloseUI.TextWrapped = true

	local UIAspectRatioConstraint = Instance.new("UIAspectRatioConstraint")
	UIAspectRatioConstraint.Parent = CloseUI

	local UICorner = Instance.new('UICorner')
	UICorner.CornerRadius = UDim.new(0, 16)
	UICorner.Parent = obj.Window.Upper.Part
	
	local UIStroke = Instance.new('UIStroke')
	UIStroke.Color = Color3.fromRGB(170, 0, 255)
	UIStroke.Thickness = 4
	UIStroke.Parent = obj.Window.Upper.Part
	
	local CloseScript = Instance.new("LocalScript")
	local DragScript = Instance.new("LocalScript")
	
	CloseScript.Parent = CloseUI
	DragScript.Parent = obj.Window.Upper.Part
	
	coroutine.wrap(function()
		local script = CloseScript
		script.Parent.MouseButton1Click:Connect(function()
			script.Parent.Parent.Parent:Destroy()
		end)
	end)()
	
	coroutine.wrap(function()
		local script = DragScript
		local UserInputService = game:GetService("UserInputService")

		local gui = script.Parent

		local dragging
		local dragInput
		local dragStart
		local startPos

		local function update(input)
			local delta = input.Position - dragStart
			gui.Parent.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
		end

		gui.InputBegan:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
				dragging = true
				dragStart = input.Position
				startPos = gui.Parent.Position

				input.Changed:Connect(function()
					if input.UserInputState == Enum.UserInputState.End then
						dragging = false
					end
				end)
			end
		end)

		gui.InputChanged:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
				dragInput = input
			end
		end)

		UserInputService.InputChanged:Connect(function(input)
			if input == dragInput and dragging then
				update(input)
			end
		end)
	end)()
	
	return obj
end

function GuiLibrary.WindowClass:CreateTab(prop)
	local obj = {}
	setmetatable(obj, GuiLibrary.TabClass)
	
	local index = #self.Window.Tabs.Part:GetChildren() + 1
	obj[index] = {}
	obj[index].Name = prop.Name
	obj[index].Part = Instance.new('Frame')
	obj[index].Part.Name = index
	obj[index].Part.Parent = self.Window.Tabs.Part
	obj[index].Part.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	obj[index].Part.BackgroundTransparency = 1.000
	obj[index].Part.BorderColor3 = Color3.fromRGB(0, 0, 0)
	obj[index].Part.BorderSizePixel = 0
	obj[index].Part.Size = UDim2.new(1, 0, 0.87, -8)
	obj[index].Part.Position = UDim2.new(0, 0, 0.13, 8)
	obj[index].Part.Visible = (index == 1)
	obj[index].Part:SetAttribute('name', prop.Name)
	
	local UICorner = Instance.new("UICorner")
	UICorner.CornerRadius = UDim.new(0, 16)
	UICorner.Parent = obj[index].Part
	
	local UIStroke = Instance.new('UIStroke')
	UIStroke.Color = Color3.fromRGB(170, 0, 255)
	UIStroke.Thickness = 4
	UIStroke.Parent = obj[index].Part
	
	obj[index].Frame = {}
	obj[index].Frame.Part = Instance.new("ScrollingFrame")
	obj[index].Frame.Part.Name = 'Frame'
	obj[index].Frame.Part.Parent = obj[index].Part
	obj[index].Frame.Part.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	obj[index].Frame.Part.BackgroundTransparency = 1.000
	obj[index].Frame.Part.Size = UDim2.new(1, 0, 1, 0)
	obj[index].Frame.Part.Position = UDim2.new(0, 0, 0, 0)
	obj[index].Frame.Part.BorderSizePixel = 0
	obj[index].Frame.Part.CanvasSize = UDim2.new(0, 0, 0, 0)
	obj[index].Frame.Part.ScrollBarThickness = 4
	obj[index].Frame.Part.ScrollBarImageColor3 = Color3.fromRGB(170, 0, 255)
	obj[index].Frame.Part:SetAttribute('resize', false)
	
	local UIListLayout = Instance.new("UIListLayout")
	UIListLayout.Parent = obj[index].Frame.Part
	UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
	UIListLayout.Padding = UDim.new(0, 8)
	
	local UIPadding = Instance.new("UIPadding")
	UIPadding.Parent = obj[index].Frame.Part
	UIPadding.PaddingTop = UDim.new(0, 8)
	UIPadding.PaddingBottom = UDim.new(0, 8)
	
	local LocalScript = Instance.new('LocalScript')
	LocalScript.Parent = obj[index].Frame.Part
	coroutine.wrap(function()
		local script = LocalScript
		script.Parent:GetAttributeChangedSignal("resize"):Connect(function()
			if script.Parent:GetAttribute("resize") then
				script.Parent.CanvasSize = UDim2.fromOffset(0, script.Parent.UIListLayout.AbsoluteContentSize.Y + 12)
				script.Parent:SetAttribute("resize", false)
			end
		end)
		
		wait()
		script.Parent:SetAttribute("resize", true)
	end)()
	
	if index > 1 then
		if not self.Window.TabsFrame then
			self.Window.TabsFrame = {}
			self.Window.TabsFrame.Part = Instance.new('Frame')
			self.Window.TabsFrame.Part.Name = "Tabs"
			self.Window.TabsFrame.Part.Parent = self.Window.Part
			self.Window.TabsFrame.Part.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
			self.Window.TabsFrame.Part.BackgroundTransparency = 1.000
			self.Window.TabsFrame.Part.BorderColor3 = Color3.fromRGB(0, 0, 0)
			self.Window.TabsFrame.Part.BorderSizePixel = 0
			self.Window.TabsFrame.Part.Position = UDim2.new(0.015, 0, 0.12, 4)
			self.Window.TabsFrame.Part.Size = UDim2.new(0.97, 0, 0.1, -8)

			local UIListLayout = Instance.new('UIListLayout')
			UIListLayout.Padding = UDim.new(0.015, 0)
			UIListLayout.FillDirection = Enum.FillDirection.Horizontal
			UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
			UIListLayout.Parent = self.Window.TabsFrame.Part

			local UIPadding = Instance.new("UIPadding")
			UIPadding.PaddingTop = UDim.new(0.15, 0)
			UIPadding.Parent = self.Window.TabsFrame.Part
		end
		
		for i, v in ipairs(self.Window.Tabs.Part:GetChildren()) do
			v.Size = UDim2.new(1, 0, 0.78, 0)
			v.Position = UDim2.new(0, 0, 0.22, 0)
		end
		
		task.spawn(function()
			update_tabs_buttons(self.Window)
			wait(0.5)
		end)
	end
	
	return obj
end

function GuiLibrary.TabClass:CreateToggle(prop)
	local obj = {}
	setmetatable(obj, GuiLibrary.ToggleClass)
	
	obj.OnValueChanged = Signal.new()
	obj.OnDisabledChanged = Signal.new()
	
	local idx
	for i, _ in pairs(self) do
		idx = i
	end

	local index = #self[idx].Frame.Part:GetChildren() - 2
	Element_Template(self, idx, obj, index, prop)
	obj.Class = 'Toggle'
	obj.Part.Label.Size = UDim2.fromScale(0.68, 1)
	
	obj.Part:SetAttribute("disabled", prop.IsDisabled)
	obj.Part:SetAttribute("state", prop.IsOn)

	local Toggle = Instance.new("Frame")
	local UICorner = Instance.new("UICorner")
	local Circle = Instance.new("Frame")
	local UICorner_2 = Instance.new("UICorner")
	local UIAspectRatioConstraint = Instance.new("UIAspectRatioConstraint")
	local ToggleButton = Instance.new("TextButton")
	local UIStroke = Instance.new('UIStroke')

	Toggle.Name = "Toggle"
	Toggle.Parent = obj.Part
	Toggle.BackgroundColor3 = Color3.fromRGB(170, 0, 255)
	Toggle.BorderColor3 = Color3.fromRGB(0, 0, 0)
	Toggle.BorderSizePixel = 0
	Toggle.Position = UDim2.new(0.75, 0, 0.25, 0)
	Toggle.Size = UDim2.new(0.200000003, 0, 0.5, 0)
	
	UIStroke.BorderStrokePosition = Enum.BorderStrokePosition.Inner
	UIStroke.Color = Color3.fromRGB(170, 0, 255)
	UIStroke.Parent = Toggle

	UICorner.CornerRadius = UDim.new(1, 0)
	UICorner.Parent = Toggle

	Circle.Name = "Circle"
	Circle.Parent = Toggle
	Circle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	Circle.BorderColor3 = Color3.fromRGB(0, 0, 0)
	Circle.BorderSizePixel = 0
	Circle.Position = UDim2.new(0.629999995, 0, 0.075000003, 0)
	Circle.Size = UDim2.new(0.850000024, 0, 0.850000024, 0)

	UICorner_2.CornerRadius = UDim.new(1, 0)
	UICorner_2.Parent = Circle

	UIAspectRatioConstraint.Parent = Circle

	ToggleButton.Name = "ToggleButton"
	ToggleButton.Parent = Toggle
	ToggleButton.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	ToggleButton.BackgroundTransparency = 1.000
	ToggleButton.BorderColor3 = Color3.fromRGB(0, 0, 0)
	ToggleButton.BorderSizePixel = 0
	ToggleButton.LayoutOrder = 1
	ToggleButton.Size = UDim2.new(1, 0, 1, 0)
	ToggleButton.Font = Enum.Font.SourceSans
	ToggleButton.Text = ""
	ToggleButton.TextColor3 = Color3.fromRGB(0, 0, 0)
	ToggleButton.TextSize = 14.000

	local function ETZS_fake_script()
		local script = Instance.new('LocalScript', ToggleButton)

		local Tween = game:GetService("TweenService")

		local state = script.Parent.Parent.Parent:GetAttribute("state")
		local button = script.Parent

		local tweeninfo = TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.Out, 0, false, 0)
		local colortweeninfo = TweenInfo.new(0.25, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, 0, false, 0)
		
		local function funcstate()
			if script.Parent.Parent.Parent:GetAttribute("state") then
				Tween:Create(button.Parent, tweeninfo, {BackgroundTransparency = 0}):Play()
				Tween:Create(button.Parent.Circle, tweeninfo, {Position = UDim2.new(0.63, 0, 0.075, 0)}):Play()
				Tween:Create(button.Parent.Circle, tweeninfo, {Size = UDim2.new(0.85, 0, 0.85, 0)}):Play()
			else
				Tween:Create(button.Parent, tweeninfo, {BackgroundTransparency = 1}):Play()
				Tween:Create(button.Parent.Circle, tweeninfo, {Position = UDim2.new(0.055, 0, 0.112, 0)}):Play()
				Tween:Create(button.Parent.Circle, tweeninfo, {Size = UDim2.new(0.75, 0, 0.75, 0)}):Play()
			end
		end
		
		local function funcdisabled()
			if script.Parent.Parent.Parent:GetAttribute("disabled") then
				if script.Parent.Parent.Parent:GetAttribute("state") then
					Tween:Create(button.Parent, tweeninfo, {BackgroundTransparency = 0}):Play()
					Tween:Create(button.Parent, colortweeninfo, {BackgroundColor3 = Color3.fromRGB(130, 130, 130)}):Play()
					Tween:Create(button.Parent.Circle, tweeninfo, {Position = UDim2.new(0.63, 0, 0.075, 0)}):Play()
					Tween:Create(button.Parent.Circle, tweeninfo, {Size = UDim2.new(0.85, 0, 0.85, 0)}):Play()
					Tween:Create(button.Parent.UIStroke, colortweeninfo, {Color = Color3.fromRGB(113, 113, 113)}):Play()
					Tween:Create(button.Parent.Parent.UIStroke, colortweeninfo, {Color = Color3.fromRGB(113, 113, 113)}):Play()
				else
					Tween:Create(button.Parent, tweeninfo, {BackgroundTransparency = 1}):Play()
					Tween:Create(button.Parent.Circle, tweeninfo, {Position = UDim2.new(0.055, 0, 0.112, 0)}):Play()
					Tween:Create(button.Parent.Circle, tweeninfo, {Size = UDim2.new(0.75, 0, 0.75, 0)}):Play()
					Tween:Create(button.Parent.Circle, colortweeninfo, {BackgroundColor3 = Color3.fromRGB(225, 225, 225)}):Play()
					Tween:Create(button.Parent.UIStroke, colortweeninfo, {Color = Color3.fromRGB(130, 130, 130)}):Play()
					Tween:Create(button.Parent.Parent.UIStroke, colortweeninfo, {Color = Color3.fromRGB(130, 130, 130)}):Play()
				end
			else
				if script.Parent.Parent.Parent:GetAttribute("state") then
					Tween:Create(button.Parent, tweeninfo, {BackgroundTransparency = 0}):Play()
					Tween:Create(button.Parent.Circle, tweeninfo, {Position = UDim2.new(0.63, 0, 0.075, 0)}):Play()
					Tween:Create(button.Parent.Circle, tweeninfo, {Size = UDim2.new(0.85, 0, 0.85, 0)}):Play()
					Tween:Create(button.Parent, colortweeninfo, {BackgroundColor3 = Color3.fromRGB(170, 0, 255)}):Play()
					Tween:Create(button.Parent.UIStroke, colortweeninfo, {Color = Color3.fromRGB(170, 0, 255)}):Play()
					Tween:Create(button.Parent.Parent.UIStroke, colortweeninfo, {Color = Color3.fromRGB(170, 0, 255)}):Play()
				else
					Tween:Create(button.Parent, tweeninfo, {BackgroundTransparency = 1}):Play()
					Tween:Create(button.Parent.Circle, tweeninfo, {Position = UDim2.new(0.055, 0, 0.112, 0)}):Play()
					Tween:Create(button.Parent.Circle, tweeninfo, {Size = UDim2.new(0.75, 0, 0.75, 0)}):Play()
					Tween:Create(button.Parent, colortweeninfo, {BackgroundColor3 = Color3.fromRGB(170, 0, 255)}):Play()
					Tween:Create(button.Parent.UIStroke, colortweeninfo, {Color = Color3.fromRGB(170, 0, 255)}):Play()
					Tween:Create(button.Parent.Parent.UIStroke, colortweeninfo, {Color = Color3.fromRGB(170, 0, 255)}):Play()
				end
			end
		end

		button.MouseButton1Click:Connect(function()
			if not script.Parent.Parent.Parent:GetAttribute("disabled") then
				state = not script.Parent.Parent.Parent:GetAttribute("state")
				script.Parent.Parent.Parent:SetAttribute("state", state)
			end
		end)

		script.Parent.Parent.Parent:GetAttributeChangedSignal("state"):Connect(function()
			funcstate()
		end)

		script.Parent.Parent.Parent:GetAttributeChangedSignal("disabled"):Connect(function()
			funcdisabled()
		end)
		
		funcstate()
		funcdisabled()
	end
	coroutine.wrap(ETZS_fake_script)()
	
	obj.Part:GetAttributeChangedSignal("state"):Connect(function()
		obj.OnValueChanged:Fire(obj.Part:GetAttribute("state"))
	end)

	obj.Part:GetAttributeChangedSignal("disabled"):Connect(function()
		obj.OnDisabledChanged:Fire(obj.Part:GetAttribute("disabled"))
	end)
	
	return obj
end

function GuiLibrary.TabClass:CreateList(prop)
	local obj = {}
	
	obj.OnValueChanged = Signal.new()
	obj.OnDisabledChanged = Signal.new()
	
	setmetatable(obj, GuiLibrary.ListClass)
	
	local idx
	for i, _ in pairs(self) do
		idx = i
	end

	local index = #self[idx].Frame.Part:GetChildren() - 2
	
	Element_Template(self, idx, obj, index, prop)
	obj.Class = 'List'
	obj.Part.ZIndex = 2	
	obj.Part.Label.Size = UDim2.fromScale(0.48, 1)
	
	obj.Part:SetAttribute('state', false)
	obj.Part:SetAttribute('disabled', prop.IsDisabled)
	obj.Part:SetAttribute('value', '')
	obj.Part.Size = UDim2.fromScale(0.97, 0.5)
	
	obj.ListButton = {}
	obj.ListButton.Part = Instance.new('Frame')
	obj.ListButton.Part.Parent = obj.Part
	obj.ListButton.Part.BackgroundTransparency = 1
	obj.ListButton.Part.Size = UDim2.fromScale(0.4, 0.85)
	obj.ListButton.Part.Position = UDim2.fromScale(0.55, 0.075)
	obj.ListButton.Part.ZIndex = 2
	obj.ListButton.Part.AutoLocalize = false
	obj.ListButton.Part.Name = 'ListButton'
	
	local ListButton = obj.ListButton.Part
	local UICorner = Instance.new("UICorner")
	local Label = Instance.new("TextLabel")
	local Arrow = Instance.new("TextLabel")
	local TextButton = Instance.new("TextButton")
	local UIAspectRatioConstraint = Instance.new("UIAspectRatioConstraint")
	local UIStroke = Instance.new('UIStroke')
	
	UIStroke.Color = Color3.fromRGB(170, 0, 225)
	UIStroke.Parent = ListButton

	UICorner.Parent = ListButton

	Label.Name = "Label"
	Label.Parent = ListButton
	Label.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	Label.BackgroundTransparency = 1.000
	Label.BorderColor3 = Color3.fromRGB(0, 0, 0)
	Label.BorderSizePixel = 0
	Label.Position = UDim2.new(0.0500000007, 0, 0, 0)
	Label.Size = UDim2.new(0.800000012, 0, 1, 0)
	Label.Font = Enum.Font.FredokaOne
	Label.Text = "None"
	Label.TextColor3 = Color3.fromRGB(255, 255, 255)
	Label.TextSize = 14.000
	Label.TextXAlignment = Enum.TextXAlignment.Left
	Label.ClipsDescendants = true

	Arrow.Name = "Arrow"
	Arrow.Parent = ListButton
	Arrow.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	Arrow.BackgroundTransparency = 1.000
	Arrow.BorderColor3 = Color3.fromRGB(0, 0, 0)
	Arrow.BorderSizePixel = 0
	Arrow.Position = UDim2.new(0.800000012, 0, 0, 0)
	Arrow.Rotation = 90.000
	Arrow.Size = UDim2.new(0.200000003, 0, 1, 0)
	Arrow.Font = Enum.Font.FredokaOne
	Arrow.Text = ">"
	Arrow.TextColor3 = Color3.fromRGB(255, 255, 255)
	Arrow.TextSize = 14.000

	TextButton.Parent = ListButton
	TextButton.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	TextButton.BackgroundTransparency = 1.000
	TextButton.BorderColor3 = Color3.fromRGB(0, 0, 0)
	TextButton.BorderSizePixel = 0
	TextButton.Size = UDim2.new(1, 0, 1, 0)
	TextButton.Font = Enum.Font.SourceSans
	TextButton.Text = ""
	TextButton.TextColor3 = Color3.fromRGB(0, 0, 0)
	TextButton.TextSize = 14.000
	TextButton.TextTransparency = 1.000

	UIAspectRatioConstraint.Parent = ListButton
	UIAspectRatioConstraint.AspectRatio = 3.140
	UIAspectRatioConstraint.DominantAxis = Enum.DominantAxis.Height
	
	local Localscript = Instance.new('LocalScript')
	Localscript.Parent = TextButton

	local function ZMXAQ_fake_script()
		local script = Localscript

		local Tween = game:GetService("TweenService")

		local state = script.Parent.Parent.Parent:GetAttribute("state")
		local button = script.Parent

		local tweeninfo1 = TweenInfo.new(0.5, Enum.EasingStyle.Quint, Enum.EasingDirection.Out, 0, false, 0)
		local colortweeninfo = TweenInfo.new(0.2, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut, 0, false, 0)

		local TweenFix = true
		
		local function funcstate()
			if not script.Parent.Parent.Parent:GetAttribute("disabled") then
				script.Parent.Parent.Parent.List.Scroll.ScrollingFrame.CanvasPosition = Vector2.new(0, 0)
				if script.Parent.Parent.Parent:GetAttribute("state") then
					TweenFix = false
					for i, v in ipairs(button.Parent.Parent.List.Scroll.ScrollingFrame:GetChildren()) do
						if v:IsA("Frame") then
							v.Label.Visible = true
						end
					end

					Tween:Create(button.Parent.Arrow, tweeninfo1, {Rotation = -90}):Play()
					Tween:Create(button.Parent.Parent.UIAspectRatioConstraint, tweeninfo1, {AspectRatio = 2.7}):Play()
					Tween:Create(button.Parent.Parent.Label, tweeninfo1, {Position = UDim2.new(0.05, 0, 0.3, 0)}):Play()
					Tween:Create(button.Parent.Parent.List, tweeninfo1, {Position = UDim2.new(0.55, 0, 0.675, 0)}):Play()
					local move = Tween:Create(button.Parent.Parent.ListButton, tweeninfo1, {Position = UDim2.new(0.55, 0, 0.6, 0)})
					move:Play()
					move.Completed:Wait()

					button.Parent.Parent.List.UIStroke.Enabled = true
					Tween:Create(button.Parent.Parent.List, tweeninfo1, {Position = UDim2.new(0.25, 0, 0.0675, 0)}):Play()
					move = Tween:Create(button.Parent.Parent.List, tweeninfo1, {Size = UDim2.new(0.7, 0, 0.5, 0)})
					move:Play()
					button.Parent.Parent.List.Scroll.Position = UDim2.new(0, 0, 1, 0)
					move.Completed:Wait()

					local mv = Tween:Create(button.Parent.Parent.List.Scroll, tweeninfo1, {Size = UDim2.new(1, 0, 0.98, 0)})
					mv:Play()
					Tween:Create(button.Parent.Parent.List.Scroll, tweeninfo1, {Position = UDim2.new(0, 0, 0.01, 0)}):Play()
					mv.Completed:Wait()
					TweenFix = true

					script.Parent.Parent.Parent.List.Scroll.ScrollingFrame.CanvasSize = UDim2.fromOffset(0, 0)
					
					local canvafix
					for i, v in ipairs(script.Parent.Parent.Parent.List.Scroll.ScrollingFrame:GetChildren()) do
						if v:IsA("Frame") then
							canvafix = v.UIAspectRatioConstraint:Clone()
							v.UIAspectRatioConstraint:Destroy()
							
							script.Parent.Parent.Parent.List.Scroll.ScrollingFrame.CanvasSize = UDim2.fromOffset(0, script.Parent.Parent.Parent.List.Scroll.ScrollingFrame.AbsoluteCanvasSize.Y + 2)
							
							canvafix.Parent = v
						end
					end
					
					script.Parent.Parent.Parent.List.Scroll.ScrollingFrame.ScrollBarImageTransparency = 0
					script.Parent.Parent.Parent.Parent:SetAttribute('resize', true)
				else
					TweenFix = false
					for i, v in ipairs(button.Parent.Parent.List.Scroll.ScrollingFrame:GetChildren()) do
						if v:IsA("Frame") then
							v.Label.Visible = false
						end
					end

					Tween:Create(button.Parent.Parent.List, tweeninfo1, {Position = UDim2.new(0.55, 0, 0.6, 0)}):Play()
					button.Parent.Parent.List.Scroll.Position = UDim2.new(0, 0, 0, 0)

					local move = Tween:Create(button.Parent.Parent.List, tweeninfo1, {Size = UDim2.new(0.4, 0, 0, 0)})
					move:Play()
					move.Completed:Wait()
					button.Parent.Parent.List.UIStroke.Enabled = false
					wait(0.05)

					button.Parent.Parent.List.Scroll.Size = UDim2.new(1, 0, 0, 0)

					Tween:Create(button.Parent.Arrow, tweeninfo1, {Rotation = 90}):Play()
					Tween:Create(button.Parent.Parent.UIAspectRatioConstraint, tweeninfo1, {AspectRatio = 6.65}):Play()
					Tween:Create(button.Parent.Parent.Label, tweeninfo1, {Position = UDim2.new(0.05, 0, 0, 0)}):Play()
					Tween:Create(button.Parent.Parent.ListButton, tweeninfo1, {Position = UDim2.new(0.55, 0, 0.075, 0)}):Play()
					TweenFix = true
					
					script.Parent.Parent.Parent.List.Scroll.ScrollingFrame.ScrollBarImageTransparency = 1
					script.Parent.Parent.Parent.Parent:SetAttribute('resize', true)
				end
			end
		end
		
		local function funcdisabled()
			obj.OnDisabledChanged:Fire(obj.Part:GetAttribute("disabled"))
			if script.Parent.Parent.Parent:GetAttribute("disabled") then
				if script.Parent.Parent.Parent:GetAttribute("state") then
					script.Parent.Parent.Parent:SetAttribute("state", not script.Parent.Parent.Parent:GetAttribute("state"))
					for i, v in ipairs(button.Parent.Parent.List.Scroll.ScrollingFrame:GetChildren()) do
						if v:IsA("Frame") then
							v.Label.Visible = false
						end
					end

					Tween:Create(button.Parent.Parent.List, tweeninfo1, {Position = UDim2.new(0.55, 0, 0.7, 0)}):Play()
					button.Parent.Parent.List.Scroll.Position = UDim2.new(0, 0, 0, 0)

					local move = Tween:Create(button.Parent.Parent.List, tweeninfo1, {Size = UDim2.new(0.4, 0, 0, 0)})
					move:Play()
					move.Completed:Wait()
					button.Parent.Parent.List.UIStroke.Enabled = false
					wait(0.05)

					button.Parent.Parent.List.Scroll.Size = UDim2.new(1, 0, 0, 0)

					Tween:Create(button.Parent.Arrow, tweeninfo1, {Rotation = 90}):Play()
					Tween:Create(button.Parent.Parent, tweeninfo1, {Size = UDim2.new(0.97, 0, 0.15, 0)}):Play()
					Tween:Create(button.Parent.Parent.Label, tweeninfo1, {Position = UDim2.new(0.05, 0, 0, 0)}):Play()
					Tween:Create(button.Parent.Parent.ListButton, tweeninfo1, {Position = UDim2.new(0.55, 0, 0.075, 0)}):Play()
				end

				Tween:Create(button.Parent.Arrow, tweeninfo1, {TextTransparency = 1}):Play()
				Tween:Create(button.Parent.Arrow, colortweeninfo, {BackgroundColor3 = Color3.fromRGB(130, 130, 130)}):Play()
				Tween:Create(button.Parent.UIStroke, colortweeninfo, {Color = Color3.fromRGB(113, 113, 113)}):Play()
				Tween:Create(button.Parent.Parent.UIStroke, colortweeninfo, {Color = Color3.fromRGB(113, 113, 113)}):Play()
			else
				Tween:Create(button.Parent.Arrow, tweeninfo1, {TextTransparency = 0}):Play()
				Tween:Create(button.Parent.Arrow, colortweeninfo, {BackgroundColor3 = Color3.fromRGB(170, 0, 255)}):Play()
				Tween:Create(button.Parent.UIStroke, colortweeninfo, {Color = Color3.fromRGB(170, 0, 255)}):Play()
				Tween:Create(button.Parent.Parent.UIStroke, colortweeninfo, {Color = Color3.fromRGB(170, 0, 255)}):Play()
			end
		end

		button.MouseButton1Click:Connect(function()
			if not script.Parent.Parent.Parent:GetAttribute("disabled") and TweenFix then
				script.Parent.Parent.Parent:SetAttribute("state", not script.Parent.Parent.Parent:GetAttribute("state"))
			end
		end)

		script.Parent.Parent.Parent:GetAttributeChangedSignal("state"):Connect(funcstate)
		script.Parent.Parent.Parent:GetAttributeChangedSignal("disabled"):Connect(funcdisabled)
		script.Parent.Parent.Parent:GetAttributeChangedSignal("value"):Connect(function()
			obj.OnValueChanged:Fire(obj.Part:GetAttribute("value"))
			if script.Parent.Parent.Parent:GetAttribute("value") ~= '' then
				script.Parent.Parent.Label.Text = script.Parent.Parent.Parent.List.Scroll.ScrollingFrame[script.Parent.Parent.Parent:GetAttribute("value")].Label.Text
			else
				script.Parent.Parent.Label.Text = 'None'
			end
		end)
		
		funcstate()
		funcdisabled()
		
		if script.Parent.Parent.Parent:GetAttribute("value") ~= '' then
			script.Parent.Parent.Label.Text = script.Parent.Parent.Parent.List.Scroll.ScrollingFrame[script.Parent.Parent.Parent:GetAttribute("value")].Label.Text
		else
			script.Parent.Parent.Label.Text = 'None'
		end
	end
	
	obj.List = {}
	obj.List.Part = Instance.new('Frame')
	obj.List.Part.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
	obj.List.Part.Position = UDim2.fromScale(0.55, 0)
	obj.List.Part.Size = UDim2.fromScale(0.4, 0)
	obj.List.Part.Name = 'List'
	obj.List.Part.Parent = obj.Part
	
	local List = obj.List.Part
	local UICorner = Instance.new("UICorner")
	local Scroll = Instance.new("Frame")
	local ScrollingFrame = Instance.new("ScrollingFrame")
	local UIListLayout = Instance.new("UIListLayout")
	local UIPadding = Instance.new("UIPadding")
	
	local UIStroke = Instance.new('UIStroke')
	UIStroke.Color = Color3.fromRGB(170, 0, 255)
	UIStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	UIStroke.Parent = List

	UICorner.Parent = List

	Scroll.Name = "Scroll"
	Scroll.Parent = List
	Scroll.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	Scroll.BackgroundTransparency = 1.000
	Scroll.BorderColor3 = Color3.fromRGB(0, 0, 0)
	Scroll.BorderSizePixel = 0
	Scroll.Size = UDim2.new(1, 0, 0, 0)

	ScrollingFrame.Parent = Scroll
	ScrollingFrame.Active = true
	ScrollingFrame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	ScrollingFrame.BackgroundTransparency = 1.000
	ScrollingFrame.BorderColor3 = Color3.fromRGB(0, 0, 0)
	ScrollingFrame.BorderSizePixel = 0
	ScrollingFrame.Size = UDim2.new(1, 0, 1, 0)
	ScrollingFrame.ScrollBarThickness = 3
	ScrollingFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
	ScrollingFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y

	UIListLayout.Parent = ScrollingFrame
	UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
	UIListLayout.Padding = UDim.new(0, 4)

	UIPadding.Parent = ScrollingFrame
	UIPadding.PaddingTop = UDim.new(0, 2)
	obj.Values = {}
	
	local count = 0
	local max = 0
	for _, _ in pairs(prop.Values) do
		max += 1
	end
	for i, v in pairs(prop.Values) do
		count += 1
		obj.Values[i] = {}
		obj.Values[i].Part = Instance.new("Frame")
		local Label = Instance.new("TextLabel")
		local Button = Instance.new("TextButton")
		local UICorner = Instance.new("UICorner")
		local UIStroke = Instance.new("UIStroke")
		local UIAspectRatio = Instance.new("UIAspectRatioConstraint")
		
		UIAspectRatio.AspectRatio = 9.87
		UIAspectRatio.DominantAxis = Enum.DominantAxis.Width
		UIAspectRatio.Parent = obj.Values[i].Part
		
		obj.Values[i].Part.Parent = ScrollingFrame
		obj.Values[i].Part.Name = i
		obj.Values[i].Part.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		obj.Values[i].Part.BackgroundTransparency = 1.000
		obj.Values[i].Part.BorderColor3 = Color3.fromRGB(0, 0, 0)
		obj.Values[i].Part.BorderSizePixel = 0
		obj.Values[i].Part.LayoutOrder = 1
		obj.Values[i].Part.Size = UDim2.new(0.98, 0, 0.4, 0)
		obj.Values[i].Part.LayoutOrder = v.position or max
		
		if #prop.Values ~= 0 then
			obj.Values[i].Part.Name = v
		end
		
		UIStroke.Color = Color3.fromRGB(170, 0, 255)
		UIStroke.Thickness = 0.5
		UIStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
		UIStroke.Parent = obj.Values[i].Part

		Label.Name = "Label"
		Label.Parent = obj.Values[i].Part
		Label.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		Label.BackgroundTransparency = 1.000
		Label.BorderColor3 = Color3.fromRGB(0, 0, 0)
		Label.BorderSizePixel = 0
		Label.Size = UDim2.new(1, 0, 1, 0)
		Label.Font = Enum.Font.FredokaOne
		Label.Text = v.text or v
		Label.TextColor3 = Color3.fromRGB(255, 255, 255)
		Label.TextSize = 14.000
		Label.TextXAlignment = Enum.TextXAlignment.Center

		Button.Name = "Button"
		Button.Parent = obj.Values[i].Part
		Button.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		Button.BackgroundTransparency = 1.000
		Button.BorderColor3 = Color3.fromRGB(0, 0, 0)
		Button.BorderSizePixel = 0
		Button.Size = UDim2.new(1, 0, 1, 0)
		Button.Font = Enum.Font.SourceSans
		Button.Text = ""
		Button.TextColor3 = Color3.fromRGB(0, 0, 0)
		Button.TextSize = 14.000

		UICorner.CornerRadius = UDim.new(1, 0)
		UICorner.Parent = obj.Values[i].Part

		local function MHFHHDV_fake_script()
			local script = Instance.new('LocalScript', Button)

			script.Parent.MouseButton1Click:Connect(function()
				if not script.Parent.Parent.Parent.Parent.Parent.Parent:GetAttribute('disabled') then
					script.Parent.Parent.Parent.Parent.Parent.Parent:SetAttribute('state', false)
					script.Parent.Parent.Parent.Parent.Parent.Parent:SetAttribute('value', script.Parent.Parent.Name)
				end
			end)

		end
		coroutine.wrap(MHFHHDV_fake_script)()
	end
	
	coroutine.wrap(ZMXAQ_fake_script)()
	
	return obj
end

function GuiLibrary.TabClass:CreateButton(prop)
	local obj = {}
	
	obj.OnClick = Signal.new()
	obj.OnDisabledChanged = Signal.new()
	obj.Class = 'Button'

	setmetatable(obj, GuiLibrary.ButtonClass)
	
	local idx
	for i, _ in pairs(self) do
		idx = i
	end

	local index = #self[idx].Frame.Part:GetChildren() - 2
	Element_Template(self, idx, obj, index, prop)
	
	obj.Part.Label.Size = UDim2.fromScale(0.9, 1)
	
	obj.Part:SetAttribute("disabled", prop.IsDisabled)
	
	local btn = Instance.new("TextLabel")
	btn.Name = "btn"
	btn.Parent = obj.Part
	btn.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	btn.BackgroundTransparency = 1.000
	btn.BorderColor3 = Color3.fromRGB(0, 0, 0)
	btn.BorderSizePixel = 0
	btn.Position = UDim2.new(0.699999988, 0, 0.25, 0)
	btn.Size = UDim2.new(0.25, 0, 0.5, 0)
	btn.Font = Enum.Font.FredokaOne
	btn.Text = "click"
	btn.TextColor3 = Color3.fromRGB(170, 0, 255)
	btn.TextSize = 14.000
	
	obj.Button = {}
	obj.Button.Part = Instance.new('TextButton')
	local TextButton = obj.Button.Part
	TextButton.Parent = obj.Part
	TextButton.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	TextButton.BackgroundTransparency = 1.000
	TextButton.BorderColor3 = Color3.fromRGB(0, 0, 0)
	TextButton.BorderSizePixel = 0
	TextButton.ClipsDescendants = true
	TextButton.Size = UDim2.new(1, 0, 1, 0)
	TextButton.Font = Enum.Font.SourceSans
	TextButton.Text = ""
	TextButton.TextColor3 = Color3.fromRGB(0, 0, 0)
	TextButton.TextSize = 14.000
	
	local CanvasGroup = Instance.new('CanvasGroup')
	CanvasGroup.Parent = TextButton
	CanvasGroup.BackgroundTransparency = 1
	CanvasGroup.Size = UDim2.fromScale(1, 1)
	
	local UICorner = Instance.new('UICorner')
	UICorner.Parent = CanvasGroup
	UICorner.CornerRadius = UDim.new(0, 16)
	
	local Effect = Instance.new("Frame")
	local UIAspectRatioConstraint = Instance.new("UIAspectRatioConstraint")
	local UICorner = Instance.new("UICorner")

	Effect.Name = "Effect"
	Effect.Parent = CanvasGroup
	Effect.AnchorPoint = Vector2.new(0.5, 0.5)
	Effect.BackgroundColor3 = Color3.fromRGB(170, 0, 255)
	Effect.BackgroundTransparency = 1.000
	Effect.BorderColor3 = Color3.fromRGB(0, 0, 0)
	Effect.BorderSizePixel = 0
	Effect.Size = UDim2.new(0.400000006, 0, 0.400000006, 0)

	UIAspectRatioConstraint.Parent = Effect

	UICorner.CornerRadius = UDim.new(1, 0)
	UICorner.Parent = Effect
	
	local scriptt = Instance.new('LocalScript')
	scriptt.Parent = TextButton

	local function HGGN_fake_script()
		local script = scriptt

		local Tween = game:GetService("TweenService")

		local ScreenGUI = script.Parent.Parent.Parent.Parent.Parent.Parent
		local Effect = script.Parent.CanvasGroup.Effect 

		local pressed = script.Parent.Parent:GetAttribute("state")
		local animation = false

		local tweeninfo1 = TweenInfo.new(0.2, Enum.EasingStyle.Sine, Enum.EasingDirection.In, 0, true, 0)
		local colortweeninfo = TweenInfo.new(0.25, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, 0, false, 0)

		script.Parent.MouseEnter:Connect(function(x, y)
			if not animation and not script.Parent.Parent:GetAttribute("disabled") then
				Effect.Position = UDim2.new(0, -(Effect.AbsolutePosition.X - Effect.Position.X.Offset - x + Effect.AbsoluteSize.X / 2), 0, -(Effect.AbsolutePosition.Y - Effect.Position.Y.Offset - y - ScreenGUI.AbsolutePosition.Y + Effect.AbsoluteSize.Y / 2))
			end
		end)

		script.Parent.MouseMoved:Connect(function(x, y)
			if not animation and not script.Parent.Parent:GetAttribute("disabled") then
				Effect.Position = UDim2.new(0, -(Effect.AbsolutePosition.X - Effect.Position.X.Offset - x + Effect.AbsoluteSize.X / 2), 0, -(Effect.AbsolutePosition.Y - Effect.Position.Y.Offset - y - ScreenGUI.AbsolutePosition.Y + Effect.AbsoluteSize.Y / 2))
			end
		end)

		script.Parent.MouseLeave:Connect(function()
			if not animation and not script.Parent.Parent:GetAttribute("disabled") then
				Effect.BackgroundTransparency = 1
			end
		end)

		script.Parent.MouseButton1Click:Connect(function()
			wait()
			if not animation and not script.Parent.Parent:GetAttribute("disabled") then
				obj.OnClick:Fire()
				script.Parent.Parent:SetAttribute("state", true)
				animation = true
				local multiplier_radius = 2 - (script.Parent.AbsoluteSize.X / 2 / math.max(math.abs(script.Parent.AbsolutePosition.X - Effect.AbsolutePosition.X + Effect.AbsoluteSize.X / 2), math.abs(math.abs(script.Parent.AbsolutePosition.X - Effect.AbsolutePosition.X + Effect.AbsoluteSize.X / 2) - script.Parent.AbsoluteSize.X)))
				local size = script.Parent.AbsolutePosition.X * (multiplier_radius) / Effect.AbsoluteSize.X * Effect.Size.X.Scale
				Tween:Create(Effect, tweeninfo1, {Transparency = 0}):Play()
				local move = Tween:Create(Effect, tweeninfo1, {Size = UDim2.new(size, 0, size, 0)})
				move:Play()
				move.Completed:Wait()

				Effect.Transparency = 1
				Effect.Size = UDim2.new(0.4, 0, 0.4, 0)

				animation = false
				script.Parent.Parent:SetAttribute("state", false)
			end
		end)

		script.Parent.Parent:GetAttributeChangedSignal("disabled"):Connect(function()
			obj.OnDisabledChanged:Fire(obj.Part:GetAttribute("disabled"))
			if script.Parent.Parent:GetAttribute("disabled") then
				Tween:Create(script.Parent.Parent.UIStroke, colortweeninfo, {Color = Color3.fromRGB(130, 130, 130)}):Play()
				Tween:Create(script.Parent.Parent.btn, colortweeninfo, {TextTransparency = 1}):Play()
			else
				Tween:Create(script.Parent.Parent.UIStroke, colortweeninfo, {Color = Color3.fromRGB(170, 0, 255)}):Play()
				Tween:Create(script.Parent.Parent.btn, colortweeninfo, {TextTransparency = 0}):Play()
			end
		end)
	end
	coroutine.wrap(HGGN_fake_script)()
	
	return obj
end

function GuiLibrary.TabClass:CreateSlider(prop)
	local obj = {}
	setmetatable(obj, GuiLibrary.SliderClass)

	obj.OnValueChanged = Signal.new()
	obj.OnDisabledChanged = Signal.new()

	local idx
	for i, _ in pairs(self) do
		idx = i
	end

	local index = #self[idx].Frame.Part:GetChildren() - 2
	Element_Template(self, idx, obj, index, prop)
	obj.Class = 'Slider'
	obj.Values = {}
	
	obj.Values.Min = prop.Values.MinValue or 0
	obj.Values.Max = prop.Values.MaxValue or 0
	obj.Values.SliderStep = prop.Values.SliderStep or 0.01
	
	obj.Part.Size = UDim2.fromScale(obj.Part.Size.X.Scale, 0.2)
	obj.Part.UIAspectRatioConstraint.AspectRatio = 5
	obj.Part.Label.Position = UDim2.fromScale(0.05, 0.1)
	obj.Part.Label.Size = UDim2.fromScale(0.6, 0.65)
	obj.Part:SetAttribute('value', 0)
	
	local UIPadding = Instance.new('UIPadding')
	UIPadding.Parent = obj.Part
	UIPadding.PaddingBottom = UDim.new(0, 8)
	
	local NumberValue1 = Instance.new('NumberValue')
	NumberValue1.Parent = obj.Part
	NumberValue1.Name = 'Valuee'
	
	local BoolValue = Instance.new('BoolValue')
	BoolValue.Parent = obj.Part
	BoolValue.Name = 'Update'
	
	obj.ValueChanger = {}
	obj.ValueChanger.Min = prop.Values.MinValue or 0
	obj.ValueChanger.Part = Instance.new('NumberValue')
	obj.ValueChanger.Part.Parent = obj.Part
	obj.ValueChanger.Part.Name = 'Custom'
	
	local TextValue = Instance.new('TextLabel')
	TextValue.BackgroundTransparency = 1
	TextValue.Position = UDim2.fromScale(0.65, 0.125)
	TextValue.Size = UDim2.fromScale(0.3, 0.55)
	TextValue.Font = Enum.Font.FredokaOne
	TextValue.Text = 0
	TextValue.TextSize = 16
	TextValue.TextColor3 = Color3.fromRGB(255, 255, 255)
	TextValue.Name = 'Value'
	TextValue.Parent = obj.Part
	
	local Slide = Instance.new("Frame")
	local UICorner = Instance.new("UICorner")
	local Circle = Instance.new("Frame")
	local UIAspectRatioConstraint = Instance.new("UIAspectRatioConstraint")
	local UICorner_2 = Instance.new("UICorner")
	local Button = Instance.new("TextButton")
	local Stroke = Instance.new("UIStroke")
	local Canvas = Instance.new('CanvasGroup')
	
	Stroke.Color = Color3.fromRGB(170, 0, 255)
	Stroke.Thickness = 2
	Stroke.Parent = Slide

	Slide.Name = "Slide"
	Slide.Parent = obj.Part
	Slide.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	Slide.BackgroundTransparency = 1.000
	Slide.BorderColor3 = Color3.fromRGB(0, 0, 0)
	Slide.BorderSizePixel = 0
	Slide.ClipsDescendants = true
	Slide.Position = UDim2.new(0.0500000007, 0, 0.800000012, 0)
	Slide.Size = UDim2.new(0.9, 0, 0.25, 0)

	UICorner.CornerRadius = UDim.new(1, 0)
	UICorner.Parent = Slide

	Circle.Name = "Circle"
	Circle.Parent = Slide
	Circle.AnchorPoint = Vector2.new(0.5, 0.5)
	Circle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	Circle.BorderColor3 = Color3.fromRGB(0, 0, 0)
	Circle.BorderSizePixel = 0
	Circle.Position = UDim2.new(0.0199999996, 0, 0.5, 0)
	Circle.Size = UDim2.new(0.850000024, 0, 0.850000024, 0)
	Circle.ZIndex = 2

	UIAspectRatioConstraint.Parent = Circle

	UICorner_2.CornerRadius = UDim.new(1, 0)
	UICorner_2.Parent = Circle

	Button.Name = "Button"
	Button.Parent = Slide
	Button.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	Button.BackgroundTransparency = 1.000
	Button.BorderColor3 = Color3.fromRGB(0, 0, 0)
	Button.BorderSizePixel = 0
	Button.Size = UDim2.new(1, 0, 1, 0)
	Button.Font = Enum.Font.SourceSans
	Button.Text = ""
	Button.TextColor3 = Color3.fromRGB(0, 0, 0)
	Button.TextSize = 14.000
	
	Canvas.Transparency = 1
	Canvas.Position = UDim2.fromScale(-0.95)
	Canvas.Size = UDim2.fromScale(1, 1)
	Canvas.Parent = Slide
	
	local Pattern = Instance.new("ImageLabel")
	local UICorner = Instance.new("UICorner")
	
	Pattern.Name = "Pattern"
	Pattern.Parent = Canvas
	Pattern.BackgroundColor3 = Color3.fromRGB(170, 0, 255)
	Pattern.BorderColor3 = Color3.fromRGB(0, 0, 0)
	Pattern.BorderSizePixel = 0
	Pattern.Position = UDim2.new(-0.0299999993, 0, -11, 0)
	Pattern.Rotation = -40.000
	Pattern.Size = UDim2.new(1, 0, 25, 0)
	Pattern.Image = "rbxassetid://121087680439417"
	Pattern.ImageColor3 = Color3.fromRGB(98, 0, 147)
	Pattern.ImageTransparency = 0.400
	Pattern.ScaleType = Enum.ScaleType.Tile
	Pattern.TileSize = UDim2.new(0, 10, 0, 10)

	UICorner.CornerRadius = UDim.new(1, 0)
	UICorner.Parent = Canvas
	
	local LocalScript = Instance.new('LocalScript')
	LocalScript.Parent = obj.Part
	
	coroutine.wrap(function()
		local UserInputService = game:GetService("UserInputService")
		local Tween = game:GetService("TweenService")
		
		local script = LocalScript

		local range = NumberRange.new(prop.Values.MinValue, prop.Values.MaxValue)
		local step = prop.Values.SliderStep or 0.01

		local multiplier = (range.Max - range.Min) / (0.96 - 0.03)

		local Slider = script.Parent.Slide
		local draging = false
		local Twen = true

		local tweeninfo = TweenInfo.new(0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.Out, 0, false, 0)
		local colortweeninfo = TweenInfo.new(0.25, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, 0, false, 0)

		Slider.Button.MouseButton1Down:Connect(function()
			if not script.Parent:GetAttribute('disabled') then
				draging = true
				Twen = true
				while draging do
					local mouse = UserInputService:GetMouseLocation()

					local x_pos = math.clamp((mouse.X - Slider.AbsolutePosition.X) / Slider.AbsoluteSize.X, 0.03, 0.96)

					if Twen and math.abs(x_pos - Slider.Circle.Position.X.Scale) > 0.1 then
						Tween:Create(Slider.Circle, tweeninfo, {Position = UDim2.fromScale(x_pos, Slider.Circle.Position.Y.Scale)}):Play()
						Tween:Create(script.Parent.Valuee, tweeninfo, {Value = (x_pos - 0.03) * multiplier + range.Min}):Play()
						local mv = Tween:Create(Slider.CanvasGroup, tweeninfo, {Position = UDim2.fromScale(-(1 - x_pos - 0.04), Slider.CanvasGroup.Position.Y.Scale)})
						mv:Play()
						mv.Completed:Wait()
					else
						Slider.Circle.Position = UDim2.fromScale(x_pos, Slider.Circle.Position.Y.Scale)
						Slider.CanvasGroup.Position = UDim2.fromScale(-(1 - x_pos - 0.04), Slider.CanvasGroup.Position.Y.Scale)
						script.Parent.Valuee.Value = (x_pos - 0.03) * multiplier + range.Min
					end

					if script.Parent:GetAttribute('disabled') then draging = false end

					Twen = false
					task.wait()
				end
			end
		end)

		UserInputService.InputEnded:Connect(function()
			draging = false
		end)

		script.Parent.Valuee:GetPropertyChangedSignal("Value"):Connect(function()
			task.wait()
			local value = math.floor((script.Parent.Valuee.Value / step) + 0.5) * step
			value = tonumber(string.format("%.3f", value))
			obj.OnValueChanged:Fire(value)
			script.Parent:SetAttribute("value", value)
			script.Parent.Value.Text = string.format("%.2f", value)
		end)

		script.Parent:GetAttributeChangedSignal("disabled"):Connect(function()
			obj.OnDisabledChanged:Fire(obj.Part:GetAttribute("disabled"))
			if script.Parent:GetAttribute('disabled') then
				Tween:Create(script.Parent.UIStroke, colortweeninfo, {Color = Color3.fromRGB(130, 130, 130)}):Play()
				Tween:Create(Slider.UIStroke, colortweeninfo, {Color = Color3.fromRGB(130, 130, 130)}):Play()
				Tween:Create(Slider.CanvasGroup.Pattern, colortweeninfo, {ImageColor3 = Color3.fromRGB(113, 113, 113)}):Play()
				Tween:Create(Slider.CanvasGroup.Pattern, colortweeninfo, {BackgroundColor3 = Color3.fromRGB(130, 130, 130)}):Play()
			else
				Tween:Create(script.Parent.UIStroke, colortweeninfo, {Color = Color3.fromRGB(170, 0, 255)}):Play()
				Tween:Create(Slider.UIStroke, colortweeninfo, {Color = Color3.fromRGB(170, 0, 255)}):Play()
				Tween:Create(Slider.CanvasGroup.Pattern, colortweeninfo, {ImageColor3 = Color3.fromRGB(98, 0, 147)}):Play()
				Tween:Create(Slider.CanvasGroup.Pattern, colortweeninfo, {BackgroundColor3 = Color3.fromRGB(170, 0, 255)}):Play()
			end
		end)

		script.Parent.Custom:GetPropertyChangedSignal("Value"):Connect(function()
			local typee = 'custom'

			local mouse = UserInputService:GetMouseLocation()

			local x_pos = math.clamp((script.Parent.Custom.Value / range.Max), 0.03, 0.96)

			if Twen and math.abs(x_pos - Slider.Circle.Position.X.Scale) > 0.1 then
				Tween:Create(Slider.Circle, tweeninfo, {Position = UDim2.fromScale(x_pos, Slider.Circle.Position.Y.Scale)}):Play()
				Tween:Create(script.Parent.Valuee, tweeninfo, {Value = math.clamp(script.Parent.Custom.Value, range.Min, range.Max)}):Play()
				local mv = Tween:Create(Slider.CanvasGroup, tweeninfo, {Position = UDim2.fromScale(-(1 - x_pos - 0.04), Slider.CanvasGroup.Position.Y.Scale)})
				mv:Play()
				mv.Completed:Wait()
			else
				Slider.Circle.Position = UDim2.fromScale(x_pos, Slider.Circle.Position.Y.Scale)
				Slider.CanvasGroup.Position = UDim2.fromScale(-(1 - x_pos - 0.04), Slider.CanvasGroup.Position.Y.Scale)
				script.Parent.Valuee.Value = math.clamp(script.Parent.Custom.Value, range.Min, range.Max)
			end

			if script.Parent:GetAttribute('disabled') then draging = false end

			Twen = true
		end)
		
		script.Parent.Update:GetPropertyChangedSignal("Value"):Connect(function()
			if script.Parent.Update.Value then
				step = obj.Values.SliderStep or step
				range = NumberRange.new(obj.Values.Min or range.Min, obj.Values.Max or range.Max)
				script.Parent.Custom.Value = obj.Values.CurrentValue or obj.Values.Min or range.Min
				multiplier = (range.Max - range.Min) / (0.96 - 0.03)
				script.Parent.Update.Value = false
			end
		end)
	end)()
	
	obj.ValueChanger.Part.Value = prop.Values.CurrentValue or 0
	obj.Part:SetAttribute("disabled", prop.IsDisabled)
	
	return obj
end

function GuiLibrary.TabClass:CreateMultiLabel(prop)
	local obj = {}
	
	obj.Class = 'Element'

	setmetatable(obj, GuiLibrary.ElementClass)

	local idx
	for i, _ in pairs(self) do
		idx = i
	end

	local index = #self[idx].Frame.Part:GetChildren() - 2
	Element_Template(self, idx, obj, index, prop)
	
	obj.Part.UIAspectRatioConstraint:Destroy()
	obj.Part.Label:Destroy()
	
	local Event = Instance.new('BoolValue')
	Event.Name = 'Event'
	Event.Parent = obj.Part
	
	obj.Elements = {}
	
	obj.Elements.Part = Instance.new('Frame')
	obj.Elements.Part.Name = "Elements"
	obj.Elements.Part.Parent = game.StarterGui.ScreenGui.Main.TabsFolder["2"].Frame["1"]
	obj.Elements.Part.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	obj.Elements.Part.BackgroundTransparency = 1.000
	obj.Elements.Part.BorderColor3 = Color3.fromRGB(0, 0, 0)
	obj.Elements.Part.BorderSizePixel = 0
	obj.Elements.Part.Size = UDim2.new(1, 0, 1, 0)
	obj.Elements.Part.Parent = obj.Part
	
	local UIListLayout = Instance.new('UIListLayout')
	
	UIListLayout.Parent = obj.Elements.Part
	UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
	UIListLayout.Padding = UDim.new(0, 8)
	
	local LocalScript = Instance.new('LocalScript')
	LocalScript.Parent = obj.Part
	
	local function DZAZT_fake_script()
		local script = LocalScript

		local function resize()
			local size = 0
			for i, v in ipairs(script.Parent.Elements:GetChildren()) do
				if not v:IsA("UIListLayout") then
					size += v.AbsoluteSize.Y
				end
			end

			size += 8 * (#script.Parent.Elements:GetChildren() - 1)
			
			script.Parent.Size = UDim2.fromScale(0.98, size / script.Parent.Parent.AbsoluteCanvasSize.Y)
		end

		script.Parent.Elements.ChildAdded:Connect(function()
			resize()
		end)

		script.Parent.Elements.ChildRemoved:Connect(function()
			resize()
		end)

		script.Parent.Event:GetPropertyChangedSignal("Value"):Connect(function()
			if script.Parent.Event.Value then
				resize()
				script.Parent.Event.Value = false
			end
		end)

		resize()
	end
	coroutine.wrap(DZAZT_fake_script)()
	
	return obj
end

function GuiLibrary.TabClass:CreateInput(prop)
	local obj = {}

	obj.Class = 'Input'

	setmetatable(obj, GuiLibrary.InputClass)

	local idx
	for i, _ in pairs(self) do
		idx = i
	end
	
	obj.OnValueChanged = Signal.new()
	obj.OnDisabledChanged = Signal.new()

	local index = #self[idx].Frame.Part:GetChildren() - 2
	Element_Template(self, idx, obj, index, prop)
	
	local LocalScript = Instance.new('LocalScript')
	LocalScript.Parent = obj.Part
	
	obj.TextInput = {}
	obj.TextInput.Part = Instance.new('TextBox')
	obj.TextInput.Text = prop.TextInBox or ""
	
	local Input = Instance.new("Frame")
	local UICorner = Instance.new("UICorner")
	local UIAspectRatioConstraint = Instance.new("UIAspectRatioConstraint")
	local UIStoke = Instance.new("UIStroke")

	Input.Name = "Input"
	Input.Parent = obj.Part
	Input.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	Input.BackgroundTransparency = 1.000
	Input.BorderColor3 = Color3.fromRGB(0, 0, 0)
	Input.BorderSizePixel = 0
	Input.Position = UDim2.new(0.45, 0, 0.075, 0)
	Input.Size = UDim2.new(0.5, 0, 0.85, 0)
	Input.ZIndex = 2

	UICorner.Parent = Input

	UIAspectRatioConstraint.Parent = Input
	UIAspectRatioConstraint.AspectRatio = 4.000
	UIAspectRatioConstraint.DominantAxis = Enum.DominantAxis.Height
	
	UIStoke.Parent = Input
	UIStoke.Color = Color3.fromRGB(170, 0, 255)
	UIStoke.Thickness = 0.5
	UIStoke.ZIndex = 0

	obj.TextInput.Part.Parent = Input
	obj.TextInput.Part.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	obj.TextInput.Part.BackgroundTransparency = 1.000
	obj.TextInput.Part.BorderColor3 = Color3.fromRGB(0, 0, 0)
	obj.TextInput.Part.BorderSizePixel = 0
	obj.TextInput.Part.Size = UDim2.new(1, 0, 1, 0)
	obj.TextInput.Part.ClearTextOnFocus = false
	obj.TextInput.Part.Font = Enum.Font.FredokaOne
	obj.TextInput.Part.PlaceholderText = prop.TextPlaceholder or "input"
	obj.TextInput.Part.Text = prop.TextInBox or ""
	obj.TextInput.Part.TextColor3 = Color3.fromRGB(255, 255, 255)
	obj.TextInput.Part.TextSize = 14.000
	
	coroutine.wrap(function()
		local script = LocalScript
		
		local Tween = game:GetService("TweenService")

		local colortweeninfo = TweenInfo.new(0.25, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, 0, false, 0)

		script.Parent:GetAttributeChangedSignal("disabled"):Connect(function()
			if script.Parent:GetAttribute('disabled') then
				Tween:Create(script.Parent.UIStroke, colortweeninfo, {Color = Color3.fromRGB(130, 130, 130)}):Play()
				Tween:Create(script.Parent.Input.UIStroke, colortweeninfo, {Color = Color3.fromRGB(130, 130, 130)}):Play()
				script.Parent.Input.TextBox.TextEditable = false
			else
				Tween:Create(script.Parent.UIStroke, colortweeninfo, {Color = Color3.fromRGB(170, 0, 255)}):Play()
				Tween:Create(script.Parent.Input.UIStroke, colortweeninfo, {Color = Color3.fromRGB(170, 0, 255)}):Play()
				script.Parent.Input.TextBox.TextEditable = true
			end
		end)

		script.Parent.Input.TextBox:GetPropertyChangedSignal("Text"):Connect(function()
			script.Parent:SetAttribute('value', script.Parent.Input.TextBox.Text)
		end)
		
		obj.Part:GetAttributeChangedSignal("value"):Connect(function()
			obj.OnValueChanged:Fire(obj.Part:GetAttribute("value"))
		end)

		obj.Part:GetAttributeChangedSignal("disabled"):Connect(function()
			obj.OnDisabledChanged:Fire(obj.Part:GetAttribute("disabled"))
		end)
	end)()
	
	obj.Part:SetAttribute("disabled", prop.IsDisabled)
	
	return obj
end

function GuiLibrary.KeyClass:GetKey()
	return self.Key:GetAttribute('value')
end

function GuiLibrary.ElementsClass:GetValue()
	if self.Class == 'Button' then return error("You can't get button value!") end 
	if self.Class == 'Element' then return error("You can't get multilabel value!") end 
	if self.Part:GetAttribute('value') ~= nil then
		if self.Part:GetAttribute('value') == '' then return nil end 
		return self.Part:GetAttribute("value")
	end
	return self.Part:GetAttribute("state")
end

function GuiLibrary.ElementsClass:GetDisabled(value)
	if self.Class == 'Element' then return error("You can't get multilabel disabled!") end 
	return self.Part:SetAttribute("disabled", value)
end

function GuiLibrary.ElementsClass:SetValue(value)
	if self.Class == 'Button' then return error("You can't change button value!") end 
	if self.Class == 'Element' then return error("You can't change multilabel value!") end 
	if self.Class == 'Slider' then self.ValueChanger.Part.Value = value return end
	if self.Part:GetAttribute('value') ~= nil then
		return self.Part:SetAttribute("value", value)
	end
	return self.Part:SetAttribute("state", value)
end

function GuiLibrary.ElementsClass:SetDisabled(value)
	if self.Class == 'Element' then return error("You can't change multilabel disabled!") end 
	return self.Part:SetAttribute("disabled", value)
end

function GuiLibrary.ListClass:GetList()
	local list = {} 
	local ans = {}
	
	for i, v in pairs(self.Values) do
		list[i] = v['Part'].LayoutOrder
	end
	
	for i, v in ipairs(bubbleSort(list)) do
		table.insert(ans, v['part'])
	end
	
	return ans
end

function GuiLibrary.SliderClass:UpdateValues(prop)
	self.Values.SliderStep = prop.SliderStep or nil
	self.Values.Min = prop.MinValue or nil
	self.Values.Max = prop.MaxValue or nil
	self.Values.CurrentValue = prop.CurrentValue or nil
	
	self.Part.Update.Value = true
	
	return self
end

function GuiLibrary.ElementClass:InsertLabel(prop)
	if not prop.Name then return error('No Label Name!') end
	
	local obj = {}
	
	obj.Text = prop.Text or ''
	obj.TextSize = prop.TextSize or 16
	obj.Name = prop.Name
	
	obj.Part = Instance.new('TextLabel')
	obj.Part.Name = prop.Name
	obj.Part.LayoutOrder = #self.Part.Elements:GetChildren() - 1
	obj.Part.Parent = self.Part.Elements
	obj.Part.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	obj.Part.BackgroundTransparency = 1.000
	obj.Part.BorderColor3 = Color3.fromRGB(0, 0, 0)
	obj.Part.BorderSizePixel = 0
	obj.Part.Position = UDim2.new(0.05, 0, 0, 0)
	obj.Part.Size = UDim2.new(0.98, 0, 0, 0)
	obj.Part.Font = prop.TextFont or Enum.Font.FredokaOne
	obj.Part.Text = prop.Text or ''
	obj.Part.TextColor3 = Color3.fromRGB(255, 255, 255)
	obj.Part.TextSize = prop.TextSize or 16
	obj.Part.TextWrapped = true
	obj.Part.TextXAlignment = Enum.TextXAlignment.Left
	obj.Part.AutomaticSize = Enum.AutomaticSize.Y
	obj.Part.RichText = true
	
	local UIPadding = Instance.new('UIPadding')
	UIPadding.Parent = obj.Part
	UIPadding.PaddingLeft = UDim.new(0.05, 0)
	UIPadding.PaddingTop = UDim.new(0, 8)
	
	self.Elements[prop.Name] = obj
	
	self.Part.Event.Value = true
	self.Part.Parent:SetAttribute('resize', true)
	
	if label_fix then task.spawn(function() task.wait(1) self.Part.Event.Value = true self.Part.Parent:SetAttribute('resize', true) end) end
	
	return self
end

function GuiLibrary.ElementClass:UpdateLabel(prop)
	if not prop.Name then return error('No Label Name!') end
	
	if self.Elements[prop.Name] then
		self.Elements[prop.Name].Part.Text = prop.Text or self.Elements[prop.Name].Part.Text
		self.Elements[prop.Name].Part.Font = prop.TextFont or Enum.Font.FredokaOne
		
		if prop.LayoutOrder then
			for i, v in ipairs(self.Elements[prop.Name].Part.Parent:GetChildren()) do
				if not v:IsA("UIListLayout") then
					if v.LayoutOrder >= prop.LayoutOrder then
						v.LayoutOrder = v.LayoutOrder + 1 
					end
				end
			end
			self.Elements[prop.Name].Part.LayoutOrder = prop.LayoutOrder
		end
	end
	
	self.Part.Event.Value = true
	self.Part.Parent:SetAttribute('resize', true)
	
	if label_fix then task.spawn(function() task.wait(1) self.Part.Event.Value = true self.Part.Parent:SetAttribute('resize', true) end) end
	
	return self
end

function GuiLibrary.KeyClass:Destroy()
	self.ScreenGUI:Destroy()
	return self
end

return GuiLibrary
