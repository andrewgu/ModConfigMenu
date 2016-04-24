# Tutorial

### Setting up your project

Before we get into writing the code, we need to set up the API files you will compile your mod against. 
[See here for more information on how this works.](https://github.com/andrewgu/ModConfigMenu/blob/master/documentation/sharedcode.md)
You don't really need to know the nitty gritty details, just follow these steps.

First, create a new mod project. 

![](https://raw.githubusercontent.com/andrewgu/ModConfigMenu/master/documentation/img/newproject.png)

Next, you will need to get a copy of the API files. You can either download this repository and 
copy the `ModConfigMenu/ModConfigMenu/Src/ModConfigMenuAPI` folder, 
or download and extract the [compressed package](https://github.com/andrewgu/ModConfigMenu/blob/master/MCM_API.zip?raw=true) 
into the `src` folder in your mod:

![](https://raw.githubusercontent.com/andrewgu/ModConfigMenu/master/documentation/img/pastefiles.png)

Paste the ModConfigMenuAPI source package. You'll know you did it right if the `src/ModConfigMenuAPI` folder looks like this:

![](https://raw.githubusercontent.com/andrewgu/ModConfigMenu/master/documentation/img/mcmapifiles.png)

In your project, you will want to add the files so that ModBuddy knows to compile them. 
The easiest way to do this is to directly edit the `.x2proj` file. First, close ModBuddy, then open the file in a text editor. 
In this example the path of the `.x2proj` file is `Documents\Firaxis ModBuddy\XCOM\MCM_Tutorial\MCM_Tutorial\MCM_Tutorial.x2proj`.

In the section that has lines that look like `<Folder Include="..." />`, insert these two lines: 

```
    <Folder Include="Src\ModConfigMenuAPI" />
    <Folder Include="Src\ModConfigMenuAPI\Classes" />
```

See this screenshot for reference:

![](https://raw.githubusercontent.com/andrewgu/ModConfigMenu/master/documentation/img/addfiles1.png)

In the section that has lines that look like `<Content Include="..." />`, insert this block of lines:

```
    <Content Include="Src\ModConfigMenuAPI\Classes\MCM_API.uc">
      <SubType>Content</SubType>
    </Content>
    <Content Include="Src\ModConfigMenuAPI\Classes\MCM_API_Button.uc">
      <SubType>Content</SubType>
    </Content>
    <Content Include="Src\ModConfigMenuAPI\Classes\MCM_API_Checkbox.uc">
      <SubType>Content</SubType>
    </Content>
    <Content Include="Src\ModConfigMenuAPI\Classes\MCM_API_Dropdown.uc">
      <SubType>Content</SubType>
    </Content>
    <Content Include="Src\ModConfigMenuAPI\Classes\MCM_API_Instance.uc">
      <SubType>Content</SubType>
    </Content>
    <Content Include="Src\ModConfigMenuAPI\Classes\MCM_API_Label.uc">
      <SubType>Content</SubType>
    </Content>
    <Content Include="Src\ModConfigMenuAPI\Classes\MCM_API_Setting.uc">
      <SubType>Content</SubType>
    </Content>
    <Content Include="Src\ModConfigMenuAPI\Classes\MCM_API_SettingsGroup.uc">
      <SubType>Content</SubType>
    </Content>
    <Content Include="Src\ModConfigMenuAPI\Classes\MCM_API_SettingsPage.uc">
      <SubType>Content</SubType>
    </Content>
    <Content Include="Src\ModConfigMenuAPI\Classes\MCM_API_Slider.uc">
      <SubType>Content</SubType>
    </Content>
    <Content Include="Src\ModConfigMenuAPI\Classes\MCM_API_Spinner.uc">
      <SubType>Content</SubType>
    </Content>
    <Content Include="Src\ModConfigMenuAPI\MCM_API_CfgHelpers.uci">
      <SubType>Content</SubType>
    </Content>
    <Content Include="Src\ModConfigMenuAPI\MCM_API_Includes.uci">
      <SubType>Content</SubType>
    </Content>
```

See this screenshot for reference:

![](https://raw.githubusercontent.com/andrewgu/ModConfigMenu/master/documentation/img/addfiles2.png)

Once you've done this, save your edits and reopen your mod in ModBuddy. If you did this right, it should look like this:

![](https://raw.githubusercontent.com/andrewgu/ModConfigMenu/master/documentation/img/addfiles3.png)

### Configuring your INI files

Now that you've added the API files, you need to configure your mod to be able to compile against the API interfaces. 
You will need to add two lines to XComEngine.ini:

```
    [UnrealEd.EditorEngine]
    +EditPackages=ModConfigMenuAPI
```

It should look like this:

![](https://raw.githubusercontent.com/andrewgu/ModConfigMenu/master/documentation/img/engineini.png)

At this point, you should be able to build your mod with no errors.

### Hooking Into MCM

Now that you've set up the API files, you're ready to start writing the actual code. In this example, we're going to add a page with one setting in it.

We're going to hook into MCM using a screen listener. In this example I created a file named `ExampleListener.uc`:

```
class ExampleListener extends UIScreenListener config(NonexistentConfigName);

`include(MCM_Tutorial/Src/ModConfigMenuAPI/MCM_API_Includes.uci)
`include(MCM_Tutorial/Src/ModConfigMenuAPI/MCM_API_CfgHelpers.uci)
```

We're also going to include two macro files because they contain useful helper code. Notice the name of the project in the file paths.

The part where "NonexistentConfigName" does not point to any INI file in your project is important in order to make it possible to save settings dynamically. 
[See this for a more detailed discussion.](https://github.com/andrewgu/ModConfigMenu/blob/master/documentation/config.md)

Now we need to make a configuration variable that stores the setting we're going to make.
We will also need a "version" variable which will be necessary later on in order for your mod to provide default values.

```
var config bool CHECKBOX_VALUE;
var config bool CONFIG_VERSION;
```

Now that we have variables out of the way, we're going to make `ExampleListener` listen for the UI screen that MCM creates. At the bottom of the file, we're going to tell the UIScreenListener to listen specifically for the magical UI screen:

```
defaultproperties
{
    ScreenClass = class'MCM_OptionsScreen';
}
```

Now we're going to use the `OnInit` event to hook into MCM:

```
event OnInit(UIScreen Screen)
{
    `MCM_API_Register(Screen, ClientModCallback);
}
```

This declares that a function named `ClientModCallback` will be doing the work of building the page and settings. Here's the function in code, which we will implement in the next step:

```
simulated function ClientModCallback(MCM_API_Instance ConfigAPI, int GameMode)
{
    // Code goes here.
}
```

### Creating a settings page

So we have our scaffolding in place. Now we're going to build the page. It's actually really straightforward, so here it is in a few lines:

```
simulated function ClientModCallback(MCM_API_Instance ConfigAPI, int GameMode)
{
    local MCM_API_SettingsPage Page;
    local MCM_API_SettingsGroup Group;
    
    LoadSavedSettings();
    
    Page = ConfigAPI.NewSettingsPage("Example Tab Label");
    Page.SetPageTitle("Example Title");
    Page.SetSaveHandler(SaveButtonClicked);
    
    Group = Page.AddGroup('Group1', "General Settings");
    
    Group.AddCheckbox('checkbox', "Example Checkbox", "Example Checkbox Tooltip", CHECKBOX_VALUE, CheckboxSaveHandler);
    
    Page.ShowSettings();
}
```

A few key points:

1. `LoadSavedSettings` is a function to load the user's current settings. We'll fill it out in the next section.
2. Notice that we're passing in CHECKBOX_VALUE. This makes sure that when we load the settings page, the checkbox is showing the player's current settings.
3. `CheckboxSaveHandler` and `SaveButtonClicked` are called in that order when the user clicks the "Save and Exit" button. We'll implement them in the next section to save the changed settings.
4. You need to call `ShowSettings()` on the page after adding your groups and settings in order to make them show up. After you call `ShowSettings()`, you should not attempt to add any more groups or settings.

### Loading and Saving settings

Alright, so we've made the UI, now we just need to hook up the loading/saving functionality.

But first, we need to have somewhere to load default settings from. If you want more details on how exactly this works, [see here](https://github.com/andrewgu/ModConfigMenu/blob/master/documentation/config.md).

We're going to make two files: `MCM_Tutorial_Defaults.uc` and `XComMCM_Tutorial_Defaults.ini`. They look like this:

```
// MCM_Tutorial_Defaults.uc
class MCM_Tutorial_Defaults extends Object config(MCM_Tutorial_Defaults);

var config bool SETTING;
var config int VERSION;
```

```
; XComMCM_Tutorial_Defaults.ini
[MCM_Tutorial.MCM_Tutorial_Defaults]
SETTING=true
VERSION=1
```

We will use the `VERSION` variable to tell us whether to use the default setting or to use the saved setting.

Now that we have the default settings set up, we're going to load them. We're using the `MCM_CH_VersionChecker` macro to declare that this class is pulling defaults from `MCM_Tutorial_Defaults`. Then we're using `MCM_CH_GetValue` to pull the right value from either the defaults or from a saved configuration.

```
`MCM_CH_VersionChecker(class'MCM_Tutorial_Defaults'.default.VERSION,CONFIG_VERSION)

simulated function LoadSavedSettings()
{
    CHECKBOX_VALUE = `MCM_CH_GetValue(class'MCM_Tutorial_Defaults'.default.SETTING,CHECKBOX_VALUE);
}
```

And finally, we need to handle saving. Fortunately there's an easy macro we can use for `CheckboxSaveHandler`:

```
`MCM_API_BasicCheckboxSaveHandler(CheckboxSaveHandler, CHECKBOX_VALUE)
```

This macro basically says to write the state of the checkbox into CHECKBOX_VALUE when the user clicks "Save and Exit".

And then in `SaveButtonClicked` we're going to actually save:

```
simulated function SaveButtonClicked(MCM_API_SettingsPage Page)
{
    self.CONFIG_VERSION = `MCM_CH_GetCompositeVersion();
    self.SaveConfig();
}
```

The first line updates the version number to tell the code to load from the saved settings in the future instead of the defaults. Then calling `self.SaveConfig()` finally saves the new settings so that they'll be there next time you start the game.

Put everything together, and `ExampleListener.uc` looks like this:

```
class ExampleListener extends UIScreenListener config(NonexistentConfigName);

`include(MCM_Tutorial/Src/ModConfigMenuAPI/MCM_API_Includes.uci)
`include(MCM_Tutorial/Src/ModConfigMenuAPI/MCM_API_CfgHelpers.uci)

var config bool CHECKBOX_VALUE;
var config bool CONFIG_VERSION;

event OnInit(UIScreen Screen)
{
    `MCM_API_Register(Screen, ClientModCallback);
}

simulated function ClientModCallback(MCM_API_Instance ConfigAPI, int GameMode)
{
    local MCM_API_SettingsPage Page;
    local MCM_API_SettingsGroup Group;
    
    LoadSavedSettings();
    
    Page = ConfigAPI.NewSettingsPage("Example Tab Label");
    Page.SetPageTitle("Example Title");
    Page.SetSaveHandler(SaveButtonClicked);
    
    Group = Page.AddGroup('Group1', "General Settings");
    
    Group.AddCheckbox('checkbox', "Example Checkbox", "Example Checkbox Tooltip", CHECKBOX_VALUE, CheckboxSaveHandler);
    
    Page.ShowSettings();
}

`MCM_CH_VersionChecker(class'MCM_Tutorial_Defaults'.default.VERSION,CONFIG_VERSION)

simulated function LoadSavedSettings()
{
    CHECKBOX_VALUE = `MCM_CH_GetValue(class'MCM_Tutorial_Defaults'.default.SETTING,CHECKBOX_VALUE);
}

`MCM_API_BasicCheckboxSaveHandler(CheckboxSaveHandler, CHECKBOX_VALUE)

simulated function SaveButtonClicked(MCM_API_SettingsPage Page)
{
    self.CONFIG_VERSION = `MCM_CH_GetCompositeVersion();
    self.SaveConfig();
}

defaultproperties
{
    ScreenClass = class'MCM_OptionsScreen';
}
```

Short, and no UI code!

### Testing

To test, you need to have the ModConfigMenu mod installed. You can do it two ways: either install it from Steam Workshop, or compile this mod from source. You can find the source code in this repository.
