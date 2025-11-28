# 🚀 Wave HUD - Quick Start Guide

## ⚡ 60-Second Setup

### 1. Add to server.cfg
```xml
<resource src="wave_hud" startup="1" protected="0"/>
```

### 2. Ensure wave_core is running first
```xml
<!-- In server.cfg, wave_core MUST be before wave_hud -->
<resource src="wave_core" startup="1" protected="0"/>
<resource src="wave_hud" startup="1" protected="0"/>
```

### 3. Start/Restart Server
```bash
/refresh
/start wave_hud
```

### 4. Test in-game
- Connect as player
- See HUD in top-right corner ✅
- See stats bar at bottom ✅
- Press H to toggle HUD
- Press DELETE to see player IDs above heads
- Press F10 to see debug info

---

## 🎯 Common Tasks

### Give Money to Player
```lua
-- Server-side
exports.wave_hud:givePlayerCash(player, 5000)         -- Add $5000 cash
exports.wave_hud:givePlayerBankMoney(player, 10000)   -- Add $10000 bank
```

### Or Use Commands
```
/givemoney [playerID] [amount]      -- Give cash
/givebankmon [playerID] [amount]    -- Give bank money
```

### Check Player Money
```lua
local cash = exports.wave_hud:getPlayerCash(player)
local bank = exports.wave_hud:getPlayerBankMoney(player)
```

### Remove Money
```lua
exports.wave_hud:takePlayerCash(player, 1000)         -- Remove $1000 cash
exports.wave_hud:takePlayerBankMoney(player, 5000)    -- Remove $5000 bank
```

### Toggle HUD Visibility
```lua
exports.wave_hud:setHUDVisible(player, false)  -- Hide
exports.wave_hud:setHUDVisible(player, true)   -- Show
```

---

## 🎨 What You See

### Top-Right Panel
- **Logo**: WAVE ROMANIA (blue gradient)
- **Player Info**: ID + Name
- **Money**: Bank balance & Cash balance
- **Faction & Group**: Current faction and rank

### Bottom-Center Stats
- **Health**: Green bar (0-100)
- **Armor**: Blue bar (0-100)  
- **Energy**: Orange bar (0-100)

All bars pulse when under 30%

---

## ⌨️ Controls

| Key | Action |
|-----|--------|
| H | Toggle HUD visibility |
| DELETE | Show player IDs above heads |
| F10 | Display debug info (admins) |

---

## 🔧 Configuration

### Update Frequency
Edit in `client/hud.lua`:
```lua
HUD.updateInterval = 500  -- Change from 500ms
```

### ID Display Distance
Edit in `client/id_display.lua`:
```lua
displayDistance = 50  -- Change from 50 meters
```

### ID Display Colors
Edit in `client/id_display.lua`:
```lua
color = {
    r = 0,      -- Red (0-255)
    g = 102,    -- Green (0-255)
    b = 255,    -- Blue (0-255)
    a = 255     -- Alpha (0-255)
}
```

---

## 📂 File Structure

```
wave_hud/
├── meta.xml              ← Resource manifest
├── README.md             ← Full documentation
├── QUICKSTART.md         ← This file
├── server/
│   └── hud.lua          ← Server logic (money, sync)
├── client/
│   ├── hud.lua          ← Client CEF browser
│   └── id_display.lua   ← DELETE key handler
└── html/
    ├── hud.html         ← Layout
    ├── hud.css          ← Styling (blue+white)
    └── hud.js           ← JavaScript logic
```

---

## 🐛 Troubleshooting

### HUD Not Showing?
1. Check server console: `/debugscript 2`
2. Ensure `wave_core` is started first
3. Restart: `/restart wave_hud`
4. Check ACL permissions

### Money Not Updating?
1. Use `/givemoney` command to test
2. Check server logs for errors
3. Verify `bankMoney` and `cashMoney` element data

### DELETE Key Not Working?
1. Try in-game, not chat
2. Check other resources aren't binding DELETE
3. Restart game client

### Performance Issues?
- Reduce `updateInterval` in config
- Close unnecessary browser windows
- Check FPS with F9

---

## 📊 Default Values

When player joins:
- Bank Money: $5,000
- Cash Money: $1,000
- Health: 100
- Armor: 0
- Energy: 100

---

## 🔗 Integration with wave_core

Wave HUD automatically uses:
- Player ID from `getElementData(player, "player:id")`
- Faction from `wave_core` exports
- Group/Rank from `wave_core` exports
- Health/Armor from MTA native functions

**Requires**: wave_core resource running first

---

## ✅ Testing Checklist

- [ ] Resource starts without errors
- [ ] HUD visible in top-right
- [ ] Stats bar visible at bottom
- [ ] Money displays correctly
- [ ] Faction/Group shows correctly
- [ ] H key toggles HUD
- [ ] DELETE shows player IDs
- [ ] F10 shows debug info
- [ ] Money updates when using commands
- [ ] Bars animate smoothly

---

## 💡 Tips & Tricks

### Auto-Give Money on Join
```lua
-- In your script
addEventHandler("onPlayerJoin", getRootElement(), function()
    setTimer(function()
        if isElement(source) then
            exports.wave_hud:setPlayerMoney(source, 5000, 1000)
        end
    end, 1000)
end)
```

### Custom HUD Data
```lua
-- Force update with custom data
local customData = {
    id = 123,
    name = "Player",
    bankMoney = 100000,
    cashMoney = 50000,
    faction = "LSPD",
    group = "officer",
    health = 100,
    armor = 100,
    energy = 100
}
exports.wave_hud:updateHUDData(customData)
```

### Hide HUD for Cutscenes
```lua
exports.wave_hud:setHUDVisible(player, false)
-- ... cutscene ...
exports.wave_hud:setHUDVisible(player, true)
```

---

## 📖 More Help

For full documentation, see: **README.md**

For API reference, check exports in:
- `server/hud.lua` - Server functions
- `client/hud.lua` - Client functions

---

**Need help?** Check console logs with `/debugscript 2` or `/debugscript 3`

Enjoy your professional Wave HUD! 🎮
