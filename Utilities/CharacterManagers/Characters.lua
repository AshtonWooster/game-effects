--Ashton
--12.14.21--12.18.21
--Characters module

--Services--
local repStorage = game:GetService("ReplicatedStorage")

--Objects--
local eventsFolder = repStorage:WaitForChild("Events")
local selectChar = eventsFolder:WaitForChild("SelectChar")
local characterData = repStorage:WaitForChild("Chars"):GetChildren()
local characters = {}

--Variables--
local players = {}
local characterInfos = {}

--Set Up characterInfos--
for i = 1, #characterData do
	local data = require(characterData[i]:WaitForChild("Data"))
	characterInfos[data["id"]] = data
end

--Find Player--
local function findPlayer(player)
	for i = 1, #players do
		if players[i][1] == player then
			return i
		end
	end
	return 0
end

--Select Char--
function characters.SelectChar(player, num)
	local playerList = players[findPlayer(player)]
	playerList[2] = num
	selectChar:FireClient(player, num)
end 

--Unselect Char--
function characters.UnselectChar(player)
	local playerList = players[findPlayer(player)]
	playerList[2] = 0
	selectChar:FireClient(player,0)
end

--Get Char--
function characters.GetChar(player)
	return players[findPlayer(player)][2]
end

--Get Num Skills--
function characters.GetNumSkills(char)
	return #characterInfos[char]["skills"]
end

--Add/Remove on join/leave--
game.Players.PlayerAdded:Connect(function(player)
	local i = #players+1
	players[i] = {player, 0}
	player.CharacterAdded:Connect(function()
		wait(0.1)
		characters.SelectChar(player,players[i][2])
	end)
end)
game.Players.PlayerRemoving:Connect(function(player)
	local num = findPlayer(player)
	if num > 0 then
		table.remove(players,num)
	end
end)

return characters