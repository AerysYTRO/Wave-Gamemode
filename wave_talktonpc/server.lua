-- wave_talktonpc/server.lua
-- Simple NPC talk system: load/save NPCs, spawn peds, exports to create/remove NPCs

local NPC_FILE = "server/npcs.xml"
local npcs = {}
local nextId = 1

local function getNPCFile()
    return NPC_FILE
end

local function loadNPCs()
    npcs = {}
    if fileExists(NPC_FILE) then
        local xml = xmlLoadFile(NPC_FILE)
        if xml then
            local root = xmlRoot(xml)
            for _, node in ipairs(xmlNodeGetChildren(root) or {}) do
                if xmlNodeGetName(node) == "npc" then
                    local id = tonumber(xmlNodeGetAttribute(node, "id") or "0")
                    local name = xmlNodeGetAttribute(node, "name") or "NPC"
                    local model = tonumber(xmlNodeGetAttribute(node, "model") or "0")
                    local x = tonumber(xmlNodeGetAttribute(node, "x") or "0")
                    local y = tonumber(xmlNodeGetAttribute(node, "y") or "0")
                    local z = tonumber(xmlNodeGetAttribute(node, "z") or "3")
                    local rot = tonumber(xmlNodeGetAttribute(node, "rot") or "0")
                    local dialog = xmlNodeGetValue(node) or ""
                    -- store dialog as raw string; client will split into lines
                    npcs[id] = { id = id, name = name, model = model, x = x, y = y, z = z, rot = rot, dialog = dialog }
                    nextId = math.max(nextId, id + 1)
                end
            end
            xmlUnloadFile(xml)
        end
    end
end

local function saveNPCs()
    local xml = xmlCreateFile(NPC_FILE, "npcs")
    if not xml then return false end
    local root = xmlRoot(xml)
    for id, npc in pairs(npcs) do
        local node = xmlCreateChild(root, "npc")
        xmlNodeSetAttribute(node, "id", tostring(npc.id))
        xmlNodeSetAttribute(node, "name", tostring(npc.name or "NPC"))
        xmlNodeSetAttribute(node, "model", tostring(npc.model or 0))
        xmlNodeSetAttribute(node, "x", tostring(npc.x or 0))
        xmlNodeSetAttribute(node, "y", tostring(npc.y or 0))
        xmlNodeSetAttribute(node, "z", tostring(npc.z or 3))
        xmlNodeSetAttribute(node, "rot", tostring(npc.rot or 0))
        -- store dialog as raw string (may contain newlines)
        local dialogText = npc.dialog or ""
        xmlNodeSetValue(node, dialogText)
    end
    xmlSaveFile(xml)
    xmlUnloadFile(xml)
    return true
end

local spawned = {}

local function spawnNPC(npc)
    if not npc then return end
    local ped = createPed((npc.model or 0), npc.x or 0, npc.y or 0, npc.z or 3, npc.rot or 0)
    if not ped then return end
    setElementData(ped, "wave_npc", true)
    setElementData(ped, "wave_npc_id", npc.id)
    setElementData(ped, "wave_npc_name", npc.name)
    setElementData(ped, "wave_npc_dialog_text", npc.dialog or "")
    spawned[npc.id] = ped
end

local function despawnAll()
    for id, ped in pairs(spawned) do
        if isElement(ped) then destroyElement(ped) end
    end
    spawned = {}
end

local function spawnAll()
    despawnAll()
    for id, npc in pairs(npcs) do
        spawnNPC(npc)
    end
end

-- Exports
function createNPC(data)
    data = data or {}
    local id = nextId
    nextId = nextId + 1
    local npc = {
        id = id,
        name = data.name or ("NPC"..tostring(id)),
        model = tonumber(data.model) or 0,
        x = tonumber(data.x) or 0,
        y = tonumber(data.y) or 0,
        z = tonumber(data.z) or 3,
        rot = tonumber(data.rot) or 0,
        dialog = data.dialog or "Salut!"
    }
    npcs[id] = npc
    saveNPCs()
    spawnNPC(npc)
    for _, player in ipairs(getElementsByType("player")) do
        triggerClientEvent(player, "wave_talktonpc:updateNPCs", resourceRoot, npcs)
    end
    return npc
end

function removeNPC(id)
    if not id then return false end
    if spawned[id] and isElement(spawned[id]) then destroyElement(spawned[id]) end
    spawned[id] = nil
    npcs[id] = nil
    saveNPCs()
    for _, player in ipairs(getElementsByType("player")) do
        triggerClientEvent(player, "wave_talktonpc:updateNPCs", resourceRoot, npcs)
    end
    return true
end

function getNPCs()
    return npcs
end

exports.createNPC = createNPC
exports.removeNPC = removeNPC
exports.getNPCs = getNPCs

addEvent("wave_talktonpc:requestNPCs", true)
addEventHandler("wave_talktonpc:requestNPCs", root, function()
    local player = source
    triggerClientEvent(player, "wave_talktonpc:updateNPCs", resourceRoot, npcs)
end)

addEvent("wave_talktonpc:interact", true)
addEventHandler("wave_talktonpc:interact", root, function(npcId)
    local player = source
    local npc = npcs[npcId]
    if not npc then return end
    triggerClientEvent(player, "wave_talktonpc:openDialog", resourceRoot, npcId, npc.name, npc.dialog)
end)

addEventHandler("onResourceStart", resourceRoot, function()
    loadNPCs()
    spawnAll()
    for _, player in ipairs(getElementsByType("player")) do
        triggerClientEvent(player, "wave_talktonpc:updateNPCs", resourceRoot, npcs)
    end
end)

addEventHandler("onResourceStop", resourceRoot, function()
    despawnAll()
end)

addEventHandler("onPlayerJoin", root, function()
    local player = source
    triggerClientEvent(player, "wave_talktonpc:updateNPCs", resourceRoot, npcs)
end)
