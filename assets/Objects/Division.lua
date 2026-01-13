-- Division.lua
-- Basic division template similar to HOI4 divisions

local Division = {}
Division.__index = Division

function Division.new(params)
    params = params or {}
    local self = setmetatable({}, Division)
    self.name = params.name or "unnamed"
    self.owner = params.owner or nil

    self.divisionTemplate = 0

    self.softAttack = params.softAttack or 0
    self.hardAttack = params.hardAttack or 0
    self.hardness = params.hardness or 0
    self.defense = params.defense or 0
    self.breakthrough = params.breakthrough or 0
    self.width = params.width or 1
    
    return self
end

function Division.fromTable(t)
    return Division.new(t)
end

function Division:toTable()
    return {
        name = self.name,
        owner = self.owner,
        softAttack = self.softAttack,
        hardAttack = self.hardAttack,
        hardness = self.hardness,
        defense = self.defense,
        breakthrough = self.breakthrough,
        width = self.width,
    }
end

function Division:clone()
    return Division.new(self:toTable())
end

function Division:__tostring()
    return string.format("Division(%s) S:%s H:%s Hard:%s D:%s B:%s W:%s",
        tostring(self.name), tostring(self.softAttack), tostring(self.hardAttack),
        tostring(self.hardness), tostring(self.defense), tostring(self.breakthrough), tostring(self.width))
end

-- Example usage:
-- local Division = require("maps.Objects.Division")
-- local inf = Division.new{ name = "Infantry", softAttack = 2, hardAttack = 0, hardness = 0, defense = 1, breakthrough = 0, width = 1 }
-- print(inf)

return Division
