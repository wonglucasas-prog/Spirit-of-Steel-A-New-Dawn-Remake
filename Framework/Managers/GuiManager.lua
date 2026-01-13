local GuiManager = {}

GuiManager.ScreenGuis = {}

local function executeDeep(tbl, methodName, ...)
    local children = {}

    for k, v in pairs(tbl) do
        if type(v) == "table" and k ~= "parent" and k ~= "Owner" then
            table.insert(children, v)
        end
    end

    table.sort(children, function(a, b)
        return (a.zIndex or 0) < (b.zIndex or 0)
    end)

    for _, v in ipairs(children) do
        if v[methodName] and type(v[methodName]) == "function" then
            v[methodName](v, ...)
        end

        executeDeep(v, methodName, ...)
    end
end

function GuiManager.add(key, guiComponent)
    if not GuiManager.ScreenGuis[key] then
        GuiManager.ScreenGuis[key] = {}
    end

    if type(guiComponent) == "table" and not guiComponent.draw  and not guiComponent.onUpdate then
        for _, component in pairs(guiComponent) do
            table.insert(GuiManager.ScreenGuis[key], component)
        end
    else
        table.insert(GuiManager.ScreenGuis[key], guiComponent)
    end

    table.sort(GuiManager.ScreenGuis[key], function(a, b)
        return (a.zIndex or 0) < (b.zIndex or 0)
    end)
end

function GuiManager.update(key, dt)
    if key and GuiManager.ScreenGuis[key] then
        executeDeep(GuiManager.ScreenGuis[key], "onUpdate", dt)
    end
end

function GuiManager.draw(key)
    if key and GuiManager.ScreenGuis[key] then
        executeDeep(GuiManager.ScreenGuis[key], "draw")
    end
end

function GuiManager.wheelmoved(key, ...)
    if key and GuiManager.ScreenGuis[key] then
        executeDeep(GuiManager.ScreenGuis[key], "wheelmoved", ...)
    end
end

function GuiManager.mousepressed(key, ...)
    if key and GuiManager.ScreenGuis[key] then
        executeDeep(GuiManager.ScreenGuis[key], "mousepressed", ...)
    end
end

return GuiManager