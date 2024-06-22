--!strict
--[[
	MODULE MADE BY: natxnek
	USAGE:
		rGuard:init(player) --initialize player with anti-cheat
		
		You can always change anti-cheat settings in Config\rSettings module
		!! PARENT Config AND Listeners FOLDERS TO THE MAIN rGuard MODULE SCRIPT
]]

local rGuard = {}
rGuard.__index = rGuard

export type guardData = {
	listeners: {[ModuleScript]: thread},
	flags: {
		speed: number,
		flight: number
	}
}

local players: {[Player]: guardData} = {}
local rSettings = require(script.Config.rSettings)

local rPrefix = "[rGuard]"

local function rDebug(message: string?)
	if not rSettings.logMessages then return end 
	print(`{rPrefix} {message}`)
end

function rGuard:getFlag(player: Player, flag: string): number?
	if not players[player] then return end
	return players[player]['flags'][flag]
end

function rGuard:kickPlayer(player: Player, flag: string?)
	player:Kick(`{rPrefix} {flag or ""} | CONTACT WITH GAME ADMINISTRATOR IF KICKED INCORRECTLY`)
end

function rGuard:checkFlag(player: Player, flag: string, kick: boolean?): boolean?
	if not players[player] and (not players[player]['flags'][flag] or not rSettings['maxFlag'][flag]) then return true end
	if kick then
		if players[player]['flags'][flag] >= rSettings['maxFlag'][flag] then
			rGuard:kickPlayer(player, flag)
		end
	end
	return players[player]['flags'][flag] < rSettings['maxFlag'][flag]
end

function rGuard:updateFlag(player: Player, flag: string, value: number)
	if not players[player] then return end
	players[player]['flags'][flag] = value

	rGuard:checkFlag(player, flag, true)
end

function rGuard:increaseFlag(player: Player, flag: string, amount: number)
	if not players[player] then return end
	players[player]['flags'][flag] += amount
	
	rDebug(`FLAG {flag} INCREASED AT {player}`)
	
	rGuard:checkFlag(player, flag, true)
end

function rGuard:startListenEvents(player: Player, character: Model)
	local guardData: guardData = players[player]
	for _,listenModule: ModuleScript in script.Listeners:GetChildren() do
		if not listenModule:IsA('ModuleScript') then continue end
		local listen = require(listenModule) :: (player: Player, character: Model) -> ()
		local listener = task.spawn(function()
			listen(player, character)
		end)
		rGuard:closeListener(player, listenModule)
		guardData['listeners'][listenModule] = listener
		
		rDebug(`{listenModule} listening`)
	end
end

function rGuard:startListener(player: Player, character: Model, moduleScript: ModuleScript): boolean
	if moduleScript.Parent ~= script.Listeners then return false end
	local guardData: guardData = players[player]
	if not guardData then return false end
	
	rGuard:closeListener(player, moduleScript)
	
	local listen = require(moduleScript) :: (player: Player, character: Model) -> ()
	local listener = task.spawn(function()
		listen(player, character)
	end)
	
	guardData['listeners'][moduleScript] = listener
	rDebug(`{moduleScript} listening`)
	
	return true
end

function rGuard:getListener(player: Player, moduleScript: ModuleScript): thread?
	if not players[player] then return end
	return players[player]['listeners'][moduleScript]
end

function rGuard:closeListener(player: Player, moduleScript: ModuleScript)
	if not players[player] then return end
	local listenThread = players[player]['listeners'][moduleScript]
	if listenThread then
		task.cancel(listenThread)
	end
end

function rGuard:closeAllListeners(player: Player)
	local guardData: guardData = players[player]
	if not guardData then return end
	for _,thread: thread in guardData['listeners'] do
		task.cancel(thread)
	end
end

function rGuard:init(player: Player)
	local guardData: guardData = {
		listeners = {},
		flags = {
			speed = 0,
			flight = 0,
		}	
	} :: guardData
	
	players[player] = guardData
	
	player.CharacterAdded:Connect(function(character)
		rGuard:startListenEvents(player, character)
	end)
	player.CharacterRemoving:Connect(function(character)
		rGuard:closeAllListeners(player)
	end)
	
	rDebug(`initialized {player}`)
end

return rGuard
