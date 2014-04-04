--Tools.lua
local Tools = {}

-- Testing only
-- local min = 0.8
-- local max = 2.5
-- local power = math.random()+1
-- local arr = {}

-- local sum = 0

-- for i=1,20 do
--     local rand = min+(max-min)*math.random()^power
--     print(rand)
--     table.insert(arr,rand)
--     sum = sum+rand
-- end

-- table.sort(arr)
-- print("High = ",arr[#arr], "Low = ", arr[1])
-- print("Mean = ", sum/20)

function Tools:generateRandomNumber(min,max,power)
	return min+(max-min)*math.pow(math.random(),power)
end

return Tools