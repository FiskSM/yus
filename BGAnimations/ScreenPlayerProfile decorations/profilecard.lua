local pn = GAMESTATE:GetEnabledPlayers()[1]
local profile = PROFILEMAN:GetProfile(pn)

local t = Def.ActorFrame{

}

t[#t+1] = Def.Quad{
	InitCommand = function (self)
		self:halign(0)
		self:zoomto(300,100)
		self:diffuse(color(colorConfig:get_data().main.frame)):diffusealpha(0.8)
	end
}

t[#t+1] = LoadActor("avatar") .. {
	InitCommand = function(self)
		self:xy(50,0)
	end;
}

t[#t+1] = LoadActor("expbar") .. {
	InitCommand = function(self)
		self:xy(100,5)
	end;
}


t[#t+1] = quadButton(3)..{
	InitCommand = function (self)
		self:xy(145,30)
		self:zoomto(90,20)
		self:diffuse(color(colorConfig:get_data().main.disabled)):diffusealpha(0.8)
	end
}

t[#t+1] = LoadFont("Common Normal")..{
	InitCommand  = function(self)
		self:xy(245,-20)
		self:zoom(0.35)
		self:settextf("Save password: ")
	end;
}

t[#t+1] = quadButton(1)..{
	InitCommand = function (self)
		self:xy(285,-20)
		self:zoomto(12,12)

		if playerConfig:get_data(pn_to_profile_slot(pn)).SavePass then
			self:diffuse(color(colorConfig:get_data().main.enabled)):diffusealpha(0.8)
		else
			self:diffuse(color(colorConfig:get_data().main.negative)):diffusealpha(0.8)
		end
	end;
	TopPressedCommand = function(self, params)
		if params.input == "DeviceButton_left mouse button" then
			playerConfig:get_data(pn_to_profile_slot(pn)).SavePass = not playerConfig:get_data(pn_to_profile_slot(pn)).SavePass
			if playerConfig:get_data(pn_to_profile_slot(pn)).SavePass == false then
				playerConfig:get_data(pn_to_profile_slot(pn)).Username = ""
				playerConfig:get_data(pn_to_profile_slot(pn)).Token = ""
				playerConfig:set_dirty(pn_to_profile_slot(pn))
				playerConfig:save(pn_to_profile_slot(pn))
			end
		end
		self:queuecommand("Init")
	end;
}

t[#t+1] = LoadFont("Common Bold")..{
	InitCommand  = function(self)
		self:xy(145,30)
		self:zoom(0.4)
		self:diffuse(color(colorConfig:get_data().selectMusic.TabContentText)):diffusealpha(0.4)
		self:queuecommand('Set')
	end;
	SetCommand = function(self)
		self:settext("Update")
	end;
}

t[#t+1] = quadButton(3)..{
	InitCommand = function (self)
		self:xy(245,30)
		self:zoomto(90,20)

		if DLMAN:IsLoggedIn() then
			self:diffuse(color(colorConfig:get_data().main.negative)):diffusealpha(0.8)
		else
			self:diffuse(color(colorConfig:get_data().main.enabled)):diffusealpha(0.8)
		end
	end;

	-- Login
	StartLoginCommand = function(self)
		if playerConfig:get_data(pn_to_profile_slot(pn)).SavePass == false or 
		playerConfig:get_data(pn_to_profile_slot(pn)).Username == "" or
		playerConfig:get_data(pn_to_profile_slot(pn)).Token == "" then

			local username = function(answer) user = answer end
			local password = function(answer) 
				pass = answer 
				DLMAN:Login(user, pass)
			end

			easyInputStringWithFunction("Password:", 50, true, password)
			easyInputStringWithFunction("Username:",50, false, username)
		else
			local user = playerConfig:get_data(pn_to_profile_slot(pn)).Username
			local Token = playerConfig:get_data(pn_to_profile_slot(pn)).Token
			DLMAN:LoginWithToken(user, Token)
		end
	end;

	-- Save config upon successful login
	LoginMessageCommand = function(self)
		self:diffuse(color(colorConfig:get_data().main.negative)):diffusealpha(0.8)
		playerConfig:get_data(pn_to_profile_slot(pn)).Username = user
		playerConfig:get_data(pn_to_profile_slot(pn)).Token = DLMAN:GetToken()
		playerConfig:set_dirty(pn_to_profile_slot(pn))
		playerConfig:save(pn_to_profile_slot(pn))
		SCREENMAN:SystemMessage("Login Successful!")
	end;

	-- Do nothing on failed login
	LoginFailedMessageCommand = function(self)
		playerConfig:get_data(pn_to_profile_slot(pn)).Username = ""
		playerConfig:get_data(pn_to_profile_slot(pn)).Token = ""
		playerConfig:set_dirty(pn_to_profile_slot(pn))
		playerConfig:save(pn_to_profile_slot(pn))
		SCREENMAN:SystemMessage("Login Failed!")
	end;

	-- delete config upon logout
	StartLogoutCommand = function(self)
		if playerConfig:get_data(pn_to_profile_slot(pn)).SavePass then
			DLMAN:Logout()
		else			
			playerConfig:get_data(pn_to_profile_slot(pn)).Username = ""
			playerConfig:get_data(pn_to_profile_slot(pn)).Password = ""
			playerConfig:set_dirty(pn_to_profile_slot(pn))
			playerConfig:save(pn_to_profile_slot(pn))
			DLMAN:Logout()
		end
	end;

	LogOutMessageCommand=function(self)
		self:diffuse(color(colorConfig:get_data().main.enabled)):diffusealpha(0.8)
		SCREENMAN:SystemMessage("Logged Out!")
	end,

	TopPressedCommand = function(self)
		if not DLMAN:IsLoggedIn() then
			self:playcommand("StartLogin")
		else
			self:playcommand("StartLogout")
		end

		self:finishtweening()
		self:diffusealpha(1)
		self:smooth(0.3)
		self:diffusealpha(0.8)
	end;
}

t[#t+1] = LoadFont("Common Bold")..{
	InitCommand  = function(self)
		self:xy(245,30)
		self:zoom(0.4)
		self:diffuse(color(colorConfig:get_data().selectMusic.TabContentText))
		if DLMAN:IsLoggedIn() then
			self:settext("Logout")
		else 
			self:settext("Login")
		end
	end;

	LoginMessageCommand = function(self)
		self:settext("Logout")
	end;

	LogOutMessageCommand=function(self)
		self:settext("Login")
	end,
}


-- Player name
t[#t+1] = LoadFont("Common BLarge")..{
	InitCommand  = function(self)
		self:xy(100,-25)
		self:zoom(0.33)
		self:halign(0)
		self:diffuse(color(colorConfig:get_data().selectMusic.TabContentText))
		self:queuecommand('Set')
	end;
	LoginMessageCommand = function(self) self:queuecommand('Set') end;
	LogOutMessageCommand = function(self) self:queuecommand('Set') end;

	SetCommand = function(self)
		local text = ""
		if profile ~= nil then
			text = getCurrentUsername(pn)
			if text == "" then
				text = pn == PLAYER_1 and "Player 1" or "Player 2"
			end
		end
		self:maxwidth(320)
		self:settext(text)
	end;
}

return t