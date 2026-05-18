local Players = game:GetService("Players")
local MarketplaceService = game:GetService("MarketplaceService")
local Config = require(game:GetService("ReplicatedStorage"):WaitForChild("Shared"):WaitForChild("Config"))

local ShopController = {}
local UIManager = require(script.Parent.UIManager)
local Remotes = nil

local shopOpen = false

local function setButtonOwned(buyBtn)
	local textLabel = buyBtn:FindFirstChild("TextLabel")
	if textLabel then
		textLabel.Text = "Owned"
	else
		buyBtn.Text = "Owned" -- Fallback if TextLabel doesn't exist
	end
	
	buyBtn.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
	buyBtn.AutoButtonColor = false
	buyBtn.Active = false
	buyBtn.Interactable = false -- Completely disable hover/click events
	buyBtn:SetAttribute("IsOwned", true)
end

function ShopController.Init(networkRemotes)
	Remotes = networkRemotes
	
	local PlayerGui = Players.LocalPlayer:WaitForChild("PlayerGui")
	
	local MenuUtama = PlayerGui:WaitForChild("MenuUtama")
	local MainFrame = MenuUtama:WaitForChild("MainFrame")
	local Shopbtn = MainFrame:WaitForChild("Shopbtn")
	local ShopFrame = MenuUtama:WaitForChild("ShopFrame")
	local ShopMainFrame = ShopFrame:WaitForChild("MainFrame")
	local ShopTitleFrame = ShopMainFrame:WaitForChild("TitleFrame")
	local CloseBtn = ShopTitleFrame:WaitForChild("CloseBtn")
	
	-- Apply Animations
	UIManager.ApplyButtonAnimation(Shopbtn)
	UIManager.ApplyButtonAnimation(CloseBtn)
	UIManager.ApplyShakeEffect(Shopbtn:WaitForChild("ImageLabel"))
	
	local function toggleShop()
		shopOpen = not shopOpen
		if shopOpen then
			-- Show Shop
			ShopFrame.Visible = true
			UIManager.AnimateFrameIn(ShopMainFrame)
			UIManager.AnimateFrameIn(ShopTitleFrame)
			
			-- Hide other UIs
			UIManager.AnimateFrameOut(MainFrame)
			local MenuKanan = PlayerGui:FindFirstChild("MenuKanan")
			if MenuKanan then
				UIManager.AnimateFrameOut(MenuKanan:FindFirstChild("MainFrame"))
			end
			local JumpGui = PlayerGui:FindFirstChild("JumpUpgradeGui")
			if JumpGui then
				UIManager.AnimateFrameOut(JumpGui:FindFirstChild("Frame"))
			end
			local HideGui = PlayerGui:FindFirstChild("HideGui")
			if HideGui then
				UIManager.AnimateFrameOut(HideGui:FindFirstChild("MainFrame"))
			end
		else
			-- Hide Shop
			UIManager.AnimateFrameOut(ShopTitleFrame)
			UIManager.AnimateFrameOut(ShopMainFrame, function()
				if not shopOpen then
					ShopFrame.Visible = false
				end
			end)
			
			-- Show other UIs
			UIManager.AnimateFrameIn(MainFrame)
			local MenuKanan = PlayerGui:FindFirstChild("MenuKanan")
			if MenuKanan then
				UIManager.AnimateFrameIn(MenuKanan:FindFirstChild("MainFrame"))
			end
			local JumpGui = PlayerGui:FindFirstChild("JumpUpgradeGui")
			if JumpGui then
				UIManager.AnimateFrameIn(JumpGui:FindFirstChild("Frame"))
			end
			local HideGui = PlayerGui:FindFirstChild("HideGui")
			if HideGui then
				UIManager.AnimateFrameIn(HideGui:FindFirstChild("MainFrame"))
			end
		end
	end
	
	Shopbtn.MouseButton1Click:Connect(function()
		if not shopOpen then
			toggleShop()
		end
	end)
	
	CloseBtn.MouseButton1Click:Connect(function()
		if shopOpen then
			toggleShop()
		end
	end)
	
	-- Setup Items
	local ScrollingFrame = ShopMainFrame:WaitForChild("ScrollingFrame")
	local itemNames = {"ItemSatu", "ItemDua", "ItemTiga", "ItemEmpat"}
	
	for _, itemName in ipairs(itemNames) do
		local itemFrame = ScrollingFrame:FindFirstChild(itemName)
		if itemFrame then
			local buyBtn = itemFrame:FindFirstChild("BuyBtn")
			if buyBtn then
				UIManager.ApplyButtonAnimation(buyBtn)
				
				-- Initial Ownership Check
				task.spawn(function()
					local isOwned = Remotes.CheckItemOwnership:InvokeServer(itemName)
					if isOwned then
						setButtonOwned(buyBtn)
					end
				end)
				
				buyBtn.MouseButton1Click:Connect(function()
					if buyBtn:GetAttribute("IsOwned") then return end
					
					local gamepassId = Config.ShopGamepasses[itemName]
					if gamepassId then
						MarketplaceService:PromptGamePassPurchase(Players.LocalPlayer, gamepassId)
					end
				end)
			end
		end
	end
	
	-- Listen for purchase complete
	MarketplaceService.PromptGamePassPurchaseFinished:Connect(function(player, gamepassId, wasPurchased)
		if player == Players.LocalPlayer and wasPurchased then
			for itemName, id in pairs(Config.ShopGamepasses) do
				if id == gamepassId then
					local itemFrame = ScrollingFrame:FindFirstChild(itemName)
					if itemFrame then
						local buyBtn = itemFrame:FindFirstChild("BuyBtn")
						if buyBtn then
							setButtonOwned(buyBtn)
						end
					end
					
					-- 1. Memunculkan notifikasi berhasil membeli (mengambil nama asli coil/pedang dari Config)
					local toolName = Config.Tools[itemName] or "Item"
					UIManager.ShowNotification("Berhasil membeli " .. toolName .. "!", false)
					
					-- 2. Otomatis menutup shopframe setiap kali berhasil membeli
					if shopOpen then
						toggleShop()
					end
				end
			end
		end
	end)
end

return ShopController
