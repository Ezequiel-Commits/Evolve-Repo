local userInputService = game:GetService("UserInputService")
local runService = game:GetService("RunService")
local mouse = game.Players.LocalPlayer:GetMouse()
local item

local function RenderSteppedRaycast()
    local screenToWorldRay = workspace.CurrentCamera:ViewportPointToRay(mouse.X,mouse.Y)
    --print(screenToWorldRay)
    local directionVector = screenToWorldRay.Direction * 1000
    local raycastResult = workspace:Raycast(screenToWorldRay.Origin, directionVector)
    if raycastResult then
        item = raycastResult.Instance
    end
    return raycastResult
end

local function OnLeftMouseButtonClick(Input, Processed)
    if Input.UserInputType == Enum.UserInputType.MouseButton1 and not Processed then 
        if item:IsA("BasePart") then
            item.Color = Color3.new(1,0,0)
            print(item)
        end
    end
end

runService.RenderStepped:Connect(RenderSteppedRaycast)
userInputService.InputBegan:Connect(OnLeftMouseButtonClick)