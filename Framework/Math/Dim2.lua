local Dim2 = {}
Dim2.__type = "Dim2"
Dim2.__index = Dim2

local function IsDim2(given)
    return getmetatable(given) == Dim2
end

function Dim2.new(width, height)
    local self = setmetatable({}, Dim2)
    self.width, self.height = width or 0, height or 0
    return self
end

function Dim2:clone()
    return Dim2.new(self.width, self.height)
end

local factories = {
    one   = function() return Dim2.new(1, 1) end,
    zero  = function() return Dim2.new(0, 0) end,
    unitX = function() return Dim2.new(1, 0) end,
    unitY = function() return Dim2.new(0, 1) end,
}

setmetatable(Dim2, {
    _index = function(_, key)
        local factory = factories[key]
        if factory then
            return factory()
        end
    end
})

function Dim2:add(other)
    if IsDim2(other) then
        self.width  = self.width + other.width
        self.height = self.height + other.height
    end
    return self
end

function Dim2:subtract(other)
    if IsDim2(other) then
        self.width  = self.width - other.width
        self.height = self.height - other.height
    end
    return self
end

function Dim2:scale(other)
    if type(other) == "number" then
        self.width  = self.width * other
        self.height = self.height * other
    elseif IsDim2(other) then
        self.width  = self.width * other.width
        self.height = self.height * other.height
    end
    return self
end

function Dim2:area()
    return self.width * self.height
end

function Dim2:aspectRatio()
    if self.height == 0 then return math.huge end
    return self.width / self.height
end

return Dim2