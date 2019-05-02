class MCM_ButtonFacade extends Actor implements(MCM_SettingFacade, MCM_API_Setting, MCM_API_Button) config(ModConfigMenu);

var name SettingName;
var string Label;
var string Tooltip;
var bool Editable;

var MCM_SettingGroup ParentGroup;

var string ButtonLabel;

var delegate<VoidSettingHandler> ClickHandler;

var MCM_Button uiInstance;

delegate VoidSettingHandler(MCM_API_Setting _Setting);

simulated function MCM_ButtonFacade InitButtonFacade(name _Name, string _Label, string _Tooltip, string _ButtonLabel, 
    delegate<VoidSettingHandler> _OnClick, MCM_SettingGroup _ParentGroup)
{
    SettingName = _Name;
    Label = _Label;
    Tooltip = _Tooltip;
    Editable = true;

    ParentGroup = _ParentGroup;

    ButtonLabel = _ButtonLabel;

    ClickHandler = _OnClick;

    uiInstance = none;

    return self;
}

// MCM_SettingFacade implementation ====================================================================

simulated function UIMechaListItem InstantiateUI(UIList parent)
{
    uiInstance = Spawn(class'MCM_Button', parent.itemContainer).InitButton(SettingName, self, Label, Tooltip, ButtonLabel, ClickHandler);
    uiInstance.Show();
    uiInstance.SetEditable(Editable);

    return uiInstance;
}

simulated function AfterParentPageDisplayed()
{
    if (uiInstance != none)
    {
        uiInstance.AfterParentPageDisplayed();
    }
}

function TriggerSaveEvent()
{
    // Button doeesn't have a save event.
}

// MCM_API_Button implementation ====================================================================

function SimulateClick()
{
    ClickHandler(self);
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
    return eSettingType_Button;
}

function MCM_API_SettingsGroup GetParentGroup()
{
    return ParentGroup;
}