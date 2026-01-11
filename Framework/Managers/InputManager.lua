local InputManager = {}

local keysDown = {}
local keysPressed = {}
local mouseButtonsDown = {}
local mouseButtonsPressed = {}

function InputManager.keyPressed(key)
    keysDown[key] = true
    
    keysPressed[key] = true
end

function InputManager.keyReleased(key)
    keysDown[key] = nil
end

function InputManager.mousePressed(x, y, button)
    mouseButtonsPressed[button] = true
    mouseButtonsDown[button] = true
end

function InputManager.mouseReleased(x, y, button)
    mouseButtonsDown[button] = nil
end

function InputManager.isKeyDown(key)
    return keysDown[key] or false
end

function InputManager.isKeyPressed(key)
    return keysPressed[key] or false
end

function InputManager.isMouseDown(button)
    return mouseButtonsDown[button] or false
end

function InputManager.isMousePressed(button)
    return mouseButtonsPressed[button] or false
end

function InputManager.clearPressed()
    keysPressed = {}
    mouseButtonsPressed = {}
end

function InputManager.loveCallbacks()
    love.keypressed = function(key) 
        InputManager.keyPressed(key)
    end

    love.keyreleased = function(key)
        InputManager.keyReleased(key)
    end

    love.mousepressed = function(x, y, button)
        InputManager.mousePressed(x, y, button)
    end

    love.mousereleased = function(x, y, button)
        InputManager.mouseReleased(x, y, button)
    end
end

return InputManager
