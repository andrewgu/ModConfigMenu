// Paired with MCM_OptionsMenuListenerHook to work around a GC bug related to screen listeners.
// This hook makes it so that this "listener" that uses a instance reference to a UIScreen 
// is actually attached to the UIOptionsScreen and not to the UIScreenListener, thus giving
// the UIScreenListener a workable object lifetime.
// It's actually attached to the UIOptionsScreen in GC terms because the instance reference to
// this object from MCM_OptionsMenuListenerHook is transient, which means this object is 
// orphaned immediately, so it's just a node on the object reference graph attached to the UI
// itself. Since the GC graph looks like that, we can safely keep a reference to UI objects here
// instead of the actual screen listener.

//class MCM_OptionsMenuListener extends UIScreenListener config(ModConfigMenu);
class MCM_OptionsMenuListener extends Object config(ModConfigMenu);

var config bool ENABLE_MENU;
var config bool USE_FLAT_DISPLAY_STYLE;

var localized string m_strModMenuButton;

//var UIOptionsPCScreen ParentScreen;
//var UIButton ModOptionsButton;

//event OnInit(UIScreen Screen)
function OnInit(UIOptionsPCSCreen Screen)
{    
    //if(UIOptionsPCSCreen(Screen) != none)
    //{
        //ParentScreen = Screen;
    
        if (ENABLE_MENU)
        {
            InjectModOptionsButton(Screen);
        }
    //}
}

simulated function InjectModOptionsButton(UIOptionsPCSCreen ParentScreen)
{
    local UIButton ModOptionsButton;
    ModOptionsButton = ParentScreen.Spawn(class'UIButton', ParentScreen);
    ModOptionsButton.InitButton(, m_strModMenuButton, ShowModOptionsDialog);
    ModOptionsButton.SetPosition(500, 850); //Relative to this screen panel
    ModOptionsButton.AnimateIn(0);
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
    //ScreenClass = none;
}

