local rGuard = require(script.Parent.Parent)
local rSettings = require(script.Parent.Parent.Config.rSettings)

return function(player: Player, character: Model)
	local humanoid: Humanoid = character:WaitForChild('Humanoid')
	local humanoidRootPart: BasePart = character:WaitForChild('HumanoidRootPart')
	
	local lastPositions: {Vector3} = {}
	
	while task.wait() do
		if not character then return end
		local hackAmount = 0
		for i = 1, 10 do
			local walkSpeed = humanoid.WalkSpeed

			if lastPositions[i] and lastPositions[i+1] then
				local distanceTraveled = (lastPositions[i]-lastPositions[i+1]).Magnitude
				if distanceTraveled >= walkSpeed/10 + rSettings.listeners.speedCheck then
					hackAmount += 1
				end
			end
			lastPositions[i] = Vector3.new(humanoidRootPart.Position.X, 0, humanoidRootPart.Position.Z)
			
			task.wait(0.1)
		end

		if hackAmount >= 5 then
			rGuard:increaseFlag(player, "speed", 1)
		end
	end
end
