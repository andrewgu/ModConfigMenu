# Updating Mod Configurations Dynamically

### The Problem

The problem is twofold.

#### Problem 1: SaveConfig and StaticSaveConfig don't always work.

##### Where Xcom 2 pulls mod configurations

Xcom 2 pulls your mod configurations from `XCOM 2/XComGame/Mods/[Your Mod]/Config`. These are the INI files that you include in your project when you are creating it with ModBuddy. 

##### The canonical way to write updated settings to INI files

UnrealScript provides two methods, `SaveConfig()` and `StaticSaveConfig()`, which both write updated INI data back into the corresponding INI files. `SaveConfig()` uses values from the current instance of the class, and `StaticSaveConfig()` uses the default values. 

Normally, if your class declaration looks like this:

```
class Foo extends Object config(Bar);
```

Then somewhere there will be a `XComBar.ini` file. Probably in your `My Games` folder. When you call either `class'Foo'.static.StaticSaveConfig()` or call `self.SaveConfig()` from inside a method belonging to `Foo`, changes will be written to `XComBar.ini`.

##### Mods have special behavior

The problem is that for mods specifically, Xcom 2 loads the INI files from the mod folder, but doesn't write the changes back into those INI files when you call `SaveConfig` or `StaticSaveConfig`.

##### Workaround

However, there is a workaround. If you declare a class to pull its config from a *non-existent* INI file, and then try to call `SaveConfig` or `StaticSaveConfig`, the game will create the missing INI file in your `My Games` folder. Any future attempts to load that class will result in pulling the settings from that file, and when you call SaveConfig, new values will get written into that file.

So if you want to be able to write new settings back into the INI file from within the game, you need to set the class to pull configurations from an initially non-existent INI file, which forces the game to create it in the `My Games` folder instead of your mod's `Config` folder.

#### Problem 2: Defining defaults and not overwriting when updating mods

##### Mod updates overwrite user settings.

If the user modified the mod's INI files inside the `Config` folder, those files will get overwritten if the mod author updates the mod for Steam Workshop. I suspect Nexus Mod Manager has the same problem. This means the user loses any settings every time the mod author decides to release a tiny patch. Not a good situation. This also means it's hard to define defaults using INI files packaged with the mod because defaults will overwrite user settings on every update.

### The Solution

In short:

1. In addition to your regular class, declare a mirror "defaults" class. Add a "VERSION" variable to both. For example, if your class `Foo` looked like this:

    ```
    class Foo extends object config(Foo);
    var config int VERSION;
    var config int CONFIG_VARIABLE;
    // and so on...
    ```
    
    Then create a parallel class like this:
    
    ```
    class Foo_Defaults extends object config(Foo_Defaults);
    var config int VERSION;
    var config int CONFIG_VARIABLE;
    ```
    
2. In your ModBuddy project, only create `XcomFoo_Defaults.ini`, don't create `XcomFoo.ini`. Since `XcomFoo.ini` is missing, the config vars in `Foo` will take on their data type defaults, i.e. false for booleans, 0 for integers, "" for strings, and so on.
3. Use the version number to figure out which settings to use. Since `XcomFoo.ini` is missing, `class'Foo'.default.VERSION` will be `0`. `class'Foo_Defaults'.default.VERSION` will be whatever you put in `XcomFoo_Defaults.ini`.
4. If the version number for `Foo` is older than `Foo_Defaults` then pull values from `Foo_Defaults` into `Foo`, update the version number in `Foo`, and call `SaveConfig()`. This will create `XcomFoo.ini`. In the future, a version number check would tell you to use the values from `Foo`.

This works especially well for our purposes with ModConfigMenu because `XcomFoo.ini` will be in your `My Games` folder, meaning it will be *writeable*!

Since you are using version numbers, it's also possible to release a new set of defaults that overwrite user settings if you really think that's necessary. And if you want to be really granular, you could in theory attach a version number to every configuration setting so that you can selectively update settings when you update your mod.

### Example Code

If you want to see this mechanism in action, take a look at `MCM_TestHarness.uc` in the ModConfigMenu project. You will have to peek into the macros it uses, but it demonstrates how to combine version numbers with the parallel "defaults" class to make an in-game configurable INI file based on default values provided by the mod author.
