local frameWidth = 280
local frameHeight = 20
local frameX = SCREEN_WIDTH-10
local frameY = 10

local top
local wheel
local song

local verts= {
	{{-280, 0, 0}, getMainColor('highlight')},
	{{-290, 20, 0}, getMainColor('highlight')},
	{{10, 20, 0}, getMainColor('highlight')},
	{{20, 0, 0}, getMainColor('highlight')},
}

local sortTable = {
	SortOrder_Preferred 			= 'Preferred',
	SortOrder_Group 				= 'Group',
	SortOrder_Title 				= 'Title',
	SortOrder_BPM 					= 'BPM',
	SortOrder_Popularity 			= 'Popular',
	SortOrder_TopGrades 			= 'Grade',
	SortOrder_Artist 				= 'Artist',
	SortOrder_Genre 				= 'Genre',
	SortOrder_BeginnerMeter 		= 'Beginner Meter',
	SortOrder_EasyMeter 			= 'Easy Meter',
	SortOrder_MediumMeter 			= 'Normal Meter',
	SortOrder_HardMeter 			= 'Hard Meter',
	SortOrder_ChallengeMeter 		= 'Insane Meter',
	SortOrder_DoubleEasyMeter 		= 'Double Easy Meter',
	SortOrder_DoubleMediumMeter 	= 'Double Normal Meter',
	SortOrder_DoubleHardMeter 		= 'Double Hard Meter',
	SortOrder_DoubleChallengeMeter 	= 'Double Insane Meter',
	SortOrder_ModeMenu 				= 'Mode Menu',
	SortOrder_AllCourses 			= 'All Courses',
	SortOrder_Nonstop 				= 'Nonstop',
	SortOrder_Oni 					= 'Oni',
	SortOrder_Endless 				= 'Endless',
	SortOrder_Length 				= 'Song Length',
	SortOrder_Roulette 				= 'Roulette',
	SortOrder_Recent 				= 'Recently Played'
};

local t = Def.ActorFrame{
	InitCommand = function(self)
		self:xy(frameX,frameY)
	end;
	OnCommand = function(self)
		top = SCREENMAN:GetTopScreen()
		wheel = top:GetMusicWheel()
		self:y(-frameHeight/2)
		self:smooth(0.4)
		self:y(frameY)
	end;
	OffCommand = function(self)
		self:smooth(0.5)
		self:y(-frameHeight/2)
	end;
};

t[#t+1] = quadMV(verts) .. {
	InitCommand=function(self)
		self:y(-10)
		self:halign(1)
		self:diffusealpha(0.8)
	end;
};

t[#t+1] = LoadFont("Common Normal") .. {
	Name="SortBar";
	InitCommand = function (self)
		self:x(5-frameWidth)
		self:halign(0)
		self:zoom(0.45)
		self:diffuse(color(colorConfig:get_data().main.headerFrameText))
		self:maxwidth((frameWidth-40)/0.45)
	end;
	SortOrderChangedMessageCommand = function(self)
		self:queuecommand("SetSortOrder")
	end;
	SetSortOrderCommand = function(self)
		local sort = GAMESTATE:GetSortOrder()
		local song = GAMESTATE:GetCurrentSong()
		if sort == nil then
			self:settext("Sort: ")
		elseif sort == "SortOrder_Group" and song ~= nil then
			self:settext(song:GetGroupName())
		else
			self:settext("Sort: "..sortTable[sort])
		end
		self:diffusealpha(1)
	end;
	SortOrderChangedMessageCommand = function(self)
		self:queuecommand("SetSortOrder")
	end;
	CurrentSongChangedMessageCommand = function(self)
		self:queuecommand("SetSortOrder")
	end;
};

t[#t+1] = LoadFont("Common Normal") .. {
	InitCommand=function(self)
		self:x(-5):halign(1):zoom(0.3):maxwidth(40/0.45)
	end;
	BeginCommand=function(self)
		self:queuecommand("Set")
	end;
	SetCommand=function(self)
		self:diffuse(color(colorConfig:get_data().main.headerFrameText))
		local top = SCREENMAN:GetTopScreen()
		if top:GetName() == "ScreenSelectMusic" or top:GetName() == "ScreenNetSelectMusic" then
			local wheel = top:GetMusicWheel()
			self:settextf("%d/%d",wheel:GetCurrentIndex()+1,wheel:GetNumItems())
		end;
	end;
	SortOrderChangedMessageCommand = function(self)
		self:queuecommand("Set")
	end;
	CurrentSongChangedMessageCommand = function(self)
		self:queuecommand("Set")
	end;
};

return t