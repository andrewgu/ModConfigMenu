class MCM_Dropdown extends MCM_SettingBase implements(MCM_API_Dropdown) config(ModConfigMenu);

var delegate<StringSettingHandler> ChangeHandler;

var MCM_API_Setting ParentFacade;
var array<string> DropdownOptions;
var int DropdownSelection;
var bool TmpSuppressEvent;

delegate StringSettingHandler(MCM_API_Setting Setting, string _SettingValue);

simulated function MCM_SettingBase InitSettingsItem(name _Name, eSettingType _Type, optional string _Label = "", optional string _Tooltip = "")
{
    `log("Don't call InitSettingsItem directly in subclass of MCM_SettingBase.");

    return none;
}

// Fancy init process
simulated function MCM_Dropdown InitDropdown(name _SettingName, MCM_API_Setting _ParentFacade, string _Label, string _Tooltip, array<string> _Options, string _Selection, 
    delegate<StringSettingHandler> _OnChange)
{
    super.InitSettingsItem(_SettingName, eSettingType_Checkbox, _Label, _Tooltip);

    ChangeHandler = _OnChange;
    ParentFacade = _ParentFacade;

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

    if (ChangeHandler != none && !TmpSuppressEvent)
    {
        ChangeHandler(ParentFacade, DropdownControl.GetSelectedItemText());
    }
}

// Need to tweak text boundary limits

simulated function UIMechaListItem UpdateDataDropdown(string _Desc, 
                                       array<String> Data, 
                                       int SelectedIndex,
                                       delegate<OnDropdownSelectionChangedCallback> _OnSelectionChange,
                                       optional delegate<OnClickDelegate> _OnClickDelegate = none)
{
    local int i;

    SetWidgetType(EUILineItemType_Dropdown);
    if(Dropdown != none)
    {
        Dropdown.Remove();
        Dropdown = none;
    }
    
    if( Dropdown == none )
    {
        Dropdown = Spawn(class'UIDropdown', self);
        Dropdown.bIsNavigable = false;
        Dropdown.InitDropdown('DropdownMC');
        Dropdown.SetPosition(width - 308, 24);
    }
    
    Dropdown.Clear();

    for(i = 0; i < Data.Length; ++i)
    {
        Dropdown.AddItem(Data[i]);
    }

    Dropdown.SetLabel("");
    Dropdown.SetSelected(SelectedIndex);
    Dropdown.Show();
    
    //Desc.SetWidth(width - 308);
    Desc.SetWidth(width - 340);
    Desc.SetHTMLText(_Desc);
    Desc.Show();

    OnClickDelegate = _OnClickDelegate;
    Dropdown.OnItemSelectedDelegate = _OnSelectionChange;
    return self;
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

// Have to override to disable the underlying control.
simulated function SetEditable(bool IsEditable)
{
    super.SetEditable(IsEditable);
    if (IsEditable)
    {
        Dropdown.Show();
    }
    else
    {
        Dropdown.Hide();
    }
}