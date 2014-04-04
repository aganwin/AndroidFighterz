-------------------------------------------------
--
-- update.lua
--
-- Continuous game loop
--
-------------------------------------------------
module(..., package.seeall) -- this line must be included in external modules

local Player = require( "gameplay.Player" )
local Item = require( "gameplay.Item" )
local Ball = require( "gameplay.Ball" )
local Hero = require( "characters.Hero" )
local Hank = require( "characters.Hank" )
local Effects = require( "gameplay.Effects" )
local Ai = require( "ai.Ai" )
local Ball = require( "gameplay.Ball" )
local GameSettings = require( "menus.GameSettings" )
local DebugPanel = require( "helpers.DebugPanel" )
local Multiplayer = require( "multiplayer.Multiplayer" )
local camera = require( "gameplay.Camera" )
local Stage = require( "gameplay.Stage" )
local AudioController = require("gameplay.AudioController")
local Debug = require("helpers.Debug")

gameLoaded = false
local gameOverGroup = display.newGroup()

multiplayerInstance = nil

lastTime = 0  -- probably needs to be global for multiplayer

function updatePosition( status, mpInstance, dirX, dirY )
	p = GameController.controlledPlayer
	
    if( status == "initial" ) then -- initial sync for character positions
   		multiplayerInstance = mpInstance -- because we don't have Multiplayer.lua require'd here, only vice versa
   		-- this will be passed in as "nil" sometimes so don't place outside
   		multiplayerInstance:startPinging() -- pinging should only be done ONCE. if this is put into "determineIfLoaded()" then pinging will be done too much and crash the connection
    	print("start pinging the other person")

   		function determineIfLoaded()
   			-- one player will be behind so the opponentSynced condition needs to check a few times
   			-- the flag turns true only when your opponent's position has been synced (Multiplayer:239)
   			if gameLoaded == "loaded" and mpInstance.opponentSynced == false then
				p:updateInitial( mpInstance.userID )
			elseif mpInstance.opponentSynced == true then
				gameLoaded = "playing"
			end
		end

		timer.performWithDelay( 100, determineIfLoaded, 0 )
    end

    -- SENDING positions

    if( gameLoaded == "playing" and GameController.gameMode == "multiplayer" ) then
		if( lastDirectionX ~= dirX or lastDirectionY ~= dirY ) then 
		   	lastDirectionX = dirX -- horizontal direction to send
		   	lastDirectionY = dirY -- vertical direction
			
			if( status == "started" ) then				
				p.localMoveStartTime = system.getTimer()	
			    hub:publish({
			    	message = {
						action = "movement",
						status = status, -- special field to denote stopped movement
						-- make sure its the right user ID
						timestamp = system.getTimer(),
						started_timestamp = p.localMoveStartTime,
						userID = multiplayerInstance.userID,
						-- send your own position
						directionX = lastDirectionX,
						directionY = lastDirectionY,
						mirror = p.mirror,				
					}
				});			
			elseif( status == "stopped" ) then
				p.localMoveStopTime = system.getTimer()
				if( p.localMoveStopTime > p.localMoveStartTime and p.localMoveStartTime ~= -1 ) then -- if there was a "started" movement message sent before
					p.localMoveDuration = p.localMoveStopTime - p.localMoveStartTime
				else
					p.localMoveDuration = 0
				end

			    hub:publish({
			    	message = {
						action = "movement",
						status = status, -- special field to denote stopped movement
						timestamp = system.getTimer(),
						stopped_timestamp = p.localMoveStopTime,
						moveDuration = p.localMoveDuration,
						userID = multiplayerInstance.userID,
						-- send your own position
						directionX = lastDirectionX,
						directionY = lastDirectionY,
						mirror = p.mirror
					}
				});	

				timer.performWithDelay( p.interpolationDelay, function()
				    hub:publish({
				    	message = {
				    		action = "movement",
							status = "correction",
							userID = multiplayerInstance.userID,
							-- send your own position after the delay and you've actually arrived at the right spot
							finalX = p.sprite.x,
							finalY = p.sprite.y,
							mirror = p.mirror
						}
					});
					print("send message to opponent to extrapolate me to",p.sprite.x,p.sprite.y)
				end)	
			end
		end
	end
end

function update()

	gameOverGroup = display.newGroup( )

	gameLoaded = false
	timeCounter = 0
	Debug.itemsToDrop = 0

	slowDownCount = 0

	-- initialize camera
	camera.group:insert(GameController.stagePicked.bgGroup) 
	for i,p in pairs(GameController.allPlayers) do
		camera.group:insert(p.sprite)
		camera.group:insert(p.group)
	end
	camera.group:insert(GameController.stagePicked.elementsNeededOnTop) 
	camera.player = GameController.controlledPlayer
	camera.rightBoundX = GameController.stagePicked.boundaryRight

	-- load sounds and bgm
	AudioController:loadSounds() -- might want to put this elsewhere
	AudioController:playBGM()

	-- reposition character(+bar) and Item sprites according to y-position
	-- buttons are always in front at the end.
	function layers() 
		for i,p in pairs(GameController.allPlayers) do
			camera.group:remove(p.sprite)
			camera.group:remove(p.group)
			table.insert( GameController.displayLayers, p )
		end

		for k, item in pairs(GameController.currentItems) do
			camera.group:remove(item.sprite)
			table.insert( GameController.displayLayers, item )
		end

		for k, ball in pairs(Ball.listOfBalls) do
			camera.group:remove(ball.sprite)
			table.insert( GameController.displayLayers, ball )
		end

		table.sort( GameController.displayLayers, function(a,b) return ( a.bot < b.bot ) end )

		for k,v in pairs( GameController.displayLayers ) do
			if( v.sprite.toFront ) then v.sprite:toFront() end
			-- if player is holding an item put it in front of the player
			if v.itemHeldFlag == true then v.itemBeingHeld.sprite:toFront() end 
		end

	    -- insert back into scrolling camera in order
	    for i, image in pairs(GameController.displayLayers) do
	    	camera.group:insert(image.sprite)
	    end

	    -- character hp bars should still be in front 
	    for i,p in pairs(GameController.allPlayers) do
			camera.group:insert(p.group)
		end

		for k,v in pairs(Effects.allEffects) do
	    	if( system.getTimer() - v.startTime > 300 ) then -- remove Effects after 300 ms
	    		v:removeSelf()
	    		table.remove( Effects.allEffects, k )
	    	else
	    		v:toFront()
	    	end
	    end

		-- certain stage elements need to appear in front of items/characters
	    GameController.stagePicked.elementsNeededOnTop:toFront()

	    GameController.displayLayers = {}
	end

	GameSettings:draw()
	if Debug.tools == true then DebugPanel:draw() end
	
	-- where the game occurs
	function updateLoop(event)

		if( not GameSettings.paused ) then

			local timeA = system.getTimer()

			GameSettings.pauseTouchDisable.isVisible = false

			-- check if someone has won
			local deadCount = 0
			for i, player in pairs(GameController.myTeam) do
				if player.dead == true then 
					deadCount = deadCount + 1
				end
			end
			if deadCount == #GameController.myTeam and #GameController.myTeam ~= 0 then -- my team has lost
				timer.performWithDelay(2000, function() gameOver("defeat") end)
			end

			local deadCount = 0
			for i, player in pairs(GameController.oppTeam) do
				if player.dead == true then 
					deadCount = deadCount + 1
				end
			end
			if deadCount == #GameController.oppTeam and #GameController.oppTeam ~= 0 then -- my team has won; make sure this isn't some solo game
				timer.performWithDelay(2000, function() gameOver("victory") end)
			end

			for k, item in pairs(GameController.currentItems) do
				if( item.paused ) then
					item.pauseTimeDiff = system.getTimer() - item.pauseTimeStart
					item.airTimer = item.airTimer + item.pauseTimeDiff
					item.pauseTimeStart = 0
					item.paused = false
				elseif( Multiplayer.slowDownFactor ~= 1 ) then
					item.slowDownFactor = Multiplayer.slowDownFactor
				end
			end

			for i,p in pairs(GameController.allPlayers) do
				if( p.sprite ) then
					if( p.sprite.isPlaying == false and p.pauseTimeStart ~= 0 ) then
						p.pauseTimeDiff = system.getTimer() - p.pauseTimeStart
						p.sprite:play()
						p.jumpTimer = p.jumpTimer + p.pauseTimeDiff
						p.flinchStartTime = p.flinchStartTime + p.pauseTimeDiff
						p.throwStartTime = p.throwStartTime + p.pauseTimeDiff
						p.fallenTimeStart = p.fallenTimeStart + p.pauseTimeDiff
						p.getUpTimeStart = p.getUpTimeStart + p.pauseTimeDiff
						p.defTimeStart = p.defTimeStart + p.pauseTimeDiff
						p.atkTimeStart = p.atkTimeStart + p.pauseTimeDiff
						p.punchComboTime = p.punchComboTime + p.pauseTimeDiff
						p.startedSpecial = p.startedSpecial + p.pauseTimeDiff
						p.pauseTimeStart = 0
					elseif( Multiplayer.slowDownFactor ~= 1 ) then
						if( p == GameController.controlledPlayer ) then
							p.slowDownFactor = Multiplayer.slowDownFactor -- Player:Update() takes care of the sprites and jump, etc.
						end
					end
				end
			end		

			-- reorder image layers
			-- if-statement overrides player update because otherwise player's control pad and hp bar will appear on top of gameover info
			if( GameController.gameEnded == false ) then

				layers()

				for b, ball in pairs(Ball.listOfBalls) do
					if( ball.paused == true ) then
						ball.paused = false
						-- no need to implement pause code for physics, just need to pause sprite in listener
						ball.sprite:play()
					end
				end
				
				for i,p in pairs(GameController.allPlayers) do
					if( p.sprite ) then
						p:update()
					end

					-- is this an AI player? Run AI script.
					if( system.getTimer() - GameController.startTime > 1000 ) then
						if( p.isAI == true and p.AIController ) then
							p.AIController:main()
						end
					end
				end

				-- drop items once per X seconds
				if( system.getTimer() - lastTime > 500  ) then
					if( Debug.itemsToDrop > 0 ) then
						Debug.itemsToDrop = Debug.itemsToDrop - 1
						local i = Item.new( "beer" )
						lastTime = system.getTimer()				
					end
				end

				Item:dropCheck() -- takes care of Item physics
				Item:keepVisible()
				Item:detectHit() -- handles whatever goes on when an item hits someone

				Ball:listener()					

				-- scroll camera 
				camera:scroll()	

				--print(system.getTimer()-timeA) -- how long does one frame take
			else
				-- TELL ALL PLAYERS (AND THINGS?) to stop updating or else there will be crashes after Confirming
				-- from game over screen (idles, sequences, etc.)
				for i,p in pairs(GameController.allPlayers) do
					p.stopUpdating = true
				end
			end
		else
			-- paused state: 
			-- 1) timer MUST pause, or else jumps will appear "finished" after resume
			-- 2) put a dim unpressable rectangle over everything
			-- 3) animations must pause
			
			
			GameSettings.pauseTouchDisable.isVisible = true
			GameSettings.pauseTouchDisable:toFront()

			for i,p in pairs(GameController.allPlayers) do
				if( p.sprite.isPlaying ) then
					p.sprite:pause()
					p.pauseTimeStart = system.getTimer()
				end
			end

			for k, item in pairs(GameController.currentItems) do
				if( item.paused == false ) then
					item.paused = true
					item.pauseTimeStart = system.getTimer()
				end
			end

			for b, ball in pairs(Ball.listOfBalls) do
				if( ball.paused == false ) then
					ball.paused = true
					-- no need to implement pause code for physics, just need to pause sprite in listener
					ball.sprite:pause()
				end
			end
		end			
	end
	
	Runtime:addEventListener("enterFrame", updateLoop)

	gameLoaded = "loaded"

	if(Debug.tools == true) then performance.group:toFront() else performance.group.isVisible = false end
end

function removeAllTimers() 
	-- many timer perform with delay functions will try to run after the game loop is ended
	-- e.g. returning back to idle animation. They must be stopped here or there will be a crash
	for id, value in pairs(timer._runlist) do
		print( 'ended a timer')
        timer.cancel(value)
	end
end

function exit()
	removeAllTimers()
	GameController:unload()
	Runtime:removeEventListener( "enterFrame", updateLoop )
	camera:reset()
	GameSettings:disappear()
	gameOverGroup:removeSelf()	
end

function displayGameOverInfo( condition )

	-- show the victory info screen
	local info = display.newImageRect( "images/gameover/"..condition..".png", 1280, 720 )
	info.x = display.contentWidth/2
	info.y = display.contentHeight/2

	gameOverGroup:insert(info)

	-- winner and loser, winners on left
	for i, player in pairs(GameController.myTeam) do
		local charIconPath = "images/mpmenu/"..string.lower(player.name)..".png"
		local charIcon = display.newImageRect( charIconPath, 222, 77 )
		charIcon.x = display.contentWidth*0.12; charIcon.y = display.contentHeight/2
		gameOverGroup:insert(charIcon)
	end

	for i, player in pairs(GameController.oppTeam) do
		local charIconPath = "images/mpmenu/"..string.lower(player.name)..".png"
		local charIcon = display.newImageRect( charIconPath, 222, 77 )
		charIcon.x = display.contentWidth*0.88; charIcon.y = display.contentHeight/2
		gameOverGroup:insert(charIcon)
	end

	local function confirmBtnTouch( event )
		if event.phase == "began" then
			exit()
		end
		return true
	end

	local confirmBtn = display.newImageRect( "images/gameover/confirm.png", 256, 82 ) --display.newRect( 0.375 * display.contentWidth, 0.888 * display.contentHeight, 0.2156 * display.contentWidth, 0.0875 * display.contentHeight )
	confirmBtn:addEventListener( "touch", confirmBtnTouch )
	confirmBtn.x = display.contentWidth/2; confirmBtn.y = display.contentHeight - confirmBtn.contentHeight/2
	gameOverGroup:insert(confirmBtn)

	gameOverGroup:toFront() -- put it in front of everything else

end

function gameOver( condition )
	if( GameController.gameEnded == false ) then
		GameController.gameEnded = true
		-- grey out 
		local greyOut = display.newRect( 0, 0, display.contentWidth, display.contentHeight ) 		
		greyOut:setFillColor( 0,0,0 )
		greyOut.alpha = 0.5

		local gameWon = display.newImageRect( "images/gameover/"..condition.."sign.png", 1186, 342 )
		gameWon.x = display.contentWidth/2
		gameWon.y = display.contentHeight/2
		gameWon:scale(1.2,1.2)

		local transitionTime = 800
		transition.to( gameWon, { time = transitionTime, yScale = 1, xScale = 1, transition = easing.outBounce } )

		-- slide up
		timer.performWithDelay( 1200, function()
			transition.to( gameWon, { time = transitionTime/2, y = display.contentHeight*0.2 } )
		end)
		timer.performWithDelay( 1600, function()
			displayGameOverInfo( condition )
			gameWon:toFront()				
		end)
			
		gameOverGroup:insert(greyOut)
		gameOverGroup:insert(gameWon)
	end
end




