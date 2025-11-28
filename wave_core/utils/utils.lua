-- Wave Romania Roleplay - Utility Functions
-- Contains helper functions used across the system

-- =====================================================
-- Text and String Functions
-- =====================================================

--- Convert text to title case
-- @param str: string to convert
-- @return converted string
function titleCase(str)
    return str:gsub("(%a)([%w_']*)", function(first, rest)
        return first:upper() .. rest:lower()
    end)
end

--- Trim whitespace from string
-- @param str: string to trim
-- @return trimmed string
function trim(str)
    return str:match("^%s*(.-)%s*$")
end

--- Split string by delimiter
-- @param str: string to split
-- @param delimiter: delimiter character
-- @return table with split values
function splitString(str, delimiter)
    local result = {}
    local pattern = "([^" .. delimiter .. "]+)"
    for match in str:gmatch(pattern) do
        table.insert(result, match)
    end
    return result
end

-- =====================================================
-- Table Functions
-- =====================================================

--- Check if table contains value
-- @param tbl: table to search
-- @param value: value to find
-- @return boolean
function tableContains(tbl, value)
    for _, v in ipairs(tbl) do
        if v == value then
            return true
        end
    end
    return false
end

--- Count table elements
-- @param tbl: table to count
-- @return number of elements
function tableCount(tbl)
    local count = 0
    for _ in pairs(tbl) do
        count = count + 1
    end
    return count
end

--- Merge two tables
-- @param tbl1: first table
-- @param tbl2: second table
-- @return merged table
function tableMerge(tbl1, tbl2)
    local result = {}
    for k, v in pairs(tbl1) do
        result[k] = v
    end
    for k, v in pairs(tbl2) do
        result[k] = v
    end
    return result
end

-- =====================================================
-- Player Functions
-- =====================================================

--- Get player by name (partial matching)
-- @param partialName: partial or full player name
-- @return player element or nil
function getPlayerByPartialName(partialName)
    partialName = partialName:lower()
    local players = getElementsByType("player")
    
    for _, player in ipairs(players) do
        local playerName = getPlayerName(player):lower()
        if playerName:find(partialName, 1, true) then
            return player
        end
    end
    return nil
end

--- Get all online players
-- @return table of players
function getOnlinePlayers()
    return getElementsByType("player")
end

--- Check if player is online
-- @param playerName: name of player to check
-- @return player element or nil
function isPlayerOnline(playerName)
    local players = getElementsByType("player")
    for _, player in ipairs(players) do
        if getPlayerName(player) == playerName then
            return player
        end
    end
    return nil
end

-- =====================================================
-- Message Functions
-- =====================================================

--- Send chat message to player with color
-- @param player: player element
-- @param message: message text
-- @param r, g, b: RGB color values
function sendPlayerMessage(player, message, r, g, b)
    r = r or 255
    g = g or 255
    b = b or 255
    outputChatBox(message, player, r, g, b)
end

--- Send success message
-- @param player: player element
-- @param message: message text
function sendSuccessMessage(player, message)
    sendPlayerMessage(player, "[SUCCESS] " .. message, 0, 255, 0)
end

--- Send error message
-- @param player: player element
-- @param message: message text
function sendErrorMessage(player, message)
    sendPlayerMessage(player, "[ERROR] " .. message, 255, 0, 0)
end

--- Send info message
-- @param player: player element
-- @param message: message text
function sendInfoMessage(player, message)
    sendPlayerMessage(player, "[INFO] " .. message, 100, 149, 237)
end

--- Send warning message
-- @param player: player element
-- @param message: message text
function sendWarningMessage(player, message)
    sendPlayerMessage(player, "[WARNING] " .. message, 255, 165, 0)
end

--- Send message to all players
-- @param message: message text
-- @param r, g, b: RGB color values
function broadcastMessage(message, r, g, b)
    r = r or 255
    g = g or 255
    b = b or 255
    outputChatBox(message, getRootElement(), r, g, b)
end

-- =====================================================
-- Time Functions
-- =====================================================

--- Get current timestamp
-- @return unix timestamp
function getCurrentTimestamp()
    return os.time()
end

--- Format timestamp to readable date
-- @param timestamp: unix timestamp
-- @return formatted date string
function formatTimestamp(timestamp)
    return os.date("%Y-%m-%d %H:%M:%S", timestamp)
end

--- Check if timestamp has expired
-- @param expiryTime: expiry unix timestamp
-- @return boolean
function hasExpired(expiryTime)
    return getCurrentTimestamp() > expiryTime
end

--- Get time difference in seconds
-- @param timestamp1, timestamp2: unix timestamps
-- @return difference in seconds
function getTimeDifference(timestamp1, timestamp2)
    return math.abs(timestamp1 - timestamp2)
end

-- =====================================================
-- Logging Functions
-- =====================================================

--- Log to console with type
-- @param logType: type of log (INFO, WARNING, ERROR, DEBUG)
-- @param message: message to log
function logMessage(logType, message)
    local timestamp = formatTimestamp(getCurrentTimestamp())
    print("[" .. timestamp .. "] [" .. logType .. "] " .. message)
end

--- Log debug message (only if debug enabled)
-- @param message: message to log
function debugLog(message)
    if resourceRoot then
        local debugConfig = exports.wave_core:getConfigValue("server", "debug")
        if debugConfig then
            logMessage("DEBUG", message)
        end
    end
end

-- =====================================================
-- Validation Functions
-- =====================================================

--- Validate email format
-- @param email: email string to validate
-- @return boolean
function isValidEmail(email)
    return email:match("^[%w%.+%-]+@[%w%.%-]+%.%w+$") ~= nil
end

--- Check if string is numeric
-- @param str: string to check
-- @return boolean
function isNumeric(str)
    return tonumber(str) ~= nil
end

--- Validate player name format
-- @param name: player name to validate
-- @return boolean
function isValidPlayerName(name)
    return #name >= 3 and #name <= 20 and name:match("^[%w_]+$") ~= nil
end

-- =====================================================
-- Math Functions
-- =====================================================

--- Clamp value between min and max
-- @param value: value to clamp
-- @param min, max: min and max bounds
-- @return clamped value
function clamp(value, min, max)
    return math.max(min, math.min(max, value))
end

--- Round number to decimal places
-- @param value: number to round
-- @param decimals: number of decimal places
-- @return rounded number
function roundNumber(value, decimals)
    local multiplier = 10 ^ (decimals or 0)
    return math.floor(value * multiplier + 0.5) / multiplier
end

--- Get percentage
-- @param part: part value
-- @param whole: whole value
-- @return percentage
function getPercentage(part, whole)
    if whole == 0 then return 0 end
    return (part / whole) * 100
end

-- =====================================================
-- Distance/Position Functions
-- =====================================================

--- Calculate distance between two 3D positions
-- @param x1, y1, z1: first position
-- @param x2, y2, z2: second position
-- @return distance
function getDistance3D(x1, y1, z1, x2, y2, z2)
    return math.sqrt((x2 - x1) ^ 2 + (y2 - y1) ^ 2 + (z2 - z1) ^ 2)
end

--- Calculate distance between two 2D positions
-- @param x1, y1: first position
-- @param x2, y2: second position
-- @return distance
function getDistance2D(x1, y1, x2, y2)
    return math.sqrt((x2 - x1) ^ 2 + (y2 - y1) ^ 2)
end

return true
