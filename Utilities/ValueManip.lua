--Value Manipulators Module Server
--Ashton
--10.1.22 -- 2.14.23

--Modules--
local valueManip = {}

--Objects--
local repStorage = game:GetService("ReplicatedStorage")
local classFolder = repStorage:WaitForChild("Classes")

--Variables--
local classArray = {}

--Set Up Classes--
for i, folder in pairs(classFolder:GetChildren()) do
	classArray[i] = folder
end

--Map Children to Hash--
function valueManip.MapChildrenToHash(obj)
	local newArray = {}
	
	for _, child in pairs(obj:GetChildren()) do
		newArray[child.Name] = child
	end
	
	return newArray
end

--Map Children Values to Hash--
function valueManip.MapChildrenValueToHash(obj)
	local newArray = {}
	
	for _, child in pairs(obj:GetChildren()) do
		newArray[child.Name] = child.Value
	end
	
	return newArray
end

--Get Children of Name--
function valueManip.GetChildrenOfName(obj, name)
	local newArray = {}
	
	for _, child in pairs(obj:GetChildren()) do
		if child.Name == name then
			newArray[#newArray+1] = child
		end
	end
	
	return newArray
end

--Remove child of Name--
function valueManip.RemoveChildOfName(obj, name)
	local part = obj:FindFirstChild(name)
	if part then
		part:Destroy()
	end
end

--Get Child without name--
function valueManip.GetChildWithoutName(obj, name)
	local toReturn
	
	for _, child in pairs(obj:GetChildren()) do
		if child.Name ~= name then
			return child
		end
	end
end

--Remove all in arr--
function valueManip.RemoveAll(arr)
	for _, obj in pairs(arr) do
		obj:Destroy()
	end
end

--Verify Class--
function valueManip.VerifyClass(name)
	for _, folder in pairs(classArray) do
		if name == folder.Name then
			return true
		end
	end
	
	return false
end

--Verify Color3 Array--
function valueManip.VerifyColor3Array(array)
	local isArray = typeof(array) == "table" and #array > 0
	local isColor = isArray and typeof(array[1]) == "Color3"
	return isColor and array
end

--Verify Number--
function valueManip.VerifyNumber(num)
	return typeof(num) == "number" and num
end

--Verify String--
function valueManip.VerifyString(text)
	return typeof(text) == "string" and text
end

--Verify Part--
function valueManip.VerifyPart(part)
	local isPart = typeof(part) == "Instance" and part:IsA("BasePart")
	return isPart and part
end

--Verify Player--
function valueManip.VerifyPlayer(player)
	local isPlayer = typeof(player) == "Instance" and player:IsA("Player")
	return isPlayer and player
end

--Verify Vector--
function valueManip.VerifyVector(vector)
	return type(vector) == "vector" and vector
end

--Vector To String--
function valueManip.VectorToString(vector)
	return "("..tostring(vector.X)..", "..tostring(vector.Y)..", "..tostring(vector.Z)..")"
end

--Check if String empty--
function valueManip.StringEmpty(text)
	return text == nil or text == ""
end

--Verify if valid textPacket--
function valueManip.VerifyForTextPacket(text)
	if not text then return end
	
	local i = string.find(text, "<")
	local l = string.len(text)
	
	while i and i < l-1 do
		wait(0.1)
		local x = string.find(string.sub(text, i+1, l), ">")
		if x then x = x + i + 1 end
		local x2 = x and string.find(string.sub(text, x+1, l), ">")
		if x2 then x2 = x2 + x + 1 end
		if not x2 then return false end
		
		i = x2+1
	end
	
	return text
end

--Convert part to world vector--
function valueManip.GetWorldVector(part)
	local abs = math.abs

	local cf = part.CFrame
	local size = part.Size
	local sx, sy, sz = size.X, size.Y, size.Z

	local x, y, z, R00, R01, R02, R10, R11, R12, R20, R21, R22 = cf:components() 

	local wsx = abs(R00) * sx + abs(R01) * sy + abs(R02) * sz
	local wsy = abs(R10) * sx + abs(R11) * sy + abs(R12) * sz
	local wsz = abs(R20) * sx + abs(R21) * sy + abs(R22) * sz

	return Vector3.new(wsx, wsy, wsz)
end

return valueManip