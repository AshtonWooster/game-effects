local gameStatus = workspace:WaitForChild("GameStatus")
local timer = workspace:WaitForChild("Time")
local replicatedStorage = game:GetService("ReplicatedStorage")
local voteEvent = replicatedStorage:WaitForChild("Vote")
local votesFolder = replicatedStorage:WaitForChild("Votes")
local mapsFolder = replicatedStorage:WaitForChild("Maps")
local weaponsFolder = replicatedStorage:WaitForChild("Weapons")
local currentMap = workspace:WaitForChild("CurrentMap")
local currentMode = workspace:WaitForChild("CurrentMode")
local appearance = require(script.Parent:WaitForChild("Appearance"))
local chosens = {1,1,1}
local players = {}
local votes = {{0,0,0},{0,0,0,0},{0,0}}
local GAME_TIME = 60
local VOTE_TIME = 20

local function endGame()
	if #game.Players:GetPlayers()<2 then
		gameStatus.Value = 1
	else
		gameStatus.Value = 2
	end
	for _,player in pairs(game.Players:GetPlayers()) do
		local character = player.Character
		appearance.RemoveWeapon(character)
		player.IsIn.Value = false
	end
end

game.Players.PlayerAdded:Connect(function(player)
	votes[player]={0,0,0}
	local livesTag = Instance.new("IntValue")
	livesTag.Name = "Lives"
	livesTag.Parent = player
	livesTag.Value = 0
	local pointsTag = Instance.new("IntValue")
	pointsTag.Parent = player
	pointsTag.Name = "Points"
	pointsTag.Value = 0
	local inTag = Instance.new("BoolValue")
	inTag.Name = "IsIn"
	inTag.Value = false
	inTag.Parent = player
	player.CharacterAdded:Connect(function(character)
		if players[player] then
			workspace:WaitForChild(player.Name)
			appearance.LoadCharacter(character,player.Class.Value)
		end
		character:WaitForChild("Humanoid").Died:Connect(function()
			if chosens[3] == 1 then
				if players[player] and players[player] <= 1 and player.IsIn.Value then
					inTag.Value = false
					players[player] = nil
					player.Lives.Value = 0
					if #players <=1 and gameStatus.Value == 4 then
						endGame()
					end
				elseif players[player] and player.IsIn.Value then
					inTag.Value = false
					players[player] = players[player]-1
					player.Lives.Value = players[player]
				end
			else
				if players[player] then
					inTag.Value = false
					players[player] = players[player]+1
					player.Lives.Value = players[player]
				end
			end
			if players[player] and players[player]>=0 then
				if currentMap.Value then
					local c = player.CharacterAdded:Wait()
					local spawnLocations = {}
					for _,part in pairs(currentMap.Value:GetChildren()) do
						if part.Name == "Spawn" then
							table.insert(spawnLocations,part)
						end
					end
					workspace:WaitForChild(player.Name)
					c:SetPrimaryPartCFrame(CFrame.new(spawnLocations[math.random(1,#spawnLocations)].Position))
					inTag.Value = true
				end
			end
		end)
	end)
	if gameStatus.Value == 4 then
		local reAdd
		reAdd = player:WaitForChild("Class").Changed:Connect(function(value)
			if value>0 and gameStatus.Value == 4 then
				local c = player.Character or player.CharacterAdded:Wait()
				local spawnLocations = {}
				for _,part in pairs(currentMap.Value:GetChildren()) do
					if part.Name == "Spawn" then
						table.insert(spawnLocations,part)
					end
				end
				c:SetPrimaryPartCFrame(CFrame.new(spawnLocations[math.random(1,#spawnLocations)].Position))
				inTag.Value = true
				if chosens[3] == 1 then
					players[player]=3
					player.Lives.Value = players[player]
				else
					players[player]=0
					player.Lives.Value = players[player]
				end
			end
			reAdd:Disconnect()
		end)
		
	end
end)
game.Players.PlayerRemoving:Connect(function(player)
	votes[player]=nil
	if players[player] then
		players[player] = nil
		if #players <=1 and gameStatus.Value == 4 then
			endGame()
		elseif #game.Players:GetPlayers()<2 then
			gameStatus.Value = 1
		end
	end
end)

voteEvent.OnServerEvent:Connect(function(player,voteType,vote)
	if gameStatus.Value == 3  and voteType >= 1 and voteType <=3 and vote>=1 and vote<=#votes[voteType] then
		if votes[player][voteType]>0 then
			votes[voteType][votes[player][voteType]] = votes[voteType][votes[player][voteType]]-1
		end
		votes[voteType][vote] = votes[voteType][vote]+1
		votes[player][voteType]=vote
		if voteType == 1 then
			for i=1,3 do
				votesFolder:WaitForChild(i).Value = votes[1][i]
			end
		end
	end
end)

while true do
	if #game.Players:GetPlayers()>=2 then
		local maps = mapsFolder:GetChildren()
		for i=1,3 do
			local rChosen = math.random(1,#maps)
			votesFolder:WaitForChild("Map"..i).Value = maps[rChosen]
			table.remove(maps,rChosen)
		end
		gameStatus.Value = 3
		votes[1]={0,0,0}
		votes[2]={0,0,0,0}
		votes[3]={0,0}
		for i=1,3 do
			votesFolder:WaitForChild(i).Value = 0
		end
		voteEvent:FireAllClients(votes[1])
		for i,player in pairs(game.Players:GetPlayers()) do
			votes[player]={0,0,0}
		end
		for i=1,VOTE_TIME do
			wait(1)
			if gameStatus.Value == 1 then
				break
			end
		end
		gameStatus.Value = 4
		chosens = {1,1,1}
		for x,j in pairs(chosens) do
			for i,vote in pairs(votes[x]) do
				if vote>votes[x][j] then
					chosens[x] = i
				end				
			end
		end
		currentMode.Value = chosens[3]
		local map = votesFolder:WaitForChild("Map"..chosens[1]).Value:Clone()
		map.Parent = workspace
		map.Name = "Map"
		currentMap.Value = map
		local spawnLocations = {}
		for _,part in pairs(map:GetChildren()) do
			if part.Name == "Spawn" then
				table.insert(spawnLocations,part)
			end
		end
		for _,player in pairs(game.Players:GetPlayers()) do
			local character = player.Character or player.CharacterAdded:Wait()
			if player:WaitForChild("Class").Value>0 then
				local rSpawn = math.random(1,#spawnLocations)
				character:SetPrimaryPartCFrame(CFrame.new(spawnLocations[rSpawn].Position))
				appearance.LoadCharacter(character,player.Class.Value)
				table.remove(spawnLocations,rSpawn)
				player.IsIn.Value = true
			else
				local reAdd 
				reAdd = player.Class.Changed:Connect(function(value)
					local c = player.Character or player.CharacterAdded:Wait()
					local spawnLocations = {}
					for _,part in pairs(currentMap.Value:GetChildren()) do
						if part.Name == "Spawn" then
							table.insert(spawnLocations,part)
						end
					end
					workspace:WaitForChild(player.Name)
					appearance.LoadCharacter(character,player.Class.Value)
					c:SetPrimaryPartCFrame(CFrame.new(spawnLocations[math.random(1,#spawnLocations)].Position))
					player.IsIn.Value = true
				end)
			end
			if chosens[3] ==  1 then
				players[player] = 3
				player.Lives.Value = players[player]
			else
				players[player] = 0
				player.Lives.Value = players[player]
			end
		end
		for i=GAME_TIME,1,-1 do
			if gameStatus.Value == 4 then
				wait(1)
				timer.Value = i 
			else
				break
			end	
		end
		if gameStatus.Value == 4 then
			endGame()
		end		
		map:Destroy()
	else
		gameStatus.Value = 1
	end
	wait(9)
	gameStatus.Value = 0
	wait(1)
	players = {}
end
