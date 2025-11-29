-- wave_character/client.lua
-- Client GUI for creating and selecting characters

local createWindow = nil
local selectWindow = nil
local characters = {}

local function createCreateWindow()
    if isElement(createWindow) then return end
    local sx, sy = guiGetScreenSize()
    local w, h = 420, 420
    createWindow = guiCreateWindow((sx-w)/2, (sy-h)/2, w, h, "Creeaza Character", false)
    guiWindowSetSizable(createWindow, false)

    guiCreateLabel(0.05, 0.08, 0.4, 0.07, "Numele Prenumele:", true, createWindow)
    local nameEdit = guiCreateEdit(0.05, 0.15, 0.9, 0.07, "", true, createWindow)

    guiCreateLabel(0.05, 0.24, 0.2, 0.07, "Varsta:", true, createWindow)
    local ageEdit = guiCreateEdit(0.25, 0.24, 0.2, 0.07, "18", true, createWindow)

    guiCreateLabel(0.05, 0.33, 0.45, 0.07, "Rasa:", true, createWindow)
    local whiteRadio = guiCreateRadioButton(0.05, 0.40, 0.45, 0.06, "Alb", true, createWindow)
    local blackRadio = guiCreateRadioButton(0.5, 0.40, 0.45, 0.06, "Negru", true, createWindow)
    guiRadioButtonSetSelected(whiteRadio, true)

    guiCreateLabel(0.05, 0.47, 0.45, 0.07, "Sex:", true, createWindow)
    local maleRadio = guiCreateRadioButton(0.05, 0.54, 0.45, 0.06, "Barbat", true, createWindow)
    local femaleRadio = guiCreateRadioButton(0.5, 0.54, 0.45, 0.06, "Femeie", true, createWindow)
    guiRadioButtonSetSelected(maleRadio, true)

    guiCreateLabel(0.05, 0.62, 0.4, 0.07, "Povestea characterului:", true, createWindow)
    local story = guiCreateMemo(0.05, 0.69, 0.9, 0.15, "", true, createWindow)

    guiCreateLabel(0.05, 0.85, 0.2, 0.07, "Greutate (kg):", true, createWindow)
    local weightEdit = guiCreateEdit(0.25, 0.85, 0.2, 0.07, "75", true, createWindow)
    guiCreateLabel(0.5, 0.85, 0.2, 0.07, "Inaltime (cm):", true, createWindow)
    local heightEdit = guiCreateEdit(0.7, 0.85, 0.25, 0.07, "180", true, createWindow)

    local saveBtn = guiCreateButton(0.05, 0.93, 0.45, 0.06, "Salveaza", true, createWindow)
    local cancelBtn = guiCreateButton(0.5, 0.93, 0.45, 0.06, "Inchide", true, createWindow)

    addEventHandler("onClientGUIClick", saveBtn, function()
        local name = guiGetText(nameEdit)
        local age = guiGetText(ageEdit)
        local race = guiRadioButtonGetSelected(whiteRadio) and "Alb" or "Negru"
        local gender = guiRadioButtonGetSelected(maleRadio) and "Barbat" or "Femeie"
        local storyText = guiGetText(story)
        local weight = guiGetText(weightEdit)
        local height = guiGetText(heightEdit)
        if name == "" then
            outputChatBox("Introdu un nume valid.")
            return
        end
        local data = { name = name, age = age, race = race, gender = gender, story = storyText, weight = weight, height = height }
        triggerServerEvent("wave_character:saveCharacter", resourceRoot, data)
    end, false)

    addEventHandler("onClientGUIClick", cancelBtn, function()
        destroyElement(createWindow)
        createWindow = nil
    end, false)
end

local function createSelectWindow()
    if isElement(selectWindow) then return end
    local sx, sy = guiGetScreenSize()
    local w, h = 600, 350
    selectWindow = guiCreateWindow((sx-w)/2, (sy-h)/2, w, h, "Selecteaza Character", false)
    guiWindowSetSizable(selectWindow, false)

    local grid = guiCreateGridList(0.03, 0.08, 0.94, 0.72, true, selectWindow)
    guiGridListAddColumn(grid, "ID", 0.08)
    guiGridListAddColumn(grid, "Nume", 0.25)
    guiGridListAddColumn(grid, "Varsta", 0.1)
    guiGridListAddColumn(grid, "Rasa", 0.12)
    guiGridListAddColumn(grid, "Sex", 0.12)
    guiGridListAddColumn(grid, "Greutate", 0.12)
    guiGridListAddColumn(grid, "Inaltime", 0.12)

    local selectBtn = guiCreateButton(0.05, 0.82, 0.28, 0.12, "Selecteaza", true, selectWindow)
    local newBtn = guiCreateButton(0.37, 0.82, 0.28, 0.12, "Creeaza Nou", true, selectWindow)
    local closeBtn = guiCreateButton(0.69, 0.82, 0.28, 0.12, "Inchide", true, selectWindow)

    addEventHandler("onClientGUIClick", newBtn, function()
        if #characters >= 5 then
            outputChatBox("Ai deja 5 caractere maxime.")
            return
        end
        createCreateWindow()
    end, false)

    addEventHandler("onClientGUIClick", closeBtn, function()
        destroyElement(selectWindow)
        selectWindow = nil
    end, false)

    addEventHandler("onClientGUIClick", selectBtn, function()
        local row, col = guiGridListGetSelectedItem(grid)
        if row == -1 then
            outputChatBox("Selecteaza un character din lista.")
            return
        end
        local id = guiGridListGetItemText(grid, row, 1)
        triggerServerEvent("wave_character:selectCharacter", resourceRoot, tonumber(id))
    end, false)

    -- fill function
    local function fillGrid()
        guiGridListClear(grid)
        for _, c in ipairs(characters) do
            local row = guiGridListAddRow(grid)
            guiGridListSetItemText(grid, row, 1, tostring(c.id or ""), false, false)
            guiGridListSetItemText(grid, row, 2, tostring(c.name or ""), false, false)
            guiGridListSetItemText(grid, row, 3, tostring(c.age or ""), false, false)
            guiGridListSetItemText(grid, row, 4, tostring(c.race or ""), false, false)
            guiGridListSetItemText(grid, row, 5, tostring(c.gender or ""), false, false)
            guiGridListSetItemText(grid, row, 6, tostring(c.weight or ""), false, false)
            guiGridListSetItemText(grid, row, 7, tostring(c.height or ""), false, false)
        end
    end

    -- expose local fill
    selectWindow.fillGrid = fillGrid
end

-- Events from server
addEvent("wave_character:openCreator", true)
addEventHandler("wave_character:openCreator", root, function()
    createCreateWindow()
    -- small visual: freeze player and fade camera
    toggleControl("enter_exit", false)
    setElementFrozen(localPlayer, true)
    fadeCamera(false, 0.5)
    setTimer(function()
        fadeCamera(true, 0.5)
    end, 600, 1)
end)

addEvent("wave_character:list", true)
addEventHandler("wave_character:list", root, function(chars)
    characters = chars or {}
    if not isElement(selectWindow) then
        createSelectWindow()
    end
    selectWindow.fillGrid()
end)

addEvent("wave_character:notify", true)
addEventHandler("wave_character:notify", root, function(ok, text)
    if ok then
        outputChatBox("[CHAR] "..tostring(text))
        if isElement(createWindow) then
            destroyElement(createWindow)
            createWindow = nil
        end
    else
        outputChatBox("[CHAR] Erorr: "..tostring(text))
    end
end)

addEvent("wave_character:applied", true)
addEventHandler("wave_character:applied", root, function(data)
    -- close GUIs and unfreeze
    if isElement(selectWindow) then destroyElement(selectWindow); selectWindow = nil end
    if isElement(createWindow) then destroyElement(createWindow); createWindow = nil end
    setElementFrozen(localPlayer, false)
    toggleControl("enter_exit", true)
    fadeCamera(false, 0.4)
    setTimer(function()
        fadeCamera(true, 0.6)
    end, 600, 1)
    outputChatBox("Character selectat: "..tostring((data.name or "")))
end)

-- Expose a key to open the menu for testing (F6)
-- Manual test binding removed: character menu opens automatically on join
