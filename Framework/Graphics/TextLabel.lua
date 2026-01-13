local Label = setmetatable({}, { __index = Framework.Component })
Label.__type = "Label"
Label.__index = Label

function Label.new(text, font)
    local self = setmetatable(Framework.Component.new(), Label)
    self.type = Framework.Component.Type.Label
    self.text = text or ""

    -- Property: Font Object (can be nil to use default)
    self.font = font or nil 
    
    -- New Property: Scale
    -- 1.0 = original size, 2.0 = double size, 0.5 = half size
    self.fontScale = 1.0 

    self.textColor = Framework.Color4.new(1, 1, 1, 1)

    self.textAlignment = Framework.TextManager.Alignment.Left
    self.textVAlignment = Framework.TextManager.VAlignment.Center
    
    return self
end

function Label:draw()
    love.graphics.push("all")

    local activeFont = self.font or love.graphics.getFont()
    local scale = self.fontScale or 1
    
    love.graphics.setFont(activeFont)
    love.graphics.setColor(self.textColor:packed())

    local standardHeight = activeFont:getHeight()
    local scaledHeight = standardHeight * scale

    local yOffset = 0
    if self.textVAlignment == Framework.TextManager.VAlignment.Center then
        yOffset = (self.dimension.height - scaledHeight) / 2
    elseif self.textVAlignment == Framework.TextManager.VAlignment.Bottom then
        yOffset = self.dimension.height - scaledHeight
    end

    love.graphics.printf(
        self.text,
        self.position.x,
        self.position.y + yOffset,
        self.dimension.width / scale,
        string.lower(self.textAlignment.Name),
        0,
        scale,
        scale
    )

    love.graphics.pop()
end

return Label