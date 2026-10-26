# EnchantVisuals — development history

**Author:** Babuni.dev

## Source-based reconstruction — 2026-10-26

A native cosmetic mod for the 32-bit WoW 1.12.1 (5875) client that allows permanent weapon enchant glows to coexist with Shaman imbue visuals. C++ code in src/EnchantVisuals.cpp with client signatures and visual pairing logic builds a native DLL. Install.ps1 checks executable and DLL checksums and configures an external loader; MinHook is vendored under its own license. This is not a Lua addon. Narrow binary compatibility and conservative installer safeguards are central; third-party MinHook and WoW assets retain their own credits.

This account preserves the technical direction evidenced in today's code without inventing original decisions or development dates. Babuni.dev retains original artistic authorship; AI interpreted the available repository material and authored this documentation. No code behavior was changed or newly verified. Run native visual-pair and installer tests on the supported build; do not claim compatibility with other clients; verify safe restoration/uninstall paths.
