local defaultConfig = {

	main = {
		frame = "#292c31",
		highlight = "#00AEEF",
		background = "#1b2123",
		warning = "#EEBB00";
		enabled = "#4CBB17",
		disabled = "#666666",
		negative = "#FF9999",
		positive = "#66ccff",
		headerText = "#F7F7F7",
		headerFrameText = "#F7F7F7",
	},

	clearType = {
		ClearType_MFC 	= "#66ccff",
		ClearType_WF 	= "#dddddd",
		ClearType_SDP 	= "#cc8800",
		ClearType_PFC 	= "#eeaa00",
		ClearType_BF 	= "#999999",
		ClearType_SDG	= "#448844",
		ClearType_FC 	= "#66cc66",
		ClearType_MF 	= "#cc6666",
		ClearType_SDCB	= "#666666",
		ClearType_EXHC 	= "#ff9933",
		ClearType_HClear 	= "#ff6666",
		ClearType_Clear 	= "#33aaff",
		ClearType_EClear 	= "#66ff66",
		ClearType_AClear 	= "#9966ff",
		ClearType_Failed = "#e61e25",
		ClearType_Invalid = "#e61e25",
		ClearType_Noplay = "#666666",
		ClearType_None = "#666666",
	},

	difficulty = {
		Difficulty_Beginner	= "#66ccff",		-- light blue
		Difficulty_Easy		= "#099948",		-- green
		Difficulty_Medium	= "#ddaa00",		-- yellow
		Difficulty_Hard		= "#ff6666",		-- red
		Difficulty_Challenge= "#c97bff",	-- light blue
		Difficulty_Edit 	= "#666666",	-- gray
		Difficulty_Couple	= "#ed0972",			-- hot pink
		Difficulty_Routine	= "#ff9a00",			-- orange
		Beginner	= "#66ccff",		
		Easy		= "#099948",		-- green
		Medium		= "#ddaa00",		-- yellow
		Hard		= "#ff6666",		-- red
		Challenge 		= "#c97bff",	-- Purple
		Edit 		= "#666666",	-- gray
		Couple		= "#ed0972",			-- hot pink
		Routine		= "#ff9a00",			-- orange
		Crazy 		= "#ff6666",		-- red
		Nightmare	= "#c97bff",	-- Purple
		HalfDouble 	= "#666666",	-- gray
		HalfDouble 	= "#666666",	-- gray
		Freestyle 	= "#666666",	-- gray
	},

	grade = {
		Grade_Tier01	= "#66ccff", -- AAAA
		Grade_Tier02	= "#eebb00", -- AAA
		Grade_Tier03	= "#66cc66", -- AA
		Grade_Tier04	= "#da5757", -- A
		Grade_Tier05	= "#5b78bb", -- B
		Grade_Tier06	= "#c97bff", -- C
		Grade_Tier07	= "#8c6239", -- D
		Grade_Tier08	= "#000000", -- ITG PLS
		Grade_Tier09	= "#000000", -- ITG PLS
		Grade_Tier10	= "#000000", -- ITG PLS
		Grade_Tier11	= "#000000", -- ITG PLS
		Grade_Tier12	= "#000000", -- ITG PLS
		Grade_Tier13	= "#000000", -- ITG PLS
		Grade_Tier14	= "#000000", -- ITG PLS
		Grade_Tier15	= "#000000", -- ITG PLS
		Grade_Tier16	= "#000000", -- ITG PLS
		Grade_Tier17	= "#000000", -- ITG PLS
		Grade_Failed	= "#cdcdcd", -- F
		Grade_None		= "#666666", -- no play
	},

	judgment = { -- Colors of each Judgment types
		TapNoteScore_W1 = "#99ccff",
		TapNoteScore_W2	= "#f2cb30",
		TapNoteScore_W3	 = "#14cc8f",
		TapNoteScore_W4	= "#1ab2ff",
		TapNoteScore_W5	= "#ff1ab3",
		TapNoteScore_Miss = "#cc2929",			
		HoldNoteScore_Held = "#f2cb30",	
		HoldNoteScore_LetGo = "#cc2929"
	},

	downloadStatus = {
		downloaded = "#66ccff",
		completed = "#66cc66",
		downloading = "#eebb00",
		available = "#da5757",
		unavailable = "#666666",
	},

	songLength = {
		short = "#666666", -- grey
		normal = "#F7F7F7", -- normal
		long = "#ff9a00", --orange
		marathon = "#da5757", -- red
		ultramarathon = "#c97bff" -- purple
	},

	gameplay = {
		ScreenFilter = "#000000",
		LaneCover = "#111111",
		PacemakerBest = "#00FF00",
		PacemakerTarget = "#FF9999",
		PacemakerCurrent = "#0099FF",
	},

	evaluation = {
		BackgroundText = "#F7F7F7",
		ScoreCardText = "#F7F7F7",
		ScoreCardDivider = "#F7F7F7",
		ScoreCardCategoryText = "#F7F7F7",
		ScoreBoardText = "#F7F7F7",
	},

	selectMusic = {
		MusicWheelTitleText = "#F7F7F7",
		MusicWheelSubtitleText = "#F7F7F7",
		MusicWheelArtistText = "#F7F7F7",
		MusicWheelSectionCountText = "#F7F7F7",
		MusicWheelDivider = "#F7F7F7",
		MusicWheelExtraColor = "#FFCCCC",
		ProfileCardText = "#F7F7F7",
		TabContentText = "#F7F7F7",
		BannerText = "#F7F7F7",
		StepsDisplayListText = "#F7F7F7"
	}

}

colorConfig =  create_setting("colorConfig", "colorConfig.lua", defaultConfig,-1)
colorConfig:load()

--keys to current table. Assumes a depth of 2.
local curColor = {"",""}

function getTableKeys()
	return curColor
end

function setTableKeys(table)
	curColor = table 
end

function getMainColor(type)
	return color(colorConfig:get_data().main[type])
end

function getGradeColor (grade)
	return color(colorConfig:get_data().grade[grade]) or color(colorConfig:get_data().grade['Grade_None']);
end

function getDifficultyColor(diff)
	return color(colorConfig:get_data().difficulty[diff]) or color("#F7F7F7");
end

function getPaceMakerColor(type)
	return color(colorConfig:get_data().gameplay["Pacemaker"..type]) or color("#F7F7F7");
end

function getSongLengthColor(s)


	if s < 60 then
		return lerp_color(s/60, color(colorConfig:get_data().songLength["short"]),
			color(colorConfig:get_data().songLength["normal"]))

	elseif s < PREFSMAN:GetPreference("LongVerSongSeconds") then
		return lerp_color((s-60)/(PREFSMAN:GetPreference("LongVerSongSeconds")-60),
			color(colorConfig:get_data().songLength["normal"]),
			color(colorConfig:get_data().songLength["long"]))

	elseif s < PREFSMAN:GetPreference("MarathonVerSongSeconds") then
		return lerp_color((s-PREFSMAN:GetPreference("LongVerSongSeconds"))/
			(PREFSMAN:GetPreference("MarathonVerSongSeconds")-PREFSMAN:GetPreference("LongVerSongSeconds")),
			color(colorConfig:get_data().songLength["long"]), 
			color(colorConfig:get_data().songLength["marathon"]))

	elseif s < 1000 then
		return lerp_color((s-PREFSMAN:GetPreference("MarathonVerSongSeconds"))/
			(1000-PREFSMAN:GetPreference("MarathonVerSongSeconds")), 
			color(colorConfig:get_data().songLength["marathon"]), 
			color(colorConfig:get_data().songLength["ultramarathon"]))

	else
		return color(colorConfig:get_data().songLength["ultramarathon"])

	end
end

function getClearTypeColor(clearType)
	return color(colorConfig:get_data().clearType[clearType])
end

function offsetToJudgeColor(offset)
	local offset = math.abs(offset)
	local scale = PREFSMAN:GetPreference("TimingWindowScale")
	if offset <= scale*PREFSMAN:GetPreference("TimingWindowSecondsW1") then
		return color(colorConfig:get_data().judgment["TapNoteScore_W1"])
	elseif offset <= scale*PREFSMAN:GetPreference("TimingWindowSecondsW2") then
		return color(colorConfig:get_data().judgment["TapNoteScore_W2"])
	elseif offset <= scale*PREFSMAN:GetPreference("TimingWindowSecondsW3") then
		return color(colorConfig:get_data().judgment["TapNoteScore_W3"])
	elseif offset <= scale*PREFSMAN:GetPreference("TimingWindowSecondsW4") then
		return color(colorConfig:get_data().judgment["TapNoteScore_W4"])
	elseif offset <= scale*PREFSMAN:GetPreference("TimingWindowSecondsW5") then
		return color(colorConfig:get_data().judgment["TapNoteScore_W5"])
	else
		return color(colorConfig:get_data().judgment["TapNoteScore_Miss"])
	end
end

function getBorderColor()
	return HSV(Hour()*360/12, 0.7, 1)
end

function TapNoteScoreToColor(tns) return color(colorConfig:get_data().judgment[tns]) or color("#F7F7F7"); end;

-- a tad-bit desaturated with a wider color range vs til death
function getMSDColor(MSD)
	if MSD then
		return HSV(math.min(220,math.max(280 - MSD*11, -40)), 0.5, 1)
	end
	return HSV(0, 0.9, 0.9)
end
