local DebounceModule = {}

function DebounceModule.Debounce(TimeOfPreviousAbility, DebounceRate)
	-- a debounce function that makes use of the current time and a cooldown rate
	local t = tick()
	print(t, TimeOfPreviousAbility)
	if t - TimeOfPreviousAbility < DebounceRate then
		print("Wait for Ability Cooldown")
		return false
	else 
		return true
	end
end

function DebounceModule.NoAbilityRunning(AbilityRunning)
	-- a debounce function used to ensure that only one ability runs at a given time using a bool value.
	if AbilityRunning then
		print("Wait until the other ability has finished")
		return false
	else
		return true
	end
end

function DebounceModule.Leap(MonsterName)
	-- the "leap" function to be used by the monsters
	assert(typeof(MonsterName) == "string", "Pass a string")

end

return DebounceModule