local SOP 		= require("kpcrew.Addon.SOP.SOP")

-- -----------------------------------------------------------------------------------------
--- draw a group to add a system element
function sop_add_system_element(label, nitem )
	
	-- Append item
	local newelement = {element="" }

	-- -----------------------------------------------------------
	-- [Add Element] [<all elements sorted> V] [<filter for list>]
	-- -----------------------------------------------------------
	ng_imgui_in_button(label.."append", "Add Element", 90, 20, 
		function () if ng_editor_sop_newelement ~= "" then newelement.element=ng_editor_sop_newelement table.insert (nitem.setelements, newelement) ng_editor_sop_newelement= "" end end) 

	-- prefill drop down beginning with element groups (#xxxx) followed by annunciators (_xxxx) 
	-- and then individual elements alphanumerically sorted
	local categnames = {""} -- load a list of category names
	
	for k,n in pairs(ng_get_active_sys().categories) do 
		for l,m in pairs(n.systems) do 
			table.insert(categnames, "#"..m.name) 
			for i,o in pairs(m.elements) do 
				table.insert(categnames, o.name) 
			end
		end
	end
	table.sort(categnames) -- sort alphabetically
	local catindx = ng_indexOf(categnames,ng_editor_sop_newelement)
	if catindx == nil then catindx = 1 end

	imgui.SameLine() ng_imgui_in_combosearch(label.."categs", categnames, catindx-1,
		function (textin) 
			catindx = textin+1
			ng_editor_sop_newelement = categnames[catindx]
			ng_editor_sop_filter = ""
		end,130,ng_editor_sop_filter)

	imgui.SameLine() ng_imgui_in_tfield(label.."filter", 140, color_white, 100, 
		ng_editor_sop_filter, function (textout) ng_editor_sop_filter = textout end)
end
-- -----------------------------------------------------------------------------------------

-- -----------------------------------------------------------------------------------------
--- render a flow item (step)
-- @param tablenode item node
-- @param int itemnode index
-- @param tablenode parent flow
function sop_rnd_flowitem(nitem, nidx, nflow)

	local itemclasses = { "", "ProcedureItem", "ChecklistItem" }
	local roles = { "", "ng_firole_PF", "ng_firole_PNF", "ng_firole_PM", "ng_firole_BOTH", 
		"ng_firole_FO", "ng_firole_CPT", "ng_firole_LHS", "ng_firole_RHS", "ng_firole_FE", 
		"ng_firole_CM1", "ng_firole_CM2", "ng_firole_CM3", "ng_firole_ALL", "ng_firole_SYS" }
	local actions = { "", "on", "off", "set", "tgl", "up", "dn", "funct", "chk", " "}

	local nlabel = nflow.title..nitem.challenge..nidx

	imgui.BeginGroup()
		
		-- imgui.Separator()
		
			if imgui.TreeNode(nidx.." "..nitem.challenge) then

				ng_imgui_in_button("setstepname","SET", 43, 20,
					function () nitem.challenge = ng_editor_step_title ng_editor_step_title = "" end)
				imgui.SameLine() 
				ng_imgui_in_tfield("stepedittitle", 350, color_white, 100, 
					ng_editor_step_title, function (textout) ng_editor_step_title = string.upper(textout) end)

				sop_up_down(nlabel, nflow.flowitem, nidx)
				
				-- put item in the copy buffer to paste in any flow
				imgui.SameLine() ng_editor_sop_itemcopy, ng_editor_sop_itemcopyname = 
					sop_copy_button(nlabel, nitem, ng_editor_sop_itemcopy, ng_editor_sop_itemcopyname)

				-- delete the item
				imgui.SameLine()
				ng_editor_sop_remove_item = sop_remove_buttons(nlabel, "ITEM", nflow.flowitem, nidx, 265, ng_editor_sop_remove_item)

				-- Class of item (Procedure or Checklist item)
				ng_imgui_out_text(color_white, "Class    :") imgui.SameLine()
				if nitem.classname ~= nil then
					ng_imgui_in_combolist(nlabel.."class", itemclasses, ng_indexOf(itemclasses,nitem.classname)-1, 
						function (textin) nitem.classname=itemclasses[textin+1] end,295)
				else
					nitem.classname = "ProcedureItem"
				end
				
				-- Response text
				ng_imgui_out_text(color_white, "Response :") imgui.SameLine()
				if nitem.response ~= nil then
					ng_imgui_in_tfield(nlabel.."response", 295, color_white, 255, 
					nitem.response, function (textout) nitem.response = string.upper(textout) end)
				else
					nitem.response = " " 
				end
				
				-- Role for this item
				ng_imgui_out_text(color_white, "Role     :") imgui.SameLine()
				if nitem.role ~= nil then
					ng_imgui_in_combolist(nlabel.."role", roles, ng_indexOf(roles,nitem.role)-1, 
						function (textin) nitem.role=roles[textin+1] end,295)
				else
					nitem.role = "ng_firole_FO"
				end
				
				-- Condition contains a "return <condition resulting in true/false>"
				-- if you want to override then set to "return true"
				ng_imgui_out_text(color_white, "Condition:") imgui.SameLine()
				if nitem.condition ~= nil then
					ng_imgui_in_button(nlabel.."removecond", "-", 15, 20, 
						function () nitem.condition = nil end) imgui.SameLine()
					if nitem.condition ~= nil then
						ng_imgui_in_tfield(nlabel.."condition", 273, color_white, 255, 
							nitem.condition, function (textout) nitem.condition = textout end)
					end
				else
					ng_imgui_in_button(nlabel.."addcond", "+", 15, 20, 
						function () nitem.condition = "true" end) 
				end
				
				-- if nocheck is set and 1 the item will not be checked during execution
				ng_imgui_out_text(color_white, "No check :") imgui.SameLine()
				if nitem.nocheck ~= nil then
					ng_imgui_in_button(nlabel.."removenchk", "-", 15, 20, 
						function () nitem.nocheck = nil end) imgui.SameLine()
					if nitem.nocheck ~= nil then
						ng_imgui_in_intfield(nlabel.."nchk", 273, color_white, 0,   
							nitem.nocheck, function (textout) if textout == "--" then nitem.nocheck = nil else nitem.nocheck = textout end end) 
					end
				else
					ng_imgui_in_button(nlabel.."addncheck", "+", 15, 20, 
						function () nitem.nocheck = 1 end) 
				end

				-- values > 0 will wait n seconds before the next step
				ng_imgui_out_text(color_white, "Delay    :") imgui.SameLine()
				if nitem.delay ~= nil then
					ng_imgui_in_button(nlabel.."removedelay", "-", 15, 20, 
						function () nitem.delay = nil end) imgui.SameLine()
					if nitem.delay ~= nil then
						ng_imgui_in_intfield(nlabel.."delay", 273, color_white, 1, 
						nitem.delay, function (textout) nitem.delay = textout end)
					end
				else
					ng_imgui_in_button(nlabel.."adddelay", "+", 15, 20, 
						function () nitem.delay = 0 end) 
				end
				
				-- now list used systems and system elements
				ng_imgui_out_text(color_white, "Systems used:") 

-- -----------------------------------------------------------
-- [Add Element] [<all elements sorted> V] [<filter for list>]
-- -----------------------------------------------------------

				sop_add_system_element(nlabel, nitem)

				-- render added systems or system elements
				if nitem.setelements ~= nil then 
					
					for eidx,nelement in ipairs(nitem.setelements) do

						if nelement.element ~= nil then
							if imgui.TreeNode(eidx.." "..nelement.element) then

								if ng_editor_sop_expcol3 > 0 then imgui.SetNextItemOpen(ng_editor_sop_expand3) end

								sop_up_down(nelement.element, nitem.setelements, eidx)
								
								-- remove the system/element from flowitem
								imgui.SameLine()
								ng_editor_sop_remove_element = sop_remove_buttons(nelement.element, "ELEMENT", nitem.setelements, eidx, 295, ng_editor_sop_remove_element)
								
								-- Selected action
								ng_imgui_out_text(color_white, "Action   :") imgui.SameLine()
								if nelement.action ~= nil then
									ng_imgui_in_combolist(nlabel..nelement.element.."act", actions, ng_indexOf(actions,nelement.action)-1, 
										function (textin) nelement.action=actions[textin+1] end, 280)
								else
									nelement.action = "chk"
								end
								
								-- direct value to set (no logic)
								ng_imgui_out_text(color_white, "Value    :") imgui.SameLine()
								if nelement.value ~= nil then
									ng_imgui_in_button(nlabel..nelement.element.."removeval", "-", 15, 20, 
										function () nelement.value = nil end) imgui.SameLine()
									if nelement.value ~= nil then
										ng_imgui_in_floatfield(nlabel..nelement.element.."val", 258, color_white, 0, "%8.3f",  
											nelement.value, function (textout) nelement.value = textout end) 
									end
								else
									ng_imgui_in_button(nlabel..nelement.element.."addval", "+", 15, 20, 
										function () nelement.value = 0 end) 
								end
								
								-- fvalue code to set the value with lua statetement "return <a resulting value>"
								-- will be used for actioning the step or check system/elements of the step
								ng_imgui_out_text(color_white, "value()  :") imgui.SameLine()
								if nelement.fvalue ~= nil then
									ng_imgui_in_button(nlabel..nelement.element.."removefvalue", "-", 15, 20, 
										function () nelement.fvalue = nil end) imgui.SameLine()
									if nelement.fvalue ~= nil then
										ng_imgui_in_tfield(nlabel..nelement.element.."fvalue", 258, color_white, 255, 
										nelement.fvalue, function (textout) nelement.fvalue = textout end)
									end
								else
									ng_imgui_in_button(nlabel..nelement.element.."addfvalue", "+", 15, 20, 
										function () nelement.fvalue = "0" end) 
								end
										
								-- fset code to set the value with lua statetement "<code to do complex logic>"
								ng_imgui_out_text(color_white, "set()    :") imgui.SameLine()
								if nelement.fset ~= nil then
									ng_imgui_in_button(nlabel..nelement.element.."removefset", "-", 15, 20, 
										function () nelement.fset = nil end) imgui.SameLine()
									if nelement.fset ~= nil then
										ng_imgui_in_tfield(nlabel..nelement.element.."fset", 258, color_white, 255, 
										nelement.fset, function (textout) nelement.fset = textout end)
									end
								else
									ng_imgui_in_button(nlabel..nelement.element.."addfset", "+", 15, 20, 
										function () nelement.fset = "return \"\"" end) 
								end
										
								-- Condition to enable or disable the system/element.
								ng_imgui_out_text(color_white, "Condition:") imgui.SameLine()
								if nelement.condition ~= nil then
									ng_imgui_in_button(nlabel..nelement.element.."removecond", "-", 15, 20, 
										function () nelement.condition = nil end) imgui.SameLine()
									if nelement.condition ~= nil then
										ng_imgui_in_tfield(nlabel..nelement.element.."cond", 258, color_white, 255, 
										nelement.condition, function (textout) nelement.condition = textout end)							
									end
								else
									ng_imgui_in_button(nlabel..nelement.element.."addcond", "+", 15, 20, 
										function () nelement.condition = "true" end) 
								end
																						
								-- no check, when 1 then ignore the system/element during checks. Set 0 to enable checks again
								ng_imgui_out_text(color_white, "No check :") imgui.SameLine()
								if nelement.nocheck ~= nil then
									ng_imgui_in_button(nlabel..nelement.element.."removenchk", "-", 15, 20, 
										function () nelement.nocheck = nil end) imgui.SameLine()
									if nelement.nocheck ~= nil then
										ng_imgui_in_intfield(nlabel..nelement.element.."nchk", 258, color_white, 0,   
											nelement.nocheck, function (textout) nelement.nocheck = textout end)
									end
								else
									ng_imgui_in_button(nlabel..nelement.element.."addnchk", "+", 15, 20, 
										function () nelement.nocheck = 1 end) 
								end
								
								-- fcheck code to check the element with code "return <true/false logic>"
								ng_imgui_out_text(color_white, "check()  :") imgui.SameLine()
								if nelement.fcheck ~= nil then
									ng_imgui_in_button(nlabel..nelement.element.."removefcheck", "-", 15, 20, 
										function () nelement.fcheck = nil end) imgui.SameLine()
									if nelement.fcheck ~= nil then
										ng_imgui_in_tfield(nlabel..nelement.element.."fcheck", 258, color_white, 255, 
										nelement.fcheck, function (textout) nelement.fcheck = textout end)
									end
								else
									ng_imgui_in_button(nlabel..nelement.element.."addfcheck", "+", 15, 20, 
										function () nelement.fcheck = "function (a) return true end" end) 
								end
							imgui.TreePop() end
						end
						imgui.Separator()
												
					end
				end

			imgui.TreePop() end
		
		imgui.Separator()
		
	imgui.EndGroup()
end
-- -----------------------------------------------------------------------------------------

-- -----------------------------------------------------------------------------------------
--- draw a up/down buttons group
function sop_remove_buttons(label, what, item, nidx, width, flag)
	
	if flag == false then 
		imgui.PushStyleColor(imgui.constant.Col.Button, color_red)
			imgui.PushStyleColor(imgui.constant.Col.Text, color_white)
				ng_imgui_in_button(label.."del", "REMOVE "..what.." "..label, width, 20, 
					function () flag = true end) 
			imgui.PopStyleColor()
		imgui.PopStyleColor()
	else 
		imgui.PushStyleColor(imgui.constant.Col.Button, color_green)
			imgui.PushStyleColor(imgui.constant.Col.Text, color_white)
				ng_imgui_in_button(label.."yes", "YES ", width/2-2, 20, 
					function () table.remove(item, nidx) flag = false end) 
			imgui.PopStyleColor()
		imgui.PopStyleColor()
		imgui.SameLine()
		imgui.PushStyleColor(imgui.constant.Col.Button, color_red)
			imgui.PushStyleColor(imgui.constant.Col.Text, color_white)
				ng_imgui_in_button(label.."no", "NO ", width/2-2, 20, 
					function () flag = false end) 
			imgui.PopStyleColor()
		imgui.PopStyleColor()
	end
	return flag
end
-- -----------------------------------------------------------------------------------------

-- -----------------------------------------------------------------------------------------
--- COPY button for copy/paste mecganism
function sop_copy_button(label, item, copyvar, namevar)
	
	-- [COPY]
	imgui.SameLine() ng_imgui_in_button(label.."copy", "COPY", 40, 20, 
		function () copyvar = item namevar = "" end) 

	return copyvar, namevar
		
end
-- -----------------------------------------------------------------------------------------

-- -----------------------------------------------------------------------------------------
--- draw a up/down buttons group
function sop_up_down(label, item, nidx)
	
	-- [UP][DN]
	ng_imgui_in_button(label.."up", "UP", 23, 20, 
		function () if nidx > 1 then 
			table.insert(item, nidx-1, table.remove(item, nidx)) end end) 

	imgui.SameLine() ng_imgui_in_button(label.."dn", "DN", 23, 20, 
		function () if nidx < #item then table.insert(item, nidx+1, table.remove(item, nidx)) end end) 
		
end
-- -----------------------------------------------------------------------------------------

-- -----------------------------------------------------------------------------------------
--- draw a expand/compress buttons group
function sop_compress_expand(label, colvar, expvar)
	
	-- [--][++]

	ng_imgui_in_button(label.."expand", "++", 23, 20, 
		function () colvar = 3 expvar = true end) 

	imgui.SameLine() ng_imgui_in_button(label.."compress", "--", 23, 20, 
		function () colvar = 3 expvar = false end) 
		
	return colvar, expvar
		
end
-- -----------------------------------------------------------------------------------------

-- -----------------------------------------------------------------------------------------
--- render a flow in the editor
-- @param tablenode flow
-- @param int index of flow 
-- @param int numflows number of flows in sop
function sop_rnd_flow(nflow, nidx, numflows)

	local phases = { "", "ng_phase_flight_planning", "ng_phase_colddark", "ng_phase_prel_preflight", 
		"ng_phase_preflight", "ng_phase_before_start", "ng_phase_after_start", "ng_phase_taxi_rwy", 
		"ng_phase_before_takeoff", "ng_phase_takeoff", "ng_phase_after_takeoff", "ng_phase_climb", 
		"ng_phase_enroute", "ng_phase_descent", "ng_phase_arrival", "ng_phase_approach", "ng_phase_landing", 
		"ng_phase_go_around", "ng_phase_afterland", "ng_phase_taxi_stand", "ng_phase_shutdown", "ng_phase_turnaround" }

	local flowclasses = { "", "ProcedureFlow", "ChecklistFlow", "BackgroundFlow" }

	local ntitle = nidx.." "..nflow.title
	
	if imgui.TreeNode(nidx.." "..nflow.title) then
		
		imgui.Separator()
		
		ng_imgui_in_button("setflowname","SET", 43, 20,
			function () nflow.title = ng_editor_flow_title ng_editor_flow_title = "" end)
		imgui.SameLine() 
		ng_imgui_in_tfield("flowedittitle", 350, color_white, 100, 
			ng_editor_flow_title, function (textout) ng_editor_flow_title = string.upper(textout) end)

		ng_editor_sop_expcol2, ng_editor_sop_expand2 = sop_compress_expand(ntitle, ng_editor_sop_expcol2, ng_editor_sop_expand2)
		
		imgui.SameLine() sop_up_down(ntitle, ng_editor_sop_json.sop.flow, nidx)
		
		imgui.SameLine() ng_editor_sop_flowcopy, ng_editor_sop_flowcopyname = 
			sop_copy_button(ntitle, nflow, ng_editor_sop_flowcopy, ng_editor_sop_flowcopyname)

		
		-- remove a flow
		imgui.SameLine()
		ng_editor_sop_remove_flow = sop_remove_buttons(ntitle, "FLOW", ng_editor_sop_json.sop.flow, nidx, 225, ng_editor_sop_remove_flow)

		ng_imgui_out_text(color_white, "Phase:") imgui.SameLine()
		ng_imgui_in_combolist(ntitle.."phase", phases, ng_indexOf(phases,nflow.phase)-1, 
			function (textin) nflow.phase=phases[textin+1] end, 345)

		ng_imgui_out_text(color_white, "Class:") imgui.SameLine()
		ng_imgui_in_combolist(ntitle.."class", flowclasses, ng_indexOf(flowclasses,nflow.classname)-1, 
			function (textin) nflow.classname=flowclasses[textin+1] end, 345)

		-- Append item
		local newitem = {challenge="", setelements = {  } }

		if ng_editor_sop_itemcopy ~= nil then
			ng_imgui_in_button(ntitle.."paste", "PASTE", 50, 20, 
			function () 
				if ng_editor_sop_itemcopyname ~= "" then 
					local copy = ng_deep_copy(ng_editor_sop_itemcopy)
					copy.challenge=string.upper(ng_editor_sop_itemcopyname) 
					table.insert (nflow.flowitem, copy) 
					ng_editor_sop_itemcopyname = ""
					ng_editor_sop_itemcopy = nil
				end
			end)
			
			imgui.SameLine() ng_imgui_out_text(color_white,"Title:")
			imgui.SameLine() ng_imgui_in_tfield(ntitle.."pastename", 290, color_white, 255, 
				ng_editor_sop_itemcopyname,
				function (textout) 
					if textout == "--" then
						ng_editor_sop_itemcopy = nil
						ng_editor_sop_itemcopyname = "" 
					else
						ng_editor_sop_itemcopyname = textout 
					end
				end)
		end 

		ng_imgui_in_button(ntitle.."append", "Append Item", 90, 20, 
			function () if ng_editor_sop_newitem ~= "" then newitem.challenge=string.upper(ng_editor_sop_newitem) table.insert (nflow.flowitem, newitem) ng_editor_sop_newitem = "" end end) 

		imgui.SameLine() ng_imgui_in_tfield(ntitle.."name", 300, color_white, 255, 
			ng_editor_sop_newitem, function (textout) ng_editor_sop_newitem = textout end)

		imgui.Separator()

		for nitemidx,nitem in ipairs(nflow.flowitem) do
			if ng_editor_sop_expcol2 > 0 then imgui.SetNextItemOpen(ng_editor_sop_expand2) end
			sop_rnd_flowitem(nitem,nitemidx,nflow)
		end
		imgui.Separator()
	imgui.TreePop() end
end
-- -----------------------------------------------------------------------------------------

-- -----------------------------------------------------------------------------------------
--- render the SOP editor
function render_sop_editor()

	if ng_editor_sop_json ~= nil then
		
		-- Loop through all flows
		if imgui.TreeNode(ng_editor_sop_json.sop.title) then
			
			-- Append flow
			local newflow = {title="", phase="ng_phase_colddark", classname="ProcedureFlow", flowitem={  } }

			if ng_editor_sop_flowcopy ~= nil then
				ng_imgui_in_button(ng_editor_sop_json.sop.title.."paste", "PASTE", 50, 20, 
				function () 
					if ng_editor_sop_flowcopyname ~= "" then 
						local copy = ng_deep_copy(ng_editor_sop_flowcopy)
						copy.title=string.upper(ng_editor_sop_flowcopyname) 
						table.insert (ng_editor_sop_json.sop.flow, copy) 
						ng_editor_sop_flowcopyname = ""
						ng_editor_sop_flowcopy = nil
					end
				end)
				
				imgui.SameLine() ng_imgui_out_text(color_white,"Title:")

				imgui.SameLine() ng_imgui_in_tfield(ng_editor_sop_json.sop.title.."pastename", 280, color_white, 255, 
					ng_editor_sop_flowcopyname, 
					function (textout) 
						if textout == "--" then
							ng_editor_sop_flowcopy = nil
							ng_editor_sop_flowcopyname = "" 
						else
							ng_editor_sop_flowcopyname = textout 
						end
					end)
			end 

			ng_imgui_in_button(ng_editor_sop_json.sop.title.."append", "Append Flow", 90, 20, 
				function () if ng_editor_sop_newflow ~= "" then newflow.title=string.upper(ng_editor_sop_newflow) table.insert (ng_editor_sop_json.sop.flow, newflow) ng_editor_sop_newflow = "" end end) 

			imgui.SameLine() ng_imgui_in_tfield(ng_editor_sop_json.sop.title.."name", 280, color_white, 255, 
				ng_editor_sop_newflow, function (textout) ng_editor_sop_newflow = textout end)

			for nidx,nflow in ipairs(ng_editor_sop_json.sop.flow) do
				sop_rnd_flow(nflow,nidx,#ng_editor_sop_json.sop.flow)
			end

		imgui.TreePop() end
	end
end

-- -----------------------------------------------------------------------------------------
--- load SOP json with definitions of all flows
function sop_load()

	local path = SCRIPT_DIRECTORY.."../Modules/kpcrew/addons/"..ng_editor_sop_icao.."_sop.json"
	if ng_editor_sop_icao == "DFLT" then 
		ng_editor_sop_error = "DFLT not allowed - XXXX"
		-- return 
	end 
	if ng_file_exists(path) then
		local json = require "kpcrew.json"
		local file = io.open(path, "r")
		local jsonstr = ""
		for line in file:lines() do jsonstr = jsonstr .. line end
		file:close()
		ng_editor_sop_json = json.parse(jsonstr)
		ng_editor_sop_error = ""
	else
		ng_editor_sop_error = "No file!"
	end
	
end
-- -----------------------------------------------------------------------------------------
		
-- -----------------------------------------------------------------------------------------
--- save edited SOP
function sop_save()

	if ng_editor_sop_json ~= nil then
		local path = SCRIPT_DIRECTORY.."../Modules/kpcrew/addons/"..ng_editor_sop_icao.."_sop.json"
		if ng_editor_sop_icao == "DFLT" then 
			ng_editor_sop_error = "DFLT not allowed - XXXX"
			-- return 
		end 
		local prettyprint = require ("kpcrew.json_pretty_print")
		local jsonout = prettyprint:pretty_print(ng_editor_sop_json,nil,true)
		local filesystem = io.open(path, "w+")
		filesystem:write(jsonout)
		filesystem:close()
		ng_editor_sop_error = ""
	end
end
-- -----------------------------------------------------------------------------------------

-- -----------------------------------------------------------------------------------------
-- add new sop json based on DFLT
function sop_add(newicao)

	local newjson = SCRIPT_DIRECTORY.."../Modules/kpcrew/addons/"..newicao.."_sop.json"
	local dfltjson = SCRIPT_DIRECTORY.."../Modules/kpcrew/addons/DFLT_sop.json"
	-- ignore when already file exists
	if newicao == "DFLT" or ng_file_exists(newjson) then 
		ng_editor_sop_error = "Exists!"
		return 
	end 

	-- read source DFLT
	local jsonin = require "kpcrew.json"
	local filein = io.open(dfltjson, "r")
	local jsonstrin = ""
	for line in filein:lines() do jsonstrin = jsonstrin .. line end
	filein:close()

	-- write to new
	local fileout = io.open(newjson, "w+")
	fileout:write(jsonstrin)
	fileout:close()
	ng_editor_sop_error = ""

end
-- -----------------------------------------------------------------------------------------

-- -----------------------------------------------------------------------------------------
--- apply edited SOP
function sop_apply()

	local prettyprint = require ("kpcrew.json_pretty_print")
	local jsonout = prettyprint:pretty_print(ng_editor_sop_json,nil,true)

	-- sop_save()
	local sop = SOP:new("SOP Default Aircraft",SCRIPT_DIRECTORY.."../Modules/kpcrew/addons/"..ng_editor_sop_icao.."_sop.json")
	sop:load()
	ng_set_active_sop(sop)
	ng_editor_sop_error = "Applied"
	
end
-- -----------------------------------------------------------------------------------------

-- -----------------------------------------------------------------------------------------
-- draw the Settings tab
function render_edit_tab_sop()

	imgui.BeginChild("#tabeditsop")
			
		ng_imgui_out_text(color_yellow," ========================== SOP EDITOR =========================")
		
		-- ICAO for systems
		ng_imgui_in_tfield("SOP for", 40, color_white, 10, ng_editor_sop_icao, 
			function (textout) ng_editor_sop_icao = string.upper(textout) end)

		-- load and save button to save after changes or load again
		imgui.SameLine()
		ng_imgui_in_button("loadsop", "LOAD", 50, 20, 
			function () sop_load() ng_editor_sop_title = ng_editor_sop_json.sop.title end)

		imgui.SameLine()
		ng_imgui_in_button("savesop","SAVE", 50, 20,
			function () sop_save() end)

		imgui.SameLine()
		ng_imgui_in_button("addsop","ADD", 50, 20,
			function () sop_add(ng_editor_sop_icao) end)

		imgui.SameLine()
		ng_imgui_in_button("applysop","APPLY", 50, 20,
			function () sop_apply() end)

		imgui.SameLine()
		ng_imgui_out_text(color_red,ng_editor_sop_error)

		ng_imgui_in_button("setsopname","SET", 43, 20,
			function () ng_editor_sop_json.sop.title = ng_editor_sop_title end)
		imgui.SameLine() 
		ng_imgui_in_tfield("sopedittitle", 250, color_white, 100, 
			ng_editor_sop_title, function (textout) ng_editor_sop_title = textout end)

		imgui.Separator()
		
		imgui.BeginChild("#soprender")
			imgui.SetNextItemOpen(true)
			render_sop_editor()
			if ng_editor_sop_expcol1 > 0 then ng_editor_sop_expcol1 = ng_editor_sop_expcol1 - 1 end
			if ng_editor_sop_expcol2 > 0 then ng_editor_sop_expcol2 = ng_editor_sop_expcol2 - 1 end
			if ng_editor_sop_expcol3 > 0 then ng_editor_sop_expcol3 = ng_editor_sop_expcol3 - 1 end
		imgui.EndChild()
		
	imgui.EndChild() -- #tabeditpref	

end
