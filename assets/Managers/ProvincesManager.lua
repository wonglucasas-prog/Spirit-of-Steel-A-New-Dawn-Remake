local ProvincesManager = {}
ProvincesManager.BorderPixels = {}
ProvincesManager.Provinces = {}

local function toByte(v)
    if not v then return 0 end
    if v <= 1 then return math.floor(v * 255 + 0.5) end
    return math.floor(v + 0.5)
end

local function colorKeyFromPixel(r, g, b, a)
    return string.format("%d,%d,%d,%d", toByte(r), toByte(g), toByte(b), toByte(a or 1))
end

local function gridNeighbours(x, y)
    local n = {}
    for yy = y - 1, y + 1 do
        for xx = x - 1, x + 1 do
            if not (xx == x and yy == y) then table.insert(n, { xx, yy }) end
        end
    end

    return n
end

local function orthogonalNeighbours(x, y)
    return {
        { x - 1, y },
        { x + 1, y },
        { x, y - 1 },
        { x, y + 1 },
    }
end

function ProvincesManager.findProvinceNeighbours(provinces)
    local pixelOwners = {}

    -- Build the pixel ownership map
    for key, province in pairs(provinces) do
        if province.BorderPixels then
            for _, pixel in ipairs(province.BorderPixels) do
                local coord = pixel.x .. "," .. pixel.y
                pixelOwners[coord] = pixelOwners[coord] or {}
                table.insert(pixelOwners[coord], key)
            end
        end
    end

    -- Initialize empty neighbors tables
    for _, province in pairs(provinces) do
        province.Neighbours = {}
    end

    -- Connect provinces that share border pixels
    for _, owners in pairs(pixelOwners) do
        if #owners > 1 then
            for i = 1, #owners do
                for j = 1, #owners do
                    if i ~= j then
                        local provinceKeyA = owners[i]
                        local provinceKeyB = owners[j]
                        -- Make sure we're not adding the province to its own neighbors
                        if provinceKeyA ~= provinceKeyB and provinces[provinceKeyA] and provinces[provinceKeyB] then
                            provinces[provinceKeyA].Neighbours[provinceKeyB] = provinces[provinceKeyB]
                        end
                    end
                end
            end
        end
    end

    -- Count neighbors for each province
    for _, province in pairs(provinces) do
        local count = 0
        for _ in pairs(province.Neighbours) do count = count + 1 end
        province.NeighboursCount = count
    end
end

function ProvincesManager.loadProvinces(imageData)
    ProvincesManager.Provinces = {}
    ProvincesManager.BorderPixels = {}  -- Ensure BorderPixels is initialized
    local provinceId = 0
    local blackKey = colorKeyFromPixel(0, 0, 0, 1)

    imageData:mapPixel(function(x, y, r, g, b, a)
        if not a or a == 0 then return r, g, b, a end

        local key = colorKeyFromPixel(r, g, b, a)
        if key ~= blackKey then
            local province = ProvincesManager.Provinces[key]
            if not province then
                provinceId = provinceId + 1
                province = Main.Province.new(provinceId)
                ProvincesManager.Provinces[key] = province
            end
            province:addPixel(x, y)
        else
            table.insert(ProvincesManager.BorderPixels, Framework.Vector2.new(x, y))
            for _, neighbor in ipairs(orthogonalNeighbours(x, y)) do
                local nx, ny = neighbor[1], neighbor[2]
                if nx >= 0 and nx < imageData:getWidth() and ny >= 0 and ny < imageData:getHeight() then
                    local nr, ng, nbcol, na = imageData:getPixel(nx, ny)
                    if na and na > 0 then
                        local neighborKey = colorKeyFromPixel(nr, ng, nbcol, na)
                        if neighborKey ~= blackKey then
                            local province = ProvincesManager.Provinces[neighborKey]
                            if not province then
                                provinceId = provinceId + 1
                                province = Main.Province.new(provinceId)
                                ProvincesManager.Provinces[neighborKey] = province
                            end
                            province:addBorderPixel(x, y)
                        end
                    end
                end
            end
        end

        return r, g, b, a
    end)

    local count = 0
    for _ in pairs(ProvincesManager.Provinces) do count = count + 1 end
    print(string.format("ProvincesManager: loaded %d provinces (ids up to %d)", count, provinceId))

    local biomesImg = Main and Main.BiomesImageData
    local biomeMap = {}

    local contents = nil
    if love.filesystem.getInfo("assets/Datas/biomeTypes.txt") then
        contents = love.filesystem.read("assets/Datas/biomeTypes.txt")
    end

    if contents then
        for line in contents:gmatch("[^\n]+") do
            local t, v = line:match("^%s*([%w_]+)%s*=%s*(.*)%s*$")
            if t and v then
                v = v:gsub("^%s*%[", ""):gsub("%]%s*$", "")
                local r, g, b = v:match("(%d+)%s*,%s*(%d+)%s*,%s*(%d+)")
                if r and g and b then
                    biomeMap[string.format("%d,%d,%d", tonumber(r), tonumber(g), tonumber(b))] = t
                end
            end
        end
    end

    for _, province in pairs(ProvincesManager.Provinces) do
        if province.calculateCenter then province:calculateCenter() end
        province.Type = "Unknown"
        if biomesImg and province.Pixels and #province.Pixels > 0 then
            local sx, sy = province.Pixels[1].x, province.Pixels[1].y
            local r, g, b = biomesImg:getPixel(sx, sy)
            local key = string.format("%d,%d,%d", toByte(r), toByte(g), toByte(b))
            if biomeMap[key] then province.Type = biomeMap[key] end
        end
    end

    return ProvincesManager.Provinces
end

function ProvincesManager.GetProvinceFromVector(x, y, imageData)
    local img = imageData or (Main and Main.ProvincesImageData)
    if not img then return nil end
    local w, h = img:getWidth(), img:getHeight()
    if w == 0 or h == 0 then return nil end

    local fx, fy = math.floor(x), math.floor(y)
    local ipx = ((fx % w) + w) % w
    local ipy = ((fy % h) + h) % h

    local r, g, b, a = img:getPixel(ipx, ipy)
    local key = colorKeyFromPixel(r, g, b, a)
    local p = ProvincesManager.Provinces[key]
    if p then return p, ipx, ipy, key, "direct" end

    -- neighbor fallback (8-neighbors)
    for ny = ipy - 1, ipy + 1 do
        for nx = ipx - 1, ipx + 1 do
            if not (nx == ipx and ny == ipy) then
                local nxw = ((nx % w) + w) % w
                local nyw = ((ny % h) + h) % h
                local nr, ng, nb, na = img:getPixel(nxw, nyw)
                local nkey = colorKeyFromPixel(nr, ng, nb, na)
                local np = ProvincesManager.Provinces[nkey]
                if np then return np, ipx, ipy, nkey, "neighbor" end
            end
        end
    end

    return nil, ipx, ipy, key, "none"
end

function ProvincesManager:callAll(funcName)
    for _, p in pairs(ProvincesManager.Provinces) do
        if p[funcName] then p[funcName](p) end
    end
end

function ProvincesManager.generateBorders(imageData, modifier)
    modifier = modifier or 0.7
    local imageWidth, imageHeight = imageData:getDimensions()

    local rawBytes = imageData:getString()

    local pixelTable = {}
    local pixelIndex = 1
    local rawLength = #rawBytes
    local stringByte = string.byte
    for byteIndex = 1, rawLength, 4 do
        local r = stringByte(rawBytes, byteIndex)
        local g = stringByte(rawBytes, byteIndex + 1)
        local b = stringByte(rawBytes, byteIndex + 2)
        pixelTable[pixelIndex] = r * 65536 + g * 256 + b
        pixelIndex = pixelIndex + 1
    end

    local function unpackToNormalizedFloat(packedValue)
        local r = math.floor(packedValue / 65536) % 256
        local g = math.floor(packedValue / 256) % 256
        local b = packedValue % 256
        return r / 255, g / 255, b / 255  -- Normalize to [0, 1]
    end

    local blackKey = 0

    local destinationImage = imageData:clone()
    local pixelArray = pixelTable
    local unpackFunction = unpackToNormalizedFloat

    destinationImage:mapPixel(function(x, y, r, g, b, a)
        if not (r == 0 and g == 0 and b == 0) then
            return r, g, b, a
        end

        local foundPackedValue = nil
        local uniqueNeighborCount = 0

        local neighborX0 = x - 1
        local neighborY0 = y - 1
        local minX = (neighborX0 >= 0) and neighborX0 or 0
        local maxX = ((x + 1) < imageWidth) and (x + 1) or (imageWidth - 1)
        local minY = (neighborY0 >= 0) and neighborY0 or 0
        local maxY = ((y + 1) < imageHeight) and (y + 1) or (imageHeight - 1)

        for ny = minY, maxY do
            local rowBase = ny * imageWidth
            for nx = minX, maxX do
                if not (nx == x and ny == y) then
                    local tableIndex = rowBase + nx + 1
                    local packedNeighbor = pixelArray[tableIndex]
                    if packedNeighbor ~= blackKey then
                        if uniqueNeighborCount == 0 then
                            foundPackedValue = packedNeighbor
                            uniqueNeighborCount = 1
                        else
                            if packedNeighbor ~= foundPackedValue then
                                uniqueNeighborCount = 2
                                minY = maxY
                                break
                            end
                        end
                    end
                end
            end
        end

        if uniqueNeighborCount == 1 then
            local unpackedRed, unpackedGreen, unpackedBlue = unpackFunction(foundPackedValue)
            return unpackedRed * modifier, unpackedGreen * modifier, unpackedBlue * modifier, 1
        end

        return 0, 0, 0, 1
    end)

    return destinationImage
end

return ProvincesManager
