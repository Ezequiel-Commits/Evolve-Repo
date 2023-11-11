local player = game.Players.LocalPlayer
local LaserRenderer = require(script.Parent:WaitForChild("LaserRenderer"))

blasterEvents = game.ReplicatedStorage.BlasterEvents

function createPlayerLaser(playerWhoShot, toolHandle, endPosition)
	-- display another player's laser
	if playerWhoShot ~= player then 
		LaserRenderer.createLaser(toolHandle, endPosition)
	end
end

blasterEvents.LaserFired.OnClientEvent:Connect(createPlayerLaser)