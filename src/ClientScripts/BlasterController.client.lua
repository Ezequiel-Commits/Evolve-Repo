local Blaster = script.Parent.Blaster
local blasterEvents = game.ReplicatedStorage.BlasterEvents
local Bullets = Blaster:WaitForChild("Bullets")

local player = game.Players.LocalPlayer
local character = player.Character
local laserRenderer = require(player.PlayerScripts.LaserRenderer)

local mouse = player:GetMouse()
maxMouseDistance = 1000
maxLaserDistance = 500

local debounce = false

local contextActionService = game:GetService("ContextActionService")
local ReloadAction = "reloadWeapon"

-- create a function to be binded to 
local function reload(character,animation)
	local humanoid = character:WaitForChild("Humanoid")
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

local animation = Blaster:WaitForChild("ReloadAnimation")
animation.AnimationId = "rbxassetid://14373884395"

-- use contextActionService instead of userInputService
local function onAction(actionName, inputState, inputObject)
	if actionName == ReloadAction and inputState == Enum.UserInputState.Begin then
		reload(character,animation)
		Blaster.TextureId = "rbxassetid://6593020923"
		wait(2)
		Blaster.TextureId = "rbxassetid://92628145"
	end
end

-- bind action
local function onEquipped()
	contextActionService:BindAction(ReloadAction, onAction, true, Enum.KeyCode.R)
	Blaster.Handle:FindFirstChild("Equipped"):Play()
end

-- unbind action
local function unEquipped()
	contextActionService:UnbindAction(ReloadAction)
end

Blaster.Equipped:Connect(onEquipped)
Blaster.Unequipped:Connect(unEquipped)


local function GetWorldMousePosition()
	-- the position of the mouse is a 2d point
	local screenToWorldRay = workspace.CurrentCamera:ViewportPointToRay(mouse.X, mouse.Y)
	local directionVector = screenToWorldRay.Direction * maxMouseDistance

	-- Raycast from the ray's origin towards its direction
	local raycastResult = workspace:Raycast(screenToWorldRay.Origin,directionVector)

	-- return the 3d point of intersection or calculate the position at the end of the ray.
	if raycastResult then  
		return raycastResult.Position
	else
		return screenToWorldRay.Origin + screenToWorldRay.Direction
	end
end


local function fireWeapon(plr)
	-- declare the 3d position of the mouse 
	local mouseLocation = GetWorldMousePosition()

	local targetLocation = (mouseLocation - Blaster.Handle.Position).Unit

	-- The direction to fire the weapon, multiplied by a maximum distance
	local directionVector = targetLocation * maxLaserDistance
	local weaponRaycastParams = RaycastParams.new()

	-- stop the player from shooting behind
	local headLookVector = game.Workspace[player.Name].Head.CFrame.LookVector
	local mouseLookVector = CFrame.new(game.Workspace[player.Name].Head.Position,mouseLocation).LookVector
	local difference = (headLookVector - mouseLookVector)
	print(difference.magnitude)
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
					-- If a humanoid is found, it's likely a player's character
					blasterEvents.DamageCharacter:FireServer(characterModel, hitPosition)
				end
			end

		else
			-- Calculate the end position 
			hitPosition = Blaster.Handle.Position + directionVector
		end

		-- create a laser on both the client and server side
		blasterEvents.LaserFired:FireServer(hitPosition)
		laserRenderer.createLaser(Blaster.Handle, hitPosition)
	end

end

Blaster.Activated:Connect(function() -- on activation
	if not debounce then
		debounce = true
		if Bullets.Value > 0 then
			print(Bullets.Value)
			fireWeapon()
			Bullets.Value = Bullets.Value - 1
		else
			print("Out of Bullets")
		end
		wait(.5)
		debounce = false
	end
end)

