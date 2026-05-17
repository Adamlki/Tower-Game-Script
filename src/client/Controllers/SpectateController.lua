local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")

local SpectateController = {}
local UIManager = require(script.Parent.UIManager)

local spectating = false
local targetIndex = 1
local connection = nil

function SpectateController.Init()
	local PlayerGui = Players.LocalPlayer:WaitForChild("PlayerGui")
	local TrollGui = PlayerGui:WaitForChild("SelectTrollGui")
	local SpectateFrame = TrollGui:WaitForChild("SpectateFrame")
	local InnerFrame = SpectateFrame:WaitForChild("Frame")
	
	local PrevBtn = InnerFrame:WaitForChild("PrevBtn")
	local NextBtn = InnerFrame:WaitForChild("NextBtn")
	
	UIManager.ApplyButtonAnimation(PrevBtn)
	UIManager.ApplyButtonAnimation(NextBtn)
	
	PrevBtn.MouseButton1Click:Connect(function()
		SpectateController.ChangeTarget(-1)
	end)
	
	NextBtn.MouseButton1Click:Connect(function()
		SpectateController.ChangeTarget(1)
	end)
end

function SpectateController.Start()
	spectating = true
	SpectateController.ChangeTarget(0)
	
	connection = game:GetService("RunService").RenderStepped:Connect(function()
		local players = Players:GetPlayers()
		if #players == 0 then return end
		local target = players[targetIndex]
		if target and target.Character and target.Character:FindFirstChild("Humanoid") then
			Workspace.CurrentCamera.CameraSubject = target.Character.Humanoid
		end
	end)
end

function SpectateController.Stop()
	spectating = true
	spectating = false
	
	if connection then
		connection:Disconnect()
		connection = nil
	end
	
	local localPlayer = Players.LocalPlayer
	if localPlayer.Character and localPlayer.Character:FindFirstChild("Humanoid") then
		Workspace.CurrentCamera.CameraSubject = localPlayer.Character.Humanoid
	end
end

function SpectateController.ChangeTarget(dir)
	local players = Players:GetPlayers()
	if #players == 0 then return end
	
	targetIndex = targetIndex + dir
	if targetIndex > #players then
		targetIndex = 1
	elseif targetIndex < 1 then
		targetIndex = #players
	end
	
	local target = players[targetIndex]
	local PlayerGui = Players.LocalPlayer:WaitForChild("PlayerGui")
	local TrollGui = PlayerGui:WaitForChild("SelectTrollGui")
	local PlayerNameLabel = TrollGui:WaitForChild("SpectateFrame"):WaitForChild("Frame"):WaitForChild("PlayerNameLabel")
	PlayerNameLabel.Text = target.DisplayName
	
	-- Update Troll UI target if open
	local TrollController = require(script.Parent.TrollController)
	TrollController.SetSelectedTarget(target.UserId)
end

function SpectateController.IsSpectating()
	return spectating
end

function SpectateController.GetTarget()
	local players = Players:GetPlayers()
	if #players > 0 and targetIndex >= 1 and targetIndex <= #players then
		return players[targetIndex]
	end
	return nil
end

return SpectateController
