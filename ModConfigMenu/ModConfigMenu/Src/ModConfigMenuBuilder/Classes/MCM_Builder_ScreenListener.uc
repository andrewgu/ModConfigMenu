//-----------------------------------------------------------
//	Class:	MCM_Builder_ScreenListener
//	Author: Musashi
//	
//-----------------------------------------------------------
class MCM_Builder_ScreenListener extends UIScreenListener;

event OnInit(UIScreen Screen)
{
	local MCM_Builder_Screen MCMScreen;

	if (ScreenClass==none)
	{
		if (MCM_API(Screen) != none)
		{
			ScreenClass = Screen.Class;
		}
		else
		{
			return;
		}
	}

	MCMScreen = new class'MCM_Builder_Screen';
	MCMScreen.OnInit(Screen);
}

defaultproperties
{
    ScreenClass = none;
}
