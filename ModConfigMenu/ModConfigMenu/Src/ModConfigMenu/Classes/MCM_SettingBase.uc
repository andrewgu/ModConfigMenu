class MCM_SettingBase extends UIMechaListItem implements(MCM_API_Setting);

var eSettingType SettingType;
var name SettingName;
// Don't need this because we can just use the Desc object.
var string DisplayLabel;
var string DisplayTooltip;


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
    ApplyTooltip();
}

// Puts DisplayTooltip on the BG panel, where the mouse events of the row originate from.
// The tooltip can only be registered once the BG exists on the flash side (bIsInited): until then it is set from the BG's OnInit callback.
// It must also be (re)applied after UIMechaListItem.SetDisabled, which removes the BG tooltip when no "disabled reason" is given
// (see SetEditable): the tooltip was lost right after having been set the first time a page was displayed.
simulated function ApplyTooltip()
{
    if (BG.bIsInited)
    {
        BG.SetTooltipText(DisplayTooltip);
    }
    else
    {
        // AddOnInitDelegate does not add the same delegate twice.
        BG.AddOnInitDelegate(OnBGInited);
    }
}

simulated function OnBGInited(UIPanel Panel)
{
    BG.SetTooltipText(DisplayTooltip);
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

    ApplyTooltip();
}

simulated function string GetHoverTooltip()
{
    return DisplayTooltip;
}

// Lets you show an option but disable it because it shouldn't be configurable.
// For example, if you don't want to allow tweaking during a mission.
simulated function SetEditable(bool IsEditable)
{
    SetDisabled(!IsEditable);

    // SetDisabled removed the BG tooltip: put it back.
    ApplyTooltip();
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