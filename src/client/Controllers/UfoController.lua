local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local Config = require(game:GetService("ReplicatedStorage"):WaitForChild("Shared"):WaitForChild("Config"))

local UfoController = {}
local LocalPlayer = Players.LocalPlayer

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

	for _, ufoModel in ipairs(UfoFolder:GetChildren()) do
		if ufoModel:IsA("Model") then
			task.spawn(function()
				local config = Config.UfoSettings[ufoModel.Name] -- Membaca dari Shared Config
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
				
				local originalPivot = ufoModel:GetPivot()
				local originalAttBawahPos = attBawah.Position
				local originalSoundVol = ufoSound and ufoSound.Volume or 1
				local isBusy = false
				
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
								
								if ufoSound then
									ufoSound.Volume = 0
									ufoSound:Play()
									TweenService:Create(ufoSound, TweenInfo.new(1), {Volume = originalSoundVol}):Play()
								end
								
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
								
								hrp.Anchored = true
								animateLight(true)
								
								local hoverPos = partBawah.Position:Lerp(partAtas.Position, 0.6)
								local hoverCFrame = CFrame.new(hoverPos) * hrp.CFrame.Rotation
								
								local liftTween = TweenService:Create(hrp, TweenInfo.new(config.LiftingTime, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {CFrame = hoverCFrame})
								liftTween:Play()
								liftTween.Completed:Wait()
								
								local weld = Instance.new("WeldConstraint")
								weld.Part0 = hrp
								weld.Part1 = partAtas
								weld.Parent = hrp
								hrp.Anchored = false 
								
								local currentPivot = ufoModel:GetPivot()
								local offset = currentPivot.Position - partBawah.Position
								local targetPivotPos = config.DropPosition + offset
								
								local dropCFrame = CFrame.new(targetPivotPos) * originalPivot.Rotation
								tweenModel(ufoModel, dropCFrame, config.MovingTime)
								
								weld:Destroy()
								
								if animTrack then
									animTrack:Stop(0.5)
									animTrack:Destroy()
								end
								
								if ufoSound then
									task.spawn(function()
										local fadeOut = TweenService:Create(ufoSound, TweenInfo.new(1), {Volume = 0})
										fadeOut:Play()
										fadeOut.Completed:Wait()
										ufoSound:Stop()
									end)
								end
								
								animateLight(false)
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