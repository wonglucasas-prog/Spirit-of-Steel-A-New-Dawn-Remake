local Frame = setmetatable({}, { __index = Framework.Component })
Frame.__type = "Frame"
Frame.__index = Frame

function Frame.new()
    local self = setmetatable( Framework.Component.new(), Frame )
    self.type = Framework.Component.Type.Frame
    self.backgroundColor = Framework.Color4.new(.2, .2, .2, 1)
    self.borderSize = 2
    self.borderColor = Framework.Color4.new(1, 1, 1, 1)
    self.cornerRadius = 0

    return self
end

function Frame:draw()
    love.graphics.push("all")
    love.graphics.setColor(self.backgroundColor:packed())
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

    love.graphics.pop()
end

return Frame