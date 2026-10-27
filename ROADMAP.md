# EnchantVisuals — verification roadmap

**Final creative decision authority:** Babuni.dev.  
**Current released rebuild:** v1.0.1, published September 18, 2026.  
**Status:** Source features and historical test claims documented. **No current-session build or game test has been run.**

## Implemented and inspected

- Native C++ x86 DLL, **not** a Lua addon; x86 Visual Studio build through [build.cmd](build.cmd).
- Combined visual selection for four recognized Shaman effects: Rockbiter (61), Flametongue (32), Windfury (81), Frostbrand (33), without changing the underlying enchantment data.
- Win32 hooks through MinHook 1.3.4 for two visual selection routines and one renderer, with another call into a client attachment path for the second effect.
- Installer SHA-256 checks for supported 32-bit 1.12.1 (5875) executable and published mod DLL; runtime check for expected image base and **five** in-memory routine signatures.
- Diagnostic DLL controlled by `EnchantVisualsDiagnostic.ini` `EnableHooks=0/1`; game restart required. Logging limited to **20,000 trace events per process session**.
- Safe-intent package installer: backup, known-file removal by hash, unrelated `dlls.txt` preservation, config continuity, idempotent installs and uninstall.
- Four screenshots of the prior tested build and explicit **MIT + MinHook BSD-family** licenses.
- Existing [visual pair C++ test](tests/visual_pair_test.cpp) and [PowerShell installer fixture](tests/test_installer.ps1), plus a published v1.0.1 release with a checksum file.

## P0 — current release in-game safety and correctness

1. On a disposable/backed-up installation of the **exact intended x86 1.12.1 (5875) executable**, verify the `WoW.exe` SHA-256 against the README **before** copying any DLL. Do not attempt unsupported builds or bypass signature checks.
2. Install via an existing, trusted `dlls.txt`-reading launcher, with game fully closed. Preserve old loader, INI, DLL and game files. Record loader version and native process architecture.
3. Test startup, full login/world entry and repeated restarts with the published **1.0.1 binary**, not just the older screenshot-tested build. Record crashes, logs and graphics-driver context.
4. On a weapon with both a permanent glow and a recognized imbue, test **all four** effects in-game. Compare to the committed screenshots with consistent camera/lighting and confirm the original permanent glow remains visible.
5. Replace one imbue with another, sheath/unsheath, switch equipment, change target/zone, logout/relogin and inspect whether render attachments are cleaned up. Equipment swaps were explicitly not yet confirmed in older README evidence.
6. Verify an imbue **naturally expires** and the extra effect disappears cleanly without losing the permanent enchant. This was **not** visually confirmed in the prior build (then one-hour imbue duration).
7. Test weapons whose built-in visual priority overrides the normal selection; confirm those effects remain unchanged.
8. Test no permanent enchant, unsupported temporary effects (including poison), duplicate permanent/temporary effects and invalid visual records: do not introduce extra or ghost visuals.
9. Test toggling `EnableHooks` with full process exit/restart and verify disabled mode installs no hooks. Verify logs report compatible/incompatible status and don't contain sensitive account data before sharing.

## P1 — repeatable build, installer and regression tests

10. Build from source using the Visual Studio **x86 Native Tools Command Prompt** plus Windows SDK. Run [build.cmd](build.cmd), collect compiler output and confirm **tests/visual_pair_test.cpp** executes before DLL linkage.
11. Execute [tests/test_installer.ps1](tests/test_installer.ps1) on its synthetic files with PowerShell. Confirm preserved configuration, unrelated DLLs/loader entries, backups, repeat installation, uninstall, and rejection of wrong hashes.
12. Download the published [v1.0.1 ZIP and checksum](https://github.com/babunidev/EnchantVisuals/releases/tag/v1.0.1), verify archive digest, inspect exact DLL + INI + installer contents and compare published binary checksum with the documented expected hash.
13. Test `dlls.txt` **missing, invalid UTF-8, unexpected contents**, game still running, unsupported exe, unrecognized existing DLL and permission failures. The installer expects `dlls.txt` to exist and read successfully.
14. Test replacement of earlier owned DLL hashes while leaving unrelated DLLs untouched; confirm old disabled `EnableHooks=0` setting is correctly **preserved**.
15. Inspect how installer behaves if it partially fails *after* creating backups. Backups are present but the code does **not** implement an atomic rollback of every file operation.
16. Run the original client's protective signature checks with supported executable only. Never weaken signature verification merely to claim compatibility with more builds.

## P2 — documentation, rights and release quality

17. Preserve Babuni.dev's [MIT LICENSE](LICENSE) and the separately licensed [MinHook source](vendor/minhook-1.3.4/LICENSE.txt), included `package/MinHook-LICENSE.txt`, and game-asset ownership acknowledgement.
18. Create/redact live screenshots for the *renamed v1.0.1 DLL*, separating historical screenshots from freshly reproduced results.
19. Audit diagnostic logs for process IDs, addresses, timestamps and other incidental metadata before attaching them to public issues.
20. Confirm native client modification complies with the relevant user's server/client rules. DLL loading into a modified WoW client is a different compatibility/permission question from installing a Lua addon.

## Creative decisions pending

Should extra visual combinations beyond these four be supported? Should the diagnostic channel have a quieter log default? Should the release include a GUI/launcher assistant? Should other exact executable builds be supported via independently validated profiles? Would a fail-safe restoration strategy be desirable? **None of these is approved in this docs session.**
