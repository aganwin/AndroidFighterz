local AudioController = {
	mute = false,
}

-- singleton, no constructor.. >.<

function AudioController:loadSounds()
	self.punchSound = audio.loadSound("sounds/effects/punch.mp3") -- loadSound for small files
	self.blockedSound = audio.loadSound("sounds/effects/blocked.mp3")
	audio.setVolume( 0.2 )
end

function AudioController:loadBGM( stage )
	if( stage == "hk" ) then
		self.bgm = audio.loadStream("sounds/hk.mp3") -- stream for large files
	end
end

-- PLAYED IN EFFECTS.LUA
function AudioController:playSound( sound )
	if sound == "punch" then
		audio.play( self.punchSound )
	elseif sound == "blocked" then
		audio.play( self.blockedSound )
	end
end

function AudioController:playBGM()
	if( self.bgm ) then
		audio.play( self.bgm, {loops=-1} )
		audio.setVolume( 0.0 )
	end
end

function AudioController:soundOnOff()
	if mute == false then
		audio.setVolume( 0.0 )
		mute = true
	else
		audio.setVolume( 0.5 )
		mute = false
	end
end

return AudioController -- or else runtime error saying "AudioController is a boolean value" in other classes