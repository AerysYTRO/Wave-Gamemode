-- Wave Romania Roleplay - HUD System (Server-side)
-- Manages HUD data synchronization and economy

-- =====================================================
-- HUD Server Configuration
-- =====================================================

local HUD_CONFIG = {
    updateInterval = 500,
    minBankMoney = 0,
    minCashMoney = 0,
    maxBankMoney = 999999999,
    maxCashMoney = 999999999
}

-- =====================================================
-- Initialize HUD
-- =====================================================

function initializeHUD()
    print("[HUD] Initializing server HUD system...")
    
    -- Register events
    registerEvents()
    
    -- Start update loop
    startServerUpdateLoop()
    
    print("[HUD] Server HUD system initialized")
end

-- =====================================================
-- Register Events
-- =====================================================

function registerEvents()
    addEvent("wave_hud:updateData", true)
    addEvent("wave_hud:showPlayerID", true)
    addEvent("wave_hud:requestData", true)
    addEvent("wave_hud:ready", true)
end

-- =====================================================
-- Server Update Loop
-- =====================================================

function startServerUpdateLoop()
    setTimer(function()
        for _, player in ipairs(getElementsByType("player")) do
            if isElement(player) then
                updatePlayerHUDData(player)
            end
        end
    end, HUD_CONFIG.updateInterval)
end

-- =====================================================
-- Update Player HUD Data
-- =====================================================

function updatePlayerHUDData(player)
    if not isElement(player) or getElementType(player) ~= "player" then
        return
    end
    
    local hudData = getPlayerHUDData(player)
    
    -- Send to client
    triggerClientEvent(player, "wave_hud:updateData", player, hudData)
end

-- =====================================================
-- Get Player HUD Data
-- =====================================================

function getPlayerHUDData(player)
    if not isElement(player) then return nil end
    
    local playerID = getElementData(player, "player:id") or 0
    local playerName = getPlayerName(player)
    local health = getElementHealth(player)
    local armor = getPedArmor(player)
    
    -- Get faction and group from wave_core
    local faction = "None"
    local group = "user"
    
    if exports.wave_core then
        faction = exports.wave_core:getPlayerFaction(player) or "None"
        group = exports.wave_core:getPlayerGroup(player) or "user"
    end
    
    -- Get money from element data
    local bankMoney = getElementData(player, "bankMoney") or 0
    local cashMoney = getElementData(player, "cashMoney") or 0
    
    -- Create HUD data table
    local hudData = {
        id = playerID,
        name = playerName,
        bankMoney = tonumber(bankMoney) or 0,
        cashMoney = tonumber(cashMoney) or 0,
        faction = faction,
        group = group,
        health = math.floor(health),
        armor = math.floor(armor),
        energy = 100
    }
    
    return hudData
end

-- =====================================================
-- Money Management Functions
-- =====================================================

--- Set player money (both bank and cash)
-- @param player: player element
-- @param bankAmount: bank money
-- @param cashAmount: cash money
function setPlayerMoney(player, bankAmount, cashAmount)
    if not isElement(player) then return false end
    
    bankAmount = math.max(HUD_CONFIG.minBankMoney, math.min(HUD_CONFIG.maxBankMoney, bankAmount or 0))
    cashAmount = math.max(HUD_CONFIG.minCashMoney, math.min(HUD_CONFIG.maxCashMoney, cashAmount or 0))
    
    setElementData(player, "bankMoney", bankAmount)
    setElementData(player, "cashMoney", cashAmount)
    
    updatePlayerHUDData(player)
    return true
end

--- Give player cash
-- @param player: player element
-- @param amount: amount to give
function givePlayerCash(player, amount)
    if not isElement(player) or not amount or amount < 0 then return false end
    
    local current = getElementData(player, "cashMoney") or 0
    local newAmount = current + amount
    
    setPlayerMoney(player, getElementData(player, "bankMoney") or 0, newAmount)
    return true
end

--- Give player bank money
-- @param player: player element
-- @param amount: amount to give
function givePlayerBankMoney(player, amount)
    if not isElement(player) or not amount or amount < 0 then return false end
    
    local current = getElementData(player, "bankMoney") or 0
    local newAmount = current + amount
    
    setPlayerMoney(player, newAmount, getElementData(player, "cashMoney") or 0)
    return true
end

--- Remove player cash
-- @param player: player element
-- @param amount: amount to remove
function takePlayerCash(player, amount)
    if not isElement(player) or not amount or amount < 0 then return false end
    
    local current = getElementData(player, "cashMoney") or 0
    local newAmount = math.max(0, current - amount)
    
    setPlayerMoney(player, getElementData(player, "bankMoney") or 0, newAmount)
    return true
end

--- Remove player bank money
-- @param player: player element
-- @param amount: amount to remove
function takePlayerBankMoney(player, amount)
    if not isElement(player) or not amount or amount < 0 then return false end
    
    local current = getElementData(player, "bankMoney") or 0
    local newAmount = math.max(0, current - amount)
    
    setPlayerMoney(player, newAmount, getElementData(player, "cashMoney") or 0)
    return true
end

--- Get player cash
-- @param player: player element
-- @return cash amount
function getPlayerCash(player)
    if not isElement(player) then return 0 end
    return getElementData(player, "cashMoney") or 0
end

--- Get player bank money
-- @param player: player element
-- @return bank money amount
function getPlayerBankMoney(player)
    if not isElement(player) then return 0 end
    return getElementData(player, "bankMoney") or 0
end

-- =====================================================
-- Events
-- =====================================================

--- Player join - Initialize money
addEventHandler("onPlayerJoin", getRootElement(), function()
    local player = source
    
    -- Initialize starting money
    setElementData(player, "bankMoney", 5000)
    setElementData(player, "cashMoney", 1000)
    
    -- Update HUD after a short delay
    setTimer(function()
        if isElement(player) then
            updatePlayerHUDData(player)
        end
    end, 500)
end)

--- Player spawn - Update HUD
addEventHandler("onPlayerSpawn", getRootElement(), function()
    setTimer(function()
        if isElement(source) then
            updatePlayerHUDData(source)
        end
    end, 100)
end)

--- Player wasted - Update HUD
addEventHandler("onPlayerWasted", getRootElement(), function()
    setTimer(function()
        if isElement(source) then
            updatePlayerHUDData(source)
        end
    end, 100)
end)

--- Request HUD data from client
addEventHandler("wave_hud:requestData", getRootElement(), function()
    local player = source
    if isElement(player) then
        updatePlayerHUDData(player)
    end
end)

-- =====================================================
-- Commands
-- =====================================================

--- Test command to give money
addCommandHandler("givemoney", function(player, cmd, targetID, amount)
    if not targetID or not amount then
        print("[HUD] Usage: /givemoney [playerID] [amount]")
        return
    end
    
    amount = tonumber(amount)
    if not amount or amount < 0 then
        print("[HUD] Invalid amount")
        return
    end
    
    local target = getPlayerFromID(tonumber(targetID))
    if not target then
        print("[HUD] Player not found")
        return
    end
    
    givePlayerCash(target, amount)
    print("[HUD] Given $" .. amount .. " to " .. getPlayerName(target))
end)

--- Give bank money command
addCommandHandler("givebankmon", function(player, cmd, targetID, amount)
    if not targetID or not amount then
        print("[HUD] Usage: /givebankmon [playerID] [amount]")
        return
    end
    
    amount = tonumber(amount)
    if not amount or amount < 0 then
        print("[HUD] Invalid amount")
        return
    end
    
    local target = getPlayerFromID(tonumber(targetID))
    if not target then
        print("[HUD] Player not found")
        return
    end
    
    givePlayerBankMoney(target, amount)
    print("[HUD] Given $" .. amount .. " bank money to " .. getPlayerName(target))
end)

-- =====================================================
-- Helper Functions
-- =====================================================

function getPlayerFromID(id)
    for _, player in ipairs(getElementsByType("player")) do
        if getElementData(player, "player:id") == id then
            return player
        end
    end
    return nil
end

-- =====================================================
-- Initialize on resource start
-- =====================================================

addEventHandler("onResourceStart", getResourceRootElement(getThisResource()), function()
    initializeHUD()
end)

-- =====================================================
-- Exports
-- =====================================================

return true
