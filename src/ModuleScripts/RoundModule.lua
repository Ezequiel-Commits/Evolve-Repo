---@diagnostic disable: trailing-space
local RoundModule = {}

function RoundModule.DisplayStatusText(time)

	local TopStatus = game.ReplicatedStorage.TimeStatus

	-- create a for loop that acts as a timer
	for i = time, 0, -1 do 

		TopStatus.Value = i
		wait(1)

	end

end

function RoundModule.SelectRandomMap(Maps)
	
	local MapTable = {}
	
	-- convert the given dictionary into a table 
	for i, MapId in pairs(Maps) do
		table.insert(MapTable, MapId)
	end

	-- return a random MapId using the new table 
	local RandomIndex = math.random(1, #MapTable)
	local RandomMapValue = MapTable[RandomIndex]

	return RandomMapValue

end

function RoundModule.ChooseMonster(ReadyPlayers)
	-- this should be eliminated once I implement server-based matchmaking

	-- choose a random player from the table of players to be the goliath
	local Rand = Random.new()
	local ChosenMonster = ReadyPlayers[Rand:NextInteger(1,#ReadyPlayers)]

	-- return a player
	return ChosenMonster

end

function RoundModule.DressMonster(ChosenMonster)

	local MonsterCharacter = game.ReplicatedStorage.Monsters:FindFirstChild("Goliath")

	MonsterCharacter.Name = ChosenMonster.Name
	ChosenMonster.Character = MonsterCharacter
	MonsterCharacter.Parent = workspace

	MonsterCharacter:PivotTo(CFrame.new(0,25,0))

end

function RoundModule.TeleportMonster()
	-- steps
	-- check for ChosenMonster
	-- teleport before players

end

function RoundModule.TeleportHunters()
	-- steps
	-- check for ChosenMonster
	-- teleport to spaceship 
	
end

function RoundModule.InsertTag()
	-- steps
	-- insert a tag(StringValue) into every player in the game
	-- hunter tags vs Monster tag
end

function RoundModule.StartRound()
	
	-- check end conditions 
	
end

return RoundModule
