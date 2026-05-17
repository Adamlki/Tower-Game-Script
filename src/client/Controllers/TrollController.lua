local Players = game:GetService("Players")
local MarketplaceService = game:GetService("MarketplaceService")
local TweenService = game:GetService("TweenService")
local Config = require(game:GetService("ReplicatedStorage"):WaitForChild("Shared"):WaitForChild("Config"))

local TrollController = {}
local UIManager = require(script.Parent.UIManager)
local SpectateController = require(script.Parent.SpectateController)
local Remotes = nil

local selectedTargetId = nil
local panelOpen = false

function TrollController.Init(networkRemotes)
	Remotes = networkRemotes
	
	local Gui = UIManager.GetGui()
	local MainHUD = Gui:WaitForChild("MainHUD")
	local TrollBtn = MainHUD:WaitForChild("TrollBtn")
	local TrollPanel = Gui:WaitForChild("TrollPanel")
	local TrollButtons = TrollPanel:WaitForChild("TrollButtons")
	
	TrollBtn.MouseButton1Click:Connect(function()
		TrollController.TogglePanel()
	end)
	
	local currentPendingTroll = nil
	local TrollConfirmPopup = Gui:WaitForChild("TrollConfirmPopup")
	
	for _, btn in ipairs(TrollButtons:GetChildren()) do
		if btn:IsA("TextButton") then
			btn.MouseButton1Click:Connect(function()
				local trollType = btn.Name:gsub("Btn", "")
				local target = SpectateController.GetTarget()
				
				currentPendingTroll = trollType
				local label = TrollConfirmPopup:WaitForChild("Label")
				
				if trollType:match("All") then
					label.Text = "Are you sure you want to " .. trollType .. " everyone?"
				else
					local name = target and target.Name or "Unknown"
					label.Text = "Are you sure you want to " .. trollType .. " " .. name .. "?"
				end
				
				UIManager.TweenPanelIn(TrollConfirmPopup, UDim2.new(0.5, -160, 0.5, -80))
			end)
		end
	end
	
	TrollConfirmPopup.YesBtn.MouseButton1Click:Connect(function()
		if currentPendingTroll then
			local target = SpectateController.GetTarget()
			if target then
				TrollController.SetSelectedTarget(target.UserId)
			end
			TrollController.ExecuteTroll(currentPendingTroll)
			currentPendingTroll = nil
			UIManager.TweenPanelOut(TrollConfirmPopup, UDim2.new(0.5, -160, -0.5, 0))
		end
	end)
	
	TrollConfirmPopup.NoBtn.MouseButton1Click:Connect(function()
		currentPendingTroll = nil
		UIManager.TweenPanelOut(TrollConfirmPopup, UDim2.new(0.5, -160, -0.5, 0))
	end)
	
	-- Handle Jumpscare & Earthquake effects
	Remotes.TrollEffect.OnClientEvent:Connect(function(effectType)
		if effectType == "Jumpscare" then
			local PlayerGui = Players.LocalPlayer:WaitForChild("PlayerGui")
			local jsGui = PlayerGui:WaitForChild("JumpscareGui")
			local jsSound = jsGui:WaitForChild("JumpscareSound")
			
			jsGui.Enabled = true
			jsSound:Play()
			
			task.delay(1.5, function()
				jsGui.Enabled = false
				jsSound:Stop()
			end)
		elseif effectType == "Earthquake" then
			local cam = workspace.CurrentCamera
			local startTime = tick()
			local conn
			conn = game:GetService("RunService").RenderStepped:Connect(function()
				if tick() - startTime > 10 then
					conn:Disconnect()
					return
				end
				cam.CFrame = cam.CFrame * CFrame.new(math.random(-10,10)/10, math.random(-10,10)/10, math.random(-10,10)/10)
			end)
		end
	end)
end

function TrollController.SetSelectedTarget(userId)
	selectedTargetId = userId
end

function TrollController.TogglePanel()
	local Gui = UIManager.GetGui()
	local TrollPanel = Gui:WaitForChild("TrollPanel")
	
	panelOpen = not panelOpen
	
	if panelOpen then
		SpectateController.Start()
		UIManager.TweenPanelIn(TrollPanel, UDim2.new(1, -250, 0.5, -250))
	else
		SpectateController.Stop()
		UIManager.TweenPanelOut(TrollPanel, UDim2.new(1, 50, 0.5, -250))
	end
end



function TrollController.ExecuteTroll(trollType)
	if trollType ~= "KillAll" and trollType ~= "SlowAll" and not selectedTargetId then
		print("No target selected")
		return
	end
	
	local success, msg = Remotes.ExecuteTroll:InvokeServer(trollType, selectedTargetId)
	if not success and msg == "Prompting purchase" then
		local productId = Config.TrollProducts[trollType]
		if productId then
			MarketplaceService:PromptProductPurchase(Players.LocalPlayer, productId)
		end
	end
end

return TrollController
