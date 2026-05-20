local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SoundService = game:GetService("SoundService")
local Lighting = game:GetService("Lighting")

local SettingController = {}
local UIManager = require(script.Parent.UIManager)

-- [BARU]: Require module TopbarPlus dari ReplicatedStorage
local Icon = require(ReplicatedStorage:WaitForChild("Icon"))

function SettingController.Init()
	local player = Players.LocalPlayer
	local playerGui = player:WaitForChild("PlayerGui")
	
	-- ==========================================
	-- 1. REFERENSI UI SETTING
	-- ==========================================
	local settingGui = playerGui:WaitForChild("SettingGui")
	
	-- settingBtn lama sudah TIDAK DIPAKAI, Anda bisa menghapusnya dari StarterGui
	
	local settingFrame = settingGui:WaitForChild("SettingFrame")
	local mainFrame = settingFrame:WaitForChild("MainFrame")
	local titleFrame = mainFrame:WaitForChild("TitleFrame")
	local closeBtn = titleFrame:WaitForChild("CloseBtn")
	
	local scroll = mainFrame:WaitForChild("ScrollingFrame")
	local hideUiBtn = scroll:WaitForChild("HideUiFrame"):WaitForChild("Button")
	local musicBtn = scroll:WaitForChild("MusicFrame"):WaitForChild("Button")
	local shadowBtn = scroll:WaitForChild("ShadowFrame"):WaitForChild("Button")
	
	-- Terapkan animasi tombol bawaan UIManager
	UIManager.ApplyButtonAnimation(closeBtn)
	UIManager.ApplyButtonAnimation(hideUiBtn)
	UIManager.ApplyButtonAnimation(musicBtn)
	UIManager.ApplyButtonAnimation(shadowBtn)
	
	-- ==========================================
	-- 2. SETUP AUDIO BGM
	-- ==========================================
	local originalMusic = ReplicatedStorage:WaitForChild("Sound"):WaitForChild("Music")
	local bgm = originalMusic:Clone()
	bgm.Parent = SoundService
	bgm.Looped = true
	bgm.Volume = 0.5
	bgm:Play()
	
	-- ==========================================
	-- 3. STATE & FUNGSI UPDATE VISUAL (TEXTLABEL & GRADIENT)
	-- ==========================================
	local states = {
		HideUI = false, 
		Music = true,
		Shadow = true
	}
	
	local function updateBtnVisual(btn, isOn)
		local gradient = btn:FindFirstChild("UIGradient")
		if not gradient then
			gradient = Instance.new("UIGradient")
			gradient.Parent = btn
		end
		
		local textLabel = btn:FindFirstChild("TextLabel")
		btn.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		
		if isOn then
			if textLabel then textLabel.Text = "ON" end
			gradient.Color = ColorSequence.new({
				ColorSequenceKeypoint.new(0, Color3.fromRGB(50, 220, 50)),
				ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 130, 0))
			})
		else
			if textLabel then textLabel.Text = "OFF" end
			gradient.Color = ColorSequence.new({
				ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 80, 80)),
				ColorSequenceKeypoint.new(1, Color3.fromRGB(150, 0, 0))
			})
		end
	end
	
	updateBtnVisual(hideUiBtn, not states.HideUI)
	updateBtnVisual(musicBtn, states.Music)
	updateBtnVisual(shadowBtn, states.Shadow)
	
	-- ==========================================
	-- 4. LOGIKA TOMBOL BUKA/TUTUP SETTING (TOPBAR PLUS)
	-- ==========================================
	local isMenuOpen = false
	
	-- Membuat ikon TopbarPlus baru
	local settingIcon = Icon.new()
		-- Ganti AssetId ini dengan icon gear/setting yang Anda inginkan
		:setImage("rbxassetid://118656083426261") 
		:setRight() -- Opsional: Menempatkan ikon di sebelah kanan (sebaris dengan menu Roblox)
		
	-- Saat Ikon diklik (Aktif)
	settingIcon:bindEvent("selected", function()
		isMenuOpen = true
		settingFrame.Visible = true
		UIManager.AnimateFrameIn(mainFrame)
	end)
	
	-- Saat Ikon diklik lagi (Nonaktif)
	settingIcon:bindEvent("deselected", function()
		isMenuOpen = false
		UIManager.AnimateFrameOut(mainFrame, function()
			if not isMenuOpen then settingFrame.Visible = false end
		end)
	end)
	
	-- Integrasi tombol Close bawaan UI
	closeBtn.MouseButton1Click:Connect(function()
		-- Memanggil method deselect() secara manual agar state Icon di Topbar ikut mati
		settingIcon:deselect() 
	end)
	
	-- ==========================================
	-- 5. LOGIKA SISTEM
	-- ==========================================
	hideUiBtn.MouseButton1Click:Connect(function()
		states.HideUI = not states.HideUI
		updateBtnVisual(hideUiBtn, not states.HideUI) 
		
		if states.HideUI then
			UIManager.HideAllGameplayHUD(playerGui)
		else
			UIManager.ShowAllGameplayHUD(playerGui)
		end
	end)
	
	musicBtn.MouseButton1Click:Connect(function()
		states.Music = not states.Music
		updateBtnVisual(musicBtn, states.Music)
		if states.Music then bgm:Resume() else bgm:Pause() end
	end)
	
	shadowBtn.MouseButton1Click:Connect(function()
		states.Shadow = not states.Shadow
		updateBtnVisual(shadowBtn, states.Shadow)
		Lighting.GlobalShadows = states.Shadow
	end)
	
end

return SettingController