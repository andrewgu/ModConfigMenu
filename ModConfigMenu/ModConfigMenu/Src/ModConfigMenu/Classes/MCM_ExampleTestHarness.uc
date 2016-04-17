class MCM_ExampleTestHarness extends UIScreenListener config(ModConfigMenu);

/*`include(ModConfigMenu/Src/ModConfigMenuAPI/MCM_API_Includes.uci);

// Doesn't have to be config vars but this would work.
config var bool CheckboxVar;
config var float SliderVar;
config var string SpinnerVar;
config var string DropdownVar;

function ClientModCallback(MCM_API_Instance ConfigAPI, int GameMode)
{
    local MCM_API_SettingsPage Page;
    local array<string> ListOfStrings;
    
    ListOfStrings.AddItem("a");
    ListOfStrings.AddItem("bcd");
    ListOfStrings.AddItem("e");
    ListOfStrings.AddItem("fgh");
    ListOfStrings.AddItem("ij");
    ListOfStrings.AddItem("klm");

    if (GameMode == eGameMode_MainMenu || GameMode == eGameMode_Strategy)
    {
        Page = ConfigAPI.NewSettingsPage("Example");

        Page.SetSaveHandler(SaveHandler);
        Page.SetCancelHandler(CancelHandler);
        Page.EnableResetButton(ResetHandler);
        
        `BasicLabel(Page, ThrowawayLabelName, "This is a label.", "Tooltip")
        `BasicButton(Page, ThrowawayButtonName, "This is a button.", "Tooltip", "Click Me")
        `BasicCheckbox(Page, CheckboxVar, "This is a checkbox.", "Tooltip")
        `BasicSlider(Page, SliderVar, "This is a slider.", "Tooltip", 0, 100, 10)
        `BasicSpinner(Page, SpinnerVar, "This is a spinner.", "Tooltip", ListOfStrings)
        `BasicDropdown(Page, DropdownVar, "This is a dropdown.", "Tooltip", ListOfStrings)

        Page.ShowSettings();
    }
}

`BasicButtonHandler(ThrowawayButtonName)
{
    `log("MCM: Button setting clicked.");
}

`BasicCheckboxSaveHandler(CheckboxVar)
`BasicSliderSaveHandler(SliderVar)
`BasicSpinnerSaveHandler(SpinnerVar)
`BasicDropdownSaveHandler(DropdownVar)

function SaveHandler(MCM_API_SettingsPage Page)
{
    `log("MCM: Save button clicked on page " $ string(Page.GetPageID()));
    SaveConfig();
}

function CancelHandler(MCM_API_SettingsPage Page)
{
    `log("MCM: Revert button clicked on page " $ string(Page.GetPageID()));
}

function ResetHandler(MCM_API_SettingsPage Page)
{
    `log("MCM: Reset button clicked on page " $ string(Page.GetPageID()));
}

`MCM_API_Boilerplate(ClientModCallback);*/