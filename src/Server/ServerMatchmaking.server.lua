-- The serverside script for matchmaking in the main menu 
local memoryStore = game:GetService("MemoryStoreService")
local HQueue = memoryStore:GetSortedMap("HQueue")
local MQueue = memoryStore:GetSortedMap("MQueue")
local teleportService = game:GetService("TeleportService")
local dataStoreService = game:GetService("DataStoreService")
local dataStore = dataStoreService:GetDataStore("Tags")
local RoundModule = require(game.ReplicatedStorage.Shared:FindFirstChild("RoundModule"))
local Monster = 1
local Hunters = 4

local Maps = {
    Armory = 16150729763,
}

local ChosenMap = RoundModule.SelectMap(Maps)
print(ChosenMap)

local function addToQueue(player, Queue)
    print("Second event connected")
    Queue:SetAsync(player.UserId, player.UserId, 100)
end

local function removeFromQueue(player, Queue)
    Queue:RemoveAsync(player.UserId)
    print("Third event connected")
end

local cooldown = {}

local function EditQueue(player, QueueButtonText)
    if cooldown[player] then return end
	cooldown[player] = true
	if QueueButtonText == "IN QUEUE" then
        task.wait(2)
        print(player:GetChildren())
        if player:FindFirstChild("Monster") then
            pcall(addToQueue, player, MQueue)
        elseif player:FindFirstChild("Hunter") then
            pcall(addToQueue, player, HQueue)
        end
	elseif QueueButtonText == "QUEUE" then
        task.wait(2)
        print(player:GetChildren())
        if player:FindFirstChild("Monster") then
            pcall(removeFromQueue, player, MQueue)
            player:FindFirstChild("Monster"):Destroy()
        elseif player:FindFirstChild("Hunter") then
            pcall(removeFromQueue, player, MQueue)
            player:FindFirstChild("Hunter"):Destroy()
        end
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

local function HunterQueue()
    local success, queuedPlayers = pcall(function()
        return HQueue:GetRangeAsync(Enum.SortDirection.Descending, Hunters)
    end)
    if success then
        local HunterQ = 0
        for i, data in pairs(queuedPlayers) do
            HunterQ += 1
            print(HunterQ)
        end
    end
end

local function MonsterQueue()
    local success, queuedPlayers = pcall(function()
        return MQueue:GetRangeAsync(Enum.SortDirection.Descending, Monster)
    end)
    if success then
        local MonsterQ = 0
        for i, data in pairs(queuedPlayers) do
            MonsterQ += 1
            print(MonsterQ)
        end
    end
end

local function Teleporting(queue, maxPlayers, queuedPlayers)
    if queue == maxPlayers  then
        -- create a new combined table here
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

-- Main matchmaking loop 
while task.wait(1) do
    HunterQueue()
    MonsterQueue()
    --Teleporting()
end
