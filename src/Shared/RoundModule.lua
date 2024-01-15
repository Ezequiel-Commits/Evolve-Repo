-- A module containing the bulk of the code used in the GameLogic script
local module = {}

local status = game.ReplicatedStorage:WaitForChild("Status") -- A value to be displayed in the main gui

function module.intermission (length)
	for i = length,0,-1 do 
		status.Value = "Next round starts in "..i.." seconds" 
		wait(1)
	end
end

function module.SelectChapter()
	local rand = Random.new()
	local chapters = game.ReplicatedStorage.Chapters:GetChildren() -- Table of all map models
	local chosenChapter = chapters[rand:NextInteger(1,#chapters)] 
	
	return chosenChapter
end

function module.ChoosePiggy(players)
	
	local RandomObj = Random.new()
	chosenPiggy = players[RandomObj:NextInteger(1,#players)] 
	
	return chosenPiggy
end

function module.dressPiggy(Piggy) 
	
	local character 
	
	if Piggy.EquippedSkin.Value ~= "" then
		if game.ReplicatedStorage.Skins:FindFirstChild(Piggy.EquippedSkin.Value) then
			character = game.ReplicatedStorage.Skins[Piggy.EquippedSkin.Value]:Clone()
		end
	else
		character = game.ReplicatedStorage.Skins.Piggy:Clone()
	end
	
	character.Name = Piggy.Name 
	Piggy.Character = character 
	character.Parent = workspace 
end

function module.TeleportPiggy(player)  
	if player.Character then 
		
		player.Character.Humanoid.WalkSpeed = 14
		
		local bat = game.ServerStorage.Tools.PiggyBat:Clone()
		bat.Parent = player.Character
		
		if player.Character:FindFirstChild("HumanoidRootPart") then -- make sure the player doesn't get stuck in the ground
			player.Character.HumanoidRootPart.CFrame = game.Workspace.WaitingRoom.PiggyWaitingSpawn.CFrame + Vector3.new(0,5,0) 
		end
		
		local TrapCount = Instance.new("IntValue") -- create a new value 
		TrapCount.Name = "TrapCount"
		TrapCount.Value = 5
		TrapCount.Parent = player
		
		game.ReplicatedStorage.ToggleTrap:FireClient(player,true)
		
	end
end

function module.TeleportPlayers(players, mapSpawns) 
	-- 'players' should be a table containing all the players in the game
	-- eg. [game.players.AlvinBlox, game.players.EpicSwagKing123...]	
	for i, player in pairs(players) do
		if player.character then
			local character = player.Character
			
			if player.Character:FindFirstChild("HumanoidRootPart") then
				
				if not chosenPiggy then
					player.Character.Humanoid.WalkSpeed = 16 	
				end
				
				local rand = Random.new()
				player.Character.HumanoidRootPart.CFrame = mapSpawns[rand:NextInteger(1,#mapSpawns)].CFrame + Vector3.new(0,10,0) -- spawn them in the chosen map
				
				local hitboxClone = game.ServerStorage.Hitbox:Clone()
				hitboxClone.CFrame = character.HumanoidRootPart.CFrame
				
				local weld = Instance.new("Weld") -- weld the hitbox to the player's character
				weld.Part0 = character.HumanoidRootPart
				weld.Part1 = hitboxClone
				weld.Parent = character
				
				hitboxClone.Parent = player.Character
			end	
		end
	end
	
end

function module.InsertTag(contestants, tagName) 
	for i, player in pairs(contestants) do
		local Tag = Instance.new("StringValue")
		Tag.Name = tagName
		Tag.Parent = player
	end
end

local function toMS(s) 
	return ("%02i:%02i"):format(s/60%60, s%60) -- 600 --> 10:00
end

function module.StartRound(length,piggy,chapterMap) 
	
	local outcome
	
	game.ServerStorage.GameValues.GameInProgress.Value = true
	
	for i = length,0,-1 do -- for each second of the round, run the code below
		
		
		if i == (length-20) then 
			module.TeleportPlayers({piggy},chapterMap.PlayerSpawns:GetChildren()) -- What's the Piggy's Walkspeed?
			status.Value = "Piggy has woken up!"
			wait(2)
			
		end
		
		local contestants = {} -- create a table 
		
		local IsPiggyHere = false -- is the piggy still in the game? 
		
		local Escapees = 0
		
		for index, player in pairs(game.Players:GetPlayers()) do
			if player:FindFirstChild("Contestant") then 
				table.insert(contestants,player)
			elseif player:FindFirstChild("Piggy") then
				IsPiggyHere = true
			end
			if player:FindFirstChild("Escaped") then-- reference code from the DoorModule
				Escapees = Escapees + 1
			end
		end
		
		status.Value = toMS(i) 
		-- Once an end condition is achieved, break the for loop and end the game
		
		if Escapees > 0 then
			outcome = "Escaped"
			break
		end
		
		if IsPiggyHere == false then  
			outcome = "Piggy left"
			break			
		end
		
		if #contestants == 0 then
			outcome = "Contestants are dead"
			break
		end
		
		if i == 0 then
			outcome = "Time's up"
			break
		end
		
		
		wait(1) -- how long to wait to count down a second
	end 
	
	-- change the status to reflect the outcome -- 
	
	if outcome == "Piggy left" then
		status.Value = "The Piggy lost"
	elseif outcome == "Contestants are dead" then
		status.Value = "The Piggy Won"
	elseif outcome == "Time's up" then
		status.Value = "Time is up"
	elseif outcome == "Escaped" then
		status.Value = "The Contestants have escaped!"
	end
	
	wait(5)
	
end

-- clean up --

function module.RemoveTags() 
	
	game.ServerStorage.GameValues.GameInProgress.Value = false  
	
	game.ReplicatedStorage.ToggleCrouch:FireAllClients(false)
	game.ReplicatedStorage.ToggleTrap:FireAllClients(false)
	
	for i, v in pairs(game.Players:GetPlayers()) do
		if v:FindFirstChild("Piggy") then
			v.Piggy:Destroy()
			
			-- the piggy should only have one tool 
			if v.Backpack:FindFirstChild("PiggyBat") then v.Backpack.PiggyBat:destroy() end 
			if v.Character:FindFirstChild("PiggyBat") then v.Character.PiggyBat:destroy() end
			
			if v:FindFirstChild("TrapCount") then
				v.TrapCount:Destroy()
			end
			
			v:LoadCharacter() -- get rid of the piggy outfit 
			
		elseif v:FindFirstChild("Contestant") then
			v.Contestant:Destroy()
			
			for _, p in pairs(v.Backpack:GetChildren()) do 
				if p:IsA("Tool") then 
					p:destroy()
				end
			end
			
			for _, p in pairs(v.Character:GetChildren()) do
				if p:IsA("Tool") then 
					p:destroy()
				end
			end
		elseif v:FindFirstChild("Escpaed") then
			v.Escaped:Destroy()	
		end	
	end
end

return module

