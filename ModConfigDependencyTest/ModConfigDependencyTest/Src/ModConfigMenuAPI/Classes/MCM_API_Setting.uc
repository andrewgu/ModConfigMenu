interface MCM_API_Setting;

enum eSettingType
{
	eSettingType_Label,
	eSettingType_Button,
	eSettingType_Checkbox,
	eSettingType_Slider,
	eSettingType_Dropdown,
	eSettingType_Spinner,
	eSettingType_Unknown
};

delegate SettingChangedHandler(MCM_API_Setting Setting);

// Name is used for ID purposes, not for UI.
function name GetName();

// Label is used for UI purposes, not for ID.
function SetLabel(string NewLabel);
function string GetLabel();

// Lets you show an option but disable it because it shouldn't be configurable.
// For example, if you don't want to allow tweaking during a mission.
function SetEditable(bool IsEditable);

// Retrieves underlying setting type. Defined as an int to make setting types more extensible to support
// future "extension types".
function int GetSettingType();

// Choose one, once.
// Pure labels won't change.
function InitAsLabel(string Label);
function InitAsButton(string Label, string ButtonLabel, delegate<SettingChangedHandler> ChangeHandler);
function InitAsCheckbox(string Label, bool InitialChecked, delegate<SettingChangedHandler> ChangeHandler);
function InitAsSlider(string Label, float min, float max, float step, float InitialValue, delegate<SettingChangedHandler> ChangeHandler);
function InitAsSpinner(string Label, array<string> Options, string InitialOption, delegate<SettingChangedHandler> ChangeHandler);
function InitAsDropdown(string Label, array<string> Options, string InitialOption, delegate<SettingChangedHandler> ChangeHandler);

// Gives way to retrieve current value by query rather than get a push by callback
function bool GetCheckboxValue();
function float GetSliderValue();
function string GetSpinnerValue();
function string GetDropdownValue();

// SuppressEvent = True to avoid raising a handler event when setting the value.
// No SuppressEvent option on button because then it'd do nothing.
function SimulateClick();
function SetCheckboxValue(bool Checked, bool SuppressEvent);
function SetSliderValue(float SliderValue, bool SuppressEvent);
function SetSpinnerValue(string Selection, bool SuppressEvent);
function SetDropdownValue(string Selection, bool SuppressEvent);

// If you want to change bounds on the setting.
function SetSliderBounds(float min, float max, float step, float newValue, bool SuppressEvent);
function SetSpinnerOptions(array<string> NewOptions, string InitialSelection, bool SuppressEvent);
function SetDropdownOptions(array<string> NewOptions, string InitialSelection, bool SuppressEvent);
