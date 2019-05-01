//-----------------------------------------------------------
//	Class:	MCM_UIButton
//	Author: Mr. Nice
//	
//-----------------------------------------------------------


class MCM_UIButton extends UIButton;

var int iButton;
var XComInputBase PlayerInput;
var float prevfTime;

simulated function UIButton InitButton(optional name InitName, optional string InitLabel, optional delegate<OnClickedDelegate> InitOnClicked, optional EUIButtonStyle InitStyle = -1, optional name InitLibID = '')
{
	PlayerInput = XComInputBase(`LOCALPLAYERCONTROLLER.PlayerInput);
	return Super.InitButton(InitName, InitLabel, InitOnClicked, InitStyle, InitLibID);
}
function StartInputListener(optional int kButton)
{
	if (kButton != 0)
	{
		iButton = kButton;
	}
	PlayerInput.Subscribe(iButton, 7*24*60*60, ResetPrevfTime);
	prevfTime = 0;
}

function StopInputListener()
{
	PlayerInput.Unsubscribe(ResetPrevfTime);
	prevfTime = -1;
}

function ResetPrevfTime()
{
	prevfTime = 0; // Somehow the button has been waiting 7 days?! Anyhow, guess we'll miss a a tick of monitoring then soldier on...
}

simulated event Tick(float DeltaTime)
{
	local float newfTime;

	if(prevfTime != -1)
	{
		newfTime = PlayerInput.GetIdler(iButton).fTime;
		if(NewfTime < prevfTime)
		{
			OnClickedDelegate(self);
		}
		prevfTime = newfTime;
	}

	Super.Tick(DeltaTime);
}