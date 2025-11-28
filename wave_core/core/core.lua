-- Wave Romania Roleplay - Core System
-- Main initialization file for the Wave Core resource

-- =====================================================
-- Global Variables
-- =====================================================

_CONFIG = nil
_CORE_INITIALIZED = false

-- =====================================================
-- Configuration Loading
-- =====================================================

--- Load configuration from XML
-- @return config element or nil
function loadConfig()
    local configFile = fileOpen("config/config.xml")
    
    if not configFile then
        print("[CORE ERROR] Config file not found: config/config.xml")
        return nil
    end
    
    fileClose(configFile)
    
    local config = xmlLoadFile("config/config.xml")
    if not config then
        print("[CORE ERROR] Failed to load config file")
        return nil
    end
    
    _CONFIG = config
    return config
end

--- Get configuration
-- @return config element
function getConfig()
    return _CONFIG
end

--- Get config value
-- @param parentName: parent element name
-- @param valueName: value element name or attribute
-- @return value or nil
function getConfigValue(parentName, valueName)
    if not _CONFIG then
        return nil
    end
    
    local parent = _CONFIG:findChild(parentName)
    if not parent then
        return nil
    end
    
    -- Try as child element
    local child = parent:findChild(valueName)
    if child then
        return child:getValue()
    end
    
    -- Try as attribute
    return parent:getAttribute(valueName)
end

-- =====================================================
-- Module Loading
-- =====================================================

--- Load Lua modules in order
-- @return boolean success
function loadModules()
    print("[CORE] Loading core modules...")
    
    local modules = {
        "core/database.lua",
        "core/permissions.lua",
        "core/priority.lua",
        "core/groups.lua",
        "core/commands.lua",
        "core/ui.lua",
        "core/factions.lua",
        "core/vip.lua",
        "core/donator.lua",
        "utils/utils.lua"
    }
    
    for _, modulePath in ipairs(modules) do
        local moduleFile = fileOpen(modulePath)
        
        if not moduleFile then
            print("[CORE ERROR] Module not found: " .. modulePath)
            fileClose(moduleFile)
            return false
        end
        
        fileClose(moduleFile)
        
        local result = loadstring(fileGetContents(modulePath), modulePath)
        if result then
            local success, err = pcall(result)
            if not success then
                print("[CORE ERROR] Failed to load " .. modulePath .. ": " .. tostring(err))
                return false
            end
            print("[CORE] Loaded module: " .. modulePath)
        else
            print("[CORE ERROR] Failed to compile " .. modulePath)
            return false
        end
    end
    
    return true
end

-- =====================================================
-- Core Initialization
-- =====================================================

--- Initialize the core system
function initializeCore()
    if _CORE_INITIALIZED then
        print("[CORE] Core already initialized")
        return true
    end
    
    print("[CORE] Initializing Wave Core System...")
    
    -- Load configuration
    if not loadConfig() then
        print("[CORE FATAL] Failed to load configuration")
        return false
    end
    print("[CORE] Configuration loaded successfully")
    
    -- Load modules
    if not loadModules() then
        print("[CORE FATAL] Failed to load modules")
        return false
    end
    print("[CORE] All modules loaded successfully")
    
    -- Initialize database
    local dbConfig = {
        host = getConfigValue("database", "host") or "localhost",
        port = tonumber(getConfigValue("database", "port")) or 3306,
        username = getConfigValue("database", "username") or "root",
        password = getConfigValue("database", "password") or "password",
        database = getConfigValue("database", "database") or "wave_roleplay"
    }
    
    if not initializeDatabase(dbConfig) then
        print("[CORE WARNING] Database initialization returned false (may be expected if MySQL not available)")
    end
    
    -- Initialize subsystems
    initializePermissions()
    initializePriority()
    initializeGroups()
    initializeUI()
    initializeFactions()
    initializeVIP()
    initializeDonator()
    
    -- Register default commands
    registerDefaultCommands()
    
    _CORE_INITIALIZED = true
    print("[CORE] Wave Core System initialized successfully!")
    
    return true
end

-- =====================================================
-- Server Info
-- =====================================================

--- Get server name
-- @return server name
function getServerName()
    return getConfigValue("server", "name") or "Wave Romania Roleplay"
end

--- Get server version
-- @return server version
function getServerVersion()
    return getConfigValue("server", "version") or "1.0.0"
end

--- Get max players
-- @return max players count
function getMaxPlayers()
    return tonumber(getConfigValue("server", "maxplayers")) or 256
end

-- =====================================================
-- Event Handlers
-- =====================================================

--- Initialize on resource start
addEventHandler("onResourceStart", resourceRoot, function()
    initializeCore()
end)

--- Cleanup on resource stop
addEventHandler("onResourceStop", resourceRoot, function()
    print("[CORE] Shutting down Wave Core System...")
    
    -- Cleanup
    clearAllPermissionCaches()
    clearAllPriorityCaches()
    clearAllGroupCaches()
    clearAllVIPCaches()
    clearAllDonatorCaches()
    
    if _CONFIG then
        xmlUnloadFile(_CONFIG)
    end
    
    print("[CORE] Wave Core System shut down")
end)

--- Player join event
addEventHandler("onPlayerJoin", getRootElement(), function()
    local player = source
    local playerName = getPlayerName(player)
    
    print("[CORE] Player joined: " .. playerName)
    
    -- Load player data (would be connected to database here)
    -- For now, set default group
    if not getElementData(player, "player:id") then
        setElementData(player, "player:id", #getElementsByType("player"))
    end
    
    if not getPlayerGroup(player) then
        setPlayerGroup(player, "user")
    end
end)

--- Player command event
addEventHandler("onPlayerCommand", getRootElement(), function(command, args)
    -- This is handled in commands.lua via executeCoreCommand
end)

return true
