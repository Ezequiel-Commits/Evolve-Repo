local dataStoreService = game:GetService("DataStoreService")
local dataStore = dataStoreService:GetDataStore("Tags")

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
