-- Wave Romania Roleplay - Exports Module
-- Exports all public functions for use by other resources

-- =====================================================
-- Permissions Exports
-- =====================================================

exports.hasPermission = hasPermission
exports.hasAnyPermission = hasAnyPermission
exports.hasAllPermissions = hasAllPermissions
exports.getPlayerPermissions = getPlayerPermissions
exports.addPlayerPermission = addPlayerPermission
exports.removePlayerPermission = removePlayerPermission
exports.clearPlayerPermissions = clearPlayerPermissions

-- =====================================================
-- Priority Exports
-- =====================================================

exports.getPlayerPriority = getPlayerPriority
exports.setPlayerPriority = setPlayerPriority
exports.incrementPlayerPriority = incrementPlayerPriority
exports.decrementPlayerPriority = decrementPlayerPriority
exports.comparePriority = comparePriority
exports.hasHigherPriority = hasHigherPriority
exports.hasMinimumPriority = hasMinimumPriority
exports.addToQueueByPriority = addToQueueByPriority
exports.getNextFromQueue = getNextFromQueue
exports.getQueueSize = getQueueSize

-- =====================================================
-- Groups Exports
-- =====================================================

exports.getPlayerGroup = getPlayerGroup
exports.setPlayerGroup = setPlayerGroup
exports.isGroupExists = isGroupExists
exports.getGroupInfo = getGroupInfo
exports.getAllGroups = getAllGroups
exports.getGroupPermissions = getGroupPermissions
exports.groupHasPermission = groupHasPermission
exports.getGroupPriority = getGroupPriority
exports.getPlayersInGroup = getPlayersInGroup
exports.countPlayersInGroup = countPlayersInGroup
exports.setGroupForPlayers = setGroupForPlayers
exports.rankPlayersByGroup = rankPlayersByGroup

-- =====================================================
-- Commands Exports
-- =====================================================

exports.addCoreCommand = addCoreCommand
exports.getCommandInfo = getCommandInfo
exports.getAllCommands = getAllCommands
exports.removeCommand = removeCommand
exports.executeCoreCommand = executeCoreCommand

-- =====================================================
-- UI Exports
-- =====================================================

exports.openUI = openUI
exports.closeUI = closeUI
exports.closeUIAll = closeUIAll
exports.hasUIOpen = hasUIOpen
exports.getPlayerOpenUI = getPlayerOpenUI
exports.sendUIData = sendUIData
exports.getUIData = getUIData
exports.notifyUI = notifyUI
exports.notifyUIAll = notifyUIAll
exports.showNotification = showNotification
exports.showDialog = showDialog
exports.showConfirmDialog = showConfirmDialog
exports.showMessageBox = showMessageBox

-- =====================================================
-- Database Exports
-- =====================================================

exports.dbQueryAsync = dbQueryAsync
exports.dbExecSync = dbExecSync
exports.getPlayerData = getPlayerData
exports.createPlayerRecord = createPlayerRecord
exports.updatePlayerLastLogin = updatePlayerLastLogin
exports.getPlayerGroupDB = getPlayerGroupDB
exports.setPlayerGroupDB = setPlayerGroupDB
exports.getPlayerPriorityDB = getPlayerPriorityDB
exports.setPlayerPriorityDB = setPlayerPriorityDB
exports.getPlayerPermissionsDB = getPlayerPermissionsDB
exports.addPlayerPermissionDB = addPlayerPermissionDB
exports.removePlayerPermissionDB = removePlayerPermissionDB
exports.logActionDB = logActionDB

-- =====================================================
-- Factions Exports
-- =====================================================

exports.addFaction = addFaction
exports.getFaction = getFaction
exports.getAllFactions = getAllFactions
exports.deleteFaction = deleteFaction
exports.getPlayerFaction = getPlayerFaction
exports.getFactionMembers = getFactionMembers
exports.assignFactionMember = assignFactionMember
exports.removeFactionMember = removeFactionMember
exports.isPlayerInFaction = isPlayerInFaction
exports.getFactionMemberCount = getFactionMemberCount
exports.getFactionPermissions = getFactionPermissions
exports.addFactionPermission = addFactionPermission
exports.factionHasPermission = factionHasPermission
exports.setFactionLeader = setFactionLeader
exports.getFactionLeader = getFactionLeader
exports.triggerFactionEvent = triggerFactionEvent

-- =====================================================
-- VIP Exports
-- =====================================================

exports.isVIP = isVIP
exports.setVIP = setVIP
exports.isVIPExpired = isVIPExpired
exports.getVIPRemainingTime = getVIPRemainingTime
exports.grantVIPPermissions = grantVIPPermissions
exports.revokeVIPPermissions = revokeVIPPermissions
exports.getVIPFeature = getVIPFeature
exports.isVIPFeatureEnabled = isVIPFeatureEnabled
exports.giveVIPBonus = giveVIPBonus
exports.getVIPPlayersOnline = getVIPPlayersOnline
exports.sendVIPMessage = sendVIPMessage
exports.loadVIPConfig = loadVIPConfig

-- =====================================================
-- Donator Exports
-- =====================================================

exports.isDonator = isDonator
exports.setDonator = setDonator
exports.getDonatorTier = getDonatorTier
exports.grantDonatorPermissions = grantDonatorPermissions
exports.revokeDonatorPermissions = revokeDonatorPermissions
exports.getDonatorBenefits = getDonatorBenefits
exports.getDonatorTierCost = getDonatorTierCost
exports.claimDonatorReward = claimDonatorReward
exports.giveDonatorBonus = giveDonatorBonus
exports.getDonatorPlayersOnline = getDonatorPlayersOnline
exports.getDonatorsByTier = getDonatorsByTier
exports.sendDonatorMessage = sendDonatorMessage
exports.loadDonatorConfig = loadDonatorConfig

-- =====================================================
-- Utility Exports
-- =====================================================

exports.titleCase = titleCase
exports.trim = trim
exports.splitString = splitString
exports.tableContains = tableContains
exports.tableCount = tableCount
exports.tableMerge = tableMerge
exports.getPlayerByPartialName = getPlayerByPartialName
exports.getOnlinePlayers = getOnlinePlayers
exports.isPlayerOnline = isPlayerOnline
exports.sendPlayerMessage = sendPlayerMessage
exports.sendSuccessMessage = sendSuccessMessage
exports.sendErrorMessage = sendErrorMessage
exports.sendInfoMessage = sendInfoMessage
exports.sendWarningMessage = sendWarningMessage
exports.broadcastMessage = broadcastMessage
exports.getCurrentTimestamp = getCurrentTimestamp
exports.formatTimestamp = formatTimestamp
exports.hasExpired = hasExpired
exports.getTimeDifference = getTimeDifference
exports.logMessage = logMessage
exports.debugLog = debugLog
exports.isValidEmail = isValidEmail
exports.isNumeric = isNumeric
exports.isValidPlayerName = isValidPlayerName
exports.clamp = clamp
exports.roundNumber = roundNumber
exports.getPercentage = getPercentage
exports.getDistance3D = getDistance3D
exports.getDistance2D = getDistance2D

-- =====================================================
-- Core Configuration Exports
-- =====================================================

exports.getConfig = getConfig
exports.getConfigValue = getConfigValue
exports.getServerName = getServerName
exports.getServerVersion = getServerVersion
exports.getMaxPlayers = getMaxPlayers

return true
