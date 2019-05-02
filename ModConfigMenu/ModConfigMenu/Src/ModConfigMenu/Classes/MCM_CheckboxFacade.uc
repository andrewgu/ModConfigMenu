class MCM_CheckboxFacade extends Actor implements(MCM_SettingFacade, MCM_API_Setting, MCM_API_Checkbox) config(ModConfigMenu);

var name SettingName;
var string Label;
var string Tooltip;
var bool Editable;

var MCM_SettingGroup ParentGroup;

var bool Checked;

var delegate<BoolSettingHandler> ChangeHandler;
var delegate<BoolSettingHandler> SaveHandler;

var MCM_Checkbox uiInstance;

delegate BoolSettingHandler(MCM_API_Setting _Setting, bool _SettingValue);

simulated function MCM_CheckboxFacade InitCheckboxFacade(name _Name, string _Label, string _Tooltip, bool _Checked, 
    delegate<BoolSettingHandler> _OnChange, delegate<BoolSettingHandler> _OnSave,
    MCM_SettingGroup _ParentGroup)
{
    SettingName = _Name;
    Label = _Label;
    Tooltip = _Tooltip;
    Editable = true;

    ParentGroup = _ParentGroup;

    Checked = _Checked;

    ChangeHandler = _OnChange;
    SaveHandler = _OnSave;

    uiInstance = none;

    return self;
}

// MCM_SettingFacade implementation ====================================================================

simulated function UIMechaListItem InstantiateUI(UIList parent)
{
    uiInstance = Spawn(class'MCM_Checkbox', parent.itemContainer).InitCheckbox(SettingName, self, Label, Tooltip, Checked, ChangeHandler);
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
    if (uiInstance != none)
    {
        SaveHandler(self, uiInstance.GetValue());
    }
    else
    {
        SaveHandler(self, Checked);
    }
}

// MCM_API_Checkbox implementation ====================================================================

function bool GetValue()
{
    return uiInstance != none ? uiInstance.GetValue(): Checked;
}

function SetValue(bool _Checked, bool SuppressEvent)
{
    if (uiInstance != none)
    {
        uiInstance.SetValue(_Checked, SuppressEvent);
    }
    else
    {
        // Degenerate case, should still fire event if changing without visible widget.
        Checked = _Checked;
        if (!SuppressEvent && ChangeHandler != none)
        {
            ChangeHandler(self, Checked);
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
    return eSettingType_Checkbox;
}

function MCM_API_SettingsGroup GetParentGroup()
{
    return ParentGroup;
}