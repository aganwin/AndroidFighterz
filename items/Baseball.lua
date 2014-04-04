local Baseball = {
	holdPointX = 0, -- 70 if reversed
	holdPointY = 0,
	damage = 50,
	bounciness = 0.05, -- 0.7 default, 0.9 = very high bounce, 0.75 = will still bounce too horizontally far
	friction = 0.3, -- coefficient of friction, or else everything will fly very far horizontally even with low bounciness
	rotatability = 1, -- 0.1 = won't rotate much, 1 = see baseball for example
}

local Baseball_metatable = {
	__index = Baseball
}

function Baseball:new()
	i = {}
	setmetatable( i, Baseball_metatable )
	return i
end

-- when throw, remove listener, etc.
function Baseball:reset()
end

return Baseball