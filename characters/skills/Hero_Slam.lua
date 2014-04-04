local camera = require("gameplay.Camera")

local seqData =
	{
		{ name = "on", start = 1, count = 20, time = 2000, loopCount = 1 },
	}

local data = {
	frames = {
		{ name=groundslam01, x = 315, y = 1260, width = 313, height = 313, sourceX=0, sourceY=0, sourceWidth=313 , sourceHeight=313 },
		{ name=groundslam02, x = 945, y = 945, width = 313, height = 313, sourceX=0, sourceY=0, sourceWidth=313 , sourceHeight=313 },
		{ name=groundslam03, x = 945, y = 630, width = 313, height = 313, sourceX=0, sourceY=0, sourceWidth=313 , sourceHeight=313 },
		{ name=groundslam04, x = 945, y = 315, width = 313, height = 313, sourceX=0, sourceY=0, sourceWidth=313 , sourceHeight=313 },
		{ name=groundslam05, x = 945, y = 0, width = 313, height = 313, sourceX=0, sourceY=0, sourceWidth=313 , sourceHeight=313 },
		{ name=groundslam06, x = 630, y = 1260, width = 313, height = 313, sourceX=0, sourceY=0, sourceWidth=313 , sourceHeight=313 },
		{ name=groundslam07, x = 630, y = 945, width = 313, height = 313, sourceX=0, sourceY=0, sourceWidth=313 , sourceHeight=313 },
		{ name=groundslam08, x = 630, y = 630, width = 313, height = 313, sourceX=0, sourceY=0, sourceWidth=313 , sourceHeight=313 },
		{ name=groundslam09, x = 630, y = 315, width = 313, height = 313, sourceX=0, sourceY=0, sourceWidth=313 , sourceHeight=313 },
		{ name=groundslam10, x = 630, y = 0, width = 313, height = 313, sourceX=0, sourceY=0, sourceWidth=313 , sourceHeight=313 },
		{ name=groundslam11, x = 945, y = 1260, width = 313, height = 313, sourceX=0, sourceY=0, sourceWidth=313 , sourceHeight=313 },
		{ name=groundslam12, x = 315, y = 945, width = 313, height = 313, sourceX=0, sourceY=0, sourceWidth=313 , sourceHeight=313 },
		{ name=groundslam13, x = 315, y = 630, width = 313, height = 313, sourceX=0, sourceY=0, sourceWidth=313 , sourceHeight=313 },
		{ name=groundslam14, x = 315, y = 315, width = 313, height = 313, sourceX=0, sourceY=0, sourceWidth=313 , sourceHeight=313 },
		{ name=groundslam15, x = 315, y = 0, width = 313, height = 313, sourceX=0, sourceY=0, sourceWidth=313 , sourceHeight=313 },
		{ name=groundslam16, x = 0, y = 1260, width = 313, height = 313, sourceX=0, sourceY=0, sourceWidth=313 , sourceHeight=313 },
		{ name=groundslam17, x = 0, y = 945, width = 313, height = 313, sourceX=0, sourceY=0, sourceWidth=313 , sourceHeight=313 },
		{ name=groundslam18, x = 0, y = 630, width = 313, height = 313, sourceX=0, sourceY=0, sourceWidth=313 , sourceHeight=313 },
		{ name=groundslam19, x = 0, y = 315, width = 313, height = 313, sourceX=0, sourceY=0, sourceWidth=313 , sourceHeight=313 },
		{ name=groundslam20, x = 0, y = 0, width = 313, height = 313, sourceX=0, sourceY=0, sourceWidth=313 , sourceHeight=313 },
	},
	sheetContentWidth = 1260,
	sheetContentHeight = 1575
}

local sheet = graphics.newImageSheet( "images/hero/groundslam.png", data )

local Hero_Slam = {
	flinchDamage = 10,
	blowupDamage = 100,
	knockbackPowerX = 0,
	knockbackPowerY = 1000,
}

local Hero_Slam_metatable = { __index = Hero_Slam }

function Hero_Slam:new( p ) -- Player is passed in to know where (x,y) to create sprites
	
	local slam = {}
	setmetatable(slam,Hero_Slam_metatable) -- all slams are created with same attributes
	
	slam.sprite = display.newSprite( sheet, seqData )
	slam.sprite:scale( p.mirror, 1 )
	slam.sprite:setSequence( "on" )
	slam.sprite:play()
	slam.sprite.x = p.sprite.x + p.mirror * 200
	slam.sprite.y = (p.sprite.y + p.bot) / 2

	camera.group:insert(slam.sprite)

	-- local function doDamage()
	-- 	GameController:hitDetection( p, slam.flinchDamage, "punch", nil, nil, slam ) 
	-- end

	-- timer.performWithDelay( 400, doDamage, 5 )

	local function blowup()
		GameController:hitDetection( p, slam.blowupDamage, "knockback+down", nil, nil, slam ) 
	end

	timer.performWithDelay( 1500, blowup )


	local function deleteSelf()
		slam.sprite:removeSelf()
		slam = nil
	end

	timer.performWithDelay( 3000, deleteSelf )
	
	return slam
end

return Hero_Slam

