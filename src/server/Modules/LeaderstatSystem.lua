local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")

local LeaderstatSystem = {}
local CheckpointSystem = require(script.Parent.CheckpointSystem)
local debounces = {}

function LeaderstatSystem.Init()
	local function onPlayerAdded(player)
		if player:FindFirstChild("leaderstats") then return end
		
		local leaderstats = Instance.new("Folder")
		leaderstats.Name = "leaderstats"
		leaderstats.Parent = player
		
		local wins = Instance.new("IntValue")
		wins.Name = "Wins"
		wins.Value = 0
		wins.Parent = leaderstats
	end
	
	Players.PlayerAdded:Connect(onPlayerAdded)
	
	for _, player in ipairs(Players:GetPlayers()) do
		onPlayerAdded(player)
	end
	
	-- Setup FinishPart touch event
	local function teleportToSpawn(player)
		local char = player.Character
		if not char then return end
		local root = char:FindFirstChild("HumanoidRootPart")
		if not root then return end
		
		local spawnLocation = Workspace:FindFirstChildWhichIsA("SpawnLocation")
		if spawnLocation then
			root.CFrame = CFrame.new(spawnLocation.Position + Vector3.new(0, 3, 0))
		else
			root.CFrame = CFrame.new(0, 5, 0)
		end
	end

	local hasFinished = {}

	-- Setup FinishPart touch event
	local function setupFinishPart(finishPart)
		finishPart.Touched:Connect(function(hit)
			local char = hit.Parent
			local player = Players:GetPlayerFromCharacter(char)
			
			if player then
				if not debounces[player.UserId] and not hasFinished[player.UserId] then
					debounces[player.UserId] = true
					hasFinished[player.UserId] = true
					
					-- Add Win
					local leaderstats = player:FindFirstChild("leaderstats")
					if leaderstats then
						local wins = leaderstats:FindFirstChild("Wins")
						if wins then
							wins.Value = wins.Value + 1
						end
					end
					
					-- No longer resetting checkpoint or teleporting here
					
					-- Cooldown
					task.wait(2)
					debounces[player.UserId] = nil
				end
			end
		end)
	end
	
	-- Setup ResetPart touch event
	local function setupResetPart(resetPart)
		resetPart.Touched:Connect(function(hit)
			local char = hit.Parent
			local player = Players:GetPlayerFromCharacter(char)
			
			if player then
				if not debounces[player.UserId] then
					debounces[player.UserId] = true
					
					-- Allow them to win again on the next run
					hasFinished[player.UserId] = nil
					
					-- Just Reset Checkpoint & Teleport
					CheckpointSystem.ResetCheckpoint(player)
					teleportToSpawn(player)
					
					-- Cooldown
					task.wait(2)
					debounces[player.UserId] = nil
				end
			end
		end)
	end
	
	task.spawn(function()
		local finishPart = nil
		local resetPart = nil
		
		for _, desc in ipairs(Workspace:GetDescendants()) do
			if desc:IsA("BasePart") then
				if desc.Name == "FinishPart" then
					finishPart = desc
				elseif desc.Name == "ResetPart" then
					resetPart = desc
				end
			end
		end
		
		if finishPart then setupFinishPart(finishPart) end
		if resetPart then setupResetPart(resetPart) end
		
		local conn
		conn = Workspace.DescendantAdded:Connect(function(desc)
			if desc:IsA("BasePart") then
				if desc.Name == "FinishPart" then
					setupFinishPart(desc)
				elseif desc.Name == "ResetPart" then
					setupResetPart(desc)
				end
			end
		end)
	end)
end

return LeaderstatSystem
