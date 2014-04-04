-- Hierarchical FSM

local fsm = {
	activeState = nil, -- points to current active state, which is a function type
}

local fsm_metatable = { __index = fsm }

function fsm.new()
	local f = {}
	setmetatable( f, fsm_metatable )
	return f
end

function fsm:setState(state)
	activeState = state
end

function fsm:update()
	if(activeState) then
		activeState()
	end
end

return fsm