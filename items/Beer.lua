local Beer = {
	holdPointX = 0, -- 70 if reversed
	holdPointY = 0,
	damage = 50,
	bounciness = 0.05, -- 0.7 default, 0.9 = very high bounce, 0.75 = will still bounce too horizontally far
	friction = 0.9, -- coefficient of friction, or else everything will fly very far horizontally even with low bounciness
	rotatability = 1, -- 0.1 = won't rotate much, 1 = see Beer for example
}

local Beer_metatable = {
	__index = Beer
}

function Beer:new()
	i = {}
	setmetatable( i, Beer_metatable )
	return i
end

-- when throw, remove listener, etc.
function Beer:reset()
end

return Beer