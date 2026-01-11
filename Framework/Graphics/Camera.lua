local Camera = {}
Camera.__index = Camera

function Camera.new(x, y, scale)
    local self = setmetatable({}, Camera)
    self.position = Framework.Vector2.new(x or 0, y or 0)
    self.target = Framework.Vector2.new(x or 0, y or 0)
    self.damping = 15
    self.scale = scale or 1
    self.targetScale = scale or 1
    self.anchor = Framework.Vector2.new(0.5, 0.5)
    return self
end

function Camera:setPosition(x, y)
    self.position.x = x
    self.position.y = y
    self.target.x = x
    self.target.y = y
end

function Camera:changePosition(dx, dy)
    self.position.x = self.position.x + dx
    self.position.y = self.position.y + dy
    self.target.x = self.target.x + dx
    self.target.y = self.target.y + dy
end

-- Move only the camera position (do not modify the target)
function Camera:translatePosition(dx, dy)
    self.position.x = self.position.x + (dx or 0)
    self.position.y = self.position.y + (dy or 0)
end

function Camera:setTarget(x, y)
    self.target.x = x
    self.target.y = y
end

function Camera:changeTarget(dx, dy)
    self.target.x = self.target.x + dx
    self.target.y = self.target.y + dy
end

function Camera:update(dt)
    local responseTime = 1 - math.exp(-self.damping * dt)
    local currentX = math.lerp(self.position.x, self.target.x, responseTime)
    local currentY = math.lerp(self.position.y, self.target.y, responseTime)

    self.position.x = currentX
    self.position.y = currentY
end

function Camera:getPosition()
    return self.position.x, self.position.y
end

function Camera:setScale(s)
    self.scale = s
    self.targetScale = s
end

function Camera:setTargetScale(s)
    self.targetScale = s
end

function Camera:getScale()
    return self.scale
end

function Camera:getTargetScale()
    return self.targetScale
end

function Camera:setAnchor(ax, ay)
    if type(ax) == "table" and ax.x and ax.y then
        self.anchor.x = ax.x
        self.anchor.y = ax.y
    else
        self.anchor.x = ax or self.anchor.x
        self.anchor.y = ay or self.anchor.y
    end
end

function Camera:getAnchor()
    return self.anchor.x, self.anchor.y
end

function Camera:changeAnchor(dx, dy)
    self.anchor.x = self.anchor.x + (dx or 0)
    self.anchor.y = self.anchor.y + (dy or 0)
end

function Camera:toWorld(screenX, screenY)
    local w = love.graphics.getWidth()
    local h = love.graphics.getHeight()
    local anchorPxX = (self.anchor.x or 0.5) * w
    local anchorPxY = (self.anchor.y or 0.5) * h
    local worldX = self.position.x + (screenX - anchorPxX) / self.scale
    local worldY = self.position.y + (screenY - anchorPxY) / self.scale
    return worldX, worldY
end

function Camera:toScreen(worldX, worldY)
    local w = love.graphics.getWidth()
    local h = love.graphics.getHeight()
    local anchorPxX = (self.anchor.x or 0.5) * w
    local anchorPxY = (self.anchor.y or 0.5) * h
    local screenX = anchorPxX + (worldX - self.position.x) * self.scale
    local screenY = anchorPxY + (worldY - self.position.y) * self.scale
    return screenX, screenY
end

function Camera:draw(scaledCallbacks, unscaledCallbacks)
    love.graphics.push("all")

    local screenWidth = love.graphics.getWidth()
    local screenHeight = love.graphics.getHeight()
    local anchorPxX = (self.anchor.x or 0.5) * screenWidth
    local anchorPxY = (self.anchor.y or 0.5) * screenHeight

    love.graphics.translate(anchorPxX, anchorPxY)
    love.graphics.scale(self.scale)
    love.graphics.translate(-self.position.x, -self.position.y)

    if type(scaledCallbacks) == "table" then
        for _, callback in ipairs(scaledCallbacks) do
            callback()
        end
    elseif type(scaledCallbacks) == "function" then
        scaledCallbacks()
    end

    love.graphics.push()
    love.graphics.scale(1 / self.scale)

    if type(unscaledCallbacks) == "table" then
        for _, callback in ipairs(unscaledCallbacks) do
            callback()
        end
    elseif type(unscaledCallbacks) == "function" then
        unscaledCallbacks()
    end

    love.graphics.pop()
    love.graphics.pop()
end


return Camera
