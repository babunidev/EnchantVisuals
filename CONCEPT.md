# EnchantVisuals — creative concept

**Original creator and creative director:** Babuni.dev  
**Current identity:** Enchant Visuals; originally Octo Enchant Visuals.  
**Platform scope:** Exact supported 32-bit World of Warcraft 1.12.1 (5875) executable, external DLL-loading launcher.

## The weapon should be allowed to tell two visual stories

Shaman weapon imbues and permanent weapon enchantments both carry recognizable graphic identities. In the supported client, the ordinary visual-selection path tends to present one selected effect, so the familiar glow from a permanent enchant can disappear when an imbue is active. Babuni.dev's design idea is simple: **let the permanent glow and the temporary Shaman effect coexist on the same weapon**.

The original README gives the concrete scene: a permanent **+4 weapon damage enchant** provides a blue glow, while the active Rockbiter, Flametongue, Windfury or Frostbrand effect remains visible around it. The combined image is expressive rather than functional. No combat power, spell uptime, enchant value, attack result, loot chance or server state is meant to change.

This is a visual restoration/extension of player identity, not a replacement for spell art. It uses the game's existing enchantment visuals, preserving the appearance people already recognize.

## A subtle client change rather than a new in-game menu

This is **not an Interface/AddOns Lua addon**. It is a narrowly targeted C++ DLL that runs within an existing supported 32-bit WoW client through an external launcher. It intercepts the client's selection and render paths so that, for a qualifying pair, the original renderer can display both effects.

A native intervention is a consequential design choice: it can reach a rendering decision that Vanilla's Lua API cannot change, but it also creates strong obligations around exact executable signatures, memory layout, install safeguards and in-game stability. The project is explicitly **not a generic mod for every WoW client**.

## Carefully bounded pairing

The code recognizes four temporary Shaman visual IDs and combines them only if an original selected visual matches a valid permanent visual. It intentionally leaves invalid/unsupported combinations, built-in higher-priority visual decisions, duplicate effects and ordinary non-Shaman temporary enchants alone. This safeguards the original game's visual hierarchy rather than replacing it wholesale.

The implementation uses a temporary internal marker for the interval between selection and rendering; the README and source specify that it **is not persisted** into game item data, DBC records or network packets. This is a rendering technique, not a new enchant data format.

## What is different about its development record

On **September 11, 2026**, the first committed version (Octo Enchant Visuals) included four illustrative screenshots and documentation reporting an in-game-verified earlier build. Its README also acknowledged previous login/loading failures of unknown cause. On **September 18**, the renamed 1.0.1 binary was rebuilt with neutral names and improved installer continuity. The release notes report offline tests passed but **did not claim the rebuilt DLL had passed a fresh game session**.

The creator deserves credit for the original aesthetic goal and its constraints; the assistant's October 27 historical explanation is **not evidence it originated the concept**. We have no original planning transcript for every technical alternative.

## Direction worth preserving

The portfolio should show the contrast between a tiny visual desire—a blue glow coexisting with a Shaman imbue—and the specialized technical work needed to produce it safely on a legacy game client. Do not turn the project into an unrelated texture overhaul, gameplay cheat, automatic combat system or unverified cross-client binary patch without explicit creator direction.
