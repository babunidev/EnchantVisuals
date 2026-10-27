# EnchantVisuals — creative and technical development journal

**Creator and creative director:** Babuni.dev  
**Retrospective prepared:** October 27, 2026 from live Git tree, two substantive September commits, original/current README, C++/PowerShell source, published releases, original screenshots and licenses. No missing original chats or uncommitted prototypes are reconstructed as fact.

## Wanting two colors to coexist

The project begins with an aesthetic frustration rather than a gameplay inefficiency. A Shaman has put a permanent enchantment on a weapon: the familiar blue glow of the +4 weapon-damage enchant tells part of the story of that equipment. Then the character adds a temporary imbue, such as Windfury, Flametongue, Frostbrand or Rockbiter. In the 1.12.1 client targeted by this mod, the ordinary visual selection tends to choose a dominant effect. The Shaman's living elemental overlay can displace the permanent glow the player also wanted to see.

Babuni.dev's desired result was simple and expressive: **both visual effects should remain visible on the weapon at the same time**. Neither spell should become stronger, and the client shouldn't invent new particle art. The desired change is entirely in how existing visual effects are chosen and attached for rendering.

That original creative idea belongs to **Babuni.dev**. The assistant writing this retrospective did not conceive it. The repository provides implementation and explanatory evidence, not a transcript of every conversation that led to the first build.

## September 11, 2026 — Octo Enchant Visuals reaches GitHub

The first visible commit, **`5213d0416e46`** (“Publish Octo Enchant Visuals with screenshots and release installer”), is dated September 11. It uploaded a substantial native **C++ x86 DLL project**, an original README, MIT license, vendored MinHook 1.3.4, PowerShell installer, build script, visual selection tests and four in-game screenshots. It was called **Octo Enchant Visuals**, and its README described support for the local 1.12.1 (5875) executable of a named Vanilla-compatible provider.

The implementation had already progressed through significant technical choices by the time it was committed. It wrapped two internal visual-selection paths, for item-related and visible-item-related records, and the model renderer using the **MinHook** library. The logic retained the game's default selector outcome, then—only where the outcome was the permanent enchant visual and an identified Shaman temporary visual was also present—encoded a temporary pair marker that the renderer would recognize.

A normal 1.12 addon Lua file cannot simply instruct the game engine to display two enchant effect children using its existing renderer. Here the effect required native access to rendering internals. That made the project's practical scope unusually narrow: a **32-bit process**, one inspected client memory layout and instruction sequence, and an external loader that reads a DLL name from `dlls.txt`. This was not an addon installed under `Interface/AddOns`.

The first README also contained a point of humility easily lost from technical portfolios: **earlier experimental development builds had login/loading failures**, and their root cause had not been conclusively established. Later source was rewritten or refined until a particular diagnostic binary behaved acceptably in its stated tests, but the repository does not preserve each of those earlier binary stages as independent Git commits. We should keep that uncertainty, not fabricate a tidy sequence of all debugging attempts.

## September 11 — screenshots and reported client observations

The original publication included four screenshots: a permanent blue enchant glow combined respectively with Rockbiter, Flametongue, Windfury and Frostbrand. These are valuable visual evidence precisely because the software's purpose is visual. A reader can see why the result matters without reading any hook code.

The contemporaneous README **reported** successful game-client checks for that original working build: full login and world entry, repeated game restarts, all four Shaman visuals paired with a permanent glow, replacing one imbue with another, and sheathing/unsheathing. The screenshots accompany that description; they do not alone prove every possible equipment condition.

The same description explicitly distinguished tests that had **not** yet happened: weapon equipment swaps were not separately confirmed, and waiting for the imbue to expire naturally was impractical because the then-tested buffs lasted an hour. Offline cleanup tests were reported instead. That makes a careful boundary: the author had reported one combination tested, but not every possible way the lifecycle could end.

GitHub preserves the original **v1.0.0** tag as a superseded historical release. Its direct downloadable asset is no longer present in current release metadata. Treat this as a record of prior distribution, not as the recommended current installer.

## The technical heart: preserving the first effect when adding the second

The pure selector helper in `VisualPair.h` recognizes four client visual identifiers: **Rockbiter 61**, **Flametongue 32**, **Windfury 81** and **Frostbrand 33**. It does not treat those as portable modern spell IDs. The code checks that an actual permanent effect is valid, that the original client picked **that same permanent effect** rather than something higher priority, and that the Shaman temporary effect is recognized and different.

When these tests pass, it packs a **temporary marker and two effect references** into a single integer returned between the selection and render hooks. This marker is explicitly not written into game item fields, network packets, DBC records or save files. It exists to tell the renderer how to compose the weapon's two effect children during that local drawing operation.

Rendering brings a second problem. The client's normal routine first **clears existing child visual effects**. Calling it once for the permanent glow and then naively calling it again for the imbue risks clearing the first. The C++ project instead calls the original renderer for the permanent visual, then executes a specialized **32-bit assembly entry** that jumps into the supported client renderer *after* that clearing step so the imbue is appended.

This is an elegant but high-stakes adaptation to a single executable. It depends on its memory layout, instruction bytes, calling conventions and attach/cleanup behavior. The project therefore checks the expected main-module base, validates **five in-memory code signatures**, and requires an exact **WoW.exe SHA-256** match in the installer before it ever tries to run the hooks.

Those checks are protective boundaries, not guarantees that the software can never crash, that it works with third-party hooks, or that it is permitted on every private server. The visual desire was small, but delivering it required an unusually specialized technical architecture.

## September 18 — separating the project from its original provider name

Commit **`6fe17ecff625`**, “Use provider-neutral names and client compatibility descriptions,” renamed Octo Enchant Visuals into **Enchant Visuals**, version **1.0.1**. It renamed C++ source, namespaces, diagnostic DLL, INI, trace log, build identifiers, installer output, and documentation, while keeping the explicit executable-specific boundary.

The old working build had a provider-specific diagnostic filename. The new release is a **rebuilt binary** with neutral naming. From a portfolio perspective this is a meaningful iteration: the project can be described by its aesthetic function, while it still refuses untested other WoW executables. **Provider-neutral wording did not make the code executable-neutral.**

The installer was also revised. The old script had some filename-based recognition; the new script recognizes two earlier owned binaries by their **actual SHA-256 hashes**, preserves unrelated loader entries and the player's existing `EnableHooks` value, backs up recognized DLL/INI/loader data, handles repeat installs, and refuses an existing current-name DLL with an unexpected hash. The new synthetic PowerShell test fixture covers upgrading, keeping unrelated mods, preserving disabled config, backup creation, uninstall and hash rejection.

This improvement addresses an important user-experience concern. Changing a binary's file name while a loader references it can leave multiple effects active, disabled settings reset or someone else's DLL touched. The hash-based approach aims to avoid confusing **ownership** of files with their names. The audit didn't execute the script; it interprets that purpose from implementation and tests.

The [v1.0.1 public release](https://github.com/babunidev/EnchantVisuals/releases/tag/v1.0.1) was published September 18 with a ZIP and SHA256SUMS text file. Its release notes say the x86 build, visual-pair tests, and installer upgrade/backup/removal/checksum fixtures passed. They also **explicitly state that the renamed rebuilt binary had not yet been validated in game**.

This difference is essential. It would be inaccurate to transfer the previous build's September 11 game-test outcome to the September 18 DLL merely because its visual algorithm is nominally the same. The project has test evidence for the previous binary and reported offline evidence for the rebuilt one, with a live validation gap for the latter.

## October 26 — attribution, licensing and first documentary structure

On October 26, the README author credit was updated to **Babuni.dev** (commit **`058a1c3a`**). A subsequent commit **`31c54d41`** changed the MIT License's copyright line to the same pseudonym without changing its basic terms. The other October commits added preliminary concept, roadmap, changelog, architecture, decisions, devlog and AGENTS documents, and made the history accessible from README.

The license picture is distinct from many small Vanilla addons. The original project code is explicitly **MIT-licensed**, but the repository also vendors **MinHook 1.3.4** with its own BSD-family license notice, plus disassembler components with their credited rightsholders. The screenshots contain World of Warcraft imagery and do not transform game art into a Babuni.dev- or AI-owned asset.

The October 27 documentation session read the actual C++ and PowerShell scripts, pure visual-pair test, client signature table, four screenshot references and the public release metadata. It expanded the documentation into a source-grounded explanation of how visual pairing works, exactly what the installer validates, what the older build was reported to have passed, and what remains unverified for v1.0.1.

**Human creator's direction:** the aesthetic goal of two coexisting enchant glows and the authority to accept/reject implementation/design changes. **AI contribution in this session:** historical and source analysis, risk characterization, technical explanatory writing, organization of the eleven project documents and Git documentation commit. The assistant did **not** develop or patch the actual C++ mod in this session and cannot claim authorship of every earlier code line from the available Git data.

**Verified now:** Git tree and relevant files, release metadata, saved LICENSE and MinHook notice, then documentation link/blob checks when committed. **Not performed:** compiling x86 C++, running the synthetic tests or installer, modifying any local game client, injecting/loading the DLL, comparing release asset bytes, capturing new screenshots, or observing the v1.0.1 renderer in-game.

## The next development chapter should be a controlled client test

The clearest next step is to repeat the actual September 11 visual scenarios using the **released 1.0.1 binary** on the exact supported client, with backups and logs: permanent enchant plus each Shaman imbue, switching imbues, sheathing and equipping different weapons. If a natural imbue expires, watch the extra effect disappear and the permanent glow remain.

It is worth documenting failures as well as successes, especially any login regression, conflicting DLL or unrecognized loader behavior. The portfolio's deeper subject is the gap between a tiny desired aesthetic and a constrained legacy engine: **one more glow**, achieved by careful pairing, client validation, release migration and respect for the difference between reported success and independently verified software.
