//-----------------------------------------------------------
//	Class:	Helper
//	Author: Musashi
//	
//-----------------------------------------------------------


class Helper extends Object;

const CONFIG_MANAGER = "MCMBuilderClientTestModConfigManager";

public static final function JsonConfig_ManagerInterface GetConfig()
{
	return class'ConfigFactory'.static.GetConfigManager(CONFIG_MANAGER);
}