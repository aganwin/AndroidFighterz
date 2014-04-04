local Player = require( "gameplay.Player" )
local Debug = require("helpers.Debug")

local TeamSelect = {
	drawn = false,
	availableCharacters = { "Closed", "Hero", "Hank" },
	chosenChar = nil, -- passed from previous menu in
	allyIndex = 1, 
	enemyIndex1 = 1, 
	enemyIndex2 = 1, -- corresponds to "Closed" if '1' were to be an enum type of availableCharacters
}

-- Notes:
-- constructor and destructor for the menus
-- every visual element is part of a display group for easy removal
-- clean entry and exit, ahhhhahahahhah

function TeamSelect:initialize()
	self.empty = display.newRect( 0, 0, display.contentWidth, display.contentHeight )
	self.bg = display.newImageRect( "images/teamselect/bg.png", 1280, 720 )
	self.bg:setReferencePoint( display.TopLeftReferencePoint )
	self.bg.x = 0; self.bg.y = 0

	self.bgGroup = display.newGroup()

	self.returnBtn = display.newImageRect( "images/teamselect/back.png", 184, 78 ) --display.newCircle( 0.949 * display.contentWidth, 0.0625 * display.contentHeight, 0.03125 * display.contentWidth, 0.0555 * display.contentHeight )
	self.confirmBtn = display.newImageRect( "images/teamselect/confirm.png", 256, 82 ) --display.newRect( 0.375 * display.contentWidth, 0.888 * display.contentHeight, 0.2156 * display.contentWidth, 0.0875 * display.contentHeight )
	
	self.returnBtn:setReferencePoint( display.CenterReferencePoint )
	self.returnBtn.x = display.contentWidth - self.returnBtn.contentWidth/2; self.returnBtn.y = self.returnBtn.contentHeight/2

	self.confirmBtn:setReferencePoint( display.CenterReferencePoint )
	self.confirmBtn.x = display.contentWidth/2; self.confirmBtn.y = display.contentHeight - self.confirmBtn.contentHeight/2

end

function TeamSelect:setPosition( slot, image ) -- ally = 1, 2; enemy = 3, 4
	if( slot == 1 ) then
		image.x = display.contentWidth * 106/1920
		image.y = display.contentHeight * 38/1080
	elseif( slot == 2 ) then
		image.x = display.contentWidth * 106/1920
		image.y = display.contentHeight * 510/1080
	elseif( slot == 3 ) then
		image.x = display.contentWidth * 1024/1920
		image.y = display.contentHeight * 38/1080
	elseif( slot == 4 ) then
		image.x = display.contentWidth * 1024/1920
		image.y = display.contentHeight * 510/1080
	end
end 

function TeamSelect:drawMenu( previousMenu )

	if( self.drawn == false ) then
		self:initialize()
		self.drawn = true
	else
		self.bgGroup.isVisible = true
		return
	end

	self.chosenChar = previousMenu.chosenChar

	--

	self.empty:setFillColor(0,0,0)
	
	-- 1. insert into bg group	
	self.bgGroup:insert( self.bg )
	self.bgGroup:insert( self.returnBtn )
	self.bgGroup:insert( self.confirmBtn )	
	self.bgGroup.isVisible = false

	-- 2. set buttons to be invisible initially

	-- 3. do the transition effect
	transition.dissolve( self.empty, self.bgGroup, 500, 100 ) -- src, dst, duration of dissolve, delay before dissolve starts

	-- show player button based on picked characters
	if( previousMenu.chosenChar == "Hero" ) then
		selfBtn = display.newImageRect( "images/teamselect/hero.png", 550, 328 )
		self.bgGroup:insert( selfBtn )
	elseif( previousMenu.chosenChar == "Hank" ) then
		selfBtn = display.newImageRect( "images/teamselect/hank.png", 550, 328 )
		self.bgGroup:insert( selfBtn )
	end

	selfBtn:setReferencePoint( display.TopLeftReferencePoint )
	self:setPosition( 1, selfBtn )

	-- show ally and enemy players as closed by default
	self.ally = self.availableCharacters[self.allyIndex]
	self.enemy1 = self.availableCharacters[self.enemyIndex1]
	self.enemy2 = self.availableCharacters[self.enemyIndex2]

	local allyBtn = display.newImageRect( "images/teamselect/closed.png", 550, 328 )
	local enemyBtn1 = display.newImageRect( "images/teamselect/closed.png", 550, 328 )
	local enemyBtn2 = display.newImageRect( "images/teamselect/closed.png", 550, 328 )

	allyBtn:setReferencePoint( display.TopLeftReferencePoint ); enemyBtn1:setReferencePoint( display.TopLeftReferencePoint ); enemyBtn2:setReferencePoint( display.TopLeftReferencePoint )
	self:setPosition( 2, allyBtn ); self:setPosition( 3, enemyBtn1 ); self:setPosition( 4, enemyBtn2 )

	self.bgGroup:insert( allyBtn )
	self.bgGroup:insert( enemyBtn1 )
	self.bgGroup:insert( enemyBtn2 )

	function allyBtnTouch( event )
		if event.phase == "began" then
			self.allyIndex = self.allyIndex + 1
			if( self.allyIndex > #self.availableCharacters ) then
				self.allyIndex = 1
			end
			self.ally = self.availableCharacters[self.allyIndex]

			-- remove old button
			allyBtn:removeSelf()
			local path = "images/teamselect/"..string.lower(self.ally)..".png" -- "images/teamselect/hank.png" instead of Hank.png
			allyBtn = display.newImageRect( path, 550, 328 )
			allyBtn:setReferencePoint( display.TopLeftReferencePoint )
			self:setPosition( 2, allyBtn )
			allyBtn:addEventListener( "touch", allyBtnTouch ) -- this is fucking weird, add event listener within an event listener...
			self.bgGroup:insert( allyBtn )

			self.returnBtn:toFront()
			self.confirmBtn:toFront()
		end
		return true
	end

	function enemyBtnTouch1( event )
		if event.phase == "began" then
			self.enemyIndex1 = self.enemyIndex1 + 1
			if( self.enemyIndex1 > #self.availableCharacters ) then
				self.enemyIndex1 = 1
			end
			self.enemy1 = self.availableCharacters[self.enemyIndex1]

			-- remove old button
			enemyBtn1:removeSelf()
			local path = "images/teamselect/"..string.lower(self.enemy1)..".png" -- "images/teamselect/hank.png" instead of Hank.png
			enemyBtn1 = display.newImageRect( path, 550, 328 )
			enemyBtn1:setReferencePoint( display.TopLeftReferencePoint )
			self:setPosition( 3, enemyBtn1 )
			enemyBtn1:addEventListener( "touch", enemyBtnTouch1 ) -- this is fucking weird, add event listener within an event listener...
			self.bgGroup:insert( enemyBtn1 )

			self.returnBtn:toFront()
			self.confirmBtn:toFront()
		end
		return true
	end

	function enemyBtnTouch2( event )
		if event.phase == "began" then
			self.enemyIndex2 = self.enemyIndex2 + 1
			if( self.enemyIndex2 > #self.availableCharacters ) then
				self.enemyIndex2 = 1
			end
			self.enemy2 = self.availableCharacters[self.enemyIndex2]

			-- remove old button
			enemyBtn2:removeSelf()
			local path = "images/teamselect/"..string.lower(self.enemy2)..".png" -- "images/teamselect/hank.png" instead of Hank.png
			enemyBtn2 = display.newImageRect( path, 550, 328 )
			enemyBtn2:setReferencePoint( display.TopLeftReferencePoint )
			self:setPosition( 4, enemyBtn2 )
			enemyBtn2:addEventListener( "touch", enemyBtnTouch2 ) -- this is fucking weird, add event listener within an event listener...
			self.bgGroup:insert( enemyBtn2 )

			self.returnBtn:toFront()
			self.confirmBtn:toFront()
		end
		return true
	end

	allyBtn:addEventListener( "touch", allyBtnTouch )
	enemyBtn1:addEventListener( "touch", enemyBtnTouch1 )
	enemyBtn2:addEventListener( "touch", enemyBtnTouch2 )

	-- return and confirm buttons

	function confirmBtnTouch( event )
		if event.phase == "began" then
			self:startGame()
			print("START GAME PRESSED")
		end
		return true
	end

	function returnBtnTouch( event )
		if event.phase == "began" then
			self:undrawMenu()
			previousMenu:redrawMenu()
		end
		return true
	end

	self.confirmBtn:addEventListener( "touch", confirmBtnTouch )
	self.returnBtn:addEventListener( "touch", returnBtnTouch )
	
	self.returnBtn:toFront()
	self.confirmBtn:toFront()
	
	if(Debug.tools == true) then performance.group:toFront() end
	
end

function TeamSelect:undrawMenu()
	self.bgGroup.isVisible = false
end

function TeamSelect:startGame()

	self:undrawMenu()

	if( currentGameMode == "single" ) then
		table.insert( GameController.allPlayers, Player.new( self.chosenChar, 1, true, false, 1 ) ) -- name, teamNum, controlled, isAI, id
    	if( self.ally ~= "Closed" ) then
    		table.insert( GameController.allPlayers, Player.new( self.ally, 1, false, true, 2 ) )
    	end
    	if( self.enemy1 ~= "Closed" ) then
    		table.insert( GameController.allPlayers, Player.new( self.enemy1, 2, false, true, 3 ) )
    	end
    	if( self.enemy2 ~= "Closed" ) then
    		table.insert( GameController.allPlayers, Player.new( self.enemy2, 2, false, true, 4 ) )
    	end

		GameController:load("single")
	end
end

return TeamSelect


