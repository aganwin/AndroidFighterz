-------------------------------------------------
--
-- Debug.lua
--
-- Filter out what print messages or displayed debug tools you want
-- Set these hear or maybe later in some "engineer" version of the game settings
--
-------------------------------------------------


local Debug = {
	logText = true,
	screenText = true,
	hitboxes = false,
	itemDebug = false,
	multiplayer = true,
	AIDebug = true,
	manaCost = true,
	tools = true, --FPS GUI and Debug Panel
	quickstart = true,
	x = 0,
	y = 0,
	botsOn = true, -- TURN BOTS OFF BY SETTING THIS TO botsOn = false,

	keyboard = true, -- WINDOWS ONLY!!!!

	itemsToDrop = 0,
}

-- local release 
--[[
local Debug = {
	logText = false,
	screenText = false,
	hitboxes = false,
	itemDebug = false,
	multiplayer = true,
	AIDebug = false,
	manaCost = false,
	tools = false, --FPS GUI
	quickstart = true,
	x = 0,
	y = 0,
	botsOn = true,
}
]]--

local Debug_metatable = { __index = Debug } -- on making a new ball, the above are the defaults (index ~ defaults)

function Debug:new()
	local d = {}
	setmetatable(d,Debug_metatable)
	return d
end

return Debug


