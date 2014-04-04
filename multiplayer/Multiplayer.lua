-----------------------
-- Notes:
-- Fix up line 333 (checkMovement() uses magic number to determine how long it should be until ping should be consider invalid)
--
-----------------------

local Player = require( "gameplay.Player" )
local update = require( "gameplay.update" )

local Multiplayer = {
	userID = nil,
	newGameID = nil,
	playersFound = {},
	selectedPlayer = nil,
	latency = 0,
	latencies = {},
	latencySum = 0,
	latencyCount = 0,
	requestedOpponent = nil,

	-- make sure acceptAndLoad() occurs only once
	requesting = false,
	accepted = false,
	finding = false,

	opponentSynced = false,	

	drawn = false,

	searchForPlayerTimer = nil,

	-- local buffer for storing other player's states
	buffer = {},

	extrapolation = true,

	-- for slowing down game time kind of like LF2's frame-rate-decrease for multiplayer
	slowDownGameTime = false, -- turned off if false
	slowDownFactor = 1, -- applied to everything in update loop. 

	lastPressedButton = "",
	lastPressedTime = 0,
	adjustTime = 0,
	endTime = 0,
}

function Multiplayer:initialize()

	self.bg = display.newImageRect( "images/mpmenu/bg.png", 1280, 720 )
	self.bg:setReferencePoint( display.TopLeftReferencePoint )
	self.bg.x = 0; self.bg.y = 0

	self.returnBtn = display.newImageRect( "images/mpmenu/back.png", 184, 78 ) --display.newCircle( 0.949 * display.contentWidth, 0.0625 * display.contentHeight, 0.03125 * display.contentWidth, 0.0555 * display.contentHeight )
	self.returnBtn:setReferencePoint( display.CenterReferencePoint )
	self.returnBtn.x = display.contentWidth - self.returnBtn.contentWidth/2
	self.returnBtn.y = self.returnBtn.contentHeight/2

	function returnBtnTouch( event )
		if event.phase == "began" then
			self:undraw()
			if( self.previousMenu.redrawMenu ) then
				self.previousMenu:redrawMenu()
			else
				self.previousMenu.isVisible = true
			end
		end
		return true
	end
	self.returnBtn:addEventListener( "touch", returnBtnTouch )

	self.queueBtn = display.newImage( "images/mpmenu/findgame.png", 527, 183) --widget.newButton( queueAttr )
	self.queueBtn:setReferencePoint( display.centerReferencePoint )
	self.queueBtn.x = display.contentWidth/2
	self.queueBtn.y = display.contentHeight/2

	-- not a button
	self.searching = display.newImage( "images/mpmenu/searching.png", 458, 140) --widget.newButton( queueAttr )
	self.searching:setReferencePoint( display.TopLeftReferencePoint )
	self.searching.x = display.contentWidth*412/1280
	self.searching.y = display.contentHeight*100/720

	self.matchFound = display.newImageRect( "images/mpmenu/connected.png", 457, 139)
	self.matchFound:setReferencePoint( display.TopLeftReferencePoint )
	self.matchFound.x = display.contentWidth*412/1280
	self.matchFound.y = display.contentHeight*100/720

	self.fightBtn = display.newImageRect( "images/mpmenu/fight.png", 499, 148 ) --widget.newButton( {width = 300, height = 100, label = "Start Game"} )
	self.fightBtn:setReferencePoint( display.centerReferencePoint )
	self.fightBtn.x = display.contentWidth/2
	self.fightBtn.y = display.contentHeight/2

	self.stopFindingBtn = display.newImageRect( "images/mpmenu/stopfinding.png", 504, 154)
	self.stopFindingBtn:setReferencePoint( display.centerReferencePoint )
	self.stopFindingBtn.x = display.contentWidth/2
	self.stopFindingBtn.y = display.contentHeight/2

	self.playerText = display.newText( "", display.contentWidth*40/1280, display.contentHeight*450/720, display.contentWidth*340/1280, display.contentHeight*340/720, "Helvetica", 30 )
	self.playerText:setTextColor( 0,0,0 )
	--[[
	self.searchText = display.newText( "No players found", 0, 0, "Comic Sans MS", 40 )
	self.searchText.x = display.contentWidth/2
	self.searchText.y = display.contentHeight/2
	]]--

	self.bgGroup = display.newGroup()
	self.bgGroup:insert(self.bg)
	self.bgGroup:insert(self.returnBtn)
	self.bgGroup:insert(self.queueBtn)
	self.bgGroup:insert(self.searching)
	self.bgGroup:insert(self.matchFound)
	self.bgGroup:insert(self.fightBtn)
	self.bgGroup:insert(self.stopFindingBtn)
	self.bgGroup:insert(self.playerText)
end

-- functions placed in the order that the multiplayer system flows
function Multiplayer:drawMenu( previousMenu, chosenChar )
	
	self.previousMenu = previousMenu

	currentGameMode = "multiplayer"

	if( self.drawn == false ) then
		self:initialize()
		self.drawn = true
	else
		self.bgGroup.isVisible = true
	end

	self.userID = userName .. math.random(1, 1000) -- if error, do not declare as 0
	self.chosenChar = chosenChar

	-- put stuff in your player window like text and pictures
	self.playerText.text = "Username: "..self.userID.."\nW/L: ".."\nCharacter: "..self.chosenChar

	local chosenCharIconPath = "images/mpmenu/"..string.lower(self.chosenChar)..".png"
	print( chosenCharIconPath)
	self.chosenCharIcon = display.newImageRect( self.bgGroup, chosenCharIconPath, 222, 77 )
	self.chosenCharIcon:setReferencePoint( display.CenterReferencePoint )
	self.chosenCharIcon.x = display.contentWidth*200/1280
	self.chosenCharIcon.y = display.contentHeight*400/720

	if DebugInstance.multiplayer then
		print( "Welcome to Multiplayer, I chose "..self.chosenChar )
	end

	local function goToQueue( event )
		if( event.phase == "began" ) then
			if( self.finding ) then
				self:dequeue()
				self.finding = false
				self.stopFindingBtn.isVisible = false
				self.queueBtn.isVisible = true
				self.searching.isVisible = false
			else
				self:queue()
				self.finding = true
				self.stopFindingBtn.isVisible = true
				self.queueBtn.isVisible = false
				self.searching.isVisible = true
			end			
		end
	end

	self.queueBtn:addEventListener( "touch", goToQueue )

	self.searching.isVisible = false
	self.matchFound.isVisible = false
	self.stopFindingBtn.isVisible = false
	self.stopFindingBtn:addEventListener( "touch", goToQueue )
	self.fightBtn.isVisible = false	

	-- Function to handle button events
	local function handleButtonEvent( event )
		local phase = event.phase 

		if "ended" == phase then
			print( "You pressed and released a button!" )
		end
	end
end

function Multiplayer:undraw()
	self.bgGroup.isVisible = false
end

function Multiplayer:queue()	
	
	if DebugInstance.multiplayer then 
		print( "My ID = "..self.userID ) 
	end

	self.searchForPlayerTimer = timer.performWithDelay( 500, function()
		self:searchForPlayers()
	end, 0 ) -- search indefinitely every 500 ms while on this screen and until match has started
	
	self:startPinging( 500 ) -- check pings of other users in lobby

	hub:subscribe({
			channel = "lobby";  
			callback = function(message)

			    -- pinging other users in lobby - THIS CODE DIFFERENTIATES A BIT FROM THE IN-GAME PINGING*
			    if(message.action == "ping") then
			        if(message.userID ~= self.userID) then -- if it came from some other guy in lobby
						hub:publish({
							message = {
								action  =  "pong",
								userID = self.userID,
								chosenChar = self.chosenChar,
								original_timestamp = message.timestamp,
								timestamp = system.getTimer()
							}
						});
					end
				end

				if( message.action == "pong" ) then 
					if( message.userID ~= self.userID ) then
						if(#self.playersFound == 0) then
							table.insert(self.playersFound, { id = message.userID, latencies = {}, latencyCount = 0, latencySum = 0, latency = 0 })
						else
							for p, player in pairs(self.playersFound) do
								if message.userID ~= player.id and message.userID ~= self.userID then
									table.insert(self.playersFound, { id = message.userID, latencies = {}, latencyCount = 0, latencySum = 0, latency = 0})
								end
							end

							for p, player in pairs(self.playersFound) do
								table.insert( player.latencies,(system.getTimer() - message.original_timestamp)/2 );
								for i,lat in ipairs(player.latencies) do
									if( player.latencyCount >= 5 ) then
										player.latencySum = 0
										player.latencyCount = 0
									end
									player.latencySum = player.latencySum+lat;
									player.latencyCount = player.latencyCount+1;
									player.latency = math.round(player.latencySum/player.latencyCount)

									if( self.oppText ) then
										self.oppText.text = "Username: "..self.userID.."\nW/L: ".."\nCharacter: "..self.chosenChar.."\nLatency: "..player.latency.."ms"
									end
								end
								
								if( player.latency ) then self:showPlayersFound( message.chosenChar ) end-- repeatedly update players found table, but to the user there's one match to choose from at a time
							end
						end					
					end
				end				
				
				if( message.action == "requesting" ) then
		           	if( message.userID == self.requestedOpponent ) then 
		           		self:acceptAndLoad()
		           		if DebugInstance.multiplayer then print( "Accept and load" ) end 
		           	end
		        elseif( message.action == "accepted" ) then
		           	if( message.userID == self.requestedOpponent ) then
		            	-- opponent has ran acceptAndLoad() but we need to send him back the same message so he can start the game as well
		            	if( not accepted ) then
			            	hub:publish({
								message = {
									action  =  "accepted",
									id = crypto.digest( crypto.md5, system.getTimer()  ..  math.random()   ),
									timestamp = system.getTimer(),
									userID = self.userID,
									newGameID = message.newGameID,
									chosenChar = self.chosenChar,
								}
							});

							-- insert characters here and start the game.
							table.insert( GameController.allPlayers, Player.new( self.chosenChar, 0, true, false, self.userID ) ) -- name, teamNum, controlled, isAI, id
							table.insert( GameController.allPlayers, Player.new( message.chosenChar, 0, false, false, message.userID ) )
							self:undraw()
							GameController:load( "multiplayer" )
							hub:unsubscribe()
				            self:newGame( message.newGameID ) -- might BUG
				        else
							-- insert characters here and start the game.
							table.insert( GameController.allPlayers, Player.new( self.chosenChar, 0, true, false, self.userID ) ) -- name, teamNum, controlled, isAI, id
							table.insert( GameController.allPlayers, Player.new( message.chosenChar, 0, false, false, message.userID ) )
							self:undraw()
							GameController:load( "multiplayer" )
							hub:unsubscribe()
			            	self:newGame( message.newGameID ) -- might BUG
						end
		            end;
		        end;
		    end;
	    });
	end

	function Multiplayer:dequeue()
		timer.cancel(self.searchForPlayerTimer)
	end

	function Multiplayer:searchForPlayers()
		hub:publish({
			message = {
			action  =  "searching",
			id = crypto.digest( crypto.md5, system.getTimer()  ..  math.random()   ),
			timestamp = system.getTimer(),
			userID = self.userID,
			chosenChar = self.chosenChar,
		}
		});	
	end

function Multiplayer:requestGame( event )
	if event.phase == "began" then
		if( self.requesting == false ) then
			self.requestedOpponent = self.playersFound[self.selectedPlayer].id -- set global variable to opponent found
	   		if DebugInstance.multiplayer then print( "Requesting "..self.requestedOpponent.." for a game" ) end -- DEBUG
			-- send message to wait for game acceptance
			hub:publish({
				message = {
					action = "requesting",
					userID = self.userID
				}
			});

			self.requesting = true
		end
		return true
	end
end

function Multiplayer:showPlayersFound( oppChar )

	if #self.playersFound > 0 then -- if we found any players, automatically pair with first player found (closest!)
		for p, player in pairs(self.playersFound) do
			--self.searchText.text = "You are matched with: "..self.playersFound[1].id.."\nPing = "..tostring(self.playersFound[1].latency).."\n# of other players found = "..tostring(#self.playersFound-1)
			
			if( self.selectedPlayer == nil ) then
				-- display this only once because this function is refreshed continually
				local oppCharIconPath = "images/mpmenu/"..string.lower(oppChar)..".png"
				print( oppCharIconPath)
				self.oppCharIcon = display.newImageRect( self.bgGroup, oppCharIconPath, 222, 77 )
				self.oppCharIcon:setReferencePoint( display.CenterReferencePoint )
				self.oppCharIcon.x = display.contentWidth*1100/1280
				self.oppCharIcon.y = display.contentHeight*210/720

				self.oppText = display.newText( "", display.contentWidth*933/1280, display.contentHeight*262/720, display.contentWidth*340/1280, display.contentHeight*340/720, "Helvetica", 30 )
				self.oppText:setTextColor( 0,0,0 )
				self.oppText.text = "Username: "..self.userID.."\nW/L: ".."\nCharacter: "..self.chosenChar.."\nLatency: "
				self.bgGroup:insert(self.oppText)
			end

			self.selectedPlayer = 1 -- indicates which player in the playersFound table you might engage with

			function request( event )
				self:requestGame( event )
			end
		end

		self.searching.isVisible = false
		self.matchFound.isVisible = true
		self.stopFindingBtn.isVisible = false

		self.fightBtn.isVisible = true
		self.fightBtn:addEventListener( "touch", request )
	end
end

function Multiplayer:acceptAndLoad()
	if( not self.accepted ) then
		self.newGameID = math.random(10000,20000)
		if DebugInstance.multiplayer then print( "send out accepted command with unique new game ID = "..self.newGameID) end
		hub:publish({
			message = {
				action  =  "accepted",
				id = crypto.digest( crypto.md5, system.getTimer()  ..  math.random()   ),
				timestamp = system.getTimer(),
				userID = self.userID,
				newGameID = self.newGameID,
				chosenChar = self.chosenChar
			}
		});

		self.accepted = true
	end
end

function Multiplayer:newGame( id )
	
	-- subscribe to new game channel
	-- game is already loading by this point, and when Update.lua is done initializing
	-- then we'll get a "loaded" message

	hub:subscribe({
		channel = "game"..tostring(id);  
		
		callback = function(message)

		    if(message.action == "initial" and self.opponentSynced == false ) then
		    	if( #GameController.controlledPlayer.opponents == 0 ) then
		    		print("shit, opponent not added")
		    	end
		    	for key, o in pairs(GameController.controlledPlayer.opponents) do
		    		if( message.userID == self.requestedOpponent ) then
			    		o.sprite.x = message.initialX
		           		o.sprite.y = message.initialY
		           		self.opponentSynced = true
		           		print( "Opponent is synced" )
					end					
				end			
			end

			-- RECEIVING INPUTS --
			if(message.action=="input") then
				if(message.userID ~= GameController.controlledPlayer.id ) then -- if input received is not for yourself
					for i, player in pairs(GameController.allPlayers) do -- but for other players
						if( message.userID == player.id ) then
							if( message.button == "stop" ) then
								player.controls:stop() -- event parameter not required
								if( self.extrapolation == true ) then
									player.sprite.x = message.x
									player.sprite.y = message.y
								end
							elseif message.button == "movement" then
								player.controls:manualMove(message.distanceMovedX, message.distanceMovedY)
							else
								local event = { phase = message.phase } -- don't need time as that's local 
								self:operateControls( player, message.button, event )
							end
						end
					end
				end
			end

	        -- ping
	        if(message.action == "ping") then
	          	if(message.userID == self.requestedOpponent) then -- if it came from opponent
					hub:publish({
						message = {
							action  =  "pong",
							userID = self.userID,
							original_timestamp = message.timestamp,
							timestamp = system.getTimer()
						}
					});
				end
			end

			if( message.action == "pong" ) then 
				if( message.userID == self.requestedOpponent ) then
					table.insert( self.latencies,(system.getTimer() - message.original_timestamp)/2 );

					for i,lat in ipairs(self.latencies) do
						if( self.latencyCount >= 10 ) then
							self.latencySum = 0
							self.latencyCount = 0
						end
						self.latencySum = self.latencySum + lat;
						self.latencyCount = self.latencyCount+1;
					end

					self.latency = math.round(self.latencySum/self.latencyCount)
					GameController.controlledPlayer.latency = self.latency
					if( self.latency < 100 ) then
						GameController.controlledPlayer.interpolationDelay = 50
					elseif( self.latency >= 100 ) then
						GameController.controlledPlayer.interpolationDelay = 100
					end

					-- *ahem* slow down
					if( self.slowDownGameTime == true ) then
						self.slowDownFactor = 1.5
					end
				end
			end		
		end; -- ends callback	
	});

	if DebugInstance.multiplayer then
		print( "Subscribed to game "..tostring(id) )
	end

	-- undraw menu
	self.bgGroup.isVisible = false

	-- you can only properly publish after you've subscribed
	update.updatePosition("initial",self) -- let Update.lua:updatePosition() handle publishing the initial sync message
	
end

function Multiplayer:operateControls( player, buttonToPress, event )
	if( buttonToPress == "up" ) then
		player.controls:up( event )
	elseif( buttonToPress == "down" ) then
		player.controls:down( event )
	elseif( buttonToPress == "left" ) then
		player.controls:left( event )
	elseif( buttonToPress == "right" ) then
		player.controls:right( event )
	elseif( buttonToPress == "upLeft" ) then
		player.controls:upLeft( event )
	elseif( buttonToPress == "upRight" ) then
		player.controls:upRight( event )
	elseif( buttonToPress == "downLeft" ) then
		player.controls:downLeft( event )
	elseif( buttonToPress == "downRight" ) then
		player.controls:downRight( event )
	end

	if ( buttonToPress == "jump" ) then
		player.controls:jump( event )
	elseif( buttonToPress == "attack" ) then
		player.controls:attack( event )
	elseif( buttonToPress == "def" ) then
		player.controls:def( event )
	end
end

function Multiplayer:getPing()
	if( currentGameMode == "multiplayer" and self.latency ~= nil ) then
		return tostring(math.round(self.latency))
	else 
		return "0"
	end
end

function Multiplayer:startPinging() -- should proably be done earlier...
	
	print("start pinging")

	-- ping every 500 ms, output on console
	timer.performWithDelay( 500, function()
		hub:publish({
			message = {
				action  =  "ping",
				userID = self.userID,
				timestamp = system.getTimer(),
				chosenChar = self.chosenChar,
			}
		});
	end, 0 );
end

function Multiplayer:nextPlayer()
	if #self.playersFound > self.selectedPlayer then
		self.selectedPlayer = self.selectedPlayer + 1
		--self.searchText.text = "Game found. Your opponent is: "..self.playersFound[self.selectedPlayer]
	else
		self.selectedPlayer = 1
		--self.searchText.text = "Game found. Your opponent is: "..self.playersFound[self.selectedPlayer].."\nNo other player available don't be so picky."
	end
end

function Multiplayer:sendStop( x, y )
    hub:publish({
    	message = {
    		userID = self.userID,
			action = "input",
			button = "stop",
			x = x,
			y = y,
		}
	});	
end

function Multiplayer:sendInput( button, phase, time, x, y )
    hub:publish({
    	message = {
    		userID = self.userID,
			action = "input",
			button = button,
			phase = phase,
			time = time,

			distanceMovedX = x,
			distanceMovedY = y,
		}
	});	
end

return Multiplayer
