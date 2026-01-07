-- Aircraft specific briefing values and functions - Default aircraft as base for all others
--
-- @author Kosta Prokopiu
-- @copyright 2025 Kosta Prokopiu

kc_acf_name 		= "X-Plane Default Aircraft"

-- === aircraft type
kc_is_airbus		= false		-- Aircraft is an Airbus
kc_is_boeing		= false		-- Aircraft is a Boeing
kc_is_zibo			= false
kc_is_ga			= false		-- Aircraft is general aviation
kc_is_turboprop		= false		-- Aircraft is turbo prop
if get("sim/aircraft2/metadata/is_cargo") == 1 then
	kc_is_cargo			= true		-- This is a cargo version
else
	kc_is_cargo			= false
end

-- === Electric system

-- === Controls
kc_NumFlapsTO		= 3
kc_TakeoffFlaps 	= "0|1|2| | | | "
kc_TakeoffFlapsInd 	= "0|1|2|2|2|2|2"
kc_NumFlapsLDG		= 3
kc_LandingFlaps 	= "0|1|2| | | | "
kc_LandingFlapsInd 	= "0|1|2|2|2|2|2"
kc_gear_ext_index	= 2			-- When to extend gear in flaps extend
kc_announce_flaps	= true 

-- === engines
-- kc_NumEngines		= -1		-- Number of engines from acf
-- kc_has_reversers	= true		-- Aircraft has reversers
-- kc_ab_engm_norm		= 1			-- Airbus engine mode norm
-- kc_ab_engm_strt		= 2			-- Airbus engine mode start
-- kc_ab_engm_crnk		= 0			-- Airbus engine mode crank
-- kc_has_rated_to		= false		-- Aircraft has rated thrust setting for T/O
-- kc_has_proplever	= false		-- Aircraft has prop lever
-- kc_prop_lvr_min		= 125		-- Prop lever Minimum
-- kc_prop_lvr_feather	= 105		-- Prop lever feather
-- kc_prop_lvr_max		= 178		-- Prop lever maximum
-- kc_has_mixlever		= false		-- Airctaft has mixture lever
-- kc_mixture_off		= 0
-- kc_mixture_min		= 0.4
-- kc_mixture_rich		= 1
-- kc_n2_after_start	= 40
-- kc_has_ignition		= true		-- has ignition switch
-- kc_needs_throttle_idle = true	-- Aircraft needs idle throttle on start
kc_StartSequence 	= "2 THEN 1|1 THEN 2"
kc_StartBackground	= { [1] = {"2", "1"}, [2] = {"1", "2"} }
kc_TakeoffThrust 	= "TOGA|FLEX|D-TO"

-- === Fuel
kc_fuel_ld_button	= true		-- Load the aircraft fuel from kpxbrief

-- === Hydraulics

-- === Air supply
kc_LandingPacks 	= "OFF|ON"
kc_TakeoffPacks 	= "OFF|ON"
kc_TakeoffBleeds 	= "OFF|ON"

-- === Anti Ice
kc_TakeoffAntiice 	= "OFF|ENGINE|ENGINE & WING"
kc_LandingAntiice 	= "OFF|ENGINE|ENGINE & WING"

-- === Payload & weights
kc_MaxRamp			= -1		-- Max Ramp weight
kc_DOW 				= -1		-- Dry Operating Weight (aka OEW)
kc_MZFW  			= -1		-- Maximum Zero Fuel Weight
kc_MaxPayload 		= -1		-- Maximum Payload to be set
kc_MTOW 			= -1		-- Maximum Takeoff Weight
kc_MLW  			= -1		-- Maximum Landing Weight
kc_pld_ld_button	= true		-- Load the aircraft payload from kpxbrief	

-- === MCP & autopilot
kc_TakeoffApModes 	= "HDG/FLCH|LNAV/VNAV"
kc_apptypes 		= "ILS CAT 1|ILS CAT 2 OR 3|VOR|NDB|RNAV|VISUAL|TOUCH AND GO|CIRCLING"
kc_show_ilsfrq_btn	= true		-- can set frequency

-- === other options
kc_can_load_speeds	= false		-- Aircraft can pass speeds to kpxbrief
kc_LandingAutoBrake = "OFF|1|2|3|MAX"
kc_LandingAutoBrInd = "1|2|3|4|5"

-- === Callouts
kc_callout_v1		= false
kc_callout_vr		= false
kc_callout_v2		= false

-- === Operating speeds
kc_speeds_vs0		= -1		-- Stall Speed, Landing Configuration from ACF
kc_speeds_vs1		= -1		-- Stall Speed, Clean (near landing speed)
kc_speeds_vs		= -1		-- Minimum Controllable Speed from ACF

kc_speeds_vx		= 270		-- Best Angle of Climb - set for aircraft
kc_speeds_vy		= 300		-- Best Rate of Climb - set for aircraft
kc_speeds_vr		= 125		-- Rotation speed - set for each aircraft

kc_speeds_vfe		= -1		-- Maximum flaps Extended Speed 

kc_speeds_vmo1		= -1		-- Maximum Operating Speed (Sea Level to 8,000 ft) 
kc_speeds_vmo2		= -1		-- Maximum Operating Speed (Above 8,000 ft) 
kc_speeds_vmo3		= -1		-- Maximum Mach Number 

kc_speeds_vle		= -1		-- Maximum Gear Operating Speed Vle from ACF
kc_speeds_vlo		= -1		-- Maximum Gear Extended Speed vle+20 if not known

kc_speeds_vne		= -1		-- V never exceed from acf
kc_speeds_vno		= -1		-- V maximum ctructural speed from acf 

-- === Altitudes
kc_max_altitude		= 40000 	-- Max Altitude

-- ======= Aircraft specific functions

-- Maximum takeoff weight as approximation = max aircraft weight
function kc_get_MaxRampWeight()
	if kc_MaxRamp == -1 then
		kc_MaxRamp = get("sim/aircraft/weight/acf_m_max")
	end
	if activePrefSet:get("general:weight_kgs") then
		return kc_MaxRamp
	else
		return kc_MaxRamp * 2.20462262
	end
end

-- Get Dry Operating Weight. 
-- use Empty Weight if not specified
function kc_get_DOW()
	if kc_DOW == -1 then
		kc_DOW = get("sim/aircraft/weight/acf_m_empty")
	end
	if activePrefSet:get("general:weight_kgs") then
		return kc_DOW
	else
		return kc_DOW * 2.20462262
	end
end

-- Maximum Fuel Capacity
function kc_get_MaxFuel()
	if kc_MaxFuel == -1 then
		kc_MaxFuel = get("sim/aircraft/weight/acf_m_fuel_tot")
	end
	if activePrefSet:get("general:weight_kgs") then
		return kc_MaxFuel
	else
		return kc_MaxFuel * 2.20462262
	end
end

-- Maximum Zero Fuel Weight
-- Calculated from max weight - max fuel weight
function kc_get_MZFW()
	if kc_MZFW == -1 then
		kc_MZFW = kc_get_MaxRampWeight() - kc_get_MaxFuel()
	end
	if activePrefSet:get("general:weight_kgs") then
		return kc_MZFW
	else
		return kc_MZFW * 2.20462262
	end
end

-- Maximum takeoff weight as approximation = max aircraft weight
-- if not specified we use Max Ramp Weight
function kc_get_MTOW()
	if kc_MTOW == -1 then
		kc_MTOW = kc_get_MaxRampWeight()
	end
	if activePrefSet:get("general:weight_kgs") then
		return kc_MTOW
	else
		return kc_MTOW * 2.20462262
	end
end

-- Maximum Landing Weight as approximation 80% of MTOW
function kc_get_MLW()
	if kc_MLW == -1 then
		kc_MLW = kc_MTOW * 0.8
	end
	if activePrefSet:get("general:weight_kgs") then
		return kc_MLW
	else
		return kc_MLW * 2.20462262
	end
end

-- Maximum Payload Weight 
function kc_get_MaxPayload()
	if kc_MaxPayload == -1 then
		kc_MaxPayload = kc_get_MaxRampWeight() - kc_get_DOW() - kc_get_MaxFuel()
	end
	if activePrefSet:get("general:weight_kgs") then
		return kc_MaxPayload
	else
		return kc_MaxPayload * 2.20462262
	end
end

-- Current Payload WEIGHT
function kc_get_Payload()
	if activePrefSet:get("general:weight_kgs") then
		return get("sim/flightmodel/weight/m_fixed")
	else
		return get("sim/flightmodel/weight/m_fixed") * 2.20462262
	end
end

-- Get current gross weight
function kc_get_gross_weight()
	if activePrefSet:get("general:weight_kgs") then
		return get("sim/flightmodel/weight/m_total")
	else
		return get("sim/flightmodel/weight/m_total")*2.20462262
	end	
end
	
-- Get current overall fuel flow
function kc_get_FFPH()
	if activePrefSet:get("general:weight_kgs") then
		return kc_FFPH
	else
		return kc_FFPH * 2.20462262
	end
end

-- Get total fuel loaded
function kc_get_total_fuel()
	if activePrefSet:get("general:weight_kgs") then
		return get("sim/flightmodel/weight/m_fuel_total")
	else
		return get("sim/flightmodel/weight/m_fuel_total")*2.20462262
	end
end

-- Get fuel loaded in up to 9 tanks kgs
function kc_get_tank_weight(tanknr)
	if activePrefSet:get("general:weight_kgs") then
		return get("sim/cockpit2/fuel/fuel_quantity", tanknr)
	else
		return get("sim/cockpit2/fuel/fuel_quantity", tanknr)*2.20462262
	end
end

-- Get max fuel level per tank
function kc_get_MFL(tanknr)
	if kc_MFL[tanknr] == -1 then
		kc_MFL[tanknr] = kc_get_MaxFuel() * get("sim/aircraft/overflow/acf_tank_rat",tanknr)
	end
	if activePrefSet:get("general:weight_kgs") then
		return kc_MFL[tanknr]
	else
		return kc_MFL[tanknr]*2.20462262
	end
end

-- Calculate current ZFW
function kc_get_zfw()
	return kc_get_gross_weight()-kc_get_total_fuel()
end


-- get number of engines
function kc_get_nr_engines()
	if kc_num_engines == -1 then
		kc_num_engines = get("sim/aircraft/engine/acf_num_engines")
	end
	return kc_num_engines
end

-- get number of batteries
function kc_get_nr_batteries()
	if kc_NumBatteries == -1 then
		kc_NumBatteries = get("sim/aircraft/electrical/num_batteries")
	end
	return kc_NumBatteries
end

-- get number of generators
function kc_get_nr_generators()
	if kc_NumGenerators == -1 then
		kc_NumGenerators = get("sim/aircraft/electrical/num_generators")
	end
	return kc_NumGenerators
end

-- get number of inverters
function kc_get_nr_inverters()
	if kc_NumInverters == -1 then
		kc_NumInverters = get("sim/aircraft/electrical/num_inverters")
	end
	return kc_NumInverters
end

-- get number of flap detents
function kc_get_nr_flapdetents()
	if kc_Numflap_detents == -1 then
		kc_Numflap_detents = get("sim/aircraft/controls/acf_flap_detents")
	end
	return kc_Numflap_detents
end

-- ==================== speeds

-- Maximum flaps Extended Speed VFe
function kc_get_VFe()
	if kc_speeds_vfe == -1 then
		kc_speeds_vfe = get("sim/aircraft/view/acf_Vfe")
	end
	return kc_speeds_vfe
end

-- Maximum Gear Extend Speed Vle
function kc_get_VLe()
	if kc_speeds_vle == -1 then
		kc_speeds_vle = get("sim/aircraft/view/acf_Vle")
	end
	return kc_speeds_vle
end

-- Maximum Gear Operating Speed Vlo
function kc_get_VLo()
	if kc_speeds_vlo == -1 then
		kc_speeds_vlo = get("sim/aircraft/view/acf_Vle") + 20
	end
	return kc_speeds_vlo
end

-- Maximum controllable speed VS
function kc_get_VS()
	if kc_speeds_vs == -1 then
		kc_speeds_vs = get("sim/aircraft/view/acf_Vs")
	end
	return kc_speeds_vs
end

-- Maximum Velocity Stall landing configuration
function kc_get_VS0()
	if kc_speeds_vs0 == -1 then
		kc_speeds_vs0 = get("sim/aircraft/view/acf_Vso")
	end
	return kc_speeds_vs0
end

-- Maximum Velocity Stall clean vs1
function kc_get_VS1()
	if kc_speeds_vs1 == -1 then
		kc_speeds_vs1 = get("sim/aircraft/view/acf_Vs") + 20
	end
	return kc_speeds_vs1
end

-- V never exceed Vne
function kc_get_Vne()
	if kc_speeds_vne == -1 then
		kc_speeds_vne = get("sim/aircraft/view/acf_Vne")
	end
	return kc_speeds_vne
end

-- V max structural speed Vno
function kc_get_Vno()
	if kc_speeds_vno == -1 then
		kc_speeds_vno = get("sim/aircraft/view/acf_Vno")
	end
	return kc_speeds_vno
end

-- V max operating speed < 8000
function kc_get_Vmo1()
	if kc_speeds_vmo1 == -1 then
		kc_speeds_vmo1 = get("sim/aircraft/view/acf_Vno") - 10
	end
	return kc_speeds_vmo1
end

-- V max operating speed < 8000
function kc_get_Vmo2()
	if kc_speeds_vmo2 == -1 then
		kc_speeds_vmo2 = get("sim/aircraft/view/acf_Vno")
	end
	return kc_speeds_vmo2
end

-- V max mach number
function kc_get_Vmo3()
	if kc_speeds_vmo3 == -1 then
		kc_speeds_vmo3 = get("sim/aircraft/engine/acf_max_mach_eff")
	end
	return kc_speeds_vmo3
end

-- ========================== weights

-- Set the payload for the aircraft
function kc_set_payload(payload)
	if payload > kc_get_MaxPayload() then 
		payload = kc_get_MaxPayload()
	end
	set("sim/flightmodel/weight/m_fixed",payload)
end

-- Set the fuel for the aircraft
function kc_set_fuel(totalfuel)
	if totalfuel > kc_get_MaxFuel() then 
		totalfuel = kc_get_MaxFuel()
	end
	set_array("sim/flightmodel/weight/m_fuel",0,0)
	set_array("sim/flightmodel/weight/m_fuel",1,0)
	set_array("sim/flightmodel/weight/m_fuel",2,0)
	set_array("sim/flightmodel/weight/m_fuel",3,0)
	set_array("sim/flightmodel/weight/m_fuel",4,0)
	if kc_get_nr_tanks() == 1 then 
		set_array("sim/flightmodel/weight/m_fuel",kc_FuelTankCntrInd,totalfuel)
		set_array("sim/flightmodel/weight/m_fuel",kc_FuelTankLeftInd,0)
		set_array("sim/flightmodel/weight/m_fuel",kc_FuelTankRghtInd,0)
	elseif kc_get_nr_tanks() == 2 then 
		set_array("sim/flightmodel/weight/m_fuel",kc_FuelTankLeftInd,totalfuel/2)
		set_array("sim/flightmodel/weight/m_fuel",kc_FuelTankRghtInd,totalfuel/2)
		set_array("sim/flightmodel/weight/m_fuel",kc_FuelTankCntrInd,0)
	elseif kc_get_nr_tanks() == 3 then 
		if kc_get_MFL(kc_FuelTankLeftInd) + kc_get_MFL(kc_FuelTankRghtInd) < totalfuel then 
			set_array("sim/flightmodel/weight/m_fuel",kc_FuelTankLeftInd,kc_get_MFL(kc_FuelTankLeftInd))
			set_array("sim/flightmodel/weight/m_fuel",kc_FuelTankRghtInd,kc_get_MFL(kc_FuelTankRghtInd))
			set_array("sim/flightmodel/weight/m_fuel",kc_FuelTankCntrInd,totalfuel - (kc_get_MFL(kc_FuelTankLeftInd) + kc_get_MFL(kc_FuelTankRghtInd)))
		else
			set_array("sim/flightmodel/weight/m_fuel",kc_FuelTankLeftInd,totalfuel/2)
			set_array("sim/flightmodel/weight/m_fuel",kc_FuelTankRghtInd,totalfuel/2)
			set_array("sim/flightmodel/weight/m_fuel",kc_FuelTankCntrInd,0)
		end
	end
end

-- get MAC% CG from x-plane
function kc_get_mac_cg()
	return get("sim/flightmodel2/misc/cg_offset_z_mac")
end

-- set the takeoff details v-speeds, trim from the aircraft if available
function kc_set_takeoff_details()
	-- activeBriefings:set("takeoff:v1",get(""))
	-- activeBriefings:set("takeoff:vr",get(""))
	-- activeBriefings:set("takeoff:v2",get(""))
	-- activeBriefings:set("takeoff:elevatorTrim",get(""))
end

-- set the landing details v-speeds, trim from aircraft if available
function kc_set_landing_details()
	-- activeBriefings:set("approach:vref",get(""))
	-- activeBriefings:set("approach:vapp",get("")+5)
end