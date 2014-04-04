local Ball = require( "gameplay.Ball" )

local seqData =
	{
		{ name="moving", start = 1, count = 3, time = 300, loopCount = 0 },
		{ name="explode", start = 4, count = 5, time = 300, loopCount = 1 }
	}
	
local data = {
	frames = {
		{ name=dlrjp01, x = 158, y = 0, width = 156, height = 156, sourceX=0, sourceY=0, sourceWidth=156 , sourceHeight=156 },
		{ name=dlrjp02, x = 316, y = 0, width = 156, height = 156, sourceX=0, sourceY=0, sourceWidth=156 , sourceHeight=156 },
		{ name=dlrjp03, x = 158, y = 316, width = 156, height = 156, sourceX=0, sourceY=0, sourceWidth=156 , sourceHeight=156 },
		{ name=dlrjp04, x = 158, y = 158, width = 156, height = 156, sourceX=0, sourceY=0, sourceWidth=156 , sourceHeight=156 },
		{ name=dlrjp05, x = 316, y = 158, width = 156, height = 156, sourceX=0, sourceY=0, sourceWidth=156 , sourceHeight=156 },
		{ name=dlrjp06, x = 0, y = 316, width = 156, height = 156, sourceX=0, sourceY=0, sourceWidth=156 , sourceHeight=156 },
		{ name=dlrjp07, x = 0, y = 158, width = 156, height = 156, sourceX=0, sourceY=0, sourceWidth=156 , sourceHeight=156 },
		{ name=dlrjp08, x = 0, y = 0, width = 156, height = 156, sourceX=0, sourceY=0, sourceWidth=156 , sourceHeight=156 },
	},
	sheetContentWidth = 474,
	sheetContentHeight = 474
}

local sheet = graphics.newImageSheet( "images/hero/dlrjp.png", data )

local Hero_Ball = { speed = 5, 
					  -- damage = 50
					  hitTarget = false,
					  knockbackPowerX = 200,
					  knockbackPowerY = 500,
					  caster = "Hero",
					  lastspeedup = 0,
					  speeduprate = 1.1,
					  speedupinterval = 100,
				  } -- default attributes of a ball

local Hero_Ball_metatable = { __index = Hero_Ball } -- on making a new ball, the above are the defaults (index ~ defaults)

-- here we define a constructor for Hero_Ball.
-- This is PSEUDO-OOP... Hero_Ball is an object, and in Lua you describe objects using tables

function Hero_Ball:new( p ) -- Player is passed in to know where (x,y) to create sprites
	local b = {}
	setmetatable(b,Hero_Ball_metatable) -- all balls are created with same attributes
	
	-- each ball = one sprite
	b.sprite = display.newSprite( sheet, seqData )
	b.sprite:scale(2,2)
	b.sprite:setSequence( "moving" )
	b.sprite:play()
	b.sprite.x = p.sprite.x + p.sprite.width/5 -- position relative to Hero sprite
	b.sprite.y = p.sprite.y - b.sprite.height/5  -- same height as his feet, magic number 
	b.bot = b.sprite.y + b.sprite.contentHeight/2
	-- if player is facing left, mirror the ball, set the speed to be going left
	if( p.mirror == -1 ) then
		b.sprite:scale(-1,1)
		b.mirror = -1
		b.speed = b.speed * -1 
	else
		b.mirror = 1
	end

	b.castingPlayer = p
	b.typeOfBall = self
	b.remove = false

	table.insert( Ball.listOfBalls, b )

	return b
end

function Hero_Ball:speedup()
	self.speed = self.speed * self.speedUp
end

function Hero_Ball:explode( b ) -- sprite of the ball is passed in, not the table
	
	--ball.sprite.isVisible = false
	b = nil

	-- 2. set explode sequence
	--self:setSequence("explode")
	--self:play()
end

return Hero_Ball

