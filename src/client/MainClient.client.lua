local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Network = ReplicatedStorage:WaitForChild("Network")

if not game:IsLoaded() then
	game.Loaded:Wait()
end

-- Initialize UI First
local UIManager = require(script.Parent:WaitForChild("Controllers"):WaitForChild("UIManager"))
UIManager.CreateUI()

-- Load Controllers
local Controllers = script.Parent:WaitForChild("Controllers")
local TrollController = require(Controllers:WaitForChild("TrollController"))
local CheckpointController = require(Controllers:WaitForChild("CheckpointController"))
local JumpController = require(Controllers:WaitForChild("JumpController"))
local SpectateController = require(Controllers:WaitForChild("SpectateController"))
local GroupController = require(Controllers:WaitForChild("GroupController"))
local AdminUIController = require(Controllers:WaitForChild("AdminUIController"))
local ShopController = require(Controllers:WaitForChild("ShopController"))
local MenuKananController = require(Controllers:WaitForChild("MenuKananController"))
local UfoController = require(Controllers:WaitForChild("UfoController"))
local WinnerController = require(Controllers:WaitForChild("WinnerController"))
local SettingController = require(Controllers:WaitForChild("SettingController"))

-- Initialize Controllers
TrollController.Init(Network)
CheckpointController.Init(Network)
JumpController.Init(Network)
SpectateController.Init(Network)
GroupController.Init(Network)
AdminUIController.Init(Network)
ShopController.Init(Network)
MenuKananController.Init(Network)
UfoController.Init()
WinnerController.Init()
SettingController.Init()

print("Client Systems Initialized")
