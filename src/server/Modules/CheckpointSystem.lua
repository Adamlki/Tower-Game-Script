local CheckpointSystem = {}
local CheckpointHistory = {} -- [userId] = {BasePart_1, BasePart_2, ...}
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
	
	Remotes.UpdateCheckpoint.OnServerEvent:Connect(function(player, cpPart)
		if typeof(cpPart) == "Instance" and cpPart:IsA("BasePart") then
			local history = CheckpointHistory[player.UserId] or {}
			if #history == 0 or history[#history] ~= cpPart then
				table.insert(history, cpPart)
				CheckpointHistory[player.UserId] = history
			end
		end
	end)
	
	Remotes.GetCheckpoint.OnServerInvoke = function(player)
		local cpPart = getTopCheckpoint(player.UserId)
		return cpPart and cpPart.Position or nil
	end
	
	Remotes.TeleportToCheckpoint.OnServerEvent:Connect(function(player)
		local cpPart = getTopCheckpoint(player.UserId)
		if cpPart and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
			-- Teleport slightly above the checkpoint to prevent getting stuck
			player.Character.HumanoidRootPart.CFrame = CFrame.new(cpPart.Position + Vector3.new(0, 3, 0))
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
			local cpPart = getTopCheckpoint(player.UserId)
			if cpPart then
				local root = character:WaitForChild("HumanoidRootPart", 5)
				if root then
					root.CFrame = CFrame.new(cpPart.Position + Vector3.new(0, 3, 0))
				end
			end
		end)
	end)
end

function CheckpointSystem.SkipCheckpoint(player)
	-- When purchased skip checkpoint, logic is generally handled on client, but we trigger the teleport here
	local cpPart = getTopCheckpoint(player.UserId)
	if cpPart and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
		player.Character.HumanoidRootPart.CFrame = CFrame.new(cpPart.Position + Vector3.new(0, 3, 0))
		return true
	end
	return false
end

function CheckpointSystem.SkipNextStage(player)
	local cpPart = getTopCheckpoint(player.UserId)
	local currentNum = 0
	if cpPart and cpPart.Name:match("^CP(%d+)$") then
		currentNum = tonumber(cpPart.Name:match("^CP(%d+)$"))
	end
	
	local nextNum = currentNum + 1
	local nextCP = workspace:FindFirstChild("Checkpoints") and workspace.Checkpoints:FindFirstChild("CP" .. nextNum)
	
	if nextCP then
		local history = CheckpointHistory[player.UserId] or {}
		if #history == 0 or history[#history] ~= nextCP then
			table.insert(history, nextCP)
			CheckpointHistory[player.UserId] = history
		end
		if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
			player.Character.HumanoidRootPart.CFrame = CFrame.new(nextCP.Position + Vector3.new(0, 3, 0))
		end
		return true
	end
	return false
end

function CheckpointSystem.SkipToFinish(player)
	local finishPart = workspace:FindFirstChild("Checkpoints") and workspace.Checkpoints:FindFirstChild("FinishPart")
	if finishPart then
		local history = CheckpointHistory[player.UserId] or {}
		if #history == 0 or history[#history] ~= finishPart then
			table.insert(history, finishPart)
			CheckpointHistory[player.UserId] = history
		end
		if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
			player.Character.HumanoidRootPart.CFrame = CFrame.new(finishPart.Position + Vector3.new(0, 3, 0))
		end
		return true
	end
	return false
end

function CheckpointSystem.ResetCheckpoint(player)
	CheckpointHistory[player.UserId] = nil
end

return CheckpointSystem
