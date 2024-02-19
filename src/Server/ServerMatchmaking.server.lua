-- The serverside script for matchmaking in the main menu 
local memoryStore = game:GetService("MemoryStoreService")
local Queue = memoryStore:GetSortedMap("Queue")
local teleportService = game:GetService("TeleportService")
local dataStoreService = game:GetService("DataStoreService")
local dataStore = dataStoreService:GetDataStore("Tags")
local RoundModule = require(game.ReplicatedStorage.Shared:FindFirstChild("RoundModule"))
local maxPlayers = 2

local Maps = {
    Armory = 16150729763,
}

local ChosenMap = RoundModule.SelectMap(Maps)

local function addToQueue(player)
    Queue:SetAsync(player.UserId, player.UserId, 100)
end

local function removeFromQueue(player)
    Queue:RemoveAsync(player.UserId)
    -- remove any tags the player has
    if player:FindFirstChild("Monster") then
        player:FindFirstChild("Monster"):Destroy()
    elseif player:FindFirstChild("Hunter") then
        player:FindFirstChild("Hunter"):Destroy()
    end
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

local function SetDataStore(player, QueueButtonText, TagName)
    -- is there a better place to put this block of code?
    if QueueButtonText == "IN QUEUE" then 
        local Tag = Instance.new("StringValue")
        Tag.Name = TagName
        Tag.Parent = player
    end
    -- add to tag name to a dataStore to access it in the map 
    local data = {}
    data.TagName = TagName
    local success, error = pcall(dataStore.SetAsync, dataStore, player.UserId, data)
end

game.Players.PlayerRemoving:Connect(removeFromQueue)
game.ReplicatedStorage.QueueEvent.OnServerEvent:Connect(SetDataStore)
game.ReplicatedStorage.QueueEvent.OnServerEvent:Connect(EditQueue)

while task.wait(1) do
    -- Main matchmaking loop; I should refactor soon 
    local success, queuedPlayers = pcall(function()
        -- The maxPlayers parameter could be tweaked 
        return Queue:GetRangeAsync(Enum.SortDirection.Descending, maxPlayers)
    end)
    if success then
        local MonsterQ = 0
        local HunterQ = 0
        -- sift through all the players currently in the queue
        for i, data in pairs(queuedPlayers) do
            local UserId = data.value
            local player = game.Players:GetPlayerByUserId(UserId)
            if player:FindFirstChild("Monster") then 
                MonsterQ += 1
                print(MonsterQ)
            elseif player:FindFirstChild("Hunter") then
                HunterQ += 1
                print(HunterQ)
            end
            if MonsterQ == 1 and HunterQ == 1 then 
                -- teleport each player in the queue if the conditions have been reached
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
                    -- remove them from the queue after they've left using a coroutine function
                    local wrappedFunction = coroutine.wrap(removeAfterLeaving)
                    wrappedFunction()
                end
            end
        end
    end
end