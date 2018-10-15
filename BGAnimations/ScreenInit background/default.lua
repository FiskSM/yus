local t = Def.ActorFrame {}

t[#t + 1] =
	Def.Quad {
	InitCommand = function(self)
		self:xy(0, 0):halign(0):valign(0):zoomto(SCREEN_WIDTH, SCREEN_HEIGHT):diffuse(color("#111111")):diffusealpha(0):linear(1)
		self:diffusealpha(1):sleep(1.75):linear(2):diffusealpha(0)
	end
}

t[#t + 1] =
	Def.ActorFrame {
	InitCommand = function(self)
		self:Center()
	end,
	LoadActor("woop") ..
		{
			OnCommand = function(self)
				self:zoomto(SCREEN_WIDTH, 150):diffusealpha(0):linear(1):diffusealpha(1):sleep(1.75):linear(2):diffusealpha(0)
			end
		},
	LoadActor("logo") ..
	{
		OnCommand = function(self)
			self:zoom(0.8):diffusealpha(0):linear(1):diffusealpha(1):sleep(1.75):linear(2):diffusealpha(0)
		end
	},

}

return t
