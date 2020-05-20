class MCM_SettingsPanelFacade extends Actor implements(MCM_API_SettingsPage) config(ModConfigMenu);

var int OffsetX;
var int OffsetY;

var int PageID;
var string Title;

var delegate<SaveStateHandler> ResetHandler;
var delegate<SaveStateHandler> CancelHandler;
var delegate<SaveStateHandler> SaveHandler;

var array<MCM_SettingGroup> SettingGroups;

var UIPanel Container;
var MCM_SettingsPanel UiInstance;

delegate SaveStateHandler(MCM_API_SettingsPage SettingsPage);

simulated function MCM_SettingsPanelFacade InitSettingsPanelFacade(int _PageID, string _Title, int UiOffsetX, int UiOffsetY, UIPanel _Container)
{
    OffsetX = UiOffsetX;
    OffsetY = UiOffsetY;
    PageID = _PageID;
    Title = _Title;

    ResetHandler = none;
    SaveHandler = none;
    CancelHandler = none;

    Container = _Container;
    UiInstance = none;

}

// Internal

simulated function MCM_SettingsPanel CreateUi()
{
    local MCM_SettingsPanel SP;
    SP = Spawn(class'MCM_SettingsPanel', Container);
    SP.InitPanel();
    SP.Facade = self;
    SP.SettingsPageID = PageID;
    SP.SetPosition(OffsetX, OffsetY);
    SP.SetPageTitle(Title);
    
    // Inject the identical group list from the facade into the panel
    SP.SettingGroups = SettingGroups;

    // Gotta make sure to forward handlers too
    SP.SetSaveHandler(SaveHandler);
    SP.SetCancelHandler(CancelHandler);
    if (ResetHandler != none)
    {
        SP.EnableResetButton(ResetHandler);
    }

    // This spawns all of the actual UI elements into the panel.
    SP.ShowSettings();

    return SP;
}

// MCM_SettingsPanelFacade helpers for OptionsScreen implementation ==============

simulated function Show()
{
    if (UiInstance == none)
    {
        // .Show() is implicitly called.
        UiInstance = CreateUi();
    }
    else
    {
        UiInstance.Show();
    }
}

simulated function Hide()
{
    if (UiInstance != none)
    {
        UiInstance.Hide();
    }
}

simulated function TriggerSaveEvent()
{
    //`log("MCM SettingsPanelFacade: triggered save event");
    // If they never actually opened the panel, then no need to start triggering any events.
    if (UiInstance != none)
    {
        //`log("MCM SettingsPanelFacade: forwarding save event");
        UiInstance.TriggerSaveEvent();
    }
}

simulated function TriggerCancelEvent()
{
    //`log("MCM SettingsPanelFacade: triggered cancel event");
    // If they never actually opened the panel, then no need to start triggering any events.
    if (UiInstance != none)
    {
        //`log("MCM SettingsPanelFacade: forwarding cancel event");
        UiInstance.TriggerCancelEvent();
    }
}

// MCM_API_SettingsPage implementation ===========================================

// Gives you a way to uniquely identify this settings page from all others, 
// guaranteed to be unique per "OnInit" of the mod settings menu.
function int GetPageId()
{
    return PageID;
}

function SetPageTitle(string _Title)
{
    Title = _Title;

    if (UiInstance != none)
    {
        UiInstance.SetPageTitle(_Title);
    }
}

// Use these to handle user triggered save/cancel events.
function SetSaveHandler(delegate<SaveStateHandler> _SaveHandler)
{
    SaveHandler = _SaveHandler;

    if (UiInstance != none)
    {
        UiInstance.SetSaveHandler(_SaveHandler);
    }
}

function SetCancelHandler(delegate<SaveStateHandler> _CancelHandler)
{
    CancelHandler = _CancelHandler;

    if (UiInstance != none)
    {
        UiInstance.SetCancelHandler(_CancelHandler);
    }
}

// By default Reset button is not visible, you can choose to use it.
// You can call this more than once to change the reset handler.
function EnableResetButton(delegate<SaveStateHandler> _ResetHandler)
{
    ResetHandler = _ResetHandler;

    if (UiInstance != none)
    {
        UiInstance.EnableResetButton(_ResetHandler);
    }
}

// Groups let you visually cluster settings. All settings belong to groups.
function MCM_API_SettingsGroup AddGroup(name GroupName, string GroupLabel)
{
    local MCM_SettingGroup Grp;

    Grp = Spawn(class'MCM_SettingGroup', self).InitSettingGroup(GroupName, GroupLabel, self);
    SettingGroups.AddItem(Grp);

    return Grp;
}

function MCM_API_SettingsGroup GetGroupByName(name GroupName)
{
    local MCM_SettingGroup iter;

    foreach SettingGroups(iter)
    {
        if (iter.GroupName == GroupName)
            return iter;
    }

    return none;
}

function MCM_API_SettingsGroup GetGroupByIndex(int Index)
{
    if (Index >= 0 && Index < SettingGroups.Length)
        return SettingGroups[Index];
    else
        return None;
}

function int GetGroupCount()
{
    return SettingGroups.Length;
}

// Call to indicate "done making settings". Must call all of your AddGroup and Group.Add#### calls before this.
function ShowSettings()
{
    // This is a no-op, the actual call to generate UI elements will happen the first time the settings panel is opened.
}