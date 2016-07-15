class MCM_OptionsMenuListenerHook extends UIScreenListener;

event OnInit(UIScreen Screen)
{
    local MCM_OptionsMenuListener listener;

    if (UIOptionsPCSCreen(Screen) != none)
    {
        // By using a transient class instance to execute the actual code,
        // we prevent the "listener code" from accidentally attaching UI objects
        // to a UIScreenListener object.
        listener = new class'MCM_OptionsMenuListener';
        listener.OnInit(UIOptionsPCSCreen(Screen));
    }
}

defaultproperties
{
    ScreenClass = none;
}