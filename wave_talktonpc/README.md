# wave_talktonpc

Lightweight NPC conversation system for Wave gamemode.

Features
- Load/save NPCs from `server/npcs.xml` and spawn peds on resource start.
- Exports:
  - `exports.wave_talktonpc.createNPC(data)` -> creates and persists an NPC. `data` fields: `name`, `model`, `x`, `y`, `z`, `rot`, `dialog` (string, can contain newlines).
  - `exports.wave_talktonpc.removeNPC(id)` -> remove npc by id.
  - `exports.wave_talktonpc.getNPCs()` -> returns current NPC table.
- Client: press `E` near an NPC (within ~3 meters) to open a simple dialog window (native GUI).

Usage
- Create NPCs programmatically (recommended) from server-side scripts:
```lua
local npc = exports.wave_talktonpc.createNPC({ name = "Primarie", model = 0, x = 0, y = 0, z = 3, rot = 0, dialog = "Buna!\nCe pot face pentru tine?" })
```
- NPCs are saved to `wave_talktonpc/server/npcs.xml`.

Notes
- Dialog is currently a simple sequence of lines separated by newlines. Future improvements can add choices, callbacks, and server-side handlers.
- The system intentionally exposes programmatic exports instead of in-game admin commands — you can create NPCs from server-side scripts or a management tool.
