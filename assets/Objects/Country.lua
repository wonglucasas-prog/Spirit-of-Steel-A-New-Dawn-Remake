local Country = {}
Country.__type = "Country"
Country.__index = Country

function Country.new(name, colour)
    local self = setmetatable({}, Country)
    self.tag = name or ""
    self.Colour = colour or Framework.Color4.new(1, 1, 1, 1)
    self.Money = 0
    self.AdminstrationPoint = 0
    self.ResearchPoint = 0
    self.Parties = {
        Communist = {
            Name = "Country Worker's Union",
            Popularity = .5,
        },
        Fascist = {
            Name = "National Front",
            Popularity = .3,
        },
        Democratic = {
            Name = "People's Party",
            Popularity = .2,
        },
        Neutral = {
            Name = "Indenpendent",
            Popularity = 0,
        },
    }
    self.Government = {
        Type = "Democratic",
        Stability = 50,
        WarSupport = 50,
    }
    self.Provinces = {}
    self.MilitaryAccess = {} -- Table of country tags that have military access
    return self
end

function Country:addProvince(province)
    table.insert(self.Provinces, province)
end

function Country:grantMilitaryAccess(countryTag)
    self.MilitaryAccess[countryTag] = true
end

function Country:revokeMilitaryAccess(countryTag)
    self.MilitaryAccess[countryTag] = nil
end

function Country:hasMilitaryAccess(countryTag)
    return self.MilitaryAccess[countryTag] == true
end

return Country
