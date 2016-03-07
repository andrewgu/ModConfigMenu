interface MCM_API_SettingsPage;

// Gives you a way to uniquely identify this settings page from all others, 
// guaranteed to be unique per "OnInit" of the mod settings menu.
function int GetPageId();

delegate SaveStateHandler(MCM_API_SettingsPage SettingsPage);

function SetPageTitle(string title);

// By default Save/Cancel buttons are not visible, you can choose to use them.
function EnableSaveAndCancelButtons(delegate<SaveStateHandler> SaveHandler, delegate<SaveStateHandler> CancelHandler);
// By default Reset button is not visible, you can choose to use it.
function EnableResetToDefaultButton(delegate<SaveStateHandler> Handler);

// It's done this way because of some UI issues where dropdowns don't behave unless you initialize
// the settings UI widgets from bottom up.
function array<MCM_API_Setting> MakeSettings(array<name> SettingNames);
// Will return None if setting by that name isn't found.
function MCM_API_Setting GetSettingByName(name SettingName);
function MCM_API_Setting GetSettingByIndex(int Index);
function int GetNumberOfSettings();