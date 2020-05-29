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
	local string PossibleValue;

	PossibleValue = class'Helper'.static.GetConfig().GetConfigTagValue(InString);
	if (PossibleValue != "")
	{
		OutString = PossibleValue;
		return true;
	}

	return false;
}
