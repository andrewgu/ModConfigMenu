// Paired with MCM_OptionsMenuListenerHook to work around a GC bug related to screen listeners.
// This hook makes it so that this "listener" that uses a instance reference to a UIScreen 
// is actually attached to the UIOptionsScreen and not to the UIScreenListener, thus giving
// the UIScreenListener a workable object lifetime.
// It's actually attached to the UIOptionsScreen in GC terms because the instance reference to
// this object from MCM_OptionsMenuListenerHook is transient, which means this object is 
// orphaned immediately, so it's just a node on the object reference graph attached to the UI
// itself. Since the GC graph looks like that, we can safely keep a reference to UI objects here
// instead of the actual screen listener.

class MCM_OptionsMenuListener extends UIScreenListener config(ModConfigMenu);
//class MCM_OptionsMenuListener extends Object config(ModConfigMenu);

var config bool ENABLE_MENU;
var config bool USE_FLAT_DISPLAY_STYLE;

var localized string m_strModMenuButton;

//var UIOptionsPCScreen ParentScreen;
//var UIButton ModOptionsButton;

event OnInit(UIScreen Screen)
//function OnInit(UIOptionsPCSCreen Screen)
{    
    //if(UIOptionsPCSCreen(Screen) != none)
    //{
        //ParentScreen = Screen;

        if (ENABLE_MENU)
        {
            InjectModOptionsButton(UIOptionsPCSCreen(Screen));
        }
    //}
}

event OnRemoved(UIScreen Screen)
{
	MCM_UIButton(Screen.GetChildByName('ModOptionsButton')).StopInputListener();
}

event OnReceiveFocus(UIScreen Screen)
{
	MCM_UIButton(Screen.GetChildByName('ModOptionsButton')).StartInputListener();
}

event OnLoseFocus(UIScreen Screen)
{
	MCM_UIButton(Screen.GetChildByName('ModOptionsButton')).StopInputListener();
}

simulated function InjectModOptionsButton(UIOptionsPCSCreen ParentScreen)
{
    local MCM_UIButton ModOptionsButton;

    ModOptionsButton = ParentScreen.Spawn(class'MCM_UIButton', ParentScreen);
	ModOptionsButton.bAnimateOnInit = false;
    ModOptionsButton.InitButton('ModOptionsButton', m_strModMenuButton, ShowModOptionsDialog, eUIButtonStyle_HOTLINK_BUTTON);
	ModOptionsButton.StartInputListener(class'UIUtilities_Input'.const.FXS_BUTTON_Y);
	ModOptionsButton.SetGamepadIcon(class'UIUtilities_Input'.const.ICON_Y_TRIANGLE);
	ModOptionsButton.DisableNavigation();
    ModOptionsButton.SetPosition(500, 850); //Relative to this screen panel
	ModOptionsButton.SetHeight(30);
}

simulated function ShowModOptionsDialog(UIButton kButton)
{
    local UIMovie TargetMovie;
    local UIOptionsPCScreen ParentScreen;

    `log("Mod Options Dialog Called.");

    ParentScreen = UIOptionsPCScreen(kButton.ParentPanel);

    if (USE_FLAT_DISPLAY_STYLE)
        TargetMovie = None;
    else
        TargetMovie = ParentScreen.Movie;

    MCM_OptionsScreen(ParentScreen.Movie.Stack.Push(ParentScreen.Spawn(class'MCM_OptionsScreen', ParentScreen), TargetMovie)).InitModOptionsMenu(self);
}

defaultproperties
{
    //ParentScreen = none;
    //ModOptionsButton = none;
    ScreenClass = class'UIOptionsPCSCreen';
}

