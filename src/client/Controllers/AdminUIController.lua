local AdminUIController = {}
local UIManager = require(script.Parent.UIManager)
local Remotes = nil

function AdminUIController.Init(networkRemotes)
	Remotes = networkRemotes
	-- Add admin UI logic here
	task.spawn(function()
		local isAdmin = Remotes.IsAdmin:InvokeServer()
		if isAdmin then
			local Gui = UIManager.GetGui()
			local AdminBtn = Gui:WaitForChild("AdminBtn")
			local AdminPanel = Gui:WaitForChild("AdminPanel")
			
			AdminBtn.Visible = true
			
			local adminOpen = false
			AdminBtn.MouseButton1Click:Connect(function()
				adminOpen = not adminOpen
				if adminOpen then
					UIManager.TweenPanelIn(AdminPanel, UDim2.new(0.5, -150, 0.5, -90))
				else
					UIManager.TweenPanelOut(AdminPanel, UDim2.new(0.5, -150, -0.5, 0))
				end
			end)
			
			AdminPanel.CloseBtn.MouseButton1Click:Connect(function()
				adminOpen = false
				UIManager.TweenPanelOut(AdminPanel, UDim2.new(0.5, -150, -0.5, 0))
			end)
			
			AdminPanel.AddAdminBtn.MouseButton1Click:Connect(function()
				local targetId = tonumber(AdminPanel.AdminIdInput.Text)
				if targetId then
					local success, msg = Remotes.AddAdmin:InvokeServer(targetId)
					print("Add Admin:", success, msg)
				else
					print("Invalid UserId format")
				end
			end)
			
			AdminPanel.RemoveAdminBtn.MouseButton1Click:Connect(function()
				local targetId = tonumber(AdminPanel.AdminIdInput.Text)
				if targetId then
					local success, msg = Remotes.RemoveAdmin:InvokeServer(targetId)
					print("Remove Admin:", success, msg)
				else
					print("Invalid UserId format")
				end
			end)
		end
	end)
end

return AdminUIController
