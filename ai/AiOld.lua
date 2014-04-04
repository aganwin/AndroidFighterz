-- note, there might only be one instance of Ai.... so two AIs might start doing the same thing then you know the table variables need to be Player's not Ai's

-- phase 1) walk towards you with occasional pauses

local Item = require( "gameplay.Item" )
local Grid = require( "libraries.Grid" ) -- for pathfinding
local Debug = require( "helpers.Debug" )

local decisionTable = require( "AiDecisionTable" )

local Ai = {
	lastDecision = 0,
	decisionInterval = 1500,
	path = nil,
	lastPathFind = 0,
	lastSkillDelay = 3000,
	pointsToVisit = {},
	counter = 0,
	initialized = false,
}

local hostile = true -- change this to make AI not attack

-- Approach state
function Ai:state_approach( a )

	self:orientDirection(a)

	-- randomly jump, run, or idle
	if( system.getTimer() - a.lastDecision > a.decisionCooldown ) then
		a.decision = math.random() -- random value between 0 and 1
		print(a.decision)
		if( a.decision < decisionTable.idle.weight ) then
			a:goIdle()
			a.decisionCooldown = decisionTable.idle.cooldown
		elseif( a.decision < decisionTable.jump.weight ) then
			a:jump()
			a.decisionCooldown = decisionTable.jump.cooldown
		elseif( a.decision < decisionTable.run.weight ) then
			self:runTowards(a) -- don't just call a:run()
			a.decisionCooldown = decisionTable.run.cooldown
		else 
			self:walkTowards( a )
			a.decisionCooldown = decisionTable.walk.cooldown
		end

		a.lastDecision = system.getTimer( )
	else
		if( a.stateChangedRecently == true ) then
			self:walkTowards(a) -- do not idle if user walks away from battle radius
			a.stateChangedRecently = false
		end
	end
end

-- Battle state
function Ai:state_battle( a ) 
	
	if hostile == false then
		a:goIdle()
	else
		if( a.decisionMade == false ) then
			a.decision = math.random(1,3)
			if( a.decision == 1 ) then 
				-- try punching
			elseif( a.decision == 2 ) then 
				-- perform a melee skill
				if( system.getTimer() - self.lastSkillDelay > 3000 ) then
					self:meleeSkill( a )
					self.lastSkillDelay = system.getTimer()
					a.decisionMade = false
					a.decision = 0
				end
			elseif( a.decision == 3 ) then -- running attack
			end

			a.decisionMade = true
		else
			if( a.decision == 1 ) then
				-- walk closer before punching
				if Ai:punch( a ) == false then
					self:walkTowards(a)
				end
			elseif( a.decision == 3 ) then
				if( a.closestEnemyDistanceX < 70 and a.running == true ) then
					a:attack()
					a.decisionMade = false
					a.decision = 0
				elseif( a.closestEnemyDistanceY > 50 ) then 
					self:walkTowards(a)
				elseif( a.closestEnemyDistanceY > 100 and a.closestEnemyDistanceX > 300 ) then
					-- give up and do somethign else
					a.decisionMade = false
					a.decision = 0
				end
			end
		end	
	end	
end

function Ai:punch( a )
	if( math.abs( a.xTarget - a.sprite.x ) < a.character.rangeX and math.abs( a.yTarget - a.sprite.y ) < a.character.rangeY ) then
		-- within range, attack
		a:idle() -- the idle prevents attacking mid-walk, which I might have to just hardcode into a:attack() later
		a:attack()
		return true
	else
		return false
		--print( a.xTarget, a.yTarget )
		--a:walkTowards()
	end
end

-- auxiliary functions
function Ai:nearestEnemy( a ) -- get the "hypotenuse"/radius

	local closestEnemyDistance = 9999

	for k, v in pairs( a.opponents ) do
		-- calculate pythagoreas distance to closest enemy
		local distanceX = math.abs( a.sprite.x - v.sprite.x )
		if( v.jumped or v.mJumped ) then
			distanceY = math.abs( a.sprite.y - v.Y0 )
		else
			distanceY = math.abs( a.sprite.y - v.sprite.y )
		end
		local distanceH = math.sqrt( distanceX*distanceX + distanceY*distanceY )
		
		if( distanceH < closestEnemyDistance ) then
			closestEnemyDistance = distanceH -- at the end of the loop, this should become the closest enemy
			a.xTarget = math.round( v.sprite.x )
			if( v.jumped or v.mJumped ) then
				a.yTarget = math.round( v.Y0 )
			else
				a.yTarget = math.round( v.sprite.y )
			end	

			a.closestEnemyDistanceX = distanceX
			a.closestEnemyDistanceY = distanceY	
		end
	end
end



function Ai:checkState( a )

	if( system.getTimer() - self.lastPathFind > 500 ) then
		self:nearestEnemy( a )
		self.lastPathFind = system.getTimer()
	end	

	distToEnemyX = math.abs( a.xTarget - a.sprite.x )
	distToEnemyY = math.abs( a.yTarget - a.sprite.y )
	local dist = math.round( math.sqrt( distToEnemyX*distToEnemyX + distToEnemyY*distToEnemyY ) )

	-- if too far, most likely approach, but might use special skill once in a while
	if( dist >= 50 or dist == 0 ) then
		if a.state ~= "approach"  then
			a.stateChangedRecently = true
		end
		a.state = "approach"
		Ai:state_approach(a)
	elseif( dist < 50 and dist ~= 0 ) then
		if a.state ~= "battle" then
			a.stateChangedRecently = true
		end
		a.state = "battle"
		Ai:state_battle(a)
	end	

end

function Ai:meleeSkill( a )

	-- depending on what character you use, this will pick one skill at random
	-- off a.character's (say Hank.lua) rangedSkill table
	local rs = a.character.meleeSkills[ math.random(1,#a.character.meleeSkills) ]
	if( rs == "dlra" ) then
		if( a.mirror == 1 ) then
			rs = "dra"
		else
			rs = "dla" 
		end
	elseif( rs == "dlrj" ) then
		if( a.mirror == 1 ) then
			rs = "drj"
		else
			rs = "dlj" 
		end
	end

	a:specialSkill( rs )
end

function Ai:rangedSkill( a )

	-- prevents this function from triggering twice
	self.lastSkillDelay = system.getTimer()
	-- depending on what character you use, this will pick one skill at random
	-- off a.character's (say Hank.lua) rangedSkill table
	local rs = a.character.rangedSkills[ math.random(1,#a.character.rangedSkills) ]
	if( rs == "dlra" ) then
		if( a.mirror == 1 ) then
			rs = "dra"
		else
			rs = "dla" 
		end
	elseif( rs == "dlrj" ) then
		if( a.mirror == 1 ) then
			rs = "drj"
		else
			rs = "dlj" 
		end
	end

	a:specialSkill( rs )
end
 
function Ai:main( a )
	self:initialize( a ) -- anything that is only run ONCE
	self:checkState( a )
end

function Ai:setDebugControl( a )

	function addPoint( event )
		if event.phase == "began" then
			a.xTarget, a.yTarget = event.x, event.y - a.sprite.contentHeight/2
			print(a.xTarget,a.yTarget)
		end
	end

	self.controlSpace = display.newRect( 0, GameController.stagePicked.boundaryTop, 1280, GameController.stagePicked.boundaryBot - GameController.stagePicked.boundaryTop )
	self.controlSpace.alpha = 0.01
	self.controlSpace:toFront()
	self.controlSpace:addEventListener( "touch", addPoint )
end

function Ai:initialize( a )
	if( self.initialized == false ) then

		if Debug.AIDebug == true then
			--self:setDebugControl( a )
		end	

		self.initialized = true
	end
end

function Ai:orientDirection( a )
	if( math.abs(math.round(a.sprite.x) - math.round(a.xTarget)) < 10 ) then
		a.directionX = 0
	elseif( a.sprite.x < a.xTarget ) then
		a.directionX = 1
		a:flipHorizontal(1)
	elseif( a.sprite.x > a.xTarget ) then
		a.directionX = -1
		a:flipHorizontal(-1)
	end

	if( math.abs(math.round(a.sprite.y) - math.round(a.yTarget)) < 10 ) then
		a.directionY = 0
	elseif( a.sprite.y < a.yTarget ) then
		a.directionY = 1
	elseif( a.sprite.y > a.yTarget ) then
		a.directionY = -1
	end
end

function Ai:runTowards( a )

	a:goIdle() -- prevents weird case where you start walking with running speed

	if a.xTarget == 9999 or a.yTarget == 9999 then
		return
	end		

	-- only run if not vertically aligned 
	if( a.directionY ~= 0 ) then
		a:run()
	else
		a:walk()
	end
end

function Ai:walkTowards( a )

	if a.xTarget == 9999 or a.yTarget == 9999 then
		a:goIdle()
		return
	end	

	if( a.directionX ~= 0 or a.directionY ~= 0 ) then
		a:walk()
		--if( a.decision == 3 ) then
		--	a:run()
		--else
		--	a:walk()
		--end
	else
		a:goIdle()
	end
end

return Ai