local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local MarketplaceService = game:GetService("MarketplaceService")
local Config = require(game:GetService("ReplicatedStorage"):WaitForChild("Shared"):WaitForChild("Config"))

local CheckpointController = {}
local UIManager = require(script.Parent.UIManager)
local Remotes = nil

local FALL_Y = -50
local currentCheckpoint = nil
local lastCheckpointPosition = nil
local isFalling = false
local fallConnection = nil

function CheckpointController.Init(networkRemotes)
	Remotes = networkRemotes
	
	local Gui = UIManager.GetGui()
	local Popup = Gui:WaitForChild("CheckpointPopup")
	
	Popup.YesBtn.MouseButton1Click:Connect(function()
		UIManager.TweenPanelOut(Popup, UDim2.new(0.5, -160, -0.5, 0))
		-- Start countdown 15s (simulated logic)
		task.delay(15, function()
			Remotes.TeleportToCheckpoint:FireServer()
			isFalling = false
		end)
	end)
	
	Popup.SkipBtn.MouseButton1Click:Connect(function()
		-- Prompt Skip Checkpoint
		MarketplaceService:PromptProductPurchase(Players.LocalPlayer, Config.Products.SkipCheckpoint)
		UIManager.TweenPanelOut(Popup, UDim2.new(0.5, -160, -0.5, 0))
		isFalling = false
	end)
	
	Popup.NoBtn.MouseButton1Click:Connect(function()
		UIManager.TweenPanelOut(Popup, UDim2.new(0.5, -160, -0.5, 0))
		isFalling = false
		-- Implement CP-1 Logic here if needed
	end)
	
	-- Setup Checkpoint Touch Events
	local CheckpointsFolder = Workspace:WaitForChild("Checkpoints", 10)
	if CheckpointsFolder then
		for _, cp in ipairs(CheckpointsFolder:GetChildren()) do
			if cp:IsA("BasePart") then
				cp.Touched:Connect(function(hit)
					local char = hit.Parent
					if char and char == Players.LocalPlayer.Character then
						if currentCheckpoint ~= cp.Name then
							currentCheckpoint = cp.Name
							lastCheckpointPosition = cp.Position
							Remotes.UpdateCheckpoint:FireServer(cp.Position)
							
							-- Show Notif
							local MainHUD = Gui:WaitForChild("MainHUD")
							local Notif = MainHUD:WaitForChild("CPNotif")
							UIManager.TweenPanelIn(Notif, UDim2.new(0.5, -125, 0, 50))
							task.delay(2, function() UIManager.TweenPanelOut(Notif, UDim2.new(0.5, -125, 0, -50)) end)
						end
					end
				end)
			end
		end
	end
	
	-- Fall Detection
	RunService.Heartbeat:Connect(function()
		local char = Players.LocalPlayer.Character
		if char then
			local root = char:FindFirstChild("HumanoidRootPart")
			if root and root.Position.Y < FALL_Y and not isFalling then
				isFalling = true
				root.Anchored = true -- Prevent further falling
				UIManager.TweenPanelIn(Popup, UDim2.new(0.5, -160, 0.5, -80))
			end
		end
	end)
end

return CheckpointController
