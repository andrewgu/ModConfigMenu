class MCM_CustomPageTest extends UIScreenListener config(ModConfigMenuTestHarness);

`include(ModConfigMenu/Src/ModConfigMenuAPI/MCM_API_Includes.uci)

delegate CustomSettingsPageCallback(UIScreen ParentScreen, int PageID);

event OnInit(UIScreen Screen)
{
    if (!(class'MCM_TestConfigStore'.default.ENABLE_TEST_HARNESS))
    {
        `log("MCM Test Harness Disabled.");
        return;
    }

    // Use the macro because it automates the version check based on the API version you're compiling against.
    `MCM_API_Register(Screen, ClientModCallback);
}

function ClientModCallback(MCM_API_Instance ConfigAPI, int GameMode)
{
    if (GameMode == eGameMode_MainMenu)
    {
        ConfigAPI.NewCustomSettingsPage("Custom Page", CustomHandler);
    }
}

function CustomHandler(UIScreen ParentScreen, int PageID)
{
    MCM_CustomPageTestUI(ParentScreen.Movie.Stack.Push(ParentScreen.Spawn(class'MCM_CustomPageTestUI', ParentScreen), ParentScreen.Movie)).InitUI();
}

defaultproperties
{
    ScreenClass = class'MCM_OptionsScreen';
}