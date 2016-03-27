interface MCM_API_SettingsPage;

// Gives you a way to uniquely identify this settings page from all others, 
// guaranteed to be unique per "OnInit" of the mod settings menu.
function int GetPageId();

delegate SaveStateHandler(MCM_API_SettingsPage SettingsPage);

function SetPageTitle(string title);

// By default Save/Cancel buttons are not visible, you can choose to use them.
function SetSaveHandler(delegate<SaveStateHandler> SaveHandler);
function SetCancelHandler(delegate<SaveStateHandler> CancelHandler);

// By default Reset button is not visible, you can choose to use it.
function EnableResetButton(delegate<SaveStateHandler> ResetHandler);

function MCM_API_SettingsGroup AddGroup(name GroupName, string GroupLabel);
function MCM_API_SettingsGroup GetGroup(name GroupName);

// It's done this way because of some UI issues where dropdowns don't behave unless you initialize
// the settings UI widgets from bottom up.
function MCM_API_Label AddLabel(name SettingName, string Label, string Tooltip, 
    optional MCM_API_SettingsGroup Group);
function MCM_API_Button AddButton(name SettingName, string Label, string Tooltip, string ButtonLabel, 
    optional MCM_API_SettingsGroup Group, optional delegate<VoidSettingHandler> SaveHandler, optional delegate<VoidSettingHandler> ChangeHandler);
function MCM_API_Checkbox AddCheckbox(name SettingName, string Label, string Tooltip, bool InitiallyChecked, 
    optional MCM_API_SettingsGroup Group, optional delegate<BoolSettingHandler> SaveHandler, optional delegate<BoolSettingHandler> ChangeHandler);
function MCM_API_Slider AddSlider(name SettingName, string Label, string Tooltip, float SliderMin, float SliderMax, float SliderStep, float InitialValue, 
    optional MCM_API_SettingsGroup Group, optional delegate<FloatSettingHandler> SaveHandler, optional delegate<FloatSettingHandler> SaveHandler);
function MCM_API_Spinner AddSpinner(name SettingName, string Label, string Tooltip, array<string> Options, string Selection, 
    optional MCM_API_SettingsGroup Group, optional delegate<StringSettingHandler> SaveHandler, optional delegate<StringSettingHandler> ChangeHandler);
function MCM_API_Dropdown AddDropdown(name SettingName, string Label, string Tooltip, array<string> Options, string Selection, 
    optional MCM_API_SettingsGroup Group, optional delegate<StringSettingHandler> SaveHandler, optional delegate<StringSettingHandler> ChangeHandler);

// Call to indicate "done making settings". Must call all of your AddGroup and Add#### calls before this.
function ShowSettings();

// Will return None if setting by that name isn't found.
function MCM_API_Setting GetSettingByName(name SettingName);
function MCM_API_Setting GetSettingByIndex(int Index);
function int GetNumberOfSettings();