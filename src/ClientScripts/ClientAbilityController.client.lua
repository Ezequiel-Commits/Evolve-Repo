---@diagnostic disable: trailing-space
local userInputService = game:GetService("UserInputService")
local DebounceModule = require(script.DebounceModule)
local AbilityRunning = false

-- tick values 
local TimeOfPreviousFire = 0
local TimeOfPreviousRock = 0
local TimeOfPreviousLeap = 0

local function FireAbility(AbilityName)
    
    assert(typeof(AbilityName) == "string", "Pass a string value")

    if AbilityName == "FireBreath" then
        
        local CastingTime = 7.5 -- is there a better way to implement this casting time? 
                                -- Could I pass it as a parameter? 
        local AbilityCooldown = 10 + CastingTime
        if DebounceModule.Debounce(TimeOfPreviousFire, AbilityCooldown) and DebounceModule.NoAbilityRunning(AbilityRunning) then
           
            -- if the conditions are fulfilled, cast the ability, start a cooldown,
            -- and make sure other abilities cannot be cast for "CastingTime" seconds
            AbilityRunning = not AbilityRunning
            TimeOfPreviousFire = tick()
            game.ReplicatedStorage.AbilityFolder.FireBreathFolder.FireBreath:FireServer()
            wait(CastingTime)
            AbilityRunning = not AbilityRunning

        end
    elseif AbilityName == "RockThrow" then
        
        local CastingTime = 2 
        local AbilityCooldown = 5 + CastingTime
        if DebounceModule.Debounce(TimeOfPreviousRock, AbilityCooldown) and DebounceModule.NoAbilityRunning(AbilityRunning) then
            
            AbilityRunning = not AbilityRunning
            TimeOfPreviousRock = tick()
            game.ReplicatedStorage.AbilityFolder.RockThrowFolder.RockThrow:FireServer()
            wait(CastingTime)
            AbilityRunning = not AbilityRunning

        end
    elseif AbilityName == "MonsterLeap" then
        
        local CastingTime = 2
        local AbilityCooldown = 5 + CastingTime
        if DebounceModule.Debounce(TimeOfPreviousLeap, AbilityCooldown) and DebounceModule.NoAbilityRunning(AbilityRunning) then
            
            AbilityRunning = not AbilityRunning
            TimeOfPreviousLeap = tick()
            game.ReplicatedStorage.AbilityFolder.LeapFolder.Leap:FireServer()
            wait(CastingTime)
            AbilityRunning = not AbilityRunning 

        end

    end
end

-- detect client input
userInputService.InputBegan:Connect(function(input,gpe)
	if input.KeyCode == Enum.KeyCode.Three then
		FireAbility("RockThrow")
    elseif input.KeyCode == Enum.KeyCode.Four then
        FireAbility("FireBreath")
    elseif input.KeyCode == Enum.KeyCode.Space then
        FireAbility("MonsterLeap")
	end
end)


