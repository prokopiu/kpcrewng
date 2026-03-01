require "kpcrew.Addon.Preferences.PreferenceDataType"

local preferenceSet = require( "kpcrew.Addon.Preferences.PreferenceSet" )
local preferenceGroup = require( "kpcrew.Addon.Preferences.PreferenceGroup" )
local preference = require("kpcrew.Addon.Preferences.PreferenceItem")

local aircraftPrefSet = preferenceSet:new("DFLT","DEFAULT AIRCRAFT",SCRIPT_DIRECTORY .. "../Modules/kpcrew_prefs/DFLT.preferences")

local addon = preferenceGroup:new("addon","ADDON PREFERENCES")
addon:add(preference:new("icao","DFLT",ng_type_text,"Aircraft ICAO in use|"))
addon:add(preference:new("aircraftname","DEFAULT AIRCRAFT",ng_type_text,"Aircraft name|"))
addon:add(preference:new("filepath",SCRIPT_DIRECTORY.."../Modules/kpcrew_prefs/DFLT.preferences",ng_type_text,"Preference filepath|"))

-- -------- General settings not associated with a preference group --------
local general = preferenceGroup:new("general","GENERAL PREFERENCES")
general:add(preference:new("iscargo",false,ng_type_flag,"Is Cargo Aircraft?|Yes|No"))
general:add(preference:new("hasautobrk",false,ng_type_flag,"Has Autobrake?|Yes|No"))
general:add(preference:new("hasgroundobj",false,ng_type_flag,"Has Ground Objects?|Yes|No"))
general:add(preference:new("haswipers",false,ng_type_flag,"Has Wipers?|Yes|No"))
general:add(preference:new("hasseatbelts",false,ng_type_flag,"Has Seatbelt Signs?|Yes|No"))
general:add(preference:new("hasnosmoking",false,ng_type_flag,"Has No Smoking Signs?|Yes|No"))
-- autobreak related setting
general:add(preference:new("abrkmodelblt","|RTO|OFF|1|2|3|4",ng_type_text,"A/BRK Labels|",nil,"return ng_getAcfPrefs():get(\"general:hasautobrk\")"))
general:add(preference:new("abrkmodevals","|0|1|2|3|4|5",ng_type_text,"A/BRK Values|",nil,"return ng_getAcfPrefs():get(\"general:hasautobrk\")"))
general:add(preference:new("abrkoffval",1,ng_type_int,"A/BRK OFF Value|0",nil,"return ng_getAcfPrefs():get(\"general:hasautobrk\")"))
general:add(preference:new("abrktroval",0,ng_type_int,"A/BRK RTO Value|0",nil,"return ng_getAcfPrefs():get(\"general:hasautobrk\")"))

-- ----------------------- Anti-Ice related settings ------------------------
local aice = preferenceGroup:new("aice","ANTI ICE SYSTEMS")
-- aice:add(preference:new("hasengaice",true,ng_type_flag,"Has Engine A-Ice|Yes|No"))
-- aice:add(preference:new("haswingaice",true,ng_type_flag,"Has Wing A-Ice|Yes|No"))
-- aice:add(preference:new("haswinheat",true,ng_type_flag,"Has Window Heat|Yes|No"))
-- aice:add(preference:new("haspitotheat",true,ng_type_flag,"Has Pitot Heat|Yes|No"))
-- AICE briefing
aice:add(preference:new("takeoffaice","|OFF|ENGINE|ENGINE & WING",ng_type_text,"Takeoff A-Ice|"))
aice:add(preference:new("landingaice","|OFF|ENGINE|ENGINE & WING",ng_type_text,"Landing A-Ice|"))

-- -------------------------- Air related settings --------------------------
local air = preferenceGroup:new("air","AIR SUPPLY SYSTEMS")
air:add(preference:new("hastempcontrol",false,ng_type_flag,"Has Temp Control|Yes|No"))
air:add(preference:new("hastrimair",false,ng_type_flag,"Has Trim Air?|Yes|No"))
air:add(preference:new("hasrecircfans",false,ng_type_flag,"Has Recirc Fans?|Yes|No"))
air:add(preference:new("hasenginebleeds",false,ng_type_flag,"Has Engine Bleds?|Yes|No"))
air:add(preference:new("hasoxygen",false,ng_type_flag,"Oxygen Supply?|Yes|No"))

-- air:add(preference:new("haspressurecab",true,ng_type_flag,"Pressure Cabin?|Yes|No"))
-- air:add(preference:new("numpacks",2,ng_type_int,"# Packs|0"))
-- air:add(preference:new("numengbleeds",2,ng_type_int,"# Engine Bleeds|0"))
-- air:add(preference:new("hasapubleed",false,ng_type_flag,"APU Bleed?|Yes|No"))
-- air:add(preference:new("hasgasper",false,ng_type_flag,"Gasper Ctrl?|Yes|No"))
-- air:add(preference:new("numisovalves",1,ng_type_int,"# Isolation Valves|0"))
-- air:add(preference:new("hasequipcool",false,ng_type_flag,"Equip Cool?|Yes|No"))
-- air:add(preference:new("numcargoheat",0,ng_type_int,"# Cargo Heat|0"))
-- air:add(preference:new("haslandalt",false,ng_type_flag,"Landing Alt?|Yes|No"))
-- air:add(preference:new("hasflightalt",false,ng_type_flag,"Flight Alt?|Yes|No"))
air:add(preference:new("takeoffpacks",2,ng_type_list,"Takeoff Packs|OFF|ON"))
air:add(preference:new("landingpacks",2,ng_type_list,"Landing Packs|OFF|ON"))
air:add(preference:new("takeoffbleeds",2,ng_type_list,"Takeoff Bleeds|ON|OFF"))
air:add(preference:new("landingbleeds",2,ng_type_list,"Landing Bleeds|ON|OFF"))

-- ----------------------- Autopilot related settings -----------------------
local autopilot = preferenceGroup:new("autopilot","AUTOPILOT")
autopilot:add(preference:new("hasirs",false,ng_type_flag,"Has IRS?|Yes|No"))
autopilot:add(preference:new("irsoff",0,ng_type_int,"IRS OFF INDX|0",nil,"return ng_getAcfPrefs():get(\"autopilot:hasirs\")"))
autopilot:add(preference:new("irsalign",1,ng_type_int,"IRS ALIGN INDX|0",nil,"return ng_getAcfPrefs():get(\"autopilot:hasirs\")"))
autopilot:add(preference:new("irsnav",2,ng_type_int,"IRS NAV INDX|0",nil,"return ng_getAcfPrefs():get(\"autopilot:hasirs\")"))
autopilot:add(preference:new("irsatt",3,ng_type_int,"IRS ATT INDX|0",nil,"return ng_getAcfPrefs():get(\"autopilot:hasirs\")"))

-- autopilot:add(preference:new("numfdirs",1,ng_type_int,"# Flight Dirs?|0"))
-- autopilot:add(preference:new("numautopilots",1,ng_type_int,"# Autopilots?|0"))
-- autopilot:add(preference:new("hasalthold",true,ng_type_flag,"A/P Alt Hold?|Yes|No"))
-- autopilot:add(preference:new("hasaltsel",false,ng_type_flag,"A/P Alt Select?|Yes|No"))
-- autopilot:add(preference:new("hashdgsel",true,ng_type_flag,"A/P Hdg Select?|Yes|No"))
-- autopilot:add(preference:new("hasvorloc",true,ng_type_flag,"A/P Alt LOC?|Yes|No"))
-- autopilot:add(preference:new("hasapp",true,ng_type_flag,"A/P Approach?|Yes|No"))
-- autopilot:add(preference:new("hasvs",true,ng_type_flag,"A/P Vertical Spd?|Yes|No"))
-- autopilot:add(preference:new("hasspdias",true,ng_type_flag,"A/P SPD/IAS?|Yes|No"))
-- autopilot:add(preference:new("hasathr",false,ng_type_flag,"A/P Autothrottle?|Yes|No"))
-- autopilot:add(preference:new("hasils",true,ng_type_flag,"A/P ILS?|Yes|No"))
-- autopilot:add(preference:new("hasattoga",true,ng_type_flag,"A/T TOGA?|Yes|No"))
-- autopilot:add(preference:new("haslnav",false,ng_type_flag,"A/P LNAV?|Yes|No"))
-- autopilot:add(preference:new("hasvnav",false,ng_type_flag,"A/P VNAV?|Yes|No"))
-- autopilot:add(preference:new("hasflch",false,ng_type_flag,"A/P FLCH?|Yes|No"))
-- autopilot:add(preference:new("hasn1",false,ng_type_flag,"A/P N1?|Yes|No"))
-- autopilot:add(preference:new("hasspdintv",false,ng_type_flag,"A/P Speed Intv?|Yes|No"))
-- autopilot:add(preference:new("hasaltintv",false,ng_type_flag,"A/P Alt Intv?|Yes|No"))
-- autopilot:add(preference:new("hasyawdamper",true,ng_type_flag,"A/P Yawdamper?|Yes|No"))
-- autopilot:add(preference:new("hasturnrate",false,ng_type_flag,"A/P Turnrate?|Yes|No"))
-- autopilot:add(preference:new("numcws",0,ng_type_int,"# CWS?|0"))

-- Anything associated to flight controls
local controls = preferenceGroup:new("controls","FLIGHT CONTROLS")
controls:add(preference:new("hasspdbreak",true,ng_type_flag,"Has Speedbreak?|Yes|No"))
controls:add(preference:new("spdbreakarms",false,ng_type_flag,"Speedbreak Arms?|Yes|No",nil,"return ng_getAcfPrefs():get(\"controls:hasspdbreak\")"))
controls:add(preference:new("spdbreakapos",0.0889,ng_type_float,"SpdBreak Arm Pos|0|%6.2f",nil,"return ng_getAcfPrefs():get(\"controls:spdbreakarms\")"))


controls:add(preference:new("flapsdetents",8,ng_type_int,"Flaps Detents|0"))
controls:add(preference:new("flapspos","|0|0.125|0.25|0.375|0.5|0.625|0.75|0.875|1",ng_type_text,"Flaps Positions"))
controls:add(preference:new("flapsspd","|230|200|180|160|155|155|150|150|150",ng_type_text,"Flaps Speeds"))
controls:add(preference:new("flapsnames","|UP|1|2|5|10|15|25|30|40",ng_type_text,"Flaps Names"))
controls:add(preference:new("numtoflaps",5,ng_type_int,"# T/O Flaps|0"))
controls:add(preference:new("toflapslbl","|UP|1|5|10|15",ng_type_text,"T/O Flaps Lbls"))
controls:add(preference:new("toflapsind","|1|2|3|4|5",ng_type_text,"T/O Flaps Index|"))
controls:add(preference:new("numldflaps",3,ng_type_int,"# LDG Flaps|0"))
controls:add(preference:new("ldflapslbl","|25|30|40",ng_type_text,"LDG Flaps|"))
controls:add(preference:new("ldflapsind","|6|7|8",ng_type_text,"LDG Flaps Index|"))
-- controls:add(preference:new("gearextind",4,ng_type_int,"Gear extend ldg|0"))
-- controls:add(preference:new("announceflaps",false,ng_type_flag,"Announce Flaps?|Yes|No"))
-- controls:add(preference:new("armspdbrkto",false,ng_type_flag,"Arm Speedbreak T/O?|Yes|No"))
-- controls:add(preference:new("haspitchtrim",true,ng_type_flag,"Pitchtrim?|Yes|No"))
-- controls:add(preference:new("hasailtrim",true,ng_type_flag,"Aileron Trim?|Yes|No"))
-- controls:add(preference:new("hasruddtrim",true,ng_type_flag,"Rudder Trim?|Yes|No"))
-- controls:add(preference:new("rudderidx",0,ng_type_int,"Index of rudder axis|0"))
-- controls:add(preference:new("rudderfullrgt",14.9,ng_type_float,"Rudder full right|0|%6.2f"))

-- EFIS
local efis = preferenceGroup:new("efis","EFIS")
-- efis:add(preference:new("hasmap",true,ng_type_flag,"ND MAP?|Yes|No"))
-- efis:add(preference:new("haswxr",false,ng_type_flag,"ND WXR?|Yes|No"))
-- efis:add(preference:new("hastfc",false,ng_type_flag,"ND Traffic?|Yes|No"))
-- efis:add(preference:new("hasterrain",false,ng_type_flag,"ND Terrain?|Yes|No"))
-- efis:add(preference:new("hasfpv",false,ng_type_flag,"FPV?|Yes|No"))
-- efis:add(preference:new("hasmeters",false,ng_type_flag,"PFD Meters?|Yes|No"))
-- efis:add(preference:new("numvoradf",0,ng_type_int,"# VORADF?|0"))
-- efis:add(preference:new("numranges",7,ng_type_int,"# MAP Ranges|0"))
-- efis:add(preference:new("mapranges",1,ng_type_list,"MAP Ranges|5|10|20|40|80|160|320|640"))
-- efis:add(preference:new("nummodes",4,ng_type_int,"# MAP Modes|0"))
-- efis:add(preference:new("mapmodes",1,ng_type_list,"MAP Modes|APP|VOR|MAP|PLAN"))
-- efis:add(preference:new("minstype",1,ng_type_list,"Minimums?|Radio|Baro"))
-- efis:add(preference:new("defbarunit",1,ng_type_list,"Baro Unit?|MB|INHG"))
-- efis:add(preference:new("numbaros",2,ng_type_int,"# Baro Dials|0"))

-- ----------------------- Electric related settings ------------------------
local electric = preferenceGroup:new("electric","ELECTRIC SYSTEMS")
electric:add(preference:new("hasstbypower",false,ng_type_flag,"Has Standby Power|Yes|No"))
electric:add(preference:new("hasgpu",false,ng_type_flag,"Has GPU?|Yes|No"))
electric:add(preference:new("hasapu",false,ng_type_flag,"Has APU?|Yes|No"))
electric:add(preference:new("apun1run",98,ng_type_int,"APU N1 running|0",nil,"return ng_getAcfPrefs():get(\"electric:apun1run\")"))
electric:add(preference:new("hascabinpwr",false,ng_type_flag,"Has Cabin Power?|Yes|No"))
electric:add(preference:new("hasifepwr",false,ng_type_flag,"Has IFE Power?|Yes|No"))
-- electric:add(preference:new("numgenerators",2,ng_type_int,"# Generators|0"))
-- electric:add(preference:new("numinverters",0,ng_type_int,"# Inverters|0"))
-- electric:add(preference:new("numgpugens",1,ng_type_int,"# GPU Generators|0"))
-- electric:add(preference:new("numapugens",1,ng_type_int,"# APU Generators|0"))
-- electric:add(preference:new("numavionics",0,ng_type_int,"# Avionics Switch|0"))
-- electric:add(preference:new("hasdcbustie",true,ng_type_flag,"DC Bustie?|Yes|No"))
-- electric:add(preference:new("hasacbustie",false,ng_type_flag,"AC Bustie?|Yes|No"))

-- ----------------------- Engines related settings ------------------------
local engines = preferenceGroup:new("engines","ENGINE SYSTEMS")
engines:add(preference:new("startseq",1,ng_type_list,"Start Sequence|2 THEN 1|1 THEN 2|"))
engines:add(preference:new("hasfiretests",false,ng_type_flag,"Has Fire Test?|Yes|No"))

-- engines:add(preference:new("numengines",2,ng_type_int,"# Engines|0"))
-- engines:add(preference:new("numignition",2,ng_type_int,"# Ignition|0"))
-- engines:add(preference:new("numreversers",2,ng_type_int,"# Reversers|0"))
-- engines:add(preference:new("nummagnetos",2,ng_type_int,"# Magnetos|0"))
-- engines:add(preference:new("hasproplvr",false,ng_type_flag,"Prop Levers?|Yes|No"))
-- engines:add(preference:new("hasmixlvr",false,ng_type_flag,"Mixture Levers?|Yes|No"))
engines:add(preference:new("tothrust",1,ng_type_list,"Takeoff Thrust|OPTIMUM|D-TO|D-TO1|D-TO2"))
-- engines:add(preference:new("hasratedto",false,ng_type_flag,"Rated Takeoff?|Yes|No"))
-- engines:add(preference:new("throttleidle",true,ng_type_flag,"Idle Throttle @ Start?|Yes|No"))
-- engines:add(preference:new("propmin",125,ng_type_int,"Prop Min Pos|0"))
-- engines:add(preference:new("propmax",178,ng_type_int,"Prop Max Pos|0"))
-- engines:add(preference:new("propfeather",105,ng_type_int,"Prop Feather Pos|0"))
-- engines:add(preference:new("mixoff",0,ng_type_float,"Mixture Off Pos|0|%4.1f"))
-- engines:add(preference:new("mixmin",0.4,ng_type_float,"Mixture Min Pos|0|%4.1f"))
-- engines:add(preference:new("mixrich",1,ng_type_float,"Mixture Rich Pos|0|%4.1f"))
-- engines:add(preference:new("n2start",40,ng_type_float,"N2 after Start|0|%4.1f"))

-- ------------------------- Fuel related settings ---------------------------
local fuel = preferenceGroup:new("fuel","FUEL SYSTEMS")
fuel:add(preference:new("canloadfuel",true,ng_type_flag,"Can load fuel?|Yes|No"))
fuel:add(preference:new("hasfuelxfeed",false,ng_type_flag,"Has Fuel Crossfeeds|Yes|No"))
-- fuel:add(preference:new("numfueltanks",2,ng_type_int,"# Fuel Tanks|0"))
-- fuel:add(preference:new("numfuelpumps",2,ng_type_int,"# Fuel Pumps|0"))
-- fuel:add(preference:new("hasfuelselect",false,ng_type_flag,"Fuel Select?|Yes|No"))
-- fuel:add(preference:new("numfuelcutoff",2,ng_type_int,"# Fuel Cutoffs|0"))

-- ----------------------- Hydraulic related settings -----------------------
local hydraulic = preferenceGroup:new("hydraulic","HYDRAULIC SYSTEMS")
hydraulic:add(preference:new("hashydelecpmps",false,ng_type_flag,"Has Electric Hyd Pumps|Yes|No"))
-- hydraulic:add(preference:new("numhydengpmps",2,ng_type_int,"# Engine Hyd Pumps|0"))
-- hydraulic:add(preference:new("hasptu",false,ng_type_flag,"PTU?|Yes|No"))
-- hydraulic:add(preference:new("hasrat",false,ng_type_flag,"RAT?|Yes|No"))

-- ----------------------- Light related settings ------------------------
local lights = preferenceGroup:new("lights","LIGHTS")
lights:add(preference:new("hasbeacon",true,ng_type_flag,"Has Beacon Lights?|Yes|No"))
lights:add(preference:new("numbeaconlts",1,ng_type_int,"# Beacons|0",nil,"return ng_getAcfPrefs():get(\"lights:hasbeacon\")"))
lights:add(preference:new("hasdomelts",true,ng_type_flag,"Has Dome Lights|Yes|No"))
lights:add(preference:new("hasemerlts",false,ng_type_flag,"Has Emergency Lights|Yes|No"))

-- lights:add(preference:new("numnavlts",1,ng_type_int,"# NAV Lights|0"))
-- lights:add(preference:new("numstrobelts",1,ng_type_int,"# Strobe Lights|0"))
-- lights:add(preference:new("numtaxilts",1,ng_type_int,"# Taxi Lights|0"))
-- lights:add(preference:new("numldglts",2,ng_type_int,"# Landing Lights|0"))
-- lights:add(preference:new("numwinglts",1,ng_type_int,"# Wing Lights|0"))
-- lights:add(preference:new("numwheellts",1,ng_type_int,"# Wheel Lights|0"))
-- lights:add(preference:new("numlogolts",1,ng_type_int,"# Logo Lights|0"))
-- lights:add(preference:new("numrwylts",1,ng_type_int,"# Runway Lights|0"))
-- lights:add(preference:new("numinstrlts",6,ng_type_int,"# Instrument Lights|0"))
-- lights:add(preference:new("numpanellts",6,ng_type_int,"# Panel Lights|0"))

-- Weight settings
local weights = preferenceGroup:new("weights","WEIGHTS")
weights:add(preference:new("canloadpld",true,ng_type_flag,"Can load payload?|Yes|No"))
weights:add(preference:new("maxramp",-1,ng_type_int,"Max Ramp Weight|0"))
weights:add(preference:new("dow",-1,ng_type_int,"Dry Operating Weight|0"))
weights:add(preference:new("maxzfw",-1,ng_type_int,"Max ZFW|0"))
weights:add(preference:new("maxtow",-1,ng_type_int,"Max TOW|0"))
weights:add(preference:new("maxldw",-1,ng_type_int,"Max LDW|0"))
weights:add(preference:new("maxpayload",-1,ng_type_int,"Max Payload|0"))
weights:add(preference:new("maxfuel",-1,ng_type_int,"Max Fuel|0"))


-- ng_apptypes 		= "ILS CAT 1|ILS CAT 2 OR 3|VOR|NDB|RNAV|VISUAL|TOUCH AND GO|CIRCLING"

-- flap detents for this aircraft
-- ng_flaps_pos 	= {[1] =   0, [2] = 0.125, [3] = 0.25, [4] = 0.375, [5] = 0.5, [6] = 0.625, [7] = 0.75, [8] = 0.875, [9] = 1}
-- ng_flaps_spd 	= {[1] = 230, [2] =   200, [3] =  180, [4] =   160, [5] = 155, [6] =   155, [7] =  150, [8] =   150, [9] = 150}
-- ng_flaps_name 	= {[1] = "UP",[2] =   "1", [3] =  "2", [4] =   "5", [5] = "10",[6] = "15",  [7] =  "25", [8] = "30", [9] = "40"}
-- ng_flaps_idx 	= {      "UP",        "1",        "2",         "5",       "10",      "15",         "25",       "30",       "40"}

-- ng_start_seq	= { [1] = {"2", "1"}, [2] = {"1", "2"} }

aircraftPrefSet:addGroup(addon)
aircraftPrefSet:addGroup(general)
aircraftPrefSet:addGroup(aice)
aircraftPrefSet:addGroup(air)
aircraftPrefSet:addGroup(autopilot)
aircraftPrefSet:addGroup(controls)
aircraftPrefSet:addGroup(electric)
aircraftPrefSet:addGroup(engines)
aircraftPrefSet:addGroup(efis)
aircraftPrefSet:addGroup(fuel)
aircraftPrefSet:addGroup(hydraulic)
aircraftPrefSet:addGroup(lights)
aircraftPrefSet:addGroup(weights)

local function custom_load()
	-- ng_getAcfPrefs():find("general:abrkmodes"):setTitle("A/BRK|"..ng_getAcfPrefs():get("general:abrkmodelblt"))
end

aircraftPrefSet:setCustomLoad(custom_load)

--- return the active aircraft preference set
-- @return PreferenceSet - acf preferences
function ng_getAcfPrefs()
	return aircraftPrefSet
end

-- ======= Aircraft specific functions =======

-- ==== Weight related functions ===

--- Maximum takeoff weight as approximation = max aircraft weight
-- @return int maximum ramp weight
function ng_get_MaxRampWeight()
	local maxramp = ng_getAcfPrefs():get("weights:maxramp")
	if maxramp == -1 then
		maxramp = get("sim/aircraft/weight/acf_m_max")
		ng_getAcfPrefs():set("weights:maxramp",maxramp)
	end
	if ng_getAppPrefs():get("general:weightunit") == "kgs" then
		return maxramp --kgs
	else
		return math.floor(maxramp * 2.20462262) -- lbs
	end
end

--- Get Dry Operating Weight. Use Empty Weight if not specified
function ng_get_DOW()
	local dow = ng_getAcfPrefs():get("weights:dow")
	if dow == -1 then
		dow = get("sim/aircraft/weight/acf_m_empty")
		ng_getAcfPrefs():set("weights:dow",dow)
	end
	if ng_getAppPrefs():get("general:weightunit") == 1 then
		return dow
	else
		return dow * 2.20462262
	end
end

--- Maximum Fuel Capacity
function ng_get_MaxFuel()
	local mfuel = ng_getAcfPrefs():get("weights:maxfuel")
	if mfuel == -1 then
		mfuel = get("sim/flightmodel/weight/m_fuel_total")
		ng_getAcfPrefs():set("weights:maxfuel",mfuel)
	end
	if ng_getAppPrefs():get("general:weightunit") == "kgs" then
		return mfuel
	else
		return mfuel * 2.20462262
	end
end

--- Maximum Zero Fuel Weight Calculated from max weight - max fuel weight
function ng_get_MZFW()
	local mzfw = ng_getAcfPrefs():get("weights:maxzfw")
	if mzfw == -1 then 
		mzfw = ng_get_MaxRampWeight() - ng_get_MaxFuel()
		ng_getAcfPrefs():set("weights:maxzfw",mzfw)
	end
	if ng_getAppPrefs():get("general:weightunit") then
		return mzfw
	else
		return mzfw * 2.20462262
	end
end

--- Maximum takeoff weight as approximation = max aircraft weight
-- if not specified we use Max Ramp Weight
function ng_get_MTOW()
	local mtow = ng_getAcfPrefs():get("weights:maxtow")
	if mtow == -1 then 
		mtow = ng_get_MaxRampWeight()
		ng_getAcfPrefs():set("weights:maxtow",mtow)
	end
	if ng_getAppPrefs():get("general:weightunit") then
		return mtow
	else
		return mtow * 2.20462262
	end
end

-- Maximum Landing Weight as approximation 80% of MTOW
function ng_get_MLDW()
	local mldw = ng_getAcfPrefs():get("weights:maxldw")
	if mldw == -1 then 
		mldw = ng_get_MTOW() * 0.8
		ng_getAcfPrefs():set("weights:maxldw",mldw)
	end
	if ng_getAppPrefs():get("general:weightunit") then
		return mldw
	else
		return mldw * 2.20462262
	end
end

-- Maximum Payload Weight 
function ng_get_MaxPayload()
	local mpayload = ng_getAcfPrefs():get("weights:maxpayload")
	if mpayload == -1 then
		mpayload = ng_get_MaxRampWeight() - ng_get_DOW() - ng_get_MaxFuel()
		ng_getAcfPrefs():set("weights:maxpayload",mpayload)
	end
	if ng_getAppPrefs():get("general:weightunit") then
		return mpayload
	else
		return mpayload * 2.20462262
	end
end

--- Get current gross weight
function ng_get_gross_weight()
	if ng_getAcfPrefs():get("general:weightunit") then
		return get("sim/flightmodel/weight/m_total")
	else
		return get("sim/flightmodel/weight/m_total")*2.20462262
	end	
end

--- Get total fuel loaded
function ng_get_total_fuel()
	if ng_getAcfPrefs():get("general:weightunit") then
		return get("sim/flightmodel/weight/m_fuel_total")
	else
		return get("sim/flightmodel/weight/m_fuel_total")*2.20462262
	end
end

--- Calculate current ZFW
function ng_get_zfw()
	return ng_get_gross_weight()-ng_get_total_fuel()
end

--- Initialze automatic preferences - those with a -1
function ng_init_acf_prefs()
	ng_get_MaxRampWeight()
	ng_get_DOW()
	ng_get_MaxFuel()
	ng_get_MZFW()
	ng_get_MTOW()
	ng_get_MLDW()
	ng_get_MaxPayload()
end

