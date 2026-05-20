local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local UserService = game:GetService("UserService") -- [BARU]: Layanan untuk mengambil Nickname/DisplayName

local LeaderstatSystem = {}
local CheckpointSystem = require(script.Parent.CheckpointSystem)
local DataSystem = require(script.Parent.DataSystem)
local debounces = {}

-- Cache memori untuk menyimpan Nickname dan Foto Profil agar tidak lag
local UserInfoCache = {}

-- ==========================================
-- 🏆 SYSTEM PATUNG 3D TOP 3 GLOBAL (FIX MENCAR)
-- ==========================================
local function updateTop3Statues(data)
	local ReplicatedStorage = game:GetService("ReplicatedStorage")
	
	local colors = {
		[1] = Color3.fromRGB(255, 215, 0),
		[2] = Color3.fromRGB(192, 192, 192),
		[3] = Color3.fromRGB(205, 127, 50)
	}
	local rankNames = {"Top 1", "Top 2", "Top 3"}

	for i = 1, 3 do
		task.spawn(function()
			local part = workspace:FindFirstChild("Top" .. i, true) 
			if not part then return end

			local entry = data[i]
			if not entry then return end 

			local userId = tonumber(entry.key)
			local totalWins = entry.value

			local nickname = "Player"
			if UserInfoCache[userId] and UserInfoCache[userId].Name ~= "Unknown Player" then
				nickname = UserInfoCache[userId].Name
			else
				-- Jika nama belum ada di memori, download langsung dari Roblox!
				pcall(function()
					local UserService = game:GetService("UserService")
					local userInfo = UserService:GetUserInfosByUserIdsAsync({userId})
					if userInfo and userInfo[1] then
						nickname = userInfo[1].DisplayName -- Ambil Nickname
					else
						nickname = game:GetService("Players"):GetNameFromUserIdAsync(userId) -- Cadangan Username
					end
					
					-- Simpan ke memori agar 30 detik berikutnya tidak perlu download lagi
					if not UserInfoCache[userId] then UserInfoCache[userId] = {} end
					UserInfoCache[userId].Name = nickname
				end)
			end

			local existingStatue = part:FindFirstChild("Statue")
			if existingStatue then
				if existingStatue:GetAttribute("UserId") == userId then
					local gui = existingStatue:FindFirstChild("LeaderboardGui")
					if gui and gui:FindFirstChild("Frame") then
						local winsLabel = gui.Frame:FindFirstChild("WinsLabel")
						if winsLabel then
							winsLabel.Text = totalWins .. " 🏆"
						end
					end
					return 
				else
					existingStatue:Destroy() 
				end
			end

			local success, dummy = pcall(function()
				return game:GetService("Players"):CreateHumanoidModelFromUserId(userId)
			end)

			if success and dummy then
				dummy.Name = "Statue"
				dummy:SetAttribute("UserId", userId)
				
				-- 1. Taruh di map dulu agar mesin Roblox mulai merakit tubuhnya
				dummy.Parent = part
				
				local hrp = dummy:FindFirstChild("HumanoidRootPart")
				local hum = dummy:FindFirstChild("Humanoid")
				
				if hrp and hum then
					-- 2. Kunci perutnya saja (HRP) agar dia tidak jatuh ke tanah
					hrp.Anchored = true 
					
					-- 3. Pindahkan posisinya ke atas part secara matematis
					-- Menggunakan part.CFrame agar patung menghadap ke arah yang sama dengan depan Part
					local yOffset = (part.Size.Y / 2) + hum.HipHeight + (hrp.Size.Y / 2)
					dummy:PivotTo(part.CFrame * CFrame.new(0, yOffset, 0))
				end
				
				-- 4. KUNCI RAHASIA: Tunggu 1.5 detik agar Roblox selesai memasang baju/kepala/tulang!
				task.wait(1.5)
				
				-- 5. Setelah rapi, baru kita bekukan seluruh tubuhnya jadi patung
				for _, v in ipairs(dummy:GetDescendants()) do
					if v:IsA("BasePart") then
						v.Anchored = true
						v.CanCollide = false 
					elseif v:IsA("Script") or v:IsA("LocalScript") then
						v:Destroy()
					end
				end
				
				-- 6. Mainkan animasinya
				if hum then
					local animator = hum:FindFirstChildOfClass("Animator") or Instance.new("Animator", hum)
					local anim = Instance.new("Animation")
					anim.AnimationId = "rbxassetid://110955034311554" 
					local track = animator:LoadAnimation(anim)
					track.Looped = true
					track:Play()
				end

				-- 7. Tambahkan UI di kepalanya
				local guiTemplate = ReplicatedStorage:FindFirstChild("LeaderboardGui")
				if guiTemplate then
					local cloneGui = guiTemplate:Clone()
					cloneGui.Adornee = dummy:FindFirstChild("Head") or hrp
					cloneGui.ExtentsOffset = Vector3.new(0, 1.5, 0)
					cloneGui.Parent = head
					
					local frame = cloneGui:FindFirstChild("Frame")
					if frame then
						local rankLabel = frame:FindFirstChild("RankLabel")
						local nameLabel = frame:FindFirstChild("NameLabel")
						local winsLabel = frame:FindFirstChild("WinsLabel")
						
						if rankLabel then rankLabel.Text = rankNames[i]; rankLabel.TextColor3 = colors[i] end
						if nameLabel then nameLabel.Text = nickname end
						if winsLabel then winsLabel.Text = totalWins .. " 🏆" end
					end
				end
			end
		end)
	end
end

-- [[ FUNGSI UPDATE PAPAN LEADERBOARD GLOBAL ]]
local function updateGlobalLeaderboard()
	local boardModel = Workspace:FindFirstChild("WinnerLeaderboard")
	if not boardModel then return end
	
	local papan = boardModel:FindFirstChild("Papan")
	if not papan then return end
	
	local surfaceGui = papan:FindFirstChild("SurfaceGui")
	if not surfaceGui then return end
	
	local frame = surfaceGui:FindFirstChild("Frame")
	if not frame then return end
	
	local template = frame:FindFirstChild("MainFrame")
	if not template then return end
	template.Visible = false 
	
	-- Ambil data top 50 langsung dari DataStore
	local pages = DataSystem.GetTopWins(50)
	
	if pages then
		-- Hapus data list lama (kecuali template)
		for _, child in ipairs(frame:GetChildren()) do
			if child:IsA("Frame") and child.Name ~= "MainFrame" then
				child:Destroy()
			end
		end
		
		local data = pages:GetCurrentPage()
		updateTop3Statues(data)
		for rank, entry in ipairs(data) do
			local userId = tonumber(entry.key)
			local totalWins = entry.value
			
			local clone = template:Clone()
			clone.Name = "Rank_" .. rank
			clone.Visible = true
			clone.LayoutOrder = rank 
			
			-- [OPTIMASI API & NICKNAME]: Cek apakah data nickname & foto sudah ada di memori cache
			if not UserInfoCache[userId] then
				local nickname = "Unknown Player"
				local thumbUrl = "rbxassetid://0"
				
				-- Ambil Nickname (DisplayName) dan Foto secara aman dari database Roblox
				pcall(function()
					-- Mengambil informasi user lengkap (termasuk DisplayName)
					local success, userInfo = pcall(function()
						return UserService:GetUserInfosByUserIdsAsync({userId})
					end)
					
					if success and userInfo and userInfo[1] then
						nickname = userInfo[1].DisplayName -- Mengambil NICKNAME, bukan Username asli!
					else
						-- Fallback jika UserService gagal, coba ambil username biasa sebagai cadangan
						nickname = Players:GetNameFromUserIdAsync(userId)
					end
					
					thumbUrl = Players:GetUserThumbnailAsync(userId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size420x420)
				end)
				
				-- Simpan ke memori sementara server
				UserInfoCache[userId] = {
					Name = nickname,
					Image = thumbUrl
				}
			end
			
			-- Ambil data dari Cache agar instan tanpa beban server
			local cachedData = UserInfoCache[userId]
			
			if clone:FindFirstChild("NameFrame") and clone.NameFrame:FindFirstChild("TextLabel") then
				clone.NameFrame.TextLabel.Text = "#" .. rank .. " " .. cachedData.Name
			end
			
			if clone:FindFirstChild("WinnerFrame") and clone.WinnerFrame:FindFirstChild("TextLabel") then
				clone.WinnerFrame.TextLabel.Text = tostring(totalWins) .. " 🏆"
			end
			
			if clone:FindFirstChild("ImagePlayerFrame") and clone.ImagePlayerFrame:FindFirstChild("ImageLabel") then
				clone.ImagePlayerFrame.ImageLabel.Image = cachedData.Image
			end
			
			clone.Parent = frame
		end
	end
end


function LeaderstatSystem.Init()
	local function onPlayerAdded(player)
		if player:FindFirstChild("leaderstats") then return end
		
		local leaderstats = Instance.new("Folder")
		leaderstats.Name = "leaderstats"
		leaderstats.Parent = player
		
		local wins = Instance.new("IntValue")
		wins.Name = "Wins"
		wins.Value = 0
		wins.Parent = leaderstats
		
		wins.Value = DataSystem.LoadWins(player.UserId)
		
		wins.Changed:Connect(function(newValue)
			DataSystem.SaveWins(player.UserId, newValue)
		end)
	end
	
	Players.PlayerAdded:Connect(onPlayerAdded)
	
	Players.PlayerRemoving:Connect(function(player)
		local leaderstats = player:FindFirstChild("leaderstats")
		if leaderstats then
			local wins = leaderstats:FindFirstChild("Wins")
			if wins then
				DataSystem.SaveWins(player.UserId, wins.Value)
			end
		end
	end)
	
	for _, player in ipairs(Players:GetPlayers()) do
		onPlayerAdded(player)
	end
	
	-- Update Papan Global setiap 30 Detik
	task.spawn(function()
		while true do
			updateGlobalLeaderboard()
			task.wait(30)
		end
	end)
	
	local function teleportToSpawn(player)
		local char = player.Character
		if not char then return end
		local root = char:FindFirstChild("HumanoidRootPart")
		if not root then return end
		
		local spawnLocation = Workspace:FindFirstChildWhichIsA("SpawnLocation")
		if spawnLocation then
			root.CFrame = CFrame.new(spawnLocation.Position + Vector3.new(0, 3, 0))
		else
			root.CFrame = CFrame.new(0, 5, 0)
		end
	end

	local hasFinished = {}

	local function setupFinishPart(finishPart)
		finishPart.Touched:Connect(function(hit)
			local char = hit.Parent
			local player = Players:GetPlayerFromCharacter(char)
			
			if player then
				if not debounces[player.UserId] and not hasFinished[player.UserId] then
					debounces[player.UserId] = true
					hasFinished[player.UserId] = true
					
					local leaderstats = player:FindFirstChild("leaderstats")
					if leaderstats then
						local wins = leaderstats:FindFirstChild("Wins")
						if wins then
							wins.Value = wins.Value + 1
						end
					end
					
					task.wait(2)
					debounces[player.UserId] = nil
				end
			end
		end)
	end
	
	local function setupResetPart(resetPart)
		resetPart.Touched:Connect(function(hit)
			local char = hit.Parent
			local player = Players:GetPlayerFromCharacter(char)
			
			if player then
				if not debounces[player.UserId] then
					debounces[player.UserId] = true
					hasFinished[player.UserId] = nil
					
					CheckpointSystem.ResetCheckpoint(player)
					teleportToSpawn(player)
					
					task.wait(2)
					debounces[player.UserId] = nil
				end
			end
		end)
	end
	
	task.spawn(function()
		local finishPart = nil
		local resetPart = nil
		
		for _, desc in ipairs(Workspace:GetDescendants()) do
			if desc:IsA("BasePart") then
				if desc.Name == "FinishPart" then
					finishPart = desc
				elseif desc.Name == "ResetPart" then
					resetPart = desc
				end
			end
		end
		
		if finishPart then setupFinishPart(finishPart) end
		if resetPart then setupResetPart(resetPart) end
		
		Workspace.DescendantAdded:Connect(function(desc)
			if desc:IsA("BasePart") then
				if desc.Name == "FinishPart" then
					setupFinishPart(desc)
				elseif desc.Name == "ResetPart" then
					setupResetPart(desc)
				end
			end
		end)
	end)
end

return LeaderstatSystem