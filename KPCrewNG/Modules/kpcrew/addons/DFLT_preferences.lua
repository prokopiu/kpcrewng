--[[
	*** KPCREWNG 0.1 
	Define the aircraft addon specific properties to tailor the DFLT definitions
	Kosta Prokopiu, 2026
--]]

require "kpcrew.Addon.Preferences.PreferenceDataType"
local preferenceSet 		= require( "kpcrew.Addon.Preferences.PreferenceSet" )
local preferenceGroup 		= require( "kpcrew.Addon.Preferences.PreferenceGroup" )
local preference 			= require( "kpcrew.Addon.Preferences.PreferenceItem")

-- ===== initialize the preference set for aircraft
local aircraftPrefSet 		= preferenceSet:new("DFLT","DEFAULT AIRCRAFT",SCRIPT_DIRECTORY .. "../Modules/kpcrew_prefs/DFLT.preferences")

-- --------------------------- Addon specific settings overwriting the base info
local addon 				= preferenceGroup:new("addon","ADDON PREFERENCES")
addon:add(preference:new("icao",			"DFLT",ng_type_text,"Aircraft ICAO in use|")) 		-- addon:icao
addon:add(preference:new("aircraftname",	"AIRCRAFT",ng_type_text,"Aircraft name|")) 	-- addon:aircraftname
-- addon:add(preference:new("filepath",SCRIPT_DIRECTORY.."../Modules/kpcrew_prefs/DFLT.preferences",
	-- ng_type_text,"Preference filepath|")) 														-- addon:filepath
-- --------------------------------------------------------------------------------------------

-- --------------------------- General settings not associated with a preference group
local general 				= preferenceGroup:new("general","GENERAL PREFERENCES")
general:add(preference:new("isairbus",		false,ng_type_flag,	"Is Airbus?|Yes|No"))			-- general:isairbus
general:add(preference:new("isboeing",		false,ng_type_flag,	"Is Boeing?|Yes|No"))			-- general:isboeing
general:add(preference:new("iscargo",		false,ng_type_flag,	"Is Cargo Aircraft?|Yes|No"))	-- general:iscargo
general:add(preference:new("hasgroundobj",	false,ng_type_flag,	"Has Ground Objects?|Yes|No"))	-- general:hasgroundobj
general:add(preference:new("haschocks",		false,ng_type_flag,	"Has Chocks?|Yes|No",
nil,"return ng_getAcfPrefs():get(\"general:hasgroundobj\")"))										-- general:haschocks
general:add(preference:new("hasstairs",		false,ng_type_flag,	"Has Stairs?|Yes|No",
nil,"return ng_getAcfPrefs():get(\"general:hasgroundobj\")"))										-- general:hasstairs
general:add(preference:new("haswipers",		false,ng_type_flag,	"Has Wipers?|Yes|No"))			-- general:haswipers
general:add(preference:new("hasseatbelts",	false,ng_type_flag,	"Has Seatbelt Signs?|Yes|No"))	-- general:hasseatbelts
general:add(preference:new("hasnosmoking",	false,ng_type_flag,	"Has No Smoking Signs?|Yes|No"))-- general:hasnosmoking
general:add(preference:new("hasdoors",		true,ng_type_flag,	"Has External Doors?|Yes|No"))	-- general:hasdoors
general:add(preference:new("hasretgear",	true,ng_type_flag,	"Has Retractable Gear?|Yes|No"))-- general:hasretgear
-- autobreak related setting
general:add(preference:new("hasautobrk",	false,ng_type_flag,	"Has Autobrake?|Yes|No"))		-- general:hasautobrk
	general:add(preference:new("abrkmodelblt",	"|MAX MAN|RTO|OFF|1|2|3|4",ng_type_text,"A/BRK Labels|",
		nil,"return ng_getAcfPrefs():get(\"general:hasautobrk\")")) 								-- general:abrkmodelblt
	general:add(preference:new("abrkmodevals",	"|-1|0|1|2|3|4|5|6",ng_type_text,"A/BRK Values|",
		nil,"return ng_getAcfPrefs():get(\"general:hasautobrk\")"))									-- general:abrkmodevals
	general:add(preference:new("abrkoffval",	1,ng_type_int,"A/BRK OFF Value|0",
		nil,"return ng_getAcfPrefs():get(\"general:hasautobrk\")"))									-- general:abrkoffval
	general:add(preference:new("abrkrtoval",	0,ng_type_int,"A/BRK RTO Value|0",
		nil,"return ng_getAcfPrefs():get(\"general:hasautobrk\")"))									-- general:abrktroval
general:add(preference:new("mcpdefspd",100,	ng_type_int,"MCP Initial Speed|0"))					-- general:mcpdefspd
general:add(preference:new("mcpdefhdg",1,	ng_type_int,"MCP Initial Heading|0"))				-- general:mcpdefhdg
general:add(preference:new("mcpdefalt",4900,ng_type_int,"MCP Initial Altitude|0"))				-- general:mcpdefalt
general:add(preference:new("hasantiskid",	false,ng_type_flag,	"Has Anti-Skid?|Yes|No"))		-- general:hasantiskid
general:add(preference:new("hastoconfig",	false,ng_type_flag,	"Has T.O. Config Warn?|Yes|No"))		-- general:hastoconfig

-- --------------------------------------------------------------------------------------------

-- --------------------------- Anti-Ice related settings 
local aice 					= preferenceGroup:new("aice","ANTI ICE SYSTEMS")
aice:add(preference:new("takeoffaice",		"|OFF|ENGINE|ENGINE & WING",
	ng_type_text,"Takeoff A-Ice|")) 															-- aice:takeoffaice
aice:add(preference:new("landingaice",		"|OFF|ENGINE|ENGINE & WING",
	ng_type_text,"Landing A-Ice|")) 															-- aice:landingaice
aice:add(preference:new("haswindowht",		true,ng_type_flag,"Has Window Heat|Yes|No"))		-- aice:haswindowht
aice:add(preference:new("haswingaice",		true,ng_type_flag,"Has Wing Anti-Ice Heat|Yes|No"))	-- aice:haswingaice
aice:add(preference:new("hasengaice",		true,ng_type_flag,"Has Engine Anti-Ice|Yes|No"))	-- aice:hasengaice
aice:add(preference:new("hasprobeheat",		true,ng_type_flag,"Has Probe Heat|Yes|No"))	-- aice:hasprobeheat
-- --------------------------------------------------------------------------------------------

-- --------------------------- Air related settings
local air 					= preferenceGroup:new("air","AIR SUPPLY SYSTEMS")
air:add(preference:new("hastempcontrol",	false,ng_type_flag,"Has Temp Control|Yes|No"))		-- air:hastempcontrol
air:add(preference:new("hastrimair",		false,ng_type_flag,"Has Trim Air|Yes|No"))			-- air:hastrimair
air:add(preference:new("hasrecircfans",		false,ng_type_flag,"Has Recirc Fans|Yes|No"))		-- air:hasrecircfans
air:add(preference:new("hasgasper",			false,ng_type_flag,"Has Gasper Fans|Yes|No"))		-- air:hasgasper
air:add(preference:new("hasisovalves",		false,ng_type_flag,"Has Iso Valves|Yes|No"))		-- air:hasisovalves
air:add(preference:new("haspacks",			false,ng_type_flag,"Has Packs|Yes|No"))			-- air:haspacks
	air:add(preference:new("takeoffpacks",		"|OFF|ON",ng_type_text,"Takeoff Packs|",
		nil,"return ng_getAcfPrefs():get(\"air:haspacks\")"))										-- air:takeoffpacks
	air:add(preference:new("landingpacks",		"|OFF|ON",ng_type_text,"Landing Packs|",
		nil,"return ng_getAcfPrefs():get(\"air:haspacks\")"))										-- air:landingpacks
air:add(preference:new("hasenginebleeds",	false,ng_type_flag,"Has Engine Bleeds|Yes|No"))	-- air:hasenginebleeds
	air:add(preference:new("takeoffbleeds",		"N/A|OFF|ON",ng_type_text,"Takeoff Bleeds|",
		nil,"return ng_getAcfPrefs():get(\"air:hasenginebleeds\")"))								-- air:takeoffbleeds
	air:add(preference:new("landingbleeds",		"N/A|OFF|ON",ng_type_text,"Landing Bleeds|",
		nil,"return ng_getAcfPrefs():get(\"air:hasenginebleeds\")"))								-- air:landingbleeds
air:add(preference:new("hasoxygen",			false,ng_type_flag,"Has Oxygen Supply|Yes|No"))		-- air:hasoxygen
air:add(preference:new("haspresspnl",		false,ng_type_flag,"Has Pressure Panel|Yes|No"))	-- air:haspresspnl
air:add(preference:new("hasequipcool",		false,ng_type_flag,"Has Equip Cooling|Yes|No"))		-- air:hasequipcooling
air:add(preference:new("hascargoheat",		false,ng_type_flag,"Has Cargo Heat|Yes|No"))		-- air:hascargoheat
-- --------------------------------------------------------------------------------------------

-- --------------------------- Autopilot related settings 
local autopilot 			= preferenceGroup:new("autopilot","AUTOPILOT")
autopilot:add(preference:new("hasathr",	false,ng_type_flag,"Has A/THR?|Yes|No"))				-- autopilot:hasathr
autopilot:add(preference:new("hasirs",		false,ng_type_flag,"Has IRS?|Yes|No"))				-- autopilot:hasirs
	autopilot:add(preference:new("irsoff",		0,ng_type_int,"IRS OFF INDX|0",
		nil,"return ng_getAcfPrefs():get(\"autopilot:hasirs\")"))									-- autopilot:irsoff
	autopilot:add(preference:new("irsalign",	1,ng_type_int,"IRS ALIGN INDX|0",
		nil,"return ng_getAcfPrefs():get(\"autopilot:hasirs\")"))									-- autopilot:irsalign
	autopilot:add(preference:new("irsnav",		2,ng_type_int,"IRS NAV INDX|0",
		nil,"return ng_getAcfPrefs():get(\"autopilot:hasirs\")"))									-- autopilot:irsnav
	autopilot:add(preference:new("irsatt",		3,ng_type_int,"IRS ATT INDX|0",
		nil,"return ng_getAcfPrefs():get(\"autopilot:hasirs\")"))									-- autopilot:irsatt
-- --------------------------------------------------------------------------------------------

-- -------------------------- Controls related settings 
local controls 				= preferenceGroup:new("controls","FLIGHT CONTROLS")
controls:add(preference:new("hasspdbreak",	false,ng_type_flag,"Has Speedbreak?|Yes|No"))		-- controls:hasspdbreak
	controls:add(preference:new("spdbreakarms",	false,ng_type_flag,"Speedbreak Arms?|Yes|No",	-- controls:spdbreakarms
		nil,"return ng_getAcfPrefs():get(\"controls:hasspdbreak\")"))
	controls:add(preference:new("spdbreakapos",	0.0889,ng_type_float,"SpdBreak Arm Pos|0|%6.2f",-- controls:spdbreakapos
		nil,"return ng_getAcfPrefs():get(\"controls:spdbreakarms\")"))
controls:add(preference:new("flapsdetents",	9,ng_type_int,"Flaps Detents|0"))
	controls:add(preference:new("flapspos",		"|0|0.125|0.25|0.375|0.5|0.625|0.75|0.875|1",
		ng_type_text,"Flaps Positions")) 															-- controls:flapspos
	controls:add(preference:new("flapsspd",		"|230|200|180|160|155|155|150|150|150",
		ng_type_text,"Flaps Speeds")) 																-- controls:flapsspd
	controls:add(preference:new("flapsnames",	"|UP|1|2|3|4|5|6|7|FULL",
		ng_type_text,"Flaps Names")) 																-- controls:flapsnames
controls:add(preference:new("numtoflaps",	5,ng_type_int,"# T/O Flaps|0"))						-- controls:numtoflaps
	controls:add(preference:new("toflapslbl",	"|UP|1|2|3|4",ng_type_text,"T/O Flaps Lbls"))		-- controls:toflapslbl
	controls:add(preference:new("toflapsind",	"|1|2|3|4|5",ng_type_text,"T/O Flaps Index|"))		-- controls:toflapsind
controls:add(preference:new("numldflaps",	4,ng_type_int,"# LDG Flaps|0"))						-- controls:numldflaps
	controls:add(preference:new("ldflapslbl",	"|5|6|7|FULL",ng_type_text,"LDG Flaps|"))				-- controls:ldflapslbl
	controls:add(preference:new("ldflapsind",	"|6|7|8|9",ng_type_text,"LDG Flaps Index|"))			-- controls:ldflapsind
controls:add(preference:new("hasyawdamper",	false,ng_type_flag,"Has Yawdamper?|Yes|No"))		-- controls:hasyawdamper
-- --------------------------------------------------------------------------------------------

-- -------------------------- EFIS
local efis 					= preferenceGroup:new("efis","EFIS")
efis:add(preference:new("hasradaralt",	false,ng_type_flag,"Has Radar Altitude|Yes|No"))		-- efis:hasradaralt
efis:add(preference:new("haswxradar",	false,ng_type_flag,"Has WX Radar|Yes|No"))				-- efis:haswxradar
-- --------------------------------------------------------------------------------------------

-- -------------------------- Electric related settings 
local electric 				= preferenceGroup:new("electric","ELECTRIC SYSTEMS")
electric:add(preference:new("hasstbypower",	false,ng_type_flag,"Has Standby Power|Yes|No"))		-- electric:hasstbypower
electric:add(preference:new("hasgpu",		false,ng_type_flag,"Has GPU?|Yes|No"))				-- electric:hasgpu
	electric:add(preference:new("startupgpu",true,ng_type_flag,"GPU @ start|On|Off",
		nil,"return ng_getAcfPrefs():get(\"electric:hasgpu\")"))								-- electric:startupgpu
electric:add(preference:new("hasapu",		false,ng_type_flag,"Has APU?|Yes|No"))				-- electric:hasapu
	electric:add(preference:new("startupapu",false,ng_type_flag,"APU @ start|On|Off",
		nil,"return ng_getAcfPrefs():get(\"electric:hasapu\")"))								-- electric:startupapu
	electric:add(preference:new("apun1run",		98,ng_type_int,"APU N1 running|0",
		nil,"return ng_getAcfPrefs():get(\"electric:hasapu\")"))								-- electric:apun1run
electric:add(preference:new("hascabinpwr",	false,ng_type_flag,"Has Cabin Power?|Yes|No"))		-- electric:hascabinpwr
electric:add(preference:new("hasifepwr",	false,ng_type_flag,"Has IFE Power?|Yes|No"))		-- electric:hasifepwr
electric:add(preference:new("hasbusties",	false,ng_type_flag,"Has Bus Ties?|Yes|No"))			-- electric:hasbusties
electric:add(preference:new("hasenggens",	true,ng_type_flag,"Has Engine Generators?|Yes|No")) -- electric:hasenggens
electric:add(preference:new("hasessbus",	false,ng_type_flag,"Has Essential Bus?|Yes|No")) 	-- electric:hasessbus
electric:add(preference:new("hastrus",		false,ng_type_flag,"Has TRUs?|Yes|No")) 			-- electric:hastrus
-- --------------------------------------------------------------------------------------------

-- ------------------------- Engines related settings 
local engines 				= preferenceGroup:new("engines","ENGINE SYSTEMS")
engines:add(preference:new("nrengines",		2,ng_type_int,"Number of Engines|0"))					-- engines:nrengines
engines:add(preference:new("startseq",		"|2 THEN 1|1 THEN 2",ng_type_text,"Start Sequence|")) -- engines:startseq
engines:add(preference:new("hasfiretests",	false,ng_type_flag,"Has Fire Test?|Yes|No"))		-- engines:hasfiretests
engines:add(preference:new("haseec",		false,ng_type_flag,"Has EEC?|Yes|No"))				-- engines:haseec
engines:add(preference:new("hasstartsels",	false,ng_type_flag,"Has Start Selectors?|Yes|No"))		-- engines:hasstartsels
engines:add(preference:new("hasstartlvrs",	false,ng_type_flag,"Has Start Levers?|Yes|No"))		-- engines:hasstartlvrs
engines:add(preference:new("hastothrust",	false,ng_type_flag,"Has T/O Thrust Rating?|Yes|No")) -- engines:hastothrust
engines:add(preference:new("n2afterstart",	50,ng_type_int,"N2 Value start|0"))					-- engines:n2afterstart
-- --------------------------------------------------------------------------------------------

-- -------------------------- Fuel related settings 
local fuel 					= preferenceGroup:new("fuel","FUEL SYSTEMS")
fuel:add(preference:new("canloadfuel",		false,ng_type_flag,"Can load fuel?|Yes|No"))		-- fuel:canloadfuel		
fuel:add(preference:new("hasfuelxfeed",		false,ng_type_flag,"Has Fuel Crossfeeds|Yes|No"))	-- fuel:hasfuelxfeed
fuel:add(preference:new("hasfuelselector",	false,ng_type_flag,"Has Fuel Selector|Yes|No"))		-- fuel:hasfuelselector
fuel:add(preference:new("hasfuelpumps",		false,ng_type_flag,"Has Fuel Pump Sws|Yes|No"))		-- fuel:hasfuelpumps
-- --------------------------------------------------------------------------------------------

-- ----------------------- Hydraulic related settings
local hydraulic 			= preferenceGroup:new("hydraulic","HYDRAULIC SYSTEMS")
hydraulic:add(preference:new("hashydelecpmps",true,ng_type_flag,
	"Has Electric Hyd Pumps|Yes|No"))															-- hydraulic:hashydelecpmps
hydraulic:add(preference:new("hashydengpmps",true,ng_type_flag,
	"Has Engine Hyd Pumps|Yes|No"))																-- hydraulic:hashydengpmps
-- --------------------------------------------------------------------------------------------

-- ---------------------- Light related settings 
local lights 				= preferenceGroup:new("lights","LIGHTS")
lights:add(preference:new("hasbeacon",		true,ng_type_flag,"Has Beacon Lights?|Yes|No"))		-- lights:hasbeacon
lights:add(preference:new("hastaxilights",	true,ng_type_flag,"Has Taxi Lights?|Yes|No"))		-- lights:hastaxilights
lights:add(preference:new("hasdomelts",		true,ng_type_flag,"Has Dome Lights|Yes|No"))		-- lights:hasdomelts
lights:add(preference:new("hasemerlts",		false,ng_type_flag,"Has Emergency Lights|Yes|No"))	-- lights:hasemerlts
lights:add(preference:new("hasstrbbeacon",	false,ng_type_flag,"Has Strobes as Beacon|Yes|No"))	-- lights:hasstrbbeacon
lights:add(preference:new("hasllastaxi",	false,ng_type_flag,"Has LLs as Taxilight|Yes|No"))	-- lights:hasllastaxi
lights:add(preference:new("haslogolts",		true,ng_type_flag,"Has Logo Lights?|Yes|No"))		-- lights:haslogolts
lights:add(preference:new("haswinglts",		true,ng_type_flag,"Has Wing Lights?|Yes|No"))		-- lights:haswinglts
lights:add(preference:new("haswheellts",	true,ng_type_flag,"Has Wheel Lights?|Yes|No"))		-- lights:haswheellts
lights:add(preference:new("hasrwylts",		true,ng_type_flag,"Has Runway Lights?|Yes|No"))		-- lights:hasrwylts
lights:add(preference:new("nrlandlights",	2,ng_type_int,"Number Landing Lights|0"))			-- lights:nrlandlights

-- --------------------------------------------------------------------------------------------

-- ---------------------- Weight related settings
local weights 				= preferenceGroup:new("weights","WEIGHTS")
weights:add(preference:new("canloadpld",	false,ng_type_flag,"Can load payload?|Yes|No"))		-- weights:canloadfuel
weights:add(preference:new("maxramp",		-1,ng_type_int,"Max Ramp Weight|0"))				-- weights:maxramp
weights:add(preference:new("dow",			-1,ng_type_int,"Dry Operating Weight|0"))			-- weights:dow	
weights:add(preference:new("maxzfw",		-1,ng_type_int,"Max ZFW|0"))						-- weights:maxzfw
weights:add(preference:new("maxtow",		-1,ng_type_int,"Max TOW|0"))						-- weights:maxtow
weights:add(preference:new("maxldw",		-1,ng_type_int,"Max LDW|0"))						-- weights:maxldw
weights:add(preference:new("maxpayload",	-1,ng_type_int,"Max Payload|0"))					-- weights:maxpayload
weights:add(preference:new("maxfuel",		-1,ng_type_int,"Max Fuel|0"))						-- weights:maxfuel	
-- --------------------------------------------------------------------------------------------
-- ---------------------- Weight related settings
local radios 				= preferenceGroup:new("radios","RADIOS")
radios:add(preference:new("hasxpdrtara", 	false,ng_type_flag,"XPDR has TARA|Yes|No"))			-- radios:xpdrtara

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
aircraftPrefSet:addGroup(radios)
aircraftPrefSet:addGroup(weights)

--- optional custom steps on loading the set
local function custom_load()
	
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
	if ng_getAcfPrefs():get("general:weightunit") ~= 1 then
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

