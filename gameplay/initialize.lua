------------------------------------------------
--
-- initialize.lua
--
-- Initialize all aspects of the game
--
--
-------------------------------------------------

module(..., package.seeall) 

local widget = require( "widget" )
--local Player = require( "gameplay.Player" )
local update = require( "gameplay.update" )
local Item = require( "gameplay.Item" )
local Stage = require( "gameplay.Stage" )
--local Grid = require( "Grid" )
local GameSettings = require( "menus.GameSettings" )
local Multiplayer = require( "multiplayer.Multiplayer" )
local Controls = require( "gameplay.Controls" )

loadedStatus = 0
gameStartTime = 0

transitionTime = 500

local currentOpponents = {}

-- added 8/24 for revamp of player/opponent system
-- don't make local, need access from update.lua init step
currentAi = {}
currentPlayers = {}

dpadtable = {}

stagePicked = nil

-- teams
myTeam = {}
oppTeam = {}

function unload() -- this is probably a piss poor function
	if( loadedStatus == 1 ) then
		empty:removeSelf()
		removeAllPlayers()
		currentAi = {}
		dpadtable = {}

		function removeAllListeners(obj)
		  obj._functionListeners = nil
		  obj._tableListeners = nil
		end

		removeAllListeners( Runtime ) -- this is fucking extreme but whatever
		loadedStatus = 0

		-- when all is said and done, load mode select again
		local ModeSelect = require( "menus.ModeSelect" )
		ModeSelect:drawMenu()

		loadedStatus = 0
	end
end

function load( gameType ) -- single or multiplayer
	
	if ( loadedStatus == 0 ) then -- in multiplayer, certain bugs cause a client to load game more than once
		
		currentGameMode = gameType
	
		stagePicked = Stage:pick( "hk" )

		empty = display.newRect( 0, 0, display.contentWidth, display.contentHeight )
		empty:setFillColor( 0,0,0 )

		stagePicked.bgGroup.isVisible = true
		empty:toFront()
		stagePicked.bgGroup:toFront()		

		transition.dissolve( empty, stagePicked.bgGroup, transitionTime, 100 )

		-- wait until stage is loaded to make characters and buttons appear

		timer.performWithDelay( 1, loadTheRest )
	end
end

function loadTheRest()

	----------------------------------------------- PLAYERS ----------------------------------------------- 

	initAllPlayers() -- local function to initialize and idle all players (including AI)

    for key, player in pairs(currentPlayers) do
      if( player.controlled == true ) then
        controlledPlayer = player -- this is the one and only "controlling" player, who is the user
      end
    end
    
    initializeTeams()
    
	----------------------------------------------- ASSORTED VARIABLES ----------------------------------------------- 	
	
	jumpDirection = 0 -- by default, we only want to jump straight up, unless left or right button is pressed
	
	----------------------------------------------- BUTTONS ----------------------------------------------- 	

	loadedStatus = 1
	gameStartTime = system.getTimer()
	update.update() -- call game update loop code to start the actual game
	--Grid:buildGrid( stagePicked.boundaryTop, stagePicked.boundaryBot )

	--debugTools()
end	

local function delaySliderListener( event )
	activePlayers().interpolationDelay = event.value * 10 -- 0 to 1000
	print("My delay changed to ", event.value, activePlayers().interpolationDelay)
end

local function spriteSizeSliderListener( event )
	activePlayers().sprite.xScale = event.value/38.46
	activePlayers().sprite.yScale = event.value/38.46
	print("Sprite size scale changed to", event.value/38.46)
end

local function gravitySliderListener( event )
	activePlayers().gravity = event.value*15 -- default = 750
	print("Gravity changed to", event.value*15)
end

local function jumpHeightSliderListener( event )
	activePlayers().defaultUy = event.value*17 -- default = 850
	activePlayers().runningUy = event.value*11.6 -- default = 580
	print("Vertical jump speed changed to", event.value*17)
end

local function speedSliderListener( event )
	activePlayers().runningSpeed = event.value/13.888*2*activePlayers().character.runningSpeedFactor -- default = 850
	activePlayers().walkingSpeed = event.value/27.777*2*activePlayers().character.walkingSpeedFactor
	print("Speed factor changed to", activePlayers().runningSpeed / activePlayers().character.runningSpeedFactor )
end

function debugTools()
	if( DebugInstance.tools == true ) then
		local delaySlider = widget.newSlider(
		{
			top = display.contentHeight * 0.2,
			left = display.contentWidth * 0.8,
			width = 200,
			value = 0,
			listener = delaySliderListener
		})

		local spriteSizeSlider = widget.newSlider(
		{
			top = display.contentHeight * 0.25,
			left = display.contentWidth * 0.8,
			width = 200,
			value = 50,
			listener = spriteSizeSliderListener
		})

		local gravitySlider = widget.newSlider(
		{
			top = display.contentHeight * 0.3,
			left = display.contentWidth * 0.8,
			width = 200,
			value = 50,
			listener = gravitySliderListener
		})

		local jumpHeightSlider = widget.newSlider(
		{
			top = display.contentHeight * 0.35,
			left = display.contentWidth * 0.8,
			width = 200,
			value = 50,
			listener = jumpHeightSliderListener
		})

		local speedSlider = widget.newSlider(
		{
			top = display.contentHeight * 0.4,
			left = display.contentWidth * 0.8,
			width = 200,
			value = 50,
			listener = speedSliderListener
		})
	end
end

-- added to fix the system along with character select
-- initializes all players inserted in CharSelect.lua
-- as well as forming a table of opponents for each
function initAllPlayers()	

	for i, p in pairs( currentPlayers ) do	
		p.controls = Controls.new(p)
		p:initialize()
		p:idle()		
	end

	for i, p in pairs( currentPlayers ) do	
		for k, q in pairs( currentPlayers ) do
			if( i ~= k and q.teamNum == 0 or p.teamNum ~= q.teamNum ) then -- if player and p teamNum are both 0, does that contradict last condition?
				table.insert( p.opponents, q )
			end
		end
	end  
end

function removeAllPlayers()	
	-- done before init.unload() is called, in Update.exit()...
	currentPlayers = {}
end

-- currently used in multiplayer
function createOpponent( name, num )
	currentOpponents[1] = Player.new( name, num, false )
	currentOpponents[1]:initialize()
	currentOpponents[1]:idle()
	return currentOpponents[1]
end

function activePlayers()
	for k,v in pairs( currentPlayers ) do
		if( v.controlled == true ) then
			return v -- v being a Player table, see line 77
		end
	end
end

function initializeTeams()
	playerTeam = activePlayers().teamNum
	for k,v in pairs( currentPlayers ) do
		if v.teamNum == playerTeam then
			table.insert(myTeam, v)
		else
			table.insert(oppTeam, v)
		end
	end
end

function activeOpponents()
	for k,v in pairs( currentOpponents ) do
		return v
	end
end

function activeAi()
	for k,v in pairs( currentAi ) do
		return v
	end
end

function getAllAi()
	
	for k,v in pairs( currentAi ) do
		--print( v.name, "belongs to team", v.teamNum )
	end

	return currentAi
end

function callUpdatePosition( status, mpInstance, dirX, dirY )
	update.updatePosition( status, mpInstance, dirX, dirY )
end
