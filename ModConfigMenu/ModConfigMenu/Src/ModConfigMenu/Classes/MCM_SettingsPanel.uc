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

var array<MCM_SettingGroup> SettingGroups;
//var float SettingItemStartY;

var delegate<SaveStateHandler> ResetHandler;
var delegate<SaveStateHandler> CancelHandler;
var delegate<SaveStateHandler> SaveHandler;

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
	TitleLine.UpdateTitle("Mod Settings");
	TitleLine.SetY(0);
	TitleLine.Show();
	TitleLine.EnableNavigation();

	//SettingItemStartY = TitleLine.Height;

	ResetButton = Spawn(class'UIButton', self);
	ResetButton.InitButton(, m_strResetButton, OnResetClicked);
	ResetButton.SetPosition(RESET_BUTTON_X, PANEL_HEIGHT - FOOTER_HEIGHT + 3); //Relative to this screen panel
	ResetButton.Hide();

	ResetHandler = none;
    SaveHandler = none;
    CancelHandler = none;

	return self;
}

simulated function OnInit()
{
	super.OnInit();
}

simulated function OnResetClicked(UIButton kButton)
{
	if (ResetHandler != none)
		ResetHandler(self);
}

// Helpers for MCM_OptionsScreen ================================================================

simulated function TriggerSaveEvent()
{
    if (SaveHandler != none)
        SaveHandler(self);
}

simulated function TriggerCancelEvent()
{
    if (CancelHandler != none)
        CancelHandler(self);
}

// MCM_API_SettingsPage implementation ===========================================

function int GetPageId()
{
	return SettingsPageID;
}

// To do : probably add description to this function too ? Super d
function SetPageTitle(string title)
{
	TitleLine.UpdateTitle(title);
}

function SetSaveHandler(delegate<SaveStateHandler> _SaveHandler)
{
    local MCM_SettingGroup grp;
    foreach SettingGroups(grp)
    {
        grp.TriggerSaveEvents();
    }

    SaveHandler = _SaveHandler;
}

function SetCancelHandler(delegate<SaveStateHandler> _CancelHandler)
{
    CancelHandler = _CancelHandler;
}

function EnableResetButton(delegate<SaveStateHandler> _ResetHandler)
{
    ResetHandler = _ResetHandler;
    ResetButton.Show();
}

// Groups let you visually cluster settings.
function MCM_API_SettingsGroup AddGroup(name GroupName, string GroupLabel)
{
    local MCM_SettingGroup Grp;

    Grp = Spawn(class'MCM_SettingGroup', self).InitSettingGroup(GroupName, GroupLabel);
    SettingGroups.AddItem(Grp);

    return Grp;
}

function MCM_API_SettingsGroup GetGroup(name GroupName)
{
    local MCM_SettingGroup iter;

    foreach SettingGroups(iter)
    {
        if (iter.GroupName == GroupName)
            return iter;
    }

    return none;
}

// Assumes that groups are iterated in reverse order and items in groups are inserted in reverse order.
function OnSettingsLineInitialized(UIMechaListItem NextItem)
{
    SettingsList.MoveItemToTop(NextItem);
}

function ShowSettings()
{
    // This is where magic happens.
    local int groupIndex;

    for (groupIndex = SettingGroups.Length - 1; groupIndex >= 0; groupIndex--) 
    {
        SettingGroups[groupIndex].InstantiateItems(OnSettingsLineInitialized, SettingsList);
    }
}

