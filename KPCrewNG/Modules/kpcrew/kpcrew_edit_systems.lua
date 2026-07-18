local Systems 	= require("kpcrew.Addon.Systems.AddonSystems")

-- -----------------------------------------------------------------------------------------
-- load system json with definitions of all systems
function systems_load()
	local path = SCRIPT_DIRECTORY.."../Modules/kpcrew/addons/"..ng_editor_system_icao.."_systems.json"
	if ng_editor_system_icao == "DFLT" then
		ng_editor_system_error = "DFLT not allowed - XXXX"
		-- return 
	end 
	if ng_file_exists(path) then
		local json = require "kpcrew.json"
		local file = io.open(path, "r")
		local jsonstr = ""
		for line in file:lines() do jsonstr = jsonstr .. line end
		file:close()
		ng_editor_system_json = json.parse(jsonstr)
		ng_editor_system_error = ""
	else
		ng_editor_system_error = "No file!"
	end
end
-- -----------------------------------------------------------------------------------------
		
-- -----------------------------------------------------------------------------------------
-- save the edited system json 
function systems_save()
	local path = SCRIPT_DIRECTORY.."../Modules/kpcrew/addons/"..ng_editor_system_icao.."_systems.json"
	if ng_editor_system_icao == "DFLT" then 
		ng_editor_system_error = "DFLT not allowed - XXXX"
		-- return 
	end 
	local prettyprint = require ("kpcrew.json_pretty_print")
	local jsonout = prettyprint:pretty_print(ng_editor_system_json,nil,true)
	local filesystem = io.open(path, "w+")
	filesystem:write(jsonout)
	filesystem:close()
	ng_editor_system_error = ""
end
-- -----------------------------------------------------------------------------------------

-- -----------------------------------------------------------------------------------------
-- add new system json based on DFLT
function systems_add(newicao)
	local newjson = SCRIPT_DIRECTORY.."../Modules/kpcrew/addons/"..newicao.."_systems.json"
	local dfltjson = SCRIPT_DIRECTORY.."../Modules/kpcrew/addons/DFLT_systems.json"
	-- ignore when already file exists
	if newicao == "DFLT" or ng_file_exists(newjson) then 
		ng_editor_system_error = "Exists!"
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
	ng_editor_system_error = ""
end
-- -----------------------------------------------------------------------------------------

-- -----------------------------------------------------------------------------------------
-- appy current state to be active
function systems_apply()
	-- systems_save()
	local systems = Systems:new("Aircraft Systems",SCRIPT_DIRECTORY.."../Modules/kpcrew/addons/"..ng_editor_system_icao.."_systems.json")
	systems:load()
	ng_set_active_sys(systems)
	ng_editor_system_error = "Applied"
end
-- -----------------------------------------------------------------------------------------

-- -----------------------------------------------------------------------------------------
-- render lowest level in systems hierarchy - individual elements
-- @param tablenode nelement current element node in system table
-- @param int ielement index of element node on parent systems table
-- @param tablenode nsystem parent system node for this element 
-- @param string category name
function systems_rnd_element(nelement, ielement, nsystem, category)

-- common part for all types
-- --------------------------------------------------------
-- name		| [                                           ]
-- type		| [<type list drop down>                     V]
-- title	| [                                           ]
-- dref		| [                                           ]
-- indx		| [                                     ][-][+]
-- acts		| [<act1 V][<act2 V][<act3 V][<act4 V][<act5 V]
-- check()	| [<code that returns true/false>             ]
-- trans()	| [<code that returns transformed value>      ]

	imgui.BeginGroup()

		imgui.Separator()
		
		local ename = nelement.name -- base name to use for imgui id 

		if ng_getAppPrefs():get("kpcrew:syshiderem") == false or category == "xtensions" then
			imgui.NextColumn() 
			ng_editor_remove_element = sop_remove_buttons(ename, "ELEMENT", nsystem.elements, ielement, 300, ng_editor_remove_element)
			imgui.NextColumn() 
		end

-- name		| [                                           ]
		ng_imgui_out_text(color_white, "name") imgui.NextColumn()
		ng_imgui_in_tfield(ename.."name", 300, color_white, 255,  
			nelement.name, function (textout) nelement.name = textout end) imgui.NextColumn()

-- type		| [<type list drop down>                     V]
		ng_imgui_out_text(color_white, "type") imgui.NextColumn()
		if nelement.type ~= nil then
			ng_imgui_in_combolist(ename.."etype", ng_editor_types, ng_indexOf(ng_editor_types,nelement.type)-1, 
				function (textin) 
					nelement.type=ng_editor_types[textin+1]
					-- nelement.acts = nil
					if nelement.type == "dataref" then nelement.acts={"on","off","tgl","set","chk"} 
						elseif nelement.type == "onofftgl" then nelement.acts={"on","off","tgl","chk",""} 
						elseif nelement.type == "dialdref" then nelement.acts={"up","dn","set","chk",""} 
						elseif nelement.type == "dialcmd" then nelement.acts={"up","dn","chk","",""} 
						elseif nelement.type == "custom" then nelement.acts={"on","off","tgl","chk","set"} 
					end
				end,
			300) imgui.NextColumn()
		else -- if empty draw the plus button
			nelement.type = "dataref" imgui.NextColumn()
		end
			
-- title	| [                                           ]				
		ng_imgui_out_text(color_white, "title") imgui.NextColumn()
		if nelement.title ~= nil then
			-- ng_imgui_in_button(ename.."niltitle", "-", 15, 20, 
				-- function () nelement.title = nil end) imgui.SameLine()
			if nelement.title ~= nil then
				ng_imgui_in_tfield(ename.."title", 300, color_white, 255,  
					nelement.title, function (textout) nelement.title = textout end) 
			end
			imgui.NextColumn()
		else
			nelement.title = "<title>"
		end
		
		if nelement.type ~= "undefined" then					
-- dref		| [                                           ]
			ng_imgui_out_text(color_white, "dref") imgui.NextColumn()
			if nelement.dref ~= nil then
				ng_imgui_in_button(ename.."nildref", "-", 15, 20, 
					function () nelement.dref = nil end) imgui.SameLine()
				if nelement.dref ~= nil then
					ng_imgui_in_tfield(ename.."dref", 278, color_white, 255,  
					nelement.dref, function (textout) nelement.dref = textout end) imgui.NextColumn()
				end
			else
				ng_imgui_in_button(ename.."adddref", "+", 15, 20, 
					function () nelement.dref = "" end) imgui.NextColumn()
			end
			
-- indx		| [                                      ][-][+]
			ng_imgui_out_text(color_white, "indx") imgui.NextColumn()
			if nelement.indx ~= nil then
				ng_imgui_in_button(ename.."nilindx", "-", 15, 20, 
					function () nelement.indx = nil end) imgui.SameLine()
				if nelement.indx ~= nil then
					ng_imgui_in_intfield(ename.."indx", 278, color_white, 0, 
					nelement.indx, function (textout) if textout == -1 then 
						nelement.indx = nil else nelement.indx = textout end end) 
				end 
				imgui.NextColumn()
			else
				ng_imgui_in_button(ename.."addindx", "+", 15, 20, 
					function () nelement.indx = 0 end) imgui.NextColumn()
			end

-- acts		| [<act1 V][<act2 V][<act3 V][<act4 V][<act5 V]
-- up to 5 allowed actions for this element, blank action does nothing
			ng_imgui_out_text(color_white, "acts") imgui.NextColumn()
			
			if nelement.acts ~= nil then
				if #nelement.acts == 0 then for i=1,5 do nelement.acts[i] = " " end end
				if #nelement.acts > 0 then
					local lactions = ng_editor_actions[nelement.type]
					for nidx,nacts in pairs(nelement.acts) do 
						ng_imgui_in_combolist(ename.."acts"..nidx, lactions, ng_indexOf(lactions,nacts)-1, 
							function (textin) nelement.acts[nidx] = (lactions[textin+1] == " " and nil or lactions[textin+1]) end,54)
						if nidx < #nelement.acts then imgui.SameLine() end
					end
					for i=#nelement.acts+1,5,1 do
						imgui.SameLine()
						ng_imgui_in_combolist(ename.."nacts"..i, lactions, ng_indexOf(lactions," ")-1, 
							function (textin) nelement.acts[i] = lactions[textin] end,54)
					end
				
					imgui.NextColumn()
				end
			else
				ng_imgui_in_button(ename.."addacts", "+", 15, 20, 
					function () --", "dialdref", "dialcmd", "custom"
						if nelement.type == "dataref" then nelement.acts={"on","off","tgl","set","chk"} 
						elseif nelement.type == "onofftgl" then nelement.acts={"on","off","tgl","chk",""} 
						elseif nelement.type == "dialdref" then nelement.acts={"up","dn","set","chk",""} 
						elseif nelement.type == "dialcmd" then nelement.acts={"up","dn","chk","",""} 
						elseif nelement.type == "custom" then nelement.acts={"on","off","tgl","chk",""} 
						end
				end) imgui.NextColumn()					
			end

-- check()	| [<code that returns true/false>             ]
-- sth like return get(\"dataref/key\") == 1" for example
			ng_imgui_out_text(color_white, "check()") imgui.NextColumn()
			if nelement.fcheck ~= nil then
				ng_imgui_in_button(ename.."nilfcheck", "-", 15, 20, 
					function () nelement.fcheck = nil end) imgui.SameLine()
				if nelement.fcheck ~= nil then
					ng_imgui_in_tfield(ename.."funccheck", 281, color_white, 255, 
					nelement.fcheck, function (textout) nelement.fcheck = textout end) 
				end
				imgui.NextColumn()
			else
				ng_imgui_in_button(ename.."addfcheck", "+", 15, 20, 
					function () nelement.fcheck = "function (a) return true end" end) imgui.NextColumn()
			end

-- trans()	| [<code that returns a transformed value>             ]
-- transform the dataref to allow for special cases (e.g. math.ceil() by values)
			ng_imgui_out_text(color_white, "trans()") imgui.NextColumn()
			if nelement.ftrans ~= nil then
				ng_imgui_in_button(ename.."niltrans", "-", 15, 20, 
					function () nelement.ftrans = nil end) imgui.SameLine()
				if nelement.ftrans ~= nil then
					ng_imgui_in_tfield(ename.."ftrans", 281, color_white, 255, 
					nelement.ftrans, function (textout) nelement.ftrans = textout end) 
				end
				imgui.NextColumn()
			else
				ng_imgui_in_button(ename.."addftrans", "+", 15, 20, 
					function () nelement.ftrans = "function (a) a=x end" end) imgui.NextColumn()
			end
		end
		
-- ========== type specific fields to be added to common part
-- toggle and onoff elements
		if nelement.type == "onofftgl" then
		
-- cmdoff	| [                                           ]
-- x-plane command id string to execute with command_once() to turn sth OFF
			ng_imgui_out_text(color_white, "cmdoff") imgui.NextColumn()
			if nelement.cmdoff ~= nil then
				ng_imgui_in_button(ename.."nilcmdoff", "-", 15, 20, 
					function () nelement.cmdoff = nil end) imgui.SameLine()
				if nelement.cmdoff ~= nil then
					ng_imgui_in_tfield(ename.."cmdoff", 281, color_white, 255,  
					nelement.cmdoff, function (textout) nelement.cmdoff = textout end) 
				end 
				imgui.NextColumn()
			else
				ng_imgui_in_button(ename.."addcmdoff", "+", 15, 20, 
					function () nelement.cmdoff = "" end) imgui.NextColumn()
			end
				
-- cmdon	| [                                           ]
-- x-plane command id string to execute with command_once() to turn sth ON
			ng_imgui_out_text(color_white, "cmdon") imgui.NextColumn()
			if nelement.cmdon ~= nil then
				ng_imgui_in_button(ename.."nilcmdon", "-", 15, 20, 
					function () nelement.cmdon = nil end) imgui.SameLine()
				if nelement.cmdon ~= nil then
					ng_imgui_in_tfield(ename.."cmdon", 281, color_white, 255,  
					nelement.cmdon, function (textout) nelement.cmdon = textout end) 
				end
				imgui.NextColumn()
			else
				ng_imgui_in_button(ename.."addcmdon", "+", 15, 20, 
					function () nelement.cmdon = "" end) imgui.NextColumn()
			end
				
-- cmdtgl	| [                                           ]
-- x-plane command id string to execute with command_once() to toggle the switch
			ng_imgui_out_text(color_white, "cmdtgl") imgui.NextColumn()
			if nelement.cmdtgl ~= nil then
				ng_imgui_in_button(ename.."nilcmdtgl", "-", 15, 20, 
					function () nelement.cmdtgl = nil end) imgui.SameLine()
				if nelement.cmdtgl ~= nil then
					ng_imgui_in_tfield(ename.."cmdtgl", 281, color_white, 255,  
					nelement.cmdtgl, function (textout) nelement.cmdtgl = textout end) 
				end
				imgui.NextColumn()
			else
				ng_imgui_in_button(ename.."addcmdtgl", "+", 15, 20, 
					function () nelement.cmdtgl = "" end) imgui.NextColumn()
			end

		end

		-- dial elements
		if nelement.type == "dialdref" or nelement.type == "dialcmd" then

-- min		| [                                      ][-][+]
-- minimal value to dial/set
			ng_imgui_out_text(color_white, "min") imgui.NextColumn()
			if nelement.min ~= nil then
				ng_imgui_in_button(ename.."nilmin", "-", 15, 20, 
					function () nelement.min = nil end) imgui.SameLine()
				if nelement.min ~= nil then
					ng_imgui_in_intfield(ename.."min", 281, color_white, 1,
					nelement.min, function (textout) nelement.min = textout end) 
				end
				imgui.NextColumn()
			else
				nelement.min = 0 imgui.NextColumn()
			end
			
-- max		| [                                      ][-][+]
-- maximal value to dial/set
			ng_imgui_out_text(color_white, "max") imgui.NextColumn()
			if nelement.max ~= nil then
				ng_imgui_in_button(ename.."nilmax", "-", 15, 20, 
					function () nelement.max = nil end) imgui.SameLine()
				if nelement.max ~= nil then
					ng_imgui_in_intfield(ename.."max", 281, color_white, 1, 
					nelement.max, function (textout) nelement.max = textout end) 
				end
				imgui.NextColumn()
			else
				nelement.max = 999 imgui.NextColumn()
			end
			
			-- only for dialdref
			if nelement.type == "dialdref" or nelement.type == "dialcmd"  then

-- incr		| [                                      ][-][+]
-- increment for each step up/down
				ng_imgui_out_text(color_white, "incr") imgui.NextColumn()
				if nelement.incr ~= nil then
					ng_imgui_in_button(ename.."nilincr", "-", 15, 20, 
						function () nelement.incr = nil end) imgui.SameLine()
					if nelement.incr ~= nil then
						ng_imgui_in_intfield(ename.."incr", 281, color_white, 1, 
						nelement.incr, function (textout) nelement.incr = textout end) 
					end
					imgui.NextColumn()
				else
					nelement.incr = 1 imgui.NextColumn()
				end
				
			end 

			-- only for dialcmd
			if nelement.type == "dialcmd" then

-- cmddn	| [                                           ]
-- x-plane command id string to execute with command_once() decrease the value
				ng_imgui_out_text(color_white, "cmddn") imgui.NextColumn()
				if nelement.cmddn ~= nil then
					ng_imgui_in_button(ename.."nilcmddn", "-", 15, 20, 
						function () nelement.cmddn = nil end) imgui.SameLine()
					if nelement.cmddn ~= nil then
						ng_imgui_in_tfield(ename.."cmddn", 300, color_white, 255,  
						nelement.cmddn, function (textout) nelement.cmddn = textout end) 
					end
					imgui.NextColumn()
				else
					ng_imgui_in_button(ename.."addcmddn", "+", 15, 20, 
						function () nelement.cmddn = "" end) imgui.NextColumn()
				end
			
-- cmdup	| [                                           ]
-- x-plane command id string to execute with command_once() increase the value
				ng_imgui_out_text(color_white, "cmdup") imgui.NextColumn()
				if nelement.cmdup ~= nil then
					ng_imgui_in_button(ename.."nilcmdup", "-", 15, 20, 
						function () nelement.cmdup = nil end) imgui.SameLine()
					if nelement.cmdup ~= nil then
						ng_imgui_in_tfield(ename.."cmdup", 300, color_white, 255,  
						nelement.cmdup, function (textout) nelement.cmdup = textout end) 
					end
					imgui.NextColumn()
				else
					ng_imgui_in_button(ename.."addcmdup", "+", 15, 20, 
						function () nelement.cmdup = "" end) imgui.NextColumn()
				end

			end
		end

-- custom elements
		if nelement.type == "custom" then

-- on()		| [                                           ]
-- function triggering actions to set a switch which is not simple 1/0 or commands
			ng_imgui_out_text(color_white, "on()") imgui.NextColumn()
			if nelement.fon ~= nil then
				ng_imgui_in_button(ename.."nilfuncon", "-", 15, 20, 
					function () nelement.fon = nil end) imgui.SameLine()
				if nelement.fon ~= nil then
					ng_imgui_in_tfield(ename.."funcon", 281, color_white, 255, 
					nelement.fon, function (textout) nelement.fon = textout end) 
				end
				imgui.NextColumn()
			else
				ng_imgui_in_button(ename.."addfuncon", "+", 15, 20, 
					function () nelement.fon = "function (a) return xx end" end) imgui.NextColumn()
			end
-- off()	| [                                           ]
-- function triggering actions to set a switch which is not simple 1/0 or commands
			ng_imgui_out_text(color_white, "off()") imgui.NextColumn()
			if nelement.foff ~= nil then
				ng_imgui_in_button(ename.."nilfuncoff", "-", 15, 20, 
					function () nelement.foff = nil end) imgui.SameLine()
				if nelement.foff ~= nil then
					ng_imgui_in_tfield(ename.."funcoff", 281, color_white, 255,  
					nelement.foff, function (textout) nelement.foff = textout end) 
				end
				imgui.NextColumn()
			else
				ng_imgui_in_button(ename.."addfuncoff", "+", 15, 20, 
					function () nelement.foff = "function (a) return xx end" end) imgui.NextColumn()
			end

-- tgl()	| [                                           ]
-- function triggering actions to set a switch which is not simple 1/0 or commands
			ng_imgui_out_text(color_white, "tgl()") imgui.NextColumn()
			if nelement.ftgl ~= nil then
				ng_imgui_in_button(ename.."nilfunctgl", "-", 15, 20, 
					function () nelement.ftgl = nil end) imgui.SameLine()
				if nelement.ftgl ~= nil then
					ng_imgui_in_tfield(ename.."ftgl", 281, color_white, 255, 
					nelement.ftgl, function (textout) nelement.ftgl = textout end) 
				end
				imgui.NextColumn()
			else
				ng_imgui_in_button(ename.."addfunctgl", "+", 15, 20, 
					function () nelement.ftgl = "function (a) return xx end" end) imgui.NextColumn()
			end
-- set()	| [                                           ]
-- function triggering actions to set a switch which is not simple 1/0 or commands
			ng_imgui_out_text(color_white, "set()") imgui.NextColumn()
			if nelement.fset ~= nil then
				ng_imgui_in_button(ename.."nilfset", "-", 15, 20, 
					function () nelement.fset = nil end) imgui.SameLine()
				if nelement.fset ~= nil then
					ng_imgui_in_tfield(ename.."fset", 281, color_white, 255, 
					nelement.fset, function (textout) nelement.fset = textout end) 
				end
				imgui.NextColumn()
			else
				ng_imgui_in_button(ename.."addfset", "+", 15, 20, 
					function () nelement.fset = "function (a) return xx end" end) imgui.NextColumn()
			end
			
		end
			
		imgui.Separator()
		
	imgui.EndGroup()
end
-- -----------------------------------------------------------------------------------------

-- -----------------------------------------------------------------------------------------
-- render the system level of systems
-- @param tablenode nsystem system with elements to render
-- @param int ielement index of system in parent table
-- @param tablenode ncategory parent category
function systems_rnd_system(nsystem, isystem, ncategory)
			
	local newelement = { name="" }
	
	local sname = nsystem.name

	if imgui.TreeNode(sname) then
		
		-- imgui.Separator()
		
		-- only show for custom category (others are fixed)
		-- if string.lower(ncategory.name) == "custom" then
			
			if ng_getAppPrefs():get("kpcrew:syshiderem") == false or string.lower(ncategory.name) == "xtensions" then
				ng_editor_remove_system = sop_remove_buttons(sname, "SYSTEM", ncategory.systems, isystem, 375, ng_editor_remove_system)

				ng_imgui_in_button(sname.."append", "Append Element", 115, 20, 
					function () if ng_editor_system_newelement ~= "" then 
						newelement.name=ng_editor_system_newelement
						table.insert (nsystem.elements, newelement) ng_editor_system_newelement = "" end 
						newelement.acts={"on","off","tgl","set","chk"} 
					end) 
				imgui.SameLine() ng_imgui_in_tfield(sname.."name", 250, color_white, 285, 
					ng_editor_system_newelement, function (textout) ng_editor_system_newelement = textout end)
			end	
		-- end

		local function compareNames(a, b)
			return a.name < b.name
		end

		table.sort(nsystem.elements, compareNames)												
		
		-- render elements of this system
		if nsystem.elements ~= nil then
			
			for ielement,nelement in ipairs(nsystem.elements) do
				imgui.Columns(2, nsystem.name, true)					
					imgui.SetColumnWidth(0, 65)
					imgui.SetColumnWidth(1, 400)
					systems_rnd_element(nelement,ielement,nsystem,ncategory.name)				
				imgui.Columns(1)
			end

		end
	imgui.TreePop() end
end
-- -----------------------------------------------------------------------------------------

-- -----------------------------------------------------------------------------------------
-- render the system category
-- @param tablenode ncategory
function systems_rnd_category(ncategory)

	-- Append system
	local newsystem = { name="", elements={} }

	if imgui.TreeNode(ncategory.name) then

		if ng_getAppPrefs():get("kpcrew:syshiderem") == false or string.lower(ncategory.name) == "xtensions" then

			ng_imgui_in_button(ncategory.name.."append", "Append System", 190, 20, 
				function () if ng_editor_system_newsystem ~= "" then newsystem.name=ng_editor_system_newsystem
					table.insert (ncategory.systems, newsystem) ng_editor_system_newsystem = "" end end) 
			imgui.SameLine() ng_imgui_in_tfield(ncategory.name.."name", 200, color_white, 270, 
				ng_editor_system_newsystem, function (textout) ng_editor_system_newsystem = textout end)
				
		end

		local function compareNames(a, b)
			return a.name < b.name
		end

		table.sort(ncategory.systems, compareNames)
		for isystems,nsystems in ipairs(ncategory.systems) do
			systems_rnd_system(nsystems,isystems,ncategory)
		end
		
	imgui.TreePop() end
end
-- -----------------------------------------------------------------------------------------
		
-- -----------------------------------------------------------------------------------------
-- draw the systems editor
function render_systems_editor()
	if ng_editor_system_json ~= nil then
		
		imgui.SetNextItemOpen(true)
		
		local function compareNames(a, b)
			return a.name < b.name
		end
		table.sort(ng_editor_system_json.addonsystems.categories, compareNames)

		if imgui.TreeNode(ng_editor_system_json.title) then
			for nidx,ncategory in pairs(ng_editor_system_json.addonsystems.categories) do
				systems_rnd_category(ncategory)
			end
		imgui.TreePop() end
		
	end
end
-- -----------------------------------------------------------------------------------------

-- -----------------------------------------------------------------------------------------
function render_edit_tab_sys()

	imgui.BeginChild("#tabeditsys")

		ng_imgui_out_text(color_yellow," =================== AIRCRAFT SYSTEMS EDITOR ===================")
	
		-- ICAO for systems
		ng_imgui_in_tfield("Systems for", 40, color_white, 10, ng_editor_system_icao, 
			function (textout) ng_editor_system_icao = string.upper(textout) end)

		-- load and save button to save after changes or load again
		imgui.SameLine()
		ng_imgui_in_button("loadsys", "LOAD", 43, 20, 
			function () 
				systems_load()
				ng_editor_system_title = ng_editor_system_json.title
			end)

		imgui.SameLine()
		ng_imgui_in_button("savesys","SAVE", 43, 20,
			function () systems_save() end)
		
		imgui.SameLine()
		ng_imgui_in_button("addsys","ADD", 43, 20,
			function () systems_add(ng_editor_system_icao) end)

		imgui.SameLine()
		ng_imgui_in_button("applysys","APPLY", 43, 20,
			function () systems_apply() end)

		imgui.SameLine()
		ng_imgui_out_text(color_red,ng_editor_system_error)
		
		ng_imgui_in_button("setsysname","SET", 43, 20,
		function () ng_editor_system_json.title = ng_editor_system_title end)
		imgui.SameLine() 
		ng_imgui_in_tfield("sysedittitle", 250, color_white, 100, 
			ng_editor_system_title, function (textout) ng_editor_system_title = textout end)

		imgui.Separator()

		imgui.BeginChild("#systemrender")
			imgui.SetNextItemOpen(true)
			render_systems_editor()
		imgui.EndChild()
		
	imgui.EndChild()
end