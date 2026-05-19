local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local SoundService = game:GetService("SoundService")
local RunService = game:GetService("RunService")

local CheckpointController = {}
local Remotes = nil

local currentCheckpoint = nil
local originalColors = {}

-- [[ SETUP VISUAL & AUDIO ]]
-- Efek Suara
local CPSound = Instance.new("Sound")
CPSound.Name = "CPSound"
CPSound.SoundId = "rbxassetid://97969485348089" 
CPSound.Volume = 0.8
CPSound.Parent = SoundService

local FinishSound = Instance.new("Sound")
FinishSound.Name = "FinishSound"
FinishSound.SoundId = "rbxassetid://115051157912492"
FinishSound.Volume = 1
FinishSound.Parent = SoundService

-- Membuat Anchor (Part tak terlihat sebagai titik pusat pergerakan panah)
local ArrowAnchor = Instance.new("Part")
ArrowAnchor.Name = "ArrowAnchor"
ArrowAnchor.Anchored = true
ArrowAnchor.CanCollide = false
ArrowAnchor.Transparency = 1
ArrowAnchor.Size = Vector3.new(1, 1, 1)
ArrowAnchor.Parent = Workspace

-- Mengambil panah 3D (Union) milikmu dari ReplicatedStorage
local PanahTemplate = ReplicatedStorage:WaitForChild("panah", 10)
if not PanahTemplate then
	warn("Model 'panah' tidak ditemukan di ReplicatedStorage! Pastikan namanya persis 'panah' huruf kecil semua.")
	return CheckpointController
end

-- SIMPAN ROTASI ASLI DARI STUDIO
local baseRotation = PanahTemplate.CFrame.Rotation 

local ArrowPart = PanahTemplate:Clone()
ArrowPart.Name = "ClientCheckpointArrow"
ArrowPart.Anchored = true
ArrowPart.CanCollide = false
ArrowPart.Transparency = 1 -- Mulai dalam kondisi tidak terlihat (Fade Out)
ArrowPart.Parent = Workspace

-- Animasi Naik Turun (Bobbing) & Berputar (Spinning)
local tickOffset = 0
local spinSpeed = 3 -- Kecepatan putaran panah

RunService.RenderStepped:Connect(function(dt)
	tickOffset = tickOffset + dt
	local floatOffset = math.sin(tickOffset * 4) * 0.8 -- Kecepatan & tinggi naik-turun panah
	
	-- 1. Tentukan Posisi Baru
	local targetPosition = ArrowAnchor.Position + Vector3.new(0, 6 + floatOffset, 0)
	
	-- 2. Tentukan Putaran (Sumbu Y Dunia)
	local spinCFrame = CFrame.Angles(0, tickOffset * spinSpeed, 0)
	
	-- 3. Gabungkan Posisi + Putaran Baru + ROTASI ASLI Panahmu
	ArrowPart.CFrame = CFrame.new(targetPosition) * spinCFrame * baseRotation
end)

-- [[ FUNGSI HELPER PENGGERAK PANAH ]]
local moveTween = nil
local function moveArrowTo(targetPart)
	if not targetPart then
		-- Fade out panah (Hilang perlahan) jika mencapai Finish
		TweenService:Create(ArrowPart, TweenInfo.new(0.5), {Transparency = 1}):Play()
		return
	end
	
	-- Fade in (Muncul perlahan) jika sebelumnya tidak kelihatan
	if ArrowPart.Transparency > 0.5 then
		TweenService:Create(ArrowPart, TweenInfo.new(0.5), {Transparency = 0}):Play()
	end
	
	-- Animasi Geser Anchor ke CP Berikutnya (yang membuat panahnya ikut bergeser)
	if moveTween then moveTween:Cancel() end
	moveTween = TweenService:Create(ArrowAnchor, TweenInfo.new(0.8, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Position = targetPart.Position})
	moveTween:Play()
end

local function getNextCP(currentName)
	if not currentName then return Workspace:FindFirstChild("Checkpoints") and Workspace.Checkpoints:FindFirstChild("CP1") end
	local num = tonumber(currentName:match("^CP(%d+)$"))
	if num then
		local nextCP = Workspace.Checkpoints:FindFirstChild("CP" .. (num + 1))
		if nextCP then return nextCP end
		return Workspace.Checkpoints:FindFirstChild("FinishPart")
	end
	return nil
end


-- [[ FUNGSI UTAMA ]]
function CheckpointController.Init(networkRemotes)
	Remotes = networkRemotes
	
	local CheckpointsFolder = Workspace:WaitForChild("Checkpoints", 10)
	if not CheckpointsFolder then return end

	local function bindCheckpoint(cp)
		if cp:IsA("BasePart") then
			-- Simpan warna asli jika belum disimpan
			if not originalColors[cp] and (cp.Name:match("^CP") or cp.Name == "FinishPart") then
				originalColors[cp] = cp.Color
			end
			
			cp.Touched:Connect(function(hit)
				local char = hit.Parent
				if char and char == Players.LocalPlayer.Character then
					
					-- JIKA MENGINJAK RESET PART / START
					if cp.Name == "ResetPart" then
						-- 1. TELEPORT INSTAN DI SISI CLIENT (Anti Delay/Nyangkut)
						local root = char:FindFirstChild("HumanoidRootPart")
						if root then
							local spawnLoc = Workspace:FindFirstChildWhichIsA("SpawnLocation")
							local targetCFrame = spawnLoc and CFrame.new(spawnLoc.Position + Vector3.new(0, 3, 0)) or CFrame.new(0, 5, 0)
							
							-- Hentikan momentum jatuh agar karakter tidak nge-bug/mental
							root.AssemblyLinearVelocity = Vector3.zero
							root.AssemblyAngularVelocity = Vector3.zero
							root.CFrame = targetCFrame
						end

						-- 2. RESET VISUAL PANAH & WARNA
						if currentCheckpoint == nil then return end 
						currentCheckpoint = nil
						
						-- Kembalikan semua warna CP ke aslinya
						for part, color in pairs(originalColors) do
							TweenService:Create(part, TweenInfo.new(0.5), {Color = color}):Play()
						end
						
						local cp1 = CheckpointsFolder:FindFirstChild("CP1")
						if cp1 then
							ArrowAnchor.Position = cp1.Position
							moveArrowTo(cp1)
						end
						return
					end
					-- JIKA MENGINJAK CHECKPOINT / FINISH
					if cp.Name:match("^CP") or cp.Name == "FinishPart" then
						local touchedNum = tonumber(cp.Name:match("^CP(%d+)$")) or (cp.Name == "FinishPart" and 9999) or 0
						local currentNum = 0
						if currentCheckpoint then
							currentNum = tonumber(currentCheckpoint:match("^CP(%d+)$")) or (currentCheckpoint == "FinishPart" and 9999) or 0
						end
						
						if touchedNum > currentNum then
							currentCheckpoint = cp.Name
							Remotes.UpdateCheckpoint:FireServer(cp)
							
							-- Warnai CP yang terlewati jadi Hijau
							for i = currentNum + 1, touchedNum do
								local prevCP = CheckpointsFolder:FindFirstChild("CP" .. i)
								if prevCP then
									TweenService:Create(prevCP, TweenInfo.new(0.3), {Color = Color3.fromRGB(50, 255, 50)}):Play()
								end
							end
							
							if cp.Name == "FinishPart" then
								TweenService:Create(cp, TweenInfo.new(0.3), {Color = Color3.fromRGB(50, 255, 50)}):Play()
								FinishSound:Play()
								moveArrowTo(nil) 
							else
								CPSound:Play()
								local nextCP = getNextCP(cp.Name)
								moveArrowTo(nextCP) 
							end
						end
					end
					
				end
			end)
		end
	end

	for _, cp in ipairs(CheckpointsFolder:GetChildren()) do
		bindCheckpoint(cp)
	end
	CheckpointsFolder.ChildAdded:Connect(bindCheckpoint)
	
	-- Sinkronisasi saat player join
	task.spawn(function()
		task.wait(1) 
		local savedPos = Remotes.GetCheckpoint:InvokeServer()
		local startCP = nil
		
		if savedPos then
			for _, cp in ipairs(CheckpointsFolder:GetChildren()) do
				if cp:IsA("BasePart") and (cp.Position - savedPos).Magnitude < 1 then
					startCP = cp
					break
				end
			end
		end
		
		if startCP then
			currentCheckpoint = startCP.Name
			local touchedNum = tonumber(startCP.Name:match("^CP(%d+)$")) or (startCP.Name == "FinishPart" and 9999) or 0
			
			for i = 1, touchedNum do
				local prevCP = CheckpointsFolder:FindFirstChild("CP" .. i)
				if prevCP then
					prevCP.Color = Color3.fromRGB(50, 255, 50)
				end
			end
			
			if startCP.Name == "FinishPart" then
				startCP.Color = Color3.fromRGB(50, 255, 50)
				ArrowAnchor.Position = startCP.Position
				moveArrowTo(nil)
			else
				local nextCP = getNextCP(startCP.Name)
				if nextCP then
					ArrowAnchor.Position = startCP.Position
					moveArrowTo(nextCP) 
				end
			end
		else
			local cp1 = CheckpointsFolder:FindFirstChild("CP1")
			if cp1 then
				ArrowAnchor.Position = cp1.Position
				moveArrowTo(cp1)
			end
		end
	end)
end

return CheckpointController