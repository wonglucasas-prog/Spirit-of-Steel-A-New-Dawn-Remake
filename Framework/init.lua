local Framework = {}

_G.Framework = Framework

-- Math
Framework.Color4 = require "Framework.Math.Color4"
Framework.Dim2 = require "Framework.Math.Dim2"
Framework.Enum = require "Framework.Math.Enum"
Framework.Vector2 = require "Framework.Math.Vector2"

-- Graphics
Framework.Component = require "Framework.Graphics.Component"
Framework.Sprite = require "Framework.Graphics.Sprite"

Framework.Camera = require "Framework.Graphics.Camera"

Framework.Frame = require "Framework.Graphics.Frame"
Framework.Button = require "Framework.Graphics.Button"
Framework.Label = require "Framework.Graphics.TextLabel"
Framework.Image = require "Framework.Graphics.ImageLabel"
Framework.ImageButton = require "Framework.Graphics.ImageButton"
Framework.ScrollableFrame = require "Framework.Graphics.ScrollableFrame"

-- Managers
Framework.InputManager = require "Framework.Managers.InputManager"
Framework.TextManager = require "Framework.Managers.TextManager"
Framework.GuiManager = require "Framework.Managers.GuiManager"

--Enums
Framework.Sprite.Shape = Framework.Enum.new("SpriteShape", { "Circle", "Rectangle", "Image" })
Framework.Sprite.Style = Framework.Enum.new("SpriteStyle", { "Fill", "Line" })

Framework.TextManager.Alignment = Framework.Enum.new("TextAlignment", { "Left", "Center", "Right" })
Framework.TextManager.VAlignment = Framework.Enum.new("TextVAlignment", { "Top", "Center", "Bottom" })

Framework.Component.Type = Framework.Enum.new("ComponentType", { "Frame", "ScrollableFrame", "Button", "ImageButton", "Label", "Image" })

function math.lerp(a, b, t)
    return a + (b - a) * t
end

return Framework