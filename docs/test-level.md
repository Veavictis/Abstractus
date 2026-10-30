# Art test level

`scenes/levels/test_level.tscn` is a bare-bones level for trying art in motion. It is the
main scene for now, so **F5** in Godot runs it.

Everything you see is a **placeholder**: grey boxes and a grid background. No creative
choices are baked in. Speeds, health, fire rate and spawn rate are plain numbers on each
node in the Inspector, to tune or replace.

## Controls

- Move: WASD, arrow keys, or the left stick / D-pad on a gamepad
- Restart: R, or the Back / Select button
- Aim: the player fires automatically toward the mouse cursor. At 0 HP the level restarts.

## Dropping in your art

Export from Aseprite to these exact paths. Godot picks the file up when you switch back to
the editor, and the game uses it instead of the placeholder. No code changes needed.

| What | File | Size per frame |
| --- | --- | --- |
| Player | `assets/art/sprites/player.png` | 48x48 |
| Enemy | `assets/art/sprites/enemy.png` | 48x48 |
| Player auto-attack shot | `assets/art/sprites/player_shot.png` | 24x24, drawn facing right (one image; the game rotates it to any direction) |
| Background chunk | `assets/art/backgrounds/test_chunk.png` | 1024x1024, seamless |

- One frame: export the PNG as is.
- Animation: File > Export Sprite Sheet, Layout **Horizontal Strip**, no padding. A strip
  wider than one frame plays left to right at 8 frames per second (`fps` on the `Sprite`
  node).
- Sprites face right; the game flips the player and enemies when they move left.
- Keep your `.aseprite` files in `assets/art/source/`.

To use a different file name, select the `Sprite` node in `scenes/actors/player.tscn`
(or `enemy.tscn`, `player_shot.tscn`) and change **Art Path**. The background's path is on
the root node of `scenes/levels/background_chunk.tscn`.

## Background obstacles (hitboxes)

The background is one painting. Obstacles are hitboxes (CollisionPolygon2D nodes) under
`Obstacles` in `scenes/levels/background_chunk.tscn`. That scene repeats in every
direction, so each hitbox repeats with the painting, once every 1024 px.

**Automatic (black floor, outlined shapes):** every shape you can't reach from the
painting's edges over black floor becomes a hitbox, inside included (so the donut's hole
is solid). Shapes that touch or overlap become one hitbox. After changing the painting,
close the scene in Godot and run this from the project folder:

    "C:\Users\User\Downloads\Godot_v4.7.2-stable_win64.exe\Godot_v4.7.2-stable_win64_console.exe" --headless --path . -s res://scripts/tools/bake_obstacles.gd

It replaces every hitbox in `Obstacles`, so hand edits there are lost on the next bake.

**By hand:** open `background_chunk.tscn`, right-click `Obstacles` > Add Child Node >
**CollisionPolygon2D**, and click around an obstacle in the painting to place points.
Click the first point again to close the shape. Select a baked hitbox to move its points.

Tip: Debug > Visible Collision Shapes shows the hitboxes while the game runs.
Everything not traced is walkable. The player and enemies slide along obstacles, and
shots disappear when they hit one. Enemies never spawn inside an obstacle. Enemies walk
straight at the player, so one can get stuck behind a wide obstacle (no pathfinding yet).
