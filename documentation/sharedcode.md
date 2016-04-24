# Making Mods Share Code

Compiling against shared modules is a core concept in programming. It's the most common way for different code to use shared base functionality. Unfortunately, it's not straightforward to do when modding Xcom 2. 

To keep programming simple, ModConfigMenu uses a workaround to make it possible to compile your code as if ModConfigMenu were part of the core game. This lets you keep your code clean and straightforward, and it lets you avoid jury-rigged message passing mechanisms.

The method described here is how ModConfigMenuAPI works under the hood.

### The Problem

Let's say you have two packages, `A` and `B`. `A` wants to use code from `B`, but you want `B` to be distributed as a separate mod. The challenge is that ModBuddy isn't built for this, and neither is Unreal Engine. When you compile `B` using the Xcom SDK, it's compiled against the base game. When you compile `A`, it's also compiled against the base game. But if you want to compile `A` with `B` included... it's not straightforward at all. The problem is that if you try to compile `A` with `B` included, it will produce two module files. When you try to load both mods, you will have a duplicate compilation of `B`, so you can't guarantee that Xcom 2 will load the original `B`. In theory this works if only one version of `B` is ever made, but then you could never patch `B`. That's bad.

Now replace `A` with "Your Mod" and `B` with "ModConfigMenu. See the problem?

### Workaround

The fix is to make it so that `B` doesn't need to change in order to patch `B`. But how?

The key is that UnrealScript supports interfaces. They're definitions of functionality but contain no actual code themselves. So you make a mod `C` that implements all of `B`'s interfaces. Then when you program `A`, it can call into `B` as well without caring about `C`'s existence. So `B` always stays the same, but since `B` doesn't need to contain any real code, that's much easier to do. `C` is the actual code, and as long as changes to `C` don't require changing `B`, then everybody is happy!

But what if `C`'s changes do need to change `B`? The answer is to make a new package of interfaces, `D`, so that `A` and `C` both use `D`.

This is the approach ModConfigMenu takes. The core ModConfigMenu mod is `C`. ModConfigMenuAPI is `B`. Your mod is `A`. If ModConfigMenu adds more types of settings or other features that it wants to give to `A` in the future, we will create a package `D`. Maybe we'll call it `ModConfigMenuAPI2`.

### How to Compile `A` against `B`

So you know how this works in principle. How does it actually work in a project?

Xcom 2's folder structure for mods looks like this:
```
MyMod
  > MyMod.v12.XCOM_suo
  > MyMod.XCOM_sln
  MyMod
    > MyMod.x2proj
    Config
      ...
    Src
      MyMod
        Classes
          *.uc
      PackageA
        Classes
          *.uc
      PackageB
        Classes
          *.uc
```

So if you want more than one package in your mod, you need a folder for each package in the `Src` folder.

Next, since each mod has a "primary package" and then a bunch of dependencies, we tell Unreal Engine to treat the extra packages as dependencies in `XComEngine.ini`. The first two lines are pretty typical for Xcom 2 mods. The last three lines are the magic lines. You don't see them in the SDK documentation, but that's how you do it. 

```
[Engine.ScriptPackages]
+NonNativePackages=MyMod

[UnrealEd.EditorEngine]
+EditPackages=PackageA
+EditPackages=PackageB
```

### How MCM Does It

As you can probably tell, MCM uses exactly this approach. ModConfigMenu is a standalone mod that implements the API. Every mod that uses ModConfigMenu imports the API and compiles against it. Since the API package promises to never change, Unreal Engine will always load the correct version of the API, so we've effectively created a way for you to compile your mod against MCM, as if MCM were part of the core game.
