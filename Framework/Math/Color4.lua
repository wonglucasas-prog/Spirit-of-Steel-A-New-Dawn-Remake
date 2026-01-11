local Color4 = {}
Color4.__type = "Color4"
Color4.__index = Color4

local factories = {
    white = function() return Color4.new(1, 1, 1, 1) end,
    black = function() return Color4.new(0, 0, 0, 1) end,
    red   = function() return Color4.new(1, 0, 0, 1) end,
    green = function() return Color4.new(0, 1, 0, 1) end,
    blue  = function() return Color4.new(0, 0, 1, 1) end,
}

setmetatable(Color4, {
    _index = function(_, key)
        local factory = factories[key]
        if factory then
            return factory()
        end
    end
})

function Color4.IsColor4(given)
    return getmetatable(given) == Color4
end

function Color4.new(r, g, b, a)
    local self = setmetatable({}, Color4)
    self.r, self.g, self.b, self.a = r or 1, g or 1, b or 1, a or 1
    return self
end

function Color4:packed()
    return { self.r, self.g, self.b, self.a }
end

function Color4:darken(amount)
    return Color4.new(
        math.max(self.r - amount, 0),
        math.max(self.g - amount, 0),
        math.max(self.b - amount, 0),
        self.a
    )
end

function Color4:lighten(amount)
    return Color4.new(
        math.min(self.r + amount, 1),
        math.min(self.g + amount, 1),
        math.min(self.b + amount, 1),
        self.a
    )
end

function Color4:clone()
    return Color4.new(self.r, self.g, self.b, self.a)
end

function Color4.random()
    return Color4.new(love.math.random(), love.math.random(), love.math.random(), 1)
end

function Color4:lerp(other, t)
    return Color4.new(
        self.r + (other.r - self.r) * t,
        self.g + (other.g - self.g) * t,
        self.b + (other.b - self.b) * t,
        self.a + (other.a - self.a) * t
    )
end

function Color4:withAlpha(a)
    return Color4.new(self.r, self.g, self.b, a)
end

function Color4:unpack()
    return self.r, self.g, self.b, self.a
end

-- conversions
function Color4.fromRGB(r, g, b, a)
    return Color4.new(r / 255, g / 255, b / 255, (a or 255) / 255)
end

function Color4:toRGB()
    return math.floor(self.r * 255 + 0.5),
           math.floor(self.g * 255 + 0.5),
           math.floor(self.b * 255 + 0.5),
           math.floor(self.a * 255 + 0.5)
end

function Color4.fromHex(hex)
    hex = hex:gsub("#", "")
    local r = tonumber(hex:sub(1, 2), 16)
    local g = tonumber(hex:sub(3, 4), 16)
    local b = tonumber(hex:sub(5, 6), 16)
    local a = #hex == 8 and tonumber(hex:sub(7, 8), 16) or 255
    return Color4.fromRGB(r, g, b, a)
end

function Color4:toHex(withAlpha)
    local r, g, b, a = self:toRGB()

    if withAlpha then
        return string.format("#%02X%02X%02X%02X", r, g, b, a)
    else
        return string.format("#%02X%02X%02X", r, g, b)
    end
end

return Color4