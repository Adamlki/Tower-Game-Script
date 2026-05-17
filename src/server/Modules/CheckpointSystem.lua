local CheckpointSystem = {}
local CheckpointHistory = {} -- [userId] = {Vector3_1, Vector3_2, ...}
local ResetTasks = {} -- [userId] = thread

local Remotes = nil

local function getTopCheckpoint(userId)
	local history = CheckpointHistory[userId]
	if history and #history > 0 then
		return history[#history]
	end
	return nil
end

function CheckpointSystem.Init(networkRemotes)
	Remotes = networkRemotes
	
	Remotes.UpdateCheckpoint.OnServerEvent:Connect(function(player, position)
		if typeof(position) == "Vector3" then
			local history = CheckpointHistory[player.UserId] or {}
			-- Only push if it's different from the current top
			if #history == 0 or (history[#history] - position).Magnitude > 1 then
				table.insert(history, position)
				CheckpointHistory[player.UserId] = history
			end
		end
	end)
	
	Remotes.GetCheckpoint.OnServerInvoke = function(player)
		return getTopCheckpoint(player.UserId)
	end
	
	Remotes.TeleportToCheckpoint.OnServerEvent:Connect(function(player)
		local pos = getTopCheckpoint(player.UserId)
		if pos and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
			-- Teleport slightly above the checkpoint to prevent getting stuck
			player.Character.HumanoidRootPart.CFrame = CFrame.new(pos + Vector3.new(0, 3, 0))
		end
	end)
	
	Remotes.DemoteCheckpoint.OnServerEvent:Connect(function(player)
		local history = CheckpointHistory[player.UserId]
		if history and #history > 0 then
			table.remove(history, #history)
		end
		
		-- Start 30s reset timer
		if ResetTasks[player.UserId] then
			task.cancel(ResetTasks[player.UserId])
		end
		
		ResetTasks[player.UserId] = task.delay(30, function()
			CheckpointSystem.ResetCheckpoint(player)
			ResetTasks[player.UserId] = nil
		end)
	end)
	
	local Players = game:GetService("Players")
	Players.PlayerAdded:Connect(function(player)
		player.CharacterAdded:Connect(function(character)
			-- Cancel 30s reset timer if they spawned
			if ResetTasks[player.UserId] then
				task.cancel(ResetTasks[player.UserId])
				ResetTasks[player.UserId] = nil
			end
			
			-- Wait for character to fully load
			task.wait(0.1)
			local pos = getTopCheckpoint(player.UserId)
			if pos then
				local root = character:WaitForChild("HumanoidRootPart", 5)
				if root then
					root.CFrame = CFrame.new(pos + Vector3.new(0, 3, 0))
				end
			end
		end)
	end)
end

function CheckpointSystem.SkipCheckpoint(player)
	-- When purchased skip checkpoint, logic is generally handled on client, but we trigger the teleport here
	local pos = getTopCheckpoint(player.UserId)
	if pos and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
		player.Character.HumanoidRootPart.CFrame = CFrame.new(pos + Vector3.new(0, 3, 0))
		return true
	end
	return false
end

function CheckpointSystem.ResetCheckpoint(player)
	CheckpointHistory[player.UserId] = nil
end

return CheckpointSystem
