local GuiManager = {}
GuiManager.ScreenGuis = {}

-- [[ 1. Localize Global Functions for Speed ]]
local pairs = pairs
local ipairs = ipairs
local type = type
local table_insert = table.insert
local table_sort = table.sort
local table_remove = table.remove

-- [[ 2. Table Pooling to prevent Garbage Collection Lag ]]
-- Instead of creating a new table every frame for every GUI element, we recycle them.
local listPool = {}

local function acquireList()
    return table_remove(listPool) or {}
end

local function releaseList(list)
    -- fast clear the table
    for i = #list, 1, -1 do
        list[i] = nil
    end
    table_insert(listPool, list)
end

-- [[ 3. Optimized Recursive Update ]]
-- Removed table creation entirely. Updates don't usually need Z-sorting, 
-- so we iterate directly.
local function updateDeep(tbl, dt, minX, minY, maxX, maxY)
    -- Direct pairs iteration avoids allocating a 'children' table
    for k, v in pairs(tbl) do
        if type(v) == "table" and k ~= "parent" and k ~= "Owner" then
            local isVisible = true

            -- Optimization: Only check math if keys exist
            if minX and v.x and v.y and v.width and v.height then
                if v.x > maxX or v.x + v.width < minX or
                   v.y > maxY or v.y + v.height < minY then
                    isVisible = false
                end
            end

            if isVisible then
                if v.onUpdate then
                    v:onUpdate(dt)
                end
                -- Recurse
                updateDeep(v, dt, minX, minY, maxX, maxY)
            end
        end
    end
end

-- [[ 4. Optimized Recursive Render ]]
-- Uses the ListPool to sort without generating garbage memory.
local function renderDeep(tbl, minX, minY, maxX, maxY)
    local children = acquireList()

    -- 1. Collect children
    for k, v in pairs(tbl) do
        if type(v) == "table" and k ~= "parent" and k ~= "Owner" then
            children[#children + 1] = v
        end
    end

    -- 2. Sort (Only if we actually have children)
    if #children > 0 then
        table_sort(children, function(a, b) 
            return (a.zIndex or 0) < (b.zIndex or 0) 
        end)
    end

    -- 3. Draw
    for i = 1, #children do
        local v = children[i]
        local isVisible = true

        if minX and v.x and v.y and v.width and v.height then
            if v.x > maxX or v.x + v.width < minX or
               v.y > maxY or v.y + v.height < minY then
                isVisible = false
            end
        end

        if isVisible then
            if v.draw then v:draw() end
            renderDeep(v, minX, minY, maxX, maxY)
        end
    end

    -- 4. Recycle the table back to the pool
    releaseList(children)
end

-- [[ 5. Generic Execution (Mouse/Inputs) ]]
-- Also optimized with pooling, though inputs happen less often than Draw/Update.
local function executeDeep(tbl, methodName, ...)
    local children = acquireList()

    for k, v in pairs(tbl) do
        if type(v) == "table" and k ~= "parent" and k ~= "Owner" then
            children[#children + 1] = v
        end
    end

    if #children > 0 then
        table_sort(children, function(a, b)
            return (a.zIndex or 0) < (b.zIndex or 0)
        end)
    end

    for i = 1, #children do
        local v = children[i]
        if v[methodName] and type(v[methodName]) == "function" then
            v[methodName](v, ...)
        end
        executeDeep(v, methodName, ...)
    end

    releaseList(children)
end

-- [[ Manager Functions ]]

function GuiManager.add(key, guiComponent)
    if not GuiManager.ScreenGuis[key] then
        GuiManager.ScreenGuis[key] = {}
    end

    local targetTable = GuiManager.ScreenGuis[key]

    if type(guiComponent) == "table" and not guiComponent.draw and not guiComponent.onUpdate then
        for _, component in pairs(guiComponent) do
            table_insert(targetTable, component)
        end
    else
        table_insert(targetTable, guiComponent)
    end
    
    -- Sort the root list immediately on add
    table_sort(targetTable, function(a, b)
        return (a.zIndex or 0) < (b.zIndex or 0)
    end)
end

function GuiManager.update(key, dt, camera)
    local root = GuiManager.ScreenGuis[key]
    if root then
        if camera then
            local minX, minY, maxX, maxY = camera:getVisibleBounds()
            -- Add padding to update slightly off-screen objects (smoother movement)
            local padding = 200 
            updateDeep(root, dt, minX - padding, minY - padding, maxX + padding, maxY + padding)
        else
            updateDeep(root, dt)
        end
    end
end

function GuiManager.draw(key, camera)
    local root = GuiManager.ScreenGuis[key]
    if root then
        if camera then
            local minX, minY, maxX, maxY = camera:getVisibleBounds()
            renderDeep(root, minX, minY, maxX, maxY)
        else
            renderDeep(root)
        end
    end
end

function GuiManager.wheelmoved(key, ...)
    if GuiManager.ScreenGuis[key] then
        executeDeep(GuiManager.ScreenGuis[key], "wheelmoved", ...)
    end
end

function GuiManager.mousepressed(key, ...)
    if GuiManager.ScreenGuis[key] then
        executeDeep(GuiManager.ScreenGuis[key], "mousepressed", ...)
    end
end

return GuiManager