require "kpcrew.Addon.Preferences.PreferenceDataType"

local preferenceSet = require( "kpcrew.Addon.Preferences.PreferenceSet" )
local preferenceGroup = require( "kpcrew.Addon.Preferences.PreferenceGroup" )
local preference = require("kpcrew.Addon.Preferences.PreferenceItem")
local http = require("socket.http")
local metar = require("kpcrew.metar")
local xml2lua = require("kpcrew.xml2lua")

-- global vars and functions for lists
ng_briefing_to_rwys = {}
ng_briefing_to_rwyidx = 0
ng_briefing_ld_rwys = {}
ng_briefing_ld_rwyidx = 0

local briefingPrefSet = preferenceSet:new("briefing","BRIEFING",SCRIPT_DIRECTORY .. "../Modules/kpcrew_prefs/briefing.preferences")

local general = preferenceGroup:new("general","BRIEFING - GENERAL")
general:add(preference:new("simversion",get("sim/version/xplane_internal_version"),ng_type_text,"Simversion|"))
general:add(preference:new("firstflight",1,ng_type_list,"First Flight of Day|First Flight|Turnaround"))
general:add(preference:new("sbweightunit","",ng_type_text,"Simbrief Weight Unit|","params.units"))
general:add(preference:new("callsign","",ng_type_text,"Callsign|","atc.callsign"))
general:add(preference:new("costindex","",ng_type_info,"Cost index|","general.costindex"))
general:add(preference:new("cruisealtitude",0,ng_type_int,"Cruise Altitude|100","general.initial_altitude"))
general:add(preference:new("averageisa",0,ng_type_int,"Average ISA|1","general.avg_temp_dev"))
general:add(preference:new("averagewndhdg",0,ng_type_int,"Average Wind Direction|10","general.avg_wind_dir"))
general:add(preference:new("averagewndspd",0,ng_type_int,"Average Wind Speed|5","general.avg_wind_spd"))
general:add(preference:new("averagewndcmp",0,ng_type_int,"Average Wind Component|1","general.avg_wind_comp"))
general:add(preference:new("tropopause",0,ng_type_int,"Tropopause|10","general.avg_tropopause"))
general:add(preference:new("route","",ng_type_text,"Route|","general.route"))
general:add(preference:new("routedistance",0,ng_type_int,"Route Distance|1","general.route_distance"))
general:add(preference:new("acficao","",ng_type_text,"Aircraft ICAO|","aircraft.icaocode"))
general:add(preference:new("acfname","",ng_type_text,"Aircraft Name|","aircraft.name"))
general:add(preference:new("acfreg","",ng_type_text,"Aircraft Registration|","aircraft.reg"))
general:add(preference:new("acfselcal","",ng_type_text,"Aircraft SELCAL|","aircraft.selcal"))
general:add(preference:new("acftlr",0,ng_type_int,"Aircraft TLR|1","aircraft.supports_tlr"))

local origin = preferenceGroup:new("origin","BRIEFING - ORIGIN")
origin:add(preference:new("icao","",ng_type_text,"Origin ICAO|","origin.icao_code"))
origin:add(preference:new("name","",ng_type_text,"Origin Name|","origin.name"))
origin:add(preference:new("elevation","",ng_type_text,"Origin Elevation|","origin.elevation"))
origin:add(preference:new("timezone",0,ng_type_int,"Origin Timezone|1","origin.timezone"))
origin:add(preference:new("planrwy","",ng_type_text,"Origin Runway|","origin.plan_rwy"))
origin:add(preference:new("selectedrwy",1,ng_type_int,"Index Runway|"))
origin:add(preference:new("transalt",0,ng_type_int,"Origin Transition Alt|1000","origin.trans_alt"))
origin:add(preference:new("translvl",0,ng_type_int,"Origin Transition Lvl|1000","origin.trans_level"))
origin:add(preference:new("metar","",ng_type_text,"Origin METAR|","origin.metar"))
origin:add(preference:new("deptype",1,ng_type_list,"Departure Type|SID|VECTORS|TRACKING"))
origin:add(preference:new("sid","",ng_type_text,"Origin SID|","general.sid_ident"))
origin:add(preference:new("sidtransition","",ng_type_text,"Origin SID Transition|","general.sid_trans"))
origin:add(preference:new("stand","",ng_type_text,"Origin Parking Position|"))
origin:add(preference:new("standtype",1,ng_type_list,"Origin Parking Type|GATE (PUSH)|STAND (PUSH)|STAND (NO PUSH)"))
origin:add(preference:new("pushtype",1,ng_type_list,"Origin Push Type|NO PUSH|NOSE LEFT|NOSE RIGHT|NOSE STRAIGHT|FACING NORTH|FACING SOUTH|FACING EAST|FACING WEST"))
origin:add(preference:new("squawk",2000,ng_type_int,"SQUAWK|0"))

local destination = preferenceGroup:new("destination","BRIEFING - DESTINATION")
destination:add(preference:new("icao","",ng_type_text,"Destination ICAO|","destination.icao_code"))
destination:add(preference:new("name","",ng_type_text,"Destination Name|","destination.name"))
destination:add(preference:new("elevation","",ng_type_info,"Destination Elevation|","destination.elevation"))
destination:add(preference:new("timezone",0,ng_type_int,"Destination Timezone|1","destination.timezone"))
destination:add(preference:new("planrwy","",ng_type_text,"Destination Runway|","destination.plan_rwy"))
destination:add(preference:new("selectedrwy",1,ng_type_int,"Index Runway|"))
destination:add(preference:new("transalt",0,ng_type_int,"Destination Transition Alt|1000","destination.trans_alt"))
destination:add(preference:new("translvl",0,ng_type_int,"Destination Transition Lvl|1000","destination.trans_level"))
destination:add(preference:new("metar","",ng_type_info,"Destination METAR|","destination.metar"))
destination:add(preference:new("star","",ng_type_text,"Destination STAR|","general.star_ident"))
destination:add(preference:new("startransition","",ng_type_text,"Destination STAR Transition|","general.star_trans"))
destination:add(preference:new("stand","",ng_type_text,"Destination Parking Position|"))
destination:add(preference:new("standtype",1,ng_type_list,"Destination Parking Type|GATE|STAND|STAND (WITH PUSH)"))
destination:add(preference:new("arrtype",1,ng_type_list,"Arrival Type|STAR|VECTORS"))

local alternate = preferenceGroup:new("alternate","BRIEFING - ALTERNATE")
alternate:add(preference:new("icao","",ng_type_text,"Alternate ICAO|","alternate.icao_code"))
alternate:add(preference:new("name","",ng_type_text,"Alternate Name|","alternate.name"))
alternate:add(preference:new("elevation","",ng_type_info,"Alternate Elevation|","alternate.elevation"))
alternate:add(preference:new("timezone",0,ng_type_int,"Alternate Timezone|1","alternate.timezone"))
alternate:add(preference:new("planrwy","",ng_type_text,"Alternate Runway|","alternate.plan_rwy"))
alternate:add(preference:new("transalt",0,ng_type_int,"Alternate Transition Alt|1000","alternate.trans_alt"))
alternate:add(preference:new("translvl",0,ng_type_int,"Alternate Transition Lvl|1000","alternate.trans_level"))
alternate:add(preference:new("metar","",ng_type_info,"Alternate METAR|","alternate.metar"))

local takeoff = preferenceGroup:new("takeoff","BRIEFING - TAKEOFF")
takeoff:add(preference:new("windhdg",0,ng_type_int,"Takeoff Wind Heading|10","tlr.takeoff.conditions.wind_direction"))
takeoff:add(preference:new("windspd",0,ng_type_int,"Takeoff Wind Speed|1","tlr.takeoff.conditions.wind_speed"))
takeoff:add(preference:new("temperature",0,ng_type_int,"Takeoff Temperature|1","tlr.takeoff.conditions.temperature"))
takeoff:add(preference:new("altimeter",0,ng_type_float,"Takeoff Altimeter|1","tlr.takeoff.conditions.altimeter"))
takeoff:add(preference:new("qaltimeter",0,ng_type_float,"Takeoff Altimeter|1"))
takeoff:add(preference:new("surfacecond","",ng_type_text,"Takeoff Surface Condition|","tlr.takeoff.conditions.surface_condition"))

takeoff:add(preference:new("rwyident","",ng_type_text,"Takeoff Runway|","tlr.takeoff.runway[ng_briefing_to_rwyidx].identifier"))
takeoff:add(preference:new("rwylength",0,ng_type_int,"Takeoff Runway Length|10","tlr.takeoff.runway[ng_briefing_to_rwyidx].length"))
takeoff:add(preference:new("rwytora",0,ng_type_int,"Takeoff Runway TORA|10","tlr.takeoff.runway[ng_briefing_to_rwyidx].length_tora"))
takeoff:add(preference:new("rwyelevation",0,ng_type_int,"Takeoff Runway Elevation|10","tlr.takeoff.runway[ng_briefing_to_rwyidx].elevation"))
takeoff:add(preference:new("rwycourse",0,ng_type_int,"Takeoff Runway Mag Course|10","tlr.takeoff.runway[ng_briefing_to_rwyidx].magnetic_course"))
takeoff:add(preference:new("rwyheadwind",0,ng_type_int,"Takeoff Runway Headwind|10","tlr.takeoff.runway[ng_briefing_to_rwyidx].headwind_component"))
takeoff:add(preference:new("rwycrosswind",0,ng_type_int,"Takeoff Runway Crosswind|10","tlr.takeoff.runway[ng_briefing_to_rwyidx].crosswind_component"))
takeoff:add(preference:new("rwyilsfreq","",ng_type_text,"Takeoff Runway ILS Freq|","tlr.takeoff.runway[ng_briefing_to_rwyidx].ils_frequency"))
takeoff:add(preference:new("rwyflaps","",ng_type_text,"Takeoff Flaps|","tlr.takeoff.runway[ng_briefing_to_rwyidx].flap_setting"))
takeoff:add(preference:new("selectedflaps",1,ng_type_int,"Selected Flaps|"))
takeoff:add(preference:new("rwythrust","",ng_type_text,"Takeoff Thrust|","tlr.takeoff.runway[ng_briefing_to_rwyidx].thrust_setting"))
takeoff:add(preference:new("selectedthrust",1,ng_type_int,"Selected Thrust|"))
takeoff:add(preference:new("rwybleed","",ng_type_text,"Takeoff Bleed|","tlr.takeoff.runway[ng_briefing_to_rwyidx].bleed_setting"))
takeoff:add(preference:new("selectedbleed",1,ng_type_int,"Selected Bleeds|"))
takeoff:add(preference:new("rwyaice","",ng_type_text,"Takeoff A/ICE|","tlr.takeoff.runway[ng_briefing_to_rwyidx].anti_ice_setting"))
takeoff:add(preference:new("selectedaice",1,ng_type_int,"Selected Aice|"))
takeoff:add(preference:new("rwyflextemp",0,ng_type_int,"Takeoff Flex Temp|1","tlr.takeoff.runway[ng_briefing_to_rwyidx].flex_temperature"))
takeoff:add(preference:new("rwyv1",0,ng_type_int,"Takeoff V1|1","tlr.takeoff.runway[ng_briefing_to_rwyidx].speeds_v1"))
takeoff:add(preference:new("rwyvr",0,ng_type_int,"Takeoff VR|1","tlr.takeoff.runway[ng_briefing_to_rwyidx].speeds_vr"))
takeoff:add(preference:new("rwyv2",0,ng_type_int,"Takeoff V2|1","tlr.takeoff.runway[ng_briefing_to_rwyidx].speeds_v2"))
takeoff:add(preference:new("initalt",4900,ng_type_int,"Initial Alt|1","general.initial_altitude"))
takeoff:add(preference:new("inithdg",0,ng_type_int,"Initial Hdg|1","navlog.fix[1].track_mag"))
takeoff:add(preference:new("pitchtrim",0,ng_type_float,"Takeoff Pitchtrim|0"))

local landing = preferenceGroup:new("landing","BRIEFING - LANDING")
landing:add(preference:new("windhdg",0,ng_type_int,"Landing Wind Heading|10","tlr.landing.conditions.wind_direction"))
landing:add(preference:new("windspd",0,ng_type_int,"Landing Wind Speed|1","tlr.landing.conditions.wind_speed"))
landing:add(preference:new("temperature",0,ng_type_int,"Landing Temperature|1","tlr.landing.conditions.temperature"))
landing:add(preference:new("altimeter",0,ng_type_float,"Landing Altimeter A|1","tlr.landing.conditions.altimeter"))
landing:add(preference:new("qaltimeter",0,ng_type_float,"Landing Altimeter Q|1"))
landing:add(preference:new("surfacecond","",ng_type_text,"Landing Surface Condition|","tlr.landing.conditions.surface_condition"))
landing:add(preference:new("plannedwgt",0,ng_type_info,"Landing Planned Weight|","tlr.landing.conditions.planned_weight"))
landing:add(preference:new("dryflaps","",ng_type_text,"Landing Flaps Dry|","tlr.landing.distance_dry.flap_setting"))
landing:add(preference:new("drybrakes","",ng_type_text,"Landing Brake Dry|","tlr.landing.distance_dry.brake_setting"))
landing:add(preference:new("dryvref",0,ng_type_int,"Landing VREF Dry|1","tlr.landing.distance_dry.speeds_vref"))
landing:add(preference:new("dryactdist",0,ng_type_int,"Landing Actual Distance Dry|1","tlr.landing.distance_dry.actual_distance"))
landing:add(preference:new("dryfactdist",0,ng_type_int,"Landing Factored Distance Dry|1","tlr.landing.distance_dry.factored_distance"))
landing:add(preference:new("wetflaps","",ng_type_text,"Landing Flaps Wet|","tlr.landing.distance_wet.flap_setting"))
landing:add(preference:new("wetbrakes","",ng_type_text,"Landing Brake Wet|","tlr.landing.distance_wet.brake_setting"))
landing:add(preference:new("wetvref",0,ng_type_int,"Landing VREF Wet|1","tlr.landing.distance_wet.speeds_vref"))
landing:add(preference:new("wetactdist",0,ng_type_int,"Landing Actual Distance Wet|1","tlr.landing.distance_wet.actual_distance"))
landing:add(preference:new("wetfactdist",0,ng_type_int,"Landing Factored Distance Wet|1","tlr.landing.distance_wet.factored_distance"))
landing:add(preference:new("selectedflaps",1,ng_type_int,"Selected ldg Flaps|"))
landing:add(preference:new("selectedbleed",1,ng_type_int,"Selected Ldg Bleeds|"))
landing:add(preference:new("selectedaice",1,ng_type_int,"Selected Ldg Aice|"))
landing:add(preference:new("selectedabrk",1,ng_type_int,"Selected Autobrake|"))
landing:add(preference:new("rwyvref",0,ng_type_int,"landing Vref|1"))
landing:add(preference:new("rwyvapp",0,ng_type_int,"landing Vapp|1"))

landing:add(preference:new("rwyident","",ng_type_text,"Landing Runway|","tlr.landing.runway[ng_briefing_ld_rwyidx].identifier"))
landing:add(preference:new("rwylength",0,ng_type_int,"Landing Runway Length|10","tlr.landing.runway[ng_briefing_ld_rwyidx].length"))
landing:add(preference:new("rwyelevation",0,ng_type_int,"Landing Runway Elevation|10","tlr.landing.runway[ng_briefing_ld_rwyidx].elevation"))
landing:add(preference:new("rwycourse",0,ng_type_int,"Landing Runway Mag Course|10","tlr.landing.runway[ng_briefing_ld_rwyidx].magnetic_course"))
landing:add(preference:new("rwyheadwind",0,ng_type_int,"Landing Runway Headwind|10","tlr.landing.runway[ng_briefing_ld_rwyidx].headwind_component"))
landing:add(preference:new("rwycrosswind",0,ng_type_int,"Landing Runway Crosswind|10","tlr.landing.runway[ng_briefing_ld_rwyidx].crosswind_component"))
landing:add(preference:new("rwyilsfreq","",ng_type_text,"Landing Runway ILS Freq|","tlr.landing.runway[ng_briefing_ld_rwyidx].ils_frequency"))
landing:add(preference:new("rwylda",0,ng_type_int,"Landing Runway LDA|10","tlr.landing.runway[ng_briefing_ld_rwyidx].length_lda"))

local fuel = preferenceGroup:new("fuel","BRIEFING - FUEL")
fuel:add(preference:new("taxi",0,ng_type_int,"Taxi Fuel|10","fuel.taxi"))
fuel:add(preference:new("enroute",0,ng_type_int,"Enroute Fuel|10","fuel.enroute_burn"))
fuel:add(preference:new("contingency",0,ng_type_int,"Contingency Fuel|10","fuel.contingency"))
fuel:add(preference:new("alternate",0,ng_type_int,"Alternate Fuel|10","fuel.alternate_burn"))
fuel:add(preference:new("reserve",0,ng_type_int,"Reserve Fuel|10","fuel.reserve"))
fuel:add(preference:new("extra",0,ng_type_int,"Extra Fuel|10","fuel.extra"))
fuel:add(preference:new("mintakeoff",0,ng_type_int,"Min TO Fuel|10","fuel.min_takeoff"))
fuel:add(preference:new("plantakeoff",0,ng_type_int,"Plan TO Fuel|10","fuel.plan_takeoff"))
fuel:add(preference:new("planramp",0,ng_type_int,"Plan Ramp Fuel|10","fuel.plan_ramp"))
fuel:add(preference:new("planlanding",0,ng_type_int,"Plan LDG Fuel|10","fuel.plan_landing"))
fuel:add(preference:new("avgfuelflow",0,ng_type_int,"AVG Fuel Flow|10","fuel.avg_fuel_flow"))
fuel:add(preference:new("maxtanks",0,ng_type_int,"Max Tanks Fuel|10","fuel.max_tanks"))

local times = preferenceGroup:new("times","BRIEFING - TIMES")
times:add(preference:new("estenroute",0,ng_type_int,"Estimate Enroute Time|10","times.est_time_enroute"))
times:add(preference:new("schedenroute",0,ng_type_int,"Scheduled Enroute|10","times.sched_time_enroute"))
times:add(preference:new("schedout",0,ng_type_int,"Scheduled OUT|10","times.sched_out"))
times:add(preference:new("schedoff",0,ng_type_int,"Scheduled OFF|10","times.sched_off"))
times:add(preference:new("schedon",0,ng_type_int,"Scheduled ON|10","times.sched_on"))
times:add(preference:new("schedin",0,ng_type_int,"Scheduled IN|10","times.sched_in"))
times:add(preference:new("schedblock",0,ng_type_int,"Scheduled BLOCK|10","times.sched_block"))
times:add(preference:new("estout",0,ng_type_int,"Estimated OUT|10","times.est_out"))
times:add(preference:new("estoff",0,ng_type_int,"Estimated OFF|10","times.est_off"))
times:add(preference:new("eston",0,ng_type_int,"Estimated ON|10","times.est_on"))
times:add(preference:new("estin",0,ng_type_int,"Estimated IN|10","times.est_in"))
times:add(preference:new("estblock",0,ng_type_int,"Estimated BLOCK|10","times.est_block"))
times:add(preference:new("taxiout",0,ng_type_int,"Taxi OUT|10","times.taxi_out"))
times:add(preference:new("taxiin",0,ng_type_int,"Taxi IN|10","times.taxi_in"))
times:add(preference:new("reserve",0,ng_type_int,"Reserve Time|10","times.reserve_time"))
times:add(preference:new("endurance",0,ng_type_int,"Endurance|10","times.endurance"))
times:add(preference:new("contfuel",0,ng_type_int,"Contingency Fuel|10","times.contfuel_time"))
times:add(preference:new("extrafuel",0,ng_type_int,"Extra Fuel|10","times.extrafuel_time"))

local weights = preferenceGroup:new("weights","BRIEFING - WEIGHTS")
weights:add(preference:new("oew",0,ng_type_int,"Weight oew|10","weights.oew"))
weights:add(preference:new("paxcount",0,ng_type_int,"Weight pax_count|10","weights.pax_count"))
weights:add(preference:new("paxweight",0,ng_type_int,"Weight pax_weight|10","weights.pax_weight"))
weights:add(preference:new("bagweight",0,ng_type_int,"Weight bag_weight|10","weights.bag_weight"))
weights:add(preference:new("bagcount",0,ng_type_int,"Bag weight|10","weights.bag_count"))
weights:add(preference:new("freightadded",0,ng_type_int,"Weight freight_added|10","weights.freight_added"))
weights:add(preference:new("cargo",0,ng_type_int,"Weight cargo|10","weights.cargo"))
weights:add(preference:new("payload",0,ng_type_int,"Weight payload|10","weights.payload"))
weights:add(preference:new("estzfw",0,ng_type_int,"Weight est_zfw|10","weights.est_zfw"))
weights:add(preference:new("maxzfw",0,ng_type_int,"Weight max_zfw|10","weights.max_zfw"))
weights:add(preference:new("esttow",0,ng_type_int,"Weight est_tow|10","weights.est_tow"))
weights:add(preference:new("maxtow",0,ng_type_int,"Weight max_tow|10","weights.max_tow"))
weights:add(preference:new("estldw",0,ng_type_int,"Weight est_ldw|10","weights.est_ldw"))
weights:add(preference:new("maxldw",0,ng_type_int,"Weight max_ldw|10","weights.max_ldw"))
weights:add(preference:new("estramp",0,ng_type_int,"Weight est_ramp|10","weights.est_ramp"))

briefingPrefSet:addGroup(general)
briefingPrefSet:addGroup(origin)
briefingPrefSet:addGroup(destination)
briefingPrefSet:addGroup(alternate)
briefingPrefSet:addGroup(takeoff)
briefingPrefSet:addGroup(landing)
briefingPrefSet:addGroup(fuel)
briefingPrefSet:addGroup(times)
briefingPrefSet:addGroup(weights)

--- return the preferenceSet
function ng_getBriefPrefs()
	return briefingPrefSet
end


--- download simbrief.xml
function ng_download_simbrief()
    local xml = ""
    local http = require("socket.http")
    local xml, result = http.request("http://www.simbrief.com/api/xml.fetcher.php?username=" .. ng_getAppPrefs():get("general:simbriefuser"))
	-- 200 means success
    if result == 200 then
		sbfile = io.open(SCRIPT_DIRECTORY .. "../Modules/kpcrew_prefs/simbrief.xml", "w+")
		sbfile:write(xml)
		sbfile:close()
	else
		print("Error simbrief: "..result)
	end
end

-- parse downloaded simbrief file
function ng_load_simbrief()
	if ng_file_exists(SCRIPT_DIRECTORY .. "../Modules/kpcrew_prefs/simbrief.xml") then
		-- latest OFP gets stored in kpcrew_prefs folder as simbrief.xml
		local xmlfile = xml2lua.loadFile(SCRIPT_DIRECTORY .. "../Modules/kpcrew_prefs/simbrief.xml")
		local parser = xml2lua.parser(xmlhandler)
		parser:parse(xmlfile)
		-- get runway array from xml
		if xmlhandler.root.OFP.tlr.takeoff ~= nil then
			ng_getBriefPrefs():set("takeoff:qaltimeter",(ng_getBriefPrefs():get("takeoff:altimeter") * 33.86548913)+1)
			ng_briefing_to_rwys = xmlhandler.root.OFP.tlr.takeoff.runway
			for i=1,#ng_briefing_to_rwys do 
				if ng_briefing_to_rwys[i].identifier == xmlhandler.root.OFP.origin.plan_rwy then
					ng_briefing_to_rwyidx = i 
					ng_getBriefPrefs():set("origin:selectedrwy",i)
					ng_getBriefPrefs():set("takeoff:selectedflaps",ng_briefing_to_rwys[ng_getBriefPrefs():get("origin:selectedrwy")].flap_setting)
					local splitTitle = ng_split(ng_getAcfPrefs():find("engines:tothrust"):getTitle(),"|") 
					ng_getBriefPrefs():set("takeoff:selectedthrust",ng_indexOf(splitTitle,ng_briefing_to_rwys[ng_getBriefPrefs():get("origin:selectedrwy")].thrust_setting)-1) 
					local splitTitle = ng_split(ng_getAcfPrefs():find("air:takeoffbleeds"):getTitle(),"|")
					ng_getBriefPrefs():set("takeoff:selectedbleed",ng_indexOf(splitTitle,ng_briefing_to_rwys[ng_getBriefPrefs():get("origin:selectedrwy")].bleed_setting)-1) 
					local splitTitle = ng_split(ng_getAcfPrefs():get("aice:takeoffaice"),"|")
					-- ng_getBriefPrefs():set("takeoff:selectedaice",ng_indexOf(splitTitle,ng_briefing_to_rwys[ng_getBriefPrefs():get("origin:selectedrwy")].anti_ice_setting)-1)
					ng_getBriefPrefs():set("takeoff:rwyflextemp",ng_briefing_to_rwys[ng_getBriefPrefs():get("origin:selectedrwy")].flex_temperature) 						
					ng_getBriefPrefs():set("takeoff:rwyv1",ng_briefing_to_rwys[ng_getBriefPrefs():get("origin:selectedrwy")].speeds_v1) 						
					ng_getBriefPrefs():set("takeoff:rwyvr",ng_briefing_to_rwys[ng_getBriefPrefs():get("origin:selectedrwy")].speeds_vr) 						
					ng_getBriefPrefs():set("takeoff:rwyv2",ng_briefing_to_rwys[ng_getBriefPrefs():get("origin:selectedrwy")].speeds_v2) 	
					ng_getBriefPrefs():set("takeoff:inithdg",ng_briefing_to_rwys[ng_getBriefPrefs():get("origin:selectedrwy")].magnetic_course)
				end
			end
		end
		if xmlhandler.root.OFP.tlr.landing ~= nil then
			-- ng_getBriefPrefs():set("takeoff:qaltimeter",(ng_getBriefPrefs():get("takeoff:altimeter") * 33.86548913)+1)
			-- ng_briefing_to_rwys = xmlhandler.root.OFP.tlr.takeoff.runway
			for i=1,#ng_briefing_ld_rwys do 
				if ng_briefing_ld_rwys[i].identifier == xmlhandler.root.OFP.destination.plan_rwy then
					ng_briefing_ld_rwyidx = i 
					ng_getBriefPrefs():set("destination:selectedrwy",i)
					-- ng_getBriefPrefs():set("takeoff:selectedflaps",ng_briefing_to_rwys[ng_getBriefPrefs():get("origin:selectedrwy")].flap_setting)
					-- local splitTitle = ng_split(ng_getAcfPrefs():find("engines:tothrust"):getTitle(),"|") 
					-- ng_getBriefPrefs():set("takeoff:selectedthrust",ng_indexOf(splitTitle,ng_briefing_to_rwys[ng_getBriefPrefs():get("origin:selectedrwy")].thrust_setting)-1) 
					-- local splitTitle = ng_split(ng_getAcfPrefs():find("air:takeoffbleeds"):getTitle(),"|")
					-- ng_getBriefPrefs():set("takeoff:selectedbleed",ng_indexOf(splitTitle,ng_briefing_to_rwys[ng_getBriefPrefs():get("origin:selectedrwy")].bleed_setting)-1) 
					-- ng_getBriefPrefs():set("takeoff:rwyflextemp",ng_briefing_to_rwys[ng_getBriefPrefs():get("origin:selectedrwy")].flex_temperature) 						
					-- ng_getBriefPrefs():set("takeoff:rwyv1",ng_briefing_to_rwys[ng_getBriefPrefs():get("origin:selectedrwy")].speeds_v1) 						
					-- ng_getBriefPrefs():set("takeoff:rwyvr",ng_briefing_to_rwys[ng_getBriefPrefs():get("origin:selectedrwy")].speeds_vr) 						
					-- ng_getBriefPrefs():set("takeoff:rwyv2",ng_briefing_to_rwys[ng_getBriefPrefs():get("origin:selectedrwy")].speeds_v2) 	
					-- ng_getBriefPrefs():set("takeoff:inithdg",ng_briefing_to_rwys[ng_getBriefPrefs():get("origin:selectedrwy")].magnetic_course)
				end
			end
		end
		-- get runway array from xml
		if xmlhandler.root.OFP.tlr.landing ~= nil then
			ng_briefing_ld_rwys = xmlhandler.root.OFP.tlr.landing.runway
			for i=1,#ng_briefing_ld_rwys do 
				if ng_briefing_ld_rwys[i].identifier == xmlhandler.root.OFP.destination.plan_rwy then
					ng_briefing_ld_rwyidx = i 
					ng_getBriefPrefs():set("destination:selectedrwy",i)
				end
			end
		end
		briefingPrefSet:sbLoad()
	else
		print("Cannot find simbrief file")
	end
end