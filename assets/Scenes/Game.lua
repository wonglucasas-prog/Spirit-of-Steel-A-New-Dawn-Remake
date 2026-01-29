local Game = {}

local GameUi = require("assets.Uis.GameUi")

function Game.initializePlayer()
    Game.Player = {
        Country = "MAL"
    }
end

function Game.initializeDate()
    local date = love.filesystem.read(string.format("%s/Datas/startDate.txt", Game.StartPath))

    local hours, day, month, year = date:match("(%d+)%s*,%s*(%d+)%s*,%s*(%d+)%s*,%s*(%d+)")

    Game.Date = {
        Hour = tonumber(hours) or 1,
        Day = tonumber(day) or 1,
        Month = tonumber(month) or 1,
        Year = tonumber(year) or 1935
    }

    Game.CurrentTick = 0
    Game.TargetTick = 100
    Game.Speed = 1 -- 1x to 5x speed
    Game.Paused = false
end

function Game.initializeGui()
    GameUi.initializeGui(Game)
end

function Game.initializeMap()
    Game.StartPath = "assets/starts/Second World War"
    love.graphics.setDefaultFilter("nearest", "nearest")
    Game.CurrentMapData = love.image.newImageData(string.format("%s/map.png", Game.StartPath))
    Game.CurrentMap = love.graphics.newImage(Game.CurrentMapData)
    Game.BorderMapData = Main.ProvincesManager.generateBorders(Game.CurrentMapData, .7)
    Game.BorderMap = love.graphics.newImage(Game.BorderMapData)
end

function Game.initializeCamera()
    Game.MoveSpeed = {
        Original = 200,
        Fast = 400
    }
    local heightRatio = love.graphics.getHeight() / Game.CurrentMap:getHeight()
    Game.Camera = Framework.Camera.new(Game.CurrentMap:getWidth() / 2, Game.CurrentMap:getHeight() / 2, heightRatio)
    Game.Zoom = {
        Min = heightRatio,
        Max = 64,
        Step = 0.1,
        Base = heightRatio
    }

    Game.cameraZoom = heightRatio
    Game.targetZoom = heightRatio
    Game.Camera:setScale(heightRatio)
    Game.targetZoomPosition = { love.graphics.getWidth() / 2, love.graphics.getHeight() / 2 }
    Game.smoothing = 20

    Game.panning = false
    Game.panLastMouse = nil
end
function Game.initializeDivisions()
    Main.DivisionsManager.initialize()
end

function Game.initialize()
    Game.initializePlayer()
    Game.initializeMap()
    Game.initializeDate()
    Game.initializeGui()
    Game.initializeCamera()
    Game.initializeMovement()
    Game.initializeDivisions()
    Game.initializeSelection()
    Game.loveCallbacks()
end

function Game.loveCallbacks()
    function love.update(dt)
        Game.update(dt)
    end

    function love.draw()
        Game.draw()
    end

    function love.resize(w, h)
        Game.updateZoomOnResize(w, h)
    end

    function love.wheelmoved(x, y)
        Game.handleZoomInput(x, y)
    end

    function love.mousepressed(x, y, button)
        Game.handleMousePress(x, y, button)
    end

    function love.mousereleased(x, y, button)
        Game.handleMouseRelease(x, y, button)
    end

    function love.mousemoved(x, y)
        Game.handleMouseMove(x, y)
    end

    function love.keypressed(key)
        Game.keypressed(key)
    end
end

function Game.updateZoomOnResize(w, h)
    local mapW = Game.CurrentMap:getWidth()
    local mapH = Game.CurrentMap:getHeight()
    local zoomX = w / mapW
    local zoomY = h / mapH
    local baseZoom = math.max(zoomX, zoomY)

    Game.Zoom.Min = baseZoom
    Game.Zoom.Base = baseZoom

    if Game.cameraZoom < baseZoom then
        Game.cameraZoom = baseZoom
        Game.targetZoom = baseZoom
        Game.Camera:setScale(baseZoom)
    end
end

function Game.handleZoomInput(x, y)
    if not Game.Camera then return end
    local mouseX, mouseY = love.mouse.getPosition()
    local oldScale = Game.targetZoom or Game.cameraZoom
    local newScale = oldScale * (1 + y * Game.Zoom.Step)
    newScale = math.max(Game.Zoom.Min, math.min(Game.Zoom.Max, newScale))
    Game.targetZoom = newScale
    Game.targetZoomPosition = { mouseX, mouseY }
end

function Game.getMovementInput(dt)
    local function keydown(keys)
        return love.keyboard.isDown(unpack(keys))
    end
    
    local speed = keydown({ "lshift", "rshift" }) and Game.MoveSpeed.Fast or Game.MoveSpeed.Original
    speed = speed

    local movement = Framework.Vector2.new(0, 0)

    if keydown({ "w", "up" }) then
        movement:add(Framework.Vector2.new(0, -1))
    end
    if keydown({ "s", "down" }) then
        movement:add(Framework.Vector2.new(0, 1))
    end
    if keydown({ "a", "left" }) then
        movement:add(Framework.Vector2.new(-1, 0))
    end
    if keydown({ "d", "right" }) then
        movement:add(Framework.Vector2.new(1, 0))
    end

    local movementX, movementY = movement.x, movement.y
    if movementX ~= 0 or movementY ~= 0 then
        local magnitude = movement:magnitude()
        if magnitude ~= 0 then            
            movementX = movementX / magnitude
            movementY = movementY / magnitude
        end
        local zoom = Game.cameraZoom or Game.Camera:getScale() or 1
        if zoom <= 0 then zoom = 1 end

        local panMultiplier = 1 / math.sqrt(zoom)
        Game.Camera:changeTarget(movementX * speed * panMultiplier * dt, movementY * speed * panMultiplier * dt)
    end

    if love.mouse.isDown(3) then
        local mx, my = love.mouse.getPosition()
        if Game.panning and Game.panLastMouse then
            local dx, dy = mx - Game.panLastMouse[1], my - Game.panLastMouse[2]
            Game.Camera:changeTarget(-dx / (Game.cameraZoom or 1), -dy / (Game.cameraZoom or 1))
        end
        Game.panning = true
        Game.panLastMouse = { mx, my }
    else
        Game.panning = false
        Game.panLastMouse = nil
    end
end

function Game.updateCameraZoom(dt)
    if not Game.targetZoom or Game.cameraZoom == Game.targetZoom then return end

    local tx, ty = Game.targetZoomPosition[1], Game.targetZoomPosition[2]
    local camX, camY = Game.Camera:getPosition()
    local oldZoom = Game.cameraZoom
    local w, h = love.graphics.getWidth(), love.graphics.getHeight()
    local ax, ay = Game.Camera:getAnchor()
    local anchorPxX, anchorPxY = (ax or 0.5) * w, (ay or 0.5) * h

    local worldBeforeX = camX + (tx - anchorPxX) / oldZoom
    local worldBeforeY = camY + (ty - anchorPxY) / oldZoom

    local decay = math.exp(-Game.smoothing * dt)
    Game.cameraZoom = Game.cameraZoom + (Game.targetZoom - Game.cameraZoom) * (1 - decay)
    Game.Camera:setScale(Game.cameraZoom)

    camX, camY = Game.Camera:getPosition()
    local newWorldMouseX = camX + (tx - anchorPxX) / Game.cameraZoom
    local newWorldMouseY = camY + (ty - anchorPxY) / Game.cameraZoom

    local dx, dy = worldBeforeX - newWorldMouseX, worldBeforeY - newWorldMouseY
    Game.Camera:changePosition(dx, dy)
end

function Game.clampCameraPosition()
    local w, h = love.graphics.getWidth(), love.graphics.getHeight()
    local mapW, mapH = Game.CurrentMap:getWidth(), Game.CurrentMap:getHeight()
    local camX, camY = Game.Camera:getPosition()
    local scale = Game.cameraZoom
    local ax, ay = Game.Camera:getAnchor()
    local anchorPxY = (ay or 0.5) * h

    local offsetY = 50
    local minTargetY = anchorPxY / scale - offsetY
    local maxTargetY = mapH - (h - anchorPxY) / scale + offsetY

    if Game.Camera.target then
        local targetX, targetY = Game.Camera.target.x, Game.Camera.target.y
        local clampedY

        if minTargetY > maxTargetY then
            clampedY = mapH * 0.5
        else
            clampedY = math.max(minTargetY, math.min(maxTargetY, targetY))
        end

        if camY < minTargetY or camY > maxTargetY then
            local targetY = math.max(minTargetY, math.min(maxTargetY, camY))
            Game.Camera:setPosition(Game.Camera.position.x, targetY)
        end

        Game.Camera:setTarget(targetX, clampedY)
    end
end

function Game.initializeSelection()
    Game.Selection = {
        selectedDivisions = {},
        isDragging = false,
        dragStart = nil,
        dragEnd = nil
    }
end

function Game.initializeMovement()
    -- Movement queue: each division can have a path of provinces to move through
    Game.MovementQueues = {} -- [divisionIndex] = {path = {province1, province2...}, currentStep = 1, timer = 0}
    Game.MOVEMENT_TIME = 7 -- seconds per province
end

function Game.handleMousePress(x, y, button)    
    if button == 1 then
        local wx, wy = Game.Camera:toWorld(x, y)
        
        local shiftHeld = love.keyboard.isDown("lshift") or love.keyboard.isDown("rshift")
        
        local divIndex = Main.DivisionsManager.getDivisionAtPoint(wx, wy)
        
        if divIndex then
            if not shiftHeld then
                Main.DivisionsManager.clearSelection()
            end
            Main.DivisionsManager.selectDivision(divIndex)
        else
            if not shiftHeld then
                Main.DivisionsManager.clearSelection()
            end

            Game.Selection.isDragging = true
            Game.Selection.dragStart = {x = wx, y = wy}
            Game.Selection.dragEnd = {x = wx, y = wy}
        end

        if not shiftHeld and not divIndex then
            local targetProvince = Game.getProvinceUnderMouse()
            if targetProvince then
                for _, country in pairs(Main.CountriesManager.Countries) do
                    for _, province in pairs(country.Provinces) do
                        if province == targetProvince then
                            print("Clicked on province: " .. tostring(province.Id) .. " owned by " .. country.tag)
                            return
                        end
                    end
                end
            end
        end

    elseif button == 2 then
        local targetProvince = Game.getProvinceUnderMouse()
                
        if next(Game.Selection.selectedDivisions) and targetProvince then
            print(targetProvince.Id)
            Main.DivisionsManager.orderMove(targetProvince)
            print("Move ordered for target: " .. tostring(targetProvince.Id))
        end
    end
end

-- Handle mouse release
function Game.handleMouseRelease(x, y, button)    
    if button == 1 and Game.Selection.isDragging then
        local wx, wy = Game.Camera:toWorld(x, y)
        Game.Selection.dragEnd = {x = wx, y = wy}
        
        -- Select all divisions in the box
        local divisions = Main.DivisionsManager.getDivisionsInRect(
            Game.Selection.dragStart.x,
            Game.Selection.dragStart.y,
            Game.Selection.dragEnd.x,
            Game.Selection.dragEnd.y
        )
        
        for _, divIndex in ipairs(divisions) do
            Main.DivisionsManager.selectDivision(divIndex)
        end
        
        Game.Selection.isDragging = false
        Game.Selection.dragStart = nil
        Game.Selection.dragEnd = nil
    end
end

-- Handle mouse move for drag selection
function Game.handleMouseMove(x, y)
    if Game.Selection.isDragging then
        local wx, wy = Game.Camera:toWorld(x, y)
        Game.Selection.dragEnd = {x = wx, y = wy}
    end
end

-- Draw selection box
function Game.drawSelectionBox()
    if Game.Selection.isDragging and Game.Selection.dragStart and Game.Selection.dragEnd then
        local x1, y1 = Game.Camera:toScreen(Game.Selection.dragStart.x, Game.Selection.dragStart.y)
        local x2, y2 = Game.Camera:toScreen(Game.Selection.dragEnd.x, Game.Selection.dragEnd.y)
        
        local minX = math.min(x1, x2)
        local minY = math.min(y1, y2)
        local width = math.abs(x2 - x1)
        local height = math.abs(y2 - y1)
        
        love.graphics.setColor(1, 1, 1, 0.2)
        love.graphics.rectangle("fill", minX, minY, width, height)
        love.graphics.setColor(1, 1, 1, 1)
        love.graphics.setLineWidth(2)
        love.graphics.rectangle("line", minX, minY, width, height)
    end
end



local function getDaysInMonth(month, year)
    local daysInMonth = { 31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31 }
    if month == 2 then
        if (year % 4 == 0 and year % 100 ~= 0) or (year % 400 == 0) then
            return 29
        end
    end
    return daysInMonth[month] or 30
end

function Game.keypressed(key)
    if key == "space" then
        Game.Paused = not Game.Paused
    elseif key == "=" then
        Game.Speed = math.min(5, Game.Speed + 1)
    elseif key == "-" then
        Game.Speed = math.max(1, Game.Speed - 1)
    end
end

function Game.TimeTick(dt)
    if not Game.Paused then
        Game.CurrentTick = Game.CurrentTick + dt * Game.Speed ^ 2 * 100
        if Game.CurrentTick >= Game.TargetTick then
            Game.CurrentTick = Game.CurrentTick - Game.TargetTick
            Game.Date.Hour = Game.Date.Hour + 1

            if Game.Date.Hour > 24 then
                Game.Date.Hour = 1
                Game.Date.Day = Game.Date.Day + 1
    
                local daysInMonth = getDaysInMonth(Game.Date.Month, Game.Date.Year)
                if Game.Date.Day > daysInMonth then
                    Game.Date.Day = 1
                    Game.Date.Month = Game.Date.Month + 1
                    if Game.Date.Month > 12 then
                        Game.Date.Month = 1
                        Game.Date.Year = Game.Date.Year + 1
                    end
                end
            end
        end
    end
end



function Game.update(dt)    
    Game.getMovementInput(dt)
    Game.updateCameraZoom(dt)
    Game.clampCameraPosition()
    Game.TimeTick(dt)

    Main.DivisionsManager.updateMovement(dt)
    Main.DivisionsManager.updateDivisionLerps(dt)
    Main.DivisionsManager.updatePathTweens(dt)

    Game.Camera:update(dt)

    local frameCount = love.timer.getTime() * 60
    local updateBatch = math.floor(frameCount) % 4
    
    if updateBatch == 0 then
        Main.DivisionsManager.updateDivisionCounts()
    end
    
    Main.DivisionsManager.updateStackOffsets(dt)

    Framework.GuiManager.update("TopBar", dt)
    Framework.GuiManager.update("DivisionGuis", dt)
end

function Game.getProvinceUnderMouse()
    if not Game.Camera then return nil end
    local mx, my = love.mouse.getPosition()
    local wx, wy = Game.Camera:toWorld(mx, my)
    local prov, px, py, key, foundBy = Main.ProvincesManager.GetProvinceFromVector(wx, wy)
    return prov, px, py, key, wx, wy, foundBy
end

function Game.drawMap()
    local tileW = Game.CurrentMap:getWidth()
    local w = love.graphics.getWidth()
    local scale = Game.Camera:getScale()
    local ax, ay = Game.Camera:getAnchor()
    local anchorPxX = (ax or 0.5) * w
    local camX, camY = Game.Camera:getPosition()

    local minX = camX - anchorPxX / scale
    local maxX = camX + (w - anchorPxX) / scale

    local startI = math.floor(minX / tileW) - 1
    local endI = math.floor(maxX / tileW) + 1

    for i = startI, endI do
        love.graphics.draw(Game.BorderMap, i * tileW, 0)
    end
end

function Game.drawGui()
    GameUi.drawGui()
end

function Game.draw()    
    local targetProvince, px, py, key, wx, wy, foundBy = Game.getProvinceUnderMouse()
    local idText = targetProvince and tostring(targetProvince.Id) or "nil"
    local countryText = "none"
    local provinceCenter = Framework.Vector2.new(0, 0)
    
    if targetProvince and Main and Main.CountriesManager and Main.CountriesManager.ProvinceToCountry then
        provinceCenter = targetProvince.Center or provinceCenter
        countryText = Main.CountriesManager.ProvinceToCountry[targetProvince] or "none"
    end
    
    local text = string.format("Province: %s  Country: %s  key: %s  method: %s  px:%d py:%d type:%s neighbourCounts: %d  FPS: %d",
        idText,
        tostring(countryText),
        tostring(key),
        tostring(foundBy),
        px or 0,
        py or 0,
        tostring(targetProvince and targetProvince.Type or "Unknown"),
        targetProvince and targetProvince.NeighboursCount or 0,
        love.timer.getFPS())
    
    local cameraDraw = function()
        Game.drawMap()
    end
    
    Game.Camera:draw(cameraDraw)
    Main.DivisionsManager.drawPathTweens()
    Main.DivisionsManager.drawMovementPaths()
    Main.DivisionsManager.drawDivisions()
    Game.drawSelectionBox()
    Game.drawGui()
end

return Game