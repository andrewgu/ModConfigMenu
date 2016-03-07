class UIStub extends UIScreenListener;

event OnInit(UIScreen Screen)
{
    `log("DEPENDENCY STUB TRIGGERED");
}

defaultproperties
{
    ScreenClass = class'UIOptionsPCScreen';
}