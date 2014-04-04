local CharSelect = require( "menus.CharSelect" )
local Login = require( "menus.Login" )
local Debug = require("helpers.Debug")
local widget = require( "widget" ) -- for scroll view

local ModeSelect = {
	drawn = false
}

function ModeSelect:initialize()
	self.empty = display.newRect( 0, 0, display.contentWidth, display.contentHeight )

	self.bg = display.newImageRect( "images/modemenu/modeselect.png", 2000, 720 )
	self.bg:setReferencePoint( display.TopLeftReferencePoint )
	self.bg.x = 0; self.bg.y = 0
	--self.bg.isFullResolution = true

	self.battleModeBtn = display.newRect( 0.1 * display.contentWidth, 0.056944 * display.contentHeight, 0.25 * display.contentWidth, 0.6555 * display.contentHeight )
	--self.battleModeBtn:setFillColor(0,0,0) -- set back to same color as "empty" background
	self.profileBtn = display.newRect( 0.62 * display.contentWidth, 0.13 * display.contentHeight , 0.121875 * display.contentWidth, 0.313889 * display.contentHeight )
	--self.profileBtn:setFillColor(0,0,0)
	self.lineMode = display.newImage( "images/modemenu/line.png", 0, 0 )
	self.multiplayerMode = display.newImage( "images/modemenu/multiplayermode.png", 0, 0 )
	self.returnBtnL = display.newCircle( 752/1280 * display.contentWidth, 201/720 * display.contentHeight, 70/1280 * display.contentWidth, 65/720 * display.contentHeight )
	self.returnBtnM = display.newCircle( 845/1280 * display.contentWidth, 200/720 * display.contentHeight, 65/1280 * display.contentWidth, 65/720 * display.contentHeight )
	self.greyOut = display.newRect( 0, 0, display.contentWidth, display.contentHeight )

	-- for line pick
	self.onlineBtn = display.newRect( 485/1280 * display.contentWidth, 250/720 * display.contentHeight, 265/1280 * display.contentWidth, 75/720 * display.contentHeight )
	self.offlineBtn = display.newRect( 485/1280 * display.contentWidth, 345/720 * display.contentHeight, 265/1280 * display.contentWidth, 75/720 * display.contentHeight )
	self.onevsoneBtn = display.newRect( 402/1280 * display.contentWidth, 247/720 * display.contentHeight, 352/1280 * display.contentWidth, 80/720 * display.contentHeight )
	self.twovstwoBtn = display.newRect( 402/1280 * display.contentWidth, 353/720 * display.contentHeight, 460/1280 * display.contentWidth, 80/720 * display.contentHeight )
end

function ModeSelect:drawMenu()

	if( self.drawn == false ) then
		self:initialize()
	else
		self:redraw()
	end

	self.empty.isVisible = true

	self.empty:setFillColor( 0,0,0 )
	self.greyOut:setFillColor( 0,0,0 )
	self.greyOut.alpha = 0.5
	
	function pickBattle( event )
		if event.phase == "began" then
			self.profileBtn.isVisible = false
			self.battleModeBtn.isVisible = false
			self.lineMode.isVisible = true
			self.returnBtnL.isVisible = true
			self.greyOut.isVisible = true
			self.onlineBtn.isVisible = true
			self.offlineBtn.isVisible = true
		end
		return true
	end

	function onlineBtnTouch( event )
		if event.phase == "began" then
			self.lineMode.isVisible = false
			self.multiplayerMode.isVisible = true
			self.onlineBtn.isVisible = false
			self.offlineBtn.isVisible = false
			self.returnBtnL.isVisible = false
			self.returnBtnM.isVisible = true

			self.onevsoneBtn.isVisible = true
			self.twovstwoBtn.isVisible = true
		end
		return true
	end

	function offlineBtnTouch( event )
		if event.phase == "began" then
			self.lineMode.isVisible = false
			self.greyOut.isVisible = false
			self.bgGroup.isVisible = false
			self.returnBtnL.isVisible = false
			
			currentGameMode = "single"	-- main.lua variable

			CharSelect:drawMenu( self )
		end
		return true
	end

	-- online modes
	function onevsoneBtnTouch( event )
		if event.phase == "began" then
			self.onevsoneBtn.isVisible = false
			self.twovstwoBtn.isVisible = false

			self.lineMode.isVisible = false
			self.greyOut.isVisible = false
			self.bgGroup.isVisible = false
			self.returnBtnL.isVisible = false

			--self.lineMode.isVisible = false

			currentGameMode = "multiplayer"	-- main.lua variable

			print( currentGameMode )
			CharSelect:drawMenu( self )
		end
		return true
	end
	
	function twovstwoBtnTouch( event )
		if event.phase == "began" then
			self.onevsoneBtn.isVisible = false
			self.twovstwoBtn.isVisible = false

			self.lineMode.isVisible = false
			self.greyOut.isVisible = false
			self.bgGroup.isVisible = false
			self.returnBtnL.isVisible = false

			currentGameMode = "multiplayer"	-- main.lua variable

			CharSelect:drawMenu( self  )
		end
		return true
	end

	function returnBtnTouch( event )
		if event.phase == "began" then
			-- pop up window for offline or online, then go to character selection screen
			self.profileBtn.isVisible = true
			self.battleModeBtn.isVisible = true
			self.lineMode.isVisible = false
			self.returnBtnL.isVisible = false
			self.returnBtnM.isVisible = false
			self.greyOut.isVisible = false
			self.multiplayerMode.isVisible = false
		end
		return true
	end

	function pickProfile( event )
		if event.phase == "began" then
			-- disable other buttons from being pressed
			self.battleModeBtn.isVisible = false
			self.profileBtn.isVisible = false -- yes, you don't want to click login multiple times
			self.greyOut.isVisible = true
			self.loginInstance = Login:popUp( self )
			if( self.loginInstance == nil ) then
				self.bgGroup:insert( self.loginInstance )
			end
		end
		return true
	end

	self.battleModeBtn:addEventListener( "touch", pickBattle )
	self.profileBtn:addEventListener( "touch", pickProfile )
	self.returnBtnL:addEventListener( "touch", returnBtnTouch )
	self.returnBtnM:addEventListener( "touch", returnBtnTouch )
	self.onlineBtn:addEventListener( "touch", onlineBtnTouch )
	self.offlineBtn:addEventListener( "touch", offlineBtnTouch )
	self.onevsoneBtn:addEventListener( "touch", onevsoneBtnTouch )
	self.twovstwoBtn:addEventListener( "touch", twovstwoBtnTouch )

	-- add scrollable view as group
	self.bgGroup = widget.newScrollView
	{
	   left = 0,
	   top = 0,
	   width = display.contentWidth, 
	   height = display.contentHeight,
	   --scrollWidth = self.bg.contentWidth,
	   scrollHeight = self.bg.contentHeight,
	   verticalScrollDisabled = true,
	   isBounceEnabled = false,
	   listener = scrollListener,
	   maxVelocity = 2.0, -- default is 2.0
	   friction = 0.972, -- default as recommended by http://www.coronalabs.com/blog/2013/03/05/new-widgets-part-3/
	   noLines = false, -- ? false
	}
	--self.bgGroup:setScrollWidth( 2000 )
	
	self.bgGroup:insert( self.returnBtnL )	
	self.bgGroup:insert( self.returnBtnM )	
	self.bgGroup:insert( self.onlineBtn )
	self.bgGroup:insert( self.offlineBtn )
	self.bgGroup:insert( self.onevsoneBtn )
	self.bgGroup:insert( self.twovstwoBtn )
	self.bgGroup:insert( self.empty )

	self.bgGroup:insert( self.battleModeBtn )
	self.bgGroup:insert( self.profileBtn )
	self.bgGroup:insert( self.bg )

	
	self.bgGroup:insert( self.greyOut )
	self.bgGroup:insert( self.lineMode )
	self.bgGroup:insert( self.multiplayerMode )

	self.bgGroup.isVisible = false

	self.lineMode.isVisible = false
	self.multiplayerMode.isVisible = false
	self.returnBtnL.isVisible = false
	self.returnBtnM.isVisible = false
	self.onlineBtn.isVisible = false
	self.offlineBtn.isVisible = false
	self.greyOut.isVisible = false
	self.onevsoneBtn.isVisible = false
	self.twovstwoBtn.isVisible = false

	transition.dissolve( self.empty, self.bgGroup, 500, 100 ) -- src, dst, duration of dissolve, delay before dissolve starts
	
	if(Debug.tools == true) then performance.group:toFront() end

end

function ModeSelect:reenable()

	self.bgGroup.isVisible = true
	-- you left ModeSelect with profile and battle mode buttons NON visible
	-- restore them
	self.profileBtn.isVisible = true
	self.battleModeBtn.isVisible = true

	-- revert back to original settings
	self.lineMode.isVisible = false
	self.multiplayerMode.isVisible = false
	self.returnBtnL.isVisible = false
	self.returnBtnM.isVisible = false
	self.onlineBtn.isVisible = false
	self.offlineBtn.isVisible = false
	self.greyOut.isVisible = false
end

function ModeSelect:redraw()
	self.bgGroup.isVisible = false
	self.profileBtn.isVisible = true
	self.battleModeBtn.isVisible = true
	transition.dissolve( self.empty, self.bgGroup, 500, 100 ) -- src, dst, duration of dissolve, delay before dissolve starts
end

return ModeSelect


