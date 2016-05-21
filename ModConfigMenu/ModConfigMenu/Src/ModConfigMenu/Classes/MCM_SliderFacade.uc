class MCM_SliderFacade extends Actor implements(MCM_SettingFacade, MCM_API_Setting, MCM_API_Slider) config(ModConfigMenu);

var name SettingName;
var string Label;
var string Tooltip;
var bool Editable;

var MCM_SettingGroup ParentGroup;

var float SliderMin;
var float SliderMax;
var float SliderStep;
var float SliderValue;

var delegate<FloatSettingHandler> ChangeHandler;
var delegate<FloatSettingHandler> SaveHandler;

var delegate<SliderValueDisplayFilter> DisplayFilter;

var MCM_Slider uiInstance;

delegate FloatSettingHandler(MCM_API_Setting Setting, float _SettingValue);
delegate string SliderValueDisplayFilter(float value);

simulated function MCM_SliderFacade InitSliderFacade(name _Name, string _Label, string _Tooltip, 
    float sMin, float sMax, float sStep, float sValue,
    delegate<FloatSettingHandler> _OnChange, delegate<FloatSettingHandler> _OnSave,
    MCM_SettingGroup _ParentGroup)
{
    SettingName = _Name;
    Label = _Label;
    Tooltip = _Tooltip;
    Editable = true;

    ParentGroup = _ParentGroup;

    SliderMin = sMin;
    SliderMax = sMax;
    SliderStep = sStep;
    SliderValue = sValue;

    ChangeHandler = _OnChange;
    SaveHandler = _OnSave;

    DisplayFilter= none;

    uiInstance = none;

    return self;
}

function int RoundFloat(float _v)
{
    if (_v >= 0)
        return int(_v + 0.5);
    else
        return int (_v - 0.5);
}

function string InnerDisplayFilter(float _Value)
{
    if (DisplayFilter == none)
    {
        return string(RoundFloat(_Value));
    }
    else
    {
        return DisplayFilter(_Value);
    }
}

// MCM_SettingFacade implementation =================================================================
function UIMechaListItem InstantiateUI(UIList Parent)
{
    uiInstance = Spawn(class'MCM_Slider', parent.itemContainer).InitSlider(SettingName, self, Label, Tooltip, 
        SliderMin, SliderMax, SliderStep, SliderValue, ChangeHandler);
    uiInstance.Show();
    uiInstance.EnableNavigation();
    uiInstance.SetEditable(Editable);
    // Always have one implemented.
    uiInstance.SetValueDisplayFilter(InnerDisplayFilter);

    return uiInstance;
}

simulated function AfterParentPageDisplayed()
{
    if (uiInstance != none)
    {
        uiInstance.AfterParentPageDisplayed();
    }
}

function TriggerSaveEvent()
{
    if (uiInstance != none)
    {
        SaveHandler(self, uiInstance.GetValue());
    }
    else
    {
        SaveHandler(self, SliderValue);
    }
}

// MCM_SettingDropdown implementation ==================================================================

function float GetValue()
{
    if (uiInstance != none)
    {
        return uiInstance.GetValue();
    }
    else
    {
        return SliderValue;
    }
}

function SetValue(float Value, bool SuppressEvent)
{
    if (uiInstance != none)
    {
        uiInstance.SetValue(Value, SuppressEvent);
    }
    else
    {
        SliderValue = Value;
        if (!SuppressEvent)
        {
            ChangeHandler(self, SliderValue);
        }
    }
}

function SetBounds(float min, float max, float step, float newValue, bool SuppressEvent)
{
    if (uiInstance != none)
    {
        uiInstance.SetBounds(min, max, step, newValue, SuppressEvent);
    }
    else
    {
        SliderMin = min;
        SliderMax = max;
        SliderStep = step;
        SliderValue = newValue;

        if (!SuppressEvent)
        {
            ChangeHandler(self, SliderValue);
        }
    }
}

function SetValueDisplayFilter(delegate<SliderValueDisplayFilter> _DisplayFilter)
{
    DisplayFilter = _DisplayFilter;
}

// MCM_API_Setting implementation ====================================================================

// Name is used for ID purposes, not for UI.
function name GetName()
{
    return uiInstance != none ? uiInstance.GetName() : SettingName;
}

// Label is used for UI purposes, not for ID.
function SetLabel(string NewLabel)
{
    if (uiInstance != none)
    {
        uiInstance.SetLabel(NewLabel);
    }
    else
    {
        Label = NewLabel;
    }
}

function string GetLabel()
{
    return uiInstance != none ? uiInstance.GetLabel() : Label;
}

// When you mouse-over the setting.
function SetHoverTooltip(string _Tooltip)
{
    if (uiInstance != none)
    {
        uiInstance.SetHoverTooltip(_Tooltip);
    }
    else
    {
        Tooltip = _Tooltip;
    }
}

function string GetHoverTooltip()
{
    return uiInstance != none ? uiInstance.GetHoverTooltip() : Tooltip;
}

// Lets you show an option but disable it because it shouldn't be configurable.
// For example, if you don't want to allow tweaking during a mission.
function SetEditable(bool IsEditable)
{
    if (uiInstance != none)
    {
        uiInstance.SetEditable(IsEditable);
    }
    else
    {
        Editable = IsEditable;
    }
}

// Retrieves underlying setting type. Defined as an int to make setting types more extensible to support
// future "extension types".
function int GetSettingType()
{
    return eSettingType_Slider;
}

function MCM_API_SettingsGroup GetParentGroup()
{
    return ParentGroup;
}