task.wait(3)
local QueueButton = script.Parent.Parent:FindFirstChild("QueueButton", true)
local SelectionGui = script.Parent.Parent:FindFirstChild("SelectionGui", true)
print(SelectionGui)

QueueButton.MouseButton1Click:Connect(function()
    SelectionGui.Enabled = not SelectionGui.Enabled
end)

local function Hunter()
    local Tag = Instance.new("StringValue")
	Tag.Name = "Hunter"
	Tag.Parent = script.Parent.Parent
    QueueButton.QueueText.Text = QueueButton.QueueText.Text == "QUEUE" and "IN QUEUE" or "QUEUE"
    game.ReplicatedStorage:WaitForChild("QueueEvent"):FireServer(QueueButton.QueueText.Text, Tag.Name)
end

local function Monster()
    local Tag = Instance.new("StringValue")
	Tag.Name = "Monster"
	Tag.Parent = script.Parent.Parent
    QueueButton.QueueText.Text = QueueButton.QueueText.Text == "QUEUE" and "IN QUEUE" or "QUEUE"
    game.ReplicatedStorage:WaitForChild("QueueEvent"):FireServer(QueueButton.QueueText.Text, Tag.Name)
end    

SelectionGui.HunterButton.MouseButton1Down:Connect(Hunter)
SelectionGui.MonsterButton.MouseButton1Down:Connect(Monster)