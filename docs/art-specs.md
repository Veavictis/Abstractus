# Art specs

Status, 2026-10-30. **Decided** by the creator:

- Base resolution: **960x540**, for the freedom to put as much or as little detail as
  wanted into level design.
- Levels: **seamless background chunks**, no tiles.
- All art, including existing art to import, is **pixel art**.
- Sprite scale: **48x48** for the player and standard enemies, so characters look
  bigger with room for detail. The other sizes below are scaled to match, as suggestions.
- Background chunks: **1024x1024**.

Anything marked "suggested" or "open" below is not decided yet; the creator picks.

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

## 3. Level canvas size (decided: 1024x1024 chunks)

- Each chunk is a **1024x1024** seamless painting that lines up edge to edge and can
  repeat in every direction.
- Level size (open): endless (chunks repeat), or a bounded area made of N x M chunks.
- Stage shape (open): endless in every direction, endless in one direction (corridor),
  or a closed arena with walls.
- Props (suggested): multiples of 24 (48x48, 48x96, 96x96).
- Aseprite tip: View > Tiled Mode shows the canvas repeated, to check seams.

## 4. Player sprite (decided: 48x48)

- Canvas: **48x48** per frame. Suggested: keep the figure about 36 to 42 px tall, with
  room around it for animation and outlines.
- Every frame of an animation is the same size. Suggested: one Aseprite file with tags
  (idle, walk, hurt, death), exported as a sprite sheet.

## 5. Enemies (decided standard: 48x48)

- Standard canvas: **48x48**, same as the player.
- Size tiers for later (suggested): small 24x24, standard 48x48, large 96x96,
  elite / boss 144x144 or 192x192.
- Big enemies can also be normal sprites scaled up in code, but scaled pixels look
  chunkier than art drawn at full size.

## 6. Enemy projectiles (base sizes, suggested)

- Small: **12x12** (pellets, sparks)
- Medium: **24x24** (orbs, shards)
- Large: **48x48** (big blasts)
- Tip: odd canvases (11x11, 23x23) give a true center pixel, so round shapes stay
  symmetric.

## 7. Player projectiles (base sizes, suggested)

- Base: **24x24** (bolts, knives, orbs)
- Large: 48x48
- Long or thin shots: 48x24 or 48x12, drawn facing right (the game rotates them)
- Areas / auras around the player: 96x96 to 192x192 (code can grow them on level up)
- Hit effects / sparks: 24x24 or 48x48 frames

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
