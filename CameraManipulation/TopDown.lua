--Client Camera Module
--Ashton
--6.13.22

--Objects--
local cameraManip = {}
local player = game.Players.LocalPlayer
local runService = game:GetService("RunService")

--Variables--
local yHeight = 20
local offset = 15
local zoom = 0
local zoomSens = 1

--Constants--
local MAX_ZOOM = 20
local MIN_ZOOM = -12

function cameraManip.TopDown(newYHeight)
	yHeight = newYHeight or yHeight
	local mouse = player:GetMouse()
	local character = player.Character or player.CharacterAdded:Wait()
	local hRP = character:WaitForChild("HumanoidRootPart")
	local camera = workspace.CurrentCamera
	camera.CameraType = Enum.CameraType.Scriptable

	runService.RenderStepped:Connect(function()
		local cameraPos = Vector3.new(hRP.Position.X - offset - zoom, hRP.Position.Y + offset + zoom, hRP.Position.Z - offset - zoom)
		local lookPos = hRP.Position
		camera.CFrame = CFrame.new(cameraPos, lookPos)
	end)

	 player.CharacterAdded:Connect(function(char)
		character = char
		hRP = character:WaitForChild("HumanoidRootPart")
	end)
	
	mouse.WheelForward:Connect(function()
		zoom = zoom - zoomSens > MIN_ZOOM and zoom - zoomSens or MIN_ZOOM
	end)
	
	mouse.WheelBackward:Connect(function()
		zoom = zoom + zoomSens < MAX_ZOOM and zoom + zoomSens or MAX_ZOOM
	end)
end

return cameraManip
