local DataStoreService = game:GetService("DataStoreService")

local DataSystem = {}

-- 📂 SEMUA DATABASE DIKUMPULKAN DI SINI
local WinsStore = DataStoreService:GetDataStore("PlayerWinsData_v1")
local WinsLeaderboard = DataStoreService:GetOrderedDataStore("GlobalWinsLeaderboard_v1")

local AdminStore = DataStoreService:GetDataStore("AdminList_v1")
local PurchaseStore = DataStoreService:GetDataStore("PurchaseHistory_v1")
local JumpSystemStore = DataStoreService:GetDataStore("JumpLevel_v1")

-- ==========================================
-- 🏆 SYSTEM WINS & LEADERBOARD
-- ==========================================
function DataSystem.LoadWins(userId)
	local success, savedWins = pcall(function()
		return WinsStore:GetAsync(tostring(userId))
	end)
	if success and savedWins then
		return savedWins
	end
	return 0 -- Default 0 win
end

function DataSystem.SaveWins(userId, winsValue)
	pcall(function()
		WinsStore:SetAsync(tostring(userId), winsValue)
		WinsLeaderboard:SetAsync(tostring(userId), winsValue)
	end)
end

function DataSystem.GetTopWins(limit)
	limit = limit or 50
	local success, pages = pcall(function()
		return WinsLeaderboard:GetSortedAsync(false, limit) 
	end)
	if success then
		return pages
	end
	return nil
end

-- ==========================================
-- 👑 SYSTEM ADMIN LIST
-- ==========================================
function DataSystem.LoadAdmins()
	local success, data = pcall(function()
		return AdminStore:GetAsync("Admins")
	end)
	if success and data then
		return data
	end
	return nil
end

function DataSystem.SaveAdmins(adminList)
	pcall(function()
		AdminStore:SetAsync("Admins", adminList)
	end)
end

-- ==========================================
-- 🛒 SYSTEM RIWAYAT PEMBELIAN (Anti Double Charge)
-- ==========================================
function DataSystem.IsPurchaseProcessed(purchaseId)
	local success, isProcessed = pcall(function()
		return PurchaseStore:GetAsync(purchaseId)
	end)
	return success and isProcessed
end

function DataSystem.MarkPurchaseProcessed(purchaseId)
	pcall(function()
		PurchaseStore:SetAsync(purchaseId, true)
	end)
end

-- ==========================================
-- 🦘 SYSTEM JUMP UPGRADE
-- ==========================================
function DataSystem.GetJumpLevel(userId)
	local success, current = pcall(function()
		return JumpSystemStore:GetAsync(tostring(userId))
	end)
	if success and current then
		return current
	end
	return 1 -- Default 1 jump
end

function DataSystem.SaveJumpLevel(userId, level)
	pcall(function()
		local success, current = pcall(function()
			return JumpSystemStore:GetAsync(tostring(userId))
		end)
		current = (success and current) or 1
		
		-- Hanya simpan jika level yang dibeli lebih tinggi dari level saat ini
		if level > current then
			JumpSystemStore:SetAsync(tostring(userId), level)
		end
	end)
end

return DataSystem