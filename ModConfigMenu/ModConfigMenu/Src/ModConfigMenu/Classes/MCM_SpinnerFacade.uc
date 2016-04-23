class MCM_SpinnerFacade extends Actor implements(MCM_SettingFacade, MCM_API_Setting, MCM_API_Spinner) config(ModConfigMenu);

var name SettingName;
var string Label;
var string Tooltip;
var bool Editable;

var array<string> Options;
var int SelectionIndex;

var MCM_SettingGroup ParentGroup;

var delegate<StringSettingHandler> ChangeHandler;
var delegate<StringSettingHandler> SaveHandler;

var MCM_Spinner uiInstance;

delegate StringSettingHandler(MCM_API_Setting Setting, string _SettingValue);

simulated function MCM_SpinnerFacade InitSpinnerFacade(name _Name, string _Label, string _Tooltip, 
    array<string> _Options, string _Selection,
    delegate<StringSettingHandler> _OnChange, delegate<StringSettingHandler> _OnSave,
    MCM_SettingGroup _ParentGroup)
{
    SettingName = _Name;
    Label = _Label;
    Tooltip = _Tooltip;
    Editable = true;

    ParentGroup = _ParentGroup;

    CloneOptionsList(_Options);
    SelectionIndex = GetSelectionIndex(_Options, _Selection); 

    ChangeHandler = _OnChange;
    SaveHandler = _OnSave;

    uiInstance = none;

    return self;
}

// Helpers

function CloneOptionsList(array<string> OptionsList)
{
    local int iter;
    Options.Length = 0;
    for (iter = 0; iter < OptionsList.Length; iter++)
    {
        Options.AddItem(OptionsList[iter]);
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

// MCM_SettingFacade implementation =================================================================
function UIMechaListItem InstantiateUI(UIList Parent)
{
    uiInstance = Spawn(class'MCM_Spinner', parent.itemContainer).InitSpinner(SettingName, self, Label, Tooltip, Options, Options[SelectionIndex], ChangeHandler);
    uiInstance.Show();
    uiInstance.EnableNavigation();
    uiInstance.SetEditable(Editable);

    return uiInstance;
}

function TriggerSaveEvent()
{
    if (uiInstance != none)
    {
        SaveHandler(self, uiInstance.GetValue());
    }
    else
    {
        SaveHandler(self, Options[SelectionIndex]);
    }
}

// MCM_API_Spinner implementation =================================================================

function string GetValue()
{
    return uiInstance != none ? uiInstance.GetValue() : Options[SelectionIndex];
}

function SetValue(string Selection, bool SuppressEvent)
{
    local int TmpIndex;

    if (uiInstance != none)
    {
        uiInstance.SetValue(Selection, SuppressEvent);
    }
    else
    {
        TmpIndex = GetSelectionIndex(Options, Selection); 
        
        if (!SuppressEvent && TmpIndex >= 0 && TmpIndex != SelectionIndex)
        {
            ChangeHandler(self, Selection);
        }

        if (TmpIndex >= 0)
        {
            SelectionIndex = TmpIndex;
        }
    }
}

function SetOptions(array<string> NewOptions, string InitialSelection, bool SuppressEvent)
{
    local int TmpIndex;

    if (uiInstance != none)
    {
        uiInstance.SetOptions(NewOptions, InitialSelection, SuppressEvent);
    }
    else
    {
        CloneOptionsList(NewOptions);
        //SelectionIndex = GetSelectionIndex(_Options, _Selection); 
        TmpIndex = GetSelectionIndex(NewOptions, InitialSelection); 
        
        if (!SuppressEvent && TmpIndex >= 0 && TmpIndex != SelectionIndex)
        {
            ChangeHandler(self, Options[SelectionIndex]);
        }

        if (TmpIndex >= 0)
        {
            SelectionIndex = TmpIndex;
        }
    }
}

// MCM_API_Setting implementation ====================================================================

// Name is used for ID purposes, not for UI.
function name GetName()
{
    return uiInstance != none ? uiInstance.GetName() : SettingName;
}

// Label is used for UI purposes, not for ID.
function SetLabel(string NewLabel)
{
    if (uiInstance != none)
    {
        uiInstance.SetLabel(NewLabel);
    }
    else
    {
        Label = NewLabel;
    }
}

function string GetLabel()
{
    return uiInstance != none ? uiInstance.GetLabel() : Label;
}

// When you mouse-over the setting.
function SetHoverTooltip(string _Tooltip)
{
    if (uiInstance != none)
    {
        uiInstance.SetHoverTooltip(_Tooltip);
    }
    else
    {
        Tooltip = _Tooltip;
    }
}

function string GetHoverTooltip()
{
    return uiInstance != none ? uiInstance.GetHoverTooltip() : Tooltip;
}

// Lets you show an option but disable it because it shouldn't be configurable.
// For example, if you don't want to allow tweaking during a mission.
function SetEditable(bool IsEditable)
{
    if (uiInstance != none)
    {
        uiInstance.SetEditable(IsEditable);
    }
    else
    {
        Editable = IsEditable;
    }
}

// Retrieves underlying setting type. Defined as an int to make setting types more extensible to support
// future "extension types".
function int GetSettingType()
{
    return eSettingType_Dropdown;
}

function MCM_API_SettingsGroup GetParentGroup()
{
    return ParentGroup;
}