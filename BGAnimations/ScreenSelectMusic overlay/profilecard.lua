local t = Def.ActorFrame{
	InitCommand = function(self) 
		self:delayedFadeIn(6)
	end;
	OffCommand = function(self)
		self:sleep(0.05)
		self:smooth(0.2)
		self:diffusealpha(0) 
	end;
};

local frameX = SCREEN_CENTER_X/2
local frameY = SCREEN_CENTER_Y+100
local maxMeter = 40
local frameWidth = capWideScale(get43size(390),390)
local frameHeight = 110
local frameHeightShort = 61
local song
local course

local steps = {
	PlayerNumber_P1,
}

local trail = {
	PlayerNumber_P1,
}

local profile = {
	PlayerNumber_P1,
}

local topScore = {
	PlayerNumber_P1,
}

local hsTable = {
	PlayerNumber_P1,
}

local function generalFrame()
	local t = Def.ActorFrame{
		SetCommand = function(self)
			self:xy(frameX,frameY)
			self:visible(GAMESTATE:IsPlayerEnabled(PLAYER_1))
		end;

		UpdateInfoCommand = function(self)
			song = GAMESTATE:GetCurrentSong()
				profile[PLAYER_1] = GetPlayerOrMachineProfile(PLAYER_1)
				steps[PLAYER_1] = GAMESTATE:GetCurrentSteps(PLAYER_1)
				topScore[PLAYER_1] = getBestScore(PLAYER_1, 0, getCurRate())
			self:RunCommandsOnChildren(function(self) self:playcommand("Set") end)
		end;

		BeginCommand = function(self) self:playcommand('Set') end;
		PlayerJoinedMessageCommand = function(self) self:playcommand("UpdateInfo") end;
		PlayerUnjoinedMessageCommand = function(self) self:playcommand("UpdateInfo") end;
		CurrentSongChangedMessageCommand = function(self) self:playcommand("UpdateInfo") end;
		CurrentStepsP1ChangedMessageCommand = function(self) self:playcommand("UpdateInfo") end;
		CurrentStepsP2ChangedMessageCommand = function(self) self:playcommand("UpdateInfo") end;
		CurrentRateChangedMessageCommand = function(self) self:playcommand("UpdateInfo") end;
	}

	--Upper Bar
	t[#t+1] = quadButton(2) .. {
		InitCommand = function(self)
			self:zoomto(frameWidth,frameHeight)
			self:valign(0)
			self:diffuse(getMainColor("frame"))
			self:diffusealpha(0.8)
		end;
	}

	-- Avatar background frame

	t[#t+1] = Def.Quad{
		InitCommand = function(self)
			self:xy(25+10-(frameWidth/2),5)
			self:zoomto(53,53)
			self:diffusealpha(0.8)
		end;
		BeginCommand = function(self)
			self:diffuseramp()
			self:effectcolor2(color("1,1,1,0.6"))
			self:effectcolor1(color("1,1,1,0"))
			self:effecttiming(2,1,0,0)
		end;
	}

	t[#t+1] = quadButton(3) .. {
		InitCommand = function(self)
			self:xy(25+10-(frameWidth/2),5)
			self:zoomto(50,50)
			self:visible(false)
		end;
		TopPressedCommand = function(self, params)
			if params.input == "DeviceButton_left mouse button" then
				SCREENMAN:AddNewScreenToTop("ScreenPlayerProfile")
			end
		end;
	}

	-- Avatar
	t[#t+1] = Def.Sprite {
		InitCommand = function (self) self:xy(25+10-(frameWidth/2),5):playcommand("ModifyAvatar") end;
		PlayerJoinedMessageCommand = function(self) self:queuecommand('ModifyAvatar') end;
		PlayerUnjoinedMessageCommand = function(self) self:queuecommand('ModifyAvatar') end;
		AvatarChangedMessageCommand = function(self) self:queuecommand('ModifyAvatar') end;
		ModifyAvatarCommand = function(self)
			self:visible(true)
			self:LoadBackground(PROFILEMAN:GetAvatarPath(PLAYER_1));
			self:zoomto(50,50)
		end;
	}

	-- Player name
	t[#t+1] = LoadFont("Common Bold")..{
		InitCommand  = function(self)
			self:xy(69-frameWidth/2,9)
			self:zoom(0.6)
			self:halign(0)
			self:diffuse(color(colorConfig:get_data().selectMusic.ProfileCardText))
		end;
		SetCommand = function(self)
			local text = ""
			if profile[PLAYER_1] ~= nil then
				text = getCurrentUsername(PLAYER_1)
				if text == "" then
					text = PLAYER_1 == PLAYER_1 and "Player 1" or "Player 2"
				end
			end
			self:settext(text)
		end;
		BeginCommand = function(self) self:queuecommand('Set') end;
		PlayerJoinedMessageCommand = function(self) self:queuecommand('Set') end;
		LoginMessageCommand = function(self) self:queuecommand('Set') end;
		LogOutMessageCommand = function(self) self:queuecommand('Set') end;
	}

	t[#t+1] = LoadFont("Common Normal")..{
		InitCommand  = function(self)
			self:xy(69-frameWidth/2,22)
			self:zoom(0.4)
			self:halign(0)
			self:diffuse(color(colorConfig:get_data().selectMusic.ProfileCardText))
		end;
		SetCommand = function(self)
			local rating = 0
			local rank = 0

			if DLMAN:IsLoggedIn() then
				rank = DLMAN:GetSkillsetRank("Overall")
				rating = DLMAN:GetSkillsetRating("Overall")

				self:settextf("Skill Rating: %0.2f (#%d)", rating, rank)

			else		
				if profile[PLAYER_1] ~= nil then
					rating = profile[PLAYER_1]:GetPlayerRating()
					self:settextf("Skill Rating: %0.2f",rating)
				end

			end

			self:AddAttribute(#"Skill Rating:", {Length = -1, Zoom =0.3 ,Diffuse = getMSDColor(rating)})
		end;
		BeginCommand = function(self) self:queuecommand('Set') end;
		PlayerJoinedMessageCommand = function(self) self:queuecommand('Set') end;
		LoginMessageCommand = function(self) self:queuecommand('Set') end;
		LogOutMessageCommand = function(self) self:queuecommand('Set') end;
		OnlineUpdateMessageCommand = function(self) self:queuecommand('Set') end;
	}

	--Score Date
	t[#t+1] = LoadFont("Common Normal")..{
		InitCommand = function(self)
			self:xy(frameWidth/2-5,3)
			self:zoom(0.35)
		    self:halign(1):valign(0)
		    self:diffuse(color(colorConfig:get_data().selectMusic.ProfileCardText)):diffusealpha(0.5)
		end;
		SetCommand = function(self)
			if getScoreDate(topScore[PLAYER_1]) == "" then
				self:settext("Date Achieved: 0000-00-00 00:00:00")
			else
				self:settext("Date Achieved: "..getScoreDate(topScore[PLAYER_1]))
			end
		end;
		BeginCommand = function(self) self:queuecommand('Set') end;
	};

	-- Steps info
	t[#t+1] = LoadFont("Common Normal")..{
		InitCommand = function(self)
			self:xy(5-frameWidth/2,40)
			self:zoom(0.3)
			self:halign(0)
			self:diffuse(color(colorConfig:get_data().selectMusic.ProfileCardText))
		end;
		SetCommand = function(self)
			local diff,stype
			local notes,holds,rolls,mines,lifts = 0
			local difftext = ""

			if GAMESTATE:IsCourseMode() then
				if course:AllSongsAreFixed() then
					if trail[PLAYER_1] ~= nil then
						notes = trail[PLAYER_1]:GetRadarValues(PLAYER_1):GetValue("RadarCategory_Notes")
						holds = trail[PLAYER_1]:GetRadarValues(PLAYER_1):GetValue("RadarCategory_Holds")
						rolls = trail[PLAYER_1]:GetRadarValues(PLAYER_1):GetValue("RadarCategory_Rolls")
						mines = trail[PLAYER_1]:GetRadarValues(PLAYER_1):GetValue("RadarCategory_Mines")
						lifts = trail[PLAYER_1]:GetRadarValues(PLAYER_1):GetValue("RadarCategory_Lifts")
						diff = trail[PLAYER_1]:GetDifficulty()
					end

					stype = ToEnumShortString(trail[PLAYER_1]:GetStepsType()):gsub("%_"," ")
					self:settextf("%s %s // Notes:%s // Holds:%s // Rolls:%s // Mines:%s // Lifts:%s",stype,diff,notes,holds,rolls,mines,lifts);
				else
					self:settextf("Disabled for courses containing random songs.")
				end
			else
				if steps[PLAYER_1] ~= nil then
					notes = steps[PLAYER_1]:GetRadarValues(PLAYER_1):GetValue("RadarCategory_Notes")
					holds = steps[PLAYER_1]:GetRadarValues(PLAYER_1):GetValue("RadarCategory_Holds")
					rolls = steps[PLAYER_1]:GetRadarValues(PLAYER_1):GetValue("RadarCategory_Rolls")
					mines = steps[PLAYER_1]:GetRadarValues(PLAYER_1):GetValue("RadarCategory_Mines")
					lifts = steps[PLAYER_1]:GetRadarValues(PLAYER_1):GetValue("RadarCategory_Lifts")
					diff = steps[PLAYER_1]:GetDifficulty()

				

					stype = ToEnumShortString(steps[PLAYER_1]:GetStepsType()):gsub("%_"," ")
					self:settextf("Notes:%s // Holds:%s // Rolls:%s // Mines:%s // Lifts:%s",notes,holds,rolls,mines,lifts);
				else
					self:settext("Disabled");
				end
			end
		end;
		BeginCommand = function(self) self:queuecommand('Set') end;
	}

	t[#t+1] = LoadFont("Common Normal")..{
		Name="StepsAndMeter";
		InitCommand = function(self)
			self:xy(frameWidth/2-5,33)
			self:zoom(0.55)
			self:halign(1)
			self:diffuse(color(colorConfig:get_data().selectMusic.ProfileCardText))
		end;
		SetCommand = function(self)
			if steps[PLAYER_1] ~= nil then

				local meter = steps[PLAYER_1]:GetMSD(getCurRateValue(),1)
				if meter == 0 then
					meter = steps[PLAYER_1]:GetMeter()
				end
				meter = math.max(1,meter)
				self:settextf("Difficulty level: %5.2f", meter)
				self:diffuse(getDifficultyColor(GetCustomDifficulty(steps[PLAYER_1]:GetStepsType(),steps[PLAYER_1]:GetDifficulty())))
			end
		end;
	};

	t[#t+1] = Def.Quad{
		InitCommand = function(self)
			self:xy(5-(frameWidth/2),50)
			self:zoomto(frameWidth-10,10)
			self:halign(0)
			self:diffusealpha(1)
			self:diffuse(getMainColor("background"))
		end
	}

	-- Stepstype and Difficulty meter
	t[#t+1] = LoadFont("Common Normal")..{
		InitCommand = function(self)
			self:xy(frameWidth-10-frameWidth/2-2,50)
			self:zoom(0.3)
			self:settext(maxMeter)
		end;
		SetCommand = function(self)
			if steps[PLAYER_1] ~= nil then
				local diff = getDifficulty(steps[PLAYER_1]:GetDifficulty())
				local stype = ToEnumShortString(steps[PLAYER_1]:GetStepsType()):gsub("%_"," ")
				self:diffuse(getDifficultyColor(GetCustomDifficulty(steps[PLAYER_1]:GetStepsType(),steps[PLAYER_1]:GetDifficulty())))
			end
		end;
	};

	t[#t+1] = Def.Quad{
		InitCommand = function(self)
			self:xy(5-(frameWidth/2),50)
			self:halign(0)
			self:zoomy(10)
			self:diffuse(getMainColor("highlight"))
		end;
		SetCommand = function(self)
			self:stoptweening()
			self:decelerate(0.5)
			local meter = 0
			local enabled = GAMESTATE:IsPlayerEnabled(PLAYER_1)
			if enabled and steps[PLAYER_1] ~= nil then
				meter = steps[PLAYER_1]:GetMSD(getCurRateValue(),1)
				if meter == 0 then
					meter = steps[PLAYER_1]:GetMeter()
				end
				self:zoomx((math.min(1,meter/maxMeter))*(frameWidth-10))
				self:diffuse(getDifficultyColor(GetCustomDifficulty(steps[PLAYER_1]:GetStepsType(),steps[PLAYER_1]:GetDifficulty())))
			else
				self:zoomx(0)
			end
		end;
		BeginCommand = function(self) self:queuecommand('Set') end;
	}

	t[#t+1] = LoadFont("Common Normal")..{
		InitCommand = function(self)
			self:y(50):zoom(0.3)
		    self:diffuse(color(colorConfig:get_data().selectMusic.ProfileCardText))
		end;
		SetCommand = function(self) 
			self:stoptweening()
			self:decelerate(0.5):visible(true)
			local meter = 0
			local enabled = GAMESTATE:IsPlayerEnabled(PLAYER_1)
			if enabled and steps[PLAYER_1] ~= nil then
				meter = steps[PLAYER_1]:GetMSD(getCurRateValue(),1)
				if meter == 0 then
					meter = steps[PLAYER_1]:GetMeter()
				end
				meter = math.max(1,meter)
				self:settext(math.floor(meter))
				self:x((math.min(1,meter/maxMeter))*(frameWidth-10)-frameWidth/2-3)
			else
				self:visible(false)
			end
		end;
		BeginCommand = function(self) self:queuecommand('Set') end;
	}

	--Grades
	t[#t+1] = LoadFont("Common BLarge")..{
		InitCommand = function(self)
			self:xy(60-frameWidth/2,frameHeight-35)
			self:zoom(0.6)
		    self:maxwidth(110/0.6)
		end;
		SetCommand = function(self)
			local grade = 'Grade_None'
			if topScore[PLAYER_1] ~= nil then
				grade = topScore[PLAYER_1]:GetWifeGrade()
			end
			self:settext(THEME:GetString("Grade",ToEnumShortString(grade)))
			self:diffuse(getGradeColor(grade))
		end;
		BeginCommand = function(self) self:queuecommand('Set') end;
	}

	--ClearType
	t[#t+1] = LoadFont("Common Bold")..{
		InitCommand = function(self)
			self:xy(60-frameWidth/2,frameHeight-15)
			self:zoom(0.4)
			self:maxwidth(110/0.4)
		end;
		SetCommand = function(self)
			self:stoptweening()

			local scoreList
			local clearType
			if profile[PLAYER_1] ~= nil and song ~= nil and steps[PLAYER_1] ~= nil then
				scoreList = getScoreTable(PLAYER_1, getCurRate())
				clearType = getHighestClearType(PLAYER_1,steps[PLAYER_1],scoreList,0)
				self:settext(getClearTypeText(clearType))
				self:diffuse(getClearTypeColor(clearType))
			end
		end;
		BeginCommand = function(self) self:queuecommand('Set') end;
	}

	-- Percentage Score
	t[#t+1] = LoadFont("Common BLarge")..{
		InitCommand= function(self)
			self:xy(190-frameWidth/2,frameHeight-36)
			self:zoom(0.45):halign(1):maxwidth(75/0.45)
		    self:diffuse(color(colorConfig:get_data().selectMusic.ProfileCardText))
		end;
		SetCommand = function(self)
			local scorevalue = 0
			if topScore[PLAYER_1] ~= nil then
				scorevalue = getScore(topScore[PLAYER_1], steps[PLAYER_1], true)
			end
			self:settextf("%.2f%%",math.floor((scorevalue)*10000)/100)
		end;
		BeginCommand = function(self) self:queuecommand('Set') end;
	}


	--Player DP/Exscore / Max DP/Exscore
	t[#t+1] = LoadFont("Common Normal")..{
		Name = "score"; 
		InitCommand= function(self)
			self:xy(177-frameWidth/2,frameHeight-18)
			self:zoom(0.5):halign(1):maxwidth(26/0.5)
		    self:diffuse(color(colorConfig:get_data().selectMusic.ProfileCardText))
		end;
		SetCommand = function(self) 
			self:settext(getMaxScore(PLAYER_1,0))
		end;
		BeginCommand = function(self) self:queuecommand('Set') end;
	}

	t[#t+1] = LoadFont("Common Normal")..{
		InitCommand= function(self)
			self:xy(177-frameWidth/2,frameHeight-18)
			self:zoom(0.5):halign(1):maxwidth(50/0.5)
		    self:diffuse(color(colorConfig:get_data().selectMusic.ProfileCardText))
		end;
		SetCommand = function(self) 
			self:x(self:GetParent():GetChild("score"):GetX()-(math.min(self:GetParent():GetChild("score"):GetWidth(),27/0.5)*0.5))

			local scoreValue = 0
			if topScore[PLAYER_1] ~= nil then
				scoreValue = getScore(topScore[PLAYER_1], steps[PLAYER_1], false)
			end
			self:settextf("%.0f/",scoreValue)
		end;
		BeginCommand = function(self) self:queuecommand('Set') end;
	};

	--ScoreType superscript(?)
	t[#t+1] = LoadFont("Common Normal")..{
		InitCommand = function(self)
			self:xy(178-frameWidth/2,frameHeight-19)
			self:zoom(0.3)
		    self:halign(0)
		    self:diffuse(color(colorConfig:get_data().selectMusic.ProfileCardText))
		end;
		BeginCommand = function(self)
			self:settext(getScoreTypeText(1))
		end;
	}

	--MaxCombo
	t[#t+1] = LoadFont("Common Normal")..{
		InitCommand = function(self)
			self:xy(210-frameWidth/2,frameHeight-40)
			self:zoom(0.4)
		    self:halign(0)
		    self:diffuse(color(colorConfig:get_data().selectMusic.ProfileCardText))
		end;
		SetCommand = function(self)
			local score = getBestMaxCombo(PLAYER_1,0, getCurRate())
			local maxCombo = 0
			maxCombo = getScoreMaxCombo(score)
			self:settextf("Max Combo: %d",maxCombo)
		end;
		BeginCommand = function(self) self:queuecommand('Set') end;
	};


	--MissCount
	t[#t+1] = LoadFont("Common Normal")..{
		InitCommand = function(self)
			self:xy(210-frameWidth/2,frameHeight-28)
			self:zoom(0.4)
		    self:halign(0)
		    self:diffuse(color(colorConfig:get_data().selectMusic.ProfileCardText))
		end;
		SetCommand = function(self)
			local score = getBestMissCount(PLAYER_1, 0, getCurRate())
			if score ~= nil then
				self:settext("Miss Count: "..getScoreMissCount(score))
			else
				self:settext("Miss Count: -")
			end
		end;
		BeginCommand = function(self) self:queuecommand('Set') end;
	};


	-- EO rank placeholder
	t[#t+1] = LoadFont("Common Normal")..{
		InitCommand = function(self)
			self:xy(210-frameWidth/2,frameHeight-16)
			self:zoom(0.4)
		    self:halign(0)
		    self:diffuse(color(colorConfig:get_data().selectMusic.ProfileCardText))
		end;
		SetCommand = function(self)
			self:settextf("Ranking: %d/%d",0,0)
		end;
		BeginCommand = function(self) self:queuecommand('Set') end;
	};

	return t
end

t[#t+1] = generalFrame()


return t