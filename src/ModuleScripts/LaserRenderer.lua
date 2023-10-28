local laserRenderer = {}

local shotDuration = 0.15

function laserRenderer.createLaser(toolHandle, endPosition)
	local startPosition = toolHandle.Position
	local laserDistance = (endPosition - startPosition).magnitude
	
	-- create a cframe based off the invisible ray
	local laserCFrame = CFrame.lookAt(startPosition,endPosition)*CFrame.new(0, 0, -laserDistance / 2)
	local laserPart = Instance.new("Part")
	
	-- Create the laser and it's properties 
	laserPart.Parent = workspace
	laserPart.Size = Vector3.new(0.2,0.2,laserDistance)
	laserPart.Anchored = true
	laserPart.CanCollide = false
	laserPart.CFrame = laserCFrame
	
	-- Add the laser beam to the Debris service to be removed and cleaned up
	game.Debris:AddItem(laserPart,shotDuration)
	
	-- play the weapon's shooting sound for everyone in the server
	local shootingSound = toolHandle:FindFirstChild("Activated")
	if shootingSound then
		shootingSound:Play()
	end
end

return laserRenderer
