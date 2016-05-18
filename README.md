# Mod Config Menu

XCOM 2 Mod Config Menu: a shared settings menu for Xcom 2 mods.

### Features

* **Optional dependency** - Your mod still works when MCM isn't installed.
* **Very simple API** - A basic settings page only takes a few lines. You don't have to write UI code if you don't want to.
* **Compiles with your code** - One function call makes the page, another makes the button, and if you're doing it wrong ModBuddy will tell you.
* **Lots of useful features** - You can preview settings, dynamically change one setting based on another, even inject a custom settings UI.
* **Built-in version control**: if your mod and the MCM versions are incompatible, MCM will handle it gracefully.

### Gamers: How do I use this?

1. Install this mod via [Steam Workshop](http://steamcommunity.com/sharedfiles/filedetails/?id=667104300) or [Nexus](http://www.nexusmods.com/xcom2/mods/573/).
2. That's it! If you have any mods that use MCM, it'll just work.

### Developers: How do I use this?

For details, see [the documentation](https://github.com/andrewgu/ModConfigMenu/blob/master/documentation/intro.md).

1. Install the MCM mod. Recommend you do this by cloning the repo and compiling in ModBuddy.
2. Add the API source files into your ModBuddy project, and make a few specific configuration changes.
3. **Warning:** If you use MCM, make sure that your mod loads configurations properly when MCM is missing or if the player never actually opens MCM. See the tutorial for specifics. 

### Screenshots

Mod Settings button in the options screen:

![Mod Settings button in the options screen](https://raw.githubusercontent.com/andrewgu/ModConfigMenu/master/Res/screen1.jpg "Mod Settings button in the options screen")

Example mod rendered in the MCM UI:

![Example mod rendered in the MCM UI](https://raw.githubusercontent.com/andrewgu/ModConfigMenu/master/Res/screen2.jpg "Example mod rendered in the MCM UI")

### Credits

In addition to our two contributors, many thanks to two collaborators who have been critical to this project:

* BlueRaja
* Patrick-Seymour

As well as various others who have contributed to this project's ongoing development:

* RealityMachina
* CMDBob

### License

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
