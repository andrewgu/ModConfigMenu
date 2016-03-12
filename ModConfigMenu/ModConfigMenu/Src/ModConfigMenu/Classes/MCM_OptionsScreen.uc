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

// Needs major version match and requested minor version needs to be <= actual minor version.
var config int API_MAJOR_VERSION;
var config int API_MINOR_VERSION;

var localized string m_strTitle;
var localized string m_strSubtitle;
var localized string m_strSaveAndExit;

var MCM_OptionsMenuListener ParentListener;

var UIPanel Container;
var UIImage BG;
var UIImage VSeparator;
var UIX2PanelHeader TitleHeader;

//var UIPanel TabsPanel;
var UIList TabsList;
var int SettingsPageCounter;
var int SelectedPageID;
//var array<MCM_UIListItemString_SelfContained> SettingsButtons;
var array<MCM_SettingsTab> SettingsTabs;
var array<MCM_SettingsPanel> SettingsPanels;
var UIButton SaveAndExitButton;

var int CurrentGameMode;
//var array<delegate<ClientModCallback> > ClientModCallbacks;

delegate ClientModCallback(MCM_API_Instance ConfigAPI, int GameMode);
delegate OnClickedDelegate(UIButton Button);
//delegate SettingsTabDelegate(MCM_UIListItemString_SelfContained Caller);
delegate SettingsTabDelegate(MCM_SettingsTab Caller, int PageID);
delegate CustomSettingsPageCallback(UIScreen ParentScreen, int PageID);

simulated function InitScreen(XComPlayerController InitController, UIMovie InitMovie, optional name InitName)
{
	`log("MCM InitScreen called.");

    super.InitScreen(InitController, InitMovie, InitName);

	UpdateGameMode();
    CreateSkeleton();
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
	
	VSeparator = Spawn(class'UIImage', Container).InitImage(,"img:///MCM.gfx.MainVerticalSeparator");
	VSeparator.SetPosition(TABLIST_WIDTH,HEADER_HEIGHT);
    
	TitleHeader = Spawn(class'UIX2PanelHeader', Container);
	TitleHeader.InitPanelHeader('', m_strTitle, m_strSubtitle);
	TitleHeader.SetHeaderWidth(Container.width - 20);
	TitleHeader.SetPosition(10, 10);
    
    TabsList = Spawn(class'UIList', Container).InitList('ModTabSelectList', 10, HEADER_HEIGHT + TABS_LIST_TOP_PADDING, TABLIST_WIDTH - 30, OPTIONS_HEIGHT);
    TabsList.SetSelectedNavigation();
	TabsList.Navigator.LoopSelection = true;

    //TestCreateTabButtons();

    // Save and exit button    
    SaveAndExitButton = Spawn(class'UIButton', Container);
	SaveAndExitButton.InitButton(, m_strSaveAndExit, SaveAndExit);
	SaveAndExitButton.SetPosition(Container.width - 190, Container.height - 40); //Relative to this screen panel

    Navigator.SetSelected(TabsList);
    TabsList.Navigator.SelectFirstAvailableIfNoCurrentSelection();
}

simulated function TabClickedHandler(MCM_SettingsTab Caller, int PageID)
{
	`log("MCM Tab clicked: " $ string(PageID));
	//TabsList.SetSelectedItem(kButton, true);
	ChoosePanelByPageID(PageID);
}

simulated function AddTabsListButton(string TabLabel, int PageID, delegate<SettingsTabDelegate> callback)
{
    local MCM_SettingsTab Item; 
    Item = Spawn(class'MCM_SettingsTab', TabsList.ItemContainer).InitSettingsTab(PageID, TabLabel);
	Item.OnClickHandler = TabClickedHandler;

	SettingsTabs.AddItem(Item);
}

simulated function SaveAndExit(UIButton kButton)
{
    Movie.Stack.Pop(self);
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

function bool HasUnsavedChanges()
{
	return true;
}

function bool WarnAboutUnsavedChanges()
{
	return true;
}

// MCM_API_Instance implementation ===============================================================
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
	local MCM_SettingsPanel CurrentSettingsPage;
	local MCM_SettingsTab TmpButton;
	local MCM_SettingsPanel TmpPage;

	CurrentSettingsPage = GetPanelByPageID(SelectedPageID);

	// Are we changing pages? Do nothing if not changing pages.
	if (PageID != SelectedPageID)
	{
		// Okay, we're changing pages.
		if (CurrentSettingsPage != none && HasUnsavedChanges())
		{
			if (WarnAboutUnsavedChanges())
			{
				// User decided to discard and continue.
				CurrentSettingsPage.RevertHandler(CurrentSettingsPage);
				SelectedPageID = PageID;
			}
			else
			{
				// User decided to come back. So we need to do nothing.
				`log("MCM: User aborted tab switch.");
				// SelectedPageID = SelectedPageID;
			}
		}
		else
		{
			SelectedPageID = PageID;
		}

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

simulated function OnSettingsTabClicked(MCM_SettingsTab Caller, int PageID)
{
	ChoosePanelByPageID(PageID);
}

function MCM_API_SettingsPage MakeSettingsPage(string TabLabel, int PageID)
{
	local MCM_SettingsPanel SP;
	SP = Spawn(class'MCM_SettingsPanel', Container);
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

function MCM_API_SettingsPage NewSettingsPage(string TabLabel)
{
	local int PageID;

	PageID = SettingsPageCounter;
	SettingsPageCounter++;

	AddTabsListButton(TabLabel, PageID, OnSettingsTabClicked);

	return MakeSettingsPage(TabLabel, PageID);
}

simulated function CustomTabClickedHandler(MCM_SettingsTab Caller, int PageID)
{
	`log("MCM Custom Screen Tab clicked");
	if (Caller.CustomPageCallback != none)
	{
		Caller.CustomPageCallback(self, PageID);
	}
}

function NewCustomSettingsPage(string TabLabel, delegate<CustomSettingsPageCallback> Handler)
{
	local MCM_SettingsTab Item; 
	local int PageID;

	PageID = SettingsPageCounter;
	SettingsPageCounter++;

    Item = Spawn(class'MCM_SettingsTab', TabsList.ItemContainer).InitSettingsTab(PageID, TabLabel);
	Item.CustomPageCallback = Handler;
	Item.OnClickHandler = CustomTabClickedHandler;
}

defaultproperties
{
    ParentListener = None;
	SettingsPageCounter = 0;
	SelectedPageID = -1;

	bAlwaysTick = true
	bConsumeMouseEvents=true
}