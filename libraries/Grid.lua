
local pathfinder = require("pathfinder")

-- constants to fiddle with
local kRoadProbability = 8 -- number between 0 and 10 with 10 being a lot of roads and 0 being none

-- our map to be generated --
local Grid = {
	level = {},
	cells = {},
	startCell = {},
	endCell = {},
	top = 0,
	bot = 0,
	oldPath = {},
	oldPathLength = 0,
	currentPathXY = {},
	currentPathXY1 = {},
	currentPathXY2 = {},
	insert1 = true,
	deleteOldPath = 0,
}

-- builds our grid --
function Grid:buildGrid( top, bot )

	self.top = top
	self.bot = bot

	self.kLevelCols = 40
	self.kLevelRows = 57.6 * (bot-top)/display.contentHeight
	self.cellWidth = display.contentWidth / 40 -- walking speed X
	self.cellHeight = display.contentHeight / 57.6 -- walking speed Y

    -- build map array --
    for x = 0, self.kLevelCols do
        self.level[x] = {}
        for y = 0, self.kLevelRows do
            local probability = math.random(0,10)
            if probability <= kRoadProbability then
                self.level[x][y] = 1
            else
                self.level[x][y] = 0
            end
        end
    end

    -- build screen now --
    for x = 0, self.kLevelCols do
        for y = 0, self.kLevelRows do
            local cell = display.newRect(x*self.cellWidth, self.top+y*self.cellHeight, self.cellWidth, self.cellHeight)
    
            cell.strokeWidth = 1
            cell:setStrokeColor(0,0,0)

            if self.level[x][y] == 0 then
                cell:setFillColor(255, 0, 0)
            end
            
            if self.cells[x] == nil then
                self.cells[x] = {}
            end
            
            self.cells[x][y] = cell
            self.cells[x][y].alpha = 0
        end
    end
end

-- called to get the A* algorithm going --
function Grid:onDetermineAStar( a, xi, yi, xf, yf )

	self.startCell.col = math.floor( xi / self.cellWidth )
	self.startCell.row = math.floor( (yi - self.top) / self.cellHeight )

	self.endCell.col = math.floor( xf / self.cellWidth )
	self.endCell.row = math.floor( (yf - self.top) / self.cellHeight )

	-- run A* --
  	local path = pathfinder.pathFind(self.level, self.kLevelCols, self.kLevelRows, self.startCell.col, self.startCell.row, self.endCell.col, self.endCell.row)
    --local path = pathfinder.pathFind(self.level, self.kLevelCols, self.kLevelRows, startCell.col, startCell.row, endCell.col, endCell.row)
    --pprint("Path", path)

    -- the following chunk of code HAS to be in front of the if path~=false, or else line will flash
    -- ***
    self:pickShorterPath()

    -- printing here won't make the path flash, but if you do it inside the
	-- if path ~= false condition, it will
    if( #self.oldPath ~= self.oldPathLength ) then
    	--print( "erase old path only if a new one has been found" )
    	self:eraseOldPath()
    end 
    -- ***
    -- end of chunk

    if path ~= false then

        -- color the path --
    	local currentCell = {x=self.startCell.col, y=self.startCell.row}
    
        for k = 0, #path do
            local cellDirectionX = path[k].dx
            local cellDirectionY = path[k].dy
            local count = path[k].count


            
            for l = 1, count do
                currentCell.x = currentCell.x + cellDirectionX
                currentCell.y = currentCell.y + cellDirectionY

                a.directionX = path[k].dx
                a.directionY = path[k].dy

                -- erase old path later
                table.insert( self.oldPath, self.cells[currentCell.x][currentCell.y] )
                if( self.insert1 ) then
                	table.insert( self.currentPathXY1, { currentCell.x, currentCell.y } )
                	self.insert1 = false
                	self.deleteOldPath = self.deleteOldPath + 1
                else
                	table.insert( self.currentPathXY2, { currentCell.x, currentCell.y } )
                	self.insert1 = true
                	self.deleteOldPath = self.deleteOldPath + 1
                end
                
                if currentCell.x ~= self.endCell.col or currentCell.y ~= self.endCell.row then
                    self:colorCell(self.cells[currentCell.x][currentCell.y], 0, 255, 0)
                    self.cells[currentCell.x][currentCell.y].strokeWidth = 2
                    self.cells[currentCell.x][currentCell.y].alpha = 1
                end


            end
        end
    end

    --print( #self.currentPathXY )
    --print( self.deleteOldPath )
    return self.currentPathXY
end

-- returns table containing index values based on where a user clicked on the grid --
function Grid:getIndices(x, y)
    return {math.floor(x / self.cellWidth), math.floor(y / self.cellHeight)}
end

-- gets the display.newRect object based on x,y value --
function Grid:getCell(x, y)
    local indices = self:getIndices(x, y)
    return self.cells[indices[1]][indices[2]]
end

-- colors a cell on the grid --
function Grid:colorCell(cell, red, green, blue)
    cell:setFillColor(red, green, blue)
end

-- erase old path --
-- only if new one has been found
-- erase means set it back to whatever color and transparency the grid is, not total erase
function Grid:eraseOldPath()
	self.oldPathLength = #self.oldPath
    for i, c in pairs(self.oldPath) do
    	--c:setFillColor(255,255,255) -- fill white again
    	c.alpha = 0 -- set alpha to 0.5 again
    end
    self.oldPath = {} -- clear all, wait for insertion of next path

    if( self.deleteOldPath > 2 ) then
    	self.currentPathXY2 = {}
    	self.currentPathXY1 = {}
    	self.deleteOldPath = 0 
    end
end

function Grid:pickShorterPath()

	--print( #self.currentPathXY )
	-- Nov.6 - this still shows varying lengths, not sure why

	if( #self.currentPathXY1 > #self.currentPathXY2 ) then
		self.currentPathXY = self.currentPathXY2
	else
		self.currentPathXY = self.currentPathXY1
	end
end

return Grid
