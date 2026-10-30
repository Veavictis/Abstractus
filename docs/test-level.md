# Art test level

`scenes/levels/test_level.tscn` is a bare-bones level for trying art in motion. It is the
main scene for now, so **F5** in Godot runs it.

Everything you see is a **placeholder**: grey boxes and a grid background. No creative
choices are baked in. Speeds, health, fire rate and spawn rate are plain numbers on each
node in the Inspector, to tune or replace.

## Controls

- Move: WASD, arrow keys, or the left stick / D-pad on a gamepad
- Restart: R, or the Back / Select button
- The player fires automatically at the nearest enemy. At 0 HP the level restarts.

## Dropping in your art

Export from Aseprite to these exact paths. Godot picks the file up when you switch back to
the editor, and the game uses it instead of the placeholder. No code changes needed.

| What | File | Size per frame |
| --- | --- | --- |
| Player | `assets/art/sprites/player.png` | 48x48 |
| Enemy | `assets/art/sprites/enemy.png` | 48x48 |
| Player auto-attack shot | `assets/art/sprites/player_shot.png` | 24x24, drawn facing right |
| Background chunk | `assets/art/backgrounds/test_chunk.png` | 1024x1024, seamless |

- One frame: export the PNG as is.
- Animation: File > Export Sprite Sheet, Layout **Horizontal Strip**, no padding. A strip
  wider than one frame plays left to right at 8 frames per second (`fps` on the `Sprite`
  node).
- Sprites face right; the game flips the player and enemies when they move left.
- Keep your `.aseprite` files in `assets/art/source/`.

To use a different file name, select the `Sprite` node in `scenes/actors/player.tscn`
(or `enemy.tscn`, `player_shot.tscn`) and change **Art Path**. The background's path is on
the `Background` node in `test_level.tscn`.
