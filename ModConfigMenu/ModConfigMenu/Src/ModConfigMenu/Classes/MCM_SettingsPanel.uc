class MCM_SettingsPanel extends UIPanel implements(MCM_API_SettingsPage) config(ModConfigMenu);

var config int PANEL_HEIGHT;
var config int PANEL_WIDTH;
var config int FOOTER_HEIGHT;
var config int RESET_BUTTON_X;
var config int APPLY_BUTTON_X;
var config int REVERT_BUTTON_X;

var localized string m_strResetButton;
var localized string m_strRevertButton;
var localized string m_strApplyButton;

var int SettingsPageID;

var UIList SettingsList;

var MCM_UISettingSeparator TitleLine;
var UIButton ResetButton;
var UIButton RevertButton;
var UIButton ApplyButton;

var array<MCM_SettingItem> SettingItems;
var float SettingItemStartY;

var delegate<SaveStateHandler> ResetHandler;
var delegate<SaveStateHandler> ApplyHandler;
var delegate<SaveStateHandler> RevertHandler;

delegate SettingChangedHandler(MCM_API_Setting Setting);
delegate SaveStateHandler(MCM_API_SettingsPage SettingsPage);

simulated function UIPanel InitPanel(optional name InitName, optional name InitLibID)
{
	super.InitPanel(InitName, InitLibID);

	SetSize(PANEL_WIDTH, PANEL_HEIGHT);

	SettingsList = Spawn(class'UIList', self).InitList('OptionsList', 0, 0, PANEL_WIDTH, PANEL_HEIGHT - FOOTER_HEIGHT - 70);
	SettingsList.SetSelectedNavigation();
	SettingsList.Navigator.LoopSelection = true;

	TitleLine = Spawn(class'MCM_UISettingSeparator', SettingsList.itemContainer);
	TitleLine.InitSeparator();
	TitleLine.UpdateTitle("Mod Settings Page");
	TitleLine.SetY(0);
	TitleLine.Show();
	TitleLine.EnableNavigation();

	SettingItemStartY = TitleLine.Height;

	RevertButton = Spawn(class'UIButton', self);
	RevertButton.InitButton(, m_strRevertButton, OnRevertClicked);
	RevertButton.SetPosition(REVERT_BUTTON_X, PANEL_HEIGHT - FOOTER_HEIGHT + 3); //Relative to this screen panel
	RevertButton.Hide();
	RevertHandler = none;

	ApplyButton = Spawn(class'UIButton', self);
	ApplyButton.InitButton(, m_strApplyButton, OnApplyClicked);
	ApplyButton.SetPosition(APPLY_BUTTON_X, PANEL_HEIGHT - FOOTER_HEIGHT + 3); //Relative to this screen panel
	ApplyButton.Hide();
	ApplyHandler = none;

	ResetButton = Spawn(class'UIButton', self);
	ResetButton.InitButton(, m_strResetButton, OnResetClicked);
	ResetButton.SetPosition(RESET_BUTTON_X, PANEL_HEIGHT - FOOTER_HEIGHT + 3); //Relative to this screen panel
	ResetButton.Hide();
	ResetHandler = none;

	return self;
}

simulated function OnInit()
{
	super.OnInit();
}

function OnRevertClicked(UIButton kButton)
{
	if (RevertHandler != none)
		RevertHandler(self);
}

function OnApplyClicked(UIButton kButton)
{
	if (ApplyHandler != none)
		ApplyHandler(self);
}

function OnResetClicked(UIButton kButton)
{
	if (ResetHandler != none)
		ResetHandler(self);
}

// MCM_API_SettingsPage implementation ===========================================

function int GetPageId()
{
	return SettingsPageID;
}
// To do : probably add description to this function too ? Super d
simulated function SetPageTitle(string title)
{
	TitleLine.UpdateTitle(title);
}

// Call in bottom-up order.
function MCM_API_Setting AddSetting(name SettingName)
{
	local MCM_SettingItem Item;

	Item = Spawn(class'MCM_SettingItem', SettingsList.itemContainer);
	Item.InitSettingsItem(SettingName);
	Item.Show();
	Item.EnableNavigation();

	// Because we're inserting backwards.
	SettingsList.MoveItemToTop(Item);

	// Also because we're inserting backwards.
	SettingItems.InsertItem(0, Item);
	return Item;
}

function array<MCM_API_Setting> MakeSettings(array<name> SettingNames)
{
	local name sName;
	local int iter;
	local array<MCM_API_Setting> SettingBuffer;
	
	SettingBuffer.Length = SettingNames.Length;

	for (iter = SettingNames.Length-1; iter >= 0; iter--)
	{
		sName = SettingNames[iter];
		SettingBuffer[iter] = AddSetting(sName);
	}

	// Make sure title line is at top.
	SettingsList.MoveItemToTop(TitleLine);

	return SettingBuffer;
}

// Will return None if setting by that name isn't found.
function MCM_API_Setting GetSettingByName(name SettingName)
{
	local MCM_SettingItem Iter;

	foreach SettingItems(Iter)
	{
		if (Iter.SettingName == SettingName)
			return Iter;
	}
	
	return None;
}

function MCM_API_Setting GetSettingByIndex(int Index)
{
	if (Index >= 0 && Index < SettingItems.Length)
	{
		return SettingItems[Index];
	}
	else
	{
		return none;
	}
}

function int GetNumberOfSettings()
{
	return SettingItems.Length;
}

// By default Save/Cancel buttons are not visible, you can choose to use them.
function EnableSaveAndCancelButtons(delegate<SaveStateHandler> SaveHandler, delegate<SaveStateHandler> CancelHandler)
{
	ApplyHandler = SaveHandler;
	RevertHandler = CancelHandler;

	ApplyButton.Show();
	RevertButton.Show();
}

// By default Reset button is not visible, you can choose to use it.
function EnableResetToDefaultButton(delegate<SaveStateHandler> Handler)
{
	ResetHandler = Handler;
	ResetButton.Show();
}
