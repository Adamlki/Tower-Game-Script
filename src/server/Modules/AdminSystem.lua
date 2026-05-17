local DataStoreService = game:GetService("DataStoreService")
local AdminStore = DataStoreService:GetDataStore("AdminList_v1")
local Config = require(game:GetService("ReplicatedStorage"):WaitForChild("Shared"):WaitForChild("Config"))

local AdminSystem = {}
local Cache = {} -- [userId] = true

local function loadAdmins()
	local success, data = pcall(function()
		return AdminStore:GetAsync("Admins")
	end)
	if success and data then
		for _, id in ipairs(data) do
			Cache[id] = true
		end
	end
	-- Owner is always admin
	if Config.OwnerId then
		Cache[Config.OwnerId] = true
	end
end

local function saveAdmins()
	local adminList = {}
	for id, _ in pairs(Cache) do
		if id ~= Config.OwnerId then -- No need to save owner
			table.insert(adminList, id)
		end
	end
	pcall(function()
		AdminStore:SetAsync("Admins", adminList)
	end)
end

function AdminSystem.IsAdmin(userId)
	if userId == Config.OwnerId then return true end
	return Cache[userId] == true
end

function AdminSystem.Init(Remotes)
	loadAdmins()
	
	Remotes.IsAdmin.OnServerInvoke = function(player)
		return AdminSystem.IsAdmin(player.UserId)
	end
	
	Remotes.GetAdmins.OnServerInvoke = function(player)
		if not AdminSystem.IsAdmin(player.UserId) then return {} end
		local list = {}
		for id, _ in pairs(Cache) do
			table.insert(list, id)
		end
		return list
	end
	
	Remotes.AddAdmin.OnServerInvoke = function(player, targetUserId)
		if player.UserId ~= Config.OwnerId then return false, "Not owner" end
		targetUserId = tonumber(targetUserId)
		if not targetUserId then return false, "Invalid ID" end
		
		Cache[targetUserId] = true
		saveAdmins()
		return true, "Admin added"
	end
	
	Remotes.RemoveAdmin.OnServerInvoke = function(player, targetUserId)
		if player.UserId ~= Config.OwnerId then return false, "Not owner" end
		targetUserId = tonumber(targetUserId)
		if not targetUserId then return false, "Invalid ID" end
		
		if targetUserId == Config.OwnerId then return false, "Cannot remove owner" end
		
		Cache[targetUserId] = nil
		saveAdmins()
		return true, "Admin removed"
	end
end

return AdminSystem
