local Player = require( "gameplay.Player" )
local TeamSelect = require( "menus.TeamSelect" )
local Multiplayer = require( "multiplayer.Multiplayer" )
local Debug = require("helpers.Debug")

local CharSelect = {
	drawn = false,
	chosenChar = nil
}

-- Logic:
-- Notes:
-- don't insert "empty" into bgGroup
-- enable and disable buttons according to what is present. Back button should not be clickable when overlay is present

function CharSelect:initialize()
	self.bg = display.newImage( "images/charmenu/menu.png", 0, 0 )
	self.empty = display.newRect( 0, 0, display.contentWidth, display.contentHeight )
	
	-- Available characters, selected using invisible rectangle buttons
	self.heroBtn = display.newRect( 0, 0, 0.1664 * display.contentWidth, 0.79444 * display.contentHeight )
	self.hankBtn = display.newRect( 0.1664 * display.contentWidth, 0, 0.1664 * display.contentWidth, 0.79444 * display.contentHeight )
	-- Available characters additional information as overlay windows
	self.heroOverlayInfo = display.newImage( "images/charmenu/hero.png", 0, 0 )
	self.hankOverlayInfo = display.newImage( "images/charmenu/hank.png", 0, 0 )
	-- for overlay windows: the return (X) button and the confirm button (listeners added later)
	self.returnBtn = display.newCircle( 0.949 * display.contentWidth, 0.0625 * display.contentHeight, 0.03125 * display.contentWidth, 0.0555 * display.contentHeight )
	self.confirmBtn = display.newRect( 0.375 * display.contentWidth, 0.888 * display.contentHeight, 0.2156 * display.contentWidth, 0.0875 * display.contentHeight )
	self.backBtn = display.newRect( display.contentWidth * 1050/1280, 0, display.contentWidth * 230/1280, display.contentHeight * 100/720 )
	self.bgGroup = display.newGroup()

	self.greyOut = display.newRect( 0, 0, display.contentWidth, display.contentHeight )
	self.greyOut:setFillColor( 0,0,0 )
	self.greyOut.alpha = 0.5
	self.greyOut.isVisible = false
end

function CharSelect:drawMenu( previousMenu )

	-- HIDE OTHER MENUS
	if( self.drawn == false ) then
		self:initialize()
	else
		self.bgGroup.isVisible = true
		return
	end
			
	function heroBtnTouch( event )
		if event.phase == "began" then
			self.chosenChar = "Hero"

			local function heroOverlay()				
				self.heroOverlayInfo.isVisible = false
				self.heroOverlayInfo.isVisible = true

				--greyout darkens out the background
				self.greyOut.isVisible = true

				self.heroOverlayInfo:scale(1.2,1.2)
				transition.to( self.heroOverlayInfo, { time = 300, yScale = 1, xScale = 1, transition = easing.outBounce } )
				self.heroOverlayInfo:toFront()
				self.returnBtn.isVisible = true
				self.confirmBtn.isVisible = true	
				self.returnBtn:toBack()
				self.confirmBtn:toBack()		
				-- disable character selection buttons
				self.heroBtn.isVisible = false
				self.hankBtn.isVisible = false
				self.backBtn.isVisible = false				
			end
			heroOverlay()
		end
		return true
	end

	function hankBtnTouch( event )
		if event.phase == "began" then
			self.chosenChar = "Hank"

			local function hankOverlay()				
				self.hankOverlayInfo.isVisible = false
				self.hankOverlayInfo.isVisible = true

				--greyout darkens out the background
				self.greyOut.isVisible = true

				self.hankOverlayInfo:scale(1.2,1.2)
				self.hankOverlayInfo.alpha = 0 
				transition.to( self.hankOverlayInfo, { time = 300, yScale = 1, xScale = 1, alpha = 1, transition = easing.outBounce } )
				self.hankOverlayInfo:toFront()
				self.returnBtn.isVisible = true
				self.confirmBtn.isVisible = true	
				self.returnBtn:toBack()
				self.confirmBtn:toBack()		
				-- disable character selection buttons
				self.heroBtn.isVisible = false
				self.hankBtn.isVisible = false
				self.backBtn.isVisible = false
			end
			hankOverlay()
		end
		return true
	end

	function backBtnTouch( event )
		if event.phase == "began" then
			self:undrawMenu()
			previousMenu:reenable()
			previousMenu:redraw()
		end
		return true
	end
	
	

	if( display.contentHeight ~= 720 ) then
		self.bgGroup:scale( display.contentHeight / 720, display.contentHeight / 720 )
	end	

	if( display.contentWidth ~= 1280 ) then
		self.heroOverlayInfo:scale( display.contentWidth/1280, display.contentWidth/1280 )
		self.heroOverlayInfo.x = display.contentWidth/2
		self.heroOverlayInfo.y = display.contentHeight/2

		self.hankOverlayInfo:scale( display.contentWidth/1280, display.contentWidth/1280 )
		self.hankOverlayInfo.x = display.contentWidth/2
		self.hankOverlayInfo.y = display.contentHeight/2
	end	
	
	function confirmBtnTouch( event )
		if event.phase == "began" then
			if( currentGameMode == "single" ) then
				self:undrawMenu()
				TeamSelect:drawMenu( self )
			elseif( currentGameMode == "multiplayer" ) then
				self:undrawMenu()
				Multiplayer:drawMenu( self, self.chosenChar )
			end
		end
		return true
	end

	function returnBtnTouch( event )
		if event.phase == "began" then
			self.heroOverlayInfo.isVisible = false
			self.hankOverlayInfo.isVisible = false
			self.returnBtn.isVisible = false
			self.confirmBtn.isVisible = false
							
			-- re-enable character selection buttons
			self.heroBtn.isVisible = true
			self.hankBtn.isVisible = true
			self.backBtn.isVisible = true

			-- turn off grey out
			self.greyOut.isVisible = false
		end
		return true
	end

	if( self.drawn == false ) then
		self.empty:setFillColor( 0, 0, 0 )

		self.bgGroup:insert( self.hankBtn )
		self.bgGroup:insert( self.heroBtn )
		self.bgGroup:insert( self.backBtn )
		self.bgGroup:insert( self.bg )
		self.bgGroup:insert( self.greyOut )
		self.bgGroup:insert( self.heroOverlayInfo )
		self.bgGroup:insert( self.hankOverlayInfo )
		self.bgGroup:insert( self.confirmBtn )
		self.bgGroup:insert( self.returnBtn )
		self.bgGroup.isVisible = false

		self.heroOverlayInfo.isVisible = false
		self.hankOverlayInfo.isVisible = false

		self.confirmBtn.isVisible = false
		self.returnBtn.isVisible = false	

		self.heroBtn:addEventListener( "touch", heroBtnTouch )
		self.hankBtn:addEventListener( "touch", hankBtnTouch )
		self.backBtn:addEventListener( "touch", backBtnTouch )
		self.returnBtn:addEventListener( "touch", returnBtnTouch )
		self.confirmBtn:addEventListener( "touch", confirmBtnTouch )

		self.drawn = true
	end

	transition.dissolve( self.empty, self.bgGroup, 500, 100 ) -- src, dst, duration of dissolve, delay before dissolve starts

	if(Debug.tools == true) then performance.group:toFront() end
	
end

function CharSelect:undrawMenu()
	-- have to remove all event listeners manually
	self.bgGroup.isVisible = false
end

function CharSelect:redrawMenu()
	self.bgGroup.isVisible = true
end

return CharSelect


