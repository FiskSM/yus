return Def.ActorFrame{

	Def.Quad{
		Name="Horizontal";
		InitCommand = function(self)
			self:x(-2):zoomto(capWideScale(get43size(344),344),48):halign(0)
			self:diffuseramp();
			self:effectperiod(1.5)
			self:effectcolor1(color("#FFFFFF00"));
			self:effectcolor2(Alpha(getMainColor("highlight"),0.6));
		end;
		SetCommand=function(self)
			self:effectcolor2(Alpha(getDifficultyColor(GAMESTATE:GetHardestStepsDifficulty()),0.6));
		end;
		CurrentStepsP1ChangedMessageCommand = function(self) self:queuecommand('Set') end;
	};

};