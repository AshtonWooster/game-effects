local replicatedStorage = game:GetService("ReplicatedStorage")
local attackFolder = replicatedStorage:WaitForChild("Attacks")
local effectsFolder = workspace:WaitForChild("AttackEffects")
local oneEvent = replicatedStorage:WaitForChild("OneEvent")
local twoEvent = replicatedStorage:WaitForChild("TwoEvent")
local threeEvent = replicatedStorage:WaitForChild("ThreeEvent")
local fourEvent = replicatedStorage:WaitForChild("FourEvent")
local changeClass = replicatedStorage:WaitForChild("ChangeClass")
local cubeHitbox = attackFolder:WaitForChild("CubeHitbox")
local hitboxes = require(script.Parent:WaitForChild("Hitbox"))
local stun = require(script.Parent:WaitForChild("Stun"))
local damage = require(script.Parent:WaitForChild("Damage"))
local effects = require(script.Parent:WaitForChild("Effects"))
local tweenService = game:GetService("TweenService")

local classes = {
	{Name="Lancer"},
}

local cooldowns = {}
game.Players.PlayerAdded:Connect(function(player)
	cooldowns[player] = {One=true,Two=true,Three=true,Four=true}
	local classTag = Instance.new("IntValue")
	classTag.Parent = player
	classTag.Name = "Class"
	classTag.Value = 0
	local canAttack = Instance.new("BoolValue")
	canAttack.Parent = player
	canAttack.Name = "CanAttack"
	canAttack.Value = true
end)
game.Players.PlayerRemoving:Connect(function(player)
	cooldowns[player] = nil
end)

oneEvent.OnServerEvent:Connect(function(player)
	if cooldowns[player]["One"] and player.IsIn.Value and player.CanAttack.Value and not player.Stunned.Value then
		cooldowns[player]["One"] = false
		player.CanAttack.Value = false
		local character = player.Character or player.CharacterAdded:Wait()
		local humanoidRootPart = character:WaitForChild("HumanoidRootPart")
		if player.Class.Value == 1 then
			wait(0.4)
			local stabSound = Instance.new("Sound")
			stabSound.Parent = humanoidRootPart
			stabSound.SoundId = "rbxassetid://4958430453"
			stabSound.Volume = 0.3
			stabSound:Play()
			local hitbox = cubeHitbox:Clone()
			hitbox.Parent = effectsFolder
			hitbox.Size = Vector3.new(5,5,7)
			hitbox.CFrame = humanoidRootPart.CFrame*CFrame.new(0,0,-2)
			local characters = hitboxes.GetCharactersInPart(hitbox,player)
			hitbox:Destroy()
			local hitSound = Instance.new("Sound")
			if #characters>0 then
				hitSound.SoundId = "rbxassetid://566593606"
				hitSound.Parent = humanoidRootPart
				hitSound.TimePosition = 0.1
				hitSound:Play()
			end
			for _,c in pairs(characters) do
				if game.Players:GetPlayerFromCharacter(c):WaitForChild("IsIn").Value then
					stun.Stun(c,5)
					damage.Damage(game.Players:GetPlayerFromCharacter(c),1,1)
				end
			end
			player.CanAttack.Value = true
			wait(0.6)
			stabSound:Destroy()
			hitSound:Destroy()
		end
		cooldowns[player]["One"] = true
	end
end)

twoEvent.OnServerEvent:Connect(function(player)
	if cooldowns[player]["Two"] and player.IsIn.Value and player.CanAttack.Value and not player.Stunned.Value then
		cooldowns[player]["Two"] = false
		player.CanAttack.Value = false
		local character = player.Character or player.CharacterAdded:Wait()
		local humanoidRootPart = character:WaitForChild("HumanoidRootPart")
		if player.Class.Value == 1 then
			effects.Fade(character:WaitForChild("1"),1,0.2)
			for i=1,40 do
				local newSpear = attackFolder:WaitForChild("LightSpear"):Clone()
				newSpear.Parent = effectsFolder
				newSpear.Transparency = 1
				newSpear.CFrame = humanoidRootPart.CFrame*CFrame.new(math.random(-25,25)*0.1,math.random(-20,22)*0.1,-1)*CFrame.Angles(math.rad(90),math.rad(math.random(-90,90)),math.rad(180))
				effects.Fade(newSpear,0,0.1)
				tweenService:Create(newSpear,TweenInfo.new(0.3,Enum.EasingStyle.Cubic,Enum.EasingDirection.Out),{CFrame = newSpear.CFrame*CFrame.new(0,6,0)}):Play()
				local newBox = cubeHitbox:Clone()
				newBox.Parent = effectsFolder
				newBox.CFrame = humanoidRootPart.CFrame*CFrame.new(0,0,-5)
				newBox.Size = Vector3.new(5,5,9)
				local characters = hitboxes.GetCharactersInPart(newBox,character)
				local hitSound = Instance.new("Sound")
				if #characters>0 then
					hitSound.SoundId = "rbxassetid://566593606"
					hitSound.Parent = humanoidRootPart
					hitSound.TimePosition = 0.1
					hitSound:Play()
				end
				for _,c in pairs(characters) do
					if game.Players:GetPlayerFromCharacter(c):WaitForChild("IsIn").Value then
						stun.Stun(c,0.12)
						damage.Damage(c,1,2)
					end
				end
				local fader = coroutine.wrap(function()
					wait(0.5)
					effects.Fade(newSpear,1,0.1)
					hitSound:Destroy()
					wait(0.1)
					newSpear:Destroy()
				end)
				fader()
				wait(0.1)
				newBox:Destroy()
			end
			effects.Fade(character:WaitForChild("1"),0,0.2)
			player.CanAttack.Value = true
			wait(1)
		end
		cooldowns[player]["Two"] = true
	end
end)

threeEvent.OnServerEvent:Connect(function(player)
	if cooldowns[player]["Three"] and player.IsIn.Value then	
		print(player.Name.." has pressed 3")
	end
end)

fourEvent.OnServerEvent:Connect(function(player)
	if cooldowns[player]["Four"] and player.IsIn.Value then	
		print(player.Name.." has pressed 4")
	end
end)

changeClass.OnServerEvent:Connect(function(player,index)
	if classes[index] and not player.IsIn.Value then
		if player:FindFirstChild("Class") then
			local class = classes[index]
			player:WaitForChild("Class").Value = index
		end
	end
end)
