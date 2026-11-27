FREE PIXEL FARM CROPS
=====================

24 farm crops in 16x16 pixel art, each with 5 growth stages (seed, sprout,
growing, mature, harvest), a gentle 4-frame sway for the mature and harvest
stages, a seed bag icon and a harvest icon (16x16 and 32x32), tilled soil
with a 47-tile autotile in dry and wet versions, and 12 farm tool icons.
Free for personal and commercial games. Made by Willosuna.

  >> PLEASE RATE IT: a quick rating on the itch.io page is the best way to
     support this pack and it keeps the free packs coming:
     https://willosuna.itch.io/free-pixel-farm-crops

WANT MORE?
  Cozy Farm Pixel Pack - 24 more crops, fruit trees, animals, buildings,
  fences and terrains in the SAME palette and outline style:
    https://willosuna.itch.io/cozy-farm-pixel-pack
  Cozy Farm Music Pack - relaxing loops for your farm game:
    https://willosuna.itch.io/cozy-farm-music-pack
  Willosuna Cozy Bundle - every cozy pack together:
    https://willosuna.itch.io/willosuna-cozy-bundle
  Willosuna All-in-One - every Willosuna pack in one download:
    https://willosuna.itch.io/willosuna-all-in-one
  Bonus file on the same page (pay $1.99 or more): 12 extra autumn and
  winter crops and 6 small barnyard animals walking in 4 directions.

THE CROPS (24)
  rice, cucumber, zucchini, broccoli, spinach, celery, asparagus,
  sweet_potato, green_bean, okra, soybean, ginger, pineapple, grape,
  raspberry, cotton, coffee, tea, lavender, tulip, hops, artichoke, bok_choy,
  rhubarb

THE TOOLS (12)
  hoe, watering_can, axe, pickaxe, shovel, sickle, pitchfork, rake, trowel,
  pruning_shears, harvest_basket, wheelbarrow

WHAT'S INSIDE
  crops/<x1|x2|x4>/<crop>/<crop>_stage<0-4>_<name>.png   120 stage sprites
  crops_sway/<x1|x2|x4>/<crop>/   mature and harvest sway, 4 frames each,
                    single frames and a strip (48 animations, 250 ms per
                    frame, loop 0-1-2-3: rest, right, rest, left)
  icons/<16px|32px>/<x1|x2|x4>/seeds|products|tools/   60 icons per size
  soil/<x1|x2|x4>/dry|wet/   47 autotile pieces + 3 plain fills each,
                    transparent outside, so the beds sit on ANY ground
  soil/<x1|x2|x4>/grass/   4 grass fill tiles
  sheets/x1|x2|x4/  crops_stages (5 columns), crops_sway (8 columns),
                    icons_16px and icons_32px (12 columns), soil (8 columns)
                    + a .json per sheet (TexturePacker hash format)
  atlas.json        every crop row, stage rectangle, icon row and soil mask
  godot/            TileSet, CropField growth script and a demo scene
  tiled/soil.tsx    Tiled tileset with the soil autotile as a Wang set
  palette/          the closed farm palette (60 colors) as PNG, HEX, GPL
  preview.png       everything at a glance

SOIL AUTOTILE
  The 47 pieces cover every combination of neighbours (blob layout). The
  wet version uses exactly the same layout 7 rows lower on the soil
  sheet, so watering a cell is one change of atlas coordinates. Mask bits
  are listed in atlas.json: N=1 NE=2 E=4 SE=8 S=16 SW=32 W=64 NW=128.

GODOT 4 (tested in Godot 4.3)
  1. Copy the folder "free_pixel_farm_crops" to res://free_pixel_farm_crops/
  2. Open godot/farm_demo.tscn and press F6: a farm grows, gets watered
     and harvested by itself.
  3. In your game: two TileMapLayers (soil and plants) using
     godot/farm_crops_tileset.tres, plus a CropField node:
       field.till(cells)            paints soil with the autotile
       field.water(cell)            swaps the cell to wet soil
       field.plant(cell, "tulip")   puts the seed stage on the plants layer
       field.harvest(cell)          returns the crop name when it is ready
     A watered crop grows one stage every seconds_per_stage and the soil
     dries again (needs_water and dry_after_growth can be turned off).
     Mature and harvest stages use animated tiles, so they sway on their
     own. In the TileSet editor the soil is the terrain "Soil".
  Sprites: godot/crop_sway_frames.tres has every sway as SpriteFrames.

OTHER ENGINES
  Unity: import a sheet, Sprite Mode Multiple, Filter Point, Compression
  None, slice by cell size 16x16 (x1). GameMaker, RPG Maker, Phaser and
  others: use the single PNGs or the sheets with their .json.
  Keep integer scales (x2, x3, x4) for crisp pixels.

PAIRS WITH COZY FARM PIXEL PACK
  Same tile size, same closed palette and the same dark colored outline,
  so these crops, soil and tools sit next to Cozy Farm art without looking
  out of place. Together they give you 48 different crops.

LICENSE
  Personal and commercial use, royalty free, no attribution required.
  Do not resell or redistribute the files as an asset pack. See LICENSE.txt.
