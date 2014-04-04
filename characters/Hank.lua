local Hank_Ball = require( "characters.skills.Hank_Ball")
local Hank_Wall = require( "characters.skills.Hank_Wall" )

local seqData = {
	{ name = "defend", start = 1, count = 2, time = 200, loopCount = 1 },
	{ name = "defend finished", start = 3, count = 1, time = 200, loopCount = 1 },
	{ name = "fallen", start = 4, count = 1, time = 2000, loopCount = 0 },
	{ name = "falling", start = 5, count = 6, time = 750, loopCount = 1 },
	{ name = "falling1", start = 8, count = 2, time = 300, loopCount = 1 },
	{ name = "falling2", start = 10, count = 1, time = 150, loopCount = 1 },
	{ name = "falling bounce", start = 8, count = 3, time = 300, loopCount = 1 },
	{ name = "getup", start = 11, count = 2, time = 500, loopCount = 1 },
	{ name = "flinch", start = 13, count = 3, time = 150, loopCount = 1 },
	{ name = "long flinch", start = 14, count = 1, time = 150, loopCount = 1 },
	{ name = "stunned", frames = {13,15}, time = 500, loopCount = 0 },
	{ name = "idle", start = 16, count = 3, time = 800, loopCount = 0 },
	{ name = "idle2", start = 19, count = 9, time = 2933, loopCount = 0 },
	{ name = "jump", start = 28, count = 4, time = 600, loopCount = 1 },
	{ name = "jump kick", start = 91, count = 6, time = 500, loopCount = 1 }, -- using DJA
	{ name = "punch", start = 36, count = 4, time = 200, loopCount = 1 },
	{ name = "punch2", start = 42, count = 5, time = 200, loopCount = 1 },
	{ name = "punch3", start = 49, count = 7, time = 800, loopCount = 1 },
	{ name = "running attack", start = 49, count = 7, time = 600, loopCount = 1 },
	{ name = "run", start = 61, count = 5, time = 600, loopCount = 0 },
	{ name = "throwing", start = 66, count = 3, time = 300, loopCount = 1 },
	{ name = "walk", start = 69, count = 5, time = 625, loopCount = 0 },
	{ name = "recover", start = 57, count = 4, time = 500, loopCount = 1},
	{ name = "dodge", start = 74, count = 9, time = 500, loopCount = 1},

	{ name="attachedToSpin", start = 10, count = 1, time = 300, loopCount = 0 }, -- for hanks DvA skill

	{ name="grab", start = 83, count = 1, time = 1, loopCount = 0 },
	{ name="grabbed", start = 86, count = 1, time = 1, loopCount = 0 },
	{ name="grab punch", start = 84, count = 2, time = 300, loopCount = 1 },

	{ name="heavy lift", start = 87, count = 2, time = 300, loopCount = 1 },
	{ name="throw opponent", start = 89, count = 2, time = 300, loopCount = 1 },
	{ name="pickup", start = 31, count = 1, time = 300, loopCount = 1 },
		
}

local seqData2 = {
	{ name = "dlrj", start = 1, count = 7, time = 500, loopCount = 1 },
	{ name = "duj", start = 8, count = 2, time = 300, loopCount = 1 },	
	{ name = "duja", start = 10, count = 6, time = 600, loopCount =1 },
	{ name = "dvj", start = 16, count = 9, time = 900, loopCount = 1 },
}

local seqData3 = {
	{ name = "dlra", start = 1, count = 8, time = 800, loopCount = 1 },
	{ name = "dua", start = 9, count = 7, time = 800, loopCount = 1 },
	{ name = "dvaStart", start = 16, count = 6, time = 400, loopCount = 1 },
	-- { name = "dvaFast", start = 22, count = 6, time = 300, loopCount = 0 },
	{ name = "dvaFast", frames = {23,25,28}, time = 120, loopCount = 0 },
	{ name = "dvaStop", start = 28, count = 6, time = 400, loopCount = 1 },
}

local data = {
	frames = {
		{ name=defend2, x = 1103, y = 474, width = 156, height = 156, sourceX=0, sourceY=0, sourceWidth=156 , sourceHeight=156 },
		{ name=defend3, x = 1735, y = 0, width = 156, height = 156, sourceX=0, sourceY=0, sourceWidth=156 , sourceHeight=156 },
		{ name=defend4, x = 1580, y = 1738, width = 156, height = 156, sourceX=0, sourceY=0, sourceWidth=156 , sourceHeight=156 },
		{ name=fallen, x = 1580, y = 1580, width = 156, height = 156, sourceX=0, sourceY=0, sourceWidth=156 , sourceHeight=156 },
		{ name=falling1, x = 1580, y = 1422, width = 156, height = 156, sourceX=0, sourceY=0, sourceWidth=156 , sourceHeight=156 },
		{ name=falling2, x = 1578, y = 1264, width = 156, height = 156, sourceX=0, sourceY=0, sourceWidth=156 , sourceHeight=156 },
		{ name=falling3, x = 1578, y = 1106, width = 156, height = 156, sourceX=0, sourceY=0, sourceWidth=156 , sourceHeight=156 },
		{ name=fallingbounce1, x = 1585, y = 790, width = 156, height = 156, sourceX=0, sourceY=0, sourceWidth=156 , sourceHeight=156 },
		{ name=fallingbounce2, x = 1578, y = 948, width = 156, height = 156, sourceX=0, sourceY=0, sourceWidth=156 , sourceHeight=156 },
		{ name=fallingbounce3, x = 1585, y = 790, width = 156, height = 156, sourceX=0, sourceY=0, sourceWidth=156 , sourceHeight=156 },
		{ name=getup1, x = 1577, y = 632, width = 156, height = 156, sourceX=0, sourceY=0, sourceWidth=156 , sourceHeight=156 },
		{ name=getup2, x = 1577, y = 474, width = 156, height = 156, sourceX=0, sourceY=0, sourceWidth=156 , sourceHeight=156 },
		{ name=hurt02, x = 1577, y = 316, width = 156, height = 156, sourceX=0, sourceY=0, sourceWidth=156 , sourceHeight=156 },
		{ name=hurt03, x = 1577, y = 158, width = 156, height = 156, sourceX=0, sourceY=0, sourceWidth=156 , sourceHeight=156 },
		{ name=hurt04, x = 1577, y = 0, width = 156, height = 156, sourceX=0, sourceY=0, sourceWidth=156 , sourceHeight=156 },
		{ name=idle01, x = 1422, y = 1738, width = 156, height = 156, sourceX=0, sourceY=0, sourceWidth=156 , sourceHeight=156 },
		{ name=idle02, x = 1422, y = 1580, width = 156, height = 156, sourceX=0, sourceY=0, sourceWidth=156 , sourceHeight=156 },
		{ name=idle03, x = 1422, y = 1422, width = 156, height = 156, sourceX=0, sourceY=0, sourceWidth=156 , sourceHeight=156 },
		{ name=idle203, x = 1420, y = 1264, width = 156, height = 156, sourceX=0, sourceY=0, sourceWidth=156 , sourceHeight=156 },
		{ name=idle204, x = 1420, y = 1106, width = 156, height = 156, sourceX=0, sourceY=0, sourceWidth=156 , sourceHeight=156 },
		{ name=idle205, x = 1427, y = 790, width = 156, height = 156, sourceX=0, sourceY=0, sourceWidth=156 , sourceHeight=156 },
		{ name=idle206, x = 1420, y = 948, width = 156, height = 156, sourceX=0, sourceY=0, sourceWidth=156 , sourceHeight=156 },
		{ name=idle207, x = 1419, y = 632, width = 156, height = 156, sourceX=0, sourceY=0, sourceWidth=156 , sourceHeight=156 },
		{ name=idle208, x = 1419, y = 474, width = 156, height = 156, sourceX=0, sourceY=0, sourceWidth=156 , sourceHeight=156 },
		{ name=idle209, x = 1419, y = 316, width = 156, height = 156, sourceX=0, sourceY=0, sourceWidth=156 , sourceHeight=156 },
		{ name=idle210, x = 1419, y = 158, width = 156, height = 156, sourceX=0, sourceY=0, sourceWidth=156 , sourceHeight=156 },
		{ name=idle211, x = 1419, y = 0, width = 156, height = 156, sourceX=0, sourceY=0, sourceWidth=156 , sourceHeight=156 },
		{ name=jump02, x = 1264, y = 1738, width = 156, height = 156, sourceX=0, sourceY=0, sourceWidth=156 , sourceHeight=156 },
		{ name=jump03, x = 1264, y = 1580, width = 156, height = 156, sourceX=0, sourceY=0, sourceWidth=156 , sourceHeight=156 },
		{ name=jump04, x = 1264, y = 1422, width = 156, height = 156, sourceX=0, sourceY=0, sourceWidth=156 , sourceHeight=156 },
		{ name=jump05, x = 1262, y = 1264, width = 156, height = 156, sourceX=0, sourceY=0, sourceWidth=156 , sourceHeight=156 },
		{ name=jumpattack02, x = 1264, y = 1738, width = 156, height = 156, sourceX=0, sourceY=0, sourceWidth=156 , sourceHeight=156 },
		{ name=jumpattack03, x = 1264, y = 1580, width = 156, height = 156, sourceX=0, sourceY=0, sourceWidth=156 , sourceHeight=156 },
		{ name=jumpattack04, x = 1262, y = 1106, width = 156, height = 156, sourceX=0, sourceY=0, sourceWidth=156 , sourceHeight=156 },
		{ name=jumpattack05, x = 1269, y = 790, width = 156, height = 156, sourceX=0, sourceY=0, sourceWidth=156 , sourceHeight=156 },
		{ name=ppp02, x = 1262, y = 948, width = 156, height = 156, sourceX=0, sourceY=0, sourceWidth=156 , sourceHeight=156 },
		{ name=ppp03, x = 1261, y = 632, width = 156, height = 156, sourceX=0, sourceY=0, sourceWidth=156 , sourceHeight=156 },
		{ name=ppp04, x = 1261, y = 474, width = 156, height = 156, sourceX=0, sourceY=0, sourceWidth=156 , sourceHeight=156 },
		{ name=ppp05, x = 1261, y = 316, width = 156, height = 156, sourceX=0, sourceY=0, sourceWidth=156 , sourceHeight=156 },
		{ name=ppp06, x = 1261, y = 158, width = 156, height = 156, sourceX=0, sourceY=0, sourceWidth=156 , sourceHeight=156 },
		{ name=ppp07, x = 1261, y = 0, width = 156, height = 156, sourceX=0, sourceY=0, sourceWidth=156 , sourceHeight=156 },
		{ name=ppp08, x = 1111, y = 790, width = 156, height = 156, sourceX=0, sourceY=0, sourceWidth=156 , sourceHeight=156 },
		{ name=ppp09, x = 1106, y = 1738, width = 156, height = 156, sourceX=0, sourceY=0, sourceWidth=156 , sourceHeight=156 },
		{ name=ppp10, x = 1106, y = 1580, width = 156, height = 156, sourceX=0, sourceY=0, sourceWidth=156 , sourceHeight=156 },
		{ name=ppp11, x = 1106, y = 1422, width = 156, height = 156, sourceX=0, sourceY=0, sourceWidth=156 , sourceHeight=156 },
		{ name=ppp12, x = 1104, y = 1264, width = 156, height = 156, sourceX=0, sourceY=0, sourceWidth=156 , sourceHeight=156 },
		{ name=ppp13, x = 1104, y = 1106, width = 156, height = 156, sourceX=0, sourceY=0, sourceWidth=156 , sourceHeight=156 },
		{ name=ppp14, x = 1104, y = 948, width = 156, height = 156, sourceX=0, sourceY=0, sourceWidth=156 , sourceHeight=156 },
		{ name=ppp15, x = 1103, y = 632, width = 156, height = 156, sourceX=0, sourceY=0, sourceWidth=156 , sourceHeight=156 },
		{ name=ppp16, x = 1735, y = 158, width = 156, height = 156, sourceX=0, sourceY=0, sourceWidth=156 , sourceHeight=156 },
		{ name=ppp17, x = 1103, y = 316, width = 156, height = 156, sourceX=0, sourceY=0, sourceWidth=156 , sourceHeight=156 },
		{ name=ppp18, x = 1103, y = 158, width = 156, height = 156, sourceX=0, sourceY=0, sourceWidth=156 , sourceHeight=156 },
		{ name=ppp19, x = 1103, y = 0, width = 156, height = 156, sourceX=0, sourceY=0, sourceWidth=156 , sourceHeight=156 },
		{ name=ppp20, x = 953, y = 790, width = 156, height = 156, sourceX=0, sourceY=0, sourceWidth=156 , sourceHeight=156 },
		{ name=ppp21, x = 948, y = 1746, width = 156, height = 156, sourceX=0, sourceY=0, sourceWidth=156 , sourceHeight=156 },
		{ name=ppp22, x = 630, y = 945, width = 163, height = 163, sourceX=0, sourceY=0, sourceWidth=163 , sourceHeight=163 },
		{ name=recover2, x = 946, y = 1419, width = 156, height = 156, sourceX=0, sourceY=0, sourceWidth=156 , sourceHeight=156 },
		{ name=recover3, x = 946, y = 1261, width = 156, height = 156, sourceX=0, sourceY=0, sourceWidth=156 , sourceHeight=156 },
		{ name=recover4, x = 946, y = 1103, width = 156, height = 156, sourceX=0, sourceY=0, sourceWidth=156 , sourceHeight=156 },
		{ name=recover5, x = 945, y = 632, width = 156, height = 156, sourceX=0, sourceY=0, sourceWidth=156 , sourceHeight=156 },
		{ name=run02, x = 945, y = 474, width = 156, height = 156, sourceX=0, sourceY=0, sourceWidth=156 , sourceHeight=156 },
		{ name=run03, x = 945, y = 316, width = 156, height = 156, sourceX=0, sourceY=0, sourceWidth=156 , sourceHeight=156 },
		{ name=run04, x = 945, y = 158, width = 156, height = 156, sourceX=0, sourceY=0, sourceWidth=156 , sourceHeight=156 },
		{ name=run05, x = 945, y = 0, width = 156, height = 156, sourceX=0, sourceY=0, sourceWidth=156 , sourceHeight=156 },
		{ name=run06, x = 795, y = 945, width = 156, height = 156, sourceX=0, sourceY=0, sourceWidth=156 , sourceHeight=156 },
		{ name=throw02, x = 790, y = 1764, width = 156, height = 156, sourceX=0, sourceY=0, sourceWidth=156 , sourceHeight=156 },
		{ name=throw03, x = 790, y = 1606, width = 156, height = 156, sourceX=0, sourceY=0, sourceWidth=156 , sourceHeight=156 },
		{ name=throw04, x = 788, y = 1448, width = 156, height = 156, sourceX=0, sourceY=0, sourceWidth=156 , sourceHeight=156 },
		{ name=walk02, x = 788, y = 1279, width = 156, height = 167, sourceX=0, sourceY=0, sourceWidth=156 , sourceHeight=167 },
		{ name=walk03, x = 788, y = 1110, width = 156, height = 167, sourceX=0, sourceY=0, sourceWidth=156 , sourceHeight=167 },
		{ name=walk04, x = 632, y = 1753, width = 156, height = 167, sourceX=0, sourceY=0, sourceWidth=156 , sourceHeight=167 },
		{ name=walk05, x = 948, y = 1577, width = 156, height = 167, sourceX=0, sourceY=0, sourceWidth=156 , sourceHeight=167 },
		{ name=walk06, x = 630, y = 1426, width = 156, height = 167, sourceX=0, sourceY=0, sourceWidth=156 , sourceHeight=167 },
		{ name=zdodge01, x = 315, y = 630, width = 313, height = 313, sourceX=0, sourceY=0, sourceWidth=313 , sourceHeight=313 },
		{ name=zdodge02, x = 630, y = 630, width = 313, height = 313, sourceX=0, sourceY=0, sourceWidth=313 , sourceHeight=313 },
		{ name=zdodge03, x = 315, y = 0, width = 313, height = 313, sourceX=0, sourceY=0, sourceWidth=313 , sourceHeight=313 },
		{ name=zdodge04, x = 630, y = 0, width = 313, height = 313, sourceX=0, sourceY=0, sourceWidth=313 , sourceHeight=313 },
		{ name=zdodge05, x = 315, y = 1260, width = 313, height = 313, sourceX=0, sourceY=0, sourceWidth=313 , sourceHeight=313 },
		{ name=zdodge06, x = 315, y = 1575, width = 313, height = 313, sourceX=0, sourceY=0, sourceWidth=313 , sourceHeight=313 },
		{ name=zdodge07, x = 315, y = 945, width = 313, height = 313, sourceX=0, sourceY=0, sourceWidth=313 , sourceHeight=313 },
		{ name=zdodge08, x = 315, y = 315, width = 313, height = 313, sourceX=0, sourceY=0, sourceWidth=313 , sourceHeight=313 },
		{ name=zdodge09, x = 630, y = 315, width = 313, height = 313, sourceX=0, sourceY=0, sourceWidth=313 , sourceHeight=313 },
		{ name=zgrab1, x = 316, y = 1890, width = 156, height = 156, sourceX=0, sourceY=0, sourceWidth=156 , sourceHeight=156 },
		{ name=zgrabattack1, x = 0, y = 1890, width = 156, height = 156, sourceX=0, sourceY=0, sourceWidth=156 , sourceHeight=156 },
		{ name=zgrabattack2, x = 158, y = 1890, width = 156, height = 156, sourceX=0, sourceY=0, sourceWidth=156 , sourceHeight=156 },
		{ name=zgrabbed, x = 630, y = 1110, width = 156, height = 156, sourceX=0, sourceY=0, sourceWidth=156 , sourceHeight=156 },
		{ name=zheavythrow1, x = 630, y = 1268, width = 156, height = 156, sourceX=0, sourceY=0, sourceWidth=156 , sourceHeight=156 },
		{ name=zheavythrow2, x = 316, y = 1890, width = 156, height = 156, sourceX=0, sourceY=0, sourceWidth=156 , sourceHeight=156 },
		{ name=zheavythrow3, x = 474, y = 1890, width = 156, height = 156, sourceX=0, sourceY=0, sourceWidth=156 , sourceHeight=156 },
		{ name=zheavythrow4, x = 630, y = 1595, width = 156, height = 156, sourceX=0, sourceY=0, sourceWidth=156 , sourceHeight=156 },
		{ name=zjp1, x = 0, y = 1575, width = 313, height = 313, sourceX=0, sourceY=0, sourceWidth=313 , sourceHeight=313 },
		{ name=zjp2, x = 0, y = 1260, width = 313, height = 313, sourceX=0, sourceY=0, sourceWidth=313 , sourceHeight=313 },
		{ name=zjp3, x = 0, y = 945, width = 313, height = 313, sourceX=0, sourceY=0, sourceWidth=313 , sourceHeight=313 },
		{ name=zjp4, x = 0, y = 630, width = 313, height = 313, sourceX=0, sourceY=0, sourceWidth=313 , sourceHeight=313 },
		{ name=zjp5, x = 0, y = 315, width = 313, height = 313, sourceX=0, sourceY=0, sourceWidth=313 , sourceHeight=313 },
		{ name=zjp6, x = 0, y = 0, width = 313, height = 313, sourceX=0, sourceY=0, sourceWidth=313 , sourceHeight=313 },
	},
	sheetContentWidth = 2048,
	sheetContentHeight = 2048
}

local data2 = {
	frames = {
		{ name=DRLJ03, x = 0, y = 630, width = 313, height = 313, sourceX=0, sourceY=0, sourceWidth=313 , sourceHeight=313 },
		{ name=DRLJ04, x = 0, y = 945, width = 313, height = 313, sourceX=0, sourceY=0, sourceWidth=313 , sourceHeight=313 },
		{ name=DRLJ05, x = 315, y = 0, width = 313, height = 313, sourceX=0, sourceY=0, sourceWidth=313 , sourceHeight=313 },
		{ name=DRLJ06, x = 315, y = 315, width = 313, height = 313, sourceX=0, sourceY=0, sourceWidth=313 , sourceHeight=313 },
		{ name=DRLJ07, x = 315, y = 630, width = 313, height = 313, sourceX=0, sourceY=0, sourceWidth=313 , sourceHeight=313 },
		{ name=DRLJ08, x = 315, y = 945, width = 313, height = 313, sourceX=0, sourceY=0, sourceWidth=313 , sourceHeight=313 },
		{ name=DRLJ09, x = 630, y = 0, width = 313, height = 313, sourceX=0, sourceY=0, sourceWidth=313 , sourceHeight=313 },
		{ name=DUJ03, x = 945, y = 0, width = 313, height = 313, sourceX=0, sourceY=0, sourceWidth=313 , sourceHeight=313 },
		{ name=DUJ04, x = 630, y = 945, width = 313, height = 313, sourceX=0, sourceY=0, sourceWidth=313 , sourceHeight=313 },
		{ name=DUJ05, x = 945, y = 630, width = 313, height = 313, sourceX=0, sourceY=0, sourceWidth=313 , sourceHeight=313 },
		{ name=DUJ06, x = 945, y = 315, width = 313, height = 313, sourceX=0, sourceY=0, sourceWidth=313 , sourceHeight=313 },
		{ name=DUJ07, x = 0, y = 315, width = 313, height = 313, sourceX=0, sourceY=0, sourceWidth=313 , sourceHeight=313 },
		{ name=DUJ08, x = 0, y = 0, width = 313, height = 313, sourceX=0, sourceY=0, sourceWidth=313 , sourceHeight=313 },
		{ name=DUJ09, x = 630, y = 630, width = 313, height = 313, sourceX=0, sourceY=0, sourceWidth=313 , sourceHeight=313 },
		{ name=DUJ10, x = 630, y = 315, width = 313, height = 313, sourceX=0, sourceY=0, sourceWidth=313 , sourceHeight=313 },
		{ name=DVJ02, x = 0, y = 1260, width = 156, height = 156, sourceX=0, sourceY=0, sourceWidth=156 , sourceHeight=156 },
		{ name=DVJ03, x = 158, y = 1260, width = 156, height = 156, sourceX=0, sourceY=0, sourceWidth=156 , sourceHeight=156 },
		{ name=DVJ04, x = 316, y = 1260, width = 156, height = 156, sourceX=0, sourceY=0, sourceWidth=156 , sourceHeight=156 },
		{ name=DVJ05, x = 474, y = 1260, width = 156, height = 156, sourceX=0, sourceY=0, sourceWidth=156 , sourceHeight=156 },
		{ name=DVJ06, x = 632, y = 1260, width = 156, height = 156, sourceX=0, sourceY=0, sourceWidth=156 , sourceHeight=156 },
		{ name=DVJ07, x = 790, y = 1260, width = 156, height = 156, sourceX=0, sourceY=0, sourceWidth=156 , sourceHeight=156 },
		{ name=DVJ08, x = 945, y = 945, width = 156, height = 156, sourceX=0, sourceY=0, sourceWidth=156 , sourceHeight=156 },
		{ name=DVJ09, x = 948, y = 1103, width = 156, height = 156, sourceX=0, sourceY=0, sourceWidth=156 , sourceHeight=156 },
		{ name=DVJ10, x = 948, y = 1261, width = 156, height = 156, sourceX=0, sourceY=0, sourceWidth=156 , sourceHeight=156 },
	},
	sheetContentWidth = 1260,
	sheetContentHeight = 1419
}

local data3 = {
	frames = {
		{ name=DRLA02, x = 1260, y = 812, width = 156, height = 156, sourceX=0, sourceY=0, sourceWidth=156 , sourceHeight=156 },
		{ name=DRLA03, x = 1418, y = 474, width = 156, height = 156, sourceX=0, sourceY=0, sourceWidth=156 , sourceHeight=156 },
		{ name=DRLA04, x = 1418, y = 316, width = 156, height = 156, sourceX=0, sourceY=0, sourceWidth=156 , sourceHeight=156 },
		{ name=DRLA05, x = 1418, y = 158, width = 156, height = 156, sourceX=0, sourceY=0, sourceWidth=156 , sourceHeight=156 },
		{ name=DRLA06, x = 1418, y = 0, width = 156, height = 156, sourceX=0, sourceY=0, sourceWidth=156 , sourceHeight=156 },
		{ name=DRLA07, x = 1260, y = 1286, width = 156, height = 156, sourceX=0, sourceY=0, sourceWidth=156 , sourceHeight=156 },
		{ name=DRLA08, x = 1260, y = 1128, width = 156, height = 156, sourceX=0, sourceY=0, sourceWidth=156 , sourceHeight=156 },
		{ name=DRLA09, x = 1260, y = 970, width = 156, height = 156, sourceX=0, sourceY=0, sourceWidth=156 , sourceHeight=156 },
		{ name=DUA02, x = 1260, y = 812, width = 156, height = 156, sourceX=0, sourceY=0, sourceWidth=156 , sourceHeight=156 },
		{ name=DUA03, x = 1418, y = 632, width = 156, height = 156, sourceX=0, sourceY=0, sourceWidth=156 , sourceHeight=156 },
		{ name=DUA04, x = 1260, y = 654, width = 156, height = 156, sourceX=0, sourceY=0, sourceWidth=156 , sourceHeight=156 },
		{ name=DUA05, x = 1260, y = 496, width = 156, height = 156, sourceX=0, sourceY=0, sourceWidth=156 , sourceHeight=156 },
		{ name=DUA06, x = 1260, y = 327, width = 156, height = 167, sourceX=0, sourceY=0, sourceWidth=156 , sourceHeight=167 },
		{ name=DUA07, x = 1260, y = 158, width = 156, height = 167, sourceX=0, sourceY=0, sourceWidth=156 , sourceHeight=167 },
		{ name=DUA08, x = 1260, y = 0, width = 156, height = 156, sourceX=0, sourceY=0, sourceWidth=156 , sourceHeight=156 },
		{ name=DVA03, x = 945, y = 1260, width = 313, height = 313, sourceX=0, sourceY=0, sourceWidth=313 , sourceHeight=313 },
		{ name=DVA04, x = 945, y = 945, width = 313, height = 313, sourceX=0, sourceY=0, sourceWidth=313 , sourceHeight=313 },
		{ name=DVA05, x = 945, y = 630, width = 313, height = 313, sourceX=0, sourceY=0, sourceWidth=313 , sourceHeight=313 },
		{ name=DVA06, x = 945, y = 315, width = 313, height = 313, sourceX=0, sourceY=0, sourceWidth=313 , sourceHeight=313 },
		{ name=DVA07, x = 945, y = 0, width = 313, height = 313, sourceX=0, sourceY=0, sourceWidth=313 , sourceHeight=313 },
		{ name=DVA08, x = 630, y = 1260, width = 313, height = 313, sourceX=0, sourceY=0, sourceWidth=313 , sourceHeight=313 },
		{ name=DVA09, x = 630, y = 945, width = 313, height = 313, sourceX=0, sourceY=0, sourceWidth=313 , sourceHeight=313 },
		{ name=DVA10, x = 630, y = 630, width = 313, height = 313, sourceX=0, sourceY=0, sourceWidth=313 , sourceHeight=313 },
		{ name=DVA11, x = 630, y = 315, width = 313, height = 313, sourceX=0, sourceY=0, sourceWidth=313 , sourceHeight=313 },
		{ name=DVA12, x = 630, y = 0, width = 313, height = 313, sourceX=0, sourceY=0, sourceWidth=313 , sourceHeight=313 },
		{ name=DVA13, x = 315, y = 1260, width = 313, height = 313, sourceX=0, sourceY=0, sourceWidth=313 , sourceHeight=313 },
		{ name=DVA14, x = 315, y = 945, width = 313, height = 313, sourceX=0, sourceY=0, sourceWidth=313 , sourceHeight=313 },
		{ name=DVA15, x = 315, y = 630, width = 313, height = 313, sourceX=0, sourceY=0, sourceWidth=313 , sourceHeight=313 },
		{ name=DVA16, x = 315, y = 315, width = 313, height = 313, sourceX=0, sourceY=0, sourceWidth=313 , sourceHeight=313 },
		{ name=DVA17, x = 315, y = 0, width = 313, height = 313, sourceX=0, sourceY=0, sourceWidth=313 , sourceHeight=313 },
		{ name=DVA18, x = 0, y = 1260, width = 313, height = 313, sourceX=0, sourceY=0, sourceWidth=313 , sourceHeight=313 },
		{ name=DVA19, x = 0, y = 945, width = 313, height = 313, sourceX=0, sourceY=0, sourceWidth=313 , sourceHeight=313 },
		{ name=DVA20, x = 0, y = 630, width = 313, height = 313, sourceX=0, sourceY=0, sourceWidth=313 , sourceHeight=313 },
		{ name=DVA21, x = 0, y = 315, width = 313, height = 313, sourceX=0, sourceY=0, sourceWidth=313 , sourceHeight=313 },
		{ name=DVA22, x = 0, y = 0, width = 313, height = 313, sourceX=0, sourceY=0, sourceWidth=313 , sourceHeight=313 },
	},
	sheetContentWidth = 1576,
	sheetContentHeight = 1575
}

local sheet = graphics.newImageSheet( "images/hank/hank.png", data )
local sheet2 = graphics.newImageSheet( "images/hank/hankjumpskills.png", data2 )
local sheet3 = graphics.newImageSheet( "images/hank/hankattackskills.png", data3 )

local Hank = {

	-- walking and running speeds
	runningSpeedFactor = 1.2,
	walkingSpeedFactor = 1.2,

	-- list of ranged skills
	rangedSkills = { "dva" , "dlra", "dlrj", "dvj" },
	-- list of melee skills
	meleeSkills = { "dva", "dua", "dvj", "dlrj",}, -- you can make him do more dva on purpose this way!

	-- size of character. 1x is based off 156 x 156 right now
	scaleFactor = 1.3,
	customIdleAnimations = true,
	longestRandomAnimation = 3000, -- based on IDLE2 being 3s long

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

	atkDuration = 600, atkTriggerTime = 300, -- time when his basic attack actually lands
	maxPunchDelay = 900,
	grabAtkDuration = 450, grabAtkTriggerTime = 150,
	finalAtkTriggerTime = 500, -- 5/8th frame
	finalAtkDuration = 900, -- allow extra 100 ms to finish playing animation
	runAtkTimeDuration = 600, -- refer to animation
	runAtkTriggerTime = 400,
	runAtkSpeedUp = 1.5,
	baseDps = 30,
	knockbackPowerX = 700, -- able to hit enemies back 200 pixels on a final punch or knockback+down type hit
	knockbackPowerY = 700,
	rangeY = display.contentHeight * 0.04,
	rangeX = 80,
	-- for attack hitbox
	topAttackPosition = 23.5/163,
	grabArmLength = 60, -- when grabbing opponent, there should be an ideal distance between them so your arm is connected to opponent's neck
	
	-- time required for punches to land
	punch2Delay = 300,
	punch3Delay = 400,

	upAtkDamage = 50, upAtkMana = 15, upAtkPowerX = 200, upAtkPowerY = 1000, -- refer to knockbackPower for better idea
	
	downAtkDamage = 50, downAtkMana = 20, downAtkPowerX = 200, downAtkPowerY = 200, -- refer to knockbackPower for better idea
	
	upJumpMana = 10, dujSpeedY = 1000, duja = true,

	dlrjDamage = 100, dlrjMana = 35, dlrjSpeedX = 1000, dlrjSpeedY = 600, dlrjPowerX = 1200, dlrjPowerY = 500,

	dlraDamage = 75, dlraDamage = 50, dlraMana = 15,

	downJumpDamage = 50, -- when the wall appears
	downJumpMana = 10, 
	downJumpRangeX = display.contentWidth/5,

	-- defense
	defenseRatio = 0.2,

	--[[
	downAtkDamage = 100,
	

	dlrjDamage = 2,
	dlrj_chargeTime1 = 900,
	dlrj_chargeTime2 = 500,
	drillSpeed = 0.5,
	drillSpeedMultiplier = 1.11,

	dujSpeedY = 1000,

	upJumpDamage = 100, 
	uppercutFlashTime = 75, -- amount of time for the animation attack to appear and disappear

	]]--

	-- HANK ONLY variables
	walls = {},

	-- for performing special permission checks
	duaType = "invulnerable",
	dvaType = "invulnerable",
	dvjType	= "invulnerable",
	dujType = "invulnerable",
	dlraType = "invulnerable",
	dlrjType = "invulnerable",


	duaVulnerability = false,
	dvaVulnerability = true,
	dlraVulnerability = true,
	dujVulnerability = false,
	dlrjVulnerability = true,
	dvjVulnerability = false,

	hpRegenValue = 0.2,
	mpRegenValue = 0.02,

	specialTimerTable = {},
}

local Hank_metatable = { __index = Hank } 

function Hank:new( instanceNum )
	local a = {}
	setmetatable(a,Hank_metatable)
	a.instanceNum = instanceNum
	return a
end

function Hank:removeTimers()
	for k,v in pairs(self.specialTimerTable) do
		timer.cancel(v)
	end
	self.specialTimerTable = {}
end

function Hank:upAttack( player )

	if( player.mpValue >= self.upAtkMana ) then
		-- deduct mana
		if( DebugInstance.manaCost == true ) then player:reduceMP( self.upAtkMana ) end

		player:spriteSwap( "attack skills" ) -- swap sprite set to use skills
		player.sprite:setSequence( "dua" )
		player.sprite:play()

		local function attackDelay()
			for k,v in pairs( player.opponents ) do
				if( math.abs(player.sprite.x - v.sprite.x) < 100 and math.abs(player.sprite.y - v.sprite.y) < 100 ) then
					
					-- get hit for different Y force based on distance away
					if( math.abs( player.sprite.x - v.sprite.x ) > 20 ) then
						ratioY = 40 / math.abs(player.sprite.x - v.sprite.x)
					else
						ratioY = 1
					end

					ratioX = math.abs(player.sprite.x - v.sprite.x) / 40

					v:getsHit( self.upAtkDamage, "knockback+down", player.mirror, false, self.upAtkPowerX * ratioX, self.upAtkPowerY * ratioY )
				end
			end
		end

		local t = timer.performWithDelay( 400, attackDelay )
		table.insert(self.specialTimerTable, t)
	
		return true
	else
		return false
	end
end	

function Hank:downAttack( player )

	if( player.mpValue >= self.downAtkMana ) then

		local attachedPlayers = {}

		local function attachPlayer()
			for k,v in pairs( player.opponents ) do
				if( math.abs(player.sprite.x - v.sprite.x) < 100 and math.abs(player.sprite.y - v.sprite.y) < 100 ) then
					v:flinch("long")
					v.sprite:scale(0.5,0.5)
					v.sprite:setSequence( "attachedToSpin" )
					v.sprite:play()
					table.insert(attachedPlayers,v)
				end
			end
		end

		local function detachPlayer()
			for k,v in pairs(attachedPlayers) do
				v.sprite.isVisible = true -- just in case spinAttachedPlayers() ended on frame 2
				v.sprite:scale(2,2)
				v:fall()
			end
		end

		local function spinAttachedPlayers()
			for k,v in pairs(attachedPlayers) do
				v.sprite.y = player.sprite.y
				if player.sprite.frame == 1 then
					v.sprite.isVisible = true
					v.sprite.x = player.sprite.x + 50
				elseif player.sprite.frame == 2 then
					v.sprite.isVisible = false
				elseif player.sprite.frame == 3 then
					v.sprite.isVisible = true
					v.sprite.x = player.sprite.x - 50
				end
			end
		end

		-- deduct mana
		if( DebugInstance.manaCost == true ) then player:reduceMP( self.downAtkMana ) end

		player:spriteSwap( "attack skills" ) -- swap sprite set to use skills
		player.sprite:setSequence( "dvaStart" )
		player.sprite:play()

		local function spinFast()
			player.sprite:setSequence( "dvaFast" )
			player.sprite:play()
			attachPlayer()
			Runtime:addEventListener("enterFrame", spinAttachedPlayers)
		end

		local function slowDown()
			player.sprite:setSequence( "dvaStop" )
			player.sprite:play()
			detachPlayer()
			Runtime:removeEventListener("enterFrame", spinAttachedPlayers)
		end

		timer.performWithDelay( 400, spinFast )
		timer.performWithDelay( 1600, slowDown )
	
		return true
	else
		return false
	end
end	

function Hank:leftRightAttack( player, direction ) -- called from self:selectPlayer():lrj( self ), where 'self'->'player'
	
	if( player.mpValue >= self.dlraMana ) then
		-- deduct mana
		if( DebugInstance.manaCost == true ) then player:reduceMP( self.dlraMana ) end

		player:spriteSwap( "attack skills" ) -- swap sprite set to use skills
		player.sprite:setSequence( "dlra" )
		player.sprite:play()
		player.ballsToShoot = 1

		player.shootingBalls = true -- not needed since only shooting one

		local function shootBall()
			table.insert( player.balls, Hank_Ball:new( player ) ) -- pass in player to know where (x,y) to create sprites
		end

		local t = timer.performWithDelay( 400, shootBall )
		table.insert(self.specialTimerTable, t)

		return true
	else
		return false
	end
end

function Hank:upJump( player )

	if( DebugInstance.manaCost == true ) then player:reduceMP( self.upJumpMana ) end
	player:spriteSwap( "jump skills" )
	player.sprite:setSequence( "duj" )
	player.sprite:play()

	-- jump up
	function jumpDelay()
		print("2",player.performingSpecial)
		player:modifiedJump( 0, self.dujSpeedY, false ) 
	end

	local t = timer.performWithDelay( 200, jumpDelay ) -- doesn't work here after new controls
	table.insert(self.specialTimerTable, t)

	self.duja = true
	
end

function Hank:downJump( player )

	if( DebugInstance.manaCost == true ) then player:reduceMP( self.downJumpMana ) end

	player:spriteSwap( "jump skills" ) -- swap sprite set to use skills
	player.sprite:setSequence( "dvj" )
	player.sprite:play()

	local function spawnWall()
		table.insert( self.walls, Hank_Wall:new( player ) )
	end

	local t = timer.performWithDelay( 650, spawnWall )
	table.insert(self.specialTimerTable, t)
	
end

function Hank:leftRightJump( player, direction )

	if( player.mpValue >= self.dlrjMana ) then

		player:darkenScreen( 400 )

		if( DebugInstance.manaCost == true ) then player:reduceMP( self.dlrjMana ) end
		
		-- dragon kick dash
		local function jumpDelay()

			player:spriteSwap( "jump skills" )
			player.sprite:setSequence( "dlrj" )
			player.sprite:play()
			
			if( direction == "left" ) then
				player:modifiedJump( -self.dlrjSpeedX, self.dlrjSpeedY, true, 600 ) -- true means offensive
			else
				player:modifiedJump( self.dlrjSpeedX, self.dlrjSpeedY, true, 600 ) -- true means offensive
			end
		end

		timer.performWithDelay( 400, jumpDelay )
		
		return true
	else
		return false
	end
end


function Hank:upJumpAttack( player )
	player.sprite:setSequence( "duja" )
	player.sprite:play()
	self.duja = false
end

function Hank:specialTime( type )
	if( type == "dva" ) then
		return 2000 -- needs to be around the same as animation time
	elseif( type == "dua" ) then
		return 800
	elseif( type == "duj" ) then
		return 1100
	elseif( type == "dla" or type == "dra" ) then
			return 800
	elseif( type == "dlj" or type == "drj" ) then
		return 9999 -- cannot be accurately determined, use code to return to idle
	elseif( type == "dvj" ) then
		return 800
	else
		return 0
	end
end

return Hank