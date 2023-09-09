--Client Dialogue Controller
--Ashton
--11.13.22 -- 1.7.23

--Modules--
local dialogue = require(script:WaitForChild("Dialogue"))

--Objects--
local player = game.Players.LocalPlayer
local repStorage = game:GetService("ReplicatedStorage")
local events = repStorage:WaitForChild("Events")
local messageEvent = events:WaitForChild("Message")
local gui = player:WaitForChild("PlayerGui"):WaitForChild("ScreenGui")
local dialogueFolder = gui:WaitForChild("Dialogue")
local posB = dialogueFolder:WaitForChild("Bottom")
local bTemplateRow = posB:WaitForChild("Row")

messageEvent.OnClientEvent:Connect(function(textPacket)
	dialogue.Create(textPacket)
end)