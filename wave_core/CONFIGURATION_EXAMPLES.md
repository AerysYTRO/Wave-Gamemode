# Configuration Examples for Wave Core

## 🔧 Common Configuration Scenarios

### 1. Adding a New Group

Edit `config/config.xml`:

```xml
<group name="journalist" priority="35">
    <permissions>
        <permission>basic.chat</permission>
        <permission>basic.move</permission>
        <permission>journalist.interview</permission>
        <permission>journalist.take_picture</permission>
        <permission>journalist.publish</permission>
    </permissions>
</group>
```

### 2. Adding a New Faction

```xml
<faction name="LSPD Gang" id="4" color="#FF0000">
    <leader>Unknown</leader>
    <maxmembers>30</maxmembers>
    <permissions>
        <permission>faction.gang.steal</permission>
        <permission>faction.gang.shoot</permission>
        <permission>faction.gang.recruit</permission>
    </permissions>
</faction>
```

### 3. Custom Donator Tier

```xml
<tier name="diamond" cost="500">
    <benefit>100000_cash</benefit>
    <benefit>all_exclusive_vehicles</benefit>
    <benefit>premium_house_x2</benefit>
    <benefit>lifetime_vip</benefit>
    <benefit>custom_weapon_pack</benefit>
</tier>
```

### 4. VIP Features Configuration

```xml
<vip>
    <enabled>true</enabled>
    <permissions>
        <permission>vip.exclusive_commands</permission>
        <permission>vip.special_events</permission>
        <permission>vip.priority_access</permission>
    </permissions>
    <features>
        <feature name="double_rewards">true</feature>
        <feature name="exclusive_events">true</feature>
        <feature name="priority_queue">true</feature>
        <feature name="custom_skin">true</feature>
    </features>
</vip>
```

---

## 📝 Lua Configuration Examples

### 1. Custom Command with Database Query

```lua
local waveCore = exports.wave_core

waveCore:addCoreCommand("topplayers", "basic.chat", function(player, args)
    -- Database query
    waveCore:dbQueryAsync(
        "SELECT username FROM players ORDER BY level DESC LIMIT 10",
        {},
        function(err, result)
            if err then
                waveCore:sendErrorMessage(player, "Failed to fetch top players")
                return
            end
            
            waveCore:sendInfoMessage(player, "=== Top 10 Players ===")
            for i, playerData in ipairs(result or {}) do
                waveCore:sendPlayerMessage(player, i .. ". " .. playerData.username)
            end
        end
    )
end, "View top 10 players")
```

### 2. Custom Permission Check in Events

```lua
local waveCore = exports.wave_core

addEventHandler("onVehicleEnter", getRootElement(), function(player, seat, jacked)
    if not isElement(player) then return end
    
    if getVehicleType(source) == "Plane" and not waveCore:hasPermission(player, "vehicles.planes") then
        cancelEvent()
        waveCore:sendErrorMessage(player, "You cannot fly planes")
    end
end)
```

### 3. Faction-Based Rewards

```lua
local waveCore = exports.wave_core

addEventHandler("onPlayerFactionChange", getRootElement(), function(newFaction)
    local player = source
    
    if newFaction == "Los Santos Police Department" then
        -- Give police starter kit
        givePlayerMoney(player, 5000)
        waveCore:sendSuccessMessage(player, "Welcome to LSPD! You received $5000")
    elseif newFaction == "San Fierro Medical" then
        -- Give medic starter kit
        givePlayerMoney(player, 3000)
        waveCore:sendSuccessMessage(player, "Welcome to Medical! You received $3000")
    end
end)
```

### 4. Time-Based VIP System

```lua
local waveCore = exports.wave_core

local function checkAndRenewVIP(player)
    if not waveCore:isVIP(player) then return end
    
    if waveCore:isVIPExpired(player) then
        waveCore:setVIP(player, false)
        waveCore:sendWarningMessage(player, "Your VIP has expired!")
    else
        local remaining = waveCore:getVIPRemainingTime(player)
        local days = math.floor(remaining / 86400)
        
        if days < 3 then
            waveCore:sendWarningMessage(player, "Your VIP expires in " .. days .. " days!")
        end
    end
end

-- Check VIP status every 5 minutes
setTimer(function()
    for _, player in ipairs(waveCore:getOnlinePlayers()) do
        checkAndRenewVIP(player)
    end
end, 300000, 0)
```

### 5. Donator Daily Bonus with Notification

```lua
local waveCore = exports.wave_core

-- Setup daily bonus claiming
waveCore:addCoreCommand("dailybonus", "donator.special_items", function(player, args)
    if not waveCore:isDonator(player) then
        waveCore:sendErrorMessage(player, "This command is for donators only")
        return
    end
    
    if waveCore:claimDonatorReward(player) then
        local tier = waveCore:getDonatorTier(player)
        local benefit = "Donator Reward Claimed - Tier: " .. tier
        waveCore:sendSuccessMessage(player, benefit)
    end
end, "Claim your daily donator bonus")
```

### 6. Admin Panel with Permissions

```lua
local waveCore = exports.wave_core

waveCore:addCoreCommand("adminpanel", "admin.manage_players", function(player, args)
    -- Open UI with admin options
    waveCore:openUI(player, "admin_panel", {
        playerName = getPlayerName(player),
        totalPlayers = #waveCore:getOnlinePlayers(),
        groups = waveCore:getAllGroups(),
        factions = waveCore:getAllFactions()
    })
end, "Open admin panel")
```

### 7. Group-Based Salary System

```lua
local waveCore = exports.wave_core

-- Pay players salary based on group
local groupSalaries = {
    user = 100,
    helper = 500,
    moderator = 1000,
    admin = 2000,
    police = 1500,
    medic = 1200
}

setTimer(function()
    for _, player in ipairs(waveCore:getOnlinePlayers()) do
        local group = waveCore:getPlayerGroup(player)
        local salary = groupSalaries[group] or 100
        
        givePlayerMoney(player, salary)
        waveCore:sendInfoMessage(player, "You received your salary: $" .. salary)
    end
end, 3600000, 0) -- Every hour
```

### 8. Logging System with Database

```lua
local waveCore = exports.wave_core

local function logAdminAction(admin, action, target, reason)
    local adminID = getElementData(admin, "player:id")
    local targetName = getPlayerName(target)
    
    local details = "Action: " .. action .. ", Target: " .. targetName .. ", Reason: " .. (reason or "None")
    
    waveCore:logActionDB(adminID, "admin_action", details)
    
    -- Notify all admins
    local adminPlayers = waveCore:getPlayersInGroup("admin")
    for _, adminPlayer in ipairs(adminPlayers) do
        waveCore:sendInfoMessage(adminPlayer, 
            getPlayerName(admin) .. " executed: " .. action .. " on " .. targetName)
    end
end
```

### 9. Permission-Based Vehicle Access

```lua
local waveCore = exports.wave_core

local vehiclePermissions = {
    [477] = "vehicles.buses", -- Bus
    [601] = "vehicles.police", -- Police car
    [609] = "vehicles.helicopters", -- Helicopter
    [553] = "vehicles.planes" -- Andromada (plane)
}

addEventHandler("onVehicleSpawn", getRootElement(), function()
    for modelID, permission in pairs(vehiclePermissions) do
        if getElementModel(source) == modelID then
            setElementData(source, "vehicle:permission", permission)
        end
    end
end)

addEventHandler("onVehicleEnter", getRootElement(), function(player)
    local permission = getElementData(source, "vehicle:permission")
    
    if permission and not waveCore:hasPermission(player, permission) then
        cancelEvent()
        waveCore:sendErrorMessage(player, "You don't have access to this vehicle")
    end
end)
```

### 10. Dynamic Group-Based Commands

```lua
local waveCore = exports.wave_core

-- Create faction commands dynamically
local factions = waveCore:getAllFactions()

for factionName, factionData in pairs(factions) do
    local cmdName = factionName:lower():gsub(" ", "_")
    
    waveCore:addCoreCommand(cmdName .. "_info", "basic.chat", function(player, args)
        if not waveCore:isPlayerInFaction(player, factionName) then
            waveCore:sendErrorMessage(player, "You are not in this faction")
            return
        end
        
        local members = waveCore:getFactionMembers(factionName)
        local leader = waveCore:getFactionLeader(factionName)
        
        waveCore:sendInfoMessage(player, "=== " .. factionName .. " ===")
        waveCore:sendPlayerMessage(player, "Leader: " .. leader)
        waveCore:sendPlayerMessage(player, "Members: " .. #members)
    end, "View " .. factionName .. " information")
end
```

---

## 🔐 Security Configuration

### 1. Restrict Admin Commands by IP

```lua
local waveCore = exports.wave_core
local allowedIPs = {"127.0.0.1", "192.168.1.100"}

waveCore:addCoreCommand("sensitivecmd", "admin.manage_players", function(player, args)
    local ip = getPlayerIP(player)
    local isAllowed = false
    
    for _, allowedIP in ipairs(allowedIPs) do
        if ip == allowedIP then
            isAllowed = true
            break
        end
    end
    
    if not isAllowed then
        waveCore:logActionDB(getElementData(player, "player:id"), "unauthorized_access", 
                            "Attempted access from " .. ip)
        return
    end
    
    -- Execute command
end, "Sensitive command")
```

### 2. Rate Limiting Commands

```lua
local waveCore = exports.wave_core
local lastCommandTime = {}
local commandCooldown = 5 -- seconds

waveCore:addCoreCommand("specialcmd", "basic.chat", function(player, args)
    local playerID = getElementData(player, "player:id")
    local currentTime = getCurrentTimestamp()
    
    if lastCommandTime[playerID] and (currentTime - lastCommandTime[playerID]) < commandCooldown then
        waveCore:sendErrorMessage(player, "Please wait before using this command again")
        return
    end
    
    lastCommandTime[playerID] = currentTime
    -- Execute command
end, "Special command with cooldown")
```

---

## 📊 Monitoring & Analytics

### 1. Player Activity Dashboard

```lua
local waveCore = exports.wave_core

local function getServerStats()
    local players = waveCore:getOnlinePlayers()
    local groups = {}
    
    for _, player in ipairs(players) do
        local group = waveCore:getPlayerGroup(player)
        groups[group] = (groups[group] or 0) + 1
    end
    
    return {
        totalPlayers = #players,
        vipPlayers = #waveCore:getVIPPlayersOnline(),
        donatorPlayers = #waveCore:getDonatorPlayersOnline(),
        groupStats = groups
    }
end
```

---

These examples demonstrate common configuration patterns and usage scenarios.
For more details, see the main README.md file.
