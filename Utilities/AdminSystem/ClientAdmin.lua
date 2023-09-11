--Client Admin Script
--Ashton
--9.13.22 -- 9.10.23

--Modules--
local mouseController = require(script.Parent:WaitForChild("Classes"):WaitForChild("Mouse"))

--Objects--
local repStorage = game:GetService("ReplicatedStorage")
local commandRanksFolder = repStorage:WaitForChild("CommandRanks")
local events = repStorage:WaitForChild("Events")
local adminEvent = events:WaitForChild("Admin")
local userIS = game:GetService("UserInputService")
local player = game.Players.LocalPlayer
local gui, adminFolder, adminBtn, adminMenu, nameBox, commandBar, adminMove, boxes
local pBox, execute, cancel, helpMenu, adminClose, helpClose, helpMove, helpName, posSelect
local currentCommand, currentPos = "", nil
local getPos, newMove, discon

--Constants--
local MENU_CENTER = UDim2.fromScale(0.564, 0.333)
local HELP_POS = UDim2.fromScale(0.5, 0.5)
local PBOX_DEFAULT = "Waiting..."

--Initialize boxes--
local function initBox(box, text)
	box.Visible = true
	box.PlaceholderText = text
end

--Initialize boxes--
local function initBoxes(num, text, start)
	for i = start or 1, num do
		initBox(boxes[i], text[i])
	end
end

--Init Pos--
local function initPos()
	posSelect.Visible = true
end

--Hide Pos--
local function hidePos()
	posSelect.Visible = false
end

--Disconnect functions--
local function disconnectAll()
	if getPos then getPos:Disconnect() end
	if newMove then newMove:Disconnect() end
	if discon then discon:Disconnect() end
end

--Clear Boxes--
local function clearBoxes()
	currentCommand = ""
	pBox.Text = PBOX_DEFAULT
	commandBar.Text = ""
	currentPos = nil
	hidePos()
	disconnectAll()
	for i=1, #boxes do
		boxes[i].Visible = false
		boxes[i].Text = ""
	end
end

--Required Ranks [ 0: Owner, 1: Admin, 2: Mod, 3: Perms ] --
local REQUIRED_RANKS = {}
for _, val in pairs(commandRanksFolder:GetChildren()) do
	REQUIRED_RANKS[val.Name] = val.Value
end

--Commands--
local COMMAND_LIST = {
	rank = function()
		initBoxes(2, {"Name", "Rank"})
		pBox.Text = "Enter name and rank"
	end,
	
	humanoidProp = function()
		initBoxes(4, {"Name", "Speed", "JumpPower", "Health"})
		pBox.Text = "Enter humanoid properties"
	end,
	
	create = function()
		initBoxes(4, {"Pos", "Name", "Num", "Height"}, 2)
		initPos()
		pBox.Text = "Enter object info"
	end,
	
	destroy = function()
		initBoxes(1, {"Name"})
		pBox.Text = "Enter object name"
	end,
	
	clear = function()
		pBox.Text = "Clear created?"
	end,
	
	tp = function()
		initBoxes(2, {"Pos", "Name"}, 2)
		initPos()
		pBox.Text = "Enter location or player"
	end,
	
	fire = function()
		initBoxes(4, {"Colors", "Bound", "Rate", "Duration"})
		pBox.Text = "NOT DONE YET"
	end,
	
	help = function()
		pBox.Text = "Help window opened"
		helpMenu.Visible = true
	end,
	
	message = function()
		initBoxes(2, {"Text", "Player"})
		pBox.Text = "Enter text and target player"
	end,
	
	class = function()
		initBoxes(2, {"Class Name", "Player"})
		pBox.Text = "Enter class name and target player"
	end,
}

--Client based commands--
local CLIENT_COMMANDS = {
	help = function()
		helpMenu.Visible = true
	end,
}

--Connect Box Texts--
local function collectText()
	local props = {}
	for i = 1, #boxes do
		props[i] = boxes[i].Text
	end
	if posSelect.Visible then
		props[1] = currentPos
	end
	return props
end

--Recconect all buttons--
local function connectAll()
	--Connect admin button--
	adminBtn.Activated:Connect(function()
		adminMenu.Visible = not adminMenu.Visible
		adminMenu.Position = MENU_CENTER
		clearBoxes()
	end)
	
	--Connect AdminMove--
	adminMove.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			local newMove
			local discon
			local mouse = player:GetMouse()
			local viewSize = workspace.CurrentCamera.ViewportSize
			local offset = adminMenu.Position - UDim2.fromScale(mouse.X/viewSize.X, mouse.Y/viewSize.Y)
			mouseController.setIcon("Move")
			newMove = mouse.Move:Connect(function()
				adminMenu.Position = UDim2.fromScale(mouse.X/viewSize.X, mouse.Y/viewSize.Y) + offset
			end)
			
			--Disconnect on mouse lift--
			discon = userIS.InputEnded:Connect(function(input)
				if input.UserInputType == Enum.UserInputType.MouseButton1 then
					mouseController.setIcon()
					newMove:Disconnect()
					discon:Disconnect()
				end
			end)
		end
	end)
	
	--Connect HelpMove--
	helpMove.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			local mouse = player:GetMouse()
			local viewSize = workspace.CurrentCamera.ViewportSize
			local offset = helpMenu.Position - UDim2.fromScale(mouse.X/viewSize.X, mouse.Y/viewSize.Y)
			mouseController.setIcon("Move")
			newMove = mouse.Move:Connect(function()
				helpMenu.Position = UDim2.fromScale(mouse.X/viewSize.X, mouse.Y/viewSize.Y) + offset
			end)

			--Disconnect on mouse lift--
			discon = userIS.InputEnded:Connect(function(input)
				if input.UserInputType == Enum.UserInputType.MouseButton1 then
					mouseController.setIcon()
					disconnectAll()
				end
			end)
		end
	end)
	
	--Connect Command Bar--
	commandBar.FocusLost:Connect(function(enterPressed)
		local toCommand = string.lower(commandBar.Text)
		local rank = player:WaitForChild("Rank").Value
		if COMMAND_LIST[toCommand] and rank <= REQUIRED_RANKS[toCommand] then
			clearBoxes()
			COMMAND_LIST[toCommand]()
			currentCommand = toCommand
		else
			print("Command "..toCommand.." failed.")
		end
	end)
	
	--Connect Cancel Button--
	cancel.Activated:Connect(function()
		clearBoxes()
	end)
	
	--Connect Execute Button--
	execute.Activated:Connect(function()
		if string.len(currentCommand) > 0 then
			if not CLIENT_COMMANDS[currentCommand] then
				adminEvent:FireServer(currentCommand, collectText())
			else
				CLIENT_COMMANDS[currentCommand]()
			end
		end
	end)
	
	--Connect AdminClose--
	adminClose.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			adminMenu.Visible = not adminMenu.Visible
			adminMenu.Position = MENU_CENTER
			clearBoxes()
		end
	end)
	
	--Connect HelpClose--
	helpClose.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			helpMenu.Visible = not helpMenu.Visible
			helpMenu.Position = HELP_POS
		end
	end)
	
	--Connect PosSelect--
	posSelect.Activated:Connect(function()
		local mouse = player:GetMouse()
		mouseController.setIcon("Circle")
		
		getPos = userIS.InputBegan:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 then
				currentPos = mouse.Hit.Position
				mouseController.click()
				mouseController.setIcon()
				getPos:Disconnect()
			end
		end)
	end)
end

--Reconnect all 
local function refreshAll()
	gui = player:WaitForChild("PlayerGui"):WaitForChild("ScreenGui")
	adminFolder = gui:WaitForChild("Admin")
	adminBtn = adminFolder:WaitForChild("AdminButton")
	adminMenu = adminFolder:WaitForChild("AdminMenu")
	nameBox = adminMenu:WaitForChild("NameBox")
	commandBar = adminMenu:WaitForChild("CommandBar")
	adminMove = adminMenu:WaitForChild("Move")
	pBox = adminMenu:WaitForChild("PrintBox")
	execute = adminMenu:WaitForChild("Execute")
	cancel = adminMenu:WaitForChild("Cancel")
	helpMenu = adminFolder:WaitForChild("HelpMenu")
	helpMove = helpMenu:WaitForChild("Move")
	helpClose = helpMenu:WaitForChild("Close")
	adminClose = adminMenu:WaitForChild("Close")
	helpName = helpMenu:WaitForChild("NameBox")
	posSelect = adminMenu:WaitForChild("PosSelect")
	
	--Initialize Boxes--
	boxes = {}
	for _, box in pairs(adminMenu:GetChildren()) do
		if string.sub(box.Name, 1, 3) == "Box" then
			boxes[tonumber(string.sub(box.Name, 4, 4))] = box
		end
	end
	
	adminBtn.Visible = true
	nameBox.Text = player.Name
	helpName.Text = player.Name
end

--Enable on respawn--
player.CharacterAdded:Connect(function(character)
	refreshAll()
	connectAll()
end)

refreshAll()
connectAll()