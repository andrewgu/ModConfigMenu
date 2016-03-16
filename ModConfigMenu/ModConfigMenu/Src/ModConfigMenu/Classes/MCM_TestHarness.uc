class MCM_TestHarness extends UIScreenListener config(ModConfigMenu);

`include(ModConfigMenu/Src/ModConfigMenuAPI/MCM_API_Includes.uci)

var config bool ENABLE_TEST_HARNESS;

var MCM_API APIInst;

event OnInit(UIScreen Screen)
{
	if (!ENABLE_TEST_HARNESS)
	{
		`log("MCM Test Harness Disabled.");
		return;
	}

	`log("MCM Test Harness: Attempt init.");
    `CheckVersionAndRegister(Screen, ClientModCallback);
	//APIInst = MCM_API(Screen);
	//if (APIInst != None)
	//{
	//	`log("MCM Test Harness: Attempt register.");
	//	APIInst.RegisterClientMod(0, 1, ClientModCallback);
	//}
}

function ClientModCallback(MCM_API_Instance ConfigAPI, int GameMode)
{
	local MCM_API_SettingsPage Page1, Page2;
	//local MCM_API_Setting Setting1, Setting2, Setting3, Setting4, Setting5;
	local array<name> Page1Settings, Page2Settings;
	local array<string> DropdownOptions;
	local array<MCM_API_Setting> P1S, P2S;

	Page1Settings.AddItem('Test Slider Setting');
	Page1Settings.AddItem('Button Setting');

	Page2Settings.AddItem('Test Checkbox Setting');
	Page2Settings.AddItem('Test Spinner');
	Page2Settings.AddItem('Test Dropdown Eventually');

	DropdownOptions.AddItem("a");
	DropdownOptions.AddItem("bcd");
	DropdownOptions.AddItem("e");
	DropdownOptions.AddItem("fgh");
	DropdownOptions.AddItem("ij");
	DropdownOptions.AddItem("klm");

	if (GameMode == eGameMode_MainMenu || GameMode == eGameMode_Strategy)
	{
		`log("Is in main menu, attempting to make page.");
		
		Page1 = ConfigAPI.NewSettingsPage("MCM_Test_1");
		Page1.EnableSaveAndCancelButtons(SaveButtonClicked, RevertButtonClicked);

		Page2 = ConfigAPI.NewSettingsPage("MCM_Test_2");
		Page2.EnableResetToDefaultButton(ResetButtonClicked);

		P1S = Page1.MakeSettings(Page1Settings);
		P2S = Page2.MakeSettings(Page2Settings);

		P1S[0].InitAsSlider("Test Setting", 1, 100, 10, 50, SliderChangeHandler);
		P1S[1].InitAsButton("Button setting", "Button", ButtonHandler);

		P2S[0].InitAsCheckbox("Test Setting", True, CheckboxChangeHandler);
		P2S[1].InitAsSpinner("Spinner setting", DropdownOptions, "e", DropdownHandler);
		P2S[2].InitAsDropdown("Dropdown setting", DropdownOptions, "ij", DropdownHandler);

		if (GameMode == eGameMode_Strategy)
			P2S[0].SetEditable(false);
	}
}

function SaveButtonClicked(MCM_API_SettingsPage Page)
{
	`log("MCM: Save button clicked on page " $ string(Page.GetPageID()));
}

function RevertButtonClicked(MCM_API_SettingsPage Page)
{
	`log("MCM: Revert button clicked on page " $ string(Page.GetPageID()));
}

function ResetButtonClicked(MCM_API_SettingsPage Page)
{
	`log("MCM: Reset button clicked on page " $ string(Page.GetPageID()));
}

function CheckboxChangeHandler(MCM_API_Setting Setting)
{
	if (Setting.GetCheckboxValue())
	{
		`log("Setting1 checked.");
	}
	else
	{
		`log("Setting1 unchecked.");
	}
}

function SliderChangeHandler(MCM_API_Setting Setting)
{
	`log("Slider changed: " $ string(Setting.GetSliderValue()));
}

function ButtonHandler(MCM_API_Setting Setting)
{
	`log("Button clicked.");
}

function SpinnerHandler(MCM_API_Setting Setting)
{
	`log("Spinner selected: " $ Setting.GetSpinnerValue());
}

function DropdownHandler(MCM_API_Setting Setting)
{
	`log("Dropdown selected: " $ Setting.GetDropdownValue());
}

defaultproperties
{
	ScreenClass = class'MCM_OptionsScreen';
}