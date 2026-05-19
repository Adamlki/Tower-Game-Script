local DataStoreService = game:GetService("DataStoreService")

local DataSystem = {}

-- Database Penyimpanan
local WinsStore = DataStoreService:GetDataStore("PlayerWinsData_v1")
local WinsLeaderboard = DataStoreService:GetOrderedDataStore("GlobalWinsLeaderboard_v1")

-- Fungsi untuk Mengambil Data Pemain Saat Masuk
function DataSystem.LoadWins(userId)
	local success, savedWins = pcall(function()
		return WinsStore:GetAsync(tostring(userId))
	end)
	
	if success and savedWins then
		return savedWins
	end
	return 0 -- Kembalikan 0 jika belum pernah main/data kosong
end

-- Fungsi untuk Menyimpan Data Pemain
function DataSystem.SaveWins(userId, winsValue)
	pcall(function()
		-- Simpan ke penyimpanan pribadi
		WinsStore:SetAsync(tostring(userId), winsValue)
		-- Simpan ke papan ranking global
		WinsLeaderboard:SetAsync(tostring(userId), winsValue)
	end)
end

-- Fungsi untuk Mengambil Top 50 Pemain Terbaik Global
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

return DataSystem