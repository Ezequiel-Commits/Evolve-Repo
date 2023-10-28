local memoryStore = game:GetService("MemoryStoreService")
local Queue = memoryStore:GetSortedMap("Queue")
local teleportService = game:GetService("TeleportService")

local RoundModule = require(game.ReplicatedStorage.ReplicatedModules:FindFirstChild("RoundModule"))
local maxPlayers = 2

local Maps = {
    Armory = 15030130019
}

local ChosenMap = RoundModule.SelectRandomMap(Maps)

local function addToQueue(player)

    --3. insert the UserIds of all people in queue to a table
    Queue:SetAsync(player.UserId, player.UserId, 100)

end

local function removeFromQueue(player)

    Queue:RemoveAsync(player.UserId)

end

local cooldown = {}

local function EditQueue(player, QueueButtonText)
    --Add and remove players from queue when they press the Queue button

    print(QueueButtonText)
    if cooldown[player] then return end
	cooldown[player] = true
	
    -- err in favor of the customer 
	if QueueButtonText == "IN QUEUE" then
		pcall(addToQueue, player)
	elseif QueueButtonText == "QUEUE" then
		pcall(removeFromQueue, player)
	end
	
	wait(1)
	cooldown[player] = false

end

game.Players.PlayerRemoving:Connect(removeFromQueue)

game.ReplicatedStorage.TeleportEvent.OnServerEvent:Connect(EditQueue)

while wait(1) do
    
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
                        teleportService:TeleportAsync(ChosenMap, {player})
                        --local teleportOptions = Instance.new("TeleportOptions")
                        --teleportOptions.ShouldReserveServer = true
                        --local reservedServerCode = teleportService:ReserveServer(ChosenMap)
                        --teleportService:TeleportToPrivateServer(ChosenMap, reservedServerCode, {player})
                    end)

                   local function removeAfterLeaving()
                    
                        if success then

                            wait(1)

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