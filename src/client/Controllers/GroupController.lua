local GroupController = {}
local UIManager = require(script.Parent.UIManager)
local Remotes = nil

function GroupController.Init(networkRemotes)
	Remotes = networkRemotes
	-- Add group popup logic here
end

return GroupController
