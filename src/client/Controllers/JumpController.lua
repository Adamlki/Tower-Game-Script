local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")

local JumpController = {}
local UIManager = require(script.Parent.UIManager)
local Remotes = nil

local maxJumps = 1
local currentJumps = 1
local jumpCount = 0
local timeSinceLastGroundJump = 0
local connection = nil

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
		return true
	end
	
	-- Connect UI
	local Gui = UIManager.GetGui()
	local JumpPanel = Gui:WaitForChild("JumpPanel")
	
	JumpPanel.BuyBtn.MouseButton1Click:Connect(function()
		local nextLevel = maxJumps + 1
		local Config = require(game:GetService("ReplicatedStorage"):WaitForChild("Shared"):WaitForChild("Config"))
		local productId = Config.JumpProducts[nextLevel]
		if productId then
			game:GetService("MarketplaceService"):PromptProductPurchase(Players.LocalPlayer, productId)
		else
			print("Max jump level reached or product not configured.")
		end
	end)
	
	JumpPanel.ApplyBtn.MouseButton1Click:Connect(function()
		local input = tonumber(JumpPanel.JumpInput.Text)
		if input and input >= 1 and input <= maxJumps then
			currentJumps = input
			Remotes.SetCurrentJump:FireServer(currentJumps) -- If server needs to know
			print("Current jumps set to: " .. currentJumps)
		else
			print("Invalid jump input. Must be between 1 and " .. maxJumps)
			JumpPanel.JumpInput.Text = tostring(currentJumps)
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
	local Gui = UIManager.GetGui()
	local JumpPanel = Gui:WaitForChild("JumpPanel")
	JumpPanel.JumpInfo.Text = "Max Jump: " .. maxJumps
	JumpPanel.JumpInput.Text = tostring(currentJumps)
	
	local Config = require(game:GetService("ReplicatedStorage"):WaitForChild("Shared"):WaitForChild("Config"))
	local nextLevel = maxJumps + 1
	if not Config.JumpProducts[nextLevel] then
		JumpPanel.BuyBtn.Text = "Maxed Out"
		JumpPanel.BuyBtn.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
	end
end

return JumpController
