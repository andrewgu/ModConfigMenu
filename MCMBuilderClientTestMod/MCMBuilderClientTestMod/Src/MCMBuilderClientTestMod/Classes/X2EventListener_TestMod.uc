class X2EventListener_TestMod extends  X2EventListener;

static function array<X2DataTemplate> CreateTemplates()
{
	local array<X2DataTemplate> Templates;

	Templates.AddItem(CreateListenerTemplate_MCMBuilderListener());

	return Templates;
}

static function CHEventListenerTemplate CreateListenerTemplate_MCMBuilderListener()
{
	local CHEventListenerTemplate Template;

	`CREATE_X2TEMPLATE(class'CHEventListenerTemplate', Template, 'MCMBuilderClientTestMod_MCMBuilderListener');

	Template.RegisterInStrategy = true;
	Template.RegisterInTactical = true;

	Template.AddCHEvent('MCM_ButtonClick', OnMCM_ButtonClick, ELD_Immediate);
	Template.AddCHEvent('MCM_ChangeHandler', OnMCM_ChangeHandler, ELD_Immediate);
	Template.AddCHEvent('MCM_SaveHandler', OnMCM_SaveHandler, ELD_Immediate);
	Template.AddCHEvent('MCM_SaveButtonClicked', OnMCM_SaveButtonClicked, ELD_Immediate);
	Template.AddCHEvent('MCM_ConfigSaved', OnMCM_ConfigSaved, ELD_Immediate);
	Template.AddCHEvent('MCM_ResetButtonClicked', OnMCM_ResetButtonClicked, ELD_Immediate);
	Template.AddCHEvent('MCM_ConfigResetted', OnMCM_ConfigResetted, ELD_Immediate);

	return Template;
}


static function EventListenerReturn OnMCM_ButtonClick(Object EventData, Object EventSource, XComGameState GameState, Name Event, Object CallbackData)
{
	if (EventSource != none)
	{
		`LOG(default.class @ GetFuncName() @ EventSource,, 'MCMBuilderClientTestMod');
	}

	return ELR_NoInterrupt;
}

static function EventListenerReturn OnMCM_ChangeHandler(Object EventData, Object EventSource, XComGameState GameState, Name Event, Object CallbackData)
{
	local XComLWTuple Tuple;

	Tuple = XComLWTuple(EventSource);

	if (Tuple.Data[0].o != none)
	{
		`LOG(default.class @ GetFuncName() @ Tuple.Data[0].o @ Tuple.Data[1].s,, 'MCMBuilderClientTestMod');
	}

	return ELR_NoInterrupt;
}

static function EventListenerReturn OnMCM_SaveHandler(Object EventData, Object EventSource, XComGameState GameState, Name Event, Object CallbackData)
{
	local XComLWTuple Tuple;

	Tuple = XComLWTuple(EventSource);

	if (Tuple.Data[0].o != none)
	{
		`LOG(default.class @ GetFuncName() @ Tuple.Data[0].o @ Tuple.Data[1].s,, 'MCMBuilderClientTestMod');
	}

	return ELR_NoInterrupt;
}

static function EventListenerReturn OnMCM_SaveButtonClicked(Object EventData, Object EventSource, XComGameState GameState, Name Event, Object CallbackData)
{
	local XComLWTuple Tuple;

	Tuple = XComLWTuple(EventSource);

	if (Tuple.Data[0].o != none)
	{
		`LOG(default.class @ Tuple.Data[0].o @ GetFuncName(),, 'MCMBuilderClientTestMod');
	}

	return ELR_NoInterrupt;
}

static function EventListenerReturn OnMCM_ConfigSaved(Object EventData, Object EventSource, XComGameState GameState, Name Event, Object CallbackData)
{
	if (EventSource != none)
	{
		`LOG(default.class @ GetFuncName() @ EventSource,, 'MCMBuilderClientTestMod');
		MakePopup();
	}

	return ELR_NoInterrupt;
}

static function EventListenerReturn OnMCM_ResetButtonClicked(Object EventData, Object EventSource, XComGameState GameState, Name Event, Object CallbackData)
{
	if (EventSource != none)
	{
		`LOG(default.class @ GetFuncName() @ EventSource,, 'MCMBuilderClientTestMod');
	}

	return ELR_NoInterrupt;
}

static function EventListenerReturn OnMCM_ConfigResetted(Object EventData, Object EventSource, XComGameState GameState, Name Event, Object CallbackData)
{
	if (EventSource != none)
	{
		`LOG(default.class @ GetFuncName() @ EventSource,, 'MCMBuilderClientTestMod');
	}

	return ELR_NoInterrupt;
}

simulated static function MakePopup()
{
	local TDialogueBoxData kDialogData;
	local JsonConfig_ManagerInterface ConfigManager;

	ConfigManager = class'ConfigFactory'.static.GetConfigManager("MCMBuilderClientTestModConfigManager");

	kDialogData.eType = eDialog_Warning;
	kDialogData.strTitle = "MCM Settings Saved";
	kDialogData.strText = 
		ConfigManager.GetConfigBoolValue("A_BOOL_PROPERTY") $ "\n" $
		ConfigManager.GetConfigIntValue("A_INT_PROPERTY") $ "\n" $
		ConfigManager.GetConfigFloatValue("A_FLOAT_PROPERTY") $ "\n" $
		ConfigManager.GetConfigStringValue("A_STRING_PROPERTY");
	//kDialogData.fnCallback = OKClickedGeneric;

	kDialogData.strAccept = class'UIUtilities_Text'.default.m_strGenericContinue;

	`PRESBASE.UIRaiseDialog(kDialogData);
}