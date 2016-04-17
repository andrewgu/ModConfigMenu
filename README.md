# Mod Config Menu

XCOM 2 Mod Config Menu: a shared settings menu for Xcom 2 mods.

# Capabilities

This project aims to do three things:

1. Centralize mod configurations in an easy place for users to access.
2. Provide UI tools to let you write an in-game settings UI for your mod with minimal actual UI code.
3. Leave this mod optional: users can use the control panel if it's installed, but your mod still works without it.

We accomplish this through:

1. a set of interfaces and utilities defining the API (`ModConfigMenuAPI`)
2. boilerplate code using a UIScreenListener that hooks into this mod's API when the mod is present

This all comes at a specific configuration complexity: **The interfaces defined in ModConfigMenuAPI must be copied character for character in every mod.** If we revise the API after its initial release, we will release it as a separate package, i.e. ModConfigMenuAPI2, to preserve backward compatibility.

# Screenshots

Mod Settings button in the options screen:

![Mod Settings button in the options screen](https://raw.githubusercontent.com/andrewgu/ModConfigMenu/master/Res/screen1.jpg "Mod Settings button in the options screen")

Example mod rendered in the MCM UI:

![Example mod rendered in the MCM UI](https://raw.githubusercontent.com/andrewgu/ModConfigMenu/master/Res/screen2.jpg "Example mod rendered in the MCM UI")

# Testing/Usage

Three general steps to get this working for your dev environment:

1. Clone and download the repository.
2. Build the ModConfigMenu project. Just open the `.XCOM_sln` file and build. You may wish to disable the self-test built into ModConfigMenu. To do this, find the config file `XComModConfigMenuTest.ini` and change the line `ENABLE_TEST_HARNESS=true` to `ENABLE_TEST_HARNESS=false`.
3. In your own mod project, copy the ModConfigMenuAPI source package. The `MCM_API_*` files should be in the path `$(ProjectDir)/Src/ModConfigMenuAPI/Classes`. You will also want the *.uci files located in `$(ProjectDir)/Src/ModConfigMenuAPI`.
4. Add these magic lines to `Config/XComEngine.ini` in your mod:

    ```
    [UnrealEd.EditorEngine]
    +EditPackages=ModConfigMenuAPI
    ```


After doing these things, your project should be able to build and run.

# Building your mod UI

There are four types of objects you need to know about:

1. **The API Instance (`MCM_API_Instance`) is the root object.** This is the entry point for the MCM API. Your mod needs to tell MCM what pages of settings to include through this object.
2. **Use the API instance to spawn pages of settings (`MCM_API_SettingsPage`).** Pages are organized in a tabbed interface like the game's settings page. Typically you will make one page per mod, but MCM lets you make more than one if you want to.
3. **Each page contains groups (`MCM_API_SettingsGroup`).** Groups let you organize the settings in a mod under subsections. Small mods might only use a "General" grouping, but bigger mods might organize settings into multiple subsections.
4. **Each group contains individual settings**, which all implement `MCM_API_Setting`, but the individual settings have their own interfaces that expose type-specific functionality.

A simple mod will go through these steps:

1. Make a `UIScreenListener` to **hook into the API instance**:

    ```
    class MCM_TestHarness extends UIScreenListener config(ModConfigMenuTestHarness);
    ```

    ```
    event OnInit(UIScreen Screen)
    {
        // The macro automates a version check to make sure the user installed a compatible version of MCM.
        `MCM_API_Register(Screen, ClientModCallback);
    }
    ```
    
    ```
    defaultproperties
    {
        ScreenClass = class'MCM_OptionsScreen';
    }
    ```

2. Use the hook from step 1 to **create a page of settings**:

    ```
    function ClientModCallback(MCM_API_Instance ConfigAPI, int GameMode)
    {
        // Only allow mod settings to change when not in-campaign.
        if (GameMode == eGameMode_MainMenu)
        {
            Page1 = ConfigAPI.NewSettingsPage("MCM_Test_1");
            Page1.SetPageTitle("Page 1");
            Page1.SetSaveHandler(SaveButtonClicked);
            
            // and so on...
    ```

3. **Add a group to the page**:

    ```
    Group1 = Page1.AddGroup('General', "General Settings");
    ```

4. **Add some settings to the group**:

    ```
    // This initializes the checkbox's state to the current value of bBoolProperty.
    P1Checkbox = Group1.AddCheckbox('checkbox', "Checkbox", "Checkbox", bBoolProperty, CheckboxSaveLogger);
    ```

5. After you're done adding adding groups and settings, **tell MCM to render the page**:

    ```
    Page1.ShowSettings();
    ```

6. Write a handler to save the settings when they're changed (`MCM_API_Includes.uci` includes helpful macros for this.):

    ```
    // Method 1: Use a macro.
    `MCM_API_BasicCheckboxSaveHandler(CheckboxSaveLogger, bBoolProperty)
    ```

    ```
    // Method 2: Same thing, but done explicitly:
    simulated function CheckboxSaveLogger (MCM_API_Setting _Setting, name _SettingName, bool _SettingValue) 
    {
        bBoolProperty = _SettingValue; 
    }
    ```

7. Fill in the code to save the settings when the user clicks the "Save and Exit" button (`MCM_API_CfgHelpers.uci` includes helpful macros for this.):

    ```
    function SaveButtonClicked(MCM_API_SettingsPage Page)
    {
        // This is a special helper macro from MCM_API_CfgHelpers.uci.
        `MCM_CH_SaveConfig();
    }
    ```

And you're done. For a full example of both the base MCM API as well as the helper macros in a basic case, see the `UIExample.uc` file in the ModConfigDependencyTest project.

# License

If it's not covered by Firaxis, then it's covered by the MIT License:

The MIT License (MIT)

Copyright (c) 2016 Andrew Gu

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
