class MCM_SettingsTab extends UIMechaListItem;

var int SettingsPageID;
var MCM_OptionsScreen OptionsScreen;
var MCM_SettingsPanel SettingsPanel;
var delegate<MCM_API_Instance.CustomSettingsPageCallback> CustomPageCallback;

var bool MouseClick;
function MCM_SettingsTab InitSettingsTab(int PageID, string Label)
{
    InitListItem();
    SettingsPageID = PageID;
	
    //UpdateDataCheckbox(Label, "", false, CheckboxChangedCallback, CheckboxClickedCallback);
	UpdateDataDescription(Label, OnSelect);
    return self;
}

// Mr. Nice: UIMechaListItem implementation calls RefreshButtonVisibility(), which resets the appearance...
simulated function OnMouseEvent( int cmd, array<string> args )
{
	super(UIPanel).OnMouseEvent(cmd, args);

	if( cmd == class'UIUtilities_Input'.const.FXS_L_MOUSE_UP )
	{
		MouseClick = true;
		Click();
	}
	else if( cmd == class'UIUtilities_Input'.const.FXS_L_MOUSE_OUT || cmd == class'UIUtilities_Input'.const.FXS_L_MOUSE_DRAG_OUT )
		OnLoseFocus();
}

function OnSelect()
{
    `log("MCM Tab clicked: " $ string(SettingsPageID));
	if (OptionsScreen.CurrentPanel != none && OptionsScreen.CurrentPanel != SettingsPanel)
	{
		OptionsScreen.CurrentPanel.Hide();
	}

	if (SettingsPanel != none)
	{
		`log("MCM: Found correct panel, showing.");
		SettingsPanel.Show();
		// Mr. Nice: Don't bother navigating into panels with nothing to navigate there!
		if (SettingsPanel.SettingsList.Navigator.NavigableControls.Length != 0)
		{
			SettingsPanel.SetSelectedNavigation();
			// Mr. Nice: if selection from a mouse click, then focus will be lost when
			// the mouse is moved off the Tab instead.
			if (!MouseClick)
			{
				OnLoseFocus();
				SettingsPanel.SettingsList.Navigator.SelectFirstAvailable();
				SettingsPanel.SettingsList.Scrollbar.SetThumbAtPercent(0);
			}
			else
			{
				OnReceiveFocus(); // Mr. Nice: to update the appearance
				MouseClick = false;
			}
		}
		else
		{
			if (MouseClick) // Mr. Nice: Confirm keyb/controller nav is on the left, otherwise may get trapped in the panel just hidden!
			{
				OptionsScreen.TabsList.SetSelectedNavigation();
				OptionsScreen.AttentionType = COAT_CATEGORIES;
				MouseClick = false;
			}
			else
			{
				OnReceiveFocus(); // Mr. Nice: to update the appearance
			}
		}
	}
	else if (CustomPageCallback != none)
    {
        CustomPageCallback(OptionsScreen, SettingsPageID);
		if (MouseClick) // Mr. Nice: Confirm keyb/controller nav is on the left, otherwise may get trapped in the panel just hidden!
		{
			OptionsScreen.TabsList.SetSelectedNavigation();
			OptionsScreen.AttentionType = COAT_CATEGORIES;
			MouseClick = false;
		}
    }
}

// Mr. Nice: Want more UIButton like behaviour, which is easier then you might think because UIMechaListItem
// has the same background, just need to poke it with some flash magic...
simulated function OnReceiveFocus()
{
	Super.OnReceiveFocus();
	// Mr. Nice: should check if we actually had focus set, for example focus is refused if init stuff isn't complete yet
	if (bIsFocused)
	{
		if(OptionsScreen.CurrentPanel != SettingsPanel || SettingsPanel == none)
		{
			BG.MC.FunctionString("gotoAndStop", "_SelectedOver");
		}
		else
		{
			BG.MC.FunctionString("gotoAndPlay", "_SelectedOver"); // Make the button pulse to show it is doubly blessed!
		}
	}
}

// Mr. Nice: When without focus, want to indicate if we are the currently displayed settings tab or not
simulated function OnLoseFocus()
{
	Super.OnLoseFocus();
	if(OptionsScreen.CurrentPanel == SettingsPanel && SettingsPanel != none)
	{
		BG.MC.FunctionString("gotoAndStop", "_SelectedUp");
		Desc.MC.ChildFunctionBool("text", "highlight", true);
	}
}

function ResetAppearance()
{
	BG.MC.FunctionString("gotoAndStop", "_Up");
	Desc.MC.ChildFunctionBool("text", "highlight", false);
}