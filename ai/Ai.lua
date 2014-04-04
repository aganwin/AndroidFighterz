-- New AI --
local Player = require( "gameplay.Player" )
local bt = require( "ai.aibht" )
local Item = require( "gameplay.Item" )
local Debug = require( "helpers.Debug" )
local Ball = require( "gameplay.Ball" )
local decisionTable = require( "ai.AiDecisionTable" )

local Tools = require( "helpers.Tools" )

local AI = {

	activeState = nil,

	attackDetected = false,
	detectAttackDelay = 400,
	lastMoveDefended = 0, -- counter increases every successful block to an enemy punch, to make consecutive blocks less likely 
	battleMode = false,

	normalDistX = 100, normalDistY = 20, -- approaching distance
	battleDistX = 50, battleDistY = 10,

	rangedDetectionDistance = 120,
}

local AI_metatable = {
	__index = AI -- inherits all Player functions
}

function AI.new( p ) -- initialized when Player is an AI
	a = {} -- must override name variable in Player{} to create sprite
	setmetatable( a, AI_metatable )
	a.someValue = "hi"
	a.player = p
	return a
end

function AI:setState(state)
	self.activeState = state
end

function AI:initialize()
	self:setState(self.approachEnemy)
	-- bt:setAI(self)
	-- self.routine = bt.routine
end

-- run it
function AI:main()
	if(self.activeState) then
		self:activeState()
	end
end

-- states

function AI:approachEnemy()

	-- consider these at all times --
	if self.player.mJumped == true then 
		if math.random() > 0.7 then
			self.player:recover()
		end
	end

	if self:detectIncomingAttack() == true or self:detectIncomingSkillOrItem() == true then
		if math.random() > 0.7 then
			self.player:defend()
		end
	end

	local x,y = 0,0 

	if self.battleMode == false then
		x,y = self.normalDistX, self.normalDistY
	else
		x,y = self.battleDistX, self.battleDistY
	end

	self:nearestEnemy() -- might not want to run this every frame

	if self.player.movementOverride == false then
		self:orientDirection(x,y) -- don't change AI's direction if he's doing movement-restricted movements (drill attack, run attack, etc.)
	end

	if( self.player.directionX ~= 0 or self.player.directionY ~= 0 ) then
		if self.player.lastRandomAction ~= "running" then -- or just use self.player.running
			self.player:walk()
		end
	else
		self.player:goIdle()
	end

	-- special requests
	self:randomAction()

	--if( self:withinRange(30,10) ) then
	if self.battleMode == true then
		--self:normalAttack()
		--self:considerSkill()
	end

	-- transitions
	if(self.player.closestEnemyDistanceX < self.normalDistX and self.player.closestEnemyDistanceY < self.normalDistY) then
		self.battleMode = true
	else
		self.battleMode = false
	end

	if( self:considerRangedSkill() == true ) then
		self:setState(self.rangedSkillRoutine)
	end
end

-- helper functions --

local possibleActions = {
    "defending", -- includes rolling/sliding
    "stopping",
    "running",
    "jumping",
}

function AI:randomAction()
    if system.getTimer() - self.player.lastRandomActionTime > self.player.lastRandomActionTimeout and self.battleMode == false then
        -- random scheme: jumping has higher priority, so random numbers usually come out higher
        local rand = math.random(1,#possibleActions)
        local randomAction = possibleActions[rand]
        print(rand, randomAction)

        -- don't repeat same action as last time; choose again in 500 ms
        if randomAction == self.player.lastRandomAction then
            self.player.lastRandomActionTimeout = 300
            print("Choose another action")
            return
        end

        if randomAction == "defending" then
            -- choose to defend, for example
            self.player:defend()
            -- lastRandomActionTimeOut is the amount of time before another random action will be chosen
            -- so if the range is (0.5,0.8), the AI might defend too often

            -- timeout is generated based on a random number range and a power (min,max,power)
            -- lower powers (<1) converge towards the max, higher powers (>1) converge towards the min
            -- (1,2,10) will give a mean of 1.09 over 20 samples
            -- (1,2,0.1) will give a mean of 1.95 over 20 samples
            self.player.lastRandomActionTimeout = Tools:generateRandomNumber(1,2,2)*1000 -- seconds
            self.player.lastRandomAction = "defending"
        elseif randomAction == "jumping" then
            self:jump()
            self.player.lastRandomActionTimeout = Tools:generateRandomNumber(2,3,1)*1000
            self.player.lastRandomAction = "jumping"
        elseif randomAction == "stopping" then
            self.player:goIdle()
            self.player.lastRandomActionTimeout = Tools:generateRandomNumber(0.2,0.3,1)*1000
            self.player.lastRandomAction = "stopping"
        elseif randomAction == "running" then
            -- no "running" in y-direction only
            if self.player.directionX ~= 0 then
                self:run()
                self.player.lastRandomActionTimeout = Tools:generateRandomNumber(1.5,3.0,5)*1000
                self.player.lastRandomAction = "running"

                timer.performWithDelay( self.player.lastRandomActionTimeout+1000, function()
                    -- dont't remain in running mode for too long, so go back to idle
                    -- but give a chance to do a defend move (run->defend->idle)
                    self.player:goIdle()
                end )
            end
        end

        self.player.lastRandomActionTime = system.getTimer()
        return true
    elseif self.battleMode == false then
        if self.player.lastRandomAction == "stopping" then
            return false -- if we wanted to go idle, we don't want to move the next frame, instead wait for the timeout duration (0.5-0.8 secs)
        else
            return true
        end
    elseif self.battleMode == true then
        return true
    end
end

function AI:orientDirection(minx,miny)

	if( math.abs(math.round(self.player.sprite.x) - math.round(self.player.xTarget)) <= minx - 1) then
		self.player.directionX = 0
		self.player.jumpDirection = 0
	elseif( self.player.sprite.x + minx < self.player.xTarget ) then
		self.player.directionX = 1
		self.player.jumpDirection = 1
	elseif( self.player.sprite.x - minx > self.player.xTarget ) then
		self.player.directionX = -1
		self.player.jumpDirection = -1
	end

	if( math.abs(math.round(self.player.sprite.y) - math.round(self.player.yTarget)) <= miny - 1 ) then
		self.player.directionY = 0
	elseif( self.player.sprite.y + miny < self.player.yTarget ) then
		self.player.directionY = 1
	elseif( self.player.sprite.y - miny > self.player.yTarget ) then
		self.player.directionY = -1
	end

	--print("orientDirection, dirX = ", self.player.directionX, "dirY = ", self.player.directionY)

end

function AI:doesEnemyExist()
	self:nearestEnemy()
	if self.player.closestEnemyDistanceX == 9999 then
		return false
	else
		return true
	end
end

function AI:doesItemExist()
	self:nearestItem()
	if self.player.closestItemDistanceX == 9999 then
		return false
	else
		return true
	end
end

function AI:withinRange(x,y) 
	if self.player.closestEnemyDistanceX < x and self.player.closestEnemyDistanceY < y then
		return true
	else
		return false
	end
end

function AI:isEnemyNearby(dist)
	self:nearestEnemy()
	
	if math.sqrt( math.pow(self.player.closestEnemyDistanceX,2) + math.pow(self.player.closestEnemyDistanceY,2) ) < dist then
		return true
	else
		return false
	end
end

function AI:isEnemyFarEnoughToRunAt(x,y)
	self:nearestEnemy()
	
	if self.player.closestEnemyDistanceX > x and self.player.closestEnemyDistanceY > y then
		return true
	else
		return false
	end
end

function AI:isItemNearby(dist)
	self:nearestItem()
	if math.sqrt( math.pow(self.player.closestItemDistanceX,2) + math.pow(self.player.closestItemDistanceY,2) ) < dist then
		return true
	else
		return false
	end
end

function AI:detectIncomingAttack()
	-- this function looks at the closest enemy to AI, 1) whether he is within range attacking or not
	-- 2) whether the closest enemy is attacking (GC:withinRange() doesn't check this)
	-- 3) whether AI already has detected an attack - this is important because without the flag, this function will run many times in 300 ms worth of enemy attacking time and return true always
	-- attackDetected flag is set back to false anyway after a timeout of 300 ms (can vary in future)

	self:nearestEnemy()
	if( self.closestEnemy == nil ) then return end

	if GameController:withinRange(self.closestEnemy, self.player) == true and self.closestEnemy.attacking == true and self.attackDetected == false then
		local rand = math.random() - self.lastMoveDefended * 0.25
		print(rand, self.lastMoveDefended)

		self.attackDetected = true
    	timer.performWithDelay( self.detectAttackDelay, function() -- this has to go before the return is done to set the attackDetected flag
	    	self.attackDetected = false
	    end)

		if( rand > 0.5 ) then
			self.lastMoveDefended = self.lastMoveDefended + 1
			return true
    	else 
    		self.lastMoveDefended = 0
    		return false
    	end    	
    end       

    return false
end

function AI:detectIncomingSkillOrItem()
	for i,b in pairs(Ball.listOfBalls) do
		if( b.castingPlayer ~= self.player ) then
	        if math.abs(self.player.sprite.x - b.sprite.x) < self.rangedDetectionDistance then
	            -- allow AI to defend even when something is coming behind his back by switching directions
	            -- (undesirable) this code is run a few times a second so AI will switch directions as ball passes
	            -- if self.player.sprite.x > b.sprite.x then
	            -- 	self.player:flipHorizontal(-1)
	            -- else
	            -- 	self.player:flipHorizontal(1)
	            -- end
	            return true
	        end
	    end
    end

    for i,v in pairs(GameController.currentItems) do
        if( v.thrower ~= self.player ) then
	        if math.abs(self.player.sprite.x - v.sprite.x) < self.rangedDetectionDistance then
	            -- allow AI to defend even when something is coming behind his back by switching directions
	            -- (undesirable) this code is run a few times a second so AI will switch directions as ball passes
	            -- if self.player.sprite.x > b.sprite.x then
	            -- 	self.player:flipHorizontal(-1)
	            -- else
	            -- 	self.player:flipHorizontal(1)
	            -- end
	            if v.thrown == true then
	            	return true
	            end
	        end
	    end
    end    
    return false 
end

function AI:flee()
	-- run opposite X direction
	if self.player.directionX == 0 then
		if GameController.stagePicked.boundaryRight - self.player.sprite.x > self.player.sprite.x - 0 then
			self.player.directionX = 1
		else
			self.player.directionX = -1
		end
	end
	
	-- this code will oscillate
	--self.player.directionX = (self.player.xTarget - self.player.sprite.x) / math.abs(self.player.xTarget - self.player.sprite.x)
	self.player:walk()
end

function AI:isEnemyInLine()

	self:nearestEnemy()
	
	if self.player.closestEnemyDistanceY < 50 then
		return true
	else
		return false
	end
end

function AI:lineUpWithEnemy()
	self.player.directionX = 0
	self.player.directionY = (self.player.yTarget - self.player.sprite.y) / math.abs(self.player.yTarget - self.player.sprite.y)
	self.player:walk()

	-- make sure you're faced the right way afterwards
	self.player:flipHorizontal( (self.player.xTarget - self.player.sprite.x) / math.abs(self.player.xTarget - self.player.sprite.x) )
end

function AI:nearestEnemy() -- get the "hypotenuse"/radius

	local closestEnemyDistance = 9999

	self.closestEnemy = nil

	for k, v in pairs( self.player.opponents ) do
		if v.invulnerable == false then
			local distanceX = math.abs( self.player.sprite.x - v.sprite.x )
			if( v.jumped or v.mJumped ) then
				distanceY = math.abs( self.player.sprite.y - v.Y0 )
			else
				distanceY = math.abs( self.player.sprite.y - v.sprite.y )
			end
			local distanceH = math.sqrt( distanceX*distanceX + distanceY*distanceY )
			
			if( distanceH < closestEnemyDistance ) then
				closestEnemyDistance = distanceH -- at the end of the loop, this should become the closest enemy
				self.player.xTarget = math.round( v.sprite.x )
				if( v.jumped or v.mJumped ) then
					self.player.yTarget = math.round( v.Y0 )
				else
					self.player.yTarget = math.round( v.sprite.y )
				end	

				self.player.closestEnemyDistanceX = distanceX
				self.player.closestEnemyDistanceY = distanceY	

				self.closestEnemy = v
			end
		else
			self.player.closestEnemyDistanceX = 9999
			self.player.closestEnemyDistanceY = 9999
		end
	end
end

function AI:nearestItem() -- get the "hypotenuse"/radius

	local closestItemDistance = 9999

	if #GameController.currentItems == 0 then
		self.player.closestItemDistanceX = 9999
		self.player.closestItemDistanceY = 9999
		return
	end

	for k, v in pairs( GameController.currentItems )do
		if v.pickedUp == false and v.flying == false then -- only detect untouched items
			local distanceX = math.abs( self.player.sprite.x - v.sprite.x )
			local distanceY = math.abs( self.player.bot - v.sprite.y )
			local distanceH = math.sqrt( distanceX*distanceX + distanceY*distanceY )
			
			if( distanceH < closestItemDistance ) then
				closestItemDistance = distanceH -- at the end of the loop, this should become the closest enemy
				self.player.xTarget = math.round( v.sprite.x )
				self.player.yTarget = math.round( v.sprite.y - self.player.sprite.contentHeight/2 )
				self.player.closestItemDistanceX = distanceX
				self.player.closestItemDistanceY = distanceY	
			end
		else
			self.player.closestItemDistanceX = 9999
			self.player.closestItemDistanceY = 9999
		end
	end
end

function AI:considerSkill()
	local timeSinceLastSkill = math.max(system.getTimer() - self.player.lastRangedSkillTime, system.getTimer() - self.player.lastMeleeSkillTime)
    if( timeSinceLastSkill > self.player.skillTimeout ) then
        if math.random() > 0.5 then
            if math.random() > 0.5 then
                self.player.chosenSkill = self.player.character.rangedSkills[ math.random(1,#self.player.character.rangedSkills) ]
                self.player.chosenSkillType = "ranged"
                self:rangedSkill()
            else
                self.player.chosenSkill = self.player.character.meleeSkills[ math.random(1,#self.player.character.meleeSkills) ]
                self.player.chosenSkillType = "melee"
                self:meleeSkill()
            end        
        else
            -- wait half a second before considering using skill again
            self.player.lastRangedSkillTime, self.player.lastMeleeSkillTime = system.getTimer()+500, system.getTimer()+500
        end
    end
end

function AI:considerRangedSkill() -- while approaching from far away
	local random = math.min((system.getTimer() - self.player.lastRangedSkillTime) / 10000, 1)
    if math.random(0,random) * ( self.player.mpValue / self.player.fullmpValue ) > 0.9 then
        return true
    else
        return false
    end 
end

function AI:rangedSkillRoutine()
	self:lineUpWithEnemy()
	if( self:isEnemyInLine() ) then
		self:rangedSkill()

		self:setState( self.approachEnemy )
	end
end

function AI:meleeSkill()
	self.player:goIdle()

	if self.player.chosenSkill == "dlrj" then
		if( self.player.mirror == 1 ) then
			self.player:specialSkill( "drj" )
		else
			self.player:specialSkill( "dlj" ) 
		end
	elseif self.player.chosenSkill == "dlra" then
		if( self.player.mirror == 1 ) then
			self.player:specialSkill( "dra" )
		else
			self.player:specialSkill( "dla" ) 
		end
	else
		self.player:specialSkill( self.player.chosenSkill )
	end

	self.player.lastMeleeSkillTime = system.getTimer( )
end

function AI:rangedSkill()
	self.player:goIdle()

	if self.player.chosenSkill == "dlrj" then
		if( self.player.mirror == 1 ) then
			self.player:specialSkill( "drj" )
		else
			self.player:specialSkill( "dlj" ) 
		end
	elseif self.player.chosenSkill == "dlra" then
		if( self.player.mirror == 1 ) then
			self.player:specialSkill( "dra" )
		else
			self.player:specialSkill( "dla" ) 
		end
	else
		self.player:specialSkill( self.player.chosenSkill )
	end

	self.player.lastRangedSkillTime = system.getTimer( )
end

function AI:normalAttack()
	self.player:attack()
end

function AI:wander()
	self.player:jump()
end

function AI:run()
	self:orientDirection(self.normalDistX, self.normalDistY)
	self.player:run()
end

function AI:jump()
	self:orientDirection(self.normalDistX, self.normalDistY)
	self.player:jump()
end

return AI
