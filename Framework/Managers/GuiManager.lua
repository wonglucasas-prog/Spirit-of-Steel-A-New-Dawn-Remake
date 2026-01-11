local GuiManager = {}

GuiManager.ScreenGuis = {}

function GuiManager.add(key, guiComponent)
    local guiComponents = nil
    if type(guiComponent) == "table" then
        guiComponents = guiComponent
    end

    if not GuiManager.ScreenGuis[key] then
        GuiManager.ScreenGuis[key] = {}
    end

    if guiComponents then
        for _, guiComponent in pairs(guiComponents) do
            table.insert(GuiManager.ScreenGuis[key], guiComponent)
        end
    else
        table.insert(GuiManager.ScreenGuis[key], guiComponent)
    end
    table.sort(GuiManager.ScreenGuis[key], function(a, b)
        return a.zIndex < b.zIndex
    end)
end

function GuiManager.update(key, dt)
    if key and GuiManager.ScreenGuis[key] then
        for _, guiComponent in pairs(GuiManager.ScreenGuis[key]) do
            if guiComponent.update then
                guiComponent:update(dt)
            end
        end
    end
end

function GuiManager.draw(key)
    if key and GuiManager.ScreenGuis[key] then
        for _, guiComponent in pairs(GuiManager.ScreenGuis[key]) do
            if guiComponent.draw then guiComponent:draw() end
        end
    end
end

local GuiManager = {}

GuiManager.ScreenGuis = {}

function GuiManager.add(key, guiComponent)
    local guiComponents = nil
    if type(guiComponent) == "table" then
        guiComponents = guiComponent
    end

    if not GuiManager.ScreenGuis[key] then
        GuiManager.ScreenGuis[key] = {}
    end

    if guiComponents then
        for _, guiComponent in pairs(guiComponents) do
            table.insert(GuiManager.ScreenGuis[key], guiComponent)
        end
    else
        table.insert(GuiManager.ScreenGuis[key], guiComponent)
    end
    table.sort(GuiManager.ScreenGuis[key], function(a, b)
        return a.zIndex < b.zIndex
    end)
end

function GuiManager.update(key, ...)
    if key and GuiManager.ScreenGuis[key] then
        for _, guiComponent in pairs(GuiManager.ScreenGuis[key]) do
            if guiComponent.onUpdate then guiComponent.onUpdate(...) end
        end
    end
end

local GuiManager = {}

GuiManager.ScreenGuis = {}

function GuiManager.add(key, guiComponent)
    local guiComponents = nil
    if type(guiComponent) == "table" then
        guiComponents = guiComponent
    end

    if not GuiManager.ScreenGuis[key] then
        GuiManager.ScreenGuis[key] = {}
    end

    if guiComponents then
        for _, guiComponent in pairs(guiComponents) do
            table.insert(GuiManager.ScreenGuis[key], guiComponent)
        end
    else
        table.insert(GuiManager.ScreenGuis[key], guiComponent)
    end
    table.sort(GuiManager.ScreenGuis[key], function(a, b)
        return a.zIndex < b.zIndex
    end)
end

function GuiManager.update(key)
    if key and GuiManager.ScreenGuis[key] then
        for _, guiComponent in pairs(GuiManager.ScreenGuis[key]) do
            if guiComponent.update then guiComponent:update() end
        end
    end
end

function GuiManager.draw(key)
    if key and GuiManager.ScreenGuis[key] then
        for _, guiComponent in pairs(GuiManager.ScreenGuis[key]) do
            if guiComponent.draw then guiComponent:draw() end
        end
    end
end

function GuiManager.wheelmoved(key, ...)
    if key and GuiManager.ScreenGuis[key] then
        for _, guiComponent in pairs(GuiManager.ScreenGuis[key]) do
            if guiComponent.wheelmoved then guiComponent:wheelmoved(...) end
        end
    end
end

return GuiManager