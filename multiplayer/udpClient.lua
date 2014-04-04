-- udp.lua
local udpClient = {}

local socket = require("socket")
local udp = socket.udp()

local address = "localhost"
local port = 1338

function udpClient:init()
	udp:settimeout(0)
	udp:setpeername(address,port)
end

function udpClient:sayHello()
	print('sending hello')
	udp:send("hello its me")
end

return udpClient