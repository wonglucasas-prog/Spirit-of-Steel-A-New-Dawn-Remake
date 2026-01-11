local Label = setmetatable({}, { __index = Framework.Component })
Label.__type = "Label"
Label.__index = Label

function Label.new(text)
    local self = setmetatable(Framework.Component.new(), Label)
    self.type = Framework.Component.Type.Label
    self.text = text or ""

    self.textColor = Framework.Color4.new(1, 1, 1, 1)

    self.textAlignment = Framework.TextManager.Alignment.Left

    self.textVAlignment = Framework.TextManager.VAlignment.Center
    return self
end

function Label:draw()
    love.graphics.push("all")

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

return Label