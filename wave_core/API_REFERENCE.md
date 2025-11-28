# Wave Romania Roleplay - Complete API Reference

## 📚 Complete Function Reference

### Permissions Module (`core/permissions.lua`)

#### Core Functions

```lua
hasPermission(player, permission) -> boolean
-- Check if player has a specific permission
-- Example: hasPermission(player, "admin.kick")

hasAnyPermission(player, permissions) -> boolean
-- Check if player has any of the permissions in table
-- Example: hasAnyPermission(player, {"admin.kick", "mod.kick"})

hasAllPermissions(player, permissions) -> boolean
-- Check if player has all permissions in table
-- Example: hasAllPermissions(player, {"admin.kick", "admin.ban"})

getPlayerPermissions(player) -> table
-- Get all permissions for a player
-- Returns: {"permission1", "permission2", ...}

addPlayerPermission(player, permission) -> boolean
-- Add a permission to player
-- Example: addPlayerPermission(player, "admin.kick")

removePlayerPermission(player, permission) -> boolean
-- Remove a permission from player
-- Example: removePlayerPermission(player, "admin.kick")

clearPlayerPermissions(player) -> boolean
-- Remove all permissions from player

clearPermissionCache(player) -> void
-- Clear cached permissions for a player (forces reload from DB)

clearAllPermissionCaches() -> void
-- Clear all permission caches
```

---

### Priority Module (`core/priority.lua`)

```lua
getPlayerPriority(player) -> integer
-- Get player's priority level (1-100)
-- Returns: priority level or 1 (default)

setPlayerPriority(player, priority) -> boolean
-- Set player's priority level
-- Priority must be between 1-100
-- Example: setPlayerPriority(player, 50)

incrementPlayerPriority(player, amount) -> integer|nil
-- Increase player's priority by amount
-- Default amount: 1
-- Returns: new priority or nil if failed

decrementPlayerPriority(player, amount) -> integer|nil
-- Decrease player's priority by amount
-- Default amount: 1
-- Returns: new priority or nil if failed

comparePriority(player1, player2) -> integer
-- Compare two players' priorities
-- Returns: 1 (player1 > player2), -1 (player1 < player2), 0 (equal)

hasHigherPriority(player1, player2) -> boolean
-- Check if player1 has higher priority than player2

hasMinimumPriority(player, minPriority) -> boolean
-- Check if player has at least minPriority level

addToQueueByPriority(player) -> integer
-- Add player to priority queue
-- Returns: position in queue

getNextFromQueue() -> player|nil
-- Get next player from priority queue (highest priority first)

getQueueSize() -> integer
-- Get number of players in queue
```

---

### Groups Module (`core/groups.lua`)

```lua
getPlayerGroup(player) -> string
-- Get player's group name
-- Returns: group name or "user" (default)

setPlayerGroup(player, groupName) -> boolean
-- Set player's group
-- Example: setPlayerGroup(player, "admin")

isGroupExists(groupName) -> boolean
-- Check if group exists in configuration

getGroupInfo(groupName) -> table|nil
-- Get group information
-- Returns: {name, priority, permissions} or nil

getAllGroups() -> table
-- Get all available group names
-- Returns: {"user", "admin", "helper", ...}

getGroupPermissions(groupName) -> table
-- Get permissions for a group
-- Returns: {"permission1", "permission2", ...}

groupHasPermission(groupName, permission) -> boolean
-- Check if group has a permission

getGroupPriority(groupName) -> integer
-- Get group's priority level

getPlayersInGroup(groupName) -> table
-- Get all players in a group
-- Returns: {player1, player2, ...}

countPlayersInGroup(groupName) -> integer
-- Count players in a group

setGroupForPlayers(players, groupName) -> integer
-- Set group for multiple players
-- Returns: number of successful changes

rankPlayersByGroup(players) -> table
-- Rank players by their group priority (highest first)
```

---

### Commands Module (`core/commands.lua`)

```lua
addCoreCommand(name, permission, callback, description) -> boolean
-- Register a command
-- callback function: function(player, arguments_table)
-- Example:
--   addCoreCommand("mycommand", "admin.all", function(player, args)
--       -- do something
--   end, "My command description")

getCommandInfo(name) -> table|nil
-- Get command information
-- Returns: {name, permission, callback, description} or nil

getAllCommands() -> table
-- Get all registered commands
-- Returns: {commandName = {info}, ...}

removeCommand(name) -> boolean
-- Remove a command

executeCoreCommand(player, commandName, ...) -> boolean
-- Execute a command
-- Example: executeCoreCommand(player, "help")
```

---

### UI Module (`core/ui.lua`)

```lua
openUI(player, uiName, data) -> boolean
-- Open UI for player
-- Example: openUI(player, "main_menu", {username = "Test"})

closeUI(player) -> boolean
-- Close player's UI

closeUIAll() -> void
-- Close UI for all players

hasUIOpen(player) -> boolean
-- Check if player has UI open

getPlayerOpenUI(player) -> string|nil
-- Get name of player's open UI

sendUIData(player, key, value) -> boolean
-- Send/update data to player's UI

getUIData(player, key) -> value|nil
-- Get UI data value

notifyUI(player, eventName, ...) -> boolean
-- Send notification event to player's UI

notifyUIAll(eventName, ...) -> void
-- Send notification to all players' UIs

showNotification(player, title, message, type, duration) -> void
-- Show notification to player
-- Types: "success", "error", "info", "warning"
-- Duration in milliseconds (default: 5000)

showDialog(player, title, message, buttons, callback) -> void
-- Show dialog to player
-- Callback: function(player, buttonIndex)

showConfirmDialog(player, message, callback) -> void
-- Show confirmation dialog
-- Callback: function(player, confirmed)

showMessageBox(player, title, message, type) -> void
-- Show message box
-- Types: "info", "warning", "error", "success"
```

---

### Database Module (`core/database.lua`)

```lua
initializeDatabase(config) -> boolean
-- Initialize database connection
-- config: {host, port, username, password, database}

dbQueryAsync(query, params, callback) -> void
-- Execute async database query
-- Callback: function(err, result)
-- Example: dbQueryAsync("SELECT * FROM players WHERE id = ?", {1}, function(err, result) end)

dbExecSync(query, params) -> table|nil
-- Execute sync database query (BLOCKING)
-- Use with caution - blocks script execution
-- Returns: result table or nil

getPlayerData(playerName) -> table|nil
-- Get player data by username

createPlayerRecord(playerName, passwordHash, playerIP) -> boolean
-- Create new player record

updatePlayerLastLogin(playerID, playerIP) -> boolean
-- Update player's last login info

getPlayerGroupDB(playerID) -> string|nil
-- Get player group from database

setPlayerGroupDB(playerID, groupName) -> boolean
-- Set player group in database

getPlayerPriorityDB(playerID) -> integer
-- Get player priority from database

setPlayerPriorityDB(playerID, priority) -> boolean
-- Set player priority in database

getPlayerPermissionsDB(playerID) -> table
-- Get custom player permissions from database

addPlayerPermissionDB(playerID, permission) -> boolean
-- Add permission to player in database

removePlayerPermissionDB(playerID, permission) -> boolean
-- Remove permission from player in database

logActionDB(playerID, action, details) -> boolean
-- Log action to database
-- Example: logActionDB(1, "player_joined", "IP: 192.168.1.1")
```

---

### Factions Module (`core/factions.lua`)

```lua
addFaction(name, factionID, permissions) -> boolean
-- Create new faction
-- Example: addFaction("Police", 1, {"faction.police.arrest"})

getFaction(factionName) -> table|nil
-- Get faction data
-- Returns: {id, name, color, leader, maxMembers, permissions, members}

getAllFactions() -> table
-- Get all factions
-- Returns: {factionName = {data}, ...}

deleteFaction(factionName) -> boolean
-- Delete faction

getPlayerFaction(player) -> string|nil
-- Get player's faction name

getFactionMembers(factionName) -> table
-- Get faction members
-- Returns: {member1, member2, ...}

assignFactionMember(player, factionName, rank) -> boolean
-- Assign player to faction
-- Rank defaults to "Member"
-- Example: assignFactionMember(player, "Police", "Officer")

removeFactionMember(player, factionName) -> boolean
-- Remove player from faction

isPlayerInFaction(player, factionName) -> boolean
-- Check if player is in faction

getFactionMemberCount(factionName) -> integer
-- Get number of members in faction

getFactionPermissions(factionName) -> table
-- Get faction permissions

addFactionPermission(factionName, permission) -> boolean
-- Add permission to faction

factionHasPermission(factionName, permission) -> boolean
-- Check if faction has permission

setFactionLeader(factionName, player) -> boolean
-- Set faction leader (player or nil to remove)

getFactionLeader(factionName) -> string
-- Get faction leader name

triggerFactionEvent(factionName, eventName, ...) -> void
-- Trigger event for all faction members
```

---

### VIP Module (`core/vip.lua`)

```lua
isVIP(player) -> boolean
-- Check if player is VIP

setVIP(player, status, expiryDate) -> boolean
-- Grant/revoke VIP status
-- status: true (permanent), "limited" (time-limited), or false (revoke)
-- expiryDate: "YYYY-MM-DD HH:MM:SS" (optional, for limited VIP)
-- Example: setVIP(player, "limited", "2025-12-31 00:00:00")

isVIPExpired(player) -> boolean
-- Check if VIP status has expired
-- Returns: true if expired or not VIP

getVIPRemainingTime(player) -> integer|nil
-- Get VIP remaining time in seconds

grantVIPPermissions(player) -> void
-- Grant VIP permissions to player

revokeVIPPermissions(player) -> void
-- Revoke VIP permissions from player

getVIPFeature(featureName) -> value|nil
-- Get VIP feature value from config

isVIPFeatureEnabled(featureName) -> boolean
-- Check if VIP feature is enabled

giveVIPBonus(player, type, amount) -> boolean
-- Give VIP bonus/reward
-- Types: "cash", "items", "exp", etc.

getVIPPlayersOnline() -> table
-- Get all VIP players online
-- Returns: {vipPlayer1, vipPlayer2, ...}

sendVIPMessage(message, r, g, b) -> void
-- Send message to all VIP players

loadVIPConfig() -> table
-- Load VIP configuration from config.xml
```

---

### Donator Module (`core/donator.lua`)

```lua
isDonator(player) -> boolean
-- Check if player is donator

setDonator(player, status, tier) -> boolean
-- Set donator status
-- tier: "bronze", "silver", "gold" (defaults to "bronze")
-- Example: setDonator(player, true, "gold")

getDonatorTier(player) -> string|nil
-- Get donator tier

grantDonatorPermissions(player, tier) -> void
-- Grant donator permissions

revokeDonatorPermissions(player) -> void
-- Revoke donator permissions

getDonatorBenefits(tier) -> table
-- Get benefits for donator tier
-- Returns: {"benefit1", "benefit2", ...}

getDonatorTierCost(tier) -> integer
-- Get cost of donator tier in currency

claimDonatorReward(player) -> boolean
-- Player claims daily donator reward
-- Can only be claimed once per day

giveDonatorBonus(player, type, amount) -> boolean
-- Give donator bonus
-- Types: "cash", "items", "vip_days", etc.

getDonatorPlayersOnline() -> table
-- Get all donators online
-- Returns: {donatorPlayer1, donatorPlayer2, ...}

getDonatorsByTier(tier) -> table
-- Get donators of specific tier online

sendDonatorMessage(message, tier, r, g, b) -> void
-- Send message to donators (specific tier or all)
-- tier: specific tier or nil for all

loadDonatorConfig() -> table
-- Load donator configuration from config.xml
```

---

### Utility Module (`utils/utils.lua`)

#### String Functions
```lua
titleCase(str) -> string
-- Convert string to title case
-- Example: titleCase("hello world") -> "Hello World"

trim(str) -> string
-- Trim whitespace from string
-- Example: trim("  hello  ") -> "hello"

splitString(str, delimiter) -> table
-- Split string by delimiter
-- Example: splitString("a,b,c", ",") -> {"a", "b", "c"}
```

#### Table Functions
```lua
tableContains(tbl, value) -> boolean
-- Check if table contains value

tableCount(tbl) -> integer
-- Count table elements

tableMerge(tbl1, tbl2) -> table
-- Merge two tables into new table
```

#### Player Functions
```lua
getPlayerByPartialName(partialName) -> player|nil
-- Find player by partial name (case-insensitive)
-- Example: getPlayerByPartialName("john") -> finds "John_Doe"

getOnlinePlayers() -> table
-- Get all online players
-- Returns: {player1, player2, ...}

isPlayerOnline(playerName) -> player|nil
-- Check if player is online by name
```

#### Message Functions
```lua
sendPlayerMessage(player, message, r, g, b) -> void
-- Send colored message to player (default: white)

sendSuccessMessage(player, message) -> void
-- Send green success message

sendErrorMessage(player, message) -> void
-- Send red error message

sendInfoMessage(player, message) -> void
-- Send blue info message

sendWarningMessage(player, message) -> void
-- Send orange warning message

broadcastMessage(message, r, g, b) -> void
-- Send message to all players
```

#### Time Functions
```lua
getCurrentTimestamp() -> integer
-- Get current Unix timestamp

formatTimestamp(timestamp) -> string
-- Format Unix timestamp to readable date
-- Example: "2025-11-28 15:30:45"

hasExpired(expiryTime) -> boolean
-- Check if timestamp has expired

getTimeDifference(timestamp1, timestamp2) -> integer
-- Get time difference in seconds
```

#### Logging Functions
```lua
logMessage(logType, message) -> void
-- Log to console with type
-- Types: "INFO", "WARNING", "ERROR", "DEBUG"

debugLog(message) -> void
-- Log debug message (only if debug enabled in config)
```

#### Validation Functions
```lua
isValidEmail(email) -> boolean
-- Validate email format

isNumeric(str) -> boolean
-- Check if string is numeric

isValidPlayerName(name) -> boolean
-- Validate player name format (3-20 chars, alphanumeric + underscore)
```

#### Math Functions
```lua
clamp(value, min, max) -> number
-- Clamp value between min and max
-- Example: clamp(150, 0, 100) -> 100

roundNumber(value, decimals) -> number
-- Round number to decimal places
-- Example: roundNumber(3.14159, 2) -> 3.14

getPercentage(part, whole) -> number
-- Calculate percentage
-- Example: getPercentage(25, 100) -> 25
```

#### Distance Functions
```lua
getDistance3D(x1, y1, z1, x2, y2, z2) -> number
-- Calculate 3D distance between two points

getDistance2D(x1, y1, x2, y2) -> number
-- Calculate 2D distance between two points
```

---

### Core Module (`core/core.lua`)

```lua
getConfig() -> xmlElement
-- Get root configuration element

getConfigValue(parentName, valueName) -> value|nil
-- Get specific config value
-- Example: getConfigValue("database", "host")

getServerName() -> string
-- Get server name from config

getServerVersion() -> string
-- Get server version from config

getMaxPlayers() -> integer
-- Get max players from config
```

---

## 🎯 Quick Reference by Purpose

### Permission Check
```lua
waveCore:hasPermission(player, "permission.name")
```

### Group Management
```lua
waveCore:setPlayerGroup(player, "admin")
local group = waveCore:getPlayerGroup(player)
```

### Priority Management
```lua
waveCore:setPlayerPriority(player, 50)
local priority = waveCore:getPlayerPriority(player)
```

### Command Registration
```lua
waveCore:addCoreCommand("cmdname", "permission", function(player, args) end, "description")
```

### Faction Assignment
```lua
waveCore:assignFactionMember(player, "Police", "Officer")
```

### VIP/Donator Status
```lua
waveCore:setVIP(player, true)
waveCore:setDonator(player, true, "gold")
```

### Database Query
```lua
waveCore:dbQueryAsync("SELECT * FROM players", {}, function(err, result) end)
```

### UI Management
```lua
waveCore:openUI(player, "menu", {data = "value"})
waveCore:closeUI(player)
```

### Messages
```lua
waveCore:sendSuccessMessage(player, "Success!")
waveCore:sendErrorMessage(player, "Error!")
waveCore:broadcastMessage("Message for all")
```

---

End of API Reference v1.0.0
