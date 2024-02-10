-- The serverside script for matchmaking in the main menu 
local memoryStore = game:GetService("MemoryStoreService")
local HQueue = memoryStore:GetSortedMap("HQueue")
local MQueue = memoryStore:GetSortedMap("MQueue")
local teleportService = game:GetService("TeleportService")
local dataStoreService = game:GetService("DataStoreService")
local dataStore = dataStoreService:GetDataStore("Tags")
local RoundModule = require(game.ReplicatedStorage.Shared:FindFirstChild("RoundModule"))
local Monster = 1
local Hunters = 2

local Maps = {
    Armory = 16150729763,
}

local ChosenMap = RoundModule.SelectMap(Maps)

local function addToQueue(player, Q)
    print("addToQueue")
    Q:SetAsync(player.UserId, player.UserId, 100)
end

local function removeFromQueue(player, Q)
    print("removeFromQueue")
    Q:RemoveAsync(player.UserId)
end

local cooldown = {}

local function EditQueue(player, QueueButtonText)
    if cooldown[player] then return end
	cooldown[player] = true
    -- Extra code required to have two different queues
	if QueueButtonText == "IN QUEUE" then
        task.wait(2)
        if player:FindFirstChild("Monster") then
            pcall(addToQueue, player, MQueue)
        elseif player:FindFirstChild("Hunter") then
            pcall(addToQueue, player, HQueue)
        end
	elseif QueueButtonText == "QUEUE" then
        task.wait(2)
        if player:FindFirstChild("Monster") then
            pcall(removeFromQueue, player, MQueue)
            player:FindFirstChild("Monster"):Destroy()
        elseif player:FindFirstChild("Hunter") then
            pcall(removeFromQueue, player, HQueue)
            player:FindFirstChild("Hunter"):Destroy()
        end
	end
	task.wait(1)
	cooldown[player] = false
end

game.Players.PlayerRemoving:Connect(removeFromQueue)
game.ReplicatedStorage.QueueEvent.OnServerEvent:Connect(function(player, QueueButtonText, TagName)
    -- avoid duplicates
    if QueueButtonText == "IN QUEUE" then 
        local Tag = Instance.new("StringValue")
        Tag.Name = TagName
        Tag.Parent = player
    end
    
    -- add to tag name to a dataStore to access it in the map 
    local data = {}
    data.TagName = TagName
    local success, error = pcall(dataStore.SetAsync, dataStore, player.UserId, data)
end)
game.ReplicatedStorage.QueueEvent.OnServerEvent:Connect(EditQueue)

local function Teleporting(amountQueued, queue, maxPlayers, queuedPlayers)
    if amountQueued == maxPlayers  then
        for i, data in pairs(queuedPlayers) do 
            local UserId = data.value
            local player = game.Players:GetPlayerByUserId(UserId)

            if player then 
                local success, error = pcall(teleportService.TeleportAsync, teleportService, ChosenMap, {player})
               local function removeAfterLeaving()
                    if success then
                        task.wait(1)
                        pcall(function()
                            queue:RemoveAsync(data.key)
                        end)
                    end
                end
                local wrappedFunction = coroutine.wrap(removeAfterLeaving)
                wrappedFunction()
            end
        end
    end
end

local function addToHunterQueue()
    local success, queuedPlayers = pcall(function()
        return HQueue:GetRangeAsync(Enum.SortDirection.Descending, Hunters)
    end)
    if success then
        local amountQueued = 0
        for i, data in pairs(queuedPlayers) do
            amountQueued += 1
            print(amountQueued)
        end
        Teleporting(amountQueued, HQueue, Hunters, queuedPlayers)
    end
end

local function addToMonsterQueue()
    local success, queuedPlayers = pcall(function()
        return MQueue:GetRangeAsync(Enum.SortDirection.Descending, Monster)
    end)
    if success then
        local amountQueued = 0
        for i, data in pairs(queuedPlayers) do
            amountQueued += 1
            print(amountQueued)
        end
        Teleporting(amountQueued, MQueue, Monster, queuedPlayers)
    end
end

-- Main matchmaking loop 
while task.wait(1) do
    addToHunterQueue()
    addToMonsterQueue()
end
