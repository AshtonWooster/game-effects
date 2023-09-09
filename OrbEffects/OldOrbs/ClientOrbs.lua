local uIP = game:GetService("UserInputService")
local replicatedStorage = game:GetService("ReplicatedStorage")
local attack = replicatedStorage:WaitForChild("Attack")
local player = game.Players.LocalPlayer

uIP.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		local mouse = player:GetMouse()
		if mouse.Target then
			attack:FireServer(mouse.Hit.p)
		end
	end
end)