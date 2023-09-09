--Ashton
--2.7.22
--Build Test Effect

--Objects--
local tweenS = game:GetService("TweenService")
local linesBlock = script.Parent:WaitForChild("LinesTest")
local linesButton = linesBlock:WaitForChild("ClickDetector")
local linesDelayedBlock = script.Parent:WaitForChild("LinesDelayedTest")
local linesDelayedButton = linesDelayedBlock:WaitForChild("ClickDetector")
local diagonalBlock = script.Parent:WaitForChild("DiagonalTest")
local diagonalButton = diagonalBlock:WaitForChild("ClickDetector")
local diagonalDelayBlock = script.Parent:WaitForChild("DiagonalDelayedTest")
local diagonalDelayButton = diagonalDelayBlock:WaitForChild("ClickDetector")
local dumpFolder = Instance.new("Folder")
dumpFolder.Parent = workspace
dumpFolder.Name = "GridDump"

--Variables--
local blocks = {}
local orgin = linesButton.Parent.Position + Vector3.new(10,0,10)
local seed = math.random(1,999)/1000
local debounce = true

--Constants--
local GRID_SIZE = 10
local BLOCK_SIZE = Vector3.new(10,1,10)
local NO_DELAY_WAIT = 0.2
local CLICK_SOUND = "rbxassetid://6236124004"
local COOLDOWN = 2

--Build Effect-- (parts: array of parts, height: height to build from, pause: time to wait between parts, sound: sound played on hit)
local function build(parts, pause, height, sound)
	height = height or 50
	height = Vector3.new(0, height, 0)
	pause = pause or 0.05
	sound = sound or "4567107047"
	sound = "rbxassetid://"..sound
	
	local toTween = {}
	for _, part in pairs(parts) do
		toTween[#toTween+1] = part
		part.Transparency = 1
		part.Position = part.Position + height
		part.CanCollide = false
	end
	
	local tweenI = TweenInfo.new(0.8, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
	for i, part in pairs(toTween) do
		local coro = coroutine.wrap(function()
			local fallT = tweenS:Create(part, tweenI, {Transparency = 0, Position = part.Position - height})
			local newSound = Instance.new("Sound")
			
			newSound.Parent = part
			newSound.SoundId = sound
			fallT:Play()
			
			fallT.Completed:Wait()
			part.CanCollide = true
			newSound:Play()
			newSound.Ended:Wait()
			newSound:Destroy()			
		end)
		coro()
		
		if pause > 0 then
			wait(pause)
		end
	end
end

--Construct a diagonal grid--
local function diagonalGrid(parts, seperate)
	local temp = {}
	local size = math.floor(math.sqrt(#parts))
	local numLines = size*2-1
	
	for i = 1, numLines do
		local limit = i+1
		
		if seperate then
			temp[i] = {}
		end
		
		for j = 1, -math.abs(i-size)+size do
			local x = i < size and i or size
			x = x-j+1
			local y = limit-x
			local part = parts[(y-1)*size+x]
			
			if seperate then
				temp[i][#temp[i]+1] = part
			else
				temp[#temp+1] = part
			end
		end
	end
	
	return temp
end

--Construct Square Grid From Array--
local function gridFromArray(list)
	local size = math.floor(math.sqrt(#list))
	local temp = {}
	
	for x = 1, size do
		temp[x] = {}
		for y = 1, size do
			temp[x][y] = list[(y-1)*size+x]
		end
	end
	
	return temp
end

--Reset Grid--
local function resetGrid(parts)
	for _, part in pairs(parts) do
		if part:IsA("BasePart") then
			part.Transparency = 1
		end
	end
end

--Button Click--
local function click(button)
	local sound = Instance.new("Sound")
	button.Position = button.Position - Vector3.new(0, 0.3, 0)
	sound.Parent = button
	sound.SoundId = CLICK_SOUND
	sound.PlayOnRemove = true
	sound:Destroy()
end

--Button Unclick--
local function unClick(button)
	local sound = Instance.new("Sound")
	button.Position = button.Position + Vector3.new(0, 0.3, 0)
	sound.Parent = button
	sound.SoundId = CLICK_SOUND
	sound.PlaybackSpeed = 0.7
	sound.PlayOnRemove = true
	sound:Destroy()
end

--Lines Effect--
linesButton.MouseClick:Connect(function()
	if debounce then
		debounce = false
		click(linesBlock)
		
		local temp = gridFromArray(blocks)
		resetGrid(blocks)
		
		for _, tempArray in pairs(temp) do
			build(tempArray, 0)
			wait(NO_DELAY_WAIT)
		end
		
		wait(COOLDOWN)
		unClick(linesBlock)
		debounce = true
	end
end)

--Lines Delayed Effect--
linesDelayedButton.MouseClick:Connect(function()
	if debounce then
		debounce = false
		click(linesDelayedBlock)
		
		build(blocks)
		
		wait(COOLDOWN)
		unClick(linesDelayedBlock)
		debounce = true
	end
end)

--Diagonal Effect--
diagonalButton.MouseClick:Connect(function()
	if debounce then
		debounce = false
		click(diagonalBlock)
		
		local temp = diagonalGrid(blocks, true)
		resetGrid(blocks)
		
		for _, tempArray in pairs(temp) do
			build(tempArray, 0)
			wait(NO_DELAY_WAIT)
		end
		
		wait(COOLDOWN)
		unClick(diagonalBlock)
		debounce = true
	end
end)

--Diagonal Delay Effect--
diagonalDelayButton.MouseClick:Connect(function()
	if debounce then
		debounce = false
		click(diagonalDelayBlock)
		
		build(diagonalGrid(blocks, false))
		
		wait(COOLDOWN)
		unClick(diagonalDelayBlock)
		debounce = true
	end
end)

--Construct grid--
for x = 1, GRID_SIZE do
	for y = 1, GRID_SIZE do
		local newBlock = Instance.new("Part")
		newBlock.Parent = dumpFolder
		newBlock.Size = BLOCK_SIZE
		newBlock.Position = orgin + Vector3.new(BLOCK_SIZE.X*x, 0, BLOCK_SIZE.Z*y)
		newBlock.Anchored = true
		newBlock.Color = Color3.fromRGB((math.noise(x, y, seed)+1)*100, (math.noise(x, y, seed)+1)*100, (math.noise(x, y, seed)+1)*100)
		newBlock.CastShadow = false

		blocks[#blocks+1] = newBlock
	end
end