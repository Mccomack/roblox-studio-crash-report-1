--!strict
local Types = {}

export type Parent = Instance|GuiClass|nil

export type GuiClasses = "Frame"|"ScrollingFrame"|"TextEditable"|"TextButton"|"Image"|"ImageButton"|"Button"|"Dropdown"|"Slider"|"Checkbox"|"RadioButtonGroup"|"RadioButton"|"Window"|"List"
export type GuiClassNames = "GuiClass_Theme"|"GuiClass_Scrollable"|"GuiClass_TextEditable"|"GuiClass_Image"|"GuiClass_Button"|"GuiClass_Dropdown"|"GuiClass_ToggleableButton"|"GuiClass_RadioButton"|"GuiClass_Window"

export type __p__guiClass = {
	Children: {GuiClass};
	
}

export type __m__guiClass = {
	__metatable: string;
	__index: ((GuiClass, string) -> (any|GuiClass|nil));
	__newindex: ((GuiClass, string, any) -> ());
	__len: ((GuiClass) -> (number)); -- set this to children count
	__tostring: ((GuiClass) -> (string)); -- set this to the name of the class
}

export type __m__guiClass_property<T> = {
	__metatable: string;
	__index: T;
	__newindex: ((any, string, any) -> ());
}

type __padding = {
	Up: UDim; 
	Down: UDim; 
	Left: UDim; 
	Right: UDim; 
}

type __stroke = {
	Enabled: boolean;
	ApplyStrokeMode: Enum.ApplyStrokeMode;
	Color: Color3;
	LineJoinMode: Enum.LineJoinMode;
	Thickness: number;
	Transparency: number;
}

type __sizeConstraint = {
	MaxSize: Vector2;
	MinSize: Vector2;
}

type __gradient = {
	Enabled: boolean;
	Color: ColorSequence;
	Rotation: number;
	Transparency: NumberSequence;
	Offset: Vector2;
}

type __aspectRatioConstraint = {
	Enabled: boolean;
	AspectRatio: number;
	AspectType: Enum.AspectType;
	DominantAxis: Enum.DominantAxis;
}

type __flexItem = {
	FlexMode: Enum.UIFlexMode;
	GrowRatio: number;
	ItemLineAlignment: Enum.ItemLineAlignment;
	ShrinkRatio: number;
}

export type PaddingSettings = typeof(setmetatable({} :: __padding, {} :: __m__guiClass_property<__padding>))
export type StrokeSettings = typeof(setmetatable({} :: __stroke, {} :: __m__guiClass_property<__stroke>))
export type SizeConstraintSettings = typeof(setmetatable({} :: __sizeConstraint, {} :: __m__guiClass_property<__sizeConstraint>))
export type GradientSettings = typeof(setmetatable({} :: __gradient, {} :: __m__guiClass_property<__gradient>))
export type AspectRatioConstraintSettings = typeof(setmetatable({} :: __aspectRatioConstraint, {} :: __m__guiClass_property<__aspectRatioConstraint>))
export type FlexItemSettings = typeof(setmetatable({} :: __flexItem, {} :: __m__guiClass_property<__flexItem>))

export type __guiClass = {
	--_children: {GuiClass}; -- private property
	Parent: Instance|GuiClass|nil;
	Name: string;
	ClassName: GuiClasses;
	Gui: CanvasGroup;
	GuiContainer: GuiObject;
		
	Color: Color3;
	Transparency: number;
	
	GroupColor: Color3;
	GroupTransparency: number;
	
	Visible: boolean;
	ZIndex: number;
	LayoutOrder: number;
	
	Position: UDim2;
	AnchorPoint: Vector2;
	Size: UDim2;
	
	CornerObject: UICorner;
	CornerRadius: UDim;
	
	PaddingObject: UIPadding;
	Padding: PaddingSettings;
	
	StrokeObject: UIStroke;
	Stroke: StrokeSettings;
	
	ScaleObject: UIScale;
	Scale: number;
	
	SizeConstraintObject: UISizeConstraint;
	SizeConstraint: SizeConstraintSettings;
	
	GradientObject: UIGradient;
	Gradient: GradientSettings;
	
	AspectRatioConstraintObject: UIAspectRatioConstraint;
	AspectRatioConstraint: AspectRatioConstraintSettings;
	
	FlexItemObject: UIFlexItem;
	FlexItem: FlexItemSettings;
	
	ChildAdded: RBXScriptSignal; -- ((child: GuiClass) -> ())
	ChildRemoved: RBXScriptSignal; -- ((child: GuiClass) -> ())
	--ParentChanged: RBXScriptSignal; -- ((oldParent: Instance|GuiClass|nil, newParent: Instance|GuiClass|nil) -> ()) 
	PropertyChanged: RBXScriptSignal; -- <T>((propertyName: string, oldPropertyValue: T, newPropertyValue: T) -> ())
	Destroyied: RBXScriptSignal; -- (() -> ())
	
	IsA: ((self: GuiClass, guiClassName: GuiClasses|GuiClassNames) -> (boolean));
	
	GetChildren: ((self: GuiClass | __guiClass) -> ({GuiClass}));
	GetDescendants: ((self: GuiClass) -> ({GuiClass}));
	
	FindFirstChild: ((self: GuiClass, name: string) -> (GuiClass?));
	FindFirstChildOfClass: ((self: GuiClass, className: GuiClasses) -> (GuiClass?));
	
	WaitForChild: ((self: GuiClass, name: string, timeout: number?) -> (GuiClass?));
	
	Destroy: ((self: GuiClass) -> ());
}

export type GuiClass = typeof(setmetatable({} :: __guiClass, {} :: __m__guiClass))

export type GuiClass_Theme = {
	Theme: number;

	UpdateTheme: ((self: GuiClass & GuiClass_Theme, animationEnabled: boolean?) -> (GuiClass & GuiClass_Theme));
}

export type GuiClass_Scrollable = {
	ScrollingDirection: Enum.ScrollingDirection;
	CanvasSize: UDim2;
	CanvasPosition: UDim;
	
	ScrollingEnabled: boolean;
	ScrollbarThickness: number;
	ScrollbarColor: Color3;
	ScrollbarTransparency: number;
	
	BottomImage: string;
	MidImage: string;
	TopImage: string;
	
	ElasticBehavior: Enum.ElasticBehavior;
	HorizontalScrollbarInset: Enum.ScrollBarInset;
	VerticalScrollbarInset: Enum.ScrollBarInset;
	VerticalScrollbarPosition: Enum.VerticalScrollBarPosition;
	
	IsScrollbarAnimationEnabled: boolean;
	MaxScrollbarThickness: number;
	MinScrollbarThickness: number;
	ScrollbarAnimationInfo: TweenInfo;
	
	UpdateCanvas: ((self: GuiClass & GuiClass_Scrollable, animationEnabled: boolean?) -> (GuiClass & GuiClass_Scrollable));
}

export type GuiClass_TextEditable = {
	Text: string;
	PlaceHolderText: string;
	Font: Enum.Font;
	TextColor: Color3;
	PlaceHolderColor: Color3;
	TextSize: number;
	RichText: boolean;
	TextWrapped: boolean;
	TextScaled: boolean;
	TextTransparency: number;
	TextXAlignment: Enum.TextXAlignment;
	TextYAlignment: Enum.TextYAlignment;
	TextDirection: Enum.TextDirection;
	
	TextSizeConstraint: UITextSizeConstraint;
	MaxTextSize: number;
	MinTextSize: number;
	
	ClearTextOnFocus: boolean;
	CursorPosition: number;
	MultiLine: boolean;
	TextEditable: boolean;
	TextTruncate: Enum.TextTruncate;
	
	CanPlayerChangeText: boolean;
}

export type GuiClass_Image = {
	ImageId: string;
	ImageColor: Color3;
	ImageRectOffset: Vector2;
	ImageRectSize: Vector2;
	ImageTransparency: number;
	ResampleMode: Enum.ResamplerMode;
	ScaleType: Enum.ScaleType;
}

export type GuiClass_Button = {
	Cooldown: number;

	isButtonCooldown: boolean;
	isButtonCooldownEnded: boolean;

	isActive: boolean;
	
	HoldAnimationEnabled: boolean;
	ClickAnimationEnabled: boolean; 
	
	HoldTweenInfo: TweenInfo;
	ClickTweenInfo: TweenInfo;
	ClickTweenInfo_Size: TweenInfo;
	CooldownBarTweenInfo: TweenInfo;
	
	ClickAnimationMaxSize: UDim;
	ClickAnimationMinSize: UDim;
	
	PlayClickAnimation: ((self: GuiClass & GuiClass_Button, pos: Vector2?) -> (GuiClass & GuiClass_Button));
	
	onClickEvent: RBXScriptSignal; -- ((x: number, y: number) -> ())
}

export type GuiClass_Dropdown = {
	DropdownIcon: (GuiClass & GuiClass_Image)?;
	DropdownText: (GuiClass & GuiClass_TextEditable);
	DropdownButton: (GuiClass & GuiClass_TextEditable & GuiClass_Image & GuiClass_Button & GuiClass_ToggleableButton);
	DropdownBody: (GuiClass & GuiClass_Scrollable);
	
	--[[Show: ((self: GuiClass & GuiClass_Dropdown) -> (GuiClass & GuiClass_Dropdown));
	Close: ((self: GuiClass & GuiClass_Dropdown) -> (GuiClass & GuiClass_Dropdown));]] -- use GuiClass_Dropdown.DropdownButton:Toggle()
}

export type GuiClass_ToggleableButton = {
	isToggled: boolean;
	
	Toggle: ((self: GuiClass & GuiClass_ToggleableButton, targetValue: boolean?) -> (GuiClass & GuiClass_ToggleableButton));
	
	onToggled: RBXScriptSignal; -- ((nowState: boolean) -> ())
}

export type GuiClass_CheckBox = {
	CheckboxIcon: (GuiClass & GuiClass_TextEditable & GuiClass_Image & GuiClass_Button);
	
	Body: (GuiClass);
}

export type GuiClass_RadioButton = {
	RadioButtonGroup: string;
}

export type GuiClass_Title = {
	Icon: GuiClass & GuiClass_Image;
	Text: GuiClass & GuiClass_TextEditable;
	
	ToMinimalSizeButton: GuiClass & GuiClass_TextEditable & GuiClass_Image & GuiClass_Button;
	ToFullscreenSizeButton: GuiClass & GuiClass_TextEditable & GuiClass_Image & GuiClass_Button;
	ToDefaultSizeButton: GuiClass & GuiClass_TextEditable & GuiClass_Image & GuiClass_Button;
	CloseButton: GuiClass & GuiClass_TextEditable & GuiClass_Image & GuiClass_Button;
}

export type GuiClass_Window = {
	Title: GuiClass & GuiClass_Title;
	
	DragEnabled: boolean;
	DragAnimation: TweenInfo;
	
	isDragging: boolean;
	
	CanPlayerChangeWindowSize: boolean;
	
	WindowState: "Opened" | "Closed";
	WindowSizeState: "Fullscreen" | "Default" | "Minimal";
	
	Open: ((GuiClass & GuiClass_Window, animationEnabled: boolean?) -> (GuiClass & GuiClass_Window));
	Close: ((GuiClass & GuiClass_Window, animationEnabled: boolean?) -> (GuiClass & GuiClass_Window));
	
	ToMinimalSize: ((GuiClass & GuiClass_Window, animationEnabled: boolean?) -> (GuiClass & GuiClass_Window));
	ToFullscreenSize: ((GuiClass & GuiClass_Window, animationEnabled: boolean?) -> (GuiClass & GuiClass_Window));
	ToDefaultSize: ((GuiClass & GuiClass_Window, animationEnabled: boolean?) -> (GuiClass & GuiClass_Window));
}

export type Frame            = GuiClass & GuiClass_Theme;
export type ScrollingFrame   = GuiClass & GuiClass_Theme & GuiClass_Scrollable;
export type TextEditable     = GuiClass & GuiClass_Theme & GuiClass_TextEditable;
export type TextButton       = GuiClass & GuiClass_Theme & GuiClass_TextEditable & GuiClass_Button;
export type ImageLabel       = GuiClass & GuiClass_Theme & GuiClass_Image;
export type ImageButton      = GuiClass & GuiClass_Theme & GuiClass_Image & GuiClass_Button;
export type Button           = GuiClass & GuiClass_Theme & GuiClass_TextEditable & GuiClass_Image & GuiClass_Button;
export type Dropdown         = GuiClass & GuiClass_Theme & GuiClass_TextEditable & GuiClass_Image & GuiClass_Button & GuiClass_ToggleableButton;
export type Slider           = GuiClass & GuiClass_Theme & GuiClass_TextEditable & GuiClass_Image & GuiClass_Button;
export type Checkbox         = GuiClass & GuiClass_Theme & GuiClass_TextEditable & GuiClass_Image & GuiClass_Button & GuiClass_ToggleableButton & GuiClass_CheckBox;
export type RadioButtonGroup = GuiClass & GuiClass_Theme & GuiClass_RadioButton;
export type RadioButton      = GuiClass & GuiClass_Theme & GuiClass_TextEditable & GuiClass_Image & GuiClass_Button & GuiClass_ToggleableButton & GuiClass_RadioButton;
export type Window           = GuiClass & GuiClass_Theme & GuiClass_Window;
-- export type List

Types.Colors = {
	Black = {
		[1] = Color3.fromRGB(0, 0, 0);
		[2] = Color3.fromRGB(15, 15, 15);
		[3] = Color3.fromRGB(30, 30, 30);
	};
	White = {
		[1] = Color3.fromRGB(255, 255, 255);
		[2] = Color3.fromRGB(240, 240, 240);
		[3] = Color3.fromRGB(220, 220, 220);
	};
	Blue = {
		[1] = Color3.fromRGB(0, 0, 255);
		[2] = Color3.fromRGB(30, 30, 255);
		[3] = Color3.fromRGB(90, 90, 255);
	};
	Red = {
		[1] = Color3.fromRGB(255, 0, 0);
		[2] = Color3.fromRGB(255, 30, 30);
		[3] = Color3.fromRGB(255, 90, 90);
	};
	Green = {
		[1] = Color3.fromRGB(0, 255, 0);
		[2] = Color3.fromRGB(30, 255, 30);
		[3] = Color3.fromRGB(90, 255, 90);
	};
	Gray = {
		[1] = Color3.fromRGB(95, 95, 95);
		[2] = Color3.fromRGB(130, 130, 130);
		[3] = Color3.fromRGB(165, 165, 165);
	};
}

Types.Themes = {
	Light = 0;
	Dark = 1;
	Colorful = 2;
}

Types.Guis = {
	Frame = 0;
	ScrollingFrame = 1;
	TextLabel = 2;
	TextBox = 3;
	TextButton = 4;
	ImageLabel = 5;
	ImageButton = 6;
	Button = 7;
	Dropdown = 8;
	Slider = 9;
	Checkbox = 10;
	RadioButtonGroup = 11;
	RadioButton = 12;
	
	Window = 14;
	List = 15;
}

Types.GuiTypes = {
	Frame = {
		"Frame";
		"CanvasGroup";
		"GuiClass";
		"GuiClass_Theme";
	};

	ScrollingFrame = {
		"Frame";
		"CanvasGroup";
		"ScrollingFrame";
		"GuiClass";
		"GuiClass_Theme";
		"GuiClass_Scrollable";
	};

	TextEditable = {
		"Frame";
		"CanvasGroup";
		"TextLabel";
		"GuiClass";
		"GuiClass_Theme";
		"GuiClass_TextEditable";
	};

	TextButton = {
		"Frame";
		"CanvasGroup";
		"TextButton";
		"GuiClass";
		"GuiClass_Theme";
		"GuiClass_TextEditable";
		"GuiClass_Button";
	};

	ImageLabel = {
		"Frame";
		"CanvasGroup";
		"ImageLabel";
		"GuiClass";
		"GuiClass_Theme";
		"GuiClass_ImageEditable";
	};

	ImageButton = {
		"Frame";
		"CanvasGroup";
		"ImageButton";
		"GuiClass";
		"GuiClass_Theme";
		"GuiClass_ImageEditable";
		"GuiClass_Button";
	};

	Button = {
		"Frame";
		"CanvasGroup";
		"TextButton";
		"ImageButton";
		"Button";
		"GuiClass";
		"GuiClass_Theme";
		"GuiClass_TextEditable";
		"GuiClass_ImageEditable";
		"GuiClass_Button";
	};

	Slider = {
		"Frame";
		"CanvasGroup";
		"Button";
		"Slider";
		"GuiClass";
		"GuiClass_Theme";
		"GuiClass_Button";
	}
}

return Types