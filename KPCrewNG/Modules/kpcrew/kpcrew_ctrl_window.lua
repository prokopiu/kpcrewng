-- =========================================================================================
-- Control window rendering
-- =========================================================================================

-- -----------------------------------------------------------------------------------------
-- drawing function for ctrl window
--
-- +--------------------------------------------------------+
-- |[<<][Flow name and current item][>>][ACT][C][R][S][B][P]|
-- +--------------------------------------------------------+
function ng_draw_ctrl_window()
	
	-- do intial setup size/position
	if ng_imgui_initial_ctrl_set == false then
		if FLYWITHLUA then
			float_wnd_set_position(ng_ctrl_wnd, ng_scrn_width-ng_imgui_initial_ctrl_width, 0) 
			ng_imgui_initial_ctrl_set = true
		else
			imgui.SetNextWindowSize({ng_imgui_initial_ctrl_width+10,ng_imgui_initial_ctrl_height+10})
			imgui.SetNextWindowPos({ng_scrn_width-ng_imgui_initial_ctrl_width,ng_scrn_height-ng_imgui_initial_ctrl_height-100})
			ng_imgui_initial_ctrl_set = true
		end
	end
	
	-- get currently active sop and flow
	local sop = ng_get_active_sop()
	local flow = sop:getActiveFlow() 

	-- Window rendering
	if FLYWITHLUA == false then imgui.Begin("Control Window") end
	
	-- Previous button
	ng_imgui_in_button("ctrlprev","<<", 20, 20, 
		function () 
			if flow:getState() ~= ng_flowstate_run and flow:getState() ~= ng_flowstate_pause and flow:getState() ~= ng_flowstate_err then 
				ng_prev_flow() 
			end
		end,"Select previous flow") 
	
	-- Draw flow/step info
	imgui.SameLine()
	if flow == nil then
		outtext = "SOP :"..sop:getTitle()
		outcolor = color_white
	else
		if flow:getActiveItem() == nil or flow:getState() == ng_flowstate_end then
			outcolor = color_yellow
			
			if flow:isSelected() then mycolor = color_flow_active end
	
			if flow:getState() == ng_flowstate_new then outcolor = color_flow_new
			elseif flow:getState() == ng_flowstate_end then outcolor = color_flow_end
			elseif flow:getState() == ng_flowstate_err then outcolor = color_flow_err
			elseif flow:getState() == ng_flowstate_pause then outcolor = color_flow_pause 
			elseif flow:getState() == ng_flowstate_run then outcolor = color_flow_run
			end
			outtext = "FLOW: "..flow:getTitle()
			if flow:getState() == ng_flowstate_end then outtext = outtext.." - COMPLETED" end
		else
			outcolor = color_white
			if flow:getActiveItem():getState() == ng_fistate_end then outcolor = color_flow_end 
			elseif flow:getActiveItem():getState() == ng_fistate_err then outcolor = color_flow_err 
			elseif flow:getActiveItem():getState() == ng_fistate_run then outcolor = color_white 
			elseif flow:getState() == ng_flowstate_pause then outcolor = color_flow_pause
			end
			outtext = flow:getActiveItem():getLine(60)
		end
	end
	
	-- Display line as button with no function
	imgui.PushStyleColor(imgui.constant.Col.ButtonHovered, color_black)
		imgui.PushStyleColor(imgui.constant.Col.Button, color_black)
			imgui.PushStyleColor(imgui.constant.Col.Text, outcolor)
				ng_imgui_in_button("outtext",outtext, 420, 20, function () end)
			imgui.PopStyleColor()
		imgui.PopStyleColor()	
	imgui.PopStyleColor()
	
	-- next flow button
	imgui.SameLine()
	ng_imgui_in_button("ctrlnext",">>", 20, 20,
		function () 
			if flow:getState() ~= ng_flowstate_run and flow:getState() ~= ng_flowstate_pause and flow:getState() ~= ng_flowstate_err then 
				ng_next_flow() 
			end
		end, "Select next flow")

	-- Action or Master button
	imgui.SameLine()
	ng_imgui_in_button("ctrlmaster","ACT", 30, 20,
		function () ng_master_action() end, "Start or action current flow item")		

	-- Set whole flow to Complete button
	imgui.SameLine()
	imgui.PushStyleColor(imgui.constant.Col.Button, color_green)
		ng_imgui_in_button("ctrlcomplete","C", 20, 20,
			function () sop:getActiveFlow():complete() end, "Complete whole flow")
	imgui.PopStyleColor()

	-- Reset whole flow button
	imgui.SameLine()
	imgui.PushStyleColor(imgui.constant.Col.Button, color_red)
		ng_imgui_in_button("ctrlreset","R", 20, 20,
			function () sop:getActiveFlow():reset() end, "Reset flow")
	imgui.PopStyleColor()

	-- Toggle SOP window
	imgui.SameLine()
	local bcolor = (ng_sop_wnd == nil and color_ocean_blue or color_dark_grey)
	imgui.PushStyleColor(imgui.constant.Col.Button, bcolor)
		ng_imgui_in_button("ctrlsop","S", 20, 20,
			function () 
				if FLYWITHLUA then 
					ng_sop_action = 1 
				else
					if ng_sop_wnd == nil then ng_sop_wnd = 0 else ng_sop_wnd = nil end
				end 
			end, "Toggle SOP window")
	imgui.PopStyleColor()
	
	-- Toggle Briefing window
	imgui.SameLine()
	local bcolor = (ng_brief_wnd == nil and color_ocean_blue or color_dark_grey)
	imgui.PushStyleColor(imgui.constant.Col.Button, bcolor)
		ng_imgui_in_button("ctrlbrief","B", 20, 20,
			function () 
				if FLYWITHLUA then 
					ng_brief_action = 1
				else
					if ng_brief_wnd == nil then ng_brief_wnd = 0 else ng_brief_wnd = nil end
				end 
			end, "Toggle briefing window")
	imgui.PopStyleColor()
	
	-- Toggle Settings / Preferences window
	imgui.SameLine()
	local bcolor = (ng_pref_wnd == nil and color_ocean_blue or color_dark_grey)
	imgui.PushStyleColor(imgui.constant.Col.Button, bcolor)
		ng_imgui_in_button("ctrlpref","P", 20, 20,
			function () 
				if FLYWITHLUA then 
					ng_pref_action = 1
				else
					if ng_pref_wnd == nil then ng_pref_wnd = 0 else ng_pref_wnd = nil end
				end 
			end, "Toggle briefing window")
	imgui.PopStyleColor()
	
	-- Toggle Editor window
	imgui.SameLine()
	local bcolor = (ng_edit_wnd == nil and color_ocean_blue or color_dark_grey)
	imgui.PushStyleColor(imgui.constant.Col.Button, bcolor)
		ng_imgui_in_button("ctrledit","E", 20, 20,
			function () 
				if FLYWITHLUA then 
					ng_edit_action = 1
				else
					if ng_edit_wnd == nil then ng_edit_wnd = 0 else ng_edit_wnd = nil end
				end 
			end, "Toggle editor window")
	imgui.PopStyleColor()
	
	if FLYWITHLUA == false then imgui.End() end
end
