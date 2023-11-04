local userInputService = game:GetService("UserInputService")

while true do 
    local mouse = userInputService:GetMouseLocation()
	local screenToWorldRay = workspace.CurrentCamera:ViewportPointToRay(mouse.x,mouse.y)
	print(screenToWorldRay)
	wait(2)
end
