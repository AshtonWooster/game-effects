--Ashton
--4.2.22
--Break Client Module

--Objects--
local bMod = {}
local repStorage = game:GetService("ReplicatedStorage")
local hitBoxes = repStorage:WaitForChild("Hitboxes")
local squareBox = hitBoxes:WaitForChild("SquareHitbox")
local events = repStorage:WaitForChild("Events")
local basic1 = events:WaitForChild("Basic1")
local basic2 = events:WaitForChild("Basic2")
local basic3 = events:WaitForChild("Basic3")
local basic4 = events:WaitForChild("Basic4")
local clientEffects = workspace:WaitForChild("ClientEffects")
local player = game.Players.LocalPlayer
local character
local humanoid

--Modules--
local utilities = require(script.Parent:WaitForChild("Utilities"))

--Variables--
local isDead = true
local isCharge = false
local currentCharge = 0
local currentBox
local move

--Constants--
local DEFAULT_PILLAR   = 10
local PILLAR_CHARGE    = 0.2
local CHARGE_WALKSPEED = 6

--Reset Vars--
local function reset()
	isCharge = false
	currentCharge = 0
	
	if move then
		move:Disconnect()
	end
	
	if currentBox then
		currentBox:Destroy()
	end
end

--Track Respawns--
player.CharacterAdded:Connect(function(char)
	character = char
	humanoid = character:WaitForChild("Humanoid")
	isDead = false

	local died
	died = humanoid.Died:Connect(function()
		isDead = true
		reset()
		died:Disconnect()
	end)
end)

--Cancel--
function bMod.Cancel()
	reset()
end


--Pillar--
function bMod.Pillar(charging)
	local mouse = player:GetMouse()
	
	if charging then
		isCharge = true
		humanoid.WalkSpeed = CHARGE_WALKSPEED
		currentCharge = DEFAULT_PILLAR
		
		currentBox = squareBox:Clone()
		currentBox.Parent = clientEffects
		local pos = utilities.RayDown(mouse.Hit.Position)
		if pos then
			currentBox.Position = pos
		end
		
		move = mouse.Move:Connect(function()
			local pos = utilities.RayDown(mouse.Hit.Position)
			if pos then
				currentBox.Position = pos
			end
		end)
		
		while isCharge do
			currentCharge = currentCharge + PILLAR_CHARGE
			currentBox.Size = Vector3.new(currentCharge, 0.1, currentCharge)
			wait()
		end
	else
		humanoid.WalkSpeed = 16
		basic1:FireServer(mouse.Hit.Position, currentCharge)
		reset()
	end
end

return bMod