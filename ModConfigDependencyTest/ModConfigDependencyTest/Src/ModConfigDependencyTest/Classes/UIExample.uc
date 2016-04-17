class UIExample extends UIScreenListener config(MCDT_Settings);

`include(ModConfigDependencyTest/Src/ModConfigMenuAPI/MCM_API_Includes.uci)
`include(ModConfigDependencyTest/Src/ModConfigMenuAPI/MCM_API_CfgHelpers.uci)

var config bool CFG_CLICKED;
var config bool CFG_CHECKBOX;
var config float CFG_SLIDER;
var config string CFG_DROPDOWN;
var config string CFG_SPINNER;

var MCM_API APIInst;

var MCM_API_Label P1Label;
var MCM_API_Button P1Button;
var MCM_API_Checkbox P1Checkbox;
var MCM_API_Slider P2Slider;
var MCM_API_Dropdown P2Dropdown;
var MCM_API_Spinner P2Spinner;

var MCM_API_SettingsPage Page1;

`MCM_CH_VersionBoilerplate(class'MCDT_ConfigSrc',VERSION)

event OnInit(UIScreen Screen)
{
    // Use the macro because it automates the version check based on the API version you're compiling against.
    `MCM_API_Register(Screen, ClientModCallback);
}

simulated function ClientModCallback(MCM_API_Instance ConfigAPI, int GameMode)
{
    local MCM_API_SettingsGroup P1G1, P1G2, P1G3;
    local array<string> Options;

    // Workaround that's needed in order to be able to "save" files.
    LoadInitialValues();

    if (GameMode == eGameMode_MainMenu || GameMode == eGameMode_Strategy)
    {
        `log("Is in main menu or strategy menu, attempting to make page.");
        
        Page1 = ConfigAPI.NewSettingsPage("MCM Example");
        Page1.SetPageTitle("MCM Example");
        Page1.SetSaveHandler(SaveButtonClicked);
        Page1.SetCancelHandler(RevertButtonClicked);
        Page1.EnableResetButton(ResetButtonClicked);
        
        P1G1 = Page1.AddGroup('MCDT1', "General Settings");
        P1G2 = Page1.AddGroup('MCDT2', "Group 1");
        P1G3 = Page1.AddGroup('MCDT3', "Group 2");

        P1Label = P1G1.AddLabel('label', "Label", "Label");
        P1Button = P1G1.AddButton('button', "Button", "Button", "OK", ButtonClickedHandler);
        P1Checkbox = P1G1.AddCheckbox('checkbox', "Checkbox", "Checkbox", CFG_CHECKBOX, CheckboxSaveLogger);

        P2Slider = P1G2.AddSlider('slider', "Slider", "Slider", 0, 200, 20, CFG_SLIDER, SliderSaveLogger);

        Options.Length = 0;
        Options.AddItem("a");
        Options.AddItem("b");
        Options.AddItem("c");
        Options.AddItem("d");
        Options.AddItem("e");
        Options.AddItem("f");
        Options.AddItem("g");

        P2Spinner = P1G3.AddSpinner('spinner', "Spinner", "Spinner", Options, CFG_SPINNER, SpinnerSaveLogger);
        P2Dropdown = P1G3.AddDropdown('dropdown', "Dropdown", "Dropdown", Options, CFG_DROPDOWN, DropdownSaveLogger);

        if (GameMode == eGameMode_Strategy)
            P1Checkbox.SetEditable(false);

        Page1.ShowSettings();
    }
}

`MCM_API_BasicCheckboxSaveHandler(CheckboxSaveLogger, CFG_CHECKBOX)
`MCM_API_BasicSliderSaveHandler(SliderSaveLogger, CFG_SLIDER)
`MCM_API_BasicDropdownSaveHandler(DropdownSaveLogger, CFG_DROPDOWN)
`MCM_API_BasicSpinnerSaveHandler(SpinnerSaveLogger, CFG_SPINNER)

`MCM_API_BasicButtonHandler(ButtonClickedHandler)
{
    CFG_CLICKED = true;
}

simulated function SaveButtonClicked(MCM_API_SettingsPage Page)
{
    `log("MCM: Save button clicked");
    
    `MCM_CH_SaveConfig();
}

simulated function ResetButtonClicked(MCM_API_SettingsPage Page)
{
    `log("MCM: Reset button clicked");

    // Revert all of the settings.
    CFG_CLICKED = false;
    P1Checkbox.SetValue(CFG_CHECKBOX, true);
    P2Slider.SetValue(CFG_SLIDER, true);
    P2Dropdown.SetValue(CFG_DROPDOWN, true);
    P2Spinner.SetValue(CFG_SPINNER, true);
}

simulated function RevertButtonClicked(MCM_API_SettingsPage Page)
{
    // Don't need to do anything since values aren't written until at save-time when you use save handlers.
    `log("MCM: Cancel button clicked");
}

// This shows how to either pull default values from a source config, or to use more user-defined values, gated by a version number mechanism.
simulated function LoadInitialValues()
{
    CFG_CLICKED = false;
    CFG_CHECKBOX = `MCM_CH_GetConfigValue(CFG_CHECKBOX,class'MCDT_ConfigSrc',CHECKBOX);
    CFG_SLIDER = `MCM_CH_GetConfigValue(CFG_SLIDER,class'MCDT_ConfigSrc',SLIDER);
    CFG_DROPDOWN = `MCM_CH_GetConfigValue(CFG_DROPDOWN,class'MCDT_ConfigSrc',DROPDOWN);
    CFG_SPINNER = `MCM_CH_GetConfigValue(CFG_SPINNER,class'MCDT_ConfigSrc',SPINNER);
}

defaultproperties
{
    ScreenClass = class'MCM_OptionsScreen';
}