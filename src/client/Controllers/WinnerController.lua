local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")

local WinnerController = {}

function WinnerController.Init()
	local player = Players.LocalPlayer
	local playerGui = player:WaitForChild("PlayerGui")
	
	local winnerGui = playerGui:WaitForChild("WinnerGui", 10)
	if not winnerGui then return end
	
	local mainFrame = winnerGui:WaitForChild("MainFrame")
	local textLabel = mainFrame:WaitForChild("TextLabel")
	
	-- [BARU]: Mengambil ImageLabel di dalam WinnerGui untuk digerakkan
	local imageLabel = mainFrame:FindFirstChild("ImageLabel")
	local UIManager = require(script.Parent.UIManager)
	
	if imageLabel then
		-- Memberikan efek getar otomatis (Shake Effect)
		UIManager.ApplyShakeEffect(imageLabel)
	end
	
	local originalSize = textLabel.Size
	
	local function popAnimation()
		local popTween = TweenService:Create(textLabel, TweenInfo.new(0.15, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
			Size = originalSize + UDim2.new(0, 10, 0, 10)
		})
		popTween:Play()
		popTween.Completed:Wait()
		TweenService:Create(textLabel, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			Size = originalSize
		}):Play()
	end

	local function updateWinsText(winsValue)
		textLabel.Text = tostring(winsValue)
	end

	local function setupLeaderstats()
		local leaderstats = player:WaitForChild("leaderstats", 10)
		if leaderstats then
			local wins = leaderstats:WaitForChild("Wins", 10)
			if wins then
				updateWinsText(wins.Value)
				wins.Changed:Connect(function(newValue)
					updateWinsText(newValue)
					popAnimation()
				end)
			end
		end
	end

	task.spawn(setupLeaderstats)
end

return WinnerController