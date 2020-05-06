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
var string Title;

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

    SettingsList = Spawn(class'UIList', self).InitList('OptionsList', 0, 0, PANEL_WIDTH, PANEL_HEIGHT - FOOTER_HEIGHT - 40);
    //SettingsList = Spawn(class'UIList', self).InitList('OptionsList', 0, 0, PANEL_WIDTH, PANEL_HEIGHT - FOOTER_HEIGHT - 20, , true);
    // Necessary to make sure dropdowns don't run past the bottom.
    //SettingsList.ScrollbarPadding = 500;
    SettingsList.SetSelectedNavigation();
    SettingsList.Navigator.LoopSelection = true;

    // Delay spawning of title line to make sure topmost "line" is also last layer.
    // See ShowSettings();
    TitleLine = none;
    //TitleLine = Spawn(class'MCM_UISettingSeparator', SettingsList.itemContainer);
    //TitleLine.InitSeparator();
    //TitleLine.UpdateTitle("Mod Settings");
    //TitleLine.SetY(0);
    //TitleLine.Show();
    //TitleLine.EnableNavigation();

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

simulated function Show()
{
    local MCM_SettingGroup iter;

    super.Show();

    // Now that it's visible, need to trigger the post-visibility update.
    foreach SettingGroups(iter)
    {
        iter.AfterParentPageDisplayed();
    }
}

// Helpers for MCM_OptionsScreen ================================================================

simulated function TriggerSaveEvent()
{
    local MCM_SettingGroup iter;

    foreach SettingGroups(iter)
    {
        iter.TriggerSaveEvents();
    }

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
function SetPageTitle(string newTitle)
{
    if(TitleLine != none)
    {
        TitleLine.UpdateTitle(newTitle);
    }
    Title = newTitle;
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

// Technically these functions are now fronted by the SettingsPanelFacade, so this is no longer needed.
// Groups let you visually cluster settings.
function MCM_API_SettingsGroup AddGroup(name GroupName, string GroupLabel)
{
    /*
    local MCM_SettingGroup Grp;

    Grp = Spawn(class'MCM_SettingGroup', self).InitSettingGroup(GroupName, GroupLabel, self);
    SettingGroups.AddItem(Grp);

    return Grp;
    */
    return none;
}

// Technically these functions are now fronted by the SettingsPanelFacade, so this is no longer needed.
function MCM_API_SettingsGroup GetGroupByName(name GroupName)
{
    /*
    local MCM_SettingGroup iter;

    foreach SettingGroups(iter)
    {
        if (iter.GroupName == GroupName)
            return iter;
    }
    */
    return none;
}

// Technically these functions are now fronted by the SettingsPanelFacade, so this is no longer needed.
function MCM_API_SettingsGroup GetGroupByIndex(int Index)
{
    /*
    if (Index >= 0 && Index < SettingGroups.Length)
        return SettingGroups[Index];
    else
        return None;
    */
    return none;
}

// Technically these functions are now fronted by the SettingsPanelFacade, so this is no longer needed.
function int GetGroupCount()
{
    /*
    return SettingGroups.Length;
    */
    return -1;
}

// Assumes that groups are iterated in reverse order and items in groups are inserted in reverse order.
//function OnSettingsLineInitialized(UIMechaListItem NextItem)
function OnSettingsLineInitialized(UIPanel NextItem)
{
    SettingsList.MoveItemToTop(NextItem);
}

function ShowSettings()
{
    // This is where magic happens.
    local int groupIndex;
    local UIImage bottomPadding;

    // Adds padding at bottom to make sure that bottom options are visisble.
    bottomPadding = Spawn(class'UIImage', SettingsList.itemContainer);
    bottomPadding.bProcessesMouseEvents = true;
    bottomPadding.InitImage('MCMBottomPadding',"img:///MCM.gfx.Transparent");
    bottomPadding.SetWidth(548);
    bottomPadding.SetHeight(150);
    OnSettingsLineInitialized(bottomPadding);

    for (groupIndex = SettingGroups.Length - 1; groupIndex >= 0; groupIndex--) 
    {
        SettingGroups[groupIndex].InstantiateItems(OnSettingsLineInitialized, SettingsList);
    }

    TitleLine = Spawn(class'MCM_UISettingSeparator', SettingsList.itemContainer);
    TitleLine.InitSeparator();
    TitleLine.UpdateTitle(Title != "" ? Title : "Mod Settings");
    TitleLine.SetY(0);
    TitleLine.Show();
    TitleLine.EnableNavigation();
    SettingsList.MoveItemToTop(TitleLine);
}

defaultproperties
{
    bProcessesMouseEvents = false;
}