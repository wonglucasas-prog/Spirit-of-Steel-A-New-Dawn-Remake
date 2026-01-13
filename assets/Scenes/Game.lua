local Game = {}

function Game.initializePlayer()
    Game.Player = {
        Country = "ITA"
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
    Game.UIScale = 1.2

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

    local moneyLabel = Framework.Label.new("500")
    moneyLabel.position = Framework.Vector2.new(moneyIcon.position.x + moneyIcon.dimension.width + 5 * Game.UIScale, 10 * Game.UIScale)
    moneyLabel.dimension = Framework.Dim2.new(50 * Game.UIScale, 20 * Game.UIScale)
    moneyLabel.textAlignment = Framework.TextManager.Alignment.Center
    moneyLabel.zIndex = 102

    local adminIcon = Framework.Image.new("icons/admin.png")
    adminIcon.position = Framework.Vector2.new(moneyLabel.position.x + moneyLabel.dimension.width + (5 * Game.UIScale), 10 * Game.UIScale)
    adminIcon.dimension = Framework.Dim2.new(20 * Game.UIScale, 20 * Game.UIScale)
    adminIcon.zIndex = 102

    local adminLabel = Framework.Label.new("150")
    adminLabel.position = Framework.Vector2.new(adminIcon.position.x + adminIcon.dimension.width + (5 * Game.UIScale), 10 * Game.UIScale)
    adminLabel.dimension = Framework.Dim2.new(50 * Game.UIScale, 20 * Game.UIScale)
    adminLabel.textAlignment = Framework.TextManager.Alignment.Center
    adminLabel.zIndex = 102

    local researchIcon = Framework.Image.new("icons/research.png")
    researchIcon.position = Framework.Vector2.new(adminLabel.position.x + adminLabel.dimension.width + (5 * Game.UIScale), 10 * Game.UIScale)
    researchIcon.dimension = Framework.Dim2.new(20 * Game.UIScale, 20 * Game.UIScale)
    researchIcon.zIndex = 102

    local researchLabel = Framework.Label.new("30")
    researchLabel.position = Framework.Vector2.new(researchIcon.position.x + researchIcon.dimension.width + (5 * Game.UIScale), 10 * Game.UIScale)
    researchLabel.dimension = Framework.Dim2.new(50 * Game.UIScale, 20 * Game.UIScale)
    researchLabel.textAlignment = Framework.TextManager.Alignment.Center
    researchLabel.zIndex = 102

    local manpowerIcon = Framework.Image.new("icons/manpower.png")
    manpowerIcon.position = Framework.Vector2.new(researchLabel.position.x + researchLabel.dimension.width + (5 * Game.UIScale), 10 * Game.UIScale)
    manpowerIcon.dimension = Framework.Dim2.new(20 * Game.UIScale, 20 * Game.UIScale)
    manpowerIcon.zIndex = 102

    local manpowerLabel = Framework.Label.new("2.5M")
    manpowerLabel.position = Framework.Vector2.new(manpowerIcon.position.x + manpowerIcon.dimension.width + (5 * Game.UIScale), 10 * Game.UIScale)
    manpowerLabel.dimension = Framework.Dim2.new(50 * Game.UIScale, 20 * Game.UIScale)
    manpowerLabel.textAlignment = Framework.TextManager.Alignment.Center
    manpowerLabel.zIndex = 102

    local factoriesIcon = Framework.Image.new("icons/factory.png")
    factoriesIcon.position = Framework.Vector2.new(manpowerLabel.position.x + manpowerLabel.dimension.width + (5 * Game.UIScale), 10 * Game.UIScale)
    factoriesIcon.dimension = Framework.Dim2.new(20 * Game.UIScale, 20 * Game.UIScale)
    factoriesIcon.zIndex = 102

    local factoriesLabel = Framework.Label.new("12")
    factoriesLabel.position = Framework.Vector2.new(factoriesIcon.position.x + factoriesIcon.dimension.width + (5 * Game.UIScale), 10 * Game.UIScale)
    factoriesLabel.dimension = Framework.Dim2.new(50 * Game.UIScale, 20 * Game.UIScale)
    factoriesLabel.textAlignment = Framework.TextManager.Alignment.Center
    factoriesLabel.zIndex = 102

    local stabilityIcon = Framework.Image.new("icons/stability.png")
    stabilityIcon.position = Framework.Vector2.new(factoriesLabel.position.x + factoriesLabel.dimension.width + (7 * Game.UIScale), 10 * Game.UIScale)
    stabilityIcon.dimension = Framework.Dim2.new(20 * Game.UIScale, 20 * Game.UIScale)
    stabilityIcon.zIndex = 102

    local stabilityLabel = Framework.Label.new("85%")
    stabilityLabel.position = Framework.Vector2.new(stabilityIcon.position.x + stabilityIcon.dimension.width + (5 * Game.UIScale), 10 * Game.UIScale)
    stabilityLabel.dimension = Framework.Dim2.new(50 * Game.UIScale, 20 * Game.UIScale)
    stabilityLabel.textAlignment = Framework.TextManager.Alignment.Center
    stabilityLabel.zIndex = 102

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

function Game.initializeMovement()

end

function Game.initializeDivisions()
    local DivisionTemplate = require("assets.Objects.DivisionTemplate")
    local Division = require("assets.Objects.Division")

    Game.Divisions = {}
    Game.DivisionGuis = {}

    local function newDivision(name, owner, province)
        local division = Division.new(DivisionTemplate.Presets.Infantry:toTable())
        division.name = name
        division.owner = owner
        division.CurrentProvince = province

        table.insert(Game.Divisions, division)

        local divisionFrame = Framework.Frame.new()
        divisionFrame.dimension = Framework.Dim2.new(40, 25)
        divisionFrame.backgroundColor = Framework.Color4.new(.1, .1, .1, 1)
        divisionFrame.cornerRadius = 0
        divisionFrame.borderSize = 0
        divisionFrame.zIndex = 1
        divisionFrame.canMouseDown = true

        divisionFrame.onClick = function()
            divisionFrame.borderSize = divisionFrame.borderSize == 1 and 0 or 1
        end

        local divisionLabel = Framework.Label.new(name)
        divisionLabel.dimension = divisionFrame.dimension
        divisionLabel.textAlignment = Framework.TextManager.Alignment.Center
        divisionLabel.zIndex = 2
        divisionLabel.fontScale = 0.7
        
        local ownerFlag = Framework.Image.new(string.format("flags/%s.png", owner))
        ownerFlag.scaleMode = "fill"
        ownerFlag.zIndex = 2
        
        local flagScale = divisionLabel.dimension.height * 0.8 / ownerFlag.dimension.height
        ownerFlag.dimension = Framework.Dim2.new(ownerFlag.dimension.width * flagScale, ownerFlag.dimension.height * flagScale)

        divisionFrame.dimension = Framework.Dim2.new(divisionFrame.dimension.width + ownerFlag.dimension.width, divisionFrame.dimension.height)
        
        divisionFrame.onUpdate = function(dt)
            local mx, my = love.mouse.getPosition()
            local mouseDown = love.mouse.isDown(1)

            local center = province.Center
            local screenX, screenY = Game.Camera:toScreen(center.x, center.y)

            divisionFrame.position = Framework.Vector2.new(screenX - divisionFrame.dimension.width / 2, screenY - divisionFrame.dimension.height / 2)
            divisionLabel.position = Framework.Vector2.new(divisionFrame.position.x + ownerFlag.dimension.width, divisionFrame.position.y)
            ownerFlag.position = Framework.Vector2.new(divisionFrame.position.x + divisionFrame.dimension.height * 0.2 / 2, divisionFrame.position.y + divisionFrame.dimension.height * 0.2 / 2)

            divisionFrame:updateMouse(mx, my, mouseDown)
        end

        Game.DivisionGuis[name] = {
            OwnerFlag = ownerFlag,
            DivisionFrame = divisionFrame,
            DivisionLabel = divisionLabel
        }
    end

    local targetProvince = nil
    if Main and Main.ProvincesManager then 
        for _, province in pairs(Main.ProvincesManager.Provinces) do
            if province.Id == 200 then targetProvince = province end
        end
    end

    if targetProvince then
        newDivision("123", "ITA", targetProvince)
        Framework.GuiManager.add("DivisionGuis", Game.DivisionGuis)
    end
end

function Game.initialize()
    Game.initializePlayer()
    Game.initializeMap()
    Game.initializeDate()
    Game.initializeGui()
    Game.initializeCamera()
    Game.initializeMovement()
    Game.initializeDivisions()
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

    Game.Camera:update(dt)

    Framework.GuiManager.update("TopBar")
    Framework.GuiManager.update("DivisionGuis")

    do
        local mx, my = love.mouse.getPosition()
        local wx, wy = Game.Camera:toWorld(mx, my)
        local mapW = Game.CurrentMapData:getWidth()
        local mapH = Game.CurrentMapData:getHeight()

        local fx = math.floor(wx)
        local fy = math.floor(wy)
        local ix0 = ((fx % mapW) + mapW) % mapW
        local iy0 = ((fy % mapH) + mapH) % mapH
    end
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
    Framework.GuiManager.draw("DivisionGuis")
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
    
    local text = string.format("Province: %s  Country: %s  key: %s  method: %s  px:%d py:%d type:%s neighbourCounts: %d",
    idText,
    tostring(countryText),
    tostring(key),
    tostring(foundBy),
    px or 0,
    py or 0,
    tostring(targetProvince and targetProvince.Type or "Unknown"),
    targetProvince and targetProvince.NeighboursCount)

    local scaledCameraDraw = function()
        Game.drawMap()
    end
    

    Game.Camera:draw(scaledCameraDraw)
    --Game.drawDivisions()

    Game.drawGui()
end

function Game.drawDivisions()
    local counts = {}
    for _, division in ipairs(Game.Divisions) do
        local province = division.CurrentProvince
        if province then
            counts[province] = (counts[province] or 0) + 1
        end
    end

    local rectangleWidth = 50
    local rectangleHeight = 30

    for province, count in pairs(counts) do
        local center = province.Center
        if center then
            local screenX, screenY = Game.Camera:toScreen(center.x, center.y)

            love.graphics.push("all")
            love.graphics.setColor(Framework.Color4.new(.1, .1, .1, 1):packed())

            love.graphics.rectangle(
                "fill",
                screenX - rectangleWidth / 2,
                screenY - rectangleHeight / 2,
                rectangleWidth,
                rectangleHeight
            )

            love.graphics.setColor(1, 1, 1, 1)

            local text = tostring(count)
            local font = love.graphics.getFont()
            local textWidth = font:getWidth(text)
            local textHeight = font:getHeight()

            love.graphics.print(
                text,
                screenX - textWidth / 2,
                screenY - textHeight / 2
            )

            love.graphics.pop()
        end
    end
end


return Game