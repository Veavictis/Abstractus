# Abstractus

A 2D isometric pixel-art game in Godot 4.7, headed for Steam (Windows and Steam Deck).

## Getting started

1. Install [Godot 4.7.2](https://godotengine.org/download) (standard build, not .NET).
2. Install [Git LFS](https://git-lfs.com) and run `git lfs install` once per machine.
3. Clone the repo and open `project.godot` in Godot.

## Play it

1. Open `project.godot` in Godot 4.7.2 and press **F5** (or the Play button, top right).
   The title screen opens; press Enter or (A) to start level 1.
2. Or run it from a terminal without opening the editor: `godot --path .`

| Action | Keyboard | Gamepad / Steam Deck |
| --- | --- | --- |
| Move | WASD or arrow keys | Left stick or D-pad |
| Melee | J or Space | X |
| Aim | Mouse (the crosshair) | Right stick |
| Shoot (after finding the weapon) | Left click (hold for 2 shots a second) | Right trigger (RT / R2) |
| Push a crate | Walk into it | Walk into it |
| Restart level | R | Y |
| Back to title / quit | Esc | B or Start |

**Level 1:** reach the exit. The first half has 3 purple circle enemies and 4 red spinners to get past.
Halfway through, a green safe room holds the triangle weapon; enemies won't chase you there. The second half has
6 more enemies and the crate puzzle: push the crate onto the yellow plate to open the gate to the exit.

**Level 2:** you start with the weapon. Orange square enemies shoot back. Shoot the target on each of the 4 walls
within 15 seconds of the first one, or they all reset. Then a portal opens in the middle and 15 circles pour out;
defeat them all and step into the portal.

Crystals are optional: every enemy drops one, and any left on the ground fly to you when you finish a level.
Losing all 3 health sends you back to the start. Got stuck? Press R.

Run the automated playthroughs: `godot --headless res://tests/test_level_01.tscn` and `test_level_02.tscn` (CI runs both).

## Layout

| Folder | What goes there |
| --- | --- |
| `assets/art/` | Exported, game-ready art: `sprites/`, `backgrounds/`, `ui/`, `textures/` |
| `assets/art/source/` | Working files (PSD, KRA, Aseprite, Blend). Excluded from exports. |
| `assets/audio/` | `music/` and `sfx/` |
| `assets/fonts/`, `assets/shaders/` | Fonts and `.gdshader` files |
| `scenes/` | `.tscn` scenes, each next to its own script: `main/`, `levels/`, `ui/`, `actors/` |
| `scripts/autoload/` | Global singletons (`Game`) |
| `scripts/components/` | Reusable scripts not tied to one scene |
| `resources/` | `.tres` data resources (themes, configs, item data) |
| `addons/` | Third-party Godot plugins (e.g. GodotSteam later) |
| `tests/` | Automated tests |
| `docs/` | Design and process notes |

Naming: `snake_case` for files and folders, `PascalCase` for node names and `class_name`.

See [docs/design-doc.md](docs/design-doc.md) for the game design and the How To Play tutorial plan,
[docs/level-design.md](docs/level-design.md) for how to build and edit levels,
[docs/git-workflow.md](docs/git-workflow.md) for branching, commits, and releases, and
[docs/art-guidelines.md](docs/art-guidelines.md) for pixel scale, Aseprite, and audio formats.
