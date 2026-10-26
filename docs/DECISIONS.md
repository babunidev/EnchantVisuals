# EnchantVisuals — decisions and constraints

**Author:** Babuni.dev

## Visible implementation choices

This is not a Lua addon. Narrow binary compatibility and conservative installer safeguards are central; third-party MinHook and WoW assets retain their own credits.

The reasons are partially inferable from source, but formal historical approvals are not recovered.

Run native visual-pair and installer tests on the supported build; do not claim compatibility with other clients; verify safe restoration/uninstall paths.
