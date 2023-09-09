--Server TextPacket Class
--Ashton
--1.6.23 -- 1.15.23

--Objects--
local TextPacket = {}
TextPacket.__index = TextPacket
local messageEvent = game:GetService("ReplicatedStorage"):WaitForChild("Events"):WaitForChild("Message")

--Constants--
local DEFAULT_MOD_BLOCK = {}

--Create Modifier Block--
local function createModBlock(modText)
	local l = string.len(modText)
	local commaIndex = string.find(modText, ",")
	local modIndex = commaIndex and commaIndex-1 or l
	local modifier = string.sub(modText, 1, modIndex)
	
	local params = {}
	local x = modIndex
	local i = x ~= l and x+2
	if i and i < l then
		local numParams = select(2, string.gsub(modText, ",", ""))
		while i and i < l do
			commaIndex = string.find(string.sub(modText, i, l), ",")
			x = commaIndex and commaIndex - 1 or l
			
			if numParams > 1 then
				params[#params+1] = string.sub(modText, i, x)
			else
				params = string.sub(modText, i, x)
			end
			
			i = x + 2
		end
	end
	
	return modifier, params
end

--Create Modifier Block Array--
local function modBlockHash(modText)
	local modBlocks = {}
	
	local l = string.len(modText)
	local i = 1
	while i and i < l-1 do
		local semiIndex = string.find(string.sub(modText, i, l), ";")
		local x = semiIndex and semiIndex-1 or l
		local modifier, params = createModBlock(string.sub(modText, i, x))
		modBlocks[modifier] = params
		
		i = x + 2
	end
	
	return modBlocks
end

--Send text to one client--
function TextPacket.SendTo(player, text)
	messageEvent:FireClient(player, TextPacket.new(text))
end

--Send Text to All Clients--
function TextPacket.SendToAll(text)
	messageEvent:FireAllClients(TextPacket.new(text))
end

--Break into text blocks--
function TextPacket.Break(text)
	local textBlocks, modifierBlocks = {}, {}
	
	local l = string.len(text)
	local i = string.find(text, "<")
	if i then
		while i and i < l-1 do
			wait(0.1)
			local x = string.find(string.sub(text, i, l), ">")
			if not x then
				return
			else
				x = x + i - 1
			end
			local modText = string.sub(text, i+1, x-1)
			modifierBlocks[#modifierBlocks + 1] = modBlockHash(modText)
			
			i = x+1
			x = string.find(string.sub(text, i, l), ">")
			if not x then return end
			x = x + i
			textBlocks[#textBlocks+1] = string.sub(text, i, x-2)
			if x < l then
				i = string.find(string.sub(text, x, l), "<")
				if i then i = i + x - 1 end
			else
				i = nil
			end
		end
	else
		textBlocks = {text}
		modifierBlocks = {DEFAULT_MOD_BLOCK}
	end
	
	return textBlocks, modifierBlocks
end

--Constructor--
function TextPacket.new(text)
	local tBlocks, mBlocks = TextPacket.Break(text)
	
	local self = setmetatable({
		textBlocks = tBlocks;
		modBlocks = mBlocks;
	}, TextPacket)
	
	return self
end

--Add Text--
function TextPacket:AddText(text)
	local tBlocks, mBlocks = TextPacket.Break(text)
	
	for i, block in pairs(tBlocks) do
		self.textBlocks[#self.textBlocks + 1] = block
		self.modBlocks[#self.modBlocks + 1] = mBlocks[i]
	end
end

--Get Text--
function TextPacket:GetText()
	return self.textBlocks
end

--Get Modifiers--
function TextPacket:GetMods()
	return self.modBlocks
end

return TextPacket