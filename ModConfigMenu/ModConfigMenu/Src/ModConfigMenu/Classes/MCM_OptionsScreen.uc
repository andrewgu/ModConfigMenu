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
var localized string m_strScroll;

var MCM_OptionsMenuListener ParentListener;

var UIPanel Container;
var UIImage BG;
var UIImage VSeparator;
var UIX2PanelHeader TitleHeader;

var UIList TabsList;
var array<MCM_SettingsTab> SettingsTabs;
var array<MCM_SettingsPanel> SettingsPanels;
var MCM_SettingsPanel CurrentPanel;
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
    
    TabsList = Spawn(class'UIList', Container).InitList('ModTabSelectList', 10, HEADER_HEIGHT + TABS_LIST_TOP_PADDING, TABLIST_WIDTH - 30, OPTIONS_HEIGHT,, true); // Mr. Nice: addBG to stop mouse scrolling "dead spots"
	TabsList.BG.SetAlpha(0);
    TabsList.SetSelectedNavigation();
	if (MouseActive)
	{
		TabsList.bSelectFirstAvailable = false;
	}
}

simulated function UpdateNavHelp( bool bWipeButtons = false )
{
	local UIScrollbar SB;
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
			SB = CurrentPanel.SettingsList.Scrollbar;
		}
		else //COAT_CATEGORIES
		{
			SB = TabsList.ScrollBar;
			NavHelp.AddSelectNavHelp();
		}
		if(SB != none)
		{
			NavHelp.AddLeftHelp(m_strScroll, class'UIUtilities_Input'.const.ICON_RSTICK);
		}
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
					ActiveTooltip.SetTooltipPosition(950.0, MechaListItem.Y - SBOffset);
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
	SBOffset = newPercent * ScrollHeight + default.SBOffset;
	if (ActiveTooltip != none)
	{
		ActiveTooltip.SetTooltipPosition(950.0, MechaListItem.Y - SBOffset);
	}
}

//Determines if a change is necessary in the Navhelp
//Mr. Nice: Also stash MechaListItem in properties, useful elsewhere!
simulated function UpdateMechItemNavHelp(UIList ContainerList, int Index)
{
	local int NewMechaListItemType; //enum EUILineItemType found in UIMechaListItem;

	// Checks to see if the selected list item is the same as the previously selected list item (to determine if we need to refresh the navhelp)
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
	else
	{
		MechaListItemType = -1;
		UpdateNavHelp();
	}
}

// Special button handlers ========================================================================

simulated function OnSaveAndExit(UIButton kButton)
{
    local MCM_SettingsPanel TmpPage;

    Movie.Pres.PlayUISound(eSUISound_MenuSelect);
    // Save all.
    foreach SettingsPanels(TmpPage)
    {
		if(TmpPage != none)
		{
			TmpPage.TriggerSaveEvent();
		}
    }
	CloseScreen();
}

simulated function OnCancel(UIButton kButton)
{
    local MCM_SettingsPanel TmpPage;
    
    // Cancel all.
    foreach SettingsPanels(TmpPage)
    {
		if(TmpPage != none)
		{
	        TmpPage.TriggerCancelEvent();
		}
    }
	CloseScreen();
}

function GoBack()
{
	switch(AttentionType)
	{
	case COAT_CATEGORIES:
		OnCancel(none);
		return;

	case COAT_DETAILS:
		AttentionType = COAT_CATEGORIES;
		TabsList.SetSelectedNavigation();
		MechaListItem.OnLoseFocus();
		CurrentPanel.SettingsList.SetSelectedIndex(-1);
		if (CurrentPanel.SettingsList.Scrollbar !=none)
		{
			CurrentPanel.SettingsList.Scrollbar.SetThumbAtPercent(0);
		}
		Movie.Pres.PlayUISound(eSUISound_MenuClose); //bsg-crobinson (5.9.17): Add close menu sound on back
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
	local UIScrollBar SB;

    if( !CheckInputIsReleaseOrDirectionRepeat(cmd, arg) )
        return false;
	
	if(!`SCREENSTACK.IsTopScreen(self))
	{
		// Mr. Nice Ok we're getting unhandled input from a Custom Settings Screen,
		// We should therefore do nothing, *except* handle the "B" button to allow controllers
		// to escape custom screens with absolutely no controller support!
		if ( cmd == class'UIUtilities_Input'.const.FXS_BUTTON_B && `ISCONTROLLERACTIVE)
		{
			`SCREENSTACK.PopUntil(self);
			Movie.Pres.PlayUISound(eSUISound_MenuClose);
			return true;
		}
		return false;
	}

	if(AttentionType == COAT_DETAILS && MechaListItem != none && MechaListItem.OnUnrealCommand(cmd, arg))
	{
		return true;
	}

    switch( cmd )
    {
		case class'UIUtilities_Input'.const.FXS_R_MOUSE_DOWN: // Mr. Nice: Rmouse is flipped to escape somewhere, so no point pretending we can treat it differently...
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
			// Mr. Nice: Stop Navigator getting confused...
			if (AttentionType == COAT_DETAILS && CurrentPanel.SettingsList.Navigator.NavigableControls.Length == 1)
			{
				PlaySound( SoundCue'SoundUI.MenuScrollCue', true );
				CurrentPanel.SettingsList.NavigatorSelectionChanged(0);
				return true;
			}
			break;

		case class'UIUtilities_Input'.const.FXS_VIRTUAL_RSTICK_DOWN:
		case class'UIUtilities_Input'.const.FXS_KEY_PAGEDN:
			SB = AttentionType == COAT_CATEGORIES ? TabsList.ScrollBar : CurrentPanel.SettingsList.Scrollbar;
			if (SB != none)
			{
				SB.OnMouseScrollEvent(-1);
			}
			return true;
		case class'UIUtilities_Input'.const.FXS_VIRTUAL_RSTICK_UP:
		case class'UIUtilities_Input'.const.FXS_KEY_PAGEUP:
			SB = AttentionType == COAT_CATEGORIES ? TabsList.ScrollBar : CurrentPanel.SettingsList.Scrollbar;
			if (SB != none)
			{
				SB.OnMouseScrollEvent(1);
			}
			return true;

        case class'UIUtilities_Input'.const.FXS_BUTTON_X:
			OnSaveAndExit(none);
			return true;
        case class'UIUtilities_Input'.const.FXS_BUTTON_SELECT:
			if(CurrentPanel != none)
			{
				CurrentPanel.OnResetClicked(none);
			}
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
	return SettingsPanels[PageID];
}

simulated function AddTabsListButton(string TabLabel)
{
    local MCM_SettingsTab Item; 
    Item = Spawn(class'MCM_SettingsTab', TabsList.ItemContainer).InitSettingsTab(SettingsTabs.Length, TabLabel);
	if(TabsList.bSelectFirstAvailable && TabsList.ItemCount == 1)
	{
		Item.SetSelectedNavigation();
	}
	Item.OptionsScreen = self;
	Item.SettingsPanel = SettingsPanels[Item.SettingsPageID];

    SettingsTabs.AddItem(Item);
}

function MCM_API_SettingsPage MakeSettingsPage(string TabLabel)
{
    local MCM_SettingsPanel SP;

	SP = Spawn(class'MCM_SettingsPanel', Container);
    SP.OptionsScreen = self;
    SP.InitPanel();
    SP.SettingsPageID = SettingsPanels.Length;
    SP.SetPosition(TABLIST_WIDTH + OPTIONS_MARGIN, HEADER_HEIGHT);

    SP.SetPageTitle(TabLabel);

    // Register panel.
    SettingsPanels.AddItem(SP);

    return SP;
}

// MCM_API_Instance implementation ===============================================================

function MCM_API_SettingsPage NewSettingsPage(string TabLabel)
{
	local MCM_API_SettingsPage NewPage;

    NewPage = MakeSettingsPage(TabLabel);
    AddTabsListButton(TabLabel);

	return NewPage;
}

function int NewCustomSettingsPage(string TabLabel, delegate<CustomSettingsPageCallback> Handler)
{
    local MCM_SettingsTab Item; 

    Item = Spawn(class'MCM_SettingsTab', TabsList.ItemContainer).InitSettingsTab(SettingsTabs.Length, TabLabel);
	if(TabsList.bSelectFirstAvailable && TabsList.ItemCount == 1)
	{
		Item.SetSelectedNavigation();
	}
    Item.CustomPageCallback = Handler;
	Item.OptionsScreen = self;

	SettingsTabs.AddItem(Item);
	SettingsPanels.AddItem(none);

    return Item.SettingsPageID;
}

function MCM_API_SettingsPage GetSettingsPageByID(int PageID)
{
	return SettingsPanels[PageID];
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

    SoldierVisible = true;

    InputState= eInputState_Evaluate;

    bAlwaysTick = true
    bConsumeMouseEvents=true
	SBOffset = -180
}