local Assignments 	= require("kpcrew.Addon.Assignments.AircraftAssignments")

-- -----------------------------------------------------------------------------------------
-- load assignment json 
function assignments_load()
	local path = SCRIPT_DIRECTORY.."../Modules/kpcrew_prefs/acftselect.json"
	if ng_file_exists(path) then
		local json = require "kpcrew.json"
		local file = io.open(path, "r")
		local jsonstr = ""
		for line in file:lines() do jsonstr = jsonstr .. line end
		file:close()
		ng_editor_assignments_json = json.parse(jsonstr)
		ng_editor_assignments_error = ""
	else
		ng_editor_assignments_error = "No file!"
	end
end
-- -----------------------------------------------------------------------------------------
		
-- -----------------------------------------------------------------------------------------
-- save the edited assignment json 
function assignments_save()
	if ng_editor_assignments_json ~= nil then
		local path = SCRIPT_DIRECTORY.."../Modules/kpcrew_prefs/acftselect.json"
		local prettyprint = require ("kpcrew.json_pretty_print")
		local jsonout = prettyprint:pretty_print(ng_editor_assignments_json,nil,true)
		local filesystem = io.open(path, "w+")
		filesystem:write(jsonout)
		filesystem:close()
		ng_editor_assignments_error = ""
	end
end
-- -----------------------------------------------------------------------------------------

-- -----------------------------------------------------------------------------------------
-- draw the assignment editor
function render_assignment_editor()


	-- Append system
	local newassignment = { name = "", planeicao = "DFLT", planetailnum = "DFLT", settings = {
          preficao = "DFLT",
          sopicao = "DFLT",
          sysicao = "DFLT" } }
		  
	if ng_editor_assignments_json ~= nil then
		
		imgui.SetNextItemOpen(true)
		
		local function compareNames(a, b)
			return a.name < b.name
		end
		
		table.sort(ng_editor_assignments_json.acftselect.addons, compareNames)

		if imgui.TreeNode("Assignments") then

			imgui.SetNextItemOpen(true)

			ng_imgui_in_button("assignmentappend", "Append Assignment", 125, 20, 
				function () if ng_editor_assignment_newelement ~= "" then 
					newassignment.name=ng_editor_assignment_newelement
					table.insert (ng_editor_assignments_json.acftselect.addons, newassignment) ng_editor_assignment_newelement = "" end 
				end) 
			imgui.SameLine() ng_imgui_in_tfield("assignmentappendname", 250, color_white, 285, 
				ng_editor_assignment_newelement, function (textout) ng_editor_assignment_newelement = textout end)
				

		
			for nidx,naddon in pairs(ng_editor_assignments_json.acftselect.addons) do
				if imgui.TreeNode(naddon.name) then
					
					ng_editor_remove_assignment = sop_remove_buttons(naddon.name, "ASSIGNMENT", ng_editor_assignments_json.acftselect.addons, nidx, 375, ng_editor_remove_assignment)

					imgui.Columns(2, naddon.name, true)					
						imgui.SetColumnWidth(0, 200)
						imgui.SetColumnWidth(1, 150)
													
							ng_imgui_out_text(color_white, "Name") imgui.NextColumn()
								ng_imgui_in_tfield(naddon.name.."name", 300, color_white, 255,  
							naddon.name, function (textout) naddon.name = textout end) imgui.NextColumn()

							ng_imgui_out_text(color_white, "ACF Plane ICAO") imgui.NextColumn()
								ng_imgui_in_tfield(naddon.name.."planeicao", 50, color_white, 255,  
							naddon.planeicao, function (textout) naddon.planeicao = textout end) imgui.NextColumn()

							ng_imgui_out_text(color_white, "ACF Plane TAIL") imgui.NextColumn()
							if naddon.planetailnum ~= nil then
								ng_imgui_in_button(naddon.name.."niltail", "-", 15, 20, 
									function () naddon.planetailnum = nil end) imgui.SameLine()
								ng_imgui_in_tfield(naddon.name.."planetailnum", 300, color_white, 255,  
									naddon.planetailnum, function (textout) naddon.planetailnum = textout end) imgui.NextColumn()
							else
								ng_imgui_in_button(naddon.name.."addtail", "+", 15, 20, 
									function () naddon.planetailnum = "" end) imgui.NextColumn()
							end

							ng_imgui_out_text(color_white, "SOP ICAO") imgui.NextColumn()
								ng_imgui_in_tfield(naddon.name.."sopicao", 50, color_white, 255,  
							naddon.settings.sopicao, function (textout) naddon.settings.sopicao = string.upper(textout) end) imgui.NextColumn()

							ng_imgui_out_text(color_white, "SYSTEMS ICAO") imgui.NextColumn()
								ng_imgui_in_tfield(naddon.name.."sysicao", 50, color_white, 255,  
							naddon.settings.sysicao, function (textout) naddon.settings.sysicao = string.upper(textout) end) imgui.NextColumn()

							ng_imgui_out_text(color_white, "PREFERENCES ICAO") imgui.NextColumn()
								ng_imgui_in_tfield(naddon.name.."preficao", 50, color_white, 255,  
							naddon.settings.preficao, function (textout) naddon.settings.preficao = string.upper(textout) end) imgui.NextColumn()

					imgui.Columns(1)	
					
				imgui.TreePop() end
			end
		imgui.TreePop() end
		
	end
end
-- -----------------------------------------------------------------------------------------

-- -----------------------------------------------------------------------------------------
function render_edit_tab_asgn()

	imgui.BeginChild("#tabeditasgn")

		ng_imgui_out_text(color_yellow," ================= AIRCRAFT ASSIGNMENT EDITOR ==================")
	
		-- load and save button to save after changes or load again
		ng_imgui_in_button("loadasgn", "LOAD", 43, 20, 
			function () assignments_load() end)

		imgui.SameLine()
		ng_imgui_in_button("saveasgn","SAVE", 43, 20,
			function () assignments_save() end)
		
		imgui.SameLine()
		ng_imgui_out_text(color_red,ng_editor_assignments_error)
		
		imgui.Separator()

		imgui.BeginChild("#assignrender")
			imgui.SetNextItemOpen(true)
			render_assignment_editor()
		imgui.EndChild()
		
	imgui.EndChild()
end