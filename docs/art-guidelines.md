# Art and audio guidelines

## Targets

- **Platforms:** Windows and Steam Deck. The Linux export is the native Steam Deck build.
- **Renderer:** Compatibility (OpenGL). Plenty for a 2D pixel game, and the lightest option on the Deck's battery.

## Pixel scale

- **Base resolution: 640x360.** The game renders at this size and scales up by whole numbers only, so pixels stay crisp:
  - 1280x720 / Steam Deck (1280x800): 2x. The Deck's taller screen shows 640x400, with no black bars.
  - 1920x1080: 3x. 2560x1440: 4x. 4K: 6x.
- **Isometric tiles: 32x16** (2:1 diamond). That's 20 tiles across the screen, with room for gradients.
- **Characters: about 32 px tall** for standard figures. Go to 48 px only for large or boss characters.
- **Texture filtering is set to Nearest** project-wide, and 2D transforms snap to whole pixels.

## Gradients

Smooth gradients in pixel art come from wide hand-picked color ramps (8 to 12 steps), not from blurred filters.
Keep a shared palette in `assets/art/source/palette.aseprite` so every asset uses the same ramps.

## Aseprite workflow

1. Save working files as `.aseprite` in `assets/art/source/`. They're tracked by Git LFS and left out of game builds.
2. Export game-ready **PNG** sprite sheets into `assets/art/sprites/`, `backgrounds/`, `ui/` or `textures/`.
3. Name files in `snake_case`, e.g. `player_walk.png`.

## Audio

- **Music:** OGG Vorbis. It loops seamlessly and is smaller than MP3 at the same quality.
- **Sound effects:** WAV. Zero decode cost and instant playback.
- **MP3 also works** in Godot 4, so existing MP3s are fine to drop in. For new music, export to OGG when you can.
