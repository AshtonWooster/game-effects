local tweenService = game:GetService("TweenService")
local effectFolder = workspace:WaitForChild("AttackEffects")

local module = {}

function module.Shockwave(position,radius) --creates a shockwave of parts with given position and radius (position of the shockwave, radius of the shockwave)
	local blacklist = {}
	for _,part in pairs(effectFolder:GetChildren()) do
		table.insert(blacklist,part)
	end
	for _,player in pairs(game.Players:GetPlayers()) do
		local character = player.Character or player.CharacterAdded:Wait()
		table.insert(blacklist,character)
	end
	local partModel = Instance.new("Model")
	partModel.Parent = effectFolder
	partModel.Name = "Shockwave"
	
	local increment = (math.pi*2)/(radius*1.5+2)
	for i=1,math.ceil(radius*1.5)+2 do
		local angle = i*increment
		local partPos = (CFrame.new(position)*CFrame.new(math.cos(angle)*radius,0,math.sin(angle)*radius)).p
		local rayParams = RaycastParams.new()
		rayParams.FilterDescendantsInstances = blacklist
		rayParams.FilterType = Enum.RaycastFilterType.Blacklist
		local result = workspace:Raycast(partPos+Vector3.new(0,1,0),Vector3.new(0,-90,0),rayParams)
		if result then
			local newPart = Instance.new("Part")
			local size = (radius/15+2)+(radius/math.random(6,40))*1/math.random(2,4)
			newPart.Size = Vector3.new(size,size,size)
			newPart.Anchored = true
			newPart.CanCollide = false
			newPart.Parent = partModel
			newPart.Position = Vector3.new(partPos.X,result.Instance.Position.Y+result.Instance.Size.Y/2,partPos.Z)
			newPart.Orientation = Vector3.new(math.random(1,180),math.random(1,180),math.random(1,180))
			newPart.Material = result.Material
			newPart.Color = result.Instance.Color
			table.insert(blacklist,newPart)
		end
	end
	local coro = coroutine.wrap(function()
		wait(3)
		local tweenInfo = TweenInfo.new(1,Enum.EasingStyle.Cubic,Enum.EasingDirection.Out,0,false,0)
		for _,part in pairs(partModel:GetChildren()) do
			tweenService:Create(part,tweenInfo,{Size=Vector3.new(0,0,0)}):Play()	
		end
		wait(1)
		partModel:Destroy()
	end)
	coro()
end

function module.LinearShockwave(startPos,endPos,size,duration) --creats two shockwave lines of parts (starting position, ending position, size and distance of the lines, how long it takes for the shockwave to hit the end)
	local blacklist = {}
	for _,part in pairs(effectFolder:GetChildren()) do
		table.insert(blacklist,part)
	end
	for _,player in pairs(game.Players:GetPlayers()) do
		local character = player.Character or player.CharacterAdded:Wait()
		table.insert(blacklist,character)
	end
	local partModel = Instance.new("Model")
	partModel.Parent = effectFolder
	partModel.Name = "LinearShockwave"
	local distance = (startPos-endPos).Magnitude
	for i=1,math.ceil(distance/size) do
		for j = 0,1 do
			local position = startPos + (endPos-startPos).Unit*i*(endPos-startPos).Magnitude/(distance/size)
			local inCFrame = CFrame.new(position,startPos)
			local offset = CFrame.new(((j*2)-1)*size*1.5,0,0)
			local partPos = (inCFrame*offset).p
			local rayParams = RaycastParams.new()
			rayParams.FilterDescendantsInstances = blacklist
			rayParams.FilterType = Enum.RaycastFilterType.Blacklist
			local result = workspace:Raycast(partPos+Vector3.new(0,1,0),Vector3.new(0,-90,0),rayParams)
			if result then
				local newPart = Instance.new("Part")
				local rSize = size + size/math.random(10,50)*(math.random(0,1)*2-1)
				newPart.Size = Vector3.new(rSize,rSize,rSize)
				newPart.Anchored = true
				newPart.CanCollide = false
				newPart.Parent = partModel
				newPart.Orientation = Vector3.new(math.random(1,180),math.random(1,180),math.random(1,180))
				newPart.Position = Vector3.new(partPos.X,result.Instance.Position.Y+result.Instance.Size.Y/2,partPos.Z)
				newPart.Material = result.Material
				newPart.Color = result.Instance.Color
				table.insert(blacklist,newPart)
			end
		end
		if duration and duration ~= 0 then
			wait(duration/math.ceil(distance*0.75))
		end
	end
	local coro = coroutine.wrap(function()
		wait(3)
		local tweenInfo = TweenInfo.new(1,Enum.EasingStyle.Cubic,Enum.EasingDirection.Out,0,false,0)
		for _,part in pairs(partModel:GetChildren()) do
			tweenService:Create(part,tweenInfo,{Size=Vector3.new(0,0,0)}):Play()	
		end
		wait(1)
		partModel:Destroy()
	end)
	coro()
end

return module
