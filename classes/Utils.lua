Utils = class("Utils")

function Utils:conv2Dto1D(x, y, width)
    return x+(y-1)*width
end

function Utils:rectsIntersect(aX1, aX2, aY1, aY2, bX1, bX2, bY1, bY2)
    return (aX1 < bX2) and (bX1 < aX2) and (aY1 < bY2) and (bY1 < aY2)
end

function Utils:inCircleRadius(pX, pY, cX, cY, cR)
    return (pX - cX)^2 + (pY - cY)^2 <= cR^2
end

function Utils:calcAngleBetw2Pts(pt1X, pt1Y, pt2X, pt2Y)
    return math.deg(math.atan2(pt2Y - pt1Y, pt2X - pt1X))+180 --use lume.angle ?
end

function Utils:tableFill(value, length)
    if table.fill then
        return table.fill(value, length)
    else
        local data = {defaultValue}
        for i=1, length do data[i] = value end
        return data
    end
end

function Utils:getTextHeight(text, width, lineHeight)
    local font = love.graphics.getFont()
    local LH = lineHeight and font:getLineHeight()*lineHeight or font:getLineHeight()
    local _, wrappedText = font:getWrap(text, width)
    local totalTextHeight = #wrappedText * font:getHeight()*LH
    local spacing = 5
    return totalTextHeight + spacing
end

function Utils:countAssoTableItems(t)
    local count = 0
    for _ in pairs(t) do
        count = count + 1
    end
    return count
end