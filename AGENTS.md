# EnchantVisuals — developer and AI agent rules

**Original creator / creative director / decision authority:** Babuni.dev.  
**Current release:** v1.0.1, exact supported **32-bit WoW 1.12.1 (5875)** build.  
**Licensing:** original code [MIT](LICENSE); vendored MinHook [BSD-family](vendor/minhook-1.3.4/LICENSE.txt).

## Preserve the authored visual idea

The artwork-level objective is **coexistence of a permanent weapon glow and one recognized Shaman temporary imbue**, while maintaining the game's own texture/attachment system and built-in visual priority. Do not change combat mechanics, enchant data, packet handling or gameplay effects.

This is not a Lua addon. Do not propose installation under Interface/AddOns. It is a native DLL loaded by an **existing** `dlls.txt`-capable launcher on the exact client hash, with an accompanying INI and log. Compatibility with other executables is **not** implied by sharing a version number.

## Safe source/installer workflow

1. Read current [README](README.md), [concept](CONCEPT.md), [roadmap](ROADMAP.md), [architecture](docs/ARCHITECTURE.md), [decisions](docs/DECISIONS.md), [journal](docs/DEVLOG.md) and original C++/PowerShell scripts before editing.
2. Require verified x86 build and **do not weaken** executable SHA-256, five runtime signatures or fixed-base checks to enable unsupported clients. Do not patch the executable on disk by default.
3. `VisualPair.h` encodes only four Shaman visual values, preserves nonqualifying/duplicate/built-in-priority values, and uses a temporary marker *only between selection and rendering*. Never persist marker bytes to item records, DBC fields, disk or network packets.
4. Native code uses MinHook for two visual selectors and renderer; `AppendVisual` enters the supported client renderer **after its clear-children step**. Changing this is memory-safety-sensitive and requires real-client tests, not just static inspection.
5. The program's diagnostic INI **defaults to enabled** only on a new installation; existing disabled settings are intentionally preserved. Changing the INI requires a process restart. Do not claim `/reload` or live DLL unload is supported.
6. Installer expects `dlls.txt`; preserves unrelated entries, recognizes earlier owned DLL hashes, creates backups and refuses unrecognized DLL under the current name. It has no transactional rollback across all file operations: test failure paths and preserve backups.
7. Build uses Visual Studio **x86 Native Tools**; `build.cmd` first compiles/runs `tests/visual_pair_test.cpp`. Separately test `package/Install.ps1` using `tests/test_installer.ps1`. Neither proves render safety in WoW.
8. Maintain third-party MinHook licenses and Babuni.dev MIT copyright. Screenshots show WoW art, not original mod-supplied assets.
9. Treat diagnostic logs as potentially sensitive for process/thread IDs, memory addresses and timing. Review/redact before sharing.
10. The September 11 previous-build game-test claim must **not** be transplanted to the September 18 v1.0.1 rebuilt DLL without a new observed client test.

## Collaboration and provenance

Record user intent and constraints, AI alternatives/contributions, revisions and rejected designs, explicit approvals/deferrals, exact code/assets/commit, and **tests actually run**. Never assign Babuni.dev's original visual idea to AI retroactively. No unrecorded earlier design dialogues are to be invented.

Update README, CONCEPT, ROADMAP, CHANGELOG, AGENTS, docs/ARCHITECTURE, docs/DESIGN, docs/CONTENT, docs/DECISIONS, docs/DEVLOG, and docs/AI_COLLABORATION for substantive changes. The current October 27 task is strictly **documentation only**.
