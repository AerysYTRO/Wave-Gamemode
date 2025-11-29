-- wave_talktonpc/client.lua
-- Client interaction: detect nearby NPCs and open GUI dialog when pressing E

local npcs = {}
local dialogWindow = nil
local dialogLabel = nil
local currentNpc = nil
local currentDialogLines = {}
local dialogIndex = 1

local function splitLines(s)
    local t = {}
    if not s or s == "" then return t end
    for line in s:gmatch("([^%c]+)") do table.insert(t, line) end
    return t
end

addEvent("wave_talktonpc:updateNPCs", true)
addEventHandler("wave_talktonpc:updateNPCs", root, function(serverNPCs)
    npcs = serverNPCs or {}
end)

addEventHandler("onClientResourceStart", resourceRoot, function()
    triggerServerEvent("wave_talktonpc:requestNPCs", resourceRoot)
end)

local function createDialogWindow()
    if isElement(dialogWindow) then return end
    local sx, sy = guiGetScreenSize()
    local w, h = 480, 220
    dialogWindow = guiCreateWindow((sx-w)/2, (sy-h)/2, w, h, "Interaction", false)
    guiWindowSetSizable(dialogWindow, false)
    dialogLabel = guiCreateLabel(0.03, 0.08, 0.94, 0.6, "", true, dialogWindow)
    guiLabelSetVerticalAlign(dialogLabel, "top")
    local nextBtn = guiCreateButton(0.05, 0.72, 0.45, 0.2, "Urmator", true, dialogWindow)
    local closeBtn = guiCreateButton(0.52, 0.72, 0.43, 0.2, "Inchide", true, dialogWindow)

    addEventHandler("onClientGUIClick", nextBtn, function()
        dialogIndex = dialogIndex + 1
        if dialogIndex > #currentDialogLines then dialogIndex = #currentDialogLines end
        guiSetText(dialogLabel, (currentDialogLines[dialogIndex] or ""))
    end, false)

    addEventHandler("onClientGUIClick", closeBtn, function()
        if isElement(dialogWindow) then destroyElement(dialogWindow); dialogWindow = nil; dialogLabel = nil end
        currentNpc = nil
        showCursor(false)
    end, false)
end

addEvent("wave_talktonpc:openDialog", true)
addEventHandler("wave_talktonpc:openDialog", root, function(npcId, name, dialogText)
    currentNpc = npcId
    currentDialogLines = splitLines(dialogText or "")
    if #currentDialogLines == 0 then currentDialogLines = {"..."} end
    dialogIndex = 1
    createDialogWindow()
    if isElement(dialogLabel) then guiSetText(dialogLabel, currentDialogLines[dialogIndex]) end
    showCursor(true)
end)

local function findNearestNPC(range)
    local px, py, pz = getElementPosition(localPlayer)
    local nearest, nid, ndist = nil, nil, range
    for id, npc in pairs(npcs) do
        local nx, ny, nz = tonumber(npc.x) or 0, tonumber(npc.y) or 0, tonumber(npc.z) or 0
        local d = getDistanceBetweenPoints3D(px, py, pz, nx, ny, nz)
        if d <= ndist then
            nearest = npc
            nid = id
            ndist = d
        end
    end
    return nearest, nid
end

bindKey("e", "down", function()
    local nearest, nid = findNearestNPC(3)
    if not nearest then return end
    triggerServerEvent("wave_talktonpc:interact", resourceRoot, nid)
end)
