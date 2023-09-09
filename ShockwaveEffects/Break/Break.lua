--Ashton
--4.3.22
--Effects Module Server

--Objects--
local effectMod = {}
local repStorage = game:GetService("ReplicatedStorage")
local tweenService = game:GetService("TweenService")
local effectsFolder = repStorage:WaitForChild("Effects")
local attackEffects = workspace:WaitForChild("AttackEffects")
local shockwavePart = effectsFolder:WaitForChild("ShockwavePart")
local outlinePart = effectsFolder:WaitForChild("Outline")

--Variables--
local fadeInfo = TweenInfo.new(2, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out)
local outlineInfo = TweenInfo.new(1, Enum.EasingStyle.Cubic, Enum.EasingDirection.In)

--Modules--
local utilities = require(script.Parent:WaitForChild("Utilities"))

--Create part--
local function createCube(pos, size)
	local newPart = shockwavePart:Clone()
	local properties = utilities.RayDown(pos)
	newPart.Position = properties[1]
	newPart.Material = properties[2]
	newPart.Color = properties[3]
	newPart.Transparency = properties[4]
	newPart.Orientation = Vector3.new(math.random(-180,180), math.random(-180, 180), math.random(-180, 180))
	newPart.Parent = attackEffects
	newPart.Size = Vector3.new(size, size, size)
	
	return newPart
end

--Convert to Square direction--
local function convertSquareDir(x)
	local xDir = (((x+1)%2)*(x-2)-1)*((x+1)%2)
	local yDir = ((x%2)*(x-1)-1)*(x%2)
	
	return {xDir, yDir}
end

--Square Shockwave--
function effectMod.SquareShockwave(pos, radius, partSize, fadeTime)
	local cubes = {}
	local numParts = radius*2/(partSize-1)
	for x = 1, 4 do
		local dirs = convertSquareDir(x)
		for i = 1, numParts do
			local offset = radius*2/numParts*(numParts/2-i)
			local xPos = (offset*(x%2) + dirs[1]*radius) + pos.X
			local yPos = (offset*((x+1)%2) + dirs[2]*radius) + pos.Z
			
			cubes[#cubes + 1] = createCube(Vector3.new(xPos, pos.Y, yPos), partSize)
		end
	end
	
	local coro = coroutine.wrap(function()
		wait(fadeTime)
		
		for _, part in pairs(cubes) do
			tweenService:Create(part, fadeInfo, {Size = Vector3.new(0,0,0), Position = part.Position - Vector3.new(0, part.Size.X/2, 0)}):Play()
		end
		wait(2)
		
		for _, part in pairs(cubes) do
			part:Destroy()
		end
	end)
	coro()
end

--Outline Square--
function effectMod.OutlineSquare(pos, radius, size, fadeTime)
	local parts = {}
	
	for x = 1, 4 do
		local dirs = convertSquareDir(x)
		local newPart = outlinePart:Clone()
		newPart.Parent = attackEffects
		newPart.Size = Vector3.new(0.2,0.2,0.2)
		newPart.Position = Vector3.new(dirs[1] * radius + pos.X, pos.Y, dirs[2] * radius + pos.Z)
		tweenService:Create(newPart, outlineInfo, {Size = Vector3.new((x%2)*size + 0.2, 0.2, ((x+1)%2)*size + 0.2)}):Play()
		parts[#parts + 1] = newPart
	end
	local newPart = outlinePart:Clone()
	newPart.Position = pos
	newPart.Size = Vector3.new(0.2,0.2,0.2)
	newPart.Parent = attackEffects
	tweenService:Create(newPart, outlineInfo, {Size = Vector3.new(radius*2, 0.2, radius*2)}):Play()
	
	local coro = coroutine.wrap(function()
		wait(fadeTime)
		
		tweenService:Create(newPart, outlineInfo, {Transparency = 1}):Play()
		for _, part in pairs(parts) do
			tweenService:Create(part, outlineInfo, {Transparency = 1}):Play()
		end
		wait(1)
		
		newPart:Destroy()
		for _, part in pairs(parts) do
			part:Destroy()
		end
	end)
	coro()
end

--Break Part--
function effectMod.BreakPart(part, xPieces, yPieces, fadeTime)
	
end

return effectMod