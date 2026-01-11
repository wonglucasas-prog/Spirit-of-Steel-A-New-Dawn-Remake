local Vector2 = {}
Vector2.__type = "Vector2"
Vector2.__index = Vector2

local function IsVector(givenVector)
    return getmetatable(givenVector) == Vector2
end

function Vector2.new(x, y)
    local self = setmetatable({}, Vector2)
    self.x, self.y = x or 0, y or 0
    return self
end

function Vector2:clone()
    return Vector2.new(self.x, self.y)
end

local factories = {
    one   = function() return Vector2.new(1, 1) end,
    zero  = function() return Vector2.new(0, 0) end,
    xAxis = function() return Vector2.new(1, 0) end,
    yAxis = function() return Vector2.new(0, 1) end,
}

setmetatable(Vector2, {
    _index = function(_, key)
        local factory = factories[key]
        if factory then
            return factory()
        end
    end
})

function Vector2.fromAngle(angle)
    return Vector2.new(math.cos(angle), math.sin(angle))
end

function Vector2:subtract(value)
    if IsVector(value) then
        self.x = self.x - value.x
        self.y = self.y - value.y
    else
        self.x = self.x - value
        self.y = self.y - value
    end
    return self
end

function Vector2:add(value)
    if IsVector(value) then
        self.x = self.x + value.x
        self.y = self.y + value.y
    else
        self.x = self.x + value
        self.y = self.y + value
    end
    return self
end

function Vector2:scale(value)
    if IsVector(value) then
        self.x = self.x * value.x
        self.y = self.y * value.y
    else
        self.x = self.x * value
        self.y = self.y * value
    end
    return self
end

function Vector2:magnitude()
    return math.sqrt(self.x ^ 2 + self.y ^ 2)
end

function Vector2:normalize()
    local magnitude = self:magnitude()
    if magnitude ~= 0 then
        self.x = self.x / magnitude
        self.y = self.y / magnitude
    end
    return self
end

return Vector2