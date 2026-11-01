---
name: pixelfx
description: Find, create, tune, and export pixel-art visual effects for ProjectVNG with the pixelfx library. Use for non-slash combat, spell, impact, projectile, environment, and UI VFX. Keep the existing slash and ice-shield implementations unchanged.
---

# Pixel VFX for ProjectVNG

Use the library at `assets/effects/pixelfx-main/pixelfx-main/`. Its upstream skill is at
`skills/pixelfx/SKILL.md`; use that for effect authoring details and consult `docs/CATALOG.md` and
`docs/AUTHORING.md` as needed.

## Scope and exception

- Use pixelfx for new or revised pixel-art VFX other than slash and the existing ice shield.
- Preserve the current slash implementation: `effects/slash.tscn`, `effects/slash.gd`, and every existing
  slash sheet in `assets/effects/Spritesheets/`. Do not replace, regenerate, rename, or remove those files.
- Preserve the current ice-shield scene and its cast ring through `BattleVFX.shield` and
  `BattleVFX.emberline_ring` in `scenes/player/battle_vfx.gd`.
- This skill covers effects, not character sprite animation. Follow `assets/sprites/ANIMATION_GUIDE.md` for
  character and other sprite animations.

## Workflow

1. Search `docs/CATALOG.md` and the library (`node tools/list.mjs <words>`) for a close existing effect.
2. Render and inspect candidates before choosing. From the library root, use
   `node tools/render.mjs <category>/<name> --gif` for a preview and `--sheet` for an engine asset.
3. Prefer a palette, seed, flip, angle, or documented option over duplicating an effect. For a new effect, read
   `docs/AUTHORING.md`, draft it with `node tools/new.mjs`, then render, inspect, refine, and run
   `node tools/check.mjs <category>/<name>`.
4. Use the exported PNG sheet in Godot; pixelfx source effects are JavaScript and are not directly runnable by
   the game. Keep pixel filtering set to nearest-neighbor and use the exported frame timing and pivot metadata.
5. Put project-specific exports in `assets/effects/pixelfx/`, keeping their category/name structure. Do not
   edit the upstream library's source just to create a project export. Retain the library license and attribution.

## Character timing

The library can export a stock character act for previews, but do not substitute its stock character for a
ProjectVNG character. Use effect timing metadata to coordinate the game's own animation, hit stop, and recovery.
