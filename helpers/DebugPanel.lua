local update = require( "gameplay.update" )
local widget = require( "widget" )

local DebugPanel = {
	menu = display.newGroup(),
	alreadyDrawn = false,
}

function DebugPanel:appear()
	-- slide out animation
	if( self.menu.isVisible ) then
		self.menu.isVisible = false
	else
		self.menu.isVisible = true
		self.menu:toFront()
		self.panelBtn:toFront()
	end
end

function DebugPanel:disappear()
	self.menu.isVisible = false
	self.panelBtn.isVisible = false
end

function DebugPanel:draw()

	if( self.alreadyDrawn == false ) then
		
		self.panelBtn = display.newImage( "images/gamesettings/settings.png" )
		self.panelBtn.x = display.contentWidth * 0.95
		self.panelBtn.y = display.contentHeight * 0.15

		local function drawMenu(event)
			if( event.phase == "began" ) then
				self:appear()
				return true
			end
		end

		-- Function to handle button events
		local function enemyJumps(event)
		    if event.phase == "began" then
		    	for k,v in pairs(GameController.controlledPlayer.opponents) do
		    		v:jump()
		    		
		    	end
		    	print("Enemy jumps")
		    end
		end

		local function enemyDLRJ(event)
		    if event.phase == "began" then
		    	for k,v in pairs(GameController.controlledPlayer.opponents) do
		    		--v:specialSkill("dlj")	   
		    		v:specialSkill("dva")	  		
		    	end
		    end
		end

		local function runLeft(event)
		    if event.phase == "began" then
		    	GameController.controlledPlayer:changeDirection(-1, 0)
				GameController.controlledPlayer:flipHorizontal(-1)
		    	GameController.controlledPlayer.directionX = -1
		        GameController.controlledPlayer:walk()
		    end
		end

		local function runRight(event)
		    if event.phase == "began" then
		    	GameController.controlledPlayer:changeDirection(1, 0)
				GameController.controlledPlayer:flipHorizontal(1)
		    	GameController.controlledPlayer.directionX = 1
		        GameController.controlledPlayer:run()
		    end
		end	

		local function fall(event)
			if event.phase == "began" then 
				GameController.controlledPlayer:fallback(300,700,-1)
			end
		end	

		local function throwOpponent(event)
			if event.phase == "began" then 
				GameController.controlledPlayer:throwOpponent(1)
			end
		end

		local function win(event)
		    if event.phase == "began" then
		    	for i, enemy in pairs(GameController.myTeam) do
		    		enemy.dead = true
		    	end
		    end
		end

		local function lose(event)
		    if event.phase == "began" then
		    	for i, player in pairs(GameController.oppTeam) do
		    		player.dead = true
		    	end
		    end
		end

		local punchOn = false
		local function punchNonstop()
			GameController.controlledPlayer:attack()
		end

		local function punch(event)
		    if event.phase == "began" then
		    	if punchOn == false then
		    		Runtime:addEventListener( "enterFrame", punchNonstop )
		    		punchOn = true
		    	else
		    		Runtime:removeEventListener( "enterFrame", punchNonstop )
		    		punchOn = false
		    	end
		    end
		end

		-- Create the widget
		local button1 = widget.newButton
		{
		    left = display.contentWidth * 0.85, top = display.contentHeight * 0.20, label = "Enemy DLRJ", onEvent = enemyDLRJ
		}

		-- Create the widget
		local button2 = widget.newButton
		{
		    left = display.contentWidth * 0.85, top = display.contentHeight * 0.25, label = "Fall", onEvent = fall
		}

		-- Create the widget
		local button3 = widget.newButton
		{
		    left = display.contentWidth * 0.85, top = display.contentHeight * 0.30, label = "Run ->", onEvent = runRight
		}

		-- Create the widget
		local button4 = widget.newButton
		{
		    left = display.contentWidth * 0.85, top = display.contentHeight * 0.35, label = "Throw Opponent", onEvent = throwOpponent
		}

		-- Create the widget
		local button4 = widget.newButton
		{
		    left = display.contentWidth * 0.85, top = display.contentHeight * 0.40, label = "Win Now", onEvent = win
		}

		-- Create the widget
		local button4 = widget.newButton
		{
		    left = display.contentWidth * 0.85, top = display.contentHeight * 0.45, label = "Lose Now", onEvent = lose
		}

		-- Create the widget
		local button4 = widget.newButton
		{
		    left = display.contentWidth * 0.85, top = display.contentHeight * 0.5, label = "Punch", onEvent = punch
		}

		self.panelBtn:addEventListener( "touch", drawMenu )
		--self.menu:insert( self.panelBtn )
		self.menu:insert( button1 )
		self.alreadyDrawn = true

	else
		self.panelBtn.isVisible = true
		self.panelBtn:toFront()
	end

end

return DebugPanel

