-- General utilities used in kpcrew and kphardware
-- some new features and ideas thanks to patrickl92
--
-- @author Kosta Prokopiu
-- @copyright 2026 Kosta Prokopiu

if FLYWITHLUA == false then -- use for Linux dev environment
	imgui = require "cimgui"
	ffi = require "ffi"
end

-- color definitions
color_black			= 0xFF000000
color_red 			= 0xFF0000FF
color_green 		= 0xFF558817
color_bright_green 	= 0xFF00FF00
color_dark_green 	= 0xFF002f00
color_white 		= 0xFFFFFFFF
color_light_blue 	= 0xFFFFFF00
color_orange 		= 0xFF003FBF
color_grey 			= 0xFFC0C0C0
color_dark_grey 	= 0xFF606060
color_left_display 	= 0xFFA0AFFF
color_ocean_blue 	= 0xFFEC652B
color_blue			= 0xFFFF0000
color_yellow 		= 0xFF00FFFF

color_flow_checklist	= 0xFF2d4e2c
color_flow_procedure	= color_dark_grey
color_flow_state		= 0xFF4F0000
color_flow_run			= 0xFF006468
color_flow_active		= 0xFF001F9F
color_flow_hovered		= 0xFF004F9F
color_flow_end			= color_green
color_flow_pause		= color_orange
color_flow_err			= color_red
color_flow_new			= color_white
color_step_procitem		= color_white
color_step_checkitem	= 0xFFb9f4b8
color_step_info			= color_dark_grey

color_mcp_button	= 0xFF303030
color_mcp_active	= 0xFF606060
color_mcp_hover		= 0xFF606060
color_mcp_text		= 0xFFC0C0C0
color_mcp_on		= 0xFF00FF00
color_mcp_off		= 0xFFC0C0C0

color_ctrl_bckgr	= 0xFF101010
color_ctrl_selected = 0xFF303030
color_mstr_flow_open = 0xFF404040

dist_sameline = 200

if FLYWITHLUA == false then -- use for Linux dev environment with cimgui
	imgui.constant = {Col = {Text=0, Button=21, ButtonActive=23, ButtonHovered=22}, StyleVar = {FramePadding=10}}
	imgui.PushStyleColor = imgui.PushStyleColor_U32
	imgui.PushStyleVar = imgui.PushStyleVar_Float 
	imgui.PushID = imgui.PushID_Str	
	imgui.Selectable = imgui.Selectable_Bool
	imgui.BeginChild = imgui.BeginChild_Str
	imgui.TreeNode = imgui.TreeNode_Str
	imgui.RadioButton = imgui.RadioButton_Bool
end 

-- ==== Output functions

--- textoutput with label
-- @param int color1 - color code of text to draw
-- @param string label - label keep "" if no label
-- @param int color2 - colr of label
-- @param string input - text to be drawn
-- @param int dist - distance between label and field
-- @param int wrap - set optional wrap position if provided
function ng_imgui_out_text(color1, label, color2, input, dist, wrap)
	if color2 ~= nil then
		imgui.PushStyleColor(imgui.constant.Col.Text, color2)
			imgui.TextUnformatted(label)
		imgui.PopStyleColor()
		imgui.SameLine(dist)
	end
	if input == nil then input = label end
	imgui.PushStyleColor(imgui.constant.Col.Text, color1)
		imgui.PushTextWrapPos(wrap)
			imgui.TextUnformatted(""..input)
		imgui.PopTextWrapPos()
	imgui.PopStyleColor()
end

-- ==== Input functions

--- Input: simple button
-- @param string push_id - unique ID for element
-- @param string btntext - text to show on button
-- @param int width - width of button
-- @param int height - height of button
-- @param function() action - activity to be triggered as function code
function ng_imgui_in_button(push_id, btntext, width, height, action)
	if FLYWITHLUA then -- switch depending on execution environment
		imgui.PushID(push_id)
			if imgui.Button(btntext, width, height) then action() end
		imgui.PopID()
	else
		imgui.PushID(push_id)
			if imgui.Button(btntext, {width, height}) then action() end
		imgui.PopID()
	end
end

function ng_imgui_in_lbutton(push_id, btntext, width, height, label, color, action)
	imgui.PushStyleColor(imgui.constant.Col.Text, color)
		imgui.TextUnformatted(label)
	imgui.PopStyleColor()
	imgui.SameLine()
	ng_imgui_in_button(push_id, btntext, width, height, action)
end

--- Input: Integer field
-- @param string push_id - unique ID for element
-- @param int itemwidth - width of field in pixel, o takes max size
-- @param int color - color of text in field
-- @param int incrdecr - step size to increment/decrement number
-- @param int input - pre-fill number
-- @param function() action - code to return the new value
function ng_imgui_in_intfield(push_id, itemwidth, color, incrdecr, input, output)
	if itemwidth > 0 then imgui.PushItemWidth(itemwidth) end
		imgui.PushID(push_id)
			imgui.PushStyleColor(imgui.constant.Col.Text, color)
				if FLYWITHLUA then
					local changed, textin = imgui.InputInt("", input, incrdecr)
					if changed then output(textin) end
				else
					local c_int_in = ffi.new("int32_t[1]", input)
					local changed = imgui.InputInt("", c_int_in, incrdecr)
					if changed then output(c_int_in[0]) end
				end					
			imgui.PopStyleColor()
		imgui.PopID()
	if itemwidth > 0 then imgui.PopItemWidth() end
end	

--- Input: Integer field with lable
-- @param string push_id - unique ID for element
-- @param int itemwidth - width of field in pixel, o takes max size
-- @param int color1 - color of text in field
-- @param int incrdecr - step size to increment/decrement number
-- @param string label - label
-- @param int solor2 - colr of label
-- @param int input - pre-fill number
-- @param function() action - code to return the new value
function ng_imgui_in_lintfield(push_id, itemwidth, color1, incrdecr, label, color2, input, output, dist)
	imgui.PushStyleColor(imgui.constant.Col.Text, color2)
		imgui.TextUnformatted(label)
	imgui.PopStyleColor()
	imgui.SameLine(dist)
	ng_imgui_in_intfield(push_id, itemwidth, color1, incrdecr, input, output)
end

--- Input: FLOAT field
-- @param string push_id - unique ID for element
-- @param int itemwidth - width of field in pixel, o takes max size
-- @param int color - color of text in field
-- @param int incrdecr - step size to increment/decrement number
-- @param string - format
-- @param float input - pre-fill number
-- @param function() action - code to return the new value
function ng_imgui_in_floatfield(push_id, itemwidth, color, incrdecr, format, input, output)
	if itemwidth > 0 then imgui.PushItemWidth(itemwidth) end
		if format == nil or format == "" then format = "%08.2f" end
		imgui.PushID(push_id)
			imgui.PushStyleColor(imgui.constant.Col.Text, color)
				if FLYWITHLUA then
					local changed, textin = imgui.InputFloat("", input, incrdecr, 1.0, format)
					if changed then output(textin) end
				else
					local c_int_in = ffi.new("float[1]", input)
					local changed = imgui.InputFloat("", c_int_in, incrdecr, 1.0, format)
					if changed then output(c_int_in[0]) end
				end					
			imgui.PopStyleColor()
		imgui.PopID()
	if itemwidth > 0 then imgui.PopItemWidth() end
end	

--- Input: Float field with lable
-- @param string push_id - unique ID for element
-- @param int itemwidth - width of field in pixel, o takes max size
-- @param int color1 - color of text in field
-- @param int incrdecr - step size to increment/decrement number
-- @param string - format
-- @param string label - label
-- @param int color2 - colr of label
-- @param float input - pre-fill number
-- @param function() output - code to return the new value
function ng_imgui_in_lfloatfield(push_id, itemwidth, color1, incrdecr, format, label, color2, input, output, dist)
	imgui.PushStyleColor(imgui.constant.Col.Text, color2)
		imgui.TextUnformatted(label)
	imgui.PopStyleColor()
	imgui.SameLine(dist)
	ng_imgui_in_floatfield(push_id, itemwidth, color1, incrdecr, format, input, output)
end

--- Input: TEXT field
-- @param string push_id - unique ID for element
-- @param int itemwidth - width of field in pixel, o takes max size
-- @param int color - color of text in field
-- @param int length # of characters
-- @param string input - pre-fill text
-- @param function() action - code to return the new value
function ng_imgui_in_tfield(push_id, itemwidth, color, length, input, output)
	if itemwidth > 0 then imgui.PushItemWidth(itemwidth) end
		imgui.PushID(push_id)
			imgui.PushStyleColor(imgui.constant.Col.Text, color)
				if FLYWITHLUA then
					local changed, textin = imgui.InputText("", input, length)
					if changed then output(textin) end					
				else
					local c_str_in = ffi.new("char[?]", length + 1)
					ffi.copy(c_str_in, input)
					local changed  = imgui.InputText("", c_str_in, length)
					if changed then output(ffi.string(c_str_in)) end
				end
			imgui.PopStyleColor()
		imgui.PopID()
	if itemwidth > 0 then imgui.PopItemWidth() end
end

--- Input: TEXT field with label
-- @param string push_id - unique ID for element
-- @param int itemwidth - width of field in pixel, o takes max size
-- @param int color - color of text in field
-- @param int length # of characters
-- @param string label - label
-- @param int color2 - colr of label
-- @param string input - pre-fill text
-- @param function() action - code to return the new value
function ng_imgui_in_ltfield(push_id, itemwidth, color1, length, label, color2, input, output, dist)
	imgui.PushStyleColor(imgui.constant.Col.Text, color2)
		imgui.TextUnformatted(label)
	imgui.PopStyleColor()
	imgui.SameLine(dist)
	ng_imgui_in_tfield(push_id, itemwidth, color1, length, input, output)
end

--- Input: Radio Button Toggle field
-- @param string option1 - text for 1st option (true)
-- @param string option2 - text for 2nd option (false)
-- @param int input - current selection
-- @param function() action - code to return the new value
function ng_imgui_in_rbtoggle(option1, option2, input, output)
	local retval = input
	if imgui.RadioButton(option1, input == true) then retval = true end
	imgui.SameLine()
	if imgui.RadioButton(option2, input ~= true) then retval = false end
	output(retval)
end

--- Input: Combo list / drop-down
-- @param string push_id - unique ID for element
-- @param string option 2 false
-- @param int input - current selection
-- @param function() action - code to return the new value
function ng_imgui_in_combolist(push_id, options, input, output, width)
	imgui.PushID(push_id)
		if width then imgui.SetNextItemWidth(width) end
		if imgui.BeginCombo("", options[input + 1]) then
			for i = 2, #options do
				if imgui.Selectable(options[i], input + 1 == i) then
					output(i - 1)
				end
			end
		imgui.EndCombo()
		end				
	imgui.PopID()
end

-- ==== General drawing functions

--- Set up main window tabs with buttons
-- @param int index id of the tab (group) to be added
-- @param int size of tab in pixel
-- @param string name of tab/button  
function ng_imgui_draw_add_main_tab(index, tabsize, text)
	
	local tabwidth = tabsize
	local tabheight = 18
	
	imgui.PushStyleVar(12, 3)
	
	if index == 1 then imgui.SameLine(index * (tabwidth + 5))
	elseif index > 1 then imgui.SameLine(index * (tabwidth + 4 - index)) end
 
	if ng_imgui_current_main_tab == index then
		imgui.PushStyleColor(21, color_mcp_active)			
	else
		imgui.PushStyleColor(21, color_mcp_button)			
 	end 
	
	imgui.PushStyleColor(22, color_mcp_hover)
	imgui.PushStyleColor(23, color_orange)
	
	ng_imgui_in_button(text..index, text, tabwidth, tabheight, function () ng_imgui_current_main_tab=index end)
	
	imgui.PopStyleVar()
	imgui.PopStyleColor(3)
end