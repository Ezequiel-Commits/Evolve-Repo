local player = game.Players.LocalPlayer
local userInputService = game:GetService("UserInputService")
local TimeOfPreviousAbility = 0
local fireRate = 1

-- create a debounce function to reduce code needed later; turn this into a module script later
local function debounce()
	local t = tick()
	if t - TimeOfPreviousAbility < fireRate then
		return false
	else 
		return true
	end
end

-- design by contract; Only fire the remote event if the cooldown is over
local function FireBreath()
	if debounce() == true then 
		game.ReplicatedStorage.FireBreathFolder.FireBreathEvent:FireServer()
		TimeOfPreviousAbility = tick()
	else
		print("Wait for cooldown")
	end
end

-- detect client input; if it's the number 4 then call another function
userInputService.InputBegan:Connect(function(input,gpe)
	if input.KeyCode == Enum.KeyCode.Four then
		FireBreath()
	end
end)


