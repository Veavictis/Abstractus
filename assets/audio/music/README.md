# Music

## TEMP tracks: replace before any public build or Steam release

Any file starting with `TEMP_` is a stand-in the developer picked to try the feel of a level.
It is someone else's copyrighted music and must not ship.

| File | Used in | Notes |
| --- | --- | --- |
| `TEMP_hero_remix.ogg` | First level (`scenes/levels/test_level.tscn`, `Music` node) | Loops. Downloaded by the developer from YouTube. Replace with licensed or original music. |
| `TEMP_vekk_title.ogg` | TEMP title screen (`scenes/main/main.tscn`, `Music` node) | Loops. Added by the developer as a stand-in. Replace with licensed or original music. |

To swap a track, select the level's `Music` node and drag the new file onto its `Stream`
(for an `.ogg`, turn on Loop in its Import tab). Then delete the TEMP file and its row here.

TEMP audio files are in `.gitignore`, so they stay on the developer's PC and are never pushed to GitHub.
Only their `.import` settings (such as Loop) are committed.
