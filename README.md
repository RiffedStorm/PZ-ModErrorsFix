<div align="center">

# 🧟 ZomboidFixes

**Small, safe compatibility patches for Project Zomboid Build 42.**
One mod to enable, many errors gone. Nothing in other mods is ever edited or replaced.

![Project Zomboid](https://img.shields.io/badge/Project%20Zomboid-Build%2042.21-8b0000?style=flat-square)
![Type](https://img.shields.io/badge/type-compatibility%20patch-2d7d46?style=flat-square)
![Singleplayer](https://img.shields.io/badge/tested-singleplayer-blue?style=flat-square)

<br>

<a href="https://steamcommunity.com/sharedfiles/filedetails/?id=3774162227">
  <img src="assets/banner.png" alt="Main collection + Project Viewpoint collection" width="900">
</a>

<sub>Made for my <b>main collection</b> &nbsp;➕&nbsp; <b>Project Viewpoint collection</b> setup.</sub>

</div>

---

## 📖 What is this?

Some mods written for older builds throw errors on **Build 42.21** and spam `console.txt` or the in-game error counter.
Instead of editing those mods (which breaks every time they update), this repo ships **one separate patch mod** that
quietly fixes the problems from the outside. Enable it, and the original mods stay exactly as their authors released them.

This repo grows over time: whenever a new error pops up in our modlist, the fix gets added here.

## ✅ Current fixes

| # | Problem | Affected mod(s) | Error you would see | Fixed in |
|---|---------|-----------------|---------------------|----------|
| 1 | Old mods pass body locations as plain strings (`"LeftWrist"`), but 42.21 wants an `ItemBodyLocation` object | Right-click *set alarm / watch* style mods | `expected argument of type ItemBodyLocation, got String` | `B42BodyLocationPatch.lua` |
| 2 | World context menu crashes on objects that have no sprite name | **Project Viewpoint** | `NullPointerException` in `ISWorldObjectContextMenuLogic.fetch` every frame | `B42ContextMenuGuard.lua` |
| 3 | `os.clock()` does not exist in Zomboid's Lua, so a draw handler fails every frame | **Immersive Overlays Retexture – Less Intrusive Version** | `Object tried to call nil in drawOverlay` (`OverlaysExtanded.lua:270`) | `B42OsClockShim.lua` |

> 💡 Got a new error? See [Adding a new fix](#-adding-a-new-fix).

## 🛡️ Safe to enable without the affected mods

You do **not** need any of the mods above installed. Every fix is written defensively:

- Fix 1 only wraps a method if the game provides it, and does nothing unless a mod actually passes a string.
- Fix 2 only filters world objects that have no sprite name, which would crash vanilla anyway.
- Fix 3 only defines `os.clock` if it is missing, and nothing else uses it unless a mod asks for it.

So it is fine to keep it enabled permanently, whether or not you keep those mods.

## 📦 Installation

1. Click **Code → Download ZIP** (or grab a release) and unzip it.
2. Copy the folder `mods/B42BodyLocationPatch` into your Zomboid mods folder:

   | OS | Path |
   |----|------|
   | Windows | `C:\Users\<you>\Zomboid\mods\` |
   | Linux / macOS | `~/Zomboid/mods/` |

3. Start the game, open **Mods**, and enable **B42 Body Location Patch**.
4. Load your save as usual. No new game needed.

The final path should look like this:

```
Zomboid/
└── mods/
    └── B42BodyLocationPatch/
        ├── mod.info
        └── 42/
            ├── mod.info
            └── media/lua/
                ├── client/B42ContextMenuGuard.lua
                └── shared/
                    ├── B42BodyLocationPatch.lua
                    └── B42OsClockShim.lua
```

> The mod ID stays `B42BodyLocationPatch` even as new fixes are added, so updating never breaks your mod list or saves. Just replace the folder.
