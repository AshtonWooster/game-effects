--Main Table Script
--Ashton
--7.18.23 -- 8.4.23

--Objects--
local repStorage = game:GetService("ReplicatedStorage")
local important = repStorage:WaitForChild("Important")
local lobbyFolder = repStorage:WaitForChild("Lobby")
local stool = lobbyFolder:WaitForChild("Stool")
local events = repStorage:WaitForChild("Events")
local leaveEvent = events:WaitForChild("Leave")
local chooseEvent = events:WaitForChild("ChooseGame")
local chairFolder = script.Parent:WaitForChild("Chairs")
local tBase = script.Parent.PrimaryPart
local clock = script.Parent:WaitForChild("TimerBlock")
local clockTime = script.Parent:WaitForChild("Clock")
local tweenService = game:GetService("TweenService")

--Variables--
local riseInfo = TweenInfo.new(4, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, 0, true, 0)
local spinInfo = TweenInfo.new(4, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, 1, false, 0)
local maxPlayers = important:WaitForChild("MaxPlayers").Value
local clockOn = false
local runningTimers = 0
local runningSpinners = 0
local currentPlayers = {} -- {Player = plr_name, Seat = current_seat, Idle = idle_anim}
local anims = {
	SeatedIdle = "rbxassetid://14271517619"
}

--Spin Timer Block--
local function timerSpin()
	if runningSpinners > 0 then return end
	
	coroutine.wrap(function()
		runningSpinners = runningSpinners + 1
		while true do
			tweenService:Create(clock, spinInfo, {Orientation = clock.Orientation + Vector3.new(0, 180, 0)}):Play()
			tweenService:Create(clock, riseInfo, {Position = clock.Position + Vector3.new(0,1,0)}):Play()
			wait(8)
			if not clockOn then
				runningSpinners = runningSpinners - 1
				return 
			end
		end
	end)()
end

--Count down timer--
local function timerCount()
	if runningTimers > 0 then return end
	
	coroutine.wrap(function()
		runningTimers = runningTimers + 1
		while true do
			local currentTime = clockTime.Value
			if currentTime > 0 then
				clockTime.Value = currentTime - 1
			else
				--Stop
			end
			wait(1)
			if not clockOn then
				runningTimers = runningTimers - 1
				return
			end
		end
	end)()
end

--Constants--
local CHAIR_RADIUS = 7

--Set up timer guis--
local guiTimers = {}
for _, face in pairs(clock:GetChildren()) do
	table.insert(guiTimers, face:WaitForChild("Timer"))
end
clockTime.Changed:Connect(function(val)
	for _, face in pairs(guiTimers) do
		face.Text = tostring(val)
	end
end)

--Turn on/off timer--
local function timer(val, duration)
	duration = duration or 0
	clockTime.Value = duration
	for _, face in pairs(guiTimers) do
		face.Visible = val
		face.Text = tostring(duration)
	end
	
	clockOn = val
	if val then
		timerCount()
		timerSpin()
	end
end

--Play Animation--
local function playAnim(player, anim, looped)
	local character = player.Character
	assert(character, player.Name.." is hacking...")
	local humanoid = character.Humanoid
	local animator = humanoid:FindFirstChildOfClass("Animator")
	if not animator then
		animator = Instance.new("Animator")
		animator.Parent = humanoid
	end
	
	local animation = Instance.new("Animation")
	animation.AnimationId = anims[anim]

	local animTrack = animator:LoadAnimation(animation)
	animTrack.Looped = looped and true or false

	animTrack:Play()
	
	return animTrack
end

--Find player obj--
local function find(player)
	for i, obj in pairs(currentPlayers) do
		if obj["Player"] == player then
			return obj, i
		end
	end
end

--Remove player obj--
local function remove(player)
	local plrObj, index = find(player)
	table.remove(currentPlayers, index)
end

--Add player obj--
local function add(player, seat)
	local newObj = {
		Player = player,
		Seat = seat,
		Idle = nil,
	}
	
	table.insert(currentPlayers, newObj)
end

--Lock Player--
local function lock(player)
	local character = player.Character
	assert(character, player.Name.." is hacking...")
	local humanoid = character.Humanoid
	
	humanoid.AutoRotate = false
	humanoid.WalkSpeed = 0
	humanoid.JumpHeight = 0
end

--Unlock Player--
local function unlock(player)
	local character = player.Character
	assert(character, player.Name.." is hacking...")
	local humanoid = character.Humanoid
	
	humanoid.AutoRotate = true
	humanoid.WalkSpeed = 16
	humanoid.JumpHeight = 7.2
end

--Wipe player--
local function wipePlayer(player)
	local playerObj = find(player)
	local playingTag = player:FindFirstChild("Playing")
	
	if playerObj then
		playerObj["Seat"].Occupant.Value = nil
	end
	
	if playingTag then
		playingTag.Value = false
	end
	
	remove(player)
end

--Set Player Pos--
local function aboveSeat(player, seat)
	local character = player.Character
	local surface = seat.Seat
	assert(character, player.Name.." is hacking...")
	
	character:PivotTo(CFrame.new(surface.Position+Vector3.new(0,surface.Size.Y/2+3,0), tBase.Position))
end

--Find player's chair--
local function findStool(player)
	for _, chair in pairs(chairFolder:GetChildren()) do
		if chair.Occupant.Value == player then return chair end
	end
end

--Offer game Choice--
local function chooseGame(player)
	
end

--Unseat player--
local function unseatPlayer(player)
	local obj = find(player)
	local seat = obj["Seat"]
	if seat then
		player.Playing.Value = false
		seat.Occupant.Value = nil
		obj["Idle"]:Stop()
		obj["Idle"]:Destroy()
		remove(player)
		unlock(player)
		leaveEvent:FireClient(player, false)
	end
end

--Seat player--
local function seatPlayer(player, seat)
	local pValue = seat.Occupant
	local character = player.Character
	assert(character, player.Name.." might be hacking.")
	
	pValue.Value = player
	player.Playing.Value = true
	add(player, seat)
	leaveEvent:FireClient(player, true)
	aboveSeat(player, seat)
	lock(player)
	find(player)["Idle"] = playAnim(player, "SeatedIdle", true)
	
	local removeOnDeath
	removeOnDeath = character:FindFirstChildOfClass("Humanoid").Died:Connect(function()
		wipePlayer(player)
		removeOnDeath:Disconnect()
	end)
	
	if #currentPlayers == 1 then
		print("Choose game")
	end
end

--Change Seats--
local function changeSeat(player, seat)
	local obj = find(player)
	local cSeat = obj["Seat"]
	local pValue = seat.Occupant
	
	if cSeat then
		cSeat.Occupant.Value = nil
	end
	
	seat.Occupant.Value = player
	obj["Seat"] = seat
	aboveSeat(player, seat)
end

--Check if already on other table--
local function checkPlayer(player)
	return not player:WaitForChild("Playing").Value or find(player)
end

--Place all Stools--
for i=1, maxPlayers do
	local newStool = stool:Clone()
	local pValue = newStool:WaitForChild("Occupant")
	local clickDetect = newStool:WaitForChild("Seat"):WaitForChild("ClickDetector")
	newStool.Parent = chairFolder
	
	local angle = (2*math.pi/maxPlayers)*i
	local xOff = math.cos(angle)*CHAIR_RADIUS
	local zOff = math.sin(angle)*CHAIR_RADIUS
	local yOff = newStool.PrimaryPart.Size.Y - tBase.Size.X/2
	local toPos = tBase.Position + Vector3.new(xOff, yOff, zOff) 
	local lookPos = tBase.Position + Vector3.new(0, yOff, 0)
	
	newStool:PivotTo(CFrame.new(toPos, lookPos))
	
	--Connect click detectors
	clickDetect.MouseClick:Connect(function(player)
		if not pValue.Value and checkPlayer(player) then
			--If player already occupies a seat, remove their previous seat
			if find(player) and pValue.Value ~= player then
				changeSeat(player, newStool)
			else
				seatPlayer(player, newStool)
			end
		end
	end)
end

--Leave Table--
leaveEvent.OnServerEvent:Connect(function(player)
	if find(player) then
		unseatPlayer(player)
	end
end)

--Remove players on leave--
game.Players.PlayerRemoving:Connect(wipePlayer)