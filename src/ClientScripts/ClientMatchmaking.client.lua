local QueueButton = script.Parent:WaitForChild("QueueButton")

QueueButton.MouseButton1Click:Connect(function()
    -- I don't really understand this change in text values 
    QueueButton.QueueText.Text = QueueButton.QueueText.Text == "QUEUE" and "IN QUEUE" or "QUEUE"
    game.ReplicatedStorage:WaitForChild("QueueEvent"):FireServer(QueueButton.QueueText.Text)

end)