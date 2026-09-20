--[[
	*** KPHWNG 0.1 
	Rewrite of kphardware for the next level, XP12 only
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

-- ====== Global variables =======
local nh_version = "NG-Dev V0.1"
nh_acf_sysicao  = "DFLT"
nh_acf_prficao  = "DFLT"

logMsg ("FWL: ** Starting KPHWNG version " .. nh_version .." **")

-- ====== Select the addon modules based on ICAO code
local Assignments	= require("kpcrew.Addon.Assignments.AircraftAssignments")
local activeAssignments = Assignments:new("Aircraft Assignments",SCRIPT_DIRECTORY.."../Modules/kpcrew_prefs/acftselect.json")
activeAssignments:load()
nh_acf_prficao = activeAssignments:findAssignment(PLANE_ICAO,PLANE_TAILNUMBER):getElementNode().preficao
nh_acf_sysicao = activeAssignments:findAssignment(PLANE_ICAO,PLANE_TAILNUMBER):getElementNode().sysicao
logMsg("ICAO: ".. ng_acf_sopicao)

-- level of exposure (to save memory and ressources
-- 0 = basic (a/p, basic functions (gear, flaps etc...)
-- 1 = medium (basic + efis) 
-- 2 = full (lights etc...)

-- ====== Aircraft Addon Specific SOP/Checklist/Procedure Definitions & Preferences
local PreferenceSet = require("kpcrew.Addon.Preferences.PreferenceSet")
if ng_file_exists(SCRIPT_DIRECTORY.."kpcres.addons"..nh_acf_prficao.."_preferences.lua") then 
	require ("kpcrew.addons."..nh_acf_prficao.."_preferences")
end

-- ====== Build object structure (Addon deprecated, will be removed eventually)
local Addon 	= require("kpcrew.Addon.Addon")
local Systems 	= require("kpcrew.Addon.Systems.AddonSystems")

-- ====== Initialize application preferences
local appPreferences = ng_getAppPrefs()
-- if no preferenes file found then write default
if ng_file_exists(appPreferences:getFilePath()) == false then appPreferences:save() end
-- load the preferences from kpcrew_prefs folder
appPreferences:load()

-- ====== Get aircraft specific preferences - first load DFLT preference set then overwrite with specific - then load prefs
local acfPreferences = ng_getAcfPrefs()
acfPreferences:setName(nh_acf_prficao) -- set aircraft specific icao as name
-- check if icao preferences file exists, if not create new
acfPreferences:setFilePath(SCRIPT_DIRECTORY .."../Modules/kpcrew_prefs/"..nh_acf_prficao..".preferences")
if ng_file_exists(acfPreferences:getFilePath()) == false then acfPreferences:save() end
acfPreferences:load()
acfPreferences:setTitle(acfPreferences:get("addon:aircraftname")) -- set overloaded aircraft name
function nh_get_active_prefs() return acfPreferences end -- global function to be used everywhere

-- ====== Get Aicraft Systems (all required switches and other elements)
local acfSystems = Systems:new("Aircraft Systems",SCRIPT_DIRECTORY.."../Modules/kpcrew/addons/"..nh_acf_sysicao.."_systems.json")
acfSystems:load()
ng_init_acf_prefs() -- initialize and make custom settings if available
function nh_get_active_sys() return acfSystems end -- global function to be used everywhere

-- ====== Initialize Addon
local activeAddon = Addon:new(nh_acf_prficao,"Addon")
activeAddon:setPreferences(acfPreferences) -- deprecated - will be replaced eventually
activeAddon:setSystems(acfSystems) -- deprecated
function nh_get_active_addon() return activeAddon end -- global function to be used everywhere

-- ========================================================================================

-- -----------------------------------------------------------------------------------------
-- execute a command from acf systems
-- @param string syselem - system element to execute
-- @param action string to apply ("chk" for this)
-- @param value a value to check against in more complex elements
-- @return true or false depeinding on the state
function ng_execute_actions(syselem, action, value)
	if syselem ~= nil and action ~= nil then
		-- # means it is a system not a system element
		if string.find(syselem,"#") ~= nil then
			ng_action_system(string.sub(syselem,2),action,value, nil)
		else
			ng_action_element(syselem, action, value, nil)
		end		
	end
end	
-- -----------------------------------------------------------------------------------------

-- -----------------------------------------------------------------------------------------
-- return true or false depending on system evaluation
-- @param string syselem - system element to check
-- @param action string to apply ("chk" for this)
-- @param value a value to check against in more complex elements
-- @return true or false depeinding on the state
function ng_get_state(syselem, action, value)
	if syselem ~= nil then
		local result = 0
		if string.find(syselem,"#") ~= nil then
			result = ng_check_system(string.sub(syselem,2),action,value, nil, nil, nil)
		else
			result = ng_check_element(syselem, action, value, nil, nil, nil)
		end
		if result then return 1 else return 0 end
	end
end 
-- -----------------------------------------------------------------------------------------

xsp_bravo_mode 			= 1
xsp_bravo_layer 		= 0
xsp_fine_coarse 		= 1

bravo_mode_alt 			= 1
bravo_mode_vs 			= 2
bravo_mode_hdg 			= 3
bravo_mode_crs 			= 4
bravo_mode_ias 			= 5

-- generic up function depending on mode and layer
function xsp_bravo_knob_up()

	-- normal A/P mode
	if xsp_bravo_layer == 0 then
		if xsp_bravo_mode == 1 then
			ng_execute_actions('altsel','up',nil)
		end
		if xsp_bravo_mode == 2 then
			ng_execute_actions('vspsel','up',nil)
		end
		if xsp_bravo_mode == 3 then
			ng_execute_actions('hdgsel','up',nil)
		end
		if xsp_bravo_mode == 4 then
			ng_execute_actions('crs1','up',nil)
		end
		if xsp_bravo_mode == 5 then
			ng_execute_actions('speedsel','up',nil)
		end
	end
	
end

-- generic down function depending on mode and layer
function xsp_bravo_knob_dn()

	-- normal A/P mode
	if xsp_bravo_layer == 0 then
		if xsp_bravo_mode == 1 then
			ng_execute_actions('altsel','dn',nil)
		end
		if xsp_bravo_mode == 2 then
			ng_execute_actions('vspsel','dn',nil)
		end
		if xsp_bravo_mode == 3 then
			ng_execute_actions('hdgsel','dn',nil)
		end
		if xsp_bravo_mode == 4 then
			ng_execute_actions('crs1','dn',nil)
		end
		if xsp_bravo_mode == 5 then
			ng_execute_actions('speedsel','dn',nil)
		end
	end

end

-- ============ aircraft generic joystick/key commands

-- ------------------ Lights Controls (toggle and on/off)
create_command("kp/xsp/lights/beacon_switch_on",	"Beacon Lights On",			"ng_execute_actions('#beacons','on',nil)",		"","")
create_command("kp/xsp/lights/beacon_switch_off",	"Beacon Lights Off",		"ng_execute_actions('#beacons','off',nil)",	"","")
create_command("kp/xsp/lights/beacon_switch_tgl",	"Beacon Lights Toggle",		"ng_execute_actions('#beacons','tgl',nil)",	"","")

create_command("kp/xsp/lights/position_switch_on",	"Position Lights On",		"ng_execute_actions('#positionlights','on',nil)",		"","")
create_command("kp/xsp/lights/position_switch_off",	"Position Lights Off",		"ng_execute_actions('#positionlights','off',nil)",		"", "")
create_command("kp/xsp/lights/position_switch_tgl",	"Position Lights Toggle",	"ng_execute_actions('#positionlights','tgl',nil)",	"","")

create_command("kp/xsp/lights/strobe_switch_on",	"Strobe Lights On",			"ng_execute_actions('#strobelights','on',nil)",				"","")
create_command("kp/xsp/lights/strobe_switch_off",	"Strobe Lights Off",		"ng_execute_actions('#strobelights','off',nil)",			"","")
create_command("kp/xsp/lights/strobe_switch_tgl",	"Strobe Lights Toggle",		"ng_execute_actions('#strobelights','tgl',nil)",			"","")

create_command("kp/xsp/lights/taxi_switch_on",		"Taxi Lights On",			"ng_execute_actions('#taxilights','on',nil)",		"","")
create_command("kp/xsp/lights/taxi_switch_off",		"Taxi Lights Off",			"ng_execute_actions('#taxilights','off',nil)",		"","")
create_command("kp/xsp/lights/taxi_switch_tgl",		"Taxi Lights Toggle",		"ng_execute_actions('#taxilights','tgl',nil)",		"","")

create_command("kp/xsp/lights/landing_switch_on",	"Landing Lights On",		"ng_execute_actions('#alllandlights','on',nil)",		"","")
create_command("kp/xsp/lights/landing_switch_off",	"Landing Lights Off",		"ng_execute_actions('#alllandlights','off',nil)",		"","")
create_command("kp/xsp/lights/landing_switch_tgl",	"Landing Lights Toggle",	"ng_execute_actions('#alllandlights','tgl',nil)",		"","")

-- only optional

if ng_getAppPrefs():get("kphwng:extlights") then

	create_command("kp/xsp/lights/rwyto_switch_on",		"Runway Lights On",			"ng_execute_actions('#rwylights','on',nil)",			"","")
	create_command("kp/xsp/lights/rwyto_switch_off",	"Runway Lights Off",		"ng_execute_actions('#rwylights','off',nil)",			"","")
	create_command("kp/xsp/lights/rwyto_switch_tgl",	"Runway Lights Toggle",		"ng_execute_actions('#rwylights','tgl',nil)",		"","")

	create_command("kp/xsp/lights/logo_switch_on",		"Logo Lights On",			"ng_execute_actions('#logolights','on',nil)",		"","")
	create_command("kp/xsp/lights/logo_switch_off",		"Logo Lights Off",			"ng_execute_actions('#logolights','off',nil)",		"","")
	create_command("kp/xsp/lights/logo_switch_tgl",		"Logo Lights Toggle",		"ng_execute_actions('#logolights','tgl',nil)",		"","")

	create_command("kp/xsp/lights/wing_switch_on",		"Wing Lights On",			"ng_execute_actions('#winglights','on',nil)",		"","")
	create_command("kp/xsp/lights/wing_switch_off",		"Wing Lights Off",			"ng_execute_actions('#winglights','off',nil)",		"","")
	create_command("kp/xsp/lights/wing_switch_tgl",		"Wing Lights Toggle",		"ng_execute_actions('#winglights','tgl',nil)",		"","")

	create_command("kp/xsp/lights/wheel_switch_on",		"Wheel Lights On",			"ng_execute_actions('#wheellights','on',nil)",		"", "")
	create_command("kp/xsp/lights/wheel_switch_off",	"Wheel Lights Off",			"ng_execute_actions('#wheellights','off',nil)",		"", "")
	create_command("kp/xsp/lights/wheel_switch_tgl",	"Wheel Lights Toggle",		"ng_execute_actions('#wheellights','tgl',nil)",	"", "")

end

---- internal lights

create_command("kp/xsp/lights/instruments_on",		"Instrument Lights On",		"ng_execute_actions('#instrlights','on',nil)",			"","")
create_command("kp/xsp/lights/instruments_off",		"Instrument Lights Off",	"ng_execute_actions('#instrlights','off',nil)",			"","")
create_command("kp/xsp/lights/instruments_tgl",		"Instrument Lights Toggle",	"ng_execute_actions('#instrlights','tgl',nil)",		"","")

create_command("kp/xsp/lights/panel_on",			"Panel Lights On",			"ng_execute_actions('#panellights','on',nil)",				"","")
create_command("kp/xsp/lights/panel_off",			"Panel Lights Off",			"ng_execute_actions('#panellights','off',nil)",			"","")
create_command("kp/xsp/lights/panel_tgl",			"Panel Lights Toggle",		"ng_execute_actions('#panellights','tgl',nil)",		"","")

create_command("kp/xsp/lights/dome_switch_on",		"Cockpit Lights On",		"ng_execute_actions('#domelights','on',nil)",		"","")
create_command("kp/xsp/lights/dome_switch_off",		"Cockpit Lights Off",		"ng_execute_actions('#domelights','off',nil)",		"","")
create_command("kp/xsp/lights/dome_switch_tgl",		"Cockpit Lights Toggle",	"ng_execute_actions('#domelights','tgl',nil)",		"","")

---------------- General Systems ---------------------

create_command("kp/xsp/systems/parking_brake_on",	"Parking Brake On",			"ng_execute_actions('parkbrake','on',nil)",			"","")
create_command("kp/xsp/systems/parking_brake_off",	"Parking Brake Off",		"ng_execute_actions('parkbrake','off',nil)",		"","")
create_command("kp/xsp/systems/parking_brake_tgl",	"Parking Brake Toggle",		"ng_execute_actions('parkbrake','tgl',nil)",		"","")

create_command("kp/xsp/systems/gears_up",			"Gears Up",					"ng_execute_actions('#gearhandle','on',nil)",			"","")
create_command("kp/xsp/systems/gears_down",			"Gears Down",				"ng_execute_actions('#gearhandle','off',nil)",			"","")
create_command("kp/xsp/systems/gears_off",			"Gears OFF",				"ng_execute_actions('#gearhandle','tgl',nil)",		"","")

create_command("kp/xsp/systems/door_l1_toggle",		"Toggle door L1",			"ng_execute_actions('doorl1','tgl',nil)","","")	
create_command("kp/xsp/systems/door_l2_toggle",		"Toggle door L2",			"ng_execute_actions('doorl2','tgl',nil)","","")	
create_command("kp/xsp/systems/door_r1_toggle",		"Toggle door R2",			"ng_execute_actions('doorr1','tgl',nil)","","")	
create_command("kp/xsp/systems/door_r2_toggle",		"Toggle door R2",			"ng_execute_actions('doorr2','tgl',nil)","","")	
create_command("kp/xsp/systems/door_cf_toggle",		"Toggle door FWD CARGO",	"ng_execute_actions('doorfcargo','tgl',nil)","","")	
create_command("kp/xsp/systems/door_ca_toggle",		"Toggle door AFT CARGO",	"ng_execute_actions('dooracargo','tgl',nil)","","")	

----------------- Electric --------------------
-- create_command("kp/xsp/electric/bat_all_master_on",	"Battery Master All On","sysElectric.batteryGroup:actuate(modeOn)","","")
-- create_command("kp/xsp/electric/bat_all_master_off","Battery Master All Off","sysElectric.batteryGroup:actuate(modeOff)","","")
-- create_command("kp/xsp/electric/bat_all_master_tgl","Battery Master All Toggle","sysElectric.batteryGroup:actuate(modeToggle)","","")

-- create_command("kp/xsp/electric/alt_all_on",			"Alternators On","sysElectric.alternatorSwitchGroup:actuate(modeOn)","","")
-- create_command("kp/xsp/electric/alt_all_off",		"Alternators Off","sysElectric.alternatorSwitchGroup:actuate(modeOff)","","")
-- create_command("kp/xsp/electric/alt_all_tgl",		"Alternators Toggle","sysElectric.alternatorSwitchGroup:actuate(modeToggle)","","")

-- create_command("kp/xsp/electric/avionics_on",		"Avionics On","sysElectric.avionicsSwitchGroup:actuate(modeOn)","","")
-- create_command("kp/xsp/electric/avionics_off",		"Avionics Off","sysElectric.avionicsSwitchGroup:actuate(modeOff)","","")
-- create_command("kp/xsp/electric/avionics_tgl",		"Avionics Toggle","sysElectric.avionicsSwitchGroup:actuate(modeToggle)","","")

----------------- Flight Controls --------------------

create_command("kp/xsp/controls/flaps_up",				"Flaps 1 Up",		"ng_execute_actions('flaplvr','dn',nil)","","","")
create_command("kp/xsp/controls/flaps_down",			"Flaps 1 Down",		"ng_execute_actions('flaplvr','up',nil)","","","")

-- create_command("kp/xsp/controls/pitch_trim_up",		"Pitch Trim Up","sysControls.pitchTrimSwitch:actuate(sysControls.trimUp)","","")
-- create_command("kp/xsp/controls/pitch_trim_down",	"Pitch Trim Down","sysControls.pitchTrimSwitch:actuate(sysControls.trimDown)","","")
-- create_command("kp/xsp/controls/pitch_trim_up_run",	"Pitch Trim Up Run","sysControls.pitchTrimUpRepeat:actuate(1)","","")
-- create_command("kp/xsp/controls/pitch_trim_up_stop",	"Pitch Trim Up Stop","sysControls.pitchTrimUpRepeat:actuate(0)","","")
-- create_command("kp/xsp/controls/pitch_trim_dn_run",	"Pitch Trim Down Run","sysControls.pitchTrimDownRepeat:actuate(1)","","")
-- create_command("kp/xsp/controls/pitch_trim_dn_stop",	"Pitch Trim Down Stop","sysControls.pitchTrimDownRepeat:actuate(0)","","")

-- create_command("kp/xsp/controls/rudder_trim_left",	"Rudder Trim Left","sysControls.rudderTrimSwitch:actuate(sysControls.trimLeft)", "sysControls.rudderTrimSwitch:actuate(sysControls.trimLeft)", "")
-- create_command("kp/xsp/controls/rudder_trim_right",	"Rudder Trim Right","sysControls.rudderTrimSwitch:actuate(sysControls.trimRight)", "sysControls.rudderTrimSwitch:actuate(sysControls.trimRight)", "")
-- create_command("kp/xsp/controls/rudder_trim_center",	"Rudder Trim Center","sysControls.rudderReset:actuate(sysControls.trimCenter)", "", "")

-- create_command("kp/xsp/controls/aileron_trim_left",	"Aileron Trim Left","sysControls.aileronTrimSwitch:actuate(sysControls.trimLeft)", "sysControls.rudderTrimSwitch:actuate(sysControls.trimRight)", "")
-- create_command("kp/xsp/controls/aileron_trim_right",	"Aileron Trim Right","sysControls.aileronTrimSwitch:actuate(sysControls.trimRight)", "sysControls.aileronTrimSwitch:actuate(sysControls.trimRight)", "")
-- create_command("kp/xsp/controls/aileron_trim_center","Aileron Trim Center","sysControls.aileronReset:actuate(sysControls.trimCenter)", "", "")

-- --------------- Engines
-- create_command("kp/xsp/engines/reverse_all_on",		"Reverse Thrust 1 On", "sysEngines.reverserGroup:actuate(modeOn)", "", "")
-- create_command("kp/xsp/engines/reverse_all_off",		"Reverse Thrust 1 Off", "sysEngines.reverserGroup:actuate(modeOff)", "", "")

-- create_command("kp/xsp/engines/magnetos_off",		"Magnetos Off", "sysEngines.magnetoOff:actuate(1)", "", "")
-- create_command("kp/xsp/engines/magnetos_l",			"Magnetos Left", "sysEngines.magnetoL:actuate(1)", "", "")
-- create_command("kp/xsp/engines/magnetos_r",			"Magnetos Right", "sysEngines.magnetoR:actuate(1)", "", "")
-- create_command("kp/xsp/engines/magnetos_both",		"Magnetos Both", "sysEngines.magnetoBoth:actuate(1)", "", "")
-- create_command("kp/xsp/engines/magnetos_start_run",	"Magnetos Start Run", "sysEngines.magnetoStartOn:actuate(1)", "", "")
-- create_command("kp/xsp/engines/magnetos_start_end",	"Magnetos Start End", "sysEngines.magnetoStartStop:actuate(1)", "", "")

-- --------------- Fuel
-- create_command("kp/xsp/fuel/pumps_on",				"Fuel Pumps On", "sysFuel.allFuelPumpGroup:actuate(modeOn)","","")
-- create_command("kp/xsp/fuel/pumps_off",				"Fuel Pumps Off", "sysFuel.allFuelPumpGroup:actuate(modeOff)","","")
-- create_command("kp/xsp/fuel/pumps_tgl",				"Fuel Pumps Toggle", "sysFuel.allFuelPumpGroup:actuate(modeToggle)","","")

-- ------------ A/P MCP functions
create_command("kp/xsp/autopilot/both_fd_on",		"All FDs On", 		"ng_execute_actions('#flightdirs','on',nil)", "", "")
create_command("kp/xsp/autopilot/both_fd_off",		"All FDs Off", 		"ng_execute_actions('#flightdirs','off',nil)", "", "")
create_command("kp/xsp/autopilot/both_fd_tgl",		"All FDs Toggle", 	"ng_execute_actions('#flightdirs','tgl',nil)", "", "")

create_command("kp/xsp/autopilot/fd1_on",			"All FDs On", 		"ng_execute_actions('flightdir1','on',nil)", "", "")
create_command("kp/xsp/autopilot/fd1_off",			"All FDs Off", 		"ng_execute_actions('flightdir1','off',nil)", "", "")
create_command("kp/xsp/autopilot/fd1_tgl",			"All FDs Toggle", 	"ng_execute_actions('flightdir1','tgl',nil)", "", "")

create_command("kp/xsp/autopilot/fd2_on",			"All FDs On", 		"ng_execute_actions('flightdir2','on',nil)", "", "")
create_command("kp/xsp/autopilot/fd2_off",			"All FDs Off", 		"ng_execute_actions('flightdir2','off',nil)", "", "")
create_command("kp/xsp/autopilot/fd2_tgl",			"All FDs Toggle", 	"ng_execute_actions('flightdir2','tgl',nil)", "", "")

create_command("kp/xsp/autopilot/ap_tgl",			"Toggle A/P 1", 	"ng_execute_actions('ap1','tgl',nil)", "", "")
create_command("kp/xsp/autopilot/ap2_tgl",			"Toggle A/P 2", 	"ng_execute_actions('ap2','tgl',nil)", "", "")
create_command("kp/xsp/autopilot/alt_tgl",			"Toggle Alt Hold", 	"ng_execute_actions('althold','tgl',nil)","","")
create_command("kp/xsp/autopilot/hdg_tgl",			"Toggle Hdg Select", "ng_execute_actions('hdghold','tgl',nil)","","")
create_command("kp/xsp/autopilot/nav_tgl",			"Toggle Nav Mode", 	"ng_execute_actions('navhold','tgl',nil)","","")
create_command("kp/xsp/autopilot/app_tgl",			"Toggle Approach", 	"ng_execute_actions('approach','tgl',nil)","","")
create_command("kp/xsp/autopilot/vs_tgl",			"Toggle Vert Speed", "ng_execute_actions('vspmode','tgl',nil)","","")
create_command("kp/xsp/autopilot/ias_tgl",			"Toggle IAS/Speed mode", "ng_execute_actions('spdmode','tgl',nil)","","")

create_command("kp/xsp/autopilot/at_tgl",			"A/T Tgl", "ng_execute_actions('autothrottle','tgl',nil)","","")
create_command("kp/xsp/autopilot/at_arm",			"A/T Arm", "ng_execute_actions('autothrottle','on',nil)","","")
create_command("kp/xsp/autopilot/at_off",			"A/T OFF", "ng_execute_actions('autothrottle','off',nil)","","")

create_command("kp/xsp/autopilot/toga_press",		"Press Left TOGA", "ng_execute_actions('toga','tgl',nil)","","")

create_command("kp/xsp/autopilot/crs1_dn",			"CRS 1 decrease", "ng_execute_actions('crs1','dn',nil)","","")
create_command("kp/xsp/autopilot/crs1_up",			"CRS 1 increase", "ng_execute_actions('crs1','up',nil)","","")
create_command("kp/xsp/autopilot/crs2_dn",			"CRS 2 decrease", "ng_execute_actions('crs2','dn',nil)","","")
create_command("kp/xsp/autopilot/crs2_up",			"CRS 2 increase", "ng_execute_actions('crs2','up',nil)","","")

create_command("kp/xsp/autopilot/spd_dn",			"Speed decrease", "ng_execute_actions('speedsel','dn',nil)","","")
create_command("kp/xsp/autopilot/spd_up",			"Speed increase", "ng_execute_actions('speedsel','up',nil)","","")

create_command("kp/xsp/autopilot/hdg_dn",			"Heading decrease", "ng_execute_actions('hdgsel','dn',nil)","","")
create_command("kp/xsp/autopilot/hdg_up",			"Heading increase", "ng_execute_actions('hdgsel','up',nil)","","")

create_command("kp/xsp/autopilot/alt_dn",			"Altitude decrease", "ng_execute_actions('altsel','dn',nil)","","")
create_command("kp/xsp/autopilot/alt_up",			"Altitude increase", "ng_execute_actions('altsel','up',nil)","","")

create_command("kp/xsp/autopilot/vsp_dn",			"Vertical Speed decrease", "ng_execute_actions('vspsel','dn',nil)","","")
create_command("kp/xsp/autopilot/vsp_up",			"Vertical Speed increase", "ng_execute_actions('vspsel','up',nil)","","")

create_command("kp/xsp/autopilot/APDiscYoke",		"Disconnect A/P from Yoke", "ng_execute_actions('yokedisc','tgl',nil)","","")

if ng_getAppPrefs():get("kphwng:levelfull") then

	if ng_getAppPrefs():get("kphwng:extmcp") then
	
		create_command("kp/xsp/autopilot/n1_tgl",	"Toggle N1/EPR mode", "ng_execute_actions('n1mode','tgl',nil)","","")
		create_command("kp/xsp/autopilot/vnav_tgl",	"Toggle VNAV mode", "ng_execute_actions('vnavmode','tgl',nil)","","")
		create_command("kp/xsp/autopilot/flch_tgl",	"Toggle Level Change mode", "ng_execute_actions('flchmode','tgl',nil)","","")
		create_command("kp/xsp/autopilot/lnav_tgl",	"Toggle LNAV mode", "ng_execute_actions('lnavmode','tgl',nil)","","")
	
	end

end
-- --------------- EFIS all captain side

create_command("kp/xsp/systems/all_alt_std",		"ALTS STD/QNH toggle",		"ng_execute_actions('#barostdbtns','tgl',nil)",		"","")

create_command("kp/xsp/systems/baro_mode_tgl",		"Baro inch/mb toggle",		"ng_execute_actions('#baromodes','tgl',nil)",	"","")

create_command("kp/xsp/systems/all_baro_down",		"All baro down",			"ng_execute_actions('#barovalues','dn',nil)","","")
create_command("kp/xsp/systems/all_baro_up",		"All baro up",				"ng_execute_actions('#barovalues','up',nil)","","")


-- MAP zoom
-- create_command("kp/xsp/efis/map_zoom_dn",			"EFIS Map Zoom In", "sysEFIS.mapZoomPilot:step(cmdDown)","","")
-- create_command("kp/xsp/efis/map_zoom_up",			"EFIS Map Zoom Out", "sysEFIS.mapZoomPilot:step(cmdUp)","","")

-- MAP mode
-- create_command("kp/xsp/efis/map_mode_dn",			"EFIS Map Mode Left", "sysEFIS.mapModePilot:step(cmdDown)","","")
-- create_command("kp/xsp/efis/map_mode_up",			"EFIS Map Mode Right", "sysEFIS.mapModePilot:step(cmdUp)","","")

-- CTR Boeing
-- create_command("kp/xsp/efis/ctr_toggle",			"EFIS CTR Toggle", "sysEFIS.ctrPilot:actuate(modeToggle)","","")

-- TFC Traffic 
-- create_command("kp/xsp/efis/tfc_toggle",			"EFIS TFC Toggle", "sysEFIS.tfcPilot:actuate(modeToggle)","","")

-- WXR Weather
-- create_command("kp/xsp/efis/wxr_toggle",			"EFIS Weather Toggle", "sysEFIS.wxrPilot:actuate(modeToggle)","","")

-- STA Boeing / VOR DFLT
-- create_command("kp/xsp/efis/sta_toggle",			"EFIS STA Toggle", "sysEFIS.staPilot:actuate(modeToggle)","","")

-- WPT / FIX
-- create_command("kp/xsp/efis/wpt_toggle",			"EFIS WPT Toggle", "sysEFIS.wptPilot:actuate(modeToggle)","","")

-- APT
-- create_command("kp/xsp/efis/apt_toggle",			"EFIS Airport Toggle", "sysEFIS.arptPilot:actuate(modeToggle)","","")

-- DATA Boeing
-- create_command("kp/xsp/efis/dat_toggle",			"EFIS DATA Toggle", "sysEFIS.dataPilot:actuate(modeToggle)","","")

-- POS Boeing / NAV DFLT
-- create_command("kp/xsp/efis/pos_toggle",			"EFIS POS Toggle", "sysEFIS.posPilot:actuate(modeToggle)","","")

-- Terrain
-- create_command("kp/xsp/efis/ter_toggle",			"EFIS Terrain Toggle", "sysEFIS.terrPilot:actuate(modeToggle)","","")

-- FPV Boeing
-- create_command("kp/xsp/efis/fpv_toggle",			"EFIS FPV Toggle", "sysEFIS.fpvPilot:actuate(modeToggle)","","")

-- MTRS Boeing
-- create_command("kp/xsp/efis/mtr_toggle",			"EFIS FPV Toggle", "sysEFIS.mtrsPilot:actuate(modeToggle)","","")

-- MINS type Boeing RADIO/BARO
-- create_command("kp/xsp/efis/mins_type_dn",			"EFIS Mins Type Knob Left", "sysEFIS.minsTypePilot:step(cmdDown)","","")
-- create_command("kp/xsp/efis/mins_type_up",			"EFIS Mins Type Knob Right", "sysEFIS.minsTypePilot:step(cmdUp)","","")

-- MINS RESET/ON OFF Boeing
-- create_command("kp/xsp/efis/mins_toggle",			"EFIS Minimums Reset", "sysEFIS.minsResetPilot:actuate(modeToggle)","","")

-- MINS SET or DH/DA
-- create_command("kp/xsp/efis/mins_dn",				"EFIS Minimums Down", "sysEFIS.minsPilot:step(cmdDown)","","")
-- create_command("kp/xsp/efis/mins_up",				"EFIS Minimums Up", "sysEFIS.minsPilot:step(cmdUp)","","")

-- VOR/ADF 1
-- create_command("kp/xsp/efis/voradf_1_dn",			"EFIS VORADF1 Down/Left", "sysEFIS.voradf1Pilot:step(cmdDown)","","")
-- create_command("kp/xsp/efis/voradf_1_up",			"EFIS VORADF1 Up/Right", "sysEFIS.voradf1Pilot:step(cmdUp)","","")

-- VOR/ADF 2
-- create_command("kp/xsp/efis/voradf_2_dn",			"EFIS VORADF2 Down/Left", "sysEFIS.voradf2Pilot:step(cmdDown)","","")
-- create_command("kp/xsp/efis/voradf_2_up",			"EFIS VORADF2 Up/Right", "sysEFIS.voradf2Pilot:step(cmdUp)","","")


-- ------------- Instantiate Datarefs for general annunciators ----------- 


-- ------ Lights Annunciators (e.g. for Go-Flight) ----------

xsp_lights_beacon 			= create_dataref_table("kp/xsp/lights/beacon", "Int")
xsp_lights_beacon[0] = 0

xsp_lights_position 		= create_dataref_table("kp/xsp/lights/position_lights", "Int")
xsp_lights_position[0] = 0

xsp_lights_strobes 			= create_dataref_table("kp/xsp/lights/strobes", "Int")
xsp_lights_strobes[0] = 0

xsp_lights_taxi 			= create_dataref_table("kp/xsp/lights/taxi_lights", "Int")
xsp_lights_taxi[0] = 0

xsp_lights_landing 			= create_dataref_table("kp/xsp/lights/landing_lights", "Int")
xsp_lights_landing[0] = 0
			
xsp_lights_instrument 		= create_dataref_table("kp/xsp/lights/instrument_lights", "Int")
xsp_lights_instrument[0] = 0

xsp_lights_panel 			= create_dataref_table("kp/xsp/lights/panel_lights", "Int")
xsp_lights_panel[0] = 0

xsp_lights_dome 			= create_dataref_table("kp/xsp/lights/dome_lights", "Int")
xsp_lights_dome[0] = 0	
		
xsp_lights_wing 		= create_dataref_table("kp/xsp/lights/wing_lights", "Int")
xsp_lights_wing[0] = 0

xsp_lights_wheel 		= create_dataref_table("kp/xsp/lights/wheel_lights", "Int")
xsp_lights_wheel[0] = 0

xsp_lights_logo 		= create_dataref_table("kp/xsp/lights/logo_lights", "Int")
xsp_lights_logo[0] = 0

xsp_lights_rwyto		= create_dataref_table("kp/xsp/lights/runway_lights", "Int")
xsp_lights_rwyto[0] = 0		
			
-- General systems and functions

xsp_parking_brake 			= create_dataref_table("kp/xsp/bravo/parking_brake", "Int")
xsp_parking_brake[0] = 0

xsp_gear_light_green		= create_dataref_table("kp/xsp/bravo/gear_light_green", "Int")
xsp_gear_light_green[0] = 0

xsp_gear_light_red			= create_dataref_table("kp/xsp/bravo/gear_light_red", "Int")
xsp_gear_light_red[0] = 0

xsp_doors = create_dataref_table("kp/xsp/bravo/doors", "Int")
xsp_doors[0] = 0

-- optional for bravo throttle display section

-- used for parking brakeon bravo
xsp_mcp_rev 				= create_dataref_table("kp/xsp/bravo/mcp_rev", "Int")
xsp_mcp_rev[0] = 0

-- xsp_gear_light_on_n			= create_dataref_table("kp/xsp/bravo/gear_light_on_n", "Int")
-- xsp_gear_light_on_n[0] = 0
-- xsp_gear_light_on_l			= create_dataref_table("kp/xsp/bravo/gear_light_on_l", "Int")
-- xsp_gear_light_on_l[0] = 0
-- xsp_gear_light_on_r			= create_dataref_table("kp/xsp/bravo/gear_light_on_r", "Int")
-- xsp_gear_light_on_r[0] = 0
-- xsp_gear_light_trans_n		= create_dataref_table("kp/xsp/bravo/gear_light_trans_n", "Int")
-- xsp_gear_light_trans_n[0] = 0
-- xsp_gear_light_trans_l 		= create_dataref_table("kp/xsp/bravo/gear_light_trans_l", "Int")
-- xsp_gear_light_trans_l[0] = 0
-- xsp_gear_light_trans_r 		= create_dataref_table("kp/xsp/bravo/gear_light_trans_r", "Int")
-- xsp_gear_light_trans_r[0] = 0

xsp_engine_fire 			= create_dataref_table("kp/xsp/bravo/engine_fire", "Int")
xsp_engine_fire[0] = 0

xsp_anc_starter = create_dataref_table("kp/xsp/bravo/anc_starter", "Int")
xsp_anc_starter[0] = 0

-- xsp_anc_reverse = create_dataref_table("kp/xsp/bravo/anc_reverse", "Int")
-- xsp_anc_reverse[0] = 0

-- xsp_anc_oil = create_dataref_table("kp/xsp/bravo/anc_oil", "Int")
-- xsp_anc_oil[0] = 0

xsp_master_caution = create_dataref_table("kp/xsp/bravo/master_caution", "Int")
xsp_master_caution[0] = 0

xsp_master_warning = create_dataref_table("kp/xsp/bravo/master_warning", "Int")
xsp_master_warning[0] = 0

xsp_apu_running	= create_dataref_table("kp/xsp/bravo/apu_running", "Int")
xsp_apu_running[0] = 0

-- xsp_low_volts = create_dataref_table("kp/xsp/bravo/low_volts", "Int")
-- xsp_low_volts[0] = 0

-- xsp_anc_hyd = create_dataref_table("kp/xsp/bravo/anc_hyd", "Int")
-- xsp_anc_hyd[0] = 0

-- xsp_fuel_press = create_dataref_table("kp/xsp/bravo/anc_fuel_low", "Int")
-- xsp_fuel_press[0] = 0

xsp_fuel_aux_pump = create_dataref_table("kp/xsp/bravo/anc_fuel_aux_pump", "Int")
xsp_fuel_aux_pump[0] = 0

-- use for reverse mode on jets
xsp_vacuum = create_dataref_table("kp/xsp/bravo/vacuum", "Int")
xsp_vacuum[0] = 0

xsp_anc_aice = create_dataref_table("kp/xsp/bravo/anc_aice", "Int")
xsp_anc_aice[0] = 0

-- Autopilot / MCP / FCU

xsp_mcp_fdir 			= create_dataref_table("kp/xsp/autopilot/mcp_fd", "Int")
xsp_mcp_fdir[0] = 0

xsp_mcp_fdir2 			= create_dataref_table("kp/xsp/autopilot/mcp_fd2", "Int")
xsp_mcp_fdir2[0] = 0

xsp_mcp_ap1 			= create_dataref_table("kp/xsp/autopilot/mcp_ap1", "Int")
xsp_mcp_ap1[0] = 0

xsp_mcp_ap2 			= create_dataref_table("kp/xsp/autopilot/mcp_ap2", "Int")
xsp_mcp_ap2[0] = 0

xsp_mcp_alt 			= create_dataref_table("kp/xsp/autopilot/mcp_alt", "Int")
xsp_mcp_alt[0] = 0

xsp_mcp_hdg 			= create_dataref_table("kp/xsp/autopilot/mcp_hdg", "Int")
xsp_mcp_hdg[0] = 0

xsp_mcp_nav 			= create_dataref_table("kp/xsp/autopilot/mcp_nav", "Int")
xsp_mcp_nav[0] = 0

xsp_mcp_app 			= create_dataref_table("kp/xsp/autopilot/mcp_app", "Int")
xsp_mcp_app[0] = 0

xsp_mcp_vsp 			= create_dataref_table("kp/xsp/autopilot/mcp_vsp", "Int")
xsp_mcp_vsp[0] = 0

xsp_mcp_ias 			= create_dataref_table("kp/xsp/autopilot/mcp_ias", "Int")
xsp_mcp_ias[0] = 0

xsp_mcp_athr 			= create_dataref_table("kp/xsp/autopilot/mcp_athr", "Int")
xsp_mcp_athr[0] = 0

xsp_mcp_toga 			= create_dataref_table("kp/xsp/autopilot/mcp_toga", "Int")
xsp_mcp_toga[0] = 0

-- datarefs for MCP values
xsp_mcp_altval = create_dataref_table("kp/xsp/bravo/mcp_altval", "Int")
xsp_mcp_altval[0] = 0

xsp_mcp_hdgval = create_dataref_table("kp/xsp/bravo/mcp_hdgval", "Int")
xsp_mcp_hdgval[0] = 0

xsp_mcp_spdval = create_dataref_table("kp/xsp/bravo/mcp_spdval", "Int")
xsp_mcp_spdval[0] = 0

xsp_mcp_vsival = create_dataref_table("kp/xsp/bravo/mcp_vsival", "Int")
xsp_mcp_vsival[0] = 0

xsp_mcp_crs1val = create_dataref_table("kp/xsp/bravo/mcp_crs1val", "Int")
xsp_mcp_crs1val[0] = 0

xsp_mcp_crs2val = create_dataref_table("kp/xsp/bravo/mcp_crs2val", "Int")
xsp_mcp_crs2val[0] = 0

-- extended MCP/FCU
xsp_mcp_n1mode = create_dataref_table("kp/xsp/autopilot/mcp_n1", "Int")
xsp_mcp_n1mode[0] = 0	

xsp_mcp_vnavmode = create_dataref_table("kp/xsp/autopilot/mcp_vnav", "Int")
xsp_mcp_vnavmode[0] = 0	

xsp_mcp_flchmode = create_dataref_table("kp/xsp/autopilot/mcp_flch", "Int")
xsp_mcp_flchmode[0] = 0	
		
-- background function every 1 sec to set lights/annunciators for hardware (honeycomb bravo)
function xsp_set_light_drefs()

-- ------ Lights Annunciators ----------

	if ng_getAppPrefs():get("kphwng:levelfull") then

		if ng_getAppPrefs():get("kphwng:lightann") then

			xsp_lights_beacon[0] 		= ng_get_state("#beacons","chk",nil)

			xsp_lights_position[0] 		= ng_get_state("#positionlights","chk",nil)

			xsp_lights_strobes[0] 		= ng_get_state("#strobelights","chk",nil)

			xsp_lights_taxi[0] 			= ng_get_state("#taxilights","chk",nil)

			xsp_lights_landing[0] 		= ng_get_state("#alllandlights","chk",nil)

			xsp_lights_panel[0] 		= ng_get_state("#panellights","chk",nil)

			xsp_lights_instrument[0] 	= ng_get_state("#instrlights","chk",nil)

			xsp_lights_dome[0] 			= ng_get_state("#domelights","chk",nil)

			if ng_getAppPrefs():get("kphwng:extlights") then

				xsp_lights_wing[0] 		= ng_get_state("#winglights","chk",nil)

				xsp_lights_wheel[0] 	= ng_get_state("#wheellights","chk",nil)

				xsp_lights_logo[0] 		= ng_get_state("#logolights","chk",nil)

				xsp_lights_rwyto[0] 	= ng_get_state("#rwylights","chk",nil)
				
			end
			
		end
		
	end

	-- PARKING BRAKE 0=off 1=set
	xsp_parking_brake[0] 				= ng_get_state("parkbrake","chk",1)

	-- General Gear light green on/off
	xsp_gear_light_green[0] 			= ng_get_state("_gearlightsgreen","chk",1)
	xsp_gear_light_red[0] 				= ng_get_state("_gearlightsred","chk",1)

	-- DOORS annunciator
	xsp_doors[0] = ng_get_state("doorl1","chk",1) + ng_get_state("doorl2","chk",1) + 
		ng_get_state("doorr1","chk",1) + ng_get_state("doorr2","chk",1) + 
		ng_get_state("dooracargo","chk",1) + ng_get_state("doorfcargo","chk",1)

	-- optional for bravo throttle display section
	if ng_getAppPrefs():get("kphwng:bravo") then

		-- REV annunciator (used for parking brake light on bravo)
		xsp_mcp_rev[0] 					= ng_get_state("parkbrake","chk",1)
	
		-- xsp_gear_light_on_l[0] 				= ng_get_state("_gearlightsgreen","chk",nil)
		-- xsp_gear_light_on_r[0] 				= ng_get_state("_gearlightsgreen","chk",nil)
		-- xsp_gear_light_on_n[0] 				= ng_get_state("_gearlightsgreen","chk",nil)
		-- xsp_gear_light_trans_l[0] 			= ng_get_state("_gearlightsred","chk",nil)
		-- xsp_gear_light_trans_r[0] 			= ng_get_state("_gearlightsred","chk",nil)
		-- xsp_gear_light_trans_n[0] 			= ng_get_state("_gearlightsred","chk",nil)

		-- ENGINE FIRE annunciator
		xsp_engine_fire[0] = ng_get_state("_eng1fire","chk",1) + ng_get_state("_eng2fire","chk",1) + 
			ng_get_state("_apufire","chk",1)

		-- STARTER annunciator
		xsp_anc_starter[0] = ng_get_state("engstartsel1","chk",1) + ng_get_state("engstartsel2","chk",1) + 
			ng_get_state("engstartsel3","chk",1) + ng_get_state("engstartsel4","chk",1)

		-- ENGINE REVERSE on
		-- xsp_anc_reverse[0] = ng_get_state("","chk",nil)
		
		-- OIL PRESSURE annunciator
		-- xsp_anc_oil[0] = ng_get_state("","chk",nil)

		-- MASTER CAUTION annunciator
		xsp_master_caution[0] = ng_get_state("_mastercaution","chk",nil)

		-- MASTER WARNING annunciator
		xsp_master_warning[0] = ng_get_state("_masterwarn","chk",nil)
		
		-- APU annunciator
		xsp_apu_running[0] = ng_get_state("_apuon","chk",nil)

		-- LOW VOLTAGE annunciator
		-- xsp_low_volts[0] = ng_get_state("","chk",nil)
		
		-- LOW HYD PRESSURE annunciator
		-- xsp_anc_hyd[0] = ng_get_state("","chk",nil)
		
		-- LOW FUEL PRESSURE annunciator
		-- xsp_fuel_press[0] = ng_get_state("","chk",nil)
	
		-- AUX FUEL PUMP working annunciators
		xsp_fuel_aux_pump[0] = ng_get_state("fuelpump1","chk",nil) + ng_get_state("fuelpump2","chk",nil) + 
			ng_get_state("fuelpump3","chk",nil) + ng_get_state("fuelpump4","chk",nil) + 
			ng_get_state("fuelpump5","chk",nil) + ng_get_state("fuelpump6","chk",nil) + 
			ng_get_state("fuelpump7","chk",nil) + ng_get_state("fuelpump8","chk",nil)
		
		-- VACUUM annunciator
		xsp_vacuum[0] = ng_get_state("_reverse","chk",nil)
		
		-- ANTI ICE annunciator
		xsp_anc_aice[0] = ng_get_state("engaice1","chk",nil) + ng_get_state("engaice2","chk",nil) + 
			ng_get_state("engaice3","chk",nil) + ng_get_state("engaice4","chk",nil) + 
			ng_get_state("wingaice1","chk",nil) + ng_get_state("wingaice2","chk",nil)

	end 
	
-- --- Autopilot/MCP/FCU	

	-- FLIGHT DIRECTOR annunciator
	xsp_mcp_fdir[0] = ng_get_state("flightdir1","chk",0)	
	xsp_mcp_fdir2[0] = ng_get_state("flightdir2","chk",0)	
	
	-- HDG annunciator
	xsp_mcp_hdg[0] = ng_get_state("_hdg","chk",nil)

	-- NAV annunciator
	xsp_mcp_nav[0] = ng_get_state("_loc","chk",nil) + ng_get_state("_lnav","chk",nil)

	-- APR annunciator
	xsp_mcp_app[0] = ng_get_state("_appr","chk",nil)

	-- ALT annunciator
	xsp_mcp_alt[0] = ng_get_state("_alt","chk",nil)

	-- VS annunciator
	xsp_mcp_vsp[0] = ng_get_state("_vsp","chk",nil)

	-- IAS annunciator
	xsp_mcp_ias[0] = ng_get_state("_ias","chk",nil)

	-- AUTO PILOT annunciator
	xsp_mcp_ap1[0] = ng_get_state("_ap1state","chk",nil) + ng_get_state("_ap2state","chk",nil)

	-- Autothrottle light
	-- xsp_mcp_athr[0] = ng_get_state("","chk",nil)

	-- TOGA light
	xsp_mcp_toga[0] = ng_get_state("toga","chk",0)

	-- Altitude display
	-- xsp_mcp_altval[0] = ng_get_state("","chk",nil)

	-- Heading dispay
	-- xsp_mcp_hdgval[0] = ng_get_state("","chk",nil)

	-- Speed value
	xsp_mcp_spdval[0] = ng_get_state("","chk",nil)

	-- VS value
	-- xsp_mcp_vsival[0] = ng_get_state("","chk",nil)

	-- CRS1 value
	-- xsp_mcp_crs1val[0] = ng_get_state("","chk",nil)

	-- CRS2 value
	-- xsp_mcp_crs2val[0] = ng_get_state("","chk",nil)

	-- extended MCP/FCU
	if ng_getAppPrefs():get("kphwng:levelfull") then

		if ng_getAppPrefs():get("kphwng:extmcp") then
		
			xsp_mcp_n1mode[0] = ng_get_state("_n1","chk",nil)
			xsp_mcp_vnavmode[0] = ng_get_state("_vnavmode","chk",nil)
			xsp_mcp_flchmode[0] = ng_get_state("_flchmode","chk",nil)
			
		end

	end	
end

-- ===== UIs =====

-- kh_scrn_width = get("sim/graphics/view/window_width")
-- kh_scrn_height = get("sim/graphics/view/window_height")

-- local start_y_pos = 0

-- regularly update the drefs for annunciators and lights (every 1 second)
do_often("xsp_set_light_drefs()")


