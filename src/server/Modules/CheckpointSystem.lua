local CheckpointSystem = {}
local Checkpoints = {} -- [userId] = Vector3

local Remotes = nil

function CheckpointSystem.Init(networkRemotes)
	Remotes = networkRemotes
	
	Remotes.UpdateCheckpoint.OnServerEvent:Connect(function(player, position)
		if typeof(position) == "Vector3" then
			Checkpoints[player.UserId] = position
		end
	end)
	
	Remotes.GetCheckpoint.OnServerInvoke = function(player)
		return Checkpoints[player.UserId]
	end
	
	Remotes.TeleportToCheckpoint.OnServerEvent:Connect(function(player)
		local pos = Checkpoints[player.UserId]
		if pos and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
			-- Teleport slightly above the checkpoint to prevent getting stuck
			player.Character.HumanoidRootPart.CFrame = CFrame.new(pos + Vector3.new(0, 3, 0))
		end
	end)
end

function CheckpointSystem.SkipCheckpoint(player)
	-- When purchased skip checkpoint, logic is generally handled on client, but we trigger the teleport here
	local pos = Checkpoints[player.UserId]
	if pos and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
		player.Character.HumanoidRootPart.CFrame = CFrame.new(pos + Vector3.new(0, 3, 0))
		return true
	end
	return false
end

return CheckpointSystem
