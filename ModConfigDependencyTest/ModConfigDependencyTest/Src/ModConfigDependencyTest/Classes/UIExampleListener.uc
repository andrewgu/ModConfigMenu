class UIExampleListener extends UIScreenListener;

event OnInit(UIScreen Screen)
{
    local UIExample example;

    if (MCM_API(Screen) != none)
    {
        example = new class'UIExample';
        example.OnInit(Screen);
    }
}

defaultproperties
{
    // The class you're listening for doesn't exist in this project, so you can't listen for it directly.
    ScreenClass = none;
}