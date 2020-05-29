class JsonConfig_MCM_Builder extends JsonConfig implements(MCM_Builder_Interface) config(MCMBuilder) perobjectconfig perobjectlocalized;

struct MCMConfigMapEntry
{
	var string PageID;
	var JsonConfig_MCM_Page MCMConfigPage;
};

var config array<string> MCMPages;
var protectedwrite array<MCMConfigMapEntry> DeserialzedPagesMap;
var string BuilderName;
var array<ObjectKey> ObjectKeys;

public function array<string> GetConfig()
{
	return MCMPages;
}

static public function MCM_Builder_Interface GetMCMBuilder(string InstanceName)
{
	local JsonConfig_MCM_Builder MCMBuilder;

	MCMBuilder = new (none, InstanceName) default.class;
	MCMBuilder.DeserializeConfig();
	MCMBuilder.BuilderName = InstanceName;

	return MCM_Builder_Interface(MCMBuilder);
}

public function string GetBuilderName()
{
	return BuilderName;
}

public function string LocalizeItem(string Key)
{
	local string Locale;

	Locale = Localize(name @ default.class, Key, "ModConfigMenu");

	if (InStr(Locale, "?INT?") > 0)
	{
		//`LOG(default.class @ GetFuncName() @ "Warning localization not found:" @ Key @ "in" @ name @ default.class,, 'ModConfigMenuBuilder');
	}
	
	return Locale;
}

public function SerializeAndSaveBuilderConfig()
{
	SerializeConfig();
	SaveConfig();
}

private function DeserializeConfig()
{
	local MCMConfigMapEntry MapEntry;
	local JSonObject JSonObject;
	local JsonConfig_MCM_Page MCMPage;
	local ObjectKey ObjKey;
	local string SanitizedJsonString, SerializedMCMPage;
	local array<string> LocalMCMPages;

	////`LOG(default.class @ GetFuncName() @ "found entries:" @ MCMPages.Length,, 'ModConfigMenuBuilder');

	LocalMCMPages = GetConfig();

	foreach LocalMCMPages(SerializedMCMPage)
	{
		SanitizedJsonString = SanitizeJson(SerializedMCMPage);

		if (SanitizedJsonString != "")
		{
			ObjectKeys = GetAllObjectKeys(SanitizedJsonString);
			JSonObject = class'JSonObject'.static.DecodeJson(SanitizedJsonString);
	
			foreach ObjectKeys(ObjKey)
			{
				if (JSonObject != none && ObjKey.ParentKey == "")
				{
					if (DeserialzedPagesMap.Find('PageID', ObjKey.Key) == INDEX_NONE)
					{
						MCMPage = new class'JsonConfig_MCM_Page';
						if (MCMPage.Deserialize(JSonObject, ObjKey.Key, self))
						{
							MapEntry.PageID = ObjKey.Key;
							MapEntry.MCMConfigPage = MCMPage;
							DeserialzedPagesMap.AddItem(MapEntry);
						}
					}
				}
			}
		}
	}
}

public function SerializeConfig()
{
	local MCMConfigMapEntry MapEntry;
	local JSonObject JSonObject;

	MCMPages.Length = 0;

	foreach DeserialzedPagesMap(MapEntry)
	{
		JSonObject = new () class'JsonObject';
		MapEntry.MCMConfigPage.Serialize(JSonObject, MapEntry.PageID);
		MCMPages.AddItem(class'JSonObject'.static.EncodeJson(JSonObject));
	}
}
