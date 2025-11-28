/**
 * Wave Romania HUD - JavaScript Frontend
 * Handles real-time HUD data updates and animations
 */

// =====================================================
// HUD Data Object
// =====================================================

const HUDData = {
    playerID: 0,
    playerName: 'Unknown',
    bankMoney: 0,
    cashMoney: 0,
    factionName: 'None',
    groupName: 'user',
    health: 100,
    armor: 0,
    energy: 100
};

// =====================================================
// DOM Elements Cache
// =====================================================

const HUDElements = {
    playerID: null,
    playerName: null,
    bankMoney: null,
    cashMoney: null,
    factionName: null,
    groupName: null,
    healthValue: null,
    healthBar: null,
    armorValue: null,
    armorBar: null,
    energyValue: null,
    energyBar: null,
    loadingIndicator: null
};

// =====================================================
// Initialize HUD
// =====================================================

document.addEventListener('DOMContentLoaded', function() {
    initializeHUD();
});

function initializeHUD() {
    console.log('[HUD] Initializing HUD system...');
    
    // Cache DOM elements
    cacheElements();
    
    // Setup communication with Lua
    setupLuaCommunication();
    
    // Initialize data update loop
    startDataUpdateLoop();
    
    console.log('[HUD] HUD system initialized successfully');
}

// =====================================================
// Cache DOM Elements
// =====================================================

function cacheElements() {
    HUDElements.playerID = document.getElementById('playerID');
    HUDElements.playerName = document.getElementById('playerName');
    HUDElements.bankMoney = document.getElementById('bankMoney');
    HUDElements.cashMoney = document.getElementById('cashMoney');
    HUDElements.factionName = document.getElementById('factionName');
    HUDElements.groupName = document.getElementById('groupName');
    HUDElements.healthValue = document.getElementById('healthValue');
    HUDElements.healthBar = document.getElementById('healthBar');
    HUDElements.armorValue = document.getElementById('armorValue');
    HUDElements.armorBar = document.getElementById('armorBar');
    HUDElements.energyValue = document.getElementById('energyValue');
    HUDElements.energyBar = document.getElementById('energyBar');
    HUDElements.loadingIndicator = document.getElementById('loadingIndicator');
}

// =====================================================
// Lua Communication
// =====================================================

function setupLuaCommunication() {
    // MTA CEF bridge event handlers
    // These will be called from the Lua client script
    
    if (typeof window.mta !== 'undefined') {
        window.mta.events.add('wave_hud:updateData', function(data) {
            updateHUDData(data);
        });
    }
}

// =====================================================
// Update HUD Data
// =====================================================

function updateHUDData(newData) {
    if (!newData) return;
    
    // Update data object
    HUDData.playerID = newData.id || HUDData.playerID;
    HUDData.playerName = newData.name || HUDData.playerName;
    HUDData.bankMoney = newData.bankMoney || HUDData.bankMoney;
    HUDData.cashMoney = newData.cashMoney || HUDData.cashMoney;
    HUDData.factionName = newData.faction || HUDData.factionName;
    HUDData.groupName = newData.group || HUDData.groupName;
    HUDData.health = newData.health || HUDData.health;
    HUDData.armor = newData.armor || HUDData.armor;
    HUDData.energy = newData.energy || HUDData.energy;
    
    // Render HUD
    renderHUD();
}

// =====================================================
// Render HUD
// =====================================================

function renderHUD() {
    // Update text values
    if (HUDElements.playerID) {
        HUDElements.playerID.textContent = String(HUDData.playerID).padStart(4, '0');
    }
    
    if (HUDElements.playerName) {
        HUDElements.playerName.textContent = HUDData.playerName;
    }
    
    if (HUDElements.bankMoney) {
        HUDElements.bankMoney.textContent = '$' + formatNumber(HUDData.bankMoney);
    }
    
    if (HUDElements.cashMoney) {
        HUDElements.cashMoney.textContent = '$' + formatNumber(HUDData.cashMoney);
    }
    
    if (HUDElements.factionName) {
        HUDElements.factionName.textContent = HUDData.factionName;
    }
    
    if (HUDElements.groupName) {
        HUDElements.groupName.textContent = HUDData.groupName.toUpperCase();
    }
    
    // Update health bar
    updateBar(
        HUDElements.healthBar,
        HUDElements.healthValue,
        HUDData.health,
        100
    );
    
    // Update armor bar
    updateBar(
        HUDElements.armorBar,
        HUDElements.armorValue,
        HUDData.armor,
        100
    );
    
    // Update energy bar
    updateBar(
        HUDElements.energyBar,
        HUDElements.energyValue,
        HUDData.energy,
        100
    );
}

// =====================================================
// Update Bar (Health/Armor/Energy)
// =====================================================

function updateBar(barElement, valueElement, current, max) {
    if (!barElement || !valueElement) return;
    
    const percentage = Math.max(0, Math.min(100, (current / max) * 100));
    
    // Smooth transition
    barElement.style.width = percentage + '%';
    
    // Update value
    valueElement.textContent = Math.floor(current);
    
    // Add pulse animation when low
    if (percentage < 30) {
        barElement.style.animation = 'pulse 0.5s ease-in-out infinite';
    } else {
        barElement.style.animation = 'none';
    }
}

// =====================================================
// Format Number (add commas)
// =====================================================

function formatNumber(num) {
    return num.toString().replace(/\B(?=(\d{3})+(?!\d))/g, ',');
}

// =====================================================
// Data Update Loop
// =====================================================

function startDataUpdateLoop() {
    // Request data from Lua every 500ms
    setInterval(function() {
        requestHUDData();
    }, 500);
}

function requestHUDData() {
    // Call Lua function to get HUD data
    if (typeof window.mta !== 'undefined' && window.mta.triggerEvent) {
        window.mta.triggerEvent('wave_hud:requestData');
    }
}

// =====================================================
// Loading State
// =====================================================

function showLoading() {
    if (HUDElements.loadingIndicator) {
        HUDElements.loadingIndicator.classList.add('active');
    }
}

function hideLoading() {
    if (HUDElements.loadingIndicator) {
        HUDElements.loadingIndicator.classList.remove('active');
    }
}

// =====================================================
// HUD Show/Hide
// =====================================================

function showHUD() {
    const topRight = document.querySelector('.hud-container.top-right');
    const bottomCenter = document.querySelector('.hud-container.bottom-center');
    
    if (topRight) topRight.classList.remove('hud-hidden');
    if (bottomCenter) bottomCenter.classList.remove('hud-hidden');
}

function hideHUD() {
    const topRight = document.querySelector('.hud-container.top-right');
    const bottomCenter = document.querySelector('.hud-container.bottom-center');
    
    if (topRight) topRight.classList.add('hud-hidden');
    if (bottomCenter) bottomCenter.classList.add('hud-hidden');
}

// =====================================================
// Utility Functions for Lua communication
// =====================================================

// Called from Lua when data is available
function onHUDDataReceived(data) {
    updateHUDData(data);
    hideLoading();
}

// Notify Lua that HUD is ready
function notifyHUDReady() {
    if (typeof window.mta !== 'undefined' && window.mta.triggerEvent) {
        window.mta.triggerEvent('wave_hud:ready');
        console.log('[HUD] Notified Lua that HUD is ready');
    }
}

// Initialize once DOM is fully loaded
window.addEventListener('load', function() {
    notifyHUDReady();
    updateHUDData(HUDData); // Show initial data
});
