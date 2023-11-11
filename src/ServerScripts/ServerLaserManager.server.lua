blasterEvents = game.ReplicatedStorage.BlasterEvents
laserDamage = 20
maxHitProximity = 10

function getPlayerToolHandle(player)
	local weapon = player.Character:FindFirstChildOfClass("Tool")
	if weapon then 
		return weapon:FindFirstChild("Handle")
	end
end

function isHitValid(playerFired, characterToDamage, hitPosition)
	-- Validate the shot fired
	local characterHitProximity = (characterToDamage.HumanoidRootPart.Position - hitPosition).Magnitude
	if characterHitProximity > maxHitProximity then
		return false
	end

	-- Check if shooting through walls
	local toolHandle = getPlayerToolHandle(playerFired)
	if toolHandle then
		local rayLength = (hitPosition - toolHandle.Position).Magnitude
		local rayDirection = (hitPosition - toolHandle.Position).Unit
		local raycastParams = RaycastParams.new()
		raycastParams.FilterDescendantsInstances = {playerFired.Character} 
		local rayResult = workspace:Raycast(toolHandle.Position, rayDirection * rayLength, raycastParams)
		
		if rayResult and not rayResult.Instance:IsDescendantOf(characterToDamage) then
			return false
		end
	end
	
	return true
	
end

function playerFiredLaser(playerFired, endPosition)
	-- fire an event to make the laser on all the clients' screen
	local toolHandle = getPlayerToolHandle(playerFired) 
	if toolHandle then
		blasterEvents.LaserFired:FireAllClients(playerFired, toolHandle, endPosition)
	end
end

function damageCharacter(playerFired, characterToDamage, hitPosition)
	-- damage the character shot
	local validShot = isHitValid(playerFired, characterToDamage, hitPosition)
	local humanoid = characterToDamage:FindFirstChild("Humanoid")
	if humanoid and validShot then
		humanoid.Health -= laserDamage
	end
end


blasterEvents.LaserFired.OnServerEvent:Connect(playerFiredLaser)
blasterEvents.DamageCharacter.OnServerEvent:Connect(damageCharacter)