# Abstractus

A 2D isometric pixel-art game in Godot 4.7, headed for Steam (Windows and Steam Deck).

## Getting started

1. Install [Godot 4.7.2](https://godotengine.org/download) (standard build, not .NET).
2. Install [Git LFS](https://git-lfs.com) and run `git lfs install` once per machine.
3. Clone the repo and open `project.godot` in Godot.

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

See [docs/git-workflow.md](docs/git-workflow.md) for branching, commits, and releases, and
[docs/art-guidelines.md](docs/art-guidelines.md) for pixel scale, Aseprite, and audio formats.
