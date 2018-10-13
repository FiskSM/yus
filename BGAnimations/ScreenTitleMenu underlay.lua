local magnitude = 0.03
local maxDistX = SCREEN_WIDTH*magnitude
local maxDistY = SCREEN_HEIGHT*magnitude

local function getPosX()
	local offset = magnitude*(INPUTFILTER:GetMouseX()-SCREEN_CENTER_X)
	local neg
	if offset < 0 then
		neg = true
		offset = math.abs(offset)
		if offset > 1 then
			offset = math.min(2*math.sqrt(math.abs(offset)),maxDistX)
		end;
	else
		neg = false
		offset = math.abs(offset)
		if offset > 1 then
			offset = math.min(2*math.sqrt(math.abs(offset)),maxDistX)
		end;
	end;
	if neg then
		return SCREEN_CENTER_X+offset
	else 
		return SCREEN_CENTER_X-offset
	end;
end

local function getPosY()
	local offset = magnitude*(INPUTFILTER:GetMouseY()-SCREEN_CENTER_Y)
	local neg
	if offset < 0 then
		neg = true
		offset = math.abs(offset)
		if offset > 1 then
			offset = math.min(2*math.sqrt(offset),maxDistY)
		end;
	else
		neg = false
		offset = math.abs(offset)
		if offset > 1 then
			offset = math.min(2*math.sqrt(offset),maxDistY)
		end;
	end;
	if neg then
		return SCREEN_CENTER_Y+offset
	else 
		return SCREEN_CENTER_Y-offset
	end;
end

local t = Def.ActorFrame{}


t[#t+1] = Def.ActorFrame{
	Name="MouseXY";

	Def.Sprite {
		InitCommand = function(self)
			self:LoadBackground(THEME:GetPathG("","REIMUBG"))
			self:SetTextureFiltering(false)
			self:scaletocover(-10,-10,SCREEN_WIDTH+10,SCREEN_BOTTOM+10);
		end
	},

	Def.Sprite {
		OnCommand=function(self)
			self:smooth(0.5):diffusealpha(0):queuecommand("ModifySongBackground")
		end;
		CurrentSongChangedMessageCommand=function(self)
			self:stoptweening():smooth(0.5):diffusealpha(0):queuecommand("ModifySongBackground")
		end;
		ModifySongBackgroundCommand=function(self)
			self:finishtweening()
					self:visible(true);

					self:scaletocover(0-maxDistY/8,0-maxDistY/8,SCREEN_WIDTH+maxDistX/8,SCREEN_BOTTOM+maxDistY/8);
					self:smooth(0.5)
		end;
		OffCommand=function(self)
			self:smooth(0.5):diffusealpha(0)
		end	
	};
};


local function Update(self)
	t.InitCommand=function(self)
		self:SetUpdateFunction(Update)
	end;
    self:GetChild("MouseXY"):xy(getPosX()-SCREEN_CENTER_X,getPosY()-SCREEN_CENTER_Y)
end; 
t.InitCommand=function(self)
	self:SetUpdateFunction(Update)
end;


t[#t+1] = LoadActor(THEME:GetPathG("", "OTHERBG")) .. {
	InitCommand = function(self)
		self:halign(0):valign(0)
		self:zoom(0.45)
	end;
}


return t






--[[
t[#t+1] = LoadActor(THEME:GetPathG("", "REIMUBG")) .. {
	InitCommand = function(self)
		self:xy(0,0)
		self:zoomto(SCREEN_WIDTH,600)
	end;
}--]]

