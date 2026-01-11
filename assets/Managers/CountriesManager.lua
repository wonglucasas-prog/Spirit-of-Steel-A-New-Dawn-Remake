local CountriesManager = {}
CountriesManager.Tags = {}
CountriesManager.Countries = {}

local function toByte(v)
    if not v then return 0 end
    if v <= 1 then return math.floor(v * 255 + 0.5) end
    return math.floor(v + 0.5)
end

local function colorKeyFromPixel(r, g, b, a)
    return string.format("%d,%d,%d,%d", toByte(r), toByte(g), toByte(b), toByte(a or 1))
end

function CountriesManager.loadTags(tagsFilePath)
    local contents, err = love.filesystem.read(tagsFilePath)
    if not contents then print("CountriesManager.loadFromTags: failed to read tags file:", err); return {} end

    local tags = {}
    for line in contents:gmatch("[^\n]+") do
        local tag, v = line:match("^%s*([%w_]+)%s*=%s*(.*)%s*$")
        if tag and v and #v > 0 then
            v = v:gsub("^%s*%[", ""):gsub("%]%s*$", "")
            local r, g, b = v:match("(%d+)%s*,%s*(%d+)%s*,%s*(%d+)")
            if r and g and b then tags[tag] = { tonumber(r), tonumber(g), tonumber(b) } end
        end
    end

    CountriesManager.Tags = tags
end

function CountriesManager.buildCountries(imageData)
    local Countries = {}

    local Country = require "assets.Objects.Country"
    local colorToTag = {}
    for tag, col in pairs(CountriesManager.Tags) do colorToTag[string.format("%d,%d,%d,255", col[1], col[2], col[3])] = tag end

    local Provinces = Main and Main.ProvincesManager and Main.ProvincesManager.Provinces or {}
    for _, province in pairs(Provinces) do
        local px, py = 0, 0
        if province.Pixels and #province.Pixels > 0 then px, py = province.Pixels[1].x, province.Pixels[1].y end
        local r, g, b, a = imageData:getPixel(px, py)
        local pkey = colorKeyFromPixel(r, g, b, a)
        local tag = colorToTag[pkey] or colorToTag[string.format("%s,255", pkey:gsub(",%d$", ""))]
        if tag then
            local country = Countries[tag]
            if not country then country = Country.new(tag, { r, g, b, a }); Countries[tag] = country end
            country:addProvince(province)
        end
    end
    CountriesManager.Countries = Countries

    CountriesManager.ProvinceToCountry = {}
    for tag, country in pairs(Countries) do
        for _, p in ipairs(country.Provinces or {}) do
            CountriesManager.ProvinceToCountry[p] = tag
        end
    end
    return Countries
end

return CountriesManager
