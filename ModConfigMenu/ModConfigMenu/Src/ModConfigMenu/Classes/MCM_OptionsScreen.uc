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
var array<MCM_SettingsPanel> SettingsPanels;
var array<MCM_SettingsPanel> ShowQueue;
var UIButton SaveAndExitButton;
var UIButton CancelButton;
var UITextTooltip ActiveTooltip;
var float SBOffset, ScrollHeight;

var int CurrentGameMode;
var UINavigationHelp NavHelp;
var ConsoleOptionAttentionType AttentionType;
var UIMechaListItem MechaListItem;
var int MechaListItemType; //enum EUILineItemType found in UIMechaListItem;

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

	NavHelp = Spawn(class'UINavigationHelp',self).InitNavHelp();
	UpdateNavHelp();
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
	local bool MouseActive;

    TotalWidth = TABLIST_WIDTH + OPTIONS_WIDTH;
    TotalHeight = HEADER_HEIGHT + OPTIONS_HEIGHT + FOOTER_HEIGHT;
    MouseActive =!`ISCONTROLLERACTIVE;

    Container = Spawn(class'UIPanel', self);
	Container.bCascadeFocus = false;
	Container.InitPanel('').SetPosition(PANEL_X, PANEL_Y).SetSize(TotalWidth, TotalHeight);
    
    BG = Spawn(class'UIImage', Container).InitImage(,"img:///MCM.gfx.MainBackground");
    BG.SetPosition(0,0).SetSize(TotalWidth, TotalHeight);
    
    VSeparator = Spawn(class'UIImage', Container).InitImage(,"img:///MCM.gfx.MainVerticalSeparator");
    VSeparator.SetPosition(TABLIST_WIDTH,HEADER_HEIGHT);
    
    // Save and exit button    
    SaveAndExitButton = Spawn(class'UIButton', Container);
	SaveAndExitButton.bAnimateOnInit = false;
    SaveAndExitButton.InitButton(, class'UIOptionsPCScreen'.default.m_strSaveAndExit, OnSaveAndExit, eUIButtonStyle_HOTLINK_BUTTON);
	SaveAndExitButton.SetGamepadIcon(class'UIUtilities_Input'.const.ICON_X_SQUARE);
    SaveAndExitButton.SetPosition(Container.width - 190, Container.height - 40); //Relative to this screen panel
	SaveAndExitButton.DisableNavigation();

	if(MouseActive)
	{
		CancelButton = Spawn(class'UIButton', Container);
		SaveAndExitButton.bAnimateOnInit = false;
		CancelButton.InitButton(, class'UIUtilities_Text'.default.m_strGenericCancel, OnCancel);
		CancelButton.SetPosition(Container.width - 190 - 170, Container.height - 40); //Relative to this screen panel
		CancelButton.DisableNavigation();
	}

    TitleHeader = Spawn(class'UIX2PanelHeader', Container);
    TitleHeader.InitPanelHeader('', m_strTitle, m_strSubtitle);
    TitleHeader.SetHeaderWidth(Container.width - 20);
    TitleHeader.SetPosition(10, 10);
    
    TabsList = Spawn(class'UIList', Container).InitList('ModTabSelectList', 10, HEADER_HEIGHT + TABS_LIST_TOP_PADDING, TABLIST_WIDTH - 30, OPTIONS_HEIGHT);
    TabsList.SetSelectedNavigation();
	if (MouseActive)
	{
		TabsList.bSelectFirstAvailable = false;
	}
    //TabsList.Navigator.LoopSelection = true;

    //Container.Navigator.AddControl(SaveAndExitButton);
    //Container.Navigator.AddControl(CancelButton);

    // Start with nothing selected.
    //Container.Navigator.SetSelected(none);
    //TabsList.Navigator.SelectFirstAvailable();
}

// Mr. Nice: Originally all the ShowSettings() would get handled in one tick, since they ultimately
// Get called from the OnInit() in the mods UISL, all of which get called in the same tick after the panel itself is Innited.
// Smooth it out by handling one per tick...
// In principle could also smooth out the SetupHandler() calls instead of calling back immediately in RegisterClientMod(), but not
// sure there's much benefit there...
event Tick(float DeltaTime)
{
	if (ShowQueue.Length!=0)
	{
		ShowQueue[0].RealShowSettings();
		ShowQueue.Remove(0, 1);
	}
	Super.Tick(DeltaTime);
}

simulated function UpdateNavHelp( bool bWipeButtons = false )
{
	NavHelp.ClearButtonHelp();
	NavHelp.bIsVerticalHelp = true; //bsg-hlee (05.05.17): Stacking the B button at the bottom left nav help to match the rest of the main menu screens.
	NavHelp.AddBackButton(GoBack);

	if (`ISCONTROLLERACTIVE)
	{
		//determines if focus is on the RIGHT column
		if (AttentionType == COAT_DETAILS)
		{
			switch(MechaListItemType)
			{
				case EUILineItemType_Slider:
					NavHelp.AddLeftHelp(class'UIUtilities_Text'.default.m_strGenericAdjust, class'UIUtilities_Input'.const.ICON_DPAD_HORIZONTAL);
					break;
				case EUILineItemType_Checkbox:
					NavHelp.AddLeftHelp(class'UIUtilities_Text'.default.m_strGenericToggle, class'UIUtilities_Input'.static.GetAdvanceButtonIcon());
					break;
				case EUILineItemType_Spinner:
					NavHelp.AddLeftHelp(class'UIUtilities_Text'.default.m_strGenericSelect, class'UIUtilities_Input'.const.ICON_DPAD_HORIZONTAL);
					break;
				case EUILineItemType_Dropdown:
				case EUILineItemType_Button:
					NavHelp.AddSelectNavHelp();
					break;
			}
			// </workshop>
		}
		else //COAT_CATEGORIES
			NavHelp.AddSelectNavHelp();
	}
	
}

simulated function OnSelectionChanged(UIList ContainerList, int ItemIndex)
{
	UpdateMechItemNavHelp(ContainerList, ItemIndex); //INS: - JTA 2016/3/18

	if(`ISCONTROLLERACTIVE)
	{
		if (ActiveTooltip != none)
		{
			if (`PRES.m_eUIMode != eUIMode_Shell)
			{
				ActiveTooltip.HideTooltip();
			}

			XComPresentationLayerBase(Owner).m_kTooltipMgr.DeactivateTooltip(ActiveTooltip, true);
			ActiveTooltip = none;
		}

		if (MechaListItem != none)
		{
			if (MechaListItem.BG.bHasTooltip)
			{
				ActiveTooltip = UITextTooltip(Movie.Pres.m_kTooltipMgr.GetTooltipByID(MechaListItem.BG.CachedTooltipId));
				if (ActiveTooltip != none)
				{
					ActiveTooltip.SetFollowMouse(false);
					ActiveTooltip.SetTooltipPosition(950.0, MechaListItem.Y - SBOffset + 180);
					ActiveTooltip.SetDelay(0);
					ActiveTooltip.ShowTooltip();
					XComPresentationLayerBase(Owner).m_kTooltipMgr.ActivateTooltip(ActiveTooltip);
				}
			}
		}
	}
}

function OnScrollPercentChanged( float newPercent )
{
	SBOffset = newPercent * ScrollHeight;
	if (ActiveTooltip != none)
	{
		ActiveTooltip.SetTooltipPosition(950.0, MechaListItem.Y - SBOffset + 180);
	}
}

//Determines if a change is necessary in the Navhelp
//Mr. Nice: Also stash MechaListItem in properties, useful elsewhere!
simulated function UpdateMechItemNavHelp(UIList ContainerList, int Index)
{
	local int NewMechaListItemType; //enum EUILineItemType found in UIMechaListItem;

	if(AttentionType == COAT_CATEGORIES) return; // Mr. Nice: Will get "spurious" Update when backing out
	//Checks to see if the selected list item is the same as the previously selected list item (to determine if we need to refresh the navhelp)
	MechaListItem = UIMechaListItem(ContainerList.GetSelectedItem());
	if(MechaListItem != None)
	{
		NewMechaListItemType = int(MechaListItem.Type);
		if(NewMechaListItemType != MechaListItemType)
		{
			MechaListItemType = NewMechaListItemType;
			UpdateNavHelp();
		}
	}
}

// Special button handlers ========================================================================

simulated function OnSaveAndExit(UIButton kButton)
{
    local MCM_SettingsPanel TmpPage;
    
    // Save all.
    foreach SettingsPanels(TmpPage)
    {
        TmpPage.TriggerSaveEvent();
    }
	CloseScreen();
}

simulated function OnCancel(UIButton kButton)
{
    local MCM_SettingsPanel TmpPage;
    
    // Cancel all.
    foreach SettingsPanels(TmpPage)
    {
        TmpPage.TriggerCancelEvent();
    }
	CloseScreen();
}

function GoBack()
{
	local UIList List;

	switch(AttentionType)
	{
	case COAT_CATEGORIES:
		OnCancel(none);
		break;

	case COAT_DETAILS:
		if(MechaListItemType == EUILineItemType_Dropdown && MechaListItem.Dropdown.isOpen)
		{
			MechaListItem.Dropdown.BackOut();
		}
		else
		{
			AttentionType = COAT_CATEGORIES;
			TabsList.SetSelectedNavigation();
			MechaListItem.OnLoseFocus();
			List = UIList(MechaListItem.GetParent(class'UIList'));
			List.SetSelectedIndex(0);
			if (List.Scrollbar !=none)
			{
				List.Scrollbar.SetThumbAtPercent(0);
			}
			if (ActiveTooltip != none)
			{
				Movie.Pres.m_kTooltipMgr.DeactivateTooltip(ActiveTooltip, true);
				ActiveTooltip = none;
			}
			UpdateNavHelp();
		}
		Movie.Pres.PlayUISound(eSUISound_MenuClose); //bsg-crobinson (5.9.17): Add close menu sound on back
		break;
	}
}

simulated function CloseScreen()
{
	Super.CloseScreen();
	// Mr. Nice: UIOptionsPCScreen isn't used to being revealed from the stack,needs a prompt to update NavHelp
	UIOptionsPCScreen(Movie.Stack.GetCurrentScreen()).UpdateNavHelp();
}

// Keyboard input ============================================================================

simulated function bool OnUnrealCommand(int cmd, int arg)
{
    if( !CheckInputIsReleaseOrDirectionRepeat(cmd, arg) )
        return false;

    switch( cmd )
    {
		case class'UIUtilities_Input'.const.FXS_R_MOUSE_DOWN:
			OnCancel(none);
	        return true;

        case class'UIUtilities_Input'.const.FXS_BUTTON_B:
        case class'UIUtilities_Input'.const.FXS_KEY_ESCAPE:
			GoBack();
	        return true;

		case class'UIUtilities_Input'.const.FXS_ARROW_DOWN:
		case class'UIUtilities_Input'.const.FXS_DPAD_DOWN:
		case class'UIUtilities_Input'.const.FXS_VIRTUAL_LSTICK_DOWN:
		case class'UIUtilities_Input'.const.FXS_ARROW_UP:
		case class'UIUtilities_Input'.const.FXS_DPAD_UP:
		case class'UIUtilities_Input'.const.FXS_VIRTUAL_LSTICK_UP:
			if(MechaListItemType == EUILineItemType_Dropdown && MechaListItem.Dropdown.isOpen)
			{
				// Mr. Nice: Let the dropdown handle it, will get consumed by the UIList otherwise
				return MechaListItem.OnUnrealCommand(cmd, arg);
			}
			break;

        case class'UIUtilities_Input'.const.FXS_BUTTON_X:
			OnSaveAndExit(none);
			return true;
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

simulated function MCM_SettingsPanel GetPanelByPageID(int PageID)
{
    local MCM_SettingsPanel TmpPage;

    foreach SettingsPanels(TmpPage)
    {
        if (TmpPage.GetPageID() == PageID)
            return TmpPage;
    }

    return None;
}

simulated function ChoosePanelByPageID(int PageID)
{
    //local MCM_SettingsPanel CurrentSettingsPage;
    local MCM_SettingsTab TmpButton;
    local MCM_SettingsPanel TmpPage;

    // Are we changing pages? Do nothing if not changing pages.
    if (PageID != SelectedPageID)
    {
        SelectedPageID = PageID;
        
        // Now choose the panel.
        foreach SettingsPanels(TmpPage)
        {
            if (TmpPage.GetPageID() != SelectedPageID)
            {
                TmpPage.Hide();
            }
            else
            {
                `log("MCM: Found correct panel, showing.");
                TmpPage.Show();
				 SelectSettingsPanel(TmpPage);
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
	else
	{
		// Mr. Nice: although no hide/show to do, move navigation into the tab for controller/keyboard support
		foreach SettingsPanels(TmpPage)
        {
            if (TmpPage.GetPageID() == SelectedPageID)
			{
                `log("MCM: Found correct panel, navigating.");
				 SelectSettingsPanel(TmpPage);
            }
        }
	}
}

simulated function SelectSettingsPanel(MCM_SettingsPanel Tab)
{
	Movie.Pres.PlayUISound(eSUISound_MenuSelect);
	AttentionType = COAT_DETAILS;
	Tab.SetSelectedNavigation();
	UpdateMechItemNavHelp(Tab.SettingsList, 0);
	ScrollHeight = Tab.SettingsList.TotalItemSize - Tab.SettingsList.Height - 55;
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
	if(TabsList.bSelectFirstAvailable && TabsList.ItemCount == 1)
	{
		Item.SetSelectedNavigation();
	}
    Item.OnClickHandler = TabClickedHandler;

    SettingsTabs.AddItem(Item);
}

function MCM_API_SettingsPage MakeSettingsPage(string TabLabel, int PageID)
{
    local MCM_SettingsPanel SP;
    SP = Spawn(class'MCM_SettingsPanel', Container);
    SP.OptionsScreen = self;
    SP.InitPanel();
    SP.SettingsPageID = PageID;
    SP.SetPosition(TABLIST_WIDTH + OPTIONS_MARGIN, HEADER_HEIGHT);

    SP.SetPageTitle(TabLabel);

    // By default do not show the panel.
    SP.Hide();

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
	if(TabsList.bSelectFirstAvailable && TabsList.ItemCount == 1)
	{
		Item.SetSelectedNavigation();
	}
    Item.CustomPageCallback = Handler;
    Item.OnClickHandler = CustomTabClickedHandler;

    return PageID;
}

function MCM_API_SettingsPage GetSettingsPageByID(int PageID)
{
    local MCM_SettingsPanel TmpPage;

    foreach SettingsPanels(TmpPage)
    {
        if (TmpPage.GetPageID() == PageID)
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