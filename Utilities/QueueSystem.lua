--6/10/2020

local event = game:GetService("ReplicatedStorage"):WaitForChild("JoinQueue")
local startEvent = game:GetService("ReplicatedStorage"):WaitForChild("StartGame")
local players = {}
local playersInQueue = script:WaitForChild("PlayersInQueue")
local resetFunction
local startingGame = false
local canLeave = true
local queueBox = workspace:WaitForChild("QueueBox")

event.OnServerEvent:Connect(function(player,purpose)
	if playersInQueue.Value < 2 and purpose == "Join" and not startingGame and not player:WaitForChild("MatchTag").Value then
		local isPlayerIn = false
		for i,playerToCheck in pairs(players) do
			if playerToCheck.Name == player.Name then
				isPlayerIn = true
			end
		end
		if not isPlayerIn then
			playersInQueue.Value = playersInQueue.Value+1
			table.insert(players,player)
			local character = player.Character or player.CharacterAdded:Wait()
			local torso = character:WaitForChild("Torso")
			torso.CFrame = CFrame.new(Vector3.new(-5.56, 4.55, -34.29))
			resetFunction = player.CharacterAdded:Connect(function(newCharacter)
				character = newCharacter
				torso = character:WaitForChild("Torso")
				torso.CFrame = CFrame.new(Vector3.new(-5.56, 4.55, -34.29))
			end)
		end
	elseif purpose == "Leave" and canLeave then
		local isPlayerIn = 0
		for i,playerToCheck in pairs(players) do
			if playerToCheck.Name == player.Name then
				isPlayerIn = i
			end
		end
		if isPlayerIn > 0 then
			table.remove(players,isPlayerIn)
			local character = player.Character or player.CharacterAdded:Wait()
			local torso = character:WaitForChild("Torso")
			torso.CFrame = CFrame.new(Vector3.new(4.1, 3, 0.3))
			playersInQueue.Value = playersInQueue.Value -1
		end
	end
end)

playersInQueue.Changed:Connect(function(value)
	if value == 2 then
		startingGame = true
		for i=1,25 do
			if math.fmod(i,5) == 0 and playersInQueue.Value == 2 then
				for _,part in pairs(queueBox:GetChildren()) do
					if part.Name == "CanChange" then
						part.BrickColor = BrickColor.Red()
					elseif part.Name == "Part" then
						part:WaitForChild("PointLight").Brightness = 3
						part:WaitForChild("PointLight").Color = Color3.fromRGB(255,0,0)
					end
				end
			end
			wait(0.2)
			if math.fmod(i,5) == 0 then
				for _,part in pairs(queueBox:GetChildren()) do
					if part.Name == "CanChange" then
						part.BrickColor = BrickColor.Gray()
					elseif part.Name == "Part" then
						part:WaitForChild("PointLight").Brightness = 1
						part:WaitForChild("PointLight").Color = Color3.fromRGB(255,255,255)
					end
				end
			end
			if not players[1] or not players[2] then
				startingGame = false
				break
			elseif playersInQueue.Value ~= 2 then
				startingGame = false
				break
			end
		end
		if startingGame then
			canLeave = false
			playersInQueue.Value = 0
			local spawns = workspace:WaitForChild("MapSpawns"):GetChildren()
			local selectedSpawn
			for i,_ in pairs(spawns) do
				if selectedSpawn ~= nil and not selectedSpawn:WaitForChild("CanMatch").Value then
					selectedSpawn = nil
				end
				if selectedSpawn == nil then		
					selectedSpawn = spawns[i]
				end
			end
			selectedSpawn:WaitForChild("CanMatch").Value = false
			startEvent:Fire(true,players,20,selectedSpawn.Position,"Lake")
			wait(2)
			canLeave = true
			startingGame = false
		end
	end
end)