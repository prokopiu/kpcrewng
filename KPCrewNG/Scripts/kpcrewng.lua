--[[
	*** KPCREWNG 0.1 
	Rewrite of kpcrew for the next level, XP12 only
	Kosta Prokopiu, 2026
--]]

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
ng_version 		= "NG-dev V0.1"
ng_acf_icao 	= "DFLT" -- ICAO code to control what aircraft to load

-- ======== UI related global settings
kb_wnd_width		= 950
kb_wnd_height		= 950
kb_wnd_pos_left		= 20
kb_wnd_pos_right	= 40
ng_sop_wnd 			= nil
ng_brief_wnd 		= nil
ng_ctrl_wnd 		= nil
ng_scrn_width 		= get("sim/graphics/view/window_width") -- get screen width from X-Plane
ng_scrn_height 		= get("sim/graphics/view/window_height")-- get screen height from X-Plane
ng_simversion 		= get("sim/version/xplane_internal_version") -- XP version

-- ======== Flags and definitions for development outside XP12 
FLYWITHLUA 			= true 	-- if true it runs in XP12, false dev env based on löve lua
DEBUGMODE 			= false -- if true adds debugging output (dprint) 

-- ======== only needed for dev env Löve
if FLYWITHLUA == false then
	imgui =	require "cimgui" -- imgui implementation needed outside XP12
	require "teststubs" 	 -- all functionality of XP12 & FWL outside the sim
end

logMsg ( "FWL: ** Starting KPCrew version " .. ng_version .. " on XP " .. ng_simversion .. " **" )

-- ====== Select the addon modules based on ICAO code
ng_acf_icao = ng_acft_select(1)
logMsg("ICAO: ".. ng_acf_icao)

-- ====== Aircraft Addon Specific SOP/Checklist/Procedure Definitions & Preferences
local PreferenceSet = require("kpcrew.Addon.Preferences.PreferenceSet")

if ng_file_exists(SCRIPT_DIRECTORY.."kpcres.addons"..ng_acf_icao.."_preferences.lua") then 
	require ("kpcrew.addons."..ng_acf_icao.."_preferences")
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
local activeSOP = SOP:new("SOP Default Aircraft",SCRIPT_DIRECTORY.."../Modules/kpcrew/addons/"..ng_acf_icao.."_sop.json")
activeSOP:load()
function ng_get_active_sop() return activeSOP end -- global function to be used everywhere

-- ====== Get aircraft specific preferences - first load DFLT preference set then overwrite with specific - then load prefs
local acfPreferences = ng_getAcfPrefs()
acfPreferences:setName(ng_acf_icao) -- set aircraft specific icao as name
-- check if icao preferences file exists, if not create new
acfPreferences:setFilePath(SCRIPT_DIRECTORY .."../Modules/kpcrew_prefs/"..ng_acf_icao..".preferences")
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
local acfSystems = Systems:new("Aircraft Systems",SCRIPT_DIRECTORY.."../Modules/kpcrew/addons/"..ng_acf_icao.."_systems.json")
acfSystems:load()
ng_init_acf_prefs() -- initialize and make custom settings if available
function ng_get_active_sys() return acfSystems end -- global function to be used everywhere

-- ====== Initialize Addon
local activeAddon = Addon:new(ng_acf_icao,"Addon")
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

	require "kpcrew.kpcrew_draw" -- include all imgui drawing modules

	-- ======== Render the briefing window
	function ng_brief_builder(wnd, x, y)
		ng_draw_main_window()
	end

	-- ======== Render the SOP window
	function ng_sop_builder(wnd, x, y)
		ng_draw_sop_window()
	end

	-- ======== Render the control bar
	function ng_ctrl_builder(wnd, x, y)
		ng_draw_ctrl_window()
	end
	
	-- ======== Initialize SOP Window (position and size)
	function ng_init_sop_window()
		ng_sop_wnd = float_wnd_create(490, ng_get_active_sop():getNumberFlows()*24, 1, true)
		float_wnd_set_position(ng_sop_wnd, ng_scrn_width-497, (60/17)*ng_get_active_sop():getNumberFlows())
		float_wnd_set_title(ng_sop_wnd, activeSOP:getTitle())
		float_wnd_set_imgui_builder(ng_sop_wnd, "ng_sop_builder")
		float_wnd_set_onclose(ng_sop_wnd, "ng_hide_sop_wnd")
	end

	-- ======== Initialize control bar Window (position and size)
	function ng_init_ctrl_window()
		ng_ctrl_wnd = float_wnd_create(615, 37, 2, true)
		float_wnd_set_position(ng_ctrl_wnd, ng_scrn_width-615, 0) 
		float_wnd_set_title(ng_ctrl_wnd, "Control")
		float_wnd_set_imgui_builder(ng_ctrl_wnd, "ng_ctrl_builder")
		float_wnd_set_onclose(ng_ctrl_wnd, "ng_hide_ctrl_wnd")
	end
		
	-- ======== Initialize Briefing Window (position and size)	
	function ng_init_brief_window()
		ng_brief_wnd = float_wnd_create(kb_wnd_width, kb_wnd_height, 1, true)
		float_wnd_set_position(ng_brief_wnd, kb_wnd_pos_left, kb_wnd_pos_right) 
		float_wnd_set_title(ng_brief_wnd, "KPCrewNG " .. ng_version)
		float_wnd_set_imgui_builder(ng_brief_wnd, "ng_brief_builder")
		float_wnd_set_onclose(ng_brief_wnd, "ng_hide_brief_wnd")
	end

	do_often("ng_flow_executor()") -- executes on flows
	
	-- ======== commands to tie to buttons and keys
	create_command("kp/crewng/master", 		"KPCrewNG Masterbutton",		"ng_master_action()","","")
	create_command("kp/crewng/next", 		"KPCrewNG Next button",			"ng_next_flow()","","")
	create_command("kp/crewng/prev", 		"KPCrewNG Prev button",			"ng_prev_flow()","","")
	create_command("kp/crewng/sopwindow", 	"KPCrewNG Toggle SOP Window",	"if ng_sop_wnd == nil then ng_init_sop_window() else ng_hide_sop_wnd() end","","")
	create_command("kp/crewng/flowwindow", 	"KPCrewNG Toggle Brief Window",	"if ng_brief_wnd == nil then ng_init_brief_window() else ng_hide_brief_wnd() end","","")
	create_command("kp/crewng/openmaster", 	"KPCrewNG Open Control Window",	"if ng_ctrl_wnd == nil then ng_init_ctrl_window() else ng_hide_ctrl_wnd() end","","")
	
else

-- ============================================================================================
-- Running in Linux Löve runtime outside xp12
-- ============================================================================================

	local ts = 0
	-- === Love runtime stuff outside XP12
	love.load = function()
	    imgui.Init()
	end
	
	love.draw = function()
		require "kpcrew.kpcrew_draw"
		ng_draw_main_window()
		ng_draw_ctrl_window()
		ng_draw_sop_window()

		--  code to render imgui
	    imgui.Render()
	    imgui.RenderDrawLists()
	end
	
	love.update = function(dt)
	    imgui.Update(dt)
	    imgui.NewFrame()
		
		ts = ts + dt
		if ts > 1.0 then
			ng_flow_executor()
			ts= 0
		end
	end
	
	love.mousemoved = function(x, y, ...)
	    imgui.MouseMoved(x, y)
	    if not imgui.GetWantCaptureMouse() then
	        -- your code here
	    end
	end
	
	love.mousepressed = function(x, y, button, ...)
	    imgui.MousePressed(button)
	    if not imgui.GetWantCaptureMouse() then
	        -- your code here 
	    end
	end
	
	love.mousereleased = function(x, y, button, ...)
	    imgui.MouseReleased(button)
	    if not imgui.GetWantCaptureMouse() then
	        -- your code here 
	    end
	end
	
	love.wheelmoved = function(x, y)
	    imgui.WheelMoved(x, y)
	    if not imgui.GetWantCaptureMouse() then
	        -- your code here 
	    end
	end
	
	love.keypressed = function(key, ...)
	    imgui.KeyPressed(key)
	    if not imgui.GetWantCaptureKeyboard() then
	        -- your code here 
	    end
	end
	
	love.keyreleased = function(key, ...)
	    imgui.KeyReleased(key)
	    if not imgui.GetWantCaptureKeyboard() then
	        -- your code here 
	    end
	end
	
	love.textinput = function(t)
	    imgui.TextInput(t)
	    if not imgui.GetWantCaptureKeyboard() then
	        -- your code here 
	    end
	end
	
	love.quit = function()
	    return imgui.Shutdown()
	end
	
	love.resize = function(w, h)
	    local io = imgui.GetIO()
	    io.DisplaySize.x, io.DisplaySize.y = w, h
	end
-- ============================================================================================

end