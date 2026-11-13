# Engine notes

## Godot 4 (tested)

Tested on Godot **4.7.2** (Compatibility renderer, macOS, Apple M4 Pro). The
demo is in `examples/godot/`. Run `./run_demo.sh` to build it, screenshot it
and compare it with a reference image.

- The demo uses NinePatchRect for the wood A–D windows and the stone and
  parchment panels, with `patch_margin_*` values read straight from
  `atlas.json` `nineSlice`. Axis stretch is set to Tile when
  `edges == "tile"`, otherwise Stretch.
- It uses TextureButton for buttons A and C in wood and stone, with all four
  textures. The demo forces disabled, toggled-pressed and mouse-hover states.
- Bars are a `bar_frame` NinePatchRect (margins 2) with a TextureProgressBar
  inside its `fillArea` (`nine_patch_stretch = true`, `texture_progress =
  bar_fill_*`).
- Text uses the BMFont `.fnt`, imported as a FontFile, with font size 9 and a
  colour override.
- Project settings: viewport 320x180, stretch mode `viewport`, default canvas
  texture filter **Nearest**.

Result: Godot's screenshot matches the Python reference render pixel for
pixel (**0 of 57,600 pixels differ**). The reference uses the same 9-slice
compositor and font renderer as the mockups. As a negative control,
`-- --perturb` shifts the left margins by 1px, which produces 815 differing
pixels. The comparison catches margin errors.

The demo cannot run under `--headless`: that mode uses Godot's dummy
renderer, which cannot read pixels back. `run_demo.sh` imports headlessly,
then renders unattended with OpenGL in an off-screen window.

## Unity (not tested)

1. Import the PNG and set Texture Type to Sprite (2D and UI), Filter Mode to
   Point, Compression to None and Mesh Type to Full Rect.
2. In the Sprite Editor, set Border L/T/R/B to the `nineSlice`
   left/top/right/bottom values. From script, note that `Sprite.border` is
   ordered (left, bottom, right, top).
3. On a UI Image, set Image Type to Sliced. For edges marked `tile`, use
   Tiled instead, so the plank seams and bricks repeat rather than stretch.
4. Pixels Per Unit has to match the Canvas Reference Pixels Per Unit. With a
   Pixel Perfect Camera, keep the scale an integer.
5. For BMFont, Unity has no built-in `.fnt` importer. Use a BMFont importer
   package, or rebuild the font as a TextMeshPro bitmap font from
   `hearthmark5x7.png` using the char rects in the `.fnt`.

## GameMaker (not tested)

1. Create a sprite from the PNG. Under Nine Slice, enable it and enter left,
   top, right and bottom from `nineSlice`. Set the edge and centre modes to
   Repeat for `tile` sprites, otherwise Stretch.
2. Turn off texture interpolation in Game Options (Graphics) to keep pixels
   sharp.
3. For the font, `font_add_sprite_ext` needs a sprite strip in character
   order. You can slice `hearthmark5x7.png` into one using the `.fnt` rects.
   The font is proportional, so pass `prop = true`.

## TrueType alternative (v1.1)

`font/hearthmark5x7.ttf` holds the same glyphs (ASCII + Latin-1) as pixel
outlines, 1 font pixel = 1/10 em. Any engine with TTF support can use it at
10, 20, 30 ... px with anti-aliasing and hinting off. Not tested in Unity,
GameMaker or Godot.
