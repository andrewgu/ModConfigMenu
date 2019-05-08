class MCM_Label extends MCM_SettingBase implements(MCM_API_Label) config(ModConfigMenu);

simulated function MCM_SettingBase InitSettingsItem(name _Name, eSettingType _Type, optional string _Label = "", optional string _Tooltip = "")
{
    `log("Don't call InitSettingsItem directly in subclass of MCM_SettingBase.");

    return none;
}

// Fancy init process
simulated function MCM_Label InitLabel(name _SettingName, MCM_API_Setting _ParentFacade, string _Label, string _Tooltip)
{
    super.InitSettingsItem(_SettingName, eSettingType_Label, _Label, _Tooltip);

    UpdateDataDescription(_Label);
    SetHoverTooltip(_Tooltip);

    return self;
}

// No special methods in MCM_API_Label.

defaultproperties
{
	bIsNavigable = false
	bShouldPlayGenericUIAudioEvents = false
}