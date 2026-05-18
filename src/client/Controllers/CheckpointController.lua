local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")

local CheckpointController = {}
local Remotes = nil

local currentCheckpoint = nil

function CheckpointController.Init(networkRemotes)
	Remotes = networkRemotes
	
	-- Setup Checkpoint Touch Events
	local CheckpointsFolder = Workspace:WaitForChild("Checkpoints", 10)
	
	local function bindCheckpoint(cp)
		if cp:IsA("BasePart") then
			cp.Touched:Connect(function(hit)
				local char = hit.Parent
				if char and char == Players.LocalPlayer.Character then
					if currentCheckpoint ~= cp.Name then
						currentCheckpoint = cp.Name
						Remotes.UpdateCheckpoint:FireServer(cp)
					end
				end
			end)
		end
	end

	if CheckpointsFolder then
		for _, cp in ipairs(CheckpointsFolder:GetChildren()) do
			bindCheckpoint(cp)
		end
		
		-- Otomatis mendeteksi jika ada checkpoint baru yang ditambahkan nanti
		CheckpointsFolder.ChildAdded:Connect(bindCheckpoint)
	end
end

return CheckpointController
