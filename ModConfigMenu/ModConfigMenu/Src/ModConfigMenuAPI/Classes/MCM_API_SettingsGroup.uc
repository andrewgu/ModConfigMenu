interface MCM_API_SettingsGroup;

delegate VoidSettingHandler(MCM_API_Setting Setting, name SettingName);
delegate BoolSettingHandler(MCM_API_Setting Setting, name SettingName, bool SettingValue);
delegate FloatSettingHandler(MCM_API_Setting Setting, name SettingName, float SettingValue);
delegate StringSettingHandler(MCM_API_Setting Setting, name SettingName, string SettingValue);

// For reference purposes, not display purposes.
function name GetName();

// For display purposes, not reference purposes.
function string GetLabel();
function SetLabel(string Label);

// Get member settings.
function GetSettings(out array<MCM_API_Setting> Buffer);