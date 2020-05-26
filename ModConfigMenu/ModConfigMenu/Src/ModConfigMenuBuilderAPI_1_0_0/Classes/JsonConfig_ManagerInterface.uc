//-----------------------------------------------------------
//	Class:	JsonConfig_ManagerInterface
//	Author: Musashi
//	DO NOT MAKE ANY CHANGES TO THIS CLASS
//-----------------------------------------------------------
interface JsonConfig_ManagerInterface;

static public function JsonConfig_ManagerInterface GetConfigManager(string InstanceName, optional bool bHasDefaultConfig = true);

static public function JsonConfig_ManagerInterface GetDefaultConfigManager();

public function SerializeAndSaveConfig();

public function bool HasConfigProperty(coerce string PropertyName, optional string Namespace);

public function SetConfigString(string PropertyName, coerce string Value);

public function int GetConfigIntValue(coerce string PropertyName, optional string TagFunction, optional string Namespace);

public function float GetConfigFloatValue(coerce string PropertyName, optional string TagFunction, optional string Namespace);

public function name GetConfigNameValue(coerce string PropertyName, optional string TagFunction, optional string Namespace);

public function int GetConfigByteValue(coerce string PropertyName, optional string TagFunction, optional string Namespace);

public function bool GetConfigBoolValue(coerce string PropertyName, optional string TagFunction, optional string Namespace);

public function array<int> GetConfigIntArray(coerce string PropertyName, optional string TagFunction, optional string Namespace);

public function array<float> GetConfigFloatArray(coerce string PropertyName, optional string TagFunction, optional string Namespace);

public function array<name> GetConfigNameArray(coerce string PropertyName, optional string TagFunction, optional string Namespace);

public function vector GetConfigVectorValue(coerce string PropertyName, optional string TagFunction, optional string Namespace);

public function array<string> GetConfigStringArray(coerce string PropertyName, optional string TagFunction, optional string Namespace);

public function WeaponDamageValue GetConfigDamageValue(coerce string PropertyName, optional string Namespace);

public function string GetConfigStringValue(coerce string PropertyName, optional string TagFunction, optional string Namespace);

public function string GetConfigTagValue(coerce string PropertyName, optional string Namespace);

