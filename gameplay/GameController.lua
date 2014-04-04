-- GameController class is in charge of loading the assets and starting the game (the fight/duel)

local widget = require( "widget" )
local update = require( "gameplay.update" )
local Item = require( "gameplay.Item" )
local Stage = require( "gameplay.Stage" )
local Multiplayer = require( "multiplayer.Multiplayer" )
local Controls = require( "gameplay.Controls" )
local Ball = require( "gameplay.Ball" )
local Effects = require( "gameplay.Effects" )

local AI = require( "ai.Ai" )

local GameController = {
	-- good habit to initialize all variables here to keep track
	gameEnded = false,
	status = 0,
	startTime = 0,
	transitionTime = 500,

	allPlayers = {},
	opponents = {}, -- not used, see Player.opponents = {} instead
	controlledPlayer = nil,
	stagePicked = nil,
	myTeam = {},
	oppTeam = {},

	gameMode = nil,
	displayLayers = {},

	currentItems = {},
	hitRangeTopY = display.contentHeight*0.038, -- LF2 value of 50 / 292 pixels
	hitRangeBotY = display.contentHeight*0.0244,
	-- jumpDirection = 0, -- this shouldn't be here
}

function GameController:reset()
	GameController.status = 0
	GameController.startTime = 0
	GameController.transitionTime = 500

	GameController:removePlayersAndControls()
	GameController.allPlayers = {}
	GameController.opponents = {}
	GameController.controlledPlayer = nil
	GameController.stagePicked = nil
	GameController.myTeam = {}
	GameController.oppTeam = {}

	Ball.listOfBalls = {}
	Effects.allEffects = {}

	GameController.gameMode = nil
	GameController.displayLayers = {}
	GameController.currentItems = {} -- wipe needed
end

function GameController:load( gameType )
	if GameController.status == 0 then
		GameController.gameMode = gameType
		GameController.stagePicked = Stage:pick("hk")

		-- visual transition
		empty = display.newRect( 0, 0, display.contentWidth, display.contentHeight )
		empty:setFillColor( 0,0,0 )
		GameController.stagePicked.bgGroup.isVisible = true
		empty:toFront()
		GameController.stagePicked.bgGroup:toFront()		
		transition.dissolve( empty, GameController.stagePicked.bgGroup, transitionTime, 100 )
		
		GameController:loadPlayers()
		GameController:loadTeams()
		GameController:positionPlayers()
				
		GameController.startTime = system.getTimer()
		GameController.status = 1
		GameController.gameEnded = false
		startUpdateLoop()
	end
end

function GameController:removePlayersAndControls()
	print('removing players. # of players = ', #GameController.allPlayers)
	for i,p in pairs(GameController.allPlayers) do
		if( p.controlled == true ) then 
			p.controls.buttonGroup:removeSelf()
			p.controls.buttonGroup = display.newGroup()
			p.controls:reset()
		end
		p.hpmp:removeSelf()
		p.bar:removeSelf()
		p.barframe:removeSelf()
		p.symbol:removeSelf()
		p.debugText:removeSelf()
		table.remove(GameController.allPlayers,i)
	end
end

function GameController:unload()
	if( GameController.status == 1 ) then -- only unload if loaded!
		GameController.gameEnded = true
		GameController:reset()
		-- when all is said and done, go back to mode select screen
		local ModeSelect = require( "ModeSelect" )
		ModeSelect:drawMenu()
		
		-- is this even needed?
		Runtime._functionListeners = nil
		--Runtime._tableListeners = nil
	end
end

function GameController:loadPlayers()

	for i, p in pairs( GameController.allPlayers ) do	
		for k, q in pairs( GameController.allPlayers ) do
			if( i ~= k and q.teamNum == 0 or p.teamNum ~= q.teamNum ) then -- if player and p teamNum are both 0, does that contradict last condition?
				table.insert( p.opponents, q )
			end
		end	

		if p.controlled == true then
			-- this is yourself
			GameController.controlledPlayer = p
			p.controls = Controls.new(p)
			p:initialize()
			p:idle()
		else
			p:initialize()
			p:idle()
			if( p.isAI == false ) then
				p.controls = Controls.new(p)
			else
				-- initialize AI script
				p.AIController = AI.new(p)
				p.AIController:initialize()
				print('initialized a new AI', p.AIController.someValue)
			end
		end
	end  
end

-- this might cause duplicate "myselves" into your own team
function GameController:loadTeams()
	local myTeamNum = GameController.controlledPlayer.teamNum
	for k,v in pairs( GameController.allPlayers ) do
		if v.teamNum == myTeamNum then
			table.insert(GameController.myTeam, v)
		else
			table.insert(GameController.oppTeam, v)
		end
	end
end

function GameController:withinRange(aggressor, enemy, x, y)

	local hitRangeBotY = GameController.hitRangeBotY
	local hitRangeTopY = GameController.hitRangeTopY

	if y then
		hitRangeBotY = y
		hitRangeTopY = y
	end

	-- if y-position isn't even correct, do not bother checking x-positions
	if aggressor.sprite.y - enemy.sprite.y > hitRangeBotY then
		return false
	elseif aggressor.sprite.y - enemy.sprite.y < -hitRangeTopY then
		return false
	end

	if aggressor.mirror == 1 then
		if aggressor.sprite.x < enemy.sprite.x then
			if x then
				if (aggressor.sprite.x + x) > (enemy.sprite.x - enemy.bodyHitbox.width/2) then
					return true
				end
			elseif (aggressor.sprite.x + aggressor.character.rangeX) > (enemy.sprite.x - enemy.bodyHitbox.width/2) then
				return true
			end
		end
	else
		if aggressor.sprite.x > enemy.sprite.x then
			if x then
				if (aggressor.sprite.x - x) < (enemy.sprite.x + enemy.bodyHitbox.width/2) then 
					return true
				end
			elseif (aggressor.sprite.x - aggressor.character.rangeX) < (enemy.sprite.x + enemy.bodyHitbox.width/2) then 
				return true
			end
		end
	end

	return false
end

function GameController:objectWithinRange(object, enemy)
	if math.abs(object.sprite.x - enemy.sprite.x) < object.sprite.contentWidth then
		if math.abs(object.sprite.y - enemy.bot) < object.sprite.contentHeight/3 then -- firewalls and earth cracks should line up with enemy bot if possible
			return true
		end
	end
	return false
end

function GameController:positionPlayers()
	-- position players, facing each other, in center of stage at the start of fight
	for k,player in pairs(GameController.allPlayers) do
		if p.teamNum == 1 then
			p.sprite.x = Stage.boundaryRight/2-150
			p.sprite.y = 400
		else
			p.sprite.x = Stage.boundaryRight/2+150
			p.sprite.y = 400
			p:flipHorizontal(-1)
		end
	end
end

-- Hit detection method --
-- aggressor = the guy who is punching
-- damage = damage
-- typeOfHit = depends on what kind of hit its going to be, could be knockdown, or just a normal punch
-- customRange means that the attack has farther range than normal
-- object = thrown items
-- customPower means that the attack will have knockback properties which will send the opponent "flying" back (Player:modifiedJump())
	
function GameController:hitDetection(aggressor, damage, typeOfHit, customRangeX, customRangeY, object, customPowerX, customPowerY)

	if GameController.gameEnded == true then return end
		
	local hitDetected = false

	if( customRangeX ~= nil ) then
		detectRangeX = customRangeX
	else
		detectRangeX = aggressor.character.rangeX
	end

	if( customRangeY ~= nil ) then
		detectRangeY = customRangeY
	else
		detectRangeY = aggressor.character.rangeY
	end

	if( customPowerX ~= nil ) then
		powerX = customPowerX
	else
		powerX = aggressor.character.knockbackPowerX
	end

	if( customRangeY ~= nil ) then
		powerY = customPowerY
	else
		powerY = aggressor.character.knockbackPowerY
	end

	for key, enemy in pairs(aggressor.opponents) do

		if enemy.invulnerable == true then 
			return 
		end
		
		if GameController:withinRange(aggressor, enemy, customRangeX, customRangeY) == true then
			-- you can only defend if you are FACING the incoming attack!
			if( enemy.defense == true and enemy.mirror == aggressor.mirror*-1 ) then
				enemy:defend( damage, aggressor.knockbackPowerX )
				Effects:def( aggressor, enemy )
				hitDetected = true
			else
				enemy.flinchTime = aggressor.atkTimeDuration
				enemy:getsHit( damage, typeOfHit, aggressor.mirror, true, powerX, powerY)
				-- play hit effect halfway between aggressor and enemy
				if( enemy:checkPermissions( "getting hit" ) == true ) then
					Effects:hit( aggressor, enemy )
					hitDetected = true
				end
			end
		end

		if( typeOfHit == "radiusBased" ) then -- do more damage if close by
			-- calculate damage
			damage = damage - math.pow( math.abs(aggressor.sprite.x - enemy.sprite.x), 0.9 )
			if( damage < 0 ) then
				return
			else
				if( math.abs(aggressor.sprite.x - enemy.sprite.x) < aggressor.sprite.width/2 ) then -- if within around 40 pixels
					enemy:getsHit( damage, "knockdown", aggressor.mirror*-1, false )
					hitDetected = true
				else
					enemy:getsHit( damage, "punch", aggressor.mirror*-1, false )
					hitDetected = true
				end
			end
		end
				
		if( object ~= nil ) then
			if GameController:objectWithinRange(object,enemy) == true then
				if( enemy.defense == true and enemy.mirror == object.mirror*-1 ) then
					enemy:defend( damage, object.knockbackPowerX )
					Effects:def( object, enemy )
					hitDetected = true
				else
					enemy:getsHit( damage, typeOfHit, aggressor.mirror, false, object.knockbackPowerX, object.knockbackPowerY )
				    -- play hit effect halfway between aggressor and enemy
					Effects:hit( object, enemy )
					hitDetected = true
				end
			end
		end
	end	

	return hitDetected -- false by default if not detected			
end

return GameController