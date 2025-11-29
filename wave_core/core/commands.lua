-- Wave Romania Roleplay - Commands Manager
-- Manages all core commands with permission checking

-- Command registry
local commands = {}

-- =====================================================
-- Command Registration
-- =====================================================

--- Add a core command
-- @param name: command name (without /)
-- @param permission: required permission (or table of permissions)
-- @param callback: callback function (player, arguments)
-- @param description: command description (optional)
-- @return boolean success
function addCoreCommand(name, permission, callback, description)
    if not name or not permission or not callback then
        print("[COMMANDS WARNING] Invalid command registration parameters")
        return false
    end
    
    commands[name] = {
        name = name,
        permission = permission,
        callback = callback,
        description = description or "No description available"
    }
    
    print("[COMMANDS] Registered command: /" .. name)
    return true
end

--- Get command info
-- @param name: command name
-- @return command info table or nil
function getCommandInfo(name)
    return commands[name]
end

--- Get all commands
-- @return table of commands
function getAllCommands()
    return commands
end

--- Remove command
-- @param name: command name
-- @return boolean success
function removeCommand(name)
    if commands[name] then
        commands[name] = nil
        return true
    end
    return false
end

-- =====================================================
-- Command Execution
-- =====================================================

--- Execute a core command
-- @param player: player element
-- @param commandName: command name without /
-- @param ...: arguments
-- @return boolean success
function executeCoreCommand(player, commandName, ...)
    if not isElement(player) or getElementType(player) ~= "player" then
        return false
    end
    
    local cmd = commands[commandName]
    if not cmd then
        sendErrorMessage(player, "Unknown command. Type /help for available commands.")
        return false
    end
    
    -- Check permission
    if not hasPermission(player, cmd.permission) then
        sendErrorMessage(player, "You don't have permission to use this command.")
        logActionDB(getElementData(player, "player:id"), "command_denied", 
                   "Command: " .. commandName .. " - Insufficient permissions")
        return false
    end
    
    -- Execute callback
    local args = {...}
    local success, errorMsg = pcall(function()
        cmd.callback(player, args)
    end)
    
    if not success then
        print("[COMMANDS ERROR] Error executing command /" .. commandName .. ": " .. tostring(errorMsg))
        sendErrorMessage(player, "An error occurred while executing the command.")
        return false
    end
    
    -- Log command execution
    logActionDB(getElementData(player, "player:id"), "command_executed", 
               "Command: /" .. commandName .. " Args: " .. table.concat(args, ", "))
    
    return true
end

-- =====================================================
-- Built-in Commands
-- =====================================================

--- Register default commands
function registerDefaultCommands()
    -- Help command
    addCoreCommand("help", "basic.chat", function(player, args)
        local page = tonumber(args[1]) or 1
        local commandList = getAllCommands()
        local availableCommands = {}
        
        -- Filter commands by permission
        for name, cmd in pairs(commandList) do
            if hasPermission(player, cmd.permission) then
                table.insert(availableCommands, cmd)
            end
        end
        
        -- Display help
        sendInfoMessage(player, "=== Available Commands (Page " .. page .. ") ===")
        for i, cmd in ipairs(availableCommands) do
            if i > (page - 1) * 10 and i <= page * 10 then
                sendPlayerMessage(player, "  /" .. cmd.name .. " - " .. cmd.description)
            end
        end
    end, "View available commands")
    
    -- Whoami command
    addCoreCommand("whoami", "basic.chat", function(player, args)
        local playerID = getElementData(player, "player:id")
        local group = getPlayerGroup(player)
        local priority = getPlayerPriority(player)
        
        sendInfoMessage(player, "Your Info:")
        sendPlayerMessage(player, "  Name: " .. getPlayerName(player))
        sendPlayerMessage(player, "  ID: " .. playerID)
        sendPlayerMessage(player, "  Group: " .. group)
        sendPlayerMessage(player, "  Priority: " .. priority)
    end, "View your information")
    
    -- Admin: Setgroup command
    addCoreCommand("setgroup", "admin.manage_groups", function(player, args)
        if #args < 2 then
            sendErrorMessage(player, "Usage: /setgroup [player_name] [group_name]")
            return
        end
        
        local targetName = args[1]
        local groupName = args[2]
        local target = getPlayerByPartialName(targetName)
        
        if not target then
            sendErrorMessage(player, "Player not found.")
            return
        end
        
        if not isGroupExists(groupName) then
            sendErrorMessage(player, "Group does not exist.")
            return
        end
        
        if setPlayerGroup(target, groupName) then
            sendSuccessMessage(player, "Set " .. getPlayerName(target) .. " group to " .. groupName)
            sendSuccessMessage(target, "Your group has been changed to " .. groupName)
        else
            sendErrorMessage(player, "Failed to set player group.")
        end
    end, "Set player's group")
    
    -- Admin: Giveperm command
    addCoreCommand("giveperm", "admin.manage_commands", function(player, args)
        if #args < 2 then
            sendErrorMessage(player, "Usage: /giveperm [player_name] [permission]")
            return
        end
        
        local targetName = args[1]
        local permission = args[2]
        local target = getPlayerByPartialName(targetName)
        
        if not target then
            sendErrorMessage(player, "Player not found.")
            return
        end
        
        if addPlayerPermission(target, permission) then
            sendSuccessMessage(player, "Gave " .. getPlayerName(target) .. " permission: " .. permission)
        else
            sendErrorMessage(player, "Failed to give permission.")
        end
    end, "Give player a permission")
    
    -- Admin: Removeperm command
    addCoreCommand("removeperm", "admin.manage_commands", function(player, args)
        if #args < 2 then
            sendErrorMessage(player, "Usage: /removeperm [player_name] [permission]")
            return
        end
        
        local targetName = args[1]
        local permission = args[2]
        local target = getPlayerByPartialName(targetName)
        
        if not target then
            sendErrorMessage(player, "Player not found.")
            return
        end
        
        if removePlayerPermission(target, permission) then
            sendSuccessMessage(player, "Removed permission from " .. getPlayerName(target) .. ": " .. permission)
        else
            sendErrorMessage(player, "Failed to remove permission.")
        end
    end, "Remove player's permission")
    
    -- Admin: Priority command
    addCoreCommand("setpriority", "admin.manage_players", function(player, args)
        if #args < 2 then
            sendErrorMessage(player, "Usage: /setpriority [player_name] [priority (1-100)]")
            return
        end
        
        local targetName = args[1]
        local priority = tonumber(args[2])
        local target = getPlayerByPartialName(targetName)
        
        if not target then
            sendErrorMessage(player, "Player not found.")
            return
        end
        
        if not priority or priority < 1 or priority > 100 then
            sendErrorMessage(player, "Priority must be between 1 and 100.")
            return
        end
        
        if setPlayerPriority(target, priority) then
            sendSuccessMessage(player, "Set " .. getPlayerName(target) .. " priority to " .. priority)
        else
            sendErrorMessage(player, "Failed to set priority.")
        end
    end, "Set player's priority")
    
    -- List players command
    addCoreCommand("players", "basic.chat", function(player, args)
        local players = getOnlinePlayers()
        sendInfoMessage(player, "=== Online Players (" .. #players .. ") ===")
        
        for _, p in ipairs(players) do
            local group = getPlayerGroup(p)
            sendPlayerMessage(player, getPlayerName(p) .. " [ID: " .. getElementData(p, "player:id") .. "] [Group: " .. group .. "]")
        end
    end, "List all online players")
    
    -- =====================================================
    -- Admin Commands
    -- =====================================================
    
    -- Admin: Spawn vehicle command
    addCoreCommand("veh", "admin.manage_players", function(player, args)
        if #args < 1 then
            sendErrorMessage(player, "Usage: /veh [vehicle_name_or_id]")
            return
        end
        
        local vehicleModel = args[1]
        local modelID = tonumber(vehicleModel)
        
        -- If string, try to get model ID from name
        if not modelID then
            modelID = getVehicleModelFromName(vehicleModel)
        end
        
        if not modelID or modelID < 400 or modelID > 611 then
            sendErrorMessage(player, "Invalid vehicle model.")
            return
        end
        
        -- Get player position slightly ahead
        local px, py, pz = getElementPosition(player)
        local rotation = getPedRotation(player)
        
        -- Spawn vehicle
        local veh = createVehicle(modelID, px + 5, py, pz + 1)
        
        if veh then
            warpPlayerIntoVehicle(player, veh)
            sendSuccessMessage(player, "Vehicle spawned successfully!")
        else
            sendErrorMessage(player, "Failed to spawn vehicle.")
        end
    end, "Spawn a vehicle")
    
    -- Admin: Noclip command
    addCoreCommand("noclip", "admin.manage_players", function(player, args)
        local noclipStatus = getElementData(player, "player:noclip") or false
        noclipStatus = not noclipStatus
        
        setElementData(player, "player:noclip", noclipStatus)
        
        if noclipStatus then
            sendSuccessMessage(player, "Noclip: ON")
            -- Freeze player to prevent fall damage
            setElementFrozen(player, true)
        else
            sendSuccessMessage(player, "Noclip: OFF")
            setElementFrozen(player, false)
        end
    end, "Toggle noclip mode")
    
    -- Admin: Noclip shortcut command
    addCoreCommand("nc", "admin.manage_players", function(player, args)
        executeCoreCommand(player, "noclip")
    end, "Toggle noclip mode (shortcut)")
    
    -- Admin: Admin duty ON
    addCoreCommand("aduty", "admin.manage_players", function(player, args)
        local onDuty = getElementData(player, "player:admin_duty") or false
        
        if onDuty then
            sendInfoMessage(player, "You are already on admin duty.")
            return
        end
        
        setElementData(player, "player:admin_duty", true)
        
        -- Grant all admin permissions
        local adminPerms = {
            "admin.spawn_vehicle",
            "admin.noclip",
            "admin.duty",
            "admin.manage_players",
            "admin.manage_groups",
            "admin.manage_commands",
            "admin.revive_players",
            "admin.check_players"
        }
        
        for _, perm in ipairs(adminPerms) do
            addPlayerPermission(player, perm)
        end
        
        -- Notify in chat
        sendSuccessMessage(player, "You are now ON ADMIN DUTY - Full admin permissions granted!")
        print("[ADMIN] " .. getPlayerName(player) .. " is now ON ADMIN DUTY")
    end, "Go on admin duty (unlock all admin commands)")
    
    -- Admin: Admin duty OFF
    addCoreCommand("adutyoff", "admin.manage_players", function(player, args)
        local onDuty = getElementData(player, "player:admin_duty") or false
        
        if not onDuty then
            sendInfoMessage(player, "You are not on admin duty.")
            return
        end
        
        setElementData(player, "player:admin_duty", false)
        
        sendSuccessMessage(player, "You are now OFF ADMIN DUTY - Admin permissions restricted.")
        print("[ADMIN] " .. getPlayerName(player) .. " is now OFF ADMIN DUTY")
    end, "Go off admin duty (restrict admin commands)")
    
    -- Admin: Revive player command
    addCoreCommand("revive", "admin.manage_players", function(player, args)
        if #args < 1 then
            sendErrorMessage(player, "Usage: /revive [player_id]")
            return
        end
        
        local targetID = tonumber(args[1])
        if not targetID then
            sendErrorMessage(player, "Invalid player ID.")
            return
        end
        
        local target = getPlayerFromID(targetID)
        if not target then
            sendErrorMessage(player, "Player not found.")
            return
        end
        
        -- Revive player
        spawnPlayer(target, 0, 0, 3)
        
        sendSuccessMessage(player, "Revived " .. getPlayerName(target))
        sendInfoMessage(target, "You have been revived by an admin!")
    end, "Revive a dead player")
    
    -- Admin: Get player ID by name
    addCoreCommand("id", "admin.manage_players", function(player, args)
        if #args < 1 then
            sendErrorMessage(player, "Usage: /id [player_name]")
            return
        end
        
        local targetName = args[1]
        local target = getPlayerByPartialName(targetName)
        
        if not target then
            sendErrorMessage(player, "Player not found.")
            return
        end
        
        local targetID = getElementData(target, "player:id") or "Unknown"
        local group = getPlayerGroup(target) or "user"
        local faction = exports.wave_core:getPlayerFaction(target) or "None"
        
        sendInfoMessage(player, "=== Player Info ===")
        sendPlayerMessage(player, "Name: " .. getPlayerName(target))
        sendPlayerMessage(player, "ID: " .. targetID)
        sendPlayerMessage(player, "Group: " .. group)
        sendPlayerMessage(player, "Faction: " .. faction)
    end, "Check player ID and info by name")
    
    print("[COMMANDS] Default commands registered successfully")
end

-- =====================================================
-- Helper Functions
-- =====================================================

--- Get player from element data ID
function getPlayerFromID(id)
    for _, player in ipairs(getElementsByType("player")) do
        if getElementData(player, "player:id") == id then
            return player
        end
    end
    return nil
end

--- Get vehicle model from name
function getVehicleModelFromName(name)
    local models = {
        ["blista"] = 496, ["baller"] = 525, ["buffalo"] = 402, ["cabbie"] = 438,
        ["cadrona"] = 484, ["car"] = 400, ["cheetah"] = 415, ["clipper"] = 446,
        ["comet"] = 480, ["dodo"] = 417, ["esperanto"] = 419, ["futo"] = 542,
        ["glendale"] = 475, ["gta"] = 434, ["hermes"] = 545, ["hotdog"] = 588,
        ["hydra"] = 520, ["infernus"] = 411, ["intruder"] = 546, ["jester"] = 559,
        ["kart"] = 571, ["landstalker"] = 400, ["manana"] = 427, ["marquis"] = 533,
        ["matrix"] = 555, ["patriot"] = 527, ["phoenix"] = 412, ["sabregt"] = 475,
        ["sadler"] = 543, ["sanchez"] = 468, ["savanna"] = 567, ["sentinel"] = 405,
        ["solair"] = 458, ["stafford"] = 580, ["sultanrs"] = 522, ["super"] = 588,
        ["taxi"] = 438, ["uranus"] = 558, ["vincent"] = 540, ["virgo"] = 491,
        ["walton"] = 478, ["wayfarer"] = 586, ["zr350"] = 551, ["hex"] = 534
    }
    
    -- If number, return it
    if tonumber(name) then
        return tonumber(name)
    end
    
    -- Lowercase search
    local searchName = name:lower()
    return models[searchName] or nil
end

-- =====================================================
-- Event Handlers
-- =====================================================

--- Handle command execution
addEventHandler("onPlayerCommand", getRootElement(), function(commandName, args)
    local argsArray = splitString(args, " ")
    
    if executeCoreCommand(source, commandName, unpack(argsArray)) then
        cancelEvent()
    end
end)

return true
