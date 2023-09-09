--Server Admin Script
--Ashton
--9.18.22 -- 3.7.23

--Modules--
local adminList = require(script.Parent:WaitForChild("AdminList"))
local valueManip = require(script.Parent:WaitForChild("ValueManip"))
local effects = require(script.Parent:WaitForChild("Effects"))
local classesFolder = script.Parent:WaitForChild("Classes")
local classes = {}
for _, obj in pairs(classesFolder:GetChildren()) do
	classes[obj.Name] = require(obj)
end

--Objects--
local players = game:GetService("Players")
local repStorage = game:GetService("ReplicatedStorage")
local commandRanksFolder = repStorage:WaitForChild("CommandRanks")
local events = repStorage:WaitForChild("Events")
local adminEvent = events:WaitForChild("Admin")
local joinEvent = events:WaitForChild("Join")
local messageEvent = events:WaitForChild("Message")
local createdParts = workspace:WaitForChild("CreatedParts")
local createable = repStorage:WaitForChild("Createable")
local defaultPart = createable:WaitForChild("Part")
local effectsFolder = repStorage:WaitForChild("Effects")

--Required Ranks [ 0: Owner, 1: Admin, 2: Mod, 3: Perms ] --
local REQUIRED_RANKS = valueManip.MapChildrenValueToHash(commandRanksFolder)

--Send Message--
local function sendMessage(player, message)
	classes["TextPacket"].SendTo(player, message)
end

--Commands--
local COMMAND_LIST = {
	rank = function(player, props) -- [ Name, Rank ]
		local pRank = player.Rank.Value
		local tPlayer = players:FindFirstChild(props[1])
		local tRank = adminList.GetRank(tPlayer) or -1
		local toRank = math.floor(tonumber(props[2]))
		local isBounded = toRank >= -1 and toRank <= 3
		
		if not tPlayer or not toRank or not isBounded then return end
		local less0 = toRank < 0
		local pHigherTPlayer = less0 and pRank < tRank
		local playerHigher = toRank > pRank or pHigherTPlayer
		local isPromotion = tRank > toRank or tRank < 0
		local isPromotable = playerHigher and isPromotion
		local isRemoving = less0 and tRank > 0
		local isDemotion = isRemoving or toRank > tRank
		local isDemotable = pRank < tRank and isDemotion
		
		local canRank = isPromotable or isDemotable
		if player ~= tPlayer and canRank then
			print(player.Name.." has ranked "..props[1].." to "..props[2])
			sendMessage(player, "Successfully updated "..props[1].." to "..props[2])
			
			tPlayer:WaitForChild("Rank").Value = toRank
			adminList.UpdateAdmin(tPlayer, toRank)
			
			tPlayer:LoadCharacter()
			if toRank < 0 then
				adminEvent:FireClient(tPlayer, false)
			else
				adminEvent:FireClient(tPlayer, true)
			end
		end
	end,

	humanoidProp = function(player, props) -- [ Name, Speed, JumpPower, Health ]
		local pRank = player.Rank.Value
		
		local toPlayer = valueManip.VerifyString(props[1]) and props[1] or player.Name
		toPlayer = pRank < 3 and players:FindFirstChild(toPlayer) or player
		if toPlayer then
			local toSpeed = props[2] and tonumber(props[2])
			local toJump = props[3] and tonumber(props[3])
			local toHealth = props[4] and tonumber(props[4])
		
			print(player.Name.." has updated "..toPlayer.Name.."'s humanoid properties.")
			sendMessage(player, "Successfully updated "..toPlayer.Name.."'s humanoid properties.")
			local character = toPlayer.Character or toPlayer.CharacterAdded:Wait()
			local humanoid = character:WaitForChild("Humanoid")
			humanoid.WalkSpeed = toSpeed or humanoid.WalkSpeed
			humanoid.JumpHeight = toJump or humanoid.JumpHeight
			humanoid.Health = toHealth or humanoid.Health
		else
			sendMessage(player, "Invalid player of name "..props[1].." provided.")
		end
	end,

	create = function(player, props) -- [ Pos, Name, Num, Height ]
		local toCreate = props[2]
		if not toCreate or not valueManip.VerifyString(toCreate) then
			sendMessage(player, "Invalid instance name provided.")
		end
		toCreate = createable:FindFirstChild(toCreate) or effectsFolder:FindFirstChild(toCreate)
		if toCreate then
			local character = player.Character or player.CharacterAdded:Wait()
			
			local toHeight = props[4] and tonumber(props[4]) or 10
			toHeight = Vector3.new(0, toHeight, 0)
			local toNum = props[3] and tonumber(props[3]) or 1
			local toPos = valueManip.VerifyVector(props[1]) or character:WaitForChild("Torso").Position
		
			local num = toNum < math.pow(10, math.abs(3-player.Rank.Value))*5 and toNum or 1 -- Limit num parts can make by player rank
			
			print(player.Name.." has created "..tostring(num).." "..props[2])
			sendMessage(player, "Successfully created "..tostring(num).." "..props[2])
			for i = 1, num do
				local newPart = toCreate:Clone()
				newPart.Parent = createdParts
				if newPart:IsA("Model") then
					newPart.PrimaryPart = newPart.PrimaryPart or newPart:GetChildren()[1]
					newPart:SetPrimaryPartCFrame(CFrame.new(toPos + toHeight))
				else
					newPart.Position = toPos + toHeight
				end
				wait()
			end
		else
			sendMessage(player, "No instance of name "..props[2].." is creatable.")
		end
	end,

	destroy = function(player, props) -- [ Name ]
		if not props[1] or not valueManip.VerifyString(props[1]) then
			sendMessage(player, "No part name provided.")
			return 
		end
		if not workspace:FindFirstDescendant(props[1]) then
			sendMessage(player, "No part of name "..props[1].." exists.")
			return
		end
		
		local parts = {}
		for _, part in pairs(workspace:GetDescendants()) do
			if part.Name == props[1] then
				parts[#parts+1] = part
			end
		end
		
		print(player.Name.." has destroyed "..tostring(#parts).." instances of "..props[1])
		sendMessage(player, "Successfully destroyed "..tostring(#parts).." instances of "..props[1])
		for i = 1, #parts do
			parts[i]:Destroy()
		end
	end,

	clear = function(player, props) -- []
		local toDestroy = createdParts:GetChildren()
		print(player.Name.." has cleared "..tostring(#toDestroy).." created parts.")
		sendMessage(player, "Successfully cleared "..tostring(#toDestroy).." created parts.")
		for _, part in pairs(toDestroy) do
			part:Destroy()
		end
	end,
	
	tp = function(player, props) -- [ Pos, Name ]
		local toPos = valueManip.VerifyVector(props[1])
		local toPlayer = props[2] and players:FindFirstChild(props[2])
		local character = player.Character or player.CharacterAdded:Wait()
		
		if toPos then
			character:SetPrimaryPartCFrame(CFrame.new(toPos))
			
			print(player.Name.." has teleported to "..valueManip.VectorToString(toPos))
			sendMessage(player, "Successfully teleported to "..valueManip.VectorToString(toPos))
		elseif toPlayer then
			local toCharacter = toPlayer.Character or toPlayer.CharacterAdded:Wait()
			character:SetPrimaryPartCFrame(toCharacter:WaitForChild("Torso").CFrame)
			
			print(player.Name.." has teleported to "..toPlayer.Name)
			sendMessage(player, "Successfully teleported to "..toPlayer.Name)
		else
			sendMessage(player, "No valid location provided")
			return
		end
	end,
	
	fire = function(player, props) -- [ Colors, Bound, Rate, Duration ]
		--Verify Parameters
		local colors = valueManip.VerifyColor3Array(props[1])
		local bound = valueManip.VerifyPart(props[2])
		local rate = valueManip.VerifyNumber(props[3])
		local duration = valueManip.VerifyNumber(props[4])
		if not bound then return end
		
		--Set defaults
		colors = colors or {Color3.fromRGB(255,255,0), Color3.fromRGB(255, 127, 0), Color3.fromRGB(255, 0, 0)}
		local area = bound.Size.X*bound.Size.Y*bound.Size.Z
		rate = rate or area/2 + 5
		duration = duration or 10
		
		effects.Fire(colors, bound, rate, duration)
	end,
	
	message = function(player, props) -- [ text, client ] 
		--Verify Parameters
		local text = valueManip.VerifyString(props[1])
		local toPlayer = valueManip.VerifyString(props[2]) and players:FindFirstChild(props[2])
		local isValidText = valueManip.VerifyForTextPacket(text)
		
		if not valueManip.StringEmpty(props[2]) and not toPlayer then
			sendMessage(player, "Invalid player provided")
			return 
		end
		if not isValidText then 
			sendMessage(player, "Invalid formatting with message "..text)
			return 
		end
		
		local textPacket = classes["TextPacket"].new(text)
		local toMessage
		
		if toPlayer then
			messageEvent:FireClient(toPlayer, textPacket)
			toMessage = toPlayer.Name.."."
		else
			messageEvent:FireAllClients(textPacket)
			toMessage = " all clients."
		end
		
		sendMessage(player, "Sent message to "..toMessage)
	end,
	
	class = function(player, props) -- [ class, player ]
		local toPlayer = valueManip.VerifyString(props[2]) and players:FindFirstChild(props[2]) or player
		local classTag = toPlayer:WaitForChild("Class")
		
		if not valueManip.VerifyString(props[1]) then
			sendMessage(player, "Invalid class provided: "..props[1])
		elseif valueManip.StringEmpty(props[1]) then
			classTag.Value = ""
			sendMessage(player, "Removed class from: "..toPlayer.Name)
		else
			classTag.Value = props[1]
			sendMessage(player, "Switched "..toPlayer.Name.." to class: "..props[1])
		end
	end,
}

--Join Event--
joinEvent.OnServerEvent:Connect(function(player)
	local rank = player:WaitForChild("Rank").Value
	if rank > -1 then
		adminEvent:FireClient(player, true)
	end
end)

--Admin Event--
adminEvent.OnServerEvent:Connect(function(player, command, props)
	local rank = player:WaitForChild("Rank").Value
	if COMMAND_LIST[command] and rank <= REQUIRED_RANKS[command] then
		COMMAND_LIST[command](player, props)
	else
		print("nah he hackin: "..player.UserId)
	end
end)

--Player rank value--
players.PlayerAdded:Connect(function(player)
	local value = Instance.new("IntValue")
	value.Parent = player
	value.Name = "Rank"
	value.Value = adminList.GetRank(player) or -1
end)