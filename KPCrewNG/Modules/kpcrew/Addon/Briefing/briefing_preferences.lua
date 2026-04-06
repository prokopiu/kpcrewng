--[[
	*** KPCREWNG 0.1 
	Briefing related fields
	Kosta Prokopiu, 2026
--]]

require "kpcrew.Addon.Preferences.PreferenceDataType"
local preferenceSet = require( "kpcrew.Addon.Preferences.PreferenceSet" )
local preferenceGroup = require( "kpcrew.Addon.Preferences.PreferenceGroup" )
local preference = require("kpcrew.Addon.Preferences.PreferenceItem")
local http = require("socket.http")
local metar = require("kpcrew.metar")
local xml2lua = require("kpcrew.xml2lua")

-- ===== global vars and functions for lists
ng_briefing_to_rwys = {}
ng_briefing_to_rwyidx = 0
ng_briefing_ld_rwys = {}
ng_briefing_ld_rwyidx = 0

-- ===== initialize the preference set for aircraft
local briefingPrefSet = preferenceSet:new("briefing","BRIEFING",SCRIPT_DIRECTORY .. "../Modules/kpcrew_prefs/briefing.preferences")

-- --------------------------- general briefing fields and settings
local general 				= preferenceGroup:new("general","BRIEFING - GENERAL")
general:add(preference:new("simbriefgentime","---",ng_type_text,"Simbrief date/time|"))									-- general:simbriefgentime
general:add(preference:new("simversion",	get("sim/version/xplane_internal_version"),ng_type_text,"Simversion|"))		-- general:simversion
general:add(preference:new("firstflight",	1,ng_type_list,"First Flight of Day|First Flight|Turnaround"))		        -- general:firstflight
general:add(preference:new("sbweightunit",	"",ng_type_text,"Simbrief Weight Unit|","params.units"))		            -- general:sbweightunit
general:add(preference:new("callsign",		"",ng_type_text,"Callsign|","atc.callsign"))		                        -- general:callsign	
general:add(preference:new("costindex",		"",ng_type_info,"Cost index|","general.costindex"))		                    -- general:costindex
general:add(preference:new("cruisealtitude",0,ng_type_int,"Cruise Altitude|100","general.initial_altitude"))		    -- general:cruisealtitude
general:add(preference:new("averageisa",	0,ng_type_int,"Average ISA|1","general.avg_temp_dev"))		                -- general:averageisa
general:add(preference:new("averagewndhdg",	0,ng_type_int,"Average Wind Direction|10","general.avg_wind_dir"))		    -- general:averagewndhdg
general:add(preference:new("averagewndspd",	0,ng_type_int,"Average Wind Speed|5","general.avg_wind_spd"))		        -- general:averagewndspd
general:add(preference:new("averagewndcmp",	0,ng_type_int,"Average Wind Component|1","general.avg_wind_comp"))		    -- general:averagewndcmp
general:add(preference:new("tropopause",	0,ng_type_int,"Tropopause|10","general.avg_tropopause"))		            -- general:tropopause
general:add(preference:new("route",			"",ng_type_text,"Route|","general.route"))		                            -- general:route		
general:add(preference:new("routedistance",	0,ng_type_int,"Route Distance|1","general.route_distance"))		            -- general:routedistance
general:add(preference:new("acficao",		"",ng_type_text,"Aircraft ICAO|","aircraft.icaocode"))		                -- general:acficao	
general:add(preference:new("acfname",		"",ng_type_text,"Aircraft Name|","aircraft.name"))		                    -- general:acfname
general:add(preference:new("acfreg",		"",ng_type_text,"Aircraft Registration|","aircraft.reg"))		            -- general:acfreg
general:add(preference:new("acfselcal",		"",ng_type_text,"Aircraft SELCAL|","aircraft.selcal"))		                -- general:acfselcal
general:add(preference:new("acftlr",		0,ng_type_int,"Aircraft TLR|1","aircraft.supports_tlr"))		            -- general:acftlr
-- --------------------------------------------------------------------------------------------

-- --------------------------- Origin airport related fields and settings
local origin 				= preferenceGroup:new("origin","BRIEFING - ORIGIN")                                         
origin:add(preference:new("icao",			"",ng_type_text,"Origin ICAO|","origin.icao_code"))                         -- origin:icao			
origin:add(preference:new("name",			"",ng_type_text,"Origin Name|","origin.name"))                              -- origin:name
origin:add(preference:new("elevation",		"",ng_type_text,"Origin Elevation|","origin.elevation"))                    -- origin:elevation
origin:add(preference:new("timezone",		0,ng_type_int,"Origin Timezone|1","origin.timezone"))                       -- origin:timezone
origin:add(preference:new("planrwy",		"",ng_type_text,"Origin Runway|","origin.plan_rwy"))                        -- origin:planrwy
origin:add(preference:new("selectedrwy",	1,ng_type_int,"Index Runway|"))                                             -- origin:selectedrwy
origin:add(preference:new("transalt",		0,ng_type_int,"Origin Transition Alt|1000","origin.trans_alt"))             -- origin:transalt
origin:add(preference:new("translvl",		0,ng_type_int,"Origin Transition Lvl|1000","origin.trans_level"))           -- origin:translvl
origin:add(preference:new("metar",			"",ng_type_text,"Origin METAR|","origin.metar"))                            -- origin:metar
origin:add(preference:new("deptype",		1,ng_type_list,"Departure Type|SID|VECTORS|TRACKING"))                      -- origin:deptype
origin:add(preference:new("sid",			"",ng_type_text,"Origin SID|","general.sid_ident"))                         -- origin:sid
origin:add(preference:new("sidtransition",	"",ng_type_text,"Origin SID Transition|","general.sid_trans"))              -- origin:sidtransition
origin:add(preference:new("stand",			"",ng_type_text,"Origin Parking Position|"))                                -- origin:stand
origin:add(preference:new("standtype",		1,ng_type_list,                                                             -- origin:standtype
	"Origin Parking Type|GATE (PUSH)|STAND (PUSH)|STAND (NO PUSH)"))                                                    
origin:add(preference:new("pushtype",		1,ng_type_list,                                                             -- origin:pushtype
	"Origin Push Type|NO PUSH|NOSE LEFT|NOSE RIGHT|NOSE STRAIGHT|FACING NORTH|FACING SOUTH|FACING EAST|FACING WEST"))   
origin:add(preference:new("squawk",			2000,ng_type_int,"SQUAWK|0"))                                               -- origin:squawk
-- --------------------------------------------------------------------------------------------                         

-- --------------------------- Destination airport related fields and settings
local destination 			= preferenceGroup:new("destination","BRIEFING - DESTINATION")
destination:add(preference:new("icao",		"",ng_type_text,"Destination ICAO|","destination.icao_code"))               -- destination:icao
destination:add(preference:new("name",		"",ng_type_text,"Destination Name|","destination.name"))                    -- destination:name
destination:add(preference:new("elevation",	"",ng_type_info,"Destination Elevation|","destination.elevation"))          -- destination:elevation
destination:add(preference:new("timezone",	0,ng_type_int,"Destination Timezone|1","destination.timezone"))             -- destination:timezone
destination:add(preference:new("planrwy",	"",ng_type_text,"Destination Runway|","destination.plan_rwy"))              -- destination:planrwy
destination:add(preference:new("selectedrwy",1,ng_type_int,"Index Runway|"))                                            -- destination:selectedrwy
destination:add(preference:new("transalt",	0,ng_type_int,"Destination Transition Alt|1000","destination.trans_alt"))   -- destination:transalt
destination:add(preference:new("translvl",	0,ng_type_int,"Destination Transition Lvl|1000","destination.trans_level")) -- destination:translvl
destination:add(preference:new("metar",		"",ng_type_info,"Destination METAR|","destination.metar"))                  -- destination:metar
destination:add(preference:new("star",		"",ng_type_text,"Destination STAR|","general.star_ident"))                  -- destination:star
destination:add(preference:new("startransition","",ng_type_text,"Destination STAR Transition|","general.star_trans"))   -- destination:startransition
destination:add(preference:new("stand",		"",ng_type_text,"Destination Parking Position|"))                           -- destination:stand
destination:add(preference:new("standtype",	1,ng_type_list,"Destination Parking Type|GATE|STAND (WITH PUSH)|STAND (NO PUSH)"))    -- destination:standtype
destination:add(preference:new("arrtype",	1,ng_type_list,"Arrival Type|STAR|VECTORS"))                                -- destination:arrtype
-- --------------------------------------------------------------------------------------------

-- --------------------------- Alternate airport related fields and settings
local alternate 			= preferenceGroup:new("alternate","BRIEFING - ALTERNATE")
alternate:add(preference:new("icao",		"",ng_type_text,"Alternate ICAO|","alternate.icao_code"))                   -- alternate:icao
alternate:add(preference:new("name",		"",ng_type_text,"Alternate Name|","alternate.name"))                        -- alternate:name
alternate:add(preference:new("elevation",	"",ng_type_info,"Alternate Elevation|","alternate.elevation"))              -- alternate:elevation
alternate:add(preference:new("timezone",	0,ng_type_int,"Alternate Timezone|1","alternate.timezone"))                 -- alternate:timezone
alternate:add(preference:new("planrwy",		"",ng_type_text,"Alternate Runway|","alternate.plan_rwy"))                  -- alternate:planrwy
alternate:add(preference:new("transalt",	0,ng_type_int,"Alternate Transition Alt|1000","alternate.trans_alt"))       -- alternate:transalt
alternate:add(preference:new("translvl",	0,ng_type_int,"Alternate Transition Lvl|1000","alternate.trans_level"))     -- alternate:translvl
alternate:add(preference:new("metar",		"",ng_type_info,"Alternate METAR|","alternate.metar"))                      -- alternate:metar
alternate:add(preference:new("altimeter",	0,ng_type_float,"Alternate Altimeter A|1")) 								-- alternate:altimeter
alternate:add(preference:new("qaltimeter",	0,ng_type_float,"Alternate Altimeter Q|1"))                                 -- alternate:qaltimeter
alternate:add(preference:new("rwyheadwind",	0,ng_type_int,                                                              -- alternate:rwyheadwind",	
	"Alternate Runway Headwind|10"))
alternate:add(preference:new("rwycrosswind",	0,ng_type_int,                                                          -- alternate:rwycrosswind",	
	"Alternate Runway Crosswind|10"))                     
alternate:add(preference:new("windhdg",		0,ng_type_int,                                                              -- alternate:windhdg
	"Altername Wind Heading|10"))                                                  
alternate:add(preference:new("windspd",		0,ng_type_int,"Alternate Wind Speed|1"))   									-- alternate:windspd
alternate:add(preference:new("temperature",	0,ng_type_int,"Alternate Temperature|1")) 									-- alternate:temperature
alternate:add(preference:new("surfacecond",	"",ng_type_text,                                                            -- takeoff:surfacecond",	
	"Alternate Surface Condition|"))                                           

-- --------------------------------------------------------------------------------------------

-- --------------------------- Takeoff related fields and settings
local takeoff 				= preferenceGroup:new("takeoff","BRIEFING - TAKEOFF")										
takeoff:add(preference:new("windhdg",		0,ng_type_int,"Takeoff Wind Heading|10",                                    -- takeoff:windhdg",		
	"tlr.takeoff.conditions.wind_direction"))                                                                           
takeoff:add(preference:new("windspd",		0,ng_type_int,                                                              -- takeoff:windspd",		
	"Takeoff Wind Speed|1","tlr.takeoff.conditions.wind_speed"))                                                        
takeoff:add(preference:new("temperature",	0,ng_type_int,                                                              -- takeoff:temperature",	
	"Takeoff Temperature|1","tlr.takeoff.conditions.temperature"))                                                      
takeoff:add(preference:new("altimeter",		0,ng_type_float,                                                            -- takeoff:altimeter",		
	"Takeoff Altimeter|1","tlr.takeoff.conditions.altimeter"))                                                          
takeoff:add(preference:new("qaltimeter",	0,ng_type_float,"Takeoff Altimeter|1"))                                     -- takeoff:qaltimeter",	
takeoff:add(preference:new("surfacecond",	"",ng_type_text,                                                            -- takeoff:surfacecond",	
	"Takeoff Surface Condition|","tlr.takeoff.conditions.surface_condition"))                                           
takeoff:add(preference:new("rwyident",		"",ng_type_text,                                                            -- takeoff:rwyident",		
	"Takeoff Runway|","tlr.takeoff.runway[ng_briefing_to_rwyidx].identifier"))                                          
takeoff:add(preference:new("rwylength",		0,ng_type_int,                                                              -- takeoff:rwylength",		
	"Takeoff Runway Length|10","tlr.takeoff.runway[ng_briefing_to_rwyidx].length"))                                     
takeoff:add(preference:new("rwytora",		0,ng_type_int,                                                              -- takeoff:rwytora",		
	"Takeoff Runway TORA|10","tlr.takeoff.runway[ng_briefing_to_rwyidx].length_tora"))                                  
takeoff:add(preference:new("rwyelevation",	0,ng_type_int,                                                              -- takeoff:rwyelevation",	
	"Takeoff Runway Elevation|10","tlr.takeoff.runway[ng_briefing_to_rwyidx].elevation"))                               
takeoff:add(preference:new("rwycourse",		0,ng_type_int,                                                              -- takeoff:rwycourse",		
	"Takeoff Runway Mag Course|10","tlr.takeoff.runway[ng_briefing_to_rwyidx].magnetic_course"))                        
takeoff:add(preference:new("rwyheadwind",	0,ng_type_int,                                                              -- takeoff:rwyheadwind",	
	"Takeoff Runway Headwind|10","tlr.takeoff.runway[ng_briefing_to_rwyidx].headwind_component"))                       
takeoff:add(preference:new("rwycrosswind",	0,ng_type_int,                                                              -- takeoff:rwycrosswind",	
	"Takeoff Runway Crosswind|10","tlr.takeoff.runway[ng_briefing_to_rwyidx].crosswind_component"))                     
takeoff:add(preference:new("rwyilsfreq",	"",ng_type_text,                                                            -- takeoff:rwyilsfreq",	
	"Takeoff Runway ILS Freq|","tlr.takeoff.runway[ng_briefing_to_rwyidx].ils_frequency"))                              
takeoff:add(preference:new("rwyflaps",		"",ng_type_text,                                                            -- takeoff:rwyflaps",		
	"Takeoff Flaps|","tlr.takeoff.runway[ng_briefing_to_rwyidx].flap_setting"))                                         
takeoff:add(preference:new("selectedflaps",	1,ng_type_int,"Selected Flaps|"))                                           -- takeoff:selectedflaps",	
takeoff:add(preference:new("rwythrust",		"",ng_type_text,                                                            -- takeoff:rwythrust",		
	"Takeoff Thrust|","tlr.takeoff.runway[ng_briefing_to_rwyidx].thrust_setting"))                                      
takeoff:add(preference:new("selectedthrust",1,ng_type_int,"Selected Thrust|0"))                                         -- takeoff:selectedthrust",
takeoff:add(preference:new("rwybleed",		"",ng_type_text,                                                            -- takeoff:rwybleed",		
	"Takeoff Bleed|","tlr.takeoff.runway[ng_briefing_to_rwyidx].bleed_setting"))                                        
takeoff:add(preference:new("selectedbleed",	2,ng_type_int,"Selected Bleeds|"))                                          -- takeoff:selectedbleed",	
takeoff:add(preference:new("selectedpacks",	2,ng_type_int,"Selected Packs|"))                                           -- takeoff:selectedpacks",	
takeoff:add(preference:new("rwyaice",		"",ng_type_text,                                                            -- takeoff:rwyaice",		
	"Takeoff A/ICE|","tlr.takeoff.runway[ng_briefing_to_rwyidx].anti_ice_setting"))                                     
takeoff:add(preference:new("selectedaice",	1,ng_type_int,"Selected Aice|"))                                            -- takeoff:selectedaice",	
takeoff:add(preference:new("rwyflextemp",	0,ng_type_int,																-- takeoff:rwyflextemp",	
	"Takeoff Flex Temp|0","tlr.takeoff.runway[ng_briefing_to_rwyidx].flex_temperature"))                                 
takeoff:add(preference:new("rwyv1",			0,ng_type_int,                                                              -- takeoff:rwyv1",			
	"Takeoff V1|1","tlr.takeoff.runway[ng_briefing_to_rwyidx].speeds_v1"))                                              
takeoff:add(preference:new("rwyvr",			0,ng_type_int,                                                              -- takeoff:rwyvr",			
	"Takeoff VR|1","tlr.takeoff.runway[ng_briefing_to_rwyidx].speeds_vr"))                                              
takeoff:add(preference:new("rwyv2",			0,ng_type_int,                                                              -- takeoff:rwyv2",			
	"Takeoff V2|1","tlr.takeoff.runway[ng_briefing_to_rwyidx].speeds_v2"))                                              
takeoff:add(preference:new("initalt",		4900,ng_type_int,"Initial Alt|1","general.initial_altitude"))               -- takeoff:initalt",		
takeoff:add(preference:new("inithdg",		0,ng_type_int,"Initial Hdg|1","navlog.fix[1].track_mag"))                   -- takeoff:inithdg",		
takeoff:add(preference:new("pitchtrim",		0,ng_type_float,"Takeoff Pitchtrim|0"))                                     -- takeoff:pitchtrim",		
-- --------------------------------------------------------------------------------------------                         

-- --------------------------- Landing related fields and settings
local landing 				= preferenceGroup:new("landing","BRIEFING - LANDING")
landing:add(preference:new("windhdg",		0,ng_type_int,                                                               -- landing:windhdg
	"Landing Wind Heading|10","tlr.landing.conditions.wind_direction"))                                                  
landing:add(preference:new("windspd",		0,ng_type_int,"Landing Wind Speed|1","tlr.landing.conditions.wind_speed"))   -- landing:windspd
landing:add(preference:new("temperature",	0,ng_type_int,"Landing Temperature|1","tlr.landing.conditions.temperature")) -- landing:temperature
landing:add(preference:new("altimeter",		0,ng_type_float,"Landing Altimeter A|1","tlr.landing.conditions.altimeter")) -- landing:altimeter
landing:add(preference:new("qaltimeter",	0,ng_type_float,"Landing Altimeter Q|1"))                                    -- landing:qaltimeter
landing:add(preference:new("surfacecond",	"",ng_type_text,                                                             -- landing:surfacecond
	"Landing Surface Condition|","tlr.landing.conditions.surface_condition"))                                            
landing:add(preference:new("plannedwgt",	0,ng_type_info,                                                              -- landing:plannedwgt
	"Landing Planned Weight|","tlr.landing.conditions.planned_weight"))                                                  
landing:add(preference:new("dryflaps",		"",ng_type_text,                                                             -- landing:dryflaps
	"Landing Flaps Dry|","tlr.landing.distance_dry.flap_setting"))                                                       
landing:add(preference:new("drybrakes",		"",ng_type_text,                                                             -- landing:drybrakes
	"Landing Brake Dry|","tlr.landing.distance_dry.brake_setting"))                                                      
landing:add(preference:new("dryvref",		0,ng_type_int,                                                               -- landing:dryvref
	"Landing VREF Dry|1","tlr.landing.distance_dry.speeds_vref"))                                                        
landing:add(preference:new("dryactdist",	0,ng_type_int,                                                               -- landing:dryactdist
	"Landing Actual Distance Dry|1","tlr.landing.distance_dry.actual_distance"))                                         
landing:add(preference:new("dryfactdist",	0,ng_type_int,                                                               -- landing:dryfactdist
	"Landing Factored Distance Dry|1","tlr.landing.distance_dry.factored_distance"))                                     
landing:add(preference:new("wetflaps",		"",ng_type_text,                                                             -- landing:wetflaps
	"Landing Flaps Wet|","tlr.landing.distance_wet.flap_setting"))                                                       
landing:add(preference:new("wetbrakes",		"",ng_type_text,                                                             -- landing:wetbrakes
	"Landing Brake Wet|","tlr.landing.distance_wet.brake_setting"))                                                      
landing:add(preference:new("wetvref",		0,ng_type_int,                                                               -- landing:wetvref
	"Landing VREF Wet|1","tlr.landing.distance_wet.speeds_vref"))                                                        
landing:add(preference:new("wetactdist",	0,ng_type_int,                                                               -- landing:wetactdist
	"Landing Actual Distance Wet|1","tlr.landing.distance_wet.actual_distance"))                                         
landing:add(preference:new("wetfactdist",	0,ng_type_int,                                                               -- landing:wetfactdist
	"Landing Factored Distance Wet|1","tlr.landing.distance_wet.factored_distance"))                                     
landing:add(preference:new("selectedflaps",	1,ng_type_int,"Selected ldg Flaps|"))                                        -- landing:selectedflaps
landing:add(preference:new("selectedbleed",	2,ng_type_int,"Selected Ldg Bleeds|"))                                       -- landing:selectedbleed
landing:add(preference:new("selectedaice",	1,ng_type_int,"Selected Ldg Aice|"))                                         -- landing:selectedaice
landing:add(preference:new("selectedabrk",	1,ng_type_int,"Selected Autobrake|"))                                        -- landing:selectedabrk
landing:add(preference:new("decisionalt",	1650,ng_type_int,"Decision Altitude|"))                                      -- landing:decisionalt
landing:add(preference:new("decisionheight",200,ng_type_int,"Decision Height|"))                                         -- landing:decisionheight
landing:add(preference:new("gaaltitude",	3000,ng_type_int,"Go-Around Altitude Height|"))                              -- landing:gaaltitude
landing:add(preference:new("gaheading",		250,ng_type_int,"Go-Around Altitude Height|"))                               -- landing:gaheading
landing:add(preference:new("rwyvref",		0,ng_type_int,"landing Vref|1"))                                             -- landing:rwyvref
landing:add(preference:new("rwyvapp",		0,ng_type_int,"landing Vapp|1"))                                             -- landing:rwyvapp
landing:add(preference:new("rwyident",		"",ng_type_text,                                                             -- landing:rwyident
	"Landing Runway|","tlr.landing.runway[ng_briefing_ld_rwyidx].identifier"))                                           
landing:add(preference:new("rwylength",		0,ng_type_int,                                                               -- landing:rwylength
	"Landing Runway Length|10","tlr.landing.runway[ng_briefing_ld_rwyidx].length"))                                      
landing:add(preference:new("rwyelevation",	0,ng_type_int,                                                               -- landing:rwyelevation
	"Landing Runway Elevation|10","tlr.landing.runway[ng_briefing_ld_rwyidx].elevation"))                                
landing:add(preference:new("rwycourse",		0,ng_type_int,                                                               -- landing:rwycourse
	"Landing Runway Mag Course|10","tlr.landing.runway[ng_briefing_ld_rwyidx].magnetic_course"))                         
landing:add(preference:new("rwyheadwind",	0,ng_type_int,                                                               -- landing:rwyheadwind
	"Landing Runway Headwind|10","tlr.landing.runway[ng_briefing_ld_rwyidx].headwind_component"))                        
landing:add(preference:new("rwycrosswind",	0,ng_type_int,                                                               -- landing:rwycrosswind
	"Landing Runway Crosswind|10","tlr.landing.runway[ng_briefing_ld_rwyidx].crosswind_component"))                      
landing:add(preference:new("rwyilsfreq",	"",ng_type_text,                                                             -- landing:rwyilsfreq
	"Landing Runway ILS Freq|","tlr.landing.runway[ng_briefing_ld_rwyidx].ils_frequency"))                               
landing:add(preference:new("rwylda",		0,ng_type_int,                                                               -- landing:rwylda
	"Landing Runway LDA|10","tlr.landing.runway[ng_briefing_ld_rwyidx].length_lda"))                                     
-- --------------------------------------------------------------------------------------------

-- --------------------------- Fuel related fields and settings
local fuel 					= preferenceGroup:new("fuel","BRIEFING - FUEL")
fuel:add(preference:new("taxi",				0,ng_type_int,"Taxi Fuel|10","fuel.taxi"))                                    -- fuel:taxi
fuel:add(preference:new("enroute",			0,ng_type_int,"Enroute Fuel|10","fuel.enroute_burn"))                         -- fuel:enroute
fuel:add(preference:new("contingency",		0,ng_type_int,"Contingency Fuel|10","fuel.contingency"))                      -- fuel:contingency
fuel:add(preference:new("alternate",		0,ng_type_int,"Alternate Fuel|10","fuel.alternate_burn"))                     -- fuel:alternate
fuel:add(preference:new("reserve",			0,ng_type_int,"Reserve Fuel|10","fuel.reserve"))                              -- fuel:reserve
fuel:add(preference:new("extra",			0,ng_type_int,"Extra Fuel|10","fuel.extra"))                                  -- fuel:extra
fuel:add(preference:new("mintakeoff",		0,ng_type_int,"Min TO Fuel|10","fuel.min_takeoff"))                           -- fuel:mintakeoff
fuel:add(preference:new("plantakeoff",		0,ng_type_int,"Plan TO Fuel|10","fuel.plan_takeoff"))                         -- fuel:plantakeoff
fuel:add(preference:new("planramp",			0,ng_type_int,"Plan Ramp Fuel|10","fuel.plan_ramp"))                          -- fuel:planramp
fuel:add(preference:new("planlanding",		0,ng_type_int,"Plan LDG Fuel|10","fuel.plan_landing"))                        -- fuel:planlanding
fuel:add(preference:new("avgfuelflow",		0,ng_type_int,"AVG Fuel Flow|10","fuel.avg_fuel_flow"))                       -- fuel:avgfuelflow
fuel:add(preference:new("maxtanks",			0,ng_type_int,"Max Tanks Fuel|10","fuel.max_tanks"))                          -- fuel:maxtanks
-- --------------------------------------------------------------------------------------------

-- --------------------------- Times related fields and settings
local times 				= preferenceGroup:new("times","BRIEFING - TIMES")
times:add(preference:new("estenroute",		0,ng_type_int,"Estimate Enroute Time|10","times.est_time_enroute"))           -- times:estenroute
times:add(preference:new("schedenroute",	0,ng_type_int,"Scheduled Enroute|10","times.sched_time_enroute"))             -- times:schedenroute
times:add(preference:new("schedout",		0,ng_type_int,"Scheduled OUT|10","times.sched_out"))                          -- times:schedout
times:add(preference:new("schedoff",		0,ng_type_int,"Scheduled OFF|10","times.sched_off"))                          -- times:schedoff
times:add(preference:new("schedon",			0,ng_type_int,"Scheduled ON|10","times.sched_on"))                            -- times:schedon
times:add(preference:new("schedin",			0,ng_type_int,"Scheduled IN|10","times.sched_in"))                            -- times:schedin
times:add(preference:new("schedblock",		0,ng_type_int,"Scheduled BLOCK|10","times.sched_block"))                      -- times:schedblock
times:add(preference:new("estout",			0,ng_type_int,"Estimated OUT|10","times.est_out"))                            -- times:estout
times:add(preference:new("estoff",			0,ng_type_int,"Estimated OFF|10","times.est_off"))                            -- times:estoff
times:add(preference:new("eston",			0,ng_type_int,"Estimated ON|10","times.est_on"))                              -- times:eston
times:add(preference:new("estin",			0,ng_type_int,"Estimated IN|10","times.est_in"))                              -- times:estin
times:add(preference:new("estblock",		0,ng_type_int,"Estimated BLOCK|10","times.est_block"))                        -- times:estblock
times:add(preference:new("taxiout",			0,ng_type_int,"Taxi OUT|10","times.taxi_out"))                                -- times:taxiout
times:add(preference:new("taxiin",			0,ng_type_int,"Taxi IN|10","times.taxi_in"))                                  -- times:taxiin
times:add(preference:new("reserve",			0,ng_type_int,"Reserve Time|10","times.reserve_time"))                        -- times:reserve
times:add(preference:new("endurance",		0,ng_type_int,"Endurance|10","times.endurance"))                              -- times:endurance
times:add(preference:new("contfuel",		0,ng_type_int,"Contingency Fuel|10","times.contfuel_time"))                   -- times:contfuel
times:add(preference:new("extrafuel",		0,ng_type_int,"Extra Fuel|10","times.extrafuel_time"))                        -- times:extrafuel
-- --------------------------------------------------------------------------------------------

-- --------------------------- Weight related fields and settings
local weights 				= preferenceGroup:new("weights","BRIEFING - WEIGHTS")
weights:add(preference:new("oew",			0,ng_type_int,"Weight oew|10","weights.oew"))                                 -- weights:oew
weights:add(preference:new("paxcount",		0,ng_type_int,"Weight pax_count|10","weights.pax_count"))                     -- weights:paxcount
weights:add(preference:new("paxweight",		0,ng_type_int,"Weight pax_weight|10","weights.pax_weight"))                   -- weights:paxweight
weights:add(preference:new("bagweight",		0,ng_type_int,"Weight bag_weight|10","weights.bag_weight"))                   -- weights:bagweight
weights:add(preference:new("bagcount",		0,ng_type_int,"Bag weight|10","weights.bag_count"))                           -- weights:bagcount
weights:add(preference:new("freightadded",	0,ng_type_int,"Weight freight_added|10","weights.freight_added"))             -- weights:freightadded
weights:add(preference:new("cargo",			0,ng_type_int,"Weight cargo|10","weights.cargo"))                             -- weights:cargo
weights:add(preference:new("payload",		0,ng_type_int,"Weight payload|10","weights.payload"))                         -- weights:payload
weights:add(preference:new("estzfw",		0,ng_type_int,"Weight est_zfw|10","weights.est_zfw"))                         -- weights:estzfw
weights:add(preference:new("maxzfw",		0,ng_type_int,"Weight max_zfw|10","weights.max_zfw"))                         -- weights:maxzfw
weights:add(preference:new("esttow",		0,ng_type_int,"Weight est_tow|10","weights.est_tow"))                         -- weights:esttow
weights:add(preference:new("maxtow",		0,ng_type_int,"Weight max_tow|10","weights.max_tow"))                         -- weights:maxtow
weights:add(preference:new("estldw",		0,ng_type_int,"Weight est_ldw|10","weights.est_ldw"))                         -- weights:estldw
weights:add(preference:new("maxldw",		0,ng_type_int,"Weight max_ldw|10","weights.max_ldw"))                         -- weights:maxldw
weights:add(preference:new("estramp",		0,ng_type_int,"Weight est_ramp|10","weights.est_ramp"))                       -- weights:estramp
-- --------------------------------------------------------------------------------------------

-- add sections to briefing set
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

-- ===== Parse downloaded simbrief file and update runway specific values
function ng_load_simbrief()
	
	-- check if a simbrief.xml file exists in kpcrew_prefs folder
	if ng_file_exists(SCRIPT_DIRECTORY .. "../Modules/kpcrew_prefs/simbrief.xml") then
		
		-- latest OFP gets stored in kpcrew_prefs folder as simbrief.xml
		local xmlfile = xml2lua.loadFile(SCRIPT_DIRECTORY .. "../Modules/kpcrew_prefs/simbrief.xml")
		local parser = xml2lua.parser(xmlhandler)
		parser:parse(xmlfile)

		ng_getBriefPrefs():set("alternate:metar",xmlhandler.root.OFP.alternate.metar)
		local qaltim = string.match(ng_getBriefPrefs():get("alternate:metar"),"Q%d%d%d%d")
		local aaltim = string.match(ng_getBriefPrefs():get("alternate:metar"),"A%d%d%d%d")
		if qaltim ~= nil then 
			ng_getBriefPrefs():set("alternate:qaltimeter", string.sub(qaltim,2)) 
			ng_getBriefPrefs():set("alternate:altimeter",(ng_getBriefPrefs():get("alternate:qaltimeter") / 33.8639))
		end
		if aaltim ~= nil then 
			ng_getBriefPrefs():set("alternate:altimeter", string.sub(aaltim,2,3).."."..string.sub(aaltim,4,5)) 
			ng_getBriefPrefs():set("alternate:qaltimeter",(ng_getBriefPrefs():get("alternate:altimeter") * 33.8639))
		end
		local wind = string.match(ng_getBriefPrefs():get("alternate:metar"),"%d%d%d%d%dKT")
		if wind ~= nil then
			ng_getBriefPrefs():set("alternate:windhdg", 0+string.sub(wind,1,3))
			ng_getBriefPrefs():set("alternate:windspd", 0+string.sub(wind,4,5))
		end
		
		local temps = string.match(ng_getBriefPrefs():get("alternate:metar"),"M%d%d/")
		if temps ~= nil then
			ng_getBriefPrefs():set("alternate:temperature", 0-string.sub(temps,2,3))
		else
			local temps = string.match(ng_getBriefPrefs():get("alternate:metar"),"%d%d/%d%d")
			if temps ~= nil then
				ng_getBriefPrefs():set("alternate:temperature", 0+string.sub(temps,1,2))
			else
				local temps = string.match(ng_getBriefPrefs():get("alternate:metar"),"%d%d/M")
				if temps ~= nil then
					ng_getBriefPrefs():set("alternate:temperature", 0+string.sub(temps,1,2))
				end
			end
		end

		ng_getBriefPrefs():set("general:simbriefgentime", string.upper(os.date("%d.%m.%Y - %H:%M",xmlhandler.root.OFP.params.time_generated)))
		-- get runway array from xml if section exists in simbrief.xml
		if xmlhandler.root.OFP.tlr.takeoff ~= nil then
			
			-- get baro pressure qnh and calculate inHG for briefing from the tlr.takeoff section
			ng_getBriefPrefs():set("takeoff:qaltimeter",(ng_getBriefPrefs():get("takeoff:altimeter") * 33.8659))

			ng_briefing_to_rwys = xmlhandler.root.OFP.tlr.takeoff.runway
			for i=1,#ng_briefing_to_rwys do 
				
				if ng_briefing_to_rwys[i].identifier == xmlhandler.root.OFP.origin.plan_rwy then -- find the suggested runway in simbrief
					
					ng_briefing_to_rwyidx = i -- set the index of runway
					ng_getBriefPrefs():set("origin:selectedrwy",i)
					
					ng_getBriefPrefs():set("takeoff:rwycourse",ng_briefing_to_rwys[ng_briefing_to_rwyidx].magnetic_course)
					ng_getBriefPrefs():set("takeoff:rwyheadwind",ng_briefing_to_rwys[ng_briefing_to_rwyidx].headwind_component)
					ng_getBriefPrefs():set("takeoff:rwycrosswind",ng_briefing_to_rwys[ng_briefing_to_rwyidx].crosswind_component)
					ng_getBriefPrefs():set("takeoff:rwyilsfreq",ng_briefing_to_rwys[ng_briefing_to_rwyidx].ils_frequency)

					-- takeoff flaps
					local splitTitle = ng_split(ng_getAcfPrefs():get("controls:toflapslbl"),"|")
					local flapidx = ng_indexOf(splitTitle,ng_briefing_to_rwys[ng_briefing_to_rwyidx].flap_setting)
					if flapidx == nil then flapidx = 1 else flapidx = flapidx - 1 end
					ng_getBriefPrefs():set("takeoff:selectedflaps",flapidx)

					-- takeoff thrust settings
					if ng_getAcfPrefs():get("air:hastothrust") then
						local splitTitle = ng_split(ng_getAcfPrefs():get("engines:tothrust"),"|") 
						ng_getBriefPrefs():set("takeoff:selectedthrust",ng_indexOf(splitTitle,ng_briefing_to_rwys[ng_briefing_to_rwyidx].thrust_setting)-1) 
					end 
					
					-- has engine bleeds
					if ng_getAcfPrefs():get("air:hasenginebleeds") then
						local splitTitle = ng_split(ng_getAcfPrefs():get("air:takeoffbleeds"),"|")
						if ng_indexOf(splitTitle,ng_briefing_to_rwys[ng_briefing_to_rwyidx].bleed_setting) ~= nil then 
							ng_getBriefPrefs():set("takeoff:selectedbleed",ng_indexOf(splitTitle,ng_briefing_to_rwys[ng_briefing_to_rwyidx].bleed_setting)-1)
						else
							ng_getBriefPrefs():set("takeoff:selectedbleed",1)
						end
					end 
					
					-- anti ice settings
					if ng_briefing_to_rwys[ng_briefing_to_rwyidx].anti_ice_setting == "N/A" then ng_briefing_to_rwys[ng_briefing_to_rwyidx].anti_ice_setting = "OFF" end
					local splitTitle = ng_split(ng_getAcfPrefs():get("aice:takeoffaice"),"|")
					ng_getBriefPrefs():set("takeoff:selectedaice",ng_indexOf(splitTitle,ng_briefing_to_rwys[ng_briefing_to_rwyidx].anti_ice_setting)-1)

					-- engine flex temperature
					if ng_getAcfPrefs():get("engines:hasflextemp") then 
						if type(ng_briefing_to_rwys[ng_briefing_to_rwyidx].flex_temperature) ~= 'table' then
							ng_getBriefPrefs():set("takeoff:rwyflextemp",ng_briefing_to_rwys[ng_briefing_to_rwyidx].flex_temperature) 						
						end
					end
						
					-- takeoff vspeeds
					ng_getBriefPrefs():set("takeoff:rwyv1",ng_briefing_to_rwys[ng_getBriefPrefs():get("origin:selectedrwy")].speeds_v1) 						
					ng_getBriefPrefs():set("takeoff:rwyvr",ng_briefing_to_rwys[ng_getBriefPrefs():get("origin:selectedrwy")].speeds_vr) 						
					ng_getBriefPrefs():set("takeoff:rwyv2",ng_briefing_to_rwys[ng_getBriefPrefs():get("origin:selectedrwy")].speeds_v2) 	
					
					-- takeoff initial heading runway direction
					ng_getBriefPrefs():set("takeoff:inithdg",ng_briefing_to_rwys[ng_getBriefPrefs():get("origin:selectedrwy")].magnetic_course)
				end
			end
		end

		-- get runway array from xml if section exists in simbrief.xml
		if xmlhandler.root.OFP.tlr.landing ~= nil then
			
			-- get baro pressure qnh and calculate inHG for briefing from the tlr.landing section
			ng_getBriefPrefs():set("landing:qaltimeter",(ng_getBriefPrefs():get("landing:altimeter") * 33.8659))
			
			local splitTitle = ng_split(ng_getAcfPrefs():get("controls:ldflapslbl"),"|")
			if ng_getBriefPrefs():get("landing:surfacecond") == "dry" then
				local flapidx = ng_indexOf(splitTitle,ng_getBriefPrefs():get("landing:dryflaps"))
				if flapidx == nil then flapidx = 1 else flapidx = flapidx -1 end
				ng_getBriefPrefs():set("landing:selectedflaps",flapidx)
			else
				local flapidx = ng_indexOf(splitTitle,ng_getBriefPrefs():get("landing:wetflaps"))
				if flapidx == nil then flapidx = 1 else flapidx = flapidx -1 end
				ng_getBriefPrefs():set("landing:selectedflaps",flapidx)
			end

			if ng_getAcfPrefs():get("general:hasautobrk") then 
				local splitTitle = ng_split(ng_getAcfPrefs():get("general:abrkmodelblt"),"|")
				if ng_getBriefPrefs():get("landing:surfacecond") == "dry" then
					if ng_getBriefPrefs():get("landing:drybrakes") ~= nil then
						if ng_getBriefPrefs():get("landing:drybrakes") == "MAX MAN" then ng_getBriefPrefs():set("landing:drybrakes","OFF") end
						ng_getBriefPrefs():set("landing:selectedabrk",ng_indexOf(splitTitle,ng_getBriefPrefs():get("landing:drybrakes"))-1)
					end
				end
				if ng_getBriefPrefs():get("landing:surfacecond") == "dry" then
					if ng_getBriefPrefs():get("landing:wetbrakes") ~= nil then
						if ng_getBriefPrefs():get("landing:wetbrakes") == "MAX MAN" then ng_getBriefPrefs():set("landing:wetbrakes","OFF") end
						ng_getBriefPrefs():set("landing:selectedabrk",ng_indexOf(splitTitle,ng_getBriefPrefs():get("landing:wetbrakes"))-1)
					end
				end
			end

			if ng_getBriefPrefs():get("landing:surfacecond") == "dry" then
				ng_getBriefPrefs():set("landing:rwyvref",ng_getBriefPrefs():get("landing:dryvref"))
				ng_getBriefPrefs():set("landing:rwyvapp",ng_getBriefPrefs():get("landing:dryvref")+5)
			else
				ng_getBriefPrefs():set("landing:rwyvref",ng_getBriefPrefs():get("landing:wetvref"))
				ng_getBriefPrefs():set("landing:rwyvapp",ng_getBriefPrefs():get("landing:wetvref")+5)
			end

			ng_briefing_ld_rwys = xmlhandler.root.OFP.tlr.landing.runway
			for i=1,#ng_briefing_ld_rwys do 

				if ng_briefing_ld_rwys[i].identifier == xmlhandler.root.OFP.destination.plan_rwy then  -- find the suggested runway in simbrief

					ng_briefing_ld_rwyidx = i 
					ng_getBriefPrefs():set("destination:selectedrwy",i)
					
					ng_getBriefPrefs():set("landing:rwycourse",ng_briefing_ld_rwys[ng_briefing_ld_rwyidx].magnetic_course)
					ng_getBriefPrefs():set("landing:rwyheadwind",ng_briefing_ld_rwys[ng_briefing_ld_rwyidx].headwind_component)
					ng_getBriefPrefs():set("landing:rwycrosswind",ng_briefing_ld_rwys[ng_briefing_ld_rwyidx].crosswind_component)
					ng_getBriefPrefs():set("landing:rwyilsfreq",ng_briefing_ld_rwys[ng_briefing_ld_rwyidx].ils_frequency)
					
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