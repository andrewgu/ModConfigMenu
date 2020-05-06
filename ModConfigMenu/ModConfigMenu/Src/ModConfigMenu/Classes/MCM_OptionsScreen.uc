class MCM_OptionsScreen extends UIScreen implements(MCM_API, MCM_API_Instance) 
    config(ModConfigMenu) dependson(UIDialogueBox);

var config int PANEL_X;
var config int PANEL_Y;
var config int TABLIST_WIDTH;
var config int TABS_LIST_TOP_PADDING;
var config int OPTIONS_HEIGHT;
var config int OPTIONS_WIDTH;
var config int OPTIONS_MARGIN;
var config int HEADER_HEIGHT;
var config int FOOTER_HEIGHT;

// If false, then hide soldier during Options menu in order to improve visibility and avoid blocking
// Save and Exit button. Allows for bigger menu.
var config bool SHOW_SOLDIER;

// Needs major version match and requested minor version needs to be <= actual minor version.
var config int API_MAJOR_VERSION;
var config int API_MINOR_VERSION;

var localized string m_strTitle;
var localized string m_strSubtitle;
var localized string m_strSaveAndExit;
var localized string m_strCancel;

var MCM_OptionsMenuListener ParentListener;

var UIPanel Container;
var UIImage BG;
var UIImage VSeparator;
var UIX2PanelHeader TitleHeader;

var UIList TabsList;
var int SettingsPageCounter;
var int SelectedPageID;
var array<MCM_SettingsTab> SettingsTabs;
var array<MCM_SettingsPanelFacade> SettingsPanels;
var UIButton SaveAndExitButton;
var UIButton CancelButton;

var int CurrentGameMode;

// Pawn hiding code thanks to Patrick-Seymour
var bool SoldierVisible;
struct PawnAndComponents {
    var XComUnitPawn Pawn;
    var array<PrimitiveComponent> Comps;
};
var array<PawnAndComponents> PawnAndComps;

delegate ClientModCallback(MCM_API_Instance ConfigAPI, int GameMode);
delegate OnClickedDelegate(UIButton Button);
delegate SettingsTabDelegate(MCM_SettingsTab Caller, int PageID);
delegate CustomSettingsPageCallback(UIScreen ParentScreen, int PageID);

simulated function InitScreen(XComPlayerController InitController, UIMovie InitMovie, optional name InitName)
{
    `log("MCM InitScreen called.");

    super.InitScreen(InitController, InitMovie, InitName);

    UpdateGameMode();
    CreateSkeleton();

    `log("MCM InitScreen complete.");
}

simulated function UpdateGameMode()
{
    local EUIMode uimode;

    if (`XENGINE.IsMultiplayerGame())
    {
        CurrentGameMode = eGameMode_Multiplayer;
    }
    else
    {
        uimode = Movie.Pres.m_eUIMode;

        if (uimode == eUIMode_Tactical)
            CurrentGameMode = eGameMode_Tactical;
        else if (uimode == eUIMode_Strategy)
            CurrentGameMode = eGameMode_Strategy;
        else if (uimode == eUIMode_Shell)
            CurrentGameMode = eGameMode_MainMenu;
        else
            CurrentGameMode = eGameMode_Unknown;
    }
}

simulated function OnInit()
{
    super.OnInit();

    `log("MCM Core: On Init Called.");

    if (CurrentGameMode == eGameMode_MainMenu && SHOW_SOLDIER == false)
    {
        `log("MCM Core: hiding soldier guy on main menu for visibility.");
        HideSoldierIfMainMenu();
    }
}

simulated function OnRemoved()
{
    if (CurrentGameMode == eGameMode_MainMenu && SHOW_SOLDIER == false)
    {
        `log("MCM Core: unhiding soldier guy on main menu for visibility.");
        ShowSoldierIfMainMenu();
    }
}

simulated function InitModOptionsMenu(MCM_OptionsMenuListener listener)
{
    ParentListener = listener;
    `log("MCM InitModOptionsMenu called.");
}

simulated function CreateSkeleton()
{
    local int TotalWidth;
    local int TotalHeight;

    TotalWidth = TABLIST_WIDTH + OPTIONS_WIDTH;
    TotalHeight = HEADER_HEIGHT + OPTIONS_HEIGHT + FOOTER_HEIGHT;
    
    Container = Spawn(class'UIPanel', self).InitPanel('').SetPosition(PANEL_X, PANEL_Y).SetSize(TotalWidth, TotalHeight);
    
    BG = Spawn(class'UIImage', Container).InitImage(,"img:///MCM.gfx.MainBackground");
    BG.SetPosition(0,0).SetSize(TotalWidth, TotalHeight);
    
    VSeparator = Spawn(class'UIImage', Container).InitImage(,"img:///MCM.gfx.MainVerticalSeparator");
    VSeparator.SetPosition(TABLIST_WIDTH,HEADER_HEIGHT);
    
    // Save and exit button    
    SaveAndExitButton = Spawn(class'UIButton', Container);
    SaveAndExitButton.InitButton(, m_strSaveAndExit, OnSaveAndExit);
    SaveAndExitButton.SetPosition(Container.width - 190, Container.height - 40); //Relative to this screen panel
    SaveAndExitButton.AnimateIn(0);

    CancelButton = Spawn(class'UIButton', Container);
    CancelButton.InitButton(, m_strCancel, OnCancel);
    CancelButton.SetPosition(Container.width - 190 - 170, Container.height - 40); //Relative to this screen panel
    CancelButton.AnimateIn(0);

    TitleHeader = Spawn(class'UIX2PanelHeader', Container);
    TitleHeader.InitPanelHeader('', m_strTitle, m_strSubtitle);
    TitleHeader.SetHeaderWidth(Container.width - 20);
    TitleHeader.SetPosition(10, 10);
    
    TabsList = Spawn(class'UIList', Container).InitList('ModTabSelectList', 10, HEADER_HEIGHT + TABS_LIST_TOP_PADDING, TABLIST_WIDTH - 30, OPTIONS_HEIGHT);
    TabsList.SetSelectedNavigation();
    TabsList.Navigator.LoopSelection = true;

    //Container.Navigator.AddControl(SaveAndExitButton);
    //Container.Navigator.AddControl(CancelButton);

    // Start with nothing selected.
    Container.Navigator.SetSelected(none);
    //TabsList.Navigator.SelectFirstAvailable();
}

// Special button handlers ========================================================================

simulated function OnSaveAndExit(UIButton kButton)
{
    local MCM_SettingsPanelFacade TmpPage;
    
    // Save all.
    foreach SettingsPanels(TmpPage)
    {
        TmpPage.TriggerSaveEvent();
    }

    Movie.Stack.Pop(self);
}

simulated function OnCancel(UIButton kButton)
{
    local MCM_SettingsPanelFacade TmpPage;
    
    // Cancel all.
    foreach SettingsPanels(TmpPage)
    {
        TmpPage.TriggerCancelEvent();
    }

    Movie.Stack.Pop(self);
}

// Keyboard input ============================================================================

simulated function bool OnUnrealCommand(int cmd, int arg)
{
    if( !CheckInputIsReleaseOrDirectionRepeat(cmd, arg) )
        return false;

    switch( cmd )
    {
        case class'UIUtilities_Input'.const.FXS_BUTTON_B:
        case class'UIUtilities_Input'.const.FXS_KEY_ESCAPE:
            OnCancel(none);
            break; 
    }

    return super.OnUnrealCommand(cmd, arg);
}

// Show/hide the soldier pawn ===================================================================
// Implementation thanks to Patrick-Seymour, who provided this code.

simulated function HideSoldier()
{
    local XComUnitPawn Pawn;
    local PrimitiveComponent Comp;
    local PawnAndComponents PawnAndComp;
    PawnAndComps.Length = 0;
    foreach `XWORLDINFO.AllActors(class'XComUnitPawn', Pawn) 
    {
        PawnAndComp.Pawn = Pawn;
        PawnAndComp.Comps.Length = 0;
        foreach Pawn.AllOwnedComponents(class'PrimitiveComponent', Comp) 
        {
            if (!Comp.HiddenGame) 
            {
                Comp.SetHidden(true);
                PawnAndComp.Comps.AddItem(Comp);
            }
        }
        PawnAndComps.AddItem(PawnAndComp);
    }

    SoldierVisible = false;
}

simulated function ShowSoldier()
{
    local XComUnitPawn Pawn;
    local PrimitiveComponent Comp;
    local int i, j;
    foreach `XWORLDINFO.AllActors(class'XComUnitPawn', Pawn) 
    {
        for (i = 0; i < PawnAndComps.Length; ++i) 
        {
            if (PawnAndComps[i].Pawn == Pawn) 
            {
                foreach Pawn.AllOwnedComponents(class'PrimitiveComponent', Comp) 
                {
                    for (j = 0; j < PawnAndComps[i].Comps.Length; ++j) 
                    {
                        if (PawnAndComps[i].Comps[j] == Comp) 
                        {
                            Comp.SetHidden(false);
                            break;
                        }
                    }
                }
                break;
            }
        }
    }
    PawnAndComps.Length = 0;

    SoldierVisible = true;
}

simulated function HideSoldierIfMainMenu()
{
    if (CurrentGameMode == eGameMode_MainMenu && SoldierVisible)
    {
        HideSoldier();
    }
}

simulated function ShowSoldierIfMainMenu()
{
    if (CurrentGameMode == eGameMode_MainMenu && !SoldierVisible)
    {
        ShowSoldier();
    }
}

// Helpers for MCM_API_Instance ===================================================================

simulated function MCM_SettingsPanelFacade GetPanelByPageID(int PageID)
{
    local MCM_SettingsPanelFacade TmpPage;

    foreach SettingsPanels(TmpPage)
    {
        if (TmpPage.GetPageId() == PageID)
            return TmpPage;
    }

    return None;
}

simulated function ChoosePanelByPageID(int PageID)
{
    //local MCM_SettingsPanel CurrentSettingsPage;
    local MCM_SettingsTab TmpButton;
    local MCM_SettingsPanelFacade TmpPage;

    // Are we changing pages? Do nothing if not changing pages.
    if (PageID != SelectedPageID)
    {
        SelectedPageID = PageID;
        
        // Now choose the panel.
        foreach SettingsPanels(TmpPage)
        {
            if (TmpPage.GetPageId() != SelectedPageID)
            {
                TmpPage.Hide();
            }
            else
            {
                `log("MCM: Found correct panel, showing.");
                TmpPage.Show();
            }
        }

        // Refresh the button. This is important if we're cancelling a tab change.
        foreach SettingsTabs(TmpButton)
        {
            if (TmpButton.SettingsPageID == SelectedPageID)
            {
                TmpButton.SetChecked(true);
            }
            else
            {
                TmpButton.SetChecked(false);
            }
        }
    }
}

simulated function TabClickedHandler(MCM_SettingsTab Caller, int PageID)
{
    `log("MCM Tab clicked: " $ string(PageID));
    //TabsList.SetSelectedItem(kButton, true);
    ChoosePanelByPageID(PageID);
}

simulated function AddTabsListButton(string TabLabel, int PageID)
{
    local MCM_SettingsTab Item; 
    Item = Spawn(class'MCM_SettingsTab', TabsList.ItemContainer).InitSettingsTab(PageID, TabLabel);
    Item.OnClickHandler = TabClickedHandler;

    SettingsTabs.AddItem(Item);
}

function MCM_API_SettingsPage MakeSettingsPage(string TabLabel, int PageID)
{
    local MCM_SettingsPanelFacade SP;
    SP = Spawn(class'MCM_SettingsPanelFacade', self);
    SP.InitSettingsPanelFacade(PageID, TabLabel, TABLIST_WIDTH + OPTIONS_MARGIN, HEADER_HEIGHT, Container);

    // Register panel.
    SettingsPanels.AddItem(SP);

    return SP;
}

simulated function CustomTabClickedHandler(MCM_SettingsTab Caller, int PageID)
{
    `log("MCM Custom Screen Tab clicked");
    if (Caller.CustomPageCallback != none)
    {
        Caller.SetChecked(false);
        Caller.CustomPageCallback(self, PageID);
    }
}

// MCM_API_Instance implementation ===============================================================

function MCM_API_SettingsPage NewSettingsPage(string TabLabel)
{
    local int PageID;

    PageID = SettingsPageCounter;
    SettingsPageCounter++;

    AddTabsListButton(TabLabel, PageID);

    return MakeSettingsPage(TabLabel, PageID);
}

function int NewCustomSettingsPage(string TabLabel, delegate<CustomSettingsPageCallback> Handler)
{
    local MCM_SettingsTab Item; 
    local int PageID;

    PageID = SettingsPageCounter;
    SettingsPageCounter++;

    Item = Spawn(class'MCM_SettingsTab', TabsList.ItemContainer).InitSettingsTab(PageID, TabLabel);
    Item.CustomPageCallback = Handler;
    Item.OnClickHandler = CustomTabClickedHandler;

    return PageID;
}

function MCM_API_SettingsPage GetSettingsPageByID(int PageID)
{
    local MCM_SettingsPanelFacade TmpPage;

    foreach SettingsPanels(TmpPage)
    {
        if (TmpPage.GetPageId() == PageID)
        {
            return TmpPage;
        }
    }

    return None;
}


// MCM_API implementation ========================================================================

function bool RegisterClientMod(int major, int minor, delegate<ClientModCallback> SetupHandler)
{
    if (major == API_MAJOR_VERSION && minor <= API_MINOR_VERSION)
    {
        SetupHandler(self, CurrentGameMode);
        return true;
    }
    else
    {
        return false;
    }
}

// Defaults ======================================================================================

defaultproperties
{
    ParentListener = None;
    SettingsPageCounter = 0;
    SelectedPageID = -1;

    SoldierVisible = true;

    InputState= eInputState_Evaluate;

    bAlwaysTick = true
    bConsumeMouseEvents=true
}