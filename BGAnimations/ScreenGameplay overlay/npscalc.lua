-- A moving average NPS calculator

local debug = false
-- Generally, a smaller window will adapt faster, but a larger window will have a more stable value.
local maxWindow = 3 --themeConfig:get_data().NPSDisplay.MaxWindow -- this will be the maximum size of the "window" in seconds. 
local minWindow = 3 --themeConfig:get_data().NPSDisplay.MinWindow -- this will be the minimum size of the "window" in seconds. Unused for now.

--Graph related stuff
local graphLastUpdate = 0
local maxVerts = 300
local graphUpdateRate = 0.1
local initialPeak = 10 -- Initial height of the NPS graph.
local graphWidth = capWideScale(50,90)
local graphHeight = 50
local graphPos = {  -- Position of the NPS graph
	PlayerNumber_P1 = {
		X = 0,
		Y = 100
	},
	PlayerNumber_P2 = {
		X = SCREEN_WIDTH-graphWidth,
		Y = 100
	}
}

local textPos = { -- Position of the NPS text
	PlayerNumber_P1 = {
		X = 5,
		Y = 84
	},
	PlayerNumber_P2 = {
		X = SCREEN_WIDTH-graphWidth,
		Y = 84
	}
}

local enabled = {
	NPSDisplay = {
		PlayerNumber_P1 = GAMESTATE:IsPlayerEnabled(PLAYER_1) and playerConfig:get_data(pn_to_profile_slot(PLAYER_1)).NPSDisplay,
		PlayerNumber_P2 = GAMESTATE:IsPlayerEnabled(PLAYER_2) and playerConfig:get_data(pn_to_profile_slot(PLAYER_2)).NPSDisplay
	},
	NPSGraph = {
		PlayerNumber_P1 = GAMESTATE:IsPlayerEnabled(PLAYER_1) and playerConfig:get_data(pn_to_profile_slot(PLAYER_1)).NPSGraph,
		PlayerNumber_P2 = GAMESTATE:IsPlayerEnabled(PLAYER_2) and playerConfig:get_data(pn_to_profile_slot(PLAYER_2)).NPSGraph
	}
}

local npsWindow = {
	PlayerNumber_P1 = maxWindow,
	PlayerNumber_P2 = maxWindow,
}

-- This table holds the timestamp of each judgment for each player.
-- being considered for the moving average and the size of the chord.
-- (let's just call this notes for simplicity)
local noteTable = {
	PlayerNumber_P1 = {},
	PlayerNumber_P2 = {},
}

local lastJudgment = {
	PlayerNumber_P1 = 'TapNoteScore_None',
	PlayerNumber_P2 = 'TapNoteScore_None'
}

-- Total sum of notes inside the moving average window for each player.
-- The values are added/subtracted whenever we add/remove a note from the noteTable.
-- This allows us to get the total sum of notes that were hit without
-- iterating through the entire noteTable to get the sum. 
local noteSum = {
	PlayerNumber_P1 = 0,
	PlayerNumber_P2 = 0, 
}

local peakNPS = {
	PlayerNumber_P1 = 0,
	PlayerNumber_P2 = 0, 
}


---------------
-- Functions -- 
---------------

-- This function will take the player, the timestamp,
-- and the size of the chord and append it to noteTable.
-- The function will also add the size of the chord to noteSum 
-- This function is called whenever a JudgmentMessageCommand for regular tap note occurs.
-- (simply put, whenever you hit/miss a note)
local function addNote(pn,time,size)
	noteTable[pn][#noteTable[pn]+1] = {time,size}
	noteSum[pn] = noteSum[pn]+size
end


-- This function is called every frame to check if there are notes that 
-- are old enough to remove from the table.
-- Every time it is called, the function will loop and remove all old notes
-- from noteTable and subtract the corresponding chord size from noteSum.
local function removeNote(pn)
	while true do
		if #noteTable[pn] >= 1 then
			if noteTable[pn][1][1] + npsWindow[pn] < GetTimeSinceStart() then
				noteSum[pn] = noteSum[pn] - noteTable[pn][1][2]
				table.remove(noteTable[pn],1)
			else
				break
			end
		else
			break
		end
	end
end


-- The function simply Calculates the moving average NPS
-- Generally this is just nps = noteSum/window.
local function getCurNPS(pn)
	return noteSum[pn]/clamp(GAMESTATE:GetSongPosition():GetMusicSeconds(),minWindow,npsWindow[pn])
end



-- This is an update function that is being called every frame while this is loaded.
local function Update(self)
	self.InitCommand=function(self)
		self:SetUpdateFunction(Update)
	end	

	for _,pn in pairs(GAMESTATE:GetEnabledPlayers()) do
		if enabled.NPSDisplay[pn] or enabled.NPSGraph[pn] then
			-- We want to constantly check for old notes to remove and update the NPS counter text. 
			removeNote(pn)

			curNPS = getCurNPS(pn)

			-- Update peak nps. Only start updating after enough time has passed.
			if GAMESTATE:GetSongPosition():GetMusicSeconds() > npsWindow[pn] then
				peakNPS[pn] = math.max(peakNPS[pn],curNPS)
			end
			-- the actor which called this update function passes itself down as "self".
			-- we then have "self" look for the child named "Text" which you can see down below.
			-- Then the settext function is called (or settextf for formatted ones) to set the text of the child "Text"
			-- every time this function is called.
			-- We don't display the decimal values due to lack of precision from having a relatively small time window.
			if enabled.NPSDisplay[pn] then
				self:GetChild("npsDisplay"..pn):GetChild("Text"):settextf("%0.0f NPS (Peak %0.0f)",curNPS,peakNPS[pn])
			end

			-- Update the graph
			if enabled.NPSGraph[pn] and GetTimeSinceStart() - graphLastUpdate > graphUpdateRate then
				graphLastUpdate = GetTimeSinceStart()
				self:GetChild("npsGraph"..pn):playcommand("GraphUpdate")
			end
		end
	end
end

local function npsDisplay(pn)
	local t = Def.ActorFrame{
	Name = "npsDisplay"..pn;
	-- Whenever a MessageCommand is broadcasted,
	-- a table contanining parameters can also be passed along. 
	JudgmentMessageCommand=function(self,params)
		local notes = params.Notes -- this is just one of those parameters.

		local chordsize = 0

		if params.Player == pn then
			if params.TapNoteScore and
				params.TapNoteScore ~= "TapNoteScore_None" and
				params.TapNoteScore ~= 'TapNoteScore_HitMine' and
				params.TapNoteScore ~= 'TapNoteScore_AvoidMine' and
				params.TapNoteScore ~= "TapNoteScore_CheckpointMiss" then



				-- The notes parameter contains a table where the table indices
				-- correspond to the columns in game.
				-- The items in the table either contains a TapNote object (if there is a note)
				-- or be simply nil (if there are no notes)
				
				-- Since we only want to count the number of notes in a chord,
				-- we just iterate over the table and count the ones that aren't nil. 
				-- Set chordsize to 1 if notes are counted separately.
				
				if GAMESTATE:CountNotesSeparately() then
					chordsize = 1
				else
					for i=1,GAMESTATE:GetCurrentStyle():ColumnsPerPlayer() do
						if notes ~= nil and notes[i] ~= nil and
							(notes[i]:GetTapNoteType() == 'TapNoteType_Tap' or
							notes[i]:GetTapNoteType() == 'TapNoteType_HoldHead' or
							notes[i]:GetTapNoteType() == 'TapNoteType_Lift') then
							chordsize = chordsize+1
						end
					end
				end 

				-- add the note to noteTable
				addNote(pn,GetTimeSinceStart(),chordsize)
				lastJudgment[pn] = params.TapNoteScore
			end
		end
	end;
	}
	-- the text that will be updated by the update function.
	if enabled.NPSDisplay[pn] then
		t[#t+1] = LoadFont("Common Normal")..{
			Name="Text"; -- sets the name of this actor as "Text". this is a child of the actor "t".
			InitCommand=function(self)
				self:x(textPos[pn].X):y(textPos[pn].Y):halign(0):zoom(0.40):halign(0):valign(0):shadowlength(1):settext("0.0 NPS")
			end;
			BeginCommand=function(self)
				if pn == PLAYER_2 then
					self:x(SCREEN_WIDTH-5)
					self:halign(1)
				end
			end;
		}
	end

	return t
end;

local function PLife(pn)
	return STATSMAN:GetCurStageStats():GetPlayerStageStats(pn):GetCurrentLife() or 0
end;

local function npsGraph(pn)
	local t = Def.ActorFrame{
		Name = "npsGraph"..pn;
		InitCommand=function(self)
			self:xy(graphPos[pn].X,graphPos[pn].Y)
		end
	}
	local verts= {
		{{0,0,0},Color.White}
	}
	local lifeverts= {
		{{0,0,0},color("#00000000")}
	}
	local total = 1
	local peakNPS = initialPeak
	local curNPS = 0

	t[#t+1] = Def.Quad{
		InitCommand=function(self)
			self:zoomto(graphWidth,graphHeight)
			self:xy(0,graphHeight)
			self:diffuse(getMainColor("frame")):diffusealpha(0.4)
			self:horizalign(0):vertalign(2)
			self:fadetop(1)
		end
	}

	t[#t+1] = Def.Quad{
		InitCommand=function(self)
			self:zoomto(graphWidth,1)
			self:xy(0,graphHeight)
			self:diffusealpha(0.5)
			self:horizalign(0)
		end
	}

	t[#t+1] = Def.Quad{
		InitCommand=function(self)
			self:zoomto(graphWidth,1)
			self:xy(0,0)
			self:diffusealpha(0.2)
			self:horizalign(0)
		end
	}

	t[#t+1] = Def.ActorMultiVertex{
		Name= "AMV_QuadStrip",
		InitCommand=function(self)
			self:visible(true)
			self:xy(graphWidth,graphHeight)
			self:SetDrawState{Mode="DrawMode_LineStrip"}
		end,
		BeginCommand=function(self)
			self:SetDrawState{First= 1, Num= -1}
			self:SetVertices(verts)
		end,
		GraphUpdateCommand=function(self)
			self:finishtweening()
			total = total+1
			curNPS = getCurNPS(pn)
			curJudgment = lastJudgment[pn]

			if curNPS > peakNPS then -- update height if there's a new peak NPS value
				for i=1,#verts do
					verts[i][1][2] = verts[i][1][2]*(peakNPS/curNPS)
				end
				peakNPS = curNPS
			end

			verts[#verts+1] = {{total*(graphWidth/maxVerts),-curNPS/peakNPS*graphHeight,0},Color.White}
			if #verts>maxVerts+2 then -- Start removing unused verts. Otherwise RIP lag
				table.remove(verts,1)
			end
			self:SetVertices(verts)
			self:addx(-graphWidth/maxVerts)
			self:SetDrawState{First = math.max(1,#verts-maxVerts), Num=math.min(maxVerts,#verts)}
		end,
	}
	return t
end

local t = Def.ActorFrame{
	OnCommand=function(self)
		if enabled.NPSDisplay[PLAYER_1] or enabled.NPSDisplay[PLAYER_2] or
		 	enabled.NPSGraph[PLAYER_1] or enabled.NPSGraph[PLAYER_2] then
			self:SetUpdateFunction(Update)
		end
	end
}

for _,pn in pairs(GAMESTATE:GetEnabledPlayers()) do
	if enabled.NPSDisplay[pn] then
		t[#t+1] = npsDisplay(pn)
	end
	if enabled.NPSGraph[pn] then
		if not enabled.NPSDisplay[pn] then
			t[#t+1] = npsDisplay(pn)
		end
		t[#t+1] = npsGraph(pn)
	end
end

return t