local function ETC()
	print("ETC:" .. "Is this easy to change?")
end

game:BindToClose(ETC)

local function fireBreath(player)
	local character = player.character
	local head = character.head
	local offset = Vector3.new(0, 0, -5)
	local location = head.cframe * cframe.new(offset)
-- get the player's head location
	local sphere = game.replicatedstorage:FindFirstChild("sphere"):Clone()
	sphere.parent = game.workspace
	sphere.cframe = location
-- create spheres off of that location
	local linearVelocity = Instance.new("LinearVelocity", sphere)
    local attachment = Instance.new("Attachment", sphere)
    
    linearVelocity.Name = "Throw"
    linearVelocity.Attachment0 = attachment
    linearVelocity.RelativeTo = Enum.ActuatorRelativeTo.Attachment0
    linearVelocity.MaxForce = 10000
    linearVelocity.VectorVelocity = Vector3.new(0, 0, -10)
	rockPart.Anchored = false
-- shoot those spheres outward
end