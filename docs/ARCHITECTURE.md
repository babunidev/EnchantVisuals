# EnchantVisuals — native architecture and compatibility

**Source reviewed:** `src/EnchantVisuals.cpp`, `src/VisualPair.h`, `src/ClientSignatures.h`, `build.cmd`, `package/Install.ps1`, `tests/visual_pair_test.cpp`, `tests/test_installer.ps1`, vendored MinHook and README. October 27, 2026. **Static inspection only; no executable ran in this audit.**

## Runtime boundary

```text
existing external DLL-capable launcher
    -> WoW.exe (x86 1.12.1 / 5875 with exact expected executable hash)
        -> dlls.txt contains EnchantVisualsDiagnostic.dll
        -> EnchantVisualsDiagnostic.ini [Diagnostic] EnableHooks=1
        -> DLL_PROCESS_ATTACH
        -> fixed image base + five in-memory signature checks
        -> MH_Initialize, create THREE MinHook detours, enable hooks
           -> item visual-selection function
           -> visible-item visual-selection function
           -> weapon model renderer
        -> temporary paired selector marker
        -> original renderer: permanent visual
        -> supported client append path: temporary Shaman visual
```

If the INI is disabled, the diagnostic DLL logs **CONTROL ONLY** and installs no client hooks. Runtime incompatibility logs a disabled message and does not install hooks. The DLL is expected to remain loaded **for the process lifetime**; disabling means a full game restart, not an in-game `/reload` or unload.

## Visual selection and transient encoding

The two selector detours invoke the original selection routines *first*. They inspect the item/visible-item enchantment IDs, translate each ID through client visual tables, validate resulting visual entries, and combine only when the original selected visual equals the **permanent visual**.

`VisualPair.h` recognizes exactly four temporary effect **visual IDs**:

| Shaman effect | Visual ID | Encoded code |
| --- | --- | --- |
| Rockbiter | 61 | 1 |
| Flametongue | 32 | 2 |
| Windfury | 81 | 3 |
| Frostbrand | 33 | 4 |

`Combine` returns the original selected visual unless all strict conditions pass: original selection positive, permanent valid/nonzero/at most 16-bit, original selection exactly equals permanent, recognized Shaman temporary visual, and permanent and temporary differ. Otherwise it encodes `0x40000000 | (permanent << 8) | code` in the **transient selection result**.

`Decode` validates the marker high byte, extracts the permanent value and maps code back to a Shaman temporary visual. This marker travels only between the selection and render hooks. As the code comments state, it **must not be written into DBC, item attributes, network messages, or persistent caches**. Different pairs yield different values, avoiding accidental reuse of a single cached identifier for changed imbues.

## Renderer path and reason for exact signatures

The rendering detour decodes the marker. If not paired, it directly delegates to the original game renderer with the untouched selected value. If paired, it calls the original renderer with the permanent visual first, then invokes `AppendVisual` to render the Shaman visual.

The `AppendVisual` helper is a **32-bit naked assembly function** that reconstructs the expected stack/register state and jumps into the **middle of the supported client's existing renderer, after its clear-child-effects call**. This lets the second effect join the first instead of erasing it. It also makes the project particularly sensitive to executable bytes, calling conventions, layout changes and other runtime DLLs modifying the renderer.

The code requires a main executable loaded at **0x400000**, then validates **five byte ranges** via FNV-1a hashes and `VirtualQuery` before installing hooks. It uses hardcoded addresses for the two selector paths, renderer, enchantment lookup and effect-attachment/cleanup. These are **not portable APIs**. They only describe this inspected executable variant.

On hook failures, MinHook is uninitialized/disabled according to branch and an error is logged. Source-level checks reduce obvious mismatches but do not prove crash-free behavior, memory safety under arbitrary mods or valid graphics on every character/weapon.

## Diagnostic behavior and privacy

Build is compiled with `/DENCHANT_DIAGNOSTIC`. The INI controls whether to attempt hooks. The diagnostic `Trace` method writes stage, object pointer, event sequence, process ID, thread ID, tick time and render depth into `EnchantVisualsDiagnostic.log`. It caps **trace events** at 20,000 per process; non-trace log lines can still be appended. Logs persist across sessions and should be inspected/redacted before public sharing.

The fixed C runtime build uses C++17 and `/MT`. `build.cmd` checks compiler availability and `VSCMD_ARG_TGT_ARCH=x86`, compiles/runs the visual-selection test, compiles MinHook C parts and links the x86 DLL.

## Installer expectations and protections

`package/Install.ps1` checks no **WoW process** is running, resolves supplied game path, verifies the **exact game EXE SHA-256** and package DLL SHA-256, then reads existing `dlls.txt` as UTF-8. It can prompt for `ClientPath`. **It expects `dlls.txt` to exist**; it does not ship a loader.

The installer scans DLLs in the client root for **two previously known release hashes** and excludes those owned DLL filenames from the loader list. It keeps unrelated entries in place and, when installing, preserves a current or prior INI's bytes, otherwise defaulting to `EnableHooks=1`. It backs up recognized DLLs, INI files and loader file under a unique folder beside the extracted installer, then writes the new loader list. It refuses unrecognized content at the current `EnchantVisualsDiagnostic.dll` path. Uninstall removes owned DLL/config and loader entries, preserving unrelated entries and leaving logs in place.

**Important limitation:** the script creates backups but not a single atomic transaction. A filesystem error after preflight can leave partial changes; recovery requires restoring from backup. Tests should cover this explicitly rather than describing the installer as unconditionally safe.

`tests/test_installer.ps1` uses fake temporary files with a **mock Get-FileHash** for test-only content. Its success doesn't prove the real published ZIP or actual WoW.exe hash unless those real bytes are independently checked.

## Testing and third-party obligations

`tests/visual_pair_test.cpp` tests recognized temporary visuals, non-Shaman effects, duplicates, invalid marker decode, built-in visual priority, expiration-input fallback and cache-key distinction. Those unit tests cover the pure pairing rules **only**.

[MinHook 1.3.4](../vendor/minhook-1.3.4/LICENSE.txt) is bundled as third-party hooking code with its own license, not original Babuni.dev authorship. Babuni.dev's MIT license lives in [LICENSE](../LICENSE). The prior-build September 11 game screenshots are evidence of historically reported function, not fresh validation of v1.0.1.
