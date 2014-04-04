Hero_Ball = require( "characters.skills.Hero_Ball" )
Hero_Slam = require( "characters.skills.Hero_Slam" )

-- SPECIAL NOTE (10/15):
-- the time for animation in punch2 and finalpunch are longer than normal punches
-- there is a character variable called punch2 and punch3 delay. It is half of the animation or so
-- it is used in Player:attack() to regulate the delay before the hit should actually register

local seqData = 
	{		
		-- name = the action
		-- start = the first frame at which the animation starts
		-- count = how many consecutive frames. Punch starts at 35 and has count of 4, so it uses frames 35,36,37,38
		-- time = the amount of time it takes to play through those frames
		-- loopCount = 1 means play once, 0 means play infinitely until something else plays
		{ name="defend", start = 1, count = 2, time = 200, loopCount = 1 },
		{ name="defend finished", start = 3, count = 1, time = 200, loopCount = 1 },
		{ name="fallen", start = 4, count = 1, time = 2000, loopCount = 0 },
		{ name="falling", start = 5, count = 7 , time = 750, loopCount = 1 }, -- includes bounce
		{ name="falling1", start = 5, count = 3, time = 300, loopCount = 1 }, -- first arc of the fall
		{ name="falling2", start = 9, count = 1, time = 150, loopCount = 1 }, -- second arc (depends on character sprites)
		{ name="falling bounce", start = 9, count = 3, time = 300, loopCount = 1 },
		{ name="getup", start = 14, count = 2, time = 500, loopCount = 1 },
		{ name="flinch", start = 12, count = 2, time = 300, loopCount = 1 },
		{ name="long flinch", start = 12, count = 2, time = 300, loopCount = 0 },
		{ name="stunned", start = 12, count = 2, time = 500, loopCount = 0 }, -- SAME AS LONG FLINCH.... but 500 ms
		{ name="idle", start = 16, count = 5, time = 1000, loopCount = 0 },
		{ name="jump kick", start = 21, count = 2, time = 200, loopCount = 1},
		{ name="jump", frames = { 26, 29 }, time = 700, loopCount = 1 },
		{ name="punch", start = 32, count = 5, time = 100, loopCount = 1 }, -- even more intense
		{ name="punch2", start = 37, count = 3, time = 100, loopCount = 1 }, -- even more intense
		{ name="punch3", start = 41, count = 6, time = 800, loopCount = 1 },
		{ name="running attack", start = 41, count = 6, time = 600, loopCount = 1 }, -- this is used for run atk time
		{ name="recover", start = 49, count = 4, time = 500, loopCount = 1 },
		{ name="run", start = 53, count = 4, time = 480, loopCount = 0 },
		{ name="throwing", start = 57, count = 3, time = 300, loopCount = 1 },
		{ name="walk", start = 60, count = 4, time = 500, loopCount = 0 },
		{ name="dodge", start = 64, count = 6, time = 500, loopCount = 1 },

		{ name="attachedToSpin", start = 7, count = 1, time = 300, loopCount = 0 }, -- for hanks DvA skill
		
		{ name="grab", start = 71, count = 1, time = 1, loopCount = 0 },
		{ name="grabbed", start = 72, count = 1, time = 1, loopCount = 0 },
		{ name="grab punch", start = 73, count = 2, time = 200, loopCount = 1 },

		{ name="throw opponent", start = 77, count = 2, time = 300, loopCount = 1 },
		{ name="pickup" , start = 25, count = 1, time = 300, loopCount = 1 },
	}

local seqData2 =
	{
		{ name="dlrj1", start = 1, count = 6, time = 700, loopCount = 1 }, -- charging
		{ name="dlrj2", start = 7, count = 3, time = 350, loopCount = 0 }, -- attack 1
		{ name="duj1", start = 11, count = 8, time = 500, loopCount = 1 },
		{ name="duj2", start = 19, count = 1, time = 500, loopCount = 1 },		
		{ name="dvj1", start = 21, count = 8, time = 1000, loopCount = 1 },
		{ name="dvj2", start = 29, count = 3, time = 150, loopCount = 0 },
		{ name="dvj3", start = 32, count = 1, time = 500, loopCount = 1 },
	}	

local seqData3 = 
{
	{ name="dlra", start = 1, count = 9, time = 1000, loopCount = 1 },	
	{ name="dua1", start = 10, count = 5, time = 400, loopCount = 1 },
	{ name="dua2", frames = { 16, 17, 18, 19 }, time = 300, loopCount = 0 },
	{ name="dva", start = 22, count = 11, time = 1200, loopCount = 1 },
}
	
local data = {
	frames = {
		{ name=defend2, x = 474, y = 316, width = 156, height = 156, sourceX=0, sourceY=0, sourceWidth=156 , sourceHeight=156 },
		{ name=defend3, x = 948, y = 485, width = 156, height = 156, sourceX=0, sourceY=0, sourceWidth=156 , sourceHeight=156 },
		{ name=defend4, x = 948, y = 327, width = 156, height = 156, sourceX=0, sourceY=0, sourceWidth=156 , sourceHeight=156 },
		{ name=fallen, x = 948, y = 158, width = 156, height = 167, sourceX=0, sourceY=0, sourceWidth=156 , sourceHeight=167 },
		{ name=falling1, x = 948, y = 0, width = 156, height = 156, sourceX=0, sourceY=0, sourceWidth=156 , sourceHeight=156 },
		{ name=falling2, x = 790, y = 1738, width = 156, height = 156, sourceX=0, sourceY=0, sourceWidth=156 , sourceHeight=156 },
		{ name=falling3, x = 790, y = 1580, width = 156, height = 156, sourceX=0, sourceY=0, sourceWidth=156 , sourceHeight=156 },
		{ name=falling4, x = 790, y = 1422, width = 156, height = 156, sourceX=0, sourceY=0, sourceWidth=156 , sourceHeight=156 },
		{ name=fallingbounce1, x = 790, y = 1264, width = 156, height = 156, sourceX=0, sourceY=0, sourceWidth=156 , sourceHeight=156 },
		{ name=fallingbounce2, x = 790, y = 1106, width = 156, height = 156, sourceX=0, sourceY=0, sourceWidth=156 , sourceHeight=156 },
		{ name=fallingbounce3, x = 790, y = 1264, width = 156, height = 156, sourceX=0, sourceY=0, sourceWidth=156 , sourceHeight=156 },
		{ name=flinch01, x = 790, y = 948, width = 156, height = 156, sourceX=0, sourceY=0, sourceWidth=156 , sourceHeight=156 },
		{ name=flinch02, x = 790, y = 790, width = 156, height = 156, sourceX=0, sourceY=0, sourceWidth=156 , sourceHeight=156 },
		{ name=getup1, x = 790, y = 632, width = 156, height = 156, sourceX=0, sourceY=0, sourceWidth=156 , sourceHeight=156 },
		{ name=getup2, x = 790, y = 474, width = 156, height = 156, sourceX=0, sourceY=0, sourceWidth=156 , sourceHeight=156 },
		{ name=idle01, x = 790, y = 316, width = 156, height = 156, sourceX=0, sourceY=0, sourceWidth=156 , sourceHeight=156 },
		{ name=idle02, x = 790, y = 158, width = 156, height = 156, sourceX=0, sourceY=0, sourceWidth=156 , sourceHeight=156 },
		{ name=idle03, x = 790, y = 0, width = 156, height = 156, sourceX=0, sourceY=0, sourceWidth=156 , sourceHeight=156 },
		{ name=idle04, x = 632, y = 1760, width = 156, height = 156, sourceX=0, sourceY=0, sourceWidth=156 , sourceHeight=156 },
		{ name=idle05, x = 632, y = 1602, width = 156, height = 156, sourceX=0, sourceY=0, sourceWidth=156 , sourceHeight=156 },
		{ name=jp1, x = 632, y = 1444, width = 156, height = 156, sourceX=0, sourceY=0, sourceWidth=156 , sourceHeight=156 },
		{ name=jp2, x = 632, y = 1286, width = 156, height = 156, sourceX=0, sourceY=0, sourceWidth=156 , sourceHeight=156 },
		{ name=jump01, x = 632, y = 1128, width = 156, height = 156, sourceX=0, sourceY=0, sourceWidth=156 , sourceHeight=156 },
		{ name=jump02, x = 632, y = 970, width = 156, height = 156, sourceX=0, sourceY=0, sourceWidth=156 , sourceHeight=156 },
		{ name=jump03, x = 632, y = 812, width = 156, height = 156, sourceX=0, sourceY=0, sourceWidth=156 , sourceHeight=156 },
		{ name=jump04, x = 632, y = 643, width = 156, height = 167, sourceX=0, sourceY=0, sourceWidth=156 , sourceHeight=167 },
		{ name=jump05, x = 632, y = 485, width = 156, height = 156, sourceX=0, sourceY=0, sourceWidth=156 , sourceHeight=156 },
		{ name=jump06, x = 632, y = 316, width = 156, height = 167, sourceX=0, sourceY=0, sourceWidth=156 , sourceHeight=167 },
		{ name=jump07, x = 632, y = 158, width = 156, height = 156, sourceX=0, sourceY=0, sourceWidth=156 , sourceHeight=156 },
		{ name=jump08, x = 632, y = 0, width = 156, height = 156, sourceX=0, sourceY=0, sourceWidth=156 , sourceHeight=156 },
		{ name=jump09, x = 474, y = 1738, width = 156, height = 156, sourceX=0, sourceY=0, sourceWidth=156 , sourceHeight=156 },
		{ name=punch01, x = 474, y = 1580, width = 156, height = 156, sourceX=0, sourceY=0, sourceWidth=156 , sourceHeight=156 },
		{ name=punch02, x = 474, y = 1422, width = 156, height = 156, sourceX=0, sourceY=0, sourceWidth=156 , sourceHeight=156 },
		{ name=punch03, x = 474, y = 1264, width = 156, height = 156, sourceX=0, sourceY=0, sourceWidth=156 , sourceHeight=156 },
		{ name=punch04, x = 474, y = 1106, width = 156, height = 156, sourceX=0, sourceY=0, sourceWidth=156 , sourceHeight=156 },
		{ name=punch05, x = 474, y = 948, width = 156, height = 156, sourceX=0, sourceY=0, sourceWidth=156 , sourceHeight=156 },
		{ name=punch06, x = 474, y = 790, width = 156, height = 156, sourceX=0, sourceY=0, sourceWidth=156 , sourceHeight=156 },
		{ name=punch07, x = 474, y = 632, width = 156, height = 156, sourceX=0, sourceY=0, sourceWidth=156 , sourceHeight=156 },
		{ name=punch08, x = 474, y = 474, width = 156, height = 156, sourceX=0, sourceY=0, sourceWidth=156 , sourceHeight=156 },
		{ name=punch09, x = 948, y = 643, width = 156, height = 156, sourceX=0, sourceY=0, sourceWidth=156 , sourceHeight=156 },
		{ name=punch10, x = 474, y = 158, width = 156, height = 156, sourceX=0, sourceY=0, sourceWidth=156 , sourceHeight=156 },
		{ name=punch11, x = 474, y = 0, width = 156, height = 156, sourceX=0, sourceY=0, sourceWidth=156 , sourceHeight=156 },
		{ name=punch12, x = 316, y = 1738, width = 156, height = 156, sourceX=0, sourceY=0, sourceWidth=156 , sourceHeight=156 },
		{ name=punch13, x = 316, y = 1580, width = 156, height = 156, sourceX=0, sourceY=0, sourceWidth=156 , sourceHeight=156 },
		{ name=punch14, x = 316, y = 1422, width = 156, height = 156, sourceX=0, sourceY=0, sourceWidth=156 , sourceHeight=156 },
		{ name=punch15, x = 316, y = 1264, width = 156, height = 156, sourceX=0, sourceY=0, sourceWidth=156 , sourceHeight=156 },
		{ name=punch16, x = 316, y = 1106, width = 156, height = 156, sourceX=0, sourceY=0, sourceWidth=156 , sourceHeight=156 },
		{ name=punch17, x = 316, y = 948, width = 156, height = 156, sourceX=0, sourceY=0, sourceWidth=156 , sourceHeight=156 },
		{ name=recover2, x = 316, y = 790, width = 156, height = 156, sourceX=0, sourceY=0, sourceWidth=156 , sourceHeight=156 },
		{ name=recover3, x = 316, y = 632, width = 156, height = 156, sourceX=0, sourceY=0, sourceWidth=156 , sourceHeight=156 },
		{ name=recover4, x = 316, y = 474, width = 156, height = 156, sourceX=0, sourceY=0, sourceWidth=156 , sourceHeight=156 },
		{ name=recover5, x = 316, y = 316, width = 156, height = 156, sourceX=0, sourceY=0, sourceWidth=156 , sourceHeight=156 },
		{ name=run1, x = 316, y = 158, width = 156, height = 156, sourceX=0, sourceY=0, sourceWidth=156 , sourceHeight=156 },
		{ name=run2, x = 316, y = 0, width = 156, height = 156, sourceX=0, sourceY=0, sourceWidth=156 , sourceHeight=156 },
		{ name=run3, x = 158, y = 1738, width = 156, height = 156, sourceX=0, sourceY=0, sourceWidth=156 , sourceHeight=156 },
		{ name=run4, x = 158, y = 1580, width = 156, height = 156, sourceX=0, sourceY=0, sourceWidth=156 , sourceHeight=156 },
		{ name=throwing01, x = 158, y = 1422, width = 156, height = 156, sourceX=0, sourceY=0, sourceWidth=156 , sourceHeight=156 },
		{ name=throwing02, x = 158, y = 1264, width = 156, height = 156, sourceX=0, sourceY=0, sourceWidth=156 , sourceHeight=156 },
		{ name=throwing03, x = 158, y = 1106, width = 156, height = 156, sourceX=0, sourceY=0, sourceWidth=156 , sourceHeight=156 },
		{ name=walk01, x = 158, y = 948, width = 156, height = 156, sourceX=0, sourceY=0, sourceWidth=156 , sourceHeight=156 },
		{ name=walk02, x = 158, y = 790, width = 156, height = 156, sourceX=0, sourceY=0, sourceWidth=156 , sourceHeight=156 },
		{ name=walk03, x = 158, y = 632, width = 156, height = 156, sourceX=0, sourceY=0, sourceWidth=156 , sourceHeight=156 },
		{ name=walk04, x = 158, y = 474, width = 156, height = 156, sourceX=0, sourceY=0, sourceWidth=156 , sourceHeight=156 },
		{ name=zdodge2, x = 158, y = 316, width = 156, height = 156, sourceX=0, sourceY=0, sourceWidth=156 , sourceHeight=156 },
		{ name=zdodge3, x = 158, y = 158, width = 156, height = 156, sourceX=0, sourceY=0, sourceWidth=156 , sourceHeight=156 },
		{ name=zdodge4, x = 158, y = 0, width = 156, height = 156, sourceX=0, sourceY=0, sourceWidth=156 , sourceHeight=156 },
		{ name=zdodge5, x = 0, y = 1738, width = 156, height = 156, sourceX=0, sourceY=0, sourceWidth=156 , sourceHeight=156 },
		{ name=zdodge6, x = 0, y = 1580, width = 156, height = 156, sourceX=0, sourceY=0, sourceWidth=156 , sourceHeight=156 },
		{ name=zdodge7, x = 0, y = 1422, width = 156, height = 156, sourceX=0, sourceY=0, sourceWidth=156 , sourceHeight=156 },
		{ name=zdodge8, x = 0, y = 1264, width = 156, height = 156, sourceX=0, sourceY=0, sourceWidth=156 , sourceHeight=156 },
		{ name=zgrab, x = 0, y = 1106, width = 156, height = 156, sourceX=0, sourceY=0, sourceWidth=156 , sourceHeight=156 },
		{ name=zgrabbed, x = 0, y = 948, width = 156, height = 156, sourceX=0, sourceY=0, sourceWidth=156 , sourceHeight=156 },
		{ name=zgrabpunch1, x = 0, y = 790, width = 156, height = 156, sourceX=0, sourceY=0, sourceWidth=156 , sourceHeight=156 },
		{ name=zgrabpunch2, x = 0, y = 632, width = 156, height = 156, sourceX=0, sourceY=0, sourceWidth=156 , sourceHeight=156 },
		{ name=zheavythrow1, x = 0, y = 474, width = 156, height = 156, sourceX=0, sourceY=0, sourceWidth=156 , sourceHeight=156 },
		{ name=zheavythrow2, x = 0, y = 316, width = 156, height = 156, sourceX=0, sourceY=0, sourceWidth=156 , sourceHeight=156 },
		{ name=zheavythrow3, x = 0, y = 158, width = 156, height = 156, sourceX=0, sourceY=0, sourceWidth=156 , sourceHeight=156 },
		{ name=zheavythrow4, x = 0, y = 0, width = 156, height = 156, sourceX=0, sourceY=0, sourceWidth=156 , sourceHeight=156 },
	},
	sheetContentWidth = 2048,
	sheetContentHeight = 2048
}

local data2 =  {
	frames = {
		{ name=dlrj01, x = 630, y = 630, width = 313, height = 313, sourceX=0, sourceY=0, sourceWidth=313 , sourceHeight=313 },
		{ name=dlrj02, x = 945, y = 0, width = 313, height = 313, sourceX=0, sourceY=0, sourceWidth=313 , sourceHeight=313 },
		{ name=dlrj03, x = 945, y = 315, width = 313, height = 313, sourceX=0, sourceY=0, sourceWidth=313 , sourceHeight=313 },
		{ name=dlrj04, x = 630, y = 945, width = 313, height = 313, sourceX=0, sourceY=0, sourceWidth=313 , sourceHeight=313 },
		{ name=dlrj05, x = 630, y = 1260, width = 313, height = 313, sourceX=0, sourceY=0, sourceWidth=313 , sourceHeight=313 },
		{ name=dlrj06, x = 1260, y = 0, width = 313, height = 313, sourceX=0, sourceY=0, sourceWidth=313 , sourceHeight=313 },
		{ name=dlrj07, x = 945, y = 945, width = 313, height = 313, sourceX=0, sourceY=0, sourceWidth=313 , sourceHeight=313 },
		{ name=dlrj08, x = 945, y = 1260, width = 313, height = 313, sourceX=0, sourceY=0, sourceWidth=313 , sourceHeight=313 },
		{ name=dlrj09, x = 1260, y = 315, width = 313, height = 313, sourceX=0, sourceY=0, sourceWidth=313 , sourceHeight=313 },
		{ name=dlrj10, x = 945, y = 630, width = 313, height = 313, sourceX=0, sourceY=0, sourceWidth=313 , sourceHeight=313 },
		{ name=duj01, x = 1418, y = 1104, width = 156, height = 156, sourceX=0, sourceY=0, sourceWidth=156 , sourceHeight=156 },
		{ name=duj02, x = 1418, y = 788, width = 156, height = 156, sourceX=0, sourceY=0, sourceWidth=156 , sourceHeight=156 },
		{ name=duj03, x = 1260, y = 946, width = 156, height = 156, sourceX=0, sourceY=0, sourceWidth=156 , sourceHeight=156 },
		{ name=duj04, x = 1260, y = 630, width = 156, height = 156, sourceX=0, sourceY=0, sourceWidth=156 , sourceHeight=156 },
		{ name=duj05, x = 1260, y = 1262, width = 156, height = 156, sourceX=0, sourceY=0, sourceWidth=156 , sourceHeight=156 },
		{ name=duj06, x = 1418, y = 630, width = 156, height = 156, sourceX=0, sourceY=0, sourceWidth=156 , sourceHeight=156 },
		{ name=duj07, x = 1418, y = 1262, width = 156, height = 156, sourceX=0, sourceY=0, sourceWidth=156 , sourceHeight=156 },
		{ name=duj08, x = 1260, y = 1104, width = 156, height = 156, sourceX=0, sourceY=0, sourceWidth=156 , sourceHeight=156 },
		{ name=duj09, x = 1260, y = 788, width = 156, height = 156, sourceX=0, sourceY=0, sourceWidth=156 , sourceHeight=156 },
		{ name=duj10, x = 1418, y = 946, width = 156, height = 156, sourceX=0, sourceY=0, sourceWidth=156 , sourceHeight=156 },
		{ name=dvj01, x = 630, y = 315, width = 313, height = 313, sourceX=0, sourceY=0, sourceWidth=313 , sourceHeight=313 },
		{ name=dvj02, x = 630, y = 0, width = 313, height = 313, sourceX=0, sourceY=0, sourceWidth=313 , sourceHeight=313 },
		{ name=dvj03, x = 315, y = 1260, width = 313, height = 313, sourceX=0, sourceY=0, sourceWidth=313 , sourceHeight=313 },
		{ name=dvj04, x = 315, y = 945, width = 313, height = 313, sourceX=0, sourceY=0, sourceWidth=313 , sourceHeight=313 },
		{ name=dvj05, x = 315, y = 630, width = 313, height = 313, sourceX=0, sourceY=0, sourceWidth=313 , sourceHeight=313 },
		{ name=dvj06, x = 315, y = 315, width = 313, height = 313, sourceX=0, sourceY=0, sourceWidth=313 , sourceHeight=313 },
		{ name=dvj07, x = 315, y = 0, width = 313, height = 313, sourceX=0, sourceY=0, sourceWidth=313 , sourceHeight=313 },
		{ name=dvj08, x = 0, y = 1260, width = 313, height = 313, sourceX=0, sourceY=0, sourceWidth=313 , sourceHeight=313 },
		{ name=dvj09, x = 0, y = 945, width = 313, height = 313, sourceX=0, sourceY=0, sourceWidth=313 , sourceHeight=313 },
		{ name=dvj10, x = 0, y = 630, width = 313, height = 313, sourceX=0, sourceY=0, sourceWidth=313 , sourceHeight=313 },
		{ name=dvj11, x = 0, y = 315, width = 313, height = 313, sourceX=0, sourceY=0, sourceWidth=313 , sourceHeight=313 },
		{ name=dvj12, x = 0, y = 0, width = 313, height = 313, sourceX=0, sourceY=0, sourceWidth=313 , sourceHeight=313 },
	},
	sheetContentWidth = 1576,
	sheetContentHeight = 1575
}

local data3 = {
	frames = {
		{ name=dlra01, x = 947, y = 632, width = 156, height = 156, sourceX=0, sourceY=0, sourceWidth=156 , sourceHeight=156 },
		{ name=dlra02, x = 947, y = 474, width = 156, height = 156, sourceX=0, sourceY=0, sourceWidth=156 , sourceHeight=156 },
		{ name=dlra03, x = 946, y = 316, width = 156, height = 156, sourceX=0, sourceY=0, sourceWidth=156 , sourceHeight=156 },
		{ name=dlra04, x = 946, y = 158, width = 156, height = 156, sourceX=0, sourceY=0, sourceWidth=156 , sourceHeight=156 },
		{ name=dlra05, x = 946, y = 0, width = 156, height = 156, sourceX=0, sourceY=0, sourceWidth=156 , sourceHeight=156 },
		{ name=dlra06, x = 789, y = 894, width = 156, height = 156, sourceX=0, sourceY=0, sourceWidth=156 , sourceHeight=156 },
		{ name=dlra07, x = 789, y = 736, width = 156, height = 156, sourceX=0, sourceY=0, sourceWidth=156 , sourceHeight=156 },
		{ name=dlra08, x = 789, y = 578, width = 156, height = 156, sourceX=0, sourceY=0, sourceWidth=156 , sourceHeight=156 },
		{ name=dlra09, x = 788, y = 420, width = 156, height = 156, sourceX=0, sourceY=0, sourceWidth=156 , sourceHeight=156 },
		{ name=dua01, x = 0, y = 316, width = 313, height = 156, sourceX=0, sourceY=0, sourceWidth=313 , sourceHeight=156 },
		{ name=dua02, x = 0, y = 948, width = 313, height = 156, sourceX=0, sourceY=0, sourceWidth=313 , sourceHeight=156 },
		{ name=dua03, x = 0, y = 632, width = 313, height = 156, sourceX=0, sourceY=0, sourceWidth=313 , sourceHeight=156 },
		{ name=dua04, x = 0, y = 790, width = 313, height = 156, sourceX=0, sourceY=0, sourceWidth=313 , sourceHeight=156 },
		{ name=dua05, x = 315, y = 474, width = 313, height = 156, sourceX=0, sourceY=0, sourceWidth=313 , sourceHeight=156 },
		{ name=dua06, x = 315, y = 158, width = 313, height = 156, sourceX=0, sourceY=0, sourceWidth=313 , sourceHeight=156 },
		{ name=dua07, x = 0, y = 0, width = 313, height = 156, sourceX=0, sourceY=0, sourceWidth=313 , sourceHeight=156 },
		{ name=dua08, x = 315, y = 316, width = 313, height = 156, sourceX=0, sourceY=0, sourceWidth=313 , sourceHeight=156 },
		{ name=dua09, x = 315, y = 632, width = 313, height = 156, sourceX=0, sourceY=0, sourceWidth=313 , sourceHeight=156 },
		{ name=dua10, x = 0, y = 474, width = 313, height = 156, sourceX=0, sourceY=0, sourceWidth=313 , sourceHeight=156 },
		{ name=dua11, x = 0, y = 158, width = 313, height = 156, sourceX=0, sourceY=0, sourceWidth=313 , sourceHeight=156 },
		{ name=dua12, x = 315, y = 0, width = 313, height = 156, sourceX=0, sourceY=0, sourceWidth=313 , sourceHeight=156 },
		{ name=dva01, x = 947, y = 632, width = 156, height = 156, sourceX=0, sourceY=0, sourceWidth=156 , sourceHeight=156 },
		{ name=dva02, x = 315, y = 790, width = 156, height = 156, sourceX=0, sourceY=0, sourceWidth=156 , sourceHeight=156 },
		{ name=dva03, x = 315, y = 948, width = 156, height = 156, sourceX=0, sourceY=0, sourceWidth=156 , sourceHeight=156 },
		{ name=dva04, x = 473, y = 790, width = 156, height = 208, sourceX=0, sourceY=0, sourceWidth=156 , sourceHeight=208 },
		{ name=dva05, x = 630, y = 420, width = 156, height = 208, sourceX=0, sourceY=0, sourceWidth=156 , sourceHeight=208 },
		{ name=dva06, x = 631, y = 630, width = 156, height = 208, sourceX=0, sourceY=0, sourceWidth=156 , sourceHeight=208 },
		{ name=dva07, x = 630, y = 210, width = 156, height = 208, sourceX=0, sourceY=0, sourceWidth=156 , sourceHeight=208 },
		{ name=dva08, x = 788, y = 0, width = 156, height = 208, sourceX=0, sourceY=0, sourceWidth=156 , sourceHeight=208 },
		{ name=dva09, x = 788, y = 210, width = 156, height = 208, sourceX=0, sourceY=0, sourceWidth=156 , sourceHeight=208 },
		{ name=dva10, x = 631, y = 840, width = 156, height = 208, sourceX=0, sourceY=0, sourceWidth=156 , sourceHeight=208 },
		{ name=dva11, x = 630, y = 0, width = 156, height = 208, sourceX=0, sourceY=0, sourceWidth=156 , sourceHeight=208 },
	},
	sheetContentWidth = 1105,
	sheetContentHeight = 1106
}

local sheet = graphics.newImageSheet( "images/hero/hero.png", data )
local sheet2 = graphics.newImageSheet( "images/hero/herojumpskills.png", data2 )
local sheet3 = graphics.newImageSheet( "images/hero/heroattackskills.png", data3 )

local Hero = {

	-- walking and running speeds
	runningSpeedFactor = 1.5,
	walkingSpeedFactor = 1.5,

	-- list of ranged skills
	rangedSkills = { "dlra", "dlrj" },
	-- list of melee skills
	meleeSkills = { "dva", "dua", "dlra", "dvj", "duj" }, -- you can make him do more dva on purpose this way!
	
	-- size of character. 1x is based off 156 x 156 right now
	scaleFactor = 1.3,
	customIdleAnimations = false,

	-- for normal sprite sheet
	seqData = seqData,
	data = data,
	sheet = sheet,

	-- for skills sprite sheet
	seqData2 = seqData2,
	data2 = data2,
	sheet2 = sheet2,
	seqData3 = seqData3,
	data3 = data3,
	sheet3 = sheet3,

	atkDuration = 400, atkTriggerTime = 100, -- time when his basic attack actually lands
	maxPunchDelay = 700,
	grabAtkDuration = 350, grabAtkTriggerTime = 100,
	finalAtkTriggerTime = 300, -- 3/8th frame
	finalAtkDuration = 600,
	runAtkTimeDuration = 600,
	runAtkTriggerTime = 400,
	runAtkSpeedUp = 1.5,
	baseDps = 20, -- for normal punches, x1.5 for second, x2 for final
	knockbackPowerX = 800, -- able to hit enemies back 200 pixels on a final punch or knockback+down type hit
	knockbackPowerY = 400,
	rangeY = display.contentHeight * 0.03,
	rangeX = 65, -- modify this value for length of his attacking hitbox 
	-- for attack hitbox
	topAttackPosition = 10/156, --modify this value for the y-position of his attacking hitbox
	grabArmLength = 60, -- when grabbing opponent, there should be an ideal distance between them so your arm is connected to opponent's neck

	upAtkDamage = 10, upAtkMana = 15, 
	downAtkDamage = 100, downAtkMana = 35, -- ground slam
	dlraDamage = 75, dlraMana = 20,
	dlrjDamage = 30, dlrjMana = 30, dlrj_chargeTime = 800, drillSpeed = 0.5, drillSpeedMultiplier = 1.2,
	dujSpeedY = 1000,
	upJumpDamage = 100, upJumpMana = 40, upJumpPowerX = 200, upJumpPowerY = 1500, -- refer to knockbackPower for better idea
	downJumpDamage = 10, downJumpMana = 45, downJumpRangeX = 100, downJumpRangeY = 100, downJumpPowerX = 0, downJumpPowerY = 1000,
	uppercutFlashTime = 75, -- amount of time for the animation attack to appear and disappear
	duja = false,

	-- defense ratio
	defenseRatio = 0.2,

	-- unfortunately this is just duplicate code, the one in use is the boolean type one
	duaVulnerability = false,
	dvaVulnerability = false,
	dlraVulnerability = false,
	dujVulnerability = true,
	dlrjVulnerability = true,
	dvjVulnerability = true,
	duaType = "vulnerable",
	dvaType = "vulnerable",
	dvjType	= "vulnerable",
	dujType = "invulnerable",
	dlraType = "vulnerable",
	dlrjType = "invulnerable",

	
	hpRegenValue = 0.2,
	mpRegenValue = 0.05,

	specialTimerTable = {},
}

local Hero_metatable = { __index = Hero } -- on making a new ball, the above are the defaults (index ~ defaults)

function Hero:new( instanceNum )
	local a = {}
	setmetatable(a,Hero_metatable)
	a.instanceNum = instanceNum -- now we'll know which player number links to which Hero instance (e.g. player 1 uses Hero instance 1)
	return a
end

-- defense + up + attack
-- "fist of fury"
-- casting time = 1000 ms
-- is like a normal punch but perhaps detects multiple hits and causes flinches

function Hero:upAttack( player )

	if( player.mpValue >= self.upAtkMana ) then
		if( DebugInstance.manaCost == true ) then player:reduceMP( self.upAtkMana ) end

		player:spriteSwap( "attack skills" ) -- swap sprite set to use skills
		player.sprite:setSequence( "dua1" )
		player.sprite:play()

		-- the actual hitting action occurs 4/10th frames in out of 1000 ms, don't have enemy hurt until then
		local function detectAfterDelay()
			player.sprite:setSequence( "dua2" )
			player.sprite:play()
			function detectHitFury()
				GameController:hitDetection( player, self.upAtkDamage, "punch", self.rangeX*3, self.rangeY*3 ) -- works like a normal punch, calls main.lua's detectPunch function
			end
			local t = timer.performWithDelay( 100, detectHitFury, 15 )
			table.insert(self.specialTimerTable, t)
		end
		local t = timer.performWithDelay( 400, detectAfterDelay ) -- can't pass in parameters to function using timer.performWithDelay
		table.insert(self.specialTimerTable, t)

		return true

	else
		return false
	end
end	

-- defense + down + attack
-- "ground fist"

-- Algorithm explanation: player simply plays the animation and slams the ground, invoking detectPunch after a delay
-- detectPunch is radius based, meaning closer enemies will receive more damage and get knocked down

-- casting animation = 1200 ms

function Hero:removeTimers()
	for k,v in pairs(self.specialTimerTable) do
		timer.cancel(v)
	end
	self.specialTimerTable = {}
end

function Hero:downAttack( player )

	if( player.mpValue >= self.downAtkMana ) then
		-- deduct mana
		if( DebugInstance.manaCost == true ) then player:reduceMP( self.downAtkMana ) end

		player:spriteSwap( "attack skills" ) -- swap sprite set to use skills
		player.sprite:setSequence( "dva" )
		player.sprite:play()

		-- the actual hitting action occurs 7/12th frames in out of 1200 ms, don't have enemy hurt until then
		local function detectAfterDelay()
			GameController:hitDetection( player, self.downAtkDamage, "radiusBased" ) -- works like a normal punch, calls main.lua's detectPunch function
			Hero_Slam:new( player )
		end

		local t = timer.performWithDelay( 700, detectAfterDelay ) -- can't pass in parameters to function using timer.performWithDelay
		table.insert(self.specialTimerTable, t)

		return true
	else
		return false
	end
end	


-- defense + left/right + attack
-- "power wave" - sends out a wave of energy along the ground. No multiple casts.

-- this attack only sends out ONE shot, not multiple, based on player.ballsToShoot
-- 1. play animation, 2. initialize an array for balls, 3. add listener for balls,
-- listener: 1. makes new ball once in a while, in this case only one total, 2. accelerates ball, 3. deletes ball if enemy hit or out of bounds
-- more on 3:

-- detectBallHit() is run every frame. It works just like GameController:hitDetection(). If enemy is hit, ball.hitTarget is set to true to prevent ball from multi-hitting
-- then, remove sprite, then the ball object

-- casting animation = 1000 ms, ball itself has its own animation

function Hero:leftRightAttack( player ) -- called from self:selectPlayer():lrj( self ), where 'self'->'player'
	
	if( player.mpValue >= self.dlraMana ) then
		-- deduct mana
		if( DebugInstance.manaCost == true ) then player:reduceMP( self.dlraMana ) end

		player:spriteSwap( "attack skills" ) -- swap sprite set to use skills
		player.sprite:setSequence( "dlra" )
		player.sprite:play()
		player.ballsToShoot = 1

		player.shootingBalls = true -- not needed since only shooting one

		local function shootBall()
			table.insert( player.balls, Hero_Ball:new( player ) )
		end
		
		local t = timer.performWithDelay( 400, shootBall )
		table.insert(self.specialTimerTable, t)

		return true
	else
		return false
	end
end

-- defense + up + jump
-- "rising/dragon fist"

-- jump usually lasts 1.05 seconds, so I jump in the air after 200 ms (that's when animation plays)
-- lands after 200+500 ms, play 1 frame of landing animation then
-- total = 1.05 seconds, the attack only ends when I land (based on Player:stateCheck() jump code)

-- update 10/28: enemy will get sent flying in x/y directions based on distance away

function Hero:upJump( player )
	if( player.mpValue >= self.upJumpMana ) then
		-- deduct mana
		if( DebugInstance.manaCost == true ) then player:reduceMP( self.upJumpMana ) end

		player:spriteSwap( "jump skills" ) -- swap sprite set to use skills
		player.sprite:setSequence( "duj1" )
		player.sprite:play()

		local function landingAnimation()
			player.sprite:setSequence( "duj2" )
			player.sprite:play()
		end

		local function jumpDelay()
			player:modifiedJump( 0, self.dujSpeedY, true ) -- offensive = true
			
			for k,v in pairs( player.opponents ) do
				if( math.abs(player.sprite.x - v.sprite.x) < 100 and math.abs(player.sprite.y - v.sprite.y) < 100 ) then
					
					-- get hit for different Y force based on distance away
					if( math.abs( player.sprite.x - v.sprite.x ) > 20 ) then
						ratioY = 40 / math.abs(player.sprite.x - v.sprite.x)
					else
						ratioY = 1
					end

					ratioX = math.abs(player.sprite.x - v.sprite.x) / 40

					--GameController:hitDetection( player, self.upJumpDamage, "knockback+down", nil, nil, nil, self.upJumpPowerX, self.upJumpPowerY )
					v:getsHit( self.upJumpDamage, "knockback+down", player.mirror, false, self.upJumpPowerX * ratioX, self.upJumpPowerY * ratioY )
				end
			end
		end

		timer.performWithDelay( 200, jumpDelay )
		timer.performWithDelay( 700, landingAnimation )
	
		return true
	else
		return false
	end
end	

-- defense + down + jump
-- an "electrical explosion" that is static

-- casting animation = 500 ms, 8 frames
-- attacking animation = 900 ms, 3 frames looped every 150 ms, 6 times total
-- finishing animation = 100 ms, 1 frame

-- total = 1500 ms

function Hero:downJump( player )

	if( player.mpValue >= self.downJumpMana ) then
		-- deduct mana
		if( DebugInstance.manaCost == true ) then player:reduceMP( self.downJumpMana ) end

		player:spriteSwap( "jump skills" ) -- swap sprite set to use skills
		player.sprite:setSequence( "dvj1" )
		player.sprite:play()

		local function triggerDamage()
			for k,v in pairs( player.opponents ) do
				if( math.abs(player.sprite.x - v.sprite.x) < self.downJumpRangeX and math.abs(player.sprite.y - v.sprite.y) < self.downJumpRangeY) then
					v:getsHit( self.downJumpDamage, "knockback+down", player.mirror, false, self.downJumpPowerX, self.downJumpPowerY)
				end
			end
		end

		local function attackAnimation()
			player.sprite:setSequence( "dvj2" )
			player.sprite:play()
			timer.performWithDelay( 100, triggerDamage, 10 ) -- randomly hit area close by for 10 times
			timer.performWithDelay( 2000, finishedAnimation )
		end		

		local function finishedAnimation()
			player.sprite:setSequence( "dvj3" )
			player.sprite:play()
		end

		timer.performWithDelay( 1000, attackAnimation )

		return true
	else
		return false
	end
end

-- defense + left/right + jump
-- "giga drill"

-- enemies in path are DRAGGED and then ultimately tossed away and knocked down (tentative)
-- cast time = 1500 ms
-- slow speed rush forward = 300 ms animation, rushing forward at 0.8 x running speed
-- fast speed rush forward = 1000 ms total using a 150 ms animation looped over and over, rushes faster now, 1.5 x running speed


function Hero:leftRightJump( player )

	if( player.mpValue >= self.dlrjMana ) then
		-- deduct mana
		if( DebugInstance.manaCost == true ) then player:reduceMP( self.dlrjMana ) end

		player:spriteSwap( "jump skills" ) -- swap sprite set to use skills
		player.sprite:setSequence( "dlrj1" )
		player.sprite:play()

		startTime = system.getTimer() -- debug

		local function drillFaster()
			if( player.performingSpecial ~= "none" ) then
				-- sometimes this function runs even after the skill has ended, resulting in an idle frame "zooming"
				self.drillSpeed = self.drillSpeed * self.drillSpeedMultiplier
				player:zoom( self.drillSpeed )

				for k, enemy in pairs( player.opponents ) do

					-- used to determine how far away enemy is and whether the attack will connect or not
					reachDistX = math.abs(player.sprite.x - enemy.sprite.x)
					reachDistY = math.abs(player.sprite.y - enemy.sprite.y)

					if( reachDistX < 100 ) then 
						if( reachDistY < 100 ) then
							-- drag the enemy, but only if he isn't dead (meaning, if enemy dies during drill, he'll fall and not get dragged)
							if( enemy:checkPermissions( "getting hit") == true ) then
								--enemy.sprite.x = player.sprite.x + player.mirror*reachDistX
								enemy:getsHit( self.dlrjDamage, "knockback+down", player.mirror, false, self.knockbackPowerX * self.drillSpeed, self.knockbackPowerY  )
								-- code later
							end
						end
					end
				end
			end
		end

		-- the actual hitting action occurs 5/11th frames in out of 1100 ms, don't have enemy hurt until then
		local function attackAfterDelay()
			player.sprite:setSequence( "dlrj2" )
			player.sprite:play()

			self.drillSpeed = 0.5	
			player:zoom( self.drillSpeed )	
			self.drillTimer = timer.performWithDelay( 100, drillFaster, 10 )
			timer.performWithDelay( 1200, function()
				timer.cancel(self.drillTimer)
				player:idle(false,false)
			end )
		end

		timer.performWithDelay( self.dlrj_chargeTime, attackAfterDelay )	

		return true
	end
end	


function Hero:specialTime( type )
	if( type == "dva" ) then
		return 1200 -- needs to be around the same as animation time
	elseif( type == "dua" ) then
		return 2000
	elseif( type == "duj" ) then
		return 1100
	elseif( type == "dla" or type == "dra" ) then
			return 1000
	elseif( type == "dlj" or type == "drj" ) then
		return 2000 -- cannot be accurately determined, use code to return to idle, *NOW* done in line 558
	elseif( type == "dvj" ) then
		return 3500
	else
		return 0
	end
end

return Hero
