-------------------------------------------------
--
-- main.lua
--
-- This is where the menu gets loaded and clicked
--
-------------------------------------------------

local startLoadingTime = system.getTimer( )

GameController = require( "gameplay.GameController" )
local Item = require( "gameplay.Item" )
local Player = require( "gameplay.Player" )
local ModeSelect = require( "menus.ModeSelect" )
local update = require( "gameplay.update" )
local Effects = require( "gameplay.Effects" )
local Debug = require( "helpers.Debug" )
local Hank_Wall = require( "characters.skills.Hank_Wall" )
local widget = require( "widget" )
local Multiplayer = require( "multiplayer.Multiplayer" )
local update = require( "gameplay.update" )

-- temporary
local udp = require( "multiplayer.udpClient" )

-- copied from: http://developer.coronalabs.com/code/output-fps-and-texture-memory-usage-your-app
local fps = require("libraries.fps")
performance = fps.PerformanceOutput.new();
performance.group.x, performance.group.y = display.contentWidth/2,  0;
performance.alpha = 0.6; -- So it doesn't get in the way of the rest of the scene
--

-- allow debugging
--require("mobdebug").start()
DebugInstance = Debug:new()

-- GGData - data storage class
local GGData = require( "libraries.GGData" )
local box = GGData:new( "data" ) -- if already exists, will load instead
-- first time test to see if I can get a value that doesn't exist
print( "This shouldn't be 'kaitagsd' on initial launch: ", box:get( "username" ) )
box:set( "username", "kaitagsd" )
print( "Now it should be: ", box:get( "username" ) )
box:save()

username = box:get( "username" )

-- example of how to load and save data to external json file
--[[
myTable = {}
myTable.username = "kaitagsd"
myTable.password = "Herochang"
loadsave.saveTable(myTable, "myTable.json")
myTable = loadsave.loadTable("myTable.json")
userName = myTable.username
]]--

userName = system.getInfo( "name" ).." "..system.getInfo( "model")

--

lagComp = update.lagCompTable
system.activate("multitouch")

-- Noobhub
crypto = require("crypto")
require("libraries.noobhub")
hub = noobhub.new({ server = "192.210.143.132"; port = 1337; });
--hub = noobhub.new({ server = "127.0.0.1"; port = 1337; });

local gameOver = false

local detectBallDiffY = display.contentHeight * 0.07

-- game mode
currentGameMode = nil -- either single or multiplayer

-- to not get confused, because in dynamic scaling mode...
screenWidth = display.pixelHeight
screenHeight = display.pixelWidth

-- main menu display group
menu = display.newGroup()

print( "-----DEVICE STATS-----\nScreen Width = ", screenWidth, "\nScreen Height = ", screenHeight, "\nViewableContentWidth", display.viewableContentWidth, "\ndisplay.contentWidth = ", display.contentWidth, "\ndisplay.contentHeight", display.contentHeight )

display.setStatusBar( display.HiddenStatusBar )

----------------------------------------------- SELECTION MENU ----------------------------------------------- 

--> Make a rectangle the same size as the screen
-- notice the use of "display.content_____", which gets the screen's height/width

function mainMenu() 

	menuBg = display.newImageRect( "images/startmenu/mainmenu.png", 1280, 720 )
	menuBg:setReferencePoint( display.CenterLeftReferencePoint )
	menuBg.x = 0
	menuBg.y = display.contentHeight/2

	menub2 = display.newImageRect( "images/startmenu/buildings_2.png", 1280, 720 )
	menub22 = display.newImageRect( "images/startmenu/buildings_2.png", 1280, 720 )
	menub2:setReferencePoint( display.CenterLeftReferencePoint )
	menub22:setReferencePoint( display.CenterLeftReferencePoint )
	menub2.x = 0; menub2.y = display.contentHeight/2
	menub22.x = -menub22.contentWidth; menub22.y = display.contentHeight/2

	menub1 = display.newImageRect( "images/startmenu/buildings_1.png", 1280, 720 )
	menub12 = display.newImageRect( "images/startmenu/buildings_1.png", 1280, 720 )
	menub1:setReferencePoint( display.CenterLeftReferencePoint )
	menub12:setReferencePoint( display.CenterLeftReferencePoint )
	menub1.x = 0; menub1.y = display.contentHeight/2
	menub12.x = -menub12.contentWidth; menub12.y = display.contentHeight/2

	menuLights = display.newImageRect( "images/startmenu/lights.png", 1280, 720 )
	menuLights2 = display.newImageRect( "images/startmenu/lights.png", 1280, 720 )
	menuLights:setReferencePoint( display.CenterLeftReferencePoint )
	menuLights2:setReferencePoint( display.CenterLeftReferencePoint )
	menuLights.x = 0; menuLights.y = display.contentHeight/2
	menuLights2.x = -menuLights2.contentWidth; menuLights2.y = display.contentHeight/2

	start = display.newImageRect( "images/startmenu/start.png", 165, 165 )
	start:setReferencePoint( display.CenterReferencePoint )
	start.x = display.contentWidth*0.48; start.y = display.contentHeight*0.7

	start:scale(2,2)
	-- tween button
	transition.to( start, { time = 400, yScale = 1, xScale = 1, transition = continuousLoop, iterations = 1 } )
	
	startBtn = display.newRect( display.contentWidth*271/640,display.contentHeight*206/360,display.contentWidth*(352-271)/640,display.contentHeight*(285-206)/360)
	
	menu:insert( 1, startBtn )
	menu:insert( 2, menuBg )
	menu:insert( 3, menub2 )
	menu:insert( 4, menub22 )
	menu:insert( 5, menub1 )
	menu:insert( 6, menub12 )
	menu:insert( 7, menuLights )
	menu:insert( 8, menuLights2 )
	menu:insert( 9, start )

	scrollSpeedFast = display.contentWidth * 0.01
	scrollSpeedMedium = display.contentWidth * 0.005
	scrollSpeedSlow = display.contentWidth * 0.0025 

	local function scrollFast()	

		menuLights:translate(scrollSpeedFast,0)
		menuLights2:translate(scrollSpeedFast,0)

		if( menuLights.x + scrollSpeedFast > menuLights.contentWidth ) then
			menuLights:translate(-menuLights.contentWidth*2,0)
		elseif( menuLights2.x + scrollSpeedFast > menuLights2.contentWidth ) then
			menuLights2:translate(-menuLights2.contentWidth*2,0)
		end		
	end

	local function scrollMedium()
		menub1:translate(scrollSpeedMedium,0)
		menub12:translate(scrollSpeedMedium,0)

		if( menub1.x + scrollSpeedMedium > menub1.contentWidth ) then
			menub1:translate(-menub1.contentWidth*2,0)
		elseif( menub12.x + scrollSpeedMedium > menub12.contentWidth ) then --and scrollingFastM == true ) then
			menub12:translate(-menub12.contentWidth*2,0)
		end
	end

	local function scrollSlow()		
		menub22:translate(scrollSpeedSlow,0)
		menub2:translate(scrollSpeedSlow,0)

		if( menub2.x + scrollSpeedSlow > menub2.contentWidth ) then
			menub2:translate( -menub2.contentWidth*2, 0 )
		elseif( menub22.x + scrollSpeedSlow > menub22.contentWidth ) then
			menub22:translate( -menub22.contentWidth*2, 0 )
		end
	end

	local function keepLayers()
		start:toFront()
	end		

	-- scroll buildings across screen, give the timers an "id" to stop them later
	local mf = timer.performWithDelay( 25, scrollFast, 0 )
	local mm = timer.performWithDelay( 25, scrollMedium, 0 )
	local ms = timer.performWithDelay( 25, scrollSlow, 0 )
	local kl = timer.performWithDelay( 25, keepLayers, 0 )

	function startBtn:touch( event )
		if event.phase == "began" then
			timer.cancel( mf )
			timer.cancel( mm )
			timer.cancel( ms )
			timer.cancel( kl )

			-- Transitioning to another screen:
			-- use the below command, with removeObject as well, which is like some built-in API
			-- transition is done in ModeSelect:drawMenu as well

			transition.to( menu, { time=500, alpha=0, onComplete=removeObject } )

			if(Debug.quickstart == true) then
				goToMultiplayerAsHankBtn:removeSelf()
				goToMultiplayerAsHeroBtn:removeSelf()
				goToSingleplayerAsHankBtn:removeSelf()
				goToSingleplayerAsHeroBtn:removeSelf()
			end
			startBtn:removeSelf()
			ModeSelect:drawMenu()
			--CharSelect:loadNow( "single" )
			return true
		end
	end

	startBtn:addEventListener( "touch", startBtn )

	playersFound = {}
	playerAlreadyFound = false
	count = 0
	requestedOpponent = nil


	if( Debug.quickstart == true ) then
		local quickstart = false

		-- MUCH, MUCH NEEDED QUICKSTART BUTTONS!!!
		-- press these buttons to go directly to multiplayer screen with chosen character.
		function goToMultiplayerAsHero(event)
			if( quickstart == false ) then
				quickstart = true
				currentGameMode = "multiplayer"
				menu.isVisible = false
				startBtn.isVisible = false
				Multiplayer:drawMenu( menu, "Hero" )
			end
		end

		function goToSingleplayerAsHero( event )
			if( event.phase == "began" and quickstart == false ) then
				quickstart = true
				currentGameMode = "single"
				table.insert( GameController.allPlayers, Player.new( "Hero", 1, true, false, 1 ) ) -- name, teamNum, controlled, isAI, id
				table.insert( GameController.allPlayers, Player.new( "Hank", 2, false, Debug.botsOn, 1 ) )
				timer.performWithDelay( 500, function()
				menu.isVisible = false
				startBtn.isVisible = false
				GameController:load("single")
				end)
				return true
			elseif event.phase == "ended" then
				return false
			end
		end	

		function goToMultiplayerAsHank(event)
			if( quickstart == false ) then
				quickstart = true
				currentGameMode = "multiplayer"
				menu.isVisible = false
				startBtn.isVisible = false
				Multiplayer:drawMenu( menu, "Hank" )
			end
		end

		function goToSingleplayerAsHank( event )
			if( event.phase == "began" and quickstart == false ) then
				quickstart = true
				currentGameMode = "single"
				table.insert( GameController.allPlayers, Player.new( "Hank", 1, true, false, 1 ) ) -- name, teamNum, controlled, isAI, id, custom table
				table.insert( GameController.allPlayers, Player.new( "Hank", 2, false, Debug.botsOn, 2 ) )
				--table.insert( GameController.allPlayers, Player.new( "Hero", 2, false, Debug.botsOn, 3, { x = 500, y = 500 } ) )
				timer.performWithDelay( 500, function()
					menu.isVisible = false
					startBtn.isVisible = false
					GameController:load("single")
				end)
				return true
			elseif event.phase == "ended" then
				return false
			end
		end	
	
		goToMultiplayerAsHeroBtn = widget.newButton( 
		{
			id = "hero",
			defaultFile = "images/hero.png",
			overFile = "images/hero2.png",
			onEvent = goToMultiplayerAsHero
		} )

		goToSingleplayerAsHeroBtn = widget.newButton( 
		{
			id = "hero",
			defaultFile = "images/hero.png",
			overFile = "images/hero2.png",
			onEvent = goToSingleplayerAsHero
		} )

		goToMultiplayerAsHankBtn = widget.newButton( 
		{
			id = "hank",
			defaultFile = "images/hank.png",
			overFile = "images/hank2.png",
			onEvent = goToMultiplayerAsHank
		} )

		goToSingleplayerAsHankBtn = widget.newButton( 
		{
			id = "hank",
			defaultFile = "images/hank.png",
			overFile = "images/hank2.png",
			onEvent = goToSingleplayerAsHank
		} )

		-- Handle press events for the checkbox
		local function onSwitchPress( event )
		    if event.phase == "began" then
		    	Debug.botsOn = not Debug.botsOn
		  --   	udp:init()
		  --   	timer.performWithDelay( 500, function()
				-- 	udp:sayHello()
				-- end, 0 )
		    	return true
		    end
		end

		-- Create the widget
		local onOffSwitch = widget.newButton
		{
		    left = 250,
		    top = 200,
		    style = "onOff",
		    label ="Turn bots on (press once)",
		    onEvent = onSwitchPress
		}

		goToMultiplayerAsHeroBtn:setReferencePoint(display.CenterReferencePoint)
		goToMultiplayerAsHeroBtn.x = display.contentWidth*0.36
		goToMultiplayerAsHeroBtn.y = display.contentHeight*0.66
		goToMultiplayerAsHankBtn:setReferencePoint(display.CenterReferencePoint)
		goToMultiplayerAsHankBtn.x = display.contentWidth*0.60
		goToMultiplayerAsHankBtn.y = display.contentHeight*0.66

		goToSingleplayerAsHeroBtn:setReferencePoint(display.CenterReferencePoint)
		goToSingleplayerAsHeroBtn.x = display.contentWidth*0.28
		goToSingleplayerAsHeroBtn.y = display.contentHeight*0.66
		goToSingleplayerAsHankBtn:setReferencePoint(display.CenterReferencePoint)
		goToSingleplayerAsHankBtn.x = display.contentWidth*0.68
		goToSingleplayerAsHankBtn.y = display.contentHeight*0.66

		quickStartGroup = display.newGroup()
		quickStartGroup:insert( goToSingleplayerAsHankBtn )
		quickStartGroup:insert( goToMultiplayerAsHankBtn )
		quickStartGroup:insert( goToSingleplayerAsHeroBtn )
		quickStartGroup:insert( goToMultiplayerAsHeroBtn )
		quickStartGroup:insert( onOffSwitch )

		menu:insert(quickStartGroup)

		performance.group:toFront()
	end
end

mainMenu()

local stopLoadingTime = system.getTimer( )
print("**Loading time = "..tostring(stopLoadingTime-startLoadingTime))

function startUpdateLoop()
	update.update()
end

-- removes update listener
function gameOverReturn()
	if( gameOver == false ) then
		gameOver = true

		gameOverText = display.newImage( "images/gameover.png" )
		gameOverText.x = display.contentWidth/2
		gameOverText.y = display.contentHeight/2
		gameOverText:addEventListener( "tap", returnToMenu )
	end
end

-- might want to implement storyboard here
function returnToMenu()
	-- remove elements and listeners
	Runtime:removeEventListener("enterFrame", updateLoop)
	-- unsubscribe if multiplayer
	-- go back to main menu (or some reward collection)
	mainMenu()
end

