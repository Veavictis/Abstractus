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
| `E` | Exit. Open from the start. |
| `S` | Crystal. Optional; any left on the ground fly to the player at the end of the level. |
| `X` | Circle enemy (melee). Drops a crystal when defeated. |
| `Q` | Square enemy (shoots). Drops a crystal when defeated. |
| `H` / `V` | Hazard that patrols its whole row (`H`) or column (`V`) until it meets a wall |
| `B` | Pushable crate |
| `O` | Pressure plate |
| `G` | Gate. Every gate opens once every plate has a crate on it. |
| `-` | Safe floor. Enemies stop chasing while the player stands on it. |
| `W` | The weapon pickup (counts as safe floor) |
| `T` | Wall switch: a wall block with a target. Shoot every one before the level's **Switch Time** runs out. |
| `M` | Where the portal appears once every switch is flipped. It pours out **Portal Wave** enemies. |

Keep every row the same length and surround the map with walls.
`tests/test_level_01.gd` checks that every shard, enemy, crate, plate and the exit can be reached;
copy it when adding a level.

## Adding a level

1. Duplicate a level scene (e.g. `level_02.tscn` as `level_03.tscn`) and change **Level Name** and **Layout**.
   Tick **Start With Weapon** if the player should already have it.
2. Add its path to `Game.LEVELS` in `scripts/autoload/game.gd`. The level complete panel goes to the next one in the list.
3. Copy a test from `tests/` and add it to `.github/workflows/ci.yml`.

## Every level mixes three things

Exploration (shards around the map), combat (enemies that hold shards), and puzzles (crates, plates, gates).
Level 1 keeps each one easy. Later levels raise the difficulty with more enemies, tighter hazard timing,
and puzzles with several crates and plates.

## Replacing placeholder art

Everything is drawn in code in each actor's `_draw()` function (`scenes/actors/*.gd`).
To use Aseprite art, add a `Sprite2D` or `AnimatedSprite2D` child to the actor's scene with the PNG from
`assets/art/sprites/`, place its feet on the node's origin (Y-sorting uses the origin), and delete the `_draw()` function.
