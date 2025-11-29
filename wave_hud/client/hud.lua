-- Wave Romania Roleplay - HUD System (Client-side)
-- Manages CEF browser rendering and data synchronization

-- =====================================================
-- Configuration
-- =====================================================

local HUD = {
    browser = nil,
    browserURL = "file:///" .. getResourcePath(getThisResource()) .. "/html/hud.html",
    isVisible = true,
    updateInterval = 500,
    resourcePath = getResourcePath(getThisResource())
}

-- =====================================================
-- HUD Initialization
-- =====================================================

function HUD:initialize()
    print("[HUD] Initializing HUD system...")
    
    -- Create CEF browser
    self:createBrowser()
    
    -- Setup events
    self:setupEvents()
    
    -- Setup key binds
    self:setupKeyBinds()
    
    -- Start update loop
    self:startUpdateLoop()
    
    print("[HUD] HUD system initialized successfully")
end

-- =====================================================
-- Create Browser
-- =====================================================

function HUD:createBrowser()
    if self.browser then
        destroyElement(self.browser)
    end
    
    -- Create CEF browser
    self.browser = createBrowser(
        800, -- width
        600, -- height
        false -- remote (local HTML file)
    )
    
    if not self.browser then
        print("[HUD] ERROR: Failed to create browser")
        return false
    end
    
    -- Try to inline HTML/CSS/JS into a data URL so CEF loads reliably
    local function safeRead(path)
        if not fileExists(path) then return nil end
        local f = fileOpen(path)
        if not f then return nil end
        local size = fileGetSize(f)
        local content = fileRead(f, size)
        fileClose(f)
        return content
    end

    local html = safeRead("html/hud.html") or ""
    local css = safeRead("html/hud.css") or ""
    local js = safeRead("html/hud.js") or ""

    -- Inline CSS and JS into the HTML (replace link/script tags if present)
    if html ~= "" then
        -- Replace stylesheet link
        html = html:gsub("<link%s+rel=\"stylesheet\"%s+href=\"hud.css\"%s*/?>", "<style>" .. css .. "</style>")
        -- Replace script tag
        html = html:gsub("<script%s+src=\"hud.js\"%s*></script>", "<script>" .. js .. "</script>")
    else
        -- Fallback minimal html
        html = "<html><head><style>" .. css .. "</style></head><body>" .. js .. "</body></html>"
    end

    -- URL-encode helper for data URI
    local function urlencode(str)
        if not str then return "" end
        local s = str:gsub("([^%w %-%_%.%~])", function(c)
            return string.format("%%%02X", string.byte(c))
        end)
        s = s:gsub(" ", "+")
        return s
    end

    local dataUrl = "data:text/html;charset=utf-8," .. urlencode(html)
    loadBrowserURL(self.browser, dataUrl)

    -- Set browser properties
    setBrowserRenderingPaused(self.browser, false)

    print("[HUD] Browser created successfully (inlined)")
    return true
end

-- =====================================================
-- Setup Events
-- =====================================================

function HUD:setupEvents()
    -- Server events
    addEvent("wave_hud:updateData", true)
    addEventHandler("wave_hud:updateData", getLocalPlayer(), function(data)
        HUD:sendDataToBrowser(data)
    end)
    
    -- Browser load/create events: attach to root and filter by browser element
    addEventHandler("onClientBrowserCreated", root, function(createdBrowser)
        if createdBrowser == HUD.browser then
            print("[HUD] Browser created event triggered")
            HUD:sendDataToBrowser(HUD:getPlayerData())
        end
    end)

    addEventHandler("onClientBrowserDocumentReady", root, function(createdBrowser)
        if createdBrowser == HUD.browser then
            print("[HUD] Browser document ready")
            HUD:sendInitialData()
        end
    end)

    addEventHandler("onClientBrowserCustom", root, function(createdBrowser, event, data)
        if createdBrowser == HUD.browser then
            HUD:handleBrowserEvent(event, data)
        end
    end)
end

-- =====================================================
-- Setup Key Binds
-- =====================================================

function HUD:setupKeyBinds()
    -- Toggle HUD visibility (H key)
    bindKey("h", "down", function()
        HUD:toggleVisibility()
    end)
    
    -- Toggle debug info (F10 key)
    bindKey("F10", "down", function()
        HUD:toggleDebugInfo()
    end)
end

-- =====================================================
-- Get Player Data
-- =====================================================

function HUD:getPlayerData()
    local player = getLocalPlayer()
    if not player then return nil end
    
    -- Get player info
    local playerID = getElementData(player, "player:id") or 0
    local playerName = getPlayerName(player)
    local health = getElementHealth(player)
    local armor = getPedArmor(player)
    
    -- Get faction and group
    local faction = exports.wave_core:getPlayerFaction(player) or "None"
    local group = exports.wave_core:getPlayerGroup(player) or "user"
    
    -- Get money
    local bankMoney = getElementData(player, "bankMoney") or 0
    local cashMoney = getElementData(player, "cashMoney") or 0
    
    -- Create data object
    local data = {
        id = playerID,
        name = playerName,
        bankMoney = bankMoney,
        cashMoney = cashMoney,
        faction = faction,
        group = group,
        health = math.floor(health),
        armor = math.floor(armor),
        energy = 100
    }
    
    return data
end

-- =====================================================
-- Send Data to Browser
-- =====================================================

function HUD:sendDataToBrowser(data)
    if not self.browser or not isElement(self.browser) then
        return
    end
    
    if not data then
        data = self:getPlayerData()
    end
    
    -- Convert to JSON and inject into browser
    local json = toJSON(data)
    local jsCode = "window.updateHUDData(" .. json .. ");"
    
    injectBrowserJavascript(self.browser, jsCode)
end

-- =====================================================
-- Send Initial Data
-- =====================================================

function HUD:sendInitialData()
    local data = self:getPlayerData()
    self:sendDataToBrowser(data)
end

-- =====================================================
-- Handle Browser Events
-- =====================================================

function HUD:handleBrowserEvent(event, ...)
    if event == "ready" then
        print("[HUD] Browser is ready")
        self:sendInitialData()
    elseif event == "requestData" then
        print("[HUD] Browser requested data update")
        self:sendInitialData()
    end
end

-- =====================================================
-- Update Loop
-- =====================================================

function HUD:startUpdateLoop()
    setTimer(function()
        if self.isVisible and self.browser and isElement(self.browser) then
            self:sendDataToBrowser()
        end
    end, self.updateInterval)
end

-- =====================================================
-- Toggle Visibility
-- =====================================================

function HUD:toggleVisibility()
    self.isVisible = not self.isVisible
    
    if self.isVisible then
        print("[HUD] HUD shown")
        if self.browser and isElement(self.browser) then
            injectBrowserJavascript(self.browser, "window.showHUD();")
        end
    else
        print("[HUD] HUD hidden")
        if self.browser and isElement(self.browser) then
            injectBrowserJavascript(self.browser, "window.hideHUD();")
        end
    end
end

-- =====================================================
-- Debug Info
-- =====================================================

function HUD:toggleDebugInfo()
    if not self.browser or not isElement(self.browser) then
        return
    end
    
    local data = self:getPlayerData()
    print("===== HUD DEBUG INFO =====")
    print("Player ID: " .. data.id)
    print("Player Name: " .. data.name)
    print("Faction: " .. data.faction)
    print("Group: " .. data.group)
    print("Bank Money: $" .. data.bankMoney)
    print("Cash Money: $" .. data.cashMoney)
    print("Health: " .. data.health)
    print("Armor: " .. data.armor)
    print("========================")
end

-- =====================================================
-- Shutdown
-- =====================================================

function HUD:shutdown()
    if self.browser and isElement(self.browser) then
        destroyElement(self.browser)
        self.browser = nil
    end
    print("[HUD] HUD system shutdown")
end

-- =====================================================
-- Main Initialize Call
-- =====================================================

addEventHandler("onClientResourceStart", getResourceRootElement(getThisResource()), function()
    setTimer(function()
        HUD:initialize()
    end, 500)
end)

addEventHandler("onClientResourceStop", getResourceRootElement(getThisResource()), function()
    HUD:shutdown()
end)

-- =====================================================
-- Exports
-- =====================================================

function getHUDData()
    return HUD:getPlayerData()
end

function setHUDVisible(visible)
    HUD.isVisible = visible
    if visible then
        if HUD.browser and isElement(HUD.browser) then
            injectBrowserJavascript(HUD.browser, "window.showHUD();")
        end
    else
        if HUD.browser and isElement(HUD.browser) then
            injectBrowserJavascript(HUD.browser, "window.hideHUD();")
        end
    end
end

function updateHUDData(data)
    HUD:sendDataToBrowser(data)
end

return true
