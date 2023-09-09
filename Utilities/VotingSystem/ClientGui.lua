local classFrame = script.Parent:WaitForChild("Classes")
local replicatedStorage = game:GetService("ReplicatedStorage")
local button = script.Parent:WaitForChild("ClassSelect")
local selector = classFrame:WaitForChild("ClassButton")
local clickSound = script:WaitForChild("Click")
local player = game.Players.LocalPlayer
local moves = script.Parent:WaitForChild("Moves")
local pClass = player:WaitForChild("Class")
local uIP = game:GetService("UserInputService")
local tweenService = game:GetService("TweenService")
local display = script.Parent:WaitForChild("Display")
local gameStatus = workspace:WaitForChild("GameStatus")
local timer = workspace:WaitForChild("Time")
local currentMode = workspace:WaitForChild("CurrentMode")
local mapVote = script.Parent:WaitForChild("MapVote")
local voteEvent = replicatedStorage:WaitForChild("Vote")
local changeClass = replicatedStorage:WaitForChild("ChangeClass")
local votesFolder = replicatedStorage:WaitForChild("Votes")
local awakeningBar = script.Parent:WaitForChild("Awakening"):WaitForChild("Bar")
local lT = script.Parent:WaitForChild("LT")
local canAttack = player:WaitForChild("CanAttack")
local pLives = player:WaitForChild("Lives")
local VOTE_TIME = 20

local function click()
	local sound = clickSound:Clone()
	sound.Parent = script
	sound.PlaybackSpeed = clickSound.PlaybackSpeed+math.random(-2,0)*0.01
	sound:Play()
	sound.Ended:Wait()
	sound:Destroy()
end

if gameStatus.Value == 3 then
	mapVote.Visible = true
end
for i=1,3 do
	if gameStatus.Value == 3 then
	local cMap = votesFolder:WaitForChild("Map"..i).Value
		mapVote:WaitForChild("Label"..i).Text=cMap.Name
		mapVote:WaitForChild("Map"..i).Image=cMap:WaitForChild("Image").Value
	end
	mapVote:WaitForChild("Map"..i):WaitForChild("NumVotes").Text = votesFolder:WaitForChild(i).Value 
	votesFolder:WaitForChild(i).Changed:Connect(function(value)
		mapVote:WaitForChild("Map"..i):WaitForChild("NumVotes").Text=value
	end)
end

local moveTags = {}
for i,gui in pairs(moves:GetChildren()) do
	if not gui:IsA("UIAspectRatioConstraint") then
		table.insert(moveTags,i,gui)
	end 
end

local classes = {
	{Name="Lancer",Moves={"Kotsa","Runnak","B","C"},Cooldowns={1,5,5,6}},
}

local colors = {
	Color3.fromRGB(2, 255, 255),
}

for y=1,math.ceil(#classes/10) do
	for i=1,10 do
		local index = (y-1)*10+i
		if classes[index] then
			local newBox = selector:Clone()
			newBox.Parent = classFrame
			newBox.Name = classes[index]["Name"]
			newBox.Text = classes[index]["Name"]
			newBox.BackgroundColor3 = colors[index]
			newBox.Visible = true
			newBox.Position = UDim2.new(0.05+(i-1)*0.1,0,0.125+0.249*(y-1),0)
			newBox.Activated:Connect(function()
				changeClass:FireServer(index)
				click()
			end)
		end
	end
end

button.Activated:Connect(function()
	if not player.IsIn.Value then
		click()
		classFrame.Visible = not classFrame.Visible
	end
end)

if classes[pClass.Value] then
	for i,tag in ipairs(moveTags) do
		tag.BackgroundColor3 = colors[pClass.Value]
		tag.Text = classes[pClass.Value]["Moves"][i]
		awakeningBar.BackgroundColor3 = colors[pClass.Value]
	end
end

pClass.Changed:Connect(function(value)
	if classes[value] then
		for i,tag in ipairs(moveTags) do
			tag.BackgroundColor3 = colors[value]
			tag.Text = classes[value]["Moves"][i]
			awakeningBar.BackgroundColor3 = colors[value]
		end
	end
end)

local dimProp = {Size = UDim2.new(1,0,0,1)}
local canUse={true,true,true,true}
uIP.InputBegan:Connect(function(input)
	local toUse = 0
	if input.KeyCode == Enum.KeyCode.One then
		toUse=1
	elseif input.KeyCode == Enum.KeyCode.Two then
		toUse=2
	elseif input.KeyCode == Enum.KeyCode.Three then
		toUse=3
	elseif input.KeyCode == Enum.KeyCode.Four then
		toUse=4
	end
	if toUse>0 and toUse<5 and canUse[toUse] and pClass.Value>0 and player.IsIn.Value and player.CanAttack.Value and not player.Stunned.Value then
		canUse[toUse] = false
		local tweenInfo = TweenInfo.new(classes[pClass.Value]["Cooldowns"][toUse],Enum.EasingStyle.Linear)
		local dim = moveTags[toUse]:WaitForChild("Dim")
		dim.Visible = true
		dim.Size = UDim2.new(1,0,1,0)
		tweenService:Create(dim,tweenInfo,dimProp):Play()
		wait(classes[pClass.Value]["Cooldowns"][toUse])
		dim.Visible = false
		canUse[toUse]=true
	end
end)

local displayInfo = TweenInfo.new(0.3,Enum.EasingStyle.Cubic,Enum.EasingDirection.Out)
local inTween = tweenService:Create(display,displayInfo,{Size = UDim2.new(0.377,0,0.132,0)})
local outTween = tweenService:Create(display,displayInfo,{Size = UDim2.new(0,1,0.132,0)})
local texts = {
"There are not enough players to start a game",
"Intermission",
"Game is starting in "..VOTE_TIME.." seconds",
"Game is starting"
}
gameStatus.Changed:Connect(function(value)
	if texts[value] then
		display.Visible = true
		display.Size = UDim2.new(0,1,0.132,0)
		inTween:Play()
		display.Text = ""
		if value==3 then
			for i=1,3 do
				local cMap = votesFolder:WaitForChild("Map"..i).Value
				mapVote:WaitForChild("Label"..i).Text=cMap.Name
				mapVote:WaitForChild("Map"..i).Image=cMap:WaitForChild("Image").Value
			end
			mapVote.Visible = true
			local timerStart = coroutine.wrap(function()
				for i=VOTE_TIME,1,-1 do
					if gameStatus.Value == 3 then
						mapVote:WaitForChild("Time").Text=i
						wait(1)
					end
				end
			end)
			timerStart()
		elseif value == 4 or value == 1 then
			mapVote.Visible = false
		end
		wait(0.4)
		for i = 1,#texts[value] do
			if gameStatus.Value == value then
				display.Text = display.Text..texts[value]:sub(i,i)
			else
				break
			end
			wait()
		end
		wait(1+#texts[value]*0.03)
		if gameStatus.Value == value then
			display.Text = ""
			outTween:Play()
			wait(0.3)
			if gameStatus.Value == value then
				display.Visible = false
			end
		end
	end
end)

for i,voter in pairs(mapVote:GetChildren()) do
	if voter:IsA("ImageButton") then
		voter.Activated:Connect(function()
			click()
			voteEvent:FireServer(1,tonumber(voter.Name:sub(4,4)))
		end)
	elseif voter:IsA("TextButton") and #voter.Name==1 then
		voter.Activated:Connect(function()
			click()
			voteEvent:FireServer(2,tonumber(voter.Name))
		end)
	elseif voter:IsA("TextButton") and voter.Name:sub(1,1)=="M" then
		voter.Activated:Connect(function()
			click()
			voteEvent:FireServer(3,tonumber(voter.Name:sub(5,5)))
		end)
	elseif voter:IsA("TextButton") then
		voter.Activated:Connect(function()
			click()
			mapVote.Visible = false
		end)
	
	end
end

if player:WaitForChild("IsIn").Value then
	button.Visible = false
	classFrame.Visible = false
	awakeningBar.Parent.Visible = true
	moves.Visible = true
else
	moves.Visible = false
	awakeningBar.Parent.Visible = false
	button.Visible = true
end

player.IsIn.Changed:Connect(function(value)
	if value then
		button.Visible = false
		classFrame.Visible = false
		awakeningBar.Parent.Visible = true
		moves.Visible = true
		if currentMode.Value == 1 then
			lT.Text = "Lives "..pLives.Value.." : "..timer.Value
		else
			lT.Text = timer.Value
		end
	else
		moves.Visible = false
		awakeningBar.Parent.Visible = false
		button.Visible = true
		if pLives.Value > 0 and currentMode.Value == 1 then
			lT.Text = "Lives "..pLives.Value.." : "..timer.Value
		else
			if gameStatus.Value == 4 then
				lT.Text = timer.Value
			end	
		end
	end
end)

timer.Changed:Connect(function(value)
	if pLives.Value > 0 and currentMode.Value == 1 then
		lT.Text = "Lives "..pLives.Value.." : "..timer.Value
	else
		if gameStatus.Value == 4 then
			lT.Text = timer.Value
		end	
	end
end)

pLives.Changed:Connect(function(value)
	if pLives.Value > 0 and currentMode.Value == 1 then
		lT.Text = "Lives "..pLives.Value.." : "..timer.Value
	else
		lT.Text = timer.Value
	end
end)