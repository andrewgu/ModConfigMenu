//---------------------------------------------------------------------------------------
//  FILE:   XComDownloadableContentInfo_MCMBuilderClientTestMod.uc                                    
//           
//	Use the X2DownloadableContentInfo class to specify unique mod behavior when the 
//  player creates a new campaign or loads a saved game.
//  
//---------------------------------------------------------------------------------------
//  Copyright (c) 2016 Firaxis Games, Inc. All rights reserved.
//---------------------------------------------------------------------------------------

class X2DownloadableContentInfo_MCMBuilderClientTestMod extends X2DownloadableContentInfo;

static function bool AbilityTagExpandHandler(string InString, out string OutString)
{
	local JsonConfig_ManagerInterface ConfigManager;
	local string PossibleValue;

	ConfigManager = class'ConfigFactory'.static.GetConfigManager("MCMBuilderClientTestModConfigManager");

	PossibleValue = ConfigManager.GetConfigTagValue(InString);
	if (PossibleValue != "")
	{
		OutString = PossibleValue;
		return true;
	}

	return false;
}
