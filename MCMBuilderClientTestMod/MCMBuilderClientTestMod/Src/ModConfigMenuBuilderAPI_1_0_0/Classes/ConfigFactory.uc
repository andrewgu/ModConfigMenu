//-----------------------------------------------------------
//	Class:	ConfigFactory
//	Author: Musashi
//	DO NOT MAKE ANY CHANGES TO THIS CLASS
//-----------------------------------------------------------
class ConfigFactory extends Object;

static function JsonConfig_ManagerInterface GetConfigManager(string ManagerName)
{
	local MCM_Builder_SingletonFactoryInterface SingletonFactoryInterface;
	local object SingletonFactoryCDO;
	
	SingletonFactoryCDO = class'XComEngine'.static.GetClassDefaultObjectByName('MCM_Builder_SingletonFactory');
	SingletonFactoryInterface = MCM_Builder_SingletonFactoryInterface(SingletonFactoryCDO);
	return SingletonFactoryInterface.static.GetManagerInstance(ManagerName);
}

static function MCM_Builder_Interface GetMCMBuilder(string BuilderName)
{
	local MCM_Builder_SingletonFactoryInterface SingletonFactoryInterface;
	local object SingletonFactoryCDO;
	
	SingletonFactoryCDO = class'XComEngine'.static.GetClassDefaultObjectByName('MCM_Builder_SingletonFactory');
	SingletonFactoryInterface = MCM_Builder_SingletonFactoryInterface(SingletonFactoryCDO);
	return SingletonFactoryInterface.static.GetMCMBuilderInstance(BuilderName);
}