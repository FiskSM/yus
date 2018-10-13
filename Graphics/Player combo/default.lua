local c;
local player = Var "Player";
local bareBone = isBareBone()
local ghostType = playerConfig:get_data(pn_to_profile_slot(player)).GhostScoreType -- 0 = off, 1 = DP, 2 = PS, 3 = MIGS
local avgScoreType = playerConfig:get_data(pn_to_profile_slot(player)).AvgScoreType-- 0 = off, 1 = DP, 2 = PS, 3 = MIGS
local target  = playerConfig:get_data(pn_to_profile_slot(player)).GhostTarget/100; -- target score from 0% to 100%.


local ShowComboAt = THEME:GetMetric("Combo", "ShowComboAt");
local Pulse = THEME:GetMetric("Combo", "PulseCommand");

local NumberMinZoom = THEME:GetMetric("Combo", "NumberMinZoom");
local NumberMaxZoom = THEME:GetMetric("Combo", "NumberMaxZoom");
local NumberMaxZoomAt = THEME:GetMetric("Combo", "NumberMaxZoomAt");

local t = Def.ActorFrame {

	LoadFont( "Combo", "numbers" ) .. {
		Name="Number";
		OnCommand = function(self)
			self:y(-68):shadowlength(1):skewx(-0.125):zoom(0.5)
		end
		--y,-68;shadowlength,1;skewx,-0.125;zoom,0.5;
	};


	LoadFont("Common Normal") .. {
		Name="GhostScore";
		OnCommand = function(self)
			self:xy(48,9):zoom(0.45):halign(0):valign(1):shadowlength(1)
			if avgScoreType == 0 then
				self:x(7)
			end
		end
	};

	LoadFont("Common Normal") .. {
		Name="AvgScore";
		OnCommand = function(self)
			self:xy(48,9):zoom(0.45):halign(1):valign(1):shadowlength(1)
		end
	};
	
	InitCommand = function(self)
		c = self:GetChildren();
		c.Number:visible(false);
		c.GhostScore:visible(false)
		c.AvgScore:visible(false)
		self:valign(1)
		self:draworder(350)
	end;

	JudgmentMessageCommand = function(self, param)
		local diff = param.WifeDifferential
		if diff > 0 then
			c.GhostScore:settextf('+%.2f', diff)
			c.GhostScore:diffuse(getMainColor('positive'))
		elseif diff == 0 then
			c.GhostScore:settextf('+%.2f', diff)
			c.GhostScore:diffuse(color("#FFFFFF"))
		else
			c.GhostScore:settextf('-%.2f', (math.abs(diff)))
			c.GhostScore:diffuse(getMainColor('negative'))
		end;

		local wifePercent = math.max(0, param.WifePercent)
		if avgScoreType ~= 0 and avgScoreType ~= nil then 
			c.AvgScore:settextf("%.2f%%", wifePercent)
		end
	end;

	ComboCommand = function(self, param)
		local iCombo = param.Misses or param.Combo;
		if not iCombo or iCombo < ShowComboAt then
			c.Number:visible(false);
			c.GhostScore:visible(false)
			c.AvgScore:visible(false)
			return;
		end

		param.Zoom = scale( iCombo, 0, NumberMaxZoomAt, NumberMinZoom, NumberMaxZoom );
		param.Zoom = clamp( param.Zoom, NumberMinZoom, NumberMaxZoom );
		
		c.Number:visible(true);
		if ghostType ~= 0 and ghostType ~= nil then 
			c.GhostScore:visible(true)

			c.GhostScore:finishtweening()
			c.GhostScore:diffusealpha(1)
			c.GhostScore:sleep(0.25)
			c.GhostScore:smooth(0.75)
			c.GhostScore:diffusealpha(0)
		end

		if avgScoreType ~= 0 and avgScoreType ~= nil then 
			c.AvgScore:visible(true)

			c.AvgScore:finishtweening()
			c.AvgScore:diffusealpha(1)
			c.AvgScore:sleep(0.25)
			c.AvgScore:smooth(0.75)
			c.AvgScore:diffusealpha(0)
		end

		c.Number:settext( string.format("%i", iCombo) );
		-- FullCombo Rewards
		if param.FullComboW1 then
			c.Number:diffuse(color("#00aeef"));
			c.Number:glowshift();
		elseif param.FullComboW2 then
			c.Number:diffuse(color("#fff568"));
			c.Number:glowshift();
		elseif param.FullComboW3 then
			c.Number:diffuse(color("#a4ff00"));
			c.Number:stopeffect();
		elseif param.Combo then
			c.Number:diffuse(Color("White"));
			c.Number:stopeffect();
		else
			c.Number:diffuse(color("#ff0000"));
			c.Number:stopeffect();
		end
		-- Pulse
		Pulse( c.Number, param );
	end;
};

return t;
