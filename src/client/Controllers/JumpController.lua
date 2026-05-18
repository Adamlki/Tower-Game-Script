local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")

local JumpController = {}
local UIManager = require(script.Parent.UIManager)
local Remotes = nil

local maxJumps = 1
local currentJumps = 1
local jumpCount = 0
local timeSinceLastGroundJump = 0
local connection = nil

local function ShowNotification(message, isError)
	UIManager.ShowNotification(message, isError)
end

function JumpController.Init(networkRemotes)
	Remotes = networkRemotes
	
	-- Fetch initial jump level
	task.spawn(function()
		local level = Remotes.GetJumpLevel:InvokeServer()
		if level then
			maxJumps = level
			currentJumps = level
			JumpController.UpdateUI()
		end
	end)
	
	Remotes.UpdateJump.OnClientInvoke = function(level)
		maxJumps = level
		currentJumps = level
		JumpController.UpdateUI()
		ShowNotification("Upgrade Berhasil!", false)
		return true
	end
	
	-- Connect UI (Manual GUI from StarterGui)
	local PlayerGui = Players.LocalPlayer:WaitForChild("PlayerGui")
	local JumpGui = PlayerGui:WaitForChild("JumpUpgradeGui")
	local FirstFrame = JumpGui:WaitForChild("Frame")
	local SecondFrame = FirstFrame:WaitForChild("Frame")
	
	local UpgradeJumpBtn = FirstFrame:WaitForChild("UpgradeJumpBtn")
	local ApplyBtn = SecondFrame:WaitForChild("ApplyBtn")
	local JumpInput = SecondFrame:WaitForChild("TextBox")
	
	-- Apply Animations
	UIManager.ApplyButtonAnimation(UpgradeJumpBtn)
	UIManager.ApplyButtonAnimation(ApplyBtn)
	
	-- Shake Animation Logic
	local ImageLabel = UpgradeJumpBtn:WaitForChild("ImageLabel")
	local HargaUpgrade = UpgradeJumpBtn:WaitForChild("HargaUpgrade")
	
	UIManager.ApplyShakeEffect(ImageLabel)
	UIManager.ApplyShakeEffect(HargaUpgrade)
	
	UpgradeJumpBtn.MouseButton1Click:Connect(function()
		local nextLevel = maxJumps + 1
		local Config = require(game:GetService("ReplicatedStorage"):WaitForChild("Shared"):WaitForChild("Config"))
		local productId = Config.JumpProducts[nextLevel]
		if productId then
			game:GetService("MarketplaceService"):PromptProductPurchase(Players.LocalPlayer, productId)
		else
			ShowNotification("Sudah Max Level!", true)
		end
	end)
	
	ApplyBtn.MouseButton1Click:Connect(function()
		local input = tonumber(JumpInput.Text)
		if input and input >= 1 and input <= maxJumps then
			currentJumps = input
			Remotes.SetCurrentJump:FireServer(currentJumps) -- If server needs to know
			ShowNotification("Apply Berhasil!", false)
		else
			ShowNotification("Max Jump kamu cuma " .. maxJumps .. "!", true)
			JumpInput.Text = tostring(currentJumps)
		end
	end)
	
	local canDoubleJump = true
	UserInputService.JumpRequest:Connect(function()
		local localPlayer = Players.LocalPlayer
		if not localPlayer.Character then return end
		local humanoid = localPlayer.Character:FindFirstChildOfClass("Humanoid")
		local hrp = localPlayer.Character:FindFirstChild("HumanoidRootPart")
		if not humanoid or not hrp then return end
		
		local state = humanoid:GetState()
		if state == Enum.HumanoidStateType.Dead then return end
		
		if state == Enum.HumanoidStateType.Freefall or state == Enum.HumanoidStateType.Jumping then
			-- Mencegah double jump terpakai seketika saat baru saja melompat dari tanah
			if tick() - timeSinceLastGroundJump < 0.2 then return end
			
			if jumpCount < currentJumps - 1 and canDoubleJump then
				canDoubleJump = false
				jumpCount = jumpCount + 1
				
				-- Terapkan dorongan fisik ke atas (Velocity) untuk double jump
				local v = hrp.AssemblyLinearVelocity
				local jumpPower = humanoid.UseJumpPower and humanoid.JumpPower or 50
				hrp.AssemblyLinearVelocity = Vector3.new(v.X, jumpPower, v.Z)
				humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
				
				-- Debounce agar lompatan tidak langsung habis jika tombol ditahan
				task.delay(0.2, function()
					canDoubleJump = true
				end)
			end
		end
	end)
	
	local function setupCharacter(char)
		local humanoid = char:WaitForChild("Humanoid")
		humanoid.StateChanged:Connect(function(old, new)
			if new == Enum.HumanoidStateType.Landed then
				jumpCount = 0
			elseif old == Enum.HumanoidStateType.Running and new == Enum.HumanoidStateType.Jumping then
				-- Catat waktu saat melompat dari tanah
				timeSinceLastGroundJump = tick()
			end
		end)
	end
	
	local localPlayer = Players.LocalPlayer
	if localPlayer.Character then
		task.spawn(setupCharacter, localPlayer.Character)
	end
	localPlayer.CharacterAdded:Connect(setupCharacter)
end

function JumpController.UpdateUI()
	local PlayerGui = Players.LocalPlayer:WaitForChild("PlayerGui")
	local JumpGui = PlayerGui:WaitForChild("JumpUpgradeGui")
	local FirstFrame = JumpGui:WaitForChild("Frame")
	local SecondFrame = FirstFrame:WaitForChild("Frame")
	
	local InfoMaxJump = FirstFrame:WaitForChild("InfoMaxJump")
	local JumpInput = SecondFrame:WaitForChild("TextBox")
	local UpgradeJumpBtn = FirstFrame:WaitForChild("UpgradeJumpBtn")
	local HargaUpgrade = UpgradeJumpBtn:WaitForChild("HargaUpgrade")
	local UpgreadeJumpText = UpgradeJumpBtn:WaitForChild("UpgradeJump")
	local ImageLabel = UpgradeJumpBtn:WaitForChild("ImageLabel")
	
	InfoMaxJump.Text = "Max Jump: " .. maxJumps
	JumpInput.Text = tostring(currentJumps)
	
	local Config = require(game:GetService("ReplicatedStorage"):WaitForChild("Shared"):WaitForChild("Config"))
	local nextLevel = maxJumps + 1
	local productId = Config.JumpProducts[nextLevel]
	
	if not productId then
		UpgreadeJumpText.Text = "MAXED OUT"
		HargaUpgrade.Text = "Max Level"
		UpgradeJumpBtn.Interactable = false
		
		ImageLabel:SetAttribute("DisableShake", true)
		HargaUpgrade:SetAttribute("DisableShake", true)
	else
		UpgreadeJumpText.Text = "UPGRADE JUMP X" .. nextLevel
		UpgradeJumpBtn.Interactable = true
		
		ImageLabel:SetAttribute("DisableShake", false)
		HargaUpgrade:SetAttribute("DisableShake", false)
		
		-- Fetch price dynamically using MarketplaceService
		task.spawn(function()
			local success, productInfo = pcall(function()
				return game:GetService("MarketplaceService"):GetProductInfo(productId, Enum.InfoType.Product)
			end)
			
			if success and productInfo then
				HargaUpgrade.Text = productInfo.PriceInRobux .. " Robux"
			else
				HargaUpgrade.Text = "? Robux"
			end
		end)
	end
end

return JumpController
