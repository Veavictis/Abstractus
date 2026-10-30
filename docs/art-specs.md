# Art specs (proposal, pending the creator's choices)

Status: options only, 2026-10-30. Nothing here is decided. Each section lists options
with a suggested default; the creator picks.

Tool: everything is drawn in Aseprite. Existing art will also be imported later.

## About the Vampire Survivors reference

Vampire Survivors does not publish its art specs. From how the game looks (not from an
official source): its characters and most enemies are small pixel sprites, roughly
16 to 32 px tall, shown scaled up on screen. Big enemies and bosses are several times
larger. Stages are large backgrounds built from repeating tiles plus scattered props,
and some stages scroll forever by repeating. The numbers below are chosen to give that
look in Godot, not copied from the game's files.

## 1. Base resolution (decide this first; everything else follows)

Pixel art is drawn small and Godot scales the whole screen up by a whole number, so
pixels stay crisp. The base resolution is the size of the "virtual screen" you draw for.

| Option | Scale to 1080p | Scale to 1440p / 4K | Steam Deck (1280x800) | Look |
| --- | --- | --- | --- | --- |
| **A. 640x360** (suggested) | 3x | 4x / 6x | 2x, slight extra space top and bottom | Close to the Vampire Survivors feel: sprites read clearly, lots of screen for crowds |
| B. 480x270 | 4x | ~5.3x / 8x | ~2.7x | Chunkier, more zoomed in, fewer enemies visible |
| C. 960x540 | 2x | ~2.7x / 4x | ~1.3x | Finer pixels, more zoomed out, sprites look small |

Godot settings that come with this choice: viewport set to the base size, stretch mode
`viewport` (or `canvas_items`), integer scaling, and texture filter `Nearest`.

## 2. How levels are built from an art standpoint

| Option | How it works in Aseprite | How it works in Godot |
| --- | --- | --- |
| **A. Tileset + props** (suggested) | Draw a tileset in Aseprite's Tilemap mode (ground, paths, edges, variations). Draw props (trees, rocks, shapes) as separate sprites. | `TileMapLayer` paints the ground; props are placed as sprites with optional collision. A level can repeat forever by wrapping tiles. |
| B. Painted chunks | Paint large seamless background images, e.g. 640x360 or 1024x1024, that tile edge to edge. Props separate. | Chunks are laid out (or repeated) as sprites behind gameplay. |
| C. Mix | Tileset for ground, hand-painted set pieces for landmarks. | Both of the above. |

Tile size options: **32x32** (suggested, matches the player size) or 16x16 (more
detail control, more tiles to draw).

## 3. Level canvas size

With a tileset you don't draw a level canvas; you draw the tileset canvas and assemble
the level in Godot. Suggested starting points:

- Tileset canvas: 256x256 (an 8x8 grid of 32x32 tiles), grow as needed.
- Level size in Godot: either infinite (repeating) or a bounded area such as 120x120
  tiles (3840x3840 px), roughly 6x10 screens at 640x360. Size is a design choice.
- If you choose painted chunks: 512x512 seamless chunks (may suit abstract floors
  better than a tile grid), or 640x360 (exactly one screen).
- Props: multiples of 16 (32x32, 32x64, 64x64).
- Stage shapes to choose from: endless in every direction, endless in one direction
  (corridor), or a closed arena with walls.
- Aseprite tip: View > Tiled Mode shows the canvas repeated, to check seams.

## 4. Player sprite

- Canvas: **32x32** per frame (suggested). Keep the figure about 24 to 28 px tall with
  room around it for animation and outlines.
- Alternative: 48x48 if the player needs more detail.
- Animations go in one Aseprite file with tags (idle, walk, hurt, death) and export as
  a sprite sheet.

## 5. Enemies (standard size)

- Standard canvas: **32x32** (suggested), same as the player.
- Size tiers for later: small 16x16, standard 32x32, large 64x64, elite / boss 96x96
  or 128x128.
- Big enemies can also be normal sprites scaled up in code, but scaled pixels look
  chunkier than art drawn at full size.

## 6. Enemy projectiles (base sizes)

- Small: **8x8** (pellets, sparks)
- Medium: **16x16** (orbs, shards)
- Large: **32x32** (big blasts)
- Tip: odd canvases (7x7, 15x15) give a true center pixel, so round shapes stay
  symmetric.

## 7. Player projectiles (base sizes)

- Base: **16x16** (bolts, knives, orbs)
- Large: 32x32
- Long or thin shots: 32x16 or 32x8, drawn facing right (the game rotates them)
- Areas / auras around the player: 64x64 to 128x128 (code can grow them on level up)
- Hit effects / sparks: 16x16 or 32x32 frames

## Imported existing art

- Art for the gallery and the jigsaw mini game is shown as an image, not as a game
  sprite, so it can keep its own size. Questions to decide: a common max size or
  aspect ratio for gallery display, and whether pixel art is shown at integer scale.
- Existing art that becomes in-game sprites will need to fit the sizes above.

## Export conventions (suggested)

- Keep `.aseprite` files in `assets/art/source/`; export PNG sheets to
  `assets/art/sprites/`, `backgrounds/`, or `ui/`.
- One file per character or enemy, animations as tags, export with JSON data so Godot
  can read frame timings.
