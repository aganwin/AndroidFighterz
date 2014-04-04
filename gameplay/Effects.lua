local camera = require("gameplay.Camera")
local AudioController = require("gameplay.AudioController")

local Effects = {
	allEffects = {}
}

local seqData =
	{
		{ name="defend", start = 1, count = 3, time = 300, loopCount = 1 },
		{ name="dust", start = 4, count = 5, time = 500, loopCount = 1 },
		{ name="death start", frames = {13,12,11,10,9}, time = 2000, loopCount = 1 },
		{ name="death end", start = 9, count = 5, time = 2000, loopCount = 1 },
		{ name="hit", start = 14, count = 5, time = 300, loopCount = 1 },		
	}
	
local data = {
	frames = {
		{ name=EFFECT_BLOCK01, x = 315, y = 630, width = 313, height = 313, sourceX=0, sourceY=0, sourceWidth=313 , sourceHeight=313 },
		{ name=EFFECT_BLOCK02, x = 630, y = 0, width = 313, height = 313, sourceX=0, sourceY=0, sourceWidth=313 , sourceHeight=313 },
		{ name=EFFECT_BLOCK03, x = 630, y = 315, width = 313, height = 313, sourceX=0, sourceY=0, sourceWidth=313 , sourceHeight=313 },
		{ name=EFFECT_DUST01, x = 788, y = 630, width = 156, height = 156, sourceX=0, sourceY=0, sourceWidth=156 , sourceHeight=156 },
		{ name=EFFECT_DUST02, x = 632, y = 788, width = 156, height = 156, sourceX=0, sourceY=0, sourceWidth=156 , sourceHeight=156 },
		{ name=EFFECT_DUST03, x = 630, y = 630, width = 156, height = 156, sourceX=0, sourceY=0, sourceWidth=156 , sourceHeight=156 },
		{ name=EFFECT_DUST04, x = 945, y = 0, width = 156, height = 156, sourceX=0, sourceY=0, sourceWidth=156 , sourceHeight=156 },
		{ name=EFFECT_DUST05, x = 790, y = 788, width = 156, height = 156, sourceX=0, sourceY=0, sourceWidth=156 , sourceHeight=156 },
		{ name=EFFECT_SKULL01, x = 158, y = 945, width = 156, height = 156, sourceX=0, sourceY=0, sourceWidth=156 , sourceHeight=156 },
		{ name=EFFECT_SKULL02, x = 945, y = 158, width = 156, height = 156, sourceX=0, sourceY=0, sourceWidth=156 , sourceHeight=156 },
		{ name=EFFECT_SKULL03, x = 316, y = 945, width = 156, height = 156, sourceX=0, sourceY=0, sourceWidth=156 , sourceHeight=156 },
		{ name=EFFECT_SKULL04, x = 0, y = 945, width = 156, height = 156, sourceX=0, sourceY=0, sourceWidth=156 , sourceHeight=156 },
		{ name=EFFECT_SKULL05, x = 474, y = 945, width = 156, height = 156, sourceX=0, sourceY=0, sourceWidth=156 , sourceHeight=156 },
		{ name=hit01, x = 315, y = 315, width = 313, height = 313, sourceX=0, sourceY=0, sourceWidth=313 , sourceHeight=313 },
		{ name=hit02, x = 315, y = 0, width = 313, height = 313, sourceX=0, sourceY=0, sourceWidth=313 , sourceHeight=313 },
		{ name=hit03, x = 0, y = 630, width = 313, height = 313, sourceX=0, sourceY=0, sourceWidth=313 , sourceHeight=313 },
		{ name=hit04, x = 0, y = 315, width = 313, height = 313, sourceX=0, sourceY=0, sourceWidth=313 , sourceHeight=313 },
		{ name=hit05, x = 0, y = 0, width = 313, height = 313, sourceX=0, sourceY=0, sourceWidth=313 , sourceHeight=313 },
	},
	sheetContentWidth = 1103,
	sheetContentHeight = 1103
}

local sheet = graphics.newImageSheet( "images/effects/sprites.png", data )

function Effects:hit( p1, p2 )

	AudioController:playSound( "punch" )

	hitEffect = display.newSprite( sheet, seqData )
	hitEffect.x = (p1.sprite.x + p2.sprite.x ) / 2
	hitEffect.y = (p1.sprite.y + p2.sprite.y ) / 2
	camera.group:insert(hitEffect)
	hitEffect:setSequence( "hit" )
	hitEffect:play()
	hitEffect.startTime = system.getTimer()

	table.insert( self.allEffects, hitEffect )
	
end

function Effects:def( p1, p2 )

	AudioController:playSound( "blocked" )

	defEffect = display.newSprite( sheet, seqData )
	defEffect.x = (p1.sprite.x + p2.sprite.x ) / 2
	defEffect.y = (p1.sprite.y + p2.sprite.y ) / 2
	camera.group:insert(defEffect)
	defEffect:setSequence( "def" )
	defEffect:play()
	defEffect.startTime = system.getTimer()
	
	table.insert( self.allEffects, defEffect )
end

function Effects:dust( p )

	dustEffect = display.newSprite( sheet, seqData )
	dustEffect.x = p.sprite.x - p.mirror*p.bodyHitbox.contentWidth/2
	dustEffect.y = (p.sprite.y+p.bot)/2
	camera.group:insert(dustEffect)
	dustEffect.xScale = p.mirror
	dustEffect:setSequence( "dust" )
	dustEffect:play()
	dustEffect.startTime = system.getTimer()
	
	table.insert( self.allEffects, dustEffect )
end

function Effects:death( p )
	
	deathEffect = display.newSprite( sheet, seqData )
	deathEffect.x = p.sprite.x
	deathEffect.y = p.sprite.y - p.sprite.contentHeight/10
	camera.group:insert(deathEffect)
	deathEffect:setSequence( "death start" )
	deathEffect:play()
	
	-- below timers are problematic after game is over
	--[[
	timer.performWithDelay( 3000, function()
		if( deathEffect ) then
			deathEffect:setSequence( "death end" )
			deathEffect:play()
		end
	end)

	timer.performWithDelay( 5000, function()
		if( deathEffect ) then
			deathEffect:removeSelf()
		end
	end)
	]]--
end

return Effects


