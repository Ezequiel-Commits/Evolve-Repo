local player = game.Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local laserRenderer = require(player.PlayerScripts:WaitForChild("LaserRenderer"))
local DebounceModule = require(game.ReplicatedStorage.ReplicatedModules.DebounceModule)
local lastIteration = 0

local Blaster = script.Parent
local Bullets = Blaster:WaitForChild("Bullets")

local mouse = player:GetMouse()
maxMouseDistance = 1000
maxLaserDistance = 500

local contextActionService = game:GetService("ContextActionService")
local ReloadAction = "reloadWeapon"

local reloadAnimation = Blaster:WaitForChild("ReloadAnimation")
reloadAnimation.AnimationId = "rbxassetid://14373884395"

local function reload(char, animation)
	-- create a function to be binded to 
	local humanoid = char:WaitForChild("Humanoid")
	if humanoid then 
		local animator = humanoid:FindFirstChildOfClass("Animator")
		if animator then
			-- Unique syntax to run the animation
			local animationTrack = animator:LoadAnimation(animation)
			animationTrack:Play()
			Bullets.Value = 6
			return animationTrack
		end
	end
end

local function onAction(actionName, inputState)
	
	-- call the reload function
	if actionName == ReloadAction and inputState == Enum.UserInputState.Begin then
		reload(character, reloadAnimation)
		Blaster.TextureId = "rbxassetid://6593020923"
		wait(2)
		Blaster.TextureId = "rbxassetid://92628145"
	end
end

local function onEquipped()
	contextActionService:BindAction(ReloadAction, onAction, true, Enum.KeyCode.R)
	Blaster.Handle:FindFirstChild("Equipped"):Play()
end

local function unEquipped()
	contextActionService:UnbindAction(ReloadAction)
end

local function GetWorldMousePosition()
	-- still a bit confusing
	local screenToWorldRay = workspace.CurrentCamera:ViewportPointToRay(mouse.X, mouse.Y)
	local directionVector = screenToWorldRay.Direction * maxMouseDistance
	print(screenToWorldRay)
	print(directionVector)

	local raycastResult = workspace:Raycast(screenToWorldRay.Origin, directionVector)

	if raycastResult then  
		return raycastResult.Position
	else
		return screenToWorldRay.Origin + screenToWorldRay.Direction
	end
end

local function fireWeapon()
	local mouseLocation = GetWorldMousePosition()

	-- confusing
	local targetLocation = (mouseLocation - Blaster.Handle.Position).Unit

	local directionVector = targetLocation * maxLaserDistance
	local weaponRaycastParams = RaycastParams.new()

	local headLookVector = game.Workspace[player.Name].Head.CFrame.LookVector
	local mouseLookVector = CFrame.new(game.Workspace[player.Name].Head.Position,mouseLocation).LookVector
	local difference = (headLookVector - mouseLookVector)
	--print(difference.magnitude)
	-- stop the player from shooting behind themselves
	if difference.magnitude < 1.33 then

		weaponRaycastParams.FilterDescendantsInstances = {player.Character}
		local weaponRaycastResult = workspace:Raycast(Blaster.Handle.Position,directionVector,weaponRaycastParams)

		local hitPosition
		if weaponRaycastResult then
			hitPosition = weaponRaycastResult.Position

			local characterModel = weaponRaycastResult.Instance:FindFirstAncestorOfClass("Model")
			if characterModel then
				local humanoid = characterModel:FindFirstChild("Humanoid")
				if humanoid then
					game.ReplicatedStorage.BlasterEvents.DamageCharacter:FireServer(characterModel, hitPosition)
				end
			end

		else
			hitPosition = Blaster.Handle.Position + directionVector
		end
		-- create a laser on the player's client, as well as on everyone else's client
		game.ReplicatedStorage.BlasterEvents.LaserFired:FireServer(hitPosition)
		laserRenderer.createLaser(Blaster.Handle, hitPosition)
	end

end

local function OnActivation()
	local cooldown = .5
	if DebounceModule.Debounce(lastIteration,cooldown) then
		if Bullets.Value > 0 then
			--print(Bullets.Value)
			fireWeapon()
			Bullets.Value = Bullets.Value - 1
		else
			print("Out of Bullets")
		end
	end
end

Blaster.Equipped:Connect(onEquipped)
Blaster.Unequipped:Connect(unEquipped)
Blaster.Activated:Connect(OnActivation)

