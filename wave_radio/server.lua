-- wave_radio/server.lua
-- Server-side radio: validates URLs and broadcasts play/stop to occupants

addEvent("wave_radio:requestPlay", true)
addEventHandler("wave_radio:requestPlay", root, function(url)
    local player = source
    if not isElement(player) or getElementType(player) ~= "player" then return end

    -- Ensure player is in a vehicle
    local veh = getPedOccupiedVehicle(player)
    if not veh then
        triggerClientEvent(player, "wave_radio:notify", player, false, "You must be in a vehicle to use the radio.")
        return
    end

    -- Basic validation: non-empty and reasonable length
    if type(url) ~= "string" or #url < 10 or #url > 2048 then
        triggerClientEvent(player, "wave_radio:notify", player, false, "Invalid URL.")
        return
    end

    -- Only allow http(s) links for now
    local lower = url:lower()
    if not (lower:match("^https?://")) then
        triggerClientEvent(player, "wave_radio:notify", player, false, "URL must start with http:// or https:// (direct audio stream).")
        return
    end

    -- If URL is from youtube/spotify or not obviously a direct stream, proxy through local proxy if configured
    local PROXY_BASE = getResourceConfig and getResourceConfig("wave_radio_proxy") or nil
    -- Fallback default proxy (local). Change in config or set env.
    if not PROXY_BASE then
        PROXY_BASE = "http://127.0.0.1:3000/stream?url="
    end

    local needsProxy = false
    if lower:match("youtube.com") or lower:match("youtu.be") or lower:match("spotify.com") or not (lower:match("%.mp3") or lower:match("%.ogg") or lower:match("stream") or lower:match("listen")) then
        needsProxy = true
    end

    if needsProxy then
        -- Build proxied URL (url-encode original)
        local function urlencode(str)
            if not str then return "" end
            str = tostring(str)
            str = str:gsub("([^%w _%.%-~])", function(c) return string.format('%%%02X', string.byte(c)) end)
            str = str:gsub(' ', '%%20')
            return str
        end
        local proxied = PROXY_BASE .. urlencode(url) .. "&format=mp3"
        triggerClientEvent(player, "wave_radio:notify", player, true, "Using proxy to stream content (YouTube/Spotify).")
        url = proxied
    end

    -- Optionally, check extension or known stream hosts (simple check)
    local ok = nil
    if lower:match("%.mp3") or lower:match("%.ogg") or lower:match("stream") or lower:match("listen") then
        ok = true
    end

    -- If not obviously an audio stream, still allow but warn
    if not ok then
        triggerClientEvent(player, "wave_radio:notify", player, true, "URL does not look like a direct audio stream. If it fails, provide a direct MP3/OGG stream.")
    end

    -- Broadcast to all occupants in the vehicle to start playing the url
    for _, p in ipairs(getElementsByType("player")) do
        if isElement(p) and getPedOccupiedVehicle(p) == veh then
            triggerClientEvent(p, "wave_radio:play", p, url)
        end
    end

    -- Save current stream on vehicle element data
    setElementData(veh, "wave_radio:current_url", url)

    -- Notify driver
    triggerClientEvent(player, "wave_radio:notify", player, true, "Playing stream for vehicle occupants.")
end)

addEvent("wave_radio:requestStop", true)
addEventHandler("wave_radio:requestStop", root, function()
    local player = source
    if not isElement(player) or getElementType(player) ~= "player" then return end

    local veh = getPedOccupiedVehicle(player)
    if not veh then
        triggerClientEvent(player, "wave_radio:notify", player, false, "You must be in a vehicle to stop the radio.")
        return
    end

    -- Broadcast stop to occupants
    for _, p in ipairs(getElementsByType("player")) do
        if isElement(p) and getPedOccupiedVehicle(p) == veh then
            triggerClientEvent(p, "wave_radio:stop", p)
        end
    end

    setElementData(veh, "wave_radio:current_url", nil)
    triggerClientEvent(player, "wave_radio:notify", player, true, "Stopped radio for vehicle occupants.")
end)

-- Helper: allow admin to force play/stop on a vehicle (server command)
addCommandHandler("radioplay", function(admin, cmd, vehicleID, url)
    if not isElement(admin) or getElementType(admin) ~= "player" then return end
    if not hasPermission(admin, "admin.manage_players") then
        outputChatBox("You don't have permission.", admin, 255,0,0)
        return
    end
    -- find vehicle by id
    local vid = tonumber(vehicleID)
    if not vid then
        outputChatBox("Usage: /radioplay [vehicleElementID] [url]", admin)
        return
    end
    local veh = getElementByID and getElementByID(vid) or nil
    if not veh then
        outputChatBox("Vehicle not found by element ID.", admin)
        return
    end
    for _, p in ipairs(getElementsByType("player")) do
        if isElement(p) and getPedOccupiedVehicle(p) == veh then
            triggerClientEvent(p, "wave_radio:play", p, url)
        end
    end
end)

addCommandHandler("radiostop", function(admin, cmd, vehicleID)
    if not isElement(admin) or getElementType(admin) ~= "player" then return end
    if not hasPermission(admin, "admin.manage_players") then
        outputChatBox("You don't have permission.", admin, 255,0,0)
        return
    end
    local vid = tonumber(vehicleID)
    if not vid then
        outputChatBox("Usage: /radiostop [vehicleElementID]", admin)
        return
    end
    local veh = getElementByID and getElementByID(vid) or nil
    if not veh then
        outputChatBox("Vehicle not found by element ID.", admin)
        return
    end
    for _, p in ipairs(getElementsByType("player")) do
        if isElement(p) and getPedOccupiedVehicle(p) == veh then
            triggerClientEvent(p, "wave_radio:stop", p)
        end
    end
end)

return true
