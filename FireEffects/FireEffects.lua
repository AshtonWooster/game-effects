--Effects Module Server
--Ashton
--10.5.22 -- 10.6.22

--Modules--
local effects = {}
local valueManip = require(script.Parent:WaitForChild("ValueManip"))

--Objects--
local repStorage = game:GetService("ReplicatedStorage")
local tService = game:GetService("TweenService")
local effectStorage = repStorage:WaitForChild("Effects")
local effectsFolder = workspace:WaitForChild("Effects")
local glowPart = effectStorage:WaitForChild("GlowPart")

--Fire--
local FIRE_PART_TIME = 0.5
local FIRST_OFFSET   = 1.2
local LAST_OFFSET    = 1.7
local LAST_SHRINK    = 0.8
local DEFAULT_HEIGHT = 5
local TICK           = 15
local IN_TRANS       = 0.3
function effects.Fire(colors, bound, rate, duration) -- Call function again to end, duration < 0 = looped
	colors = colors or {Color3.fromRGB(255,255,0), Color3.fromRGB(255, 127, 0), Color3.fromRGB(255, 0, 0), Color3.fromRGB(255,0,0)}
	
	local totalParts = duration*rate
	local colorTime = FIRE_PART_TIME/#colors
	local bSize = valueManip.GetWorldVector(bound)
	local transInfo = TweenInfo.new(FIRE_PART_TIME*4/5, Enum.EasingStyle.Quint, Enum.EasingDirection.In)
	local transInInfo = TweenInfo.new(FIRE_PART_TIME/5, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out)
	local posInfo = TweenInfo.new(FIRE_PART_TIME, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
	local colorInfo = TweenInfo.new(colorTime, Enum.EasingStyle.Cubic, Enum.EasingDirection.InOut)
	local firstSize = Vector3.new(glowPart.Size.X*FIRST_OFFSET, glowPart.Size.Y, glowPart.Size.Z*FIRST_OFFSET)
	local finalSize = Vector3.new(glowPart.Size.X*LAST_SHRINK, glowPart.Size.Y*LAST_OFFSET, glowPart.Size.Z*LAST_SHRINK) 
	
	local looped = duration <= 0
	local count = 0
	coroutine.wrap(function()
		while looped or count < duration do
			if not bound then break end

			for i = 0, math.ceil(rate/TICK) do
				local rX, rY, rZ = math.random(bSize.X/-2, bSize.X/2), math.random(bSize.Y/-2, bSize.Y/2), math.random(bSize.Z/-2, bSize.Z/2)
				local rPos = (bound.CFrame * CFrame.new(rX, rY, -rZ)).Position
				local height = DEFAULT_HEIGHT + math.random(-DEFAULT_HEIGHT/2, DEFAULT_HEIGHT/2)
				local tweenProp = {Size = finalSize, Position = rPos + Vector3.new(0, height, 0)}
				local newPart = glowPart:Clone()
				newPart.Parent = effectsFolder
				newPart.Position = rPos
				newPart.Size = firstSize

				tService:Create(newPart, transInInfo, {Transparency = IN_TRANS}):Play()
				tService:Create(newPart, posInfo, tweenProp):Play()
				
				--Colors
				coroutine.wrap(function()
					for j = 1, #colors do 
						tService:Create(newPart, colorInfo, {Color = colors[j]}):Play()
						wait(colorTime)
					end
				end)()		
				
				--Transparency
				coroutine.wrap(function()
					wait(FIRE_PART_TIME/5)
					tService:Create(newPart, transInfo, {Transparency = 1}):Play()
				end)()

			end
			wait(1/TICK)

			count = count + 0.1
		end
	end)()
	
	return function()
		count = duration
		looped = false
	end
end

return effects