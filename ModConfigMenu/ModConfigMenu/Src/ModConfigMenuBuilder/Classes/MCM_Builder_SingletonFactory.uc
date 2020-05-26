//-----------------------------------------------------------
//	Class:	MCM_Builder_SingletonFactory
//	Author: Musashi
//	
//-----------------------------------------------------------
class MCM_Builder_SingletonFactory extends Actor implements(MCM_Builder_SingletonFactoryInterface) config(Game);

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

var array<ManagerInstanceCache> ManagerInstances;
var array<MCMBuilderInstanceCache> MCMBuilderInstances;

var config string SINGLETON_PATH;


static function JsonConfig_ManagerInterface GetManagerInstance(string InstanceName, optional bool bHasDefaultConfig = true)
{
	local MCM_Builder_SingletonFactory Instance;
	local JsonConfig_ManagerInterface JsonConfigManagerInterface;
	local ManagerInstanceCache NewManagerInstance;
	local int Index;
	
	Instance = MCM_Builder_SingletonFactory(FindObject(default.SINGLETON_PATH, default.Class));

	if (Instance == none)
	{
		Instance = class'WorldInfo'.static.GetWorldInfo().Spawn(default.Class);
		//`LOG(default.class @ GetFuncName() @ "Create new instance" @ default.SINGLETON_PATH,, 'ModConfigMenuBuilder');
		default.SINGLETON_PATH = PathName(Instance);
	}

	Index = Instance.ManagerInstances.Find('InstanceName', InstanceName);
	if (Index == INDEX_NONE)
	{
		JsonConfigManagerInterface = class'JsonConfig_Manager'.static.GetConfigManager(InstanceName, bHasDefaultConfig);

		NewManagerInstance.InstanceName = InstanceName;
		NewManagerInstance.Manager = JsonConfig_Manager(JsonConfigManagerInterface);
		Instance.ManagerInstances.AddItem(NewManagerInstance);
		
		return JsonConfig_ManagerInterface(NewManagerInstance.Manager);
	}

	return JsonConfig_ManagerInterface(Instance.ManagerInstances[Index].Manager);
}

static function JsonConfig_MCM_Builder GetMCMBuilderInstance(string InstanceName)
{
	local MCM_Builder_SingletonFactory Instance;
	local MCMBuilderInstanceCache NewBuilderInstance;
	local int Index;
	
	Instance = MCM_Builder_SingletonFactory(FindObject(default.SINGLETON_PATH, default.Class));

	if (Instance == none)
	{
		Instance = class'WorldInfo'.static.GetWorldInfo().Spawn(default.Class);
		//`LOG(default.class @ GetFuncName() @ "Create new instance" @ default.SINGLETON_PATH,, 'ModConfigMenuBuilder');
		default.SINGLETON_PATH = PathName(Instance);
	}

	Index = Instance.MCMBuilderInstances.Find('InstanceName', InstanceName);
	if (Index == INDEX_NONE)
	{
		NewBuilderInstance.InstanceName = InstanceName;
		NewBuilderInstance.Builder = class'JsonConfig_MCM_Builder'.static.GetMCMBuilder(InstanceName);
		Instance.MCMBuilderInstances.AddItem(NewBuilderInstance);
		
		return NewBuilderInstance.Builder;
	}

	return Instance.MCMBuilderInstances[Index].Builder;
}