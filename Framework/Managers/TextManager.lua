local TextManager = {}

function TextManager.getTextYOffset(font, vAlignment, dimension)
    local fh = font:getHeight()
    if vAlignment == TextManager.VAlignment.Top then
        return 0
    elseif vAlignment == TextManager.VAlignment.Center then
        return (dimension.height - fh) / 2
    elseif vAlignment == TextManager.VAlignment.Bottom then
        return dimension.height - fh
    end
    return 0
end

return TextManager