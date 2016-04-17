class MCM_TestHarness extends UIScreenListener config(ModConfigMenu);

//`include(ModConfigMenu/Src/ModConfigMenuAPI/MCM_API_Includes.uci)

var config bool ENABLE_TEST_HARNESS;
var config bool P2G2C_SETTING;

var MCM_API APIInst;

event OnInit(UIScreen Screen)
{
    if (!ENABLE_TEST_HARNESS)
    {
        `log("MCM Test Harness Disabled.");
        return;
    }

    `log("MCM Test Harness: Attempt init.");

    APIInst = MCM_API(Screen);
    if (APIInst != None)
    {
        `log("MCM Test Harness: Attempt register.");
        APIInst.RegisterClientMod(0, 2, ClientModCallback);
    }
}

function ClientModCallback(MCM_API_Instance ConfigAPI, int GameMode)
{
    local MCM_API_SettingsPage Page1, Page2;
    local MCM_API_SettingsGroup P1G1, P2G1, P2G2;
    local MCM_API_Checkbox P2G2_C;

    if (GameMode == eGameMode_MainMenu || GameMode == eGameMode_Strategy)
    {
        `log("Is in main menu or strategy menu, attempting to make page.");
        
        Page1 = ConfigAPI.NewSettingsPage("MCM_Test_1");
        Page1.SetPageTitle("Page 1");
        Page1.SetSaveHandler(SaveButtonClicked);
        Page1.SetCancelHandler(RevertButtonClicked);
        Page1.EnableResetButton(ResetButtonClicked);
        P1G1 = Page1.AddGroup('MCM_Test_P1_G1', "General Settings (P1)");
        
        Page2 = ConfigAPI.NewSettingsPage("MCM_Test_2");
        Page2.SetPageTitle("Page 2");
        Page2.SetSaveHandler(SaveButtonClicked);
        Page2.SetCancelHandler(RevertButtonClicked);

        P2G1 = Page2.AddGroup('MCM_Test_P2_G1', "General Settings (P2)");
        P2G2 = Page2.AddGroup('MCM_Test_P2_G2', "Not So General Settings (P2)");

        P1G1.AddCheckbox('P1G1_S1', "P1G1 Setting 1", "Tooltip!", false, CheckboxSaveLogger, CheckboxChangeLogger);
        P1G1.AddCheckbox('P1G1_S2', "P1G1 Setting 2", "Other Tooltip!", true, CheckboxSaveLogger, CheckboxChangeLogger);

        P2G1.AddCheckbox('P2G1_S1', "P2G1 General Setting", "Page 2", false, CheckboxSaveLogger, CheckboxChangeLogger);
        P2G2_C = P2G2.AddCheckbox('P2G2_S2', "P2G2 Specific Setting", "Page 2", P2G2C_SETTING, CheckboxSaveLogger, CheckboxChangeLogger);

        if (GameMode == eGameMode_Strategy)
            P2G2_C.SetEditable(false);

        Page1.ShowSettings();
        Page2.ShowSettings();
    }
}

function SaveButtonClicked(MCM_API_SettingsPage Page)
{
    `log("MCM: Save button clicked on page " $ string(Page.GetPageID()));
    class'MCM_TestHarness'.static.StaticSaveConfig();
}

function RevertButtonClicked(MCM_API_SettingsPage Page)
{
    `log("MCM: Revert button clicked on page " $ string(Page.GetPageID()));
}

function ResetButtonClicked(MCM_API_SettingsPage Page)
{
    `log("MCM: Reset button clicked on page " $ string(Page.GetPageID()));
}

function CheckboxChangeLogger(MCM_API_Setting Setting, name SettingName, bool SettingValue)
{
    `log("MCM Test Changed: " $ string(SettingName) $ " set to " $ (SettingValue ? "true" : "false"));
}

function CheckboxSaveLogger(MCM_API_Setting Setting, name SettingName, bool SettingValue)
{
    `log("MCM Test Saved: " $ string(SettingName) $ " set to " $ (SettingValue ? "true" : "false"));

    if (SettingName == 'P2G2_S2')
    {
        `log("MCM Special setting save");
        P2G2C_SETTING = SettingValue;
        class'MCM_TestHarness'.default.P2G2C_SETTING = SettingValue;
    }
}

defaultproperties
{
    ScreenClass = class'MCM_OptionsScreen';
}