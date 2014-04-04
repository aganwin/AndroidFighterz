local Effects = require( "gameplay.Effects" )
local Hank_Wall = require( "characters.skills.Hank_Wall" )

local Ball = {
	listOfBalls = {},

	-- for system pause
	paused = false,
	pauseTimeStart = 0,
	pauseTimeDiff = 0,
}

function Ball:detectHit( aggressor, ball, damage ) 

	for key, enemy in pairs(aggressor.opponents) do
		if( enemy.dead == false and enemy.invulnerable == false and enemy.fallen == false ) then
			if( math.abs(ball.sprite.x - enemy.sprite.x) < (ball.sprite.width + enemy.sprite.width)/4 ) then
				if( math.abs(ball.sprite.y - enemy.sprite.y) < 50 ) then
					if( ball.hitTarget == false ) then -- make sure ball only hits once
						ball.hitTarget = true

						if( enemy.defense == true and enemy.mirror == ball.mirror*-1 ) then
							enemy:defend( damage, ball.knockbackPowerX )
							Effects:def( ball, enemy )
						else
							enemy:getsHit( damage, "knockback+down", ball.mirror, false, ball.knockbackPowerX, ball.knockbackPowerY )
							-- play hit effect halfway between aggressor and enemy
							Effects:hit( ball, enemy )
						end
					end
				end
			end
		end
	end

	if( ball.caster == "Hank" ) then -- Hank fireball
		for key, w in pairs(aggressor.character.walls) do -- only if aggressor.character = Hank
			if( w.active == true ) then
				if( math.abs(ball.sprite.x - w.sprite.x) < (ball.sprite.width + w.sprite.width)/4 ) then
					if( ball.buffed == false ) then 
						ball.sprite:setSequence( "bigmoving" )
						ball.sprite:play()
						ball.buffed = true -- or else this line will keep playing
						-- play wall effect
						Hank_Wall:playTransform( w, ball.mirror )			
					end
				end
			end
		end
	end
end

function Ball:listener()
	for i,ball in pairs(self.listOfBalls) do

		ball.sprite.x = ball.sprite.x + ball.speed

		-- 2700 instead of 2500 to give it some time to be outside the screen
		if( ball.remove == true or ball.sprite.x + ball.sprite.width > 2700 or ball.sprite.x + ball.sprite.width < -100 ) then
			print("remove ball")
			ball.sprite.isVisible = false
			table.remove( self.listOfBalls, i ) -- table remove is done with index, not object (ball table)
			ball = nil
			return
		end

		if( system.getTimer() - ball.lastspeedup > ball.speedupinterval ) then
			self:speedup( ball, ball.speeduprate )
			ball.lastspeedup = system.getTimer()
		end

		if( ball.caster == "Hank" ) then			

			if ( ball.hitTarget == true ) then
				if( ball.buffed ) then
					if( ball.sprite.sequence ~= "bigexplode" ) then
						ball.sprite:setSequence("bigexplode")
						ball.sprite:play()
					end
				else
					if( ball.sprite.sequence ~= "explode" ) then
						ball.sprite:setSequence("explode")
						ball.sprite:play()
					end
				end

				ball.speed = 0
				ball.remove = true
				
			else
				if( ball.buffed ) then
					dmg = ball.castingPlayer.character.dlraDamage * 2
				else
					dmg = ball.castingPlayer.character.dlraDamage
				end
				self:detectHit( ball.castingPlayer, ball, dmg )
			end

		elseif( ball.caster == "Hero" ) then

			if ( ball.hitTarget == true ) then
				if( ball.sprite.sequence ~= "explode" ) then
					ball.sprite:setSequence("explode")
					ball.sprite:play()
				end
				ball.speed = 0
				ball.remove = true
			else
				self:detectHit( ball.castingPlayer, ball, ball.castingPlayer.character.dlraDamage )
			end
		end
	end
end

function Ball:speedup( b, rate )
	if( b ) then b.speed = b.speed * rate end
end

return Ball