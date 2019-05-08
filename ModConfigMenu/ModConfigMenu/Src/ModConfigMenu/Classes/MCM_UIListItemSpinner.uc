//-----------------------------------------------------------
//	Class:	MCM_UIListItemSpinner
//	Author: Mr. Nice
//	
//-----------------------------------------------------------


class MCM_UIListItemSpinner extends UIListItemSpinner;


simulated function OnMouseEvent(int cmd, array<string> args)
{
	Super.OnMouseEvent(cmd, args);
	
	if(cmd == class'UIUtilities_Input'.const.FXS_L_MOUSE_UP)
	{
		Movie.Pres.PlayUISound(eSUISound_MenuSelect);
	}
}