--[[
	*** KPCREWNG 0.1 
	Rewrite of kpcrew for the next level, XP12 only
	Kosta Prokopiu, 2026
--]]

require "kpcrew.Addon.SOP.Executor"

-- ====== Global variables =======
kc_VERSION = "NG-dev V0.1"
ng_acf_icao = "DFLT" -- ICAO code to control what aircraft to load

-- UI related global settings
kb_font_scale = 1.0
kb_wnd_width =  950 * kb_font_scale
kb_wnd_height = 950 * kb_font_scale


-- Modules related global settings
origmetar = ""
destmetar = ""
altnmetar = ""
origtranslvl = 0
desttransalt = 0
altntransalt = 0
wunit = "KG"

ng_sop_wnd = nil
ng_brief_wnd = nil
ng_ctrl_wnd = nil

-- Flags and definitions for development outside XP12 
FLYWITHLUA = true -- if true it runs in XP12, false dev env based on love lua
DEBUGMODE = true -- if true adds debugging code 

if FLYWITHLUA == false then
	imgui =	require "cimgui" -- imgui implementation needed outside XP12
	require "teststubs" 	 -- all functionality of XP12 & FWL outside the sim
end

if DEBUGMODE == false then
	function print(text)
	end
end

-- get screen width from X-Plane
ng_scrn_width = get("sim/graphics/view/window_width")
ng_scrn_height = get("sim/graphics/view/window_height")
kc_simversion = get("sim/version/xplane_internal_version") -- XP version

require "kpcrew.acft_select"
require "kpcrew.nggenutils"
require "kpcrew.Addon.SOP.FlightPhases"
require "kpcrew.Addon.SOP.FlowItemRole"
local http = require("socket.http")

logMsg ( "FWL: ** Starting KPCrew version " .. kc_VERSION .. " on XP " .. kc_simversion .. " **" )

-- ====== Select the addon modules based on ICAO code
ng_acf_icao = ng_acft_select()
logMsg("ICAO: "..ng_acf_icao)

-- Aircraft Specific SOP/Checklist/Procedure Definitions & Preferences
local PreferenceSet = require("kpcrew.Addon.Preferences.PreferenceSet")
require "kpcrew.Addon.Preferences.application_preferences"
require "kpcrew.Addon.Preferences.background_vars"
require ("kpcrew.addons."..ng_acf_icao.."_preferences")
require "kpcrew.Addon.Briefing.briefing_preferences"

-- application preferences
local appPreferences = ng_getAppPrefs()
if ng_file_exists(appPreferences:getFilePath()) == false then appPreferences:save() end
appPreferences:load()

-- Backgrounf Vars

local bckVars = ng_getBckVars()

-- Build new object structure
local Addon = require("kpcrew.Addon.Addon")
local SOP = require("kpcrew.Addon.SOP.SOP")
local Systems = require("kpcrew.Addon.Systems.AddonSystems")

-- Initialize Addon
local activeAddon = Addon:new(ng_acf_icao,"Addon")
function ng_get_active_addon() return activeAddon end

-- Initialize addon specific SOP
local activeSOP = SOP:new("SOP Default Aircraft",SCRIPT_DIRECTORY.."../Modules/kpcrew/addons/"..ng_acf_icao.."_sop.json")
activeAddon:setSop(activeSOP)
activeSOP:load()
function ng_get_active_sop() return activeSOP end

-- Get aircraft specific preferences
local acfPreferences = ng_getAcfPrefs()
if ng_file_exists(acfPreferences:getFilePath()) == false then acfPreferences:save() end
activeAddon:setPreferences(acfPreferences)
acfPreferences:load()

-- Get Briefing
local briefPreferences = ng_getBriefPrefs()
if ng_file_exists(briefPreferences:getFilePath()) == false then briefPreferences:save() end
activeAddon:setBriefing(briefPreferences)
briefPreferences:load()
ng_load_simbrief()

-- Get Aicraft Systems
local acfSystems = Systems:new("Aircraft Systems",SCRIPT_DIRECTORY.."../Modules/kpcrew/addons/"..ng_acf_icao.."_systems.json")
acfSystems:load()
ng_init_acf_prefs()
activeAddon:setSystems(acfSystems)
function ng_get_active_systems() return acfSystems end


-- ============================================================================================
if FLYWITHLUA then

	-- Hide the briefing window
	function ng_hide_brief_wnd(wnd)
		if ng_brief_wnd ~= nil then 
			float_wnd_destroy(ng_brief_wnd)
			ng_brief_wnd = nil
		end
	end

	function ng_hide_sop_wnd(wnd)
		if ng_sop_wnd ~= nil then 
			float_wnd_destroy(ng_sop_wnd)
			ng_sop_wnd = nil
		end
	end

	function ng_hide_ctrl_wnd(wnd)
		if ng_ctrl_wnd ~= nil then 
			float_wnd_destroy(ng_ctrl_wnd)
			ng_ctrl_wnd = nil
		end
	end

	require "kpcrew.kpcrew_draw"

	function ng_brief_builder(wnd, x, y)
		ng_draw_main_window()
	end

	function ng_sop_builder(wnd, x, y)
		ng_draw_sop_window()
	end

	function ng_ctrl_builder(wnd, x, y)
		ng_draw_ctrl_window()
	end
	
	function ng_init_sop_window()
	print(ng_get_active_sop():getNumberFlows())
		ng_sop_wnd = float_wnd_create(490, ng_get_active_sop():getNumberFlows()*24, 1, true)
		float_wnd_set_position(ng_sop_wnd, ng_scrn_width-497, (60/17)*ng_get_active_sop():getNumberFlows())
		float_wnd_set_title(ng_sop_wnd, activeSOP:getTitle())
		float_wnd_set_imgui_builder(ng_sop_wnd, "ng_sop_builder")
		float_wnd_set_onclose(ng_sop_wnd, "ng_hide_sop_wnd")
	end

	function ng_init_ctrl_window()
		ng_ctrl_wnd = float_wnd_create(615, 37, 2, true)
		float_wnd_set_position(ng_ctrl_wnd, ng_scrn_width-615, 0) 
		float_wnd_set_title(ng_ctrl_wnd, "Control")
		float_wnd_set_imgui_builder(ng_ctrl_wnd, "ng_ctrl_builder")
		float_wnd_set_onclose(ng_ctrl_wnd, "ng_hide_ctrl_wnd")
	end
	
    local wndWidth =  960
    local wndHeight = 950
    fontScale1 = 1
    angle=1
    fontScale = 1
	
	function ng_init_brief_window()
		ng_brief_wnd = float_wnd_create(wndWidth, wndHeight, 1, true)
		float_wnd_set_position(ng_brief_wnd, 20, 40) 
		float_wnd_set_title(ng_brief_wnd, "KPCrewNG " .. kc_VERSION)
		float_wnd_set_imgui_builder(ng_brief_wnd, "ng_brief_builder")
		float_wnd_set_onclose(ng_brief_wnd, "ng_hide_brief_wnd")
	end

	do_often("ng_flow_executor()")
	create_command("kp/crewng/master", "KPCrewNG Masterbutton","ng_master_action()","","")
	create_command("kp/crewng/next", "KPCrewNG Next button","ng_next_flow()","","")
	create_command("kp/crewng/prev", "KPCrewNG Prev button","ng_prev_flow()","","")
	create_command("kp/crewng/sopwindow", "KPCrewNG Toggle SOP Window","if ng_sop_wnd == nil then ng_init_sop_window() else ng_hide_sop_wnd() end","","")
	create_command("kp/crewng/flowwindow", "KPCrewNG Toggle Brief Window","if ng_brief_wnd == nil then ng_init_brief_window() else ng_hide_brief_wnd() end","","")
	create_command("kp/crewng/openmaster", "KPCrewNG Open Control Window","if ng_ctrl_wnd == nil then ng_init_ctrl_window() else ng_hide_ctrl_wnd() end","","")


else
	local ts = 0
	-- === Love runtime stuff outside XP12
	love.load = function()
	
	    imgui.Init()
--	    draw = require "kpcrew.kpcrew_draw"
		
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
--			print("1 second" .. ts)
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
end