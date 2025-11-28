-- Wave Romania Roleplay - Priority System
-- Manages player priority levels

-- Priority cache
local playerPriority = {}

-- =====================================================
-- Priority Initialization
-- =====================================================

--- Initialize priority system
-- @return boolean success
function initializePriority()
    print("[PRIORITY] Initializing priority system...")
    return true
end

-- =====================================================
-- Priority Management Functions
-- =====================================================

--- Get player priority level
-- @param player: player element
-- @return priority level (1-100)
function getPlayerPriority(player)
    if not isElement(player) or getElementType(player) ~= "player" then
        return 1
    end
    
    -- Check cache first
    local playerID = getElementData(player, "player:id")
    if playerID and playerPriority[playerID] then
        return playerPriority[playerID]
    end
    
    -- Try to get from database
    if playerID then
        local priority = getPlayerPriorityDB(playerID)
        if priority then
            playerPriority[playerID] = priority
            return priority
        end
    end
    
    -- Check player group for default priority
    local group = getPlayerGroup(player)
    if group then
        local config = exports.wave_core:getConfig()
        if config and config.groups then
            for _, groupElement in ipairs(config.groups) do
                if groupElement:getAttribute("name") == group then
                    local groupPriority = tonumber(groupElement:getAttribute("priority")) or 1
                    if playerID then
                        playerPriority[playerID] = groupPriority
                    end
                    return groupPriority
                end
            end
        end
    end
    
    return 1
end

--- Set player priority
-- @param player: player element
-- @param priority: priority level (1-100)
-- @return boolean
function setPlayerPriority(player, priority)
    if not isElement(player) or getElementType(player) ~= "player" then
        return false
    end
    
    -- Validate priority value
    priority = math.max(1, math.min(100, tonumber(priority) or 1))
    
    local playerID = getElementData(player, "player:id")
    if not playerID then
        return false
    end
    
    -- Save to database
    local success = setPlayerPriorityDB(playerID, priority)
    
    if success then
        -- Update cache
        playerPriority[playerID] = priority
        -- Update element data for quick access
        setElementData(player, "player:priority", priority)
    end
    
    return success
end

--- Increment player priority
-- @param player: player element
-- @param amount: amount to add (default 1)
-- @return new priority or nil
function incrementPlayerPriority(player, amount)
    amount = amount or 1
    local currentPriority = getPlayerPriority(player)
    local newPriority = currentPriority + amount
    
    if setPlayerPriority(player, newPriority) then
        return newPriority
    end
    
    return nil
end

--- Decrement player priority
-- @param player: player element
-- @param amount: amount to subtract (default 1)
-- @return new priority or nil
function decrementPlayerPriority(player, amount)
    amount = amount or 1
    local currentPriority = getPlayerPriority(player)
    local newPriority = currentPriority - amount
    
    if setPlayerPriority(player, newPriority) then
        return newPriority
    end
    
    return nil
end

-- =====================================================
-- Priority Comparison Functions
-- =====================================================

--- Compare two players' priority
-- @param player1: first player element
-- @param player2: second player element
-- @return 1 if player1 > player2, -1 if player1 < player2, 0 if equal
function comparePriority(player1, player2)
    local priority1 = getPlayerPriority(player1)
    local priority2 = getPlayerPriority(player2)
    
    if priority1 > priority2 then
        return 1
    elseif priority1 < priority2 then
        return -1
    else
        return 0
    end
end

--- Check if player1 has higher priority than player2
-- @param player1: first player element
-- @param player2: second player element
-- @return boolean
function hasHigherPriority(player1, player2)
    return comparePriority(player1, player2) > 0
end

--- Check if player has minimum priority level
-- @param player: player element
-- @param minPriority: minimum priority level
-- @return boolean
function hasMinimumPriority(player, minPriority)
    return getPlayerPriority(player) >= minPriority
end

-- =====================================================
-- Queue System (based on priority)
-- =====================================================

local priorityQueue = {}

--- Add player to priority queue
-- @param player: player element
-- @return position in queue
function addToQueueByPriority(player)
    if not isElement(player) or getElementType(player) ~= "player" then
        return -1
    end
    
    local playerPriority = getPlayerPriority(player)
    local position = 1
    
    for i, queuedPlayer in ipairs(priorityQueue) do
        if isElement(queuedPlayer) then
            if playerPriority > getPlayerPriority(queuedPlayer) then
                table.insert(priorityQueue, i, player)
                return i
            end
            position = i + 1
        end
    end
    
    table.insert(priorityQueue, player)
    return position
end

--- Get next player from priority queue
-- @return player element or nil
function getNextFromQueue()
    while #priorityQueue > 0 do
        local player = table.remove(priorityQueue, 1)
        if isElement(player) then
            return player
        end
    end
    return nil
end

--- Get queue size
-- @return number of players in queue
function getQueueSize()
    return #priorityQueue
end

-- =====================================================
-- Priority Caching
-- =====================================================

--- Clear priority cache for player
-- @param player: player element
function clearPriorityCache(player)
    local playerID = getElementData(player, "player:id")
    if playerID then
        playerPriority[playerID] = nil
    end
end

--- Clear all priority caches
function clearAllPriorityCaches()
    playerPriority = {}
end

-- =====================================================
-- Event Handlers
-- =====================================================

addEventHandler("onPlayerQuit", getRootElement(), function()
    clearPriorityCache(source)
    
    -- Remove from queue
    for i, player in ipairs(priorityQueue) do
        if player == source then
            table.remove(priorityQueue, i)
            break
        end
    end
end)

return true
