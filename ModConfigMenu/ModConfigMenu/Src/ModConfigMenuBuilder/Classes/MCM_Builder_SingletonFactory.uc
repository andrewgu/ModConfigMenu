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

static function MCM_Builder_Interface GetMCMBuilderInstance(string InstanceName)
{
	local MCM_Builder_Interface BuilderInterface;
	local MCMBuilderInstanceCache NewBuilderInstance;
	local int Index;

	Index = default.MCMBuilderInstances.Find('InstanceName', InstanceName);
	if (Index == INDEX_NONE)
	{
		BuilderInterface = class'JsonConfig_MCM_Builder'.static.GetMCMBuilder(InstanceName);

		`LOG(default.class @ GetFuncName() @ "create singleton instance" @ BuilderInterface,, 'ModConfigMenuBuilder');

		NewBuilderInstance.InstanceName = InstanceName;
		NewBuilderInstance.Builder = JsonConfig_MCM_Builder(BuilderInterface);
		default.MCMBuilderInstances.AddItem(NewBuilderInstance);
		
		return MCM_Builder_Interface(NewBuilderInstance.Builder);
	}

	return MCM_Builder_Interface(default.MCMBuilderInstances[Index].Builder);
}