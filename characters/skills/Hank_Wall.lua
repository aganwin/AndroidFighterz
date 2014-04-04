local camera = require("gameplay.Camera")

local seqData =
	{
		{ name = "on", start = 1, count = 4, time = 500, loopCount = 1 },
		{ name = "burn", start = 5, count = 3, time = 300, loopCount = 0 },
		{ name = "off", start = 8, count = 3, time = 500, loopCount = 1 },
		{ name = "transform", start = 11, count = 9, time = 300, loopCount = 1 }
	}

local data = {
	frames = {
		{ name=firewall01, x = 0, y = 315, width = 313, height = 313, sourceX=0, sourceY=0, sourceWidth=313 , sourceHeight=313 },
		{ name=firewall02, x = 315, y = 315, width = 313, height = 313, sourceX=0, sourceY=0, sourceWidth=313 , sourceHeight=313 },
		{ name=firewall03, x = 0, y = 945, width = 313, height = 313, sourceX=0, sourceY=0, sourceWidth=313 , sourceHeight=313 },
		{ name=firewall04, x = 315, y = 0, width = 313, height = 313, sourceX=0, sourceY=0, sourceWidth=313 , sourceHeight=313 },
		{ name=firewall05, x = 630, y = 0, width = 313, height = 313, sourceX=0, sourceY=0, sourceWidth=313 , sourceHeight=313 },
		{ name=firewall06, x = 315, y = 630, width = 313, height = 313, sourceX=0, sourceY=0, sourceWidth=313 , sourceHeight=313 },
		{ name=firewall07, x = 315, y = 945, width = 313, height = 313, sourceX=0, sourceY=0, sourceWidth=313 , sourceHeight=313 },
		{ name=firewall08, x = 630, y = 945, width = 313, height = 313, sourceX=0, sourceY=0, sourceWidth=313 , sourceHeight=313 },
		{ name=firewall09, x = 630, y = 630, width = 313, height = 313, sourceX=0, sourceY=0, sourceWidth=313 , sourceHeight=313 },
		{ name=firewall10, x = 0, y = 630, width = 313, height = 313, sourceX=0, sourceY=0, sourceWidth=313 , sourceHeight=313 },
		{ name=firewall11, x = 0, y = 0, width = 313, height = 313, sourceX=0, sourceY=0, sourceWidth=313 , sourceHeight=313 },
		{ name=firewall12, x = 630, y = 315, width = 313, height = 313, sourceX=0, sourceY=0, sourceWidth=313 , sourceHeight=313 },
		{ name=transformeffect01, x = 945, y = 158, width = 156, height = 156, sourceX=0, sourceY=0, sourceWidth=156 , sourceHeight=156 },
		{ name=transformeffect02, x = 945, y = 316, width = 156, height = 156, sourceX=0, sourceY=0, sourceWidth=156 , sourceHeight=156 },
		{ name=transformeffect03, x = 945, y = 0, width = 156, height = 156, sourceX=0, sourceY=0, sourceWidth=156 , sourceHeight=156 },
		{ name=transformeffect04, x = 945, y = 632, width = 156, height = 156, sourceX=0, sourceY=0, sourceWidth=156 , sourceHeight=156 },
		{ name=transformeffect05, x = 945, y = 790, width = 156, height = 156, sourceX=0, sourceY=0, sourceWidth=156 , sourceHeight=156 },
		{ name=transformeffect06, x = 945, y = 474, width = 156, height = 156, sourceX=0, sourceY=0, sourceWidth=156 , sourceHeight=156 },
		{ name=transformeffect07, x = 1103, y = 0, width = 156, height = 156, sourceX=0, sourceY=0, sourceWidth=156 , sourceHeight=156 },
		{ name=transformeffect08, x = 1103, y = 158, width = 156, height = 156, sourceX=0, sourceY=0, sourceWidth=156 , sourceHeight=156 },
		{ name=transformeffect09, x = 945, y = 948, width = 156, height = 156, sourceX=0, sourceY=0, sourceWidth=156 , sourceHeight=156 },
	},
	sheetContentWidth = 1261,
	sheetContentHeight = 1260
}

local sheet = graphics.newImageSheet( "images/hank/firewall.png", data )
local transformSheet = graphics.newImageSheet( "images/hank/firewall2.png", data )

local Hank_Wall = { damage = 15,
	transforms = {}
 }

local Hank_Wall_metatable = { __index = Hank_Wall }

allWalls = {}

function Hank_Wall:new( p ) -- Player is passed in to know where (x,y) to create sprites
	
	local wall = {}
	setmetatable(wall,Hank_Wall_metatable) -- all walls are created with same attributes
	
	wall.sprite = display.newSprite( sheet, seqData )
	wall.sprite:scale(1.2,1.2)
	wall.sprite:setSequence( "on" )
	wall.sprite:play()

	camera.group:insert(wall.sprite)

	wall.active = true

	local function burnAnimation()
		wall.sprite:setSequence( "burn" )
		wall.sprite:play()
	end

	local function OffAnimation()
		wall.sprite:setSequence( "off" )
		wall.sprite:play()
		wall.active = false
	end

	local function disappear()
		table.remove( allWalls, #allWalls )
		wall.sprite:removeSelf()
		wall = nil
	end

	wall.sprite.x = p.sprite.x + p.mirror*p.character.downJumpRangeX
	wall.sprite.y = (p.sprite.y + p.bot)/2

	-- if player is facing left, mirror the ball, set the speed to be going left
	if( p.mirror == -1 ) then
		wall.sprite:scale(-1,1)
		wall.mirror = -1
	else
		wall.mirror = 1
	end

	timer.performWithDelay( 500, burnAnimation )
	timer.performWithDelay( 5500, OffAnimation )
	timer.performWithDelay( 6500, disappear )

	-- now for the do damage part...

	local function doDamage()
		GameController:hitDetection( p, wall.damage, "stationary flinch", nil, nil, wall ) 
	end
	-- start doing damage when the wall burns, like 10 times
	timer.performWithDelay( 750, doDamage, 6 )

	table.insert( allWalls, wall )
	
	return wall
end

function Hank_Wall:playTransform( wall_instance, direction )
	fireballTransform = display.newSprite( transformSheet, seqData )
	if( direction == -1 ) then
		fireballTransform:scale(-1,1)
	end
	fireballTransform.x = wall_instance.sprite.x
	fireballTransform.y = wall_instance.sprite.y
	fireballTransform:setSequence( "transform" )
	fireballTransform:play()

	fireballTransform:toFront()
	fireballTransform.remove = false

	local function delete()
		if( fireballTransform.remove == false ) then
			print("Remove fireballTransform")
			fireballTransform:removeSelf()
			fireballTransform.remove = true
		end
	end

	timer.performWithDelay( 300, delete )
end

return Hank_Wall

