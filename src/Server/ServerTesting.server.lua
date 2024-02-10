local Players = game:GetService("Players")

local function ETC()
	print("ETC:" .. "Is this easy to change?")
	print(Players.Dale_dave:GetChildren())
end

game:BindToClose(ETC)
