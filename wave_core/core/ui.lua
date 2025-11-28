-- Wave Romania Roleplay - UI Module
-- Handles UI interactions and external API

-- UI state tracking
local playerUI = {}

-- =====================================================
-- UI Initialization
-- =====================================================

--- Initialize UI system
-- @return boolean success
function initializeUI()
    print("[UI] Initializing UI system...")
    return true
end

-- =====================================================
-- UI Management Functions
-- =====================================================

--- Open UI for player
-- @param player: player element
-- @param uiName: UI identifier/name
-- @param data: table with UI data
-- @return boolean success
function openUI(player, uiName, data)
    if not isElement(player) or getElementType(player) ~= "player" then
        return false
    end
    
    if not uiName or uiName == "" then
        print("[UI ERROR] Invalid UI name")
        return false
    end
    
    data = data or {}
    
    -- Store UI state
    playerUI[getElementData(player, "player:id")] = {
        name = uiName,
        data = data,
        openedAt = getCurrentTimestamp()
    }
    
    -- Trigger client event
    triggerClientEvent(player, "wave_core:openUI", player, uiName, data)
    
    return true
end

--- Close UI for player
-- @param player: player element
-- @return boolean success
function closeUI(player)
    if not isElement(player) or getElementType(player) ~= "player" then
        return false
    end
    
    local playerID = getElementData(player, "player:id")
    
    -- Clear UI state
    playerUI[playerID] = nil
    
    -- Trigger client event
    triggerClientEvent(player, "wave_core:closeUI", player)
    
    return true
end

--- Close UI for all players
function closeUIAll()
    local players = getOnlinePlayers()
    
    for _, player in ipairs(players) do
        closeUI(player)
    end
end

--- Check if player has UI open
-- @param player: player element
-- @return boolean
function hasUIOpen(player)
    local playerID = getElementData(player, "player:id")
    return playerUI[playerID] ~= nil
end

--- Get player's open UI name
-- @param player: player element
-- @return UI name or nil
function getPlayerOpenUI(player)
    local playerID = getElementData(player, "player:id")
    if playerUI[playerID] then
        return playerUI[playerID].name
    end
    return nil
end

-- =====================================================
-- UI Data Functions
-- =====================================================

--- Send data to player's UI
-- @param player: player element
-- @param key: data key
-- @param value: data value
-- @return boolean success
function sendUIData(player, key, value)
    if not isElement(player) or getElementType(player) ~= "player" then
        return false
    end
    
    local playerID = getElementData(player, "player:id")
    if not playerUI[playerID] then
        return false
    end
    
    playerUI[playerID].data[key] = value
    triggerClientEvent(player, "wave_core:updateUI", player, key, value)
    
    return true
end

--- Get UI data
-- @param player: player element
-- @param key: data key
-- @return data value or nil
function getUIData(player, key)
    local playerID = getElementData(player, "player:id")
    if playerUI[playerID] and playerUI[playerID].data then
        return playerUI[playerID].data[key]
    end
    return nil
end

-- =====================================================
-- UI Events
-- =====================================================

--- Notify UI update to player
-- @param player: player element
-- @param eventName: event name
-- @param ...: event data
function notifyUI(player, eventName, ...)
    if not isElement(player) or getElementType(player) ~= "player" then
        return false
    end
    
    triggerClientEvent(player, "wave_core:notifyUI", player, eventName, {...})
    
    return true
end

--- Notify all players' UI
-- @param eventName: event name
-- @param ...: event data
function notifyUIAll(eventName, ...)
    local players = getOnlinePlayers()
    
    for _, player in ipairs(players) do
        notifyUI(player, eventName, ...)
    end
end

-- =====================================================
-- Common UI Functions
-- =====================================================

--- Show notification to player
-- @param player: player element
-- @param title: notification title
-- @param message: notification message
-- @param type: notification type (success, error, info, warning)
-- @param duration: duration in milliseconds
function showNotification(player, title, message, type, duration)
    type = type or "info"
    duration = duration or 5000
    
    openUI(player, "notification", {
        title = title,
        message = message,
        type = type,
        duration = duration
    })
    
    setTimer(function()
        if isElement(player) then
            closeUI(player)
        end
    end, duration, 1)
end

--- Show dialog to player
-- @param player: player element
-- @param title: dialog title
-- @param message: dialog message
-- @param buttons: table of button labels
-- @param callback: callback function (player, buttonIndex)
function showDialog(player, title, message, buttons, callback)
    openUI(player, "dialog", {
        title = title,
        message = message,
        buttons = buttons
    })
    
    -- Store callback for handling response
    local playerID = getElementData(player, "player:id")
    if not playerUI[playerID] then
        playerUI[playerID] = {}
    end
    playerUI[playerID].callback = callback
end

--- Show confirm dialog
-- @param player: player element
-- @param message: confirmation message
-- @param callback: callback function (player, confirmed)
function showConfirmDialog(player, message, callback)
    showDialog(player, "Confirmation", message, {"Yes", "No"}, function(p, buttonIndex)
        if callback then
            callback(p, buttonIndex == 1)
        end
    end)
end

--- Show message box
-- @param player: player element
-- @param title: message box title
-- @param message: message content
-- @param type: message type (info, warning, error, success)
function showMessageBox(player, title, message, type)
    type = type or "info"
    showNotification(player, title, message, type)
end

-- =====================================================
-- Event Handlers
-- =====================================================

--- Handle UI response from client
addEventHandler("wave_core:UIResponse", getRootElement(), function(uiName, responseData)
    local player = source
    if not isElement(player) then return end
    
    local playerID = getElementData(player, "player:id")
    if playerUI[playerID] and playerUI[playerID].callback then
        pcall(playerUI[playerID].callback, player, responseData)
    end
end)

--- Handle player quit - cleanup UI
addEventHandler("onPlayerQuit", getRootElement(), function()
    local playerID = getElementData(source, "player:id")
    if playerUI[playerID] then
        playerUI[playerID] = nil
    end
end)

return true
