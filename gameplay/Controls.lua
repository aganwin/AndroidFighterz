local GameSettings = require( "menus.GameSettings" )
local Multiplayer = require( "multiplayer.Multiplayer" )
local Debug = require( "helpers.Debug" )

system.setTapDelay( 300 )
lowestTransparency = 0.01

local Controls = {
	turnOtherSideDelay = 300,

	lastTapTime = 0,
	minTapTime = 300,

	analogPosX = display.contentWidth*160/1280,
	analogPosY = display.contentHeight*555/720,
	analogDistanceMax = 30, -- how far away the analog stick can move away from the controls
	maxAnalogDragDistance = display.contentWidth*150/1280, -- how far your finger can drag away from the initial point
	fixedController = false,

	lastKeyboardDirection = 0,

	bLeftPressed = false,
	bRightPressed = false,

	keyboardLeftLetGoTime = 0,
	keyboardRightLetGoTime = 0
}

local Controls_metatable = {
	__index = Controls
}

local atkKeyOn = false
local defKeyOn = false
local jumpKeyOn = false

function Controls.new( player )
	c = {}
	setmetatable( c, Controls_metatable )
	c.player = player
	if c.player.controlled == true then
		c:draw()
	end
	c:init()
	return c
end

function Controls:draw()

	self.buttonGroup = display.newGroup()

	self.analogArea = display.newRect( 0, 0, display.contentWidth/2, display.contentHeight )

	self.bAttack = display.newImageRect( "images/buttons/attack.png", 151, 151 )
	self.bDef = display.newImageRect( "images/buttons/defense.png", 151, 151 )
	self.bJump = display.newImageRect( "images/buttons/jump.png", 151, 151 )
	self.bGetItem = display.newImageRect( "images/buttons/pickupitem.png", 151, 151 )
	self.bRecover = display.newImageRect( "images/buttons/recover.png", 151, 151 )

	self.bAttack:setReferencePoint( display.CenterReferencePoint )
	self.bDef:setReferencePoint( display.CenterReferencePoint )
	self.bJump:setReferencePoint( display.CenterReferencePoint )
	self.bGetItem:setReferencePoint( display.CenterReferencePoint )
	self.bRecover:setReferencePoint( display.CenterReferencePoint )

	self.analogArea.alpha = 0.01
	self.bAttack.alpha = 0.6
	self.bDef.alpha = 0.6
	self.bJump.alpha = 0.6
	self.bGetItem.alpha = 0.6
	self.bGetItem.isVisible = false -- only turned visible when item is nearby
	self.bRecover.isVisible = false

	self.bDPAD = display.newImageRect( "images/buttons/analog.png", 160, 160 )
	self.bDPAD:scale(1.2,1.2)
	self.bDPAD.alpha = 0.5
	self.bDPAD.x = self.analogPosX; self.bDPAD.y = self.analogPosY

	self.bStick = display.newImageRect( "images/buttons/stick.png", 160, 160 )
	self.bStick:scale(0.8,0.8)
	self.bStick.alpha = 0.5
	self.bStick.x = self.analogPosX; self.bStick.y = self.analogPosY

	self.instructions = display.newImage( "images/buttons/taptomove.png", 0, 0 )
	self.instructions.alpha = 1
	self.instructions.x = self.analogPosX + 200; self.instructions.y = self.analogPosY - 120;
	timer.performWithDelay(1000, function()
		transition.to( self.instructions, { time = 1500, alpha = 0 } )
	end )
				
	self.bDef.x = display.contentWidth * 29/40
	self.bDef.y = display.contentHeight * 17/20
	self.bAttack.x = display.contentWidth * 33/40
	self.bAttack.y = display.contentHeight * 15/20
	self.bGetItem.x = display.contentWidth * 33/40
	self.bGetItem.y = display.contentHeight * 15/20
	self.bJump.x = display.contentWidth * 37/40
	self.bJump.y = display.contentHeight * 13/20
	self.bRecover.x = display.contentWidth * 37/40
	self.bRecover.y = display.contentHeight * 13/20
	
	self.buttonGroup:insert( self.instructions )
	self.buttonGroup:insert( self.analogArea )
	self.buttonGroup:insert( self.bAttack )
	self.buttonGroup:insert( self.bDef )
	self.buttonGroup:insert( self.bJump )
	self.buttonGroup:insert( self.bGetItem )
	self.buttonGroup:insert( self.bRecover )
	self.buttonGroup:insert( self.bDPAD )
	self.buttonGroup:insert( self.bStick )
end

function Controls:stop() 

	if( currentGameMode == "multiplayer" and self.player.controlled == true ) then 
		Multiplayer:sendStop( self.player.sprite.x, self.player.sprite.y )
	end

	self.player:changeDirection( 0, 0 )
	self.player:idle(false,true)
end

function Controls:init()
	if self.player.controlled == true then
		self.analogArea:addEventListener( "touch", function(event) self:move(event) end )
		self.bDef:addEventListener( "touch", function(event) self:def(event) end )
		self.bAttack:addEventListener( "touch", function(event) self:attack(event) end )
		self.bGetItem:addEventListener( "touch", function(event) self:attack(event) end )
		self.bJump:addEventListener( "touch", function(event) self:jump(event) end )	
		self.bRecover:addEventListener( "touch", function(event) self:jump(event) end )

		function onKey(event)
			local key = event.keyName
			local keyCode = event.nativeKeyCode
			local isCtrlDown = event.isCtrlDown
			local isAltDown = event.isAltDown
			local isShiftDown = event.isShiftDown
			local phase = event.phase

			--print( key, keyCode, phase )

			local event = {}
			if( phase == "down" ) then
				if( key == "w" ) then
					self:manualKeyboardMove(nil,-1)
					self.player.commands = self.player.commands.."u"
				elseif( key == "s" ) then
					self:manualKeyboardMove(nil,1)
					self.player.commands = self.player.commands.."v"
				end

				if( key == "a" ) then
					self:manualKeyboardMove(-1,nil)
					self.player.commands = self.player.commands.."l"
					self.bLeftPressed = true
					self.bRightPressed = false
				elseif( key == "d" ) then
					self:manualKeyboardMove(1,nil)
					self.player.commands = self.player.commands.."r"
					self.bRightPressed = true
					self.bLeftPressed = false
				end
				event.phase = "began"

				if( key == "j" and defKeyOn == false ) then
					self:def(event)
					defKeyOn = not defKeyOn
				elseif( key == "k" and atkKeyOn == false ) then
					self:attack(event)
					atkKeyOn = not atkKeyOn
				elseif( key == "l" and jumpKeyOn == false ) then
					self:jump(event)
					jumpKeyOn = not jumpKeyOn
				end	

			elseif( phase == "up" ) then
				event.phase = "ended"
				if( key == "w" or key == "a" or key == "s" or key == "d" ) then
					self:manualKeyboardMove(0,0)		
				end	

				if( key == "a" ) then
					self.keyboardLeftLetGoTime = system.getTimer()
					self.keyboardRightLetGoTime = 0
					self.bLeftPressed = false
				elseif( key == "d" ) then
					self.keyboardRightLetGoTime = system.getTimer()
					self.keyboardLeftLetGoTime = 0					
					self.bRightPressed = false
				end	

				if( key == "j" and defKeyOn == true ) then
					defKeyOn = not defKeyOn
				elseif( key == "k" and atkKeyOn == true ) then
					atkKeyOn = not atkKeyOn
				elseif( key == "l" and jumpKeyOn == true ) then
					jumpKeyOn = not jumpKeyOn
				end					
			end			

		    return true
		end

		if Debug.keyboard == true then Runtime:addEventListener( "key", onKey ) end
	end
end

function Controls:letGo()
	if Controls.fixedController == false then
		self.bDPAD.isVisible = false
		self.bStick.isVisible = false
	else
		self.bStick.x = self.bDPAD.x; self.bStick.y = self.bDPAD.y
	end

	if self.player.directionX == 1 then
		self.player.commands = self.player.commands.."r"
	elseif self.player.directionX == -1 then
		self.player.commands = self.player.commands.."l"
	end

	if self.player.directionY == 1 then
		self.player.commands = self.player.commands.."v"
	elseif self.player.directionY == -1 then
		self.player.commands = self.player.commands.."u"
	end

	self:stop()
end

function Controls:manualKeyboardMove(x,y)

	if x == 0 and y == 0 then
		self:stop()
		return
	end

	self.player:changeDirection(x,y)

	if self.player.running == false then -- this function will keep proc-ing when < > button is held, so make sure run doesnt stop
		self.player:walk()
	end

	if x == self.lastKeyboardDirection then
		if system.getTimer() - self.keyboardLeftLetGoTime < 200 then 
			self.player:run()
		elseif system.getTimer() - self.keyboardRightLetGoTime < 200 then 
			self.player:run()
		end
	end

	self.lastKeyboardDirection = x
end

function Controls:manualMove(distanceMovedX, distanceMovedY)
	local distanceMoved = math.sqrt(math.pow(math.abs(distanceMovedX),2)+math.pow(math.abs(distanceMovedY),2))

	local directionMovedX
	local directionMovedY

	if distanceMovedX > 10 then
		directionMovedX = 1
		self.bRightPressed = true
	elseif distanceMovedX < -10 then
		directionMovedX = -1
		self.bLeftPressed = true
	else
		directionMovedX = 0
	end

	if distanceMovedY > 10 then
		directionMovedY = 1
	elseif distanceMovedY < -10 then
		directionMovedY = -1
	else
		directionMovedY = 0
	end
			
	if distanceMoved >= 40 then
		self.player:changeDirection(directionMovedX, directionMovedY)
		self.player:flipHorizontal(directionMovedX)

		if directionMovedX ~= 0 then 
			self.player:run()
		else
			self.player:walk()
		end
	elseif distanceMoved >= 10 then
		self.player:changeDirection(directionMovedX, directionMovedY)
		self.player:flipHorizontal(directionMovedX)
		self.player:walk()
	else
		self.player:goIdle()
	end
end

function Controls:move(event)

	if GameSettings.paused == false then
		if event.phase == "began" then
			if Controls.fixedController == false then
				self.instructions.isVisible = false
				self.bDPAD.isVisible = false
				self.bStick.isVisible = false
				self.bDPAD.x = event.x; self.bDPAD.y = event.y
				self.bStick.x = event.x; self.bStick.y = event.y
				self.bDPAD.isVisible = true
				self.bStick.isVisible = true
			end
		elseif event.phase == "moved" then

			-- finger must start dragging at analog stick area
			if Controls.fixedController == true then
				if event.xStart > Controls.analogPosX + Controls.maxAnalogDragDistance or event.xStart < Controls.analogPosX - Controls.maxAnalogDragDistance then
					return
				elseif event.yStart > Controls.analogPosY + Controls.maxAnalogDragDistance or event.yStart < Controls.analogPosY - Controls.maxAnalogDragDistance then
					return
				end
			end

			-- detect direction moved
			local distanceMovedX = event.x - event.xStart
			local distanceMovedY = event.y - event.yStart

			-- calculate distance moved away from center
			local distanceMoved = math.sqrt(math.pow(math.abs(distanceMovedX),2)+math.pow(math.abs(distanceMovedY),2))

			if distanceMoved > self.maxAnalogDragDistance then
				self:letGo()
				return
			end

			local directionMovedX
			local directionMovedY

			if distanceMovedX > 10 then
				directionMovedX = 1
			elseif distanceMovedX < -10 then
				directionMovedX = -1
			else
				directionMovedX = 0
			end

			if distanceMovedY > 10 then
				directionMovedY = 1
			elseif distanceMovedY < -10 then
				directionMovedY = -1
			else
				directionMovedY = 0
			end

			Multiplayer:sendInput("movement", event.phase, event.time, distanceMovedX, distanceMovedY)

			if distanceMovedX <= -10 then 
				self.bLeftPressed = true
			elseif distanceMovedX >= 10 then
				self.bRightPressed = true
			else
				self.bLeftPressed = false
				self.bRightPressed = false
			end

			if distanceMoved >= 40 then
				self.player:changeDirection(directionMovedX, directionMovedY)
				self.player:flipHorizontal(directionMovedX)

				-- don't use run() for strictly up/down movement
				if directionMovedX ~= 0 then 
					self.player:run()
				else
					self.player:walk()
				end

				self.bStick.x = self.bDPAD.x + directionMovedX * self.analogDistanceMax
				self.bStick.y = self.bDPAD.y + directionMovedY * self.analogDistanceMax
			elseif distanceMoved >= 10 then
				self.player:changeDirection(directionMovedX, directionMovedY)
				self.player:flipHorizontal(directionMovedX)
				self.player:walk()

				if Controls.fixedController == false then
					self.bStick.x = event.x
					self.bStick.y = event.y
				else
					self.bStick.x = self.bDPAD.x + directionMovedX * self.analogDistanceMax
					self.bStick.y = self.bDPAD.y + directionMovedY * self.analogDistanceMax
				end
			else
				self.player:goIdle()

				if Controls.fixedController == false then
					self.bStick.x = event.x
					self.bStick.y = event.y
				else
					self.bStick.x = self.bDPAD.x + directionMovedX * self.analogDistanceMax
					self.bStick.y = self.bDPAD.y + directionMovedY * self.analogDistanceMax
				end
			end

		elseif event.phase == "ended" then
			self:letGo()
		end
	end
end	

function Controls:def( event )
	if event.phase == "began" and GameSettings.paused == false then

		if( currentGameMode == "multiplayer" and self.player.controlled == true ) then 
			Multiplayer:sendInput("def", event.phase, event.time )
			self.player.commands = self.player.commands.."d"
			self.player:defend()
		elseif( currentGameMode == "multiplayer" and self.player.controlled == false ) then
			-- if opponent player actually defended within certain timeframe, bypass his current state
			self.player.commands = self.player.commands.."d"
			self.player:defend( nil, nil, true )
		elseif( currentGameMode ~= "multiplayer" ) then
			self.player.commands = self.player.commands.."d"
			self.player:defend()
		end
		
		transition.to( self.bDef, { xScale = 0.92, yScale = 0.92, time = 100 } )

		return true
	elseif event.phase == "ended" then
		
		transition.to( self.bDef, { xScale = 1, yScale = 1, time = 100 } )

		return false
	end
end

-- if there is an Item in vicinity, pick it up
-- if an Item is held, throw it
function Controls:attack( event )
	if event.phase == "began" and GameSettings.paused == false then
		
		if( currentGameMode == "multiplayer" and self.player.controlled == true ) then 
			Multiplayer:sendInput("attack", event.phase, event.time )
		end

		self.player.commands = self.player.commands.."a" -- for special skill commands
		self.player:specialSkill( nil, "attack" ) -- nil is for typeOfSkill, used by AI
		-- shrink button a little
		transition.to( self.bAttack, { xScale = 0.92, yScale = 0.92, time = 100 } )
		
		return true
	-- A release of the punch button isn't necessary for function
	elseif event.phase == "ended" then
		-- enlarge it back
		transition.to( self.bAttack, { xScale = 1, yScale = 1, time = 100 } )

		return false
	end
end

function Controls:jump( event )
	if event.phase == "began" and GameSettings.paused == false then
		
		if( currentGameMode == "multiplayer" and self.player.controlled == true ) then 
			Multiplayer:sendInput("jump", event.phase, event.time )
		end

		self.player.commands = self.player.commands.."j" -- for special skill commands
	
		self.player:specialSkill( nil, "jump" ) -- performs jump if no special skill valid
		
		transition.to( self.bJump, { xScale = 0.92, yScale = 0.92, time = 100 } )

		return true

	elseif event.phase == "ended" then

		transition.to( self.bJump, { xScale = 1, yScale = 1, time = 100 } )

		return false
	end
end

function Controls:reset() -- remove event listeners or else they wil continue after game is over
	--Runtime:removeEventListener( "touch", detectRelease )
end

return Controls

