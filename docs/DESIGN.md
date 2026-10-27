# EnchantVisuals — visual and experiential design

**Creator and creative director:** Babuni.dev.  
**Evidence:** original/readme illustration, four committed screenshots and selection logic. No new screenshots or code generated during this audit.

## Two enchant aesthetics rather than a winner

In the supported Vanilla-era client, two simultaneous enchantments can exist as gameplay state but the weapon may visually emphasize one. The creator's goal is for the **permanent enchant glow** and **Shaman imbue artwork** to coexist, making the weapon appear to carry both identities.

The motivating example is a **blue permanent +4 weapon-damage enchant glow** alongside an elemental Shaman treatment. That is visual storytelling through combat equipment rather than an interface overlay. It enriches the appearance of an already-owned weapon without inventing new visual art or changing damage values.

The design has four recognizable variations preserved in the repository:

| Rockbiter | Flametongue |
| --- | --- |
| ![Rockbiter and permanent blue glow](../docs/screenshots/rockbiter.png) | ![Flametongue and permanent blue glow](../docs/screenshots/flametongue.png) |
| Windfury | Frostbrand |
| ![Windfury and permanent blue glow](../docs/screenshots/windfury.png) | ![Frostbrand and permanent blue glow](../docs/screenshots/frostbrand.png) |

These screenshots document **the earlier September 11 build**, not a separately confirmed visual run of the renamed **v1.0.1 binary**.

## No replacement assets

The extension doesn't include new enchant particle textures, hand-painted spell effects, shaders, icons, character art or a UI menu. It uses **the client's own rendering path**, allowing the renderer to apply the permanent effect and then append the Shaman effect. This is additive composition, not a new asset pack.

Weapons whose original selected visual has priority are left unchanged. That restraint maintains familiar behavior where the game treats a built-in enchant/weapon visual as more important than the potential pair.

## Aesthetic result versus engineering surface

The output in screenshots looks nearly effortless: both enchant colors/material effects appear together. But the underlying implementation is high-risk compared with drawing a Lua window. It uses a native 32-bit DLL, protected runtime signatures, MinHook detours and a jump into a particular renderer sequence after it has cleared its existing effect children.

The creator's aesthetic objective remains narrow despite the complicated internals. Documentation should neither hide the technical ingenuity nor imply the modification runs safely on every 1.12 game binary.

## Existing interaction and control

There is no in-game configuration panel. The control is an external **INI flag `EnableHooks=0/1`** requiring full process restart. An existing DLL-loading launcher reads a `dlls.txt` entry. The player needn't install a separate Lua addon or change their spell-casting behavior.

This makes the modification visually invisible until a qualifying weapon is equipped. It can affect all matching character models rendered on the local user's screen, not only their own Shaman, because the hook works at the client renderer.

## Usability and aesthetic questions for real tests

- Do both effects remain clear rather than overbright in dark/light zones?
- How does the combination look from different cameras, weapon classes and while mounted?
- Does effect replacement or expiration clean up properly?
- How does it look after weapon switching or sheathing?
- Does the local player want the mod to affect other visible Shamans too?
- Are diagnostic logging and external INI activation sufficiently discoverable?

The source cannot answer these visually. The prior screenshots and reported earlier tests are helpful reference evidence; **v1.0.1 still requires actual in-game verification** before that experience is claimed for the release.
