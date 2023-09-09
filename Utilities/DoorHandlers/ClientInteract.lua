local replicatedStorage = game:GetService("ReplicatedStorage")
local interactEvent = replicatedStorage:WaitForChild("Interact")
local interaction = replicatedStorage:WaitForChild("Interaction")
local uIS = game:GetService("UserInputService")
local tweenService = game:GetService("TweenService")
local clickInfo = TweenInfo.new(0.5,Enum.EasingStyle.Cubic,Enum.EasingDirection.Out)
local tI = TweenInfo.new(0.4,Enum.EasingStyle.Cubic,Enum.EasingDirection.In)
local prompt
local doorCooldown = true

interactEvent.OnClientEvent:Connect(function(value,action)
	if action and action.Name == "Door" then
		if value then
			prompt = interaction:Clone()
			prompt.Parent = action
			local interact
			interact = uIS.InputBegan:Connect(function(input)
				if input.UserInputType == Enum.UserInputType.Keyboard then
					if input.KeyCode == Enum.KeyCode.E and doorCooldown then
						doorCooldown = false
						local circle = prompt.Circle
						circle.Visible = true
						tweenService:Create(circle,clickInfo,{Size = UDim2.new(1,0,1,0)}):Play()
						tweenService:Create(circle,tI,{ImageTransparency = 1}):Play()
						local sound = Instance.new("Sound")
						sound.Parent = workspace
						sound.SoundId = "rbxassetid://421058925"
						sound:Play()
						interactEvent:FireServer(action)
						wait(0.5)
						doorCooldown = true
						sound:Destroy()
						prompt:Destroy()
						interact:Disconnect()
					end
				end
			end)
		else
			if prompt then
				prompt:Destroy()
			end
		end
	end
end)