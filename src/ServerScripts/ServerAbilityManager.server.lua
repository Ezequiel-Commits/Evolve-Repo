---@diagnostic disable: trailing-space
local replicatedStorage = game.ReplicatedStorage
Bezier = require(replicatedStorage.ReplicatedModules.BezierModule)
local Debris = game:GetService("Debris")

local function ChangePlayerMovement(player, speed, JumpPower)
	-- given a player, number, and boolean, restrict the player's movement
	
	assert(typeof(speed) == "number","Pass a number")
	assert(typeof(JumpPower) == "number", "Pass a number")

	local character = player.character or player.CharacterAdded:wait()
	local humanoid = character:FindFirstChild("Humanoid")

	humanoid.WalkSpeed = speed
	--[[humanoid.JumpPower = JumpPower
	humanoid.UseJumpPower = true]]

end

local function DamageFunc(Hitbox, damage)
	-- given a hitbox and dps, damage any other players who touch the ability
	
	-- the debounce for this function 
	wait(.5)

	local parts = Hitbox:GetTouchingParts()
	
	local humanoidsDamaged = {}
	
	for i, part in pairs(parts) do
		if part.Parent:FindFirstChild("Humanoid") and not humanoidsDamaged[part.Parent.Humanoid] then
			
			humanoidsDamaged[part.Parent.Humanoid] = true
			part.Parent.Humanoid:TakeDamage(damage)
		end
	end

end

local function CreateATween(P,I,G)

	-- if unachored the part could move wildly
	local PartToTween = P
	PartToTween.Anchored = true
	local TweenService = game:GetService("TweenService")

	local TweenInfo = I
	local TweenGoals = G
	local Tween = TweenService:Create(PartToTween, TweenInfo, TweenGoals)
	Tween:Play()

end

local function SpawnInAPoint(HumanoidRootPart, PointName, PointPosition)
	-- Spawn In a Point to be used for making a Bezier Curve

	assert(typeof(PointName) == "string", "Pass a String")
	assert(typeof(PointPosition) == "Vector3", "Pass a Vector3")

	local ServerStorage = game.ServerStorage
	local workspace = game.Workspace

	local Point = ServerStorage[PointName]:Clone()
	-- the CFrame of the player seems to lag behind a little bit 
	Point.CFrame = CFrame.new(HumanoidRootPart.CFrame * PointPosition)
	Point.Parent = workspace

	Debris:AddItem(Point, 2)

end

local function MakeBezierCurve(HumanoidRootPart, p0, p1, p2, p3)
	-- A function that'll make use of the Bezier Module to create a Bezier Curve

	local workspace = game.Workspace

	local p0pos = workspace[p0].Position
	local p1pos = workspace[p1].Position
	local p2pos = workspace[p2].Position
	local p3pos = workspace[p3].Position

	local markerTemplate = game.ServerStorage.marker

	local curve = Bezier.new(p0pos, p1pos, p2pos, p3pos)
	
	-- create a for loop with "t" to visualze the bezier curve and tween the player 
	for t = .05, 1, 0.1 do

		local marker = markerTemplate:Clone()
		
		marker.Position = curve:Calc(t)
		marker.Parent = workspace
		CreateATween(HumanoidRootPart, TweenInfo.new(.1, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, 0, false, 0), {Position = marker.Position})
		
		wait(0.1)
		
		Debris:AddItem(marker,1.5)

	end

	HumanoidRootPart.Anchored = false

end

local function RockThrowfunc(player)

	ChangePlayerMovement(player, 0, 0)

	-- Spawn in a rock 
	local character = player.character or player.CharacterAdded:wait()
	
    local rock = replicatedStorage.AbilityFolder.RockThrowFolder.Rock:Clone()
    rock.Parent = game.Workspace
    rock.Part.Anchored = true

    local offset = Vector3.new(2,2,-2)
    rock:PivotTo(character.Head.CFrame * CFrame.new(offset))
	
	rock.Part.Touched:Connect(function(otherPart)
		
		DamageFunc(rock.Part, 20)

		if not otherPart:IsDescendantOf(character) then
			rock:Destroy()
		end
	end)
	
	game.Debris:AddItem(rock, 4.5) 
	
	wait(1.5) 
	-- insert animation code here
	
	-- Throw the rock
	local rockPart = rock.Part
	local linearVelocity = Instance.new("LinearVelocity", rockPart)
    local attachment = Instance.new("Attachment", rockPart)
    
    linearVelocity.Name = "Throw"
    linearVelocity.Attachment0 = attachment
    linearVelocity.RelativeTo = Enum.ActuatorRelativeTo.Attachment0
    linearVelocity.MaxForce = 10000
    linearVelocity.VectorVelocity = Vector3.new(0,-5,-30)
	rockPart.Anchored = false

	ChangePlayerMovement(player, 16, 50)

end

local function FireBreathFunc(player)
	
	ChangePlayerMovement(player, 5, 0)

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
		DamageFunc(Hitbox, 5)
	end)
	
	game.Debris:AddItem(Model, 7.5)

	ChangePlayerMovement(player, 16, 50)
	
end

local function LeapFunc(player)
	
	local character = player.character or player.characterAdded:wait()
	local HumanoidRootPart = character:FindFirstChild("HumanoidRootPart")

	-- Spawn in the points for the Bezier Curve
	SpawnInAPoint(HumanoidRootPart, "p0", Vector3.new(0, 0, -2*2))
	SpawnInAPoint(HumanoidRootPart, "p1", Vector3.new(0, 8*2, -8.5*2))
	SpawnInAPoint(HumanoidRootPart, "p2", Vector3.new(0, 8*2, -16*2))
	SpawnInAPoint(HumanoidRootPart, "p3", Vector3.new(0, 0, -23.5*2))

	MakeBezierCurve(HumanoidRootPart, "p0", "p1", "p2", "p3")


end

replicatedStorage.AbilityFolder.RockThrowFolder.RockThrow.OnServerEvent:Connect(RockThrowfunc)
replicatedStorage.AbilityFolder.FireBreathFolder.FireBreath.OnServerEvent:Connect(FireBreathFunc)
replicatedStorage.AbilityFolder.LeapFolder.Leap.onServerEvent:Connect(LeapFunc)
