-- DivisionManager.lua
-- Manages all division-related functionality

local DivisionManager = {}

-- Initialize division data structures
function DivisionManager.initialize()
    local DivisionTemplate = require("assets.Objects.DivisionTemplate")
    local Division = require("assets.Objects.Division")

    DivisionManager.Divisions = {}
    DivisionManager.DivisionPositionsX = {}
    DivisionManager.DivisionPositionsY = {}
    DivisionManager.DivisionOwnersY = {} -- Stack offset Y for smooth layout
    DivisionManager.DivisionLerps = {} -- [divIndex] = {startX, startY, endX, endY} - uses fixed t value
    DivisionManager.DivisionOwners = {}
    DivisionManager.DivisionCounts = {}
    DivisionManager.DIVISION_LERP_T = 0.2 -- Fixed lerp factor per frame, independent of game speed
    DivisionManager.PathTweens = {} -- Background tween effects for movement paths
    
    DivisionManager.FlagAtlas = {}
    DivisionManager.FlagQuads = {}
    
    local divisionIconImg = love.graphics.newImage("icons/manpower.png")
    DivisionManager.DivisionBatch = love.graphics.newSpriteBatch(divisionIconImg, 10000, "stream")
    
    local function loadFlagTexture(countryTag)
        if not DivisionManager.FlagAtlas[countryTag] then
            DivisionManager.FlagAtlas[countryTag] = love.graphics.newImage(string.format("flags/%s.png", countryTag))
        end
    end

    local function newDivision(name, owner, province)
        local division = Division.new(DivisionTemplate.Presets.Infantry:toTable())
        division.name = name
        division.owner = owner
        division.CurrentProvince = province

        local idx = #DivisionManager.Divisions + 1
        DivisionManager.Divisions[idx] = division
        DivisionManager.DivisionPositionsX[idx] = province.Center.x
        DivisionManager.DivisionPositionsY[idx] = province.Center.y
        DivisionManager.DivisionOwnersY[idx] = 0 -- Stack offset starts at 0
        DivisionManager.DivisionOwners[idx] = owner
        
        loadFlagTexture(owner)
    end

    if Main and Main.ProvincesManager then
        for _, country in pairs(Main.CountriesManager.Countries) do
            newDivision(country.tag, country.tag, country.Provinces[1])
        end
    end

    local rectW, rectH = 40, 25
    local textObj = love.graphics.newText(Main.Font)
    
    DivisionManager.DivisionTemplate = {
        frame = {
            w = rectW,
            h = rectH,
            color = {0.1, 0.1, 0.1, 1}
        },
        textObj = textObj
    }
end

-- Check if division is selected
function DivisionManager.isDivisionSelected(divIndex)
    return Main.Game.Selection.selectedDivisions[divIndex] == true
end

-- Select a division
function DivisionManager.selectDivision(divIndex)
    Main.Game.Selection.selectedDivisions[divIndex] = true
end

-- Deselect a division
function DivisionManager.deselectDivision(divIndex)
    Main.Game.Selection.selectedDivisions[divIndex] = nil
end

-- Clear all selections
function DivisionManager.clearSelection()
    Main.Game.Selection.selectedDivisions = {}
end

-- Check if a point is inside a province (using division position)
function DivisionManager.getDivisionAtPoint(wx, wy, tolerance)
    tolerance = tolerance or 20
    
    for i = 1, #DivisionManager.Divisions do
        local div = DivisionManager.Divisions[i]
        if div.owner == Main.Game.Player.Country then
            local dx = DivisionManager.DivisionPositionsX[i] - wx
            local dy = DivisionManager.DivisionPositionsY[i] - wy
            local dist = math.sqrt(dx * dx + dy * dy)
            
            if dist < tolerance / Main.Game.cameraZoom then
                return i
            end
        end
    end
    
    return nil
end

-- Get all divisions in a rectangle
function DivisionManager.getDivisionsInRect(x1, y1, x2, y2)
    local minX = math.min(x1, x2)
    local maxX = math.max(x1, x2)
    local minY = math.min(y1, y2)
    local maxY = math.max(y1, y2)
    
    local divisions = {}
    local addedProvinces = {}
    
    -- Check all divisions
    for i = 1, #DivisionManager.Divisions do
        local div = DivisionManager.Divisions[i]
        if div.owner == Main.Game.Player.Country and div.CurrentProvince then
            -- Avoid duplicates from the same province
            if not addedProvinces[div.CurrentProvince] then
                local center = div.CurrentProvince.Center
                if center.x >= minX and center.x <= maxX and center.y >= minY and center.y <= maxY then
                    table.insert(divisions, i)
                    addedProvinces[div.CurrentProvince] = true
                end
            end
        end
    end
    
    return divisions
end

function DivisionManager.findPath(startProvince, endProvince, movingCountryTag)
    if not startProvince or not endProvince then return nil end
    if startProvince == endProvince then return {endProvince} end
    
    -- Determine if the division is starting on land or water
    local isOnWater = false
    if startProvince.Type == "water" or startProvince.Type == "sea" or startProvince.Type == "ocean" then
        isOnWater = true
    end
    
    -- Movement costs depend on where the division is
    local WATER_COST, LAND_COST
    if isOnWater then
        -- Division is on water: prefer water (cost 1), avoid land (cost 3)
        WATER_COST = 1
        LAND_COST = 3
    else
        -- Division is on land: prefer land (cost 1), avoid water (cost 3)
        WATER_COST = 3
        LAND_COST = 1
    end
    
    -- Helper function to get movement cost for a province
    local function getMovementCost(province)
        if province.Type == "water" or province.Type == "sea" or province.Type == "ocean" then
            return WATER_COST
        end
        return LAND_COST
    end
    
    -- Helper function to check if a province can be entered
    local function canEnterProvince(province)
        if not movingCountryTag then return true end
        
        -- Get the country that owns this province
        local provinceOwner = Main.CountriesManager.ProvinceToCountry[province]
        
        -- If no owner (neutral), allow entry
        if not provinceOwner then return true end
        
        -- If the province belongs to the moving country, allow entry
        if provinceOwner == movingCountryTag then return true end
        
        -- Check if the moving country has military access to the province owner
        local movingCountry = Main.CountriesManager.Countries[movingCountryTag]
        if movingCountry and movingCountry:hasMilitaryAccess(provinceOwner) then
            return true
        end
        
        -- Cannot enter - no military access
        return false
    end
    
    -- Dijkstra's algorithm with priority queue
    local distances = {} -- Distance from start to each province
    local cameFrom = {} -- Parent of each province
    local unvisited = {} -- Provinces to visit
    
    -- Initialize
    distances[startProvince] = 0
    cameFrom[startProvince] = "start"
    table.insert(unvisited, startProvince)
    
    while #unvisited > 0 do
        -- Find the unvisited province with the smallest distance
        local current = nil
        local minDist = math.huge
        local currentIndex = 1
        
        for i, province in ipairs(unvisited) do
            local dist = distances[province] or math.huge
            if dist < minDist then
                minDist = dist
                current = province
                currentIndex = i
            end
        end
        
        if not current then break end
        
        -- Remove current from unvisited
        table.remove(unvisited, currentIndex)
        
        -- If we reached the end province, reconstruct the path
        if current == endProvince then
            local path = {}
            local curr = endProvince
            while curr ~= "start" do
                table.insert(path, 1, curr)
                curr = cameFrom[curr]
            end
            return path
        end
        
        -- Check all neighbors
        if current.Neighbours then
            for _, neighbor in pairs(current.Neighbours) do
                if type(neighbor) == "table" then
                    -- Check if we can enter this province
                    if canEnterProvince(neighbor) then
                        local cost = getMovementCost(neighbor)
                        local newDist = (distances[current] or math.huge) + cost
                        
                        -- If we found a shorter path to this neighbor
                        if newDist < (distances[neighbor] or math.huge) then
                            distances[neighbor] = newDist
                            cameFrom[neighbor] = current
                            
                            -- Add to unvisited if not already there
                            local found = false
                            for _, prov in ipairs(unvisited) do
                                if prov == neighbor then
                                    found = true
                                    break
                                end
                            end
                            if not found then
                                table.insert(unvisited, neighbor)
                            end
                        end
                    end
                end
            end
        end
    end
    
    return nil
end

function DivisionManager.orderMove(targetProvince)
    local selectedCount = 0
    for divIndex, _ in pairs(Main.Game.Selection.selectedDivisions) do
        selectedCount = selectedCount + 1
        local div = DivisionManager.Divisions[divIndex]
        
        if div then
            local existingMovement = Main.Game.MovementQueues[divIndex]
            
            local startNode
            local shouldKeepMovement = false
            
            if existingMovement then
                local targetMovementTime = Main.Game.MOVEMENT_TIME / Main.Game.Speed
                local progress = existingMovement.timer / targetMovementTime
                
                local finalTarget = existingMovement.path[#existingMovement.path]
                
                if targetProvince == finalTarget then
                    shouldKeepMovement = true
                    startNode = div.CurrentProvince
                    
                    DivisionManager.DivisionLerps[divIndex] = nil
                    if div.CurrentProvince then
                        DivisionManager.DivisionPositionsX[divIndex] = div.CurrentProvince.Center.x
                        DivisionManager.DivisionPositionsY[divIndex] = div.CurrentProvince.Center.y
                    end
                else
                    shouldKeepMovement = false
                    startNode = div.CurrentProvince
                    
                    DivisionManager.DivisionLerps[divIndex] = nil
                    if div.CurrentProvince then
                        DivisionManager.DivisionPositionsX[divIndex] = div.CurrentProvince.Center.x
                        DivisionManager.DivisionPositionsY[divIndex] = div.CurrentProvince.Center.y
                    end
                end
            else
                startNode = div.CurrentProvince
                shouldKeepMovement = false
            end
            
            if startNode ~= targetProvince then
                local path = DivisionManager.findPath(startNode, targetProvince, div.owner)
                
                -- Debug: Print the path
                if path and #path > 0 then
                    print(string.format("Division %d: Path from %s to %s:", divIndex, tostring(startNode.Id), tostring(targetProvince.Id)))
                    for i, prov in ipairs(path) do
                        print(string.format("  [%d] Province %d", i, prov.Id))
                    end
                end
                
                if path and #path > 0 then
                    if existingMovement and shouldKeepMovement then
                        -- Keep only the current movement, replace the rest
                        -- Truncate the path to keep only up to nextProvinceIndex
                        local newPath = {}
                        for i = 1, existingMovement.nextProvinceIndex do
                            table.insert(newPath, existingMovement.path[i])
                        end
                        
                        -- Append the new path (skip first element to avoid duplicate)
                        for i = 2, #path do
                            table.insert(newPath, path[i])
                        end
                        
                        -- Replace the path but keep timer and nextProvinceIndex
                        existingMovement.path = newPath
                        existingMovement.isLastMove = false
                    else
                        -- Create new movement queue (either no existing movement or progress < 50%)
                        Main.Game.MovementQueues[divIndex] = {
                            path = path,
                            nextProvinceIndex = 2, -- Start moving to path[2] after first timer
                            timer = 0
                        }
                        
                        -- FIX: Only update current province if division is not already moving
                        -- This prevents the hop when spamming new targets
                        if not existingMovement then
                            DivisionManager.Divisions[divIndex].CurrentProvince = path[1]
                            -- Also sync the visual position with the province
                            DivisionManager.DivisionPositionsX[divIndex] = path[1].Center.x
                            DivisionManager.DivisionPositionsY[divIndex] = path[1].Center.y
                        end
                        
                        -- Add background tween effect for the path
                        -- This shows a visual effect from current province to target province
                        if path and #path > 1 then
                            local targetProvince = path[#path]
                            local currentProvince = DivisionManager.Divisions[divIndex].CurrentProvince
                            
                            if currentProvince and targetProvince then
                                DivisionManager.PathTweens[divIndex] = {
                                    startX = currentProvince.Center.x,
                                    startY = currentProvince.Center.y,
                                    endX = targetProvince.Center.x,
                                    endY = targetProvince.Center.y,
                                    timer = 0,
                                    duration = 1.5, -- 1.5 seconds for the background tween
                                    isComplete = false
                                }
                            end
                        end
                    end
                end
            end
        end
    end
    
    return selectedCount
end

-- Update division movement
function DivisionManager.updateMovement(dt)
    for divIndex, movement in pairs(Main.Game.MovementQueues) do
        if movement and not Main.Game.Paused then
            movement.timer = movement.timer + dt * Main.Game.Speed ^ 2
            
            if movement.timer >= Main.Game.MOVEMENT_TIME then
                -- Check if timer threshold reached to advance to next province
                movement.timer = 0
                
                if movement.nextProvinceIndex <= #movement.path then
                    -- Create lerp to the next province
                    local targetProvince = movement.path[movement.nextProvinceIndex]
                    DivisionManager.Divisions[divIndex].CurrentProvince = targetProvince
                    
                    -- Debug: Print movement to next province
                    print(string.format("Division %d: Moving to Province %d (path index %d/%d)", divIndex, targetProvince.Id, movement.nextProvinceIndex, #movement.path))
                    
                    DivisionManager.DivisionLerps[divIndex] = {
                        startX = DivisionManager.DivisionPositionsX[divIndex],
                        startY = DivisionManager.DivisionPositionsY[divIndex],
                        endX = targetProvince.Center.x,
                        endY = targetProvince.Center.y
                    }
                    
                    -- If this is the final province, mark queue for cleanup after lerp completes
                    if movement.nextProvinceIndex == #movement.path then
                        movement.isLastMove = true
                    end
                    
                    movement.nextProvinceIndex = movement.nextProvinceIndex + 1
                else
                    -- Should not reach here with new logic
                    Main.Game.MovementQueues[divIndex] = nil
                end
            end
        end
    end
end

-- Update division lerps (smooth movement)
function DivisionManager.updateDivisionLerps(dt)
    for divIndex, lerp in pairs(DivisionManager.DivisionLerps) do
        if lerp and not Main.Game.Paused then
            -- Apply fixed lerp factor t = 0.2, independent of game speed
            -- This creates smooth, flexible movement regardless of game speed
            local t = DivisionManager.DIVISION_LERP_T
            local newX = lerp.startX + (lerp.endX - lerp.startX) * t
            local newY = lerp.startY + (lerp.endY - lerp.startY) * t
            
            -- Check if we've reached the target (within small tolerance)
            local distX = math.abs(newX - lerp.endX)
            local distY = math.abs(newY - lerp.endY)
            
            if distX < 0.1 and distY < 0.1 then
                -- Snap to final position and complete lerp
                DivisionManager.DivisionPositionsX[divIndex] = lerp.endX
                DivisionManager.DivisionPositionsY[divIndex] = lerp.endY
                DivisionManager.DivisionLerps[divIndex] = nil
                
                -- If this was the final move, clean up the movement queue
                if Main.Game.MovementQueues[divIndex] and Main.Game.MovementQueues[divIndex].isLastMove then
                    Main.Game.MovementQueues[divIndex] = nil
                    
                    -- FIX: When movement completes, sync division position with its current province
                    -- This prevents hopping when starting a new movement
                    local div = DivisionManager.Divisions[divIndex]
                    if div and div.CurrentProvince then
                        DivisionManager.DivisionPositionsX[divIndex] = div.CurrentProvince.Center.x
                        DivisionManager.DivisionPositionsY[divIndex] = div.CurrentProvince.Center.y
                    end
                end
            else
                -- Update position
                DivisionManager.DivisionPositionsX[divIndex] = newX
                DivisionManager.DivisionPositionsY[divIndex] = newY
                
                -- Update start position for next frame's lerp
                lerp.startX = newX
                lerp.startY = newY
            end
        end
    end
end

-- Update path tween effects (background visual effects)
function DivisionManager.updatePathTweens(dt)
    for divIndex, tween in pairs(DivisionManager.PathTweens) do
        if tween and not Main.Game.Paused then
            tween.timer = tween.timer + dt
            
            -- Check if the tween is complete
            if tween.timer >= tween.duration then
                tween.isComplete = true
                DivisionManager.PathTweens[divIndex] = nil
            end
        end
    end
end

-- Update division counts (for stacking)
function DivisionManager.updateDivisionCounts()
    DivisionManager.DivisionCounts = {}
    
    for i = 1, #DivisionManager.Divisions do
        -- Only count divisions that are NOT currently moving
        if not Main.Game.MovementQueues[i] then
            local province = DivisionManager.Divisions[i].CurrentProvince
            if province then
                if not DivisionManager.DivisionCounts[province] then
                    DivisionManager.DivisionCounts[province] = {}
                end
                
                local owner = DivisionManager.DivisionOwners[i]
                if not DivisionManager.DivisionCounts[province][owner] then
                    DivisionManager.DivisionCounts[province][owner] = {
                        count = 0,
                        divisions = {}
                    }
                end
                
                DivisionManager.DivisionCounts[province][owner].count = DivisionManager.DivisionCounts[province][owner].count + 1
                table.insert(DivisionManager.DivisionCounts[province][owner].divisions, i)
            end
        end
    end
end

-- Update stack offsets for divisions in the same province
function DivisionManager.updateStackOffsets(dt)
    -- Calculate target stack offsets for divisions in the same province
    local frameHeight = DivisionManager.DivisionTemplate.frame.h
    local stackSpacing = frameHeight -- Gap between stacked divisions
    
    -- Calculate target offsets
    local divisionStackPositions = {} -- [divIndex] = targetOffsetY
    
    for province, ownerData in pairs(DivisionManager.DivisionCounts) do
        local totalStacks = 0
        for _, _ in pairs(ownerData) do totalStacks = totalStacks + 1 end
        
        local totalHeight = totalStacks * stackSpacing
        local startOffsetY = -totalHeight / 2 + stackSpacing / 2
        local currentStack = 0
        
        for owner, data in pairs(ownerData) do
            local targetOffsetY = startOffsetY + currentStack * stackSpacing
            for _, divIndex in ipairs(data.divisions) do
                divisionStackPositions[divIndex] = targetOffsetY
            end
            currentStack = currentStack + 1
        end
    end
    
    -- Apply offsets directly (no smooth lerp)
    for i = 1, #DivisionManager.Divisions do
        local targetOffsetY = divisionStackPositions[i] or 0
        DivisionManager.DivisionOwnersY[i] = targetOffsetY
    end
end

-- Check if a province has a selected division
function DivisionManager.isProvinceSelected(province)
    for i = 1, #DivisionManager.Divisions do
        if DivisionManager.Divisions[i].CurrentProvince == province and DivisionManager.isDivisionSelected(i) then
            return true
        end
    end
    return false
end

-- Draw divisions
function DivisionManager.drawDivisions()
    local cameraX, cameraY = Main.Game.Camera:getPosition()
    local cameraZoom = Main.Game.cameraZoom
    local tileWidth = Main.Game.CurrentMap:getWidth()
    local screenWidth, screenHeight = love.graphics.getWidth(), love.graphics.getHeight()
    local anchorX, anchorY = Main.Game.Camera:getAnchor()
    local anchorPixelX, anchorPixelY = (anchorX or 0.5) * screenWidth, (anchorY or 0.5) * screenHeight

    local minX = cameraX - anchorPixelX / cameraZoom
    local maxX = cameraX + (screenWidth - anchorPixelX) / cameraZoom
    local minY = cameraY - anchorPixelY / cameraZoom
    local maxY = cameraY + (screenHeight - anchorPixelY) / cameraZoom

    local startIndex = math.floor(minX / tileWidth) - 1
    local endIndex = math.floor(maxX / tileWidth) + 1

    local textScale = .8
    local template = DivisionManager.DivisionTemplate
    local frameWidth, frameHeight = template.frame.w, template.frame.h
    local textObject = template.textObj

    local function drawUnitBox(screenX, screenY, owner, count, isSelected)
        local flag = DivisionManager.FlagAtlas[owner]
        local flagWidth, flagHeight = 0, 0

        if flag then
            flagHeight = frameHeight * 0.8
            flagWidth = flag:getWidth() * (flagHeight / flag:getHeight())
        end

        local totalWidth = frameWidth + flagWidth
        
        -- Calculate the top-left corner for drawing (center the box at screenX, screenY)
        local boxX = screenX - totalWidth / 2
        local boxY = screenY - frameHeight / 2

        love.graphics.setColor(template.frame.color)
        love.graphics.rectangle("fill", boxX, boxY, totalWidth, frameHeight)

        if owner == Main.Game.Player.Country then
            love.graphics.setColor(0, 1, 0, 1)
            love.graphics.setLineWidth(1)
            love.graphics.rectangle("line", boxX, boxY, totalWidth, frameHeight)
        end

        if isSelected then
            love.graphics.setColor(1, 1, 0, 1)
            love.graphics.setLineWidth(1)
            love.graphics.rectangle("line", boxX, boxY, totalWidth, frameHeight)
        end

        if flag then
            love.graphics.setColor(1, 1, 1, 1)
            love.graphics.draw(flag, boxX + frameHeight * 0.1, boxY + frameHeight * 0.1, 0, flagWidth / flag:getWidth(), flagHeight / flag:getHeight())
        end

        textObject:setf(tostring(count or 1), frameWidth / textScale, "center")
        love.graphics.setColor(1, 1, 1, 1)
        love.graphics.draw(textObject, boxX + flagWidth / 2 + frameWidth / 2, boxY + frameHeight / 2 - (love.graphics.getFont():getHeight() * textScale) / 2, 0, textScale, textScale)
    end

    for province, ownerData in pairs(DivisionManager.DivisionCounts) do
        local center = province.Center
        if not center then goto continue end

        local baseY = center.y
        if baseY < minY or baseY > maxY then goto continue end

        for owner, data in pairs(ownerData) do
            for i = startIndex, endIndex do
                local worldX = center.x + i * tileWidth
                if worldX < minX or worldX > maxX then goto nextTile end

                local isAnySelected = false
                for _, divIndex in ipairs(data.divisions) do
                    if DivisionManager.isDivisionSelected(divIndex) then 
                        isAnySelected = true 
                        break 
                    end
                end
                
                local totalDivisionsY = 0
                for _, divIndex in ipairs(data.divisions) do
                    local offsetY = DivisionManager.DivisionOwnersY[divIndex] or 0
                    local screenX, screenY = Main.Game.Camera:toScreen(worldX, baseY)
                    -- Apply offset in screen space (not affected by camera zoom)
                    screenY = screenY + offsetY
                    drawUnitBox(screenX, screenY, owner, 1, DivisionManager.isDivisionSelected(divIndex))
                    totalDivisionsY = offsetY
                end

                ::nextTile::
            end
        end
        ::continue::
    end

    for divIndex = 1, #DivisionManager.Divisions do
        local div = DivisionManager.Divisions[divIndex]
        if not div then goto continueMoving end
        
        -- Only draw moving divisions here; stationary divisions are drawn above
        if not Main.Game.MovementQueues[divIndex] then goto continueMoving end

        local baseX = DivisionManager.DivisionPositionsX[divIndex] or (div.CurrentProvince and div.CurrentProvince.Center.x) or 0
        local baseY = DivisionManager.DivisionPositionsY[divIndex] or (div.CurrentProvince and div.CurrentProvince.Center.y) or 0

        for i = startIndex, endIndex do
            local worldX = baseX + i * tileWidth
            if worldX >= minX and worldX <= maxX and baseY >= minY and baseY <= maxY then
                local screenX, screenY = Main.Game.Camera:toScreen(worldX, baseY)
                drawUnitBox(screenX, screenY, div.owner, 1, DivisionManager.isDivisionSelected(divIndex))
            end
        end
        ::continueMoving::
    end
end

-- Draw movement paths
function DivisionManager.drawMovementPaths()
    love.graphics.setLineWidth(6)
    
    for divIndex, lerp in pairs(DivisionManager.DivisionLerps) do
        if DivisionManager.isDivisionSelected(divIndex) then
            local startX = lerp.startX
            local startY = lerp.startY
            local endX = lerp.endX
            local endY = lerp.endY
            
            local currentX = DivisionManager.DivisionPositionsX[divIndex]
            local currentY = DivisionManager.DivisionPositionsY[divIndex]
            local distToEnd = math.sqrt((endX - currentX)^2 + (endY - currentY)^2)
            local totalDist = math.sqrt((endX - startX)^2 + (endY - startY)^2)
            local progress = totalDist > 0 and (1 - distToEnd / totalDist) or 0
            
            local dx = endX - startX
            local dy = endY - startY
            local dist = math.sqrt(dx * dx + dy * dy)
            
            local controlOffset = dist * 0.5
            local p0 = {x = startX, y = startY}
            local p1 = {x = startX + dx * 0.3, y = startY + dy * 0.3 - controlOffset * 0.4}
            local p2 = {x = startX + dx * 0.7, y = startY + dy * 0.7 - controlOffset * 0.4}
            local p3 = {x = endX, y = endY}
            
            love.graphics.setColor(0.2, 1, 0.2, 0.2)
            local sx1, sy1 = Main.Game.Camera:toScreen(p0.x, p0.y)
            local sx2, sy2 = Main.Game.Camera:toScreen(p3.x, p3.y)
            love.graphics.line(sx1, sy1, sx2, sy2)
            
            -- Draw progress portion in bright color
            if progress > 0 then
                local progressX = startX + (endX - startX) * progress
                local progressY = startY + (endY - startY) * progress
                local sx3, sy3 = Main.Game.Camera:toScreen(progressX, progressY)
                love.graphics.setColor(0.2, 1, 0.2, 0.9)
                love.graphics.line(sx1, sy1, sx3, sy3)
            end
        end
    end
    
    -- Draw timer-based movement progress from current province to next province
    for divIndex, movement in pairs(Main.Game.MovementQueues) do
        if movement and DivisionManager.isDivisionSelected(divIndex) then
            local path = movement.path
            if path and movement.nextProvinceIndex <= #path then
                -- Current province is at nextProvinceIndex - 1
                local currentProvinceIdx = movement.nextProvinceIndex - 1
                if currentProvinceIdx >= 1 then
                    local startProvince = path[currentProvinceIdx]
                    local endProvince = path[movement.nextProvinceIndex]
                    
                    if startProvince and endProvince then
                        local startX = startProvince.Center.x
                        local startY = startProvince.Center.y
                        local endX = endProvince.Center.x
                        local endY = endProvince.Center.y
                        
                        -- Calculate progress based on actual time (independent of game speed)
                        -- This ensures progress percentage remains constant when speed changes
                        local progress = math.min(1, movement.timer / Main.Game.MOVEMENT_TIME)
                        
                        -- Draw full segment in dim color
                        love.graphics.setColor(1, 0.8, 0, 0.2)
                        local sx1, sy1 = Main.Game.Camera:toScreen(startX, startY)
                        local sx2, sy2 = Main.Game.Camera:toScreen(endX, endY)
                        love.graphics.line(sx1, sy1, sx2, sy2)
                        
                        -- Draw progress portion in bright color
                        love.graphics.setColor(1, 0.8, 0, 0.9)
                        local progressX = startX + (endX - startX) * progress
                        local progressY = startY + (endY - startY) * progress
                        local sx3, sy3 = Main.Game.Camera:toScreen(progressX, progressY)
                        love.graphics.line(sx1, sy1, sx3, sy3)
                    end
                end
            end
        end
    end
    
    love.graphics.setLineWidth(1)
end

-- Update path tween effects (background visual effects)
function DivisionManager.updatePathTweens(dt)
    for divIndex, tween in pairs(DivisionManager.PathTweens) do
        if tween and not Main.Game.Paused then
            tween.timer = tween.timer + dt
            
            -- Check if the tween is complete
            if tween.timer >= tween.duration then
                tween.isComplete = true
                DivisionManager.PathTweens[divIndex] = nil
            end
        end
    end
end

-- Draw background path tween effects
function DivisionManager.drawPathTweens()
    for divIndex, tween in pairs(DivisionManager.PathTweens) do
        if tween and tween.path and #tween.path > 1 then
            local div = DivisionManager.Divisions[divIndex]
            if div then
                -- Calculate alpha based on timer (fade in then fade out)
                local alpha = 1.0
                if tween.timer < tween.duration * 0.3 then
                    -- Fade in
                    alpha = tween.timer / (tween.duration * 0.3)
                elseif tween.timer > tween.duration * 0.7 then
                    -- Fade out
                    alpha = 1.0 - ((tween.timer - tween.duration * 0.7) / (tween.duration * 0.3))
                end
                
                -- Get country color
                local country = Main.CountriesManager.getCountryByTag(div.CountryTag)
                local r, g, b = 0.5, 0.5, 0.5 -- Default gray
                if country then
                    r, g, b = country.Color.r / 255, country.Color.g / 255, country.Color.b / 255
                end
                
                -- Draw the path with the calculated alpha
                love.graphics.setColor(r, g, b, alpha * 0.4)
                love.graphics.setLineWidth(3)
                
                -- Draw bezier curve through the path points
                local points = {}
                for i, point in ipairs(tween.path) do
                    table.insert(points, point.x)
                    table.insert(points, point.y)
                end
                
                love.graphics.line(points)
                
                -- Draw small dots at each waypoint to make the path more visible
                love.graphics.setColor(r, g, b, alpha * 0.6)
                for i, point in ipairs(tween.path) do
                    love.graphics.circle("fill", point.x, point.y, 2)
                end
            end
        end
    end
end

return DivisionManager
