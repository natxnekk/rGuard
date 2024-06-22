local rGuard = require(script.Parent.Parent)
local rSettings = require(script.Parent.Parent.Config.rSettings)

local function isTouchingFloor(humanoidRootPart: BasePart): boolean
	local params = RaycastParams.new()
	params.FilterType = Enum.RaycastFilterType.Exclude
	params.FilterDescendantsInstances = {humanoidRootPart.Parent}
	
	for i = -1, 1 do
		local origin = humanoidRootPart.Position + Vector3.new(i, 0, 0)
		local raycast = workspace:Raycast(humanoidRootPart.Position, Vector3.new(0, -3.5, 0), params)
		if raycast and raycast.Instance then
			return true
		end
	end	
	
	return false
end

return function(player: Player, character: Model)
	local humanoid: Humanoid = character:WaitForChild('Humanoid')
	local humanoidRootPart: BasePart = character:WaitForChild('HumanoidRootPart')
	
	local lastGroundTick = tick()
	local lastGroundPosition = Vector3.zero
	
	while task.wait() do
		if not character then return end
		if isTouchingFloor(humanoidRootPart) then
			lastGroundTick = tick()
			lastGroundPosition = humanoidRootPart.Position
		end
		
		local elapsedGroundTick = tick() - lastGroundTick
		if elapsedGroundTick > rSettings.listeners.maxAirTime then
			if lastGroundPosition then
				humanoidRootPart.Position = lastGroundPosition
				lastGroundTick = tick()
				rGuard:increaseFlag(player, "flight", 1)
			end
		end
	end
end
