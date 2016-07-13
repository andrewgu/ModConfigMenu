class MCM_OptionsMenuListenerHook extends UIScreenListener;

var int initCounter;

var UIScreen scr;

event OnInit(UIScreen Screen)
{
    local MCM_OptionsMenuListener listener;

    if (UIOptionsPCSCreen(Screen) != none)
    {
        scr = Screen;

        // By using a transient class instance to execute the actual code,
        // we prevent the "listener code" from accidentally attaching UI objects
        // to a UIScreenListener object.
        listener = new class'MCM_OptionsMenuListener';
        listener.OnInit(UIOptionsPCSCreen(Screen));
    }
}

defaultproperties
{
    initCounter = 0;
    ScreenClass = none;
}