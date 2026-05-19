local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")

local UfoController = {}
local LocalPlayer = Players.LocalPlayer

-- [[ KONFIGURASI MASING-MASING UFO ]]
local UfoSettings = {
	UFO1 = {
		DropPosition = Vector3.new(-20.5, 62.5, 592),
		LiftingTime = 2,
		MovingTime = 3,
		ReturnTime = 3,
		AnimationId = "rbxassetid://112089880074848", -- Ganti angka 0 dengan ID Animasi melayang kamu
	},
	UFO2 = {
		DropPosition = Vector3.new(-20.5, 62.5, 592),
		LiftingTime = 2,
		MovingTime = 3,
		ReturnTime = 3,
		AnimationId = "rbxassetid://112089880074848", -- Ganti angka 0 dengan ID Animasi melayang kamu
	}
	-- Tambahkan UFO3, UFO4 di sini jika ada...
}

-- Fungsi untuk mengerakkan seluruh Model UFO menggunakan Tween
local function tweenModel(model, targetCFrame, time)
	local cframeValue = Instance.new("CFrameValue")
	cframeValue.Value = model:GetPivot()
	
	local connection = cframeValue.Changed:Connect(function(newCf)
		model:PivotTo(newCf)
	end)
	
	local tween = TweenService:Create(cframeValue, TweenInfo.new(time, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut), {Value = targetCFrame})
	tween:Play()
	tween.Completed:Wait()
	
	connection:Disconnect()
	cframeValue:Destroy()
end

function UfoController.Init()
	local UfoFolder = workspace:WaitForChild("UfoFolder", 10)
	if not UfoFolder then return end

	-- Setup untuk setiap UFO yang ada di UfoFolder
	for _, ufoModel in ipairs(UfoFolder:GetChildren()) do
		if ufoModel:IsA("Model") then
			
			task.spawn(function()
				local config = UfoSettings[ufoModel.Name]
				if not config then return end 

				local lightFolder = ufoModel:WaitForChild("Light")
				local partAtas = lightFolder:WaitForChild("PartAtas")
				local partBawah = lightFolder:WaitForChild("PartBawah")
				
				local subUfo = ufoModel:WaitForChild("UFO")
				local deteksiPart = subUfo:WaitForChild("Deteksi")
				
				local beam = partAtas:WaitForChild("light") 
				local ufoSound = partAtas:FindFirstChild("UfoSound")
				
				local attAtas = partAtas:WaitForChild("Attachment")
				local attBawah = partBawah:WaitForChild("Attachment")
				
				-- Simpan data asli
				local originalPivot = ufoModel:GetPivot()
				local originalAttBawahPos = attBawah.Position
				local originalSoundVol = ufoSound and ufoSound.Volume or 1
				local isBusy = false
				
				-- Fungsi Animasi Cahaya
				local function animateLight(turnOn)
					if turnOn then
						attBawah.WorldPosition = attAtas.WorldPosition
						beam.Enabled = true
						local tween = TweenService:Create(attBawah, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Position = originalAttBawahPos})
						tween:Play()
						tween.Completed:Wait()
					else
						local tween = TweenService:Create(attBawah, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {WorldPosition = attAtas.WorldPosition})
						tween:Play()
						tween.Completed:Wait()
						beam.Enabled = false
						attBawah.Position = originalAttBawahPos
					end
				end

				while task.wait(0.5) do
					if isBusy then continue end
					
					local char = LocalPlayer.Character
					if char and char:FindFirstChild("HumanoidRootPart") and char:FindFirstChild("Humanoid") then
						local hrp = char.HumanoidRootPart
						local hum = char.Humanoid
						
						if hum.Health > 0 then
							local partsInArea = workspace:GetPartsInPart(deteksiPart)
							local playerInArea = false
							
							for _, part in ipairs(partsInArea) do
								if part:IsDescendantOf(char) then
									playerInArea = true
									break
								end
							end
							
							if playerInArea then
								isBusy = true
								
								-- Memutar Suara dengan efek Fade-In (suara perlahan membesar 1 detik)
								if ufoSound then
									ufoSound.Volume = 0
									ufoSound:Play()
									TweenService:Create(ufoSound, TweenInfo.new(1), {Volume = originalSoundVol}):Play()
								end
								
								-- Memutar Animasi Karakter (Jika ID-nya sudah kamu isi dan bukan 0)
								local animTrack = nil
								if config.AnimationId and config.AnimationId ~= "rbxassetid://0" then
									local animator = hum:FindFirstChildOfClass("Animator")
									if animator then
										local anim = Instance.new("Animation")
										anim.AnimationId = config.AnimationId
										animTrack = animator:LoadAnimation(anim)
										animTrack:Play()
									end
								end
								
								-- 1. Kunci Player
								hrp.Anchored = true
								
								-- 2. Tembakkan Cahaya
								animateLight(true)
								
								-- 3. Sedot Player
								local hoverPos = partBawah.Position:Lerp(partAtas.Position, 0.6)
								local hoverCFrame = CFrame.new(hoverPos) * hrp.CFrame.Rotation
								
								local liftTween = TweenService:Create(hrp, TweenInfo.new(config.LiftingTime, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {CFrame = hoverCFrame})
								liftTween:Play()
								liftTween.Completed:Wait()
								
								-- 4. Ikat Player ke UFO
								local weld = Instance.new("WeldConstraint")
								weld.Part0 = hrp
								weld.Part1 = partAtas
								weld.Parent = hrp
								hrp.Anchored = false 
								
								-- 5. Terbangkan UFO ke lokasi Drop
								local currentPivot = ufoModel:GetPivot()
								local offset = currentPivot.Position - partBawah.Position
								local targetPivotPos = config.DropPosition + offset
								
								local dropCFrame = CFrame.new(targetPivotPos) * originalPivot.Rotation
								tweenModel(ufoModel, dropCFrame, config.MovingTime)
								
								-- 6. Jatuhkan Player
								weld:Destroy()
								
								-- Hentikan Animasi
								if animTrack then
									animTrack:Stop(0.5) -- 0.5 detik transisi animasi kembali ke normal
									animTrack:Destroy()
								end
								
								-- Mematikan Suara dengan efek Fade-Out (suara perlahan mengecil 1 detik)
								if ufoSound then
									task.spawn(function()
										local fadeOut = TweenService:Create(ufoSound, TweenInfo.new(1), {Volume = 0})
										fadeOut:Play()
										fadeOut.Completed:Wait()
										ufoSound:Stop()
									end)
								end
								
								-- 7. Tarik Cahaya ke atas
								animateLight(false)
								
								-- 8. Kembalikan UFO ke Posisi Awal semula
								tweenModel(ufoModel, originalPivot, config.ReturnTime)
								
								task.wait(1)
								isBusy = false
							end
						end
					end
				end
			end)
			
		end
	end
end

return UfoController