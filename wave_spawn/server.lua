-- wave_spawn/server.lua
-- Provides a configurable 'primarie' spawn and exports spawnAtPrimarie(player, charData)

-- Configure your Primarie coordinates here
local PRIMARIE_SPAWN = {
    x = 0,
    y = 0,
    z = 3,
    rot = 0
}

local function applyCharacterToPlayer(player, charData)
    if not isElement(player) then return end
    setElementData(player, "character", charData)
end

function spawnAtPrimarie(player, charData)
    if not isElement(player) then return false end
    -- Simple skin mapping (mirror wave_character fallback)
    local skin = 0
    if charData and charData.gender and string.lower(charData.gender):find("fem") then
        skin = 6
    else
        skin = 0
    end
    spawnPlayer(player, PRIMARIE_SPAWN.x, PRIMARIE_SPAWN.y, PRIMARIE_SPAWN.z, PRIMARIE_SPAWN.rot or 0, skin)
    applyCharacterToPlayer(player, charData)
    -- Tell client the character was applied so GUI can unfreeze/unload
    triggerClientEvent(player, "wave_character:applied", resourceRoot, charData)
    return true
end

-- Make available as an export
_G.exports = _G.exports or {}
if not exports then exports = {} end
exports.spawnAtPrimarie = spawnAtPrimarie

-- Also provide an admin command to set spawn coords (for server admins)
addCommandHandler("setprimariespawn", function(player, cmd, x, y, z, rot)
    if not isObjectInACLGroup("user."..getAccountName(getPlayerAccount(player)), aclGetGroup("Admin")) then
        outputChatBox("Nu ai permisiunea.", player)
        return
    end
    x = tonumber(x); y = tonumber(y); z = tonumber(z); rot = tonumber(rot) or 0
    if not (x and y and z) then
        outputChatBox("Folosire: /setprimariespawn x y z [rot]")
        return
    end
    PRIMARIE_SPAWN.x = x
    PRIMARIE_SPAWN.y = y
    PRIMARIE_SPAWN.z = z
    PRIMARIE_SPAWN.rot = rot
    outputChatBox("Primarie spawn actualizat.", player)
end)

-- For legacy compatibility, allow other resources to call via exports.wave_spawn.spawnAtPrimarie
function getPrimarieSpawn()
    return PRIMARIE_SPAWN.x, PRIMARIE_SPAWN.y, PRIMARIE_SPAWN.z, PRIMARIE_SPAWN.rot
end
exports.getPrimarieSpawn = getPrimarieSpawn
