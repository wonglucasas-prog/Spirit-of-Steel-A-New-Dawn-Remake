local ScrollableFrame = setmetatable({}, { __index = Framework.Component })
ScrollableFrame.__type = "ScrollableFrame"
ScrollableFrame.__index = ScrollableFrame

function ScrollableFrame.new()
	local self = setmetatable(Framework.Component.new(), ScrollableFrame)
	self.type = Framework.Component.Type.ScrollableFrame
	self.dimension = Framework.Dim2.new(200, 200)
	self.position = Framework.Vector2.new(0, 0)
	self.backgroundColor = Framework.Color4.new(0.15, 0.15, 0.15, 1)
	self.borderSize = 1
	self.borderColor = Framework.Color4.new(1, 1, 1, 0.1)
	self.cornerRadius = 4

	self.contents = {}
    self.smoothScroll = true

    self.damping = 20

	self.scroll = 0
    self.targetScroll = 0

	self.scrollMax = 0
	self.scrollSpeed = 24

	return self
end

function ScrollableFrame:addChild(child)
	self.contents[#self.contents + 1] = child
end

function ScrollableFrame:setScrollLimits(totalContentHeight)
	local maxScroll = math.max(0, (totalContentHeight or 0) - self.dimension.height)
	self.scrollMax = maxScroll
	if self.scroll > self.scrollMax then
		self.scroll = self.scrollMax
	end
end

function ScrollableFrame:wheelmoved(x, y)
	if y ~= 0 and self.isMouseHovering then
		self.targetScroll = math.max(0, math.min(self.targetScroll - y * self.scrollSpeed, self.scrollMax))
	end
end

function ScrollableFrame:updateMouse(x, y, mousePressed)
    Framework.Component.updateMouse(self, x, y, mousePressed)

    local vx, vy = self.position.x, self.position.y
    local vw, vh = self.dimension.width, self.dimension.height
    self.isMouseHovering = x >= vx and x <= vx + vw and y >= vy and y <= vy + vh

    if not self.isMouseHovering then
        for _, child in ipairs(self.contents) do
            if child.isMouseDown then
                child.isMouseDown = false
                if child.onMouseUp then child.onMouseUp(child) end
            end
            if child.isMouseHovering then
                child.isMouseHovering = false
                if child.onMouseLeave then child:onMouseLeave() end
            end
            if child._prevMouseDown then child._prevMouseDown = mousePressed end
        end
        return
    end

    local offsetY = y + self.scroll
    for _, child in ipairs(self.contents) do
        if child.onUpdate then child:onUpdate() end
        child:updateMouse(x, offsetY, mousePressed)
    end

    self.scroll = math.lerp(self.scroll, self.targetScroll, self.smoothScroll and 1 - math.exp(-self.damping * Main.deltaTime) or 1)
end

function ScrollableFrame:draw()
    love.graphics.push("all")

    love.graphics.setColor(self.backgroundColor:packed())
    love.graphics.rectangle("fill",
        self.position.x,
        self.position.y,
        self.dimension.width,
        self.dimension.height,
        self.cornerRadius,
        self.cornerRadius
    )

    if self.borderSize > 0 then
        love.graphics.setLineWidth(self.borderSize)
        love.graphics.setColor(self.borderColor:packed())
        love.graphics.rectangle("line",
            self.position.x,
            self.position.y,
            self.dimension.width,
            self.dimension.height,
            self.cornerRadius,
            self.cornerRadius
        )
    end

    local x, y, w, h = self.position.x, self.position.y, self.dimension.width, self.dimension.height
    local prevScissor = { love.graphics.getScissor() }
    love.graphics.setScissor(x, y, w, h)

    love.graphics.push()
    love.graphics.translate(0, -self.scroll)

    for i, child in ipairs(self.contents) do
        local success, err = pcall(child.draw, child)
        if not success then
            print("Error drawing child " .. i .. ": " .. tostring(err))
        end
    end

    love.graphics.pop()

    if prevScissor[1] then
        love.graphics.setScissor(prevScissor[1], prevScissor[2], prevScissor[3], prevScissor[4])
    else
        love.graphics.setScissor()
    end

    love.graphics.pop()
end

return ScrollableFrame


