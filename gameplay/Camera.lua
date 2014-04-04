---------------------
-- camera is just a display group
-- what belongs to the camera?
---------------------

local camera = {
	group = display.newGroup()
}

camera.scrollSpeedX = 0
camera.slowScrollSpeedX = display.contentWidth/450
camera.fastScrollSpeedX = display.contentWidth/250
camera.newX = 1

function camera:reset()
	camera.group:removeSelf()
	camera.group = display.newGroup()
end

-- do more stuff here
function camera:scroll()
	-- for a brief second, sprite is removed and replaced, which causes camera to mess up (badly)
	if camera.player.mirror == 1 then
		if camera.player.sprite.x > display.contentWidth*0.4 then
			if( camera.player.running == true ) then
				camera.scrollSpeedX = camera.fastScrollSpeedX
				camera.newX = -camera.player.sprite.x + display.contentWidth/2
			elseif( camera.player.movementOverride == true or camera.player.performingSpecial ~= "none" ) then
				camera.scrollSpeedX = camera.fastScrollSpeedX * 2
				camera.newX = -camera.player.sprite.x + display.contentWidth/2
			else
				camera.scrollSpeedX = camera.slowScrollSpeedX
				camera.newX = -camera.player.sprite.x + display.contentWidth*0.4
			end
		end
	else
		if camera.player.sprite.x < camera.rightBoundX - display.contentWidth*0.6 then
			if( camera.player.running == true ) then
				camera.scrollSpeedX = camera.fastScrollSpeedX
				camera.newX = -camera.player.sprite.x + display.contentWidth/2
			elseif( camera.player.movementOverride == true or camera.player.performingSpecial ~= "none" ) then
				camera.scrollSpeedX = camera.fastScrollSpeedX * 2
				camera.newX = -camera.player.sprite.x + display.contentWidth/2
			else
				camera.scrollSpeedX = camera.slowScrollSpeedX
				camera.newX = -camera.player.sprite.x + display.contentWidth*0.6
			end
		end
	end	

	camera:ease()
end

function camera:ease()
	if( camera.newX > -1200 and camera.newX < 0 ) then
		local directionX = (camera.newX - camera.group.x)/math.abs(camera.newX - camera.group.x)
		if camera.group.x < camera.newX - camera.scrollSpeedX or camera.group.x > camera.newX + camera.scrollSpeedX then
			camera.group.x = camera.group.x + directionX * camera.scrollSpeedX
		end
	end
end

return camera