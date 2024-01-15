-- The main script for creating the round loop and running it continuously(I.E Game logic)
local Round = require(script.RoundModule)
local Status = game.ReplicatedStorage:WaitForChild("Status")

while true do
	
	repeat -- wait to start the game until there are enough players 
		local availablePlayers = {}
		
		for i, plr in pairs(game.Players:GetPlayers()) do
			if not plr:FindFirstChild("InMenu") then
				table.insert(availablePlayers,plr)
			end
		end
		
		Status.Value = "2 'ready' players needed ("..#availablePlayers.."/2)"
		
		wait(2)
		
	until #availablePlayers >= 2 
	
	Round.intermission(5) 
	
	local chosenChapter = Round.SelectChapter() 

	local clonedChapter = chosenChapter:Clone() -- create a clone of the map
	clonedChapter.Name = "Map" 
	clonedChapter.Parent = game.Workspace
	
	wait(2)
	
	if clonedChapter:FindFirstChild("Doors") then 
		Door.ActivateDoors(clonedChapter.Doors) -- pass the folder containing the doors
	else
		warn("Fatal error: Doors folder required")
	end

	local contestants = {} -- Create a table 

	for i, v in pairs(game.Players:GetPlayers()) do -- add every active player into the table
		if not v:FindFirstChild("InMenu") then
			table.insert(contestants, v)
		end
	end

	local chosenPiggy = Round.ChoosePiggy(contestants) 

	for i, v in pairs(contestants) do 
		if v == chosenPiggy then
			table.remove(contestants,i) -- remove the chosen piggy 
		end
	end

	for i, v in pairs(contestants) do 
		if v ~= chosenPiggy then
			print("toggleCrouch fired for player: "..v.Name)
			game.ReplicatedStorage.ToggleCrouch:FireClient(v,true) -- enable the crouch button 
		end
	end

	Round.dressPiggy(chosenPiggy) 

	Round.TeleportPiggy(chosenPiggy) 

	if clonedChapter:FindFirstChild("PlayerSpawns") then
		Round.TeleportPlayers(contestants,clonedChapter.PlayerSpawns:GetChildren()) 
	else
		warn("Fatal error: Missing spawns")
	end
		
	Round.InsertTag(contestants,"Contestant")
	Round.InsertTag({chosenPiggy},"Piggy")

	Round.StartRound(600,chosenPiggy,clonedChapter)
	
	-- start cleaning up the round -- 
	
	contestants = {} 

	for i, v in pairs(game.Players:GetPlayers()) do 
		if not v:FindFirstChild("InMenu") then
			table.insert(contestants, v)
		end
	end
	
	-- teleport the players back to the lobby
	if game.Workspace.Lobby:FindFirstChild("Spawns") then 
		Round.TeleportPlayers(contestants,game.Workspace.Lobby.Spawns:GetChildren())
	else
		warn("Fatal error: Missing spawns")
	end
	
	
	clonedChapter:Destroy()

	Round.RemoveTags()
	
	wait(2)
end
