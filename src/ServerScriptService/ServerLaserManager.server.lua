blasterEvents = game.ReplicatedStorage.BlasterEvents
laserDamage = 20
maxHitProximity = 10

-- Find the handle of the tool the player is holding
function getPlayerToolHandle(player)
	local weapon = player.Character:FindFirstChildOfClass("Tool")
	if weapon then 
		return weapon:FindFirstChild("Handle")
	end
end

function isHitValid(playerFired, characterToDamage, hitPosition)
	-- Validate distance between the character hit and the hit position
	local characterHitProximity = (characterToDamage.HumanoidRootPart.Position - hitPosition).Magnitude
	if characterHitProximity > maxHitProximity then
		return false
	end
	
	-- check if shooting through walls
	local toolHandle = getPlayerToolHandle(playerFired)
	if toolHandle then
		local rayLength = (hitPosition - toolHandle.Position).Magnitude
		local rayDirection = (hitPosition - toolHandle.Position).Unit
		local raycastParams = RaycastParams.new()
		raycastParams.FilterDescendantsInstances = {playerFired.Character} -- filter out the player's character
		local rayResult = workspace:Raycast(toolHandle.Position,rayLength * rayDirection,raycastParams)
		
		-- If an instance was hit that was not the character then ignore the shot
		if rayResult and not rayResult.Instance:IsDescendantOf(characterToDamage) then
			return false
		end
	end
	
	return true
	
end

-- Notify all clients that a laser has been fired
function playerFiredLaser(playerFired, endPosition)
	local toolHandle = getPlayerToolHandle(playerFired) 
	if toolHandle then
		blasterEvents.LaserFired:FireAllClients(playerFired, toolHandle, endPosition)
	end
end

function damageCharacter(playerFired, characterToDamage, hitPosition)
	local validShot = isHitValid(playerFired, characterToDamage, hitPosition)
	local humanoid = characterToDamage:FindFirstChild("Humanoid")
	if humanoid and validShot then
		-- subtract laserDamage(20) health from character
		humanoid.Health -= laserDamage
	end
end


blasterEvents.LaserFired.OnServerEvent:Connect(playerFiredLaser)
blasterEvents.DamageCharacter.OnServerEvent:Connect(damageCharacter)

