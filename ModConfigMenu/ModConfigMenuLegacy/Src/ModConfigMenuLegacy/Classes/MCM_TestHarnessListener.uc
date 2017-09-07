class MCM_TestHarnessListener extends UIScreenListener config(ModConfigMenuTestHarness);

event OnInit(UIScreen Screen)
{
    local MCM_TestHarness RegularTestHarness;
    local MCM_CustomPageTest CustomPageTestHarness;

    if (MCM_API(Screen) != none)
    {
        if (!(class'MCM_TestConfigStore'.default.ENABLE_TEST_HARNESS))
        {
            `log("MCM Test Harness Disabled.");
            return;
        }
    }

    RegularTestHarness = new class'MCM_TestHarness';
    CustomPageTestHarness = new class'MCM_CustomPageTest';

    RegularTestHarness.OnInit(Screen);
    CustomPageTestHarness.OnInit(Screen);
}

defaultproperties
{
    // Need this because you won't be able to listen for a concrete class type that doesn't exist yet.
    ScreenClass = none;
}