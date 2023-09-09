local uIP = game:GetService("UserInputService")
local replicatedStorage = game:GetService("ReplicatedStorage")
local attack = replicatedStorage:WaitForChild("Attack")
local player = game.Players.LocalPlayer

uIP.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		local mouse = player:GetMouse()
		if mouse.Target then
			attack:FireServer("Auto",mouse.Hit.p)
		end
	elseif input.UserInputType == Enum.UserInputType.Keyboard then
		if input.KeyCode == Enum.KeyCode.F then
			attack:FireServer("F")
		elseif input.KeyCode == Enum.KeyCode.Q then
			local mouse = player:GetMouse()
			if mouse.Target then
				attack:FireServer("Q",mouse.Hit.p)
			end
		end
	end
end)