local replicatedStorage = game:GetService("ReplicatedStorage")
local grass = replicatedStorage:WaitForChild("Grass")
local desert = replicatedStorage:WaitForChild("Desert")
local water = replicatedStorage:WaitForChild("Water")
local forest = replicatedStorage:WaitForChild("Forest")
local oasis = replicatedStorage:WaitForChild("Oasis")

local function createBoard(boardSize,pos,seed)
	if not seed then
		seed = math.random(1,10000000)
	end
	for x=1,boardSize do
		local start,finish = nil,nil
		if x<math.ceil(boardSize/2) then
			start,finish = math.ceil(boardSize/2)-x+1,boardSize
		else
			start,finish = 1,boardSize-math.floor(x-boardSize/2)
		end
		for y=start,finish do
			local position = pos + Vector3.new((x+y/2)*grass.PrimaryPart.Size.X,1,y*grass.PrimaryPart.Size.Z*0.75) 
			local newTile
			local desertVal = ((math.noise(x/7,y/7,seed)+1)/2)*100
			local forestVal = ((math.noise(x/7,y/7,seed+1000)+1)/2)*100
			local waterVal = ((math.noise(x/6,y/6,seed+2000)+1)/2)*100
			if waterVal <38 then
				newTile = water:Clone()
				position = position - Vector3.new(0,0.5,0)
			elseif desertVal <20 then
				newTile = oasis:Clone()
			elseif desertVal <30 then
				newTile = desert:Clone()
			elseif forestVal >72 then
				newTile = forest:Clone()
			else
				newTile = grass:Clone()
			end
			newTile.Parent = workspace:WaitForChild("HexagonGrid")
			newTile:SetPrimaryPartCFrame(CFrame.new(position))
		end
	end
end

createBoard(15,Vector3.new(0,0,0))
