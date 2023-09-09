--Ashton
--4.3.22
--Break Server Module

--Objects--
local bMod = {}
local repStorage = game:GetService("ReplicatedStorage")
local effects = repStorage:WaitForChild("Effects")
local cube = effects:WaitForChild("BreakCube")
local dust = effects:WaitForChild("Dust")
local effectsFolder = workspace:WaitForChild("AttackEffects")
local tweenService = game:GetService("TweenService")

--Variables--
local pillarInfo = TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

--Modules--
local utilities = require(script.Parent:WaitForChild("Utilities"))
local effects = require(script.Parent:WaitForChild("Effects"))

--Constants--
local PILLAR_TIME = 5

--Basic1 [ Pillar ] --
function bMod.Basic1(pos, charge)
	local coro
	coro = coroutine.wrap(function()
		local properties = utilities.RayDown(pos)
		if properties then
			local newDust = dust:Clone()
			local smoke = newDust:WaitForChild("Smoke")
			newDust.Size = Vector3.new(charge/2, 0.1, charge/2)
			newDust.Parent = effectsFolder
			newDust.Position = properties[1]
			smoke.Color = ColorSequence.new(properties[3])
			smoke.Speed = NumberRange.new(charge*4)
			smoke.Drag = charge/2
			
			local newCube = cube:Clone()
			local shake = newCube:WaitForChild("Shake")
			local energy = newCube:WaitForChild("Energy")
			newCube.Size = Vector3.new(charge,0.1,charge)
			newCube.Parent = effectsFolder
			newCube.Material = properties[2]
			newCube.Color = properties[3]
			newCube.Transparency = 1
			newCube.Position = properties[1]+Vector3.new(0, newCube.Size.Y/2, 0)
			
			energy:Play()
			effects.OutlineSquare(properties[1], charge/2, charge, 1)
			wait(1)
			
			local pillarPos = Vector3.new(pos.X, pos.Y + charge - 1, pos.Z)
			local pillarSize = Vector3.new(charge, charge*2, charge)
			smoke:Emit(charge*4)
			effects.SquareShockwave(properties[1], charge*7/12, charge/4, PILLAR_TIME)
			newCube.Transparency = properties[4]
			shake:Play()
			tweenService:Create(newCube, pillarInfo, {Size = pillarSize, Position = pillarPos}):Play()
			wait(PILLAR_TIME)
			
			newCube:Destroy()
			newDust:Destroy()
		end
	end)
	coro()
end

return bMod