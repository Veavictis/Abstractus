# Abstractus: Game Design Document

Status: first draft, 2026-10-30. This doc records only what the creator has stated.
Anything not yet decided is listed under [Open questions](#open-questions) and is
decided by the creator, not filled in by tools.

## Pitch (in the creator's words)

> Vampire Survivors Clone.
> Game / Art style is exactly like Vampire Survivors.

Genre: survivors-like (auto-attacking, wave survival), modeled on Vampire Survivors'
gameplay and presentation.

The Vampire Survivors name is an internal reference only. It will never be mentioned
on the Steam page or in marketing.

## What makes Abstractus different

1. **Abstract world.** The player and everything they fight are a series of abstract
   shapes and colors.
2. **Random events as mini games.** Random events trigger mini games during play.
   - The one defined so far: the player has **15 seconds to put together a jigsaw
     puzzle** made out of the creator's art.
3. **Art gallery.** An art gallery that the player slowly fills in with **over 300
   pieces** of the creator's art.
4. **Meta progression from art.** Collecting art pieces grants some type of
   **permanent meta progression bonus** (details TBD).
5. **HUB.** The player can view the collected art at any time from a HUB, which the
   creator designs.
6. **Unique upgrade system(s).** TBD, to be designed in a dedicated discussion.

## Story

- Very minimal story.
- Basic plot: TBD.

## Art

- 100% of the art is made by the creator.
- Style: the same as Vampire Survivors, with all characters and enemies as abstract
  shapes and colors.
- Shaders are sometimes used to enhance the art (`assets/shaders/`).

## Audio

- 100% of the music and SFX are made by the creator.
- Voiceovers will be added later and will need some audio touch-up.
  See [Voiceover processing in Godot](#voiceover-processing-in-godot).

## Voiceover processing in Godot

Godot can do the touch-up live, through its audio buses (Project > Audio tab at the
bottom of the editor). A `Voice` bus can carry a chain of built-in effects:

| Need | Godot effect |
| --- | --- |
| Cut rumble / hiss, shape tone | `AudioEffectEQ` (6/10/21 band), `AudioEffectHighPassFilter`, `AudioEffectLowPassFilter` |
| Even out loud and quiet lines | `AudioEffectCompressor` |
| Stop peaks from clipping | `AudioEffectHardLimiter` |
| Room / space | `AudioEffectReverb` |
| Other color | `AudioEffectChorus`, `AudioEffectDistortion`, `AudioEffectPitchShift`, `AudioEffectDelay` |
| Lower music while a line plays (ducking) | Compressor on the Music bus with its sidechain set to the Voice bus |

Limits: Godot has no noise reduction, de-essing, or offline normalization of the files
themselves. Those (and loudness normalization to a common level) are best done once in
an audio editor such as Audacity or Reaper before importing. Godot's
`volume_db` per line can then fine-tune.

## Open questions

These are for the creator to decide. Nothing here has been chosen.

**Story**
- What is the basic plot?
- How and where is the minimal story delivered (and where do voiceovers play)?

**Upgrade system(s)**
- Full design to come from a dedicated, long discussion.

**Meta progression from the gallery**
- What type of permanent bonus does collecting art give?
- Per piece, per set, per milestone, or something else?

**Art gallery**
- How are art pieces earned (jigsaw mini game, runs, other events)?
- Are the 300+ pieces grouped in any way?

**Random events / mini games**
- Which other mini games exist besides the jigsaw?
- Jigsaw: how many pieces, what happens on success or failure, does the run pause?

**HUB**
- What does the HUB contain besides the gallery?
