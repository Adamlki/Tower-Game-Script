local MarketplaceService = game:GetService("MarketplaceService")
local ServerStorage = game:GetService("ServerStorage")
local Players = game:GetService("Players")

local Config = require(game:GetService("ReplicatedStorage"):WaitForChild("Shared"):WaitForChild("Config"))
local AdminSystem = require(script.Parent:WaitForChild("AdminSystem"))

local ShopSystem = {}

local function GiveToolToPlayer(player, toolName)
	local toolsFolder = ServerStorage:FindFirstChild("Tools")
	if not toolsFolder then
		warn("Tools folder not found in ServerStorage")
		return
	end
	
	local toolPrefab = toolsFolder:FindFirstChild(toolName)
	if not toolPrefab then
		warn("Tool " .. toolName .. " not found in ServerStorage.Tools")
		return
	end
	
	-- Check if player already has it
	if player.Backpack:FindFirstChild(toolName) or (player.Character and player.Character:FindFirstChild(toolName)) then
		return -- Already has it
	end
	
	local clone1 = toolPrefab:Clone()
	clone1.Parent = player.Backpack
	
	-- Add to StarterGear so it persists on respawn
	local starterGear = player:FindFirstChild("StarterGear")
	if starterGear and not starterGear:FindFirstChild(toolName) then
		local clone2 = toolPrefab:Clone()
		clone2.Parent = starterGear
	end
end

function ShopSystem.Init(Remotes)
	Players.PlayerAdded:Connect(function(player)
		-- Wait a bit for data to load if needed, but GamePass check is generally fast
		local isAdmin = AdminSystem.IsAdmin(player.UserId)
		
		for itemKey, gamepassId in pairs(Config.ShopGamepasses) do
			local ownsGamepass = false
			
			if isAdmin then
				ownsGamepass = true
			else
				local success, res = pcall(function()
					return MarketplaceService:UserOwnsGamePassAsync(player.UserId, gamepassId)
				end)
				ownsGamepass = success and res
			end
			
			if ownsGamepass then
				local toolName = Config.Tools[itemKey]
				if toolName then
					GiveToolToPlayer(player, toolName)
				end
			end
		end
	end)
	
	MarketplaceService.PromptGamePassPurchaseFinished:Connect(function(player, gamepassId, wasPurchased)
		if wasPurchased then
			for itemKey, id in pairs(Config.ShopGamepasses) do
				if id == gamepassId then
					local toolName = Config.Tools[itemKey]
					if toolName then
						GiveToolToPlayer(player, toolName)
					end
				end
			end
		end
	end)
	
	-- Remote Function to check if player owns a specific item (used by client to update UI)
	Remotes.CheckItemOwnership = Instance.new("RemoteFunction")
	Remotes.CheckItemOwnership.Name = "CheckItemOwnership"
	Remotes.CheckItemOwnership.Parent = game:GetService("ReplicatedStorage").Network
	
	Remotes.CheckItemOwnership.OnServerInvoke = function(player, itemKey)
		if AdminSystem.IsAdmin(player.UserId) then return true end
		
		local gamepassId = Config.ShopGamepasses[itemKey]
		if not gamepassId then return false end
		
		local success, ownsGamepass = pcall(function()
			return MarketplaceService:UserOwnsGamePassAsync(player.UserId, gamepassId)
		end)
		
		return success and ownsGamepass
	end
end

return ShopSystem
