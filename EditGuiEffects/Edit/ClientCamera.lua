--Ashton
--1.30.22
--Camera Manipulator Client

--Objects--
local cameraMod = {}
local tweenService = game:GetService("TweenService")
local player = game.Players.LocalPlayer
local screen = script.Parent.Parent:WaitForChild("ScreenGui")
local fadeEffect = screen:WaitForChild("Fade")

--Variables

--Move Camera-- 
function cameraMod.MoveCamera(toCFrame, duration) 
	local cam = workspace.CurrentCamera
	duration = duration or 0
	toCFrame = toCFrame or CFrame.new(0,0,0)
	
	if duration > 0 then
		local tInfo = TweenInfo.new(duration,Enum.EasingStyle.Cubic,Enum.EasingDirection.Out)
		tweenService:Create(cam, tInfo, {CFrame = toCFrame}):Play()
	else
		cam.CFrame = toCFrame
	end
end

--Fade--
function cameraMod.Fade(inOut) --True for fade in, false for fade out
	local toTrans = inOut and 0 or 1
	local tInfo = TweenInfo.new(1,Enum.EasingStyle.Cubic,Enum.EasingDirection.Out)
	
	tweenService:Create(fadeEffect, tInfo, {Transparency = toTrans}):Play()
end

return cameraMod
