--!strict
local GuiService = game:GetService("GuiService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local Logger = require(ReplicatedStorage.Module.Logger)("GuiBuilder")
Logger.Log("error", "errortest")
local GuiBuilder = {}

local Types = require(script.Types)
local Themes = require(script.Themes)

GuiBuilder.Types = Types

GuiBuilder.MainTheme = Types.Themes.Dark

local Signals = {}

local GuiCreated = Instance.new("BindableEvent")
local MainThemeChanged = Instance.new("BindableEvent")
Signals.GuiCreated = GuiCreated.Event
Signals.MainThemeChanged = MainThemeChanged.Event

GuiBuilder.Signals = Signals

local onChildAdded = Instance.new("BindableEvent") -- ((parent: Types.GuiClass, child: Types.GuiClass))

export type new = (
	((guiType: "Frame",          parent: Types.Parent, affectedByGlobalTheme: boolean?) -> (Types.Frame)) & 
	((guiType: "ScrollingFrame", parent: Types.Parent, affectedByGlobalTheme: boolean?) -> (Types.ScrollingFrame)) & 
	((guiType: "TextEditable",   parent: Types.Parent, affectedByGlobalTheme: boolean?) -> (Types.TextEditable)) & 
	((guiType: "TextButton",     parent: Types.Parent, affectedByGlobalTheme: boolean?) -> (Types.TextButton)) & 
	((guiType: "Image",          parent: Types.Parent, affectedByGlobalTheme: boolean?) -> (Types.ImageLabel)) & 
	((guiType: "ImageButton",    parent: Types.Parent, affectedByGlobalTheme: boolean?) -> (Types.ImageButton)) & 
	((guiType: "Button",         parent: Types.Parent, affectedByGlobalTheme: boolean?) -> (Types.Button)) & 
	((guiType: "Dropdown",       parent: Types.Parent, affectedByGlobalTheme: boolean?) -> (Types.Dropdown)) & 
	((guiType: "Slider",         parent: Types.Parent, affectedByGlobalTheme: boolean?) -> (Types.Slider)) & 
	((guiType: "Checkbox",       parent: Types.Parent, affectedByGlobalTheme: boolean?) -> ())
)

local ROBLOX_TOPBAR_Y_OFFSET = GuiService.TopbarInset.Height

GuiService:GetPropertyChangedSignal("TopbarInset"):Connect(function()
	ROBLOX_TOPBAR_Y_OFFSET = GuiService.TopbarInset.Height
end)

-- basic functions
local function cloneTable(t)
	local o = {}
	
	for i, v in pairs(t) do
		if typeof(v) == "table" then
			o[i] = cloneTable(v)
		else
			o[i] = v
		end
	end
	
	return o
end

local function getFont(font: Enum.Font?): Enum.Font
	local defaultFont = Enum.Font.BuilderSans
	
	if not font or typeof(font) ~= "Enum" then return defaultFont end
	
	for _, v in ipairs(Enum.Font:GetEnumItems()) do
		if v.Name ~= font.Name then continue end
		
		return v
	end
	
	return defaultFont
end

local function getGuiName(guiType: number): string
	for i, v in pairs(Types.Guis) do
		if guiType == v then
			return i
		end
	end
	
	Logger.Log("error", "gui name does not exist")
	error("")
end

local function getThemeName(themeType: number): string
	for i, v in pairs(Types.Themes) do
		if themeType == v then
			return i
		end
	end

	Logger.Log("error", "theme does not exist")
	error("")
end

local function isThemeAndColorChangeable(guiType:number):boolean
	if guiType == Types.Guis.BackgroundShadow or guiType == Types.Guis.RadioButtonGroup then
		return false
	else
		return true
	end
end

local function applyTheme(self: Types.GuiClass, gui: GuiObject, theme, animationEnabled: boolean?)
	for i, v in pairs(theme) do
		if typeof(v) == "table" then
			local i = getGuiName(i)
			
			local gui1 = gui:FindFirstChild(i)
print(i, v, gui1)
			if not gui1 or typeof(gui1) ~= "Instance" or not gui1:IsA("GuiObject") then
				Logger.Log("warn", "Can't apply theme on "..i)
			else
				applyTheme(self, gui1, v, animationEnabled)
			end
		elseif typeof(v) == "Enum" or typeof(v) == "boolean" then
			gui[i] = v
		else
			if animationEnabled then
				TweenService:Create(gui, TweenInfo.new(0.25, Enum.EasingStyle.Linear, Enum.EasingDirection.In), {
					[i] = v
				}):Play()
			else
				gui[i] = v
			end
		end
	end
end

-- GuiClass functions. named as `__f__{lowerletterfirstname}{lastname}`
local function __f__isA(self: Types.GuiClass|Types.__guiClass, guiClassName: Types.GuiClasses|Types.GuiClassNames): boolean
	assert((self.ClassName and typeof(self.ClassName) == "string" and #self.ClassName ~= 0), "GuiClass.GuiClassName property must be string. ")
	
	for i, v in ipairs(Types.GuiTypes[self.ClassName]) do
		if v == guiClassName then
			return true
		end
	end
	
	return false
end

local function __f__getChildren(self: Types.GuiClass | Types.__guiClass, privateGuiClass: Types.__p__guiClass): {Types.GuiClass}
	return table.clone(privateGuiClass.Children)
end

local function __f__getDescendants(self: Types.GuiClass | Types.__guiClass): {Types.GuiClass}
	local descendants = {}
	
	local function getDes(guiClass: Types.GuiClass | Types.__guiClass)
		for _, v in ipairs(self:GetChildren()) do
			local des = v:GetChildren()
			
			if des ~= {} then
				table.insert(descendants, v)
			else
				getDes(v)
			end
		end
	end
	
	getDes(self)
	
	return descendants
end

local function __f__findFirstChild(self: Types.GuiClass | Types.__guiClass, name: string): Types.GuiClass?
	for _, v in ipairs(self:GetChildren()) do
		if v.Name == name then
			return v
		end
	end
	
	return
end

local function __f__findFirstChildOfClass(self: Types.GuiClass, className: Types.GuiClasses): Types.GuiClass?
	for _, v in ipairs(self:GetChildren()) do
		if v:IsA(className) then
			return v
		end
	end
	
	return
end

local function __f__waitForChild(self: Types.GuiClass, name: string, timeout: number?): Types.GuiClass?
	local start = os.clock()
	local timeout = timeout or 10
	local found = self:FindFirstChild(name)
	
	while not found and os.clock() - start < timeout do
		task.wait()
		found = self:FindFirstChild(name)
	end
	
	return found
end

local function __f__destroy(self, destroiedEvent: BindableEvent)
	local self = self :: Types.__guiClass
	
	self.Gui:Destroy()
	self.Parent = nil
	
	self = table.freeze(self)
	
	destroiedEvent:Fire()
end

-- Types.__m__guiClass
local function __f__applyChange_Scrollable(self: Types.__guiClass & Types.GuiClass_Scrollable)
	local GuiContainer = self.GuiContainer :: ScrollingFrame
	
	GuiContainer.ScrollingEnabled = self.ScrollingEnabled
	GuiContainer.ScrollBarThickness =  self.ScrollbarThickness
	GuiContainer.ScrollBarImageTransparency = self.ScrollbarTransparency
	GuiContainer.ScrollBarImageColor3 = self.ScrollbarColor
	
	GuiContainer.BottomImage = self.BottomImage
	GuiContainer.MidImage = self.MidImage
	GuiContainer.TopImage = self.TopImage
	
	GuiContainer.ElasticBehavior = self.ElasticBehavior
	GuiContainer.HorizontalScrollBarInset = self.HorizontalScrollbarInset
	GuiContainer.VerticalScrollBarInset = self.VerticalScrollbarInset
	GuiContainer.VerticalScrollBarPosition = self.VerticalScrollbarPosition
	
	if not self.IsScrollbarAnimationEnabled then
		GuiContainer.ScrollBarThickness = self.MinScrollbarThickness
	end
end

local function __f__applyChange_TextEditable(self: Types.__guiClass & Types.GuiClass_TextEditable)
	local GuiContainer = self.GuiContainer :: TextBox
	
	GuiContainer.Text = self.Text
	GuiContainer.PlaceholderText = self.PlaceHolderText
	GuiContainer.Font = getFont(self.Font)
	GuiContainer.PlaceholderColor3 = self.PlaceHolderColor
	GuiContainer.TextColor3 = self.TextColor
	GuiContainer.TextSize = self.TextSize
	GuiContainer.RichText = self.RichText
	GuiContainer.TextWrapped = self.TextWrapped
	GuiContainer.TextScaled = self.TextScaled
	GuiContainer.TextTransparency = self.TextTransparency
	GuiContainer.TextXAlignment = self.TextXAlignment
	GuiContainer.TextYAlignment = self.TextYAlignment
	GuiContainer.TextDirection = self.TextDirection
	
	self.TextSizeConstraint.MaxTextSize = self.MaxTextSize
	self.TextSizeConstraint.MinTextSize = self.MinTextSize
	
	GuiContainer.ClearTextOnFocus = self.ClearTextOnFocus
	GuiContainer.CursorPosition = self.CursorPosition
	GuiContainer.MultiLine = self.MultiLine
	GuiContainer.TextEditable = self.TextEditable
	GuiContainer.TextTruncate = self.TextTruncate
	
	GuiContainer.Interactable = self.CanPlayerChangeText
end

local function __f__applyChange(self: Types.__guiClass)
	local parent: Instance?
	
	if typeof(self.Parent) == "table" then
		local ns = self.Parent :: Types.GuiClass
		
		parent = ns.GuiContainer
	else
		parent = self.Parent
	end
	
	self.Gui.Parent = parent
	
	onChildAdded:Fire(self.Parent, self)
	
	self.Gui.Name = self.Name
	self.Gui.Visible = self.Visible
	self.Gui.ZIndex = self.ZIndex
	self.Gui.LayoutOrder = self.LayoutOrder
	self.Gui.Position = self.Position
	self.Gui.AnchorPoint = self.AnchorPoint
	self.Gui.Size = self.Size
	
	self.Gui.BackgroundColor3 = self.Color
	self.Gui.Transparency = self.Transparency
	
	self.Gui.GroupColor3 = self.GroupColor
	self.Gui.GroupTransparency = self.GroupTransparency
	
	self.CornerObject.CornerRadius = self.CornerRadius
	
	self.PaddingObject.PaddingTop =    self.Padding.Up
	self.PaddingObject.PaddingBottom = self.Padding.Down
	self.PaddingObject.PaddingLeft =   self.Padding.Left
	self.PaddingObject.PaddingRight =  self.Padding.Right
	
	self.StrokeObject.Enabled = self.Stroke.Enabled
	self.StrokeObject.ApplyStrokeMode = self.Stroke.ApplyStrokeMode
	self.StrokeObject.Color = self.Stroke.Color
	self.StrokeObject.LineJoinMode = self.Stroke.LineJoinMode
	self.StrokeObject.Thickness = self.Stroke.Thickness
	self.StrokeObject.Transparency = self.Stroke.Transparency
	
	self.SizeConstraintObject.MaxSize = self.SizeConstraint.MaxSize
	self.SizeConstraintObject.MinSize = self.SizeConstraint.MinSize
	
	self.GradientObject.Enabled = self.Gradient.Enabled
	self.GradientObject.Color = self.Gradient.Color
	self.GradientObject.Rotation = self.Gradient.Rotation
	self.GradientObject.Transparency = self.Gradient.Transparency
	self.GradientObject.Offset = self.Gradient.Offset
	
	if not self.AspectRatioConstraint.Enabled then
		self.AspectRatioConstraintObject.Parent = nil
	else
		self.AspectRatioConstraintObject.Parent = self.Gui
	end
	
	self.AspectRatioConstraintObject.AspectRatio = self.AspectRatioConstraint.AspectRatio
	self.AspectRatioConstraintObject.AspectType = self.AspectRatioConstraint.AspectType
	self.AspectRatioConstraintObject.DominantAxis = self.AspectRatioConstraint.DominantAxis
	
	self.FlexItemObject.FlexMode = self.FlexItem.FlexMode
	self.FlexItemObject.ItemLineAlignment = self.FlexItem.ItemLineAlignment
	
	if self.FlexItemObject.FlexMode == Enum.UIFlexMode.Custom then
		self.FlexItemObject.GrowRatio = self.FlexItem.GrowRatio
		self.FlexItemObject.ShrinkRatio = self.FlexItem.ShrinkRatio
	elseif (self.FlexItem.FlexMode ~= Enum.UIFlexMode.None) and (((self.FlexItem.GrowRatio ~= 0)  and (self.FlexItem.GrowRatio ~= -1)) or ((self.FlexItem.ShrinkRatio ~= 0) and (self.FlexItem.ShrinkRatio ~= -1))) then
		Logger.Log("warn", "Can't apply self.FlexItem.GrowRatio and self.FlexItem.ShrinkRatio because self.FlexItem.FlexMode is not Enum.UIFlexMode.Custom. if you want to disable it then make them to 0 or -1 or set self.FlexItem.FlexMode to Enum.UIFlexMode.None. ")
	end
	
	if __f__isA(self, "GuiClass_Scrollable") then
		local self = self :: Types.__guiClass & Types.GuiClass_Scrollable
		
		__f__applyChange_Scrollable(self)
	elseif __f__isA(self, "GuiClass_TextEditable") then
		local self = self :: Types.__guiClass & Types.GuiClass_TextEditable
		
		__f__applyChange_TextEditable(self)
	end
end

local function __f__index(self: Types.__guiClass, index: string): any|Types.GuiClass|nil
	assert(typeof(index) == "string", "index must be string. ")
	
	local v = self[index]
	local v1 = __f__findFirstChild(self, index)
	
	if v then
		return v
	elseif v1 then
		return v1
	end
	
	return nil
end

local function __f__newindex(self: Types.__guiClass, index: string, value: any, propertyChangedEvent: BindableEvent)
	assert(typeof(index) == "string", "index must be string. ")
	
	if index == "Gui" or index == "GuiContainer" or index == "ClassName" or typeof(self[index]) == "function" or typeof(self[index]) == "RBXScriptSignal" or typeof(self[index]) == "Instance" then
		error(`{index} property is read-only. `)
	elseif index == "Parent" then
		local Parent = value :: Instance?
		
		if Parent and ((not Parent:IsA("Instance")) or typeof(Parent) ~= "table") then
			error("Parent must be a nil, GuiClass or an Instance. ")
		end
	elseif index == "onClickFunc" and typeof(value) == "function" then
	elseif typeof(self[index]) ~= "nil" and typeof(self[index]) == typeof(value) then
	else
		error(`{index} is not a valid member of {self.ClassName}. `)
	end
	
	local oldV = self[index]
	
	self[index] = value
	
	propertyChangedEvent:Fire(index, oldV, value)
	
	__f__applyChange(self)
end

-- Types.GuiClass_Theme
local function __f__updateTheme(self: Types.GuiClass & Types.GuiClass_Theme, animationEnabled: boolean?)
	local ThemeName = getThemeName(self.Theme)
	assert(ThemeName, "Cannot update theme because theme is not supported. ")
	
	local ThemePath = script.Themes:FindFirstChild(ThemeName) :: ModuleScript
	assert(ThemePath, "Theme does not exist")
	
	local Theme = require(ThemePath)
	assert(Theme, "Cannot update theme because theme is not supported. ")
	
	applyTheme(self, self.Gui, Theme[Types.Guis[self.ClassName]], animationEnabled)
	
	return self
end

-- Types.GuiClass_Scrollable
local function __f__updateCanvas(self: Types.GuiClass & Types.GuiClass_Scrollable, animationEnabled: boolean?)
	local ScrollingFrame = self.GuiContainer :: ScrollingFrame
	
	local filldire: "X"|"Y"
	if (self.ScrollingDirection == Enum.ScrollingDirection.X) then
		filldire = "X" 
	else 
		filldire = "Y"
	end
	
	local size = 0
	
	do
		local canvasSize, absoluteSize
		if filldire == "X" then
			canvasSize = self.CanvasSize.X
			absoluteSize = ScrollingFrame.AbsoluteSize.X
		else
			canvasSize = self.CanvasSize.Y
			absoluteSize = ScrollingFrame.AbsoluteSize.Y
		end
		
		for _, v in ipairs(ScrollingFrame:GetChildren()) do
			if v:IsA("GuiObject") then
				local vSize
				
				local ptSize = 0--((self.Padding.Scale / (1 + canvasSize.Scale) * absoluteSize) + self.Padding.Offset)
				if filldire == "X" then
					vSize = v.Size.X
					
					ptSize = ((self.Padding.Left.Scale / (1 + canvasSize.Scale) * absoluteSize) + (self.Padding.Right.Scale / (1 + canvasSize.Scale) * absoluteSize) + self.Padding.Left.Offset + self.Padding.Right.Offset)
				else
					vSize = v.Size.Y
					
					ptSize = ((self.Padding.Up.Scale / (1 + canvasSize.Scale) * absoluteSize) + (self.Padding.Down.Scale / (1 + canvasSize.Scale) * absoluteSize) + self.Padding.Up.Offset + self.Padding.Down.Offset)
				end
				
				local rtSize = ((vSize.Scale / (1 + canvasSize.Scale) * absoluteSize) + vSize.Offset)
				
				size += rtSize + ptSize
			end
		end
	end
	
	local canvasSize
	if filldire == "X" then
		canvasSize = UDim2.new(0, size, 0, 0)
	else
		canvasSize = UDim2.new(0, 0, 0, size)
	end
	
	if animationEnabled then
		TweenService:Create(ScrollingFrame, TweenInfo.new(.25, Enum.EasingStyle.Linear, Enum.EasingDirection.In), {
			["CanvasSize"] = canvasSize
		}):Play()
	else
		ScrollingFrame.CanvasSize = canvasSize
	end
	
	self.CanvasSize = canvasSize
	
	return self
end

-- Types.GuiClass_Window
local function __f__open(self: Types.GuiClass & Types.GuiClass_Window, animationEnabled: boolean?)
	
end

-- creating GuiClass
local function createMetaGuiClassPropertyBase<propertyType>(self: Types.__guiClass, property: propertyType): Types.__m__guiClass_property<propertyType>
	assert(typeof(property) == "table", "property must be a table type. ")
	
	return {
		__metatable = "The metatable is locked";
		__index = property;
		__newindex = function(_: propertyType, index: string, value: any)
			assert(property[index], "Property does not exist. ")
			assert(typeof(property[index]) == typeof(value), "Type mismatch. ")
			
			property[index] = value
			
			__f__applyChange(self)
		end;
	}
end

local function createMetaGuiClassProperty<propertyType>(self: Types.__guiClass, property: propertyType)
	assert(typeof(property) == "table", "property must be a table type. ")
	
	return setmetatable({} :: {[string]: any}, createMetaGuiClassPropertyBase(self, property))
end

local function createGuiClassBase(ClassName: Types.GuiClasses): (Types.__guiClass, {ChildAdded: BindableEvent; ChildRemoved: BindableEvent; PropertyChanged: BindableEvent; Destroied: BindableEvent}, Types.__p__guiClass)
	local self = {} :: Types.__guiClass
	
	local privateGuiClass: Types.__p__guiClass = {
		Children = {};
	}
	
	local Events = {
		ChildAdded = Instance.new("BindableEvent");
		ChildRemoved = Instance.new("BindableEvent");
		PropertyChanged = Instance.new("BindableEvent");
		Destroied = Instance.new("BindableEvent")
	}
	
	self.Parent = nil
	self.Name = ""
	self.ClassName = ClassName
	--self.Gui
	--self.GuiContainer
	
	self.Color = Types.Colors.White[1]
	self.Transparency = 0
	
	self.GroupColor = Types.Colors.White[1]
	self.GroupTransparency = 0
	
	self.Visible = true
	self.ZIndex = 1
	self.LayoutOrder = 0
	
	self.Position = UDim2.new(0, 0, 0, 0)
	self.AnchorPoint = Vector2.new(0, 0)
	self.Size = UDim2.new(0, 250, 0, 250)
	
	--self.CornerObject
	self.CornerRadius = UDim.new(0, 0)
	
	--self.PaddingObject
	self.Padding = createMetaGuiClassProperty(self, {
		Up =    UDim.new(0, 0);
		Down =  UDim.new(0, 0);
		Left =  UDim.new(0, 0);
		Right = UDim.new(0, 0);
	})
	
	--self.StrokeObject
	self.Stroke = createMetaGuiClassProperty(self, {
		Enabled = false;
		ApplyStrokeMode = Enum.ApplyStrokeMode.Contextual;
		Color = Types.Colors.Black[1];
		LineJoinMode = Enum.LineJoinMode.Round;
		Thickness = 1;
		Transparency = 0;
	})
	
	--self.ScaleObject
	self.Scale = 1
	
	--self.SizeConstraintObject
	self.SizeConstraint = createMetaGuiClassProperty(self, {
		MaxSize = Vector2.new(math.huge, math.huge);
		MinSize = Vector2.zero;
	})
	
	--self.GradientObject
	self.Gradient = createMetaGuiClassProperty(self, {
		Enabled = false;
		Color = ColorSequence.new(Types.Colors.White[1]);
		Rotation = 0;
		Transparency = NumberSequence.new(0);
		Offset = Vector2.zero;
	})
	
	--self.AspectRatioConstraintObject
	self.AspectRatioConstraint = createMetaGuiClassProperty(self, {
		Enabled = false;
		AspectRatio = 1;
		AspectType = Enum.AspectType.FitWithinMaxSize;
		DominantAxis = Enum.DominantAxis.Width;
	})
	
	--self.FlexItemObject
	self.FlexItem = createMetaGuiClassProperty(self, {
		FlexMode = Enum.UIFlexMode.None;
		GrowRatio = 0;
		ItemLineAlignment = Enum.ItemLineAlignment.Automatic;
		ShrinkRatio = 0;
	})
	
	self.ChildAdded = Events.ChildAdded.Event
	self.ChildRemoved = Events.ChildRemoved.Event
	self.PropertyChanged = Events.PropertyChanged.Event
	self.Destroyied = Events.Destroied.Event
	
	self.IsA = __f__isA
	
	self.GetChildren = function(self) return __f__getChildren(self, privateGuiClass) end
	self.GetDescendants = __f__getDescendants
	
	self.FindFirstChild = __f__findFirstChild
	self.FindFirstChildOfClass = __f__findFirstChildOfClass
	
	self.WaitForChild = __f__waitForChild
	
	self.Destroy = function(self: Types.GuiClass) return __f__destroy(self, Events.Destroied) end
	
	return self, Events, privateGuiClass
end

local function createMetaGuiClassBase(self: Types.__guiClass, propertyChangedEvent: BindableEvent): Types.__m__guiClass
	local metaGuiClass = {} :: Types.__m__guiClass
	
	metaGuiClass.__metatable = "The metatable is locked."
	metaGuiClass.__index = function(_, index: string) return __f__index(self, index) end
	metaGuiClass.__newindex = function(_, a, b) return __f__newindex(self, a, b, propertyChangedEvent) end
	metaGuiClass.__len = function(self: Types.GuiClass) return #self:GetChildren() end
	metaGuiClass.__tostring = function(self: Types.GuiClass) return self.Name end
	
	return metaGuiClass
end

local function createMetaGuiClass(self: Types.__guiClass, propertyChangedEvent: BindableEvent): Types.GuiClass
	return setmetatable({} :: Types.__guiClass, createMetaGuiClassBase(self, propertyChangedEvent))
end

-- add Type on __guiClass
local function addGuiClass_Theme(self: Types.__guiClass): (Types.__guiClass & Types.GuiClass_Theme)
	local self = self :: Types.__guiClass & Types.GuiClass_Theme
	
	self.Theme = GuiBuilder.MainTheme
	
	self.Color = Types.Colors.White[1]
	self.Transparency = 0
	
	self.GroupColor = Types.Colors.White[1]
	self.GroupTransparency = 0
	
	self.UpdateTheme = __f__updateTheme
	
	return self
end

local function addGuiClass_Scrollable(self: Types.__guiClass): (Types.__guiClass & Types.GuiClass_Scrollable)
	local self = self :: Types.__guiClass & Types.GuiClass_Scrollable
	
	self.ScrollingDirection = Enum.ScrollingDirection.Y
	self.CanvasSize = UDim2.new(0, 0, 1, 0)
	self.CanvasPosition = UDim.new(0, 0)
	
	self.ScrollingEnabled = true
	self.ScrollbarThickness = 0
	self.ScrollbarColor = Types.Colors.White[1]
	self.ScrollbarTransparency = 0
	
	self.BottomImage = "rbxasset://textures/ui/Scroll/scroll-bottom.png"
	self.MidImage = "rbxasset://textures/ui/Scroll/scroll-middle.png"
	self.TopImage = "rbxasset://textures/ui/Scroll/scroll-top.png"
	
	self.ElasticBehavior = Enum.ElasticBehavior.WhenScrollable
	self.HorizontalScrollbarInset = Enum.ScrollBarInset.None
	self.VerticalScrollbarInset = Enum.ScrollBarInset.None
	self.VerticalScrollbarPosition = Enum.VerticalScrollBarPosition.Right
	
	self.IsScrollbarAnimationEnabled = true
	self.MaxScrollbarThickness = 5
	self.MinScrollbarThickness = 0
	self.ScrollbarAnimationInfo = TweenInfo.new(.125, Enum.EasingStyle.Linear, Enum.EasingDirection.In)
	
	self.UpdateCanvas = __f__updateCanvas
	
	return self
end

local function addGuiClass_TextEditable(self: Types.__guiClass): (Types.__guiClass & Types.GuiClass_TextEditable)
	local self = self :: Types.__guiClass & Types.GuiClass_TextEditable
	
	self.Text = ""
	self.PlaceHolderText = ""
	self.TextColor = Types.Colors.White[1]
	self.PlaceHolderColor = Types.Colors.White[1]
	self.Font = Enum.Font.SourceSans
	self.TextSize = 14
	self.RichText = false
	self.TextWrapped = true
	self.TextScaled = false
	self.TextTransparency = 0
	self.TextXAlignment = Enum.TextXAlignment.Center
	self.TextYAlignment = Enum.TextYAlignment.Center
	
	--self.TextSizeConstraint
	self.MaxTextSize = 100;
	self.MinTextSize = 1;
	
	self.ClearTextOnFocus = false
	self.CursorPosition = 1
	self.MultiLine = false
	self.TextEditable = false
	self.TextTruncate = Enum.TextTruncate.None
	
	self.CanPlayerChangeText = false
	
	return self
end

local function addGuiClass_Image(self: Types.__guiClass): (Types.__guiClass & Types.GuiClass_Image)
	local self = self :: Types.__guiClass & Types.GuiClass_Image
	
	self.ImageId = "rbxasset://textures/ui/GuiImagePlaceholder.png"
	self.ImageTransparency = 0
	self.ImageRectOffset = Vector2.new(0, 0)
	self.ImageRectSize = Vector2.new(0, 0)
	self.ImageColor = Types.Colors.White[1]
	self.ResampleMode = Enum.ResamplerMode.Default
	self.ScaleType = Enum.ScaleType.Stretch
	
	return self
end

local function addGuiClass_Button(self: Types.__guiClass): (Types.__guiClass & Types.GuiClass_Button)
	local self = self :: Types.__guiClass & Types.GuiClass_Button
	
	self.Cooldown = 0
	
	self.isButtonCooldown = false
	self.isButtonCooldownEnded = true
	
	self.isActive = true
	
	self.HoldAnimationEnabled = true
	self.ClickAnimationEnabled = true
	
	
	
	return self
end

local function addGuiClass_asdf(self: Types.__guiClass): (Types.__guiClass & Types.GuiClass_asdf)
	
end

-- get GuiObjects by function
local function __getCanvasGroup(): CanvasGroup
	local canvasGroup = Instance.new("CanvasGroup")
	
	canvasGroup.BorderSizePixel = 0
	canvasGroup.AutoLocalize = false
	canvasGroup.Size = UDim2.new(0, 250, 0, 250)
	
	return canvasGroup
end

local function __getScrollingFrame(): ScrollingFrame
	local scrollingFrame = Instance.new("ScrollingFrame")
	
	scrollingFrame.BackgroundTransparency = 1
	scrollingFrame.BorderSizePixel = 0
	scrollingFrame.AutoLocalize = false
	scrollingFrame.Size = UDim2.new(1, 0, 1, 0)
	
	return scrollingFrame
end

local function __getTextBox(): TextBox
	local textBox = Instance.new("TextBox")
	
	textBox.BackgroundTransparency = 1
	textBox.BorderSizePixel = 0
	textBox.AutoLocalize = false
	textBox.Size = UDim2.new(1, 0, 1, 0)
	
	return textBox
end

local function __getTextButton(): TextButton
	local textButton = Instance.new("TextButton")
	
	textButton.BackgroundTransparency = 1
	textButton.BorderSizePixel = 0
	textButton.AutoLocalize = false
	textButton.Size = UDim2.new(1, 0, 1, 0)
	
	return textButton
end

local function __getImageLabel(): ImageLabel
	local imageLabel = Instance.new("ImageLabel")
	
	imageLabel.BackgroundTransparency = 1
	imageLabel.BorderSizePixel = 0
	imageLabel.AutoLocalize = false
	imageLabel.Size = UDim2.new(1, 0, 1, 0)
	
	return imageLabel
end

-- __guiClass to GuiClass
local function toGuiClass_Frame(self: Types.__guiClass): (Types.__guiClass & Types.GuiClass_Theme)
	local Gui = __getCanvasGroup()
	
	self.Gui = Gui
	self.GuiContainer = Gui
	
	local CornerObject = Instance.new("UICorner", Gui)
	local PaddingObject = Instance.new("UIPadding", Gui)
	local StrokeObject = Instance.new("UIStroke", Gui)
	local ScaleObject = Instance.new("UIScale", Gui)
	local SizeConstraintObject = Instance.new("UISizeConstraint", Gui)
	local GradientObject = Instance.new("UIGradient", Gui)
	local AspectRatioConstraintObject = Instance.new("UIAspectRatioConstraint", Gui)
	local FlexItem = Instance.new("UIFlexItem", Gui)
	
	self.CornerObject = CornerObject
	self.PaddingObject = PaddingObject
	self.StrokeObject = StrokeObject
	self.ScaleObject = ScaleObject
	self.SizeConstraintObject = SizeConstraintObject
	self.GradientObject = GradientObject
	self.AspectRatioConstraintObject = AspectRatioConstraintObject
	self.FlexItemObject = FlexItem
	
	self.ClassName = "Frame"
	
	local self = addGuiClass_Theme(self)
	
	return self
end

local function toGuiClass_ScrollingFrame(self: Types.__guiClass): (Types.__guiClass & Types.GuiClass_Theme & Types.GuiClass_Scrollable)
	local Gui = __getCanvasGroup()
	local GuiContainer = __getScrollingFrame()
	
	GuiContainer.Parent = Gui
	
	self.Gui = Gui
	self.GuiContainer = GuiContainer
	
	local CornerObject = Instance.new("UICorner", Gui)
	local PaddingObject = Instance.new("UIPadding", GuiContainer)
	local StrokeObject = Instance.new("UIStroke", Gui)
	local ScaleObject = Instance.new("UIScale", Gui)
	local SizeConstraintObject = Instance.new("UISizeConstraint", Gui)
	local GradientObject = Instance.new("UIGradient", Gui)
	local AspectRatioConstraintObject = Instance.new("UIAspectRatioConstraint", Gui)
	local FlexItem = Instance.new("UIFlexItem", GuiContainer)

	self.CornerObject = CornerObject
	self.PaddingObject = PaddingObject
	self.StrokeObject = StrokeObject
	self.ScaleObject = ScaleObject
	self.SizeConstraintObject = SizeConstraintObject
	self.GradientObject = GradientObject
	self.AspectRatioConstraintObject = AspectRatioConstraintObject
	self.FlexItemObject = FlexItem
	
	self.ClassName = "ScrollingFrame"
	
	local self = addGuiClass_Scrollable(addGuiClass_Theme(self)) :: Types.__guiClass & Types.GuiClass_Theme & Types.GuiClass_Scrollable
	
	local function playTween(tV: number)
		if not self.IsScrollbarAnimationEnabled then return end
		
		local tween = TweenService:Create(GuiContainer, self.ScrollbarAnimationInfo, {
			ScrollBarThickness = tV
		})
		
		tween:Play()
		
		tween.Completed:Connect(function(playbackState: Enum.PlaybackState) 
			if playbackState ~= Enum.PlaybackState.Completed then return end
			
			tween:Destroy()
			
			self.ScrollbarThickness = tV
		end)
	end
	
	GuiContainer.MouseEnter:Connect(function()
		playTween(self.MaxScrollbarThickness)
	end)
	
	GuiContainer.MouseLeave:Connect(function()
		playTween(self.MinScrollbarThickness)
	end)
	
	GuiContainer.ScrollBarThickness = self.MinScrollbarThickness
	
	return self
end

local function toGuiClass_TextEditable(self: Types.__guiClass, propertyChangedEvent: BindableEvent): (Types.__guiClass & Types.GuiClass_Theme & Types.GuiClass_TextEditable)
	local Gui = __getCanvasGroup()
	local GuiContainer = __getTextBox()
	
	GuiContainer.Parent = Gui
	
	self.Gui = Gui
	self.GuiContainer = GuiContainer
	
	local CornerObject = Instance.new("UICorner", Gui)
	local PaddingObject = Instance.new("UIPadding", Gui)
	local StrokeObject = Instance.new("UIStroke", Gui)
	local ScaleObject = Instance.new("UIScale", Gui)
	local SizeConstraintObject = Instance.new("UISizeConstraint", Gui)
	local GradientObject = Instance.new("UIGradient", Gui)
	local AspectRatioConstraintObject = Instance.new("UIAspectRatioConstraint", Gui)
	local FlexItem = Instance.new("UIFlexItem", Gui)
	
	self.CornerObject = CornerObject
	self.PaddingObject = PaddingObject
	self.StrokeObject = StrokeObject
	self.ScaleObject = ScaleObject
	self.SizeConstraintObject = SizeConstraintObject
	self.GradientObject = GradientObject
	self.AspectRatioConstraintObject = AspectRatioConstraintObject
	self.FlexItemObject = FlexItem
	
	self.ClassName = "TextEditable"
	
	local self = addGuiClass_TextEditable(addGuiClass_Theme(self)) :: Types.__guiClass & Types.GuiClass_Theme & Types.GuiClass_TextEditable
	
	GuiContainer.ClearTextOnFocus = false
	GuiContainer.TextEditable = true
	GuiContainer.Text = ""
	GuiContainer.PlaceholderText = ""
	GuiContainer.PlaceholderColor3 = Color3.fromRGB(128, 128, 128)
	GuiContainer.TextScaled = true
	GuiContainer.TextSize = 14
	GuiContainer.RichText = true
	GuiContainer.TextColor3 = Color3.fromRGB(0, 0, 0)
	GuiContainer.TextWrapped = true
	GuiContainer.Font = Enum.Font.SourceSans
	
	GuiContainer:GetPropertyChangedSignal("Text"):Connect(function()
		if self.CanPlayerChangeText then
			local oldText = self.Text
			
			self.Text = GuiContainer.Text
			
			propertyChangedEvent:Fire("Text", oldText, self.Text)
		end
	end)
	
	return self
end

local function toGuiClass_Image(self: Types.__guiClass): (Types.__guiClass & Types.GuiClass_Theme & Types.GuiClass_Image)
	local Gui = __getCanvasGroup()
	local GuiContainer = __getImageLabel()
	
	GuiContainer.Parent = Gui
	
	self.Gui = Gui
	self.GuiContainer = GuiContainer
	
	local CornerObject = Instance.new("UICorner", Gui)
	local PaddingObject = Instance.new("UIPadding", Gui)
	local StrokeObject = Instance.new("UIStroke", Gui)
	local ScaleObject = Instance.new("UIScale", Gui)
	local SizeConstraintObject = Instance.new("UISizeConstraint", Gui)
	local GradientObject = Instance.new("UIGradient", Gui)
	local AspectRatioConstraintObject = Instance.new("UIAspectRatioConstraint", Gui)
	local FlexItem = Instance.new("UIFlexItem", Gui)
	
	self.CornerObject = CornerObject
	self.PaddingObject = PaddingObject
	self.StrokeObject = StrokeObject
	self.ScaleObject = ScaleObject
	self.SizeConstraintObject = SizeConstraintObject
	self.GradientObject = GradientObject
	self.AspectRatioConstraintObject = AspectRatioConstraintObject
	self.FlexItemObject = FlexItem
	
	self.ClassName = "Image"
	
	local self = addGuiClass_Image(addGuiClass_Theme(self)) :: Types.__guiClass & Types.GuiClass_Theme & Types.GuiClass_Image
	
	GuiContainer.Image = "rbxasset://textures/ui/GuiImagePlaceholder.png"
	GuiContainer.ImageColor3 = Color3.fromRGB(255, 255, 255)
	GuiContainer.ScaleType = Enum.ScaleType.Fit
	GuiContainer.SliceCenter = Rect.new(0, 0, 0, 0)
	GuiContainer.SliceScale = 1
	GuiContainer.ImageRectSize = Vector2.new(0, 0)
	GuiContainer.ImageRectOffset = Vector2.new(0, 0)
	GuiContainer.ImageTransparency = 0
	GuiContainer.BackgroundTransparency = 1
	GuiContainer.ImageTransparency = 0
	
	return self
end

local function toGuiClass_Button(self: Types.__guiClass): (Types.__guiClass & Types.GuiClass_Theme & Types.GuiClass_Button)
	local Gui = __getCanvasGroup()
	local GuiContainer = __getCanvasGroup()
	
	GuiContainer.Parent = Gui
	
	self.Gui = Gui
	self.GuiContainer = GuiContainer
	
	local CornerObject = Instance.new("UICorner", Gui)
	local PaddingObject = Instance.new("UIPadding", GuiContainer)
	local StrokeObject = Instance.new("UIStroke", Gui)
	local ScaleObject = Instance.new("UIScale", Gui)
	local SizeConstraintObject = Instance.new("UISizeConstraint", Gui)
	local GradientObject = Instance.new("UIGradient", Gui)
	local AspectRatioConstraintObject = Instance.new("UIAspectRatioConstraint", Gui)
	local FlexItem = Instance.new("UIFlexItem", GuiContainer)

	self.CornerObject = CornerObject
	self.PaddingObject = PaddingObject
	self.StrokeObject = StrokeObject
	self.ScaleObject = ScaleObject
	self.SizeConstraintObject = SizeConstraintObject
	self.GradientObject = GradientObject
	self.AspectRatioConstraintObject = AspectRatioConstraintObject
	self.FlexItemObject = FlexItem

	self.ClassName = "Button"
	
	local self = addGuiClass_Button(addGuiClass_Theme(self)) :: Types.__guiClass & Types.GuiClass_Theme & Types.GuiClass_Button
	
	GuiContainer.BackgroundTransparency = 1
	GuiContainer.Size = UDim2.new(1, 0, 1, 0)
	GuiContainer.BorderSizePixel = 0
	
	local isDestroying = false
	local onClicked = Instance.new("BindableEvent")
	local onIsActiveChange = Instance.new("BindableEvent")
	local cooldownBarTween: TweenBase

	local function Do(func, ...)
		if not self.isActive then return end
		if self.isButtonCooldown then return end
		if self.Cooldown > 0 and not self.isButtonCooldownEnded then return end
		if isDestroying then return end

		return func(...)
	end

	local ButtonHolder = __getImageLabel()
	ButtonHolder.Parent = Gui
	ButtonHolder.ClipsDescendants = true
	ButtonHolder.BackgroundColor3 = self.Color
	ButtonHolder.BackgroundTransparency = 0
	ButtonHolder.ImageTransparency = 1

	local ButtonEventHolder = __getTextButton()
	ButtonEventHolder.Parent = Gui
	ButtonEventHolder.BackgroundColor3 = Types.Colors.White[2]
	ButtonEventHolder.Text = ""
	ButtonEventHolder.TextTransparency = 1
	ButtonEventHolder.AutoButtonColor = false

	local function onClick(clickPos: Vector2)
		Do(function()
			local smallestSize = math.min(ButtonEventHolder.AbsoluteSize.X, ButtonEventHolder.AbsoluteSize.Y)

			local BeforeTween_Size = UDim2.new(0, smallestSize * 1.25, 0, smallestSize * 1.25)
			local AfterTween_Size = UDim2.new(0, smallestSize * 5, 0, smallestSize * 5)

			local clickEffect = Instance.new("Frame", ButtonEventHolder)
			clickEffect.Name = "Circle"
			clickEffect.AnchorPoint = Vector2.new(.5, .5)
			clickEffect.Position = UDim2.new(0, math.round(clickPos.X - ButtonEventHolder.AbsolutePosition.X), 0, math.round(clickPos.Y - ButtonEventHolder.AbsolutePosition.Y) - ROBLOX_TOPBAR_Y_OFFSET)
			clickEffect.Size = BeforeTween_Size
			clickEffect.BackgroundColor3 = Types.Colors.White[2]
			clickEffect.BackgroundTransparency = 0.9

			do
				local Corner = Instance.new("UICorner", clickEffect)
				Corner.CornerRadius = UDim.new(1, 0)
			end

			local _Tween_Size = TweenService:Create(clickEffect, TweenInfo.new(.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
				Size = AfterTween_Size
			})

			local _Tween = TweenService:Create(clickEffect, TweenInfo.new(.5, Enum.EasingStyle.Linear, Enum.EasingDirection.In), {
				BackgroundTransparency = 1;
				BackgroundColor3 = Types.Colors.White[2];
			})

			_Tween_Size:Play()
			_Tween:Play()

			_Tween.Completed:Connect(function()
				clickEffect:Destroy()
			end)

			return
		end)
	end

	local function onHold()
		Do(function()
			TweenService:Create(ButtonEventHolder, TweenInfo.new(.5, Enum.EasingStyle.Linear, Enum.EasingDirection.In), {
				BackgroundTransparency = 0.9;
				BackgroundColor3 = Types.Colors.White[2];
			}):Play()

			return
		end)
	end

	local function onHoldEnded()
		Do(function()
			TweenService:Create(ButtonEventHolder, TweenInfo.new(.5, Enum.EasingStyle.Linear, Enum.EasingDirection.In), {
				BackgroundTransparency = 1;
				BackgroundColor3 = Types.Colors.White[2];
			}):Play()

			return
		end)
	end

	if self.Cooldown ~= 0 then
		self.CooldownBarTweenInfo = TweenInfo.new(self.Cooldown, Enum.EasingStyle.Linear, Enum.EasingDirection.In)

		local CooldownBar = __getCanvasGroup()
		CooldownBar.Parent = self.Gui
		CooldownBar.Size = UDim2.new(1, 0, 1, 0)
		CooldownBar.BackgroundTransparency = 0.6
		CooldownBar.BackgroundColor3 = Types.Colors.Black[2]

		self.Destroyied:Connect(function()
			self.isButtonCooldown = false
		end)

		local function SetState(complete: boolean)
			if not complete then
				CooldownBar.Size = UDim2.new(1, 0, 1, 0)
				CooldownBar.BackgroundTransparency = 0.6
				CooldownBar.BackgroundColor3 = Types.Colors.Black[2]

				self.isButtonCooldown = true
				self.isButtonCooldownEnded = false
			else
				CooldownBar.Size = UDim2.new(0, 0, 1, 0)
				CooldownBar.BackgroundTransparency = 1
				CooldownBar.BackgroundColor3 = Types.Colors.Black[2]

				self.isButtonCooldown = false
				self.isButtonCooldownEnded = true
			end
		end

		local function StopTween()
			if cooldownBarTween then
				if cooldownBarTween.PlaybackState == Enum.PlaybackState.Playing then
					cooldownBarTween:Cancel()
				end

				cooldownBarTween:Destroy()
			end
		end

		local function PlayTween()
			if cooldownBarTween and cooldownBarTween.PlaybackState == Enum.PlaybackState.Playing then
				StopTween()
			end

			local CooldownBarTween = TweenService:Create(CooldownBar, self.CooldownBarTweenInfo, {
				["Size"] = UDim2.new(0, 0, 1, 0);
				["BackgroundTransparency"] = 1;
				["BackgroundColor3"] = Types.Colors.Black[2];
			})

			cooldownBarTween = CooldownBarTween

			CooldownBarTween:Play()

			return CooldownBarTween
		end

		if self.isActive then
			SetState(false)

			local tw = PlayTween()
			
			tw.Completed:Connect(function(PlaybackState)
				SetState(PlaybackState == Enum.PlaybackState.Completed)
			end)
		end

		onIsActiveChange.Event:Connect(function(new: boolean)
			if not new then
				StopTween()

				SetState(false)
				
				return
			end
			
			if self.isButtonCooldown and not self.isButtonCooldownEnded then
				SetState(false)

				local tw = PlayTween()

				tw.Completed:Connect(function(PlaybackState)
					SetState(PlaybackState == Enum.PlaybackState.Completed)
				end)
			end
		end)
	end

	ButtonEventHolder.MouseButton1Down:Connect(function(x, y)
		onClick(Vector2.new(x, y))
	end)

	ButtonEventHolder.MouseButton1Up:Connect(function(...) Do(onClicked.Fire, onClicked, ...) end)

	ButtonEventHolder.MouseEnter:Connect(onHold)

	ButtonEventHolder.MouseLeave:Connect(onHoldEnded)

	return self
end

local function toGuiClass_Title(self: Types.__guiClass): (Types.__guiClass & Types.GuiClass_Title)
	
end

local function toGuiClass_Window(self: Types.__guiClass): (Types.__guiClass & Types.GuiClass_Theme & Types.GuiClass_Window)
	
end

-- you know what it does
local new: new = function(guiType, parent, affectedByGlobalTheme: boolean?): any
	local _self, Events, privateGuiClass = createGuiClassBase(guiType)
	
	if guiType == "Frame" then _self = toGuiClass_Frame(_self)
	elseif guiType == "ScrollingFrame" then _self = toGuiClass_ScrollingFrame(_self)
	elseif guiType == "TextEditable" then _self = toGuiClass_TextEditable(_self, Events.PropertyChanged)
	else error(`The guiType({guiType}) does not supported. `)
	end
	
	_self.Parent = parent
	
	local self = createMetaGuiClass(_self, Events.PropertyChanged)
	
	onChildAdded.Event:Connect(function(parent: Types.GuiClass, child: Types.GuiClass)
		if parent == self then
			child.Parent = self
			
			table.insert(privateGuiClass.Children, child)
			
			Events.ChildAdded:Fire(child)
		elseif child == self then
			self.Parent = parent
			
			for _, pChild in ipairs(privateGuiClass.Children) do
				onChildAdded:Fire(self, child)
			end
			
			Events.PropertyChanged:Fire("Parent", parent)
		else
			local i = table.find(privateGuiClass.Children, child)
			
			if i then
				local c = privateGuiClass.Children[i]
				
				table.remove(privateGuiClass.Children, i)
				
				Events.ChildRemoved:Fire(c)
			end
		end
	end)
	
	MainThemeChanged.Event:Connect(function(oldTheme: number, newTheme: number, animationEnabled: boolean?)
		if not affectedByGlobalTheme then return end
		if oldTheme == newTheme then return end
		if not __f__isA(self, "GuiClass_Theme") then return end
		
		local self = self :: (Types.GuiClass & Types.GuiClass_Theme)
		
		self.Theme = newTheme
		
		(self):UpdateTheme(animationEnabled)
	end)
	
	__f__applyChange(_self)
	
	return self
end

GuiBuilder.__new = new

-- general function
function GuiBuilder:ChangeMainTheme(newTheme: number, animationEnabled: boolean?)
	if newTheme ~= GuiBuilder["MainTheme"] then
		MainThemeChanged:Fire(GuiBuilder["MainTheme"], newTheme, animationEnabled)
		
		GuiBuilder["MainTheme"] = newTheme
	end
end

-- old function. do not use this.
function GuiBuilder.new(guiType: number, parent: Types.Parent | Types.GuiClass): Types.GuiClass
	assert(getGuiName(guiType), `GuiType isn't exist. `)
	
	local Parent:Types.Parent
	
	do
		if typeof(parent) == "table" then
			if typeof(parent.Gui) == "Instance" then
				if parent.Gui:IsA("GuiObject") then
					Parent = parent.Gui
				end
			end
		elseif typeof(parent) == "Instance" then 
			if parent:IsA("GuiObject") or parent:IsA("GuiBase") then
				Parent = parent
			end
		end
	end
	
	local self: Types.GuiClass = {
		Parent = parent;
		Children = {};
	}

	if guiType == Types.Guis.Frame or guiType == Types.Guis.ScrollingFrame then
		local Frame = createGuiObject(guiType, Parent)
		
		self.Gui = Frame

		createGuiFunctions(self, guiType, Parent, Frame)
	elseif guiType == Types.Guis.List then
		local BaseFrame: Frame = createGuiObject(Types.Guis.Frame, Parent)
		BaseFrame.Name = "ListFrame"
		
		self.Gui = BaseFrame

		local ListFrame: ScrollingFrame = createGuiObject(Types.Guis.ScrollingFrame, BaseFrame)
		ListFrame.Name = "ListBaseFrame"
		ListFrame.BackgroundTransparency = 1

		local UIListLayout = Instance.new("UIListLayout", ListFrame)
		UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
		UIListLayout.Padding = UDim.new(0, 5)

		createGuiFunctions(self, guiType, Parent, BaseFrame, ListFrame, UIListLayout)
	end
	
	self.IsThemeAndColorChangeable = isThemeAndColorChangeable(guiType)
	if self.IsThemeAndColorChangeable then
		self.Theme = GuiBuilder.MainTheme

		local ColorChanged = Instance.new("BindableEvent")
		local ThemeChanged = Instance.new("BindableEvent")
		self.ColorChanged = ColorChanged.Event
		self.ThemeChanged = ThemeChanged.Event

		local function UpdateTheme(self: Types.GuiClass): Types.GuiClass
			applyTheme(self.Gui, Themes[getThemeName(self.Theme)][guiType] or {})
			
			return self
		end
		
		local function ChangeTheme(self: Types.GuiClass, newTheme: number): Types.GuiClass
			assert(getThemeName(newTheme), "ThemeType does not exist. ")
			
			if self.Theme ~= Themes[getThemeName(newTheme)] then
				ThemeChanged:Fire(self.Theme, newTheme)

				self.Theme = newTheme

				UpdateTheme(self)
			end

			return self
		end
		
		self.UpdateTheme = UpdateTheme
		self.ChangeTheme = ChangeTheme
		
		MainThemeChanged.Event:Connect(function()
			ChangeTheme(self, GuiBuilder.MainTheme)
		end)
		
		UpdateTheme(self)
	end
	
	GuiCreated:Fire(self)
	
	return self
end

return GuiBuilder