-- The main script for creating the round loop and running it continuously(I.E Game logic)
-- This should be in each map rather than in the main menu 
local Round = require(game.ReplicatedStorage.Shared.RoundModule)
local Status = game.ReplicatedStorage:WaitForChild("Status")

while true do
	
	-- in intermission for loading players in? 
	Round.intermission(5)

	local contestants = {} 

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
