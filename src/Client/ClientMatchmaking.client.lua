local QueueButton = script.Parent:WaitForChild("QueueButton")

QueueButton.MouseButton1Click:Connect(function()

    QueueButton.QueueText.Text = QueueButton.QueueText.Text == "QUEUE" and "IN QUEUE" or "QUEUE"

    game.ReplicatedStorage:WaitForChild("TeleportEvent"):FireServer(QueueButton.QueueText.Text)

end)