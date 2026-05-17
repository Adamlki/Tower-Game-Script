local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local Modules = ServerScriptService:WaitForChild("Server"):WaitForChild("Modules")

-- Create Network folder
local Network = Instance.new("Folder")
Network.Name = "Network"
Network.Parent = ReplicatedStorage

-- Function to create RemoteEvent/RemoteFunction safely
local function CreateRemote(class, name)
	local instance = Instance.new(class)
	instance.Name = name
	instance.Parent = Network
	return instance
end

-- Setup Network Events
local Remotes = {
	-- Admin Remotes
	AddAdmin = CreateRemote("RemoteFunction", "AddAdmin"),
	RemoveAdmin = CreateRemote("RemoteFunction", "RemoveAdmin"),
	GetAdmins = CreateRemote("RemoteFunction", "GetAdmins"),
	IsAdmin = CreateRemote("RemoteFunction", "IsAdmin"),
	
	-- Troll Remotes
	ExecuteTroll = CreateRemote("RemoteFunction", "ExecuteTroll"),
	TrollEffect = CreateRemote("RemoteEvent", "TrollEffect"), -- Server to Client visual effects (e.g., Jumpscare)
	
	-- Jump Remotes
	UpdateJump = CreateRemote("RemoteFunction", "UpdateJump"),
	SetCurrentJump = CreateRemote("RemoteEvent", "SetCurrentJump"),
	GetJumpLevel = CreateRemote("RemoteFunction", "GetJumpLevel"),
	
	-- Checkpoint Remotes
	UpdateCheckpoint = CreateRemote("RemoteEvent", "UpdateCheckpoint"),
	GetCheckpoint = CreateRemote("RemoteFunction", "GetCheckpoint"),
	TeleportToCheckpoint = CreateRemote("RemoteEvent", "TeleportToCheckpoint"),
	
	-- UI Trigger Remotes
	ShowPopup = CreateRemote("RemoteEvent", "ShowPopup"),
	ClaimGroupReward = CreateRemote("RemoteFunction", "ClaimGroupReward")
}

-- Load Systems
local AdminSystem = require(Modules.AdminSystem)
local CheckpointSystem = require(Modules.CheckpointSystem)
local TrollSystem = require(Modules.TrollSystem)
local PurchaseSystem = require(Modules.PurchaseSystem)

-- Initialize Systems
AdminSystem.Init(Remotes)
CheckpointSystem.Init(Remotes)
TrollSystem.Init(Remotes)
PurchaseSystem.Init(Remotes, {
	Admin = AdminSystem,
	Troll = TrollSystem,
	Checkpoint = CheckpointSystem
})

print("Server Systems Initialized")
