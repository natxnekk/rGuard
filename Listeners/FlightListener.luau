--!strict
local rGuard = require(script.Parent.Parent)
local rSettings = require(script.Parent.Parent.Config.rSettings)

local function isTouchingFloor(humanoid: Humanoid): boolean
	return humanoid.FloorMaterial ~= Enum.Material.Air
end

return function(player: Player, character: Model)
	local humanoid = character:WaitForChild('Humanoid') :: Humanoid
	local humanoidRootPart = character:WaitForChild('HumanoidRootPart') :: BasePart
	
	local lastGroundTick = os.clock()
	local lastGroundPosition = Vector3.zero
	
	while task.wait() do
		if not character then return end
		if isTouchingFloor(humanoid) then
			lastGroundTick = os.clock()
			lastGroundPosition = humanoidRootPart.Position
		end
		
		local elapsedGroundTick = os.clock() - lastGroundTick
		if elapsedGroundTick > rSettings.listeners.maxAirTime then
			if lastGroundPosition then
				humanoidRootPart.Position = lastGroundPosition
				lastGroundTick = os.clock()
				rGuard:increaseFlag(player, "flight", 1)
			end
		end
	end
end
