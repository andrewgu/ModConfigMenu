//-----------------------------------------------------------
//	Class:	MCM_Builder_SingletonFactory
//	Author: Musashi
//	
//-----------------------------------------------------------
class MCM_Builder_SingletonFactory extends Object implements(MCM_Builder_SingletonFactoryInterface) config(Null);

struct ManagerInstanceCache
{
	var string InstanceName;
	var JsonConfig_Manager Manager;
};

struct MCMBuilderInstanceCache
{
	var string InstanceName;
	var JsonConfig_MCM_Builder Builder;
};

// only config for fake singleton
var config array<ManagerInstanceCache> ManagerInstances;
var config array<MCMBuilderInstanceCache> MCMBuilderInstances;

static function JsonConfig_ManagerInterface GetManagerInstance(string InstanceName, optional bool bHasDefaultConfig = true)
{
	local MCM_Builder_SingletonFactory Instance;
	local JsonConfig_ManagerInterface JsonConfigManagerInterface;
	local ManagerInstanceCache NewManagerInstance;
	local int Index;

	Index = default.ManagerInstances.Find('InstanceName', InstanceName);
	if (Index == INDEX_NONE)
	{
		JsonConfigManagerInterface = class'JsonConfig_Manager'.static.GetConfigManager(InstanceName, bHasDefaultConfig);

		`LOG(default.class @ GetFuncName() @ "create singleton instance" @ JsonConfigManagerInterface,, 'ModConfigMenuBuilder');

		NewManagerInstance.InstanceName = InstanceName;
		NewManagerInstance.Manager = JsonConfig_Manager(JsonConfigManagerInterface);
		default.ManagerInstances.AddItem(NewManagerInstance);
		return JsonConfig_ManagerInterface(NewManagerInstance.Manager);
	}

	return JsonConfig_ManagerInterface(default.ManagerInstances[Index].Manager);
}

static function JsonConfig_MCM_Builder GetMCMBuilderInstance(string InstanceName)
{
	local MCMBuilderInstanceCache NewBuilderInstance;
	local int Index;

	Index = default.MCMBuilderInstances.Find('InstanceName', InstanceName);
	if (Index == INDEX_NONE)
	{
		NewBuilderInstance.InstanceName = InstanceName;
		NewBuilderInstance.Builder = class'JsonConfig_MCM_Builder'.static.GetMCMBuilder(InstanceName);
		default.MCMBuilderInstances.AddItem(NewBuilderInstance);
		
		return NewBuilderInstance.Builder;
	}

	return default.MCMBuilderInstances[Index].Builder;
}