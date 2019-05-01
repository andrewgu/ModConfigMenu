class MCM_Dropdown extends MCM_SettingBase implements(MCM_API_Dropdown) config(ModConfigMenu);

var delegate<MCM_API_SettingsGroup.StringSettingHandler> ChangeHandler;

var MCM_API_Setting ParentFacade;
var array<string> DropdownOptions;
var bool TmpSuppressEvent;

simulated function MCM_SettingBase InitSettingsItem(name _Name, eSettingType _Type, optional string _Label = "", optional string _Tooltip = "")
{
    `log("Don't call InitSettingsItem directly in subclass of MCM_SettingBase.");

    return none;
}

// Fancy init process
simulated function MCM_Dropdown InitDropdown(name _SettingName, MCM_API_Setting _ParentFacade, string _Label, string _Tooltip, array<string> _Options, string _Selection, 
    delegate<MCM_API_SettingsGroup.StringSettingHandler> _OnChange)
{
    super.InitSettingsItem(_SettingName, eSettingType_Checkbox, _Label, _Tooltip);

    ChangeHandler = _OnChange;
    ParentFacade = _ParentFacade;

    DropdownOptions = _Options;

    TmpSuppressEvent = true;
    UpdateDataDropdown(_Label, _Options,  _Options.find(_Selection), DropdownChangedCallback);
	Dropdown.OnMouseEventDelegate = MouseSoundCheck;
	// Need to tweak text boundary limits
	Desc.SetWidth(width - 340);
    TmpSuppressEvent = false;

    SetHoverTooltip(_Tooltip);

    return self;
}

// Helpers

function DropdownChangedCallback(UIDropdown DropdownControl)
{
    if (ChangeHandler != none && !TmpSuppressEvent)
    {
        ChangeHandler(ParentFacade, DropdownControl.GetSelectedItemText());
    }
}

// MCM_API_Dropdown implementation ===========================================================================

function string GetValue()
{
    return Dropdown.GetSelectedItemText();
}

function SetValue(string Selection, bool SuppressEvent)
{
    local int index;

    index = DropdownOptions.find(Selection);
    // If found.
    if (index >= 0)
    {
        TmpSuppressEvent = SuppressEvent;
        Dropdown.SetSelected(index);
        TmpSuppressEvent = false;
    }
}

function SetOptions(array<string> NewOptions, string InitialSelection, bool SuppressEvent)
{
    DropdownOptions = NewOptions;

    TmpSuppressEvent = SuppressEvent;
    UpdateDataDropdown(GetLabel(), NewOptions, NewOptions.find(InitialSelection), DropdownChangedCallback);
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

simulated function MouseSoundCheck(UIPanel Panel, int Cmd)
{
	if(cmd == class'UIUtilities_Input'.const.FXS_L_MOUSE_UP)
	{
		Movie.Pres.PlayUISound(eSUISound_MenuSelect);
	}
}

simulated function UIPanel ProcessMouseEvents(optional delegate<OnMouseEventDelegate> MouseEventDelegate = MouseSoundCheck)
{
	return Super.ProcessMouseEvents(MouseEventDelegate);
}