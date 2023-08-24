local replicatedStorage = game.ReplicatedStorage
local FireBreathEvents = replicatedStorage.FireBreathFolder
local TimeOfPreviousDamage = 0
local DamageRate = .5

-- create a debounce function to reduce code needed later
local function debounce()
	local t = tick()
	if t - TimeOfPreviousDamage < DamageRate then
		return false
	else 
		return true
	end
end

-- on the firing of this remote event(FireBreathEvent), spawn flames in front of the player
FireBreathEvents.FireBreathEvent.OnServerEvent:Connect(function(player)
	
	-- use the passed player to define some variables	
	local character = player.Character or player.CharacterAdded:wait()
	local humanoid = character:WaitForChild("Humanoid")
	
	local FireBreathModel = game.ReplicatedStorage.FireBreathFolder:FindFirstChild("FireBreathModel"):Clone()
	local hitbox = FireBreathModel.Hitbox
	FireBreathModel.Parent = game.Workspace

	-- constantly update the CFrame of the model to be in front of the player 
	--[[local offset = Vector3.new(0,2,-3) 
	FireBreathModel:PivotTo(player.Character.HumanoidRootPart.CFrame*CFrame.new(offset))]]
	
	local head = player.Character.Head

	local primarypart = FireBreathModel:WaitForChild("FireBreathPart")
	local weld = Instance.new("Weld", head) -- why add head here?
	primarypart.CFrame = head.CFrame

	weld.Part0 = head
	weld.Part1 = primarypart
	FireBreathModel.Parent = player.Character
	
	local function DamagePlayer(otherPart)	
		print("Hitbox Touched")
		local character = otherPart.Parent
		local humanoid = character:FindFirstChild("Humanoid")
		
		-- try not to damage the player that used the ability(upcoming change)
		if humanoid then
			if debounce() == true then
				print("Humanoid Found")
				humanoid:TakeDamage(5)
				TimeOfPreviousDamage = tick()	
			end
		end
	end

	hitbox.Touched:Connect(DamagePlayer)
	
end)
