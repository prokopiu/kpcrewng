-- Render windows for KPCrewNG
--
-- @author Kosta Prokopiu
-- @copyright 2026 Kosta Prokopiu

if FLYWITHLUA == false then -- for dev environment on Linux and cimgui
	local imgui = require "cimgui"
	local ffi = require "ffi"
	require "teststubs"
end

require "kpcrew.nggenutils"
require "kpcrew.imgui_utils"
require "kpcrew.acft_select"

local SOP = require("kpcrew.Addon.SOP.SOP")

ng_imgui_current_main_tab = 0
ng_imgui_main_wnd_width = 950
ng_imgui_main_wnd_height = 950
ng_weightunit = "KGS"
ng_kgslbs = 1
ng_editor_system_icao = ng_acft_select(2)
ng_editor_system_json = nil
ng_editor_sop_icao = ng_acft_select(1)
ng_editor_sop_json = nil
ng_editor_sop_expand1 = false
ng_editor_sop_expcol1 = 0
ng_editor_sop_expand2 = false
ng_editor_sop_expcol2 = 0
ng_editor_sop_expand3 = false
ng_editor_sop_expcol3 = 0
ng_editor_sop_newflow = ""
ng_editor_sop_newitem = ""
ng_editor_sop_newelement = ""
ng_editor_system_newsystem = ""
ng_editor_system_newelement = ""

-- -----------------------------------------------------------------------------------------
-- Main window rendering
-- -----------------------------------------------------------------------------------------
-- Draw the Briefing main window
function ng_draw_main_window()

	-- set and display current weight unit
	if ng_getAppPrefs():get("general:weightunit") == 1 then 
		ng_weightunit = "KGS"
		nk_kgslbs = (ng_getBriefPrefs():get("general:sbweightunit") == "kgs" and 1 or 1/2.20462262) 
	else 
		ng_weightunit = "LBS"
		ng_kgslbs = (ng_getBriefPrefs():get("general:sbweightunit") == "kgs" and 2.20462262 or 1)
	end
	
-- -----------------------------------------------------------------------------------------
-- Draw the Status block on top of briefing window
	local function render_status_block()

		-- Load latest simbrief flight plan
		ng_imgui_in_button("SIMBRIEF", "SIMBRIEF", 70, 20, 
			function () ng_download_simbrief() ng_load_simbrief() end)

		imgui.SameLine()
		ng_imgui_in_button("loadbrief", "LOAD", 70, 20, 
			function () ng_getBriefPrefs():load() end)

		imgui.SameLine()
		ng_imgui_in_button("savebrief","SAVE", 70, 20,
			function () ng_getBriefPrefs():save() end)

		imgui.Separator()
		
		-- XP: vvvvvv Flight State: State of SOP Aircraft Type: type [XP ICAO: XXXX]
		-- ---------------------------------------------------------------------------------------
		ng_imgui_out_text(color_yellow,"XP:",color_white, ng_getBriefPrefs():get("general:simversion"))
		
		imgui.SameLine()
		ng_imgui_out_text(color_yellow, "Flight State:", color_white, 
			ng_flightphases[math.abs(ng_getBckVars():get("general:flightstate"))])

	    imgui.SameLine()
		ng_imgui_out_text(color_green, "Aircraft Type:", color_white, 
			ng_get_active_addon():getTitle() .. " - " .. ng_acf_icao .. " [XP ICAO: " .. PLANE_ICAO .. "]")

		imgui.SameLine()
		ng_imgui_out_text(color_green, "SB Wgt Unit:", color_white, 
			ng_getBriefPrefs():get("general:sbweightunit"))


		-- Position: 99o41'14" N - 9o11'35" E/N99999 E99999 | Elevation 9999 ft | Time: 99:99:99 / 99:99:99Z
		-- ---------------------------------------------------------------------------------------

		ng_imgui_out_text(color_green,"Position:",color_white,ng_convertDMS(get("sim/flightmodel/position/latitude"),get("sim/flightmodel/position/longitude")) .. "/" ..
				ng_convertINS(get("sim/flightmodel/position/latitude"),get("sim/flightmodel/position/longitude")))

		imgui.SameLine()
		ng_imgui_out_text(color_green, "| Elevation:", color_white, 
			string.format("%6.0f ft\n",get("sim/cockpit2/autopilot/altitude_readout_preselector")))
			
		imgui.SameLine()
		ng_imgui_out_text(color_green, "| Time:", color_white, 
			ng_dispTimeFull(get("sim/time/zulu_time_sec")) .. "Z / " .. ng_dispTimeFull(get("sim/time/local_time_sec")))

		imgui.SameLine()
		ng_imgui_out_text(color_green, "Date:", color_white, 
			string.upper(os.date("%d.%m.%Y",ng_getBriefPrefs():get("times:schedout"))))

		imgui.Separator()
		
		-- ---------------------------------------------------------------------------------------
		-- Flight Times: Off Blocks: S ==:== C | Out: S ==:== C | In: S ==:== C | On Blocks: S ==:== C RST
		-- ---------------------------------------------------------------------------------------
		ng_imgui_out_text(color_white,"Flight times:")
		imgui.SameLine()
		ng_imgui_in_lbutton("outtime:", "S", 15, 20, "OUT:", color_white,
			function () ng_getBckVars():set("general:timeout",ng_dispTimeHHMM(get("sim/time/zulu_time_sec"))) end)
		imgui.SameLine()
		ng_imgui_in_lbutton("outclear:", "C", 15, 20, ng_getBckVars():get("general:timeout"), color_yellow,
			function () ng_getBckVars():set("general:timeout","==:==") end)

			imgui.SameLine()
			ng_imgui_in_lbutton("offtime:", "S", 15, 20, "OFF:", color_white,
				function () ng_getBckVars():set("general:timeoff",ng_dispTimeHHMM(get("sim/time/zulu_time_sec"))) end)
			imgui.SameLine()
			ng_imgui_in_lbutton("offclear:", "C", 15, 20, ng_getBckVars():get("general:timeoff"), color_yellow,
				function () ng_getBckVars():set("general:timeoff","==:==") end)

			imgui.SameLine()
			ng_imgui_in_lbutton("intime:", "S", 15, 20, "IN:", color_white,
				function () ng_getBckVars():set("general:timein",ng_dispTimeHHMM(get("sim/time/zulu_time_sec"))) end)
			imgui.SameLine()
			ng_imgui_in_lbutton("inclear:", "C", 15, 20, ng_getBckVars():get("general:timein"), color_yellow,
				function () ng_getBckVars():set("general:timein","==:==") end)

			imgui.SameLine()
			ng_imgui_in_lbutton("ontime:", "S", 15, 20, "ON:", color_white,
				function () ng_getBckVars():set("general:timeon",ng_dispTimeHHMM(get("sim/time/zulu_time_sec"))) end)
			imgui.SameLine()
			ng_imgui_in_lbutton("onclear:", "C", 15, 20, ng_getBckVars():get("general:timeon"), color_yellow,
				function () ng_getBckVars():set("general:timeon","==:==") end)

			imgui.SameLine()
			ng_imgui_in_button("allclear:", "RESET", 50, 20, 
				function () 
					ng_getBckVars():set("general:timeoff","==:==") 
					ng_getBckVars():set("general:timeout","==:==") 
					ng_getBckVars():set("general:timein","==:==") 
					ng_getBckVars():set("general:timeon","==:==") 
				end)

			imgui.Separator()

-- Flight: XXX999 | Origin: XXXX/name | Destination: XXXX/name | Alternate: XXXX/name

		ng_imgui_out_text(color_white,"Flight:")
		imgui.SameLine()
		ng_imgui_in_tfield("Flight Number", 70, color_orange, 8, 
			ng_getBriefPrefs():get("general:callsign"), function (textout) ng_getBriefPrefs():set("general:callsign",textout) end)

		imgui.SameLine()
		ng_imgui_in_ltfield("*Origin ICAO:", 38, color_orange, 5, "Departure:", color_white,
			ng_getBriefPrefs():get("origin:icao"), function (textout) ng_getBriefPrefs():set("origin:icao",textout) end)
		imgui.SameLine()
		ng_imgui_in_ltfield("*Origin name:", 123, color_white, 100, "/", color_white,
			ng_getBriefPrefs():get("origin:name"), function (textout) ng_getBriefPrefs():set("origin:name",textout) end)
		
		imgui.SameLine()
		ng_imgui_in_ltfield("*Destination ICAO:", 38, color_orange, 5, "Arrival:", color_white, 
			ng_getBriefPrefs():get("destination:icao"), function (textout) ng_getBriefPrefs():set("destination:icao",textout) end)
		imgui.SameLine()
		ng_imgui_in_ltfield("*Destination name:", 123, color_white, 100, "/", color_white,
			ng_getBriefPrefs():get("destination:name"), function (textout) ng_getBriefPrefs():set("destination:name",textout) end)
		
		imgui.SameLine()
		ng_imgui_in_ltfield("*Alternate ICAO:", 38, color_orange, 5, "Alternate:", color_white, 
			ng_getBriefPrefs():get("alternate:icao"), function (textout) ng_getBriefPrefs():set("alternate:icao",textout) end)
		imgui.SameLine()
		ng_imgui_in_ltfield("*Alternate name:", 123, color_white, 100, "/", color_white,
			ng_getBriefPrefs():get("alternate:name"), function (textout) ng_getBriefPrefs():set("alternate:name",textout) end)

		imgui.Separator()

		-- CRUISE: [altitude]/FLxxx Times: OUT: 9999Z OFF: 9999Z ON: 9999Z IN: 9999Z Block time: 9999Z Air time: 9999Z
		-- Distances Air: 9999 nm Ground: 9999 nm  Average Wind: 999/999 W/C: +999 ISA: -009 FF/h: 99999 kgs/lbs 
		-- --------------------------------------------------------------------------------------
		ng_imgui_out_text(color_white,"Cruise altitude (level):")
		imgui.SameLine()
		ng_imgui_in_intfield("calt", 45, color_orange, 0, ng_getBriefPrefs():get("general:cruisealtitude"), 
			function (textout) ng_getBriefPrefs():set("general:cruisealtitude",textout) end)
		imgui.SameLine()
		ng_imgui_out_text(color_green, "(FL" .. ng_getBriefPrefs():get("general:cruisealtitude")/100 .. ")" )
		imgui.SameLine()
		ng_imgui_out_text(color_green, "Times: OUT:", color_white, os.date("!%H%M",ng_getBriefPrefs():get("times:schedout")).."Z")
		imgui.SameLine()
		ng_imgui_out_text(color_green, "OFF:", color_white, os.date("!%H%M",ng_getBriefPrefs():get("times:schedoff")).."Z")
		imgui.SameLine()
		ng_imgui_out_text(color_green, "IN:", color_white, os.date("!%H%M",ng_getBriefPrefs():get("times:schedin")).."Z")
		imgui.SameLine()
		ng_imgui_out_text(color_green, "ON:", color_white, os.date("!%H%M",ng_getBriefPrefs():get("times:schedon")).."Z")
		imgui.SameLine()
		ng_imgui_out_text(color_green, "Block Time:", color_white, os.date("!%H%M",ng_getBriefPrefs():get("times:schedblock")).." h")
		imgui.SameLine()
		ng_imgui_out_text(color_green, "Air Time:", color_white, os.date("!%H%M",ng_getBriefPrefs():get("times:estenroute")).." h")

		ng_imgui_out_text(color_white,"Distance:")
		imgui.SameLine()
		ng_imgui_out_text(color_green, ""..ng_getBriefPrefs():get("general:routedistance").." nm" )
		imgui.SameLine()
		ng_imgui_out_text(color_green, "Average Wind:", color_white, ng_getBriefPrefs():get("general:averagewndhdg").."/"..ng_getBriefPrefs():get("general:averagewndspd"))
		imgui.SameLine()
		ng_imgui_out_text(color_green, "Wind Component:", color_white, (ng_getBriefPrefs():get("general:averagewndcmp") >= 0 and "P" or "M")..ng_getBriefPrefs():get("general:averagewndcmp"))
		imgui.SameLine()
		ng_imgui_out_text(color_green, "ISA Dev:", color_white, ""..ng_getBriefPrefs():get("general:averageisa"))
		imgui.SameLine()
		ng_imgui_out_text(color_green, "Tropopause:", color_white, ""..ng_getBriefPrefs():get("general:tropopause"))
		imgui.SameLine()
		ng_imgui_out_text(color_green, "Cost Index:", color_white, ""..ng_getBriefPrefs():get("general:costindex"))
		imgui.SameLine()
		ng_imgui_out_text(color_green, "FF/h:", color_white, ""..ng_getBriefPrefs():get("fuel:avgfuelflow").." kgs/h")
		imgui.SameLine()
		ng_imgui_out_text(color_green, "PAX:", color_white, ""..ng_getBriefPrefs():get("weights:paxcount"))

		imgui.Separator()

		-- --------------------------------------------------------------------------------------
		-- Route: <route text>
		-- --------------------------------------------------------------------------------------
		ng_imgui_out_text(color_white,"Route:")
		imgui.SameLine()
		ng_imgui_in_tfield("origicao:", 38, 0xFF1b9af8, 5, 
			ng_getBriefPrefs():get("origin:icao"),function (textin) ng_getBriefPrefs():get("origin:icao",textin) end)
		imgui.SameLine()
		ng_imgui_in_tfield("origrwy:", 25, 0xFF1b9af8, 3,  
			ng_getBriefPrefs():get("origin:planrwy"),function (textin) ng_getBriefPrefs():get("origin:planrwy",textin) end)
		imgui.SameLine()
		ng_imgui_in_tfield("Route:", 715, 0xFF1b9af8, 255,ng_getBriefPrefs():get("general:route"), 
		function (textin) ng_getBriefPrefs():get("general:route",textin) end)		
		imgui.SameLine()
		ng_imgui_in_tfield("desticao:", 38, 0xFF1b9af8, 5,  
			ng_getBriefPrefs():get("destination:icao"),function (textin) ng_getBriefPrefs():get("destination:icao",textin) end)
		imgui.SameLine()
		ng_imgui_in_tfield("destrwy:", 25, 0xFF1b9af8, 3, 
			ng_getBriefPrefs():get("destination:planrwy"),function (textin) ng_getBriefPrefs():get("destination:planrwy",textin) end)

		imgui.Separator()
		imgui.Separator()

	end

-- -----------------------------------------------------------------------------------------
-- Draw the Planning section FUEL
	local function render_fuel_block()

-- --------------------------------------------
-- FUEL				<WUNIT>			HHMM
-- --------------------------------------------
-- TRIP FUEL		999999			9999
-- ALTERNATE		999999
-- FINAL RESERVE	999999
-- TAXI FUEL		999999			9999
-- MINIMUM BLOCK	999999			9999
-- EXTRA FUEL		999999			9999
-- --------------------------------------------
-- PLAN BLOCK		999999			9999
-- --------------------------------------------
-- --------------------------------------------

		imgui.BeginTable("fuel",3)
			imgui.TableNextColumn()
			ng_imgui_out_text(color_yellow,"FUEL")
			imgui.TableNextColumn()
			ng_imgui_out_text(color_yellow,"   "..ng_weightunit)
			imgui.TableNextColumn()
			ng_imgui_out_text(color_yellow,"HHMM")
			imgui.Separator()

			imgui.TableNextRow()
			imgui.TableNextColumn()
			ng_imgui_out_text(color_white,"TRIP FUEL")
			imgui.TableNextColumn()
			ng_imgui_out_text(color_green, string.format("%6.0f",ng_getBriefPrefs():get("fuel:enroute")*ng_kgslbs))
			imgui.TableNextColumn()
			ng_imgui_out_text(color_green, os.date("!%H%M",ng_getBriefPrefs():get("times:enroute")))

			imgui.TableNextRow()
			imgui.TableNextColumn()
			ng_imgui_out_text(color_white,"ALTERNATE")
			imgui.TableNextColumn()
			ng_imgui_out_text(color_green, string.format("%6.0f",ng_getBriefPrefs():get("fuel:alternate")*ng_kgslbs))
			imgui.TableNextColumn()
			ng_imgui_out_text(color_green, "")
			
			imgui.TableNextRow()
			imgui.TableNextColumn()
			ng_imgui_out_text(color_white,"FINAL RESERVE")
			imgui.TableNextColumn()
			ng_imgui_out_text(color_green, string.format("%6.0f",ng_getBriefPrefs():get("fuel:alternate")*ng_kgslbs))
			imgui.TableNextColumn()
			ng_imgui_out_text(color_green, os.date("!%H%M",ng_getBriefPrefs():get("times:reserve")))

			imgui.TableNextRow()
			imgui.TableNextColumn()
			ng_imgui_out_text(color_white,"TAXI FUEL")
			imgui.TableNextColumn()
			ng_imgui_out_text(color_green, string.format("%6.0f",ng_getBriefPrefs():get("fuel:taxi")*ng_kgslbs))
			imgui.TableNextColumn()
			ng_imgui_out_text(color_green, os.date("!%H%M",ng_getBriefPrefs():get("times:taxi_out")))
			
			imgui.TableNextRow()
			imgui.TableNextColumn()
			ng_imgui_out_text(color_white,"MINIMUM BLOCK")
			imgui.TableNextColumn()
			ng_imgui_out_text(color_green, string.format("%6.0f",ng_getBriefPrefs():get("fuel:mintakeoff")*ng_kgslbs))
			imgui.TableNextColumn()
			ng_imgui_out_text(color_green, os.date("!%H%M",ng_getBriefPrefs():get("times:endurance")))

			imgui.TableNextRow()
			imgui.TableNextColumn()
			ng_imgui_out_text(color_white,"EXTRA FUEL")
			imgui.TableNextColumn()
			ng_imgui_out_text(color_green, string.format("%6.0f",ng_getBriefPrefs():get("fuel:extra")*ng_kgslbs))
			imgui.TableNextColumn()
			ng_imgui_out_text(color_green, os.date("!%H%M",ng_getBriefPrefs():get("times:extrafuel")))

			imgui.Separator()

			imgui.TableNextRow()
			imgui.TableNextColumn()
			ng_imgui_out_text(color_white,"PLAN BLOCK")
			imgui.TableNextColumn()
			ng_imgui_out_text(color_green, string.format("%6.0f",ng_getBriefPrefs():get("fuel:plantakeoff")*ng_kgslbs))
			imgui.TableNextColumn()
			ng_imgui_out_text(color_green, os.date("!%H%M",ng_getBriefPrefs():get("times:schedblock")))
			
			imgui.Separator()
			imgui.Separator()

		imgui.EndTable()	
	
	end

-- -----------------------------------------------------------------------------------------
-- Draw the Planning section Weights
	local function render_weights_block()
	
-- --------------------------------------------
-- WEIGHTS			<WUNIT>			MAX/ACF
-- --------------------------------------------
-- EST ZFW			999999			999999 MAX
-- EST TOW			999999			999999 MAX
-- EST LDW			999999			999999 MAX
-- EST LAND FUEL	999999			
-- CARGO WEIGHT		999999			
-- PAYLOAD			999999			999999 MAX
-- FREIGHT ADDED	999999
-- PAX WGT/CNT		999 / 999
-- BAG WGT/CNT		999 / 999
-- DOW				999999			999999
-- *BLOCK FUEL		[999999]		999999 MAX
-- ACT ZFW			999999			999999 MAX
-- ACT WEIGHT		999999			999999 MAX
-- --------------------------------------------
-- MAC CG			99.90
-- --------------------------------------------

		imgui.BeginTable("weights",3)
			imgui.TableNextColumn()
			ng_imgui_out_text(color_yellow,"WEIGHTS")
			imgui.TableNextColumn()
			ng_imgui_out_text(color_yellow,"   "..ng_weightunit)
			imgui.TableNextColumn()
			ng_imgui_out_text(color_yellow," MAX/ACF")
			imgui.Separator()

			imgui.TableNextRow()
			imgui.TableNextColumn()
			ng_imgui_out_text(color_white,"EST ZFW")
			imgui.TableNextColumn()
			ng_imgui_out_text(color_green, string.format("%6.0f",ng_getBriefPrefs():get("weights:estzfw")*ng_kgslbs))
			imgui.TableNextColumn()
			ng_imgui_out_text(color_green, string.format("%6.0f MAX",ng_getBriefPrefs():get("weights:maxzfw")*ng_kgslbs))

			imgui.TableNextRow()
			imgui.TableNextColumn()
			ng_imgui_out_text(color_white,"EST TOW")
			imgui.TableNextColumn()
			ng_imgui_out_text(color_green, string.format("%6.0f",ng_getBriefPrefs():get("weights:esttow")*ng_kgslbs))
			imgui.TableNextColumn()
			ng_imgui_out_text(color_green, string.format("%6.0f MAX",ng_getBriefPrefs():get("weights:maxtow")*ng_kgslbs))

			imgui.TableNextRow()
			imgui.TableNextColumn()
			ng_imgui_out_text(color_white,"EST LDW")
			imgui.TableNextColumn()
			ng_imgui_out_text(color_green, string.format("%6.0f",ng_getBriefPrefs():get("weights:estldw")*ng_kgslbs))
			imgui.TableNextColumn()
			ng_imgui_out_text(color_green, string.format("%6.0f MAX",ng_getBriefPrefs():get("weights:maxldw")*ng_kgslbs))

			imgui.TableNextRow()
			imgui.TableNextColumn()
			ng_imgui_out_text(color_white,"EST LAND FUEL")
			imgui.TableNextColumn()
			ng_imgui_out_text(color_green, string.format("%6.0f",ng_getBriefPrefs():get("fuel:planlanding")*ng_kgslbs))

			imgui.TableNextRow()
			imgui.TableNextColumn()
			ng_imgui_out_text(color_white,"CARGO WEIGHT")
			imgui.TableNextColumn()
			ng_imgui_out_text(color_green, string.format("%6.0f",ng_getBriefPrefs():get("weights:cargo")*ng_kgslbs))
						
			imgui.TableNextRow()
			imgui.TableNextColumn()
			ng_imgui_out_text(color_white,"PAYLOAD")
			imgui.TableNextColumn()
			ng_imgui_out_text(color_green, string.format("%6.0f",ng_getBriefPrefs():get("weights:payload")*ng_kgslbs))
			imgui.TableNextColumn()
			local pcolor = (ng_getBriefPrefs():get("weights:payload")*ng_kgslbs > ng_get_MaxPayload() and color_red or color_green) 
			ng_imgui_out_text(pcolor, string.format("%6.0f MAX",ng_get_MaxPayload()))

			imgui.TableNextRow()
			imgui.TableNextColumn()
			ng_imgui_out_text(color_white,"FREIGHT ADDED")
			imgui.TableNextColumn()
			ng_imgui_out_text(color_green, string.format("%6.0f",ng_getBriefPrefs():get("weights:freightadded")*ng_kgslbs))
						
			imgui.TableNextRow()
			imgui.TableNextColumn()
			ng_imgui_out_text(color_white,"PAX WGT/CNT")
			imgui.TableNextColumn()
			ng_imgui_out_text(color_green, string.format("%6.0f / %3.0f", ng_getBriefPrefs():get("weights:paxweight")*ng_kgslbs, 
				ng_getBriefPrefs():get("weights:paxcount")))

			imgui.TableNextRow()
			imgui.TableNextColumn()
			ng_imgui_out_text(color_white,"BAG WGT/CNT")
			imgui.TableNextColumn()
			ng_imgui_out_text(color_green, string.format("%6.0f / %3.0f",ng_getBriefPrefs():get("weights:bagweight")*ng_kgslbs, 
				ng_getBriefPrefs():get("weights:bagcount")))

			imgui.TableNextRow()
			imgui.TableNextColumn()
			ng_imgui_out_text(color_white,"DOW")
			imgui.TableNextColumn()
			ng_imgui_out_text(color_green, string.format("%6.0f",ng_getBriefPrefs():get("weights:oew")*ng_kgslbs))
			imgui.TableNextColumn()
			ng_imgui_out_text(color_green, string.format("%6.0f",ng_get_DOW()))
			
			imgui.TableNextRow()
			imgui.TableNextColumn()
			ng_imgui_out_text(color_white,"*BLOCK FUEL")
			imgui.TableNextColumn()
			ng_imgui_in_intfield("*BLOCK FUEL:", 50, color_orange, 0, ng_getBriefPrefs():get("fuel:planramp")*ng_kgslbs, 
			function (textout) ng_getBriefPrefs():set("fuel:planramp",textout) end )
			imgui.TableNextColumn()
			ng_imgui_out_text(color_green, string.format("%6.0f MAX",ng_getBriefPrefs():get("fuel:maxtanks")*ng_kgslbs))

			imgui.TableNextRow()
			imgui.TableNextColumn()
			ng_imgui_out_text(color_white,"ACT ZFW")
			imgui.TableNextColumn()
			ng_imgui_out_text(color_green, string.format("%6.0f",ng_get_zfw()))
			imgui.TableNextColumn()
			ng_imgui_out_text(color_green, string.format("%6.0f MAX",ng_getBriefPrefs():get("weights:maxzfw")*ng_kgslbs))

			imgui.TableNextRow()
			imgui.TableNextColumn()
			ng_imgui_out_text(color_white,"ACT WEIGHT")
			imgui.TableNextColumn()
			ng_imgui_out_text(color_green, string.format("%6.0f",ng_get_gross_weight()))
			imgui.TableNextColumn()
			ng_imgui_out_text(color_green, string.format("%6.0f MAX",ng_getBriefPrefs():get("weights:maxtow")*ng_kgslbs))
			
			imgui.Separator()

			imgui.TableNextRow()
			imgui.TableNextColumn()
			ng_imgui_out_text(color_white,"MAC CG")
			imgui.TableNextColumn()
			ng_imgui_out_text(color_green, string.format("%6.2f",21.2)) --ng_getBriefPrefs():get("weights:paxweight")))
			
			imgui.Separator()
			imgui.Separator()
			
		imgui.EndTable()
	
	end

-- -----------------------------------------------------------------------------------------
-- Draw the Planning section Times
	local function render_times_block()
	
-- --------------------------------------------
-- TIMES			EST HHMM		SCED HHMM
-- --------------------------------------------
-- TRIP TIME		9999 h			9999 h
-- OUT TIME			9999Z			9999Z
-- OFF TIME			9999Z			9999Z
-- ON TIME			9999Z			9999Z
-- IN TIME			9999Z			9999Z
-- BLOCK TIME		9999 h			9999 h
-- TAXI OUT TIME	9999 h
-- TAXI IN TIME		9999 h
-- RESERVE TIME		9999 h
-- ENDURANCE		9999 h
-- CONTINGENCY		9999 h
-- EXTRA TIME		9999 h
-- --------------------------------------------
-- --------------------------------------------

		imgui.BeginTable("times",3)
			imgui.TableNextColumn()
			ng_imgui_out_text(color_yellow,"TIMES")
			imgui.TableNextColumn()
			ng_imgui_out_text(color_yellow,"EST HHMM")
			imgui.TableNextColumn()
			ng_imgui_out_text(color_yellow,"SCED HHMM")
			imgui.Separator()
			
			imgui.TableNextRow()
			imgui.TableNextColumn()
			ng_imgui_out_text(color_white,"TRIP TIME")
			imgui.TableNextColumn()
			ng_imgui_out_text(color_green, os.date("!%H%M",ng_getBriefPrefs():get("times:estenroute")).." h")
			imgui.TableNextColumn()
			ng_imgui_out_text(color_green, os.date("!%H%M",ng_getBriefPrefs():get("times:schedenroute")).." h")

			imgui.TableNextRow()
			imgui.TableNextColumn()
			ng_imgui_out_text(color_white,"OUT TIME")
			imgui.TableNextColumn()
			ng_imgui_out_text(color_green, os.date("!%H%M",ng_getBriefPrefs():get("times:estout")).."Z")
			imgui.TableNextColumn()
			ng_imgui_out_text(color_green, os.date("!%H%M",ng_getBriefPrefs():get("times:schedout")).."Z")

			imgui.TableNextRow()
			imgui.TableNextColumn()
			ng_imgui_out_text(color_white,"OFF TIME")
			imgui.TableNextColumn()
			ng_imgui_out_text(color_green, os.date("!%H%M",ng_getBriefPrefs():get("times:estoff")).."Z")
			imgui.TableNextColumn()
			ng_imgui_out_text(color_green, os.date("!%H%M",ng_getBriefPrefs():get("times:schedoff")).."Z")

			imgui.TableNextRow()
			imgui.TableNextColumn()
			ng_imgui_out_text(color_white,"ON TIME")
			imgui.TableNextColumn()
			ng_imgui_out_text(color_green, os.date("!%H%M",ng_getBriefPrefs():get("times:eston")).."Z")
			imgui.TableNextColumn()
			ng_imgui_out_text(color_green, os.date("!%H%M",ng_getBriefPrefs():get("times:schedon")).."Z")

			imgui.TableNextRow()
			imgui.TableNextColumn()
			ng_imgui_out_text(color_white,"IN TIME")
			imgui.TableNextColumn()
			ng_imgui_out_text(color_green, os.date("!%H%M",ng_getBriefPrefs():get("times:estin")).."Z")
			imgui.TableNextColumn()
			ng_imgui_out_text(color_green, os.date("!%H%M",ng_getBriefPrefs():get("times:schedin")).."Z")

			imgui.TableNextRow()
			imgui.TableNextColumn()
			ng_imgui_out_text(color_white,"BLOCK TIME")
			imgui.TableNextColumn()
			ng_imgui_out_text(color_green, os.date("!%H%M",ng_getBriefPrefs():get("times:estblock")).." h")
			imgui.TableNextColumn()
			ng_imgui_out_text(color_green, os.date("!%H%M",ng_getBriefPrefs():get("times:schedblock")).." h")

			imgui.TableNextRow()
			imgui.TableNextColumn()
			ng_imgui_out_text(color_white,"TAXI OUT TIME")
			imgui.TableNextColumn()
			ng_imgui_out_text(color_green, os.date("!%H%M",ng_getBriefPrefs():get("times:taxiout")).." h")

			imgui.TableNextRow()
			imgui.TableNextColumn()
			ng_imgui_out_text(color_white,"TAXI IN TIME")
			imgui.TableNextColumn()
			ng_imgui_out_text(color_green, os.date("!%H%M",ng_getBriefPrefs():get("times:taxiin")).." h")

			imgui.TableNextRow()
			imgui.TableNextColumn()
			ng_imgui_out_text(color_white,"RESERVE TIME")
			imgui.TableNextColumn()
			ng_imgui_out_text(color_green, os.date("!%H%M",ng_getBriefPrefs():get("times:reserve")).." h")

			imgui.TableNextRow()
			imgui.TableNextColumn()
			ng_imgui_out_text(color_white,"ENDURANCE")
			imgui.TableNextColumn()
			ng_imgui_out_text(color_green, os.date("!%H%M",ng_getBriefPrefs():get("times:endurance")).." h")

			imgui.TableNextRow()
			imgui.TableNextColumn()
			ng_imgui_out_text(color_white,"CONTINGENCY")
			imgui.TableNextColumn()
			ng_imgui_out_text(color_green, os.date("!%H%M",ng_getBriefPrefs():get("times:contfuel")).." h")

			imgui.TableNextRow()
			imgui.TableNextColumn()
			ng_imgui_out_text(color_white,"EXTRA TIME")
			imgui.TableNextColumn()
			ng_imgui_out_text(color_green, os.date("!%H%M",ng_getBriefPrefs():get("times:extrafuel")).." h")

		imgui.EndTable()
				
		imgui.Separator()
		imgui.Separator()
	end
	
-- -----------------------------------------------------------------------------------------
-- Draw Flight tab preflight planning
	local function render_preflight_planning()
		
		-- block with fuel information
		render_fuel_block()

		-- render block with weights
		render_weights_block()
		
		-- render times block
		render_times_block()
	end

-- -----------------------------------------------------------------------------------------
-- Draw the Origin Airport information block
	local function render_origin_arpt_info()

-- --------------------------------------------
-- ORIGIN					ICAO/NAME OF ARPT
-- --------------------------------------------
-- AIRPORT ELEVATION		9999 ft
-- TRANSITION ALT/LVL		99999 / FL99
-- METAR					METAR text....
-- [LD]
-- PARKING POSITION			[xxxx]
-- STAND TYPE				[type of stand v]
-- PUSH DIRECTION			[direction push v]
-- TAKEOFF RWY				[runway id v]
-- LENGTH / TORA			99999 ft / 99999 ft
-- RWY ELEVATION			99999 ft
-- MAGNETIC COURSE			999
-- HEAD / CROSS WIND		999 kts / 9999 kts
-- WIND | TEMP				999/999 | 999 C
-- BARO Q/A					Q9999 / A99.99
-- SURFACE CONDITION		<condition>
-- --------------------------------------------

		imgui.BeginTable("origininfo",2)
		
			local ddwidth=146
			imgui.TableNextColumn()
			ng_imgui_out_text(color_yellow,"ORIGIN")
			imgui.Separator()
			imgui.TableNextColumn()
			ng_imgui_out_text(color_yellow, ng_getBriefPrefs():get("origin:icao").." / "..ng_getBriefPrefs():get("origin:name"))		
			imgui.Separator()
			
			imgui.TableNextRow()
			imgui.TableNextColumn()
			ng_imgui_out_text(color_white,"AIRPORT ELEVATION")
			imgui.TableNextColumn()
			ng_imgui_out_text(color_green, ng_getBriefPrefs():get("origin:elevation").." ft")

			imgui.TableNextRow()
			imgui.TableNextColumn()
			ng_imgui_out_text(color_white,"TRANSITION ALT/LVL")
			imgui.TableNextColumn()
			ng_imgui_out_text(color_green, ng_getBriefPrefs():get("origin:transalt").." / FL"..ng_getBriefPrefs():get("origin:translvl")/100)

			imgui.TableNextRow()
			imgui.TableNextColumn()
			ng_imgui_out_text(color_white,"METAR")  
			ng_imgui_in_button("ldoriginmetar", "LD", 20, 20, 
				function () ng_getBriefPrefs():set("origin:metar",ng_get_xp_metar(ng_getBriefPrefs():get("origin:icao"))) end)
			imgui.TableNextColumn()
			ng_imgui_out_text(color_green, ng_getBriefPrefs():get("origin:metar"))

			imgui.TableNextRow()
			imgui.TableNextColumn()
			ng_imgui_out_text(color_white,"PARKING POSITION")
			imgui.TableNextColumn()
			ng_imgui_in_tfield("OPARKPOS", ddwidth, color_white, 10, ng_getBriefPrefs():get("origin:stand"), 
				function (textout) ng_getBriefPrefs():set("origin:stand",textout) end )

			imgui.TableNextRow()
			imgui.TableNextColumn()
			ng_imgui_out_text(color_white,"STAND TYPE")
			imgui.TableNextColumn()
			local splitTitle = ng_split(ng_getBriefPrefs():find("origin:standtype"):getTitle(),"|")
			ng_imgui_in_combolist("oparktype", splitTitle, ng_getBriefPrefs():get("origin:standtype"), 
				function (textin) ng_getBriefPrefs():set("origin:standtype",textin) end, ddwidth)

			imgui.TableNextRow()
			imgui.TableNextColumn()
			ng_imgui_out_text(color_white,"PUSH DIRECTION")
			imgui.TableNextColumn()
			local splitTitle = ng_split(ng_getBriefPrefs():find("origin:pushtype"):getTitle(),"|")
			ng_imgui_in_combolist("opushtype", splitTitle, ng_getBriefPrefs():get("origin:pushtype"), 
				function (textin) ng_getBriefPrefs():set("origin:pushtype",textin) end, ddwidth)

			imgui.TableNextRow()
			imgui.TableNextColumn()
			ng_imgui_out_text(color_white,"TAKEOFF RWY")
			imgui.TableNextColumn()
			if #ng_briefing_to_rwys > 0 then
				local torwys = {""} for _, torwy in pairs(ng_briefing_to_rwys) do table.insert(torwys,torwy.identifier) end
				ng_imgui_in_combolist("orwys", torwys, ng_getBriefPrefs():get("origin:selectedrwy"), 
					function 
						(textin) ng_getBriefPrefs():set("origin:selectedrwy",textin) 
						ng_getBriefPrefs():set("origin:planrwy",torwys[textin+1])
						ng_getBriefPrefs():set("takeoff:selectedflaps",ng_briefing_to_rwys[ng_getBriefPrefs():get("origin:selectedrwy")].flap_setting)
						local splitTitle = ng_split(ng_getAcfPrefs():find("engines:tothrust"):getTitle(),"|") 
						ng_getBriefPrefs():set("takeoff:selectedthrust",ng_indexOf(splitTitle,ng_briefing_to_rwys[ng_getBriefPrefs():get("origin:selectedrwy")].thrust_setting)-1) 
						local splitTitle = ng_split(ng_getAcfPrefs():find("air:takeoffbleeds"):getTitle(),"|")
						ng_getBriefPrefs():set("takeoff:selectedbleed",ng_indexOf(splitTitle,ng_briefing_to_rwys[ng_getBriefPrefs():get("origin:selectedrwy")].bleed_setting)-1) 
						local splitTitle = ng_split(ng_getAcfPrefs():find("aice:takeoffaice"):getTitle(),"|")
						ng_getBriefPrefs():set("takeoff:selectedaice",ng_indexOf(splitTitle,ng_briefing_to_rwys[ng_getBriefPrefs():get("origin:selectedrwy")].anti_ice_setting)-1)
						ng_getBriefPrefs():set("takeoff:rwyflextemp",ng_briefing_to_rwys[ng_getBriefPrefs():get("origin:selectedrwy")].flex_temperature)
						ng_getBriefPrefs():set("takeoff:rwyv1",ng_briefing_to_rwys[ng_getBriefPrefs():get("origin:selectedrwy")].speeds_v1) 						
						ng_getBriefPrefs():set("takeoff:rwyvr",ng_briefing_to_rwys[ng_getBriefPrefs():get("origin:selectedrwy")].speeds_vr) 						
						ng_getBriefPrefs():set("takeoff:rwyv2",ng_briefing_to_rwys[ng_getBriefPrefs():get("origin:selectedrwy")].speeds_v2) 						
						ng_getBriefPrefs():set("takeoff:inithdg",ng_briefing_to_rwys[ng_getBriefPrefs():get("origin:selectedrwy")].magnetic_course)				
					end, ddwidth)
			else
				ng_imgui_in_tfield("orwy", ddwidth, color_orange, 10, ng_getBriefPrefs():get("origin:planrwy"), 
					function (textout) ng_getBriefPrefs():set("origin:planrwy",textout) end )				
			end
			
-- only show if TLR takeoff section is available
			if #ng_briefing_to_rwys > 0 then
			
				imgui.TableNextRow()
				imgui.TableNextColumn()
				ng_imgui_out_text(color_white,"LENGTH / TORA")
				imgui.TableNextColumn()
				ng_getBriefPrefs():set("takeoff:rwylength",ng_briefing_to_rwys[ng_getBriefPrefs():get("origin:selectedrwy")].length)
				ng_getBriefPrefs():set("takeoff:rwytora",ng_briefing_to_rwys[ng_getBriefPrefs():get("origin:selectedrwy")].length_tora)
				ng_imgui_out_text(color_green, ng_getBriefPrefs():get("takeoff:rwylength").." ft / "..ng_getBriefPrefs():get("takeoff:rwytora").." ft")

				imgui.TableNextRow()
				imgui.TableNextColumn()
				ng_imgui_out_text(color_white,"RWY ELEVATION")
				imgui.TableNextColumn()
				ng_getBriefPrefs():set("takeoff:rwyelevation",ng_briefing_to_rwys[ng_getBriefPrefs():get("origin:selectedrwy")].elevation)
				ng_imgui_out_text(color_green, ng_getBriefPrefs():get("takeoff:rwyelevation").." ft")

				imgui.TableNextRow()
				imgui.TableNextColumn()
				ng_imgui_out_text(color_white,"MAGNETIC COURSE")
				imgui.TableNextColumn()
				ng_getBriefPrefs():set("takeoff:rwycourse",ng_briefing_to_rwys[ng_getBriefPrefs():get("origin:selectedrwy")].magnetic_course)
				ng_imgui_out_text(color_green, ng_getBriefPrefs():get("takeoff:rwycourse"))

				imgui.TableNextRow()
				imgui.TableNextColumn()
				ng_imgui_out_text(color_white,"HEAD / CROSS WIND")
				imgui.TableNextColumn()
				ng_getBriefPrefs():set("takeoff:rwyheadwind",ng_briefing_to_rwys[ng_getBriefPrefs():get("origin:selectedrwy")].headwind_component)
				ng_getBriefPrefs():set("takeoff:rwycrosswind",ng_briefing_to_rwys[ng_getBriefPrefs():get("origin:selectedrwy")].crosswind_component)
				ng_imgui_out_text(color_green, ng_getBriefPrefs():get("takeoff:rwyheadwind").." kts / "..ng_getBriefPrefs():get("takeoff:rwycrosswind").." kts")

				imgui.TableNextRow()
				imgui.TableNextColumn()
				ng_imgui_out_text(color_white,"WIND | TEMP")
				imgui.TableNextColumn()
				ng_imgui_out_text(color_green, string.format("%03.0f",ng_getBriefPrefs():get("takeoff:windhdg")).."/"..string.format("%03.0f",ng_getBriefPrefs():get("takeoff:windspd")).." | "..ng_getBriefPrefs():get("takeoff:temperature").." C")

				imgui.TableNextRow()
				imgui.TableNextColumn()
				ng_imgui_out_text(color_white,"SURFACE CONDITION")
				imgui.TableNextColumn()
				ng_imgui_out_text(color_green, string.upper(ng_getBriefPrefs():get("takeoff:surfacecond")))

			end

		imgui.EndTable()
		imgui.Separator()
	
	end

-- -----------------------------------------------------------------------------------------
-- Draw the Departure block
	local function render_departure_info()

-- --------------------------------------------
-- DEPARTURE				[depearturename]
-- --------------------------------------------
-- DEPARTURE TYPE			[type v]
-- TRANSITION				[transitionname]
-- SQUAWK					[9999]
-- TAKEOFF FLAPS			[flap_setting v]
-- TAKEOFF THRUST			[thrust_setting v]
-- TAKEOFF BLEEDS			[bleed_setting v]
-- TAKEOFF ANTI-ICE			[aice_setting v]
-- TAKEOFF PITCH TRIM		[99.9]
-- TAKEOFF FLEX TEMP		[99]
-- TAKEOFF V1,VR,V2			[999] [999] [999]
-- INITIAL HDG/ALT			[999] / [99999]
-- *BARO Q/A				[9999] [>][<][99.99]		
-- --------------------------------------------

		imgui.BeginTable("departureinfo",2)
		
			local ddwidth=146
			imgui.TableNextColumn()
			ng_imgui_out_text(color_yellow,"DEPARTURE")
			imgui.TableNextColumn()
			ng_imgui_in_tfield("Odeparture", ddwidth, color_white, 10, ng_getBriefPrefs():get("origin:sid"), 
				function (textout) ng_getBriefPrefs():set("origin:sid",textout) end )

			imgui.TableNextRow()
			imgui.TableNextColumn()
			ng_imgui_out_text(color_white,"DEPARTURE TYPE")
			imgui.TableNextColumn()
			local splitTitle = ng_split(ng_getBriefPrefs():find("origin:deptype"):getTitle(),"|")
			ng_imgui_in_combolist("odeptype", splitTitle, ng_getBriefPrefs():get("origin:deptype"), 
				function (textin) ng_getBriefPrefs():set("origin:deptype",textin) end, ddwidth)

			imgui.TableNextRow()
			imgui.TableNextColumn()
			ng_imgui_out_text(color_white,"TRANSITION")
			imgui.TableNextColumn()
			ng_imgui_in_tfield("Otransition", ddwidth, color_white, 10, ng_getBriefPrefs():get("origin:sidtransition"), 
				function (textout) ng_getBriefPrefs():set("origin:sidtransition",textout) end )

			imgui.TableNextRow()
			imgui.TableNextColumn()
			ng_imgui_out_text(color_white,"SQUAWK")
			imgui.TableNextColumn()
			ng_imgui_in_tfield("Osquawk", ddwidth, color_white, 5, string.format("%04.0f",ng_getBriefPrefs():get("origin:squawk")), 
				function (textout) ng_getBriefPrefs():set("origin:squawk",textout) end )

			imgui.TableNextRow()
			imgui.TableNextColumn()
			ng_imgui_out_text(color_white,"TAKEOFF FLAPS")
			imgui.TableNextColumn()
			local splitTitle = ng_split(ng_getAcfPrefs():get("controls:toflapslbl"),"|")
			ng_imgui_in_combolist("oflaps", splitTitle, ng_getBriefPrefs():get("takeoff:selectedflaps"), 
				function (textin) ng_getBriefPrefs():set("takeoff:selectedflaps",textin) end, ddwidth)

			imgui.TableNextRow()
			imgui.TableNextColumn()
			ng_imgui_out_text(color_white,"TAKEOFF THRUST")
			imgui.TableNextColumn()
			local splitTitle = ng_split(ng_getAcfPrefs():find("engines:tothrust"):getTitle(),"|")
			ng_imgui_in_combolist("othrust", splitTitle, ng_getBriefPrefs():get("takeoff:selectedthrust"), 
				function (textin) ng_getBriefPrefs():set("takeoff:selectedthrust",textin) end, ddwidth)

			imgui.TableNextRow()
			imgui.TableNextColumn()
			ng_imgui_out_text(color_white,"TAKEOFF BLEEDS")
			imgui.TableNextColumn()
			local splitTitle = ng_split(ng_getAcfPrefs():find("air:takeoffbleeds"):getTitle(),"|")
			ng_imgui_in_combolist("obleeds", splitTitle, ng_getBriefPrefs():get("takeoff:selectedbleed"), 
				function (textin) ng_getBriefPrefs():set("takeoff:selectedbleed",textin) end, ddwidth)
				
			imgui.TableNextRow()
			imgui.TableNextColumn()
			ng_imgui_out_text(color_white,"TAKEOFF ANTI-ICE")
			imgui.TableNextColumn()
			local splitTitle = ng_split(ng_getAcfPrefs():get("aice:takeoffaice"),"|")
			ng_imgui_in_combolist("oaice", splitTitle, ng_getBriefPrefs():get("takeoff:selectedaice"), 
				function (textin) ng_getBriefPrefs():set("takeoff:selectedaice",textin) end, ddwidth)

			imgui.TableNextRow()
			imgui.TableNextColumn()
			ng_imgui_out_text(color_white,"TAKEOFF PITCH TRIM")
			imgui.TableNextColumn()
			ng_imgui_in_floatfield("pitchtrim", ddwidth, color_white, 0, "%5.1f", ng_getBriefPrefs():get("takeoff:pitchtrim"), 
				function (textout) ng_getBriefPrefs():set("takeoff:pitchtrim",textout) end )

			imgui.TableNextRow()
			imgui.TableNextColumn()
			ng_imgui_out_text(color_white,"TAKEOFF FLEX TEMP")
			imgui.TableNextColumn()
			ng_imgui_in_intfield("otemp", ddwidth, color_white, 0, ng_getBriefPrefs():get("takeoff:rwyflextemp"), 
				function (textout) ng_getBriefPrefs():set("takeoff:rwyflextemp",textout) end )
					
			imgui.TableNextRow()
			imgui.TableNextColumn()
			ng_imgui_out_text(color_white,"TAKEOFF V1,VR,V2")
			imgui.TableNextColumn()
			ng_imgui_in_intfield("ov1", 30, color_white, 0, ng_getBriefPrefs():get("takeoff:rwyv1"), 
				function (textout) ng_getBriefPrefs():set("takeoff:rwyv1",textout) end ) imgui.SameLine()
			ng_imgui_in_intfield("ovr", 30, color_white, 0, ng_getBriefPrefs():get("takeoff:rwyvr"), 
				function (textout) ng_getBriefPrefs():set("takeoff:rwyvr",textout) end ) imgui.SameLine()
			ng_imgui_in_intfield("ov2", 30, color_white, 0, ng_getBriefPrefs():get("takeoff:rwyv2"), 
				function (textout) ng_getBriefPrefs():set("takeoff:rwyv2",textout) end ) imgui.SameLine()

			imgui.TableNextRow()
			imgui.TableNextColumn()
			ng_imgui_out_text(color_white,"INITIAL HDG/ALT")
			imgui.TableNextColumn()
			ng_imgui_in_intfield("ohdg", 30, color_white, 0, ng_getBriefPrefs():get("takeoff:inithdg"), 
				function (textout) ng_getBriefPrefs():set("takeoff:inithdg",textout) end ) imgui.SameLine()
			ng_imgui_in_intfield("oinitalt", 70, color_white, 0, ng_getBriefPrefs():get("takeoff:initalt"), 
				function (textout) ng_getBriefPrefs():set("takeoff:initalt",textout) end ) imgui.SameLine()					

			imgui.TableNextRow()
			imgui.TableNextColumn()
			ng_imgui_out_text(color_white,"*BARO Q/A")
			imgui.TableNextColumn()
			ng_imgui_in_floatfield("baroq", 40, color_white, 0, "%04.0f",ng_getBriefPrefs():get("takeoff:qaltimeter"), 
				function (textout) ng_getBriefPrefs():set("takeoff:qaltimeter",textout) end ) imgui.SameLine()
			ng_imgui_in_button("convbaro", "<", 15, 20, 
				function () ng_getBriefPrefs():set("takeoff:qaltimeter",(ng_getBriefPrefs():get("takeoff:altimeter") * 33.8639)) end ) imgui.SameLine()
			ng_imgui_in_button("convbaro", ">", 15, 20, 
				function () ng_getBriefPrefs():set("takeoff:altimeter",(ng_getBriefPrefs():get("takeoff:qaltimeter") / 33.8639)) end ) imgui.SameLine()
			ng_imgui_in_floatfield("baroa", 40, color_white, 0, "%05.2f", ng_getBriefPrefs():get("takeoff:altimeter"), 
				function (textout) ng_getBriefPrefs():set("takeoff:altimeter",textout) end ) 
			
		imgui.EndTable()
		imgui.Separator()
	end
	
-- -----------------------------------------------------------------------------------------
-- Draw the Flight tab origin 
	local function render_preflight_origin()
	
		render_origin_arpt_info()
		render_departure_info()

	end

-- -----------------------------------------------------------------------------------------
-- Draw the Origin Airport information block
	local function render_destination_arpt_info()

-- --------------------------------------------
-- DESTINATION				ICAO/NAME OF ARPT
-- --------------------------------------------
-- AIRPORT ELEVATION		9999 ft
-- TRANSITION ALT/LVL		99999 / FL99
-- METAR					METAR text....
-- [LD]
-- LANDING RWY				[runway id v]
-- LENGTH / LDA			99999 ft / 99999 ft
-- RWY ELEVATION			99999 ft
-- MAGNETIC COURSE			999
-- HEAD / CROSS WIND		999 kts / 9999 kts
-- WIND | TEMP				999/999 | 999 C
-- BARO Q/A					Q9999 / A99.99
-- SURFACE CONDITION		<condition>
-- --------------------------------------------

		imgui.BeginTable("destinationinfo",2)
		
			local ddwidth=146
			imgui.TableNextColumn()
			ng_imgui_out_text(color_yellow,"DESTINATION")
			imgui.Separator()
			imgui.TableNextColumn()
			ng_imgui_out_text(color_yellow, ng_getBriefPrefs():get("destination:icao").." / "..ng_getBriefPrefs():get("destination:name"))		
			imgui.Separator()
			
			imgui.TableNextRow()
			imgui.TableNextColumn()
			ng_imgui_out_text(color_white,"AIRPORT ELEVATION")
			imgui.TableNextColumn()
			ng_imgui_out_text(color_green, ng_getBriefPrefs():get("destination:elevation").." ft")

			imgui.TableNextRow()
			imgui.TableNextColumn()
			ng_imgui_out_text(color_white,"TRANSITION ALT/LVL")
			imgui.TableNextColumn()
			ng_imgui_out_text(color_green, ng_getBriefPrefs():get("destination:transalt").." / FL"..ng_getBriefPrefs():get("destination:translvl")/100)

			imgui.TableNextRow()
			imgui.TableNextColumn()
			ng_imgui_out_text(color_white,"METAR")
			ng_imgui_in_button("lddestmetar", "LD", 20, 20, 
				function () ng_getBriefPrefs():set("destination:metar",ng_get_xp_metar(ng_getBriefPrefs():get("destination:icao"))) end)
			
			imgui.TableNextColumn()
			ng_imgui_out_text(color_green, ng_getBriefPrefs():get("destination:metar"))

			imgui.TableNextRow()
			imgui.TableNextColumn()
			ng_imgui_out_text(color_white,"LANDING RWY")
			imgui.TableNextColumn()
			if #ng_briefing_ld_rwys > 0 then -- takeoff runways exist in sim
				local ldrwys = {""} for _, ldrwy in pairs(ng_briefing_ld_rwys) do table.insert(ldrwys,ldrwy.identifier) end
				ng_imgui_in_combolist("drwys", ldrwys, ng_getBriefPrefs():get("destination:selectedrwy"), 
					function 
						(textin) ng_getBriefPrefs():set("origin:selectedrwy",textin) 
						ng_getBriefPrefs():set("origin:planrwy",torwys[textin+1])
						ng_getBriefPrefs():set("takeoff:selectedflaps",ng_briefing_to_rwys[ng_getBriefPrefs():get("origin:selectedrwy")].flap_setting)
						local splitTitle = ng_split(ng_getAcfPrefs():find("engines:tothrust"):getTitle(),"|") 
						ng_getBriefPrefs():set("takeoff:selectedthrust",ng_indexOf(splitTitle,ng_briefing_to_rwys[ng_getBriefPrefs():get("origin:selectedrwy")].thrust_setting)-1) 
						local splitTitle = ng_split(ng_getAcfPrefs():find("air:takeoffbleeds"):getTitle(),"|")
						ng_getBriefPrefs():set("takeoff:selectedbleed",ng_indexOf(splitTitle,ng_briefing_to_rwys[ng_getBriefPrefs():get("origin:selectedrwy")].bleed_setting)-1) 
						local splitTitle = ng_split(ng_getAcfPrefs():find("aice:takeoffaice"):getTitle(),"|")
						ng_getBriefPrefs():set("takeoff:selectedaice",ng_indexOf(splitTitle,ng_briefing_to_rwys[ng_getBriefPrefs():get("origin:selectedrwy")].anti_ice_setting)-1)
						ng_getBriefPrefs():set("takeoff:rwyflextemp",ng_briefing_to_rwys[ng_getBriefPrefs():get("origin:selectedrwy")].flex_temperature)
						ng_getBriefPrefs():set("takeoff:rwyv1",ng_briefing_to_rwys[ng_getBriefPrefs():get("origin:selectedrwy")].speeds_v1) 						
						ng_getBriefPrefs():set("takeoff:rwyvr",ng_briefing_to_rwys[ng_getBriefPrefs():get("origin:selectedrwy")].speeds_vr) 						
						ng_getBriefPrefs():set("takeoff:rwyv2",ng_briefing_to_rwys[ng_getBriefPrefs():get("origin:selectedrwy")].speeds_v2) 						
						ng_getBriefPrefs():set("takeoff:inithdg",ng_briefing_to_rwys[ng_getBriefPrefs():get("origin:selectedrwy")].magnetic_course)
					end, ddwidth)
			else
				ng_imgui_in_tfield("drwy", ddwidth, color_orange, 10, ng_getBriefPrefs():get("destination:planrwy"), 
					function (textout) ng_getBriefPrefs():set("destination:planrwy",textout) end )				
			end
			
			if #ng_briefing_ld_rwys > 0 then
			
				imgui.TableNextRow()
				imgui.TableNextColumn()
				ng_imgui_out_text(color_white,"LENGTH / LDA")
				imgui.TableNextColumn()
				ng_getBriefPrefs():set("landing:rwylength",ng_briefing_ld_rwys[ng_getBriefPrefs():get("destination:selectedrwy")].length)
				ng_getBriefPrefs():set("landing:rwylda",ng_briefing_ld_rwys[ng_getBriefPrefs():get("destination:selectedrwy")].length_lda)
				ng_imgui_out_text(color_green, ng_getBriefPrefs():get("landing:rwylength").." ft / "..ng_getBriefPrefs():get("landing:rwylda").." ft")

				imgui.TableNextRow()
				imgui.TableNextColumn()
				ng_imgui_out_text(color_white,"RWY ELEVATION")
				imgui.TableNextColumn()
				ng_getBriefPrefs():set("landing:rwyelevation",ng_briefing_ld_rwys[ng_getBriefPrefs():get("destination:selectedrwy")].elevation)
				ng_imgui_out_text(color_green, ng_getBriefPrefs():get("landing:rwyelevation").." ft")

				imgui.TableNextRow()
				imgui.TableNextColumn()
				ng_imgui_out_text(color_white,"MAGNETIC COURSE")
				imgui.TableNextColumn()
				ng_getBriefPrefs():set("landing:rwycourse",ng_briefing_ld_rwys[ng_getBriefPrefs():get("destination:selectedrwy")].magnetic_course)
				ng_imgui_out_text(color_green, ng_getBriefPrefs():get("landing:rwycourse"))

				imgui.TableNextRow()
				imgui.TableNextColumn()
				ng_imgui_out_text(color_white,"HEAD / CROSS WIND")
				imgui.TableNextColumn()
				ng_getBriefPrefs():set("landing:rwyheadwind",ng_briefing_ld_rwys[ng_getBriefPrefs():get("destination:selectedrwy")].headwind_component)
				ng_getBriefPrefs():set("landing:rwycrosswind",ng_briefing_ld_rwys[ng_getBriefPrefs():get("destination:selectedrwy")].crosswind_component)
				ng_imgui_out_text(color_green, ng_getBriefPrefs():get("landing:rwyheadwind").." kts / "..ng_getBriefPrefs():get("landing:rwycrosswind").." kts")

				imgui.TableNextRow()
				imgui.TableNextColumn()
				ng_imgui_out_text(color_white,"WIND | TEMP")
				imgui.TableNextColumn()
				ng_imgui_out_text(color_green, string.format("%03.0f",ng_getBriefPrefs():get("landing:windhdg")).."/"..string.format("%03.0f",ng_getBriefPrefs():get("landing:windspd")).." | "..ng_getBriefPrefs():get("landing:temperature").." C")

				imgui.TableNextRow()
				imgui.TableNextColumn()
				ng_imgui_out_text(color_white,"SURFACE CONDITION")
				imgui.TableNextColumn()
				ng_imgui_out_text(color_green, string.upper(ng_getBriefPrefs():get("landing:surfacecond")))

			end

			imgui.TableNextRow()
			imgui.TableNextColumn()
			ng_imgui_out_text(color_white,"PARKING POSITION")
			imgui.TableNextColumn()
			ng_imgui_in_tfield("DPARKPOS", ddwidth, color_white, 10, ng_getBriefPrefs():get("destination:stand"), 
				function (textout) ng_getBriefPrefs():set("destination:stand",textout) end )

			imgui.TableNextRow()
			imgui.TableNextColumn()
			ng_imgui_out_text(color_white,"STAND TYPE")
			imgui.TableNextColumn()
			local splitTitle = ng_split(ng_getBriefPrefs():find("destination:standtype"):getTitle(),"|")
			ng_imgui_in_combolist("dparktype", splitTitle, ng_getBriefPrefs():get("destination:standtype"),
				function (textin) ng_getBriefPrefs():set("destination:standtype",textin) end, ddwidth)

		imgui.EndTable()
		imgui.Separator()
	
	end

-- -----------------------------------------------------------------------------------------
-- draw the Flight tab destination		
	local function render_arrival_info() 

-- ----------------------------------------------
-- ARRIVAL					[depearturename]
-- ARRIVAL TYPE				[type v]
-- TRANSITION				[transitionname]
-- APPR TYPE				[type v]
-- ILS FREQ					[999.999]
-- CRS1/CRS2				[999] [999]
-- DH / DA					[99999] / [99999]
-- GA ALT / HDG				[999999] [999]
-- FAF ALT					[99999]
-- LANDING FLAPS			[flap_setting v]
-- AUTO BRAKE				[abrk v]
-- LANDING BLEEDS			[bleed_setting v]
-- LANDING ANTI-ICE			[aice_setting v]
-- SPEEDS VREF, VAPP		[999] [999]
-- *BARO Q/A				[9999] [>][<][99.99]		
-- ----------------------------------------------

		imgui.BeginTable("arrivalinfo",2)
		
			local ddwidth=146
			imgui.TableNextColumn()
			ng_imgui_out_text(color_yellow,"ARRIVAL")
			imgui.TableNextColumn()
			ng_imgui_in_tfield("darrival", ddwidth, color_white, 10, ng_getBriefPrefs():get("destination:star"), 
				function (textout) ng_getBriefPrefs():set("destination:star",textout) end )	
				
			imgui.TableNextRow()
			imgui.TableNextColumn()
			ng_imgui_out_text(color_white,"ARRIVAL TYPE")
			imgui.TableNextColumn()
			local splitTitle = ng_split(ng_getBriefPrefs():find("destination:arrtype"):getTitle(),"|")
			ng_imgui_in_combolist("darrtype", splitTitle, ng_getBriefPrefs():get("destination:arrtype"), 
				function (textin) ng_getBriefPrefs():set("destination:arrtype",textin) end, ddwidth)

			imgui.TableNextRow()
			imgui.TableNextColumn()
			ng_imgui_out_text(color_white,"TRANSITION")
			imgui.TableNextColumn()
			ng_imgui_in_tfield("Dtransition", ddwidth, color_white, 10, ng_getBriefPrefs():get("destination:startransition"), 
				function (textout) ng_getBriefPrefs():set("destination:startransition",textout) end )
				
			imgui.TableNextRow()
			imgui.TableNextColumn()
			ng_imgui_out_text(color_white,"LANDING FLAPS")
			imgui.TableNextColumn()
			local splitTitle = ng_split(ng_getAcfPrefs():get("controls:ldflapslbl"),"|")
			-- ng_imgui_in_combolist("dflaps", splitTitle, ng_getBriefPrefs():get("landing:selectedflaps"), 
				-- function (textin) ng_getBriefPrefs():set("landing:selectedflaps",textin) end, ddwidth)

			imgui.TableNextRow()
			imgui.TableNextColumn()
			ng_imgui_out_text(color_white,"LANDING BLEEDS")
			imgui.TableNextColumn()
			local splitTitle = ng_split(ng_getAcfPrefs():find("air:landingbleeds"):getTitle(),"|")
			ng_imgui_in_combolist("dbleeds", splitTitle, ng_getBriefPrefs():get("landing:selectedbleed"), 
				function (textin) ng_getBriefPrefs():set("landing:selectedbleed",textin) end, ddwidth)
				
			imgui.TableNextRow()
			imgui.TableNextColumn()
			ng_imgui_out_text(color_white,"LANDING ANTI-ICE")
			imgui.TableNextColumn()
			local splitTitle = ng_split(ng_getAcfPrefs():get("aice:landingaice"),"|")
			ng_imgui_in_combolist("daice", splitTitle, ng_getBriefPrefs():get("landing:selectedaice"), 
				function (textin) ng_getBriefPrefs():set("landing:selectedaice",textin) end, ddwidth)

			imgui.TableNextRow()
			imgui.TableNextColumn()
			ng_imgui_out_text(color_white,"LANDING VREF,VAPP")
			imgui.TableNextColumn()
			ng_imgui_in_intfield("dvref", 30, color_white, 0, ng_getBriefPrefs():get("landing:rwyvref"), 
				function (textout) ng_getBriefPrefs():set("landing:rwyvref",textout) end ) imgui.SameLine()
			ng_imgui_in_intfield("dvapp", 30, color_white, 0, ng_getBriefPrefs():get("landing:rwyvapp"), 
				function (textout) ng_getBriefPrefs():set("landing:rwyvapp",textout) end ) 

			if ng_getAcfPrefs():get("general:hasautobrk") then
				imgui.TableNextRow()
				imgui.TableNextColumn()
				ng_imgui_out_text(color_white,"AUTOBRAKE")
				imgui.TableNextColumn()
				local splitTitle = ng_split(ng_getAcfPrefs():get("general:abrkmodelblt"),"|")
				ng_imgui_in_combolist("abrkset", splitTitle, ng_getBriefPrefs():get("landing:selectedabrk"), 
					function (textin) ng_getBriefPrefs():set("landing:selectedabrk",textin) end, ddwidth)
			end
			
			imgui.TableNextRow()
			imgui.TableNextColumn()
			ng_imgui_out_text(color_white,"*BARO Q/A")
			imgui.TableNextColumn()
			ng_imgui_in_floatfield("baroq", 40, color_white, 0, "%04.0f",ng_getBriefPrefs():get("landing:qaltimeter"), 
				function (textout) ng_getBriefPrefs():set("landing:qaltimeter",textout) end ) imgui.SameLine()
			ng_imgui_in_button("convbaro", "<", 15, 20, 
				function () ng_getBriefPrefs():set("landing:qaltimeter",(ng_getBriefPrefs():get("landing:altimeter") * 33.8639)) end ) imgui.SameLine()
			ng_imgui_in_button("convbaro", ">", 15, 20, 
				function () ng_getBriefPrefs():set("landing:altimeter",(ng_getBriefPrefs():get("landing:qaltimeter") / 33.8639)) end ) imgui.SameLine()
			ng_imgui_in_floatfield("baroa", 40, color_white, 0, "%05.2f", ng_getBriefPrefs():get("landing:altimeter"), 
				function (textout) ng_getBriefPrefs():set("landing:altimeter",textout) end ) 
			
		imgui.EndTable()
		imgui.Separator()
	
	end

-- -----------------------------------------------------------------------------------------
-- draw the Flight tab destination		
	local function render_preflight_destination() -- destination
	
		imgui.BeginTable("destination",2)

			render_destination_arpt_info()
			render_arrival_info()
			
	end
			
-- -----------------------------------------------------------------------------------------
-- draw the Flight tab
	local function render_main_tab_flight()
	
		imgui.BeginChild("#tabmain")

			local fstate = ng_getBckVars():get("general:flightstate")
			render_status_block()

			imgui.Columns(3,"preflightcols",true)
				imgui.BeginChild("preflightcol1")
					
					-- change context depending on flight phase
					if fstate < 7 then
						render_preflight_planning()
					elseif fstate >= 7 and fstate <= 12 then
						render_preflight_origin()
					elseif fstate > 12 then
						render_preflight_destination()
					end
				imgui.EndChild()
				
			imgui.NextColumn()
				
				imgui.BeginChild("preflightcol2")
					
					-- change context depending on flight phase
					if fstate < 7 then
						render_preflight_origin()
					elseif fstate >= 7 and fstate <= 12 then
						render_preflight_destination()
					elseif fstate > 12 then
					end
					
				imgui.EndChild()
				
			imgui.NextColumn()
			
				imgui.BeginChild("preflightcol3")
				
					-- change context depending on flight phase
					if fstate < 7 then
						render_preflight_destination()
					elseif fstate >= 7 and fstate <= 12 then
					elseif fstate > 12 then
					end
					
				imgui.EndChild()
			imgui.Columns()
		imgui.EndChild()		
	end

-- -----------------------------------------------------------------------------------------
-- draw the Full SOP tab
	local function render_main_tab_sop()
	
		imgui.BeginChild("#tab2")
			ng_get_active_sop():render("f")
		imgui.EndChild()		
		
	end

-- -----------------------------------------------------------------------------------------
-- SOP / Systems Editor rendering
-- -----------------------------------------------------------------------------------------
-- draw the Editor tab

	local function render_main_tab_editor()
	
-- -----------------------------------------------------------------------------------------
-- System Editor	
-- -----------------------------------------------------------------------------------------

-- -----------------------------------------------------------------------------------------
-- load system json with definitions of all systems
		local function loadsystem()
			local path = SCRIPT_DIRECTORY.."../Modules/kpcrew/addons/"..ng_editor_system_icao.."_systems.json"
			if ng_file_exists(path) then
				local json = require "kpcrew.json"
				local file = io.open(path, "r")
				local jsonstr = ""
				for line in file:lines() do jsonstr = jsonstr .. line end
				file:close()
				ng_editor_system_json = json.parse(jsonstr)
			end
		end
		
-- -----------------------------------------------------------------------------------------
-- save the edited system json 
		local function savesystem()
			local path = SCRIPT_DIRECTORY.."../Modules/kpcrew/addons/"..ng_editor_system_icao.."_systems.json"
			local prettyprint = require ("kpcrew.json_pretty_print")
			local jsonout = prettyprint:pretty_print(ng_editor_system_json,nil,true)
			local filesystem = io.open(path, "w+")
			filesystem:write(jsonout)
			filesystem:close()
		end

-- -----------------------------------------------------------------------------------------
-- render lowest level in systems hierarchy - individual elements
-- @param tablenode nelement current element node in system table
-- @param int ielement index of element node on parent systems table
-- @param tablenode nsystem parent system node for this element 
-- @param string category name
		local function renderelements(nelement, ielement, nsystem, category)

-- common part for all types
-- --------------------------------------------------------
-- name		| [                                           ]
-- type		| [<type list drop down>                     V]
-- title	| [                                           ]
-- dref		| [                                           ]
-- indx		| [+] <-- if not set + creates it
-- indx		| [                                     ][-][+]
-- acts		| [<act1 V][<act2 V][<act3 V][<act4 V][<act5 V]
-- check()	| [<code that returns true/false>             ]

			imgui.BeginGroup()
	
				imgui.Separator()
				
				-- available types for elements
				local elementtypes = { "", "dataref", "function", "onoff", "toggle", "multistate", "dial" }
				-- available actions for elements
				local actions = { "", "on", "off", "set", "toggle", "up", "down", "function", " "}

				local ename = nelement.name -- base name to use for imgui id 

-- name		| [                                           ]
				ng_imgui_out_text(color_white, "name") imgui.NextColumn()
				ng_imgui_in_tfield(ename.."name", 300, color_white, 255,  
					nelement.name, function (textout) nelement.name = textout end) imgui.NextColumn()

-- type		| [<type list drop down>                     V]
				ng_imgui_out_text(color_white, "type") imgui.NextColumn()
				if nelement.type ~= nil then
					ng_imgui_in_combolist(ename.."etype", elementtypes, ng_indexOf(elementtypes,nelement.type)-1, 
						function (textin) nelement.type=elementtypes[textin+1] end,300) imgui.NextColumn()
				else -- if empty draw the plus button
					ng_imgui_in_button(ename.."addtype", "+", 15, 20, 
						function () nelement.type = "dataref" end) imgui.NextColumn()
				end
					
-- title	| [                                           ]				
				ng_imgui_out_text(color_white, "title") imgui.NextColumn()
				if nelement.title ~= nil then
					ng_imgui_in_tfield(ename.."title", 300, color_orange, 255,  
						nelement.title, function (textout) nelement.title = textout end) imgui.NextColumn()
				else
					ng_imgui_in_button(ename.."addtitle", "+", 15, 20, 
						function () nelement.title = "" end) imgui.NextColumn()
				end
					
-- dref		| [                                           ]
				ng_imgui_out_text(color_white, "dref") imgui.NextColumn()
				if nelement.dref ~= nil then
					ng_imgui_in_tfield(ename.."dref", 300, color_orange, 255,  
					nelement.dref, function (textout) nelement.dref = textout end) imgui.NextColumn()
				else
					ng_imgui_in_button(ename.."adddref", "+", 15, 20, 
						function () nelement.dref = "" end) imgui.NextColumn()
				end
				
-- indx		| [                                      ][-][+]
				ng_imgui_out_text(color_white, "indx") imgui.NextColumn()
				if nelement.indx ~= nil then
					ng_imgui_in_intfield(ename.."indx", 300, color_orange, 1, 
					nelement.indx, function (textout) nelement.indx = textout end) imgui.NextColumn()
				else
					ng_imgui_in_button(ename.."addindx", "+", 15, 20, 
						function () nelement.indx = 0 end) imgui.NextColumn()
				end

-- acts		| [<act1 V][<act2 V][<act3 V][<act4 V][<act5 V]
-- up to 5 allowed actions for this element, blank action does nothing
				ng_imgui_out_text(color_white, "acts") imgui.NextColumn() 
				if nelement.acts ~= nil and #nelement.acts > 0 then

					for nidx,nacts in pairs(nelement.acts) do 
						ng_imgui_in_combolist(ename.."acts"..nidx, actions, ng_indexOf(actions,nacts)-1, 
							function (textin) nelement.acts[nidx] = (actions[textin+1] == " " and nil or actions[textin+1]) end,55)
						if nidx < #nelement.acts then imgui.SameLine() end
					end
					for i=#nelement.acts+1,5,1 do
						imgui.SameLine()
						ng_imgui_in_combolist(ename.."nacts"..i, actions, ng_indexOf(actions," ")-1, 
							function (textin) nelement.acts[i] = actions[textin] end,55)
					end
					
					imgui.NextColumn()
				else
					ng_imgui_in_button(ename.."addacts", "+", 15, 20, 
						function () nelement.acts={"on","","","",""} end) imgui.NextColumn()					
				end

-- check()	| [<code that returns true/false>             ]
-- sth like return get(\"dataref/key\") == 1" for example
				ng_imgui_out_text(color_white, "check()") imgui.NextColumn()
				if nelement.fcheck ~= nil then
					ng_imgui_in_tfield(ename.."fcheck", 300, color_orange, 255, 
					nelement.fcheck, function (textout) nelement.fcheck = textout end) imgui.NextColumn()
				else
					ng_imgui_in_button(ename.."addfcheck", "+", 15, 20, 
						function () nelement.fcheck = "" end) imgui.NextColumn()
				end

-- ========== type specific fields to be added to common part
-- toggle and onoff elements
				if nelement.type == "toggle" or nelement.type == "onoff" then
				
					if nelement.type == "onoff" then -- on off have the off and on cmd + toggle
					
-- cmdoff	| [                                           ]
-- x-plane command id string to execute with command_once() to turn sth OFF
						ng_imgui_out_text(color_white, "cmdoff") imgui.NextColumn()
						if nelement.cmdoff ~= nil then
							ng_imgui_in_tfield(ename.."cmdoff", 300, color_orange, 255,  
							nelement.cmdoff, function (textout) nelement.cmdoff = textout end) imgui.NextColumn()
						else
							ng_imgui_in_button(ename.."addcmdoff", "+", 15, 20, 
								function () nelement.cmdoff = "" end) imgui.NextColumn()
						end
						
-- cmdon	| [                                           ]
-- x-plane command id string to execute with command_once() to turn sth ON
						ng_imgui_out_text(color_white, "cmdon") imgui.NextColumn()
						if nelement.cmdon ~= nil then
							ng_imgui_in_tfield(ename.."cmdon", 300, color_orange, 255,  
							nelement.cmdon, function (textout) nelement.cmdon = textout end) imgui.NextColumn()
						else
							ng_imgui_in_button(ename.."addcmdon", "+", 15, 20, 
								function () nelement.cmdon = "" end) imgui.NextColumn()
						end
						
					end
						
-- cmdtgl	| [                                           ]
-- x-plane command id string to execute with command_once() to toggle the switch
					ng_imgui_out_text(color_white, "cmdtgl") imgui.NextColumn()
					if nelement.cmdtgl ~= nil then
						ng_imgui_in_tfield(ename.."cmdtgl", 300, color_orange, 255,  
						nelement.cmdtgl, function (textout) nelement.cmdtgl = textout end) imgui.NextColumn()
					else
						ng_imgui_in_button(ename.."addcmdtgl", "+", 15, 20, 
							function () nelement.cmdtgl = "" end) imgui.NextColumn()
					end

				end

-- function element - special elements with lua code for on/off/tgl and check
				if nelement.type == "function" then

-- on()		| [                                           ]
-- function triggering actions to set a switch which is not simple 1/0 or commands
					ng_imgui_out_text(color_white, "on()") imgui.NextColumn()
					if nelement.funcon ~= nil then
						ng_imgui_in_tfield(ename.."funcon", 300, color_orange, 255, 
						nelement.funcon, function (textout) nelement.funcon = textout end) imgui.NextColumn()
					else
						ng_imgui_in_button(ename.."addfuncon", "+", 15, 20, 
							function () nelement.funcon = "" end) imgui.NextColumn()
					end
					
-- off()	| [                                           ]
-- function triggering actions to set a switch which is not simple 1/0 or commands
					ng_imgui_out_text(color_white, "off()") imgui.NextColumn()
					if nelement.funcoff ~= nil then
						ng_imgui_in_tfield(ename.."funcoff", 300, color_orange, 255,  
						nelement.funcoff, function (textout) nelement.funcoff = textout end) imgui.NextColumn()
					else
						ng_imgui_in_button(ename.."addfuncoff", "+", 15, 20, 
							function () nelement.funcoff = "" end) imgui.NextColumn()
					end
					
-- tgl()	| [                                           ]
-- function triggering actions to set a switch which is not simple 1/0 or commands
					ng_imgui_out_text(color_white, "tgl()") imgui.NextColumn()
					if nelement.functgl ~= nil then
						ng_imgui_in_tfield(ename.."functgl", 300, color_orange, 255, 
						nelement.functgl, function (textout) nelement.functgl = textout end) imgui.NextColumn()
					else
						ng_imgui_in_button(ename.."addfunctgl", "+", 15, 20, 
							function () nelement.functgl = "" end) imgui.NextColumn()
					end
					
				end

-- dial or multistate are for elements which dial up or down or have n options to set				
				if nelement.type == "dial" or nelement.type == "multistate" then

-- min		| [                                      ][-][+]
-- minimal value to dial/set
					ng_imgui_out_text(color_white, "min") imgui.NextColumn()
					if nelement.min ~= nil then
						ng_imgui_in_intfield(ename.."min", 300, color_orange, 1,
						nelement.min, function (textout) nelement.min = textout end) imgui.NextColumn()
					else
						ng_imgui_in_button(ename.."addmin", "+", 15, 20, 
							function () nelement.min = 0 end) imgui.NextColumn()
					end
					
-- max		| [                                      ][-][+]
-- maximal value to dial/set
					ng_imgui_out_text(color_white, "max") imgui.NextColumn()
					if nelement.max ~= nil then
						ng_imgui_in_intfield(ename.."max", 300, color_orange, 1, 
						nelement.max, function (textout) nelement.max = textout end) imgui.NextColumn()
					else
						ng_imgui_in_button(ename.."addmax", "+", 15, 20, 
							function () nelement.max = 0 end) imgui.NextColumn()
					end
					
-- incr		| [                                      ][-][+]
-- increment for each step up/down
					if nelement.type == "dial" then
						ng_imgui_out_text(color_white, "incr") imgui.NextColumn()
						if nelement.incr ~= nil then
							ng_imgui_in_intfield(ename.."incr", 300, color_orange, 1, 
							nelement.incr, function (textout) nelement.incr = textout end) imgui.NextColumn()
						else
							ng_imgui_in_button(ename.."addincr", "+", 15, 20, 
								function () nelement.incr = 1 end) imgui.NextColumn()
						end
					end 
					
-- cmddn	| [                                           ]
-- x-plane command id string to execute with command_once() decrease the value
					ng_imgui_out_text(color_white, "cmddn") imgui.NextColumn()
					if nelement.cmddn ~= nil then
						ng_imgui_in_tfield(ename.."cmddn", 300, color_orange, 255,  
						nelement.cmddn, function (textout) nelement.cmddn = textout end) imgui.NextColumn()
					else
						ng_imgui_in_button(ename.."addcmddn", "+", 15, 20, 
							function () nelement.cmddn = "" end) imgui.NextColumn()
					end
					
-- cmdup	| [                                           ]
-- x-plane command id string to execute with command_once() increase the value
					ng_imgui_out_text(color_white, "cmdup") imgui.NextColumn()
					if nelement.cmdup ~= nil then
						ng_imgui_in_tfield(ename.."cmdup", 300, color_orange, 255,  
						nelement.cmdup, function (textout) nelement.cmdup = textout end) imgui.NextColumn()
					else
						ng_imgui_in_button(ename.."addcmdup", "+", 15, 20, 
							function () nelement.cmdup = "" end) imgui.NextColumn()
					end
					
				end

				if string.lower(category) == "custom" then
					
					imgui.NextColumn()
					imgui.PushStyleColor(imgui.constant.Col.Button, color_red)
						ng_imgui_in_button(ename.."del", "REMOVE ELEMENT "..ename, 300, 20, 
							function () table.remove(nsystem.elements, ielement) end) 
					imgui.PopStyleColor()

				end 				
				
				imgui.Separator()
				
			imgui.EndGroup()
		end

-- -----------------------------------------------------------------------------------------
-- render the system level of systems
-- @param tablenode nsystem system with elements to render
-- @param int ielement index of system in parent table
-- @param tablenode ncategory parent category
		local function rendersystems(nsystem, isystem, ncategory)
					
			local newelement = { name="" }
			
			local sname = nsystem.name

			if imgui.TreeNode(sname) then
				
				-- imgui.Separator()
				
				-- only show for custom category (others are fixed)
				if string.lower(ncategory.name) == "custom" then
					
					imgui.PushStyleColor(imgui.constant.Col.Button, color_red)
					ng_imgui_in_button(sname.."del", "REMOVE SYSTEM "..sname, 367, 20, 
						function () table.remove(ncategory.systems, isystems) end) 
					imgui.PopStyleColor()

					ng_imgui_in_button(sname.."append", "Append Element", 109, 20, 
						function () if ng_editor_system_newelement ~= "" then newelement.name=ng_editor_system_newelement
							table.insert (nsystem.elements, newelement) ng_editor_system_newelement = "" end end) 
					imgui.SameLine() ng_imgui_in_tfield(sname.."name", 250, color_orange, 255, 
						ng_editor_system_newelement, function (textout) ng_editor_system_newelement = textout end)
						
				end
				
				-- render elements of this system
				if nsystem.elements ~= nil then
					
					for ielement,nelement in ipairs(nsystem.elements) do
												
						imgui.Columns(2, nsystem.name, true)					
							imgui.SetColumnWidth(0, 65)
							imgui.SetColumnWidth(1, 400)
							renderelements(nelement,ielement,nsystem,ncategory.name)				
						imgui.Columns(1)
					end

				end
			imgui.TreePop() end
		end

		local function rendercategory(ncategory)
		
			-- Append system
			local newsystem = { name="", elements={} }

			if imgui.TreeNode(ncategory.name) then

				if string.lower(ncategory.name) == "custom" then
					
					ng_imgui_in_button(ncategory.name.."append", "Append System", 180, 20, 
						function () if ng_editor_system_newsystem ~= "" then newsystem.name=ng_editor_system_newsystem
							table.insert (ncategory.systems, newsystem) ng_editor_system_newsystem = "" end end) 
					imgui.SameLine() ng_imgui_in_tfield(ncategory.name.."name", 200, color_orange, 255, 
						ng_editor_system_newsystem, function (textout) ng_editor_system_newsystem = textout end)
				end
				for isystems,nsystems in ipairs(ncategory.systems) do
					rendersystems(nsystems,isystems,ncategory)
				end
				
			imgui.TreePop() end
		end
		
		-- draw
		local function rendersystem()
			if ng_editor_system_json ~= nil then
				imgui.SetNextItemOpen(true)
				if imgui.TreeNode(ng_editor_system_json.title) then
					for nidx,ncategory in pairs(ng_editor_system_json.addonsystems.categories) do
						rendercategory(ncategory)
					end
				imgui.TreePop() end
			end
		end

-- -------------------------------------- SOP Editor 	

		-- load sop json
		local function loadsop()
			local path = SCRIPT_DIRECTORY.."../Modules/kpcrew/addons/"..ng_editor_sop_icao.."_sop.json"
			if ng_file_exists(path) then
				local json = require "kpcrew.json"
				local file = io.open(path, "r")
				local jsonstr = ""
				for line in file:lines() do jsonstr = jsonstr .. line end
				file:close()
				ng_editor_sop_json = json.parse(jsonstr)
				print(ng_editor_sop_json.title)
			end
		end
		
		-- load system json
		local function savesop()
			local path = SCRIPT_DIRECTORY.."../Modules/kpcrew/addons/"..ng_editor_sop_icao.."_sop.json"
			local prettyprint = require ("kpcrew.json_pretty_print")
			local jsonout = prettyprint:pretty_print(ng_editor_sop_json,nil,true)
			local filesystem = io.open(path, "w+")
			filesystem:write(jsonout)
			filesystem:close()
		end

		-- render flow item
		local function renderitem(nitem, nidx, nflow)

			local itemclasses = { "", "ProcedureItem", "ChecklistItem" }
			local roles = { "", "ng_firole_PF", "ng_firole_PNF", "ng_firole_PM", "ng_firole_BOTH", 
				"ng_firole_FO", "ng_firole_CPT", "ng_firole_LHS", "ng_firole_RHS", "ng_firole_FE", 
				"ng_firole_CM1", "ng_firole_CM2", "ng_firole_CM3", "ng_firole_ALL", "ng_firole_SYS" }
			local actions = { "", "on", "off", "set", "toggle", "up", "down", "function", " "}
		
			local nlabel = nitem.challenge

			imgui.BeginGroup()
				
				-- imgui.Separator()
				
					if imgui.TreeNode(nitem.challenge) then

						ng_imgui_in_button(nlabel.."up", "UP", 20, 20, 
							function () if nidx > 1 then table.insert(nflow.flowitem, nidx-1, table.remove(nflow.flowitem,nidx)) end end) 
						imgui.SameLine() ng_imgui_in_button(nlabel.."dn", "DN", 20, 20, 
							function () if nidx < #nflow.flowitem then table.insert(nflow.flowitem, nidx+1, table.remove(nflow.flowitem,nidx)) end end) 

						imgui.PushStyleColor(imgui.constant.Col.Button, color_red)
							imgui.SameLine() ng_imgui_in_button(nlabel.."del", "REMOVE ITEM!", 90, 20, 
								function () table.remove(nflow.flowitem, nidx) end) 
						imgui.PopStyleColor()

-- --------------------------------------						
						ng_imgui_out_text(color_white, "Class:") imgui.SameLine()
						if nitem.classname ~= nil then
							ng_imgui_in_combolist(nlabel.."class", itemclasses, ng_indexOf(itemclasses,nitem.classname)-1, 
								function (textin) nitem.classname=itemclasses[textin+1] end,320)
						else
							ng_imgui_in_button(nlabel.."addclass", "+", 15, 20, 
								function () nitem.classname = "" end) 
						end
				
						ng_imgui_out_text(color_white, "Response:") imgui.SameLine()
						if nitem.response ~= nil then
							ng_imgui_in_tfield(nlabel.."response", 350, color_orange, 255, 
							nitem.response, function (textout) nitem.response = string.upper(textout) end)
						else
							ng_imgui_in_button(nlabel.."addresp", "+", 15, 20, 
								function () nitem.response = "" end) 
						end
						
						ng_imgui_out_text(color_white, "Role:") imgui.SameLine()
						if nitem.role ~= nil then
							ng_imgui_in_combolist(nlabel.."role", roles, ng_indexOf(roles,nitem.role)-1, 
								function (textin) nitem.role=roles[textin+1] end,320)
						else
							ng_imgui_in_button(nlabel.."addrole", "+", 15, 20, 
								function () nitem.role = "" end) 
						end
						
						ng_imgui_out_text(color_white, "Condition:") imgui.SameLine()
						if nitem.condition ~= nil then
							ng_imgui_in_tfield(nlabel.."condition", 500, color_orange, 255, 
								nitem.condition, function (textout) nitem.condition = textout end)
						else
							ng_imgui_in_button(nlabel.."addcond", "+", 15, 20, 
								function () nitem.condition = "" end) 
						end
						
						ng_imgui_out_text(color_white, "No check:") imgui.SameLine()
						if nitem.nocheck ~= nil then
							ng_imgui_in_intfield(nlabel.."nchk", 320, color_orange, 0,   
								nitem.nocheck, function (textout) nitem.nocheck = textout end) 
						else
							ng_imgui_in_button(nlabel.."addncheck", "+", 15, 20, 
								function () nitem.nocheck = 1 end) 
						end
						
						ng_imgui_out_text(color_white, "Systems used:") 

						-- Append item
						local newelement = {element="" }

						ng_imgui_in_button(nlabel.."append", "Append Element", 105, 20, 
							function () if ng_editor_sop_newelement ~= "" then newelement.element=ng_editor_sop_newelement table.insert (nitem.setelements, newelement) ng_editor_sop_newelement= "" end end) 

						imgui.SameLine() ng_imgui_in_tfield(nlabel.."name", 200, color_orange, 255, 
							ng_editor_sop_newelement, function (textout) ng_editor_sop_newelement = textout end)
						
						if nitem.setelements ~= nil then 
							
							for eidx,nelement in ipairs(nitem.setelements) do

								imgui.Separator()
								if ng_editor_sop_expcol3 > 0 then imgui.SetNextItemOpen(ng_editor_sop_expand3) end

								ng_imgui_in_button(nelement.element.."up", "UP", 20, 20, 
									function () if eidx > 1 then table.insert(nitem.setelements, eidx-1, table.remove(nitem.setelements,eidx)) end end) 
								imgui.SameLine() ng_imgui_in_button(nelement.element.."dn", "DN", 20, 20, 
									function () if eidx < #nitem.setelements then table.insert(nitem.setelements, eidx+1, table.remove(nitem.setelements,eidx)) end end) 
								imgui.PushStyleColor(imgui.constant.Col.Button, color_red)
									imgui.SameLine() ng_imgui_in_button(nelement.element.."del", "REMOVE ELEMENT!", 110, 20, 
										function () table.remove(nitem.setelements, eidx) end) 
								imgui.PopStyleColor()
								
								ng_imgui_out_text(color_white, "Name:") imgui.SameLine()
								if nelement.element ~= nil then
									ng_imgui_in_tfield(nlabel..nelement.element, 320, color_orange, 255, 
									nelement.element, function (textout) nelement.element = textout end)
								else
									ng_imgui_in_button(nlabel..nelement.element.."addnname", "+", 15, 20, 
										function () nelement.element = "" end) 
								end
								
								ng_imgui_out_text(color_white, "Action:") imgui.SameLine()
								if nelement.action ~= nil then
									ng_imgui_in_combolist(nlabel..nelement.element.."act", actions, ng_indexOf(actions,nelement.action)-1, 
										function (textin) nelement.action=actions[textin+1] end,320)
									-- ng_imgui_in_tfield(nlabel..nelement.element.."act", 320, color_orange, 255, 
										-- nelement.action, function (textout) nelement.action = textout end)
								else
									ng_imgui_in_button(nlabel..nelement.element.."addact", "+", 15, 20, 
										function () nelement.action = "" end) 
								end
								
								ng_imgui_out_text(color_white, "Value:") imgui.SameLine()
								if nelement.value ~= nil then
									ng_imgui_in_floatfield(nlabel..nelement.element.."val", 320, color_orange, 0, "%7.2f",  
										nelement.value, function (textout) nelement.value = textout end) 
								else
									ng_imgui_in_button(nlabel..nelement.element.."addval", "+", 15, 20, 
										function () nelement.value = 0 end) 
								end
								
								ng_imgui_out_text(color_white, "Condition:") imgui.SameLine()
								if nelement.condition ~= nil then
									ng_imgui_in_tfield(nlabel..nelement.element.."cond", 500, color_orange, 255, 
									nelement.condition, function (textout) nelement.condition = textout end)
								else
									ng_imgui_in_button(nlabel..nelement.element.."addcond", "+", 15, 20, 
										function () nelement.condition = "" end) 
								end
																						
								ng_imgui_out_text(color_white, "No check:") imgui.SameLine()
								if nelement.nocheck ~= nil then
									ng_imgui_in_intfield(nlabel..nelement.element.."nchk", 500, color_orange, 0,   
										nelement.nocheck, function (textout) nelement.nocheck = textout end) 
								else
									ng_imgui_in_button(nlabel..nelement.element.."addnchk", "+", 15, 20, 
										function () nelement.nocheck = 1 end) 
								end

								ng_imgui_out_text(color_white, "set():") imgui.SameLine()
								if nelement.fset ~= nil then
									ng_imgui_in_tfield(nlabel..nelement.element.."fset", 500, color_orange, 255, 
									nelement.fset, function (textout) nelement.fset = textout end)
								else
									ng_imgui_in_button(nlabel..nelement.element.."addfset", "+", 15, 20, 
										function () nelement.fset = "" end) 
								end

								imgui.Separator()
														
							end
						end

					imgui.TreePop() end
				
				imgui.Separator()
				
			imgui.EndGroup()
		end
		
		local function renderflow(nflow, nidx, numflows)

			local phases = { "", "ng_phase_flight_planning", "ng_phase_colddark", "ng_phase_prel_preflight", 
				"ng_phase_preflight", "ng_phase_before_start", "ng_phase_after_start", "ng_phase_taxi_rwy", 
				"ng_phase_before_takeoff", "ng_phase_takeoff", "ng_phase_after_takeoff", "ng_phase_climb", 
				"ng_phase_enroute", "ng_phase_descent", "ng_phase_arrival", "ng_phase_approach", "ng_phase_landing", 
				"ng_phase_go_around", "ng_phase_afterland", "ng_phase_taxi_stand", "ng_phase_shutdown", "ng_phase_turnaround" }

			local flowclasses = { "", "ProcedureFlow", "ChecklistFlow", "BackgroundFlow" }

			local ntitle = nflow.title
			
			if imgui.TreeNode(ntitle) then
				imgui.Separator()

				ng_imgui_in_button(ntitle.."expand", "Expand", 60, 20, 
					function () ng_editor_sop_expcol2 = 3 ng_editor_sop_expand2 = true end) 

				imgui.SameLine() ng_imgui_in_button(ntitle.."compress", "Compress", 60, 20, 
					function () ng_editor_sop_expcol2 = 3 ng_editor_sop_expand2 = false end) 

				imgui.SameLine()ng_imgui_in_button(ntitle.."up", "UP", 20, 20, 
					function () if nidx > 1 then table.insert(ng_editor_sop_json.sop.flow, nidx-1, table.remove(ng_editor_sop_json.sop.flow,nidx)) end end) 
				imgui.SameLine() ng_imgui_in_button(ntitle.."dn", "DN", 20, 20, 
					function () if nidx < numflows then table.insert(ng_editor_sop_json.sop.flow, nidx+1, table.remove(ng_editor_sop_json.sop.flow,nidx)) end end) 

				imgui.PushStyleColor(imgui.constant.Col.Button, color_red)
					imgui.SameLine() ng_imgui_in_button(ntitle.."del", "REMOVE FLOW!", 90, 20, 
						function () table.remove(ng_editor_sop_json.sop.flow, nidx) end) 
				imgui.PopStyleColor()

				ng_imgui_out_text(color_white, "Phase:") imgui.SameLine()
				ng_imgui_in_combolist(ntitle.."phase", phases, ng_indexOf(phases,nflow.phase)-1, 
					function (textin) nflow.phase=phases[textin+1] end,320)

				ng_imgui_out_text(color_white, "Class:") imgui.SameLine()
				ng_imgui_in_combolist(ntitle.."class", flowclasses, ng_indexOf(flowclasses,nflow.classname)-1, 
					function (textin) nflow.classname=flowclasses[textin+1] end,320)

				-- Append item
				local newitem = {challenge="", setelements = {  } }

				ng_imgui_in_button(ntitle.."append", "Append Item", 90, 20, 
					function () if ng_editor_sop_newitem ~= "" then newitem.challenge=string.upper(ng_editor_sop_newitem) table.insert (nflow.flowitem, newitem) ng_editor_sop_newitem = "" end end) 

				imgui.SameLine() ng_imgui_in_tfield(ntitle.."name", 200, color_orange, 255, 
					ng_editor_sop_newitem, function (textout) ng_editor_sop_newitem = textout end)

				for nitemidx,nitem in ipairs(nflow.flowitem) do
					if ng_editor_sop_expcol2 > 0 then imgui.SetNextItemOpen(ng_editor_sop_expand2) end
					renderitem(nitem,nitemidx,nflow)
				end
				imgui.Separator()
			imgui.TreePop() end
		end
		
		-- draw
		local function rendersop()
			if ng_editor_sop_json ~= nil then
				
				imgui.Separator()
				
				ng_imgui_in_button(ng_editor_sop_json.sop.title.."expand", "Expand", 60, 20, 
					function () ng_editor_sop_expcol1 = 3 ng_editor_sop_expand1 = true end) 

				imgui.SameLine() ng_imgui_in_button(ng_editor_sop_json.sop.title.."compress", "Compress", 60, 20, 
					function () ng_editor_sop_expcol1 = 3 ng_editor_sop_expand1 = false end) 

				-- Append flow
				local newflow = {title="", phase="ng_phase_colddark", classname="ProcedureFlow", flowitem={  } }

				imgui.SameLine() ng_imgui_in_button(ng_editor_sop_json.sop.title.."append", "Append Flow", 90, 20, 
					function () if ng_editor_sop_newflow ~= "" then newflow.title=string.upper(ng_editor_sop_newflow) table.insert (ng_editor_sop_json.sop.flow, newflow) ng_editor_sop_newflow = "" end end) 

				imgui.SameLine() ng_imgui_in_tfield(ng_editor_sop_json.sop.title.."name", 200, color_orange, 255, 
					ng_editor_sop_newflow, function (textout) ng_editor_sop_newflow = textout end)


				-- Loop through all flows
				if ng_editor_sop_expcol1 > 0 then imgui.SetNextItemOpen(ng_editor_sop_expand1) end
				if imgui.TreeNode(ng_editor_sop_json.sop.title) then
					for nidx,nflow in ipairs(ng_editor_sop_json.sop.flow) do
						renderflow(nflow,nidx,#ng_editor_sop_json.sop.flow)
					end
				imgui.TreePop() end
			end
		end
	
		imgui.BeginChild("#tab4")

			-- editor columns
			imgui.Columns(2,"editor",true)
				imgui.BeginChild("editcol1")
				
					ng_imgui_out_text(color_yellow,"====================== AIRCRAFT SYSTEMS ======================")
				
					-- ICAO for systems
					ng_imgui_in_tfield("Systems for", 50, color_white, 10, ng_editor_system_icao, 
						function (textout) ng_editor_system_icao = textout end)

					-- load and save button to save after changes or load again
					imgui.SameLine()
					ng_imgui_in_button("loadsys", "LOAD", 70, 20, 
						function () loadsystem() end)

					imgui.SameLine()
					ng_imgui_in_button("savesys","SAVE", 70, 20,
						function () savesystem() end)
					
					imgui.SetNextItemOpen(true)
					rendersystem()
					
				imgui.EndChild()
				
			imgui.NextColumn()
			
				-- right tab with aircraft preferences
				imgui.BeginChild("editcol2")
				
					ng_imgui_out_text(color_yellow,"========================== SOP EDITOR ========================")

					-- ICAO for systems
					ng_imgui_in_tfield("SOP for", 50, color_white, 10, ng_editor_sop_icao, 
						function (textout) ng_editor_sop_icao = textout end)

					-- load and save button to save after changes or load again
					imgui.SameLine()
					ng_imgui_in_button("loadbrief", "LOAD", 70, 20, 
						function () loadsop() end)
	
					imgui.SameLine()
					ng_imgui_in_button("savebrief","SAVE", 70, 20,
						function () savesop() end)
	
					rendersop()
					if ng_editor_sop_expcol1 > 0 then ng_editor_sop_expcol1 = ng_editor_sop_expcol1 - 1 end
					if ng_editor_sop_expcol2 > 0 then ng_editor_sop_expcol2 = ng_editor_sop_expcol2 - 1 end
					if ng_editor_sop_expcol3 > 0 then ng_editor_sop_expcol3 = ng_editor_sop_expcol3 - 1 end

				imgui.EndChild()
			imgui.Columns()

		imgui.EndChild()		
		
	end

-- -----------------------------------------------------------------------------------------
-- draw the Settings tab
	local function render_main_tab_settings()
	
		imgui.BeginChild("#tab3")
			
			-- left tab with app preferences
			imgui.Columns(2,"settings",true)
				imgui.BeginChild("prefcol1")
				
					-- load and save button to save after changes or load again
					ng_imgui_in_button("loadapp", "LOAD", 70, 20, 
						function () ng_getAppPrefs():load() end)

					imgui.SameLine()
					ng_imgui_in_button("savebapp","SAVE", 70, 20,
						function () ng_getAppPrefs():save() end)
					
					-- render preferences tree
					imgui.SetNextItemOpen(true)
					ng_getAppPrefs():render("tree")
					
				imgui.EndChild()
				
			imgui.NextColumn()
			
				-- right tab with aircraft preferences
				imgui.BeginChild("prefcol2")
				
					-- load and save button to save after changes or load again
					ng_imgui_in_button("loadbrief", "LOAD", 70, 20, 
						function () ng_getAcfPrefs():load() end)
	
					imgui.SameLine()
					ng_imgui_in_button("savebrief","SAVE", 70, 20,
						function () ng_getAcfPrefs():save() end)
	
					-- render preferences tree
					imgui.SetNextItemOpen(true)
					ng_getAcfPrefs():render("tree")
					
				imgui.EndChild()
			imgui.Columns()
			
		imgui.EndChild()		
		
	end
	
-- -----------------------------------------------------------------------------------------
-- set up windows

	-- get screen width from X-Plane
	ng_scrn_width = get("sim/graphics/view/window_width")
	ng_scrn_height = get("sim/graphics/view/window_height")
	
	if FLYWITHLUA then
		imgui.SetNextWindowSize(ng_imgui_main_wnd_width,ng_imgui_main_wnd_height)
	else
		imgui.SetNextWindowSize({ng_imgui_main_wnd_width,ng_imgui_main_wnd_height})
	end
	
	if FLYWITHLUA == false then imgui.Begin("KPCrewNG " .. ng_VERSION) end

	local tabsDef = {[0]="Flight", [1]="Full SOP", [2]="Settings", [3]="Editor"}
	local tabsNumber = (#tabsDef+1)
	local tabsSize = kb_wnd_width / tabsNumber - 4
	
	imgui.BeginGroup()
		for i = 0,#tabsDef,1 do ng_imgui_draw_add_main_tab(i, tabsSize, tabsDef[i]) end
	imgui.EndGroup()
	
	imgui.BeginGroup()
	if     ng_imgui_current_main_tab == 0 then render_main_tab_flight()
	elseif ng_imgui_current_main_tab == 1 then render_main_tab_sop() 
	elseif ng_imgui_current_main_tab == 2 then render_main_tab_settings()
	elseif ng_imgui_current_main_tab == 3 then render_main_tab_editor()
	end
	imgui.EndGroup()
	
	if FLYWITHLUA == false then imgui.End() end
		
end

-- -----------------------------------------------------------------------------------------
-- drawing function for SOP window
function ng_draw_sop_window()
	
	if FLYWITHLUA then
		-- imgui.SetNextWindowSize(460,(15 + 2 ) * 23 + 12 + 27)
		imgui.SetNextWindowPos(ng_scrn_width-455,ng_scrn_height-((15 + 2 ) * 23 + 12 + 77))
	else
		imgui.SetNextWindowSize({490,ng_get_active_sop():getNumberFlows()*24})
		imgui.SetNextWindowPos({ng_scrn_width-497, (60/17)*ng_get_active_sop():getNumberFlows()})
	end

	if FLYWITHLUA == false then imgui.Begin(ng_get_active_sop():getTitle()) end
		ng_get_active_sop():render("i")
	if FLYWITHLUA == false then imgui.End() end
	
end

-- -----------------------------------------------------------------------------------------
-- drawing function for ctrl window
function ng_draw_ctrl_window()
	
	if FLYWITHLUA then
		-- imgui.SetNextWindowSize(700,50)
		imgui.SetNextWindowPos(ng_scrn_width-705,ng_scrn_height-46)
	else
		imgui.SetNextWindowSize({615,50})
		imgui.SetNextWindowPos({ng_scrn_width-615,ng_scrn_height-46})
	end
	
	local sop = ng_get_active_sop()
	local flow = sop:getActiveFlow() 
	
	if FLYWITHLUA == false then imgui.Begin("Control Window") end
	
	ng_imgui_in_button("ctrlprev","<<", 20, 20,
		function () ng_prev_flow()  end) 
		 
	imgui.SameLine()
	local color = color_white
	-- local outtext
	if flow == nil then
		outtext = "SOP :"..sop:getTitle()
		outcolor = color_white
	else
		if flow:getActiveItem() == nil or flow:getState() == ng_flowstate_end then
			outcolor = color_yellow
			
			if flow:isSelected() then mycolor = color_flow_active end
	
			if flow:getState() == ng_flowstate_new then outcolor = color_flow_new
			elseif flow:getState() == ng_flowstate_end then outcolor = color_flow_end
			elseif flow:getState() == ng_flowstate_err then outcolor = color_flow_err
			elseif flow:getState() == ng_flowstate_pause then outcolor = color_flow_pause 
			elseif flow:getState() == ng_flowstate_run then outcolor = color_flow_run
			end
			outtext = "FLOW: "..flow:getTitle()
			if flow:getState() == ng_flowstate_end then outtext = outtext.." - COMPLETED" end
		else
			outcolor = color_white
			if flow:getActiveItem():getState() == ng_fistate_end then outcolor = color_flow_end 
			elseif flow:getActiveItem():getState() == ng_fistate_err then outcolor = color_flow_err 
			elseif flow:getActiveItem():getState() == ng_fistate_run then outcolor = color_white 
			elseif flow:getActiveItem():getState() == ng_fistate_pause then outcolor = color_flow_pause
			end
			outtext = flow:getActiveItem():getLine(60)
		end
	end		
		 
	-- display line 
	imgui.PushStyleColor(imgui.constant.Col.Button, color_black)
		imgui.PushStyleColor(imgui.constant.Col.Text, outcolor)
			ng_imgui_in_button("outtext",outtext, 420, 20, function () end)
		imgui.PopStyleColor()
	imgui.PopStyleColor()	
	
	imgui.SameLine()
	ng_imgui_in_button("ctrlnext",">>", 20, 20,
		function () ng_next_flow() end)

	imgui.SameLine()
	ng_imgui_in_button("ctrlmaster","MASTER", 50, 20,
		function () ng_master_action() end)		
		
	imgui.SameLine()
	imgui.PushStyleColor(imgui.constant.Col.Button, color_red)
		ng_imgui_in_button("ctrlreset","RESET", 50, 20,
			function () sop:reset() end)		
	imgui.PopStyleColor()
	
	if FLYWITHLUA == false then imgui.End() end
end