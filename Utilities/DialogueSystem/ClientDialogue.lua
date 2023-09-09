--Client Dialogue Module
--Ashton
--11.13.22 -- 1.15.23

--Objects--
local dialogue = {}
local textService = game:GetService("TextService")
local tweenService = game:GetService("TweenService")
local player = game.Players.LocalPlayer
local gui = player:WaitForChild("PlayerGui"):WaitForChild("ScreenGui")
local dialogueFolder = gui:WaitForChild("Dialogue")
local posB = dialogueFolder:WaitForChild("Bottom")
local bTemplateRow = posB:WaitForChild("Row")
local bTemplateChar = posB:WaitForChild("Row1"):WaitForChild("Char")
local bRows = {}

--Variables--
local bText = {}
local numRows = 0
local heightDiff
local awayPos

--Constants--
local DEFAULT_MODS      = {Size = bTemplateChar.TextSize, Visible = true}
local FONT              = Enum.Font.Nunito
local TEXT_MOVE_TIME    = 0.3
local TEXT_INFO         = TweenInfo.new(TEXT_MOVE_TIME, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out)
local IN_INFO           = TweenInfo.new(TEXT_MOVE_TIME, Enum.EasingStyle.Cubic, Enum.EasingDirection.In)
local OUT_TRANSPARENCY  = {TextTransparency = 1}
local IN_TRANSPARENCY   = {TextTransparency = 0}
local DEFAULT_TEXT_TIME = 7
local HEIGHT_SQUEEZE    = 0.9

--Update Text Size--
bTemplateChar:GetPropertyChangedSignal("TextSize"):Connect(function()
	DEFAULT_MODS["Size"] = bTemplateChar.TextSize
end)

--Populate Rows Array--
for i = 1, #posB:GetChildren()-1 do
	bRows[i] = posB:WaitForChild("Row"..tostring(i))
end
heightDiff = bRows[2].Position - bRows[1].Position
awayPos = bRows[#bRows].Position + heightDiff

--Merge HashMap--
local function mergeHash(hash1, hash2)
	local resultant = {}
	
	for key, value in pairs(hash2) do
		if not hash1[key] then
			resultant[key] = value
		else
			resultant[key] = hash1[key]
		end
	end
	
	return resultant
end

--Calc String Length-- [ Returns in scale if [ parent ] is provided, else returns in offset ]
local function calcStringLength(text, fontSize, parent)
	local size = textService:GetTextSize(text, fontSize, FONT, Vector2.new(100000, 100000)).X
	
	return parent and size/parent.AbsoluteSize.X or size
end

--Calc XStart--
local function calcXStart(totalSize, parent, just)
	if just == "CENTER" then
		return (parent.AbsoluteSize.X - totalSize)/2
	elseif just == "LEFT" then
		return 0
	else
		return parent.AbsoluteSize.X - totalSize
	end
end

--Calc Char Pos Size Array--
local function calcCharPosSizeArray(textArray, modArray, parent, just)
	just = just or "CENTER"
	local charPosArrays = {}
	local charSizeArrays = {}
	local totalSize = 0
	local totalStrings = {}
	
	--Construct strings
	for x, array in pairs(textArray) do
		totalStrings[x] = ""
		local numWords = #array
		
		for y, word in pairs(array) do
			local space = y < numWords and " " or ""
			totalStrings[x] = totalStrings[x]..word..space
		end
	end
	
	--Calc Total Length--
	for i, text in pairs(totalStrings) do
		totalSize = totalSize + calcStringLength(text, modArray[i]["Size"])
	end
	
	local xStart = calcXStart(totalSize, parent, just)
	
	local currentLetter = 1
	local nextOffset = 0
	for x, text in pairs(totalStrings) do
		charPosArrays[x] = {}
		charSizeArrays[x] = {}
		for i = 1, string.len(text) do
			if currentLetter == 1 then
				charPosArrays[x][i] = xStart
				
				currentLetter = currentLetter + 1
			else
				local iPos
				if i == 1 then
					iPos = charPosArrays[x-1][#charPosArrays[x-1]]
				else
					iPos = charPosArrays[x][i-1]
				end
				charPosArrays[x][i] = iPos + nextOffset
			end
			
			nextOffset = calcStringLength(string.sub(text, i, i), modArray[x]["Size"])
			charSizeArrays[x][i] = nextOffset
		end
	end
	
	return charPosArrays, charSizeArrays
end

--local function split string into word array--
local function divByWords(text)
	local wordArray = {}
	
	for word in text:gmatch("%S+") do 
		wordArray[#wordArray + 1] = word
	end
	
	return wordArray
end

--Split into seperate arrays--
local function divByRows(textBlocks, mods)
	local textArrays = {}
	local modArrays = {}
	local splitText = {}
	local maxSize = bTemplateRow.AbsoluteSize.X
	local currentBlock = 1
	local currentLength = 0
	local currentWord = 1
	local currentRow = 1
	local blockRowNum = 1
	for i, textBlock in pairs(textBlocks) do
		splitText[i] = divByWords(textBlock)
	end
	
	textArrays[1] = {}
	modArrays[1] = {}
	while currentBlock <= #splitText do
		textArrays[currentRow][blockRowNum] = {}
		modArrays[currentRow][blockRowNum] = mods[currentBlock]
		
		for i, word in pairs(splitText[currentBlock]) do
			local wordLength = calcStringLength(word, mods[currentBlock]["Size"])
			if currentLength + wordLength <= maxSize then
				currentLength = currentLength + wordLength
				textArrays[currentRow][blockRowNum][currentWord] = word
			else
				currentRow = currentRow + 1
				blockRowNum = 1
				currentWord = 1
				textArrays[currentRow] = {}
				modArrays[currentRow] = {}
				modArrays[currentRow][blockRowNum] = mods[currentBlock]
				textArrays[currentRow][blockRowNum] = {word}
				if wordLength > maxSize then return end -- Oopsie!! ;)
				
				currentLength = wordLength
			end
			
			currentWord = currentWord + 1
		end
		
		currentBlock = currentBlock + 1
		blockRowNum = blockRowNum + 1
	end
	
	return textArrays, modArrays
end

--Convert array of words to string--
local function arrayToString(textArray)
	local text = ""
	
	for i, word in pairs(textArray) do
		text = i < #textArray and text..word.." " or text..word
	end
	
	return text
end

--Tween Children--
local function tweenChildren(parent, info, props)
	local tweens = {}
	
	for _, child in pairs(parent:GetChildren()) do
		if child:IsA("TextLabel") then
			local tween = tweenService:Create(child, info, props)
			tween:Play()
			
			tweens[#tweens+1] = tween
		end
	end
	
	return tweens
end

--Tween Rows' Children--
local function tweenAllChildren(parents, info, props)
	local tweens = {}
	
	for x, row in pairs(parents) do
		tweens[x] = tweenChildren(row, info, props)
	end
	
	return tweens
end

--Place Char--
local function placeChar(letter, modPacket, blockSize, blockPos, num, parent)
	local size = modPacket["Size"]
	local vis = modPacket["Visible"]
	
	local newChar = bTemplateChar:Clone()
	newChar.Parent = parent
	newChar.Name = tostring(num)
	newChar.Size = UDim2.fromScale(blockSize/parent.AbsoluteSize.X, 1)
	newChar.TextSize = size
	newChar.Visible = vis
	newChar.Position = UDim2.fromScale(blockPos/parent.AbsoluteSize.X, 0.5)
	newChar.Text = letter
	
	--Set Props
	for prop, value in pairs(modPacket) do
		if prop == "Color" then
			newChar.TextColor3 = value
		elseif prop == "Transparency" then
			newChar.TextTransparency = value
		end
	end
	
	return newChar
end

--Remove Object--
local function remove(obj, delayTime, tweenOut)
	coroutine.wrap(function()
		if delayTime then
			wait(delayTime)
		end
		
		if tweenOut then
			tweenChildren(obj, TEXT_INFO, OUT_TRANSPARENCY)
			wait(TEXT_MOVE_TIME)
		end
		
		if obj then obj:Destroy() end
	end)()
end

--Tween Row--
local function tweenRow(row, toPos, away)
	local props = {Position = toPos}
	
	local tween = tweenService:Create(row, TEXT_INFO, props)
	tween:Play()
	
	if away then
		remove(row, false, true)
	end
	
	return tween
end

--Remove Rows--
local function removeRows(num) -- num: [ Removes [ num ] rows starting from last row ]
	for i = numRows, numRows - num + 1, -1 do
		if bText[i] then
			tweenRow(bText[i], awayPos, true)
			bText[i] = nil
			numRows = numRows - 1
		end
	end
end

--Move Rows--
local function moveRows(num) -- num: [ moves all rows [ num ] rows up ]
	assert(bRows[numRows + num], "Moving rows out of bounds at index "..tostring(numRows+num))

	for i = numRows, 1, -1 do
		bText[i+num] = bText[i]
		bText[i] = nil
		
		tweenRow(bText[i+num], bRows[i+num].Position)
	end
end

--Clear Rows--
local function clearRows(num) -- num: [ removes the last [ num ] rows and moves all other rows [ num ] rows up ] 
	if #bRows - numRows < num then
		removeRows(num - (#bRows - numRows))
	end
	
	moveRows(num)
end

--Create Row--
local function createRows(num) -- num: [ creates [ num ] rows starting at index 1 ]
	clearRows(num)
	
	local newRows = {}
	for i = 1, num do
		local newRow = bTemplateRow:Clone()
		newRow.Parent = posB
		newRow.Name = "TextRow"
		newRow.Position = bRows[i].Position
		bText[i] = newRow
		newRows[#newRows + 1] = newRow
		
		numRows = numRows + 1
	end
	
	return newRows
end

--Populate Row--
local function populate(textArray, modArray, parent, just)
	local finalArray = {}
	local charPosArray, charSizeArray = calcCharPosSizeArray(textArray, modArray, parent, just)
	local currentLetter = 1

	for x, array in pairs(textArray) do
		local text = arrayToString(array)
		local modPacket = modArray[x]
		local maxLetters = string.len(text)
		for i = 1, maxLetters do
			local letter = string.sub(text, i, i)
			if letter == " " then
				finalArray[i] = "Space"
			else
				finalArray[i] = placeChar(letter, modPacket, charSizeArray[x][i], charPosArray[x][i], i, parent)
			end
			
			currentLetter = currentLetter + 1
		end
	end

	return finalArray
end

--Spawn Text--
function dialogue.Create(textPacket, just)
	just = just or "CENTER"
	local textBlocks = textPacket["textBlocks"]
	local modBlocks = {}
	local blocks = textPacket["modBlocks"] do
		for i = 1, #blocks do
			modBlocks[i] = mergeHash(blocks[i], DEFAULT_MODS)
		end
	end

	local splitText, splitMods = divByRows(textBlocks, modBlocks)
	local numRows = #splitText
	if numRows < 1 then return end
	if numRows > #bRows then numRows = #bRows end
	local newRows = createRows(numRows)
	
	for i, row in pairs(newRows) do
		local nRow = math.abs(i-#newRows)+1
		populate(splitText[nRow], splitMods[nRow], row, just)
		remove(row, DEFAULT_TEXT_TIME, true)
	end
	
	tweenAllChildren(newRows, IN_INFO, IN_TRANSPARENCY)
end

return dialogue
