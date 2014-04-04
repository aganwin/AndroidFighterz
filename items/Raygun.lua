local rays = {}

local Raygun = {
	holdPointX = 25, -- 70 if reversed
	holdPointY = 5,
	--ability = shoot,
	rays = rays,
	listenerAdded = false,
	damage = 10,
	bounciness = 0.02,
	friction = 0.8,
	rotatability = 0.1,
}

local Raygun_metatable = {
__index = Raygun
}

function Raygun:new()
	i = {}
	setmetatable( i, Raygun_metatable )
	return i
end

function Raygun:newRay( x, y, direction )
	local ray = display.newRect( x + direction*60, y - 8 , 80, 5 )
	ray:setFillColor( 255,255, 0 )
	ray.direction = direction
	return ray
end




function Raygun:ability( x, y, direction, player )

	function moveRays()

		if( #self.rays ~= 0 ) then
			for k,v in pairs( self.rays ) do
				v.x = v.x + v.direction*30
				-- upon contact with enemy
        for k, o in pairs( player.opponents ) do
          if( math.abs( v.x - o.sprite.x ) <= 50 and math.abs( v.y - o.sprite.y ) <= 50 ) then
            v = nil
            print 'enemy hit'
            o:getsHit( self.damage, "punch" )
          end
        end
				if( v.x < 0 or v.x > display.contentWidth ) then
					v = nil
				end
			end
		end

	end

	table.insert( self.rays, self:newRay( x, y, direction ) )

	print( #self.rays )

	if( self.listenerAdded == false ) then
		print 'Add moveRays() listener'
		Runtime:addEventListener( "enterFrame", moveRays )
		self.listenerAdded = true
	end

	print 'Raygun shot a ray'
	

end

-- when throw, remove listener, etc.
function Raygun:reset()
	print 'Reset Raygun'
	self.rays = {}
end

return Raygun