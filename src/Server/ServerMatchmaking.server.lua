-- The serverside script for matchmaking in the main menu
-- This doesn't have much to do with the game logic besides getting the player into the game. 
local memoryStore = game:GetService("MemoryStoreService")
local Queue = memoryStore:GetSortedMap("Queue")
local teleportService = game:GetService("TeleportService")

local RoundModule = require(game.ReplicatedStorage.Shared:FindFirstChild("RoundModule"))
local maxPlayers = 1

local Maps = {
    Armory = 15030130019
}

local ChosenMap = RoundModule.SelectChapter(Maps)
print(ChosenMap)

local function addToQueue(player)
    -- insert the UserIds of all people in queue to a table
    Queue:SetAsync(player.UserId, player.UserId, 100)
end

local function removeFromQueue(player)
    Queue:RemoveAsync(player.UserId)
end

local cooldown = {}

local function EditQueue(player, QueueButtonText)
    -- Add and remove players from queue when they press the Queue button
    if cooldown[player] then return end
	cooldown[player] = true
	if QueueButtonText == "IN QUEUE" then
		pcall(addToQueue, player)
	elseif QueueButtonText == "QUEUE" then
		pcall(removeFromQueue, player)
	end
	task.wait(1)
	cooldown[player] = false
end

game.Players.PlayerRemoving:Connect(removeFromQueue)
game.ReplicatedStorage.QueueEvent.OnServerEvent:Connect(EditQueue)

while task.wait(1) do
    print("Main loop connecting")
    local success, queuedPlayers = pcall(function()
        return Queue:GetRangeAsync(Enum.SortDirection.Descending, maxPlayers)
    end)
    if success then
        local amountQueued = 0
        for i, data in pairs(queuedPlayers) do
            amountQueued += 1
        end
        if amountQueued == maxPlayers then
            -- access a table to get the players
            for i, data in pairs(queuedPlayers) do 
                local UserId = data.value
                local player = game.Players:GetPlayerByUserId(UserId)

                if player then 
                    -- reserve a server so that the players are teleported to the same place 
                    local success, err = pcall(function()
                        print("Final teleportation check")
                        teleportService:TeleportAsync(ChosenMap, {player})
                        --local teleportOptions = Instance.new("TeleportOptions")
                        --teleportOptions.ShouldReserveServer = true
                        --local reservedServerCode = teleportService:ReserveServer(ChosenMap)
                        --teleportService:TeleportToPrivateServer(ChosenMap, reservedServerCode, {player})
                    end)
                   local function removeAfterLeaving()
                        if success then
                            task.wait(1)
                            pcall(function()
                                Queue:RemoveAsync(data.key)
                            end)
                        end
                    end
                    local wrappedFunction = coroutine.wrap(removeAfterLeaving)
                    wrappedFunction()
                end
            end
        end
    end
end