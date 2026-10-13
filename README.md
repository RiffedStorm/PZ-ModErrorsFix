<div align="center">

# Error fixes for PZ mods

**One mod to enable, many errors gone**.

![Project Zomboid](https://img.shields.io/badge/Project%20Zomboid-Build%2042.21-8b0000?style=flat-square)
![Type](https://img.shields.io/badge/type-compatibility%20patch-2d7d46?style=flat-square)
![Singleplayer](https://img.shields.io/badge/tested-singleplayer-blue?style=flat-square)

<br>

<a href="https://steamcommunity.com/sharedfiles/filedetails/?id=3774162227">
  <img src="assets/banner.png" alt="Main collection + Project Viewpoint collection" width="900">
</a>

<sub><b>For both **Main collection** and **Project Viewpoint** collection</b></sub>

</div>

---

## 📦 Installation

1. Click **Code → Download ZIP** (or grab a release) and unzip it.
2. Copy the folder `mods/RiffedPatches` into your Zomboid mods folder:

   | OS | Path |
   |----|------|
   | Windows | `C:\Users\<you>\Zomboid\mods\` |
   | Linux / macOS | `~/Zomboid/mods/` |

3. Start the game, open **Mods**, and enable **Riffed Patches**.
4. Load your save as usual. No new game needed.

The final path should look like this:

```
Zomboid/
└── mods/
    └── RiffedPatches/
        ├── mod.info
        └── 42/
            ├── mod.info
            └── media/lua/
                ├── client/B42ContextMenuGuard.lua
                └── shared/
                    ├── B42BodyLocationPatch.lua
                    └── B42OsClockShim.lua
```

> The mod ID stays `RiffedPatches` even as new fixes are added, so updating never breaks your mod list or saves. Just replace the folder.

## License
MIT
