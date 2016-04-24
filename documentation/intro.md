# Introduction to ModConfigMenu
##### Quick Start

Follow the [*Tutorial*](https://github.com/andrewgu/ModConfigMenu/blob/master/documentation/tutorial.md). 
You will also want to read
[*Updating Mod Configurations Dynamically*](https://github.com/andrewgu/ModConfigMenu/blob/master/documentation/config.md)

##### Example Code

See the [ModConfigDependencyTest project](https://github.com/andrewgu/ModConfigMenu/tree/master/ModConfigDependencyTest) in this repo for a working example.

##### Advanced Features

This mod supports several very useful advanced features that let you make your settings page more dynamic. 
See the [*Advanced Features*](https://github.com/andrewgu/ModConfigMenu/blob/master/documentation/advanced.md)
documentation for details.

##### API Documentation

For a complete catalog of all of the functions available to you, see [*API Documentation*](https://github.com/andrewgu/ModConfigMenu/blob/master/documentation/apidoc.md)

### Key Concepts

To understand how this mod works, you need to understand its core object types:

1. The *API Instance* (`MCM_API_Instance`) is the entry point for the MCM API. Your mod will create its settings pages from here.
2. The *Page* (`MCM_API_SettingsPage`) represents a visual page of settings, which you can access by clicking the corresponding tab in the options screen. Each page contains groups of settings. Most mods will use only one page.
3. The *Group* (`MCM_API_SettingsGroup`) is a visual grouping of settings. Most mods might only need one group, but more complex mods might want to organize settings into groups.
4. The *Setting* (`MCM_API_Setting` and other Settings classes) are the actual widgets: checkboxes, sliders, dropdowns, etc. Typically these widgets represent some adjustable setting in your mod.

A typical workflow would look like this:

1. Call the API instance to create a page.
2. Add groups to the page.
3. Add settings to the groups.
4. Hook up the code to save settings to an INI file.
