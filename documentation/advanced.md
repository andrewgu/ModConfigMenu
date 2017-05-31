# Advanced Features

This is best read alongside the API documentation. We designed the API to maximize 
generality while keeping the API clean and modular, so really these features are
just mixing and matching parts of the API in ways that the developers (yours truly!) anticipated.

### More than one Settings Page per mod

Most mods shouldn't need more than one settings page, but you can do it for big mods or 
collection mods where it makes sense for the settings to be split up into multiple pages.

To do this, just call `MCM_API_Instance.NewSettingsPage()` multiple times. 
You will be responsible for keeping track of the `MCM_API_SettingsPage` instances. If you
use the same event handlers for multiple pages, it's up to you to remember which page is which. 
Either keep references to the MCM_API_SettingsPage objects, or remember their PageID's and use
`GetSettingsPageByID(int PageID)` to retrieve the Page objects.

#### A warning about PageID

PageID is generated internally by MCM. It's given to you to give you a convenient way to reference
Page objects, but there is no guarantee that the PageID for a settings page will persist beyond the
lifetime of the settings page itself. The PageID might even change if the user clicks "Save and Exit" 
and reopens the "Mod Settings" menu.

While in theory you could use the PageID and `GetSettingsByPageID` to break into other mods, I highly
advise against doing so because the PageID is not a stable value.

If you have some way of passing the PageID between mods, perhaps using the same [technique that allows you
to talk to MCM](https://github.com/andrewgu/ModConfigMenu/blob/master/documentation/sharedcode.md), then
a more robust solution would be to pass the reference to a `MCM_API_SettingsPage` object instead.

### Adding Groups or Settings dynamically

Right now this isn't supported. Don't try to work around it, because you will dig up UI bugs that
the `MCM_API_SettingsPage.ShowSettings()` pattern is specifically designed to hide. Maybe we'll find
a better way to do this in the future.

That said, you can dynamically enable/disable settings. Disabled settings look gray and aren't editable.
So if you want a workaround, enable/disable stuff instead of hiding/showing it.

### When a user changes a setting, update another setting

This is probably most common when there's a checkbox that toggles a feature on or off. The feature itself
might have associated settings you don't want to make accessible unless the feature is enabled.

To do this, you will need to use "Change Handlers". This refers to the second of the two handlers that 
the `MCM_API_SettingsGroup.Add*****()` functions optionally. Here's an example function definition:

```
function MCM_API_Dropdown AddDropdown(name SettingName, 
    string Label, string Tooltip, array<string> Options, string Selection, 
    optional delegate<StringSettingHandler> SaveHandler, 
    optional delegate<StringSettingHandler> ChangeHandler);
```

In simple cases `SaveHandler` is enough because you only really need to know the values the user chose 
when you want to save the settings. But if you need to update the UI based on choices the user is making
before the user saves anything, then you should use the `ChangeHandler`, which is triggered every time 
a value changes, rather than only when the user saves. `ChangeHandler` uses the same signature as `SaveHandler`.

The only exception to "every time a value changes" is if you are manually setting a value and opt to 
suppress the event. For example, in `MCM_API_Dropdown` the `SetValue` function looks like this:

```
function SetValue(string Selection, bool SuppressEvent);
```

When `SuppressEvent` is set to true, ChangeHandler will not be called as a result of changing the value 
of the dropdown. If `SuppressEvent` is false, then ChangeHandler will be called.

The only thing you can't do as a response to changing a setting is outright adding/removing settings or groups.
You *can* enable/disable settings dynamically.

### "Reset to factory defaults"

Since MCM can't automate much of the work involved in applying default settings, the reset button is disabled by default.

`MCM_API_SettingsPage` has a function named `EnableResetButton`. If called, the reset button will be revealed. You'll 
have to decide how you want to implement this because MCM can't remember the defaults for you, but this option is there
if you want to provide that convenience to your users.

### Custom Settings Widgets

At the moment this is not supported. We may add support for this in a future version. Until then, please let us know
in the Issues tracker if you think that the widget type you want would be useful to others.

If you absolutely must do something custom, you have the option of implementing a custom settings page.

### Custom Settings Pages

Custom Settings Pages give you a way to build your own settings page, but hook it into the MCM menu just to keep 
everything in a central place. Custom pages are treated as popups. You will have to handle revealing/hiding the custom page.
To create a custom page, you need to call `MCM_API_Instance.NewCustomSettingsPage`:

```
function int NewCustomSettingsPage(string TabLabel, delegate<CustomSettingsPageCallback> Handler);
```

`TabLabel` will be the name that appears on the left of the menu. `Handler` gets called when the user selects the tab. Your 
job is to implement the dialog that popups up and to gracefully handle returning control back to MCM when the user exits 
your custom settings page. You will have to implement your own saving/cancelling/resetting mechanism.

An example of how to use `NewCustomSettingsPage` can be found in the `MCM_CustomPageTest.uc` and `MC_CustomPageTestUI.uc` 
files in the `ModConfigMenu` project.

### Custom Settings Pages by ini config

You may also add new custom settings pages through ini config without using MCM_API. 

To add a custom page entry, create the file `XComModConfigMenu.ini` with the following contents:

```
[ModConfigMenu.MCM_OptionsScreen]
+CustomPages=(TabLabel="Mod Name", ScreenClass="YourMod.YourOptionsScreen", ShowInGameMode=eGameMode_MainMenu)
```

Where `TabLabel` will be the name that appears on the left of the menu. `ScreenClass` will be the class of your custom options screen (Note that you need to include your mod package name to avoid class name conflicts). And `ShowInGameMode` will be the options menu screen your custom page will show up in, the available values can be found in the next section, you will need to repeat the line for each menu you want the custom page to show up on.


### Limit options for main menu / Avenger screen / In-mission screen

MCM will tell you about the game mode through the handler you passed into the version check. You can see an example in 
`MCM_TestHarness.uc` in `ModConfigMenu`. The specific delegate is declared as: 

```
delegate ClientModCallback(MCM_API_Instance ConfigAPI, int GameMode);
```

In `MCM_TestHarness.uc` you can see how this is used to selectively disable an option if you're in between missions, and 
completely skip revealing any options at all in-mission.

```
function ClientModCallback(MCM_API_Instance ConfigAPI, int GameMode)
{
    local MCM_API_SettingsGroup P1G1, P1G2, P1G3;
    local array<string> Options;

    if (GameMode == eGameMode_MainMenu || GameMode == eGameMode_Strategy)
    {
        `log("Is in main menu or strategy menu, attempting to make page.");
        
        //Snip
        
        if (GameMode == eGameMode_Strategy)
        {
            P1Checkbox.SetEditable(false);
        }
    }
}
```

Here are the possible values for the GameMode:

```
enum eGameMode
{
    eGameMode_MainMenu,
    eGameMode_Strategy,
    eGameMode_Tactical,
    eGameMode_Multiplayer,
    eGameMode_Unknown
};
```

### Using MCM for Per-Campaign Settings

Technically MCM is agnostic to where you are loading/saving the settings, so it's quite possible to use MCM for campaign settings. In general this means you need to do two things:

1. Figure out how you're loading/saving the settings into the game state, or wherever else you are storing them. 
2. Use the game mode information to only enable settings when you're in Strategy or Tactical views, but not the main menu or multiplayer.

You may have to manually implement the save handlers for individual settings, and you definitely will have to implement the handler for the "Save and Exit" button yourself in order to write settings into the game state.

You will not be able to use any of the `MCM_CH_***` macros because they are meant for loading/saving to config INI's, but the other `MCM_API_***` macros may still be useful. You should still use the macro-based version check.

### Formatted text

Formatted text (size, color, weight) should work for all group labels and settings labels. Just be careful about:
1. making it look ugly
2. cutting text off if it doens't fit into the widgets.

### Version Checking, under the hood.

The version check is mostly made automatic using macros in `MCM_API_Includes.uci`. This means it grabs the version numbers 
that come with whichever copy of the API files you got. This should be sufficient for pretty much everyone.

However, if you want to be extra strict about version numbers, you can do this manually. MCM uses a Major/Minor number system, 
where 1/0 is the first public release, and 1/10 would be major version 1, minor version 10. As long as the version of MCM
installed is the same major version as your mod, and is at least as recent as the minor version of your mod, everything should work.

However, it may be that the user hasn't updated MCM in a while and your mod uses a more recent minor version. In that case, if you
know that your mod isn't doing anything special to the newer minor version, it might make sense to hard-code to an earlier minor 
version.

To figure out the version number MCM is using, look at `XComModConfigMenu.ini`.

Here's an example of how you would manually handle the version check instead of using the `MCM_API_Register` macro:

```
event OnInit(UIScreen Screen)
{
    if (MCM_API(Screen) != none)
    {
        MCM_API(Screen).RegisterClientMod(1, 0, ClientModCallback);
    }
}
```
