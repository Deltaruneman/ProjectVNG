# Elemental orbs

Regenerate from project root with `node tools/export_elemental_orbs.mjs`.
Each orb is the bundled pixelfx `projectiles/plasma-shot` at size 8, seed 3,
with its exported `palette.json`: white/neutral, orange/fire, cyan/ice, yellow/lightning.
24 frames, 144 x 60 pixels, 30 fps loop, pivot [108, 30]. Nearest filtering.
The Player projectile owns flight and lifetime; the sheet animates the head, corona and trail only.

Keep the bundled pixelfx MIT LICENSE and original attribution:
Sprite Fusion energy bolt and orb, MIT License, Copyright (c) 2026 Hugo Duprez.
https://www.spritefusion.com/pixel-art-vfx/energy
