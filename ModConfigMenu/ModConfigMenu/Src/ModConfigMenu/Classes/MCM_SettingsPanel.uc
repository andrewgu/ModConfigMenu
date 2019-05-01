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
var MCM_OptionsScreen OptionsScreen;
var bool NavSortEnabled; // Mr. Nice: When controls are made editable *after* the page has instantiated,
						// then the Navigation Order must be sorted to match the list (ie visual) order.
var byte ShowStatus; // 0=Show not requested; 1 = Show requested; 2= Show complete
						
var MCM_UISettingSeparator TitleLine;
var UIImage bottomPadding;
var UIButton ResetButton;
var string Title;
var float DropAllowance;
var int DropIndexOffSet;

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

    //SettingsList = Spawn(class'UIList', self).InitList('OptionsList', 0, 0, PANEL_WIDTH, PANEL_HEIGHT - FOOTER_HEIGHT - 40,, true);
	SettingsList = Spawn(class'UIList', self).InitList('OptionsList', 0, 0, PANEL_WIDTH, PANEL_HEIGHT - FOOTER_HEIGHT + 29,, true); // Mr. Nice: addBG to stop mouse scrolling "dead spots"
    SettingsList.SetSelectedNavigation();
	SettingsList.OnSelectionChanged = OptionsScreen.OnSelectionChanged;
	SettingsList.BG.SetAlpha(0);

    return self;
}

simulated function OnInit()
{
    super.OnInit();
}

simulated function OnResetClicked(UIButton kButton)
{
    if (ResetHandler != none)
	{
		Movie.Pres.PlayUISound(eSUISound_MenuSelect);
        ResetHandler(self);
	}
}

simulated function Show()
{
    local MCM_SettingGroup iter;

	// Mr. Nice: Originally all the ShowSettings() would get handled in one tick, since they ultimately
	// Get called from the OnInit() in the mods UISL, all of which get called in the same tick after the panel itself is Innited.
	// Now Super Lazy and only do it when about to be shown!
	if (ShowStatus == 1)
	{
		RealShowSettings();
	}
    super.Show();

	OptionsScreen.CurrentPanel = self;
	OPtionsScreen.ScrollHeight = SettingsList.TotalItemSize - SettingsList.Height;
    // Now that it's visible, need to trigger the post-visibility update.
    foreach SettingGroups(iter)
    {
        iter.AfterParentPageDisplayed();
    }
}

simulated function Hide()
{
	Super.Hide();

	if (OptionsScreen.CurrentPanel == self)
	{
		OptionsScreen.CurrentPanel = none;
		class'UIUtilities_Controls'.static.CloseAllDropdowns(self);
		OPtionsScreen.SettingsTabs[SettingsPageID].ResetAppearance();
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

	if (ResetButton == none)
	{
		SettingsList.SetHeight(PANEL_HEIGHT - FOOTER_HEIGHT - 28);
		RealiseSettingsList();
		ResetButton = Spawn(class'UIButton', self);
		ResetButton.bIsNavigable = false;
		ResetButton.InitButton(, Caps(class'UIPhotoboothBase'.default.m_CategoryReset), OnResetClicked, eUIButtonStyle_HOTLINK_BUTTON);
		ResetButton.SetPosition(RESET_BUTTON_X, PANEL_HEIGHT - FOOTER_HEIGHT + 3); //Relative to this screen panel
		ResetButton.SetGamepadIcon(class'UIUtilities_Input'.const.ICON_BACK_SELECT);
	}
}

// Groups let you visually cluster settings.
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

// Mr. Nice: Instantiating all the UI can be quite slow, so defer until the Panel is about to be shown
function ShowSettings()
{
	ShowStatus = 1;
}

function RealShowSettings()
{
    // This is where magic happens.
    local int groupIndex, i;
	local byte bFoundDropdown;
	local UIPanel tmpItem;

    // Adds padding at bottom to make sure that bottom options are visisble.
	bottomPadding = Spawn(class'UIImage', SettingsList.itemContainer);
	bottomPadding.bProcessesMouseEvents = true;
	bottomPadding.bShouldPlayGenericUIAudioEvents = false;
	bottomPadding.Width = PANEL_WIDTH;
    bottomPadding.InitImage('MCMBottomPadding',"img:///MCM.gfx.Transparent");
	DropAllowance = 160;
	DropIndexOffSet = 1;

    for (groupIndex = SettingGroups.Length - 1; groupIndex >= 0; groupIndex--) 
    {
        SettingGroups[groupIndex].InstantiateItems(SettingsList, DropAllowance, DropIndexOffSet, bFoundDropdown);
    }

	if(bFoundDropdown == 0 || !`ISCONTROLLERACTIVE && DropAllowance <= 0)
	{
		bottomPadding.Remove();
		bottomPadding = none;
	}

    TitleLine = Spawn(class'MCM_UISettingSeparator', SettingsList.itemContainer);
    TitleLine.InitSeparator();
    TitleLine.UpdateTitle(Title != "" ? Title : "Mod Settings");
    TitleLine.SetY(0);
	
	for(i = 0; i < SettingsList.ItemContainer.ChildPanels.Length /2; i++)
	{
		tmpItem = SettingsList.ItemContainer.ChildPanels[i];
		SettingsList.ItemContainer.ChildPanels[i] = SettingsList.ItemContainer.ChildPanels[SettingsList.ItemContainer.ChildPanels.Length - 1 - i];
		SettingsList.ItemContainer.ChildPanels[SettingsList.ItemContainer.ChildPanels.Length - 1 - i] = tmpItem;
	}
	RealiseSettingsList(true);

	if (SettingsList.Scrollbar != none)
	{
		SettingsList.Scrollbar.NotifyPercentChange(OptionsScreen.OnScrollPercentChanged);
	}
	NavSortEnabled = true;
	NavSort();
	ShowStatus = 2;
}

function RealiseSettingsList( optional bool force)
{
	local float PaddingSize;

	if(`ISCONTROLLERACTIVE || force)
	{
		if(force)
		{
			SettingsList.RealizeItems();
		}
		if(bottomPadding != none)
		{
			if( SettingsList.ItemContainer.ChildPanels.Find(bottomPadding) != INDEX_NONE)
			{
				SettingsList.ItemContainer.RemoveChild(bottomPadding);
				force = false; //Mr. Nice: All force obligations met now
			}
			if (`ISCONTROLLERACTIVE)
			{
				// Controllers can't directly control the scroll bar, it's position when on the last drop down
				// must make allowance for this. Maths, it just werks!
				if ( 0 < DropAllowance * (SettingsList.ItemCount-1) + (SettingsList.TotalItemSize - SettingsList.Height) * (DropIndexOffSet-1) )
				PaddingSize = (DropAllowance * SettingsList.ItemCount + (SettingsList.TotalItemSize - SettingsList.Height) * DropIndexOffSet) / (SettingsList.ItemCount - DropIndexOffSet);
				`log(`showvar(DropAllowance));
				`log(`showvar(PaddingSize));
				`log(`showvar((SettingsList.TotalItemSize - SettingsList.Height)));
				`log(`showvar(SettingsList.ItemCount));
				`log(`showvar(DropIndexOffSet));
			}
			else
			{
				PaddingSize = DropAllowance;
			}
			if(PaddingSize > 0)
			{
				bottomPadding.SetHeight(PaddingSize);
				bottomPadding.Show();
				SettingsList.ItemContainer.AddChild(bottomPadding);
			}
			else
			{
				bottomPadding.Hide();
				if(force)
				{
					SettingsList.RealizeItems();
				}
			}
		}
		else
		{
			SettingsList.RealizeList();
		}
	}
}

function NavSort()
{
	if(NavSortEnabled)
	{
		SettingsList.Navigator.NavigableControls.Sort(ListIndexOrder);
	}
}

function int ListIndexOrder(UIPanel FirstItem, UIPanel SecondItem)
{
	return SettingsList.GetItemIndex(SecondItem) - SettingsList.GetItemIndex(FirstItem);
}

simulated function OnReceiveFocus()
{
	Super.OnReceiveFocus();
	if(bIsFocused)
	{
		OptionsScreen.AttentionType = COAT_DETAILS;
		OptionsScreen.UpdateMechItemNavHelp(SettingsList, SettingsList.SelectedIndex);
	}
}

simulated function OnLoseFocus()
{
	Super.OnLoseFocus();
	OptionsScreen.AttentionType = COAT_CATEGORIES;
}

defaultproperties
{
    bProcessesMouseEvents = false;
	bCascadeFocus = false;
	bIsVisible = false;
}