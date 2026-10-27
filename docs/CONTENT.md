# EnchantVisuals — visual inventory, release packaging and rights

**Creator:** Babuni.dev. **Source:** committed C++ tables, screenshots, installer, licenses and release metadata.

## Supported temporary Shaman visuals

| Effect | Client visual identifier | Temporary marker code |
| --- | ---: | ---: |
| Rockbiter | 61 | 1 |
| Flametongue | 32 | 2 |
| Windfury | 81 | 3 |
| Frostbrand | 33 | 4 |

These are **client visual IDs** recognized by `VisualPair.h`, not spell IDs exposed by a modern addon API, and they should not be described as a transferable list for other client builds. The mod pairs one of these with an already selected valid permanent enchant effect only when original selection matches that permanent effect.

A built-in priority visual, invalid data, unknown temporary effect or identical effect is left in the client's original rendering mode.

## The four game-art screenshots

The repository includes exactly four committed screenshots of the historically tested earlier build:
- [Rockbiter with permanent blue glow](screenshots/rockbiter.png)
- [Flametongue with permanent blue glow](screenshots/flametongue.png)
- [Windfury with permanent blue glow](screenshots/windfury.png)
- [Frostbrand with permanent blue glow](screenshots/frostbrand.png)

They depict World of Warcraft game assets; images do not imply ownership over original Blizzard enchant art. No custom texture files, in-game UI art bundle or new shader sources were found. Do not replace these existing images without user approval.

## Source and build artifacts

| Path | Meaning |
| --- | --- |
| [`src/EnchantVisuals.cpp`](../src/EnchantVisuals.cpp) | Native x86 hooks, signature compatibility, render append and diagnostics |
| [`src/VisualPair.h`](../src/VisualPair.h) | Four-effect pairing/decoding rules |
| [`src/ClientSignatures.h`](../src/ClientSignatures.h) | Exact inspected client byte-region signatures |
| [`build.cmd`](../build.cmd) | Visual-pair test then build/link of diagnostic x86 DLL |
| [`package/Install.ps1`](../package/Install.ps1) | Installer/uninstaller with digest checks and backups |
| [`package/EnchantVisualsDiagnostic.ini`](../package/EnchantVisualsDiagnostic.ini) | New-package default `EnableHooks=1` |
| [`tests/visual_pair_test.cpp`](../tests/visual_pair_test.cpp) | Pure pairing selection assertions |
| [`tests/test_installer.ps1`](../tests/test_installer.ps1) | Synthetic installer upgrade/remove/invalid-hash fixture |

`build/`, `dist/`, native `*.dll` and logs are gitignored. **The repository's main tree contains no compiled diagnostic DLL.** Users need the published release archive or to build their own developer DLL. The published installer intentionally accepts the recorded release hash, so custom binaries require manual installation rather than a fake release hash.

## Release identity and scope

Current published [v1.0.1](https://github.com/babunidev/EnchantVisuals/releases/tag/v1.0.1), dated September 18, contains **EnchantVisuals-1.0.1.zip** and **SHA256SUMS.txt**. The older [v1.0.0 tag](https://github.com/babunidev/EnchantVisuals/releases/tag/v1.0.0) is preserved as a historical entry with a superseded download.

The DLL is named **EnchantVisualsDiagnostic.dll**, paired with **EnchantVisualsDiagnostic.ini** and logs written as **EnchantVisualsDiagnostic.log**. The external loader is configured through a `dlls.txt` line in the game directory.

The supported WoW.exe SHA-256 appears in the existing README/installer, as does the expected release DLL hash. These constants are identity checks, not cryptographic guarantees of user trust; always obtain actual artifacts from a trusted source and verify the published checksum.

## Licensing and privacy

The original code/documents have an explicit **[MIT LICENSE](../LICENSE)**, credited to **Babuni.dev**. Third-party **[MinHook v1.3.4](../vendor/minhook-1.3.4/LICENSE.txt)** and packaged [license text](../package/MinHook-LICENSE.txt) retain their separate BSD-family obligations, including embedded disassembler components.

The world, weapons, enchantment particle art and frame imagery belong to the game rightsholders. Diagnostic logs include pointer addresses, process/thread IDs and timing; review/redact them before posting. No personal player data was fetched or added during this documentation audit.
