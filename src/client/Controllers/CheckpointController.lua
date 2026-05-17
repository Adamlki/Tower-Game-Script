local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")

local CheckpointController = {}
local Remotes = nil

local currentCheckpoint = nil

function CheckpointController.Init(networkRemotes)
	Remotes = networkRemotes
	
	-- Setup Checkpoint Touch Events
	local CheckpointsFolder = Workspace:WaitForChild("Checkpoints", 10)
	if CheckpointsFolder then
		for _, cp in ipairs(CheckpointsFolder:GetChildren()) do
			if cp:IsA("BasePart") then
				cp.Touched:Connect(function(hit)
					local char = hit.Parent
					if char and char == Players.LocalPlayer.Character then
						if currentCheckpoint ~= cp.Name then
							currentCheckpoint = cp.Name
							Remotes.UpdateCheckpoint:FireServer(cp.Position)
						end
					end
				end)
			end
		end
	end
end

return CheckpointController
