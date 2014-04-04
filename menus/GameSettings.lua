-- GameSettings.lua
-- can be accessed in-game

-- draw() is activated once
-- the rest is just visible or not
local update = require( "gameplay.update" )
local AudioController = require( "gameplay.AudioController" )

local GameSettings = {
	menu = display.newGroup(),
	paused = false,
	alreadyDrawn = false,
}

function GameSettings:appear()
	-- slide out animation
	if( self.menu.isVisible ) then
		self.menu.isVisible = false
	else
		self.menu.isVisible = true
		self.menu:toFront()
		self.settingsBtn:toFront()
	end
end

function GameSettings:disappear()
	self.menu.isVisible = false
	self.settingsBtn.isVisible = false
end

function GameSettings:draw()

	if( self.alreadyDrawn == false ) then
		
		self.pauseTouchDisable = display.newRect( 0, 0, display.contentWidth, display.contentHeight ) 		
		self.pauseTouchDisable:setFillColor( 0,0,0 )
		self.pauseTouchDisable.alpha = 0.5
		self.pauseTouchDisable.isVisible = false
	
		-- settings bg
		--[[
		self.bg = display.newImage( "images/gamesettings/bg.png" )
		self.bg.x = display.contentWidth * 0.9
		self.bg.y = display.contentHeight * 0.1
		]]--

		-- the settings button itself!
		self.settingsBtn = display.newImage( "images/gamesettings/settings.png" )
		self.settingsBtn.x = display.contentWidth * 0.95
		self.settingsBtn.y = display.contentHeight * 0.05

		local function drawMenu(event)
			if( event.phase == "began" ) then
				self:appear()
				return true
			end
		end

		self.settingsBtn:addEventListener( "touch", drawMenu )
		
		-- main menu / mode screen button
		local returnBtn = display.newImage( "images/gamesettings/return.png" )
		-- pause button (offline only)
		local pauseBtn = display.newImage( "images/gamesettings/pause.png" )
		-- sound off
		local soundBtn = {
			imageOn = display.newImage( "images/gamesettings/soundon.png" ),
			imageOff = display.newImage( "images/gamesettings/soundoff.png" )
		}
		soundBtn.imageOff.isVisible = false
		-- when pressed, uses another image for soundoff

		returnBtn.x = display.contentWidth * 0.9
		returnBtn.y = display.contentHeight * 0.05

		pauseBtn.x = display.contentWidth * 0.85
		pauseBtn.y = display.contentHeight * 0.05

		soundBtn.imageOn.x = display.contentWidth * 0.8
		soundBtn.imageOn.y = display.contentHeight * 0.05
		soundBtn.imageOff.x = display.contentWidth * 0.8
		soundBtn.imageOff.y = display.contentHeight * 0.05


		function returnBtn:touch( event )
			if event.phase == "began" then
				update.exit()
				return true
			end
		end

		returnBtn:addEventListener( "touch", returnBtn )

		function soundBtn:touch( event )
			AudioController:soundOnOff()
			if( AudioController.mute == true ) then
				soundBtn.imageOn.isVisible = false
				soundBtn.imageOff.isVisible = true 
			else
				soundBtn.imageOn.isVisible = true
				soundBtn.imageOff.isVisible = false 
			end	
		end

		soundBtn.imageOn:addEventListener( "touch", soundBtn )
		soundBtn.imageOff:addEventListener( "touch", soundBtn )

		function pauseBtn:touch( event )
			if event.phase == "began" then
				if( self.paused ) then
					self.paused = false
					--pauseBtn.alpha = 0.5
					--system.setIdleTimer( enabled )
				else
					self.paused = true
					--pauseBtn.alpha = 1
					pauseBtn:toFront()
					--system.setIdleTimer( disabled )
				end		
				return true
			end
		end

		pauseBtn:addEventListener( "touch", pauseBtn )

		--self.menu:insert( self.bg )
		self.menu:insert( returnBtn )
		self.menu:insert( pauseBtn )
		self.menu:insert( soundBtn.imageOn )
		self.menu:insert( soundBtn.imageOff )

		--self.menu.alpha = 0.5
		self.menu.isVisible = false

		-- for after the first load
		self.alreadyDrawn = true

	else
		-- just move the dinky button up to front again XD
		self.settingsBtn.isVisible = true
		self.settingsBtn:toFront()
	end

end

return GameSettings

