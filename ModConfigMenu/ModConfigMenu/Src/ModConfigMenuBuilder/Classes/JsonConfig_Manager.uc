class JsonConfig_Manager extends JsonConfig implements (JsonConfig_ManagerInterface) config(JsonConfigManager_NullConfig) perobjectconfig;

struct ConfigPropertyMapEntry
{
	var string PropertyName;
	var JsonConfig_TaggedConfigProperty ConfigProperty;
};

var config array<string> ConfigProperties;
var protectedwrite array<ConfigPropertyMapEntry> DeserialzedConfigPropertyMap;
var JsonConfig_Manager DefaultConfigManager;

delegate bool TagFunctionDelegate(name TagFunctionName, JsonConfig_TaggedConfigProperty ConfigProperty, out string TagValue);


public function array<string> GetConfig()
{
	return ConfigProperties;
}

static public function JsonConfig_ManagerInterface GetConfigManager(string InstanceName, optional bool bHasDefaultConfig = true)
{
	local JsonConfig_Manager ConfigManager;

	// ConfigManager = JsonConfig_Manager(class'Engine'.FindClassDefaultObject(ClassNameParam));

	ConfigManager = new (none, InstanceName) default.class;
	
	//`LOG(default.class @ GetFuncName() @ `ShowVar(ConfigManager) @ `ShowVar(InstanceName) @ `ShowVar(default.class) @ `ShowVar(JsonConfig_ManagerInterface(ConfigManager)),, 'ModConfigMenuBuilder');

	ConfigManager.DeserializeConfig();

	if (bHasDefaultConfig)
	{
		ConfigManager.SetDefaultConfigManager(InstanceName);
	}

	return JsonConfig_ManagerInterface(ConfigManager);
}

public function JsonConfig_ManagerInterface GetDefaultConfigManager()
{
	return JsonConfig_ManagerInterface(DefaultConfigManager);
}

public function SetDefaultConfigManager(string InstanceName)
{
	local JsonConfig_ManagerInterface LocalJsonConfig_ManagerInterface;
	LocalJsonConfig_ManagerInterface = class'JsonConfig_ManagerDefault'.static.GetConfigManager(InstanceName, false);
	DefaultConfigManager = JsonConfig_Manager(LocalJsonConfig_ManagerInterface);
	//`LOG(default.class @ GetFuncName() @ `ShowVar(InstanceName) @ `ShowVar(DefaultConfigManager),, 'ModConfigMenuBuilder');
}

public function SerializeAndSaveConfig()
{
	SerializeConfig();
	SaveConfig();
}

private function DeserializeConfig()
{
	local ConfigPropertyMapEntry MapEntry;
	local JSonObject JSonObject, JSonObjectProperty;
	local JsonConfig_TaggedConfigProperty ConfigProperty;
	local string SerializedConfigProperty, PropertyName;
	local array<string> Sections;

	GetPerObjectConfigSections(self.Class, Sections);

	//`LOG(default.class @ GetFuncName() @ self.Name @ "found entries:" @ ConfigProperties.Length @ Sections[0],, 'ModConfigMenuBuilder');

	foreach ConfigProperties(SerializedConfigProperty)
	{
		PropertyName = GetObjectKey(SanitizeJson(SerializedConfigProperty));
		JSonObject = class'JSonObject'.static.DecodeJson(SanitizeJson(SerializedConfigProperty));

		if (JSonObject != none && PropertyName != "")
		{
			JSonObjectProperty = JSonObject.GetObject(PropertyName);

			if (JSonObjectProperty != none &&
				DeserialzedConfigPropertyMap.Find('PropertyName', PropertyName) == INDEX_NONE)
			{
				ConfigProperty = new class'JsonConfig_TaggedConfigProperty';
				ConfigProperty.ManagerInstance = self;
				ConfigProperty.Deserialize(JSonObjectProperty);
				MapEntry.PropertyName = PropertyName;
				MapEntry.ConfigProperty = ConfigProperty;
				DeserialzedConfigPropertyMap.AddItem(MapEntry);
			}
		}
	}
}

private function SerializeConfig()
{
	local ConfigPropertyMapEntry MapEntry;
	local JSonObject JSonObject;

	ConfigProperties.Length = 0;

	foreach DeserialzedConfigPropertyMap(MapEntry)
	{
		JSonObject = new () class'JsonObject';
		JSonObject.SetObject(MapEntry.PropertyName, MapEntry.ConfigProperty.Serialize());
		ConfigProperties.AddItem(class'JSonObject'.static.EncodeJson(JSonObject));
	}
}

public function bool HasConfigProperty(coerce string PropertyName, optional string Namespace)
{
	PropertyName = GetPropertyName(PropertyName, Namespace);

	return DeserialzedConfigPropertyMap.Find('PropertyName', PropertyName) != INDEX_NONE;
}

public function SetConfigString(string PropertyName, coerce string Value)
{
	local JsonConfig_TaggedConfigProperty ConfigProperty;
	local ConfigPropertyMapEntry MapEntry;

	if (HasConfigProperty(PropertyName))
	{
		ConfigProperty = GetConfigProperty(PropertyName);
		ConfigProperty.SetValue(Value);
	}
	else
	{
		ConfigProperty = new class'JsonConfig_TaggedConfigProperty';
		ConfigProperty.ManagerInstance = self;
		ConfigProperty.SetValue(Value);

		MapEntry.PropertyName = PropertyName;
		MapEntry.ConfigProperty = ConfigProperty;

		DeserialzedConfigPropertyMap.AddItem(MapEntry);
	}
}

public function int GetConfigIntValue(coerce string PropertyName, optional string TagFunction, optional string Namespace)
{
	return int(GetConfigStringValue(PropertyName, TagFunction, Namespace));
}

public function float GetConfigFloatValue(coerce string PropertyName, optional string TagFunction, optional string Namespace)
{
	return float(GetConfigStringValue(PropertyName, TagFunction, Namespace));
}

public function name GetConfigNameValue(coerce string PropertyName, optional string TagFunction, optional string Namespace)
{
	return name(GetConfigStringValue(PropertyName, TagFunction, Namespace));
}

public function int GetConfigByteValue(coerce string PropertyName, optional string TagFunction, optional string Namespace)
{
	return byte(GetConfigStringValue(PropertyName, TagFunction, Namespace));
}

public function bool GetConfigBoolValue(coerce string PropertyName, optional string TagFunction, optional string Namespace)
{
	return bool(GetConfigStringValue(PropertyName, TagFunction, Namespace));
}

public function array<int> GetConfigIntArray(coerce string PropertyName, optional string TagFunction, optional string Namespace)
{
	local array<string> StringArray;
	local string Value;
	local array<int> IntArray;

	StringArray = GetConfigStringArray(PropertyName, TagFunction, Namespace);

	foreach StringArray(Value)
	{
		IntArray.AddItem(int(Value));
	}

	return IntArray;
}

public function array<float> GetConfigFloatArray(coerce string PropertyName, optional string TagFunction, optional string Namespace)
{
	local array<string> StringArray;
	local string Value;
	local array<float> FloatArray;

	StringArray = GetConfigStringArray(PropertyName, TagFunction, Namespace);

	foreach StringArray(Value)
	{
		FloatArray.AddItem(float(Value));
	}

	return FloatArray;
}

public function array<name> GetConfigNameArray(coerce string PropertyName, optional string TagFunction, optional string Namespace)
{
	local array<string> StringArray;
	local string Value;
	local array<name> NameArray;

	StringArray = GetConfigStringArray(PropertyName, TagFunction, Namespace);

	foreach StringArray(Value)
	{
		NameArray.AddItem(name(Value));
	}

	return NameArray;
}

public function vector GetConfigVectorValue(coerce string PropertyName, optional string TagFunction, optional string Namespace)
{
	local JsonConfig_TaggedConfigProperty ConfigProperty;

	ConfigProperty = GetConfigProperty(PropertyName);

	if (ConfigProperty != none)
	{
		////`LOG(default.class @ GetFuncName() @ `ShowVar(PropertyName) @ "Value:" @ ConfigProperty.VectorValue.ToString() @ `ShowVar(Namespace),, 'ModConfigMenuBuilder');
		return ConfigProperty.GetVectorValue();
	}

	return vect(0, 0, 0);
}

public function array<string> GetConfigStringArray(coerce string PropertyName, optional string TagFunction, optional string Namespace)
{
	local JsonConfig_TaggedConfigProperty ConfigProperty;
	local array<string> EmptyArray;

	ConfigProperty = GetConfigProperty(PropertyName, Namespace);

	if (ConfigProperty != none)
	{
		////`LOG(default.class @ GetFuncName() @ `ShowVar(PropertyName) @ "Value:" @ ConfigProperty.ArrayValue.ToString() @ `ShowVar(Namespace),, 'ModConfigMenuBuilder');
		return ConfigProperty.GetArrayValue();
	}

	EmptyArray.Length = 0; // Prevent unassigned warning

	return EmptyArray;
}

public function WeaponDamageValue GetConfigDamageValue(coerce string PropertyName, optional string Namespace)
{
	local JsonConfig_TaggedConfigProperty ConfigProperty;
	local WeaponDamageValue Value;

	ConfigProperty = GetConfigProperty(PropertyName, Namespace);

	if (ConfigProperty != none)
	{
		Value =  ConfigProperty.GetDamageValue();
		////`LOG(default.class @ GetFuncName() @ `ShowVar(PropertyName) @ "Value:" @ ConfigProperty.DamageValue.ToString() @ `ShowVar(Namespace),, 'ModConfigMenuBuilder');
	}

	return Value;
}

public function string GetConfigStringValue(coerce string PropertyName, optional string TagFunction, optional string Namespace)
{
	local JsonConfig_TaggedConfigProperty ConfigProperty;
	local string Value;

	ConfigProperty = GetConfigProperty(PropertyName, Namespace);

	if (ConfigProperty != none)
	{
		Value =  ConfigProperty.GetValue(TagFunction);
		////`LOG(default.class @ GetFuncName() @ `ShowVar(PropertyName) @ `ShowVar(Value) @ `ShowVar(TagFunction) @ `ShowVar(Namespace),, 'ModConfigMenuBuilder');
	}

	return Value;
}

public function string GetConfigTagValue(coerce string PropertyName, optional string Namespace)
{
	local JsonConfig_TaggedConfigProperty ConfigProperty;

	ConfigProperty = GetConfigProperty(PropertyName, Namespace);

	if (ConfigProperty != none)
	{
		return ConfigProperty.GetTagValue();
	}

	return  "";
}


public function JsonConfig_TaggedConfigProperty GetConfigProperty(
	coerce string PropertyName,
	optional string Namespace
)
{
	local int Index;
	
	PropertyName = GetPropertyName(PropertyName, Namespace);

	Index = DeserialzedConfigPropertyMap.Find('PropertyName', PropertyName);
	if (Index != INDEX_NONE)
	{
		return DeserialzedConfigPropertyMap[Index].ConfigProperty;
	}

	if (DefaultConfigManager != none)
	{
		return DefaultConfigManager.GetConfigProperty(PropertyName, Namespace);
	}

	//`LOG(default.class @ GetFuncName() @ "could not find config property for" @ PropertyName @ DeserialzedConfigPropertyMap.Length,, 'ModConfigMenuBuilder');

	return none;
}
