-- Wave Romania Roleplay - Permissions Module
-- Manages player permissions and access control

-- Permission cache for performance
local playerPermissions = {}
local permissionCache = {}

-- =====================================================
-- Permission Initialization
-- =====================================================

--- Initialize permissions system
-- @return boolean success
function initializePermissions()
    print("[PERMISSIONS] Initializing permissions system...")
    return true
end

--- Load group permissions from config
-- @return permissions table
function loadGroupPermissions()
    local config = exports.wave_core:getConfig()
    local permissions = {}
    
    if config and config.groups then
        for _, group in ipairs(config.groups) do
            local groupName = group:getAttribute("name")
            permissions[groupName] = {}
            
            for _, perm in ipairs(group:getElementsByTagName("permission")) do
                local permName = perm:getValue()
                table.insert(permissions[groupName], permName)
            end
        end
    end
    
    return permissions
end

-- =====================================================
-- Permission Checking Functions
-- =====================================================

--- Check if player has permission
-- @param player: player element
-- @param permission: permission string to check
-- @return boolean
function hasPermission(player, permission)
    if not isElement(player) or getElementType(player) ~= "player" then
        return false
    end
    
    -- Check wildcard permission
    local playerPerms = getPlayerPermissions(player)
    if tableContains(playerPerms, "*") then
        return true
    end
    
    -- Check specific permission
    if tableContains(playerPerms, permission) then
        return true
    end
    
    -- Check permission group (e.g., "admin.all" contains "admin.kick")
    for _, playerPerm in ipairs(playerPerms) do
        if playerPerm:match("%.all$") then
            local prefix = playerPerm:gsub("%.all$", "")
            if permission:match("^" .. prefix .. "%.") then
                return true
            end
        end
    end
    
    return false
end

--- Check if player has any of multiple permissions
-- @param player: player element
-- @param permissions: table of permissions
-- @return boolean
function hasAnyPermission(player, permissions)
    for _, perm in ipairs(permissions) do
        if hasPermission(player, perm) then
            return true
        end
    end
    return false
end

--- Check if player has all permissions
-- @param player: player element
-- @param permissions: table of permissions
-- @return boolean
function hasAllPermissions(player, permissions)
    for _, perm in ipairs(permissions) do
        if not hasPermission(player, perm) then
            return false
        end
    end
    return true
end

-- =====================================================
-- Player Permission Management
-- =====================================================

--- Get all player permissions
-- @param player: player element
-- @return table of permissions
function getPlayerPermissions(player)
    if not isElement(player) or getElementType(player) ~= "player" then
        return {}
    end
    
    -- Check cache first
    local playerID = getElementData(player, "player:id")
    if playerID and playerPermissions[playerID] then
        return playerPermissions[playerID]
    end
    
    local permissions = {}
    
    -- Get permissions from player's group
    local group = getPlayerGroup(player)
    if group then
        local groupPerms = loadGroupPermissions()
        if groupPerms[group] then
            permissions = tableMerge(permissions, groupPerms[group]) or permissions
        end
    end
    
    -- Get custom player permissions from database (if needed)
    if playerID then
        local customPerms = getPlayerPermissionsDB(playerID) or {}
        permissions = tableMerge(permissions, customPerms) or permissions
        playerPermissions[playerID] = permissions
    end
    
    return permissions
end

--- Add permission to player
-- @param player: player element
-- @param permission: permission string
-- @return boolean
function addPlayerPermission(player, permission)
    if not isElement(player) or getElementType(player) ~= "player" then
        return false
    end
    
    local playerID = getElementData(player, "player:id")
    if not playerID then
        return false
    end
    
    -- Add to database
    local success = addPlayerPermissionDB(playerID, permission)
    
    if success then
        -- Update cache
        if playerPermissions[playerID] then
            table.insert(playerPermissions[playerID], permission)
        end
    end
    
    return success
end

--- Remove permission from player
-- @param player: player element
-- @param permission: permission string
-- @return boolean
function removePlayerPermission(player, permission)
    if not isElement(player) or getElementType(player) ~= "player" then
        return false
    end
    
    local playerID = getElementData(player, "player:id")
    if not playerID then
        return false
    end
    
    -- Remove from database
    local success = removePlayerPermissionDB(playerID, permission)
    
    if success then
        -- Update cache
        if playerPermissions[playerID] then
            for i, perm in ipairs(playerPermissions[playerID]) do
                if perm == permission then
                    table.remove(playerPermissions[playerID], i)
                    break
                end
            end
        end
    end
    
    return success
end

--- Clear all player permissions
-- @param player: player element
-- @return boolean
function clearPlayerPermissions(player)
    if not isElement(player) or getElementType(player) ~= "player" then
        return false
    end
    
    local playerID = getElementData(player, "player:id")
    if not playerID then
        return false
    end
    
    -- Clear from database
    local query = "DELETE FROM player_permissions WHERE player_id = ?"
    local success = dbExecSync(query, {playerID}) ~= nil
    
    if success then
        playerPermissions[playerID] = {}
    end
    
    return success
end

-- =====================================================
-- Permission Caching
-- =====================================================

--- Clear permission cache for player
-- @param player: player element
function clearPermissionCache(player)
    local playerID = getElementData(player, "player:id")
    if playerID then
        playerPermissions[playerID] = nil
    end
end

--- Clear all permission caches
function clearAllPermissionCaches()
    playerPermissions = {}
end

-- =====================================================
-- Event Handlers
-- =====================================================

addEventHandler("onPlayerQuit", getRootElement(), function()
    clearPermissionCache(source)
end)

return true
