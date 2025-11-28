-- Wave Romania Roleplay - Database Module
-- Handles all database operations for MariaDB/MySQL

-- Database connection pool
local db = nil
local dbConfig = {}

-- =====================================================
-- Database Initialization
-- =====================================================

--- Initialize database connection
-- @param config: database configuration table
-- @return boolean success
function initializeDatabase(config)
    dbConfig = config or {
        host = "localhost",
        port = 3306,
        username = "root",
        password = "password",
        database = "wave_roleplay"
    }
    
    -- Try to connect to the database
    local connectionString = string.format(
        "dbname=%s;host=%s;port=%s;user=%s;password=%s",
        dbConfig.database,
        dbConfig.host,
        dbConfig.port,
        dbConfig.username,
        dbConfig.password
    )
    
    print("[DATABASE] Attempting to connect to: " .. dbConfig.host .. ":" .. dbConfig.port)
    
    -- Using MTA's built-in database system
    if not mysql then
        print("[DATABASE] MySQL module not available, attempting to load...")
        return false
    end
    
    return true
end

-- =====================================================
-- Async Query Functions
-- =====================================================

--- Execute async query with callback
-- @param query: SQL query string
-- @param params: table of parameters for prepared statement
-- @param callback: callback function (err, result)
function dbQueryAsync(query, params, callback)
    if not mysql then
        if callback then
            callback("MySQL module not available", nil)
        end
        return
    end
    
    -- Prepare query with parameters
    local preparedQuery = query
    if params and #params > 0 then
        for i, param in ipairs(params) do
            local value = tostring(param)
            if type(param) == "string" then
                value = "'" .. mysql:escape(param) .. "'"
            elseif type(param) == "boolean" then
                value = param and "1" or "0"
            end
            preparedQuery = preparedQuery:gsub("?", value, 1)
        end
    end
    
    -- Execute async
    setTimer(function()
        local result = mysql:query(preparedQuery)
        if callback then
            if result then
                callback(nil, result)
            else
                callback("Query execution failed", nil)
            end
        end
    end, 0)
end

-- =====================================================
-- Sync Query Functions
-- =====================================================

--- Execute sync query
-- @param query: SQL query string
-- @param params: table of parameters for prepared statement
-- @return result table or nil
function dbExecSync(query, params)
    if not mysql then
        print("[DATABASE ERROR] MySQL module not available")
        return nil
    end
    
    -- Prepare query with parameters
    local preparedQuery = query
    if params and #params > 0 then
        for i, param in ipairs(params) do
            local value = tostring(param)
            if type(param) == "string" then
                value = "'" .. (mysql:escape(param) or "") .. "'"
            elseif type(param) == "boolean" then
                value = param and "1" or "0"
            end
            preparedQuery = preparedQuery:gsub("?", value, 1)
        end
    end
    
    local result = mysql:query(preparedQuery)
    return result
end

-- =====================================================
-- Player Database Functions
-- =====================================================

--- Get player data from database
-- @param playerName: player username
-- @return player data table or nil
function getPlayerData(playerName)
    local query = "SELECT * FROM players WHERE username = ?"
    local result = dbExecSync(query, {playerName})
    
    if result and #result > 0 then
        return result[1]
    end
    return nil
end

--- Create new player record
-- @param playerName: player username
-- @param passwordHash: hashed password
-- @param playerIP: player IP address
-- @return success boolean
function createPlayerRecord(playerName, passwordHash, playerIP)
    local query = "INSERT INTO players (username, password_hash, last_ip) VALUES (?, ?, ?)"
    local result = dbExecSync(query, {playerName, passwordHash, playerIP})
    return result ~= nil
end

--- Update player last login
-- @param playerID: player database ID
-- @param playerIP: player IP address
-- @return success boolean
function updatePlayerLastLogin(playerID, playerIP)
    local query = "UPDATE players SET last_ip = ?, last_login = CURRENT_TIMESTAMP WHERE id = ?"
    local result = dbExecSync(query, {playerIP, playerID})
    return result ~= nil
end

--- Get player group
-- @param playerID: player database ID
-- @return group name or nil
function getPlayerGroupDB(playerID)
    local query = "SELECT group_name FROM player_groups WHERE player_id = ?"
    local result = dbExecSync(query, {playerID})
    
    if result and #result > 0 then
        return result[1].group_name
    end
    return nil
end

--- Set player group
-- @param playerID: player database ID
-- @param groupName: group name
-- @return success boolean
function setPlayerGroupDB(playerID, groupName)
    -- Remove existing group
    local delQuery = "DELETE FROM player_groups WHERE player_id = ?"
    dbExecSync(delQuery, {playerID})
    
    -- Insert new group
    local query = "INSERT INTO player_groups (player_id, group_name) VALUES (?, ?)"
    local result = dbExecSync(query, {playerID, groupName})
    return result ~= nil
end

-- =====================================================
-- Priority Database Functions
-- =====================================================

--- Get player priority
-- @param playerID: player database ID
-- @return priority level (1-100) or nil
function getPlayerPriorityDB(playerID)
    local query = "SELECT priority_level FROM player_priority WHERE player_id = ?"
    local result = dbExecSync(query, {playerID})
    
    if result and #result > 0 then
        return result[1].priority_level
    end
    return 1
end

--- Set player priority
-- @param playerID: player database ID
-- @param priority: priority level (1-100)
-- @return success boolean
function setPlayerPriorityDB(playerID, priority)
    priority = math.max(1, math.min(100, priority))
    
    local query = "INSERT INTO player_priority (player_id, priority_level) VALUES (?, ?) ON DUPLICATE KEY UPDATE priority_level = ?"
    local result = dbExecSync(query, {playerID, priority, priority})
    return result ~= nil
end

-- =====================================================
-- Permission Database Functions
-- =====================================================

--- Get player permissions
-- @param playerID: player database ID
-- @return table of permissions or empty table
function getPlayerPermissionsDB(playerID)
    local query = "SELECT permission FROM player_permissions WHERE player_id = ?"
    local result = dbExecSync(query, {playerID})
    
    local permissions = {}
    if result then
        for _, row in ipairs(result) do
            table.insert(permissions, row.permission)
        end
    end
    return permissions
end

--- Add player permission
-- @param playerID: player database ID
-- @param permission: permission string
-- @return success boolean
function addPlayerPermissionDB(playerID, permission)
    local query = "INSERT INTO player_permissions (player_id, permission) VALUES (?, ?)"
    local result = dbExecSync(query, {playerID, permission})
    return result ~= nil
end

--- Remove player permission
-- @param playerID: player database ID
-- @param permission: permission string
-- @return success boolean
function removePlayerPermissionDB(playerID, permission)
    local query = "DELETE FROM player_permissions WHERE player_id = ? AND permission = ?"
    local result = dbExecSync(query, {playerID, permission})
    return result ~= nil
end

-- =====================================================
-- Faction Database Functions
-- =====================================================

--- Get faction data
-- @param factionName: faction name
-- @return faction data table or nil
function getFactionDataDB(factionName)
    local query = "SELECT * FROM factions WHERE name = ?"
    local result = dbExecSync(query, {factionName})
    
    if result and #result > 0 then
        return result[1]
    end
    return nil
end

--- Get faction members
-- @param factionID: faction database ID
-- @return table of members or empty table
function getFactionMembersDB(factionID)
    local query = "SELECT p.id, p.username, fm.rank FROM faction_members fm JOIN players p ON fm.player_id = p.id WHERE fm.faction_id = ?"
    local result = dbExecSync(query, {factionID})
    
    return result or {}
end

--- Add faction member
-- @param factionID: faction database ID
-- @param playerID: player database ID
-- @param rank: member rank
-- @return success boolean
function addFactionMemberDB(factionID, playerID, rank)
    rank = rank or "Member"
    local query = "INSERT INTO faction_members (faction_id, player_id, rank) VALUES (?, ?, ?)"
    local result = dbExecSync(query, {factionID, playerID, rank})
    return result ~= nil
end

--- Remove faction member
-- @param factionID: faction database ID
-- @param playerID: player database ID
-- @return success boolean
function removeFactionMemberDB(factionID, playerID)
    local query = "DELETE FROM faction_members WHERE faction_id = ? AND player_id = ?"
    local result = dbExecSync(query, {factionID, playerID})
    return result ~= nil
end

-- =====================================================
-- VIP Database Functions
-- =====================================================

--- Check if player is VIP
-- @param playerID: player database ID
-- @return boolean
function isPlayerVIPDB(playerID)
    local query = "SELECT is_vip FROM player_vip WHERE player_id = ?"
    local result = dbExecSync(query, {playerID})
    
    if result and #result > 0 then
        return result[1].is_vip == 1
    end
    return false
end

--- Set player VIP status
-- @param playerID: player database ID
-- @param isVIP: boolean
-- @param expiryDate: expiry date string (optional)
-- @return success boolean
function setPlayerVIPDB(playerID, isVIP, expiryDate)
    expiryDate = expiryDate or nil
    
    local query = "INSERT INTO player_vip (player_id, is_vip, vip_expire_date) VALUES (?, ?, ?) ON DUPLICATE KEY UPDATE is_vip = ?, vip_expire_date = ?"
    local result = dbExecSync(query, {playerID, isVIP and 1 or 0, expiryDate, isVIP and 1 or 0, expiryDate})
    return result ~= nil
end

-- =====================================================
-- Donator Database Functions
-- =====================================================

--- Check if player is donator
-- @param playerID: player database ID
-- @return boolean
function isPlayerDonatorDB(playerID)
    local query = "SELECT is_donator FROM player_donator WHERE player_id = ?"
    local result = dbExecSync(query, {playerID})
    
    if result and #result > 0 then
        return result[1].is_donator == 1
    end
    return false
end

--- Set player donator status
-- @param playerID: player database ID
-- @param isDonator: boolean
-- @param tier: donator tier
-- @return success boolean
function setPlayerDonatorDB(playerID, isDonator, tier)
    tier = tier or "bronze"
    
    local query = "INSERT INTO player_donator (player_id, is_donator, donator_tier) VALUES (?, ?, ?) ON DUPLICATE KEY UPDATE is_donator = ?, donator_tier = ?"
    local result = dbExecSync(query, {playerID, isDonator and 1 or 0, tier, isDonator and 1 or 0, tier})
    return result ~= nil
end

-- =====================================================
-- Logging Functions
-- =====================================================

--- Log action to database
-- @param playerID: player database ID
-- @param action: action name
-- @param details: action details
-- @return success boolean
function logActionDB(playerID, action, details)
    local query = "INSERT INTO logs (player_id, action, details) VALUES (?, ?, ?)"
    local result = dbExecSync(query, {playerID, action, details})
    return result ~= nil
end

return true
