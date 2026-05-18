local Players = game:GetService("Players")

local TrollSystem = {}
local Remotes = nil

function TrollSystem.Init(networkRemotes)
	Remotes = networkRemotes
	
	-- Admin bypass or execution from client without purchase (if admin)
	Remotes.ExecuteTroll.OnServerInvoke = function(player, trollType, targetUserId)
		-- Check if player is admin
		local AdminSystem = require(script.Parent.AdminSystem)
		if not AdminSystem.IsAdmin(player.UserId) then
			return false, "Not an admin, must purchase"
		end
		
		return TrollSystem.ApplyTroll(player, trollType, targetUserId)
	end
end

function TrollSystem.ApplyTroll(buyer, trollType, targetUserId)
	local targets = {}
	
	if trollType == "KillAll" or trollType == "SlowAll" then
		for _, p in ipairs(Players:GetPlayers()) do
			if p ~= buyer then
				table.insert(targets, p)
			end
		end
	else
		local targetPlayer = nil
		for _, p in ipairs(Players:GetPlayers()) do
			if p.UserId == tonumber(targetUserId) then
				targetPlayer = p
				break
			end
		end
		if targetPlayer then
			table.insert(targets, targetPlayer)
		else
			return false, "Target player not found"
		end
	end
	
	for _, target in ipairs(targets) do
		local char = target.Character
		local hum = char and char:FindFirstChild("Humanoid")
		local root = char and char:FindFirstChild("HumanoidRootPart")
		
		if trollType == "Kill" or trollType == "KillAll" then
			if hum then hum.Health = 0 end
			
		elseif trollType == "Fling" then
			if root then
				local bodyVelocity = Instance.new("BodyVelocity")
				bodyVelocity.Velocity = Vector3.new(math.random(-500,500), 2000, math.random(-500,500))
				bodyVelocity.MaxForce = Vector3.new(100000,100000,100000)
				bodyVelocity.Parent = root
				game.Debris:AddItem(bodyVelocity, 0.2)
			end
			
		elseif trollType == "Kick" then
			target:Kick("You have been trolled by " .. buyer.Name)
			
		elseif trollType == "Slow" or trollType == "SlowAll" then
			if hum then
				local oldSpeed = hum.WalkSpeed
				hum.WalkSpeed = 5
				task.delay(10, function()
					if hum and hum.Parent then
						hum.WalkSpeed = oldSpeed
					end
				end)
			end
			
		elseif trollType == "Earthquake" then
			Remotes.TrollEffect:FireClient(target, "Earthquake")
			
		elseif trollType == "Jumpscare" then
			Remotes.TrollEffect:FireClient(target, "Jumpscare")
			
		elseif trollType == "Freeze" then
			if root and hum then
				root.Anchored = true
				task.delay(15, function()
					if root and root.Parent then
						root.Anchored = false
					end
				end)
			end
			
		elseif trollType == "SetFire" then
			if root and hum then
				local fire = Instance.new("Fire")
				fire.Parent = root
				
				local conn
				conn = task.spawn(function()
					for i = 1, 10 do
						if not hum or not hum.Parent or hum.Health <= 0 then break end
						hum:TakeDamage(15)
						task.wait(1)
					end
					if fire and fire.Parent then fire:Destroy() end
				end)
			end
		end
		
		if trollType ~= "Kick" then
			pcall(function()
				-- isError = true → warna merah untuk korban
				Remotes.TrollEffect:FireClient(target, "Notif", "Anda di troll " .. trollType, true)
			end)
		end
	end
	
	if buyer then
		local targetNameText = ""
		if trollType == "KillAll" or trollType == "SlowAll" then
			targetNameText = "semua orang"
		else
			local names = {}
			for _, t in ipairs(targets) do
				table.insert(names, t.DisplayName)
			end
			targetNameText = table.concat(names, ", ")
		end
		
		pcall(function()
			-- isError = false → warna hijau untuk pembeli (berhasil troll)
			Remotes.TrollEffect:FireClient(buyer, "Notif", "Anda berhasil mengetroll " .. targetNameText .. " menggunakan troll " .. trollType, false)
		end)
	end
	
	return true, "Troll applied"
end

return TrollSystem
