# wave_character

Simple character creation and selection system for Wave gamemode.

Features:
- Create up to 5 characters per player (stored by player serial in `server/characters/<serial>.xml`).
- Character fields: `name`, `age`, `race` (Alb/Negru), `gender` (Barbat/Femeie), `story`, `weight`, `height`.
- Native MTA GUI for creation and selection (no HTML/CEF).
- Basic spawn logic: selects a skin by gender and respawns the player with the chosen character.

Usage:
- On joining the server, if you have no characters you'll be prompted to create one.
- The character selection/creation flow is automatic on join; manual test bindings and commands were removed.

Persistence:
- Characters are saved to XML files inside `wave_character/server/characters/` by player serial.
- You can backup or migrate these files as needed.

Notes & next steps:
- You may want to change the spawn coordinates in `server.lua` (currently set to `0,0,3`).
- The skin mapping is very simple (gender -> skin id). You can expand this to more realistic skins and race-based selections.
- Consider migrating storage to your main DB (`wave_core`) for production.
