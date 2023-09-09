--Ashton
--1.30.22 -- 1.31.22
--Gui Controller Controller

--Modules--
local camManip = require(script:WaitForChild("Camera"))
local charEdit = require(script:WaitForChild("CharacterEdit"))

--Objects--
local screen = script.Parent:WaitForChild("ScreenGui")
local tweenService = game:GetService("TweenService")
local repStorage = game:GetService("ReplicatedStorage")
local uInput = game:GetService("UserInputService")
local weaponsFolder = repStorage:WaitForChild("Weapons")
local miscFolder = repStorage:WaitForChild("Misc")
local editButton = screen:WaitForChild("CharacterEdit")
local editPlace = miscFolder:WaitForChild("CharacterEdit")
local player = game.Players.LocalPlayer

--Variables--
local isEditing = false
local editDebounce = true
local editCurrent
local rotateFunction

--Constants--
local BASE_SPEED = 16
local BASE_JUMP = 50
local FADE_TIME = 1

--Edit Button--
editButton.Activated:Connect(function()
	local camera = workspace.CurrentCamera
	if not isEditing and editDebounce then --Begin Character Edit
		isEditing = true 
		editDebounce = false
		
		editCurrent = editPlace:Clone()
		editCurrent.Parent = workspace
		
		local weaponPos = editCurrent:WaitForChild("WeaponPos")
		local weaponLook = editCurrent:WaitForChild("WeaponLook")
		local character = player.Character or player.CharacterAdded:Wait()
		local humanoid = character:WaitForChild("Humanoid")
		
		local newWeapon = weaponsFolder:WaitForChild("Odachi"):Clone() --This is bad fix this some time? Needs to be modular
		newWeapon.Parent = editCurrent
		newWeapon:WaitForChild("Sheath"):Destroy()
		for _, part in pairs(newWeapon:GetChildren()) do
			if part:IsA("BasePart") then
				part.Anchored = true
			end
		end
		newWeapon:SetPrimaryPartCFrame(weaponLook.CFrame)
		
		rotateFunction = uInput.InputBegan:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 then
				charEdit.RotateModel(newWeapon)
			end
		end)
		
		camManip.Fade(true)
		wait(FADE_TIME)
		
		humanoid.JumpPower = 0
		humanoid.WalkSpeed = 0
		
		camera.CameraType = Enum.CameraType.Scriptable
		camManip.MoveCamera(CFrame.new(weaponPos.Position,weaponLook.Position))
		camManip.Fade(false)
		
		editDebounce = true
	elseif editDebounce then --End character edit
		isEditing = false
		editDebounce = false
		
		local character = player.Character or player.CharacterAdded:Wait()
		local humanoid = character:WaitForChild("Humanoid")
		
		camManip.Fade(true)
		wait(FADE_TIME)
		
		humanoid.JumpPower = BASE_JUMP
		humanoid.WalkSpeed = BASE_SPEED
		
		camera.CameraType = Enum.CameraType.Custom
		camManip.Fade(false)
		
		if rotateFunction then
			rotateFunction:Disconnect()
		end
		if editCurrent then
			editCurrent:Destroy()
		end
		
		editDebounce = true
	end
end)