--[[
	*** KPCREWNG 0.1 
	Rewrite of kpcrew for the next level, XP12 only
	Kosta Prokopiu, 2026
--]]

-- ====== Global variables =======
kc_VERSION = "NG-dev V0.1"
kc_acf_icao = "DFLT" -- ICAO code to control what aircraft to load

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

-- Flags and definitions for development outside XP12 
FLYWITHLUA = false -- if true it runs in XP12, false dev env based on love lua
DEBUGMODE = true -- if true adds debugging code 

if FLYWITHLUA == false then
	imgui =	require "cimgui" -- imgui implementation needed outside XP12
	require "teststubs" -- all functionality of XP12 & FWL outside the sim
end

kc_simversion = get("sim/version/xplane_internal_version") -- XP version

require "kpcrew.acft_select"
require "kpcrew.genutils"
require "kpcrew.Addon.SOP.FlightPhases"
require "kpcrew.Addon.SOP.FlowItemRole"

logMsg ( "FWL: ** Starting KPCrew version " .. kc_VERSION .. " on XP " .. kc_simversion .. " **" )

-- ====== Select the addon modules based on ICAO code
kc_acf_icao = kc_get_matching_icao_code()
logMsg("ICAO: "..kc_acf_icao)

-- Aircraft Specific SOP/Checklist/Procedure Definitions
kcPreferenceSet 		= require("kpcrew.preferences.PreferenceSet")
kcPreferenceGroup 		= require("kpcrew.preferences.PreferenceGroup")
kcPreference 			= require("kpcrew.preferences.Preference")
kc_global_procvars 		= kcPreferenceGroup:new("procvars","Procedure Variables")
kcLoadedPrefs 			= require("kpcrew.preferences.defaultPrefs")
kcLoadedBrief			= require("kpcrew.briefings.defaultBriefings")
kcLoadedVars 			= require("kpcrew.preferences.backgroundVars")

if kc_file_exists(SCRIPT_DIRECTORY .. "../Modules/kpcrew_prefs/" .. kc_acf_icao .. ".preferences") then
	dbgMsg(SCRIPT_DIRECTORY .. "../Modules/kpcrew_prefs/" .. kc_acf_icao .. ".preferences")
	getActivePrefs():load()
end

if kc_file_exists(SCRIPT_DIRECTORY .. "../Modules/kpcrew_prefs/" .. kc_acf_icao .. ".preferences") then
	dbgMsg(SCRIPT_DIRECTORY .. "../Modules/kpcrew_prefs/" .. kc_acf_icao .. ".preferences")
	getActivePrefs():load()
end

--kcLoadedSOP 			= require("kpcrew.sops.SOP_" .. kc_acf_icao)
--kcLoadedVars 			= require("kpcrew.preferences.backgroundVars")

-- build new object structure
local Addon = require("kpcrew.Addon.Addon")
local SOP = require("kpcrew.Addon.SOP.SOP")
local Flow = require("kpcrew.Addon.SOP.Flow")
local FlowItem = require("kpcrew.Addon.SOP.FlowItem")

activeAddon = Addon:new("DFLT","Default Aircraft")
function ng_get_active_addon() return activeAddon end

local activeSOP = SOP:new("SOP Default Aircraft")
activeAddon:setSop(activeSOP)
function ng_get_active_sop() return activeSOP end

local flow1 = Flow:new("PRELIMINARY COCKPIT PREPARATION",ng_phase_flight_planning,Flow.classProcedureFlow)
flow1:appendFlowItem(FlowItem:new("ENG 1,2 MASTERS","OFF",ng_firole_PM))
flow1:appendFlowItem(FlowItem:new("ENG MODE SELECTOR","OFF",ng_firole_PM))
flow1:appendFlowItem(FlowItem:new("WEATHER RADAR","OFF",ng_firole_PM))
flow1:appendFlowItem(FlowItem:new("LANDING GEAR LEVER","DOWN",ng_firole_PM))
flow1:appendFlowItem(FlowItem:new("WIPER SELECTORS","BOTH OFF",ng_firole_PM))
flow1:appendFlowItem(FlowItem:new("BATTERY","CHECKED/AUTO",ng_firole_PM))
flow1:appendFlowItem(FlowItem:new("EXT PWR","AS REQD",ng_firole_PM))
flow1:appendFlowItem(FlowItem:new("APU FIRE","CHECK/TEST",ng_firole_PM))
flow1:appendFlowItem(FlowItem:new("APU","START",ng_firole_PM))
flow1:appendFlowItem(FlowItem:new("When APU is avail","",ng_firole_PM))
flow1:appendFlowItem(FlowItem:new("EXT PWR","OFF",ng_firole_PM))
flow1:appendFlowItem(FlowItem:new("AIR COND PANEL","SET",ng_firole_PM))
--flow1:appendFlowItem(FlowItem:new("COCKPIT LIGHTS","AS REQUIRED",ng_firole_BOTH))

activeSOP:appendFlow(flow1)

print(ng_get_flight_phase_title(ng_phase_before_start))


-- ============================================================================================
if FLYWITHLUA then

	-- initializing steps when in XP12

else
	local ts = 0
	-- === Love runtime stuff outside XP12
	love.load = function()
	
	    imgui.Init()
	    draw = require "kpcrew.kpcrew_draw"
		
	end
	
	love.draw = function()
	    draw()
	    --  code to render imgui
	    imgui.Render()
	    imgui.RenderDrawLists()
	end
	
	love.update = function(dt)
	    imgui.Update(dt)
	    imgui.NewFrame()
		
		ts = ts + dt
		if ts > 1.0 then
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