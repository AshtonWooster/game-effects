--Server Effects Module
--Ashton
--6.7.22 -- 6.12.22

--Objects--
local effects = {}
local effectsFolder = workspace:WaitForChild("Effects")
local tweenService = game:GetService("TweenService")

--Copy Properties--
function effects.CopyProperties(partA, partB)
	partA.Color = partB.Color
	partA.Transparency = partB.Transparency
	partA.Material = partB.Material
	partA.CanCollide = partB.CanCollide
	partA.Anchored = partB.Anchored
end

--Create Lightning--
function effects.CreateLightning(posA, posB, numPoints, size, modelPart, construct)
	--Vars
	local distance = (posA-posB).Magnitude
	local direction = (posB-posA).Unit
	local points = {}
	
	--Place points and offset all but first & last
	for i = 1, numPoints do
		points[i] = posA + direction*distance/(numPoints-1)*(i-1)
	end
	for i = 2, numPoints-1 do
		local offMag = distance/10
		local rX, rY, rZ = math.random(-1000,1000)/1000, math.random(-1000,1000)/1000, math.random(-1000,1000)/1000 
		points[i] = points[i] + Vector3.new(offMag*rX, offMag*rY, offMag*rZ)
	end
	
	--Place Parts in between points
	local model = Instance.new("Model")
	model.Parent = effectsFolder
	for i = 1, numPoints-1 do
		local pSize, cFrame
		local newPart = Instance.new("Part")
		newPart.Parent = model
		
		--Constructed or not
		if construct then
			pSize = Vector3.new(size, size, (points[i] - points[i+1]).Magnitude)
			cFrame = CFrame.new((points[i] + points[i+1])/2, points[i+1])
		else
			pSize = Vector3.new(size, size, size)
			cFrame = CFrame.new(points[i], points[i+1])
		end
		newPart.Size = pSize
		newPart.CFrame = cFrame
		newPart.Name = tostring(i)
		
		effects.CopyProperties(newPart, modelPart)
	end
	
	return model, points
end

function effects.LightningFade(model, points, duration, toTrans, inOut)
	--Get Part Array
	local parts = {}
	for i = 1, #points-1 do
		parts[i] = model:WaitForChild(tostring(i))
	end
	local size = parts[1].Size.X
	
	--Calculate times
	local totalLength = 0
	for i = 1, #points-1 do
		totalLength = totalLength + (points[i]-points[i+1]).Magnitude
	end
	local perStud = duration/totalLength
	local times = {}
	for i = 1, #points-1 do
		times[i] = (points[i]-points[i+1]).Magnitude*perStud
	end
	
	--Tween Parts
	coroutine.wrap(function()
		for i, t in pairs(times) do
			parts[i].Transparency = inOut and toTrans or parts[i].Transparency
			
			local tweenInfo = TweenInfo.new(t, Enum.EasingStyle.Linear)
			local toSize = inOut and Vector3.new(size, size, (points[i] - points[i+1]).Magnitude)  or Vector3.new(size, size, size)
			local toPos = inOut and (points[i+1] + points[i])/2 or points[i+1]
			tweenService:Create(parts[i], tweenInfo, {Size = toSize, Position = toPos}):Play()
			
			wait(t)
			parts[i].Transparency = inOut and parts[i].Transparency or toTrans
		end
	end)()
end

return effects
