class MCM_Dropdown extends MCM_SettingBase implements(MCM_API_Dropdown) config(ModConfigMenu);

var delegate<StringSettingHandler> ChangeHandler;

var array<string> DropdownOptions;
var int DropdownSelection;
var bool TmpSuppressEvent;

delegate StringSettingHandler(MCM_API_Setting Setting, name _SettingName, string _SettingValue);

simulated function MCM_SettingBase InitSettingsItem(name _Name, eSettingType _Type, optional string _Label = "", optional string _Tooltip = "")
{
    `log("Don't call InitSettingsItem directly in subclass of MCM_SettingBase.");

    return none;
}

// Fancy init process
simulated function MCM_Dropdown InitDropdown(name _SettingName, string _Label, string _Tooltip, array<string> _Options, string _Selection, 
    delegate<StringSettingHandler> _OnChange)
{
    super.InitSettingsItem(_SettingName, eSettingType_Checkbox, _Label, _Tooltip);

    ChangeHandler = _OnChange;

    CloneOptionsList(_Options);
    DropdownSelection = GetSelectionIndex(_Options, _Selection);

    TmpSuppressEvent = true;
    UpdateDataDropdown(_Label, _Options, DropdownSelection, DropdownChangedCallback);
    TmpSuppressEvent = false;

    SetHoverTooltip(_Tooltip);

    return self;
}

// Helpers

function CloneOptionsList(array<string> OptionsList)
{
    local int iter;
    DropdownOptions.Length = 0;
    for (iter = 0; iter < OptionsList.Length; iter++)
    {
        DropdownOptions.AddItem(OptionsList[iter]);
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

function DropdownChangedCallback(UIDropdown DropdownControl)
{
    DropdownSelection = DropdownControl.SelectedItem;

    if (!TmpSuppressEvent)
    {
        ChangeHandler(self, SettingName, DropdownControl.GetSelectedItemText());
    }
}

// MCM_API_Dropdown implementation ===========================================================================

function string GetValue()
{
    return DropdownOptions[DropdownSelection];
}

function SetValue(string Selection, bool SuppressEvent)
{
    local int index;

    index = GetSelectionIndex(DropdownOptions, Selection);
    // If found.
    if (index >= 0)
    {
        DropdownSelection = index;
        TmpSuppressEvent = SuppressEvent;
        Dropdown.SetSelected(index);
        TmpSuppressEvent = false;
    }
}

function SetOptions(array<string> NewOptions, string InitialSelection, bool SuppressEvent)
{
    CloneOptionsList(NewOptions);
    DropdownSelection = GetSelectionIndex(NewOptions, InitialSelection);

    TmpSuppressEvent = SuppressEvent;
    UpdateDataDropdown(GetLabel(), NewOptions, DropdownSelection, DropdownChangedCallback);
    TmpSuppressEvent = false;

    SetHoverTooltip(DisplayTooltip);
}
