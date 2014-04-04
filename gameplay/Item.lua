-------------------------------------------------
--
-- Item.lua
--
-------------------------------------------------
local Effects = require("gameplay.Effects")
local Stage = require( "gameplay.Stage" )

-- default Item table, linked with metatable

local Item = {

	----------------------------------------------- VARIABLES -----------------------------------------------
	bot = 0,

	mirror = 1,
	mirrored = false,

	currentTimeX = 0,
	currentTimeY = 0,
	startTimeX = 0,
	startTimeY = 0,
	Vx = 0,
	defaultUx = 800, -- 850 = almost one screen
	Vy = 0, -- current velocity in y direction, changes throughout motion
	Uy = 0, -- initial velocity in y direction (goes down each bounce)
	defaultUy = 15, -- default initial velocity in y direction (for the throwing)
	g = 300,
	Y0 = 0,
	X0 = 0,
	Ux = 0, -- if not thrown horizontally
	direction = 0,	
	
	firstBounce = false,
	previousBounceUy = 0,
	flying = true, -- every item is initially dropped out of the sky and is 'flying'
	flashing = false,
	cutOffBounceVy = 100, -- item will cease to bounce after this velocity
	-- (or else the item will keep bouncing and oscillating at very low velocities and never be able to be picked up)

	-- interactions with players
	pickedUp = false,
	thrown = false,
	hitTarget = false,
	thrower = nil,

	maxItemSize = 100, -- determines how far off the edge of the screen an item will be removed

	-- list of all current items, not self.currentItems (thats available items)
	--currentItems = {}, -- now delegated to GameController for easy reset

	-- for system pause
	paused = false,
	pauseTimeStart = 0,
	pauseTimeDiff = 0,

	-- for multiplayer slow down (test)
	slowDownFactor = 1,
}

local Item_metatable = {
__index = Item
}

local availableItems = {
	--"treelog",
	"baseball",
	"raygun",
	"bamboostick",
	"beer",
	--"heart",
	--"rock"
	-- must be a string
}

-- default Item constructor

function Item.new( name ) -- make item based on name input; can be random or manual
	
	-- add item types here
	if( name == nil ) then -- use a random item
		name = availableItems[math.random(1, #availableItems)]
	elseif( name == "raygun" ) then
		itemType = require( "items.Raygun" )
	elseif( name == "baseball" ) then
		itemType = require( "items.Baseball" )
	elseif( name == "bamboostick" ) then
		itemType = require( "items.BambooStick" )
	elseif( name == "beer" ) then
		itemType = require( "items.Beer" )
	end
			
	i = { 
		name = name, 
		itemType = itemType:new(),
	}
	setmetatable( i, Item_metatable )

	i.sprite = display.newImage( "images/items/"..name..".png" )
	i.sprite.x = math.random(0, display.contentWidth) -- random spot
	i.Y0 = i.sprite.y
	i.X0 = i.sprite.x

	i.dropPoint = math.random(Stage.boundaryTop + display.contentHeight * 150/720, Stage.boundaryBot) -- boundaryTop was intended for player.sprite.y...
	i:drop()

	return i
end

function Item:getAllItems()
	return GameController.currentItems
end

function Item:removeAllItems()
	for i,v in pairs(GameController.currentItems) do
		v.sprite:removeSelf()
		v = nil		
	end
	GameController.currentItems = {}
end

-- every item needs to be dropped once it is created
function Item:drop()
	self.airTimer = system.getTimer()
	self.flying = true
	--if itemDebug then print( self.name.." has been dropped." ) end
	table.insert( GameController.currentItems, self )
end

function Item:keepVisible() -- also do mirroring
	for i,v in pairs(GameController.currentItems) do
		if( v ~= nil and v.flying == false ) then
			v.sprite.isVisible = true

			if( v.mirrored == false and v.mirror == -1 ) then
				v.sprite:scale( -1, 1 )
				v.mirrored = true
			elseif( v.mirrored == true and v.mirror == 1 ) then
				v.sprite:scale( -1, 1 )
				v.mirrored = false
			end
		end
	end
end

--[[

function Item:pickUp( player ) -- allow Player/AI to pick up item
	for k, v in pairs( GameController.currentItems ) do
		--if itemDebug then print( v.name.." is - pickedUp: "..tostring(v.pickedUp).." flying: "..tostring(v.flying) ) end
		if( v.pickedUp == false and v.flying == false ) then -- can't pick up if item is in-air
			if( math.abs(player.sprite.x - v.sprite.x) <= player.pickUpDistanceX ) then
				if( math.abs(player.sprite.y) <= player.pickUpDistanceY ) then
					v.pickedUp = true
					return v
				end
			end	
		end			
	end
end

]]--

-- This function returns the coordinates of the most nearby item (not the distance to)
function Item:detectClosestItem( player ) -- allow Player/AI to pick up item

	minX = 9999
	minY = 9999

	targetX = 0
	targetY = 0

	for k, v in pairs( GameController.currentItems ) do
		if( v.pickedUp == false and v.flying == false ) then -- can't pick up if item is in-air
			if( math.abs( player.sprite.x - v.sprite.x ) < minX and math.abs( player.sprite.y - v.sprite.y ) < minY ) then
				minX = math.abs( player.sprite.x - v.sprite.x )
				minY = math.abs( player.sprite.y - v.sprite.y )

				-- new closer target found, return that item's coordinates
				targetX = v.sprite.x
				targetY = v.sprite.y	
			end
		end			
	end

	return targetX, targetY
end

function Item:detectItems( player ) -- allow Player/AI to pick up item
	if( player.jumped == false and player.itemHeldFlag == false ) then -- a jumping player can't detect items
		for k, v in pairs( GameController.currentItems ) do
			if( v.pickedUp == false and v.flying == false ) then -- can't pick up if item is in-air
				if( math.abs(player.sprite.x - v.sprite.x) <= player.pickUpDistanceX ) then
					if( math.abs(player.bot - v.sprite.y) <= player.pickUpDistanceY ) then
						return true
					else
						return false
					end
				end	
			end		
		end	
	end
end

function Item:resetVariables()

	-- properties
	self.flying = false
	self.thrown = false
	self.pickedUp = false
	self.hitTarget = false
	self.thrower = nil
	self.airTimer = 0
	self.currentAirTime = 0

	-- reset velocities for bouncing
	self.Vx = 0
	self.Vy = 0 -- current velocity in y direction, changes throughout motion
	self.Uy = 0 -- initial velocity in y direction (goes down each bounce)
	-- X0 and Y0 are not reset - that is where the item is now
	self.Ux = 0 -- if not thrown horizontally
	
	-- bouncing related
	self.firstBounce = false
	self.previousBounceUy = 0

	-- reset rotation orientation
	local xi = self.sprite.x
	local yi = self.sprite.y
	self.sprite:removeSelf()
	self.sprite = display.newImage( "images/items/"..self.name..".png" )
	self.sprite.x = xi
	self.sprite.y = yi

	-- reset item specifics
	self.itemType:reset()

	-- if item was thrown to the left, the new sprite will be facing right
	if( self.mirrored == true ) then
		self.sprite:scale(-1,1)
		-- otherwise its fine
	end
end

-- authored 10/28
-- can choose to take out hitTarget flag if you want item to possibly hit enemy more than once
-- once an item is thrown, it will have a "Player" attached, so any enemy will get damaged
function Item:detectHit()
	for i,v in pairs(GameController.currentItems) do
		if v.flying == true and v.thrown and v.thrower ~= nil then -- only check items that have aggressiveness; fixlater
			for key, enemy in pairs(v.thrower.opponents) do
				if( enemy.dead == false and enemy.invulnerable == false and enemy.fallen == false ) then
					if( math.abs(v.sprite.x - enemy.sprite.x) < (v.sprite.width + enemy.sprite.width)/4 ) then -- fixlater
						if( math.abs( v.sprite.y - enemy.sprite.y ) < enemy.sprite.contentHeight/2  ) then -- fixlater
							if( v.hitTarget == false ) then -- make sure v only hits once
								v.hitTarget = true

								if( enemy.defense == true and enemy.mirror == v.mirror*-1 ) then
									enemy:defend( damage )
									Effects:def( v, enemy )
								else
									enemy:getsHit( v.itemType.damage, "punch", v.direction, false ) -- if getting punched from the right, face right when flinching
									-- play hit effect halfway between aggressor and enemy
									Effects:hit( v, enemy )
								end
												
								v.X0 = enemy.sprite.x
								v.direction = v.direction * -1
								v.Ux = 0.5 * v.Ux * (1-v.itemType.friction) -- further damp by half

							end
						end
					end
				end
			end
		end
	end
end


function Item:dropCheck()

	for i,v in pairs(GameController.currentItems) do
		
		-- physics for the Item dropping and flying
		if v.flying == true then

			-- used in Update.lua to detect item layering
			-- Important NOTE: if item is flying, its bot-y value for layering is still based on its drop points
			v.bot = v.dropPoint + v.sprite.contentHeight/2 

			v.currentAirTime = ( system.getTimer()/1000 - v.airTimer/1000 ) / v.slowDownFactor
			v.Vy = v.Uy -  2*( v.g * v.currentAirTime )
			v.sprite.x = v.X0 + v.direction * v.Ux * v.currentAirTime
			v.sprite.y = v.Y0 - v.Vy * v.currentAirTime --+ 0.5 * v.g * math.pow(v.currentAirTime, 2)
			
			-- Items will be removed once its off-screen (gone forever)
			if( v.sprite.x > Stage.boundaryRight + self.maxItemSize ) then
				v.sprite.x = 9999 -- apparently items weren't really removed and were detected by AI, just for insurance
				v.sprite:removeSelf()
				v = nil
				table.remove( GameController.currentItems, i )
				break
			elseif( v.sprite.x < 0-self.maxItemSize ) then
				v.sprite.x = -9999 -- apparently items weren't really removed and were detected by AI, just for insurance
				v.sprite:removeSelf()
				v = nil
				table.remove( GameController.currentItems, i )
				break
			end			

			if( v.sprite.y > v.dropPoint  ) then
				-- debug text
				--if itemDebug then print ( "Horizontal velocity = ", v.Ux ) end

				v.airFinishedTime = system.getTimer() 
				--if itemDebug then print ( "Item bounced after "..((v.airFinishedTime - v.airTimer)/1000).." seconds" ) end -- DEBUG: print how long jump took
				v.sprite.y = v.dropPoint -- this makes sure you don't end up landing further than where you started
				
				-- bounce
				-- reset airTimer
				v.airTimer = system.getTimer()
				-- new Y0 is the new launch point now (try dropPoint or v.sprite.y)
				v.Y0 = v.dropPoint 
				-- bounce effect is caused by reversal of Uy

				-- current sprite.x position is now the new X0
				v.X0 = v.sprite.x
				-- x-velocity decreases based on friction
				v.Ux = v.Ux * (1-v.itemType.friction)

				if( v.firstBounce == false ) then
					v.Uy = v.Vy * -(1+v.itemType.bounciness) -- because the physics equation are flawed for pixel scale
					v.previousBounceUy = v.Uy
					v.firstBounce = true
				else
					--if itemDebug then print( "Before bounce terminal velocity: ", v.Uy ) end
					v.Uy = v.previousBounceUy * v.itemType.bounciness
					v.previousBounceUy = v.Uy
					--if itemDebug then print( "After bounce rebound velocity: ", v.Uy ) end
					if( v.Uy < v.cutOffBounceVy ) then -- anything below 50 is considered finished bouncing
						v:resetVariables()
					end
				end
			end

			-- rotate items if thrown; to make more realistic, stop rotating it when velocity is slow
			if( v.thrown == true and v.Ux > v.cutOffBounceVy ) then
				v.sprite:rotate( v.itemType.rotatability * v.Ux/20)
			end
		else
			-- used for Update.lua layering, here the item is stationary, use its bot value
			v.bot = v.sprite.y + v.sprite.contentHeight/2 
		end
	end
end

return Item