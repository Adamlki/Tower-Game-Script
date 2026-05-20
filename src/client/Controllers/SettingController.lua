local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SoundService = game:GetService("SoundService")
local Lighting = game:GetService("Lighting")

local SettingController = {}
local UIManager = require(script.Parent.UIManager)

function SettingController.Init()
	local player = Players.LocalPlayer
	local playerGui = player:WaitForChild("PlayerGui")
	
	-- ==========================================
	-- 1. REFERENSI UI SETTING
	-- ==========================================
	local settingGui = playerGui:WaitForChild("SettingGui")
	local settingBtn = settingGui:WaitForChild("SettingBtn")
	
	local settingFrame = settingGui:WaitForChild("SettingFrame")
	local mainFrame = settingFrame:WaitForChild("MainFrame")
	local titleFrame = mainFrame:WaitForChild("TitleFrame")
	local closeBtn = titleFrame:WaitForChild("CloseBtn")
	
	local scroll = mainFrame:WaitForChild("ScrollingFrame")
	local hideUiBtn = scroll:WaitForChild("HideUiFrame"):WaitForChild("Button")
	local musicBtn = scroll:WaitForChild("MusicFrame"):WaitForChild("Button")
	local shadowBtn = scroll:WaitForChild("ShadowFrame"):WaitForChild("Button")
	
	-- Terapkan animasi tombol bawaan UIManager
	UIManager.ApplyButtonAnimation(settingBtn)
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
		-- Cari UIGradient di dalam Button, buat otomatis kalau belum ada
		local gradient = btn:FindFirstChild("UIGradient")
		if not gradient then
			gradient = Instance.new("UIGradient")
			gradient.Parent = btn
		end
		
		-- Cari TextLabel di dalam tombol tersebut
		local textLabel = btn:FindFirstChild("TextLabel")
		
		-- Set Background ke Putih agar warna gradasi bisa keluar sempurna
		btn.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		
		if isOn then
			-- Ubah teks di TextLabel
			if textLabel then
				textLabel.Text = "ON"
			end
			-- Gradasi Hijau
			gradient.Color = ColorSequence.new({
				ColorSequenceKeypoint.new(0, Color3.fromRGB(50, 220, 50)),
				ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 130, 0))
			})
		else
			-- Ubah teks di TextLabel
			if textLabel then
				textLabel.Text = "OFF"
			end
			-- Gradasi Merah
			gradient.Color = ColorSequence.new({
				ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 80, 80)),
				ColorSequenceKeypoint.new(1, Color3.fromRGB(150, 0, 0))
			})
		end
	end
	
	-- Setel visual awal saat masuk game
	updateBtnVisual(hideUiBtn, not states.HideUI)
	updateBtnVisual(musicBtn, states.Music)
	updateBtnVisual(shadowBtn, states.Shadow)
	
	-- ==========================================
	-- 4. LOGIKA TOMBOL BUKA/TUTUP SETTING
	-- ==========================================
	local isMenuOpen = false
	settingBtn.MouseButton1Click:Connect(function()
		isMenuOpen = not isMenuOpen
		if isMenuOpen then
			settingFrame.Visible = true
			UIManager.AnimateFrameIn(mainFrame)
		else
			UIManager.AnimateFrameOut(mainFrame, function()
				if not isMenuOpen then settingFrame.Visible = false end
			end)
		end
	end)
	
	closeBtn.MouseButton1Click:Connect(function()
		if isMenuOpen then
			isMenuOpen = false
			UIManager.AnimateFrameOut(mainFrame, function()
				if not isMenuOpen then settingFrame.Visible = false end
			end)
		end
	end)
	
	-- ==========================================
	-- 5. LOGIKA SISTEM
	-- ==========================================
	
	-- A. HIDE UI
	hideUiBtn.MouseButton1Click:Connect(function()
		states.HideUI = not states.HideUI
		updateBtnVisual(hideUiBtn, not states.HideUI) 
		
		if states.HideUI then
			UIManager.HideAllGameplayHUD(playerGui)
		else
			UIManager.ShowAllGameplayHUD(playerGui)
		end
	end)
	
	-- B. MUSIC ON/OFF
	musicBtn.MouseButton1Click:Connect(function()
		states.Music = not states.Music
		updateBtnVisual(musicBtn, states.Music)
		
		if states.Music then
			bgm:Resume()
		else
			bgm:Pause()
		end
	end)
	
	-- C. GLOBAL SHADOW ON/OFF
	shadowBtn.MouseButton1Click:Connect(function()
		states.Shadow = not states.Shadow
		updateBtnVisual(shadowBtn, states.Shadow)
		Lighting.GlobalShadows = states.Shadow
	end)
	
end

return SettingController