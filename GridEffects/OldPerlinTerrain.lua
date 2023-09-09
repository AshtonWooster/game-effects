--6/10/2020

local replicatedStorage = game:GetService("ReplicatedStorage")
local event = replicatedStorage:WaitForChild("StartGame")
local createGUI = replicatedStorage:WaitForChild("CreateGUI")
local tilesToReplicate = replicatedStorage:WaitForChild("Tiles")
local grassTile = tilesToReplicate:WaitForChild("GrassTile")
local waterTile = tilesToReplicate:WaitForChild("WaterTile")
local sandTile = tilesToReplicate:WaitForChild("SandTile")
local forestTile = tilesToReplicate:WaitForChild("ForestTile")
local resetGUIConnection
local scale = workspace:WaitForChild("Scale")
local miscFolder = replicatedStorage:WaitForChild("Misc")
local beachEdgePart = miscFolder:WaitForChild("BeachPart")
local beachCornerPart = miscFolder:WaitForChild("CornerBeachPart")
local water = miscFolder:WaitForChild("BackgroundWater")
local loadEvent = replicatedStorage:WaitForChild("Load")
local clientLoaded
scale.Value = 8
event.Event:Connect(function(purpose,players,sizeOfGrid,position,mapType)
	if purpose then
		local changeLoaded = loadEvent.OnServerEvent:Connect(function(player)
			if player:WaitForChild("MatchTag").Value then
				player:WaitForChild("IsLoaded").Value = true
				local character = player.Character or player.CharacterAdded:Wait()
				local torso = character:WaitForChild("Torso")
				torso.Anchored=false
			end
		end)
		local rng = Random.new(game.Workspace.DistributedGameTime)
		local seed = (rng:NextInteger(1,100000)+rng:NextInteger(1,100000))/200000
		local tiles = {}
		local newTile
		local tileFolder = Instance.new("Folder",workspace)
		tileFolder.Name = ("TileFolder")
		local tilesInFolder = Instance.new("Folder",tileFolder)
		tilesInFolder.Name =("Tiles")
		local troopsInFolder = Instance.new("Folder",tileFolder)
		troopsInFolder.Name = ("Troops")
		local playersInFolder = Instance.new("Folder",tileFolder)
		playersInFolder.Name = "Players"
		for j=1,sizeOfGrid do
			tiles[j] = {}
			for i=1,sizeOfGrid do
				local tile
				local createBeachEdge = {}
				local createBeachCorner = {}
				if mapType == "Random" then
					tile = tilesToReplicate:GetChildren()[math.random(1,#tilesToReplicate:GetChildren())]
				elseif mapType == "Lake" then
					local max = 100
					local waterThreshold = 60
					local heightValue = math.floor(((math.noise(j/scale.Value,i/scale.Value,seed)+1)/2)*max)
					local waterValue = math.floor(((math.noise((j+100)/scale.Value,(i+100)/scale.Value,seed)+1)/2)*max)
					local forestValue = math.floor(((math.noise((j+200)/scale.Value,(i+200)/scale.Value,seed)+1)/2)*max)
					if waterValue >= waterThreshold then
						tile = waterTile
						local left,top,right,bottom = false,false,false,false
						if j ~= 1 and not (math.floor(((math.noise((j+99)/scale.Value,(i+100)/scale.Value,seed)+1)/2)*max) >= waterThreshold) then
							table.insert(createBeachEdge,270)
							left = true
						end
						if j ~= sizeOfGrid and not (math.floor(((math.noise((j+101)/scale.Value,(i+100)/scale.Value,seed)+1)/2)*max) >= waterThreshold) then
							table.insert(createBeachEdge,90)
							right = true
						end
						if i ~= sizeOfGrid and not (math.floor(((math.noise((j+100)/scale.Value,(i+101)/scale.Value,seed)+1)/2)*max) >= waterThreshold) then
							table.insert(createBeachEdge,0)
							bottom = true
						end
						if i ~= 1 and not (math.floor(((math.noise((j+100)/scale.Value,(i+99)/scale.Value,seed)+1)/2)*max) >= waterThreshold) then
							table.insert(createBeachEdge,180)
							top = true
						end
						if i ~= 1 and j ~= 1 and not (math.floor(((math.noise((j+99)/scale.Value,(i+99)/scale.Value,seed)+1)/2)*max) >= waterThreshold) and not top and not left then
							table.insert(createBeachCorner,90)
						end
						if i ~= sizeOfGrid and j ~= 1 and not (math.floor(((math.noise((j+99)/scale.Value,(i+101)/scale.Value,seed)+1)/2)*max) >= waterThreshold) and not left and not bottom then
							table.insert(createBeachCorner,180)
						end
						if i ~= sizeOfGrid and j ~= sizeOfGrid and not (math.floor(((math.noise((j+101)/scale.Value,(i+101)/scale.Value,seed)+1)/2)*max) >= waterThreshold) and not right and not bottom then
							table.insert(createBeachCorner,270)
						end
						if i ~= 1 and j ~= sizeOfGrid and not (math.floor(((math.noise((j+101)/scale.Value,(i+99)/scale.Value,seed)+1)/2)*max) >= waterThreshold) and not top and not right then
							table.insert(createBeachCorner,0)
						end
					elseif heightValue <= 80 and forestValue >= 51 then
						tile = forestTile
					else
						tile=grassTile
					end
				else
					tile = mapType
				end
				newTile = tile:Clone()
				newTile.Parent = tilesInFolder
				newTile:SetPrimaryPartCFrame(CFrame.new(Vector3.new(position.X + (j*8),position.Y,position.Z + (i*8))))
				for _,rotationOfBeach in pairs(createBeachEdge) do
					local rotationCharter = {Vector3.new(0,0.5,2),Vector3.new(2,0.5,0),Vector3.new(0,0.5,-2),Vector3.new(-2,0.5,0)}
					local newBeachEdge = beachEdgePart:Clone()
					newBeachEdge.Parent = newTile
					newTile:WaitForChild("TileType").Value = "Beach"
					newBeachEdge.Orientation = Vector3.new(0,rotationOfBeach,0)
					newBeachEdge.Position = newTile:WaitForChild("Sand").Position+rotationCharter[(rotationOfBeach/90)+1]
				end
				for _,rotationOfCorner in pairs(createBeachCorner) do
					local rotationCharter = {Vector3.new(2,0.5,-2),Vector3.new(-2,0.5,-2),Vector3.new(-2,0.5,2),Vector3.new(2,0.5,2)}
					local newBeachCorner = beachCornerPart:Clone()
					newBeachCorner.Parent = newTile
					newTile:WaitForChild("TileType").Value = "Beach"
					newBeachCorner.Orientation = Vector3.new(0,rotationOfCorner,0)
					newBeachCorner.Position = newTile:WaitForChild("Sand").Position+rotationCharter[(rotationOfCorner/90)+1]
				end
				tiles[j][i] = newTile
				if j >= 10 and i >= 10 then newTile.Name = (tostring(j)..":"..tostring(i))
				elseif j >=10 then newTile.Name = (tostring(j)..":0"..tostring(i))
				elseif i >= 10 then newTile.Name = ("0"..tostring(j)..":"..tostring(i))
				else newTile.Name = ("0"..tostring(j)..":0"..tostring(i))	
				end
			end
		end
		local newWater = water:Clone()
		newWater.Parent = tileFolder
		newWater.Size = Vector3.new(sizeOfGrid*8,0.75,sizeOfGrid*8)
		newWater.Position = (tiles[1][1].PrimaryPart.Position+tiles[sizeOfGrid][sizeOfGrid].PrimaryPart.Position)/2-(Vector3.new(0,0.5,0))
		for _,player in pairs(players) do
			local newTag = Instance.new("ObjectValue",playersInFolder)
			newTag.Name = player.Name
			newTag.Value = player.Character or player.CharacterAdded:Wait()
			player:WaitForChild("MatchTag").Value = tileFolder
			player:WaitForChild("IsLoaded").Value = false
			local character = player.Character or player.CharacterAdded:Wait()
			local torso = character:WaitForChild("Torso")
			torso.CFrame = CFrame.new(tiles[math.random(1,sizeOfGrid)][math.random(1,sizeOfGrid)].PrimaryPart.Position+Vector3.new(0,20,0))
			wait(1/30)
			torso.Anchored = true
			loadEvent:FireClient(player,tilesInFolder,true)
			createGUI:FireClient(player,tiles,"Add")
			resetGUIConnection = player.CharacterAdded:Connect(function(newCharacter)
				newTag.Value = player.Character or player.CharacterAdded:Wait()
				wait(2)
				character=newCharacter
				torso = character:WaitForChild("Torso")
				torso.CFrame = CFrame.new(tiles[math.random(1,sizeOfGrid)][math.random(1,sizeOfGrid)].PrimaryPart.Position+Vector3.new(0,20,0))
				wait(1/30)
				torso.Anchored=true
				loadEvent:FireClient(player,tilesInFolder,true)
				createGUI:FireClient(player,tiles,"Remove")
				createGUI:FireClient(player,tiles,"Add")
				createGUI:FireClient(player,nil,"FillSlots")
			end)
		end
	else
		resetGUIConnection:Disconnect()
	end
end)