class MCM_LabelFacade extends Actor implements(MCM_SettingFacade, MCM_API_Setting, MCM_API_Label) config(ModConfigMenu);

var name SettingName;
var string Label;
var string Tooltip;
var bool Editable;

var MCM_Label uiInstance;

simulated function MCM_LabelFacade InitLabelFacade(name _Name, string _Label, string _Tooltip)
{
    SettingName = _Name;
    Label = _Label;
    Tooltip = _Tooltip;
    Editable = false;

    uiInstance = none;

    return self;
}

// MCM_SettingFacade implementation ====================================================================

simulated function UIMechaListItem InstantiateUI(UIList parent)
{
    uiInstance = Spawn(class'MCM_Label', parent.itemContainer).InitLabel(SettingName, self, Label, Tooltip);
    uiInstance.Show();
    uiInstance.EnableNavigation();
    uiInstance.SetEditable(Editable);

    return uiInstance;
}

function TriggerSaveEvent()
{
    // Label doeesn't have a save event.
}

// MCM_API_Label implementation ====================================================================

// No label methods.

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
    return eSettingType_Label;
}
