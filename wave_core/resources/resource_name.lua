-- Wave Romania Roleplay - Default Resource File
-- This file serves as a template for extending the Wave Core system
-- You can use this as a starting point for creating your own resources

-- =====================================================
-- Resource Initialization
-- =====================================================

print("[RESOURCE] Loading example resource...")

-- =====================================================
-- Example Custom Commands
-- =====================================================

-- Get Wave Core exports
local waveCore = exports.wave_core

-- Example: Custom admin command
if waveCore then
    -- Add a custom command
    waveCore:addCoreCommand("example", "admin.manage_players", function(player, args)
        waveCore:sendSuccessMessage(player, "This is an example command!")
    end, "Example command - requires admin permissions")
    
    print("[RESOURCE] Example commands registered")
end

-- =====================================================
-- Example Event Handlers
-- =====================================================

-- Listen to player VIP grant event
addEventHandler("onPlayerVIPGranted", getRootElement(), function()
    local playerName = getPlayerName(source)
    print("[RESOURCE] Player became VIP: " .. playerName)
    -- Add custom VIP effects here
end)

-- Listen to donator bonus event
addEventHandler("onDonatorBonus", getRootElement(), function(bonusType, amount)
    local playerName = getPlayerName(source)
    print("[RESOURCE] Player received donator bonus: " .. playerName .. " - " .. bonusType .. ": " .. amount)
    -- Handle donator bonuses here
end)

-- =====================================================
-- Example: Custom Faction Command
-- =====================================================

if waveCore then
    waveCore:addCoreCommand("myfaction", "basic.chat", function(player, args)
        local faction = waveCore:getPlayerFaction(player)
        
        if not faction then
            waveCore:sendErrorMessage(player, "You are not in a faction.")
            return
        end
        
        local members = waveCore:getFactionMembers(faction)
        waveCore:sendInfoMessage(player, "=== " .. faction .. " ===")
        waveCore:sendPlayerMessage(player, "Members: " .. #members)
        waveCore:sendPlayerMessage(player, "Leader: " .. waveCore:getFactionLeader(faction))
    end, "View your faction info")
end

print("[RESOURCE] Resource loaded successfully!")

return true
