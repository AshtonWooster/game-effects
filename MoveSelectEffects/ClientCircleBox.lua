local replicatedStorage = game:GetService("ReplicatedStorage")
local userInput = game:GetService("UserInputService")
local event = replicatedStorage:WaitForChild("Attack")
local miscFolder = replicatedStorage:WaitForChild("Misc")
local cylinderHit = miscFolder:WaitForChild("CylinderHit")
local player = game.Players.LocalPlayer
local cooldowns = {E=true}

userInput.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.Keyboard then
		local mouse = player:GetMouse()
		local character = player.Character or player.CharacterAdded:Wait()
		local torso = character:WaitForChild("Torso")
		if input.KeyCode == Enum.KeyCode.E and cooldowns["E"] then
			local hitBox = cylinderHit:Clone()
			hitBox.Size = Vector3.new(0.05,10,10)
			hitBox.Parent = workspace
			hitBox.Transparency = 0.7
			local position = mouse.Hit.p
			if (position-torso.Position).Magnitude > 50 then
				position = torso.Position + (position-torso.Position).Unit*50
			end
			local blacklist = {hitBox}
			local rayParams = RaycastParams.new()
			rayParams.FilterType = Enum.RaycastFilterType.Blacklist
			rayParams.FilterDescendantsInstances = blacklist
			local result = workspace:Raycast(position+Vector3.new(0,0.5,0),Vector3.new(0,-90,0),rayParams)
			if result then
				position = result.Position
			end
			hitBox.Position = position
			local mouseFunction
			mouseFunction = mouse.Move:Connect(function()
				local position = mouse.Hit.p
				if (position-torso.Position).Magnitude > 50 then
					position = torso.Position + (position-torso.Position).Unit*50
				end
				rayParams.FilterType = Enum.RaycastFilterType.Blacklist
				rayParams.FilterDescendantsInstances = blacklist
				local resultM = workspace:Raycast(position+Vector3.new(0,0.5,0),Vector3.new(0,-90,0),rayParams)
				if resultM then
					position = resultM.Position
				end
				hitBox.Position = position
			end)
			local stopFunction
			stopFunction = userInput.InputEnded:Connect(function(inputE)
				if inputE.UserInputType == Enum.UserInputType.Keyboard then
					if inputE.KeyCode == Enum.KeyCode.E then
						cooldowns["E"]=false
						mouseFunction:Disconnect()
						event:FireServer("E",hitBox.Position)
						hitBox:Destroy()
						stopFunction:Disconnect()
						wait(3)
						cooldowns["E"]=true
					end
				end
			end)
		end
	end
end)
