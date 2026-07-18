-- =========================================================================================
-- SOP window rendering #sopwindow
-- =========================================================================================

-- -----------------------------------------------------------------------------------------
-- drawing function for SOP window
--
-- +-----------------------------------------------------|
-- |[++] [RESET SOP]                                     |
-- |-----------------------------------------------------|
-- |[+] [S] [Flowname button                     ] [C][R]|
-- |...                                                  |
-- +-----------------------------------------------------+
function ng_draw_sop_window()

	-- do intial setup size/position
	if ng_imgui_initial_sop_set == false then
		if FLYWITHLUA then
			-- imgui.SetNextWindowPos(ng_scrn_width-ng_imgui_initial_sop_width,ng_scrn_height-((15 + 2 ) * 23 + 12 + 77))
		else
			imgui.SetNextWindowSize({ng_imgui_initial_sop_width,ng_get_active_sop():getNumberFlows()*ng_imgui_initial_sop_height})
			imgui.SetNextWindowPos({ng_scrn_width-ng_imgui_initial_sop_width, (50/17)*ng_get_active_sop():getNumberFlows()})
			ng_imgui_initial_sop_set = true
		end
	end 
	
	if FLYWITHLUA == false then imgui.Begin(ng_get_active_sop():getTitle()) end
		
		-- [++] Unfold/Fold all flow entries
		ng_imgui_in_button(ng_get_active_sop():getTitle().."toggle",ng_sop_flows_visible and "--" or "++",20, 20, 
					function() ng_sop_flows_visible = not ng_sop_flows_visible 
						ng_get_active_sop():setVisibility(ng_sop_flows_visible) 
					end,"Unfold/Fold all flows")
					
		-- [RESET SOP] Resets all flows in SOP	
		imgui.SameLine()
		imgui.PushStyleColor(imgui.constant.Col.Button, color_red)
			ng_imgui_in_button("sopreset","RESET SOP", 100, 20,
				function () ng_get_active_sop():reset() end, "Reset all flows of SOP")
		imgui.PopStyleColor()
		imgui.Separator()

		-- Renders the list of flows
		ng_get_active_sop():render("i")
		
	if FLYWITHLUA == false then imgui.End() end
	
end
