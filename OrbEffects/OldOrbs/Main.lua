local repStorage = game:GetService("ReplicatedStorage")
local attack = repStorage:WaitForChild("Attack")
local planet = repStorage:WaitForChild("Planet")
local planetGroups = {}

local NUMPLANETS = 8
local RADIUS     = 4
local DISTANCE   = 4
local MIN, MAX   = 0.5,3
local YOFFSET    = 2
local ZOFFSET    = 3
local DAMPENING  = 10
local POWER      = 100
local SPEED      = 1.5

local function findList(player)
	for i,list in pairs(planetGroups) do
		if list[1] == player then
			return list
		end
	end
	return nil
end

game.Players.PlayerAdded:Connect(function(player)
	local planets = {player,{},{},{}}
	table.insert(planetGroups,planets)
	player.CharacterAdded:Connect(function(character)
		local hRP = character:WaitForChild("HumanoidRootPart")
		local head = character:WaitForChild("Head")
		for i=1,NUMPLANETS do
			local angle = math.pi*2/NUMPLANETS*i
			local x,y = math.cos(angle)*RADIUS, math.sin(angle)*RADIUS + YOFFSET
			local newPlan = planet:Clone()
			local bodyPos = Instance.new("BodyPosition")
			bodyPos.Parent = newPlan
			bodyPos.P = POWER
			bodyPos.D = DAMPENING
			newPlan.Parent = workspace
			newPlan.Color = Color3.fromRGB(255,255,255)
			newPlan.Size = Vector3.new(1,1,1)
			bodyPos.Position = (head.CFrame*CFrame.new(x,y,ZOFFSET)).p
			table.insert(planets[2],newPlan)
			table.insert(planets[3],false)
			table.insert(planets[4],true)
		end
		local rotNum = 0
		while character:FindFirstChild("Humanoid") do
			for i,newPlan in pairs(planets[2]) do
				if not planets[3][i] then
					local angle = math.pi*(i/NUMPLANETS+rotNum/(100/SPEED))*2
					local x,y = math.cos(angle)*RADIUS, math.sin(angle)*RADIUS + YOFFSET
					newPlan.BodyPosition.Position = (head.CFrame*CFrame.new(x,y,ZOFFSET)).p
				end
			end
			rotNum = (rotNum+1)%(100/SPEED)
			wait()
		end
	end)
	player.CharacterRemoving:Connect(function()
		for i,toDestroy in pairs(planets[2]) do
			table.remove(planets[2],i)
			table.remove(planets[3],i)
			table.remove(planets[4],i)
			toDestroy:Destroy()
		end
	end)
end)

attack.OnServerEvent:Connect(function(player,pos)
	local plan = 0
	local planets = findList(player)
	if planets then
		for i,_ in pairs(planets[2]) do
			if planets[4][i] then
				plan = i
				break
			end
		end
	end
	if plan > 0 then
		planets[3][plan] = true
		planets[4][plan] = false
		local bodyPos = planets[2][plan].BodyPosition
		bodyPos.Position = pos
		local dmgEvent
		dmgEvent = planets[2][plan].Touched:Connect(function(hit)
			if hit.Parent:FindFirstChild("Humanoid") then
				if hit.Parent.Name ~= player.Name then
					hit.Parent.Humanoid:TakeDamage(10)
					dmgEvent:Disconnect()
				end
			end
		end)
		wait(0.7)
		planets[3][plan] = false
		wait(0.7)
		if dmgEvent then
			dmgEvent:Disconnect()
		end
		planets[4][plan] = true
	end
end)