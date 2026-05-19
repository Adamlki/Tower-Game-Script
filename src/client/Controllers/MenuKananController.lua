local Players = game:GetService("Players")
local MarketplaceService = game:GetService("MarketplaceService")
local SocialService = game:GetService("SocialService")
local Config = require(game:GetService("ReplicatedStorage"):WaitForChild("Shared"):WaitForChild("Config"))

local MenuKananController = {}
local UIManager = require(script.Parent.UIManager)
local Remotes = nil

function MenuKananController.Init(networkRemotes)
	Remotes = networkRemotes
	
	local PlayerGui = Players.LocalPlayer:WaitForChild("PlayerGui")
	
	local MenuKanan = PlayerGui:WaitForChild("MenuKanan")
	local MainFrame = MenuKanan:WaitForChild("MainFrame")
	
	-- We expect InviteBtn, SkipStageBtn, and SkipToFinishBtn
	-- Note: The user had two buttons named SkipStageBtn. 
	-- We differentiate them by name, but if they are named the same, we check for ImageLabel.
	
	for _, child in ipairs(MainFrame:GetChildren()) do
		if child:IsA("TextButton") or child:IsA("ImageButton") then
			UIManager.ApplyButtonAnimation(child)
			
			-- Shake Effects
			local imageLabel = child:FindFirstChild("ImageLabel")
			if imageLabel then
				UIManager.ApplyShakeEffect(imageLabel)
			end
			
			local hargaLabel = child:FindFirstChild("HargaLabel")
			if hargaLabel then
				UIManager.ApplyShakeEffect(hargaLabel)
			end
			
			child.MouseButton1Click:Connect(function()
				if child.Name == "InviteBtn" or (child.Name == "SkipStageBtn" and child:FindFirstChild("ImageLabel")) then
					-- Invite
					local success, canInvite = pcall(function()
						return SocialService:CanSendGameInviteAsync(Players.LocalPlayer)
					end)
					if success and canInvite then
						SocialService:PromptGameInvite(Players.LocalPlayer)
					end
				elseif child.Name == "SkipStageBtn" and child:FindFirstChild("HargaLabel") then
					-- Coba Skip via server
					local success, status = Remotes.ExecuteSkip:InvokeServer("SkipNextStage")
					-- Hanya munculkan menu beli jika statusnya PromptPurchase (Bukan NotAllowed)
					if not success and status == "PromptPurchase" and Config.Products.SkipNextStage then
						MarketplaceService:PromptProductPurchase(Players.LocalPlayer, Config.Products.SkipNextStage)
					end
				elseif child.Name == "SkipToFinishBtn" then
					-- Coba Skip via server
					local success, status = Remotes.ExecuteSkip:InvokeServer("SkipToFinish")
					-- Hanya munculkan menu beli jika statusnya PromptPurchase (Bukan NotAllowed)
					if not success and status == "PromptPurchase" and Config.Products.SkipToFinish then
						MarketplaceService:PromptProductPurchase(Players.LocalPlayer, Config.Products.SkipToFinish)
					end
				end
			end)
		end
	end
end

return MenuKananController
