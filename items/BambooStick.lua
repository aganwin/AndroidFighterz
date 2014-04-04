local BambooStick = {
	holdPointX = 0, -- 70 if reversed
	holdPointY = 0,
	damage = 50,
	bounciness = 0.4, -- 0.7 default, 0.9 = very high bounce, 0.75 = will still bounce too horizontally far
	friction = 0.7, -- coefficient of friction, or else everything will fly very far horizontally even with low bounciness
	rotatability = 0.2, -- 0.1 = won't rotate much, 1 = see baseball for example
}

local BambooStick_metatable = {
	__index = BambooStick
}

function BambooStick:new()
	i = {}
	setmetatable( i, BambooStick_metatable )
	return i
end

-- when throw, remove listener, etc.
function BambooStick:reset()
end

return BambooStick