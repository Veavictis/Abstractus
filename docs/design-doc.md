# Abstractus design doc

A 2D isometric pixel-art action puzzle game for Windows and Steam Deck (Godot 4.7, 640x360, 32x16 tiles).
Every level mixes three things: exploration (crystals around the map), combat (enemies), and puzzles.

## Creative direction

Abstractus is **AI assisted, not AI generated.** Every creative decision (mechanics, level layouts, numbers
that change the feel, art, story, names) is made by the game's creator. AI helps build, test and document
those decisions, and asks instead of deciding.

How to read this doc:

- **Decided:** the creator's call. Build it as written.
- **Suggestion:** an idea from AI that still needs the creator's OK. Don't build it until it's approved.
- **OPEN:** a question with no answer yet.

---

## How To Play

Three short tutorial levels that teach every system in the game. Each level adds new mechanics on top of the
last, and killing the boss at the end of level 3 finishes the How To Play section. Building these first lets us
lock down the style, the feel, and every game system before the real first level.

| | Level 1: Basics | Level 2: Ranged combat | Level 3: Shield and boss |
| --- | --- | --- | --- |
| New mechanics | Move, crystals, dodging hazards, melee, crate puzzle, exit | Enemies that shoot, the triangle weapon, timed wall switches | Shield, crate and switch puzzle, boss |
| Goal | Collect every crystal, reach the exit | **OPEN** | Beat the puzzle, then defeat the boss |
| Status | Playable (today's level 1) | To build | To build |

### Shared systems (used by all three levels)

These come from the current level 1 build.

- **Health:** 3 hearts. A hit gives 1 second of invulnerability (the player blinks) and a knockback.
  Losing all health sends you back to the level start; crystals you picked up stay collected.
- **Crystals:** the collectible. Enemies can carry crystals and drop them on death.
- **Exit portal:** stays locked until every crystal is collected, then opens.
- **Restart:** R / (Y) reloads the level, the safety net for a stuck puzzle.
- **Level complete panel:** time and deaths.

Suggestions, waiting for the creator's OK:

- On-screen hints the first time a mechanic appears ("Walk into the crate to push it"), showing the
  right button for keyboard or gamepad.
- "Continue" on the level complete panel goes to the next tutorial level.

---

### Level 1: Basics

**Teaches:** moving on the isometric grid, collecting crystals, dodging hazards, the crate-on-plate puzzle,
and melee combat.

This is the level 1 that's playable today (`scenes/levels/level_01.tscn`). It becomes tutorial level 1.

**Mechanics (built)**

1. **Navigation.** Move with WASD, arrows, left stick or D-pad. Diagonals run along the isometric grid.
2. **Crystals.** 4 crystals lie in the open; 2 more are carried by enemies (6 total).
3. **Dodging.** Red spinners patrol a row or column and hurt on touch.
4. **The puzzle box.** Push the crate onto the yellow plate by walking into it. The plate opens the gate to the last crystal and the exit.
5. **Enemies.** Purple melee enemies wander, chase when you're close, and hurt on contact. 3 melee hits
   (J / Space / (X)) defeat one, and it drops a crystal.

**To do:** rename shards to crystals in the code, HUD, and docs.

**Art asset list, level 1**

| Asset | Type | Size (px) | Frames / notes |
| --- | --- | --- | --- |
| Player idle | Character | ~32 tall | 4 directions (or 4 and mirror), 2 to 4 frames |
| Player walk | Character | ~32 tall | 4 directions, 4 to 6 frames |
| Player melee swing | Character + effect | ~32 tall | 4 directions, 3 to 4 frames, plus a swing arc effect |
| Player hurt | Character | ~32 tall | 1 to 2 frames (the blink is done in code) |
| Melee enemy idle / walk | Character | ~32 tall | 4 directions, 4 frames |
| Melee enemy hurt / death | Character | ~32 tall | 1 hurt frame, 4 to 6 death frames |
| Crystal | Pickup | ~12 to 16 | Shimmer or bob loop |
| Crystal pickup effect | Effect | ~16 to 24 | 4 to 6 frames |
| Red spinner hazard | Hazard | ~16 | Spin loop |
| Crate | Prop | 32x16 base | 1 frame |
| Pressure plate | Floor tile | 32x16 | 2 frames: up and pressed |
| Gate | Prop | 32x16 base | Closed and open |
| Exit portal | Prop | ~32 | Locked and unlocked |
| Floor tiles | Tileset | 32x16 | A few variations to break up repetition |
| Wall tiles | Tileset | 32x16 base | Straight, inner corner, outer corner, end pieces |
| HUD | UI | | Heart (full and empty), crystal icon, font |

Frame counts are starting points for planning; the creator sets the real ones.

---

### Level 2: Ranged combat

**Teaches:** enemies that shoot, the triangle weapon, and the timed wall switch puzzle.

**Decided**

1. **Enemies shoot.** Level 2 adds enemies that shoot at the player.
2. **The weapon.** A simple weapon made entirely of triangles that shoots triangles. Name TBD.
   The creator is drawing the art.
3. **Shoot back.** Once the player finds the weapon, they can shoot enemies.
4. **Puzzle: timed wall switches.** There is one shooting switch on each of the 4 walls. The player has
   15 seconds to shoot all 4. If time runs out first, all 4 reset.

**OPEN**

- Weapon: fire rate, ammo or unlimited, how aiming works (where you face, or right stick), and which button fires.
- Where the weapon is found, and what the player does before they have it.
- Switch timer: does the 15 seconds start on the first switch hit, and does the HUD show a countdown?
- What the 4 switches unlock (a gate, the exit, a crystal).
- The shooting enemy: how it moves, how fast its bullets are, how many hits it takes, and whether it drops a crystal.
- Do walls and crates block bullets?
- Level goal: still "collect every crystal, reach the exit"?

**Art asset list, level 2**

| Asset | Type | Notes |
| --- | --- | --- |
| Triangle weapon | Pickup + held | Creator is drawing it. A pickup version and a held version |
| Triangle projectile | Effect | Plus an impact effect |
| Player shoot | Character | 4 directions, plus muzzle flash if wanted |
| Shooting enemy idle / walk / shoot | Character | ~32 tall, 4 directions |
| Shooting enemy hurt / death | Character | |
| Enemy projectile | Effect | Plus an impact effect |
| Wall switch | Prop | 3 states: off, hit (timer running), reset |
| HUD | UI | Weapon icon, switch timer *(if shown)* |

---

### Level 3: Shield and boss

**Teaches:** the shield, the crate and switch puzzle, and the boss fight.

**Decided**

1. **Shield.** The first and only power-up in level 3. It surrounds the player and blocks all damage for
   3 seconds. The player can move while it's up. 30 second cooldown.
2. **Puzzle: crates and switches, all 4 walls, 45 seconds.**
   1. Push a crate (onto its plate) by one wall.
   2. A switch appears on the opposite wall.
   3. Move over there and shoot it.
   4. Move another crate, shoot the next switch on the opposite side. Repeat for all 4 walls.
   - All of it within 45 seconds.
   - **Fail:** the crates and switches reset.
   - **Succeed:** the boss spawns.
3. **Boss.** A jumble of abstract shapes, drawn by the creator.
   - 5x bigger than the player sprite.
   - Shoots bullets in all directions, in a couple of different patterns.
   - An area attack that fills the whole level every 40 seconds. The only way through is the shield.
   - Takes 300 bullet hits to kill.
4. **The end.** Killing the boss ends the How To Play section.

**OPEN**

- **Kill gauge:** the first outline had "kill enemies until a gauge fills, then the boss spawns". With the
  puzzle now spawning the boss, is the gauge still in, and if so where does it go?
- Puzzle: are there regular enemies during the puzzle, and does the 45 seconds show on the HUD?
- Puzzle: does a crate need to go onto a plate, or does moving it anywhere count?
- Shield: which button, and how the player gets it (a pickup, a shrine, given at the start of level 3).
- Shield vs. the boss's area attack: the shield cooldown (30 s) is shorter than the area attack timer (40 s),
  so the shield is always ready if the player saves it. Is that the intent?
- Boss: which bullet patterns, whether it moves, whether there is a warning before the area attack,
  and whether it has phases.
- Boss: does melee hurt it, or only bullets? The weapon's fire rate decides how long the fight lasts:
  at 5 shots a second, 300 hits is a full minute of hitting it.
- Boss size: 5x the player is about 140 to 160 px tall, close to half the 360 px screen. The art guidelines
  say 48 px for big characters, so the guidelines need updating to match. Does the camera stay the same
  in the boss fight, or zoom out?
- What happens after the boss: a "tutorial complete" screen, straight into the main game, or back to the title?
- Do the weapon and shield carry over into the main game?

**Art asset list, level 3**

| Asset | Type | Notes |
| --- | --- | --- |
| Shield | Effect | Surrounds the player, 3 second loop, plus pop-up and fade-out |
| Shield pickup / source | Prop | Depends on how the player gets it |
| HUD shield icon | UI | With a 30 second cooldown display |
| Wall switch (appearing) | Prop | Appear animation, on top of the level 2 switch states |
| Crates and plates | Prop | Reuse level 1, or new versions |
| Puzzle timer | UI | 45 second countdown *(if shown)* |
| Boss idle / move | Character | Abstract shapes, 5x the player sprite |
| Boss bullet patterns | Effect | Boss bullets, one look or one per pattern |
| Boss area attack | Effect | Fills the whole level, plus a warning if there is one |
| Boss hurt / death | Character | Hurt flash, death animation |
| Boss health bar | UI | 300 hits |

---

### Suggested art order (suggestion)

1. Floor and wall tiles, the player idle and walk. These set the style for everything else.
2. Crystal, red spinner, crate, plate, gate, exit portal.
3. Melee enemy, melee swing, HUD hearts and crystal icon. Level 1 is then fully drawn.
4. The triangle weapon and its projectile, then the rest of level 2, then level 3, then the boss.

Each piece can replace the placeholder shapes in the game one at a time (see `docs/level-design.md`,
"Replacing placeholder art").
