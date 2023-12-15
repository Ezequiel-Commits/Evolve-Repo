local players = game.Players
local ReadyPlayers = {}
local RoundModule = require(game.ReplicatedStorage.ModuleScripts:FindFirstChild("RoundModule"))

local function AddPlayerToTable(player)
    -- add all players in the lobby to a table
    table.insert(ReadyPlayers,player)

end

players.PlayerAdded:Connect(AddPlayerToTable)

wait(5)

-- Make this function concurrent
-- RoundModule.DisplayStatusText(10)

-- this isn't working every time 
local ChosenMonster = RoundModule.ChooseMonster(ReadyPlayers)

RoundModule.DressMonster(ChosenMonster)
