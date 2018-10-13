local alphaInactive = 0.4

local frameWidth = 200
local frameHeight = 20
local frameX = SCREEN_WIDTH-305
local frameY = 10

local searchstring = ""
local active = false
local wheel
local isDeleting = false

local verts= {
	{{-170, 0, 0}, getMainColor('highlight')},
	{{-180, 20, 0}, getMainColor('highlight')},
	{{10, 20, 0}, getMainColor('highlight')},
	{{20, 0, 0}, getMainColor('highlight')},
}

local function searchInput(event)
	if event.type ~= "InputEventType_Release" and 
		event.DeviceInput.button ~= "DeviceButton_left mouse button" and
		event.DeviceInput.button ~= "DeviceButton_right mouse button" and 
		active then

		if event.button == "Back" then
			searchstring = ""
			wheel:SongSearch("")
			MESSAGEMAN:Broadcast("EndSearch")

		elseif event.button == "Start" then
			MESSAGEMAN:Broadcast("EndSearch")

		elseif event.DeviceInput.button == "DeviceButton_space" then					-- add space to the string
			searchstring = searchstring.." "

		elseif event.DeviceInput.button == "DeviceButton_backspace" then
			if searchstring == "" then
				MESSAGEMAN:Broadcast("EndSearch")
			else
				searchstring = searchstring:sub(1, -2) -- remove the last element of the string
				isDeleting = true
				MESSAGEMAN:Broadcast("UpdateString")
			end					

		elseif event.DeviceInput.button == "DeviceButton_delete"  then
			searchstring = ""

		elseif event.DeviceInput.button == "DeviceButton_="  then
			searchstring = searchstring.."="

		else
			--if not nil and (not a number or (ctrl pressed and not online))
			if event.char then
				searchstring = searchstring..event.char
				isDeleting = false
			end	
		end

		if not isDeleting or searchstring=="" then
			MESSAGEMAN:Broadcast("UpdateString")
			wheel:SongSearch(searchstring)
		end
	end
end

local t = Def.ActorFrame{
	InitCommand = function(self)
		self:xy(frameX,frameY)
		self:GetChild("Searchstr"):smooth(0.2):diffusealpha(alphaInactive-0.2):settext("Type to Search..")
		SCREENMAN:set_input_redirected(PLAYER_1, false)
	end;
	OnCommand = function(self)
		wheel = (SCREENMAN:GetTopScreen()):GetMusicWheel()
		SCREENMAN:GetTopScreen():AddInputCallback(searchInput)
		self:y(-frameHeight/2)
		self:smooth(0.5)
		self:y(frameY)
	end;
	OffCommand = function(self)
		self:smooth(0.5)
		self:y(-frameHeight/2)
	end;
	StartSearchMessageCommand = function(self)
		active = true
		self:GetChild("Icon"):smooth(0.2):diffusealpha(0.7)
		self:GetChild("IconB"):smooth(0.2):diffusealpha(alphaInactive)
		self:GetChild("Searchstr"):smooth(0.2):diffusealpha(1)
		SCREENMAN:set_input_redirected(PLAYER_1, true)
	end;
	EndSearchMessageCommand = function(self)
		SCREENMAN:set_input_redirected(PLAYER_1, false)
		active = false
		self:GetChild("Icon"):smooth(0.2):diffusealpha(alphaInactive-0.2)
		self:GetChild("IconB"):smooth(0.2):diffusealpha(0)
		if searchstring == "" then
			self:GetChild("Searchstr"):smooth(0.2):playcommand("ChangeText")
		else
			self:GetChild("Searchstr"):diffusealpha(alphaInactive)
		end
	end;
};

t[#t+1] = quadMV(verts) .. {
	InitCommand=function(self)
		self:xy(-19,-10)
		self:diffusealpha(0.8)
	end;
};

t[#t+1] = quadButton(4) .. {
	InitCommand = function(self)
		self:halign(1)
		self:zoomto(frameWidth,frameHeight)
		self:visible(false)
	end;
	TopPressedCommand = function(self)
		MESSAGEMAN:Broadcast("StartSearch")
	end;
};

t[#t+1] = LoadActor(THEME:GetPathG("", "searchicon")) .. {
	Name="Icon";
	InitCommand = function(self)
		self:x(13-frameWidth)
		self:halign(0)
		self:zoom(0.53)
		self:diffusealpha(alphaInactive-0.1)  --yep, this sucks so much, must edit the image file
	end,
};

t[#t+1] = LoadActor(THEME:GetPathG("", "searchb")) .. {
	Name="IconB";
	InitCommand = function(self)
		self:xy(SCREEN_CENTER_X-frameX,(SCREEN_HEIGHT-10)/2)
		self:zoom(0.2)
		self:diffusealpha(0)
	end,
}

t[#t+1] = LoadFont("Common Normal")..{
	Name="Searchstr";
	InitCommand=function(self)
		self:x(30-frameWidth)
		self:halign(0)
		self:zoom(0.45)
		self:diffuse(color(colorConfig:get_data().main.headerFrameText))
		self:maxwidth((frameWidth-30)/0.45)
	end,
	ChangeTextCommand = function(self)
		if searchstring == "" then
			self:diffusealpha(alphaInactive)
			self:settext("Type to Search..")
		else
			self:settext(searchstring)
			self:diffusealpha(1)
		end
	end;
	UpdateStringMessageCommand = function(self)
		self:queuecommand("ChangeText")
	end;
};

return t
