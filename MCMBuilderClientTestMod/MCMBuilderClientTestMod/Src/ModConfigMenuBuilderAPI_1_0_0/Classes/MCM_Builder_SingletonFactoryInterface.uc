//-----------------------------------------------------------
//	Class:	MCM_Builder_SingletonFactoryInterface
//	Author: Musashi
//	DO NOT MAKE ANY CHANGES TO THIS CLASS
//-----------------------------------------------------------

interface MCM_Builder_SingletonFactoryInterface;

static function JsonConfig_ManagerInterface GetManagerInstance(string InstanceName, optional bool bHasDefaultConfig = true);

static function MCM_Builder_Interface GetMCMBuilderInstance(string InstanceName);