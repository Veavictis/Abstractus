# Abstractus design doc

A 2D isometric pixel-art action puzzle game for Windows and Steam Deck (Godot 4.7, 640x360, 32x16 tiles).
Every level mixes three things: exploration (crystals around the map), combat (enemies), and puzzles.

Items marked **OPEN** are design choices that still need a decision. Items marked *(proposal)* are a
suggested starting point, easy to change.

---

## How To Play

Three short tutorial levels that teach every system in the game, one step at a time. Each level adds new
mechanics on top of the last, and killing the boss at the end of level 3 finishes the How To Play section.
Building these first lets us lock down the style, the feel, and every game system before the real first level.

Each level teaches with the same pattern: **show it safely, then test it once, then combine it.**
A new mechanic first appears where it can't hurt you, then in a simple challenge, then mixed with
what you already know.

| | Level 1: Basics | Level 2: Ranged combat | Level 3: Abilities and boss |
| --- | --- | --- | --- |
| New mechanics | Move, crystals, dodging hazards, melee, crate puzzle, exit | Enemies that shoot, finding a weapon, shooting back, second puzzle type | Abilities, third puzzle type, kill gauge, boss |
| Goal | Collect every crystal, reach the exit | Collect every crystal, reach the exit | Fill the gauge, defeat the boss |
| Status | Playable (today's level 1) | To build | To build |

### Shared systems (used by all three levels)

- **Health:** 3 hearts. A hit gives 1 second of invulnerability (the player blinks) and a knockback.
  Losing all health sends you back to the level start; crystals you picked up stay collected.
- **Crystals:** the collectible. The HUD shows `Crystals n / total`. Enemies can carry crystals and drop them on death.
- **Exit portal:** stays locked until every crystal is collected, then opens.
- **Restart:** R / (Y) reloads the level, the safety net for a stuck puzzle.
- **On-screen hints:** short one-line prompts the first time a mechanic appears ("Walk into the crate to push it").
  They show the right button for keyboard or gamepad. *(proposal)*
- **Level complete panel:** time and deaths, then continue to the next tutorial level.

---

### Level 1: Basics

**Teaches:** moving on the isometric grid, collecting crystals, dodging hazards, the crate-on-plate puzzle,
and melee combat.

This is the level 1 that's playable today (`scenes/levels/level_01.tscn`). It becomes tutorial level 1.

**Mechanics**

1. **Navigation.** Move with WASD, arrows, left stick or D-pad. Diagonals run along the isometric grid.
   The start room is safe, with walls to bump into and a corridor to follow.
2. **Crystals.** 4 crystals lie in the open; 2 more are carried by enemies (6 total).
3. **Dodging.** Red spinners patrol a row or column and hurt on touch. You learn to watch the pattern and time your crossing.
4. **The puzzle box.** Push the crate onto the yellow plate by walking into it. The plate opens the gate to the last crystal and the exit.
5. **Enemies.** Purple melee enemies wander, chase when you're close, and hurt on contact. 3 hits with the
   melee swing (J / Space / (X)) defeats one, and it drops a crystal.

**Tutorial changes still to make**

- Rename shards to crystals in the code, HUD, and docs.
- Add the first-time hint prompts (move, push, attack).
- Make "continue" on the complete panel go to level 2 instead of replaying.

**Art asset list, level 1**

| Asset | Type | Size (px) | Frames / notes |
| --- | --- | --- | --- |
| Player idle | Character | ~32 tall | 4 directions (or 4 and mirror), 2 to 4 frames |
| Player walk | Character | ~32 tall | 4 directions, 4 to 6 frames |
| Player melee swing | Character + effect | ~32 tall | 4 directions, 3 to 4 frames, plus a swing arc effect |
| Player hurt | Character | ~32 tall | 1 to 2 frames (the blink is done in code) |
| Melee enemy idle / walk | Character | ~32 tall | 4 directions, 4 frames |
| Melee enemy hurt / death | Character | ~32 tall | 1 hurt frame, 4 to 6 death frames |
| Crystal | Pickup | ~12 to 16 | 4 to 8 frame shimmer or bob |
| Crystal pickup effect | Effect | ~16 to 24 | 4 to 6 frames |
| Red spinner hazard | Hazard | ~16 | 4 to 8 frame spin |
| Crate | Prop | 32x16 base | 1 frame (optional: a push-squash frame) |
| Pressure plate | Floor tile | 32x16 | 2 frames: up and pressed |
| Gate | Prop | 32x16 base | Closed and open, optional 3 to 4 frame open animation |
| Exit portal | Prop | ~32 | Locked (idle) and unlocked (4 to 8 frame loop) |
| Floor tiles | Tileset | 32x16 | 2 to 4 variations to break up repetition |
| Wall tiles | Tileset | 32x16 base | Straight, inner corner, outer corner, end pieces |
| HUD | UI | | Heart (full and empty), crystal icon, font |
| Hint prompt | UI | | Small panel, button icons for keyboard and gamepad |

---

### Level 2: Ranged combat

**Teaches:** enemies that shoot, finding and using a weapon, and the second puzzle type.

**Mechanics**

1. **Enemies shoot.** A new ranged enemy keeps its distance and fires slow, readable projectiles that travel in a straight line.
   The first one sits behind a low wall or across a gap, so you meet its bullets before you can reach it.
   Projectiles stop at walls, and crates block them too, so cover matters. *(proposal)*
2. **Find the weapon.** Partway through, a pickup on a pedestal gives you a ranged weapon. Before that, the level
   is about dodging bullets and using cover. After it, you shoot back.
   - **OPEN: weapon type.** Options: a straight-shot blaster (simplest), a slow charged shot, a short-range spread,
     or a thrown weapon that comes back. Also open: ammo or no ammo, and whether it aims where you face or with the right stick.
3. **Shoot back.** Aim and fire (button **OPEN**, suggestion: K / (RB) or right stick + trigger). Melee still works,
   so you can choose: the ranged enemy is weak up close, the melee enemy is safer to shoot from far away.
4. **Second puzzle.** **OPEN: which puzzle.** It should use the new weapon so the level teaches one idea.
   Some options:
   - **Shoot a switch:** crystal targets on the walls that open a gate when hit, some only reachable at range.
   - **Timed switches:** shoot two or three targets within a few seconds of each other.
   - **Redirect:** shoot a reflector so the shot bounces around a corner into a target.
5. **Crystals** are collected the same way as level 1, now including ones carried by ranged enemies.

**Art asset list, level 2**

| Asset | Type | Size (px) | Frames / notes |
| --- | --- | --- | --- |
| Ranged enemy idle / walk | Character | ~32 tall | 4 directions, 4 frames |
| Ranged enemy aim / shoot | Character | ~32 tall | 4 directions, 2 to 4 frames, with a "tell" before firing |
| Ranged enemy hurt / death | Character | ~32 tall | 1 hurt frame, 4 to 6 death frames |
| Enemy projectile | Effect | ~6 to 8 | 2 to 4 frame loop, plus a 3-frame impact |
| Weapon pickup | Pickup | ~16 | Idle glow loop, on a pedestal prop |
| Player with weapon: idle / walk | Character | ~32 tall | 4 directions (the weapon may be a separate overlay) |
| Player shoot | Character | ~32 tall | 4 directions, 2 to 3 frames, plus muzzle flash |
| Player projectile | Effect | ~6 to 8 | 2 to 4 frame loop, plus impact |
| Puzzle pieces | Prop | | Depends on the puzzle picked: e.g. target switch (off, hit, on) |
| Cover / low wall | Tileset | 32x16 base | A shorter wall the player can see and shoot over *(if used)* |
| New floor and wall variation | Tileset | 32x16 | Optional: a new look so level 2 reads as a new place |
| HUD | UI | | Weapon icon, ammo display *(if ammo is used)* |

---

### Level 3: Abilities and boss

**Teaches:** abilities, the third puzzle type, the kill gauge, and a boss fight.

**Mechanics**

1. **Abilities.** The player unlocks abilities early in the level, each introduced in its own small room.
   - **OPEN: which abilities, and how many.** Common picks that fit an isometric action puzzle game:
     dash (a short invulnerable burst, good for crossing hazards), shield or parry (block or reflect bullets),
     area attack (a ring that hits everything nearby), slow time, or a grapple to pull yourself or crates.
   - **OPEN:** do abilities use a cooldown, an energy bar, or crystals as a resource?
2. **Third puzzle.** **OPEN: which puzzle.** It works best if it needs an ability. For example: dash across a gap or
   through a row of spinners, a parried bullet hits a target, or a pull brings a crate across a gap.
   Other ideas: pressure plates that only stay down while you stand on them, light beams and mirrors,
   colored crystals that unlock matching gates.
3. **Kill gauge.** After the puzzle, you enter an arena. Waves of enemies (melee and ranged mixed) spawn, and each kill
   fills a gauge on the HUD. *(proposal: about 10 to 15 kills.)* This tests everything: dodging, melee, shooting, abilities.
   - **OPEN:** does the gauge drain over time if you stop killing, or only go up?
4. **Boss.** When the gauge fills, the boss spawns. **OPEN: the boss's design.** As a tutorial boss it should
   test what the three levels taught, with clear, readable phases. A possible outline:
   - Phase 1: slow melee charges and a bullet ring to dodge.
   - Phase 2 (half health): summons a few small enemies or spinners, needs an ability to get through.
   - A health bar on the HUD, larger sprite (up to 48 px tall per the art guidelines).
5. **The end.** Killing the boss ends the How To Play section: a "tutorial complete" screen, then on to the main game
   (or back to the title for now).

**Art asset list, level 3**

| Asset | Type | Size (px) | Frames / notes |
| --- | --- | --- | --- |
| Ability effects | Effect | | One set per ability, e.g. dash trail, shield bubble, area ring |
| Player ability animations | Character | ~32 tall | 4 directions, per ability (e.g. dash pose) |
| Ability pickup / unlock shrine | Prop | ~32 | Idle loop and "activated" moment |
| Puzzle pieces | Prop | | Depends on the puzzle picked |
| Arena floor and walls | Tileset | 32x16 | A distinct look for the arena |
| Enemy spawn effect | Effect | ~32 | 4 to 6 frames, warns where an enemy will appear |
| Boss idle / move | Character | ~48 tall | 4 directions, 4 to 6 frames |
| Boss attacks | Character + effects | ~48 tall | One set per attack, each with a "tell" frame before it hits |
| Boss hurt / death | Character | ~48 tall | Hurt flash frame, longer death animation (8+ frames) |
| Boss projectiles | Effect | ~8 to 12 | If the boss shoots |
| HUD | UI | | Kill gauge (empty, filling, full), boss health bar, ability icons with cooldown |
| Tutorial complete screen | UI | 640x360 | Background or panel and title text |

---

### Suggested art order

To get the look and feel nailed down early, draw in this order. Each step can replace the placeholder
shapes in the game one piece at a time (see `docs/level-design.md`, "Replacing placeholder art").

1. Floor and wall tiles, the player idle and walk. These set the style for everything else.
2. Crystal, red spinner, crate, plate, gate, exit portal. Level 1 is then fully drawn apart from the enemy.
3. Melee enemy, melee swing, HUD hearts and crystal icon. Level 1 is complete.
4. Level 2 pieces, then level 3, then the boss last.

### Open questions

1. **Weapon** (level 2): what kind, ammo or not, and how aiming works.
2. **Second puzzle** (level 2): shoot switches, timed switches, reflectors, or something else.
3. **Abilities** (level 3): which ones, how many, and what powers them.
4. **Third puzzle** (level 3): which one, and which ability it needs.
5. **Kill gauge:** how many kills, and whether it drains.
6. **Boss:** look, attacks, and how many phases.
7. **Do the abilities and weapon carry over** into the main game, or does the main game unlock them again?
