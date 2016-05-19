class UIStub extends UIScreenListener;

event OnInit(UIScreen Screen)
{
    if (MCM_API(Screen) != none)
    {
        `log("MCDT: Dependency Stub Triggered.");
    }
}

defaultproperties
{
    ScreenClass = none;
}