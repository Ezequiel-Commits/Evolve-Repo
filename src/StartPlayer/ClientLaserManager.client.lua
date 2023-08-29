local player = game.Players.LocalPlayer
local LaserRenderer = require(script.Parent:WaitForChild("LaserRenderer"))

blasterEvents = game.ReplicatedStorage.BlasterEvents

function createPlayerLaser(playerWhoShot, toolHandle, endPosition)
	if playerWhoShot ~= player then 
		-- if not the current client who shot, create a laser and play the shooting sound 
		LaserRenderer.createLaser(toolHandle, endPosition)
	end
end

blasterEvents.LaserFired.OnClientEvent:Connect(createPlayerLaser)