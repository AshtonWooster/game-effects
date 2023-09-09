local tweenService = game:GetService("TweenService")
local repStorage = game:GetService("ReplicatedStorage")
local rotReg3 = require(script.Parent:WaitForChild("RotatedRegion3"))
local attack = repStorage:WaitForChild("Attack")
local planet = repStorage:WaitForChild("Planet")
local barrier = repStorage:WaitForChild("Barrier")
local laser = repStorage:WaitForChild("Beam")
local attackEffects = workspace:WaitForChild("AttackEffects")
local planetGroups = {}

local NUMPLANETS     = 10
local RADIUS         = 4
local DISTANCE       = 4
local MIN, MAX       = 0.5,3
local YOFFSET        = 2
local ZOFFSET        = 3

local DAMPENING      = 10
local POWER          = 100
local SPEED          = 2.5
local AUTORANGE      = 80
local AUTODAMAGE     = 10

local SHIELDWIDTH    = 25
local SHIELDHEIGHT   = 15
local SHIELDDURATION = 7

local BEAMLENGTH     = 150
local BEAMSCALE      = 0.4
local NUMROTATIONS   = 5
local DAMAGEPERORB   = 10

local function findList(player)
	for i,list in pairs(planetGroups) do
		if list[1] == player then
			return list
		end
	end
	return nil
end

local function findBarrier(player,bar)
	local list = findList(player)
	for i,blocker in pairs(list[5]) do
		if blocker == bar then
			return i
		end
	end
	return 0
end

local function fade(part,trans,duration)
	tweenService:Create(part,TweenInfo.new(duration,Enum.EasingStyle.Cubic,Enum.EasingDirection.Out),{Transparency = trans}):Play()
end
		
game.Players.PlayerAdded:Connect(function(player)
	local planets = {player,{},{},{},{}}
	local character
	table.insert(planetGroups,planets)
	player.CharacterAdded:Connect(function(char)
		local died = false
		character = char
		local hRP = character:WaitForChild("HumanoidRootPart")
		local head = character:WaitForChild("Head")
		local color = Color3.fromRGB(math.random(1,255),math.random(1,255),math.random(1,255))
		for i=1,NUMPLANETS do
			local angle = math.pi*2/NUMPLANETS*i
			local x,y = math.cos(angle)*RADIUS, math.sin(angle)*RADIUS + YOFFSET
			local newPlan = planet:Clone()
			local bodyPos = Instance.new("BodyPosition")
			bodyPos.Parent = newPlan
			bodyPos.P = POWER
			bodyPos.D = DAMPENING
			newPlan.Parent = attackEffects
			newPlan.Color = color
			newPlan.Size = Vector3.new(1,1,1)
			newPlan.Position = (head.CFrame*CFrame.new(x,y,ZOFFSET)).p
			planets[2][i] = newPlan
			planets[3][i] = true
			planets[4][i] = true
		end
		local dieReset
		dieReset = character:WaitForChild("Humanoid").Died:Connect(function()
			for i=1,NUMPLANETS do
				planets[2][i]:Destroy()
			end
			for i=1,#planets[5] do
				planets[5][i]:Destroy()
			end
			died = true
			dieReset:Disconnect()
		end)
		local rotNum = 0
		while not died and planets[2][1] do
			for i,newPlan in pairs(planets[2]) do
				if planets[3][i] and newPlan and newPlan:FindFirstChild("BodyPosition") then
					local angle = math.pi*(i/NUMPLANETS+rotNum/(100/SPEED))*2
					local x,y = math.cos(angle)*RADIUS, math.sin(angle)*RADIUS + YOFFSET
					newPlan.BodyPosition.Position = (head.CFrame*CFrame.new(x,y,ZOFFSET)).p
				end
			end
			rotNum = (rotNum+1)%(100/SPEED)
			wait(0.1)
		end
	end)
end)

game.Players.PlayerRemoving:Connect(function(player)
	for i,list in pairs(planetGroups) do
		if list[1] == player then
			for _,planet in pairs(list[2]) do
				planet:Destroy()
			end
			for i=1,#list[5] do
				list[5][i]:Destroy()
			end
			table.remove(planetGroups,i)
		end
	end
end)

attack.OnServerEvent:Connect(function(player,val,pos)
	if val == "Auto" then
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
		if plan > 0 and planets[2][plan]:FindFirstChild("BodyPosition") then
			local toThrow = planets[2][plan]
			local character = player.Character or player.CharacterAdded:Wait()
			local blacklist = {}
			for _,part in pairs(attackEffects:GetChildren()) do
				if part.Name ~= "Barrier" then
					table.insert(blacklist,part)
				end
			end
			for _,part in pairs(character:GetChildren()) do
				if part:IsA("Part") or part:IsA("MeshPart") and not part.Name == "Barrier" then
					table.insert(blacklist,part)
				end
			end
			local rayParams = RaycastParams.new()
			rayParams.FilterType = Enum.RaycastFilterType.Blacklist
			rayParams.FilterDescendantsInstances = blacklist
			local result = workspace:Raycast(toThrow.Position,(pos-toThrow.Position).Unit*500,rayParams)
			if result then
				planets[3][plan] = false
				planets[4][plan] = false
				local torso = character:WaitForChild("Torso")
				local position = result.Position
				if (position-torso.Position).Magnitude > AUTORANGE then
					position = torso.Position + (position-torso.Position).Unit*AUTORANGE
				end
				toThrow.BodyPosition.Position = position
				toThrow.ShotSound:Play()
				local hitted = false
				local dmgEvent
				dmgEvent = toThrow.Touched:Connect(function(hit)
					if hit.Parent:FindFirstChild("Humanoid") and not hitted then
						if hit.Parent.Name ~= player.Name then
							hit.Parent.Humanoid:TakeDamage(AUTODAMAGE)
							toThrow.HitSound:Play()
							dmgEvent:Disconnect()
							hit = true
						end
					elseif hit.Parent.Name ~= player.Name and hit.Parent.Name ~= "AttackEffects" or hit.Name == "Barrier" and not hitted then
						hit = true
						dmgEvent:Disconnect()
						planets[3][plan] = true
						wait(1)
						planets[4][plan] = true
					end
				end)
				wait(0.7)
				if not hitted then
					planets[3][plan] = true
					wait(0.7)
					if not hitted then
						if dmgEvent then
							dmgEvent:Disconnect()
						end
						planets[4][plan] = true
					end
				end
			end
		end
	elseif val == "F" then
		local blocking = {}
		local planets = findList(player)
		for i,plan in pairs(planets[2]) do
			if plan:FindFirstChild("BodyPosition") and planets[4][i] and #blocking<4 then
				table.insert(blocking,i)
			end
		end
		if #blocking == 4 then
			local toCheck = planets[2][blocking[1]]
			local character = player.Character or player.CharacterAdded:Wait()
			local torso = character:WaitForChild("Torso")
			for j,i in pairs(blocking) do
				planets[4][i] = false
				planets[3][i] = false
				local plan = planets[2][i]
				local yOff = (j%2)*SHIELDHEIGHT
				local xOff = SHIELDWIDTH/2
				if j<3 then
					xOff = -xOff
				end
				plan.BodyPosition.Position = (torso.CFrame*CFrame.new(xOff,yOff,-3)).p
			end
			local pos = (torso.CFrame*CFrame.new(0,SHIELDHEIGHT/2-2,-3)).p
			local lookVec = torso.Position
			wait(0.5)
			if toCheck then
				local newBar = barrier:Clone()
				newBar.Owner.Value = player.Name
				newBar.Color = toCheck.Color
				newBar.Size = Vector3.new(SHIELDWIDTH,SHIELDHEIGHT,1)
				newBar.Parent = attackEffects
				newBar.CFrame = CFrame.new(pos,Vector3.new(lookVec.X,lookVec.Y+SHIELDHEIGHT/2-2,lookVec.Z))
				table.insert(planets[5],newBar)
				fade(newBar,0.5,0.5)
				newBar.Ambience:Play()
				wait(SHIELDDURATION)
				if newBar then
					fade(newBar,1,0.5)
					wait(0.5)
					if newBar then
						table.remove(planets[5],findBarrier(player,newBar))
						newBar:Destroy()
						for _,num in pairs(blocking) do
							planets[3][num] = true
							planets[4][num] = true
						end
					end
				end
			end
		end
	elseif val == "Q" then
		local planets = findList(player)
		local toFire = {}
		for i,_ in pairs(planets[2]) do
			if planets[3][i] and planets[4][i] then
				table.insert(toFire,i)
			end
		end
		if #toFire > 0 then
			local rad = #toFire*BEAMSCALE
			local character = player.Character or player.CharacterAdded:Wait()
			local torso = character:WaitForChild("Torso")
			local pivot = CFrame.new((torso.CFrame*CFrame.new(0,0,-7)).p,pos)
			local toCheck = planets[2][toFire[1]]
			if toCheck.Parent then
				for i,plan in pairs(toFire) do
					planets[3][plan] = false
					planets[4][plan] = false
					local angle = math.pi*2/#toFire*i
					local x,y = math.cos(angle)*rad, math.sin(angle)*rad+YOFFSET
					local position = (pivot*CFrame.new(x,y,0)).p
					planets[2][plan].BodyPosition.Position = position
				end
			end
			local beam = laser:Clone()
			beam.Parent = attackEffects
			beam.CanCollide = false
			beam.Color = toCheck.Color
			beam.CFrame = CFrame.new(pivot.p-(pivot.p-pos).Unit*BEAMLENGTH/2,pivot.p)*CFrame.Angles(0,math.rad(90),0)
			beam.Size = Vector3.new(BEAMLENGTH,0.01,0.01)
			beam.Charge:Play()
			beam.Charge.Ended:Wait()
			beam.Beam:Play()
			fade(beam,0,0.1)
			tweenService:Create(beam,TweenInfo.new(0.1,Enum.EasingStyle.Cubic,Enum.EasingDirection.Out),{Size = Vector3.new(BEAMLENGTH,rad*2,rad*2)}):Play()
			if toCheck.Parent then
				for i,plan in pairs(toFire) do
					local angle = math.pi*2/#toFire*i
					local x,y = math.cos(angle)*rad*8, math.sin(angle)*rad*8+YOFFSET
					local position = (pivot*CFrame.new(x,y,rad*10)).p
					planets[2][plan].BodyPosition.Position = position
				end
			end
			wait(0.2)
			if toCheck then
				local r3 = rotReg3.FromPart(beam)
				local parts = r3:FindPartsInRegion3()
				local damaged = {player.Name}
				for _,part in pairs(parts) do
					if part.Parent:FindFirstChild("Humanoid") then
						local canDamage = true
						for _, name in pairs(damaged) do
							if part.Parent.Name == name then
								canDamage = false
							end
						end
						if canDamage then
							part.Parent.Humanoid:TakeDamage(#toFire*DAMAGEPERORB)
						end
					elseif part.Name == "Barrier" and part.Owner.Value ~= player.Name then
						beam.Break:Play()
						part:Destroy()
					end
				end
			end
			tweenService:Create(beam,TweenInfo.new(1,Enum.EasingStyle.Cubic,Enum.EasingDirection.Out),{Size = Vector3.new(BEAMLENGTH,0.01,0.01)}):Play()
			wait(0.3)
			fade(beam,1,0.7)
			wait(0.7)
			if toCheck.Parent then
				for i,plan in pairs(toFire) do
					planets[3][plan] = true
					planets[4][plan] = true
				end
			end
			beam:Destroy()
		end
	end
end)