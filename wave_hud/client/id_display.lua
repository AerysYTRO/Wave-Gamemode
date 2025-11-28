-- Wave Romania Roleplay - ID Display System (Client-side)
-- Shows player ID above head when pressing DELETE key

-- =====================================================
-- ID Display Configuration
-- =====================================================

local IDDisplay = {
    isEnabled = true,
    showAboveHead = true,
    displayDistance = 50, -- meters
    screenX = 0,
    screenY = 0,
    fontSize = 1.0,
    color = {
        r = 0,
        g = 102,
        b = 255,
        a = 255
    },
    shadowColor = {
        r = 0,
        g = 0,
        b = 0,
        a =200
    },
    backgroundColor = {
        r = 0,
        g = 0,
        b = 0,
        a = 100
    }
}

-- =====================================================
-- Initialize ID Display
-- =====================================================

function IDDisplay:initialize()
    print("[ID Display] Initializing ID display system...")
    
    -- Setup key binding
    self:setupKeyBinds()
    
    -- Setup rendering
    self:setupRendering()
    
    print("[ID Display] ID display system initialized")
end

-- =====================================================
-- Setup Key Binds
-- =====================================================

function IDDisplay:setupKeyBinds()
    -- Bind DELETE key to toggle ID display
    bindKey("delete", "down", function()
        IDDisplay:toggleIDDisplay()
    end)
end

-- =====================================================
-- Toggle ID Display
-- =====================================================

function IDDisplay:toggleIDDisplay()
    self.isEnabled = not self.isEnabled
    
    if self.isEnabled then
        print("[ID Display] Player ID display enabled")
    else
        print("[ID Display] Player ID display disabled")
    end
end

-- =====================================================
-- Setup Rendering
-- =====================================================

function IDDisplay:setupRendering()
    -- Add render handler
    addEventHandler("onClientRender", getRootElement(), function()
        IDDisplay:render()
    end)
end

-- =====================================================
-- Render
-- =====================================================

function IDDisplay:render()
    if not self.isEnabled then return end
    
    local player = getLocalPlayer()
    if not player or not isElement(player) then return end
    
    -- Draw ID above all players
    for _, targetPlayer in ipairs(getElementsByType("player")) do
        if isElement(targetPlayer) and targetPlayer ~= player then
            self:drawPlayerID(targetPlayer)
        end
    end
    
    -- Draw own ID in center of screen
    self:drawOwnID(player)
end

-- =====================================================
-- Draw Player ID Above Head
-- =====================================================

function IDDisplay:drawPlayerID(targetPlayer)
    if not isElement(targetPlayer) then return end
    
    -- Get player position
    local x, y, z = getElementPosition(targetPlayer)
    if not x then return end
    
    -- Get camera position
    local camX, camY, camZ = getCameraMatrix()
    
    -- Calculate distance
    local distance = getDistanceBetweenPoints3D(camX, camY, camZ, x, y, z)
    
    -- Only show if within distance
    if distance > self.displayDistance then return end
    
    -- Convert world position to screen position (above head)
    local screenX, screenY = getScreenFromWorldPosition(x, y, z + 1)
    
    if not screenX then return end
    
    -- Get player ID
    local playerID = getElementData(targetPlayer, "player:id") or 0
    local playerName = getPlayerName(targetPlayer)
    local displayText = "[" .. playerID .. "] " .. playerName
    
    -- Draw ID
    self:drawIDText(displayText, screenX, screenY, distance)
end

-- =====================================================
-- Draw Own ID (Center of Screen)
-- =====================================================

function IDDisplay:drawOwnID(player)
    if not isElement(player) then return end
    
    local playerID = getElementData(player, "player:id") or 0
    local playerName = getPlayerName(player)
    local displayText = "YOUR ID: [" .. playerID .. "] " .. playerName
    
    local screenWidth = guiGetScreenSize()
    local screenHeight = select(2, guiGetScreenSize())
    
    -- Draw at top center of screen
    self:drawIDText(displayText, screenWidth / 2, screenHeight * 0.05, 0)
end

-- =====================================================
-- Draw ID Text with Effects
-- =====================================================

function IDDisplay:drawIDText(text, screenX, screenY, distance)
    -- Calculate opacity based on distance
    local opacity = 1.0
    if distance > 0 then
        opacity = math.max(0.5, 1.0 - (distance / self.displayDistance) * 0.5)
    end
    
    -- Adjust alpha based on distance
    local alpha = self.color.a * opacity
    local shadowAlpha = self.shadowColor.a * opacity
    local bgAlpha = self.backgroundColor.a * opacity
    
    -- Text properties
    local scale = 1.2
    
    -- Calculate text width for background
    local textWidth = dxGetTextWidth(text, scale, "default-bold")
    local textHeight = dxGetFontHeight(scale, "default-bold")
    
    -- Draw background rectangle
    dxDrawRectangle(
        screenX - (textWidth + 20) / 2,
        screenY - textHeight - 10,
        textWidth + 20,
        textHeight + 10,
        tocolor(self.backgroundColor.r, self.backgroundColor.g, self.backgroundColor.b, bgAlpha)
    )
    
    -- Draw border
    dxDrawRectangle(
        screenX - (textWidth + 20) / 2,
        screenY - textHeight - 10,
        textWidth + 20,
        textHeight + 10,
        tocolor(self.color.r, self.color.g, self.color.b, alpha),
        1
    )
    
    -- Draw shadow
    dxDrawText(
        text,
        screenX - textWidth / 2 + 1,
        screenY - textHeight + 1,
        screenX + textWidth / 2,
        screenY + 5,
        tocolor(self.shadowColor.r, self.shadowColor.g, self.shadowColor.b, shadowAlpha),
        scale,
        "default-bold",
        "center",
        "center"
    )
    
    -- Draw text
    dxDrawText(
        text,
        screenX - textWidth / 2,
        screenY - textHeight,
        screenX + textWidth / 2,
        screenY + 5,
        tocolor(self.color.r, self.color.g, self.color.b, alpha),
        scale,
        "default-bold",
        "center",
        "center"
    )
end

-- =====================================================
-- Helper Functions
-- =====================================================

function getScreenFromWorldPosition(x, y, z)
    local screenX, screenY = getScreenFromWorldPosition(x, y, z)
    return screenX, screenY
end

-- =====================================================
-- Shutdown
-- =====================================================

function IDDisplay:shutdown()
    unbindKey("delete", "down")
    print("[ID Display] ID display system shutdown")
end

-- =====================================================
-- Initialize on resource start
-- =====================================================

addEventHandler("onClientResourceStart", getResourceRootElement(getThisResource()), function()
    setTimer(function()
        IDDisplay:initialize()
    end, 500)
end)

addEventHandler("onClientResourceStop", getResourceRootElement(getThisResource()), function()
    IDDisplay:shutdown()
end)

return true
