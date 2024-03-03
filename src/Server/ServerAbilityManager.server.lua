---@diagnostic disable: trailing-space
--[[local replicatedStorage = game.ReplicatedStorage
Bezier = require(replicatedStorage.Shared.BezierModule)
local Debris = game:GetService("Debris")

local function ChangePlayerMovement(player, speed)
	-- given a player, number, and boolean, restrict the player's movement
	
	assert(typeof(speed) == "number","Pass a number")

	local character = player.character or player.CharacterAdded:wait()
	local humanoid = character:FindFirstChild("Humanoid")

	humanoid.WalkSpeed = speed
	-- how can I stop players from jumping during an ability?

end

local function DamageFunc(player, Hitbox, damage)
	-- given a hitbox and dps, damage any other players who touch the ability

	-- the debounce for this function 
	wait(.5)

	local parts = Hitbox:GetTouchingParts()

	print(parts)

	local humanoidsDamaged = {}
	local objectsDamaged = {}

	print("DamageFunc has been called")

	for i, part in pairs(parts) do
		local destoryable = part.Parent:FindFirstChild("Destroyable")
		local health = part.Parent:FindFirstChild("Health")
		local destroyed = part.Parent:FindFirstChild("Destroyed")

		print(part)

		if part.Parent:FindFirstChild("Humanoid") and not humanoidsDamaged[part.Parent.Humanoid] then
			
			humanoidsDamaged[part.Parent.Humanoid] = true
			part.Parent.Humanoid:TakeDamage(damage)
			
		elseif destoryable and health and not destroyed and not objectsDamaged[part.Parent] and player then
			
			objectsDamaged[part.Parent] = true

			local evolved = nil

			warn("There is no evolved value, you need to create one. Put the path to the evolved object-value")

			if evolved then
				if evolved.Value >= 3 then
					if health.Value > 0 then
						health.Value -= damage

						print("Hit Object")
					end

					if health.Value < 0 and not destroyed  then
						local destroyed = Instance.new("BoolValue")
						destroyed.Name = "Destroyed"
						destroyed.Parent = part.Parent

						print("Destroyed Object")
					end
				end
			end
			
		end
	end

end

local function RockThrowfunc(player)

	ChangePlayerMovement(player, 0)

	local character = player.character or player.CharacterAdded:wait()
	
    local rock = replicatedStorage.AbilityFolder.RockThrowFolder.Rock:Clone()
    rock.Parent = game.Workspace
    rock.Part.Anchored = true

    local offset = Vector3.new(2,2,-2)
    rock:PivotTo(character.Head.CFrame * CFrame.new(offset))

	wait(1.5)
	-- insert the animation before the rock is thrown

	local rockPart = rock.Part
	local linearVelocity = Instance.new("LinearVelocity", rockPart)
    local attachment = Instance.new("Attachment", rockPart)
    
    linearVelocity.Name = "Throw"
    linearVelocity.Attachment0 = attachment
    linearVelocity.RelativeTo = Enum.ActuatorRelativeTo.Attachment0
    linearVelocity.MaxForce = 10000
    linearVelocity.VectorVelocity = Vector3.new(0,-5,-30)
	rockPart.Anchored = false

	rock.Part.Touched:Connect(function(otherPart)
		
		DamageFunc(player, rock.Part, 20)

		if not otherPart:IsDescendantOf(character) then
			rock:Destroy()
		end
	end)
	
	-- cleanup
	game.Debris:AddItem(rock, 4.5) 
	ChangePlayerMovement(player, 16)

end

local function FireBreathFunc(player)
	
	ChangePlayerMovement(player, 5)

	local character = player.Character or player.CharacterAdded:wait()
	local head = character.Head
	local Model = replicatedStorage.AbilityFolder.FireBreathFolder.Model:clone()
	local Part = Model.Part
	local Hitbox = Part.Hitbox
	Model.Parent = game.Workspace

	local offset = Vector3.new(0,0,-3)
	Model:PivotTo(head.CFrame * CFrame.new(offset))
	
	-- keep that part glued to the front of the player; massless == true
	local weldConstraint1 = Instance.new("WeldConstraint")
	
	weldConstraint1.Parent = head
	weldConstraint1.Part0 = head 
	weldConstraint1.Part1 = Part
	
	local weldConstraint2 = Instance.new("WeldConstraint")

	weldConstraint2.Parent = head
	weldConstraint2.Part0 = head 
	weldConstraint2.Part1 = Hitbox

	Hitbox.Touched:Connect(function(otherPart)
		DamageFunc(player, Hitbox, 5)
	end)
	
	-- cleanup 
	game.Debris:AddItem(Model, 7.5)
	ChangePlayerMovement(player, 16)
	
end

local function LeapFunc(player)

	local character = player.character or player.characterAdded:wait()
	local HumanoidRootPart = character:FindFirstChild("HumanoidRootPart")
	local workspace = game.Workspace

	local Point0 = Instance.new("Part")
	local Point1 = Instance.new("Part")
	local Point2 = Instance.new("Part")
	local Point3 = Instance.new("Part")

	Point0.Name = "p0"
	Point1.Name = "p1"
	Point2.Name = "p2"
	Point3.Name = "p3"

	Point0.Parent = workspace
	Point1.Parent = workspace
	Point2.Parent = workspace
	Point3.Parent = workspace

	Point0.Transparency = 1
	Point1.Transparency = 1
	Point2.Transparency = 1
	Point3.Transparency = 1

	local Point0Position  = Vector3.new(0,0, -2*2)
	local Point1Position  = Vector3.new(0,8*2, -8.5*2)
	local Point2Position  = Vector3.new(0,8*2, -16*2)
	local Point3Position  = Vector3.new(0,0, -23.5*2)

	-- the points lag begind the player a bit; how could I fix this?  

	Point0.CFrame = CFrame.new(HumanoidRootPart.CFrame * Point0Position)
	Point1.CFrame = CFrame.new(HumanoidRootPart.CFrame * Point1Position)
	Point2.CFrame = CFrame.new(HumanoidRootPart.CFrame * Point2Position)
	Point3.CFrame = CFrame.new(HumanoidRootPart.CFrame * Point3Position)

	Debris:AddItem(Point0, 2)
	Debris:AddItem(Point1, 2)
	Debris:AddItem(Point2, 2)
	Debris:AddItem(Point3, 2)

	-- create the bezier curve
	local p0pos = workspace.p0.Position
	local p1pos = workspace.p1.Position
	local p2pos = workspace.p2.Position
	local p3pos = workspace.p3.Position

	local markerTemplate = Instance.new("Part")
	markerTemplate.Parent = game.ServerStorage

	local curve = Bezier.newCurve(20, p0pos, p1pos, p2pos, p3pos)
	
	for t = 0, 1, 0.1 do
		-- create a for loop with "t" to visualze the bezier curve and tween the player 

		local marker = markerTemplate:Clone()
		
		marker.Position = curve:CalcT(t)
		marker.Parent = workspace
		marker.Transparency = 1

		-- create a tween that uses the bezier curve 
		local PartToTween = HumanoidRootPart
		PartToTween.Anchored = true
		local TweenService = game:GetService("TweenService")

		local TweenInfo = TweenInfo.new(.1, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, 0, false, 0)
		local TweenGoals = {Position = marker.Position}
		local Tween = TweenService:Create(PartToTween, TweenInfo, TweenGoals)
		Tween:Play()
		
		wait(0.1)
		
		Debris:AddItem(marker,1)

	end

	HumanoidRootPart.Anchored = false

end

replicatedStorage.AbilityFolder.RockThrowFolder.RockThrow.OnServerEvent:Connect(RockThrowfunc)
replicatedStorage.AbilityFolder.FireBreathFolder.FireBreath.OnServerEvent:Connect(FireBreathFunc)
replicatedStorage.AbilityFolder.LeapFolder.Leap.onServerEvent:Connect(LeapFunc)]]