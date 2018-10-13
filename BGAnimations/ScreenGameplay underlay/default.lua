local playeroptions = GAMESTATE:GetPlayerState(PLAYER_1):GetPlayerOptions(modslevel)
playeroptions:Mini( 2 - playerConfig:get_data(pn_to_profile_slot(PLAYER_1)).ReceptorSize/50 )

local t = Def.ActorFrame{}

t[#t+1] = Def.Quad{
	InitCommand=function(self)
		self:xy(0,0):halign(0):valign(0):zoomto(SCREEN_WIDTH,30):diffuse(color("#00000099")):fadebottom(0.8)
	end;
};

t[#t+1] = LoadActor("ScreenFilter")

return t