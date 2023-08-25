local function ETC()
	print("ETC:" .. "Is this easy to change?")
end

-- game:BindToClose(ETC)

--[[addressDatabase = {
	
	Elmer = 1,
	Eze = 2,
	Saul = 3
	
}

print(addressDatabase)

for i, v in pairs(addressDatabase) do 
	wait(0.5)
	print(i,v)
end]]

-- trying to understand how a weld constraint works
local partA = Instance.new("Part")
local partB = Instance.new("Part")

partA.Position = Vector3.new(0, 10, 0)
partA.Parent = game.Workspace

partB.Position = Vector3.new(0, 10, 10)
partB.Parent = game.Workspace

local weld = Instance.new("WeldConstraint")
weld.Parent = partA
weld.Part0 = partA
weld.Part1 = partB