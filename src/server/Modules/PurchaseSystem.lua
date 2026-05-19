local MarketplaceService = game:GetService("MarketplaceService")
local Config = require(game:GetService("ReplicatedStorage"):WaitForChild("Shared"):WaitForChild("Config"))
local DataSystem = require(script.Parent:WaitForChild("DataSystem")) -- Memanggil DataSystem

local PurchaseSystem = {}
local Systems = {}

function PurchaseSystem.Init(Remotes, loadedSystems)
	Systems = loadedSystems
	
	MarketplaceService.ProcessReceipt = function(receiptInfo)
		local player = game.Players:GetPlayerByUserId(receiptInfo.PlayerId)
		if not player then
			return Enum.ProductPurchaseDecision.NotProcessedYet
		end
		
		-- Cek apakah struk belanja sudah pernah diproses di database
		local isProcessed = DataSystem.IsPurchaseProcessed(receiptInfo.PurchaseId)
		if isProcessed then
			return Enum.ProductPurchaseDecision.PurchaseGranted
		end
		
		local productId = receiptInfo.ProductId
		local granted = false
		
		-- Proses Produk Troll
		for trollName, id in pairs(Config.TrollProducts) do
			if id == productId then
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
		
		-- Proses Produk Jump Upgrade
		for level, id in pairs(Config.JumpProducts) do
			if id == productId then
				-- Simpan level lompatan ke database via DataSystem
				DataSystem.SaveJumpLevel(player.UserId, level)
				Remotes.UpdateJump:InvokeClient(player, level)
				granted = true
			end
		end
		
		-- Proses Produk Checkpoint
		if productId == Config.Products.SkipCheckpoint then
			granted = Systems.Checkpoint.SkipCheckpoint(player)
		elseif productId == Config.Products.SkipNextStage then
			granted = Systems.Checkpoint.SkipNextStage(player)
		elseif productId == Config.Products.SkipToFinish then
			granted = Systems.Checkpoint.SkipToFinish(player)
		end
		
		if granted then
			-- Tandai bahwa struk ini sudah sukses diproses di database
			DataSystem.MarkPurchaseProcessed(receiptInfo.PurchaseId)
			return Enum.ProductPurchaseDecision.PurchaseGranted
		else
			return Enum.ProductPurchaseDecision.NotProcessedYet
		end
	end
	
	-- Cache sementara untuk target Troll
	PurchaseSystem.PendingTrolls = {}
	Remotes.ExecuteTroll.OnServerInvoke = function(player, trollType, targetUserId)
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
	
	-- Mengambil level Jump dari database
	Remotes.GetJumpLevel.OnServerInvoke = function(player)
		if Systems.Admin.IsAdmin(player.UserId) then
			return 5 -- Admin otomatis dapat jump maksimal
		end
		return DataSystem.GetJumpLevel(player.UserId)
	end
	
	-- Mengeksekusi Checkpoint Skip
	Remotes.ExecuteSkip.OnServerInvoke = function(player, skipType)
		local canSkip = true
		local msg = ""
		
		if skipType == "SkipNextStage" then
			canSkip, msg = Systems.Checkpoint.CanSkipNextStage(player)
		elseif skipType == "SkipToFinish" then
			canSkip, msg = Systems.Checkpoint.CanSkipToFinish(player)
		end
		
		if not canSkip then
			if Remotes and Remotes.TrollEffect then
				Remotes.TrollEffect:FireClient(player, "Notif", msg, true)
			end
			return false, "NotAllowed"
		end
		
		if Systems.Admin.IsAdmin(player.UserId) then
			if skipType == "SkipNextStage" then
				Systems.Checkpoint.SkipNextStage(player)
				return true, "AdminSuccess"
			elseif skipType == "SkipToFinish" then
				Systems.Checkpoint.SkipToFinish(player)
				return true, "AdminSuccess"
			end
		end
		
		return false, "PromptPurchase"
	end
end

return PurchaseSystem