class MCM_SettingBase extends UIMechaListItem implements(MCM_API_Setting);

var eSettingType SettingType;
var name SettingName;
// Don't need this because we can just use the Desc object.
//var string DisplayLabel;
var string DisplayTooltip;


// Force different init pattern.
simulated function UIMechaListItem InitListItem()
{
    `log("Don't use this.");
    // Intentionally make this break stuff.
    return none;
}

// This is the real initializer.
simulated function MCM_SettingBase InitSettingsItem(name _Name, eSettingType _Type, optional string _Label = "", optional string _Tooltip = "")
{
    super.InitListItem();

    SettingName = _Name;
    //ChangedHandler = Handler;
    SettingType = _Type;

    DisplayTooltip = _Tooltip;

    return self;
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
    Desc.SetText(NewLabel);
}

simulated function string GetLabel()
{
    return Desc.text;
}

// When you mouse-over the setting.
simulated function SetHoverTooltip(string Tooltip)
{
    // Doesn't inherently store Tooltip text so we'll remember it.
    DisplayTooltip = Tooltip;
    
    if (BG.bHasTooltip)
        BG.RemoveTooltip();

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
    SetDisabled(!IsEditable);
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