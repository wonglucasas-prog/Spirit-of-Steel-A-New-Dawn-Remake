_G.Framework = require "Framework"
_G.Main = {
    -- Scenes
    Game = require "assets.Scenes.Game",
    
    -- Managers
    ProvincesManager = require "assets.Managers.ProvincesManager",
    CountriesManager = require "assets.Managers.CountriesManager",
    DivisionsManager = require "assets.Managers.DivisionManager",

    -- Objects
    Province = require "assets.Objects.Province"
}

function Framework.loadFont(size)
    local fontFolder = "assets/Font"
    local fontFile

    for _, file in ipairs(love.filesystem.getDirectoryItems(fontFolder)) do
        if file:match("%.ttf$") or file:match("%.otf$") then
            fontFile = fontFolder .. "/" .. file
            break
        end
    end

    if fontFile then
        local font = love.graphics.newFont(fontFile, size)
        return font
    else
        local font = love.graphics.newFont(size)
        print("No .ttf or .otf font found in " .. fontFolder)
        return font
    end
end

function love.load()
    Main.Font = Framework.loadFont(15)
    love.graphics.setFont(Main.Font)

    Main.BiomesImageData = love.image.newImageData("assets/maps/biomes.png")
    Main.ProvincesImageData = love.image.newImageData("assets/maps/regions.png")
    Main.CountriesImageData = love.image.newImageData("assets/starts/Second World War/map.png")
    
    Main.Provinces = Main.ProvincesManager.loadProvinces(Main.ProvincesImageData)
    Main.ProvincesManager.findProvinceNeighbours(Main.Provinces)

    Main.Countries = Main.CountriesManager.loadTags("assets/Datas/countryTags.txt")
    Main.Countries = Main.CountriesManager.buildCountries(Main.CountriesImageData)

    Main.Game.initialize()
end

function love.update(dt)
    Main.deltaTime = dt
end