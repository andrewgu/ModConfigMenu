class MCM_SettingItem extends Object;


/*class MCM_SettingItem extends UIMechaListItem implements(MCM_API_Setting) config(ModConfigMenu);

var name SettingName;
var int SettingType;
var delegate<SettingChangedHandler> ChangedHandler;

var float SliderMin;
var float SliderMax;
var float SliderValue;

var array<string> SpinnerOptions;
var int SpinnerIndex;

var array<string> DropdownOptions;
var int DropdownIndex;

var bool TmpSuppressEvent;

delegate SettingChangedHandler(MCM_API_Setting Setting);

// MCM_API_Setting implementation ===========================================================

function int GetSettingType()
{
	return SettingType;
}

// Force different init pattern.
simulated function UIMechaListItem InitListItem()
{
	`log("Don't use this.");
	// Intentionally make this break stuff.
	return none;
}

simulated function MCM_SettingItem InitSettingsItem(name _SettingName)
{
	super.InitListItem();

	SettingName = _SettingName;
	//ChangedHandler = Handler;
	SettingType = eSettingType_Unknown;

	SliderMin = 0;
	SliderMax = 1;
	SliderValue = 1;

	return self;
}

function name GetName()
{
	return SettingName;
}

function InitAsButton(string Label, string ButtonLabel, delegate<SettingChangedHandler> ChangeHandler)
{
	ChangedHandler = ChangeHandler;
	UpdateDataButton(Label, ButtonLabel, ButtonClickedCallback);
	SettingType = eSettingType_Button;
}

function InitAsLabel(string Label)
{
	UpdateDataDescription(Label);
	SettingType = eSettingType_Label;
}

function InitAsCheckbox(string Label, bool InitialChecked, delegate<SettingChangedHandler> ChangeHandler)
{
	ChangedHandler = ChangeHandler;
	UpdateDataCheckbox(Label, "", InitialChecked, CheckboxChangedCallback);
	SettingType = eSettingType_Checkbox;
}

function InitAsSlider(string Label, float min, float max, float step, float InitialValue, delegate<SettingChangedHandler> ChangeHandler)
{
	local float position;

	ChangedHandler = ChangeHandler;

	SliderMin = min;
	SliderMax = max;
	SliderValue = InitialValue;

	// Map to [1,100] range
	position = (InitialValue - SliderMin)/(SliderMax - SliderMin) * 99.0 + 1.0;

	UpdateDataSlider(Label, "", int(position + 0.5), none, SliderChangedCallback);
	
	// So that there's no early signal when setting position with higher precision.
	TmpSuppressEvent = true;
	Slider.SetPercent(position);
	Slider.SetStepSize(step);
	TmpSuppressEvent = false;

	SettingType = eSettingType_Slider;
}

function InitAsSpinner(string Label, array<string> Options, string InitialOption, delegate<SettingChangedHandler> ChangeHandler)
{
	local string OptionIter;

	ChangedHandler = ChangeHandler;

	SpinnerOptions.Length = 0;
	foreach Options(OptionIter)
		SpinnerOptions.AddItem(OptionIter);
	
	SpinnerIndex = Options.Find(InitialOption);

	TmpSuppressEvent = true;
	UpdateDataSpinner(Label, InitialOption, SpinnerChangedCallback);
	TmpSuppressEvent = false;

	SettingType = eSettingType_Spinner;
}

function InitAsDropdown(string Label, array<string> Options, string InitialOption, delegate<SettingChangedHandler> ChangeHandler)
{
	local string Opt;

	ChangedHandler = ChangeHandler;

	DropdownOptions.Length = 0;
	foreach Options(Opt)
		DropdownOptions.AddItem(Opt);

	DropdownIndex = DropdownOptions.Find(InitialOption);

	if (DropdownIndex < 0)
	{
		DropdownOptions.AddItem(InitialOption);
		DropdownIndex = DropdownOptions.Length - 1;
	}

	TmpSuppressEvent = true;
	UpdateDataDropdown(Label, DropdownOptions, DropdownIndex, DropdownSelectionChangedCallback);
	TmpSuppressEvent = false;
}

function SetEditable(bool IsEditable)
{
	SetDisabled(!IsEditable);
}

function string GetLabel()
{
	return Desc.text;
}

function bool GetCheckboxValue()
{
	return Checkbox.bChecked;
}

function float GetSliderValue()
{
	return SliderValue;
}

function string GetDropdownValue()
{
	if (DropdownIndex >= 0 && DropdownIndex < DropdownOptions.Length)
		return DropdownOptions[DropdownIndex];
	else
		return "";
}

function string GetSpinnerValue()
{
	return Spinner.Value;
}

function SetLabel(string NewLabel)
{
	Desc.SetText(NewLabel);
}

function SimulateClick()
{
	ButtonClickedCallback(Button);
}

// SuppressEvent = True to avoid raising a handler event when setting the value.
function SetCheckboxValue(bool Checked, bool SuppressEvent)
{
	Checkbox.SetChecked(Checked, !SuppressEvent);
}

function SetSliderBounds(float min, float max, float step, float newValue, bool SuppressEvent)
{
	local float position;

	SliderMin = min;
	SliderMax = max;
	SliderValue = newValue;

	// Map to [1,100] range
	position = (SliderValue - SliderMin)/(SliderMax - SliderMin) * 99.0 + 1.0;

	TmpSuppressEvent = SuppressEvent;
	Slider.SetPercent(position);
	Slider.SetStepSize(step);
	TmpSuppressEvent = false;
}

function SetSliderValue(float _SliderValue, bool SuppressEvent)
{
	local float position;

	SliderValue = _SliderValue;

	// Map to [1,100] range
	position = (SliderValue - SliderMin)/(SliderMax - SliderMin) * 99.0 + 1.0;

	TmpSuppressEvent = SuppressEvent;
	Slider.SetPercent(position);
	TmpSuppressEvent = false;
}

function SetDropdownOptions(array<string> NewOptions, string InitialSelection, bool SuppressEvent)
{
	local string Opt;

	TmpSuppressEvent = SuppressEvent;

	DropdownOptions.Length = 0;
	foreach NewOptions(Opt)
		DropdownOptions.AddItem(Opt);

	DropdownIndex = DropdownOptions.Find(InitialSelection);

	if (DropdownIndex < 0)
	{
		DropdownOptions.AddItem(InitialSelection);
		DropdownIndex = DropdownOptions.Length - 1;
	}

	TmpSuppressEvent = true;
	Dropdown.SetSelected(DropdownIndex);
	TmpSuppressEvent = false;
}

function SetDropdownValue(string Selection, bool SuppressEvent)
{
	DropdownIndex = DropdownOptions.Find(Selection);

	// Don't do anything if trying to set invalid selection.
	if (DropdownIndex >= 0)
	{
		TmpSuppressEvent = SuppressEvent;
		Dropdown.SetSelected(DropdownIndex);
		TmpSuppressEvent = false;
	}
}

function SetSpinnerOptions(array<string> NewOptions, string InitialSelection, bool SuppressEvent)
{
	local string Opt;

	TmpSuppressEvent = SuppressEvent;

	SpinnerOptions.Length = 0;
	foreach NewOptions(Opt)
		SpinnerOptions.AddItem(Opt);

	SpinnerIndex = SpinnerOptions.Find(InitialSelection);

	TmpSuppressEvent = true;
	Spinner.SetValue(InitialSelection);
	TmpSuppressEvent = false;
}

function SetSpinnerValue(string Selection, bool SuppressEvent)
{
	SpinnerIndex = SpinnerOptions.Find(Selection);
	
	TmpSuppressEvent = SuppressEvent;
	Spinner.SetValue(Selection);
	TmpSuppressEvent = false;
}

// ======================================= Event handlers.

function CheckboxChangedCallback(UICheckbox CheckboxControl)
{
	ChangedHandler(self);
}

function ButtonClickedCallback(UIButton ButtonSource)
{
	if (ChangedHandler != none)
		ChangedHandler(self);
}

function SliderChangedCallback(UISlider SliderControl)
{
	// map [1,100] to [min,max]
	SliderValue = SliderMin + (Slider.percent - 1.0)/99.0 * (SliderMax - SliderMin);

	if (!TmpSuppressEvent && ChangedHandler != none)
		ChangedHandler(self);
}

function DropdownSelectionChangedCallback(UIDropdown DropdownControl)
{
	local string Opt;

	Opt = DropdownControl.GetSelectedItemText();

	DropdownIndex = DropdownOptions.Find(Opt);

	if (!TmpSuppressEvent && ChangedHandler != none)
		ChangedHandler(self);
}

function SpinnerChangedCallback(UIListItemSpinner spinnerControl, int direction)
{
	if (SpinnerIndex < 0)
	{
		if ( SpinnerOptions.Length > 0 )
			SpinnerIndex = 0;
	}
	else
	{
		SpinnerIndex = (SpinnerIndex + direction + SpinnerOptions.Length) % SpinnerOptions.Length;
	}

	if (SpinnerIndex >= 0)
	{
		spinnerControl.SetValue(SpinnerOptions[SpinnerIndex]);
	}
	else
	{
		spinnerControl.SetValue("???");
	}

	if (!TmpSuppressEvent && ChangedHandler != none)
	{
		ChangedHandler(self);
	}
}*/