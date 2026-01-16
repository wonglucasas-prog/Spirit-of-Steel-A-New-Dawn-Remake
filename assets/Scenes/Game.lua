local Game = {}

function Game.initializePlayer()
    Game.Player = {
        Country = "GER"
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
    Game.Gui = {}
    Game.UIScale = 1.0

    Main.Font = Framework.loadFont(15 * Game.UIScale)
    love.graphics.setFont(Main.Font)

    local topBar = Framework.Frame.new()
    topBar.position = Framework.Vector2.new(0, 0)
    topBar.dimension = Framework.Dim2.new(love.graphics.getWidth(), 40 * Game.UIScale)
    topBar.backgroundColor = Framework.Color4.new(0.1, 0.1, 0.1, 1)
    topBar.borderSize = 0
    topBar.zIndex = 100

    local worldTentionFrame = Framework.Frame.new()
    worldTentionFrame.dimension = Framework.Dim2.new(80 * Game.UIScale, 80 * Game.UIScale)
    worldTentionFrame.backgroundColor = Framework.Color4.new(0.1, 0.1, 0.1, 1)
    worldTentionFrame.borderSize = 0
    worldTentionFrame.cornerRadius = 40 * Game.UIScale
    worldTentionFrame.zIndex = 101

    local worldTentionImage = Framework.Image.new("icons/earth.png")
    worldTentionImage.dimension = Framework.Dim2.new(60 * Game.UIScale, 60 * Game.UIScale)
    worldTentionImage.scaleMode = "fill"
    worldTentionImage.zIndex = 102

    local dateLabel = Framework.Label.new("01/01/1935  01:00")
    dateLabel.dimension = Framework.Dim2.new(250 * Game.UIScale, 15 * Game.UIScale)
    dateLabel.textAlignment = Framework.TextManager.Alignment.Right
    dateLabel.zIndex = 102
    dateLabel:setText("01/01/1935  01:00")

    local plusButton = Framework.Button.new("+")
    plusButton.backgroundColor = Framework.Color4.new(0.1, 0.1, 0.1, 1)
    plusButton.dimension = Framework.Dim2.new(20 * Game.UIScale, 20 * Game.UIScale)
    plusButton.borderSize = 0
    plusButton.cornerRadius = 10 * Game.UIScale
    plusButton.zIndex = 102

    local minusButton = Framework.Button.new("-")
    minusButton.backgroundColor = Framework.Color4.new(0.1, 0.1, 0.1, 1)
    minusButton.dimension = Framework.Dim2.new(20 * Game.UIScale, 20 * Game.UIScale)
    minusButton.borderSize = 0
    minusButton.cornerRadius = 10 * Game.UIScale
    minusButton.zIndex = 102
    
    local playAsCountryFlag = Framework.ImageButton.new(string.format("flags/%s.png", Game.Player.Country))
    playAsCountryFlag.position = Framework.Vector2.new(8, 8)
    local playAsCountryFlagOverlay = Framework.Image.new("flags/flag_overlay.png")
    playAsCountryFlagOverlay.position = playAsCountryFlag.position

    local flagScale = topBar.dimension.height * 1.4 / playAsCountryFlag.dimension.height
    
    playAsCountryFlag.dimension = Framework.Dim2.new(playAsCountryFlag.dimension.width * flagScale, playAsCountryFlag.dimension.height * flagScale)
    playAsCountryFlag.scaleMode = "fill"
    playAsCountryFlag.cornerRadius = 5
    playAsCountryFlag.zIndex = 102

    playAsCountryFlagOverlay.dimension = playAsCountryFlag.dimension
    playAsCountryFlagOverlay.scaleMode = "fill"
    playAsCountryFlagOverlay.cornerRadius = 5
    playAsCountryFlagOverlay.zIndex = 103

    local playAsCountryFlagFrame = Framework.Frame.new()
    playAsCountryFlagFrame.dimension = Framework.Dim2.new(playAsCountryFlag.dimension.width + (16), playAsCountryFlag.dimension.height + (16))
    playAsCountryFlagFrame.backgroundColor = Framework.Color4.new(.1, .1, .1, 1)
    playAsCountryFlagFrame.borderSize = 0
    playAsCountryFlagFrame.cornerRadius = 5
    playAsCountryFlagFrame.zIndex = 101

    local moneyIcon = Framework.Image.new("icons/dollar.png")
    moneyIcon.position = Framework.Vector2.new(playAsCountryFlag.dimension.width + (20 * Game.UIScale), 10 * Game.UIScale)
    moneyIcon.dimension = Framework.Dim2.new(20 * Game.UIScale, 20 * Game.UIScale)
    moneyIcon.zIndex = 102

    local moneyLabel = Framework.Label.new("")
    moneyLabel.position = Framework.Vector2.new(moneyIcon.position.x + moneyIcon.dimension.width + 5 * Game.UIScale, 10 * Game.UIScale)
    moneyLabel.dimension = Framework.Dim2.new(50 * Game.UIScale, 20 * Game.UIScale)
    moneyLabel.textAlignment = Framework.TextManager.Alignment.Center
    moneyLabel.zIndex = 102
    moneyLabel:setText("150M")

    local adminIcon = Framework.Image.new("icons/admin.png")
    adminIcon.position = Framework.Vector2.new(moneyLabel.position.x + moneyLabel.dimension.width + (5 * Game.UIScale), 10 * Game.UIScale)
    adminIcon.dimension = Framework.Dim2.new(20 * Game.UIScale, 20 * Game.UIScale)
    adminIcon.zIndex = 102

    local adminLabel = Framework.Label.new("")
    adminLabel.position = Framework.Vector2.new(adminIcon.position.x + adminIcon.dimension.width + (5 * Game.UIScale), 10 * Game.UIScale)
    adminLabel.dimension = Framework.Dim2.new(50 * Game.UIScale, 20 * Game.UIScale)
    adminLabel.textAlignment = Framework.TextManager.Alignment.Center
    adminLabel.zIndex = 102
    adminLabel:setText("150")

    local researchIcon = Framework.Image.new("icons/research.png")
    researchIcon.position = Framework.Vector2.new(adminLabel.position.x + adminLabel.dimension.width + (5 * Game.UIScale), 10 * Game.UIScale)
    researchIcon.dimension = Framework.Dim2.new(20 * Game.UIScale, 20 * Game.UIScale)
    researchIcon.zIndex = 102

    local researchLabel = Framework.Label.new("")
    researchLabel.position = Framework.Vector2.new(researchIcon.position.x + researchIcon.dimension.width + (5 * Game.UIScale), 10 * Game.UIScale)
    researchLabel.dimension = Framework.Dim2.new(50 * Game.UIScale, 20 * Game.UIScale)
    researchLabel.textAlignment = Framework.TextManager.Alignment.Center
    researchLabel.zIndex = 102
    researchLabel:setText("50")

    local manpowerIcon = Framework.Image.new("icons/manpower.png")
    manpowerIcon.position = Framework.Vector2.new(researchLabel.position.x + researchLabel.dimension.width + (5 * Game.UIScale), 10 * Game.UIScale)
    manpowerIcon.dimension = Framework.Dim2.new(20 * Game.UIScale, 20 * Game.UIScale)
    manpowerIcon.zIndex = 102

    local manpowerLabel = Framework.Label.new("")
    manpowerLabel.position = Framework.Vector2.new(manpowerIcon.position.x + manpowerIcon.dimension.width + (5 * Game.UIScale), 10 * Game.UIScale)
    manpowerLabel.dimension = Framework.Dim2.new(50 * Game.UIScale, 20 * Game.UIScale)
    manpowerLabel.textAlignment = Framework.TextManager.Alignment.Center
    manpowerLabel.zIndex = 102
    manpowerLabel:setText("2.5M")

    local factoriesIcon = Framework.Image.new("icons/factory.png")
    factoriesIcon.position = Framework.Vector2.new(manpowerLabel.position.x + manpowerLabel.dimension.width + (5 * Game.UIScale), 10 * Game.UIScale)
    factoriesIcon.dimension = Framework.Dim2.new(20 * Game.UIScale, 20 * Game.UIScale)
    factoriesIcon.zIndex = 102

    local factoriesLabel = Framework.Label.new("")
    factoriesLabel.position = Framework.Vector2.new(factoriesIcon.position.x + factoriesIcon.dimension.width + (5 * Game.UIScale), 10 * Game.UIScale)
    factoriesLabel.dimension = Framework.Dim2.new(50 * Game.UIScale, 20 * Game.UIScale)
    factoriesLabel.textAlignment = Framework.TextManager.Alignment.Center
    factoriesLabel.zIndex = 102
    factoriesLabel:setText("12")

    local stabilityIcon = Framework.Image.new("icons/stability.png")
    stabilityIcon.position = Framework.Vector2.new(factoriesLabel.position.x + factoriesLabel.dimension.width + (7 * Game.UIScale), 10 * Game.UIScale)
    stabilityIcon.dimension = Framework.Dim2.new(20 * Game.UIScale, 20 * Game.UIScale)
    stabilityIcon.zIndex = 102

    local stabilityLabel = Framework.Label.new("")
    stabilityLabel.position = Framework.Vector2.new(stabilityIcon.position.x + stabilityIcon.dimension.width + (5 * Game.UIScale), 10 * Game.UIScale)
    stabilityLabel.dimension = Framework.Dim2.new(50 * Game.UIScale, 20 * Game.UIScale)
    stabilityLabel.textAlignment = Framework.TextManager.Alignment.Center
    stabilityLabel.zIndex = 102
    stabilityLabel:setText("85%")

    local dicisionButton = Framework.Button.new("Dicision")
    dicisionButton.position = Framework.Vector2.new(playAsCountryFlag.dimension.width + (20 * Game.UIScale), 45 * Game.UIScale)
    dicisionButton.backgroundColor = Framework.Color4.new(0.1, 0.1, 0.1, 1)
    dicisionButton.dimension = Framework.Dim2.new(100 * Game.UIScale, 22 * Game.UIScale)
    dicisionButton.borderSize = 0
    dicisionButton.fontScale = 1
    dicisionButton.cornerRadius = 3 * Game.UIScale
    dicisionButton.zIndex = 102

    local researchButton = Framework.Button.new("Research")
    researchButton.position = Framework.Vector2.new(dicisionButton.position.x + dicisionButton.dimension.width + (5 * Game.UIScale), 45 * Game.UIScale)
    researchButton.backgroundColor = Framework.Color4.new(0.1, 0.1, 0.1, 1)
    researchButton.dimension = Framework.Dim2.new(100 * Game.UIScale, 22 * Game.UIScale)
    researchButton.borderSize = 0
    researchButton.fontScale = 1
    researchButton.cornerRadius = 3 * Game.UIScale
    researchButton.zIndex = 102

    researchButton.onClick = function()

    end

    plusButton.onClick = function()
        Game.Speed = math.min(5, Game.Speed + 1)
    end

    minusButton.onClick = function()
        Game.Speed = math.max(1, Game.Speed - 1)
    end

    for i = 1, 5 do
        local speedBar = Framework.Frame.new()
        speedBar.position = Framework.Vector2.new(love.graphics.getWidth() - (115 * Game.UIScale) - (i - 1) * (25 * Game.UIScale), 32.5 * Game.UIScale)
        speedBar.dimension = Framework.Dim2.new(20 * Game.UIScale, 2.5 * Game.UIScale)
        speedBar.backgroundColor = Framework.Color4.new(1, 1, 1, 1)
        speedBar.borderSize = 0
        speedBar.cornerRadius = 2 * Game.UIScale
        speedBar.zIndex = 102

        if Game.Speed >= i then
            speedBar.backgroundColor = Framework.Color4.new(1, 1, 1, 1)
        else
            speedBar.backgroundColor = Framework.Color4.new(.2, .2, .2, 1)
        end

        speedBar.onUpdate = function(dt)
            speedBar.position = Framework.Vector2.new(love.graphics.getWidth() - (115 * Game.UIScale) - (i - 1) * (25 * Game.UIScale), 31 * Game.UIScale)
            if Game.Speed >= i then
                speedBar.backgroundColor = speedBar.backgroundColor:lerp(Framework.Color4.new(1, 1, 1, 1), 0.2)
            else
                speedBar.backgroundColor = speedBar.backgroundColor:lerp(Framework.Color4.new(.2, .2, .2, 1), 0.2)
            end
        end

        Game.Gui["speedBar" .. i] = speedBar
    end

    Game.Gui.topBar = topBar
    Game.Gui.worldTentionFrame = worldTentionFrame
    Game.Gui.worldTentionImage = worldTentionImage
    
    Game.Gui.dateLabel = dateLabel

    Game.Gui.plusButton = plusButton
    Game.Gui.minusButton = minusButton

    Game.Gui.playAsCountryFlag = playAsCountryFlag
    Game.Gui.playAsCountryFlagFrame = playAsCountryFlagFrame
    Game.Gui.playAsCountryFlagOverlay = playAsCountryFlagOverlay

    Game.Gui.moneyIcon = moneyIcon
    Game.Gui.moneyLabel = moneyLabel

    Game.Gui.adminIcon = adminIcon
    Game.Gui.adminLabel = adminLabel

    Game.Gui.researchIcon = researchIcon
    Game.Gui.researchLabel = researchLabel

    Game.Gui.manpowerIcon = manpowerIcon
    Game.Gui.manpowerLabel = manpowerLabel

    Game.Gui.factoriesIcon = factoriesIcon
    Game.Gui.factoriesLabel = factoriesLabel

    Game.Gui.stabilityIcon = stabilityIcon
    Game.Gui.stabilityLabel = stabilityLabel

    Game.Gui.dicisionButton = dicisionButton
    Game.Gui.researchButton = researchButton

    topBar.onUpdate = function(dt)
        local mx, my = love.mouse.getPosition()
        local mouseDown = love.mouse.isDown(1)

        topBar.dimension = Framework.Dim2.new(love.graphics.getWidth(), 40 * Game.UIScale)

        playAsCountryFlag:updateMouse(mx, my, mouseDown)

        plusButton.position = Framework.Vector2.new(love.graphics.getWidth() - (115 * Game.UIScale), 45 * Game.UIScale)
        plusButton:updateMouse(mx, my, mouseDown)

        minusButton.position = Framework.Vector2.new(love.graphics.getWidth() - (140 * Game.UIScale), 45 * Game.UIScale)
        minusButton:updateMouse(mx, my, mouseDown)

        worldTentionFrame.position = Framework.Vector2.new(love.graphics.getWidth() - (90 * Game.UIScale), 0)
        worldTentionImage.position = Framework.Vector2.new(love.graphics.getWidth() - (80 * Game.UIScale), 10 * Game.UIScale)

        dateLabel.position = Framework.Vector2.new(love.graphics.getWidth() - (345 * Game.UIScale), 10 * Game.UIScale)
        dateLabel.text = string.format("%02d/%02d/%04d  %02d:00", Game.Date.Day, Game.Date.Month, Game.Date.Year, Game.Date.Hour)
        dateLabel:setText(dateLabel.text)

        dicisionButton:updateMouse(mx, my, mouseDown)
        researchButton:updateMouse(mx, my, mouseDown)
    end

    Framework.GuiManager.add("TopBar", Game.Gui)
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
    local DivisionTemplate = require("assets.Objects.DivisionTemplate")
    local Division = require("assets.Objects.Division")

    Game.Divisions = {}
    Game.DivisionPositionsX = {}
    Game.DivisionPositionsY = {}
    Game.DivisionOwnersY = {} -- Stack offset Y for smooth layout
    Game.DivisionLerps = {} -- [divIndex] = {startX, startY, endX, endY, elapsed, duration}
    Game.DivisionOwners = {}
    Game.DivisionCounts = {}
    
    Game.FlagAtlas = {}
    Game.FlagQuads = {}
    
    local divisionIconImg = love.graphics.newImage("icons/manpower.png")
    Game.DivisionBatch = love.graphics.newSpriteBatch(divisionIconImg, 10000, "stream")
    
    local function loadFlagTexture(countryTag)
        if not Game.FlagAtlas[countryTag] then
            Game.FlagAtlas[countryTag] = love.graphics.newImage(string.format("flags/%s.png", countryTag))
        end
    end

    local function newDivision(name, owner, province)
        local division = Division.new(DivisionTemplate.Presets.Infantry:toTable())
        division.name = name
        division.owner = owner
        division.CurrentProvince = province

        local idx = #Game.Divisions + 1
        Game.Divisions[idx] = division
        Game.DivisionPositionsX[idx] = province.Center.x
        Game.DivisionPositionsY[idx] = province.Center.y
        Game.DivisionOwnersY[idx] = 0 -- Stack offset starts at 0
        Game.DivisionOwners[idx] = owner
        
        loadFlagTexture(owner)
    end

    if Main and Main.ProvincesManager then
        for _, country in pairs(Main.CountriesManager.Countries) do
            newDivision(country.tag, country.tag, country.Provinces[1])
        end
    end

    local rectW, rectH = 40, 25
    local textObj = love.graphics.newText(Main.Font)
    
    Game.DivisionTemplate = {
        frame = {
            w = rectW,
            h = rectH,
            color = {0.1, 0.1, 0.1, 1}
        },
        textObj = textObj
    }
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
    Game.MOVEMENT_TIME = 3 -- seconds per province
end

function Game.findPath(startProvince, endProvince)
    if not startProvince or not endProvince then return nil end
    if startProvince == endProvince then return {endProvince} end
    
    -- Queue stores just the province node, not the full history
    local queue = {startProvince}
    -- cameFrom tracks the path: key=node, value=parent
    local cameFrom = {[startProvince] = "start"}
    
    local head = 1
    local tail = 1
    
    while head <= tail do
        local current = queue[head]
        head = head + 1
        
        if current == endProvince then
            -- Reconstruct path by backtracking from end to start
            local path = {}
            local curr = endProvince
            while curr ~= "start" do
                table.insert(path, 1, curr)
                curr = cameFrom[curr]
            end
            return path
        end
        
        -- CHANGED: Use pairs() instead of ipairs()
        -- This ensures iteration works even if Neighbours is a sparse table or dictionary
        if current.Neighbours then
            for _, neighbor in pairs(current.Neighbours) do
                -- Basic validation to ensure we have a valid object to check
                if type(neighbor) == "table" and not cameFrom[neighbor] then
                    cameFrom[neighbor] = current
                    tail = tail + 1
                    queue[tail] = neighbor
                end
            end
        end
    end
    
    return nil -- No path found
end

-- Check if division is selected
function Game.isDivisionSelected(divIndex)
    return Game.Selection.selectedDivisions[divIndex] == true
end

-- Select a division
function Game.selectDivision(divIndex)
    Game.Selection.selectedDivisions[divIndex] = true
end

-- Deselect a division
function Game.deselectDivision(divIndex)
    Game.Selection.selectedDivisions[divIndex] = nil
end

-- Clear all selections
function Game.clearSelection()
    Game.Selection.selectedDivisions = {}
end

-- Check if a point is inside a province (using division position)
function Game.getDivisionAtPoint(wx, wy, tolerance)
    tolerance = tolerance or 20
    
    for i = 1, #Game.Divisions do
        local div = Game.Divisions[i]
        if div.owner == Game.Player.Country then
            local dx = Game.DivisionPositionsX[i] - wx
            local dy = Game.DivisionPositionsY[i] - wy
            local dist = math.sqrt(dx * dx + dy * dy)
            
            if dist < tolerance / Game.cameraZoom then
                return i
            end
        end
    end
    
    return nil
end

-- Get all divisions in a rectangle
function Game.getDivisionsInRect(x1, y1, x2, y2)
    local minX = math.min(x1, x2)
    local maxX = math.max(x1, x2)
    local minY = math.min(y1, y2)
    local maxY = math.max(y1, y2)
    
    local divisions = {}
    local addedProvinces = {}
    
    -- Check all divisions
    for i = 1, #Game.Divisions do
        local div = Game.Divisions[i]
        if div.owner == Game.Player.Country and div.CurrentProvince then
            -- Avoid duplicates from the same province
            if not addedProvinces[div.CurrentProvince] then
                local center = div.CurrentProvince.Center
                if center.x >= minX and center.x <= maxX and center.y >= minY and center.y <= maxY then
                    table.insert(divisions, i)
                    addedProvinces[div.CurrentProvince] = true
                end
            end
        end
    end
    
    return divisions
end

function Game.orderMove(targetProvince)
    local selectedCount = 0
    for divIndex, _ in pairs(Game.Selection.selectedDivisions) do
        selectedCount = selectedCount + 1
        local div = Game.Divisions[divIndex]
        
        if div then
            -- Default start is the logical province
            local startNode = div.CurrentProvince
            
            -- Capture the EXACT current visual position to prevent snapping
            local visualStartX = Game.DivisionPositionsX[divIndex]
            local visualStartY = Game.DivisionPositionsY[divIndex]
            
            -- If the unit is already moving, we rely on its current visual pos, 
            -- but the pathfinding still needs to know the logical 'from' node.
            -- If we are mid-move, 'CurrentProvince' is still the previous one.
            if startNode ~= targetProvince then
                local path = Game.findPath(startNode, targetProvince)
                
                if path and #path > 1 then
                    -- Overwrite or create the movement queue
                    -- We set 'visualStart' so the interpolation begins from where the unit IS, 
                    -- not where the province center is.
                    Game.MovementQueues[divIndex] = {
                        path = path,
                        currentStep = 2, -- Step 1 is the starting node, we move to Step 2
                        timer = 0,
                        visualStart = {x = visualStartX, y = visualStartY}
                    }
                else
                    -- If no path (e.g. clicking same province), clear movement to stop.
                    -- Optionally handle 'already there' logic here
                    print("No path found or already at destination")
                end
            end
        end
    end
    
    return selectedCount
end

function Game.updateMovement(dt)
    for divIndex, movement in pairs(Game.MovementQueues) do
        if movement and not Game.Paused then
            movement.timer = movement.timer + dt
            
            local targetMovementTime = Game.MOVEMENT_TIME / Game.Speed
            
            if movement.timer >= targetMovementTime then
                movement.currentStep = movement.currentStep + 1
                
                if movement.currentStep > #movement.path then
                    local finalProvince = movement.path[#movement.path]
                    Game.Divisions[divIndex].CurrentProvince = finalProvince
                    
                    -- Start lerp to new province center
                    Game.DivisionLerps[divIndex] = {
                        startX = Game.DivisionPositionsX[divIndex],
                        startY = Game.DivisionPositionsY[divIndex],
                        endX = finalProvince.Center.x,
                        endY = finalProvince.Center.y,
                        elapsed = 0,
                        duration = 0.5 -- 0.5 second lerp after movement completes
                    }
                    
                    Game.MovementQueues[divIndex] = nil
                else
                    Game.Divisions[divIndex].CurrentProvince = movement.path[movement.currentStep]
                    
                    -- Start lerp to intermediate province
                    local newProvince = movement.path[movement.currentStep]
                    Game.DivisionLerps[divIndex] = {
                        startX = Game.DivisionPositionsX[divIndex],
                        startY = Game.DivisionPositionsY[divIndex],
                        endX = newProvince.Center.x,
                        endY = newProvince.Center.y,
                        elapsed = 0,
                        duration = 0.5 -- 0.5 second lerp after each movement step
                    }
                    
                    movement.timer = 0
                end
            end
        end
    end
end

function Game.updateDivisionLerps(dt)
    for divIndex, lerp in pairs(Game.DivisionLerps) do
        if not Game.Paused then
            lerp.elapsed = lerp.elapsed + dt
        end
        
        if lerp.elapsed >= lerp.duration then
            -- Lerp complete, snap to final position
            Game.DivisionPositionsX[divIndex] = lerp.endX
            Game.DivisionPositionsY[divIndex] = lerp.endY
            Game.DivisionLerps[divIndex] = nil
        else
            -- Interpolate
            local progress = lerp.elapsed / lerp.duration
            Game.DivisionPositionsX[divIndex] = lerp.startX + (lerp.endX - lerp.startX) * progress
            Game.DivisionPositionsY[divIndex] = lerp.startY + (lerp.endY - lerp.startY) * progress
        end
    end
end

-- Handle mouse press for selection and movement
function Game.handleMousePress(x, y, button)
    if button == 1 then -- Left click
        local wx, wy = Game.Camera:toWorld(x, y)
        
        -- Check if shift is held for multi-select
        local shiftHeld = love.keyboard.isDown("lshift") or love.keyboard.isDown("rshift")
        
        -- Try to select a division
        local divIndex = Game.getDivisionAtPoint(wx, wy)
        
        if divIndex then
            if not shiftHeld then
                Game.clearSelection()
            end
            Game.selectDivision(divIndex)
        else
            if not shiftHeld then
                Game.clearSelection()
            end

            Game.Selection.isDragging = true
            Game.Selection.dragStart = {x = wx, y = wy}
            Game.Selection.dragEnd = {x = wx, y = wy}
        end
    elseif button == 2 then -- Right click - move order
        local targetProvince = Game.getProvinceUnderMouse()
                
        if next(Game.Selection.selectedDivisions) and targetProvince then
            print(targetProvince.Id)
            Game.orderMove(targetProvince)
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
        local divisions = Game.getDivisionsInRect(
            Game.Selection.dragStart.x,
            Game.Selection.dragStart.y,
            Game.Selection.dragEnd.x,
            Game.Selection.dragEnd.y
        )
        
        for _, divIndex in ipairs(divisions) do
            Game.selectDivision(divIndex)
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

function Game.drawMovementPaths()
    local dashSize = 10
    local gapSize = 10
    local totalCycle = dashSize + gapSize
    local animationSpeed = 30
    
    local timeOffset = (love.timer.getTime() * animationSpeed) % totalCycle
    
    love.graphics.setLineWidth(7)
    
    for divIndex, movement in pairs(Game.MovementQueues) do
        if movement and Game.isDivisionSelected(divIndex) then
            love.graphics.setColor(1, 0.8, 0, 0.8)
            
            if movement.currentStep <= #movement.path then
                local targetProvince = movement.path[movement.currentStep]
                
                local startX = Game.DivisionPositionsX[divIndex]
                local startY = Game.DivisionPositionsY[divIndex]
                
                local endX = targetProvince.Center.x
                local endY = targetProvince.Center.y
                
                local dx = endX - startX
                local dy = endY - startY
                local dist = math.sqrt(dx * dx + dy * dy)
                local angle = math.atan2(dy, dx)
                
                local nx = dx / dist
                local ny = dy / dist
                
                local currentDist = timeOffset - totalCycle 
                
                while currentDist < dist do
                    local segStart = math.max(0, currentDist)
                    local segEnd = math.min(dist, currentDist + dashSize)
                    
                    if segEnd > segStart then
                        local sx1, sy1 = Game.Camera:toScreen(startX + nx * segStart, startY + ny * segStart)
                        local sx2, sy2 = Game.Camera:toScreen(startX + nx * segEnd, startY + ny * segEnd)
                        love.graphics.line(sx1, sy1, sx2, sy2)
                    end
                    currentDist = currentDist + totalCycle
                end
            end
        end
    end
    love.graphics.setLineWidth(1) 
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

function Game.updateDivisionCounts()
    Game.DivisionCounts = {}
    
    for i = 1, #Game.Divisions do
        -- Only count divisions that are NOT currently moving
        if not Game.MovementQueues[i] then
            local province = Game.Divisions[i].CurrentProvince
            if province then
                if not Game.DivisionCounts[province] then
                    Game.DivisionCounts[province] = {}
                end
                
                local owner = Game.DivisionOwners[i]
                if not Game.DivisionCounts[province][owner] then
                    Game.DivisionCounts[province][owner] = {
                        count = 0,
                        divisions = {}
                    }
                end
                
                Game.DivisionCounts[province][owner].count = Game.DivisionCounts[province][owner].count + 1
                table.insert(Game.DivisionCounts[province][owner].divisions, i)
            end
        end
    end
end

function Game.updateStackOffsets(dt)
    -- Calculate target stack offsets for divisions in the same province
    local frameHeight = Game.DivisionTemplate.frame.h
    local smoothSpeed = 15 -- Units per second for smooth animation
    
    -- First pass: calculate target offsets
    local divisionStackPositions = {} -- [divIndex] = targetOffsetY
    
    for province, ownerData in pairs(Game.DivisionCounts) do
        local totalStacks = 0
        for _, _ in pairs(ownerData) do totalStacks = totalStacks + 1 end
        
        local stackSpacing = frameHeight
        local totalHeight = totalStacks * stackSpacing
        local startOffsetY = -totalHeight / 2 + stackSpacing / 2
        local currentStack = 0
        
        for owner, data in pairs(ownerData) do
            local targetOffsetY = startOffsetY + currentStack * stackSpacing
            for _, divIndex in ipairs(data.divisions) do
                divisionStackPositions[divIndex] = targetOffsetY
            end
            currentStack = currentStack + 1
        end
    end
    
    -- Second pass: smooth interpolate current offsets towards targets
    for i = 1, #Game.Divisions do
        local targetOffsetY = divisionStackPositions[i] or 0
        local currentOffsetY = Game.DivisionOwnersY[i] or 0
        
        if math.abs(targetOffsetY - currentOffsetY) > 0.1 then
            local maxStep = smoothSpeed * dt
            local diff = targetOffsetY - currentOffsetY
            local stepSize = math.min(maxStep, math.abs(diff))
            Game.DivisionOwnersY[i] = currentOffsetY + (diff > 0 and stepSize or -stepSize)
        else
            Game.DivisionOwnersY[i] = targetOffsetY
        end
    end
end

function Game.update(dt)
    Game.getMovementInput(dt)
    Game.updateCameraZoom(dt)
    Game.clampCameraPosition()
    Game.TimeTick(dt)

    Game.updateMovement(dt)
    Game.updateDivisionLerps(dt)

    Game.Camera:update(dt)

    local frameCount = love.timer.getTime() * 60
    local updateBatch = math.floor(frameCount) % 4
    
    if updateBatch == 0 then
        Game.updateDivisionCounts()
    end
    
    Game.updateStackOffsets(dt)

    Framework.GuiManager.update("TopBar", dt)
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
    Framework.GuiManager.draw("TopBar")
    Framework.GuiManager.draw("DivisionGuis", Game.Camera)
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
    Game.drawMovementPaths()
    Game.drawDivisions()
    Game.drawSelectionBox()
    Game.drawGui()
end

function Game.isProvinceSelected(province)
    for i = 1, #Game.Divisions do
        if Game.Divisions[i].CurrentProvince == province and Game.isDivisionSelected(i) then
            return true
        end
    end
    return false
end

function Game.drawDivisions()
    local cameraX, cameraY = Game.Camera:getPosition()
    local cameraZoom = Game.cameraZoom
    local tileWidth = Game.CurrentMap:getWidth()
    local screenWidth, screenHeight = love.graphics.getWidth(), love.graphics.getHeight()
    local anchorX, anchorY = Game.Camera:getAnchor()
    local anchorPixelX, anchorPixelY = (anchorX or 0.5) * screenWidth, (anchorY or 0.5) * screenHeight

    local minX = cameraX - anchorPixelX / cameraZoom
    local maxX = cameraX + (screenWidth - anchorPixelX) / cameraZoom
    local minY = cameraY - anchorPixelY / cameraZoom
    local maxY = cameraY + (screenHeight - anchorPixelY) / cameraZoom

    local startIndex = math.floor(minX / tileWidth) - 1
    local endIndex = math.floor(maxX / tileWidth) + 1

    local textScale = .8
    local template = Game.DivisionTemplate
    local frameWidth, frameHeight = template.frame.w, template.frame.h
    local textObject = template.textObj

    local function drawUnitBox(screenX, screenY, owner, count, isSelected, isMoving)
        local flag = Game.FlagAtlas[owner]
        local flagWidth, flagHeight = 0, 0

        if flag then
            flagHeight = frameHeight * 0.8
            flagWidth = flag:getWidth() * (flagHeight / flag:getHeight())
        end

        local totalWidth = frameWidth + flagWidth

        love.graphics.setColor(template.frame.color)
        love.graphics.rectangle("fill", screenX - totalWidth / 2, screenY - frameHeight / 2, totalWidth, frameHeight)

        if owner == Game.Player.Country then
            love.graphics.setColor(0, 1, 0, 1)
            love.graphics.setLineWidth(1)
            love.graphics.rectangle("line", screenX - totalWidth / 2, screenY - frameHeight / 2, totalWidth, frameHeight)
        end

        if isSelected then
            love.graphics.setColor(1, 1, 0, 1)
            love.graphics.setLineWidth(2)
            love.graphics.rectangle("line", screenX - totalWidth / 2, screenY - frameHeight / 2, totalWidth, frameHeight)
        end

        if flag then
            love.graphics.setColor(1, 1, 1, 1)
            love.graphics.draw(flag, screenX - totalWidth / 2 + frameHeight * 0.1, screenY - frameHeight / 2 + frameHeight * 0.1, 0, flagWidth / flag:getWidth(), flagHeight / flag:getHeight())
        end

        textObject:setf(tostring(count or 1), frameWidth / textScale, "center")
        love.graphics.setColor(1, 1, 1, 1)
        love.graphics.draw(textObject, screenX - totalWidth / 2 + flagWidth / 2 + frameWidth / 2, screenY - (love.graphics.getFont():getHeight() * textScale) / 2, 0, textScale, textScale)
    end

    for province, ownerData in pairs(Game.DivisionCounts) do
        local center = province.Center
        if not center then goto continue end

        local baseY = center.y
        if baseY < minY or baseY > maxY then goto continue end

        for owner, data in pairs(ownerData) do
            for i = startIndex, endIndex do
                local worldX = center.x + i * tileWidth
                if worldX < minX or worldX > maxX then goto nextTile end

                local isAnySelected = false
                for _, divIndex in ipairs(data.divisions) do
                    if Game.isDivisionSelected(divIndex) then 
                        isAnySelected = true 
                        break 
                    end
                end
                
                local totalDivisionsY = 0
                for _, divIndex in ipairs(data.divisions) do
                    local offsetY = Game.DivisionOwnersY[divIndex] or 0
                    local screenX, screenY = Game.Camera:toScreen(worldX, baseY + offsetY)
                    drawUnitBox(screenX, screenY, owner, 1, Game.isDivisionSelected(divIndex), false)
                    totalDivisionsY = offsetY
                end

                ::nextTile::
            end
        end
        ::continue::
    end

    for divIndex = 1, #Game.Divisions do
        local div = Game.Divisions[divIndex]
        if not div then goto continueMoving end
        
        -- Only draw moving divisions here; stationary divisions are drawn above
        if not Game.MovementQueues[divIndex] then goto continueMoving end

        local baseX = Game.DivisionPositionsX[divIndex] or (div.CurrentProvince and div.CurrentProvince.Center.x) or 0
        local baseY = Game.DivisionPositionsY[divIndex] or (div.CurrentProvince and div.CurrentProvince.Center.y) or 0

        for i = startIndex, endIndex do
            local worldX = baseX + i * tileWidth
            if worldX >= minX and worldX <= maxX and baseY >= minY and baseY <= maxY then
                local screenX, screenY = Game.Camera:toScreen(worldX, baseY)
                drawUnitBox(screenX, screenY, div.owner, 1, Game.isDivisionSelected(divIndex), true)
            end
        end
        ::continueMoving::
    end
end


return Game