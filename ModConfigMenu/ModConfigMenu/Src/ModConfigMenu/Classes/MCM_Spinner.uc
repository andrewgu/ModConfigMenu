class MCM_Spinner extends MCM_SettingBase implements(MCM_API_Spinner) config(ModConfigMenu);

var delegate<MCM_API_SettingsGroup.StringSettingHandler> ChangeHandler;

var MCM_API_Setting ParentFacade;
var array<string> SpinnerOptions;
var int SpinnerSelection;
var bool TmpSuppressEvent;

simulated function MCM_SettingBase InitSettingsItem(name _Name, eSettingType _Type, optional string _Label = "", optional string _Tooltip = "")
{
    `log("Don't call InitSettingsItem directly in subclass of MCM_SettingBase.");

    return none;
}

// Fancy init process
simulated function MCM_Spinner InitSpinner(name _SettingName, MCM_API_Setting _ParentFacade, string _Label, string _Tooltip, out array<string> _Options, string _Selection, 
    delegate<MCM_API_SettingsGroup.StringSettingHandler> _OnChange)
{
    super.InitSettingsItem(_SettingName, eSettingType_Checkbox, _Label, _Tooltip);
	Spinner.Remove();
	Spinner = Spawn(class'MCM_UIListItemSpinner', self);
	Spinner.bAnimateOnInit = false;
	Spinner.bIsNavigable = false;
	Spinner.MCName = 'SpinnerMC';
	Spinner.InitSpinner(,, OnSpinnerChangeDelegate);
	Spinner.Navigator.HorizontalNavigation = true;
	Spinner.SetX(width - 330);
	Spinner.SetValueWidth(250, true);

    ChangeHandler = _OnChange;
    ParentFacade = _ParentFacade;

    SpinnerOptions = _Options;
    SpinnerSelection = _Options.find(_Selection);

    TmpSuppressEvent = true;
    UpdateDataSpinner(_Label, "", SpinnerChangedCallback);
    Spinner.SetValue(_Selection);
    TmpSuppressEvent = false;

    SetHoverTooltip(_Tooltip);

    return self;
}

// Helpers

function SpinnerChangedCallback(UIListItemSpinner SpinnerControl, int Direction)
{
    SpinnerSelection += Direction;
    // Clamp index.
    if (SpinnerSelection >= SpinnerOptions.Length)
        SpinnerSelection = SpinnerOptions.Length - 1;
    if (SpinnerSelection < 0)
        SpinnerSelection = 0;

    Spinner.SetValue(GetValue());

    if (ChangeHandler != none && !TmpSuppressEvent)
    {
        ChangeHandler(ParentFacade, GetValue());
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

    index = SpinnerOptions.find(Selection);
    // If found.
    if (index >= 0)
    {
        SpinnerSelection = index;
        TmpSuppressEvent = SuppressEvent;
        Spinner.SetValue(Selection);

        // SetValue doesn't trigger the event so we manually trigger it if needed.
        if (ChangeHandler != none && !TmpSuppressEvent)
        {
            ChangeHandler(ParentFacade, GetValue());
        }

        TmpSuppressEvent = false;
    }
}

function SetOptions(out array<string> NewOptions, string InitialSelection, bool SuppressEvent)
{
    SpinnerOptions = NewOptions;
    SpinnerSelection = NewOptions.find(InitialSelection);

    TmpSuppressEvent = SuppressEvent;
    Spinner.SetValue(InitialSelection);

    // SetValue doesn't trigger the event so we manually trigger it if needed.
    if (ChangeHandler != none && !TmpSuppressEvent)
    {
        ChangeHandler(ParentFacade, GetValue());
    }

    TmpSuppressEvent = false;

    SetHoverTooltip(DisplayTooltip);
}

// Have to override to disable the underlying control.
simulated function SetEditable(bool IsEditable)
{
    super.SetEditable(IsEditable);

    if (IsEditable)
    {
        Spinner.Show();
    }
    else
    {
        Spinner.Hide();
    }
}

defaultproperties
{
	NavSound = "Play_MenuSelect"
}