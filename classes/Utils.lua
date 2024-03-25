Utils = class("Utils")

function Utils:conv2Dto1D(x, y, width)
    return x+(y-1)*width
end

function Utils:rectsIntersect(aX1, aX2, aY1, aY2, bX1, bX2, bY1, bY2)
    return (aX1 < bX2) and (bX1 < aX2) and (aY1 < bY2) and (bY1 < aY2)
end

--[[function Utils:calcAngle = lume.memoize(function(mouse, target)
    return math.atan2(mouse.x - B.y, M.x - B.x)
end)--]]
