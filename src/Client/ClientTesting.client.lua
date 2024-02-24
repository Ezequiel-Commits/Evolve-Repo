local userInputService = game:GetService("UserInputService")
local runService = game:GetService("RunService")
local player = game.Players.LocalPlayer
local mouse = player:GetMouse()
local item

--[[local function Raycast()
    local screenToWorldRay = workspace.CurrentCamera:ViewportPointToRay(mouse.X,mouse.Y)
    local directionVector = screenToWorldRay.Direction * 1000

    local raycastParams = RaycastParams.new()
    raycastParams.FilterType = Enum.RaycastFilterType.Exclude
    raycastParams.FilterDescendantsInstances = {player.Character, workspace["CanQuery test"]}

    local raycastResult = workspace:Raycast(screenToWorldRay.Origin, directionVector, raycastParams)
    if raycastResult and raycastResult.Instance then
        item = raycastResult.Instance
    end
    return raycastResult
end

local function OnLeftMouseButtonClick(Input, Processed)
    Raycast()
    if Input.UserInputType == Enum.UserInputType.MouseButton1 and not Processed then 
        if item:IsA("BasePart") then
            item.Color = Color3.new(1,0,0)
            print("Raycast instance:" .. item.Name)
        end
    end
end

-- runService.RenderStepped:Connect(Raycast)
userInputService.InputBegan:Connect(OnLeftMouseButtonClick)--]]