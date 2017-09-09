class MCM_LegacyDlcCleanerUI extends Object config(ModConfigMenu);

`include(ModConfigMenu/Src/ModConfigMenuAPI/MCM_API_Includes.uci)

var config name LEGACY_DEPENDENCY_DLC_NAME;

var MCM_API_SettingsPage Page1;
var MCM_API_Button P1Button;

function OnInit(UIScreen Screen)
{
    if (MCM_API(Screen) != none)
    {
        `MCM_API_Register(Screen, ClientModCallback);
    }
}

function ClientModCallback(MCM_API_Instance ConfigAPI, int GameMode)
{
    local MCM_API_SettingsGroup Group;

    if (GameMode == eGameMode_Strategy || GameMode == eGameMode_Tactical)
    {
        Page1 = ConfigAPI.NewSettingsPage("MCM Legacy Cleaner");
        Page1.SetPageTitle("DLC Cleaner");

        Group = Page1.AddGroup('Group1', "Settings");

        P1Button = Group.AddButton('CleanDlcNames', "Clean DLC Names", "Removes dependency on temporary (incorrect) DLC name.", "Clean", ButtonClickedHandler);

        Page1.ShowSettings();
    }
}

`MCM_API_BasicButtonHandler(ButtonClickedHandler)
{
    TryToRemoveLegacyDependency();
}

static function TryToRemoveLegacyDependency()
{
    local XComGameStateHistory History;
	local XComOnlineEventMgr EventManager;
	local name DLCName;
	local XComGameState_CampaignSettings Settings;
	local int i;

    `Log("MCM Legacy: Attempting to remove legacy dependency.");
	
	EventManager = `ONLINEEVENTMGR;
	History = `XCOMHISTORY;
	Settings = XComGameState_CampaignSettings(History.GetSingleGameStateObjectForClass(class'XComGameState_CampaignSettings', true));
	Settings.RemoveAllRequiredDLC();
	for(i = 0; i < EventManager.GetNumDLC(); ++i)
	{
		DLCName = EventManager.GetDLCNames(i);
        // Add everything back EXCEPT the legacy DLC name.
		if(DLCName != default.LEGACY_DEPENDENCY_DLC_NAME)
		{
            `Log("MCM Legacy: Keeping mod " $ string(DLCName));
			Settings.AddRequiredDLC(DLCName);
		}
        else
        {
            `Log("MCM Legacy: Removed legacy DLC name from save.");
        }
	}
}