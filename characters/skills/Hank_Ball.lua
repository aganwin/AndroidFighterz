local Ball = require( "gameplay.Ball" )

local seqData =
	{
		{ name="moving", start = 10, count = 3, time = 300, loopCount = 0 },
		{ name="explode", start = 13, count = 6, time = 300, loopCount = 1 },
		{ name="bigmoving", start = 1, count = 3, time = 300, loopCount = 0 },
		{ name="bigexplode", start = 4, count = 6, time = 300, loopCount = 1 },
	}
	
local data = {
	frames = {
		{ name=bigfireball01, x = 158, y = 474, width = 156, height = 156, sourceX=0, sourceY=0, sourceWidth=156 , sourceHeight=156 },
		{ name=bigfireball02, x = 474, y = 158, width = 156, height = 156, sourceX=0, sourceY=0, sourceWidth=156 , sourceHeight=156 },
		{ name=bigfireball03, x = 474, y = 0, width = 156, height = 156, sourceX=0, sourceY=0, sourceWidth=156 , sourceHeight=156 },
		{ name=bigfireball04, x = 316, y = 632, width = 156, height = 156, sourceX=0, sourceY=0, sourceWidth=156 , sourceHeight=156 },
		{ name=bigfireball05, x = 316, y = 474, width = 156, height = 156, sourceX=0, sourceY=0, sourceWidth=156 , sourceHeight=156 },
		{ name=bigfireball06, x = 316, y = 316, width = 156, height = 156, sourceX=0, sourceY=0, sourceWidth=156 , sourceHeight=156 },
		{ name=bigfireball07, x = 316, y = 158, width = 156, height = 156, sourceX=0, sourceY=0, sourceWidth=156 , sourceHeight=156 },
		{ name=bigfireball08, x = 316, y = 0, width = 156, height = 156, sourceX=0, sourceY=0, sourceWidth=156 , sourceHeight=156 },
		{ name=bigfireball09, x = 158, y = 632, width = 156, height = 156, sourceX=0, sourceY=0, sourceWidth=156 , sourceHeight=156 },
		{ name=fireball01, x = 474, y = 316, width = 156, height = 156, sourceX=0, sourceY=0, sourceWidth=156 , sourceHeight=156 },
		{ name=fireball02, x = 158, y = 316, width = 156, height = 156, sourceX=0, sourceY=0, sourceWidth=156 , sourceHeight=156 },
		{ name=fireball03, x = 158, y = 158, width = 156, height = 156, sourceX=0, sourceY=0, sourceWidth=156 , sourceHeight=156 },
		{ name=fireball04, x = 158, y = 0, width = 156, height = 156, sourceX=0, sourceY=0, sourceWidth=156 , sourceHeight=156 },
		{ name=fireball05, x = 0, y = 632, width = 156, height = 156, sourceX=0, sourceY=0, sourceWidth=156 , sourceHeight=156 },
		{ name=fireball06, x = 0, y = 474, width = 156, height = 156, sourceX=0, sourceY=0, sourceWidth=156 , sourceHeight=156 },
		{ name=fireball07, x = 0, y = 316, width = 156, height = 156, sourceX=0, sourceY=0, sourceWidth=156 , sourceHeight=156 },
		{ name=fireball08, x = 0, y = 158, width = 156, height = 156, sourceX=0, sourceY=0, sourceWidth=156 , sourceHeight=156 },
		{ name=fireball09, x = 0, y = 0, width = 156, height = 156, sourceX=0, sourceY=0, sourceWidth=156 , sourceHeight=156 },
	},
	sheetContentWidth = 632,
	sheetContentHeight = 790
}

local sheet = graphics.newImageSheet( "images/hank/fireball.png", data )

local Hank_Ball = { speed = 10, 
					  -- damage = 50, 
					  speedUp = 1.2,
					  hitTarget = false,
					  knockbackPowerX = 500, --200,
					  knockbackPowerY = 1000, --500,
					  caster = "Hank",
					  lastspeedup = 0,
					  speeduprate = 1.1,
					  speedupinterval = 100,
					  } -- default attributes of a ball

local Hank_Ball_metatable = { __index = Hank_Ball } -- on making a new ball, the above are the defaults (index ~ defaults)

-- here we define a constructor for Hank_Ball.
-- This is PSEUDO-OOP... Hank_Ball is an object, and in Lua you describe objects using tables

function Hank_Ball:new( p ) -- Player is passed in to know where (x,y) to create sprites
	local b = {}
	setmetatable(b,Hank_Ball_metatable) -- all balls are created with same attributes
	
	-- each ball = one sprite
	b.sprite = display.newSprite( sheet, seqData )
	b.sprite:scale(1.5,1.5)
	b.sprite:setSequence( "moving" )
	b.sprite:play()
	b.sprite.x = p.sprite.x + p.mirror*p.bodyHitbox.contentWidth -- position relative to Hank sprite
	b.sprite.y  = p.bodyHitbox.y -- same height as his feet, magic number 
	b.bot = b.sprite.y + b.sprite.contentHeight/2
	-- if player is facing left, mirror the ball, set the speed to be going left
	if( p.mirror == -1 ) then
		b.sprite:scale(-1,1)
		b.mirror = -1
		b.speed = b.speed * -1 
	else
		b.mirror = 1
	end

	if( p.controlled == false ) then
		b.speedupinterval = 200
	end

	b.buffed = false
	b.lastSpeedup = system.getTimer( )
	b.castingPlayer = p

	b.typeOfBall = self
	b.remove = false

	table.insert( Ball.listOfBalls, b )	

	return b
end

function Hank_Ball:speedup()
	self.speed = self.speed * self.speedUp
	self.lastSpeedup = system.getTimer( )
end

function Hank_Ball:transformBig( b ) -- sprite of the ball is passed in, not the table
	
	b.sprite:setSequence( "bigmoving" )
	b.sprite:play()

end

function Hank_Ball:explode( b ) -- sprite of the ball is passed in, not the table
	
	--ball.sprite.isVisible = false
	b = nil

	-- 2. set explode sequence
	--self:setSequence("explode")
	--self:play()
end

return Hank_Ball

