class MCM_Slider extends MCM_SettingBase implements(MCM_API_Slider) config(ModConfigMenu);

var MCM_API_Setting ParentFacade;
var delegate<FloatSettingHandler> ChangeHandler;

var float SliderMin;
var float SliderMax;
var float SliderStep;
var float SliderValue;

var UIScrollingText SliderValueDisplay;

var bool SuppressEvent;

var delegate<SliderValueDisplayFilter> DisplayFilter;

delegate string SliderValueDisplayFilter(float _value);
delegate FloatSettingHandler(MCM_API_Setting Setting, float _SettingValue);

simulated function MCM_SettingBase InitSettingsItem(name _Name, eSettingType _Type, optional string _Label = "", optional string _Tooltip = "")
{
    `log("Don't call InitSettingsItem directly in subclass of MCM_SettingBase.");

    return none;
}

// Fancy init process
simulated function MCM_Slider InitSlider(name _SettingName, MCM_API_Setting _ParentFacade, string _Label, string _Tooltip, 
    float sMin, float sMax, float sStep, float sValue, delegate<FloatSettingHandler> _OnChange)
{
    super.InitSettingsItem(_SettingName, eSettingType_Slider, _Label, _Tooltip);

    SliderValueDisplay = Spawn(class'UIScrollingText', self);
	SliderValueDisplay.bIsNavigable = false;
	SliderValueDisplay.bAnimateOnInit = bAnimateOnInit;
	SliderValueDisplay.InitScrollingText('SliderValueTextControl',,90,260);

    SuppressEvent = false;

    ChangeHandler = _OnChange;
    ParentFacade = _ParentFacade;

    SliderMin = sMin;
    SliderMax = sMax;
    SliderStep = sStep;
    SliderValue = ClampAndSnapValue(sMin, sMax, sStep, sValue);

    UpdateDataSlider(_Label, "", GetSliderPositionFromValue(SliderMin, SliderMax, SliderValue), , SliderChangedCallback);

    // Initially no filter.
    DisplayFilter = none;
    UpdateSliderValueDisplay();

    SetHoverTooltip(_Tooltip);

    return self;
}

function SliderChangedCallback(UISlider SliderControl)
{
    if (!SuppressEvent)
    {
        // Safe to put this inside the SuppressEvent guard because SuppressEvent is only set via methods that modify the SliderValue directly.
        SliderValue = ClampAndSnapValue(SliderMin, SliderMax, SliderStep, GetSliderValueFromPosition(SliderMin, SliderMax, Slider.percent));
        UpdateSliderValueDisplay();
        if(ChangeHandler != none)
        {
            ChangeHandler(ParentFacade, self.GetValue());
        }
    }
}

simulated function AfterParentPageDisplayed()
{
    super.AfterParentPageDisplayed();
}

function UpdateSliderValueDisplay()
{
    //SliderValueDisplay.SetHTMLText("<p align='right'>" $ string(GetValue()) $ "</p>");
    if (DisplayFilter == none)
    {
        SliderValueDisplay.SetText(DefaultDisplayFilter(GetValue()));
    }
    else
    {
        SliderValueDisplay.SetText(DisplayFilter(GetValue()));
    }
}

function string DefaultDisplayFilter(float _value)
{
    return DefaultFormatValueForDisplay(SliderMin, SliderMax, SliderStep, _value);
}

// =============================================== Patching some unhelpful stuff that UpdateDataSlider does.

simulated function UpdateDataSlider(string _Desc,
									 String _SliderLabel,
									 optional int _SliderPosition,
									 optional delegate<OnClickDelegate> _OnClickDelegate = none,
									 optional delegate<OnSliderChangedCallback> _OnSliderChangedDelegate = none)
{
	SetWidgetType(EUILineItemType_Slider);

	if( Slider == none )
	{
		Slider = Spawn(class'MCM_XCOM2_UISlider', self);
		Slider.bIsNavigable = false;
		Slider.bAnimateOnInit = false;
		Slider.InitSlider('SliderMC');
		Slider.Navigator.HorizontalNavigation = true;
		//Slider.SetPosition(width - 420, 0);
		Slider.SetX(width - 420);
	}

	Slider.SetPercent(_SliderPosition);
	Slider.SetText(_SliderLabel);
	Slider.Show();

	// Since we have a narrower settings object, we're just going to hard-code this as 250 because it's wide enough.
    //Desc.SetWidth(width - 420);
    Desc.SetWidth(250);

	Desc.SetHTMLText(_Desc);
	Desc.Show();

	OnClickDelegate = _OnClickDelegate;
	OnSliderChangedCallback = _OnSliderChangedDelegate;
	Slider.onChangedDelegate = _OnSliderChangedDelegate;
}

// MCM_API_Slider implementation =============================================================================

simulated function float GetValue()
{
    return SliderValue;
}

simulated function SetValue(float _Value, bool _SuppressEvent)
{
    SliderValue = ClampAndSnapValue(SliderMin, SliderMax, SliderStep, _Value);

    SuppressEvent = _SuppressEvent;
    Slider.SetPercent(GetSliderPositionFromValue(SliderMin, SliderMax, SliderValue));
    UpdateSliderValueDisplay();
    SuppressEvent = false;
}

function GetBounds(out float sMin, out float sMax, out float sStep, out float sValue)
{
    sMin = SliderMin;
    sMax = SliderMax;
    sStep = SliderStep;
    sValue = SliderValue;
}

simulated function SetBounds(float min, float max, float step, float newValue, bool _SuppressEvent)
{
    SliderMin = min;
    SliderMax = max;
    SliderStep = step;
    SliderValue = ClampAndSnapValue(min, max, step, newValue);
    
    SuppressEvent = _SuppressEvent;
    Slider.SetPercent(GetSliderPositionFromValue(SliderMin, SliderMax, SliderValue));
    UpdateSliderValueDisplay();
    SuppressEvent = false;
}

simulated function SetValueDisplayFilter(delegate<SliderValueDisplayFilter> _DisplayFilter)
{
    DisplayFilter = _DisplayFilter;
    UpdateSliderValueDisplay();
}

// Have to override to disable the underlying control.
simulated function SetEditable(bool IsEditable)
{
    super.SetEditable(IsEditable);
    //SliderValueDisplay.SetDisabled(!IsEditable);

    // Hiding *everything* for consistency's sake. Until there's a better answer.
    if (IsEditable)
    {
        SliderValueDisplay.Show();
        Slider.Show();
    }
    else
    {
        SliderValueDisplay.Hide();
        Slider.Hide();
    }
}

// =============================================== Value/Position conversions

// For an indicated numerical value, get the percent on the slider that represents
// that value.
static function float GetSliderPositionFromValue(float sMin, float sMax, float sValue)
{
    // The weird 99 is because range is [1,100] and not [0,100].
    //return 1.0 + 99.0 * (sValue - sMin)/(sMax - sMin);
    return 100.0 * (sValue - sMin) / (sMax - sMin);
}

// For an indicated percent position on the slider, get the value that is represented
// by that position.
static function float GetSliderValueFromPosition(float sMin, float sMax, float sPercent)
{
    // The weird 99 is because range is [1,100] and not [0,100].
    //return sMin + (sMax - sMin) * ((sPercent-1.0) / 99.0);
    return sMin + (sMax - sMin) * (sPercent / 100.0);
}

// Clamps the indicated value to between the min/max, and also snaps it to the nearest
// stepping point between them.
static function float ClampAndSnapValue(float sMin, float sMax, float sStep, float sValue)
{
    if (sValue <= sMin) return sMin;
    if (sValue >= sMax) return sMax;
    if (sStep > 0)
    {
        return float(int((sValue - sMin) / sStep)) * sStep + sMin;
    }
    return sValue;
}

static function float PercentPerStep(float sMin, float sMax, float sStep)
{
    if (sStep == 0) return 0;
    return sStep / (sMax - sMin) * 100.0;
}

// =============================================== Default value display code

// The default function to format a value into a string for display. Is used by both the
// Slider and SliderFacade, so put here for less duplication.
static function string DefaultFormatValueForDisplay(float sMin, float sMax, float sStep, float sValue)
{
    local string retstring;
    local int i;
    
    retstring = string(sValue);

    // if there is a decimal, strip out any ending zeroes (and the decimal if necessary)
    i = InStr(retstring, ".");
    if (i > 0) {
        while (Right(retstring, 1) == "0") retstring = Left(retstring, Len(retstring) - 1);
        if    (Right(retstring, 1) == ".") retstring = Left(retstring, Len(retstring) - 1);
    }
    
    return retstring;
}
