class MCM_LegacyDlcCleaner extends UIScreenListener config(ModConfigMenu);

var config bool ALLOW_REMOVE_LEGACY_DEPENDENCY;

event OnInit(UIScreen Screen)
{
    local MCM_LegacyDlcCleanerUI CleanerUI;

    if (MCM_API(Screen) != none)
    {
        if (ALLOW_REMOVE_LEGACY_DEPENDENCY)
        {
            `log("MCM Legacy Cleaner UI added.");

            CleanerUI = new class'MCM_LegacyDlcCleanerUI';
            CleanerUI.OnInit(Screen);
        }
    }
}

defaultproperties
{
    // Need this because you won't be able to listen for a concrete class type that doesn't exist yet.
    ScreenClass = none;
}