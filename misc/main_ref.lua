_G.Framework = require "Framework"

local ui = {}

function love.load()
    love.graphics.setBackgroundColor(0.12, 0.12, 0.12, 1)

    Framework.InputManager.loveCallbacks()

    ui.frame = Framework.Frame.new()
    ui.frame.position = Framework.Vector2.new(100, 100)
    ui.frame.dimension = Framework.Dim2.new(400, 220)
    ui.frame.backgroundColor = Framework.Color4.new(0.18, 0.18, 0.22, 1)
    ui.frame.borderColor = Framework.Color4.new(1, 1, 1, 0.15)
    ui.frame.zIndex = 1
    ui.frame.borderSize = 1
    ui.frame.cornerRadius = 8

    ui.label = Framework.Label.new("Hello, Steel UI!")
    ui.label.position = Framework.Vector2.new(ui.frame.position.x + 16, ui.frame.position.y + 16)
    ui.label.dimension = Framework.Dim2.new(ui.frame.dimension.width - 32, 24)
    ui.label.textAlignment = Framework.TextManager.Alignment.Center
    ui.label.zIndex = 2

    ui.scrollableFrame = Framework.ScrollableFrame.new()
    ui.scrollableFrame.position = Framework.Vector2.new(520, 100)
    ui.scrollableFrame.dimension = Framework.Dim2.new(240, 294)
    ui.label.zIndex = 3

    ui.image = Framework.Image.new()
    ui.image.cornerRadius = 5
    ui.image.position = Framework.Vector2.new(800, 100)
    ui.image.dimension = Framework.Dim2.new(200, 200)
    ui.image.borderSize = 2

    ui.imageButton = Framework.ImageButton.new("icon.jpg")
    ui.imageButton.cornerRadius = 5
    ui.imageButton.position = Framework.Vector2.new(1050, 100)
    ui.imageButton.dimension = Framework.Dim2.new(200, 200)
    ui.imageButton.borderSize = 2

    ui.imageButton.onUpdate = function(dt)
        local mx,my = love.mouse.getPosition()
        local mouseDown = Framework.InputManager.isMouseDown(1)
        ui.imageButton:updateMouse(mx, my, mouseDown)
    end

    ui.imageButton.onClick = function(dt)
        ui.label.text = "Image clicked!"
    end

    local selectedButton = nil
    
    for i = 1, 20 do
        for j = 1, 2 do
            local button = Framework.Button.new()
            button.position = Framework.Vector2.new(ui.scrollableFrame.position.x + 8 + 116 * (j - 1), ui.scrollableFrame.position.y + (i-1)*48 + 8)
            button.dimension = Framework.Dim2.new(108, 40)
            button.borderColor = Framework.Color4.new(.5, .5, .5, 1)
            button.text = "Item " .. i .. j

            button.onUpdate = function(dt)
                if button == selectedButton then
                    button.borderColor = button.borderColor:lerp(Framework.Color4.new(1, 1, 1, 1), .2)
                else
                    button.borderColor = button.borderColor:lerp(Framework.Color4.new(.5, .5, .5, .5), .2)
                end
            end
    
            button.onClick = function(dt)
                selectedButton = button
                ui.label.text = "Button " .. i .. j .. " clicked!"
            end
    
            ui.scrollableFrame:addChild(button)
        end
      end

    ui.scrollableFrame.scrollSpeed = 48
    ui.scrollableFrame:setScrollLimits((40 + 8) * 20 + 8)

    ui.scrollableFrame.onUpdate = function(dt)
        local mx,my = love.mouse.getPosition()
        local mouseDown = Framework.InputManager.isMouseDown(1)
        ui.scrollableFrame:updateMouse(mx, my, mouseDown)
    end

    Framework.GuiManager.add("Menu", ui)
end
-- This is the end of the main_ref.lua file.
-- Moving this file to the misc folder.
-- The new path will be c:\Users\ASUS\Documents\Love2ds\Steel\misc\main_ref.lua
-- Ensure to update any references to this file in your project.
-- The content of the file remains unchanged.
-- The following lines are the same as before.
function love.update(dt)
    Framework.GuiManager.update("Menu")
end
function love.draw()
    Framework.GuiManager.draw("Menu")
end
function love.wheelmoved(x, y)
    Framework.GuiManager.wheelmoved("Menu", x, y)
end