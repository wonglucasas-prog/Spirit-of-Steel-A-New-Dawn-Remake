local Button = setmetatable({}, { __index = Framework.Component })
Button.__type = "Button"
Button.__index = Button

function Button.new(text)
    local self = setmetatable(Framework.Component.new(), Button)
    self.type = Framework.Component.Type.Button
    self.text = text or "Button"

    self.backgroundColor = Framework.Color4.new(.3, .3, .3, 1)
    self.hoverColor = Framework.Color4.new(.4, .4, .4, 1)
    self.pressColor = Framework.Color4.new(.2, .2, .2, 1)
    self.textColor = Framework.Color4.new(1, 1, 1, 1)

    self.cornerRadius = 4
    self.borderSize = 2

    self.targetColor = self.backgroundColor

    self.borderColor = Framework.Color4.new(1, 1, 1, 1)

    self.textAlignment = Framework.TextManager.Alignment.Center
    self.textVAlignment = Framework.TextManager.VAlignment.Center
    
    return self
end

function Button:draw()
    love.graphics.push("all")

    if self.isMouseDown then
        self.targetColor = self.targetColor:lerp(self.pressColor, .2)
    elseif self.isMouseHovering then
        self.targetColor = self.targetColor:lerp(self.hoverColor, .2)
    else
        self.targetColor = self.targetColor:lerp(self.backgroundColor, .2)
    end

    love.graphics.setColor(self.targetColor:packed())
    love.graphics.rectangle("fill",
        self.position.x,
        self.position.y,
        self.dimension.width,
        self.dimension.height,
        self.cornerRadius,
        self.cornerRadius
    )

    if self.borderSize > 0 then
        love.graphics.setLineWidth(self.borderSize)
        love.graphics.setColor(self.borderColor:packed())
        love.graphics.rectangle("line",
            self.position.x,
            self.position.y,
            self.dimension.width,
            self.dimension.height,
            self.cornerRadius,
            self.cornerRadius
        )
    end

    local font = love.graphics.getFont()
    local yOffset = Framework.TextManager.getTextYOffset(font, self.textVAlignment, self.dimension)

    love.graphics.setColor(self.textColor:packed())
    love.graphics.printf(
        self.text,
        self.position.x,
        self.position.y + yOffset,
        self.dimension.width,
        string.lower(self.textAlignment.Name)
    )

    love.graphics.pop()
end

return Button