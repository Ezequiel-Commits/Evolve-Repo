task.wait(3)
local QueueButton = script.Parent.Parent:FindFirstChild("QueueButton", true)

QueueButton.MouseButton1Click:Connect(function()
    -- I don't really understand this change in text values 
    print("Queue function connecting")
    QueueButton.QueueText.Text = QueueButton.QueueText.Text == "QUEUE" and "IN QUEUE" or "QUEUE"
    game.ReplicatedStorage:WaitForChild("QueueEvent"):FireServer(QueueButton.QueueText.Text)

end)