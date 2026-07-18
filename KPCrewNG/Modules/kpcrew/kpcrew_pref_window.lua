-- =========================================================================================
-- Settings window rendering #prefwindow
-- =========================================================================================

-- -----------------------------------------------------------------------------------------
-- add new preference based on DFLT
function prefs_add(newicao)

	local newprefs = SCRIPT_DIRECTORY.."../Modules/kpcrew_prefs/"..newicao..".preferences"
	local dfltprefs = SCRIPT_DIRECTORY.."../Modules/kpcrew_prefs/DFLT.preferences"
	-- ignore when already file exists
	if newicao == "DFLT" or ng_file_exists(newprefs) then 
		ng_preferences_error = "Exists!"
		return 
	end 

	-- read source DFLT
	local filein = io.open(dfltprefs, "r")
	local prefsin = ""
	for line in filein:lines() do prefsin = prefsin .. line .. "\n" end
	filein:close()

	-- write to new
	local fileout = io.open(newprefs, "w+")
	fileout:write(prefsin)
	fileout:close()
	ng_editor_system_error = ""
end
-- -----------------------------------------------------------------------------------------

-- -----------------------------------------------------------------------------------------
-- drawing function for Preference window
-- +----------------------------------------------------------+
-- | [LOAD] [SAVE]                                            |
-- |----------------------------------------------------------|
-- | + APPLICATION SETTINGS                                   |
-- | ...tree                                                  |
-- +----------------------------------------------------------+
function ng_draw_pref_window()

	-- do intial setup size/position
	if ng_imgui_initial_pref_set == false then
		if FLYWITHLUA then
			-- imgui.SetNextWindowPos(ng_scrn_width-ng_imgui_initial_pref_xpos,ng_imgui_initial_pref_ypos)
			ng_imgui_initial_pref_set = true
		else
			imgui.SetNextWindowSize({ng_imgui_initial_pref_width,ng_imgui_initial_pref_height})
			imgui.SetNextWindowPos({ng_scrn_width-ng_imgui_initial_pref_xpos, ng_imgui_initial_pref_ypos})
			ng_imgui_initial_pref_set = true
		end
	end
	
	if FLYWITHLUA == false then imgui.Begin("APPLICATION SETTINGS") end
		
		-- load and save button to save after changes or load again
		ng_imgui_in_button("loadapp", "LOAD SETTINGS", 190, 20, 
			function () ng_getAppPrefs():load() end)

		imgui.SameLine()
		ng_imgui_in_button("savebapp","SAVE SETTINGS", 190, 20,
			function () ng_getAppPrefs():save() end)
		
		imgui.Separator()

		-- render preferences tree
		imgui.SetNextItemOpen(true)
		ng_getAppPrefs():render("tree")	
			
	if FLYWITHLUA == false then imgui.End() end
	
end
