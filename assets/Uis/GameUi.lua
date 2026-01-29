local GameUi = {}

function GameUi.initializeGui(game)
    game.Gui = {}
    game.UIScale = 1.0

    Main.Font = Framework.loadFont(15 * game.UIScale)
    love.graphics.setFont(Main.Font)

    local topBar = Framework.Frame.new()
    topBar.position = Framework.Vector2.new(0, 0)
    topBar.dimension = Framework.Dim2.new(love.graphics.getWidth(), 40 * game.UIScale)
    topBar.backgroundColor = Framework.Color4.new(0.1, 0.1, 0.1, 1)
    topBar.borderSize = 0
    topBar.zIndex = 100

    local worldTentionFrame = Framework.Frame.new()
    worldTentionFrame.dimension = Framework.Dim2.new(80 * game.UIScale, 80 * game.UIScale)
    worldTentionFrame.backgroundColor = Framework.Color4.new(0.1, 0.1, 0.1, 1)
    worldTentionFrame.borderSize = 0
    worldTentionFrame.cornerRadius = 40 * game.UIScale
    worldTentionFrame.zIndex = 101

    local worldTentionImage = Framework.Image.new("icons/earth.png")
    worldTentionImage.dimension = Framework.Dim2.new(60 * game.UIScale, 60 * game.UIScale)
    worldTentionImage.scaleMode = "fill"
    worldTentionImage.zIndex = 102

    local dateLabel = Framework.Label.new("01/01/1935  01:00")
    dateLabel.dimension = Framework.Dim2.new(250 * game.UIScale, 15 * game.UIScale)
    dateLabel.textAlignment = Framework.TextManager.Alignment.Right
    dateLabel.zIndex = 102
    dateLabel:setText("01/01/1935  01:00")

    local plusButton = Framework.Button.new("+")
    plusButton.backgroundColor = Framework.Color4.new(0.1, 0.1, 0.1, 1)
    plusButton.dimension = Framework.Dim2.new(20 * game.UIScale, 20 * game.UIScale)
    plusButton.borderSize = 0
    plusButton.cornerRadius = 10 * game.UIScale
    plusButton.zIndex = 102

    local minusButton = Framework.Button.new("-")
    minusButton.backgroundColor = Framework.Color4.new(0.1, 0.1, 0.1, 1)
    minusButton.dimension = Framework.Dim2.new(20 * game.UIScale, 20 * game.UIScale)
    minusButton.borderSize = 0
    minusButton.cornerRadius = 10 * game.UIScale
    minusButton.zIndex = 102
    
    local playAsCountryFlag = Framework.ImageButton.new(string.format("flags/%s.png", game.Player.Country))
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
    moneyIcon.position = Framework.Vector2.new(playAsCountryFlag.dimension.width + (20 * game.UIScale), 10 * game.UIScale)
    moneyIcon.dimension = Framework.Dim2.new(20 * game.UIScale, 20 * game.UIScale)
    moneyIcon.zIndex = 102

    local moneyLabel = Framework.Label.new("")
    moneyLabel.position = Framework.Vector2.new(moneyIcon.position.x + moneyIcon.dimension.width + 5 * game.UIScale, 10 * game.UIScale)
    moneyLabel.dimension = Framework.Dim2.new(50 * game.UIScale, 20 * game.UIScale)
    moneyLabel.textAlignment = Framework.TextManager.Alignment.Center
    moneyLabel.zIndex = 102
    moneyLabel:setText("150M")

    local adminIcon = Framework.Image.new("icons/admin.png")
    adminIcon.position = Framework.Vector2.new(moneyLabel.position.x + moneyLabel.dimension.width + (5 * game.UIScale), 10 * game.UIScale)
    adminIcon.dimension = Framework.Dim2.new(20 * game.UIScale, 20 * game.UIScale)
    adminIcon.zIndex = 102

    local adminLabel = Framework.Label.new("")
    adminLabel.position = Framework.Vector2.new(adminIcon.position.x + adminIcon.dimension.width + (5 * game.UIScale), 10 * game.UIScale)
    adminLabel.dimension = Framework.Dim2.new(50 * game.UIScale, 20 * game.UIScale)
    adminLabel.textAlignment = Framework.TextManager.Alignment.Center
    adminLabel.zIndex = 102
    adminLabel:setText("150")

    local researchIcon = Framework.Image.new("icons/research.png")
    researchIcon.position = Framework.Vector2.new(adminLabel.position.x + adminLabel.dimension.width + (5 * game.UIScale), 10 * game.UIScale)
    researchIcon.dimension = Framework.Dim2.new(20 * game.UIScale, 20 * game.UIScale)
    researchIcon.zIndex = 102

    local researchLabel = Framework.Label.new("")
    researchLabel.position = Framework.Vector2.new(researchIcon.position.x + researchIcon.dimension.width + (5 * game.UIScale), 10 * game.UIScale)
    researchLabel.dimension = Framework.Dim2.new(50 * game.UIScale, 20 * game.UIScale)
    researchLabel.textAlignment = Framework.TextManager.Alignment.Center
    researchLabel.zIndex = 102
    researchLabel:setText("50")

    local manpowerIcon = Framework.Image.new("icons/manpower.png")
    manpowerIcon.position = Framework.Vector2.new(researchLabel.position.x + researchLabel.dimension.width + (5 * game.UIScale), 10 * game.UIScale)
    manpowerIcon.dimension = Framework.Dim2.new(20 * game.UIScale, 20 * game.UIScale)
    manpowerIcon.zIndex = 102

    local manpowerLabel = Framework.Label.new("")
    manpowerLabel.position = Framework.Vector2.new(manpowerIcon.position.x + manpowerIcon.dimension.width + (5 * game.UIScale), 10 * game.UIScale)
    manpowerLabel.dimension = Framework.Dim2.new(50 * game.UIScale, 20 * game.UIScale)
    manpowerLabel.textAlignment = Framework.TextManager.Alignment.Center
    manpowerLabel.zIndex = 102
    manpowerLabel:setText("2.5M")

    local factoriesIcon = Framework.Image.new("icons/factory.png")
    factoriesIcon.position = Framework.Vector2.new(manpowerLabel.position.x + manpowerLabel.dimension.width + (5 * game.UIScale), 10 * game.UIScale)
    factoriesIcon.dimension = Framework.Dim2.new(20 * game.UIScale, 20 * game.UIScale)
    factoriesIcon.zIndex = 102

    local factoriesLabel = Framework.Label.new("")
    factoriesLabel.position = Framework.Vector2.new(factoriesIcon.position.x + factoriesIcon.dimension.width + (5 * game.UIScale), 10 * game.UIScale)
    factoriesLabel.dimension = Framework.Dim2.new(50 * game.UIScale, 20 * game.UIScale)
    factoriesLabel.textAlignment = Framework.TextManager.Alignment.Center
    factoriesLabel.zIndex = 102
    factoriesLabel:setText("12")

    local stabilityIcon = Framework.Image.new("icons/stability.png")
    stabilityIcon.position = Framework.Vector2.new(factoriesLabel.position.x + factoriesLabel.dimension.width + (7 * game.UIScale), 10 * game.UIScale)
    stabilityIcon.dimension = Framework.Dim2.new(20 * game.UIScale, 20 * game.UIScale)
    stabilityIcon.zIndex = 102

    local stabilityLabel = Framework.Label.new("")
    stabilityLabel.position = Framework.Vector2.new(stabilityIcon.position.x + stabilityIcon.dimension.width + (5 * game.UIScale), 10 * game.UIScale)
    stabilityLabel.dimension = Framework.Dim2.new(50 * game.UIScale, 20 * game.UIScale)
    stabilityLabel.textAlignment = Framework.TextManager.Alignment.Center
    stabilityLabel.zIndex = 102
    stabilityLabel:setText("85%")

    local dicisionButton = Framework.Button.new("Dicision")
    dicisionButton.position = Framework.Vector2.new(playAsCountryFlag.dimension.width + (20 * game.UIScale), 45 * game.UIScale)
    dicisionButton.backgroundColor = Framework.Color4.new(0.1, 0.1, 0.1, 1)
    dicisionButton.dimension = Framework.Dim2.new(100 * game.UIScale, 22 * game.UIScale)
    dicisionButton.borderSize = 0
    dicisionButton.fontScale = 1
    dicisionButton.cornerRadius = 3 * game.UIScale
    dicisionButton.zIndex = 102

    local researchButton = Framework.Button.new("Research")
    researchButton.position = Framework.Vector2.new(dicisionButton.position.x + dicisionButton.dimension.width + (5 * game.UIScale), 45 * game.UIScale)
    researchButton.backgroundColor = Framework.Color4.new(0.1, 0.1, 0.1, 1)
    researchButton.dimension = Framework.Dim2.new(100 * game.UIScale, 22 * game.UIScale)
    researchButton.borderSize = 0
    researchButton.fontScale = 1
    researchButton.cornerRadius = 3 * game.UIScale
    researchButton.zIndex = 102

    researchButton.onClick = function()

    end

    plusButton.onClick = function()
        game.Speed = math.min(5, game.Speed + 1)
    end

    minusButton.onClick = function()
        game.Speed = math.max(1, game.Speed - 1)
    end

    for i = 1, 5 do
        local speedBar = Framework.Frame.new()
        speedBar.position = Framework.Vector2.new(love.graphics.getWidth() - (115 * game.UIScale) - (i - 1) * (25 * game.UIScale), 32.5 * game.UIScale)
        speedBar.dimension = Framework.Dim2.new(20 * game.UIScale, 2.5 * game.UIScale)
        speedBar.backgroundColor = Framework.Color4.new(1, 1, 1, 1)
        speedBar.borderSize = 0
        speedBar.cornerRadius = 2 * game.UIScale
        speedBar.zIndex = 102

        if game.Speed >= i then
            speedBar.backgroundColor = Framework.Color4.new(1, 1, 1, 1)
        else
            speedBar.backgroundColor = Framework.Color4.new(.2, .2, .2, 1)
        end

        speedBar.onUpdate = function(dt)
            speedBar.position = Framework.Vector2.new(love.graphics.getWidth() - (115 * game.UIScale) - (i - 1) * (25 * game.UIScale), 31 * game.UIScale)
            if game.Speed >= i then
                speedBar.backgroundColor = speedBar.backgroundColor:lerp(Framework.Color4.new(1, 1, 1, 1), 0.2)
            else
                speedBar.backgroundColor = speedBar.backgroundColor:lerp(Framework.Color4.new(.2, .2, .2, 1), 0.2)
            end
        end

        game.Gui["speedBar" .. i] = speedBar
    end

    game.Gui.topBar = topBar
    game.Gui.worldTentionFrame = worldTentionFrame
    game.Gui.worldTentionImage = worldTentionImage
    
    game.Gui.dateLabel = dateLabel

    game.Gui.plusButton = plusButton
    game.Gui.minusButton = minusButton

    game.Gui.playAsCountryFlag = playAsCountryFlag
    game.Gui.playAsCountryFlagFrame = playAsCountryFlagFrame
    game.Gui.playAsCountryFlagOverlay = playAsCountryFlagOverlay

    game.Gui.moneyIcon = moneyIcon
    game.Gui.moneyLabel = moneyLabel

    game.Gui.adminIcon = adminIcon
    game.Gui.adminLabel = adminLabel

    game.Gui.researchIcon = researchIcon
    game.Gui.researchLabel = researchLabel

    game.Gui.manpowerIcon = manpowerIcon
    game.Gui.manpowerLabel = manpowerLabel

    game.Gui.factoriesIcon = factoriesIcon
    game.Gui.factoriesLabel = factoriesLabel

    game.Gui.stabilityIcon = stabilityIcon
    game.Gui.stabilityLabel = stabilityLabel

    game.Gui.dicisionButton = dicisionButton
    game.Gui.researchButton = researchButton

    topBar.onUpdate = function(dt)
        local mx, my = love.mouse.getPosition()
        local mouseDown = love.mouse.isDown(1)

        topBar.dimension = Framework.Dim2.new(love.graphics.getWidth(), 40 * game.UIScale)

        playAsCountryFlag:updateMouse(mx, my, mouseDown)

        plusButton.position = Framework.Vector2.new(love.graphics.getWidth() - (115 * game.UIScale), 45 * game.UIScale)
        plusButton:updateMouse(mx, my, mouseDown)

        minusButton.position = Framework.Vector2.new(love.graphics.getWidth() - (140 * game.UIScale), 45 * game.UIScale)
        minusButton:updateMouse(mx, my, mouseDown)

        worldTentionFrame.position = Framework.Vector2.new(love.graphics.getWidth() - (90 * game.UIScale), 0)
        worldTentionImage.position = Framework.Vector2.new(love.graphics.getWidth() - (80 * game.UIScale), 10 * game.UIScale)

        dateLabel.position = Framework.Vector2.new(love.graphics.getWidth() - (345 * game.UIScale), 10 * game.UIScale)
        dateLabel.text = string.format("%02d/%02d/%04d  %02d:00", game.Date.Day, game.Date.Month, game.Date.Year, game.Date.Hour)
        dateLabel:setText(dateLabel.text)

        dicisionButton:updateMouse(mx, my, mouseDown)
        researchButton:updateMouse(mx, my, mouseDown)
    end

    Framework.GuiManager.add("TopBar", game.Gui)
end

function GameUi.drawGui()
    Framework.GuiManager.draw("TopBar")
end

return GameUi