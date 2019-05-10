local text_width = 420

local active_index = 0
local choice_actors = {}

local InputHandler = function(event)
	if not event.PlayerNumber or not event.button then return false end

	if event.type == "InputEventType_FirstPress" then
		if event.GameButton == "MenuRight" or event.GameButton == "MenuLeft" then
			-- old active choice loses focus
			choice_actors[active_index]:diffuse(1,1,1,1):linear(0.1):zoom(0.5)
			-- update active_index
			active_index = (active_index + (event.GameButton=="MenuRight" and 1 or -1))%3
			-- new active choice gains focus
			choice_actors[active_index]:diffuse(PlayerColor(PLAYER_2)):linear(0.1):zoom(1.1)

		elseif event.GameButton == "Back" or (event.GameButton == "Start" and active_index == 2) then
			SCREENMAN:GetTopScreen():SetNextScreenName("ScreenSelectGame"):StartTransitioningScreen("SM_GoToNextScreen")

		elseif event.GameButton == "Start" and (active_index == 0 or active_index == 1) then
			-- if the player wants to reset Preferences back to SM5 defaults
			if active_index == 0 then
				-- loop through all the Preferences that SL forcibly manages and reset them
				for key, value in pairs(SL.Preferences[SL.Global.GameMode]) do
					PREFSMAN:SetPreferenceToDefault(key)
				end
				-- now that those Preferences are reset to default values, write Preferences.ini to disk now
				PREFSMAN:SavePreferences()
			end

			--either way, change the theme now
			THEME:SetTheme(SL.NextTheme)
		end
	end
end

local af = Def.ActorFrame{ OnCommand=function(self) SCREENMAN:GetTopScreen():AddInputCallback(InputHandler) end }

af[#af+1] = LoadFont("Common normal")..{
	Text=ScreenString("Paragraph1"),
	InitCommand=function(self)
		self:xy(_screen.cx-text_width/2, 25):wrapwidthpixels(text_width):align(0,0):diffusealpha(0)
	end,
	OnCommand=function(self) self:linear(0.15):diffusealpha(1) end
}

af[#af+1] = LoadFont("Common normal")..{
	Text=ScreenString("Paragraph2"),
	InitCommand=function(self)
		self:xy(_screen.cx-text_width/2, 315):wrapwidthpixels(text_width):align(0,0):diffusealpha(0)
	end,
	OnCommand=function(self) self:linear(0.15):diffusealpha(1) end
}

local choices_af = Def.ActorFrame{
	InitCommand=function(self) self:diffusealpha(0) end,
	OnCommand=function(self) self:sleep(0.333):linear(0.15):diffusealpha(1) end,
}

choices_af[#choices_af+1] = LoadFont("_wendy small")..{
	Text=THEME:GetString("ThemePrefs", "Yes"),
	InitCommand=function(self)
		self:xy(_screen.cx-text_width/2, 250):zoom(1.1):diffuse( PlayerColor(PLAYER_2) )
		choice_actors[0] = self
	end
}

choices_af[#choices_af+1] = LoadFont("_wendy small")..{
	Text=THEME:GetString("ThemePrefs", "No"),
	InitCommand=function(self)
		self:xy(_screen.cx, 250):zoom(0.5)
		choice_actors[1] = self
	end
}

choices_af[#choices_af+1] = LoadFont("_wendy small")..{
	Text=THEME:GetString("ScreenTextEntry", "Cancel"),
	InitCommand=function(self)
		self:xy(_screen.cx+text_width/2, 250):zoom(0.5)
		choice_actors[2] = self
	end
}

af[#af+1] = choices_af

return af