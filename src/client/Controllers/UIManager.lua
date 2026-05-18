local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local Player = Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")

local UIManager = {}
local MainGui = nil

function UIManager.ApplyButtonAnimation(button)
	local TweenService = game:GetService("TweenService")
	local originalSize = button.Size
	local originalRotation = button.Rotation
	
	local hoverSound = button:FindFirstChild("HoverSound") or Instance.new("Sound")
	hoverSound.Name = "HoverSound"
	hoverSound.SoundId = "rbxassetid://6895079853"
	hoverSound.Volume = 0.2
	hoverSound.PlaybackSpeed = 1.2
	hoverSound.Parent = button
	
	local clickSound = button:FindFirstChild("ClickSound") or Instance.new("Sound")
	clickSound.Name = "ClickSound"
	clickSound.SoundId = "rbxassetid://6895079853"
	clickSound.Volume = 0.8
	clickSound.Parent = button
	
	button.MouseEnter:Connect(function()
		hoverSound:Play()
		TweenService:Create(button, TweenInfo.new(0.15, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
			Size = originalSize + UDim2.new(0, 6, 0, 6),
			Rotation = originalRotation + 2
		}):Play()
	end)
	
	button.MouseLeave:Connect(function()
		TweenService:Create(button, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			Size = originalSize,
			Rotation = originalRotation
		}):Play()
	end)
	
	button.MouseButton1Down:Connect(function()
		clickSound:Play()
		TweenService:Create(button, TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			Size = originalSize - UDim2.new(0, 3, 0, 3),
			Rotation = originalRotation - 2
		}):Play()
	end)
	
	button.MouseButton1Up:Connect(function()
		TweenService:Create(button, TweenInfo.new(0.15, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
			Size = originalSize + UDim2.new(0, 6, 0, 6),
			Rotation = originalRotation + 2
		}):Play()
	end)
	
	-- Reset otomatis kalau GUI disembunyikan (untuk mencegah bug nyangkut efek membesar)
	local screenGui = button:FindFirstAncestorOfClass("ScreenGui")
	if screenGui then
		screenGui:GetPropertyChangedSignal("Enabled"):Connect(function()
			if not screenGui.Enabled then
				TweenService:Create(button, TweenInfo.new(0), {
					Size = originalSize,
					Rotation = originalRotation
				}):Play()
			end
		end)
	end
	
	-- Reset tambahan kalau parent langsungnya disembunyikan (seperti ConfirmationFrame)
	if button.Parent and button.Parent:IsA("GuiObject") then
		button.Parent:GetPropertyChangedSignal("Visible"):Connect(function()
			if not button.Parent.Visible then
				TweenService:Create(button, TweenInfo.new(0), {
					Size = originalSize,
					Rotation = originalRotation
				}):Play()
			end
		end)
	end
end

function UIManager.ApplyShakeEffect(guiObj)
	if not guiObj then return end
	local TweenService = game:GetService("TweenService")
	local originalRotation = guiObj.Rotation
	
	task.spawn(function()
		while true do
			if not guiObj or not guiObj.Parent then break end
			
			if guiObj:GetAttribute("DisableShake") then
				guiObj.Rotation = originalRotation
				task.wait(1)
				continue
			end
			
			-- 0.1 di sini adalah KECEPATAN getarnya. Semakin besar angkanya, semakin lambat. (Sebelumnya 0.05)
			local tInfo = TweenInfo.new(0.1, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, 1, true)
			
			local t1 = TweenService:Create(guiObj, tInfo, {Rotation = originalRotation + 15})
			t1:Play()
			t1.Completed:Wait()
			if not guiObj or not guiObj.Parent or guiObj:GetAttribute("DisableShake") then continue end
			
			local t2 = TweenService:Create(guiObj, tInfo, {Rotation = originalRotation - 15})
			t2:Play()
			t2.Completed:Wait()
			if not guiObj or not guiObj.Parent or guiObj:GetAttribute("DisableShake") then continue end
			
			t1:Play()
			t1.Completed:Wait()
			if not guiObj or not guiObj.Parent or guiObj:GetAttribute("DisableShake") then continue end
			
			t2:Play()
			t2.Completed:Wait()
			
			-- Wait 5 seconds, checking periodically if disabled
			for i = 1, 10 do
				if not guiObj or not guiObj.Parent or guiObj:GetAttribute("DisableShake") then break end
				task.wait(0.5)
			end
		end
	end)
end

function UIManager.AnimateFrameIn(frame)
	if not frame then return end
	frame.Visible = true
	
	local TweenService = game:GetService("TweenService")
	local uiScale = frame:FindFirstChild("UIScale")
	if not uiScale then
		uiScale = Instance.new("UIScale")
		uiScale.Parent = frame
	end
	
	uiScale.Scale = 0
	TweenService:Create(uiScale, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Scale = 1}):Play()
	
	-- Fade main background
	local origBg = frame:GetAttribute("OrigBgTrans")
	if not origBg then
		origBg = frame.BackgroundTransparency
		frame:SetAttribute("OrigBgTrans", origBg)
	end
	frame.BackgroundTransparency = 1
	TweenService:Create(frame, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {BackgroundTransparency = origBg}):Play()
end

function UIManager.AnimateFrameOut(frame, onComplete)
	if not frame then return end
	
	local TweenService = game:GetService("TweenService")
	local uiScale = frame:FindFirstChild("UIScale")
	if not uiScale then
		uiScale = Instance.new("UIScale")
		uiScale.Parent = frame
	end
	
	local tween = TweenService:Create(uiScale, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {Scale = 0})
	tween:Play()
	
	local origBg = frame:GetAttribute("OrigBgTrans")
	if origBg then
		TweenService:Create(frame, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {BackgroundTransparency = 1}):Play()
	end
	
	local connection
	connection = tween.Completed:Connect(function()
		connection:Disconnect()
		frame.Visible = false
		if onComplete then onComplete() end
	end)
end

local function makeRounded(guiObj, radius)
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, radius or 8)
	corner.Parent = guiObj
end

local function makeShadow(guiObj)
	local stroke = Instance.new("UIStroke")
	stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	stroke.Color = Color3.fromRGB(0, 0, 0)
	stroke.Transparency = 0.5
	stroke.Thickness = 2
	stroke.Parent = guiObj
end

function UIManager.CreateUI()
	local Gui = Instance.new("ScreenGui")
	Gui.Name = "NotificationGui"
	Gui.ResetOnSpawn = false
	Gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	
	-- UI Scale
	local uiScale = Instance.new("UIScale")
	uiScale.Parent = Gui
	local function updateScale()
		local viewport = workspace.CurrentCamera.ViewportSize
		local ratio = viewport.X / 1366
		uiScale.Scale = math.clamp(ratio, 0.6, 1.2)
	end
	workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(updateScale)
	updateScale()
	
	-- Factory for Panels
	local function createPanel(name, size, pos, parent)
		local panel = Instance.new("Frame")
		panel.Name = name
		panel.Size = size
		panel.Position = pos
		panel.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
		panel.BorderSizePixel = 0
		makeRounded(panel, 12)
		makeShadow(panel)
		panel.Parent = parent
		return panel
	end
	
	-- Factory for Buttons
	local function createButton(name, text, size, pos, color, parent)
		local btn = Instance.new("TextButton")
		btn.Name = name
		btn.Size = size
		btn.Position = pos
		btn.Text = text
		btn.Font = Enum.Font.GothamBold
		btn.TextSize = 14
		btn.TextColor3 = Color3.new(1,1,1)
		btn.BackgroundColor3 = color
		btn.AutoButtonColor = false
		makeRounded(btn, 8)
		UIManager.ApplyButtonAnimation(btn)
		btn.Parent = parent
		return btn
	end

	-- Factory for TextBox
	local function createInput(name, placeholder, size, pos, parent)
		local box = Instance.new("TextBox")
		box.Name = name
		box.Size = size
		box.Position = pos
		box.PlaceholderText = placeholder
		box.Text = ""
		box.Font = Enum.Font.GothamSemibold
		box.TextSize = 14
		box.TextColor3 = Color3.new(1,1,1)
		box.BackgroundColor3 = Color3.fromRGB(45, 45, 50)
		makeRounded(box, 8)
		box.Parent = parent
		return box
	end
	
	local AdminBtn = createButton("AdminBtn", "ADMIN PANEL", UDim2.new(0, 140, 0, 45), UDim2.new(0, 20, 0.5, 5), Color3.fromRGB(50, 200, 100), Gui)
	AdminBtn.Visible = false
	
	local CPNotif = Instance.new("TextLabel")
	CPNotif.Name = "CPNotif"
	CPNotif.Size = UDim2.new(0, 250, 0, 40)
	CPNotif.Position = UDim2.new(0.5, -125, 0, -50) -- Offscreen top
	CPNotif.Text = "Checkpoint Saved!"
	CPNotif.Font = Enum.Font.GothamBold
	CPNotif.TextSize = 16
	CPNotif.BackgroundColor3 = Color3.fromRGB(40, 200, 80)
	CPNotif.TextColor3 = Color3.new(1, 1, 1)
	CPNotif.Visible = false
	makeRounded(CPNotif, 8)
	makeShadow(CPNotif)
	CPNotif.Parent = Gui

	-- Checkpoint Popup
	local CheckpointPopup = createPanel("CheckpointPopup", UDim2.new(0, 320, 0, 160), UDim2.new(0.5, -160, -0.5, 0), Gui)
	CheckpointPopup.Visible = false
	
	local CPLabel = Instance.new("TextLabel")
	CPLabel.Name = "Label"
	CPLabel.Size = UDim2.new(1, 0, 0, 60)
	CPLabel.Text = "You fell!\nTeleport to checkpoint?"
	CPLabel.Font = Enum.Font.GothamBold
	CPLabel.TextSize = 18
	CPLabel.TextColor3 = Color3.new(1,1,1)
	CPLabel.BackgroundTransparency = 1
	CPLabel.Parent = CheckpointPopup
	
	local YesBtn = createButton("YesBtn", "Yes", UDim2.new(0, 80, 0, 40), UDim2.new(0, 15, 0, 100), Color3.fromRGB(50, 150, 50), CheckpointPopup)
	local SkipBtn = createButton("SkipBtn", "Skip(5R$)", UDim2.new(0, 100, 0, 40), UDim2.new(0.5, -50, 0, 100), Color3.fromRGB(220, 150, 0), CheckpointPopup)
	local NoBtn = createButton("NoBtn", "No", UDim2.new(0, 80, 0, 40), UDim2.new(1, -95, 0, 100), Color3.fromRGB(150, 50, 50), CheckpointPopup)
	

	
	-- AdminPanel
	local AdminPanel = createPanel("AdminPanel", UDim2.new(0, 300, 0, 180), UDim2.new(0.5, -150, -0.5, 0), Gui)
	AdminPanel.Visible = false
	
	local AdminTitle = Instance.new("TextLabel")
	AdminTitle.Size = UDim2.new(1, 0, 0, 30)
	AdminTitle.Text = "ADMIN PANEL"
	AdminTitle.Font = Enum.Font.GothamBlack
	AdminTitle.TextColor3 = Color3.new(1,1,1)
	AdminTitle.BackgroundTransparency = 1
	AdminTitle.Parent = AdminPanel
	
	local AdminIdInput = createInput("AdminIdInput", "Target UserId", UDim2.new(1, -30, 0, 40), UDim2.new(0, 15, 0, 35), AdminPanel)
	local AddAdminBtn = createButton("AddAdminBtn", "Add", UDim2.new(0.5, -20, 0, 40), UDim2.new(0, 15, 0, 85), Color3.fromRGB(50, 180, 80), AdminPanel)
	local RemoveAdminBtn = createButton("RemoveAdminBtn", "Remove", UDim2.new(0.5, -20, 0, 40), UDim2.new(0.5, 5, 0, 85), Color3.fromRGB(200, 60, 60), AdminPanel)
	local CloseAdminBtn = createButton("CloseBtn", "Close", UDim2.new(1, -30, 0, 35), UDim2.new(0, 15, 0, 135), Color3.fromRGB(80, 80, 90), AdminPanel)
	
	-- Jumpscare Gui (Separate to IgnoreGuiInset)
	local JumpscareGui = Instance.new("ScreenGui")
	JumpscareGui.Name = "JumpscareGui"
	JumpscareGui.ResetOnSpawn = false
	JumpscareGui.IgnoreGuiInset = true -- Makes it truly fullscreen, covering top bar
	JumpscareGui.DisplayOrder = 100
	JumpscareGui.Enabled = false
	JumpscareGui.Parent = PlayerGui
	
	local JumpscareImage = Instance.new("ImageLabel")
	JumpscareImage.Name = "JumpscareImage"
	JumpscareImage.Size = UDim2.new(1, 0, 1, 0)
	JumpscareImage.BackgroundTransparency = 1
	JumpscareImage.Image = "rbxthumb://type=Asset&id=1308665113&w=420&h=420"
	JumpscareImage.ScaleType = Enum.ScaleType.Stretch
	JumpscareImage.Parent = JumpscareGui
	
	local JumpscareSound = Instance.new("Sound")
	JumpscareSound.Name = "JumpscareSound"
	JumpscareSound.SoundId = "rbxassetid://139162107746216"
	JumpscareSound.Volume = 2
	JumpscareSound.Parent = JumpscareGui
	
	Gui.Parent = PlayerGui
	MainGui = Gui
	return Gui
end

function UIManager.GetGui()
	return MainGui or UIManager.CreateUI()
end

function UIManager.TweenPanelIn(panel, targetPos)
	panel.Visible = true
	TweenService:Create(panel, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Position = targetPos}):Play()
end

function UIManager.TweenPanelOut(panel, offscreenPos)
	local tween = TweenService:Create(panel, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {Position = offscreenPos})
	tween:Play()
	-- Do not set visible false immediately, wait for tween
end

function UIManager.CreatePlayerListButton(player, parent, clickCallback)
	local originalColor = Color3.fromRGB(45, 45, 50)
	local btn = Instance.new("TextButton")
	btn.Name = "Player_" .. player.UserId
	btn.Size = UDim2.new(1, -10, 0, 35)
	btn.Text = player.Name
	btn.Font = Enum.Font.GothamMedium
	btn.TextSize = 14
	btn.TextColor3 = Color3.new(1,1,1)
	btn.BackgroundColor3 = originalColor
	btn.AutoButtonColor = false
	
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 6)
	corner.Parent = btn
	
	local hoverColor = Color3.fromRGB(65, 65, 75)
	btn.MouseEnter:Connect(function()
		TweenService:Create(btn, TweenInfo.new(0.15), {BackgroundColor3 = hoverColor}):Play()
	end)
	btn.MouseLeave:Connect(function()
		TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = originalColor}):Play()
	end)
	
	btn.MouseButton1Click:Connect(clickCallback)
	btn.Parent = parent
	return btn
end 

-- Shared active notification list
local activeNotifications = {}

-- isError = true → merah (korban troll / error)
-- isError = false → hijau (berhasil troll / upgrade sukses)
function UIManager.ShowNotification(message, isError)
	local PlayerGui = Players.LocalPlayer:WaitForChild("PlayerGui")
	local NotificationGui = PlayerGui:FindFirstChild("NotificationGui")
	if not NotificationGui then return end
	
	local NotifikasiFrame = NotificationGui:FindFirstChild("NotifikasiFrame")
	if not NotifikasiFrame then return end
	
	local Template = NotifikasiFrame:FindFirstChild("MainFrame")
	if not Template then return end
	
	-- Clone template untuk setiap notifikasi
	local clone = Template:Clone()
	clone.Name = "NotifClone"
	
	local textLabel = clone:FindFirstChild("TextLabel")
	local gradient = clone:FindFirstChild("UIGradient")
	
	if textLabel then
		textLabel.Text = message
	end
	
	if gradient then
		if isError then
			-- Merah: untuk korban troll / error
			gradient.Color = ColorSequence.new{
				ColorSequenceKeypoint.new(0, Color3.fromRGB(200, 50, 50)),
				ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 100, 100))
			}
		else
			-- Hijau: untuk berhasil troll / upgrade sukses
			gradient.Color = ColorSequence.new{
				ColorSequenceKeypoint.new(0, Color3.fromRGB(50, 180, 50)),
				ColorSequenceKeypoint.new(1, Color3.fromRGB(100, 255, 100))
			}
		end
	end
	
	clone.Visible = true
	clone.Parent = NotifikasiFrame
	
	table.insert(activeNotifications, clone)
	
	-- Batasi maks 3 notifikasi sekaligus
	if #activeNotifications > 3 then
		local oldest = table.remove(activeNotifications, 1)
		if oldest and oldest.Parent then
			oldest:Destroy()
		end
	end
	
	-- Auto-hilang setelah 3 detik
	task.delay(3, function()
		if clone and clone.Parent then
			local index = table.find(activeNotifications, clone)
			if index then
				table.remove(activeNotifications, index)
			end
			clone:Destroy()
		end
	end)
end

return UIManager
