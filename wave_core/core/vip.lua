-- Wave Romania Roleplay - VIP Module
-- Manages VIP status and benefits

-- VIP cache
local playerVIP = {}

-- =====================================================
-- VIP Initialization
-- =====================================================

--- Initialize VIP system
-- @return boolean success
function initializeVIP()
    print("[VIP] Initializing VIP system...")
    return true
end

--- Load VIP config
-- @return VIP configuration table
function loadVIPConfig()
    local config = exports.wave_core:getConfig()
    if config and config.vip then
        return {
            enabled = config.vip:getElementsByTagName("enabled")[1] and config.vip:getElementsByTagName("enabled")[1]:getValue() == "true",
            permissions = {},
            features = {}
        }
    end
    return { enabled = true, permissions = {}, features = {} }
end

-- =====================================================
-- VIP Status Functions
-- =====================================================

--- Check if player is VIP
-- @param player: player element
-- @return boolean
function isVIP(player)
    if not isElement(player) or getElementType(player) ~= "player" then
        return false
    end
    
    -- Check cache first
    local playerID = getElementData(player, "player:id")
    if playerID and playerVIP[playerID] ~= nil then
        return playerVIP[playerID].isVIP
    end
    
    -- Check database
    if playerID then
        local isVIPStatus = isPlayerVIPDB(playerID)
        playerVIP[playerID] = { isVIP = isVIPStatus }
        return isVIPStatus
    end
    
    return false
end

--- Set player VIP status
-- @param player: player element
-- @param status: boolean or "limited" for time-limited VIP
-- @param expiryDate: expiry date string (optional, for limited VIP)
-- @return boolean success
function setVIP(player, status, expiryDate)
    if not isElement(player) or getElementType(player) ~~ "player" then
        return false
    end
    
    local playerID = getElementData(player, "player:id")
    if not playerID then
        return false
    end
    
    status = status or true
    
    -- Handle limited VIP
    if status == "limited" and not expiryDate then
        -- Default 30 days from now
        expiryDate = os.date("%Y-%m-%d %H:%M:%S", os.time() + (30 * 24 * 60 * 60))
    end
    
    local success = setPlayerVIPDB(playerID, status ~= false, expiryDate)
    
    if success then
        -- Update cache
        playerVIP[playerID] = {
            isVIP = status ~= false,
            expiryDate = expiryDate
        }
        
        -- Update element data
        setElementData(player, "player:vip", status ~= false)
        if expiryDate then
            setElementData(player, "player:vip_expires", expiryDate)
        end
        
        -- Grant VIP permissions
        if status ~= false then
            grantVIPPermissions(player)
        else
            revokeVIPPermissions(player)
        end
    end
    
    return success
end

--- Check if VIP status has expired
-- @param player: player element
-- @return boolean (true if expired or not VIP)
function isVIPExpired(player)
    if not isVIP(player) then
        return true
    end
    
    local playerID = getElementData(player, "player:id")
    if playerVIP[playerID] and playerVIP[playerID].expiryDate then
        local expiryTime = playerVIP[playerID].expiryDate
        return hasExpired(expiryTime)
    end
    
    return false
end

--- Get VIP remaining time
-- @param player: player element
-- @return remaining seconds or nil
function getVIPRemainingTime(player)
    if not isVIP(player) then
        return nil
    end
    
    local playerID = getElementData(player, "player:id")
    if playerVIP[playerID] and playerVIP[playerID].expiryDate then
        local expiryTime = playerVIP[playerID].expiryDate
        local currentTime = getCurrentTimestamp()
        local difference = expiryTime - currentTime
        
        if difference > 0 then
            return difference
        end
    end
    
    return nil
end

-- =====================================================
-- VIP Permissions and Benefits
-- =====================================================

--- Grant VIP permissions to player
-- @param player: player element
function grantVIPPermissions(player)
    local config = loadVIPConfig()
    
    if config.permissions then
        for _, perm in ipairs(config.permissions) do
            addPlayerPermission(player, perm)
        end
    end
    
    triggerEvent("onPlayerVIPGranted", player)
end

--- Revoke VIP permissions from player
-- @param player: player element
function revokeVIPPermissions(player)
    local config = loadVIPConfig()
    
    if config.permissions then
        for _, perm in ipairs(config.permissions) do
            removePlayerPermission(player, perm)
        end
    end
    
    triggerEvent("onPlayerVIPRevoked", player)
end

--- Get VIP feature value
-- @param featureName: feature name
-- @return feature value or nil
function getVIPFeature(featureName)
    local config = loadVIPConfig()
    if config.features then
        return config.features[featureName]
    end
    return nil
end

--- Check if VIP feature is enabled
-- @param featureName: feature name
-- @return boolean
function isVIPFeatureEnabled(featureName)
    local feature = getVIPFeature(featureName)
    return feature ~= nil and feature ~= false
end

-- =====================================================
-- VIP Benefits Functions
-- =====================================================

--- Give VIP bonus
-- @param player: player element
-- @param type: bonus type (cash, items, etc)
-- @param amount: bonus amount
-- @return boolean success
function giveVIPBonus(player, type, amount)
    if not isVIP(player) then
        return false
    end
    
    -- Log VIP bonus
    local playerID = getElementData(player, "player:id")
    logActionDB(playerID, "vip_bonus", type .. ": " .. amount)
    
    return true
end

--- Get all VIP players online
-- @return table of VIP players
function getVIPPlayersOnline()
    local players = getOnlinePlayers()
    local vipPlayers = {}
    
    for _, player in ipairs(players) do
        if isVIP(player) then
            table.insert(vipPlayers, player)
        end
    end
    
    return vipPlayers
end

--- Send message to all VIP players
-- @param message: message text
-- @param r, g, b: RGB color
function sendVIPMessage(message, r, g, b)
    r = r or 255
    g = g or 255
    b = b or 255
    
    local vipPlayers = getVIPPlayersOnline()
    for _, player in ipairs(vipPlayers) do
        outputChatBox(message, player, r, g, b)
    end
end

-- =====================================================
-- VIP Caching
-- =====================================================

--- Clear VIP cache for player
-- @param player: player element
function clearVIPCache(player)
    local playerID = getElementData(player, "player:id")
    if playerID then
        playerVIP[playerID] = nil
    end
end

--- Clear all VIP caches
function clearAllVIPCaches()
    playerVIP = {}
end

-- =====================================================
-- Event Handlers
-- =====================================================

--- Check and handle expired VIP on player join
addEventHandler("onPlayerJoin", getRootElement(), function()
    local player = source
    if isVIP(player) and isVIPExpired(player) then
        setVIP(player, false)
        sendErrorMessage(player, "Your VIP status has expired.")
    end
end)

--- Clean up on quit
addEventHandler("onPlayerQuit", getRootElement(), function()
    clearVIPCache(source)
end)

return true
