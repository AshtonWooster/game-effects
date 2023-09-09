--Ashton
--1.31.22
--Character Edit Module Client

--Objects--
local charEdit = {}
local uInput = game:GetService("UserInputService")
local player = game.Players.LocalPlayer

--Variables--

--Constants--
local MAX_DIF_X   = 0.1
local MAX_DIF_Y   = 0.3
local ROTATE_SENS = 350

--Rotate model--
function charEdit.RotateModel(model) -- iPos must be normalized, model is a model
	local mouse = player:GetMouse()
	if math.abs(mouse.X/mouse.ViewSizeX - 0.5) < MAX_DIF_X and math.abs(mouse.Y/mouse.ViewSizeY - 0.5) < MAX_DIF_Y then -- if around the weapon
		local iPos = Vector2.new(mouse.X, mouse.Y)/Vector2.new(mouse.ViewSizeX, mouse.ViewSizeY)
		
		local moveFunction
		moveFunction = mouse.Move:Connect(function()
			local nPos =  Vector2.new(mouse.X,mouse.Y)/Vector2.new(mouse.ViewSizeX,mouse.ViewSizeY) --Offset / max size
			local rX = (iPos.X - nPos.X)*ROTATE_SENS
			local rY = (iPos.Y - nPos.Y)*ROTATE_SENS
			
			model:SetPrimaryPartCFrame(model.PrimaryPart.CFrame*CFrame.Angles(math.rad(rX),math.rad(rY),0))
			iPos = nPos
		end)
		
		local disconnectFunction
		disconnectFunction = uInput.InputEnded:Connect(function()
			moveFunction:Disconnect()
			disconnectFunction:Disconnect()
		end)
	end
end

return charEdit
