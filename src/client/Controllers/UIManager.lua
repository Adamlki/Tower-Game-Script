local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local Player = Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")

local UIManager = {}
local MainGui = nil

-- Utility for animations
local function applyHoverAnim(button)
	local originalSize = button.Size
	local originalColor = button.BackgroundColor3
	local h, s, v = Color3.toHSV(originalColor)
	local hoverColor = Color3.fromHSV(h, s, math.clamp(v + 0.2, 0, 1))
	
	button.MouseEnter:Connect(function()
		TweenService:Create(button, TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			BackgroundColor3 = hoverColor,
			Size = originalSize + UDim2.new(0, 4, 0, 4),
			Position = button.Position - UDim2.new(0, 2, 0, 2)
		}):Play()
	end)
	
	button.MouseLeave:Connect(function()
		TweenService:Create(button, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			BackgroundColor3 = originalColor,
			Size = originalSize,
			Position = button.Position + UDim2.new(0, 2, 0, 2)
		}):Play()
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
	Gui.Name = "TowerGameGui"
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
		applyHoverAnim(btn)
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
	
	-- MainHUD
	local MainHUD = Instance.new("Frame")
	MainHUD.Name = "MainHUD"
	MainHUD.Size = UDim2.new(1, 0, 1, 0)
	MainHUD.BackgroundTransparency = 1
	MainHUD.Parent = Gui
	
	local TrollBtn = createButton("TrollBtn", "TROLL MENU", UDim2.new(0, 140, 0, 45), UDim2.new(0, 20, 0.5, -50), Color3.fromRGB(220, 50, 50), MainHUD)
	local AdminBtn = createButton("AdminBtn", "ADMIN PANEL", UDim2.new(0, 140, 0, 45), UDim2.new(0, 20, 0.5, 5), Color3.fromRGB(50, 200, 100), MainHUD)
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
	CPNotif.Parent = MainHUD
	
	-- TrollPanel
	local TrollPanel = createPanel("TrollPanel", UDim2.new(0, 220, 0, 500), UDim2.new(1, 50, 0.5, -250), Gui) -- Offscreen right
	TrollPanel.BackgroundTransparency = 0.05
	
	local TrollTitle = Instance.new("TextLabel")
	TrollTitle.Size = UDim2.new(1, 0, 0, 40)
	TrollTitle.Text = "SELECT TROLL"
	TrollTitle.Font = Enum.Font.GothamBlack
	TrollTitle.TextSize = 16
	TrollTitle.TextColor3 = Color3.new(1,1,1)
	TrollTitle.BackgroundTransparency = 1
	TrollTitle.Parent = TrollPanel
	
	local TrollButtons = Instance.new("ScrollingFrame")
	TrollButtons.Name = "TrollButtons"
	TrollButtons.Size = UDim2.new(1, -20, 1, -50)
	TrollButtons.Position = UDim2.new(0, 10, 0, 40)
	TrollButtons.BackgroundTransparency = 1
	TrollButtons.ScrollBarThickness = 1
	TrollButtons.CanvasSize = UDim2.new(0, 0, 0, 0)
	TrollButtons.AutomaticCanvasSize = Enum.AutomaticSize.Y
	TrollButtons.Parent = TrollPanel
	
	local layout = Instance.new("UIListLayout")
	layout.Padding = UDim.new(0, 5)
	layout.Parent = TrollButtons
	
	local trolls = {"Kill", "Fling", "Kick", "Slow", "Earthquake", "Jumpscare", "Freeze", "SetFire", "KillAll", "SlowAll"}
	for i, t in ipairs(trolls) do
		local btn = createButton(t .. "Btn", t, UDim2.new(1, 0, 0, 35), UDim2.new(), Color3.fromRGB(180, 50, 50), TrollButtons)
	end
	
	-- JumpPanel
	local JumpPanel = createPanel("JumpPanel", UDim2.new(0, 200, 0, 160), UDim2.new(0, 20, 0.5, 60), Gui)
	
	local JumpTitle = Instance.new("TextLabel")
	JumpTitle.Size = UDim2.new(1, 0, 0, 30)
	JumpTitle.Text = "JUMP UPGRADES"
	JumpTitle.Font = Enum.Font.GothamBlack
	JumpTitle.TextColor3 = Color3.new(1,1,1)
	JumpTitle.BackgroundTransparency = 1
	JumpTitle.Parent = JumpPanel
	
	local BuyJumpBtn = createButton("BuyBtn", "Buy Jump", UDim2.new(1, -20, 0, 35), UDim2.new(0, 10, 0, 35), Color3.fromRGB(0, 150, 220), JumpPanel)
	local JumpInput = createInput("JumpInput", "Count", UDim2.new(0, 80, 0, 35), UDim2.new(0, 10, 0, 80), JumpPanel)
	local ApplyJumpBtn = createButton("ApplyBtn", "Apply", UDim2.new(0, 85, 0, 35), UDim2.new(1, -95, 0, 80), Color3.fromRGB(0, 180, 100), JumpPanel)
	
	local JumpInfo = Instance.new("TextLabel")
	JumpInfo.Name = "JumpInfo"
	JumpInfo.Size = UDim2.new(1, -20, 0, 25)
	JumpInfo.Position = UDim2.new(0, 10, 0, 125)
	JumpInfo.Text = "Max Jump: 1"
	JumpInfo.Font = Enum.Font.GothamMedium
	JumpInfo.TextColor3 = Color3.fromRGB(200, 200, 200)
	JumpInfo.BackgroundTransparency = 1
	JumpInfo.Parent = JumpPanel
	
	-- Spectate UI
	local SpectateUI = createPanel("SpectateUI", UDim2.new(0, 350, 0, 60), UDim2.new(0.5, -175, 1, 50), Gui) -- Offscreen bottom
	
	local PrevBtn = createButton("PrevBtn", "◀", UDim2.new(0, 50, 0, 40), UDim2.new(0, 10, 0.5, -20), Color3.fromRGB(60, 60, 70), SpectateUI)
	local NextBtn = createButton("NextBtn", "▶", UDim2.new(0, 50, 0, 40), UDim2.new(1, -60, 0.5, -20), Color3.fromRGB(60, 60, 70), SpectateUI)
	
	local PlayerNameLabel = Instance.new("TextLabel")
	PlayerNameLabel.Name = "PlayerNameLabel"
	PlayerNameLabel.Size = UDim2.new(1, -120, 1, 0)
	PlayerNameLabel.Position = UDim2.new(0, 60, 0, 0)
	PlayerNameLabel.Text = "Spectating..."
	PlayerNameLabel.Font = Enum.Font.GothamBold
	PlayerNameLabel.TextSize = 18
	PlayerNameLabel.TextColor3 = Color3.new(1,1,1)
	PlayerNameLabel.BackgroundTransparency = 1
	PlayerNameLabel.Parent = SpectateUI
	
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
	
	-- Troll Confirm Popup
	local TrollConfirmPopup = createPanel("TrollConfirmPopup", UDim2.new(0, 320, 0, 160), UDim2.new(0.5, -160, -0.5, 0), Gui)
	TrollConfirmPopup.Visible = false
	
	local TrollConfirmLabel = Instance.new("TextLabel")
	TrollConfirmLabel.Name = "Label"
	TrollConfirmLabel.Size = UDim2.new(1, -20, 0, 80)
	TrollConfirmLabel.Position = UDim2.new(0, 10, 0, 10)
	TrollConfirmLabel.Text = "Are you sure?"
	TrollConfirmLabel.Font = Enum.Font.GothamBold
	TrollConfirmLabel.TextSize = 16
	TrollConfirmLabel.TextWrapped = true
	TrollConfirmLabel.TextColor3 = Color3.new(1,1,1)
	TrollConfirmLabel.BackgroundTransparency = 1
	TrollConfirmLabel.Parent = TrollConfirmPopup
	
	local TrollYesBtn = createButton("YesBtn", "Yes", UDim2.new(0, 100, 0, 40), UDim2.new(0, 30, 0, 100), Color3.fromRGB(50, 150, 50), TrollConfirmPopup)
	local TrollNoBtn = createButton("NoBtn", "No", UDim2.new(0, 100, 0, 40), UDim2.new(1, -130, 0, 100), Color3.fromRGB(150, 50, 50), TrollConfirmPopup)
	
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

return UIManager
