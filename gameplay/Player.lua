-------------------------------------------------
--
-- Player.lua
--
-- Template for a player class, AI included (9/3/2013)
--
-------------------------------------------------

local Item = require( "gameplay.Item" )
local Hero = require( "characters.Hero" )
local Hank = require( "characters.Hank" )
local Effects = require( "gameplay.Effects" )
local Debug = require( "helpers.Debug" )
local camera = require( "gameplay.Camera" )

local Player = {	

	stopUpdating = false, -- true when game over, applied to update() and idle triggering functions
	   
	bot = 0,

	hpValue = 300,
	fullhpValue = 300,
	mpValue = 100,
	fullmpValue = 100,
	baseMpRegenValue = 0.01,

	thrownAsObjectLandingDamage = 50,
	thrownAsObjectCrashingDamage = 30,

	-- Basic states
	mirror = 1, -- which side Player is facing; 1 = right, -1 = left
	fallen = false,
	invulnerable = false, -- when rolling or on the floor, Player cannot be damaged
	dead = false, -- when reduceHP takes self's hp to 0, dead becomes true and fallen animation plays
	hit = false,
	flinching = false, -- normal flinch reaction to normal punches
	alreadyHit = false, -- so attacks like Hank's dlrj don't proc multiple times
	flinchStartTime = 0,
	flinchTime = 300,
	flinchDistance = display.contentWidth * 0.007, -- player should be knocked a little back when flinching
	--stunned
	stunned = false,
	stunnedStartTime = 0,
	stunnedTime = 2000,
	--grabbed
	grabbed = false,
	grabbing = false,
	grabTime = 1800,
	--throwing
	throwing = false,
	throwStartTime = 0,
	throwTime = 300, -- based on character animation
	totalThrowTime = 500, -- let's animation stay on the last frame to look more realistic
	fallenTimeStart = 0,
	fallenTimeDuration1 = 750,
	fallenTimeDuration2 = 2000,
	gettingUp = false,
	getUpTimeStart = 0,
	getUpTimeDuration = 500, 


	-- Running and walking speed related; based on screen width 
	speedX = 0,
	speedY = 0,
	walking = false,
	running = false,
	runningAcceleration = true,
	defaultRunningSpeed = 7, --display.contentWidth/200,
	defaultWalkingSpeed = 4, --display.contentWidth/400,
	defaultSpeedY = 3, --display.contentHeight/576,
	defaultDragSpeed = 7, --display.contentWidth/200,
	runningSpeed = display.contentWidth/200, -- in new(), this will be factored based on character
	walkingSpeed = display.contentWidth/400, -- same
	verticalSpeedY = display.contentWidth/576, -- same
	runDiagonalSpeedRatio = 0.636, -- calibrated from LF2 by measuring ratio of time required to run and walk over a y-distance
	walkDiagonalSpeedRatio = 0.8,
	dragSpeed = display.contentWidth/200,
	destinationX = 0, -- when player gets hit, send him to a certain destination in stateCheck()
	destinationY = 0,

	movementOverride = false, -- turns to true during certain special attacks that require manual movement of character, or else inside initialize.lua, if no ^v<> buttons are pressed then directionX/Y are repeatedly turned to 0
	movementOverrideMask = { x = 1, y = 1 },

	-- Defense related
	defense = false,
	defTime = 500, -- amount of time Player can defend for
	defTimeStart = 0,
	defDelay = false,
	defDelayTimeStart = 0,
	defDelayTime = 100,

	-- Dodge/roll
	dodging = false, -- uses same code as defense
	
	-- Jumping related
	jumped = false,
	mJumped = false, -- falls that require bounciness
	-- mJump related
	firstBounce = false,
	previousBounceUy = 0,
	cutOffBounceVy = 100,
	friction = 0.7,
	bounciness = 0.5,
	jumpTimer = 0, -- allow short amout of time after a static jump to do a fast jump
	directionX = 0,
	directionY = 0,
	directionH = 0, -- for multiplayer sync checks only
	directionV = 0,
	justJumped = false,
	jumpTimeWindow = 300, -- allow 300 ms to issue another jump after landing to do a jump->hop->jump->... combo
	-- new (6/23) no physics implementation
	
	thrownAsObject = false,
	damageWhenThrown = 50,

	currentJumpTime = 0,
	jumpStartTime = 0,
	defaultUx = 400,
	runningUx = 800,
	Vy = 0, -- instantaenous velocity in y
	Ux = 0, -- velocity in x (constant)
	Uy = 0, -- initial velocity in y
	defaultUy = 950, --850, -- tweak for jump height; should be 2.2x of character pixel height
	runningUy = 700, --580, -- less jump height on a running jump
	gravity = 750, -- tweak for total time jumped; LF2 is around 750-800 ms
	Y0 = 0, -- initial x,y position for the jump, used for ending jump on land
	jumpLandingDisplacementY = 0, -- pressing up or down while jumping displaces the landing position
	defaultJumpLandingDisplacementY = 85,
	X0 = 0,
	offensiveJump = false,
	jumpDirection = 0,
	
	-- jump recover
	recovering = false,	

	-- Attacking related
	attacking = false,
	normalAttackPenalty = false,
	normalAttackPenaltyTime = 100, -- a possible bug exists, please see commit of 2/14
	lastNormalPunch = "punch2",
	punchCount = 0,
	grabPunchAllowed = true,
	runAtkTime = 500, -- should be determined by each character themselves, so this is just a default value
	jumpAtkTime = 9999, -- jump attacks cannot be done more than once
	atkTimeStart = 0,
	atkTimeDuration = 0,
	
	-- Items and Special Attacks related
	-- holding Items
	itemHeldFlag = false,
	itemBeingHeld = nil, -- doubles as a flag as well	
	thrownItem = false,
	throwPower = 1,
	pickUpDistanceX = 100,
	pickUpDistanceY = 100,
	
	-- special moves table to listen for commands such as D ^ A
	commands = "",
	performingSpecial = "none", -- flag to indicate Player is performing a special - can't interrupt it
	startedSpecial = 0,
	typeOfSpecial = "",
	spriteSwapping = false,

	-- for ranged attacks
	shootingBalls = false,
	shootBallDelay = 0,
	balls = {},
	
	-- table for all opponents of this player
	opponents = {},	
	
	-- AI
	xTarget = 9999,
	yTarget = 9999,
	closestEnemyDistanceX = 9999,
	closestEnemyDistanceY = 9999,
	state = "",
	itemIsCloser = false,
	-- AI Decision making
	chosenSkill = "",
	skillTimeout = 1000,
	lastMeleeSkillTime = 0,
	lastRangedSkillTime = 0,

	lastDecision = 0,
	decision = 0,
	decisionMade = false,
	decisionCooldown = 0,
	stateChangedRecently = false,
	lastSpriteChange = 0, -- for custom idle animations in update()

	lastRandomAction = "",
	lastRandomActionTimeout = 0,
	lastRandomActionTime = 0,


	-- for system pausing

	pauseTimeDiff = 0,
	pauseTimeStart = 0,

	-- for multiplayer only
	networkSaidStop = false, -- an enable/disable flag for moving 
	networkMoveStartTime = 0,
	networkMoveDuration = 0,
	
	localMoveDuration = -1,
	localMoveStartTime = -1,
	localMoveStopTime = -1,
	
	finalX = 0, finalY = 0,
	interpolationDelay = 0, -- get used to it!
	latency = 0,

	-- multiplayer slowdown
	slowDownFactor = 1,

	debt = {
		right = 0,
		left = 0,
		up = 0,
		down = 0,
	}
}

local Player_metatable = {
	__index = Player
}

function Player.new( name, num, controlled, ai, id, customOptions )

	if customOptions then
		x = customOptions.x
		y = customOptions.y
	end

	p = { 
		name = name,
		teamNum = num, -- 0 = independent, 1, 2, 3, 4...
		controlled = controlled, -- false = any multiplayer player or AI, true = you
		isAI = ai, -- is this player an AI?
		id = id, -- FOR MULTIPLAYER
		opponents = {},
		spriteSet = "normal",
		character = nil,
		startAtX = x,
		startAtY = y,
	} -- must override name variable in Player{} to create sprite

	--p.debugText = display.newText( { text = "", x = 0, y = 0, width = 400, height = 720, font = "Verdana", fontSize = 25 } )
	p.debugText = display.newText( "", 0, 0, "Verdana", 25 )
	p.debugText:setTextColor( 0, 0, 0 )

	setmetatable( p, Player_metatable )
	
	return p
end

function Player:initialize()
	
	-- Sprite Data --
	if DebugInstance.logText then print( "Created player on team "..self.teamNum.." using the character "..self.name.."." ) end

	-- Use this player's name to create relevant sprite and character
	local char = self:selectPlayer( self.name )
	self.character = char:new( self.name ) -- for example, self.character = Davis:new()

	self.sprite = display.newSprite( self.character.sheet, self.character.seqData )
	self.sprite2 = display.newSprite( self.character.sheet2, self.character.seqData2 )
	self.sprite3 = display.newSprite( self.character.sheet3, self.character.seqData3 )
	self.sprite2.isVisible = false; self.sprite3.isVisible = false; -- only used for skills

	if self.startAtX then
		self.sprite.x = self.startAtX
	else
		self.sprite.x = math.random(0, display.contentWidth)
	end

	if self.startAtY then
		self.sprite.y = self.startAtY
	else
		self.sprite.y = math.random(display.contentHeight * 0.4, display.contentHeight * 0.7)
	end

    self.sprite:scale( self.character.scaleFactor, self.character.scaleFactor )
		
	----------------------------------------------- HP/MP BAR ----------------------------------------------- 
	
	self.hpmp = display.newGroup()

	if( self.controlled == false ) then
		self.hpmp = display.newGroup()

    	self.bar = display.newImage( "images/hpmpbars/barenemysmall.png" )
      	self.hp = display.newImage( "images/hpmpbars/hpenemy.png" )
      	self.mp = display.newImage( "images/hpmpbars/mpsmall.png" )
      	self.barframe = display.newImage( "images/hpmpbars/framesmall.png" )
      	self.symbol = display.newImage( "images/hpmpbars/enemies.png" )
      	self.hpmp:insert( self.hp )
      	self.hpmp:insert( self.mp )
	    -- hp bar needs a mask because the parallelogram will protrude out of the frame when shrunk
	    local hpmask  = graphics.newMask( "images/hpmpbars/hpmpmasksmall.png" )
	    self.hpmp:setMask( hpmask )

	    -- for debug only, Hitboxes
		self.bodyHitbox = display.newRect( 0, 0, self.sprite.contentWidth * 68/156, self.sprite.contentHeight * 85/156)
		self.bodyHitbox:setStrokeColor( 0, 255, 0 )

		--self.sprite.contentWidth * 50/156
		self.attackHitbox = display.newRect( 0, 0, self.character.rangeX, self.sprite.contentHeight * 20/156)
		self.attackHitbox:setStrokeColor( 0, 255, 0 )
	else
		self.bar = display.newImage( "images/hpmpbars/newbar.png" )
		self.hp = display.newImage( "images/hpmpbars/newhp.png" )
		self.hpUnder = display.newImage( "images/hpmpbars/newhpunder.png" )
		self.mp = display.newImage( "images/hpmpbars/newmp.png" )
		self.barframe = display.newImage( "images/hpmpbars/newframe.png" )
		self.mpUnder = display.newImage( "images/hpmpbars/newmpunder.png" )
		self.symbol = display.newImage( "images/hpmpbars/main.png" )

		self.hpmp:insert( self.mpUnder )
		self.hpmp:insert( self.hpUnder )
		self.hpmp:insert( self.mp )
		self.hpmp:insert( self.hp )

		-- hp bar needs a mask because the parallelogram will protrude out of the frame when shrunk
	    local hpmask  = graphics.newMask( "images/hpmpbars/hpmpmask.png" )
	    self.hpmp:setMask( hpmask )

		self.hpmp:setReferencePoint( display.TopLeftReferencePoint )
		self.hpmp.x = 0
		self.hpmp.y = 0

		self.hpLeft = self.hp.x
		self.mpLeft = self.mp.x

		-- for debug only, Hitboxes
		self.bodyHitbox = display.newRect( 0, 0, self.sprite.contentWidth * 68/156, self.sprite.contentHeight * 85/156)
		self.bodyHitbox:setStrokeColor( 0, 0, 255 )

		self.attackHitbox = display.newRect( 0, 0, self.character.rangeX, self.sprite.contentHeight * 20/156)
		self.attackHitbox:setStrokeColor( 0, 255, 0 )

	end

	self.hpOffset = 0	
	self.mpOffset = 0

	self.bodyHitbox.strokeWidth = 5
	self.bodyHitbox:setFillColor( 0, 0, 0, 0 )
	self.bodyHitbox:setReferencePoint( display.CenterReferencePoint )

	self.attackHitbox.strokeWidth = 3
	self.attackHitbox:setFillColor( 0, 0, 0, 0 )
	self.attackHitbox:setReferencePoint( display.TopLeftReferencePoint )

	-- experiment: darken screen overlay
	self.darkOverlay = display.newRect( 0, 0, display.contentWidth, display.contentHeight )
	self.darkOverlay:setFillColor( 0, 0, 0 ) -- black
	self.darkOverlay.alpha = 0.5 -- grey out
	self.darkOverlay.isVisible = false

	if( DebugInstance.hitboxes == false ) then 
		self.bodyHitbox.isVisible = false
		self.attackHitbox.isVisible = false
		-- need to disable elsewhere as well
	end

	-- custom walk run speeds
	self.runningSpeed = self.runningSpeed*self.character.runningSpeedFactor
	self.walkingSpeed = self.walkingSpeed*self.character.walkingSpeedFactor

	-- *new* display group needed to follow with player sprite when moving across a scrolling screen
	self.group = display.newGroup() 
	self.group:insert( self.attackHitbox )
	self.group:insert( self.bodyHitbox )
	self.group:insert( self.debugText )
	if( self.controlled == false ) then
		self.group:insert( self.hpmp )
		self.group:insert( self.bar )
		self.group:insert( self.barframe ) 
		self.group:insert( self.symbol )
	end
end
	
function Player:idle( check, yesDelay )

	-- from Initialize.lua you will see Player:idle( true, true )
	-- this means that it is a packet to be sent, but there is a delay for interpolation that needs to be applied since its a user input
	-- network player idles will come in as idle( false, nil )
	-- so they won't send a packet, and they won't be delayed

	-- false false = your opponents simulation will take care of it for you, no delay, no message sent 
	-- true false = non-reactive idle... hmm probably not any
	-- true true = non-reactive idle, yes delay, such as player letting go of button (YOU caused it)

	if( currentGameMode == "multiplayer" and check == true or check == nil ) then
		self:changeState( "idle" )		
	end	

	if( self.stopUpdating == false ) then -- going back to idle after game is over will crash because sprite is gone
		if( yesDelay == true ) then 
			timer.performWithDelay( self.interpolationDelay, function()
				if( self:checkPermissions("idle") == true ) then self:goIdle() end
			end)
		else
			if( self:checkPermissions("idle") == true ) then self:goIdle() end
		end
	end
end

-- the reason this function is needed is because:
-- even if there is interpolation, a character's animation should go back to idle IMMEDIAELY after its done playing
-- there shouldn't be a delay between finishing a move -> going back to idle
-- so in Player:idle() by default noDelay is nil, which means, there is no delay for going into idle
function Player:goIdle()

	-- conditions where you absolutely cant go idle
	if( self:checkPermissions("idle") == false ) then
		print(self.name, "not allowed to go idle. Here's why:")
		self:printVariables()
		return
	end

	self:stopMoving() -- this is instant from this point of view, unlike changeDirection()

	-- switch back to normal sprites
	if( self.spriteSet ~= "normal" ) then
		self:spriteSwap( "normal" )
	end

	-- make sure all variables are set
	self.defense = false
	self.dodging = false
	self.jumped = false; self.gravity = 750; self.defaultGravity = 750; -- modifiedJump might change this
	self.running = false
	self.walking = false
	self.attacking = false
	self.performingSpecial = "none"
	self.typeOfSpecial = ""
	self.startedSpecial = system.getTimer()
	-- now done in appropriate recovery/dodge/getup code instead -- self.invulnerable = false
	self.fallen = false
	self.gettingUp = false
	self.throwing = false
	self.flinching = false
	self.alreadyHit = false

	self.grabPunchAllowed = true -- allow grab punch again for next time
	
	-- new, for pausing
	self.pauseTimeDiff = 0
	
	-- in Hero's dlrj (drill attack/tornado punch) move, I needed to set the flag
	-- movementOverride to true to allow forced movement
	-- I must manually reset the speed back to 0 if mO was on.					
	if( self.movementOverride == true ) then
		self.directionX = 0
		self.directionY = 0
		self.speedX = 0
		self.speedY = 0
		self.movementOverride = false
	end

	self.movementOverrideMask = { x = 1, y = 1 } -- this might need to go inside above inside

	if self.justJumped == true then -- if we just jumped and L/R button is held, we should walk and not be idle
		if self.controls then
			if self.controls.bRightPressed == true or self.controls.bLeftPressed == true then
				self:walk()
			else
				self.sprite:setSequence( "idle" )
				self.sprite:play()
			end
		else -- no L/R button was pressed after jump finished
			self.sprite:setSequence( "idle" )
			self.sprite:play()

			self.speedX = 0 -- might need to delete
			self.speedY = 0 -- might need to delete
			self.Vy = 0
		end
	else
		-- only set to idle once, or else animation will just be stuck on first frame
		if( self.sprite.sequence ~= "idle" ) then
			self.sprite:setSequence( "idle" )
			self.sprite:play()
			self.sprite.blendMode = "normal"
		end
		self.speedX = 0 -- might need to delete
		self.speedY = 0 -- might need to delete
		self.directionX = 0
		self.directionY = 0
		self.Vy = 0
	end

	-- turn Hitbox back to normal color
	if( self.controlled ) then
		self.bodyHitbox:setStrokeColor( 0, 255, 0 )
	else
		self.bodyHitbox:setStrokeColor( 0, 0, 255 )
	end

	self.attackHitbox.isVisible = false
end

function Player:stopMoving()
	--if not( init.bUpLeftPressed or init.bUpRightPressed or init.bDownLeftPressed or init.bDownRightPressed ) then
		if( self.movementOverride == false ) then -- if doing Player:zoom(), letting go of buttons won't stop the Player
			self.directionX = 0
			self.directionY = 0
		end
	--end
end

function Player:autoIdle( check ) -- only for AI - let AI go into idle mode, but it shouldn't mess up his other functions. e.g. if he goes into self:idle() nonstop, he will not fall()
  
  if( check == false or self:checkPermissions( "auto idle" ) == true ) then 
	-- make sure all variables are set
    self.defense = false
    self.jumped = false
    self.running = false
    self.attacking = false
    self.performingSpecial = "none"
    self.typeOfSpecial = ""
    self.invulnerable = false	
    self.fallen = false
    self.gettingUp = false
	
    -- in Hero's dlrj (drill attack/tornado punch) move, I needed to set the flag
    -- movementOverride to true to allow forced movement
    -- I must manually reset the speed back to 0 if mO was on.					
    if( self.movementOverride == true ) then
      self.directionX = 0
      self.speedX = 0
      self.speedY = 0
      self.movementOverride = false
      self.movementOverrideMask = { x = 1, y = 1 }
    end

    if self.justJumped then -- if we just jumped and L/R button is held, we should walk and not be idle
      if self.controls then
      	if self.controls.bRightPressed or self.controls.bLeftPressed then
      		self:walk(true,false)
      	end
      else -- no L/R button was pressed after jump finished
        self.sprite:setSequence( "idle" )
        self.sprite:play()
        self.speedX = 0 -- might need to delete
        self.speedY = 0 -- might need to delete
        self.Vy = 0
      end
    else
      self.sprite:setSequence( "idle" )
      self.sprite:play()
      self.speedX = 0 -- might need to delete
      self.speedY = 0 -- might need to delete
      self.Vy = 0
    end

    if( currentGameMode == "multiplayer" and check ~= false ) then
    	self:changeState( "auto idle" )
    end	
  end
end

function Player:walk( check )
	
	if( currentGameMode == "multiplayer" and check ~= false ) then
		self:changeState( "walk" )
	end	

	timer.performWithDelay( self.interpolationDelay, function()

	if( self:checkPermissions( "walk" ) == true ) then

		-- if the walking sprite is already playing, don't replay it
		if self.sprite.sequence ~= "walk" then
			--if( self.controlled == true or self.controlled == false and self.networkMoveDuration > 100 ) then -- don't play walk animation on other players who only walk a short distance
				self.sprite:setSequence( "walk" )
				self.sprite:play()
			--end
		end

		self.running = false
		self.walking = true
		self.speedX = self.walkingSpeed
		if self.directionX == 0 then
			self.speedY = self.verticalSpeedY
		else
			self.speedY = self.verticalSpeedY * self.walkDiagonalSpeedRatio
		end

	else
		if( self.isAI ) then
			self.speedX = 0
			self.speedY = 0
		end
	end

	end)
end

function Player:changeDirection( x, y )
	-- initialize.lua line 188~ already sends update position packet
	timer.performWithDelay( self.interpolationDelay, function()
		if( self.movementOverride == true ) then return end 
		if( x ) then self.directionX = x end
		if( y ) then self.directionY = y end
	end)
end

function Player:run( check, direction )

	if( currentGameMode == "multiplayer" and check ~= false ) then
		self:changeState( "run" )
	end	

	timer.performWithDelay( self.interpolationDelay, function()

	if( self:checkPermissions( "run" ) == true ) then	

		if( self.sprite.sequence ~= "run" ) then
			self.sprite:setSequence( "run" )
			self.sprite:play()
		end

		if self.running == false then
			self.running = true
			self.walking = false

			if self.runningAcceleration == true then
				self.speedX = self.runningSpeed*0.25
				self:startRunningAcceleration()	
			else
				self.speedX = self.runningSpeed
			end

			self.speedY = self.verticalSpeedY * self.runDiagonalSpeedRatio
		end	
		
	end

	end)
end

function Player:startRunningAcceleration()
	self.runTimer1 = timer.performWithDelay( 150, function() 
		if self.running == true then
			self.speedX = self.runningSpeed * 0.6 
		end
	end)
	self.runTimer2 = timer.performWithDelay( 300, function() 
		if self.running == true then
			self.speedX = self.runningSpeed * 0.8
		end
	end)
	self.runTimer3 = timer.performWithDelay( 450, function()
		if self.running == true then
			self.speedX = self.runningSpeed
		end
	end)
end

function Player:stopRunningAcceleration()
	if( self.runTimer1 ) then timer.cancel(self.runTimer1) end
	if( self.runTimer2 ) then timer.cancel(self.runTimer2) end
	if( self.runTimer3 ) then timer.cancel(self.runTimer3) end
end

function Player:releaseLRBtn( h, v )

	if( self.running == false ) then
		--init.callUpdatePosition( "stopped", nil, 0, 0 )
	end

	timer.performWithDelay( self.interpolationDelay, function()

	if( h == 1 and self.running == false ) then
		if( v == 1 ) then
			self.controls.bDownRightPressed = false
		elseif( v == -1 ) then
			self.controls.bDownRightPressed = false
		else
			self.controls.bRightPressed = false
		end
	elseif( h == -1 and self.running == false ) then
		if( v == 1 ) then
			self.controls.bDownLeftPressed = false
		elseif( v == -1 ) then
			self.controls.bUpLeftPressed = false
		else
			self.controls.bLeftPressed = false
		end
	elseif( v == 1 and self.running == false ) then
		self.controls.bDownPressed = false
	elseif( v == -1 and self.running == false ) then
		self.controls.bUpPressed = false
	end

	-- the true, FALSE means 1) release LR btn in initialize.lua, 2) delay, 3) go back to idle immediately
	-- instead of idle(true,true) which would be 1) release, 2) delay, 3) call idle, 4) delay, 5) actually go idle
	if( self.running == false ) then
		self:idle( true, false ) -- caused by you, so true for multiplayer packet sending
	end

	end)
end

function Player:zoom( multiplier )
	self.movementOverride = true
	self.movementOverrideMask = { x = 1, y = 0 } 
	self.directionX = self.mirror
	self.speedX = self.runningSpeed * multiplier
	self.speedY = 0
	--self.speedY = self.verticalSpeedY/2 * 1/multiplier 
end

function Player:move()

	if self.movementOverride == true or self.sprite.sequence == "walk" or self.sprite.sequence == "run" then
		-- this is to prevent moving while lying down when controls are pressed
		local distanceX = self.directionX * self.speedX
		if( self.sprite.x + distanceX < GameController.stagePicked.boundaryRight ) then
			if( self.sprite.x + distanceX > GameController.stagePicked.boundaryLeft ) then
				self.sprite.x = self.sprite.x + distanceX * self.movementOverrideMask.x
			end
		end
		local distanceY = self.directionY * self.speedY
		if( self.sprite.y + self.sprite.contentHeight/2 + distanceY < GameController.stagePicked.boundaryBot ) then
			-- the below equation is are all additions is because distanceY becomes a negative value
			if( self.sprite.y + self.sprite.contentHeight/2 + distanceY > GameController.stagePicked.boundaryTop ) then  
				self.sprite.y = self.sprite.y + distanceY * self.movementOverrideMask.y
			end
		end

		-- automatically grab a stunned enemy if you walk into him 
		-- you must be walking, and you must be walking into him (won't work if you're same x-position already)
		if( self.sprite.sequence == "walk" ) then
			for i, opp in pairs(self.opponents) do
				if( opp.stunned == true ) then
					if( math.abs(opp.sprite.y - self.sprite.y) < 50 ) then
						if( self.mirror == 1 and self.sprite.x + self.bodyHitbox.width/2 > opp.sprite.x - opp.bodyHitbox.width/2 ) then
							self:goIdle() --self.walking = false
							-- you are facing right, opponent should now face left
							if( opp.mirror ~= -1 ) then 
								opp.mirror = -1
								opp.sprite:scale(-1,1)
							end

							self.sprite.x = opp.sprite.x - self.character.grabArmLength
							opp.sprite.y = self.sprite.y-1 -- move opponent a little "behind" you so that your grabbing arm's sprite stays on top
							self:grab( opp )
							opp.stunned = false -- stop this early to prevent retriggering		
						elseif ( self.mirror == -1 and self.sprite.x - self.bodyHitbox.width/2 < opp.sprite.x + opp.bodyHitbox.width/2 ) then
							self:goIdle() --self.walking = false
							-- you are facing left, opponent should now face right
							if( opp.mirror ~= 1 ) then 
								opp.mirror = 1
								opp.sprite:scale(-1,1)
							end

							self.sprite.x = opp.sprite.x + self.character.grabArmLength
							opp.sprite.y = self.sprite.y-1
							self:grab( opp )
							opp.stunned = false -- stop this early to prevent retriggering	
						end
					end			
				end
			end
		end
	end
end

function Player:defend( damage, knockback, bypass )
	
	if( currentGameMode == "multiplayer" and check ~= false ) then
		self:changeState( "defend" )
	end	

	timer.performWithDelay( self.interpolationDelay, function()

	if( self:checkPermissions( "defend" ) and self.defDelay == false or bypass == true ) then
						
		if self.running == true then -- roll instead
			self.movementOverride = true
			self.movementOverrideMask = {x=1,y=0}
			self.sprite:setSequence( "dodge" )
			self.sprite.blendMode = "multiply"
			self.dodging = true
			self.invulnerable = true -- DEBUG: hard to test this without another Player
			Effects:dust(self)

			timer.performWithDelay( self.defTime, function()
				if( self.dodging == true ) then -- only perform arithmetic below if Player is defending
					self.dodging = false
					self.invulnerable = false
					self.movementOverride = false
					self:goIdle() -- defense expires after 'defTime'
				end
			end)
		else
			self.sprite:setSequence( "defend" )
			self.defense = true

			timer.performWithDelay( self.defTime, function()
				if( self.defense == true and self.performingSpecial == "none" ) then -- only perform arithmetic below if Player is defending
					self.sprite:setSequence( "defend finished" )
					self.sprite:play()
					timer.performWithDelay( 200, function() 
						self.defense = false
						self.defDelay = false
						self:goIdle()					
					end ) -- 200 = how long the defend-finished frame is
					self.defDelay = true
					self.defDelayTimeStart = system.getTimer()
					self.speedX = 0 -- 6/28: prevent player from sliding while defending
					self.speedY = 0
				elseif( self.performingSpecial ~= "none" ) then
					self.defense = false
					self.defDelay = false
				end
			end)
		end
		
		self.sprite:play()
		self.defTimeStart = system.getTimer()	

	end

	end)
	
end

function Player:jump( check )
	
	if( currentGameMode == "multiplayer" and check ~= false ) then -- 7/7 might have bugs since jumping is complicated
		self:changeState( "jump", direction )
	end	

	if self.grabbing == true then
		if self.controls.bRightPressed == true then
			self:throwOpponent(1)
		elseif self.controls.bLeftPressed == true then
			self:throwOpponent(-1)
		else
			self:throwOpponent(self.mirror)
		end
		return 
	end

	timer.performWithDelay( self.interpolationDelay, function()

	if( self:checkPermissions( "jump" ) == true ) then
	
		-- if Player is running, permit him to do running jump without holding onto buttons
		if self.running == true then
			self.Ux = self.directionX * self.runningUx
			self.Uy = self.runningUy

			self.slowJump = false
			
			if DebugInstance.logText then print( "Running jump" ) end -- DEBUG
		else
			if self.slowJump == true then
				self.Ux = self.directionX * self.runningUx
				self.Uy = self.runningUy

				if self.Ux == 0 then
					self.Uy = self.defaultUy
					self.slowJump = true
				else
					self.slowJump = false
				end			
			else
				-- normal boring jump
				self.Ux = self.directionX * self.defaultUx
				self.Uy = self.defaultUy
				self.slowJump = true
							
				if DebugInstance.logText then print( "Static Jump" ) end
				-- print( "Static Jump in direction", direction ) -- DEBUG
			end
		end
		
		self.X0 = self.sprite.x
		self.Y0 = self.sprite.y -- Y0 is the position you start jumping at

		self.jumped = true -- set to jumped status
		self.jumpTimer = system.getTimer()

		if( self.directionY == 1 ) then
			self.jumpLandingDisplacementY = self.defaultJumpLandingDisplacementY
			self.Uy = self.Uy * 0.75
		elseif self.directionY == -1 then
			self.jumpLandingDisplacementY = -self.defaultJumpLandingDisplacementY
			self.Uy = self.Uy * 1.15
		elseif self.directionY == 0 then
			self.jumpLandingDisplacementY = 0
		end
		
		self.sprite:setSequence( "jump" )
		self.sprite:play()	
	else
		self:recover()
	end

	end)
end

function Player:modifiedJump( forceX, forceY, offensive, customGravity ) 

	self.Ux = forceX
	self.Uy = forceY
	self.previousBounceUy = self.Uy

	if customGravity then
		self.gravity = customGravity
	else
		self.gravity = self.defaultGravity
	end
	
	self.X0 = self.sprite.x	
	if( self.jumped == false and self.mJumped == false ) then 
		self.Y0 = self.sprite.y -- Y0 is the position you start jumping at
	else
		-- if player is being hit again while already in a mJump, keep original landing Y position
		-- do nothing
	end
	print("mjump, Y0 = ", self.Y0)

	-- e.g. performing dragon kick (where the jump itself is offensive), hero dragon punch
	if( self.performingSpecial ~= "none" and offensive == true ) then
		self.jumped = true
		self.mJumped = false 
		self.offensiveJump = true -- knocks anything in the way
	-- jump itself is unoffensive but its still a move... (which?)
	elseif( self.performingSpecial ~= "none" and offensive == false) then
		self.jumped = true
		self.mJumped = false 
		self.offensiveJump = false
	-- if thrown as object by opponent
	elseif( self.performingSpecial == "none" and offensive == true ) then
		-- Player has been thrown as an object
		self.mJumped = true
		self.jumped = false
		self.thrownAsObject = true
		
		-- exact same code chunk as fall(), but I don't know why some of that is used
		self.sprite:setSequence( "falling" )
		self.sprite:play()
		self.falling = true
	-- normal knockback, e.g. when you get hit by dragon kick
	elseif( self.performingSpecial == "none" and offensive == false ) then
		self.mJumped = true
		self.jumped = false
		self.thrownAsObject = false

		self.sprite:setSequence( "falling" )
		self.sprite:play()
		self.falling = true
	end

	self.jumpTimer = system.getTimer()

	-- rare edge case where Y0 wasn't set
	if self.Y0 == 0 then
		self.Y0 = self.sprite.y 
	end
	
end

function Player:requestHitDetection( damage, typeOfHit ) -- customRange etc.
	for i, opp in pairs(self.opponents) do
		hub:publish({
			message = {
				action = "request hit detection",
				-- make sure its the right user ID
				timestamp = system.getTimer(),
				userID = self.id,
				detectID = opp.id,
				opp_x = opp.sprite.x,
				opp_y = opp.sprite.y,
				damage = damage,
				typeOfHit = typeOfHit
			}
		});
	end
end

function Player:jumpAttack()
	-- animation
	self.sprite:setSequence( "jump kick" )
	self.sprite:play()

	-- set variables
	self.attacking = true
	self.atkTimeDuration = self.jumpAtkTime
	self.atkTimeStart = system.getTimer()
	self.dps = self.character.baseDps * 1.5

	timer.performWithDelay( 200, function() self:registerHit("knockdown") end )
end

function Player:runningJumpAttack()
	-- animation
	self.sprite:setSequence( "jump kick" )
	self.sprite:play()

	-- set variables
	self.attacking = true
	self.atkTimeDuration = self.jumpAtkTime
	self.atkTimeStart = system.getTimer()
	self.dps = self.character.baseDps * 1.5

	timer.performWithDelay( 200, function() self:registerHit("knockdown") end )
end

function Player:grabAttack()
	-- AI does not have controls. Code differently
	if self.controls.bRightPressed == true then
		self:throwOpponent(1)
	elseif self.controls.bLeftPressed == true then
		self:throwOpponent(-1)
	elseif self.grabPunchAllowed == true then
		-- animation
		self.sprite:setSequence( "grab punch" )
		self.sprite:play()

		-- set variables
		self.grabPunchAllowed = false
		self.attacking = true -- we're still "attacking", but its set to false without setting us to idle, instead sets grabPunchAllowed to true again
		
		-- timing
		timer.performWithDelay( self.character.grabAtkDuration, function()
			self.grabPunchAllowed = true
			self.attacking = false
		end)	

		self.dps = self.character.baseDps * 0.5	

		timer.performWithDelay( self.character.grabAtkTriggerTime, function() self:registerHit("punch") end)
	end
end

function Player:runningAttack()
	-- sprite will not be running or walking but he still needs to trigger Player:move()
	self.movementOverride = true
	self.performingSpecial = "runAttack" -- easy solution for not allowing turning around during run attack
	self.movementOverrideMask = { x = 1, y = 0 } -- restrict vertical movement

	-- animation
	self.sprite:setSequence( "running attack" )
	self.sprite:play()

	-- temporary speed up for the punch
	self.speedX = self.speedX * self.character.runAtkSpeedUp

	-- set variables
	self.attacking = true
	self.atkTimeDuration = self.character.runAtkTimeDuration
	self.dps = self.character.baseDps * 2 -- same as final punch ?
	self.atkTimeStart = system.getTimer()
	timer.performWithDelay( self.character.runAtkTriggerTime, function() self:registerHit("knockdown") end )

	timer.performWithDelay( self.atkTimeDuration * self.slowDownFactor, function()
		if( self.attacking == true ) then
			self.attacking = false
			self.performingSpecial = "none"
			self.movementOverride = false -- if was running attack
			self:goIdle()
		end	
	end)
end

--[[
Test cases: 
Punch enemy 3 times. He should now be stunned. Punch him now to do a final punch of a flashy animation that knocks him down.
Punch enemy 3 times and stun him, but this time walk into him. He should now be grabbed.
Punch enemy 3 times, then do nothing. After he is idle, punch him again, which should come out as a normal punch again.
]]--
function Player:normalAttack()

	self.attacking = true
	self.atkTimeDuration = self.character.atkDuration

	local function nearbyEnemyStunned()
		for k, enemy in pairs( self.opponents ) do
			if enemy.stunned == true then
				if( math.abs(self.sprite.y - enemy.sprite.y) < GameController.hitRangeBotY ) then
					if( (self.sprite.x + self.character.rangeX) > (enemy.sprite.x - enemy.bodyHitbox.width/2) and self.sprite.x < enemy.sprite.x ) then
						return true
					elseif( (self.sprite.x - self.character.rangeX) < (enemy.sprite.x + enemy.bodyHitbox.width/2) and self.sprite.x > enemy.sprite.x ) then
						return true
					end
				end
			end					
		end
		return false
	end

	if nearbyEnemyStunned() == true or self.punchCount == 3 and self.grabbing == false then -- never be able to do final punch while grabbing
		self.sprite:setSequence( "punch3" )
		self.sprite:play()
		self.atkTimeDuration = self.character.finalAtkDuration
		timer.performWithDelay( self.character.finalAtkTriggerTime, function() self:registerHit("knockback+down") end )
		self.dps = self.character.baseDps * 1.5
	elseif self.punchCount == 0 then
		if self.lastNormalPunch == "punch" then
			self.sprite:setSequence( "punch2" )
			self.lastNormalPunch = "punch2"
		else
			self.sprite:setSequence( "punch" )
			self.lastNormalPunch = "punch"
			timer.performWithDelay( self.atkTimeDuration+200, function() self.lastNormalPunch = "punch2" end ) -- no alternate punching animations after certain (200 ms) time frame
		end
		self.sprite:play()
		timer.performWithDelay( self.character.atkTriggerTime, function() self:registerHit("punch") end ) -- different characters might punch at different speeds
		self.dps = self.character.baseDps
	elseif( self.punchCount == 1 ) then
		self.sprite:setSequence( "punch2" )
		self.sprite:play()
		timer.performWithDelay( self.character.atkTriggerTime, function() self:registerHit("punch") end ) -- different characters might punch at different speeds
		self.dps = self.character.baseDps
	elseif( self.punchCount == 2 ) then
		self.sprite:setSequence( "punch" )
		self.sprite:play()
		timer.performWithDelay( self.character.atkTriggerTime, function() self:registerHit("stun") end ) -- different characters might punch at different speeds
		self.dps = self.character.baseDps
	end

	print("This is punch "..self.punchCount)
	
	-- shift a bit when punching
	self.sprite.x = self.sprite.x + self.mirror * self.flinchDistance/2

	timer.performWithDelay( self.atkTimeDuration, function()
		if self.normalAttackPenalty == true then
			timer.performWithDelay( self.normalAttackPenaltyTime, function()
				self.attacking = false
				self:goIdle()
				self.normalAttackPenalty = false
			end)
			self:goIdle()
			self.attacking = true
		else
			self.attacking = false
			self:goIdle()
		end
	end)
end

function Player:registerHit( typeOfHit )
	local punchSuccess = GameController:hitDetection( self, self.dps, typeOfHit )
	if( self.punchCount == 3 ) then
		self.punchCount = 0
	end
	if( punchSuccess == true ) then
		self.punchCount = self.punchCount + 1

		-- punch again within certain timeframe, or else punch count will expire. 
		-- this fixes the problem where a player doesnt punch for long time but suddenly gets a final punch to use
		if(self.punchTimer) then timer.cancel(self.punchTimer) end
		self.punchTimer = timer.performWithDelay( self.character.maxPunchDelay, function()
			self.punchCount = 0 -- note this is reset, not just punchCount--
			print("reset punch counter")
		end )
	else
		if( self.punchCount > 0 ) then -- if say, player used defense
			self.punchCount = self.punchCount - 1
		end
	end

	if self.grabPunchAllowed == false then -- if the player was just grab punching (meaning this flag is now false), do not increase punch Count
		self.punchCount = 0 
	end
end

function Player:attack( check )

	-- code for attacks that are DUJ+A
	if self.jumped == true and self.character.duja == true and self.performingSpecial ~= "none" and self.typeOfSpecial == "duj" then
		self.character:upJumpAttack( self )
		return
	end

	timer.performWithDelay( self.interpolationDelay, function()

		if self:checkPermissions( "attack" ) == true then
			if self.grabbing == true then
				if self.isAI == false then
					self:grabAttack()				
				end
				return
			end

			if self.itemHeldFlag == true then
				self:ItemAttack()
				return
			end

			if self.jumped == true and self.running == true then
				self:runningJumpAttack()
				return
			elseif self.jumped == true and self.running == false then
				self:jumpAttack()
				return
			end

			if self.jumped == false and self.running == true then
				self:runningAttack()
				return
			end

			if( self:pickUpItem() == false ) then
				if( self.mirror == 1 ) then
					self.attackHitbox:setReferencePoint( display.TopLeftReferencePoint )
					self.attackHitbox.x = self.sprite.x
				else
					self.attackHitbox:setReferencePoint( display.TopRightReferencePoint )
					self.attackHitbox.x = self.sprite.x
				end

				if DebugInstance.hitboxes == true then 
					self.attackHitbox.isVisible = true
				end		

				self:normalAttack()
			end
		else
			if self.attacking == true then 
				--print("impose penalty for trying to punch again too early")
				self.normalAttackPenalty = true
			end
		end

	end)
end

function Player:updateInitial( id )
	hub:publish({
		message = {
			action = "initial",
			userID = id, -- yourself
			-- send your own position
			initialX = self.sprite.x,
			initialY = self.sprite.y,
			status = "loaded",
		}
	});
end

function Player:changeState( state, extra1, extra2, extra3 )
	hub:publish({
		message = {
			action = "state change",
			-- make sure its the right user ID
			userID = self.id,
			stateToChange = state,
			extra1 = extra1, -- corresponds to extra data sent about a certain action
			extra2 = extra2, 
			extra3 = extra3,
			extra4 = extra4,
		}
	});
end

function Player:jumpCheck()

	-- physics for the Player jumping
	if self.jumped == true then
		self.currentJumpTime = (system.getTimer()/1000 - self.jumpTimer/1000)/self.slowDownFactor
		self.Vy = self.Uy - self.gravity * self.currentJumpTime
		
		self.sprite.x = self.X0 + self.Ux * self.currentJumpTime
		self.sprite.y = self.Y0 - self.Vy * self.currentJumpTime + 0.5 * self.gravity * math.pow(self.currentJumpTime, 2)

		if( self.offensiveJump == true ) then -- hit anything in the way (first implemented for Hank DLRJ)
			for k, enemy in pairs(self.opponents) do
				if( enemy:checkPermissions( "getting hit") == true and enemy.alreadyHit == false ) then
					if( math.abs(self.sprite.x-enemy.sprite.x) < self.bodyHitbox.width and enemy.bot <= self.Y0+self.sprite.contentHeight and enemy.bot >= self.Y0-self.sprite.contentHeight) then
						if( self.typeOfSpecial == "dlj" or self.typeOfSpecial == "drj" ) then
							enemy:getsHit( self.character.dlrjDamage, "knockback+down", self.mirror, false, self.character.dlrjPowerX, self.character.dlrjPowerY  )
							enemy.alreadyHit = true
						elseif( self.typeOfSpecial == "duj" ) then
							enemy:getsHit( self.character.upJumpDamage, "knockback+down", self.mirror, false, self.character.upJumpPowerX, self.character.upJumpPowerY  )
							enemy.alreadyHit = true
						end
					end
				end
			end
		end

		-- landing code
		if( self.sprite.y > self.Y0 + self.jumpLandingDisplacementY and system.getTimer() - self.jumpTimer > 400 ) then
			self.sprite.y = self.Y0 + self.jumpLandingDisplacementY -- this makes sure you don't end up landing further than where you started
			
			-- boundary check**

			self.jumpFinishedTime = system.getTimer() 
			self.recovering = false
			self.offensiveJump = false 
			if DebugInstance.logText then print ( "Jump landed after "..((self.jumpFinishedTime - self.jumpTimer)/1000).." seconds" ) end
			
			if self.attacking == false then
				self.justJumped = true -- if idle code sees this flag as true, then it'll allow another a static jump -> hop
				-- don't allow if you just attacked, too OP
			end

			-- special attack jumps don't count as chainable jumps
			if self.performingSpecial ~= "none" and self.typeOfSpecial == "duj" then 
				self.performingSpecial = "none"
				self.typeOfSpecial = "" -- allow Player:stateCheck() to now return player to idle
				self.justJumped = false
			end			

			self.jumped = false
			self.performingSpecial = "none"
			self.attacking = false
			self.recovering = false
			
			if( self.controls ) then -- player should be allowed to hold directional button after jump to walk, this shouldn't be here
				if self.controls.bRightPressed == true or self.controls.bLeftPressed == true then
					self:walk()
				else
					self:goIdle()
				end
			else
				self:goIdle() -- going to idle is definitely not delayed and it is reactive function, so is not sent as a message
			end
		end
	end	

	if self.justJumped == true then
		--self.slowJump = not(self.slowJump)
		timer.performWithDelay( self.jumpTimeWindow, function()
			if self.jumped == false then
				self.justJumped = false
				self.slowJump = false
			end
		end)
	end
end

function Player:recover()
	-- jump recover: only when mid-jump (not almost landing), meaning there has to be enough time
	if( self.mJumped == true and self.recovering == false and self.currentJumpTime < 0.3 ) then -- or 0.79 sec (total jump time) - animation play time
		self.sprite:setSequence( "recover" )
		self.sprite:play()
		self.falling = false -- IMPORTANT or else you won't idle 
		self.thrownAsObject = false
		
		self.invulnerable = true
		timer.performWithDelay( 300, function()
			self.invulnerable = false
		end) -- invulnerable while doing this 
		self.jumped = true -- THE JUMP TIME VALUES MIGHT NOT CARRY FORTH but we need this so he can chain hop/jump right after
		self.recovering = true
		self.mJumped = false
		self.gravity = self.gravity/1.5
	end
	-- 2nd (not yet coded) requirement:only when Vy is somewhat sufficient
end

function Player:mJumpCheck()

	if self.mJumped == true then
		self.currentJumpTime = (system.getTimer()/1000 - self.jumpTimer/1000)/self.slowDownFactor
		self.Vy = self.Uy -  2*( self.gravity * self.currentJumpTime )
		self.sprite.x = self.X0 + self.Ux * self.currentJumpTime
		self.sprite.y = self.Y0 - self.Vy * self.currentJumpTime 

		self.grabbed = false

		-- you got thrown and so you are a "weapon"... offensiveJump is a misleading term
		if( self.thrownAsObject == true ) then -- hit anything in the way (first implemented for Hank DLRJ, then for throwing)
			for i, anyone in pairs( GameController.allPlayers ) do
				if( anyone ~= self.guyWhoThrowsYou and anyone ~= self ) then -- your body can't smack yourself or the guy who throws you
					if( anyone:checkPermissions( "getting hit") == true and anyone.alreadyHit == false ) then
						if( math.abs(self.sprite.x-anyone.sprite.x) < self.bodyHitbox.width and anyone.bot <= self.Y0+self.sprite.contentHeight and anyone.bot >= self.Y0-self.sprite.contentHeight) then
							anyone:getsHit( self.thrownAsObjectCrashingDamage, "knockdown", self.mirror, false )
							anyone.alreadyHit = true
						end
					end
				end
			end
		end

		if( self.sprite.y > self.Y0 ) then
			
			if( self.thrownAsObject == true ) then
				self:reduceHP( self.thrownAsObjectLandingDamage )
				self.thrownAsObject = false -- prevent multiple procs
			end

			self.sprite:setSequence( "falling2" )
			self.sprite:play()

			self.sprite.y = self.Y0 -- this makes sure you don't end up landing further than where you started
			
			-- bounce
			-- reset jumpTimer
			self.jumpTimer = system.getTimer()	
			-- new Y0 is the new launch point now 
			self.Y0 = self.sprite.y
			-- current x position is now the new X0
			self.X0 = self.sprite.x
			-- x-velocity decreases based on friction
			self.Ux = self.Ux * (1-self.friction)

			-- bounce code
			self.Uy = self.previousBounceUy * self.bounciness
			self.previousBounceUy = self.Uy
			if( self.Uy < self.cutOffBounceVy ) then -- anything below 50 is considered finished bouncing
				self:resetMJump()
				self:fall( false ) -- display fallen animation (don't re-fall)
			end
		end
	end
end

function Player:resetMJump()
	self.jumpTimer = 0
	self.currentJumpTime = 0
	self.Vx = 0
	self.Vu = 0
	self.Uy = 0
	self.Ux = 0
	self.firstBounce = false
	self.previousBounceUy = 0
end

function Player:extrapolate( x,y )
	print("opponent told me to extrapolate to "..x..","..y)
	
	self.sprite.x = x; self.sprite.y = y; -- warping

	-- non warping version
	--[[
	self.finalX = x; self.finalY = y
	
	local dX = self.finalX - self.sprite.x 
	local dY = self.finalY - self.sprite.y

	-- if close enough (within 5 pixels, just "teleport/warp"
	if( math.abs(dX) < 5 and math.abs(dY) < 5 ) then
		self.sprite.x = self.finalX
		self.sprite.y = self.finalY
		self:idle(false,false)
	else
		self.speedX = self.walkingSpeed 
		self.directionX = dX/math.abs(dX)
		self.speedY = self.verticalSpeedY
		self.directionY = dY/math.abs(dY)

		self:walk(false)
	end
	]]--
end

function Player:stateCheck()

	-- player should always be facing the right way (high priority)
	self:flipHorizontal(self.directionX)

	-- for multiplayer movement extrapolation..this is for correcting your opponent.
	if( currentGameMode == "multiplayer" and self.controlled == false ) then -- extra check, only noncontrolled players are compensated
		if( self.networkSaidStop == true ) then
			if( system.getTimer() - self.networkMoveStartTime >= self.networkMoveDuration ) then
				self:stopMoving() -- check/p.e.
				self.networkSaidStop = false -- no use				
			end
		end
	end

	-- Wall boundary code, prevent getting stuck at walls
	if( self.sprite.x > GameController.stagePicked.boundaryRight ) then
		self.X0 = GameController.stagePicked.boundaryRight
		self.Ux = 0
		self.sprite.x = GameController.stagePicked.boundaryRight -- prevents getting stuck
	elseif( self.sprite.x < 0) then
		self.X0 = 0
		self.Ux = 0
		self.sprite.x = 0 -- prevents getting stuck
	end

	-- this is probably more important, bugs where player got stuck up top has happened before
	if( self.sprite.y < GameController.stagePicked.boundaryTop and self.jumped == false and self.mJumped == false ) then
		self.Y0 = GameController.stagePicked.boundaryTop
		self.Uy = 0
		self.sprite.y = GameController.stagePicked.boundaryTop -- prevents getting stuck
	end	
	
	-- if an Item is thrown, update its position
	if( self.thrownItem == true ) then
		ItemToThrow.currentTimeX = (system.getTimer()/1000 - ItemToThrow.startTimeX)/self.slowDownFactor 
		ItemToThrow.currentTimeY = (system.getTimer()/1000 - ItemToThrow.startTimeY)/self.slowDownFactor 
		--ItemToThrow.Vy = ItemToThrow.Uy + 0.5 * ItemToThrow.g * math.pow(ItemToThrow.currentTimeY, 2)
		ItemToThrow.Vx = ItemToThrow.Vx * 0.99 -- air resistance
		ItemToThrow.sprite.y = ItemToThrow.Y0 - ( ItemToThrow.Uy - 0.5 * ItemToThrow.g * math.pow(ItemToThrow.currentTimeY, 2) )
		ItemToThrow.sprite.x = ItemToThrow.X0 + self.mirror * ItemToThrow.Vx * ItemToThrow.currentTimeX -- if self.mirror = 1, we throw to the right
		
		-- rotate the Item (depends on what Item it is though)
		ItemToThrow.sprite:rotate( 20 )
		--print( "Vx", ItemToThrow.Vx )
		--print( "Current Time", ItemToThrow.currentTimeX, ItemToThrow.currentTimeY )
		
		-- make sure Item bounces off the ground
		if( ItemToThrow.sprite.y > ( ItemToThrow.Y0 + self.sprite.height/2 ) ) then
			ItemToThrow.Vy = ( ItemToThrow.Uy - 0.5 * ItemToThrow.g * math.pow(ItemToThrow.currentTimeY, 2) )
			--ItemToThrow.Vx = ItemToThrow.Vx + ItemToThrow.u * (ItemToThrow.e - 1) * ItemToThrow.Vy -- friction and bounciness depend on vertical velocity
			ItemToThrow.Uy = - ((ItemToThrow.e) * ItemToThrow.Vy) -- vy = -e*vy, where e is the bounciness
			ItemToThrow.X0 = ItemToThrow.sprite.x
			--ItemToThrow.startTimeY = system.getTimer()/1000
			ItemToThrow.startTimeX = system.getTimer()/1000
			ItemToThrow.bounceCount = ItemToThrow.bounceCount + 1
			
			
			if DebugInstance.itemDebug then print ("Bounce, velocity: x = ", ItemToThrow.Vx, "Vy = ", ItemToThrow.Vy ) end
			print ("Uy = ", ItemToThrow.Uy)
			
			-- maximum of bounces reached
			if( ItemToThrow.bounceCount == ItemToThrow.maxBounce ) then 
				print ("Bounce stopped." )
				self.thrownItem = false
				ItemToThrow.X0 = ItemToThrow.sprite.x
				ItemToThrow.Y0 = ItemToThrow.sprite.y
				ItemToThrow.Vx = 0
				ItemToThrow.Vy = 0
			end
			
		end
		
	end

end

function Player:printVariables()
	--if( self.controlled == false ) then return end
	print( self.throwing,
		self.grabbing, 
		self.grabbed, 
		self.thrownAsObject, 
		self.falling, 
		self.dead, 
		self.attacking, 
		self.defense, 
		self.jumped, 
		self.mJumped, 
		self.performingSpecial ~= "none", 
		self.flinching, 
		self.fallen, 
		self.gettingUp, 
		self.invulnerable, 
		self.dodging )
end

function Player:checkPermissions( checkThisState )


	if( checkThisState == "auto idle" ) then
		if( self.dead or self.attacking or self.defense or self.jumped or self.mJumped or self.performingSpecial ~= "none" or self.flinching or self.fallen or self.gettingUp or self.invulnerable ) then
			return false
		else 
			return true 
		end
	elseif( checkThisState == "idle" ) then
		if( self.attacking or self.grabbing or self.grabbed or self.thrownAsObject or self.falling or self.dead or self.defense or self.jumped or self.mJumped or self.performingSpecial ~= "none" or self.flinching or self.fallen or self.gettingUp or self.dodging ) then
			-- don't put "attacking" in above because that would clash with jump-attacks
			return false
		else 
			return true 
		end
	elseif( checkThisState == "walk" ) then
		if( self.throwing or self.grabbed or self.stunned or self.grabbing or self.dodging or self.mJumped or self.performingSpecial ~= "none" or self.attacking or self.defense or self.jumped or self.flinching or self.fallen or self.falling or self.gettingUp ) then
			return false
		else 
			return true 
		end
	elseif( checkThisState == "run" ) then
		if( self.throwing or self.grabbed or self.stunned or self.grabbing or self.dodging or self.performingSpecial ~= "none" or self.attacking or self.defense or self.jumped or self.mJumped or self.flinching or self.fallen or self.gettingUp ) then
			return false
		else 
			return true 
		end
	elseif( checkThisState == "defend" ) then
		if( self.throwing or self.grabbed or self.stunned or self.grabbing or self.dodging or self.performingSpecial ~= "none" or self.attacking or self.defense or self.jumped or self.mJumped or self.flinching or self.fallen or self.falling or  self.gettingUp ) then
			return false
		else 
			return true 
		end
	elseif( checkThisState == "attack" ) then
		if( self.throwing or self.grabbed or self.stunned or self.dodging or self.performingSpecial ~= "none" or self.attacking or self.defense or self.flinching or self.fallen or self.gettingUp  or self.mJumped ) then 
			return false
		else
			return true
		end
	elseif( checkThisState == "jump" ) then	
		if( self.throwing or self.grabbed or self.stunned or self.grabbing or self.dodging or self.attacking or self.defense or self.jumped or self.mJumped or self.performingSpecial ~= "none" or self.flinching or self.fallen or self.gettingUp ) then 
			return false
		else
			return true 
		end
	elseif( checkThisState == "mirroring" ) then
		if( self.movementOverride or self.grabbed or self.stunned or self.grabbing or self.dodging  or self.attacking or self.performingSpecial ~= "none" or self.mJumped or self.defending or self.flinching or self.fallen or self.falling or self.gettingUp  ) then
			return false
		else 
			return true 
		end
	elseif( checkThisState == "releaseLR" ) then
		if( self.grabbed or self.stunned or self.grabbing  or self.jumped or self.attacking or self.defending or self.performingSpecial ~= "none" or self.running or self.fallen or self.gettingUp ) then
			return false
		else 
			return true
		end
	elseif( checkThisState == "getting hit" ) then
		if( self.falling or self.dodging or self.fallen or self.gettingUp or self.invulnerable or self.dead or self.performingSpecialVulnerability == true or self.performingSpecial == "runAttack" ) then
			return false
		else 
			return true
		end
	elseif( checkThisState == "skill" ) then
		if( self.throwing or self.grabbed or self.stunned or self.grabbing or self.dodging  or self.fallen or self.gettingUp or self.dead or self.performingSpecial ~= "none" ) then
			return false
		else 
			return true
		end
	end
end

function Player:elementsFollowing()

	self.bodyHitbox.x = self.sprite.x
	self.bodyHitbox.y = self.sprite.y --+ (self.bot - self.sprite.y)/2
	-- gets sent to front in Update.lua > elementsToFront()

	self.attackHitbox.x = self.sprite.x
	self.attackHitbox.y = self.sprite.y + self.sprite.contentHeight * self.character.topAttackPosition
	
	if( self.controlled == true ) then
		self.hp.x = self.hpLeft - self.hpOffset
		self.mp.x = self.mpLeft - self.mpOffset

		self.mpUnder.x = self.mpLeft - self.mpOffset/2
		self.hpUnder.x = self.hpLeft - self.hpOffset/2
		-- just do this in Update - elementsFollowing
		--self.hpmp:toFront()
		--self.symbol:toFront()

		self.hpmp.maskX = self.bar.x  --self.hpmp.x
		self.hpmp.maskY = self.bar.y  --self.hpmp.y
	else
		-- move bar, frame, hp, hp mask (required), mp, mp mask (required) along with player
		self.bar.y = self.sprite.y - display.contentHeight*0.15
		self.bar.x = self.sprite.x
		self.barframe.y = self.bar.y
		self.barframe.x = self.sprite.x
		self.hp.x = self.sprite.x - self.hpOffset
		self.hp.y = self.bar.y
		self.mp.x = self.sprite.x - self.mpOffset
		self.mp.y = self.bar.y
		self.symbol.x = self.sprite.x - self.bar.contentWidth/3
		self.symbol.y = self.bar.y + self.bar.contentHeight/10
		self.hpmp.maskX = self.sprite.x
		self.hpmp.maskY = self.bar.y
	end
end

function Player:elementsToFront()
	self.bar:toFront()
	self.hpmp:toFront()
	self.hp:toFront()
	self.mp:toFront()
	self.barframe:toFront()
	self.symbol:toFront()
	if( DebugInstance.hitboxes ) then
		self.bodyHitbox:toFront()
		self.attackHitbox:toFront()
	else
		self.attackHitbox.isVisible = false
	end

	if( self.darkOverlay.isVisible == true ) then
		self.darkOverlay:toFront()
		-- then, put the player in front
		self.sprite:toFront()
	end
end

function Player:resetSpeed()
	self.speedX = 0
	self.speedY = 0
end

function Player:getsHit( damage, typeOfHit, direction, check, x, y )

	if( self:checkPermissions( "getting hit" ) == true ) then

		-- reset movement speed back to 0 to prevent
		-- "sliding while fallen"
		self:resetSpeed()

		self.character:removeTimers() -- if character is performing a vulnerable special, remove any eventual effects of that skill
		self.performingSpecial = "none"
		self:goIdle()

		if( typeOfHit == "punch" ) then
			self:flinch( "short", direction )
		elseif( typeOfHit == "drag" ) then
			self:flinch( "long", direction )
		elseif( typeOfHit == "stationary flinch" ) then
			self:flinch( "stationary", direction )
		elseif( typeOfHit == "knockback+down" ) then
			self:modifiedJump( x * direction, y, false ) -- Ai is pushed back in the opposite direction of which he is facing
		elseif( typeOfHit == "knockdown" ) then
			self:fall( false )
		elseif( typeOfHit == "stun" ) then
			self:getStunned( false )
		else
			self:fall( false )
		end						
				
		self:reduceHP( damage )

		-- for debug only
		self.bodyHitbox:setStrokeColor( 255, 0, 0 ) -- turn the hit box red, but back to original in idle
				
	end
end


function Player:defendSuccess( damage, pushback )
	-- depending on the nature of the attack, player might still get hurt and pushed back
	-- self.defense was checked in main.detectPunch
	self:reduceHP( self.character.defenseRatio * damage )
	if( pushback ) then
		self:slideBack( pushback ) -- don't want to use modifiedJump 
	else
		self:slideBack() -- push back flinch amount or something
	end
end

function Player:slideBack( pushback )
	-- implement an acceleration/friction function here for accurate pushback
	self.sprite.x = self.sprite.x + self.mirror * -1 * 10
end

function Player:flipHorizontal( direction, check )

	-- if( currentGameMode == "multiplayer" and check ~= false ) then
	-- 	self:changeState( "flip horizontal", direction )
	-- end	

	timer.performWithDelay( self.interpolationDelay, function()
	
	if( self:checkPermissions( "mirroring" ) ) then 
		if( direction ~= self.mirror and direction ~= 0 ) then
			self.mirror = direction
			self.sprite:scale( -1, 1 )			
		end
	end

	end)
end

function Player:flinch( typeOfFlinch, direction )
	if( typeOfFlinch == "long" ) then -- when getting dragged, don't keep flinching; only flinch once, or will mess up Hero's drill attack
		--self.flinch = false -- setting this repeatedly causes Hero tornado drill to cease working properly, surprisingly
		if( self.sprite.sequence ~= "long flinch" ) then
			self.sprite:setSequence( "long flinch" )
			self.sprite:play()
		end
	elseif( typeOfFlinch == "short" ) then
		if( self.grabbed == false ) then -- if you are stunned, then you don't go back to idle
			self.flinching = true
			self.flinchStartTime = system.getTimer()
			self.sprite:setSequence( "flinch" )
			self.sprite:play()

			self.sprite.x = self.sprite.x + direction * self.flinchDistance/3	
		end 
	else
		-- stationary flinch
		self.flinching = true
		self.flinchStartTime = system.getTimer()
		self.sprite:setSequence( "flinch" )
		self.sprite:play()
	end

	-- should never be 0
	if( self.flinchTime == nil or self.flinchTime == 0 ) then
		self.flinchTime = 300
	end

	print("Flinch for ", self.flinchTime, "seconds.")
	timer.performWithDelay( self.flinchTime, function()
		if( self.flinching == true ) then
			self.flinching = false
			self:goIdle()
		end
	end)

end

function Player:getStunned()
	self.sprite:setSequence( "stunned" )
	self.sprite:play()
	self.stunned = true
	self.stunnedStartTime = system.getTimer()

	timer.performWithDelay( self.stunnedTime, function()
		self.stunned = false
		self:goIdle()
	end)
end

function Player:die()

	if( self.dead == false ) then

		self.hpValue = 0
		self.hp.isVisible = false
		self.dead = true

		self:fall( false )

		timer.performWithDelay(2000,function() Effects:death(self) end)
	end

	--[[
		
	-- if Player is still in the middle of a fall, let that play out first
	if( self.mJumped == false ) then
		if( self.dead == false ) then
			self.dead = true
			self:fall( false ) -- otherwise just fall down normally
		end
	end

	-- if for some damn reason you are still standing, fall anyway
	if( self.sprite.sequence == "idle" ) then
		self:fall( false )
	end
	]]--
	--[[
	if( currentGameMode == "multiplayer" ) then
		self:changeState( "game over" )
		gameOverReturn() -- runs main.lua:gameOver()
	end	
	]]--
end	

function Player:regenerateHP()
	if( self.hpValue <= self.fullhpValue ) then
		self.hpValue = self.hpValue + self.character.hpRegenValue
		if( self.controlled ) then
			self.hpOffset = (1-self.hpValue/self.fullhpValue) * 244 -- measured this value off the length of the mp bar only (not the whole PNG)... very crude
		else				
			self.hpPreX = self.hp.x - self.hp.contentWidth/2 -- using self.hp.x to compare doesn't work because hp.x doesn't change here, only width does
			self.hp.xScale = self.hpValue / self.fullhpValue
			self.hpPostX = self.hp.x - self.hp.contentWidth/2 
			self.hpOffset = self.hpOffset + (self.hpPostX - self.hpPreX)/2
		end
	end
end

function Player:regenerateMP()
	if( self.mpValue <= self.fullmpValue ) then
		self.mpValue = self.mpValue + (1-self.mpValue/self.fullmpValue)*self.character.mpRegenValue + self.baseMpRegenValue
		if( self.controlled ) then
			self.mpOffset = (1-self.mpValue/self.fullmpValue) * 151 -- measured this value off the length of the mp bar only (not the whole PNG)... very crude
		else			
			self.mpPreX = self.mp.x - self.mp.contentWidth/2 -- using self.hp.x to compare doesn't work because hp.x doesn't change here, only width does
			self.mp.xScale = self.mpValue / self.fullmpValue
			self.mpPostX = self.mp.x - self.mp.contentWidth/2 
			self.mpOffset = self.mpOffset + (self.mpPostX - self.mpPreX)/2
		end
	end

	--self.mpUnder.x = self.mpLeft - self.mpOffset/2
end

-- separate function made to reduce confusion
function Player:reduceHP( damage ) 
	-- if next hit takes self's hp below 0, set as 0 instead
	if( self.hpValue - math.round(damage) <= 0 ) then
		self:die()		
	else
		if DebugInstance.logText then print( self.name.." has been damaged for "..tostring(damage).." HP!") end
		damage = math.round(damage)	-- to round radius-based type attacks	
		self.hpValue = self.hpValue - math.round(damage)	
		
		if( self.controlled ) then
			self.hpOffset = (1-self.hpValue/self.fullhpValue) * 244 -- measured this value off the length of the mp bar only (not the whole PNG)... very crude
		else				
			self.hpPreX = self.hp.x - self.hp.contentWidth/2 -- using self.hp.x to compare doesn't work because hp.x doesn't change here, only width does
			self.hp.xScale = self.hpValue / self.fullhpValue
			self.hpPostX = self.hp.x - self.hp.contentWidth/2 
			self.hpOffset = self.hpOffset + (self.hpPostX - self.hpPreX)/2
		end
	end

end

function Player:reduceMP( mana ) 

	self.mpValue = self.mpValue - mana

	if( self.mpValue - mana <= 0 ) then
		self.mpValue = 0
	else
		if self.controlled then
			self.mpOffset = (1-self.mpValue/self.fullmpValue) * 151
		else 
			self.mpPreX = self.mp.x - self.mp.contentWidth/2 -- using self.hp.x to compare doesn't work because hp.x doesn't change here, only width does
			self.mp.xScale = self.mpValue / self.fullmpValue
			self.mpPostX = self.mp.x - self.mp.contentWidth/2 
			self.mpOffset = self.mpOffset + (self.mpPostX - self.mpPreX)/2
		end
	end
end

function Player:fall( check )

	self.invulnerable = true -- cannot be hit while falling (or can he?)
	self.flinching = false -- is this necessary?
	
	if( self.sprite.sequence ~= "falling" or self.sprite.sequence ~= "fallen" ) then
		self.sprite:setSequence( "falling" )
		self.sprite:play()
		self.falling = true
	end

	-- if holding an item, drop it (later on, drop it only when fallen onto the ground)
	if self.itemHeldFlag == true then
		self:dropItem()
	end

	-- when is this used?
	if( self.mJumped == true ) then
		self.mJumped = false
		self.sprite:setSequence( "fallen" )
		self.sprite:play()
		self.fallen = true -- flag check for fallen
	end

	self.fallenTimeStart = system.getTimer()

	-- after 2 seconds
	timer.performWithDelay( self.fallenTimeDuration2, function()
		if( self.dead == false ) then 
			self.fallen = false
			self:getUp( false )
		end -- if dead, don't get up
	end)

	-- after 0.750 seconds, play the "fallen on the ground" animation
	timer.performWithDelay( self.fallenTimeDuration1, function()
		self.falling = false
		self.fallen = true
		self.sprite:setSequence( "fallen" )
		self.sprite:play()
	end)
end

function Player:fallback( forceX, forceY, direction ) -- equivalent to getting knocked back, but without any vertical
	-- self:flinch( "long" )
  	self.sprite:setSequence( "falling1" )
  	self.sprite:play()
	-- do a modified jump
	self:modifiedJump( forceX * direction, forceY, false ) -- Ai is pushed back in the opposite direction of which he is facing
	--self.knocked = true
	-- For future notes: don't set flinch to true in above; you'll go back to idle instantly
	-- use self.knocked, not hit.
end

function Player:getUp( check )
	self.gettingUp = true
	self.fallen = false
	self.invulnerable = true
	-- show getting up sprite
	self.sprite:setSequence("getup")
	self.sprite:play()
	self.getUpTimeStart = system.getTimer()

	timer.performWithDelay( self.getUpTimeDuration, function()
		if( self.gettingUp == true ) then
			self.falling = false
			self.fallen = false 
			self.gettingUp = false
			self:goIdle()

			timer.performWithDelay( 1000, function() -- stay invulnerable for another 500 seconds after getting up animation is finished playing (500+500)
				self.invulnerable = false 
			end)
		end
	end)
end


-- auxiliary functions

function Player:grab( opponent )
	opponent.grabbed = true
	opponent.stunned = false -- prevent him from getting grabbed again
	
	opponent.sprite:setSequence("grabbed")
	opponent.sprite:play()
	
	self.sprite:setSequence("grab")
	self.sprite:play()

	self.opponentHeld = opponent
	self.grabStartTime = system.getTimer()
	self.grabbing = true; self.grabbed = false;

	self.attacking = false -- cancel penalty delay of last attack + grab

	timer.performWithDelay( self.grabTime, function()
		if self.grabbing == true and self.throwing == false then
			self.opponentHeld.grabbed = false
			self.opponentHeld:fall( false )
			self.grabbing = false
			self.grabPunchAllowed = true -- allow grab punch again for next time
			-- let go of opponent, making sure he can't get hit again on the way down
			self.opponentHeld = nil
			self:goIdle()
		end
	end)
end

function Player:throwOpponent( direction )

	if( self.grabbing == true ) then
		self.grabbing = false -- turn it false here before it expires (it will crash if performed in timer below)
		self.throwing = true
		self.throwStartTime = system.getTimer()
		self.sprite:setSequence( "throw opponent" )
		self.sprite:play()
		print("throw opponent in the direction of ", direction)

		if( direction ~= self.mirror ) then
			self.sprite:scale( -1, 1 )
		end

		timer.performWithDelay( self.throwTime*2/3, function()
			self.opponentHeld.grabbed = false
			self.opponentHeld.guyWhoThrowsYou = self
			self.opponentHeld:modifiedJump( direction*1000, 500, true ) -- forceX, forceY, offensive (well I guess you can hurt people)
			-- opponent is no longer grabbed, though I'm afraid this 0.0001 second of freedom will make him do weird things
			self.opponentHeld = nil
		end)

		timer.performWithDelay( self.throwTime+100, function()
			self.throwing = false
			self:goIdle()
		end)
	end
end

function Player:pickUpItem( check )

	for k, v in pairs( GameController.currentItems ) do
		--if itemDebug then print( v.name.." is - pickedUp: "..tostring(v.pickedUp).." flying: "..tostring(v.flying) ) end
		if( v.pickedUp == false and v.flying == false ) then -- can't pick up if item is in-air
			if( math.abs(self.sprite.x - v.sprite.x) <= self.pickUpDistanceX ) then
				if( math.abs(self.bot - v.sprite.y) <= self.pickUpDistanceY ) then
					self.sprite:setSequence( "pickup" )
					self.sprite:play()
					v.pickedUp = true
					self.itemBeingHeld = v
					self.itemHeldFlag = true
				end
			end	
		end			
	end

	timer.performWithDelay( 300, function()
		if self.attacking == false then
			self:goIdle()
		end
	end)
	
	if( self.itemBeingHeld == nil ) then
		if DebugInstance.logText then print ( "No nearby items" ) end	
		return false 
	else
		if DebugInstance.logText then print ( "Picked up", self.itemBeingHeld.name ) end
		return true
	end
end

-- This function is checked with every update loop
-- If the Player's itemBeingHeld table (i.e. a list of Items he's holding onto) 
function Player:holdingItems()
	if self.itemBeingHeld ~= nil then 
		self.itemBeingHeld.mirror = self.mirror -- mirror item image if necessary

		self.itemBeingHeld.sprite.x = ( self.sprite.x - self.mirror * self.sprite.width/30 ) 
		self.itemBeingHeld.sprite.y = self.sprite.y + self.sprite.width*0.4

		-- make sure item is oriented the same way as the player!
		if( self.throwing == false ) then
			self.itemBeingHeld.sprite.x = self.itemBeingHeld.sprite.x + self.itemBeingHeld.mirror * self.itemBeingHeld.itemType.holdPointX
			self.itemBeingHeld.sprite.y = self.itemBeingHeld.sprite.y + self.itemBeingHeld.itemType.holdPointY 
		else
			-- adjust item sprite based on throwing animation frames WHILE Item:throw(self) in function below has not been activated yet
			--if( system.getTimer() - self.throwStartTime < self.throwTime*3/4 ) then	
			if( system.getTimer() - self.throwStartTime > ( self.throwTime*2/3 - 60 ) / self.slowDownFactor ) then
				-- second frame
				self.itemBeingHeld.sprite.x = self.sprite.x + self.mirror * self.sprite.width/2
				self.itemBeingHeld.sprite.y = self.sprite.y + self.sprite.height*0.019			
			elseif( system.getTimer() - self.throwStartTime > self.throwTime*1/3 / self.slowDownFactor ) then
				-- second frame
				self.itemBeingHeld.sprite.x = self.sprite.x + self.mirror * self.sprite.width*0.186
				self.itemBeingHeld.sprite.y = self.sprite.y + self.sprite.height*0.019
			elseif( system.getTimer() - self.throwStartTime > 0 ) then
				-- first frame
				self.itemBeingHeld.sprite.x = self.sprite.x + self.mirror * -1 * self.sprite.width*0.25 
				self.itemBeingHeld.sprite.y = self.sprite.y + self.sprite.height*0.045
			end
		end
	end
end

function Player:dropItem()
	self.itemHeldFlag = false
	local itemToDrop = self.itemBeingHeld
	self.itemBeingHeld = nil
	itemToDrop.flying = true -- so Item:dropCheck() listener can start moving it
	itemToDrop.pickedUp = false
	itemToDrop.airTimer = system.getTimer()

	itemToDrop.X0 = itemToDrop.sprite.x
	itemToDrop.Y0 = self.sprite.y -- throw from player's face-level
	itemToDrop.dropPoint = self.bot -- land at player's feet level instead
	itemToDrop.Ux = 0	
	itemToDrop.Uy = 0
end


function Player:throwItem()
	
	local itemToThrow = self.itemBeingHeld
	self.itemBeingHeld = nil
	itemToThrow.flying = true
	itemToThrow.thrown = true
	itemToThrow.pickedUp = false -- do not allow item to be picked up anymore
	itemToThrow.thrower = self

	-- item sprite should be oriented the direction player throws it
	itemToThrow.mirror = self.mirror 
	if( self.mirror == 1 ) then 
		itemToThrow.mirrored = false 
	else 
		itemToThrow.mirrored = true 
	end	

	-- initialize physics equations
	itemToThrow.airTimer = system.getTimer()

	-- jump throw
	if( self.jumped == true ) then
		itemToThrow.Uy = -400 -- should be an angle of where he's jumped but whatever for now, or just always set to throw downwards
		itemToThrow.Y0 = self.sprite.y
		itemToThrow.dropPoint = self.Y0 --+ player.sprite.contentHeight/2 -- the "bot" of his landing position
		if( self.running == true ) then -- throw 1.5x farther if running (2x is too far)
			itemToThrow.Ux = itemToThrow.defaultUx * self.throwPower * 1.5
		else
			itemToThrow.Ux = itemToThrow.defaultUx * self.throwPower * 0.7
		end
	else -- non-jump throw
		itemToThrow.Uy = itemToThrow.defaultUy
		itemToThrow.Y0 = self.sprite.y -- throw from player's face-level
		itemToThrow.dropPoint = self.bot -- land at player's feet level instead
		if( self.running == true ) then -- throw 1.5x farther if running (2x is too far)
			itemToThrow.Ux = itemToThrow.defaultUx * self.throwPower * 1.5
		else
			itemToThrow.Ux = itemToThrow.defaultUx * self.throwPower
		end
	end
	
	itemToThrow.X0 = itemToThrow.sprite.x + self.mirror * self.sprite.width/2 -- throw from player's arm length
	itemToThrow.direction = self.mirror
end

function Player:ItemAttack( check )

	if( self.itemBeingHeld.itemType.ability == nil ) then
		self.throwing = true
		self.throwStartTime = system.getTimer()
		self.sprite:setSequence( "throwing" )
		self.sprite:play()
		self.sprite.timeScale = 2.0
		timer.performWithDelay( self.throwTime*2/3, function() 
			if self.itemHeldFlag == true then
				self:throwItem() 
				self.itemHeldFlag = false
			end
		end )
	else
		self.itemBeingHeld.itemType:ability( self.itemBeingHeld.sprite.x, self.itemBeingHeld.sprite.y, self.mirror, self )
	end	

	timer.performWithDelay( self.totalThrowTime, function()
		if( self.throwing == true ) then
			self.throwing = false
			self:goIdle()
		end
	end)
end

function Player:interpretSpecial()
	-- this function is already done inside specialSkill() but the interpretation is needed in advance to send out the packet for other clients
	if ( string.match(self.commands, "dua") ) then
		return "dua"
	elseif ( string.match(self.commands, "dra") ) then
		return "dra"
	elseif ( string.match(self.commands, "dla") ) then
		return "dla"
	elseif ( string.match(self.commands, "drj") ) then
		return "drj"
	elseif ( string.match(self.commands, "dlj") ) then
		return "dlj"
	elseif ( string.match(self.commands, "duj") ) then
		return "duj"
	elseif ( string.match(self.commands, "dva") ) then
		return "dva"
	elseif ( string.match(self.commands, "dvj") ) then
		return "dvj"
	else
		return ""
	end
end

function Player:specialSkill( typeOfSkill, playerAction )

	if( currentGameMode == "multiplayer"  ) then 
		local sp = self:interpretSpecial()
		self:changeState( "special", sp )
	end	

	timer.performWithDelay( self.interpolationDelay, function()

	if typeOfSkill == nil then
		self.typeOfSpecial = self:interpretSpecial()
	else
		self.typeOfSpecial = typeOfSkill
	end

	if( self:checkPermissions( "skill" ) and self.typeOfSpecial ~= "" ) then

		if ( self.typeOfSpecial == "dua" or currentGameMode == "multiplayer" and typeOfSkill == "dua" or self.isAI and typeOfSkill == "dua" ) then
			if( self.performingSpecial == "none" ) then -- prevents player from performing a special during another special
				if( self.character:upAttack( self ) ) then
					self.performingSpecial = self.character.duaType
					self.performingSpecialVulnerability = self.character.duaVulnerability
					self.startedSpecial = system.getTimer()					
				end
				self.commands = ""
			end		
		elseif ( self.typeOfSpecial == "dra" or currentGameMode == "multiplayer" and typeOfSkill == "dra" or self.isAI and typeOfSkill == "dra" )  then
			if( self.performingSpecial == "none" or self.shootingBalls == true ) then -- prevents player from performing a special during another special
				if( self.character:leftRightAttack( self, "right" ) ) then
					self.performingSpecial = self.character.dlraType
					self.performingSpecialVulnerability = self.character.dlraVulnerability
					self.startedSpecial = system.getTimer() -- set timer to put performingSpecial back to false in stateCheck()
				end
				self.commands = ""
			end
		elseif ( self.typeOfSpecial == "dla" or currentGameMode == "multiplayer" and typeOfSkill == "dla" or self.isAI and typeOfSkill == "dla" )  then
			if( self.performingSpecial == "none" or self.shootingBalls == true ) then -- prevents player from performing a special during another special
				if( self.character:leftRightAttack( self, "left" ) ) then
					self.performingSpecial = self.character.dlraType
					self.performingSpecialVulnerability = self.character.dlraVulnerability
					self.startedSpecial = system.getTimer() -- set timer to put performingSpecial back to false in stateCheck()
				end
				self.commands = ""
			end
		elseif ( self.typeOfSpecial == "drj" or currentGameMode == "multiplayer" and typeOfSkill == "drj" or self.isAI and typeOfSkill == "drj" )  then
			if( self.performingSpecial == "none" ) then -- prevents player from performing a special during another special
				if( self.character:leftRightJump( self, "right") ) then
					self.performingSpecial = self.character.dlrjType
					self.performingSpecialVulnerability = self.character.dlrjVulnerability	
					self.startedSpecial = system.getTimer() -- set timer to put performingSpecial back to false in stateCheck()
				end
				self.commands = ""
			end		
		elseif (self.typeOfSpecial == "dlj" or currentGameMode == "multiplayer" and typeOfSkill == "dlj" or self.isAI and typeOfSkill == "dlj" )then
			if( self.performingSpecial == "none" ) then -- prevents player from performing a special during another special
				if( self.character:leftRightJump( self, "left" ) ) then
					self.performingSpecial = self.character.dlrjType
					self.performingSpecialVulnerability = self.character.dlrjVulnerability
					self.startedSpecial = system.getTimer() -- set timer to put performingSpecial back to false in stateCheck()
				end
				self.commands = ""
			end	
		elseif ( self.typeOfSpecial == "dva"  or currentGameMode == "multiplayer" and typeOfSkill == "dva" or self.isAI and typeOfSkill == "dva" ) then
			if( self.performingSpecial == "none" ) then -- prevents player from performing a special during another special
				if( self.character:downAttack( self ) ) then
					self.performingSpecial = self.character.dvaType
					self.performingSpecialVulnerability = self.character.dvaVulnerability
					self.startedSpecial = system.getTimer() -- set timer to put performingSpecial back to false in stateCheck()
				end
				self.commands = ""			
			end
		elseif ( self.typeOfSpecial == "duj" or currentGameMode == "multiplayer" and typeOfSkill == "duj" or self.isAI and typeOfSkill == "duj" ) then
			if( self.performingSpecial == "none" ) then -- prevents player from performing a special during another special
				if( self.mpValue >= self.character.upJumpMana ) then
					self.performingSpecial = self.character.dujType
					self.performingSpecialVulnerability = self.character.dujVulnerability
					self.startedSpecial = system.getTimer() -- set timer to put performingSpecial back to false in stateCheck()
					self.character:upJump( self )
				end
				self.commands = ""			
			end		
		elseif ( self.typeOfSpecial == "dvj" or currentGameMode == "multiplayer" and typeOfSkill == "dvj" or self.isAI and typeOfSkill == "dvj" ) then
			if( self.performingSpecial == "none" ) then -- prevents player from performing a special during another special
				if( self.mpValue >= self.character.downJumpMana ) then
					self.performingSpecial = self.character.dvjType
					self.performingSpecialVulnerability = self.character.dvjVulnerability
					self.startedSpecial = system.getTimer() -- set timer to put performingSpecial back to false in stateCheck()
					self.character:downJump( self )
				end
				self.commands = ""
			end	
		end

		-- if performing special skill, don't show item held
		if( self.itemBeingHeld ) then
			self.itemBeingHeld.sprite.isVisible = false
		end

		timer.performWithDelay( self.character:specialTime( self.typeOfSpecial ), function()
			if( self.performingSpecial ~= "none" ) then
				if( self.itemBeingHeld ) then
					self.itemBeingHeld.sprite.isVisible = true
				end
				self.performingSpecial = "none"
				self.performingSpecialVulnerability = false
				self:goIdle()		
			end			
		end)
	else
		self.commands = ""

		-- execute jump or attack here
		if( playerAction == "jump" ) then
			self:jump()
		elseif( playerAction == "attack" ) then
			self:attack()
		end
	end

	end)
end

function Player:selectPlayer( name )
	if( name == "Hero" ) then
		return Hero
	elseif( name == "Hank" ) then
    	return Hank
	end
end

function Player:epsilon( num1, num2, range ) -- returns true if two numbers are within range (approximate)
	if( math.abs(num1-num2) <= range ) then 
		return true
	else 
		return false
	end
end

function Player:update()

	-- multiplayer slow down applied to sprite animation
	self.sprite.timeScale = 1/self.slowDownFactor 
	-- also applied to JUMP, MJUMP, RUN SPEED, and..?
	self.runningSpeed = self.defaultRunningSpeed/self.slowDownFactor
	self.walkingSpeed = self.defaultWalkingSpeed/self.slowDownFactor
	self.verticalSpeedY = self.defaultSpeedY/self.slowDownFactor
	self.dragSpeed = self.defaultDragSpeed/self.slowDownFactor

	-- used for Update.lua layers() layering
	self.bot = self.sprite.y + self.sprite.contentHeight/2
	
	-- changes idle animations randomly
	if( self.character.customIdleAnimations == true ) then -- if character custom idle animations are supported
		if( system.getTimer() - self.lastSpriteChange > self.character.longestRandomAnimation * self.slowDownFactor ) then -- one probable sprite change every 3 secs; favors sprite animations with shorter playtimes to play
			local rand = math.random(1,3)
			if( rand == 3 ) then -- 33% chance of changing
				if( self.sprite.sequence == "idle" ) then
					self.sprite:setSequence( "idle2" )
					self.sprite:play()
				elseif( self.sprite.sequence == "idle2" ) then
					self.sprite:setSequence( "idle" )
					self.sprite:play()
				end
			end
			self.lastSpriteChange = system.getTimer()
		end
	end

	-- update buttons (jump/getitem)
	if self.controlled == true then
		if Item:detectItems( self ) == true then
			self.controls.bGetItem.isVisible = true
			self.controls.bAttack.isVisible = false
			self.controls.buttonGroup:toFront()
		else
			self.controls.bGetItem.isVisible = false
			self.controls.bAttack.isVisible = true
			self.controls.buttonGroup:toFront()
		end
	end
	
	self:move()
	self:mJumpCheck()
	self:jumpCheck() -- changes player position during the jump, and checks for when jump has ended
	self:stateCheck() -- checks expiry times for attack and defense, checks for thrown Items
	self:elementsFollowing() -- makes sure the health bar follows the Player
	self:elementsToFront()
	self:holdingItems() -- makes sure Items that Player is holding is attached to/follows him
	self:debug()

	self:regenerateHP(); self:regenerateMP()
end

function Player:spriteSwap( var )

	temp_x = self.sprite.x
	temp_y = self.sprite.y
	temp_xScale = self.sprite.xScale
	temp_yScale = self.sprite.yScale
	self.sprite:removeSelf()

	if( var == "normal" ) then
		self.sprite = display.newSprite( self.character.sheet, self.character.seqData )
		self.spriteSet = "normal"
	elseif( var == "attack skills" ) then
		self.sprite = display.newSprite( self.character.sheet3, self.character.seqData3 )
		self.spriteSet = "skills"
	elseif( var == "jump skills" ) then
		self.sprite = display.newSprite( self.character.sheet2, self.character.seqData2 )
		self.spriteSet = "skills"
	end

	self.sprite.y = temp_y
	self.sprite.x = temp_x
    self.sprite:scale(temp_xScale, temp_yScale ) -- flip horizontally if character was mirrored
   
   	-- put sprite back into camera
   camera.group:insert(self.sprite)
end

function Player:darkenScreen( duration )
	-- experimentative function that darkens the whole screen for a split second
	-- right when Player performs a special

	self.darkOverlay.isVisible = true

	local function removeDarken()
		self.darkOverlay.isVisible = false
	end

	timer.performWithDelay( duration, removeDarken )
end

function Player:debug()

	if DebugInstance.screenText then
		if( self.controlled == true ) then
			self.debugText.text = self.sprite.sequence
		    self.debugText:setReferencePoint( display.CenterReferencePoint )
			self.debugText.x = self.sprite.x
			self.debugText.y = self.bot
			self.debugText.width = 300
		else			
			--self.debugText.text = "AI State = "..self.state.." \nxTarget = "..self.xTarget.."\nyTarget = "..self.yTarget.."\nDirectionX = "..self.directionX.."\nDirectionY = "..self.directionY.."\nHP = "..self.hpValue.."\nSpeedX = "..self.speedX
		    self.debugText.text = tostring(self.itemHeldFlag).."\n"..tostring(self.xTarget)..",".."\n"..tostring(self.yTarget)
		    self.debugText:setReferencePoint( display.CenterReferencePoint )
			self.debugText.x = self.sprite.x
			self.debugText.y = self.bot
			self.debugText.width = 300
			self.debugText.height = 500
		end
	end
end	

return Player


