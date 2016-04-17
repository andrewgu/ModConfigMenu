class MCM_Button extends MCM_SettingBase implements(MCM_API_Button) config(ModConfigMenu);

var delegate<VoidSettingHandler> ClickHandler;

var MCM_API_Setting ParentFacade;

delegate VoidSettingHandler(MCM_API_Setting Setting, name _SettingName);

simulated function MCM_SettingBase InitSettingsItem(name _Name, eSettingType _Type, optional string _Label = "", optional string _Tooltip = "")
{
    `log("Don't call InitSettingsItem directly in subclass of MCM_SettingBase.");

    return none;
}

// Fancy init process
simulated function MCM_Button InitButton(name _SettingName, MCM_API_Setting _ParentFacade, string _Label, string _Tooltip, string _ButtonLabel, delegate<VoidSettingHandler> _OnClick)
{
    super.InitSettingsItem(_SettingName, eSettingType_Button, _Label, _Tooltip);

    ClickHandler = _OnClick;
    ParentFacade = _ParentFacade;

    UpdateDataButton(_Label, _ButtonLabel, ButtonClickedCallback);
    SetHoverTooltip(_Tooltip);

    return self;
}

function ButtonClickedCallback(UIButton ButtonSource)
{
    ClickHandler(ParentFacade, SettingName);
}

// MCM_API_Button implementation
function SimulateClick()
{
    ClickHandler(ParentFacade, SettingName);
}