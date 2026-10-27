# Enchant Visuals

**Author:** Babuni.dev

Keep your permanent weapon enchant glow **and** your shaman imbue visible at the same time.

A small cosmetic client mod for the supported **World of Warcraft 1.12.1 executable**, supporting Rockbiter, Flametongue, Windfury, and Frostbrand. Your +4 weapon damage enchant can keep its blue glow while the shaman effect plays around the same weapon.

**[Download EnchantVisuals v1.0.1](https://github.com/babunidev/EnchantVisuals/releases/tag/v1.0.1)**

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

Earlier development builds had reported login/loading failures whose cause was not conclusively established. This release rebuilds that implementation with neutral names; the rebuilt binary has not yet been validated in game. If you encounter a problem, disable the mod, restart, and report your client version and reproduction steps in [Issues](https://github.com/babunidev/EnchantVisuals/issues).

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

## Developer, safety and portfolio notes

**This is a native-process DLL, not a WoW Lua addon.** Use it only with an independently verified, supported 32-bit Windows client and an existing, functioning DLL-loading launcher that uses `dlls.txt`. The installer itself expects an existing `dlls.txt`; it does not install or configure a launcher. A modified/different WoW executable fails the installer SHA-256 check, while the DLL itself checks a fixed image base and five runtime code signatures before installing hooks. Those safeguards reduce accidental mismatches but are not proof of general binary safety or of compatibility with every custom server.

**Installation/uninstallation deserves a backup and a fully closed game.** The PowerShell installer maintains unrelated `dlls.txt` entries and copies existing recognized mod/configuration/loader files into a backup folder before making supported changes. It recognizes prior builds by hash, not merely a filename. Uninstall removes recognized mod-owned DLL/INI and loader references; it does not delete diagnostic logs or roll back arbitrary unrelated changes. If `EnableHooks=0` is preserved from an earlier configuration, an upgrade may leave hooks intentionally disabled.

**What is tested?** The initial **September 11, 2026** build was *reported* tested in game for all four Shaman effects, repeated logins, effect replacement and sheathing. The later **September 18 v1.0.1 rebuilt binary** has a published release whose notes report successful x86 compilation, visual-pair tests and installer tests, but explicitly say the rebuilt DLL still needs new in-game validation. This October 27 documentation audit neither executed the DLL nor independently ran any compiler, test, installer or game-client verification. Equipment swaps and natural imbue expiration are still open visual checks.

**Boundaries and privacy:** The mod changes what the local client renders, not stats or other players' installations. Its diagnostic log can contain pointer addresses, process/thread identifiers and timing data; inspect and redact logs before publishing or sending them. The source is [MIT licensed](LICENSE) under Babuni.dev's notice; bundled [MinHook 1.3.4](vendor/minhook-1.3.4/LICENSE.txt) retains its separate BSD-family license and the screenshots depict World of Warcraft assets owned by their rightsholders.

## Development documentation

- [Creative concept](CONCEPT.md) · [Verification roadmap](ROADMAP.md) · [Git and release changelog](CHANGELOG.md)
- [C++ and installer architecture](docs/ARCHITECTURE.md) · [Visual design](docs/DESIGN.md) · [Assets and packaging](docs/CONTENT.md)
- [Decisions and tradeoffs](docs/DECISIONS.md) · [Narrative development journal](docs/DEVLOG.md)
- [Human–AI collaboration](docs/AI_COLLABORATION.md) · [Contributor rules](AGENTS.md)

**Original creative direction:** Babuni.dev. **Current audit contribution:** source/history analysis and documentation only, without modifying the mod or the MIT/MinHook licenses.

