local Players = game:GetService("Players")

local HideUIController = {}
local UIManager = require(script.Parent.UIManager)

local uiHidden = false

function HideUIController.Init(networkRemotes)
	local PlayerGui = Players.LocalPlayer:WaitForChild("PlayerGui")
	
	local HideGui = PlayerGui:WaitForChild("HideGui")
	local HideBtn = HideGui:WaitForChild("MainFrame"):WaitForChild("HideBtn")
	local TextLabel = HideBtn:WaitForChild("TextLabel")
	
	UIManager.ApplyButtonAnimation(HideBtn)
	
	-- We want to toggle visibility of these specific GUIs
	local guisToToggle = {
		"MenuUtama",
		"MenuKanan",
		"JumpUpgradeGui",
		"WinnerGui",
		"NotificationGui"
	}
	
	HideBtn.MouseButton1Click:Connect(function()
		uiHidden = not uiHidden
		
		if uiHidden then
			-- Hide
			TextLabel.Text = "UNHIDE UI"
			HideBtn.BackgroundColor3 = Color3.fromRGB(50, 200, 50) -- Green
			
			for _, guiName in ipairs(guisToToggle) do
				local gui = PlayerGui:FindFirstChild(guiName)
				if gui then
					-- Typically they have a MainFrame or Frame
					local frame = gui:FindFirstChild("MainFrame") or gui:FindFirstChild("Frame")
					if frame then
						UIManager.AnimateFrameOut(frame)
					end
				end
			end
		else
			-- Show
			TextLabel.Text = "HIDE UI"
			HideBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50) -- Red
			
			for _, guiName in ipairs(guisToToggle) do
				local gui = PlayerGui:FindFirstChild(guiName)
				if gui then
					local frame = gui:FindFirstChild("MainFrame") or gui:FindFirstChild("Frame")
					if frame then
						UIManager.AnimateFrameIn(frame)
					end
				end
			end
		end
	end)
end

return HideUIController
