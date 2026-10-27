# EnchantVisuals — human–AI collaboration and technical provenance

**Project creator and final creative authority:** Babuni.dev.

## Creative attribution

The original design—the permanent weapon enchant glow coexisting with a Shaman's temporary imbue—and the decision to preserve the original game's visual vocabulary belong to Babuni.dev. The first September 11 publication already included the full core C++ implementation, screenshot examples and an installer.

Git does **not** establish a complete record of earlier human–AI conversations or who personally wrote each C++ line before the initial commit. An assistant involved in **October 27 documentation** cannot retroactively claim to have invented the effect, approved the risks or completed the first game client tests.

The project also has independent third-party provenance: MinHook 1.3.4 and its disassembler subcomponents have named upstream copyright holders and licenses. World of Warcraft imagery and effects belong to their respective game rightsholders.

## AI work documented during this October 27, 2026 audit

The assistant:
- Identified **EnchantVisuals** as repository **#23** in the Babuni.dev audit sequence, following #21 GroupBuffToggle and #22 TotemTimers.
- Read the live repository tree, README, current C++ renderer and visual-pair helpers, client signatures, Windows build file, installer, INI, tests, LICENSE, MinHook notices, and four screenshot file entries.
- Inspected the September 11 initial publication and September 18 provider-neutral rename/build changes, October credit/documentation commits, and **v1.0.0/v1.0.1 release metadata**.
- Documented that the **earlier build was reported tested in-game**, while the **newly rebuilt v1.0.1 DLL was not yet revalidated in-game** according to its own published release.
- Distinguished transient render-marker composition from persistent enchant/gameplay data, and explained installer executable/DLL SHA checks, five runtime signatures, config preservation and diagnostic logs.
- Expanded/revised 11 Markdown files to preserve concept, architecture, interface design, asset rights, decisions, verification roadmap and a readable development journal.

This is **source research, explanation, editorial work and documentation Git changes**, not original visual conception, gameplay testing, installer execution or repair of native runtime code.

## Guidelines for continuing development history

For every significant change preserve:
1. **User direction:** the actual artistic result desired and constraints.
2. **AI contribution:** what was suggested, generated, coded, documented or tested.
3. **Creative iteration:** alternatives, failures, source challenges, debugging steps and corrected assumptions.
4. **Creator decision:** explicit approval/rejection/deferral, not mere implication from a roadmap.
5. **Implementation:** exact C++/installer/assets/document paths, commits and release identifiers.
6. **Verification:** actual client executable, checksum, DLL binary, test commands, observed runtime behavior and unresolved limitations.

Protect player privacy and machine state. Redact process/thread IDs and pointers in publicly shared diagnostic logs. Don't disclose raw private chats, personal local paths or credentials. Keep the MIT and MinHook license distinctions visible in any published portfolio representation.

**This October 27 audit changes only documentation, not the executable or its build/configuration.**
