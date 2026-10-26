# Enchant Visuals

**Author:** Babuni.dev

Keep your permanent weapon enchant glow **and** your shaman imbue visible at the same time.

A small cosmetic client mod for the supported **World of Warcraft 1.12.1 executable**, supporting Rockbiter, Flametongue, Windfury, and Frostbrand. Your +4 weapon damage enchant can keep its blue glow while the shaman effect plays around the same weapon.

**[Download the latest release](https://github.com/Morkahja/EnchantVisuals/releases/latest)**

## In game

Screenshots of the preceding build, showing a permanent blue enchant glow together with each imbue.

| Frostbrand | Windfury |
| :---: | :---: |
| ![Frostbrand and permanent blue weapon glow](docs/screenshots/frostbrand.png) | ![Windfury and permanent blue weapon glow](docs/screenshots/windfury.png) |
| **Rockbiter** | **Flametongue** |
| ![Rockbiter and permanent blue weapon glow](docs/screenshots/rockbiter.png) | ![Flametongue and permanent blue weapon glow](docs/screenshots/flametongue.png) |

## Install

Requires the supported **32-bit World of Warcraft 1.12.1 (5875) client** and an existing launcher/DLL loader that reads `dlls.txt` beside `WoW.exe`. This is a native client mod, not an Interface/AddOns addon. Other client builds are not supported.

1. Download **EnchantVisuals-1.0.1.zip** from Releases, and extract it outside your game folder.
2. Fully close WoW. The launcher can stay open.
3. Open PowerShell in the extracted folder and run:

   ```powershell
   powershell -ExecutionPolicy Bypass -File .\Install.ps1 -ClientPath "C:\Games\World of Warcraft"
   ```

   Replace the example path with the folder containing your `WoW.exe`. Omitting `-ClientPath` prompts for the folder.
4. Start the game through your usual DLL-loading launcher. If it lists individual mods, enable **EnchantVisualsDiagnostic.dll**.

The installer checks the executable and release DLL checksums, preserves unrelated loader entries and your existing configuration, and saves backups beside the script. Previous releases are recognized by their checksums and replaced without depending on their file names. Only **one mod DLL** is needed; the matching INI is its configuration file.

The current library is `EnchantVisualsDiagnostic.dll`. It is a rebuilt binary with neutral configuration and log names.

## Disable or remove

Set `EnableHooks=0` in `EnchantVisualsDiagnostic.ini` beside WoW.exe, then fully exit and restart WoW. Set it back to `1` to re-enable. A UI reload is not enough.

To uninstall, close WoW and run the extracted installer:

```powershell
powershell -ExecutionPolicy Bypass -File .\Install.ps1 -ClientPath "C:\Games\World of Warcraft" -Uninstall
```

Existing diagnostic logs are left in place and can be deleted while the game is closed.

## What it changes

The DLL extends the client's weapon visual selection and attachment routines using MinHook. It renders both qualifying effects with the game's existing visuals. It does not change enchant stats, game assets, the executable on disk, or network settings.

The result is local to your computer. Qualifying weapons on other characters can also show both effects on your screen; other players need their own installation to see the change.

## Tested behavior and limitations

The preceding build was confirmed in game on September 11, 2026. The renamed 1.0.1 rebuild passes offline tests; these in-game checks must be repeated for the new binary:

- Full login and world entry, including repeated game restarts.
- Permanent enchant glow combined with all four shaman imbues.
- Replacing one imbue with another.
- Sheathing and unsheathing.

Natural imbue expiration has not yet been visually checked in game because the tested imbues lasted an hour. Cleanup logic passed offline tests. Equipment swaps have not been separately confirmed.

Weapons whose built-in visual takes priority retain the original priority rule. Non-shaman temporary enchants are outside this mod's scope.

Earlier development builds had reported login/loading failures whose cause was not conclusively established. This release rebuilds that implementation with neutral names; the rebuilt binary has not yet been validated in game. If you encounter a problem, disable the mod, restart, and report your client version and reproduction steps in [Issues](https://github.com/Morkahja/EnchantVisuals/issues).

Diagnostic logging remains enabled in `EnchantVisualsDiagnostic.log`, capped at 20,000 trace events per game session. Review logs before sharing them.

### Exact compatibility

The installer refuses a different executable. Runtime code signatures provide an additional check.

| File | SHA-256 |
| --- | --- |
| Supported WoW.exe | `183cd1128bcb9fa7d1bc7b3eaaa3ab384f71fdaadfa1be3ad8d458e93587d4bd` |
| Release DLL | `0f21b57f3f7f9d763fc69fca37431eca42499e7da71c154eb7b08c288752d87e` |

## Build from source

Install Visual Studio C++ Build Tools with the Windows SDK. Open an **x86 Native Tools Command Prompt**, then run:

```bat
build.cmd
```

This runs the visual-pair unit tests and builds `dist\EnchantVisualsDiagnostic.dll` using the static C runtime. MinHook 1.3.4 is included under `vendor/`.

The release download contains the renamed rebuild. Rebuilds may have different checksums; the release installer deliberately accepts only the published binary. Developer builds require manual placement of the DLL and INI beside WoW.exe and one matching entry in `dlls.txt`, while WoW is closed.

## License and credits

Original mod code is MIT licensed; see [LICENSE](LICENSE). [MinHook](https://github.com/TsudaKageyu/minhook) retains its [BSD license](vendor/minhook-1.3.4/LICENSE.txt).

Screenshots depict World of Warcraft; game artwork belongs to its respective owners. This is an independent community project.
