local ImageButton = setmetatable({}, { __index = Framework.Component })
ImageButton.__type = "ImageButton"
ImageButton.__index = ImageButton

function ImageButton.new(path)
	local self = setmetatable(Framework.Component.new(), ImageButton)
	self.type = Framework.Component.Type.ImageButton
	self.image = path and love.graphics.newImage(path) or love.graphics.newImage("placeholder.png")
	if self.image then
		self.dimension = Framework.Dim2.new(self.image:getWidth(), self.image:getHeight())
	end
	self.color = Framework.Color4.new(1, 1, 1, 1)
	self.hoverColor = Framework.Color4.new(1.2, 1.2, 1.2, 1)
	self.pressColor = Framework.Color4.new(0.9, 0.9, 0.9, 1)
	self.tintOnHover = Framework.Color4.new(1, 1, 1, 1)
	self.tintOnPress = Framework.Color4.new(0.9, 0.9, 0.9, 1)
	self.scaleMode = "fit"
	self.borderSize = 0
	self.borderColor = Framework.Color4.new(1, 1, 1, 1)
	self.cornerRadius = 0

	self.onClick = nil

	return self
end

local function computeDrawParams(self)
	if not self.image then return nil end
	local iw, ih = self.image:getWidth(), self.image:getHeight()
	local cw, ch = self.dimension.width, self.dimension.height
	local x, y = self.position.x, self.position.y
	local sx, sy = 1, 1
	local dx, dy = x, y

	if self.scaleMode == "none" then
		sx, sy = 1, 1
		dx = x
		dy = y
	elseif self.scaleMode == "stretch" then
		sx = cw / iw
		sy = ch / ih
		dx = x
		dy = y
	elseif self.scaleMode == "fill" then
		local scale = math.max(cw / iw, ch / ih)
		sx = scale
		sy = scale
		local rw, rh = iw * sx, ih * sy
		dx = x + (cw - rw) / 2
		dy = y + (ch - rh) / 2
	else -- fit
		local scale = math.min(cw / iw, ch / ih)
		sx = scale
		sy = scale
		local rw, rh = iw * sx, ih * sy
		dx = x + (cw - rw) / 2
		dy = y + (ch - rh) / 2
	end

	return dx, dy, 0, sx, sy
end

function ImageButton:draw()
    love.graphics.push()

	local color = self.color
    if self.isMouseDown then
        color = self.pressColor
    elseif self.isMouseHovering then
        color = self.hoverColor
    end

    local function stencil()
        love.graphics.rectangle("fill",
            self.position.x,
            self.position.y,
            self.dimension.width,
            self.dimension.height,
            self.cornerRadius,
            self.cornerRadius
        )
    end

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

	if self.image then
        if self.cornerRadius > 0 then
            love.graphics.stencil(stencil, "replace", 1)
            love.graphics.setStencilTest("greater", 0)
        end

        local dx, dy, r, sx, sy = computeDrawParams(self)
        love.graphics.setColor(self.color:unpack())
        love.graphics.draw(self.image, dx, dy, r, sx, sy)

        if self.cornerRadius > 0 then
            love.graphics.setStencilTest()
        end
    end
	
    love.graphics.pop()
	love.graphics.setColor(1, 1, 1, 1)
end

return ImageButton


