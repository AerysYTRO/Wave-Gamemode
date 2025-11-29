-- wave_character/server.lua
-- Simple character system: XML storage per player serial, up to 5 characters

local CHAR_DIR = "server/characters"
local MAX_CHAR = 5

function ensureCharDir()
    if not fileExists(CHAR_DIR) then
        -- create a dummy file inside folder by creating file path; MTA requires creating files via fileCreate
        -- We'll create the directory implicitly by saving files into it later.
    end
end

local function getCharFilePath(serial)
    return CHAR_DIR .. "/" .. tostring(serial) .. ".xml"
end

local function loadCharacters(serial)
    -- Try DB first (if wave_core exports available), otherwise fallback to XML files
    local chars = {}
    if exports and exports.wave_core and exports.wave_core.dbExecSync then
        local q = "SELECT id, char_index, name, age, race, gender, story, weight, height, created_at FROM player_characters WHERE player_serial = ? ORDER BY char_index ASC"
        local res = exports.wave_core.dbExecSync(q, {serial})
        if res and #res > 0 then
            for _, row in ipairs(res) do
                local c = {
                    id = tonumber(row.id),
                    char_index = tonumber(row.char_index),
                    name = row.name,
                    age = row.age,
                    race = row.race,
                    gender = row.gender,
                    story = row.story,
                    weight = row.weight,
                    height = row.height,
                    created_at = row.created_at,
                }
                table.insert(chars, c)
            end
            return chars
        end
    end

    -- Fallback to XML storage
    local path = getCharFilePath(serial)
    if fileExists(path) then
        local xml = xmlLoadFile(path)
        if xml then
            local root = xmlRoot(xml)
            for i, node in ipairs(xmlNodeGetChildren(root) or {}) do
                if xmlNodeGetName(node) == "character" then
                    local id = tonumber(xmlNodeGetAttribute(node, "id") or "0")
                    local data = {}
                    for _, child in ipairs(xmlNodeGetChildren(node) or {}) do
                        local name = xmlNodeGetName(child)
                        data[name] = xmlNodeGetValue(child) or ""
                    end
                    data.id = id
                    table.insert(chars, data)
                end
            end
            xmlUnloadFile(xml)
        end
    end
    return chars
end

local function saveCharacters(serial, chars)
    -- If DB available, perform transactional-ish save (delete existing and reinsert)
    if exports and exports.wave_core and exports.wave_core.dbExecSync then
        -- Expect table `player_characters` with columns: id (PK AUTO), player_serial, char_index, name, age, race, gender, story, weight, height, created_at
        -- We'll delete all for this serial and reinsert the provided chars preserving their char_index or id
        local delQ = "DELETE FROM player_characters WHERE player_serial = ?"
        exports.wave_core.dbExecSync(delQ, {serial})
        for index, c in ipairs(chars) do
            local q = [[
                INSERT INTO player_characters (player_serial, char_index, name, age, race, gender, story, weight, height, created_at)
                VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, CURRENT_TIMESTAMP)
            ]]
            exports.wave_core.dbExecSync(q, {serial, index, c.name or "", c.age or "", c.race or "", c.gender or "", c.story or "", c.weight or "", c.height or ""})
        end
        return true
    end

    -- Fallback to XML
    local path = getCharFilePath(serial)
    local xml = xmlCreateFile(path, "characters")
    if not xml then return false end
    local root = xmlRoot(xml)
    for _, c in ipairs(chars) do
        local node = xmlCreateChild(root, "character")
        xmlNodeSetAttribute(node, "id", tostring(c.id or 0))
        for k, v in pairs(c) do
            if k ~= "id" then
                local child = xmlCreateChild(node, tostring(k))
                xmlNodeSetValue(child, tostring(v))
            end
        end
    end
    xmlSaveFile(xml)
    xmlUnloadFile(xml)
    return true
end

local function getNextId(chars)
    local maxid = 0
    for _, c in ipairs(chars) do
        if c.id and tonumber(c.id) > maxid then
            maxid = tonumber(c.id)
        end
    end
    return maxid + 1
end

-- Events
addEvent("wave_character:requestList", true)
addEventHandler("wave_character:requestList", root, function()
    local player = source
    local serial = getPlayerSerial(player) or getPlayerName(player)
    local chars = loadCharacters(serial)
    triggerClientEvent(player, "wave_character:list", resourceRoot, chars)
end)

addEvent("wave_character:saveCharacter", true)
addEventHandler("wave_character:saveCharacter", root, function(data)
    local player = source
    local serial = getPlayerSerial(player) or getPlayerName(player)
    if type(data) ~= "table" then return end
    local chars = loadCharacters(serial)
    if #chars >= MAX_CHAR then
        triggerClientEvent(player, "wave_character:notify", resourceRoot, false, "Ai deja "..MAX_CHAR.." caractere.")
        return
    end
    local id = getNextId(chars)
    data.id = id
    table.insert(chars, data)
    if saveCharacters(serial, chars) then
        triggerClientEvent(player, "wave_character:notify", resourceRoot, true, "Caracter salvat.")
        triggerClientEvent(player, "wave_character:list", resourceRoot, chars)
    else
        triggerClientEvent(player, "wave_character:notify", resourceRoot, false, "Eroare la salvare.")
    end
end)

addEvent("wave_character:selectCharacter", true)
addEventHandler("wave_character:selectCharacter", root, function(charId)
    local player = source
    local serial = getPlayerSerial(player) or getPlayerName(player)
    local chars = loadCharacters(serial)
    local chosen = nil
    for _, c in ipairs(chars) do
        if tonumber(c.id) == tonumber(charId) then chosen = c; break end
    end
    if not chosen then
        triggerClientEvent(player, "wave_character:notify", resourceRoot, false, "Character invalid.")
        return
    end
    -- Delegate spawn to wave_spawn resource if available, otherwise fallback
    if getResourceFromName and getResourceFromName("wave_spawn") and exports.wave_spawn and exports.wave_spawn.spawnAtPrimarie then
        exports.wave_spawn.spawnAtPrimarie(player, chosen)
    else
        -- Simple skin mapping by gender
        local skin = 0
        if chosen.gender and string.lower(chosen.gender):find("fem") then
            skin = 6
        else
            skin = 0
        end
        -- spawn player at default coords (can be adjusted)
        local sx, sy, sz = 0, 0, 3
        spawnPlayer(player, sx, sy, sz, 0, skin)
        -- set element data for character
        setElementData(player, "character", chosen)
        triggerClientEvent(player, "wave_character:applied", resourceRoot, chosen)
    end
end)

-- On player join, request list automatically
addEventHandler("onPlayerJoin", root, function()
    local player = source
    local serial = getPlayerSerial(player) or getPlayerName(player)
    local chars = loadCharacters(serial)
    -- if player has no characters, open creator
    if #chars == 0 then
        triggerClientEvent(player, "wave_character:openCreator", resourceRoot)
    else
        triggerClientEvent(player, "wave_character:list", resourceRoot, chars)
    end
end)

-- Admin command to open character menu (for testing)
-- Manual `/chars` command removed to keep character flow automatic.
-- Use onPlayerJoin and client events to show creator/selection without commands.
