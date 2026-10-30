# Art specs

Status, 2026-10-30. **Decided** by the creator:

- Base resolution: **960x540**, for the freedom to put as much or as little detail as
  wanted into level design.
- Levels: **seamless background chunks**, no tiles.
- All art, including existing art to import, is **pixel art**.

Everything else below is still an option with a suggested default; the creator picks.

**Open: sprite sizes at 960x540.** The sizes in sections 4 to 7 were suggested for a
640x360 base. At 960x540 the same canvas looks two-thirds as big on screen. Either keep
them (smaller sprites, more zoomed-out view, more room for crowds) or scale them by 1.5x
(player and standard enemy 48x48, projectiles 12x12 / 24x24 / 48x48) to keep the same
on-screen size.

Tool: everything is drawn in Aseprite. Existing art will also be imported later.

## About the Vampire Survivors reference

Vampire Survivors does not publish its art specs. From how the game looks (not from an
official source): its characters and most enemies are small pixel sprites, roughly
16 to 32 px tall, shown scaled up on screen. Big enemies and bosses are several times
larger. Stages are large backgrounds built from repeating tiles plus scattered props,
and some stages scroll forever by repeating. The numbers below are chosen to give that
look in Godot, not copied from the game's files.

## 1. Base resolution (decided: 960x540)

Pixel art is drawn small and Godot scales the whole screen up by a whole number, so
pixels stay crisp. The base resolution is the size of the "virtual screen" you draw for.

Options that were considered: 640x360 (3x at 1080p) and 480x270 (4x at 1080p).

Set in `project.godot`: viewport 960x540, window opens at 1920x1080, stretch mode
`viewport`, aspect `expand`, integer scaling, texture filter `Nearest`, and pixel
snapping. At 1080p the game is scaled 2x, at 4K 4x. On Steam Deck (1280x800) integer
scaling stays at 1x and the view expands to show more of the world; switching to
fractional scaling there would fill the screen but make pixel sizes slightly uneven.

## 2. How levels are built from an art standpoint (decided: painted chunks)

- In Aseprite: paint large seamless background images that line up edge to edge.
  Props (rocks, shapes, landmarks) are drawn as separate sprites.
- In Godot: chunks are laid out, or repeated, as sprites behind gameplay; props are
  placed on top, with collision where needed.
- Tiles (Aseprite Tilemap mode + Godot `TileMapLayer`) were considered and declined.

## 3. Level canvas size

Levels are seamless painted chunks that line up edge to edge. Chunk canvas options
(open):

- 960x540: exactly one screen.
- 1024x1024: square, easy to repeat in every direction.
- 512x512: smaller files, repeats more visibly.

Level size (open): endless (chunks repeat), or a bounded area made of N x M chunks.

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

## Imported existing art (decided: all pixel art)

- It is shown with nearest filtering and, where it fits, integer scale so pixels stay
  crisp.
- Art for the gallery and the jigsaw mini game is shown as an image, not as a game
  sprite, so it can keep its own size. Questions to decide: a common max size or
  aspect ratio for gallery display.
- Existing art that becomes in-game sprites will need to fit the sizes above.

## Export conventions (suggested)

- Keep `.aseprite` files in `assets/art/source/`; export PNG sheets to
  `assets/art/sprites/`, `backgrounds/`, or `ui/`.
- One file per character or enemy, animations as tags, export with JSON data so Godot
  can read frame timings.
