class UIStub extends UIScreenListener;

event OnInit(UIScreen Screen)
{
    `log("MCDT: Dependency Stub Triggered.");
}

defaultproperties
{
    ScreenClass = class'MCM_OptionsScreen';
}