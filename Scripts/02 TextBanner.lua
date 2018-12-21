local mainMaxWidth = capWideScale(get43size(280),280); -- zoom w/subtitle is 0.75 (multiply by 1.25)
local artistMaxWidth = capWideScale(get43size(280),280);

local mainMaxWidthHighScore = 192; -- zoom w/subtitle is 0.75 (multiply by 1.25)
local artistMaxWidthHighScore = 280/0.8;

function TextBannerAfterSet(self,param)
	local Title = self:GetChild("Title")
	local Subtitle = self:GetChild("Subtitle")
	local Artist = self:GetChild("Artist")
	
	Title:maxwidth(mainMaxWidth/0.75)
	Title:xy(-20,-13)
	Title:zoom(0.52)

	Subtitle:visible(false)

	Artist:zoom(0.35)
	Artist:maxwidth(artistMaxWidth/0.35)
	Artist:xy(-20,-1)
end

