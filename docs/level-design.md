# Level design

Levels are built from a text map, so a new layout is quick to sketch and playtest.

## Editing a level

Open `scenes/levels/level_01.tscn`, select the root node, and edit **Layout** in the Inspector.
One character per tile. Rows run top-left to bottom-right on screen (the grid is turned 45° into the isometric view).

| Char | Tile |
| --- | --- |
| `#` | Wall |
| `.` | Floor |
| `P` | Player start (exactly one) |
| `E` | Exit. Opens once every shard is collected. |
| `S` | Shard |
| `X` | Enemy. Drops a shard when defeated, so it counts toward the shard total. |
| `H` / `V` | Hazard that patrols its whole row (`H`) or column (`V`) until it meets a wall |
| `B` | Pushable crate |
| `O` | Pressure plate |
| `G` | Gate. Every gate opens once every plate has a crate on it. |

Keep every row the same length and surround the map with walls.
`tests/test_level_01.gd` checks that every shard, enemy, crate, plate and the exit can be reached;
copy it when adding a level.

## Adding level 2

1. Duplicate `level_01.tscn` as `level_02.tscn` and change **Level Name** and **Layout**.
2. Point the "play again" flow at it (for now `Game.FIRST_LEVEL` is the only level; a level list comes next).

## Every level mixes three things

Exploration (shards around the map), combat (enemies that hold shards), and puzzles (crates, plates, gates).
Level 1 keeps each one easy. Later levels raise the difficulty with more enemies, tighter hazard timing,
and puzzles with several crates and plates.

## Replacing placeholder art

Everything is drawn in code in each actor's `_draw()` function (`scenes/actors/*.gd`).
To use Aseprite art, add a `Sprite2D` or `AnimatedSprite2D` child to the actor's scene with the PNG from
`assets/art/sprites/`, place its feet on the node's origin (Y-sorting uses the origin), and delete the `_draw()` function.
