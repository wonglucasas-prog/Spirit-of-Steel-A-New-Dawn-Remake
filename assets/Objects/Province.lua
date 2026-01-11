local Province = {}
Province.__type = "Province"
Province.__index = Province

function Province.new(id)
    local self = setmetatable({}, Province)
    -- keep both conventions (Id and id) for compatibility across the project
    self.Id = id or 0
    
    self.Pixels = {}
    self.BorderPixels = {}

    self.Type = "Unknown"
    self.Neighbours = {}
    self.NeighboursCount = 0

    -- Center will be calculated after pixels are added by the loader
    self.Center = Framework.Vector2.new(0, 0)

    return self
end

function Province:calculateCenter()
    local sumX, sumY = 0, 0
    local count = #self.Pixels
    if count == 0 then
        self.Center = Framework.Vector2.new(0, 0)
        return self.Center
    end

    for _, pixel in ipairs(self.Pixels) do
        sumX = sumX + pixel.x
        sumY = sumY + pixel.y
    end

    self.Center = Framework.Vector2.new(sumX / count + .5, sumY / count + .5)
    
    return self.Center
end

function Province:addPixel(x, y)
    table.insert(self.Pixels, Framework.Vector2.new(x, y))
end

function Province:addBorderPixel(x, y)
    table.insert(self.BorderPixels, Framework.Vector2.new(x, y))
end

return Province