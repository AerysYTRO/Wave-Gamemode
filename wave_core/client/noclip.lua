-- Wave Romania Roleplay - Noclip Handler (Client-side)
-- Manages noclip movement for admin users

local noclipSpeed = 0.5
local noclipActive = false
local camera = getCameraTarget()

-- =====================================================
-- Initialize Noclip
-- =====================================================

function initializeNoclip()
    print("[NOCLIP] Noclip system initialized")
    addEventHandler("onClientRender", getRootElement(), handleNoclip)
end

-- =====================================================
-- Handle Noclip
-- =====================================================

function handleNoclip()
    local player = getLocalPlayer()
    if not isElement(player) then return end
    
    noclipActive = getElementData(player, "player:noclip") or false
    
    if not noclipActive then
        return
    end
    
    -- Get camera position and rotation
    local camX, camY, camZ = getCameraMatrix()
    local camRot = getCamera():getRotation()
    
    -- Get movement keys
    local moveForward = getKeyState("w") or getKeyState("up")
    local moveBackward = getKeyState("s") or getKeyState("down")
    local moveLeft = getKeyState("a") or getKeyState("left")
    local moveRight = getKeyState("d") or getKeyState("right")
    local moveUp = getKeyState("space")
    local moveDown = getKeyState("lctrl") or getKeyState("rctrl")
    
    -- Calculate new position
    local newX, newY, newZ = camX, camY, camZ
    
    if moveForward then
        newX = newX + math.sin(math.rad(camRot)) * noclipSpeed
        newY = newY - math.cos(math.rad(camRot)) * noclipSpeed
    end
    
    if moveBackward then
        newX = newX - math.sin(math.rad(camRot)) * noclipSpeed
        newY = newY + math.cos(math.rad(camRot)) * noclipSpeed
    end
    
    if moveLeft then
        newX = newX - math.cos(math.rad(camRot)) * noclipSpeed
        newY = newY - math.sin(math.rad(camRot)) * noclipSpeed
    end
    
    if moveRight then
        newX = newX + math.cos(math.rad(camRot)) * noclipSpeed
        newY = newY + math.sin(math.rad(camRot)) * noclipSpeed
    end
    
    if moveUp then
        newZ = newZ + noclipSpeed
    end
    
    if moveDown then
        newZ = newZ - noclipSpeed
    end
    
    -- Update camera position if changed
    if newX ~= camX or newY ~= camY or newZ ~= camZ then
        getCameraMatrix = function() return newX, newY, newZ end
    end
end

-- =====================================================
-- Speed Control
-- =====================================================

--- Set noclip speed
function setNoclipSpeed(speed)
    if speed and speed > 0 then
        noclipSpeed = speed
    end
end

--- Get noclip speed
function getNoclipSpeed()
    return noclipSpeed
end

-- =====================================================
-- Initialize on resource start
-- =====================================================

addEventHandler("onClientResourceStart", getResourceRootElement(getThisResource()), function()
    initializeNoclip()
end)

return true
