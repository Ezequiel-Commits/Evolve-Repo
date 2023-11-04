local function FindOnCubicBezier(t, p0, p1, p2, p3)
    -- find t on a cubic bezier curve 

	return (1 - t)^3*p0 + 3*(1 - t)^2*t*p1 + 3*(1 - t)*t^2*p2 + t^3*p3

end

local function createLUT(numSegments, ...) 
    -- create a look-up table given a number of segments and some points
    local distanceSum = 0
    local sums = {}
    local step = 1/numSegments

    for i = 0, 1, step do

        local firstPoint = FindOnCubicBezier(i, ...)
        local secondPoint = FindOnCubicBezier(i + step, ...)
        local distance = (secondPoint - firstPoint).Magnitude
        table.insert(sums, distanceSum)
        distanceSum += distance
    end
    return sums
end

local function remap(n, oldMin, oldMax, min, max)
    -- remap the percentage of an old min and max value onto a new min and max value 
    return (min + ((max - min) * ((n - oldMin) / (oldMax - oldMin))))
end

local Bezier = {}
-- creating a new class
Bezier.__index = Bezier

function Bezier.newCurve(numSegments, p0, p1, p2, p3)

    -- add some basic functionality to our Bezier table
    local self = setmetatable({}, Bezier)
    self._points = {p0, p1, p2, p3}
    self._LUT = createLUT(numSegments, p0, p1, p2, p3)
    
    return self
end

function Bezier:CalcT(t)
    -- calculate t's position on the Bezier Curve and return the result using a new api
    
     local LUT = self._LUT
     local arcLength = LUT[#LUT]
     local targetDistance = arcLength * t
     
     for i, distance in ipairs(LUT) do 
        local nextDistance = LUT[i+1]
        if targetDistance >= distance and targetDistance < nextDistance then 
            local adjustedT = remap(targetDistance, distance, nextDistance, i/#LUT, (i+1)/#LUT)
            return FindOnCubicBezier(adjustedT, unpack(self._points))
        end
     end
end

return Bezier