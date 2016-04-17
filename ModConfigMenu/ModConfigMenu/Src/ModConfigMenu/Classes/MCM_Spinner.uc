class MCM_Spinner extends MCM_SettingBase implements(MCM_API_Spinner) config(ModConfigMenu);

var delegate<StringSettingHandler> ChangeHandler;

var MCM_API_Setting ParentFacade;
var array<string> SpinnerOptions;
var int SpinnerSelection;
var bool TmpSuppressEvent;

delegate StringSettingHandler(MCM_API_Setting Setting, name _SettingName, string _SettingValue);

simulated function MCM_SettingBase InitSettingsItem(name _Name, eSettingType _Type, optional string _Label = "", optional string _Tooltip = "")
{
    `log("Don't call InitSettingsItem directly in subclass of MCM_SettingBase.");

    return none;
}

// Fancy init process
simulated function MCM_Spinner InitSpinner(name _SettingName, MCM_API_Setting _ParentFacade, string _Label, string _Tooltip, array<string> _Options, string _Selection, 
    delegate<StringSettingHandler> _OnChange)
{
    super.InitSettingsItem(_SettingName, eSettingType_Checkbox, _Label, _Tooltip);

    ChangeHandler = _OnChange;
    ParentFacade = _ParentFacade;

    CloneOptionsList(_Options);
    SpinnerSelection = GetSelectionIndex(_Options, _Selection);

    TmpSuppressEvent = true;
    UpdateDataSpinner(_Label, "", SpinnerChangedCallback);
    Spinner.SetValue(_Selection);
    TmpSuppressEvent = false;

    SetHoverTooltip(_Tooltip);

    return self;
}

// Helpers

function CloneOptionsList(array<string> OptionsList)
{
    local int iter;
    SpinnerOptions.Length = 0;
    for (iter = 0; iter < OptionsList.Length; iter++)
    {
        SpinnerOptions.AddItem(OptionsList[iter]);
    }
}

function int GetSelectionIndex(array<string> OptionsList, string SelectedOption)
{
    local int iter;
    for (iter = 0; iter < OptionsList.Length; iter++)
    {
        if (SelectedOption == OptionsList[iter])
            return iter;
    }

    return -1;
}

function SpinnerChangedCallback(UIListItemSpinner SpinnerControl, int Direction)
{
    SpinnerSelection += Direction;
    // Clamp index.
    if (SpinnerSelection >= SpinnerOptions.Length)
        SpinnerSelection = SpinnerOptions.Length - 1;
    if (SpinnerSelection < 0)
        SpinnerSelection = 0;

    if (!TmpSuppressEvent)
    {
        ChangeHandler(ParentFacade, SettingName, GetValue());
    }
}

// MCM_API_Spinner implementation ===========================================================================

function string GetValue()
{
    return SpinnerOptions[SpinnerSelection];
}

function SetValue(string Selection, bool SuppressEvent)
{
    local int index;

    index = GetSelectionIndex(SpinnerOptions, Selection);
    // If found.
    if (index >= 0)
    {
        SpinnerSelection = index;
        TmpSuppressEvent = SuppressEvent;
        Spinner.SetValue(Selection);

        // SetValue doesn't trigger the event so we manually trigger it if needed.
        if (!TmpSuppressEvent)
        {
            ChangeHandler(ParentFacade, SettingName, GetValue());
        }

        TmpSuppressEvent = false;
    }
}

function SetOptions(array<string> NewOptions, string InitialSelection, bool SuppressEvent)
{
    CloneOptionsList(NewOptions);
    SpinnerSelection = GetSelectionIndex(NewOptions, InitialSelection);

    TmpSuppressEvent = SuppressEvent;
    Spinner.SetValue(InitialSelection);

    // SetValue doesn't trigger the event so we manually trigger it if needed.
    if (!TmpSuppressEvent)
    {
        ChangeHandler(ParentFacade, SettingName, GetValue());
    }

    TmpSuppressEvent = false;

    SetHoverTooltip(DisplayTooltip);
}
