local Component = {}
Component.__type = "GUIComponent"
Component.__index = Component

Component._handCursor = love.mouse.getSystemCursor("hand")
Component._arrowCursor = love.mouse.getSystemCursor("arrow")

function Component.new()
    local self = setmetatable({}, Component)
    self.dimension = Framework.Dim2.new(100, 50)
    self.position = Framework.Vector2.new(0, 0)
    self.type = Component.Type.Frame
    self.zIndex = 1
    self.active = true

    self.canMouseHover = false
    self.canMouseDown = false
    self.isMouseHovering = false
    self.isMouseDown = false
    self._prevMouseDown = false

    self.onMouseHover = nil
    self.onMouseDown = nil
    self.onMouseUp = nil
    self.onUpdate = nil
    self.onClick = nil

    return self
end

local function pointInBounds(component, x, y)
    local px, py = component.position.x, component.position.y
    local w, h = component.dimension.width, component.dimension.height
    return x >= px and x <= px + w and y >= py and y <= py + h
end

function Component:updateMouse(x, y, mousePressed)
    local inBounds = pointInBounds(self, x, y)

    if inBounds and not self.isMouseHovering then
        self.isMouseHovering = true
        love.mouse.setCursor(Component._handCursor)
        if self.onMouseHover then self.onMouseHover(self) end
        self:onMouseEnter()
    elseif not inBounds and self.isMouseHovering then
        self.isMouseHovering = false
        love.mouse.setCursor(Component._arrowCursor)
        self:onMouseLeave()
    end

    local justPressed = mousePressed and not self._prevMouseDown
    local justReleased = (not mousePressed) and self._prevMouseDown

    if inBounds and justPressed then
        self.isMouseDown = true
        if self.onMouseDown then self.onMouseDown(self) end
    end

    if (not inBounds) and self.isMouseDown then
        self.isMouseDown = false
        if self.onMouseUp then self.onMouseUp(self) end
    end

    if inBounds and justReleased and self.isMouseDown then
        self.isMouseDown = false
        if self.onMouseUp then self.onMouseUp(self) end
        if self.onClick then self.onClick(self) end
    elseif justReleased and self.isMouseDown then
        self.isMouseDown = false
        if self.onMouseUp then self.onMouseUp(self) end
    end

    self._prevMouseDown = mousePressed
end

function Component:update()
    if self.onUpdate then self:onUpdate() end
end

function Component:onMouseEnter() end
function Component:onMouseLeave() end

return Component