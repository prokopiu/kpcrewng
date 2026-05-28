-- simulate x-plane and flywithlua functions and variables

SCRIPT_DIRECTORY = "/home/kosta/eclipse-workspace/KPCrewNG/Scripts/"
SYSTEM_DIRECTORY = "/home/kosta/eclipse-workspace/KPCrewNG/"

PLANE_ICAO = "B738"
PLANE_TAILNUMBER = "ZB738"
OPERATING_SYSTEM = "Linux"
 
local dataref_local_store = {
	["sim/operation/prefs/text_out"] = 0,
	["sim/flightmodel/position/latitude"] = 48.124, 
	["sim/flightmodel/position/longitude"] = 10.43,
	["sim/cockpit2/autopilot/altitude_readout_preselector"] = 10000,
	["sim/time/zulu_time_sec"] = 12344,
	["sim/time/local_time_sec"] = 8977,
	["sim/version/xplane_internal_version"] = function () return 130000+1 end,
	["sim/graphics/view/window_width"] = 1920,
	["sim/graphics/view/window_height"] = 1080,
	["sim/graphics/view/window_width"] = 1920,
	["sim/graphics/view/window_height"] = 1080,
	["sim/flightmodel/position/latitude"] = 1,
	["sim/flightmodel/position/longitude"] = 1,
	["sim/aircraft/weight/acf_m_max"] = 46000,
	["sim/aircraft/weight/acf_m_empty"] = 43111,
	["sim/flightmodel/weight/m_fuel_total"] = 6000,
	["sim/flightmodel/weight/m_total"] = 400000,
	["sim/cockpit/switches/anti_ice_inlet_heat_per_engine"] = 0,
	["sim/cockpit2/ice/ice_surfce_heat_on"] = 1,
	["sim/cockpit2/controls/parking_brake_ratio"] = 0,
	["sim/cockpit2/ice/ice_window_heat_on_window"] = 0,
	["laminar/B738/switches/left_wiper_pos"] = 0,
	["laminar/B738/switches/right_wiper_pos"] = 0,
	["sim/cockpit/engine/APU_N1"] = 97,
	["laminar/B738/gpu_available"] = 0,
	["laminar/B738/electrical/apu_gen1_pos"] = 0,
	["laminar/B738/electrical/apu_gen2_pos"] = 0,
	["sim/private/stats/skyc/sun_amb_b"] = 1,
	["laminar/B738/toggle_switch/cockpit_dome_pos"] = 0,
	["laminar/B738/toggle_switch/emer_exit_lights"] = 0,
	["laminar/B738/engine/thrust1_leveler"] = 0,
	["laminar/B738/engine/thrust2_leveler"] = 0,
	["laminar/B738/toggle_switch/electric_hydro_pumps1_pos"] = 0,
	["laminar/B738/toggle_switch/electric_hydro_pumps2_pos"] = 0,
	["laminar/B738/toggle_switch/hydro_pumps1_pos"] = 0,
	["laminar/B738/toggle_switch/hydro_pumps2_pos"] = 0,
	["laminar/B738/knob/transponder_pos"] = 0,
	["laminar/B738/toggle_switch/irs_left"] = 0,
	["laminar/B738/toggle_switch/irs_right"] = 0,
	["laminar/B738/toggle_switch/seatbelt_sign_pos"] = 0,
	["laminar/B738/toggle_switch/no_smoking_pos"] = 0,
	["laminar/B738/electric/standby_bat_pos"] = 0,
	
	
}

local command_store = {
	["laminar/B738/push_button/park_brake_on_off"] 				= { "tgl", "sim/cockpit2/controls/parking_brake_ratio", -1},
	["laminar/B738/push_button/gear_down"] 						= { "on",  "laminar/B738/controls/gear_handle_down", -1},
	["laminar/B738/push_button/gear_up"] 						= { "off", "laminar/B738/controls/gear_handle_down", -1},
	["laminar/B738/push_button/flaps_0"] 						= { "off",  "sim/cockpit2/controls/flap_ratio", -1},
	["laminar/B738/push_button/flaps_1"] 						= { "on",  "sim/cockpit2/controls/flap_ratio", -1},
	["laminar/B738/push_button/flaps_2"] 						= { "on",  "sim/cockpit2/controls/flap_ratio", -1},
	["laminar/B738/push_button/flaps_5"] 						= { "on",  "sim/cockpit2/controls/flap_ratio", -1},
	["laminar/B738/push_button/flaps_10"] 						= { "on",  "sim/cockpit2/controls/flap_ratio", -1},
	["laminar/B738/push_button/flaps_15"] 						= { "on",  "sim/cockpit2/controls/flap_ratio", -1},
	["laminar/B738/push_button/flaps_25"] 						= { "on",  "sim/cockpit2/controls/flap_ratio", -1},
	["laminar/B738/push_button/flaps_30"] 						= { "on",  "sim/cockpit2/controls/flap_ratio", -1},
	["laminar/B738/push_button/flaps_40"] 						= { "on",  "sim/cockpit2/controls/flap_ratio", -1},
	["laminar/B738/switch/battery_dn"] 							= { "on",  "laminar/B738/electric/battery_pos", -1},
	["laminar/B738/switch/battery_up"] 							= { "off", "laminar/B738/electric/battery_pos", -1},
	["laminar/B738/knob/left_wiper_dn"]							= { "dn",  "laminar/B738/switches/left_wiper_pos", -1},
	["laminar/B738/knob/left_wiper_up"]							= { "up",  "laminar/B738/switches/left_wiper_pos", -1},
	["laminar/B738/knob/right_wiper_dn"]						= { "dn",  "laminar/B738/switches/right_wiper_pos", -1},
	["laminar/B738/knob/right_wiper_up"]						= { "up",  "laminar/B738/switches/right_wiper_pos", -1},
	["laminar/B738/gpu_toggle"]									= { "tgl", "laminar/B738/gpu_available", -1},
	["laminar/B738/toggle_switch/gpu_dn"]						= { "on",  "sim/cockpit2/electrical/GPU_generator_on", -1},
	["laminar/B738/toggle_switch/gpu_up"]						= { "off", "sim/cockpit2/electrical/GPU_generator_on", -1},
	["laminar/B738/toggle_switch/apu_gen1_dn"]					= { "dn", "laminar/B738/electrical/apu_gen1_pos", -1},
	["laminar/B738/toggle_switch/apu_gen1_up"]					= { "up", "laminar/B738/electrical/apu_gen1_pos", -1},
	["laminar/B738/toggle_switch/apu_gen2_dn"]					= { "dn", "laminar/B738/electrical/apu_gen2_pos", -1},
	["laminar/B738/toggle_switch/apu_gen2_up"]					= { "up", "laminar/B738/electrical/apu_gen2_pos", -1},
	["sim/lights/beacon_lights_on"]								= { "on", "sim/cockpit/electrical/beacon_lights_on", -1},
	["sim/lights/beacon_lights_off"]							= { "off","sim/cockpit/electrical/beacon_lights_on", -1},
	["sim/lights/beacon_lights_toggle"]							= { "tgl","sim/cockpit/electrical/beacon_lights_on", -1},
	["laminar/B738/toggle_switch/taxi_light_brightness_on"]		= { "on", "laminar/B738/toggle_switch/taxi_light_brightness_pos", -1},
	["laminar/B738/toggle_switch/taxi_light_brightness_off"] 	= { "off","laminar/B738/toggle_switch/taxi_light_brightness_pos", -1},
	["laminar/B738/toggle_switch/taxi_light_brightness_toggle"]	= { "tgl","laminar/B738/toggle_switch/taxi_light_brightness_pos", -1},
	["laminar/B738/switch/rwy_light_left_on"]					= { "on", "laminar/B738/toggle_switch/rwy_light_left", -1},
	["laminar/B738/switch/rwy_light_left_off"]					= { "off","laminar/B738/toggle_switch/rwy_light_left", -1},
	["laminar/B738/switch/rwy_light_left_toggle"]				= { "tgl","laminar/B738/toggle_switch/rwy_light_left", -1},
	["laminar/B738/switch/rwy_light_right_on"]					= { "on", "laminar/B738/toggle_switch/rwy_light_right", -1},
	["laminar/B738/switch/rwy_light_right_off"]					= { "off","laminar/B738/toggle_switch/rwy_light_right", -1},
	["laminar/B738/switch/rwy_light_right_toggle"]				= { "tgl","laminar/B738/toggle_switch/rwy_light_right", -1},
	["laminar/B738/switch/wing_light_on"]						= { "on", "laminar/B738/toggle_switch/wing_light", -1},
	["laminar/B738/switch/wing_light_off"]						= { "off","laminar/B738/toggle_switch/wing_light", -1},
	["laminar/B738/switch/wing_light_toggle"]					= { "tgl","laminar/B738/toggle_switch/wing_light", -1},
	["laminar/B738/switch/land_lights_ret_left_on"]				= { "on", "laminar/B738/switch/land_lights_ret_left_pos", -1},
	["laminar/B738/switch/land_lights_ret_left_off"]			= { "off","laminar/B738/switch/land_lights_ret_left_pos", -1},
	["laminar/B738/switch/land_lights_ret_right_on"]			= { "on", "laminar/B738/switch/land_lights_ret_right_pos", -1},
	["laminar/B738/switch/land_lights_ret_right_off"] 			= { "off","laminar/B738/switch/land_lights_ret_right_pos", -1},
	["laminar/B738/switch/land_lights_left_on"]					= { "on", "laminar/B738/switch/land_lights_left_pos", -1},
	["laminar/B738/switch/land_lights_left_off"]				= { "off","laminar/B738/switch/land_lights_left_pos", -1},
	["laminar/B738/switch/land_lights_right_on"]				= { "on", "laminar/B738/switch/land_lights_right_pos", -1},
	["laminar/B738/switch/land_lights_right_off"]				= { "off","laminar/B738/switch/land_lights_right_pos", -1},
	["laminar/B738/toggle_switch/position_light_steady"]		= { "on", "laminar/B738/toggle_switch/position_light_pos", -1},
	["laminar/B738/toggle_switch/position_light_off"]			= { "off","laminar/B738/toggle_switch/position_light_pos", -1},
	["laminar/B738/toggle_switch/position_light_strobe"]		= { "on", "laminar/B738/toggle_switch/position_light_pos", -1},
	["laminar/B738/toggle_switch/position_light_off"]			= { "off","laminar/B738/toggle_switch/position_light_pos", -1},
	["laminar/B738/toggle_switch/hydro_pumps1"]					= { "tgl","laminar/B738/toggle_switch/hydro_pumps1_pos", -1},
	["laminar/B738/toggle_switch/hydro_pumps2"]					= { "tgl","laminar/B738/toggle_switch/hydro_pumps2_pos", -1},
	["laminar/B738/toggle_switch/electric_hydro_pumps1"]		= { "tgl","laminar/B738/toggle_switch/electric_hydro_pumps1_pos", -1},
	["laminar/B738/toggle_switch/electric_hydro_pumps2"]		= { "tgl","laminar/B738/toggle_switch/electric_hydro_pumps2_pos", -1},
	["laminar/B738/door/fwd_L_toggle"]							= { "tgl","737u/doors/L1", -1},
	["laminar/B738/door/aft_L_toggle"]							= { "tgl","737u/doors/L2", -1},
	["laminar/B738/door/fwd_R_toggle"]							= { "tgl","737u/doors/R1", -1},
	["laminar/B738/door/aft_R_toggle"]							= { "tgl","737u/doors/R2", -1},
	["laminar/B738/door/fwd_cargo_toggle"]						= { "tgl","737u/doors/Fwd_Cargo", -1},
	["laminar/B738/door/aft_cargo_toggle"]						= { "tgl","737u/doors/aft_Cargo", -1},
	["laminar/B738/toggle_switch/crossfeed_valve_on"]			= { "on", "laminar/B738/knobs/cross_feed_pos", -1},
	["laminar/B738/toggle_switch/crossfeed_valve_off"]			= { "off","laminar/B738/knobs/cross_feed_pos", -1},
	["laminar/B738/switch/logo_light_on"]						= { "on", "laminar/B738/toggle_switch/logo_light", -1},
	["laminar/B738/switch/logo_light_off"]						= { "off","laminar/B738/toggle_switch/logo_light", -1},
	["laminar/B738/switch/logo_light_toggle"]					= { "tgl","laminar/B738/toggle_switch/logo_light", -1},
	["laminar/B738/toggle_switch/cockpit_dome_dn"]				= { "dn", "laminar/B738/toggle_switch/cockpit_dome_pos", -1},
	["laminar/B738/toggle_switch/cockpit_dome_up"]				= { "up", "laminar/B738/toggle_switch/cockpit_dome_pos", -1},
	["laminar/B738/toggle_switch/emer_exit_lights_dn"]			= { "dn", "laminar/B738/toggle_switch/emer_exit_lights", -1},
	["laminar/B738/toggle_switch/emer_exit_lights_up"]			= { "up", "laminar/B738/toggle_switch/emer_exit_lights", -1},
	["laminar/B738/button_switch_cover09"]						= { "tgl","laminar/B738/button_switch/cover_position", 9},
	["laminar/B738/knob/transponder_mode_dn"]					= { "dn", "laminar/B738/knob/transponder_pos", -1},
	["laminar/B738/knob/transponder_mode_up"]					= { "up", "laminar/B738/knob/transponder_pos", -1},
	["laminar/B738/toggle_switch/irs_L_left"]					= { "dn", "laminar/B738/toggle_switch/irs_left", -1},
	["laminar/B738/toggle_switch/irs_L_right"]					= { "up", "laminar/B738/toggle_switch/irs_left", -1},
	["laminar/B738/toggle_switch/irs_R_left"]					= { "dn", "laminar/B738/toggle_switch/irs_right", -1},
	["laminar/B738/toggle_switch/irs_R_right"]					= { "up", "laminar/B738/toggle_switch/irs_right", -1},
	["laminar/B738/toggle_switch/seatbelt_sign_dn"]				= { "dn", "laminar/B738/toggle_switch/seatbelt_sign_pos", -1},
	["laminar/B738/toggle_switch/seatbelt_sign_up"]				= { "up", "laminar/B738/toggle_switch/seatbelt_sign_pos", -1},
	["laminar/B738/toggle_switch/no_smoking_dn"]				= { "dn", "laminar/B738/toggle_switch/no_smoking_pos", -1},
	["laminar/B738/toggle_switch/no_smoking_up"]				= { "up", "laminar/B738/toggle_switch/no_smoking_pos", -1},
	["laminar/B738/switch/standby_bat_left"]					= { "dn", "laminar/B738/electric/standby_bat_pos", -1},
	["laminar/B738/switch/standby_bat_right"]					= { "up", "laminar/B738/electric/standby_bat_pos", -1},

}

local function lset (dref, idx, value)
	if idx == nil then
		set(dref,value)
	else
		set_array(dref,idx,value)
	end
end

function get(datarefname, index)
	if index ~= nil then
		if dataref_local_store[datarefname.."["..index.."]"] == nil then lset(datarefname,index,0) end
		if type(dataref_local_store[datarefname.."["..index.."]"]) == 'function' then
			return dataref_local_store[datarefname.."["..index.."]"]()
		else
			return dataref_local_store[datarefname.."["..index.."]"]
		end
	else
		if dataref_local_store[datarefname] == nil then lset(datarefname,0) end
		if type(dataref_local_store[datarefname]) == 'function' then
			return dataref_local_store[datarefname]()
		else
			return dataref_local_store[datarefname]
		end
		return dataref_local_store[datarefname]
	end
end

function dataref_table(datarefname, index)
	return 0
end

function dataref(datarefname, index)
	return 0
end

function set(datarefname, value)
	dataref_local_store[datarefname] = value
end
	
function set_array(datarefname, index, value)
	dataref_local_store[datarefname.."["..index.."]"] = value
end

function command_once(cmd) 
	
	print("Executing "..cmd)
	local cmds = command_store[cmd]
	if cmds[3] == -1 then cmds[3] = nil end
	
	if cmds[1] == "tgl" then
		if get(cmds[2],cmds[3]) == 0 then 
			lset(cmds[2],cmds[3],1)
		else
			lset(cmds[2],cmds[3],0)
		end
		
	elseif cmds[1] == "on" then
		lset(cmds[2],cmds[3],1)
			
	elseif cmds[1] == "off" then
		lset(cmds[2],cmds[3],0)
			
	elseif cmds[1] == "up" then
		if get(cmds[2],cmds[3]) == nil then lset(cmds[2],cmds[3],0) end
		lset(cmds[2],cmds[3],get(cmds[2],cmds[3])+1)
			
	elseif cmds[1] == "dn" then
		if get(cmds[2],cmds[3]) == nil then lset(cmds[2],cmds[3],1) end			
		lset(cmds[2],cmds[3],get(cmds[2],cmds[3])-1)
	end
		
end

function logMsg(text)
	print(text)
end

function dbgMsg(text)
	if DEBUGMODE then
		print(text)
	end
end

function renderDataRefs()
	dbgMsg("===== datarefs =====")
	for k, v in pairs(dataref_local_store) do
		if type(v) == 'function' then dbgMsg(k.."="..v()) else dbgMsg(k.."="..v) end  
	end
end
