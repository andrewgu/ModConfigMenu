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
    SliderValue = sValue;

    // Magical incantation to make SetStepSize work without messing up the location of the marker. SetStepSize has a really weird bug in it.
    UpdateDataSlider(_Label, "", int(GetSliderPositionFromValue(SliderMin, SliderMax, SliderValue) + 0.5), , SliderChangedCallback);
    //UpdateDataSlider(_Label, "", 1, , SliderChangedCallback);
    Slider.SetStepSize(GetSliderStepSize(SliderMin, SliderMax, SliderStep));
    Slider.SetPercent(GetSliderPositionFromValue(SliderMin, SliderMax, SliderValue));

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
        SliderValue = GetSliderValueFromPosition(SliderMin, SliderMax, Slider.percent);
        UpdateSliderValueDisplay();
        ChangeHandler(ParentFacade, self.GetValue());
    }
}

function UpdateSliderValueDisplay()
{
    //SliderValueDisplay.SetHTMLText("<p align='right'>" $ string(GetValue()) $ "</p>");
    if (DisplayFilter == none)
    {
        SliderValueDisplay.SetText(string(int(GetValue()+0.5)));
    }
    else
    {
        SliderValueDisplay.SetText(DisplayFilter(GetValue()));
    }
}

// Helpers

function float GetSliderPositionFromValue(float sMin, float sMax, float sValue)
{
    // The weird 99 is because range is [1,100] and not [0,100].
    return 1.0 + 99.0 * (sValue - sMin)/(sMax - sMin);
}

function float GetSliderValueFromPosition(float sMin, float sMax, float sPercent)
{
    // The weird 99 is because range is [1,100] and not [0,100].
    return (sMax - sMin) * ((sPercent-1.0) / 99.0);
}

function float GetSliderStepSize(float sMin, float sMax, float sStep)
{
    // The weird 99 is because range is [1,100] and not [0,100].
    return 99.0 * sStep / (sMax - sMin);
}

// MCM_API_Slider implementation =============================================================================

simulated function float GetValue()
{
    return SliderValue;
}

simulated function SetValue(float _Value, bool _SuppressEvent)
{
    SliderValue = _Value;

    SuppressEvent = _SuppressEvent;
    Slider.SetPercent(GetSliderPositionFromValue(SliderMin, SliderMax, SliderValue));
    UpdateSliderValueDisplay();
    SuppressEvent = false;
}

simulated function SetBounds(float min, float max, float step, float newValue, bool _SuppressEvent)
{
    SliderMin = min;
    SliderMax = max;
    SliderStep = step;
    SliderValue = newValue;
    
    SuppressEvent = _SuppressEvent;

    // Magical incantation to make SetStepSize work without messing up the location of the marker. SetStepSize has a really weird bug in it.
    UpdateDataSlider(GetLabel(), "", int(GetSliderPositionFromValue(SliderMin, SliderMax, SliderValue) + 0.5), , SliderChangedCallback);
    //UpdateDataSlider(GetLabel(), "", 1, , SliderChangedCallback);
    Slider.SetStepSize(GetSliderStepSize(SliderMin, SliderMax, SliderStep));
    Slider.SetPercent(GetSliderPositionFromValue(SliderMin, SliderMax, SliderValue));
    UpdateSliderValueDisplay();
    SetHoverTooltip(GetHoverTooltip());
    
    SuppressEvent = false;
}

simulated function SetValueDisplayFilter(delegate<SliderValueDisplayFilter> _DisplayFilter)
{
    DisplayFilter = _DisplayFilter;
    UpdateSliderValueDisplay();
}