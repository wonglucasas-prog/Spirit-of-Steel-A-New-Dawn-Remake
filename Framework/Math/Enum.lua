local Enum = {}
Enum.__index = Enum
Enum.__type = "Enum"

function Enum.new(typeName, values)
    local self = {}

    self.__type = typeName
    self.__index = self

    for _, valueName in ipairs(values) do
        self[valueName] = setmetatable({
            Name = valueName,
            Type = typeName,
        }, self)
    end

    return self
end

return Enum