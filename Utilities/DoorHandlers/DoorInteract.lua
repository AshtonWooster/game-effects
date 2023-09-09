local tweenService = game:GetService("TweenService")
local replicatedStorage = game:GetService("ReplicatedStorage")
local interactEvent = replicatedStorage:WaitForChild("Interact")
local tI = TweenInfo.new(0.5,Enum.EasingStyle.Cubic,Enum.EasingDirection.Out)
local openID = "rbxassetid://2091298142"
local range = 25

local cooldowns = {}
local function findPlayer(player)
	for i,cooldown in pairs(cooldowns) do
		if cooldown[1] == player then
			return i
		end
	end
	return 0
end
local function findFromDoor(door)
	local toReturn = {}
	for _,list in pairs(cooldowns) do
		if list[3] == door then
			table.insert(toReturn,list)
		end
	end
	return toReturn
end
local function findPlayersAtDoor(door)
	local toReturn = {}
	for _,player in pairs(game.Players:GetPlayers()) do
		local character = player.Character or player.CharacterAdded:Wait()
		local hRP = character:WaitForChild("HumanoidRootPart")
		local dist = (door.Position - character.HumanoidRootPart.Position).Magnitude
		local maxDist = math.sqrt((range/2)^2*2)
		if findPlayer(player) == 0 and dist < maxDist then
			table.insert(toReturn,player)
		end
	end
	return toReturn
end

local players = game:GetService("Players")
players.PlayerAdded:Connect(function(player)
	player.CharacterAdded:Connect(function(character)
		character:WaitForChild("Humanoid").Died:Connect(function()
			local found = findPlayer(player)
			if found > 0 then
				interactEvent:FireClient(player,false)
				player.CharacterAdded:Wait()
				table.remove(cooldowns,found)
			end
		end)
	end)
end)

players.PlayerRemoving:Connect(function(player)
	local found = findPlayer(player)
	if found > 0 then
		table.remove(cooldowns,found)
	end
end)

local doorCooldowns = {}
for i,door in pairs(workspace:GetDescendants()) do
	if door.Name == "Door" and (door:IsA("UnionOperation") or door:IsA("Part")) and door:FindFirstChild("Hinge") then
		table.insert(doorCooldowns,{door,true})
		local doorNum = #doorCooldowns
		local prompter = Instance.new("Part")
		prompter.Transparency = 1
		prompter.Size = Vector3.new(range,range,range)
		prompter.Anchored = true
		prompter.CanCollide = false
		prompter.CFrame = door.CFrame
		prompter.Parent = door.Parent
		prompter.Name = "DoorPrompt"
		prompter.Touched:Connect(function(hit)
			if hit.Name == "HumanoidRootPart" then
				local player = players:GetPlayerFromCharacter(hit.Parent)
				local character = player.Character or player.CharacterAdded:Wait()
				if findPlayer(player) == 0 and doorCooldowns[doorNum][2] then
					interactEvent:FireClient(player,true,door)
					table.insert(cooldowns,{player,true,door})
					while findPlayer(player) > 0 do
						local dist = (prompter.Position - character.HumanoidRootPart.Position).Magnitude
						local maxDist = math.sqrt((range/2)^2*2)+2
						if dist > maxDist then
							table.remove(cooldowns,findPlayer(player))
							interactEvent:FireClient(player,false)
						end
						wait(0.5)
					end
				end
			end
		end)
	end
end

local function findDoor(door)
	for i,list in pairs(doorCooldowns) do
		if list[1] == door then
			return i
		end
	end
	return 0
end

interactEvent.OnServerEvent:Connect(function(player,action)
	local found = findPlayer(player)
	if action.Name == "Door" and found > 0 then
		local num = findDoor(cooldowns[found][3])
		local door = cooldowns[found][3]
	 	if num > 0 and cooldowns[found][2] and cooldowns[found][3] == action and doorCooldowns[num][2] then
			cooldowns[found][2] = false
			doorCooldowns[num][2] = false
			table.remove(cooldowns,found)
			local toCancel = findFromDoor(door)
			for _,list in pairs(toCancel) do
				table.remove(cooldowns,findPlayer(list[1]))
				interactEvent:FireClient(list[1],false)
			end
			local hinge = door.Hinge.Value
			tweenService:Create(door.Hinge.Value,tI,{CFrame = hinge.CFrame*CFrame.Angles(0,math.rad(90),0)}):Play()
			local newSound = Instance.new("Sound")
			newSound.SoundId = openID
			newSound.Parent = door
			newSound.TimePosition = 0.5
			newSound:Play()
			newSound.Volume = 2
			wait(3)
			tweenService:Create(door.Hinge.Value,tI,{CFrame = hinge.CFrame*CFrame.Angles(0,math.rad(-90),0)}):Play()
			wait(0.5)
			newSound:Destroy()
			local toGive = findPlayersAtDoor(door)
			for _,plr in pairs(toGive) do
				interactEvent:FireClient(plr,true,door)
				table.insert(cooldowns,{plr,true,door})
				local character = plr.Character or plr.CharacterAdded:Wait()
				local coro
				coro = coroutine.wrap(function()
					while findPlayer(plr) > 0 do
						local dist = (door.Position - character.HumanoidRootPart.Position).Magnitude
						local maxDist = math.sqrt((range/2)^2*2)+2
						if dist > maxDist then
							table.remove(cooldowns,findPlayer(plr))
							interactEvent:FireClient(plr,false)
						end
						wait(0.5)
					end
				end)
				coro()
			end
			doorCooldowns[num][2] = true
		end
	end
end)