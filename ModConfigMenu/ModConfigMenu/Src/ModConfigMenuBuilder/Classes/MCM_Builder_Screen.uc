//-----------------------------------------------------------
//	Class:	MCM_Builder_Screen
//	Author: Musashi
//	Here we marry the MCMBuilder with the MCM Api
//	ATTENTION: The event api is experimental at the moment and doesnt work if the MCM Options are openend in the Shell screen
//	This could be fixed in the Highlander (https://github.com/X2CommunityCore/X2WOTCCommunityHighlander/issues/297) but even then would need the highlander to work properly
//	Maybe it would be better to replace it by an delegate based system.
//	Note the event system isnt necessary for the basic functionality
//-----------------------------------------------------------
class MCM_Builder_Screen extends Object config(MCMBuilder);

struct BuilderInstance
{
	var int PageId;
	var JsonConfig_MCM_Builder Builder;
};

var config int VERSION_CFG;
var config array<string> MCMBuilder;

var array<BuilderInstance> BuilderInstances;

event OnInit(UIScreen Screen)
{
	if (MCM_API(Screen) != none)
	{
		MCM_API(Screen).RegisterClientMod(1, 0, ClientModCallback);
	}
}

simulated function ClientModCallback(MCM_API_Instance ConfigAPI, int GameMode)
{
	local string BuilderName;

	foreach default.MCMBuilder(BuilderName)
	{
		BuildMCM(
			BuilderName,
			ConfigAPI,
			GameMode
		);
	}
}

simulated function BuildMCM(
	string BuilderName,
	MCM_API_Instance ConfigAPI,
	int GameMode
)
{
	local MCM_Builder_Interface BuilderInterface;
	local BuilderInstance Instance;
	local MCMConfigMapEntry MapEntry;
	local JsonConfig_MCM_Page MCMPageConfig;
	local JsonConfig_MCM_Group MCMGroupConfig;
	local JsonConfig_MCM_Element MCMElementConfig;
	local JsonConfig_ManagerInterface SaveConfigManager;
	local MCM_API_SettingsPage Page;
	local MCM_API_SettingsGroup Group;
	local name SetttingName;
	
	BuilderInterface = class'ConfigFactory'.static.GetMCMBuilder(BuilderName);
	// BuilderInterface = class'MCM_Builder_SingletonFactory'.static.GetMCMBuilderInstance(BuilderName);
	Instance.Builder = JsonConfig_MCM_Builder(BuilderInterface);

	foreach Instance.Builder.DeserialzedPagesMap(MapEntry)
	{
		MCMPageConfig = MapEntry.MCMConfigPage;
		Page = ConfigAPI.NewSettingsPage(MCMPageConfig.GetPageTitle());
		Page.SetPageTitle(MCMPageConfig.GetTabLabel());

		if (MCMPageConfig.ShouldEnableResetButton())
		{
			Page.EnableResetButton(ResetButtonClicked);
		}

		MCMPageConfig.MCMPageId = Page.GetPageId();
		Instance.PageId = Page.GetPageId();
		BuilderInstances.AddItem(Instance);

		foreach MCMPageConfig.Groups(MCMGroupConfig)
		{
			SaveConfigManager = GetConfigManager(MCMPageConfig, MCMGroupConfig);
			
			Group = Page.AddGroup(name(MCMGroupConfig.GetGroupName()), MCMGroupConfig.GetGroupLabel());

			foreach MCMGroupConfig.Elements(MCMElementConfig)
			{
				SetttingName = name(Caps(MCMElementConfig.SettingName));
				
				switch (MCMElementConfig.Type)
				{
					case "Label":
						Group.AddLabel(
							SetttingName,
							MCMElementConfig.GetLabel(),
							MCMElementConfig.GetTooltip()
						);
						break;
					case "Button":
						Group.AddButton(
							SetttingName,
							MCMElementConfig.GetLabel(),
							MCMElementConfig.GetTooltip(),
							MCMElementConfig.ButtonLabel,
							ButtonClickHandler
						);
						break;
					case "Checkbox":
						Group.AddCheckbox(
							SetttingName,
							MCMElementConfig.GetLabel(),
							MCMElementConfig.GetTooltip(),
							SaveConfigManager.GetConfigBoolValue(MCMElementConfig.SettingName),
							BoolSaveHandler,
							BoolChangeHandler
						);
						break;
					case "Slider":
						Group.AddSlider(
							SetttingName,
							MCMElementConfig.GetLabel(),
							MCMElementConfig.GetTooltip(),
							float(MCMElementConfig.SliderMin),
							float(MCMElementConfig.SliderMax),
							float(MCMElementConfig.SliderStep),
							SaveConfigManager.GetConfigFloatValue(MCMElementConfig.SettingName),
							FloatSaveHandler,
							FloatChangeHandler
						);
						break;
					case "Spinner":
						Group.AddSpinner(
							SetttingName,
							MCMElementConfig.GetLabel(),
							MCMElementConfig.GetTooltip(),
							MCMElementConfig.Options.GetArrayValue(),
							SaveConfigManager.GetConfigStringValue(MCMElementConfig.SettingName),
							StringSaveHandler,
							StringChangeHandler
						);
						break;
					case "Dropdown":
						Group.AddDropdown(
							SetttingName,
							MCMElementConfig.GetLabel(),
							MCMElementConfig.GetTooltip(),
							MCMElementConfig.Options.GetArrayValue(),
							SaveConfigManager.GetConfigStringValue(MCMElementConfig.SettingName),
							StringSaveHandler,
							StringChangeHandler
						);
						break;
					default:
						//`LOG(default.class @ GetFuncName() @ "unknown MCM element type" @ MCMElementConfig.Type);
						break;
				}
			}
		}
		
		Page.ShowSettings();
		Page.SetSaveHandler(SaveButtonClicked);
	}
}

simulated function ButtonClickHandler(MCM_API_Setting Setting)
{
	`XEVENTMGR.TriggerEvent('MCM_ButtonClick', Setting, GetBuilder(Setting.GetParentGroup().GetParentPage().GetPageId()), none);
}

simulated function BoolChangeHandler(MCM_API_Setting Setting, bool SettingValue)
{
	ElementChangeHandler(Setting, SettingValue);
}

simulated function BoolSaveHandler(MCM_API_Setting Setting, bool SettingValue)
{
	ElementSaveHandler(Setting, SettingValue);
}

simulated function FloatChangeHandler(MCM_API_Setting Setting, float SettingValue)
{
	ElementChangeHandler(Setting, SettingValue);
}

simulated function FloatSaveHandler(MCM_API_Setting Setting, float SettingValue)
{
	ElementSaveHandler(Setting, SettingValue);
}

simulated function StringChangeHandler(MCM_API_Setting Setting, string SettingValue)
{
	ElementChangeHandler(Setting, SettingValue);
}

simulated function StringSaveHandler(MCM_API_Setting Setting, string SettingValue)
{
	ElementSaveHandler(Setting, SettingValue);
}

simulated function ElementChangeHandler(MCM_API_Setting Setting, coerce string SettingValue)
{
	local JsonObject Tuple;

	Tuple = new class'JsonObject';
	Tuple.SetStringValue("Id", "MCM_ChangeHandler");
	Tuple.SetObject("MCMBuilder", GetBuilder(Setting.GetParentGroup().GetParentPage().GetPageId()));
	Tuple.SetStringValue("SettingValue", SettingValue);
	Tuple.SetStringValue("SettingName", string(Setting.GetName()));
	Tuple.SetStringValue("SettingLabel", Setting.GetLabel());

	`LOG(default.class @ GetFuncName() @ Setting @ Setting.GetName() @ Setting.GetLabel() @ Setting.GetSettingType(),, 'ModConfigMenuBuilder');

	`XEVENTMGR.TriggerEvent('MCM_ChangeHandler', Setting, Tuple, none);
}

simulated function ElementSaveHandler(MCM_API_Setting Setting, coerce string SettingValue)
{
	local JsonConfig_MCM_Page Page;
	local JsonConfig_MCM_Group Group;
	local JsonConfig_ManagerInterface SaveConfigManager;
	local JsonObject Tuple;
	local bool bOverrideDefaultHandler;
	
	bOverrideDefaultHandler = false;

	Tuple = new class'JsonObject';
	Tuple.SetStringValue("Id", "MCM_SaveHandler");
	Tuple.SetObject("MCMBuilder", GetBuilder(Setting.GetParentGroup().GetParentPage().GetPageId()));
	Tuple.SetStringValue("SettingValue", SettingValue);
	Tuple.SetBoolValue("bOverrideDefaultHandler", bOverrideDefaultHandler);
	Tuple.SetStringValue("SettingName", string(Setting.GetName()));
	Tuple.SetStringValue("SettingLabel",Setting.GetLabel());

	`XEVENTMGR.TriggerEvent('MCM_SaveHandler', Setting, Tuple, none);

	if (!Tuple.GetBoolValue("bOverrideDefaultHandler"))
	{
		
		Page = GetPage(Setting.GetParentGroup().GetParentPage().GetPageId());
		Group = GetGroup(
			Setting.GetParentGroup().GetParentPage().GetPageId(),
			Setting.GetParentGroup().GetName()
		);
		SaveConfigManager = GetConfigManager(Page, Group);
		SaveConfigManager.SetConfigString(Caps(string(Setting.GetName())), SettingValue);
	}
}

simulated function SaveButtonClicked(MCM_API_SettingsPage Page)
{
	local JsonConfig_MCM_Page ConfigPage;
	local JsonConfig_MCM_Group ConfigGroup;
	local JsonConfig_Manager SaveConfigManager;
	local JsonConfig_ManagerInterface Temp;
	local JsonObject Tuple;
	local bool bOverrideDefaultHandler;
	local int Index;

	bOverrideDefaultHandler = false;

	Tuple = new class'JsonObject';
	Tuple.SetStringValue("Id", "MCM_SaveButtonClicked");
	Tuple.SetBoolValue("bOverrideDefaultHandler", bOverrideDefaultHandler);
	Tuple.SetObject("MCMBuilder", GetBuilder(Page.GetPageId()));

	`XEVENTMGR.TriggerEvent('MCM_SaveButtonClicked', Page, Tuple, none);

	if (!Tuple.GetBoolValue("bOverrideDefaultHandler"))
	{
		for (Index = 0; Index < Page.GetGroupCount(); Index++)
		{
			ConfigGroup = GetGroup(
				Page.GetPageId(),
				Page.GetGroupByIndex(Index).GetName()
			);
			if (ConfigGroup.SaveConfigManager != "")
			{
				Temp = class'MCM_Builder_SingletonFactory'.static.GetManagerInstance(ConfigGroup.SaveConfigManager);
				SaveConfigManager = JsonConfig_Manager(Temp);
				SaveConfigManager.SerializeAndSaveConfig();
			}
		}

		ConfigPage = GetPage(Page.GetPageId());

		Temp = class'MCM_Builder_SingletonFactory'.static.GetManagerInstance(ConfigPage.SaveConfigManager);
		Temp.SerializeAndSaveConfig();
		
		`XEVENTMGR.TriggerEvent('MCM_ConfigSaved', Page, GetBuilder(Page.GetPageId()), none);
	}
}

simulated function ResetButtonClicked(MCM_API_SettingsPage Page)
{
	local JsonConfig_MCM_Page ConfigPage;
	local JsonConfig_MCM_Group ConfigGroup;
	local JsonConfig_ManagerInterface SaveConfigManager, DefaultConfigManager;
	local int Index;
	local int SettingIndex;
	local MCM_API_SettingsGroup Group;
	local MCM_API_Setting Setting;
	local MCM_API_Checkbox Checkbox;
	local MCM_API_Slider Slider;
	local MCM_API_Spinner Spinner;
	local MCM_API_Dropdown Dropdown;
	local JsonObject Tuple;
	local bool bOverrideDefaultHandler;

	bOverrideDefaultHandler = false;
		
	Tuple = new class'JsonObject';
	Tuple.SetStringValue("Id", "ResetButtonClicked");
	Tuple.SetObject("MCMBuilder", GetBuilder(Page.GetPageId()));
	Tuple.SetBoolValue("bOverrideDefaultHandler", bOverrideDefaultHandler);

	`XEVENTMGR.TriggerEvent('MCM_ResetButtonClicked', Page, Tuple, none);
	if (!Tuple.GetBoolValue("bOverrideDefaultHandler"))
	{
		ConfigPage = GetPage(Page.GetPageId());
		
		for (Index = 0; Index < Page.GetGroupCount(); Index++)
		{
			Group = Page.GetGroupByIndex(Index);

			ConfigGroup = GetGroup(
				Page.GetPageId(),
				Page.GetGroupByIndex(Index).GetName()
			);
			SaveConfigManager = GetConfigManager(ConfigPage, ConfigGroup);
			DefaultConfigManager = SaveConfigManager.GetDefaultConfigManager();

			for (SettingIndex = 0; SettingIndex < Group.GetNumberOfSettings(); SettingIndex++)
			{
				Setting = Group.GetSettingByIndex(SettingIndex);
			
				switch (Setting.GetSettingType())
				{
					case eSettingType_Checkbox:
						Checkbox = MCM_API_Checkbox(Setting);
						Checkbox.SetValue(DefaultConfigManager.GetConfigBoolValue(Checkbox.GetName()), true);
						break;
					case eSettingType_Slider:
						Slider = MCM_API_Slider(Setting);
						Slider.SetValue(DefaultConfigManager.GetConfigFloatValue(Slider.GetName()), true);
						break;
					case eSettingType_Dropdown:
						Dropdown = MCM_API_Dropdown(Setting);
						if (Dropdown == none)
						{
							Spinner = MCM_API_Spinner(Setting);
							Spinner.SetValue(DefaultConfigManager.GetConfigStringValue(Spinner.GetName()), true);
						}
						else
						{
							Dropdown.SetValue(DefaultConfigManager.GetConfigStringValue(Dropdown.GetName()), true);
						}
						break;
					case eSettingType_Spinner:
						Spinner = MCM_API_Spinner(Setting);
						Spinner.SetValue(DefaultConfigManager.GetConfigStringValue(Spinner.GetName()), true);
						break;
				}
			}
		}

		`XEVENTMGR.TriggerEvent('MCM_ConfigResetted', Page, GetBuilder(Page.GetPageId()), none);
	}
}

function JsonConfig_ManagerInterface GetConfigManager(JsonConfig_MCM_Page Page, JsonConfig_MCM_Group Group)
{
	if (Group.SaveConfigManager != "")
	{
		return class'MCM_Builder_SingletonFactory'.static.GetManagerInstance(Group.SaveConfigManager);
	}
	else
	{
		return class'MCM_Builder_SingletonFactory'.static.GetManagerInstance(Page.SaveConfigManager);
	}
}

simulated public function JsonConfig_MCM_Page GetPage(int PageID)
{
	local JsonConfig_MCM_Builder Builder;
	local MCMConfigMapEntry MCMConfig;
	local JsonConfig_MCM_Page Page;


	Builder = GetBuilder(PageID);

	if (Builder != none)
	{
		foreach Builder.DeserialzedPagesMap(MCMConfig)
		{
			Page = MCMConfig.MCMConfigPage;

			if (Page.MCMPageId == PageID)
			{
				return Page;
			}
		}
	}

	//`LOG(default.class @ GetFuncName() @ Builder @ "could not find MCMConfigPage for" @ PageID,, 'ModConfigMenuBuilder');

	return none;
}

simulated public function JsonConfig_MCM_Group GetGroup(int PageID, name GroupName)
{
	local JsonConfig_MCM_Page Page;
	local JsonConfig_MCM_Group Group;

	Page = GetPage(PageID);

	foreach Page.Groups(Group)
	{
		if (name(Group.GetGroupName()) == GroupName)
		{
			return Group;
		}
	}

	//`LOG(default.class @ GetFuncName() @ "could not find JsonConfig_MCM_Group for" @ PageID @ GroupName,, 'ModConfigMenuBuilder');

	return none;
}

simulated public function JsonConfig_MCM_Element GetElement(int PageID, name GroupName, name SettingName)
{
	local JsonConfig_MCM_Group Group;
	local JsonConfig_MCM_Element Element;

	Group = GetGroup(PageID, GroupName);

	foreach Group.Elements(Element)
	{
		if (name(Element.SettingName) == SettingName)
		{
			return Element;
		}
	}

	//`LOG(default.class @ GetFuncName() @ "could not find JsonConfig_MCM_Element for" @ PageID @ GroupName @ SettingName,, 'ModConfigMenuBuilder');

	return none;
}

simulated function JsonConfig_MCM_Builder GetBuilder(int PageID)
{
	return BuilderInstances[BuilderInstances.Find('PageId', PageID)].Builder;
}