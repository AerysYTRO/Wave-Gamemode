# Wave Romania Roleplay - Core Resource

## 📋 Overview

**Wave Core** is a comprehensive, modular core resource system for MTA (Multi Theft Auto) servers. Designed specifically for **Wave Romania Roleplay**, it provides a robust foundation for managing player permissions, groups, priorities, factions, VIP status, donator systems, and more.

Built with clean, well-documented Lua code, Wave Core follows best practices for modularity, scalability, and extensibility.

---

## 🚀 Features

### 1. **Player Permissions System**
- Role-based permission management
- Support for wildcard permissions (`*`)
- Permission groups and inheritance
- Cached permissions for performance
- Database-backed permission storage

### 2. **Priority System**
- Player priority levels (1-100)
- Priority-based queue system
- Comparison functions for players
- Automatic priority inheritance from groups
- Cache support for quick lookups

### 3. **Groups System**
- Predefined groups (admin, helper, moderator, police, medic, etc.)
- Group-based permissions
- Group priority levels
- Single group per player
- Easy group switching

### 4. **Commands Manager**
- Modular command registration
- Permission-based command access
- Built-in command logging
- Admin commands for managing players
- Extensible command system

### 5. **UI External API**
- Open/close UI for players
- Send data to UI elements
- Notification system
- Dialog/confirmation boxes
- Message boxes with types

### 6. **Database System**
- MariaDB/MySQL support
- Async and sync query functions
- Parameter-bound queries (prepared statements)
- Connection pooling
- Complete schema included

### 7. **Factions System**
- Create and manage factions
- Assign players to factions
- Faction-specific permissions
- Leader assignment
- Member management

### 8. **VIP System**
- VIP status management
- Time-limited VIP support
- VIP permissions and features
- Daily bonus system
- VIP player announcements

### 9. **Donator System**
- Donator status tracking
- Multiple donator tiers (bronze, silver, gold)
- Tier-specific benefits
- Daily reward claiming
- Donator leaderboards

### 10. **Utility Functions**
- String manipulation (trim, split, title case)
- Table operations (merge, contains, count)
- Player lookup functions
- Message formatting and sending
- Time/date functions
- Math utilities
- Validation functions

---

## 📁 Directory Structure

```
wave_core/
├── meta.xml                  # Resource manifest and configuration
├── config/
│   └── config.xml           # Server configuration (groups, factions, VIP, donator)
├── core/
│   ├── core.lua             # Main initialization module
│   ├── permissions.lua      # Permission system
│   ├── priority.lua         # Priority system
│   ├── groups.lua           # Groups system
│   ├── commands.lua         # Commands manager
│   ├── exports.lua          # Export definitions
│   ├── ui.lua               # UI system
│   ├── database.lua         # Database operations
│   ├── factions.lua         # Factions system
│   ├── vip.lua              # VIP system
│   └── donator.lua          # Donator system
├── utils/
│   └── utils.lua            # Utility functions
├── resources/
│   └── resource_name.lua    # Template for custom resources
├── db/
│   └── schema.sql           # Database schema (create tables)
└── README.md                # This file
```

---

## ⚙️ Installation & Setup

### 1. **Install the Resource**

```bash
# Copy the wave_core folder to your MTA server's resources directory
cp -r wave_core /path/to/mta/server/resources/
```

### 2. **Configure Database**

Edit `config/config.xml` and update database credentials:

```xml
<database>
    <host>localhost</host>
    <port>3306</port>
    <username>root</username>
    <password>your_password</password>
    <database>wave_roleplay</database>
</database>
```

### 3. **Create Database Tables**

Import the schema into your database:

```bash
mysql -u root -p wave_roleplay < db/schema.sql
```

Or using a MySQL client:

```sql
-- Copy contents of db/schema.sql and execute in your MySQL client
```

### 4. **Add to Server Configuration**

Edit your `mtaserver.conf` and add:

```xml
<resource src="wave_core" startup="1" protected="0"/>
```

### 5. **Start the Server**

The resource will automatically initialize on server startup.

---

## 📖 Usage Guide

### Basic Functions

#### Check Player Permissions
```lua
-- Export wave_core first
local waveCore = exports.wave_core

-- Check single permission
if waveCore:hasPermission(player, "admin.kick") then
    -- Player has permission
end

-- Check multiple permissions (any)
if waveCore:hasAnyPermission(player, {"admin.kick", "mod.kick"}) then
    -- Player has at least one
end

-- Check all permissions
if waveCore:hasAllPermissions(player, {"admin.kick", "admin.ban"}) then
    -- Player has all permissions
end
```

#### Manage Player Groups
```lua
local waveCore = exports.wave_core

-- Get player group
local group = waveCore:getPlayerGroup(player)
print("Player group: " .. group)

-- Set player group
waveCore:setPlayerGroup(player, "admin")

-- Get available groups
local groups = waveCore:getAllGroups()
for _, groupName in ipairs(groups) do
    print("Group: " .. groupName)
end
```

#### Player Priority
```lua
local waveCore = exports.wave_core

-- Get priority
local priority = waveCore:getPlayerPriority(player)

-- Set priority (1-100)
waveCore:setPlayerPriority(player, 50)

-- Check minimum priority
if waveCore:hasMinimumPriority(player, 30) then
    print("Player has high priority")
end

-- Compare players
if waveCore:hasHigherPriority(player1, player2) then
    print("Player1 has higher priority")
end
```

#### Commands Registration
```lua
local waveCore = exports.wave_core

-- Register a command
waveCore:addCoreCommand(
    "mycommand",                    -- Command name
    "admin.manage_players",         -- Required permission
    function(player, args)           -- Callback
        waveCore:sendSuccessMessage(player, "Command executed!")
    end,
    "My command description"        -- Description
)

-- Remove command
waveCore:removeCommand("mycommand")
```

#### Faction Management
```lua
local waveCore = exports.wave_core

-- Get player faction
local faction = waveCore:getPlayerFaction(player)

-- Assign to faction
waveCore:assignFactionMember(player, "Los Santos Police Department", "Officer")

-- Get faction members
local members = waveCore:getFactionMembers("Los Santos Police Department")
for _, member in ipairs(members) do
    print(member.username .. " - " .. member.rank)
end

-- Remove from faction
waveCore:removeFactionMember(player, "Los Santos Police Department")
```

#### VIP System
```lua
local waveCore = exports.wave_core

-- Check VIP status
if waveCore:isVIP(player) then
    print("Player is VIP")
end

-- Grant VIP
waveCore:setVIP(player, true)

-- Time-limited VIP (30 days)
waveCore:setVIP(player, "limited", "2025-12-28 00:00:00")

-- Check remaining time
local remaining = waveCore:getVIPRemainingTime(player)
if remaining then
    print("VIP expires in " .. remaining .. " seconds")
end

-- Get all VIP players online
local vipPlayers = waveCore:getVIPPlayersOnline()
```

#### Donator System
```lua
local waveCore = exports.wave_core

-- Check donator status
if waveCore:isDonator(player) then
    print("Player is a donator")
end

-- Set as donator
waveCore:setDonator(player, true, "gold")

-- Get donator tier
local tier = waveCore:getDonatorTier(player)

-- Get benefits for tier
local benefits = waveCore:getDonatorBenefits("gold")

-- Claim daily reward
waveCore:claimDonatorReward(player)
```

#### UI Functions
```lua
local waveCore = exports.wave_core

-- Open UI
waveCore:openUI(player, "main_menu", {
    username = getPlayerName(player),
    level = 10
})

-- Send data to UI
waveCore:sendUIData(player, "health", getElementHealth(player))

-- Show notification
waveCore:showNotification(player, "Success", "Action completed!", "success", 5000)

-- Show dialog
waveCore:showDialog(player, "Confirm", "Are you sure?", {"Yes", "No"}, function(p, buttonIndex)
    if buttonIndex == 1 then
        print("User confirmed")
    end
end)

-- Close UI
waveCore:closeUI(player)
```

---

## 🔐 Permission System

### Default Groups and Permissions

#### User (Priority: 1)
```
basic.chat
basic.move
```

#### Helper (Priority: 30)
```
basic.chat
basic.move
help.kick
help.warn
help.mute
```

#### Moderator (Priority: 50)
```
basic.chat
basic.move
mod.kick
mod.ban
mod.warn
mod.mute
mod.jail
```

#### Admin (Priority: 75)
```
admin.all
admin.kick
admin.ban
admin.manage_players
admin.manage_groups
admin.manage_commands
```

#### SuperAdmin (Priority: 100)
```
* (Wildcard - all permissions)
```

### Custom Permissions

Add custom permissions to groups in `config/config.xml`:

```xml
<group name="yourgroup" priority="45">
    <permissions>
        <permission>custom.permission.one</permission>
        <permission>custom.permission.two</permission>
    </permissions>
</group>
```

---

## 🗄️ Database Schema

The system uses 10 main tables:

1. **players** - Player accounts
2. **player_groups** - Player group assignments
3. **player_permissions** - Custom player permissions
4. **player_priority** - Priority levels
5. **factions** - Faction definitions
6. **faction_members** - Faction membership
7. **faction_permissions** - Faction-specific permissions
8. **player_vip** - VIP status
9. **player_donator** - Donator status
10. **logs** - Activity logging

All tables are indexed for optimal performance.

---

## 🎯 Built-in Commands

### User Commands
- `/help` - View available commands
- `/whoami` - View your player information
- `/players` - List online players
- `/myfaction` - View your faction information

### Admin Commands
- `/setgroup [player] [group]` - Set player group
- `/giveperm [player] [permission]` - Grant permission
- `/removeperm [player] [permission]` - Remove permission
- `/setpriority [player] [priority]` - Set priority (1-100)

---

## 📚 Advanced Usage

### Custom Command Handler
```lua
local waveCore = exports.wave_core

-- Create a custom admin command
waveCore:addCoreCommand(
    "kick",
    "admin.kick",
    function(player, args)
        if #args < 1 then
            waveCore:sendErrorMessage(player, "Usage: /kick [player_name] [reason]")
            return
        end
        
        local target = waveCore:getPlayerByPartialName(args[1])
        if not target then
            waveCore:sendErrorMessage(player, "Player not found")
            return
        end
        
        local reason = table.concat(args, " ", 2) or "No reason"
        kickPlayer(target, player, reason)
        
        waveCore:sendSuccessMessage(player, "Kicked " .. getPlayerName(target))
    end,
    "Kick a player from the server"
)
```

### Listening to Events
```lua
-- Listen for VIP grants
addEventHandler("onPlayerVIPGranted", getRootElement(), function(player)
    print(getPlayerName(player) .. " became VIP!")
    -- Add custom VIP effects
end)

-- Listen for donator bonuses
addEventHandler("onDonatorBonus", getRootElement(), function(bonusType, amount)
    print("Donator bonus: " .. bonusType .. " - " .. amount)
end)

-- Listen for faction changes
addEventHandler("onPlayerFactionChanged", getRootElement(), function(newFaction)
    print(getPlayerName(source) .. " joined " .. newFaction)
end)
```

### Database Queries
```lua
local waveCore = exports.wave_core

-- Async query (recommended)
waveCore:dbQueryAsync(
    "SELECT * FROM players WHERE username = ?",
    {"PlayerName"},
    function(err, result)
        if err then
            print("Error: " .. err)
        else
            if result and #result > 0 then
                local player = result[1]
                print("Found player: " .. player.username)
            end
        end
    end
)

-- Sync query (blocks until complete - use carefully)
local result = waveCore:dbExecSync(
    "SELECT * FROM players WHERE id = ?",
    {1}
)
```

---

## 🛠️ Extending the System

### Creating Custom Modules

Create a new Lua file in the `resources` folder:

```lua
-- resources/my_feature.lua

local waveCore = exports.wave_core

-- Your custom code
local function myCustomFunction(player)
    if waveCore:hasPermission(player, "my.permission") then
        -- Do something
    end
end

-- Register as export
exports.myFeature = myCustomFunction
```

Add to `meta.xml`:

```xml
<script src="resources/my_feature.lua" type="server"/>
```

---

## ⚡ Performance Tips

1. **Use Caching**: The system caches permissions, priorities, and groups
2. **Batch Updates**: Update multiple players with `setGroupForPlayers()`
3. **Async Queries**: Always use `dbQueryAsync()` for database operations
4. **Minimize Exports Calls**: Store exported functions in local variables
5. **Monitor Logs**: Use `/debugscript 3` to monitor performance

---

## 🐛 Troubleshooting

### Database Connection Issues
- Check credentials in `config/config.xml`
- Verify MariaDB/MySQL is running
- Check firewall rules (port 3306)
- Review server logs for connection errors

### Commands Not Working
- Verify permission in config
- Check `/debugscript 3` for errors
- Use `/whoami` to verify permissions
- Ensure command name is lowercase

### Performance Issues
- Clear caches with cache clearing functions
- Check database for slow queries
- Monitor player count
- Review log files

---

## 📝 Configuration Guide

Edit `config/config.xml` to customize:

- Database credentials
- Group definitions and permissions
- Faction list and permissions
- VIP features
- Donator tiers
- Server settings

---

## 🔄 Update & Maintenance

To update the resource:

1. Backup current installation
2. Download new version
3. Replace files
4. Review configuration changes
5. Test on development server
6. Deploy to production

---

## 📄 License

Wave Core is developed for the Wave Romania Roleplay project.

---

## 👥 Support & Credits

**Developed by:** Wave Romania Roleplay Development Team

For issues, suggestions, or contributions, please contact the development team.

---

## 🎓 Quick Start Checklist

- [ ] Install resource to server
- [ ] Update database credentials
- [ ] Create database tables (schema.sql)
- [ ] Add resource to mtaserver.conf
- [ ] Test commands with `/help`
- [ ] Configure custom groups in config.xml
- [ ] Create custom commands as needed
- [ ] Monitor logs for errors

---

## 🔗 Related Documentation

- [MTA Documentation](https://wiki.multitheftauto.com/)
- [MariaDB Documentation](https://mariadb.com/docs/)
- [Lua 5.1 Reference](https://www.lua.org/manual/5.1/)

---

**Wave Core v1.0.0** - Ready for production use ✅
