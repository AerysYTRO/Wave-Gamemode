-- Wave Romania Roleplay - Groups Module
-- Manages player groups and group-based permissions

-- Group cache
local playerGroups = {}
local groupConfig = {}

-- =====================================================
-- Groups Initialization
-- =====================================================

--- Initialize groups system
-- @return boolean success
function initializeGroups()
    print("[GROUPS] Initializing groups system...")
    groupConfig = loadGroupPermissions() or {}
    return true
end

--- Load groups from config
-- @return groups table
function loadGroupConfig()
    local config = exports.wave_core:getConfig()
    local groups = {}
    
    if config and config.groups then
        for _, group in ipairs(config.groups) do
            local groupName = group:getAttribute("name")
            local priority = tonumber(group:getAttribute("priority")) or 1
            
            groups[groupName] = {
                name = groupName,
                priority = priority,
                permissions = {}
            }
            
            for _, perm in ipairs(group:getElementsByTagName("permission")) do
                local permName = perm:getValue()
                table.insert(groups[groupName].permissions, permName)
            end
        end
    end
    
    return groups
end

-- =====================================================
-- Group Management Functions
-- =====================================================

--- Get player's group
-- @param player: player element
-- @return group name or "user" (default)
function getPlayerGroup(player)
    if not isElement(player) or getElementType(player) ~= "player" then
        return "user"
    end
    
    -- Check cache first
    local playerID = getElementData(player, "player:id")
    if playerID and playerGroups[playerID] then
        return playerGroups[playerID]
    end
    
    -- Try to get from database
    if playerID then
        local group = getPlayerGroupDB(playerID)
        if group then
            playerGroups[playerID] = group
            setElementData(player, "player:group", group)
            return group
        end
    end
    
    return "user"
end

--- Set player's group
-- @param player: player element
-- @param groupName: group name to set
-- @return boolean success
function setPlayerGroup(player, groupName)
    if not isElement(player) or getElementType(player) ~= "player" then
        return false
    end
    
    -- Validate group exists
    if not isGroupExists(groupName) then
        print("[GROUPS WARNING] Attempt to set invalid group: " .. groupName)
        return false
    end
    
    local playerID = getElementData(player, "player:id")
    if not playerID then
        return false
    end
    
    -- Save to database
    local success = setPlayerGroupDB(playerID, groupName)
    
    if success then
        -- Update cache
        playerGroups[playerID] = groupName
        -- Update element data
        setElementData(player, "player:group", groupName)
        -- Clear permission cache to reload
        clearPermissionCache(player)
    end
    
    return success
end

--- Check if group exists
-- @param groupName: group name to check
-- @return boolean
function isGroupExists(groupName)
    local config = loadGroupConfig()
    return config[groupName] ~= nil
end

--- Get group info
-- @param groupName: group name
-- @return group info table or nil
function getGroupInfo(groupName)
    local config = loadGroupConfig()
    return config[groupName]
end

--- Get all available groups
-- @return table of group names
function getAllGroups()
    local config = loadGroupConfig()
    local groups = {}
    
    for groupName, _ in pairs(config) do
        table.insert(groups, groupName)
    end
    
    return groups
end

-- =====================================================
-- Group Permission Functions
-- =====================================================

--- Get group permissions
-- @param groupName: group name
-- @return table of permissions
function getGroupPermissions(groupName)
    local config = loadGroupConfig()
    if config[groupName] then
        return config[groupName].permissions
    end
    return {}
end

--- Check if group has permission
-- @param groupName: group name
-- @param permission: permission string
-- @return boolean
function groupHasPermission(groupName, permission)
    local permissions = getGroupPermissions(groupName)
    return tableContains(permissions, permission) or tableContains(permissions, "*")
end

--- Get group priority
-- @param groupName: group name
-- @return priority level
function getGroupPriority(groupName)
    local config = loadGroupConfig()
    if config[groupName] then
        return config[groupName].priority
    end
    return 1
end

-- =====================================================
-- Bulk Operations
-- =====================================================

--- Get all players in group
-- @param groupName: group name
-- @return table of players
function getPlayersInGroup(groupName)
    local players = getElementsByType("player")
    local groupPlayers = {}
    
    for _, player in ipairs(players) do
        if getPlayerGroup(player) == groupName then
            table.insert(groupPlayers, player)
        end
    end
    
    return groupPlayers
end

--- Count players in group
-- @param groupName: group name
-- @return number of players
function countPlayersInGroup(groupName)
    return #getPlayersInGroup(groupName)
end

--- Set group for multiple players
-- @param players: table of player elements
-- @param groupName: group name
-- @return number of successful changes
function setGroupForPlayers(players, groupName)
    local count = 0
    
    for _, player in ipairs(players) do
        if setPlayerGroup(player, groupName) then
            count = count + 1
        end
    end
    
    return count
end

-- =====================================================
-- Group Ranking
-- =====================================================

--- Get highest group priority from player list
-- @param players: table of player elements
-- @return highest priority value
function getHighestGroupPriority(players)
    local highest = 1
    
    for _, player in ipairs(players) do
        local group = getPlayerGroup(player)
        local priority = getGroupPriority(group)
        if priority > highest then
            highest = priority
        end
    end
    
    return highest
end

--- Rank players by their group priority
-- @param players: table of player elements
-- @return sorted table of players (highest to lowest priority)
function rankPlayersByGroup(players)
    local ranked = {}
    
    for _, player in ipairs(players) do
        table.insert(ranked, player)
    end
    
    table.sort(ranked, function(a, b)
        local priorityA = getGroupPriority(getPlayerGroup(a))
        local priorityB = getGroupPriority(getPlayerGroup(b))
        return priorityA > priorityB
    end)
    
    return ranked
end

-- =====================================================
-- Group Caching
-- =====================================================

--- Clear group cache for player
-- @param player: player element
function clearGroupCache(player)
    local playerID = getElementData(player, "player:id")
    if playerID then
        playerGroups[playerID] = nil
    end
end

--- Clear all group caches
function clearAllGroupCaches()
    playerGroups = {}
end

-- =====================================================
-- Event Handlers
-- =====================================================

addEventHandler("onPlayerQuit", getRootElement(), function()
    clearGroupCache(source)
end)

return true
