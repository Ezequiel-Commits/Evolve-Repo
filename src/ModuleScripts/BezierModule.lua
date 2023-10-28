-- make a bezier curve given a set of 4 points and a point(t) to lerp
local function cubicBezier(t, p0, p1, p2, p3)

	return (1 - t)^3*p0 + 3*(1 - t)^2*t*p1 + 3*(1 - t)*t^2*p2 + t^3*p3

end

local function createLUT(numSegments, ...) -- at 17 minutes 
    -- create a look-up table given a number of segments and some points
    local distSum = 0
    local sums = {}
    local step = 1/numSegments

    for i = 0, 1, step do

        local firstPoint = cubicBezier(i, ...)
        local secondPoint = cubicBezier(i + step, ...)
        local dist = firstPoint
    end

end

local Bezier = {}
-- encapsulation
Bezier.__index = Bezier

function Bezier.new(p0, p1, p2, p3)
    -- use the position of four points to create a cubic Bezier curve
    
    -- syntax jargon
    local self = setmetatable({}, Bezier)
    self._points = {p0, p1, p2, p3}

    return self
end

function Bezier:Calc(t)
    -- calculate the Bezier Curve and return the result using a new api
    
    return cubicBezier(t, unpack(self._points))

end

return Bezier