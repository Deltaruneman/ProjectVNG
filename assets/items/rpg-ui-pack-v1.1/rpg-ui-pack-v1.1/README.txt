Hearthmark: Pixel RPG UI + Icon Pack v1.1
=========================================

Everything is 1 art pixel = 1 image pixel. Scale by whole numbers with
nearest-neighbour filtering. Turn mipmaps off.

ui/          individual UI PNGs by group
icons/A/     96 item icons, 16x16, primary style (1px outline, 3-step)
icons/C/     the same 96 icons, alternate style (heavy outline, 4-step)
sheets/      ui.png (1px gaps), icons-A.png and icons-C.png (8 per row, no gaps)
font/        hearthmark5x7.png + .fnt (BMFont text format), hearthmark5x7.ttf
             (TrueType pixel outlines) and a specimen PNG
mockups/     inventory (style A), inventory-alt (icons C, buttons C, wood B)
             and dialogue screens at 1x (320x180) and 3x
previews/    4x GIF previews of animations and button states
atlas.json   rects, 9-slice borders, hotspots, animation timings, palette

9-slice: atlas.json "nineSlice" gives left/top/right/bottom borders in
pixels. "edges": "tile" repeats the edge and centre segments. "stretch"
means the segments are uniform, so stretch or tile gives the same result.
Window sprites have a 10px title bar inside the top border. Wood ships in four
variants (panel_wood_a..d, window_wood_a..d); variant C has 6px borders.
Buttons ship as button_a_* (bevel) and button_c_* (rounded pill).
Tested in Godot 4.7 (NinePatchRect, TextureButton, TextureProgressBar, BMFont).

Font: cap height 7, x-height 5, 2-row descenders, lineHeight 10, base 7.
191 glyphs: printable ASCII (U+0020-007E) and Latin-1 (U+00A0-00FF).
Accented capitals reach 2 px above the cap line (BMFont yoffset -2).
The glyphs are white, so tint them in your engine.
TTF: use font sizes of 10, 20, 30 ... px (10 px = 1 font pixel per screen
pixel) with anti-aliasing and hinting off, for crisp pixels.

Cursors: use the "hotspot" field in atlas.json. Animated cursor_wait and
dialogue_next frames list their per-frame durations in ms under
"animations".

Licence: CC0 1.0 Universal (public domain; see LICENSE.txt).
