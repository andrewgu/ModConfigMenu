interface MCM_API_SettingsPage;

// Gives you a way to uniquely identify this settings page from all others, 
// guaranteed to be unique per "OnInit" of the mod settings menu.
function int GetPageId();

delegate SaveStateHandler(MCM_API_SettingsPage SettingsPage);

delegate VoidSettingHandler(MCM_API_Setting Setting, name SettingName);
delegate BoolSettingHandler(MCM_API_Setting Setting, name SettingName, bool SettingValue);
delegate FloatSettingHandler(MCM_API_Setting Setting, name SettingName, float SettingValue);
delegate StringSettingHandler(MCM_API_Setting Setting, name SettingName, string SettingValue);

function SetPageTitle(string title);

// By default Save/Cancel buttons are not visible, you can choose to use them.
function SetSaveHandler(delegate<SaveStateHandler> SaveHandler);
function SetCancelHandler(delegate<SaveStateHandler> CancelHandler);

// By default Reset button is not visible, you can choose to use it.
function EnableResetButton(delegate<SaveStateHandler> ResetHandler);

// It's done this way because of some UI issues where dropdowns don't behave unless you initialize
// the settings UI widgets from bottom up.
function MCM_API_Label AddLabel(name SettingName, string Label, string Tooltip);
function MCM_API_Button AddButton(name SettingName, string Label, string Tooltip, string ButtonLabel, delegate<VoidSettingHandler> Handler);
function MCM_API_Checkbox AddCheckbox(name SettingName, string Label, string Tooltip, bool InitiallyChecked, delegate<BoolSettingHandler> Handler);
function MCM_API_Slider AddSlider(name SettingName, string Label, string Tooltip, float SliderMin, float SliderMax, float SliderStep, float InitialValue, delegate<FloatSettingHandler> Handler);
function MCM_API_Spinner AddSpinner(name SettingName, string Label, string Tooltip, array<string> Options, string Selection, delegate<StringSettingHandler> Handler);
function MCM_API_Dropdown AddDropdown(name SettingName, string Label, string Tooltip, array<string> Options, string Selection, delegate<StringSettingHandler> Handler);

function ShowSettings();

// Will return None if setting by that name isn't found.
function MCM_API_Setting GetSettingByName(name SettingName);
function MCM_API_Setting GetSettingByIndex(int Index);
function int GetNumberOfSettings();

// Allows you to specify whether the page should channel change events directly, or only on save.
function SetEventMode(eSettingEventMode Mode);
function eSettingEventMode GetEventMode();