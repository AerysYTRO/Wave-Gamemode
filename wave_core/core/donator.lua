-- Wave Romania Roleplay - Donator Module
-- Manages donator status and rewards

-- Donator cache
local playerDonator = {}

-- =====================================================
-- Donator Initialization
-- =====================================================

--- Initialize donator system
-- @return boolean success
function initializeDonator()
    print("[DONATOR] Initializing donator system...")
    return true
end

--- Load donator config
-- @return donator configuration table
function loadDonatorConfig()
    local config = exports.wave_core:getConfig()
    if config and config.donator then
        local donatorConfig = {
            enabled = config.donator:getElementsByTagName("enabled")[1] and config.donator:getElementsByTagName("enabled")[1]:getValue() == "true",
            permissions = {},
            tiers = {}
        }
        
        -- Load tiers
        for _, tier in ipairs(config.donator:getElementsByTagName("tier")) do
            local tierName = tier:getAttribute("name")
            local tierCost = tonumber(tier:getAttribute("cost")) or 0
            
            donatorConfig.tiers[tierName] = {
                cost = tierCost,
                benefits = {}
            }
            
            for _, benefit in ipairs(tier:getElementsByTagName("benefit")) do
                table.insert(donatorConfig.tiers[tierName].benefits, benefit:getValue())
            end
        end
        
        return donatorConfig
    end
    return { enabled = true, permissions = {}, tiers = {} }
end

-- =====================================================
-- Donator Status Functions
-- =====================================================

--- Check if player is donator
-- @param player: player element
-- @return boolean
function isDonator(player)
    if not isElement(player) or getElementType(player) ~= "player" then
        return false
    end
    
    -- Check cache first
    local playerID = getElementData(player, "player:id")
    if playerID and playerDonator[playerID] ~= nil then
        return playerDonator[playerID].isDonator
    end
    
    -- Check database
    if playerID then
        local isDonatorStatus = isPlayerDonatorDB(playerID)
        playerDonator[playerID] = { isDonator = isDonatorStatus }
        return isDonatorStatus
    end
    
    return false
end

--- Set player donator status
-- @param player: player element
-- @param status: boolean
-- @param tier: donator tier (bronze, silver, gold)
-- @return boolean success
function setDonator(player, status, tier)
    if not isElement(player) or getElementType(player) ~= "player" then
        return false
    end
    
    local playerID = getElementData(player, "player:id")
    if not playerID then
        return false
    end
    
    tier = tier or "bronze"
    
    local success = setPlayerDonatorDB(playerID, status or false, tier)
    
    if success then
        -- Update cache
        playerDonator[playerID] = {
            isDonator = status or false,
            tier = tier
        }
        
        -- Update element data
        setElementData(player, "player:donator", status or false)
        setElementData(player, "player:donator_tier", tier)
        
        -- Grant donator permissions
        if status then
            grantDonatorPermissions(player, tier)
        else
            revokeDonatorPermissions(player)
        end
    end
    
    return success
end

--- Get donator tier
-- @param player: player element
-- @return tier name or nil
function getDonatorTier(player)
    if not isDonator(player) then
        return nil
    end
    
    local playerID = getElementData(player, "player:id")
    if playerDonator[playerID] then
        return playerDonator[playerID].tier
    end
    
    return nil
end

-- =====================================================
-- Donator Permissions and Benefits
-- =====================================================

--- Grant donator permissions to player
-- @param player: player element
-- @param tier: donator tier
function grantDonatorPermissions(player, tier)
    tier = tier or getDonatorTier(player) or "bronze"
    
    local config = loadDonatorConfig()
    
    if config.permissions then
        for _, perm in ipairs(config.permissions) do
            addPlayerPermission(player, perm)
        end
    end
    
    -- Grant tier-specific permissions
    if config.tiers[tier] then
        for _, benefit in ipairs(config.tiers[tier].benefits) do
            -- Process benefit (some are commands, some are items, etc)
            triggerEvent("onDonatorBenefit", player, benefit, tier)
        end
    end
    
    triggerEvent("onPlayerDonatorGranted", player, tier)
end

--- Revoke donator permissions from player
-- @param player: player element
function revokeDonatorPermissions(player)
    local config = loadDonatorConfig()
    
    if config.permissions then
        for _, perm in ipairs(config.permissions) do
            removePlayerPermission(player, perm)
        end
    end
    
    triggerEvent("onPlayerDonatorRevoked", player)
end

--- Get donator benefits
-- @param tier: donator tier
-- @return table of benefits
function getDonatorBenefits(tier)
    tier = tier or "bronze"
    
    local config = loadDonatorConfig()
    if config.tiers[tier] then
        return config.tiers[tier].benefits
    end
    
    return {}
end

--- Get donator tier cost
-- @param tier: donator tier
-- @return cost in currency
function getDonatorTierCost(tier)
    tier = tier or "bronze"
    
    local config = loadDonatorConfig()
    if config.tiers[tier] then
        return config.tiers[tier].cost
    end
    
    return 0
end

-- =====================================================
-- Donator Rewards
-- =====================================================

--- Claim donator reward
-- @param player: player element
-- @return boolean success
function claimDonatorReward(player)
    if not isDonator(player) then
        sendErrorMessage(player, "You are not a donator.")
        return false
    end
    
    local playerID = getElementData(player, "player:id")
    local tier = getDonatorTier(player)
    
    -- Check if already claimed today
    local query = "SELECT last_reward_claimed FROM player_donator WHERE player_id = ?"
    local result = dbExecSync(query, {playerID})
    
    if result and #result > 0 then
        local lastClaimed = result[1].last_reward_claimed
        if lastClaimed then
            local lastDate = os.date("%Y-%m-%d", tonumber(lastClaimed))
            local today = os.date("%Y-%m-%d")
            
            if lastDate == today then
                sendErrorMessage(player, "You have already claimed your daily reward.")
                return false
            end
        end
    end
    
    -- Give reward based on tier
    local rewardAmount = 0
    if tier == "bronze" then
        rewardAmount = 5000
    elseif tier == "silver" then
        rewardAmount = 15000
    elseif tier == "gold" then
        rewardAmount = 50000
    end
    
    if rewardAmount > 0 then
        -- Give player reward (this would integrate with your economy system)
        triggerEvent("onDonatorReward", player, "daily_cash", rewardAmount)
        
        -- Update last reward claimed
        local updateQuery = "UPDATE player_donator SET last_reward_claimed = CURRENT_TIMESTAMP WHERE player_id = ?"
        dbExecSync(updateQuery, {playerID})
        
        sendSuccessMessage(player, "You claimed your daily reward: $" .. rewardAmount)
        return true
    end
    
    return false
end

--- Give donator bonus
-- @param player: player element
-- @param type: bonus type
-- @param amount: bonus amount
-- @return boolean success
function giveDonatorBonus(player, type, amount)
    if not isDonator(player) then
        return false
    end
    
    local playerID = getElementData(player, "player:id")
    logActionDB(playerID, "donator_bonus", type .. ": " .. amount)
    
    triggerEvent("onDonatorBonus", player, type, amount)
    
    return true
end

-- =====================================================
-- Donator Info Functions
-- =====================================================

--- Get all donators online
-- @return table of donator players
function getDonatorPlayersOnline()
    local players = getOnlinePlayers()
    local donatorPlayers = {}
    
    for _, player in ipairs(players) do
        if isDonator(player) then
            table.insert(donatorPlayers, player)
        end
    end
    
    return donatorPlayers
end

--- Get donators by tier
-- @param tier: donator tier
-- @return table of players with that tier
function getDonatorsByTier(tier)
    local players = getOnlinePlayers()
    local tierPlayers = {}
    
    for _, player in ipairs(players) do
        if getDonatorTier(player) == tier then
            table.insert(tierPlayers, player)
        end
    end
    
    return tierPlayers
end

--- Send message to all donators
-- @param message: message text
-- @param tier: specific tier or nil for all
-- @param r, g, b: RGB color
function sendDonatorMessage(message, tier, r, g, b)
    r = r or 255
    g = g or 255
    b = b or 255
    
    local donatorPlayers
    if tier then
        donatorPlayers = getDonatorsByTier(tier)
    else
        donatorPlayers = getDonatorPlayersOnline()
    end
    
    for _, player in ipairs(donatorPlayers) do
        outputChatBox(message, player, r, g, b)
    end
end

-- =====================================================
-- Donator Caching
-- =====================================================

--- Clear donator cache for player
-- @param player: player element
function clearDonatorCache(player)
    local playerID = getElementData(player, "player:id")
    if playerID then
        playerDonator[playerID] = nil
    end
end

--- Clear all donator caches
function clearAllDonatorCaches()
    playerDonator = {}
end

-- =====================================================
-- Event Handlers
-- =====================================================

addEventHandler("onPlayerQuit", getRootElement(), function()
    clearDonatorCache(source)
end)

return true
