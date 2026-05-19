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
	
	local PlayerGui = Players.LocalPlayer:WaitForChild("PlayerGui")
	
	-- Menu Utama (Troll Button)
	local MenuUtama = PlayerGui:WaitForChild("MenuUtama",10)
	local TrollBtn = MenuUtama:WaitForChild("MainFrame"):WaitForChild("TrollBtn")
	
	-- Select Troll Gui
	local TrollGui = PlayerGui:WaitForChild("SelectTrollGui")
	local TrollMainFrame = TrollGui:WaitForChild("TrollMainFrame")
	local CloseBtn = TrollMainFrame:WaitForChild("CloseBtn")
	
	UIManager.ApplyButtonAnimation(TrollBtn)
	UIManager.ApplyButtonAnimation(CloseBtn)
	UIManager.ApplyShakeEffect(TrollBtn:WaitForChild("ImageLabel"))
	
	TrollBtn.MouseButton1Click:Connect(function()
		TrollController.TogglePanel()
	end)
	
	CloseBtn.MouseButton1Click:Connect(function()
		if panelOpen then
			TrollController.TogglePanel()
		end
	end)
	
	local currentPendingTroll = nil
	local ConfirmationFrame = TrollGui:WaitForChild("ConfirmationFrame")
	local ConfirmMainFrame = ConfirmationFrame:WaitForChild("MainFrame")
	local ConfirmLabel = ConfirmMainFrame:WaitForChild("TextLabel")
	local ConfirmYesBtn = ConfirmMainFrame:WaitForChild("FrameBtn"):WaitForChild("YesBtn")
	local ConfirmCloseBtn = ConfirmMainFrame:WaitForChild("FrameBtn"):WaitForChild("CloseBtn")
	
	UIManager.ApplyButtonAnimation(ConfirmYesBtn)
	UIManager.ApplyButtonAnimation(ConfirmCloseBtn)
	
	local BtnFrame = TrollMainFrame:WaitForChild("BtnFrame")
	
	for _, btn in ipairs(BtnFrame:GetChildren()) do
		if btn:IsA("TextButton") then
			UIManager.ApplyButtonAnimation(btn)
			
			btn.MouseButton1Click:Connect(function()
				local trollType = btn.Name:gsub("Btn", "")
				local target = SpectateController.GetTarget()
				
				currentPendingTroll = trollType
				
				if trollType:match("All") then
					ConfirmLabel.Text = "Are you sure you want to " .. trollType .. " everyone?"
				else
					local name = target and target.DisplayName or "Unknown"
					ConfirmLabel.Text = "Are you sure you want to " .. trollType .. " " .. name .. "?"
				end
				
				UIManager.AnimateFrameIn(ConfirmationFrame)
			end)
		end
	end
	
	ConfirmYesBtn.MouseButton1Click:Connect(function()
		if currentPendingTroll then
			local target = SpectateController.GetTarget()
			if target then
				TrollController.SetSelectedTarget(target.UserId)
			end
			TrollController.ExecuteTroll(currentPendingTroll)
			currentPendingTroll = nil
			UIManager.AnimateFrameOut(ConfirmationFrame)
		end
	end)
	
	ConfirmCloseBtn.MouseButton1Click:Connect(function()
		currentPendingTroll = nil
		UIManager.AnimateFrameOut(ConfirmationFrame)
	end)
	
	-- Handle Jumpscare & Earthquake effects
	Remotes.TrollEffect.OnClientEvent:Connect(function(effectType, msg, isError)
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
		elseif effectType == "Notif" then
			-- isError: true = merah (korban troll), false = hijau (berhasil troll)
			UIManager.ShowNotification(msg or "Notifikasi", isError)
		end
	end)
end

function TrollController.SetSelectedTarget(userId)
	selectedTargetId = userId
end

function TrollController.TogglePanel()
	local PlayerGui = Players.LocalPlayer:WaitForChild("PlayerGui")
	local TrollGui = PlayerGui:WaitForChild("SelectTrollGui")
	
	-- Ambil WinnerGui MainFrame
	local WinnerGui = PlayerGui:FindFirstChild("WinnerGui")
	local WinnerFrame = WinnerGui and WinnerGui:FindFirstChild("MainFrame")
	
	panelOpen = not panelOpen
	
	if panelOpen then
		SpectateController.Start()
		TrollGui.Enabled = true
		local TrollMainFrame = TrollGui:WaitForChild("TrollMainFrame")
		local SpectateFrame = TrollGui:WaitForChild("SpectateFrame")
		UIManager.AnimateFrameIn(TrollMainFrame)
		UIManager.AnimateFrameIn(SpectateFrame)
		
		local MenuUtama = PlayerGui:WaitForChild("MenuUtama")
		local JumpGui = PlayerGui:WaitForChild("JumpUpgradeGui")
		UIManager.AnimateFrameOut(MenuUtama:WaitForChild("MainFrame"))
		UIManager.AnimateFrameOut(JumpGui:WaitForChild("Frame"))
		
		-- [BARU]: Sembunyikan WinnerGui saat panel Troll buka
		if WinnerFrame then UIManager.AnimateFrameOut(WinnerFrame) end
		
		local MenuKanan = PlayerGui:FindFirstChild("MenuKanan")
		if MenuKanan then
			UIManager.AnimateFrameOut(MenuKanan:FindFirstChild("MainFrame"))
		end
		
		local HideGui = PlayerGui:FindFirstChild("HideGui")
		if HideGui then
			UIManager.AnimateFrameOut(HideGui:FindFirstChild("MainFrame"))
		end
	else
		SpectateController.Stop()
		local TrollMainFrame = TrollGui:WaitForChild("TrollMainFrame")
		local SpectateFrame = TrollGui:WaitForChild("SpectateFrame")
		UIManager.AnimateFrameOut(SpectateFrame)
		UIManager.AnimateFrameOut(TrollMainFrame, function()
			if not panelOpen then
				TrollGui.Enabled = false
			end
		end)
		
		local MenuUtama = PlayerGui:WaitForChild("MenuUtama")
		local JumpGui = PlayerGui:WaitForChild("JumpUpgradeGui")
		UIManager.AnimateFrameIn(MenuUtama:WaitForChild("MainFrame"))
		UIManager.AnimateFrameIn(JumpGui:WaitForChild("Frame"))
		
		-- [BARU]: Munculkan kembali WinnerGui saat panel Troll tutup
		if WinnerFrame then UIManager.AnimateFrameIn(WinnerFrame) end
		
		local MenuKanan = PlayerGui:FindFirstChild("MenuKanan")
		if MenuKanan then
			UIManager.AnimateFrameIn(MenuKanan:FindFirstChild("MainFrame"))
		end
		
		local HideGui = PlayerGui:FindFirstChild("HideGui")
		if HideGui then
			UIManager.AnimateFrameIn(HideGui:FindFirstChild("MainFrame"))
		end
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
