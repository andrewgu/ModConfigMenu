class MCM_TestHarness extends UIScreenListener config(ModConfigMenu);

//`include(ModConfigMenu/Src/ModConfigMenuAPI/MCM_API_Includes.uci)

var config bool ENABLE_TEST_HARNESS;

var config int DEFAULT_VERSION;
var config bool DEFAULT_CLICKED;
var config bool DEFAULT_CHECKBOX;
var config float DEFAULT_SLIDER;
var config string DEFAULT_DROPDOWN;
var config string DEFAULT_SPINNER;

var MCM_API APIInst;

var MCM_API_Label P1Label;
var MCM_API_Button P1Button;
var MCM_API_Checkbox P1Checkbox;
var MCM_API_Slider P2Slider;
var MCM_API_Dropdown P2Dropdown;
var MCM_API_Spinner P2Spinner;

var MCM_API_SettingsPage Page1;
var MCM_API_SettingsPage Page2;

event OnInit(UIScreen Screen)
{
    if (!ENABLE_TEST_HARNESS)
    {
        `log("MCM Test Harness Disabled.");
        return;
    }

    // Need to "install" the config.
    if (class'MCM_TestConfigStore'.default.VERSION < DEFAULT_VERSION)
    {
        class'MCM_TestConfigStore'.default.VERSION = DEFAULT_VERSION;
        class'MCM_TestConfigStore'.default.CLICKED = false;
        class'MCM_TestConfigStore'.default.CHECKBOX = DEFAULT_CHECKBOX;
        class'MCM_TestConfigStore'.default.SLIDER = DEFAULT_SLIDER;
        class'MCM_TestConfigStore'.default.DROPDOWN = DEFAULT_DROPDOWN;
        class'MCM_TestConfigStore'.default.SPINNER = DEFAULT_SPINNER;
        class'MCM_TestConfigStore'.static.StaticSaveConfig();
    }

    APIInst = MCM_API(Screen);
    if (APIInst != None)
    {
        `log("MCM Test Harness: Attempt register.");
        APIInst.RegisterClientMod(0, 2, ClientModCallback);
    }
}

function ClientModCallback(MCM_API_Instance ConfigAPI, int GameMode)
{
    local MCM_API_SettingsGroup P1G1, P2G1, P2G2;
    local array<string> Options;

    if (GameMode == eGameMode_MainMenu || GameMode == eGameMode_Strategy)
    {
        `log("Is in main menu or strategy menu, attempting to make page.");
        
        Page1 = ConfigAPI.NewSettingsPage("MCM_Test_1");
        Page1.SetPageTitle("Page 1");
        Page1.SetSaveHandler(SaveButtonClicked);
        Page1.SetCancelHandler(RevertButtonClicked);
        Page1.EnableResetButton(ResetButtonClicked);
        
        P1G1 = Page1.AddGroup('MCM_Test_P1_G1', "General Settings");
        
        Page2 = ConfigAPI.NewSettingsPage("MCM_Test_2");
        Page2.SetPageTitle("Page 2");
        Page2.SetSaveHandler(SaveButtonClicked);
        Page2.SetCancelHandler(RevertButtonClicked);

        P2G1 = Page2.AddGroup('MCM_Test_P2_G1', "Group 1");
        P2G2 = Page2.AddGroup('MCM_Test_P2_G2', "Group 2");

        P1Label = P1G1.AddLabel('label', "Label", "Label");

        DEFAULT_CLICKED = false;

        P1Button = P1G1.AddButton('button', "Button", "Button", "OK", ButtonClickedHandler);
        P1Checkbox = P1G1.AddCheckbox('checkbox', "Checkbox", "Checkbox", class'MCM_TestConfigStore'.default.CHECKBOX, CheckboxSaveLogger);

        P2Slider = P2G1.AddSlider('slider', "Slider", "Slider", 0, 200, 20, class'MCM_TestConfigStore'.default.SLIDER, SliderSaveLogger);

        Options.Length = 0;
        Options.AddItem("a");
        Options.AddItem("b");
        Options.AddItem("c");
        Options.AddItem("d");
        Options.AddItem("e");
        Options.AddItem("f");
        Options.AddItem("g");

        P2Spinner = P2G2.AddSpinner('spinner', "Spinner", "Spinner", Options, class'MCM_TestConfigStore'.default.SPINNER, SpinnerSaveLogger);
        P2Dropdown = P2G2.AddDropdown('dropdown', "Dropdown", "Dropdown", Options, class'MCM_TestConfigStore'.default.DROPDOWN, DropdownSaveLogger);

        if (GameMode == eGameMode_Strategy)
            P1Checkbox.SetEditable(false);

        Page1.ShowSettings();
        Page2.ShowSettings();
    }
}

function SaveButtonClicked(MCM_API_SettingsPage Page)
{
    `log("MCM: Save button clicked on page " $ string(Page.GetPageID()));
    
    if (Page == Page1)
    {
        class'MCM_TestConfigStore'.default.CLICKED = DEFAULT_CLICKED;
        class'MCM_TestConfigStore'.default.CHECKBOX = DEFAULT_CHECKBOX;
        
        class'MCM_TestConfigStore'.static.StaticSaveConfig();
    }
    else if (Page == Page2)
    {
        class'MCM_TestConfigStore'.default.SLIDER = DEFAULT_SLIDER;
        class'MCM_TestConfigStore'.default.DROPDOWN = DEFAULT_DROPDOWN;
        class'MCM_TestConfigStore'.default.SPINNER = DEFAULT_SPINNER;

        class'MCM_TestConfigStore'.static.StaticSaveConfig();
    }
}

function RevertButtonClicked(MCM_API_SettingsPage Page)
{
    `log("MCM: Revert button clicked on page " $ string(Page.GetPageID()));

    if (Page == Page1)
    {
        DEFAULT_CLICKED = false;
        DEFAULT_CHECKBOX = class'MCM_TestConfigStore'.default.CHECKBOX;
    }
    else if (Page == Page2)
    {
        DEFAULT_SLIDER = class'MCM_TestConfigStore'.default.SLIDER;
        DEFAULT_DROPDOWN = class'MCM_TestConfigStore'.default.DROPDOWN;
        DEFAULT_SPINNER = class'MCM_TestConfigStore'.default.SPINNER;
    }
}

function ResetButtonClicked(MCM_API_SettingsPage Page)
{
    `log("MCM: Reset button clicked on page " $ string(Page.GetPageID()));

    if (Page == Page1)
    {
        DEFAULT_CLICKED = false;
        P1Checkbox.SetValue(class'MCM_TestConfigStore'.default.CHECKBOX, true);
    }
    else if (Page == Page2)
    {
        P2Slider.SetValue(class'MCM_TestConfigStore'.default.SLIDER, true);
        P2Dropdown.SetValue(class'MCM_TestConfigStore'.default.DROPDOWN, true);
        P2Spinner.SetValue(class'MCM_TestConfigStore'.default.SPINNER, true);
    }
}


function ButtonClickedHandler(MCM_API_Setting Setting, name SettingName)
{
    DEFAULT_CLICKED = true;
}

function CheckboxSaveLogger(MCM_API_Setting Setting, name SettingName, bool SettingValue)
{
    `log("MCM Test Saved: " $ string(SettingName) $ " set to " $ (SettingValue ? "true" : "false"));
    DEFAULT_CHECKBOX = SettingValue;
}

function SliderSaveLogger(MCM_API_Setting Setting, name SettingName, float SettingValue)
{
    `log("MCM Test Saved: " $ string(SettingName) $ " set to " $ string(SettingValue));
    DEFAULT_SLIDER = SettingValue;
}

function DropdownSaveLogger(MCM_API_Setting Setting, name SettingName, string SettingValue)
{
    `log("MCM Test Saved: " $ string(SettingName) $ " set to " $ SettingValue);
    DEFAULT_DROPDOWN = SettingValue;
}

function SpinnerSaveLogger(MCM_API_Setting Setting, name SettingName, string SettingValue)
{
    `log("MCM Test Saved: " $ string(SettingName) $ " set to " $ SettingValue);
    DEFAULT_SPINNER = SettingValue;
}

defaultproperties
{
    ScreenClass = class'MCM_OptionsScreen';
}