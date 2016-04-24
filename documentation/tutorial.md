# Tutorial

### Setting up your project

Before we get into writing the code, we need to set up the API files you will compile your mod against. 
[See here for more information on how this works.](https://github.com/andrewgu/ModConfigMenu/blob/master/documentation/sharedcode.md)

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

Now that you've set up the API files, you're ready to start writing the actual code.

### Creating a settings page

### Adding some settings

### Saving settings

### Testing
