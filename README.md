# Mod Config Menu

XCOM 2 Mod Config Menu: a shared settings menu for Xcom 2 mods.

# Capabilities

This project aims to do three things:

1. Centralize mod configurations in an easy place for users to access.
2. Provide UI abstractions so that you don't have to write any UI code to add an in-game settings page to your mod.
3. Fail gracefully if a user has not installed the Mod Config Menu, but still tries to run a mod that uses this.

We accomplish this through:

1. a set of interfaces defining the API (`ModConfigMenuAPI`)
2. a UIScreenListener that listens for the settings screen that this mod creates
3. boilerplate conditional code that only executes the dependent code if the mod is installed

This all comes at one very big cost though: **The interfaces defined in ModConfigMenuAPI must be copied character for character in every mod.** If we revise the API after its initial release, we will release it as a separate package, i.e. ModConfigMenuAPI2, to preserve backward compatibility. Also, seriously, don't touch `XComModConfigMenu.ini`. Those settings are hiding some *interesting* behaviors in XCOM 2's UI scripting.

# Testing/Usage

Three general steps to get this working:

1. Build the ModConfigMenu project. Just open the `.XCOM_sln` file and build. You may wish to disable the self-test built into ModConfigMenu. To do this, find the config file `XComModConfigMenu.ini` and change the line `ENABLE_TEST_HARNESS=True` to `ENABLE_TEST_HARNESS=False`.
2. In your own mod project, copy the ModConfigMenuAPI source package. The `MCM_API_*` files should be in the path `$(ProjectDir)/Src/ModConfigMenuAPI/Classes`
3. Add these magic lines to `Config/XComEngine.ini` in your mod:

    ```
    [UnrealEd.EditorEngine]
    +EditPackages=ModConfigMenuAPI
    ```


After doing these things, your project should be able to build and run.

For a working example of how to use the mod for the actual settings page, see the ModConfigDependencyTest project. The basic process is:

1. Create a UIScreenListener subclass that listens for `ScreenClass = class'MCM_OptionsScreen';` Note that this will throw a warning because MCM_OptionsScreen is not defined anywhere in your mod project.
2. Use this boilerplate to inject the settings page code only if ModConfigMenu is installed:

    ```
    event OnInit(UIScreen Screen)
    {
        local MCM_API APIInst;
        APIInst = MCM_API(Screen);
        if (APIInst != None)
         {
            APIInst.RegisterClientMod(0, 1, ClientModCallback);
        }
    }
    ```

3. All of your code that depends on the Mod Config Menu should go into ClientModCallback.

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
