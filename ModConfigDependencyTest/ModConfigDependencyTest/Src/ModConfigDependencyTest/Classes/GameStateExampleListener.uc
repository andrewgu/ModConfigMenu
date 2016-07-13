class GameStateExampleListener extends UIScreenListener;

event OnInit(UIScreen Screen)
{
    local GameStateExample example;

    if (MCM_API(Screen) != none)
    {
        example = new class'GameStateExample';
        example.OnInit(MCM_API(Screen));
    }
}

defaultproperties
{
    // The class you're listening for doesn't exist in this project, so you can't listen for it directly.
    ScreenClass = none;
}