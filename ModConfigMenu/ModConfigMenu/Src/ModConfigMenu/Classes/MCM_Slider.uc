class MCM_Slider extends MCM_SettingBase implements(MCM_API_Slider) config(ModConfigMenu);

var MCM_API_Setting ParentFacade;
var delegate<FloatSettingHandler> ChangeHandler;

var float SliderMin;
var float SliderMax;
var float SliderStep;
var float SliderValue;

var bool SuppressEvent;

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

    SuppressEvent = false;

    ChangeHandler = _OnChange;
    ParentFacade = _ParentFacade;

    SliderMin = sMin;
    SliderMax = sMax;
    SliderStep = sStep;
    SliderValue = sValue;

    UpdateDataSlider(_Label, "", int(GetSliderPositionFromValue(SliderMin, SliderMax, SliderValue) + 0.5), , SliderChangedCallback);
    Slider.SetStepSize(GetSliderStepSize(SliderMin, SliderMax, SliderStep));

    SetHoverTooltip(_Tooltip);

    return self;
}

function SliderChangedCallback(UISlider SliderControl)
{
    if (!SuppressEvent)
    {
        // Safe to put this inside the SuppressEvent guard because SuppressEvent is only set via methods that modify the SliderValue directly.
        SliderValue = GetSliderValueFromPosition(SliderMin, SliderMax, Slider.percent);
        ChangeHandler(ParentFacade, self.GetValue());
    }
}

// Helpers

function float GetSliderPositionFromValue(float sMin, float sMax, float sValue)
{
    return 100.0 * (sValue - sMin)/(sMax - sMin);
}

function float GetSliderValueFromPosition(float sMin, float sMax, float sPercent)
{
    return (sMax - sMin) * (sPercent / 100.0);
}

function float GetSliderStepSize(float sMin, float sMax, float sStep)
{
    return 100.0 * sStep / (sMax - sMin);
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
    SuppressEvent = false;
}

simulated function SetBounds(float min, float max, float step, float newValue, bool _SuppressEvent)
{
    SliderMin = min;
    SliderMax = max;
    SliderStep = step;
    SliderValue = newValue;
    
    SuppressEvent = _SuppressEvent;

    UpdateDataSlider(GetLabel(), "", int(GetSliderPositionFromValue(SliderMin, SliderMax, SliderValue) + 0.5), , SliderChangedCallback);
    Slider.SetStepSize(GetSliderStepSize(SliderMin, SliderMax, SliderStep));
    SetHoverTooltip(GetHoverTooltip());
    
    SuppressEvent = false;
}