local t = Def.ActorFrame{}
local pn = GAMESTATE:GetEnabledPlayers()[1]
local profile = GetPlayerOrMachineProfile(pn)
local steps = GAMESTATE:GetCurrentSteps(pn)


t[#t+1] = LoadActor("../_frame");
t[#t+1] = LoadActor("../_mouse");

local curTab = 1
local function input(event)
	if event.type == "InputEventType_FirstPress" then
		-- For swapping back and forth between scoreboard and offset display.
		for i=1,2 do
			if event.DeviceInput.button == "DeviceButton_"..i then
				if i ~= curTab then
					curTab = i
					MESSAGEMAN:Broadcast("TabChanged",{index = i})
					SOUND:PlayOnce(THEME:GetPathS("","whoosh"),true)
				end
			end
		end

	end
	return false
end


--Group folder name
local frameWidth = 280
local frameHeight = 20
local frameX = SCREEN_WIDTH-10
local frameY = 10
local verts= {
	{{-260, 0, 0}, getMainColor('highlight')},
	{{-270, 20, 0}, getMainColor('highlight')},
	{{10, 20, 0}, getMainColor('highlight')},
	{{20, 0, 0}, getMainColor('highlight')},
}

t[#t+1] = Def.ActorFrame{
	InitCommand = function(self)
		self:xy(frameX,frameY)
	end;
	OnCommand = function(self)
		SCREENMAN:GetTopScreen():AddInputCallback(input)
		self:y(-frameHeight/2)
		self:smooth(0.5)
		self:y(frameY)
	end;
	OffCommand = function(self)
		self:smooth(0.5)
		self:y(-frameHeight/2)
	end;
	quadMV(verts) .. {
		InitCommand=function(self)
			self:xy(-19,-10)
			self:diffusealpha(0.8)
		end;
	};
	LoadFont("Common Normal") .. {
		InitCommand=function(self)
			self:x(-frameWidth+5):halign(0):zoom(0.45):maxwidth((frameWidth-10)/0.45)
		end;
		BeginCommand=function(self)
			self:diffuse(color(colorConfig:get_data().main.headerFrameText))
			local song = GAMESTATE:GetCurrentSong()
			if song ~= nil then
				self:settext(song:GetGroupName())
			end;
		end;
	};
}

t[#t+1] = LoadActor("../_cursor");

t[#t+1] = quadButton(6)..{
	InitCommand = function(self)
		self:xy(SCREEN_WIDTH-10,53)
		self:zoomto(48, 48)
		self:diffusealpha(0)
		self:halign(1)
	end;
	TopPressedCommand = function(self)
		self:diffusealpha(0.2)
		self:smooth(0.3)
		self:diffusealpha(0)
		SaveScreenshot(nil, false, false)
	end;
}

t[#t+1] = LoadActor(THEME:GetPathG("", "screenshot")) .. {
	InitCommand = function(self)
		self:xy(SCREEN_WIDTH-17,36)
		self:halign(1):valign(0)
		self:zoom(0.26)
	end;
}

local largeImageText = string.format("%s: %5.2f",profile:GetDisplayName(), profile:GetPlayerRating())

-- Max 64 for title, 32 for artist.
local title = GAMESTATE:GetCurrentSong():GetDisplayMainTitle()
title = #title < 64 and title or string.format("%s...", string.sub(title, 1, 60))

local artist = GAMESTATE:GetCurrentSong():GetDisplayArtist()
artist = #artist < 32 and artist or string.format("%s...", string.sub(artist, 1, 28))

local detail = string.format("Results: %s - %s (%s)", artist, title, string.gsub(getCurRateDisplayString(), "Music", ""))

local difficulty = getDifficulty(steps:GetDifficulty())
local stepsType = ToEnumShortString(steps:GetStepsType()):gsub("%_"," ")
local MSD = steps:GetMSD(getCurRateValue(),1)
MSDString = MSD > 0 and string.format("(%5.2f)", MSD) or "(Unranked)"

local state = string.format("%s %s %s",stepsType, difficulty, MSDString)

GAMESTATE:UpdateDiscordPresence(largeImageText, detail, state, 0)

return t