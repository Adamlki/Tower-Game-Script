local MarketplaceService = game:GetService("MarketplaceService")
local DataStoreService = game:GetService("DataStoreService")
local PurchaseStore = DataStoreService:GetDataStore("PurchaseHistory_v1")
local Config = require(game:GetService("ReplicatedStorage"):WaitForChild("Shared"):WaitForChild("Config"))

local PurchaseSystem = {}
local Systems = {}

function PurchaseSystem.Init(Remotes, loadedSystems)
	Systems = loadedSystems
	
	MarketplaceService.ProcessReceipt = function(receiptInfo)
		local player = game.Players:GetPlayerByUserId(receiptInfo.PlayerId)
		if not player then
			return Enum.ProductPurchaseDecision.NotProcessedYet
		end
		
		-- Check if already processed (basic protection against double purchase)
		local success, isProcessed = pcall(function()
			return PurchaseStore:GetAsync(receiptInfo.PurchaseId)
		end)
		if success and isProcessed then
			return Enum.ProductPurchaseDecision.PurchaseGranted
		end
		
		local productId = receiptInfo.ProductId
		local granted = false
		
		-- Troll Products
		for trollName, id in pairs(Config.TrollProducts) do
			if id == productId then
				-- We don't know the target from receiptInfo. We have to store a pending target or handle it.
				-- A simpler way is to handle troll target via a remote event *after* purchase,
				-- but robust systems store pending purchases. 
				-- For this game, we'll assume the client sent the target right before prompt and we saved it,
				-- OR we just grant the troll right and let the client execute it once.
				-- Let's use a PendingTrolls cache
				if PurchaseSystem.PendingTrolls and PurchaseSystem.PendingTrolls[player.UserId] then
					local pending = PurchaseSystem.PendingTrolls[player.UserId]
					if pending.Type == trollName then
						Systems.Troll.ApplyTroll(player, pending.Type, pending.TargetId)
						PurchaseSystem.PendingTrolls[player.UserId] = nil
						granted = true
					end
				end
			end
		end
		
		-- Jump Products
		for level, id in pairs(Config.JumpProducts) do
			if id == productId then
				-- Give jump level to player
				-- Usually saved in DataStore
				local JumpSystemStore = DataStoreService:GetDataStore("JumpLevel_v1")
				pcall(function()
					local current = JumpSystemStore:GetAsync(player.UserId) or 1
					if level > current then
						JumpSystemStore:SetAsync(player.UserId, level)
					end
				end)
				Remotes.UpdateJump:InvokeClient(player, level)
				granted = true
			end
		end
		
		-- Checkpoint Products
		if productId == Config.Products.SkipCheckpoint then
			granted = Systems.Checkpoint.SkipCheckpoint(player)
		elseif productId == Config.Products.SkipNextStage then
			granted = Systems.Checkpoint.SkipNextStage(player)
		elseif productId == Config.Products.SkipToFinish then
			granted = Systems.Checkpoint.SkipToFinish(player)
		end
		
		if granted then
			pcall(function()
				PurchaseStore:SetAsync(receiptInfo.PurchaseId, true)
			end)
			return Enum.ProductPurchaseDecision.PurchaseGranted
		else
			return Enum.ProductPurchaseDecision.NotProcessedYet
		end
	end
	
	-- Store pending troll target before prompting
	PurchaseSystem.PendingTrolls = {}
	Remotes.ExecuteTroll.OnServerInvoke = function(player, trollType, targetUserId)
		-- Intercept ExecuteTroll to set pending if not admin
		if Systems.Admin.IsAdmin(player.UserId) then
			return Systems.Troll.ApplyTroll(player, trollType, targetUserId)
		else
			PurchaseSystem.PendingTrolls[player.UserId] = {
				Type = trollType,
				TargetId = targetUserId
			}
			return false, "Prompting purchase"
		end
	end
	
	Remotes.GetJumpLevel.OnServerInvoke = function(player)
		if Systems.Admin.IsAdmin(player.UserId) then
			return 5 -- Admin gets max jumps automatically
		end
		
		local JumpSystemStore = DataStoreService:GetDataStore("JumpLevel_v1")
		local success, current = pcall(function()
			return JumpSystemStore:GetAsync(player.UserId)
		end)
		return (success and current) or 1
	end
	
	-- Intercept ExecuteSkip agar divalidasi dulu sebelum prompt beli/gratis
	Remotes.ExecuteSkip.OnServerInvoke = function(player, skipType)
		local canSkip = true
		local msg = ""
		
		-- Lakukan validasi berdasarkan tipe skip
		if skipType == "SkipNextStage" then
			canSkip, msg = Systems.Checkpoint.CanSkipNextStage(player)
		elseif skipType == "SkipToFinish" then
			canSkip, msg = Systems.Checkpoint.CanSkipToFinish(player)
		end
		
		-- Jika validasi gagal (sudah finish / di cp terakhir)
		if not canSkip then
			if Remotes and Remotes.TrollEffect then
				-- Kirim notif merah ke player, true = isError (warna merah)
				Remotes.TrollEffect:FireClient(player, "Notif", msg, true)
			end
			return false, "NotAllowed" -- Beri tahu klien untuk Batal memunculkan prompt beli
		end
		
		-- Jika boleh skip, cek apakah dia Admin (gratis)
		if Systems.Admin.IsAdmin(player.UserId) then
			if skipType == "SkipNextStage" then
				Systems.Checkpoint.SkipNextStage(player)
				return true, "AdminSuccess"
			elseif skipType == "SkipToFinish" then
				Systems.Checkpoint.SkipToFinish(player)
				return true, "AdminSuccess"
			end
		end
		
		-- Jika player biasa dan valid, beri izin prompt pembelian
		return false, "PromptPurchase"
	end
end

return PurchaseSystem
