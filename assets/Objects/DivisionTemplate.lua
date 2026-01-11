local DivisionTemplate = {}
DivisionTemplate.__type = "DivisionTemplate"
DivisionTemplate.__index = DivisionTemplate

function DivisionTemplate.new(params)
    params = params or {}
    local self = setmetatable({}, DivisionTemplate)
    self.name = params.name or "unnamed_template"
    self.softAttack = tonumber(params.softAttack) or 0
    self.hardAttack = tonumber(params.hardAttack) or 0
    self.hardness = tonumber(params.hardness) or 0
    self.defense = tonumber(params.defense) or 0
    self.breakthrough = tonumber(params.breakthrough) or 0
    self.manpower = tonumber(params.manpower) or 0
    self.width = tonumber(params.width) or 1
    return self
end

function DivisionTemplate.fromTable(t)
    return DivisionTemplate.new(t)
end

function DivisionTemplate:toTable()
    return {
        name = self.name,
        softAttack = self.softAttack,
        hardAttack = self.hardAttack,
        manpower = self.manpower,
        hardness = self.hardness,
        defense = self.defense,
        breakthrough = self.breakthrough,
        width = self.width,
    }
end

function DivisionTemplate:clone()
    return DivisionTemplate.new(self:toTable())
end

function DivisionTemplate:__tostring()
    return string.format("DivisionTemplate(%s) S:%s H:%s Hard:%s D:%s B:%s W:%s",
        tostring(self.name), tostring(self.softAttack), tostring(self.hardAttack),
        tostring(self.hardness), tostring(self.defense), tostring(self.breakthrough), tostring(self.width))
end

-- Convenience predefined templates
DivisionTemplate.Presets = {
    Infantry = DivisionTemplate.new{ name = "Infantry", softAttack = 2, hardAttack = 0, hardness = 0, defense = 1, breakthrough = 0, width = 1 },
    Mechanized = DivisionTemplate.new{ name = "Mechanized", softAttack = 3, hardAttack = 1, hardness = 1, defense = 2, breakthrough = 1, width = 2 },
    Armor = DivisionTemplate.new{ name = "Armor", softAttack = 4, hardAttack = 2, hardness = 2, defense = 3, breakthrough = 3, width = 3 },
}

-- Example usage in comments:
-- local DivisionTemplate = require("assets.Objects.DivisionTemplate")
-- local t = DivisionTemplate.Presets.Infantry:clone()
-- print(t)

return DivisionTemplate
