-- Wave Romania Roleplay - Factions Module
-- Manages factions and faction-based permissions

-- Faction cache
local factions = {}
local playerFactions = {}

-- =====================================================
-- Factions Initialization
-- =====================================================

--- Initialize factions system
-- @return boolean success
function initializeFactions()
    print("[FACTIONS] Initializing factions system...")
    loadFactionsFromConfig()
    return true
end

--- Load factions from config
function loadFactionsFromConfig()
    local config = exports.wave_core:getConfig()
    
    if config and config.factions then
        for _, faction in ipairs(config.factions) do
            local factionName = faction:getAttribute("name")
            local factionID = tonumber(faction:getAttribute("id")) or 0
            local color = faction:getAttribute("color") or "#FFFFFF"
            
            factions[factionName] = {
                id = factionID,
                name = factionName,
                color = color,
                leader = faction:getElementsByTagName("leader")[1] and faction:getElementsByTagName("leader")[1]:getValue() or "Unknown",
                maxMembers = tonumber(faction:getAttribute("maxmembers")) or 50,
                permissions = {},
                members = {}
            }
            
            -- Load faction permissions
            for _, perm in ipairs(faction:getElementsByTagName("permission")) do
                table.insert(factions[factionName].permissions, perm:getValue())
            end
        end
    end
end

-- =====================================================
-- Faction Management Functions
-- =====================================================

--- Add new faction
-- @param name: faction name
-- @param factionID: faction ID
-- @param permissions: table of permissions
-- @return boolean success
function addFaction(name, factionID, permissions)
    if factions[name] then
        print("[FACTIONS WARNING] Faction already exists: " .. name)
        return false
    end
    
    factions[name] = {
        id = factionID or #factions + 1,
        name = name,
        color = "#FFFFFF",
        leader = "Unknown",
        maxMembers = 50,
        permissions = permissions or {},
        members = {}
    }
    
    -- Save to database
    local query = "INSERT INTO factions (name, faction_id, max_members) VALUES (?, ?, ?)"
    local result = dbExecSync(query, {name, factions[name].id, 50})
    
    if result then
        print("[FACTIONS] Faction created: " .. name)
        return true
    end
    
    return false
end

--- Get faction data
-- @param factionName: faction name
-- @return faction table or nil
function getFaction(factionName)
    return factions[factionName]
end

--- Get all factions
-- @return table of factions
function getAllFactions()
    return factions
end

--- Delete faction
-- @param factionName: faction name
-- @return boolean success
function deleteFaction(factionName)
    if not factions[factionName] then
        return false
    end
    
    local factionID = factions[factionName].id
    
    -- Delete from database
    local query = "DELETE FROM factions WHERE faction_id = ?"
    local result = dbExecSync(query, {factionID})
    
    if result then
        factions[factionName] = nil
        return true
    end
    
    return false
end

-- =====================================================
-- Faction Member Management
-- =====================================================

--- Get player's faction
-- @param player: player element
-- @return faction name or nil
function getPlayerFaction(player)
    if not isElement(player) or getElementType(player) ~= "player" then
        return nil
    end
    
    local playerID = getElementData(player, "player:id")
    if playerID and playerFactions[playerID] then
        return playerFactions[playerID]
    end
    
    return nil
end

--- Get faction members
-- @param factionName: faction name
-- @return table of members or empty table
function getFactionMembers(factionName)
    local faction = factions[factionName]
    if not faction then
        return {}
    end
    
    local factionID = faction.id
    local members = getFactionMembersDB(factionID)
    
    return members
end

--- Assign player to faction
-- @param player: player element
-- @param factionName: faction name
-- @param rank: member rank (optional)
-- @return boolean success
function assignFactionMember(player, factionName, rank)
    if not isElement(player) or getElementType(player) ~= "player" then
        return false
    end
    
    local faction = factions[factionName]
    if not faction then
        print("[FACTIONS WARNING] Faction not found: " .. factionName)
        return false
    end
    
    local playerID = getElementData(player, "player:id")
    if not playerID then
        return false
    end
    
    rank = rank or "Member"
    
    -- Remove from previous faction if any
    local currentFaction = getPlayerFaction(player)
    if currentFaction then
        removeFactionMember(player, currentFaction)
    end
    
    -- Add to new faction
    local success = addFactionMemberDB(faction.id, playerID, rank)
    
    if success then
        playerFactions[playerID] = factionName
        setElementData(player, "player:faction", factionName)
        setElementData(player, "player:faction_rank", rank)
        
        -- Grant faction permissions
        for _, perm in ipairs(faction.permissions) do
            addPlayerPermission(player, perm)
        end
    end
    
    return success
end

--- Remove player from faction
-- @param player: player element
-- @param factionName: faction name (optional)
-- @return boolean success
function removeFactionMember(player, factionName)
    if not isElement(player) or getElementType(player) ~= "player" then
        return false
    end
    
    local playerID = getElementData(player, "player:id")
    if not playerID then
        return false
    end
    
    -- Determine faction to remove from
    factionName = factionName or getPlayerFaction(player)
    if not factionName then
        return false
    end
    
    local faction = factions[factionName]
    if not faction then
        return false
    end
    
    -- Remove from database
    local success = removeFactionMemberDB(faction.id, playerID)
    
    if success then
        playerFactions[playerID] = nil
        setElementData(player, "player:faction", nil)
        setElementData(player, "player:faction_rank", nil)
        
        -- Remove faction permissions
        for _, perm in ipairs(faction.permissions) do
            removePlayerPermission(player, perm)
        end
    end
    
    return success
end

--- Check if player is in faction
-- @param player: player element
-- @param factionName: faction name
-- @return boolean
function isPlayerInFaction(player, factionName)
    local playerFaction = getPlayerFaction(player)
    return playerFaction == factionName
end

--- Get faction member count
-- @param factionName: faction name
-- @return number of members
function getFactionMemberCount(factionName)
    local members = getFactionMembers(factionName)
    return #members
end

-- =====================================================
-- Faction Permissions
-- =====================================================

--- Get faction permissions
-- @param factionName: faction name
-- @return table of permissions
function getFactionPermissions(factionName)
    local faction = factions[factionName]
    if faction then
        return faction.permissions
    end
    return {}
end

--- Add permission to faction
-- @param factionName: faction name
-- @param permission: permission string
-- @return boolean success
function addFactionPermission(factionName, permission)
    local faction = factions[factionName]
    if not faction then
        return false
    end
    
    table.insert(faction.permissions, permission)
    
    -- Update faction members with new permission
    local members = getFactionMembers(factionName)
    for _, member in ipairs(members) do
        local player = isPlayerOnline(member.username)
        if player then
            addPlayerPermission(player, permission)
        end
    end
    
    return true
end

--- Check if faction has permission
-- @param factionName: faction name
-- @param permission: permission string
-- @return boolean
function factionHasPermission(factionName, permission)
    local permissions = getFactionPermissions(factionName)
    return tableContains(permissions, permission)
end

-- =====================================================
-- Faction Leadership
-- =====================================================

--- Set faction leader
-- @param factionName: faction name
-- @param player: player element (or nil to remove)
-- @return boolean success
function setFactionLeader(factionName, player)
    local faction = factions[factionName]
    if not faction then
        return false
    end
    
    if player then
        if not isPlayerInFaction(player, factionName) then
            return false
        end
        
        faction.leader = getPlayerName(player)
        
        -- Update database
        local playerID = getElementData(player, "player:id")
        local query = "UPDATE factions SET leader_id = ? WHERE name = ?"
        dbExecSync(query, {playerID, factionName})
    else
        faction.leader = "Unknown"
        local query = "UPDATE factions SET leader_id = NULL WHERE name = ?"
        dbExecSync(query, {factionName})
    end
    
    return true
end

--- Get faction leader
-- @param factionName: faction name
-- @return leader name or "Unknown"
function getFactionLeader(factionName)
    local faction = factions[factionName]
    if faction then
        return faction.leader
    end
    return "Unknown"
end

-- =====================================================
-- Faction Events
-- =====================================================

--- Trigger event for faction members
-- @param factionName: faction name
-- @param eventName: event name
-- @param ...: event arguments
function triggerFactionEvent(factionName, eventName, ...)
    local members = getFactionMembers(factionName)
    
    for _, member in ipairs(members) do
        local player = isPlayerOnline(member.username)
        if player then
            triggerEvent(eventName, player, ...)
        end
    end
end

return true
