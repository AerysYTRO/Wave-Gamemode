-- wave_radio/client.lua
-- Client-side radio GUI and playback (no HTML)

local RADIO = {
    window = nil,
    edit = nil,
    playBtn = nil,
    stopBtn = nil,
    statusLabel = nil,
    sound = nil,
    isOpen = false
}

-- Utility to create GUI
local function createGUI()
    if RADIO.window and isElement(RADIO.window) then return end

    local screenW, screenH = guiGetScreenSize()
    local w, h = 420, 140
    local x, y = (screenW - w) / 2, (screenH - h) / 2

    RADIO.window = guiCreateWindow(x, y, w, h, "Wave Radio", false)
    guiWindowSetSizable(RADIO.window, false)

    RADIO.edit = guiCreateEdit(0.05, 0.18, 0.9, 0.26, "http://", true, RADIO.window)
    RADIO.playBtn = guiCreateButton(0.12, 0.52, 0.32, 0.28, "PLAY", true, RADIO.window)
    RADIO.stopBtn = guiCreateButton(0.56, 0.52, 0.32, 0.28, "STOP", true, RADIO.window)
    RADIO.statusLabel = guiCreateLabel(0.05, 0.86, 0.9, 0.12, "Status: Idle", true, RADIO.window)
    guiLabelSetColor(RADIO.statusLabel, 255, 255, 255)
    guiSetVisible(RADIO.window, false)

    addEventHandler("onClientGUIClick", RADIO.playBtn, function()
        local url = guiGetText(RADIO.edit)
        triggerServerEvent("wave_radio:requestPlay", resourceRoot, url)
    end, false)

    addEventHandler("onClientGUIClick", RADIO.stopBtn, function()
        triggerServerEvent("wave_radio:requestStop", resourceRoot)
    end, false)
end

-- Open/Close GUI
local function toggleGUI()
    local player = getLocalPlayer()
    local veh = getPedOccupiedVehicle(player)
    if not veh then
        exports.wave_core:sendErrorMessage(player, "You must be in a vehicle to use the radio.")
        return
    end

    if not RADIO.window then createGUI() end
    RADIO.isOpen = not RADIO.isOpen
    guiSetVisible(RADIO.window, RADIO.isOpen)
    showCursor(RADIO.isOpen)
end

-- Key binding: shift opens GUI
bindKey("lshift", "down", function()
    toggleGUI()
end)
bindKey("rshift", "down", function()
    toggleGUI()
end)

-- Play received URL
addEvent("wave_radio:play", true)
addEventHandler("wave_radio:play", root, function(url)
    if RADIO.sound and isElement(RADIO.sound) then
        destroyElement(RADIO.sound)
        RADIO.sound = nil
    end

    -- Try playSound with URL (works for direct mp3/ogg streams)
    local ok, soundOrErr = pcall(function()
        return playSound(url)
    end)

    if ok and soundOrErr then
        RADIO.sound = soundOrErr
        setSoundVolume(RADIO.sound, 1.0)
        if RADIO.statusLabel then guiSetText(RADIO.statusLabel, "Status: Playing") end
    else
        if RADIO.statusLabel then guiSetText(RADIO.statusLabel, "Status: Failed to play stream") end
        exports.wave_core:sendErrorMessage(getLocalPlayer(), "Failed to play stream. Ensure the URL is a direct audio stream (mp3/ogg) or an internet radio stream.")
    end
end)

-- Stop playback
addEvent("wave_radio:stop", true)
addEventHandler("wave_radio:stop", root, function()
    if RADIO.sound and isElement(RADIO.sound) then
        stopSound(RADIO.sound)
        destroyElement(RADIO.sound)
        RADIO.sound = nil
    end
    if RADIO.statusLabel then guiSetText(RADIO.statusLabel, "Status: Stopped") end
end)

-- Notifications from server
addEvent("wave_radio:notify", true)
addEventHandler("wave_radio:notify", root, function(success, msg)
    if success then
        exports.wave_core:sendSuccessMessage(getLocalPlayer(), msg)
    else
        exports.wave_core:sendErrorMessage(getLocalPlayer(), msg)
    end
end)

-- Clean up on resource stop
addEventHandler("onClientResourceStop", resourceRoot, function()
    if RADIO.sound and isElement(RADIO.sound) then
        stopSound(RADIO.sound)
        destroyElement(RADIO.sound)
        RADIO.sound = nil
    end
    if RADIO.window and isElement(RADIO.window) then
        destroyElement(RADIO.window)
        RADIO.window = nil
    end
end)

return true
