class MCM_SettingBase extends UIMechaListItem implements(MCM_API_Setting);

var eSettingType SettingType;
var name SettingName;
// Don't need this because we can just use the Desc object.
var string DisplayLabel;
var string DisplayTooltip;
var string NavSound;


// Force different init pattern.
//simulated function UIMechaListItem InitListItem(optional name InitName, optional int defaultWidth = -1)
//{
//    `log("Don't use this.");
//    // Intentionally make this break stuff.
//    return none;
//}

// This is the real initializer.
simulated function MCM_SettingBase InitSettingsItem(name _Name, eSettingType _Type, optional string _Label = "", optional string _Tooltip = "")
{
    super.InitListItem();

    SettingName = _Name;
    //ChangedHandler = Handler;
    SettingType = _Type;

    DisplayLabel = _Label;
    Desc.SetText(DisplayLabel);

    DisplayTooltip = _Tooltip;
    //SetHoverTooltip(DisplayTooltip);

    return self;
}

simulated function AfterParentPageDisplayed()
{
    // Apparently you have to set it once the screen element is actually visible.
    BG.SetTooltipText(DisplayTooltip);
}

simulated function bool OnUnrealCommand(int cmd, int arg)
{
	if (Super.OnUnrealCommand(cmd, arg))
	{
		switch( cmd )
		{
			case class'UIUtilities_Input'.const.FXS_R_MOUSE_DOWN: // Mr. Nice: Rmouse is flipped to escape somewhere, so no point pretending we can treat it differently...
			case class'UIUtilities_Input'.const.FXS_BUTTON_B:
			case class'UIUtilities_Input'.const.FXS_KEY_ESCAPE:
				Movie.Pres.PlayUISound(eSUISound_MenuClose);
				break;

			case class'UIUtilities_Input'.const.FXS_BUTTON_A:
			case class'UIUtilities_Input'.const.FXS_KEY_ENTER:
			case class'UIUtilities_Input'.const.FXS_KEY_SPACEBAR:
				Movie.Pres.PlayUISound(eSUISound_MenuSelect);
				break;

			case class'UIUtilities_Input'.const.FXS_ARROW_DOWN:
			case class'UIUtilities_Input'.const.FXS_DPAD_DOWN:
			case class'UIUtilities_Input'.const.FXS_VIRTUAL_LSTICK_DOWN:
			case class'UIUtilities_Input'.const.FXS_ARROW_UP:
			case class'UIUtilities_Input'.const.FXS_DPAD_UP:
			case class'UIUtilities_Input'.const.FXS_VIRTUAL_LSTICK_UP:
			case class'UIUtilities_Input'.const.FXS_ARROW_LEFT:
			case class'UIUtilities_Input'.const.FXS_DPAD_LEFT:
			case class'UIUtilities_Input'.const.FXS_VIRTUAL_LSTICK_LEFT:
			case class'UIUtilities_Input'.const.FXS_ARROW_RIGHT:
			case class'UIUtilities_Input'.const.FXS_DPAD_RIGHT:
			case class'UIUtilities_Input'.const.FXS_VIRTUAL_LSTICK_RIGHT:
				`SOUNDMGR.PlaySoundEvent(NavSound);
				break;
		}
		return true;
	}
	return false;
}

// MCM_API_Setting implementation ==========================================================================

// Name is used for ID purposes, not for UI.
simulated function name GetName()
{
    return SettingName;
}

// Label is used for UI purposes, not for ID.
simulated function SetLabel(string NewLabel)
{
    DisplayLabel = NewLabel;
    Desc.SetText(NewLabel);
}

simulated function string GetLabel()
{
    return DisplayLabel;
}

// When you mouse-over the setting.
simulated function SetHoverTooltip(string Tooltip)
{
    // Doesn't inherently store Tooltip text so we'll remember it.
    DisplayTooltip = Tooltip;

    BG.SetTooltipText(Tooltip);
}

simulated function string GetHoverTooltip()
{
    return DisplayTooltip;
}

// Lets you show an option but disable it because it shouldn't be configurable.
// For example, if you don't want to allow tweaking during a mission.
simulated function SetEditable(bool IsEditable)
{
    // Mr. Nice: SetDisabled kills the tooltip unless you pass it again!
    SetDisabled(!IsEditable, DisplayTooltip);
	if(IsEditable)
	{	
		if(default.bIsNavigable)
		{
			EnableNavigation();
			bShouldPlayGenericUIAudioEvents = true;
		}
		MCM_SettingsPanel(GetParent(class'MCM_SettingsPanel')).NavSort();
	}
	else
	{
		if(default.bIsNavigable)
		{
			DisableNavigation();
			bShouldPlayGenericUIAudioEvents = false;
		}
	}
}

// Retrieves underlying setting type. Defined as an int to make setting types more extensible to support
// future "extension types".
simulated function int GetSettingType()
{
    return SettingType;
}

simulated function MCM_API_SettingsGroup GetParentGroup()
{
    // MCM_SettingBase derived classes will never get GetParentGroup called because it's handled by the 
    // Facade object that wraps it.
    return None;
}

defaultproperties
{
	NavSound = "Play_Mouseover"
}