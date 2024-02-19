task.wait(3)
local QueueButton = script.Parent.Parent:FindFirstChild("QueueButton", true)
local MultiplayerGui = script.Parent.Parent:FindFirstChild("SelectionGui", true)
print(MultiplayerGui)

QueueButton.MouseButton1Click:Connect(function()
    -- Open or close multiplayer view
    MultiplayerGui.Enabled = not MultiplayerGui.Enabled
end)

local function HunterSelected()
    QueueButton.QueueText.Text = QueueButton.QueueText.Text == "QUEUE" and "IN QUEUE" or "QUEUE"
    game.ReplicatedStorage:WaitForChild("QueueEvent"):FireServer(QueueButton.QueueText.Text, "Hunter")
end
local function MonsterSelected()
    QueueButton.QueueText.Text = QueueButton.QueueText.Text == "QUEUE" and "IN QUEUE" or "QUEUE"
    game.ReplicatedStorage:WaitForChild("QueueEvent"):FireServer(QueueButton.QueueText.Text, "Monster")
end    

MultiplayerGui.HunterButton.MouseButton1Down:Connect(HunterSelected)
MultiplayerGui.MonsterButton.MouseButton1Down:Connect(MonsterSelected)