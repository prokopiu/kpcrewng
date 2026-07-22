-- -----------------------------------------------------------------------------------------
-- SOP / Systems Editor rendering
-- -----------------------------------------------------------------------------------------
require "kpcrew.kpcrew_edit_sop"
require "kpcrew.kpcrew_edit_systems"

-- -----------------------------------------------------------------------------------------
-- draw the Settings tab
function render_edit_tab_pref()

	imgui.BeginChild("#tabeditpref")
	
	-- right tab with aircraft preferences
	-- if FLYWITHLUA then imgui.BeginChild("prefscolh2",0,50) else imgui.BeginChild("prefscolh2",{0,50}) end
		
		ng_imgui_out_text(color_yellow," ====================== AIRCRAFT SETTINGS ======================")
	
		-- ICAO for preferences
		ng_imgui_in_tfield("Settings for", 50, color_white, 10, ng_settings_icao, 
			function (textout) 
				ng_settings_icao = string.upper(textout) 
				ng_getAcfPrefs():setFilePath(SCRIPT_DIRECTORY .."../Modules/kpcrew_prefs/"..ng_settings_icao..".preferences")
			end)

		-- load and save button to save after changes or load again
		imgui.SameLine()
		ng_imgui_in_button("loadprefs", "LOAD", 70, 20, 
			function () ng_getAcfPrefs():load() end)

		imgui.SameLine()
		ng_imgui_in_button("saveprefs","SAVE", 70, 20,
			function () ng_getAcfPrefs():save() end)

		imgui.SameLine()
		ng_imgui_in_button("addprefs","ADD", 70, 20,
			function () prefs_add(ng_settings_icao) end)

		imgui.SameLine()
		ng_imgui_out_text(color_red,ng_preferences_error)
				
		imgui.Separator()

		-- render aircraft preferences tree
		imgui.BeginChild("#prefrender")
			-- imgui.SetNextItemOpen(true)
			ng_getAcfPrefs():render("tree")
		imgui.EndChild()
		
	imgui.EndChild() -- #tabeditpref	

end

-- -----------------------------------------------------------------------------------------

-- -----------------------------------------------------------------------------------------
-- drawing Editor OPS tab
-- -----------------------------------------------------------------------------------------
-- -----------------------------------------------------------------------------------------
--- Set up brief window tabs with buttons
-- @param int index id of the tab (group) to be added
-- @param int size of tab in pixel
-- @param string name of tab/button  
function ng_imgui_draw_add_edit_tab(index, tabsize, text)
	
	local tabwidth = tabsize
	local tabheight = 18
	
	imgui.PushStyleVar(12, 3)
	
	if index == 1 then imgui.SameLine(index * (tabwidth + 5))
	elseif index > 1 then imgui.SameLine(index * (tabwidth + 4 - index)) end
 
	if ng_imgui_current_edit_tab == index then
		imgui.PushStyleColor(21, color_mcp_active)			
	else
		imgui.PushStyleColor(21, color_mcp_button)			
 	end 
	
	imgui.PushStyleColor(22, color_mcp_hover)
	imgui.PushStyleColor(23, color_orange)
	
	ng_imgui_in_button(text..index, text, tabwidth, tabheight, function () ng_imgui_current_edit_tab=index end)
	
	imgui.PopStyleVar()
	imgui.PopStyleColor(3)
end

-- -----------------------------------------------------------------------------------------
-- drawing Editor window
-- -----------------------------------------------------------------------------------------
function ng_draw_edit_window()

	-- if ng_imgui_initial_edit_set == false then
		if FLYWITHLUA then
			-- imgui.SetNextWindowPos(ng_imgui_initial_edit_xpos,ng_imgui_initial_edit_ypos)
			ng_imgui_initial_edit_set = true
		else
			imgui.SetNextWindowSize({ng_imgui_initial_edit_width,ng_imgui_initial_edit_height})
			imgui.SetNextWindowPos({ng_imgui_initial_edit_xpos, ng_imgui_initial_edit_ypos})
			ng_imgui_initial_edit_set = true
		end
	-- end

	if FLYWITHLUA == false then imgui.Begin("EDITOR") end

		local tabsDef = {[0]="SOP", [1]="SYSTEMS", [2]="PREFS"}
		
		local tabsNumber = (#tabsDef+1)
		local tabsSize = 480 / tabsNumber - 4
		
		imgui.BeginGroup()
			for i = 0,#tabsDef,1 do ng_imgui_draw_add_edit_tab(i, tabsSize, tabsDef[i]) end
		imgui.EndGroup()
		
		imgui.BeginGroup()
		if ng_imgui_current_edit_tab == 0 then render_edit_tab_sop()
		elseif ng_imgui_current_edit_tab == 1 then render_edit_tab_sys() 
		elseif ng_imgui_current_edit_tab == 2 then render_edit_tab_pref()
		end
		imgui.EndGroup()


	if FLYWITHLUA == false then imgui.End() end

end