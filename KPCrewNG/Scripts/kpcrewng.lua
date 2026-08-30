--[[
	*** KPCREWNG 0.1 
	Rewrite of kpcrew for the next level, XP12 only
	Kosta Prokopiu, 2026
--]]

-- ======== Flags and definitions for development outside XP12 
FLYWITHLUA 			= true -- if true it runs in XP12, false dev env based on löve lua
DEBUGMODE 			= false -- if true adds debugging output (dprint) 

-- ======== only needed for dev env Löve
if FLYWITHLUA == false then
	imgui =	require "cimgui" -- imgui implementation needed outside XP12
	require "teststubs" 	 -- all functionality of XP12 & FWL outside the sim
end

require "kpcrew.Addon.SOP.Executor" -- executing the flows
require "kpcrew.acft_select" -- get the running aircraft addon icao
require "kpcrew.nggenutils" -- many utilities needed
require "kpcrew.Addon.SOP.FlightPhases" -- enumerator for flightphases
require "kpcrew.Addon.SOP.FlowItemRole" -- enumerator for pilot roles
require "kpcrew.Addon.Preferences.application_preferences" -- application settings
require "kpcrew.Addon.Preferences.background_vars" -- background variables
require ("kpcrew.addons.DFLT_preferences") -- definition of aircraft settings
require "kpcrew.Addon.Briefing.briefing_preferences" -- definition of briefing fields

-- local http = require("socket.http")

-- ====== Global variables =======
ng_version 		= "NG-dev V0.1-R03"
ng_acf_sopicao 	= "DFLT" -- ICAO code to control what aircraft to loadng_acf_sopicao 	= "DFLT" -- ICAO code to control what aircraft to load
ng_acf_sysicao  = "DFLT"
ng_acf_prficao  = "DFLT"

-- ======== UI related global settings
-- kb_wnd_width		= 960
-- kb_wnd_height		= 950
-- kb_wnd_pos_left		= 20
-- kb_wnd_pos_right	= 40

ng_ctrl_wnd 		= nil
ng_ctrl_show 		= 0
ng_ctrl_hide 		= 0
ng_ctrl_action 		= 1

ng_sop_wnd 			= nil
ng_sop_show 		= 0
ng_sop_hide 		= 0
ng_sop_action 		= 0

ng_brief_wnd 		= nil
ng_brief_show 		= 0
ng_brief_hide 		= 0
ng_brief_action 	= 0

ng_pref_wnd			= nil
ng_pref_show 		= 0
ng_pref_hide 		= 0
ng_pref_action 		= 0

ng_edit_wnd			= nil
ng_edit_show 		= 0
ng_edit_hide 		= 0
ng_edit_action 		= 0

ng_scrn_width 		= get("sim/graphics/view/window_width") -- get screen width from X-Plane
ng_scrn_height 		= get("sim/graphics/view/window_height")-- get screen height from X-Plane
ng_simversion 		= get("sim/version/xplane_internal_version") -- XP version

logMsg ( "FWL: ** Starting KPCrewNG version " .. ng_version .. " on XP " .. ng_simversion .. " **" )

-- ====== Select the addon modules based on ICAO code
local Assignments	= require("kpcrew.Addon.Assignments.AircraftAssignments")
local activeAssignments = Assignments:new("Aircraft Assignments",SCRIPT_DIRECTORY.."../Modules/kpcrew_prefs/acftselect.json")
activeAssignments:load()
ng_acf_sopicao = activeAssignments:findAssignment(PLANE_ICAO,PLANE_TAILNUMBER):getElementNode().sopicao
ng_acf_prficao = activeAssignments:findAssignment(PLANE_ICAO,PLANE_TAILNUMBER):getElementNode().preficao
ng_acf_sysicao = activeAssignments:findAssignment(PLANE_ICAO,PLANE_TAILNUMBER):getElementNode().sysicao
logMsg("ICAO: ".. ng_acf_sopicao)

-- ====== Aircraft Addon Specific SOP/Checklist/Procedure Definitions & Preferences
local PreferenceSet = require("kpcrew.Addon.Preferences.PreferenceSet")
if ng_file_exists(SCRIPT_DIRECTORY.."kpcres.addons"..ng_acf_prficao.."_preferences.lua") then 
	require ("kpcrew.addons."..ng_acf_prficao.."_preferences")
end

-- ====== Initialize application preferences
local appPreferences = ng_getAppPrefs()
-- if no preferenes file found then write default
if ng_file_exists(appPreferences:getFilePath()) == false then appPreferences:save() end
-- load the preferences from kpcrew_prefs folder
appPreferences:load()

-- Background Vars
-- local bckVars = ng_getBckVars()

-- ====== Build object structure (Addon deprecated, will be removed eventually)
local Addon 	= require("kpcrew.Addon.Addon")
local SOP 		= require("kpcrew.Addon.SOP.SOP")
local Systems 	= require("kpcrew.Addon.Systems.AddonSystems")

-- ====== Initialize addon specific SOP
local activeSOP = SOP:new("SOP Default Aircraft",SCRIPT_DIRECTORY.."../Modules/kpcrew/addons/"..ng_acf_sopicao.."_sop.json")
activeSOP:load()
function ng_get_active_sop() return activeSOP end -- global function to be used everywhere
function ng_set_active_sop(newSOP) activeSOP = newSOP end -- global function to replace SOP

-- ====== Get aircraft specific preferences - first load DFLT preference set then overwrite with specific - then load prefs
local acfPreferences = ng_getAcfPrefs()
acfPreferences:setName(ng_acf_prficao) -- set aircraft specific icao as name
-- check if icao preferences file exists, if not create new
acfPreferences:setFilePath(SCRIPT_DIRECTORY .."../Modules/kpcrew_prefs/"..ng_acf_prficao..".preferences")
if ng_file_exists(acfPreferences:getFilePath()) == false then acfPreferences:save() end
acfPreferences:load()
acfPreferences:setTitle(acfPreferences:get("addon:aircraftname")) -- set overloaded aircraft name
function ng_get_active_prefs() return acfPreferences end -- global function to be used everywhere

-- ====== Get Briefing data saved in last session
local briefPreferences = ng_getBriefPrefs()
if ng_file_exists(briefPreferences:getFilePath()) == false then briefPreferences:save() end
briefPreferences:load() -- first load from file
ng_load_simbrief() -- if exists load last simbrief xml download and overwrite
function ng_get_active_brief() return briefPreferences end -- global function to be used everywhere

-- ====== Get Aicraft Systems (all required switches and other elements)
local acfSystems = Systems:new("Aircraft Systems",SCRIPT_DIRECTORY.."../Modules/kpcrew/addons/"..ng_acf_sysicao.."_systems.json")
acfSystems:load()
ng_init_acf_prefs() -- initialize and make custom settings if available
function ng_get_active_sys() return acfSystems end -- global function to be used everywhere
function ng_set_active_sys(newsystems) acfSystems = newsystems end

-- ====== Initialize Addon
local activeAddon = Addon:new(ng_acf_sopicao,"Addon")
activeAddon:setSop(activeSOP) -- deprecated
activeAddon:setPreferences(acfPreferences) -- deprecated - will be replaced eventually
activeAddon:setBriefing(briefPreferences) -- deprecated
activeAddon:setSystems(acfSystems) -- deprecated
function ng_get_active_addon() return activeAddon end -- global function to be used everywhere

-- ============================================================================================
-- Running in XP12 with FLYWITHLUA
-- ============================================================================================

if FLYWITHLUA then

	-- ======== Hide the briefing window
	function ng_hide_brief_wnd(wnd)
		if ng_brief_wnd ~= nil then 
			float_wnd_destroy(ng_brief_wnd)
			ng_brief_wnd = nil
		end
	end

	-- ======== Hide the SOP window
	function ng_hide_sop_wnd(wnd)
		if ng_sop_wnd ~= nil then 
			float_wnd_destroy(ng_sop_wnd)
			ng_sop_wnd = nil
		end
	end

	-- ======== Hide the control bar at the bottom
	function ng_hide_ctrl_wnd(wnd)
		if ng_ctrl_wnd ~= nil then 
			float_wnd_destroy(ng_ctrl_wnd)
			ng_ctrl_wnd = nil
		end
	end

	-- ======== Hide the Settings window
	function ng_hide_pref_wnd(wnd)
		if ng_pref_wnd ~= nil then 
			float_wnd_destroy(ng_pref_wnd)
			ng_pref_wnd = nil
		end
	end

	-- ======== Hide the editor window
	function ng_hide_edit_wnd(wnd)
		if ng_edit_wnd ~= nil then 
			float_wnd_destroy(ng_edit_wnd)
			ng_edit_wnd = nil
		end
	end

	require "kpcrew.kpcrew_draw" -- include all imgui drawing modules

	-- ======== Render the briefing window
	function ng_brief_builder(wnd, x, y)
		ng_draw_brief_window()
	end

	-- ======== Render the SOP window
	function ng_sop_builder(wnd, x, y)
		ng_draw_sop_window()
	end

	-- ======== Render the control bar
	function ng_ctrl_builder(wnd, x, y)
		ng_draw_ctrl_window()
	end

	-- ======== Render the PREF window
	function ng_pref_builder(wnd, x, y)
		ng_draw_pref_window()
	end
	
	-- ======== Render the EDIT window
	function ng_edit_builder(wnd, x, y)
		ng_draw_edit_window()
	end
	
	-- ======== Initialize SOP Window (position and size)
	function ng_init_sop_window()
		ng_sop_wnd = float_wnd_create(ng_imgui_initial_sop_width, ng_get_active_sop():getNumberFlows()*ng_imgui_initial_sop_height, 1, true)
		float_wnd_set_position(ng_sop_wnd, ng_scrn_width-ng_imgui_initial_sop_width-10, ng_get_active_sop():getNumberFlows()*ng_imgui_initial_sop_height)
		float_wnd_set_title(ng_sop_wnd, activeSOP:getTitle())
		float_wnd_set_imgui_builder(ng_sop_wnd, "ng_sop_builder")
		-- float_wnd_set_onclose(ng_sop_wnd, "ng_hide_sop_wnd")
	end

	-- ======== Initialize control bar Window (position and size)
	function ng_init_ctrl_window()
		ng_ctrl_wnd = float_wnd_create(ng_imgui_initial_ctrl_width, ng_imgui_initial_ctrl_height, 3, true)
		float_wnd_set_position(ng_ctrl_wnd, ng_scrn_width-ng_imgui_initial_ctrl_width, 0) 
		float_wnd_set_title(ng_ctrl_wnd, "Control")
		float_wnd_set_imgui_builder(ng_ctrl_wnd, "ng_ctrl_builder")
		-- float_wnd_set_onclose(ng_ctrl_wnd, "ng_hide_ctrl_wnd")
	end
		
	-- ======== Initialize Briefing Window (position and size)	
	function ng_init_brief_window()
		ng_brief_wnd = float_wnd_create(ng_imgui_initial_brief_width, ng_imgui_initial_brief_height, 1, true)
		float_wnd_set_position(ng_brief_wnd, ng_imgui_initial_brief_xpos, ng_imgui_initial_brief_ypos) 
		float_wnd_set_title(ng_brief_wnd, "Briefing")
		float_wnd_set_imgui_builder(ng_brief_wnd, "ng_brief_builder")
		-- float_wnd_set_onclose(ng_brief_wnd, "ng_hide_brief_wnd")
	end

	-- ======== Initialize Briefing Window (position and size)	
	function ng_init_pref_window()
		ng_pref_wnd = float_wnd_create(ng_imgui_initial_pref_width, ng_imgui_initial_pref_height, 1, true)
		float_wnd_set_position(ng_pref_wnd, ng_imgui_initial_pref_xpos, ng_imgui_initial_pref_ypos) 
		float_wnd_set_title(ng_pref_wnd, "Preferences")
		float_wnd_set_imgui_builder(ng_pref_wnd, "ng_pref_builder")
		-- float_wnd_set_onclose(ng_brief_wnd, "ng_hide_pref_wnd")
	end

	-- ======== Initialize Editor Window (position and size)	
	function ng_init_edit_window()
		ng_edit_wnd = float_wnd_create(ng_imgui_initial_edit_width, ng_imgui_initial_edit_height, 1, true)
		float_wnd_set_position(ng_edit_wnd, ng_imgui_initial_edit_xpos, ng_imgui_initial_edit_ypos) 
		float_wnd_set_title(ng_edit_wnd, "SOP Editor")
		float_wnd_set_imgui_builder(ng_edit_wnd, "ng_edit_builder")
		-- float_wnd_set_onclose(ng_edit_wnd, "ng_hide_edit_wnd")
	end

	-- ======= Toggle briefing window
	function ng_toggle_brief_window()
		ng_brief_show_window = not ng_brief_show_window
		if ng_brief_show_window then
			if ng_brief_show == 0 then
				ng_init_brief_window()
				ng_brief_show = 1
				ng_brief_hide = 0
			end
		else
			if ng_brief_hide == 0 then
				ng_hide_brief_wnd()
				ng_brief_hide = 1
				ng_brief_show = 0
			end
		end
	end	
	
	-- ======= Toggle SOP window
	function ng_toggle_sop_window()
		ng_sop_show_window = not ng_sop_show_window
		if ng_sop_show_window then
			if ng_sop_show == 0 then
				ng_init_sop_window()
				ng_sop_show = 1
				ng_sop_hide = 0
			end
		else
			if ng_sop_hide == 0 then
				ng_hide_sop_wnd()
				ng_sop_hide = 1
				ng_sop_show = 0
			end
		end
	end	

	-- ======= Toggle PREF window
	function ng_toggle_pref_window()
		ng_pref_show_window = not ng_pref_show_window
		if ng_pref_show_window then
			if ng_pref_show == 0 then
				ng_init_pref_window()
				ng_pref_show = 1
				ng_pref_hide = 0
			end
		else
			if ng_pref_hide == 0 then
				ng_hide_pref_wnd()
				ng_pref_hide = 1
				ng_pref_show = 0
			end
		end
	end	
	
	-- ======= Toggle EDIT window
	function ng_toggle_edit_window()
		ng_edit_show_window = not ng_edit_show_window
		if ng_edit_show_window then
			if ng_edit_show == 0 then
				ng_init_edit_window()
				ng_edit_show = 1
				ng_edit_hide = 0
			end
		else
			if ng_edit_hide == 0 then
				ng_hide_edit_wnd()
				ng_edit_hide = 1
				ng_edit_show = 0
			end
		end
	end	

	-- ======= Toggle CTRL window
	function ng_toggle_ctrl_window()
		ng_ctrl_show_window = not ng_ctrl_show_window
		if ng_ctrl_show_window then
			if ng_ctrl_show == 0 then
				ng_init_ctrl_window()
				ng_ctrl_show = 1
				ng_ctrl_hide = 0
			end
		else
			if ng_ctrl_hide == 0 then
				ng_hide_ctrl_wnd()
				ng_ctrl_hide = 1
				ng_ctrl_show = 0
			end
		end
	end	

	function bckWindowOpen()
		if ng_brief_action == 1 then
			ng_brief_action = 0
			ng_toggle_brief_window()
		end
		if ng_sop_action == 1 then
			ng_sop_action = 0
			ng_toggle_sop_window()
		end
		if ng_pref_action == 1 then
			ng_pref_action = 0
			ng_toggle_pref_window()
		end
		if ng_edit_action == 1 then
			ng_edit_action = 0
			ng_toggle_edit_window()
		end
		if ng_ctrl_action == 1 then
			ng_ctrl_action = 0
			ng_toggle_ctrl_window()
		end
	end	
	
	do_every_frame("bckWindowOpen()")

	-- ===== 
	do_often("ng_flow_executor()") -- executes on flows
	
	-- ======== commands to tie to buttons and keys
	create_command("kp/crewng/master", 		"KPCrewNG Masterbutton",		"ng_master_action()","","")
	create_command("kp/crewng/next", 		"KPCrewNG Next button",			"ng_next_flow()","","")
	create_command("kp/crewng/prev", 		"KPCrewNG Prev button",			"ng_prev_flow()","","")
	create_command("kp/crewng/ctrlwindow", 	"KPCrewNG Open Control Window",	"if ng_ctrl_wnd == nil then ng_init_ctrl_window() else ng_hide_ctrl_wnd() end","","")
	create_command("kp/crewng/sopwindow", 	"KPCrewNG Toggle SOP Window",	"ng_sop_action = 1","","")
	create_command("kp/crewng/briefwindow", "KPCrewNG Toggle Brief Window",	"ng_brief_action = 1","","")
	
	add_macro("KPCrew Toggle Control Window", 	"ng_ctrl_action = 1")
	add_macro("KPCrew Toggle SOP Window", 		"ng_sop_action = 1")
	add_macro("KPCrew Toggle Preferences", 		"ng_pref_action = 1")
	add_macro("KPCrew Toggle Briefing Window", 	"ng_brief_action = 1")
	add_macro("KPCrew Toggle Editor Window", 	"ng_edit_action = 1")


else

-- ============================================================================================
-- Running in Linux Löve runtime outside xp12
-- ============================================================================================


-- ============================================================================================

end
