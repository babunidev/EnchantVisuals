# EnchantVisuals — implementation decisions, risk boundaries, open choices

**Creator / decision-maker:** Babuni.dev. **Method:** source and Git history inspection, **not** invented private conversations.

## Evidence-backed decisions

| Evidence | Implemented choice | Limit |
| --- | --- | --- |
| Sep 11 `5213d041` initial publication | Preserve permanent enchant glows together with four Shaman imbue effects | Cosmetic only; tested earlier binary per README |
| Sep 11 original C++ | Use **two selection hooks plus one renderer hook** instead of Lua | Executable-specific and memory-layout-dependent |
| `VisualPair.h` initial | Encode strictly qualified effects with a transient marker; keep original priority otherwise | Only 4 Shaman visual codes supported |
| `ClientSignatures.h` | Five exact byte-region hashes + fixed image base | Guardrail, **not broad compatibility** |
| `package/Install.ps1` | Verify executable/DLL hash, back up files, use preexisting loader | Does not install the loader or auto-roll-back every failure |
| Sep 18 `6fe17ecf` | Rename DLL/config/log to provider-neutral **EnchantVisualsDiagnostic**, rebuild, recognize earlier owned DLLs by hash | Requires new in-game check |
| Sep 18 v1.0.1 release | Report successful x86/visual-pair/installer tests and publish zip+digest | Does **not** claim current binary live-tested |
| Oct 26 `31c54d41` | Change MIT copyright pseudonym to **Babuni.dev** | Existing license remains MIT |

These are facts about changes. The record does not supply original discussions, exact author of each earlier C++ line or every rejected alternative.

## Reasoning and tradeoffs visible in current code

**Aesthetic coexistence vs client safety.** The addon seeks a beautiful tiny effect but the only available implementation in this repo is native hooking of old internal rendering routines. The signatures are therefore part of the product contract.

**Append after clearing.** The original render routine clears child effects; two naive render calls would risk replacing the first. The helper jumps into a supported internal entry *after* the clear operation so the second effect can coexist. That is implementation evidence, not independent proof on other game binaries.

**Preserve original selection priority.** Pair only if the selected effect is exactly the permanent effect; preserve negative/sentinel and special cases. This chooses visual restraint rather than forcing glows onto weapons where client rules say otherwise.

**Use ephemeral marker, not mutate saved data.** A high-byte marker encodes which temporary Shaman visual should be added only for selection/render interchange. The code's contract explicitly forbids persisting it to item fields or network packets.

**Rebuild vs prior runtime evidence.** A renamed, recompiled DLL may reproduce the same logic but it is **not the same binary** tested in September 11 gameplay. Treat offline tests as support for logical correctness, not substitution for a new full login/render test.

**Installer convenience vs responsibility.** A script can preserve unrelated `dlls.txt` entries and recognized old configs, yet failure may happen mid-way. Keep recoverable backups and avoid claiming atomicity or safety on an unsupported executable.

## Pending proposals requiring creator approval

- Test and optionally add other temporary effects, or keep four Shaman only?
- Provide a no-diagnostic lightweight build or keep logging for transparency?
- Support additional exactly validated 1.12 executables as **distinct compatibility profiles**, never by bypassing checks?
- Add full installer rollback on partial failure?
- Offer a launcher UI or stay command-line and INI-only?
- Add new screenshots for v1.0.1 when independently game-tested?

None of these is approved or implemented by this documentation pass. Preserve true human decisions and verification evidence when development resumes.
