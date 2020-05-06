// This is an Unreal Script
class MCM_SettingGroup extends Actor implements(MCM_API_SettingsGroup);

var name GroupName;
var MCM_GroupLabel GroupLabel;
var array<MCM_SettingFacade> Settings;

var MCM_SettingsPanelFacade ParentPanel;

var bool UiInstantiated;

delegate VoidSettingHandler(MCM_API_Setting Setting);
delegate BoolSettingHandler(MCM_API_Setting Setting, bool SettingValue);
delegate FloatSettingHandler(MCM_API_Setting Setting, float SettingValue);
delegate StringSettingHandler(MCM_API_Setting Setting, string SettingValue);

//delegate ListItemHandler(UIMechaListItem item);
delegate ListItemHandler(UIPanel item);

function MCM_SettingGroup InitSettingGroup(name _GroupName, string Label, MCM_SettingsPanelFacade _ParentPanel)
{
    GroupName = _GroupName;
    ParentPanel = _ParentPanel;
    GroupLabel = Spawn(class'MCM_GroupLabel', self).InitGroupLabel(Label);
    UiInstantiated = false;

    return self;
}

// Helpers ==========================================================================

function TriggerSaveEvents()
{
    local int iter;
    for (iter = 0; iter < Settings.Length; iter++)
    {
        Settings[iter].TriggerSaveEvent();
    }
}

function AddSetting(MCM_SettingFacade Instance)
{
    if (UiInstantiated)
    {
        `log("MCM: Error: Cannot add more settings after ShowSettings() has been called.");
    }
    else
    {
        Settings.AddItem(Instance);
    }
}

// This is a signal to actually create the UI items.
function InstantiateItems(delegate<ListItemHandler> handler, UIList Parent)
{
    local int iter;
    local MCM_SettingFacade TmpItem;

    if (UiInstantiated)
        return;

    // now items in reverse order.
    for (iter = Settings.Length-1; iter >= 0; iter--)
    {
        TmpItem = Settings[iter];
        handler(TmpItem.InstantiateUI(Parent));
    }

    // Group header last.
    handler(GroupLabel.InstantiateUI(Parent));

    UiInstantiated = true;
}

simulated function AfterParentPageDisplayed()
{
    local int iter;
    local MCM_SettingFacade TmpItem;

    if (UiInstantiated)
    {
        for (iter = 0; iter < Settings.Length; iter++)
        {
            TmpItem = Settings[iter];
            TmpItem.AfterParentPageDisplayed();
        }
    }
}

// MCM_API_SettingsGroup implementation =============================================

// For reference purposes, not display purposes.
function name GetName()
{
    return GroupName;
}

// For display purposes, not reference purposes.
function string GetLabel()
{
    return GroupLabel.GetGroupLabel();
}

function SetLabel(string Label)
{
    GroupLabel.SetGroupLabel(Label);
}

function MCM_API_SettingsPage GetParentPage()
{
    return ParentPanel;
}

// Will return None if setting by that name isn't found.
function MCM_API_Setting GetSettingByName(name _SettingName)
{
    local int iter;
    local MCM_SettingFacade Tmp;

    for (iter = 0; iter < Settings.Length; iter++)
    {
        Tmp = Settings[iter];
        if (Tmp.GetName() == _SettingName)
        {
            return Tmp;
        }
    }

    return none;
}

function MCM_API_Setting GetSettingByIndex(int Index)
{
    if (Index >= 0 && Index < Settings.Length)
    {
        return Settings[Index];
    }
    else
    {
        return none;
    }
}

function int GetNumberOfSettings()
{
    return Settings.Length;
}

// The complicated stuff

function MCM_API_Label AddLabel(name SettingName, string Label, string Tooltip)
{
    local MCM_LabelFacade Instance;

    Instance = Spawn(class'MCM_LabelFacade', self).InitLabelFacade(SettingName, Label, Tooltip, self);
    AddSetting(Instance);

    return Instance;
}

function MCM_API_Button AddButton(name SettingName, string Label, string Tooltip, string ButtonLabel, 
    optional delegate<VoidSettingHandler> ClickHandler)
{
    local MCM_ButtonFacade Instance;

    Instance = Spawn(class'MCM_ButtonFacade', self).InitButtonFacade(SettingName, Label, Tooltip, ButtonLabel, ClickHandler, self);
    AddSetting(Instance);

    return Instance;
}

function MCM_API_Checkbox AddCheckbox(name SettingName, string Label, string Tooltip, bool InitiallyChecked, 
    optional delegate<BoolSettingHandler> SaveHandler, 
    optional delegate<BoolSettingHandler> ChangeHandler)
{
    local MCM_CheckboxFacade Instance;

    Instance = Spawn(class'MCM_CheckboxFacade', self).InitCheckboxFacade(SettingName, Label, Tooltip, InitiallyChecked, ChangeHandler, SaveHandler, self);
    AddSetting(Instance);

    return Instance;
}

function MCM_API_Slider AddSlider(name SettingName, string Label, string Tooltip, float SliderMin, float SliderMax, float SliderStep, float InitialValue, 
    optional delegate<FloatSettingHandler> SaveHandler, 
    optional delegate<FloatSettingHandler> ChangeHandler)
{
    local MCM_SliderFacade Instance;

    Instance = Spawn(class'MCM_SliderFacade', self).InitSliderFacade(SettingName, Label, Tooltip,
        SliderMin, SliderMax, SliderStep, InitialValue, ChangeHandler, SaveHandler, self);
    AddSetting(Instance);

    return Instance;
}

function MCM_API_Spinner AddSpinner(name SettingName, string Label, string Tooltip, array<string> Options, string Selection, 
    optional delegate<StringSettingHandler> SaveHandler, 
    optional delegate<StringSettingHandler> ChangeHandler)
{
    local MCM_SpinnerFacade Instance;

    Instance = Spawn(class'MCM_SpinnerFacade', self).InitSpinnerFacade(SettingName, Label, Tooltip,
        Options, Selection, ChangeHandler, SaveHandler, self);
    AddSetting(Instance);

    return Instance;
}

function MCM_API_Dropdown AddDropdown(name SettingName, string Label, string Tooltip, array<string> Options, string Selection, 
    optional delegate<StringSettingHandler> SaveHandler, 
    optional delegate<StringSettingHandler> ChangeHandler)
{
    local MCM_DropdownFacade Instance;

    Instance = Spawn(class'MCM_DropdownFacade', self).InitDropdownFacade(SettingName, Label, Tooltip,
        Options, Selection, ChangeHandler, SaveHandler, self);
    AddSetting(Instance);

    return Instance;
}