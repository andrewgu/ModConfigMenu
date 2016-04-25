# API Doc

### Interface `MCM_API`

##### `function bool RegisterClientMod(int major, int minor, delegate<ClientModCallback> SetupHandler);`

Registers your mod to ask MCM to call your SetupHandler. The major/minor version numbers are to give MCM a way to enforce a  compatibility check to guard against unsupported mods.

We recommend that you use the `MCM_API_Register` macro, which takes care of the major/minor version numbers for you. For more about the major/minor version, see the [advanced features](https://github.com/andrewgu/ModConfigMenu/blob/master/documentation/advanced.md).

`SetupHandler` should be the function where you do page, group, and setting creation. 

##### `delegate ClientModCallback(MCM_API_Instance ConfigAPI, int GameMode);`

The `ClientModCallback` callback takes two critical parameters: the API instance, and the game mode. The API instance is only ever provided during this callback because this is the only time you should be calling the Page/Group/Setting creation functions.

Since `MCM_OptionsScreen` gets initialized once for every time the screen is pulled up, the `ClientModCallback` callback gets called once for every time the screen is pulled up. Thus it's save to assume that `GameMode` is the correct mode for the lifetime of the pages/groups/settings that you create from inside the handler.

##### `enum eGameMode`

Recognized game modes that `ClientModCallback` might receive are:

```
    eGameMode_MainMenu,
    eGameMode_Strategy,
    eGameMode_Tactical,
    eGameMode_Multiplayer,
    eGameMode_Unknown
```

### Interface `MCM_API_Instance`
