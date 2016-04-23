class MCM_Checkbox extends MCM_SettingBase implements(MCM_API_Checkbox) config(ModConfigMenu);

var MCM_API_Setting ParentFacade;
var delegate<BoolSettingHandler> ChangeHandler;

delegate BoolSettingHandler(MCM_API_Setting _Setting, bool _SettingValue);

simulated function MCM_SettingBase InitSettingsItem(name _Name, eSettingType _Type, optional string _Label = "", optional string _Tooltip = "")
{
    `log("Don't call InitSettingsItem directly in subclass of MCM_SettingBase.");

    return none;
}

// Fancy init process
simulated function MCM_Checkbox InitCheckbox(name _SettingName, MCM_API_Setting _ParentFacade, string _Label, string _Tooltip, bool initiallyChecked, delegate<BoolSettingHandler> _OnChange)
{
    super.InitSettingsItem(_SettingName, eSettingType_Checkbox, _Label, _Tooltip);

    ChangeHandler = _OnChange;
    ParentFacade = _ParentFacade;

    UpdateDataCheckbox(_Label, "", initiallyChecked, CheckboxChangedCallback);
    SetHoverTooltip(_Tooltip);

    return self;
}

function CheckboxChangedCallback(UICheckbox CheckboxControl)
{
    ChangeHandler(ParentFacade, self.GetValue());
}

// MCM_API_Checkbox implementation =============================================================================

simulated function bool GetValue()
{
    return Checkbox.bChecked;
}

simulated function SetValue(bool Checked, bool SuppressEvent)
{
    Checkbox.SetChecked(Checked, !SuppressEvent);
}