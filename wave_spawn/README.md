# wave_spawn

Simple spawn manager providing a configurable `primarie` spawn and an export to spawn players there.

Features:
- Exported function: `exports.wave_spawn.spawnAtPrimarie(player, charData)` — spawns a player at configured Primarie coords and applies character data.
- Admin command: `/setprimariespawn x y z [rot]` — set the Primarie spawn (requires Admin ACL membership; adjust permission check as needed).
- Export: `exports.wave_spawn.getPrimarieSpawn()` returns x,y,z,rot.

Configuration:
- Edit `server.lua` and set `PRIMARIE_SPAWN` coordinates.

Integration:
- `wave_character` now calls the export if `wave_spawn` resource is present. If not present, `wave_character` falls back to its default spawn behavior.
