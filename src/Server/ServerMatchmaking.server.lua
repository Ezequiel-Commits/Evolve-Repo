-- The serverside script for matchmaking in the main menu 
local memoryStore = game:GetService("MemoryStoreService")
local Queue = memoryStore:GetSortedMap("Queue")
local teleportService = game:GetService("TeleportService")
local dataStoreService = game:GetService("DataStoreService")
local dataStore = dataStoreService:GetDataStore("Tags")
local RoundModule = require(game.ReplicatedStorage.Shared:FindFirstChild("RoundModule"))
local maxPlayers = 1

local Maps = {
    Armory = 15030130019,
}

local ChosenMap = RoundModule.SelectMap(Maps)
print(ChosenMap)

local function addToQueue(player)
    Queue:SetAsync(player.UserId, player.UserId, 100)
end

local function removeFromQueue(player)
    Queue:RemoveAsync(player.UserId)
end

local cooldown = {}

local function EditQueue(player, QueueButtonText)
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

game.ReplicatedStorage.QueueEvent.OnServerEvent:Connect(function(player, QueueButtonText, TagName)
    -- save to a datastore
    local data = {}
    data.TagName = TagName
    local success, error = pcall(dataStore.SetAsync, dataStore, player.UserId, data)
end)

game.players.PlayerAdded:Connect(function(player)
    local data
	
	local success, errormsg = pcall(function() 
		data = dataStore:GetAsync(player.UserId)
        print(data)
	end)

    if data ~= nil then 
        local Tag = Instance.new("StringValue")
	    Tag.Name = data.TagName
	    Tag.Parent = player
    end
end)

-- Main matchmaking loop 
while task.wait(1) do
    local success, queuedPlayers = pcall(function()
        return Queue:GetRangeAsync(Enum.SortDirection.Descending, maxPlayers)
    end)
    if success then
        local amountQueued = 0
        for i, data in pairs(queuedPlayers) do
            amountQueued += 1
        end
        if amountQueued == maxPlayers then
            for i, data in pairs(queuedPlayers) do 
                local UserId = data.value
                local player = game.Players:GetPlayerByUserId(UserId)

                if player then 
                    local success, error = pcall(teleportService.TeleportAsync, teleportService, ChosenMap, {player})
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