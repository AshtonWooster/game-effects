local replicatedStorage = game:GetService("ReplicatedStorage")
local tweenService = game:GetService("TweenService")
local event = replicatedStorage:WaitForChild("Attack")
local effects = require(script.Parent:WaitForChild("EffectModule"))
local attackEffects = workspace:WaitForChild("AttackEffects")
local lightFolder = replicatedStorage:WaitForChild("LightWeapons")
local lightWeapons = lightFolder:GetChildren()
local cooldowns = {}
local ranges = {light={E=50}}

game.Players.PlayerAdded:Connect(function(player)
	cooldowns[player]={Q=true,E=true}
end)

game.Players.PlayerRemoving:Connect(function(player)
	cooldowns[player]=nil
end)

event.OnServerEvent:Connect(function(player,attack,pos)
	if cooldowns[player][attack] then
		local character = player.Character or player.CharacterAdded:Wait()
		local torso = character:WaitForChild("Torso")
		if (pos-torso.Position).Magnitude>ranges["light"][attack] then
			pos = torso.Position + (pos-torso.Position).Unit*ranges["light"][attack]
		end
		local result = workspace:Raycast(pos+Vector3.new(0,0.5,0),Vector3.new(0,-90,0))
		if result then
			pos = result.Position
		end
		if attack == "E" then
			cooldowns[player]["E"]=false
			local spears = {}
			for i=1,13 do
				local newSpear = lightFolder:WaitForChild("LightSpear"):Clone()
				newSpear.Parent = attackEffects
				newSpear.Anchored = true
				table.insert(spears,newSpear)
				local rPos = pos+Vector3.new(math.random(-5,5),0,math.random(-5,5))
				if (rPos-pos).Magnitude>5 then
					rPos = pos+(rPos-pos).Unit*5
				end
				newSpear.Position = rPos-Vector3.new(0,4,0)
				newSpear.Transparency = 0
				newSpear.Orientation = Vector3.new(0,math.random(1,360),0)
				tweenService:Create(newSpear,TweenInfo.new(0.2,Enum.EasingStyle.Cubic,Enum.EasingDirection.Out,0,false,0),{Position=rPos+Vector3.new(0,3.6,0)}):Play()
				local sound = Instance.new("Sound")
				sound.Parent = workspace
				sound.SoundId = "rbxassetid://5810316165"
				sound:Play()
			end
			wait(0.8)
			for _,spear in pairs(spears) do
				effects.Fade(spear,1,0.3)
			end
			wait(0.3)
			for _,spear in pairs(spears) do
				spear:Destroy()
			end
			wait(1.9)
			cooldowns[player]["E"]=true
		end
		
	end
end)
