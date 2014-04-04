crypto = require("crypto")
require("libraries.noobhub")
local widget = require( "widget" )

hub = noobhub.new({ server = "192.210.143.132"; port = 1337; }); 

local login = {
	username = "",
	password = "",
	email = "",
	country = "",
	drawn = false,
	loggedIn = false,
}

function login:init()

	function returnBtnTouch( event )
		if event.phase == "began" then
			login:close()
			--modeSelMenu.greyOut.isVisible = false
			--modeSelMenu.battleModeBtn.isVisble = true
		end
		return true
	end	

	function loginButtonTouch( event )
		if event.phase == "began" then
			login:connect() 
			login:loginNow() -- not sure if subscribe and publish needs to be separate
			-- don't evaluate loginSuccess here, login.lua will proc the success/failure because it takes network time
		end
		return true
	end

	function signUp(event)
		if event.phase == "began" then
			-- does signup action here
			local webView = native.newWebView( 0, 0, display.contentWidth, display.contentHeight )
			webView:request( "http://192.210.143.132:8080/signup" )

			local function webListener( event )
			    if event.type == "other" then 
			    	-- assume user signed up successfully.. should be "formsubmmited" instead though
			    	webView:removeSelf()
			    end
			end
			
			webView:addEventListener( "urlRequest", webListener )

			self.group:insert(webView)
		return true
		end
	end

	self.returnBtn = display.newCircle( 865/1280 * display.contentWidth, 230/720 * display.contentHeight, 35/1280 * display.contentWidth )
	self.loginWindow = display.newImage( "images/login/login.png", 0, 0 )
	self.returnBtn:setFillColor( 255,255,0 )-- just for testing 
	self.returnBtn.alpha = 0.01

	self.returnBtn:addEventListener( "touch", returnBtnTouch )

	self.loginButton = display.newRect( display.contentWidth*520/1280, display.contentHeight*510/720, display.contentWidth*250/1280, display.contentHeight*50/720 )
	self.loginButton:addEventListener( "touch", loginButtonTouch )
	self.loginButton.alpha = 0.01

	-- sign up button (can be later just grouped with the other UI)
	self.signUpButton = display.newImage( "images/login/signup.png", 0, 0 )
	self.signUpButton.x = display.contentWidth*0.8
	self.signUpButton.y = display.contentCenterY
	self.signUpButton:addEventListener( "touch", signUp )
	
	self.group = display.newGroup( )		
	self.group:insert(self.returnBtn)
	self.group:insert(self.loginButton)
	self.group:insert(self.loginWindow)
	self.group:insert(self.signUpButton)

	self.drawn = true

end

function login:initTextFields()
	-- native UI
	self.usernameField = native.newTextField( display.contentWidth*420/1280, display.contentHeight*315/720, display.contentWidth*400/1280, display.contentHeight*30/720 )
	self.passwordField = native.newTextField( display.contentWidth*420/1280, display.contentHeight*395/720, display.contentWidth*400/1280, display.contentHeight*30/720 )

	self.usernameField:toBack()
	self.passwordField:toBack()

	function usernameListener( event )
		login.username = event.text -- self.username would refer to this function's username variable which DNE
	end

	function passwordListener( event )
		login.password = event.text -- self.username would refer to this function's username variable which DNE
	end

	self.usernameField.userInput = usernameListener
	self.usernameField:addEventListener( "userInput", usernameField )
	self.passwordField.userInput = passwordListener
	self.passwordField:addEventListener( "userInput", passwordField )
end

function login:showProfile()

	function returnBtnTouch( event )
		if event.phase == "began" then
			login:close()
			--modeSelMenu.greyOut.isVisible = false
			--modeSelMenu.battleModeBtn.isVisble = true
		end
		return true
	end	

	-- show user profile

	self.profile = native.newTextBox( 200, 200, 280, 140 )
	self.profile.text = "Username: "..self.username.."\nEmail: "..self.email.."\nCountry: "..self.country
	
	-- exceptions for newly added variables that might not exist in older accounts, serves as sample code
	if( self.winCount == nil ) then
		login:addIndex("winCount")
	else
		self.profile.text = self.profile.text.."\nWin Count: "..self.winCount
	end

	if( self.loseCount == nil ) then
		login:addIndex("loseCount")
	else
		self.profile.text = self.profile.text.."\nLose Count: "..self.loseCount
	end
	
	self.returnBtn = display.newImage( "images/login/signup.png", 0, 0 )
	self.returnBtn.x = display.contentWidth*0.8
	self.returnBtn.y = display.contentCenterY 
	self.returnBtn:addEventListener( "touch", returnBtnTouch )

	self.group = display.newGroup( )	
	self.group:insert(self.profile)	
	self.group:insert(self.returnBtn)

	self.drawn = true
end

function login:popUp( modeSelMenu )

	login.modeSelMenu = modeSelMenu

	if( self.loggedIn == false ) then
		if( self.drawn == false ) then
			self:init()
		else
			self.group.isVisible = true
		end

		login:initTextFields()
	else 
		if(self.group) then
			-- remove old display group elements that consisted of the login window
			self.group:removeSelf()
		end
		login:showProfile()
		self.group.isVisible = true
	end

	return self.group
end

function login:connect()
	hub:subscribe({
	    channel = "hello-world";  
	    callback = function(message)

		    if(message.action == "login") then
				print( "Attempting to login" )
			end

	        if(message.action == "Login_success") then
				print( "Login successful as "..login.username.."!" )
				native.showAlert( "Login status", "Logged in successfully as "..login.username.."!" )
				login:close()
				login:getCredentials()
				login.loggedIn = true				
			end

			if(message.action == "Login_fails_on_user" or message.action == "Login_fails_on_pass") then
				print( "Wrong username or password, please try again" )
				print( "Username = ", login.username )
				print( "Password = ", login.password )
				native.showAlert( "Login status", "Failed to log in, please try again." )
			end

			if(message.action == "get_credentials_success") then
				self.username = message.username
				self.email = message.email
				self.country = message.country
				self.winCount = message.winCount
				self.loseCount = message.loseCount
				self.points = message.points
				self.gold = message.gold
			end

			if(message.action == "add_index_success") then
				print("add index success said server...")
				if( message.index == "winCount" ) then
					self.winCount = 0
				elseif( message.index == "loseCount" ) then
					self.loseCount = 0
				elseif( message.index == "points" ) then
					self.points = 0
				elseif( message.index == "gold" ) then
					self.gold = 0
				end
			end
	    end;
	});
end

function login:getCredentials()
	hub:publish({
	    message = {
	        action = "get_credentials",
	        username = login.username,
	    }
	});
end

function login:addIndex(index)
	hub:publish({
		message = {
			action = "add_index",
			index = index,
		}
	});
end

function login:loginNow()
	hub:publish({
	    message = {
	        action = "login",
	        username = login.username,
	        password = login.password,
	    }
	});
end

function login:close() -- either from the return button or successful login was executed
	self.group.isVisible = false
	if( self.loggedIn == false ) then
		self.usernameField:removeSelf() -- doesn't exist if profile is already loaded
		self.passwordField:removeSelf() 
	else
		self.profile:removeSelf()
	end

	self.modeSelMenu:reenable()
end

return login

