class X2DownloadableContentInfo_MCMLegacy extends X2DownloadableContentInfo config(ModConfigMenu);

var config bool AUTO_REMOVE_LEGACY_DEPENDENCY;
var config name LEGACY_DEPENDENCY_DLC_NAME;

static event OnLoadedSavedGame()
{
    `Log("MCM Legacy: DLCInfo legacy dependency removal check triggered.");
    if (default.AUTO_REMOVE_LEGACY_DEPENDENCY)
    {
        TryToRemoveLegacyDependency();
    }
}

static event OnLoadedSavedGameToStrategy()
{
    `Log("MCM Legacy: DLCInfo legacy dependency removal check triggered.");
    if (default.AUTO_REMOVE_LEGACY_DEPENDENCY)
    {
        TryToRemoveLegacyDependency();
    }
}

static function TryToRemoveLegacyDependency()
{
    local XComGameStateHistory History;
	local XComOnlineEventMgr EventManager;
	local name DLCName;
	local XComGameState_CampaignSettings Settings;
	local int i;
	
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
            `Log("MCM Legacy: Removed legacy DLC name from save.");
			Settings.AddRequiredDLC(DLCName);
		}
	}
}

defaultproperties
{
}