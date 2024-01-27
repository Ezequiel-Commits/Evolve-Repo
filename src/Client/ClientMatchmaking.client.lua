task.wait(3)
local QueueButton = script.Parent.Parent:FindFirstChild("QueueButton", true)
local SelectionGui = script.Parent.Parent:FindFirstChild("SelectionGui", true)
print(SelectionGui)

QueueButton.MouseButton1Click:Connect(function()
    SelectionGui.Enabled = true
    local function Hunter()
        print("Hunter selected")
            QueueButton.QueueText.Text = QueueButton.QueueText.Text == "QUEUE" and "IN QUEUE" or "QUEUE"
            game.ReplicatedStorage:WaitForChild("QueueEvent"):FireServer(QueueButton.QueueText.Text)
    end
    local function Monster()
        print("Monster selected")
            QueueButton.QueueText.Text = QueueButton.QueueText.Text == "QUEUE" and "IN QUEUE" or "QUEUE"
            game.ReplicatedStorage:WaitForChild("QueueEvent"):FireServer(QueueButton.QueueText.Text)
    end    

    SelectionGui.HunterButton.MouseButton1Down:Connect(Hunter)
    SelectionGui.MonsterButton.MouseButton1Down:Connect(Monster)
end)