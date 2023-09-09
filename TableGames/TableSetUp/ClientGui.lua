--Gui Controller Client
--Ashton
--7.31.23

--Objects--
local repStorage = game:GetService("ReplicatedStorage")
local events = repStorage:WaitForChild("Events")
local leaveEvent = events:WaitForChild("Leave")
local player = game.Players.LocalPlayer
local gui = player:WaitForChild("PlayerGui"):WaitForChild("ScreenGui")
local clickEffect = gui:WaitForChild("ClickEffect")
local leaveButton = gui:WaitForChild("Leave")

--Show/Hide leave button--
leaveEvent.OnClientEvent:Connect(function(val)
	leaveButton.Visible = val
end)

--Leave table--
leaveButton.Activated:Connect(function()
	leaveEvent:FireServer()
end)