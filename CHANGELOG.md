# EnchantVisuals — source and release history

**Project creator:** Babuni.dev.  
**Interpretation:** Dated Git commits and release notes support the entries below; prior local experiments and game tests are reproduced as **reported history**, not new independent verification.

## 2026-10-27 — expanded portfolio and safety documentation

- Expanded README and added substantial concept, roadmap, developer rules, architecture, design, content inventory, decisions, narrative DEVLOG and AI collaboration record.
- Corrected README release/issue links from an older GitHub owner to the current `babunidev/EnchantVisuals`.
- Distinguished original September 11 **in-game-tested earlier binary** from September 18 **v1.0.1 renamed rebuild** with historically reported successful offline tests and **remaining in-game validation**.
- Documented exact-client restriction, temporary visual marker strategy, original-renderer priority, reversible hooks via configuration/restart, installer/loader assumptions and diagnostic log privacy.
- **11 Markdown files only**. No native source, MinHook, installer, tests, assets or licenses were changed. No executable run in this session.

## 2026-09-11 — Octo Enchant Visuals original publication

Commit **`5213d0416e46`** (“Publish Octo Enchant Visuals with screenshots and release installer”) introduced the main C++ source, signature table, visual-pair helper, x86 build script, vendored **MinHook 1.3.4**, original MIT license, PowerShell installer, original Readme and four effect screenshots. It was already a relatively complete **native DLL**, not a WoW Lua addon.

The first README described a **permanent blue weapon enchant glow alongside Rockbiter, Flametongue, Windfury or Frostbrand** and reported successful live-client checks of the earlier diagnostic build: full login, repeated restarts, effect replacement, and sheath/unsheath. It also explicitly reported earlier development builds with inconclusive **login/loading failures**, so the release should not be portrayed as an effortless first attempt.

GitHub tag **v1.0.0** is preserved historically, with its download superseded by the later v1.0.1 release. No individual earlier prototype commits are visible.

## 2026-09-18 — Enchant Visuals v1.0.1 rename/rebuild

Commit **`6fe17ecff625`** (“Use provider-neutral names and client compatibility descriptions”) renamed the original Octo-namespaced DLL/source, INI, log files, build identifiers and installer messages to **EnchantVisualsDiagnostic** / EnchantVisuals. The exact-client validation, C++ visual-combination logic and runtime signature table remained in place.

The installer was made more careful about recognizing earlier releases **by DLL checksum rather than filename alone**, preserving existing `EnableHooks` config, keeping unrelated loader entries, creating backups and refusing unrecognized current DLL contents. It also added `tests/test_installer.ps1` for repeat installation, upgrade, uninstall and checksum-refusal behavior.

The [v1.0.1 release](https://github.com/babunidev/EnchantVisuals/releases/tag/v1.0.1), published **September 18**, distributes **EnchantVisuals-1.0.1.zip** and **SHA256SUMS.txt**. Release notes **report** successful x86 build, visual-selection tests and installer tests. They specifically warn that the **renamed rebuilt binary had not yet been revalidated in game**. No stronger runtime claim is warranted from that evidence.

## 2026-10-26 — author credit and initial documentation

- **`058a1c3a8a3d`** credited **Babuni.dev** in the README.
- **`31c54d414f7d`** changed the MIT copyright notice from an earlier pseudonym to **Babuni.dev**.
- **`9d42b89fe61e`** established brief concept, roadmap, changelog, AGENTS, architecture, decisions and DEVLOG files.
- **`03b86114172b`** linked that documentation from README.

There were **no new native-code feature commits** in October in the inspected Git history. This audit expands documentation only.
