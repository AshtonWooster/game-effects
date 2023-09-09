--An old script that didn't have a date, not sure when I last worked with this one

local rR3 = require(script.Parent:WaitForChild("RotatedRegion3"))
local repStorage = game:GetService("ReplicatedStorage")
local rEvent = repStorage:WaitForChild("REvent")
local attackFolder = workspace:WaitForChild("AttackEffects")
local tweenService = game:GetService("TweenService")
local chargeInfo = TweenInfo.new(0.375,Enum.EasingStyle.Cubic,Enum.EasingDirection.InOut)
local shotInfo = TweenInfo.new(0.5,Enum.EasingStyle.Cubic,Enum.EasingDirection.Out)
local shot2Info = TweenInfo.new(0.2,Enum.EasingStyle.Cubic,Enum.EasingDirection.Out)

local cooldowns = {}
game.Players.PlayerAdded:Connect(function(player)
	table.insert(cooldowns,{player,{true,true,true}})
end)

local function findCharge(player)
	for _,part in pairs(attackFolder:GetChildren()) do
		if part.Owner.Value == player.Name then
			return part
		end
	end
	return nil
end

local function findList(player)
	for i,list in pairs(cooldowns) do
		if list[1] == player then
			return i
		end
	end
	return 0
end

game.Players.PlayerRemoving:Connect(function(player)
	table.remove(cooldowns[findList(player)])
end)

rEvent.OnServerEvent:Connect(function(player,status,hit)
	local cooldown = cooldowns[findList(player)]
	local character = player.Character or player.CharacterAdded:Wait()
	local hRP = character:WaitForChild("HumanoidRootPart")
	local gun = character:WaitForChild("Gun")
	local gunAttach = gun:WaitForChild("GunAttach")
	if status == 1 and cooldown[2][3] then
		cooldown[2][3] = false
		gunAttach:WaitForChild("Charge"):Play()
		local newWeld = Instance.new("WeldConstraint")
		newWeld.Parent = gunAttach
		newWeld.Part0 = gunAttach
		newWeld.Name = "EffectWeld"
		local charge = repStorage:WaitForChild("GunCharge"):Clone()
		charge.Owner.Value = player.Name
		charge:WaitForChild("Outer").Color = gun.Tertiary.Color
		charge:WaitForChild("Inner").Color = gun.Glow.Color
		charge.Parent = attackFolder
		charge:SetPrimaryPartCFrame(gunAttach.CFrame*CFrame.new(0,-3.2,-0.6))
		newWeld.Part1 = charge.PrimaryPart
		tweenService:Create(charge.Inner,chargeInfo,{Size = charge.Inner.Size*70}):Play()
		tweenService:Create(charge.Outer,chargeInfo,{Size = charge.Outer.Size*70}):Play()
		wait(0.375)
		tweenService:Create(charge.Inner,chargeInfo,{Size = charge.Inner.Size/10}):Play()
		tweenService:Create(charge.Outer,chargeInfo,{Size = charge.Outer.Size/10}):Play()
		wait(0.375)
		charge.Inner.Anchored = true
		charge.Outer.Anchored = true
		if newWeld then
			newWeld:Destroy()
		end
	elseif status == 2 and not cooldown[2][3] then
		cooldown[2][3] = true
		local charge = findCharge(player)
		if gunAttach:WaitForChild("Charge").IsPlaying then
			gunAttach.Charge:Stop()
		end
		if gun:FindFirstChild("EffectWeld") then
			gun.EffectWeld:Destroy()
		end
		gunAttach:WaitForChild("Shot"):Play()
		charge:SetPrimaryPartCFrame(CFrame.new(charge.PrimaryPart.Position,hRP.Position))
		local fromPos = charge.PrimaryPart.Position
		local toPos = (charge.PrimaryPart.CFrame*CFrame.new(0,0,15)).p
		local tweenPos = CFrame.new(fromPos-(fromPos-Vector3.new(toPos.X,fromPos.Y,toPos.Z)).Unit*15,fromPos)
		tweenService:Create(charge.Inner,shot2Info,{Size = Vector3.new(3,3,30),CFrame = tweenPos}):Play()
		tweenService:Create(charge.Outer,shot2Info,{Size = Vector3.new(4,4,30),CFrame = tweenPos}):Play()
		wait(0.2)
		local r3 = rR3.FromPart(charge.Outer)
		local alreadyHit = {}
		for _,part in pairs(r3:FindPartsInRegion3()) do
			local hum = part.Parent:FindFirstChild("Humanoid") or part.Parent.Parent:FindFirstChild("Humanoid")
			if hum then
				local canHit = true
				for _,chr in pairs(alreadyHit) do
					if hum.Parent == chr then
						canHit = false
					end
				end
				if canHit and hum.Parent ~= character then
					table.insert(alreadyHit,hum.Parent)
					hum:TakeDamage(30)
				end
			end
		end
		tweenService:Create(charge.Inner,shotInfo,{Size = Vector3.new(0.024,0.024,30)}):Play()
		tweenService:Create(charge.Outer,shotInfo,{Size = Vector3.new(0.032,0.032,30)}):Play()
		wait(0.5)
		charge:Destroy()
	end
end)