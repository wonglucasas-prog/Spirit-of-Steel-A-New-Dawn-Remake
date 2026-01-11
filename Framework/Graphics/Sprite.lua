local Sprite = {}
Sprite.__index = Sprite
Sprite.__type = "Sprite"

function Sprite.new(shape, style, parameters)
    local self = setmetatable({}, Sprite)
    self.shape = shape or Sprite.Shape.Rectangle
    self.style = style or Sprite.Style.Fill
    self.position = Framework.Vector2.zero
    self.size = Framework.Dim2.new(50, 50)
    self.rotation = 0
    self.scale = Framework.Vector2.new(1, 1)
    self.origin = Framework.Vector2.zero
    self.color = Framework.Color4.white
    self.image = nil

    if self.shape == Sprite.Shape.Image and parameters and parameters.path then
        self.image = love.graphics.newImage(parameters.path)
        self.size = Framework.Vector2.new(self.image:getWidth(), self.image:getHeight())
    end

    return self
end

function Sprite:draw()
    love.graphics.setColor(self.color:unpack())
    if self.shape == Sprite.Shape.Circle then
        love.graphics.circle(string.lower(self.style.Name), self.position.x, self.position.y, self.size.x / 2)
    elseif self.shape == Sprite.Shape.Rectangle then
        love.graphics.rectangle(string.lower(self.style.Name), self.position.x, self.position.y, self.size.x, self.size.y)
    elseif self.shape == Sprite.Shape.Image and self.image then
        love.graphics.draw(string.lower(self.style.Name), self.position.x, self.position.y, self.rotation, self.scale.x, self.scale.y, self.origin.x, self.origin.y)
    end
end

return Sprite