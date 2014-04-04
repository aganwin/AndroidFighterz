local Stage = {}
local AudioController = require( "gameplay.AudioController" )


-- notes:
-- max size is 2048 x 2048, might as well cut it up 


local Stage_metatable = {
--__index = Stage
}

function Stage:pick( map )
	s = {}
	--setmetatable( s, Stage_metatable )
	s.path = "images/backgrounds/"..map.."/"
	s.bgGroup = display.newGroup()
	s.elementsNeededOnTop = display.newGroup()

	-- display the background, make sure its full res
	s.bg = display.newImageRect( s.path.."hkstreet.png", 2500, 720 )
	s.bg:setReferencePoint( display.TopLeftReferencePoint )
	s.bg.x = 0
	s.bg.y = 0

	s.bgGroup:insert(s.bg)

	if( map == "hk" ) then		
		-- poles and fences (specific to the background)
		s.fences = {}
		for i=0,18 do
			local fence = display.newImageRect( s.path.."hkfence.png", 138, 91 )
			fence:setReferencePoint( display.BottomLeftReferencePoint )
			fence.x = i * fence.contentWidth * 130/138 -- fence was not drawn for repeating, the pole is 8 pixels wide
			fence.y = display.contentHeight
			s.elementsNeededOnTop:insert(fence) -- because fence needs to be on top
			table.insert( s.fences, fence )

			s.boundaryLeft = 0
			s.boundaryRight = s.bg.contentWidth
			-- set boundary points based on pic and its size
			s.boundaryTop = display.contentHeight * 0.37
			s.boundaryBot = display.contentHeight

			AudioController:loadBGM("hk")
		end
	end	
	
	
	

	Stage.boundaryTop = s.boundaryTop
	Stage.boundaryBot = s.boundaryBot
	Stage.boundaryRight = s.boundaryRight

	return s
end

function Stage:initPosition( player )
	s.bg.x = player.sprite.x
end

function Stage:scroll( player )
	if( player.directionX == 0 ) then
	else		
		local toShift = player.directionX * -1 * display.contentWidth/400
		if( s.bg.x + toShift > display.contentWidth/2 and s.bg2.x + toShift < display.contentWidth * 3/2 ) then
			s.bg.x = s.bg.x + toShift
		end
	end
end

return Stage