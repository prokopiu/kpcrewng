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

local SOP = require("kpcrew.Addon.SOP.SOP")

ng_imgui_current_main_tab = 0
ng_imgui_main_wnd_width = 950
ng_imgui_main_wnd_height = 950
ng_weightunit = "KGS"
ng_kgslbs = 1

-- -----------------------------------------------------------------------------------------
-- draw the Briefing main window
function ng_draw_main_window()

	if ng_getAppPrefs():get("general:weightunit") == 1 then 
		ng_weightunit = "KGS"
		nk_kgslbs = (ng_getBriefPrefs():get("general:sbweightunit") == "kgs" and 1 or 1/2.20462262) 
	else 
		ng_weightunit = "LBS"
		ng_kgslbs = (ng_getBriefPrefs():get("general:sbweightunit") == "kgs" and 2.20462262 or 1)
	end
	
-- -----------------------------------------------------------------------------------------
-- draw the Status block
	local function render_status_block()

		-- Load latest simbrief flight plan
		ng_imgui_in_button("SIMBRIEF", "SIMBRIEF", 70*kb_font_scale, 20*kb_font_scale, 
			function () ng_download_simbrief() ng_load_simbrief() end)

		imgui.SameLine()
		ng_imgui_in_button("loadbrief", "LOAD", 70*kb_font_scale, 20*kb_font_scale, 
			function () ng_getBriefPrefs():load() end)

		imgui.SameLine()
		ng_imgui_in_button("savebrief","SAVE", 70*kb_font_scale, 20*kb_font_scale,
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

		ng_imgui_out_text(color_green,"Position:",color_white,kc_convertDMS(get("sim/flightmodel/position/latitude"),get("sim/flightmodel/position/longitude")) .. "/" ..
				kc_convertINS(get("sim/flightmodel/position/latitude"),get("sim/flightmodel/position/longitude")))

		imgui.SameLine()
		ng_imgui_out_text(color_green, "| Elevation:", color_white, 
			string.format("%6.0f ft\n",get("sim/cockpit2/autopilot/altitude_readout_preselector")))
			
		imgui.SameLine()
		ng_imgui_out_text(color_green, "| Time:", color_white, 
			kc_dispTimeFull(get("sim/time/zulu_time_sec")) .. "Z / " .. kc_dispTimeFull(get("sim/time/local_time_sec")))

		imgui.SameLine()
		ng_imgui_out_text(color_green, "Date:", color_white, 
			string.upper(os.date("%d.%m.%Y",ng_getBriefPrefs():get("times:schedout"))))

		imgui.Separator()
		
		-- ---------------------------------------------------------------------------------------
		-- Flight Times: Off Blocks: S ==:== C | Out: S ==:== C | In: S ==:== C | On Blocks: S ==:== C RST
		-- ---------------------------------------------------------------------------------------
		ng_imgui_out_text(color_white,"Flight times:")
		imgui.SameLine()
		ng_imgui_in_lbutton("outtime:", "S", 15*kb_font_scale, 20*kb_font_scale, "OUT:", color_white,
			function () ng_getBckVars():set("general:timeout",kc_dispTimeHHMM(get("sim/time/zulu_time_sec"))) end)
		imgui.SameLine()
		ng_imgui_in_lbutton("outclear:", "C", 15*kb_font_scale, 20*kb_font_scale, ng_getBckVars():get("general:timeout"), color_yellow,
			function () ng_getBckVars():set("general:timeout","==:==") end)

			imgui.SameLine()
			ng_imgui_in_lbutton("offtime:", "S", 15*kb_font_scale, 20*kb_font_scale, "OFF:", color_white,
				function () ng_getBckVars():set("general:timeoff",kc_dispTimeHHMM(get("sim/time/zulu_time_sec"))) end)
			imgui.SameLine()
			ng_imgui_in_lbutton("offclear:", "C", 15*kb_font_scale, 20*kb_font_scale, ng_getBckVars():get("general:timeoff"), color_yellow,
				function () ng_getBckVars():set("general:timeoff","==:==") end)

			imgui.SameLine()
			ng_imgui_in_lbutton("intime:", "S", 15*kb_font_scale, 20*kb_font_scale, "IN:", color_white,
				function () ng_getBckVars():set("general:timein",kc_dispTimeHHMM(get("sim/time/zulu_time_sec"))) end)
			imgui.SameLine()
			ng_imgui_in_lbutton("inclear:", "C", 15*kb_font_scale, 20*kb_font_scale, ng_getBckVars():get("general:timein"), color_yellow,
				function () ng_getBckVars():set("general:timein","==:==") end)

			imgui.SameLine()
			ng_imgui_in_lbutton("ontime:", "S", 15*kb_font_scale, 20*kb_font_scale, "ON:", color_white,
				function () ng_getBckVars():set("general:timeon",kc_dispTimeHHMM(get("sim/time/zulu_time_sec"))) end)
			imgui.SameLine()
			ng_imgui_in_lbutton("onclear:", "C", 15*kb_font_scale, 20*kb_font_scale, ng_getBckVars():get("general:timeon"), color_yellow,
				function () ng_getBckVars():set("general:timeon","==:==") end)

			imgui.SameLine()
			ng_imgui_in_button("allclear:", "RESET", 50*kb_font_scale, 20*kb_font_scale, 
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
		ng_imgui_in_tfield("Flight Number", 70*kb_font_scale, color_orange, 8, 
			ng_getBriefPrefs():get("general:callsign"), function (textout) ng_getBriefPrefs():set("general:callsign",textout) end)

		imgui.SameLine()
		ng_imgui_in_ltfield("*Origin ICAO:", 38*kb_font_scale, color_orange, 5, "Departure:", color_white,
			ng_getBriefPrefs():get("origin:icao"), function (textout) ng_getBriefPrefs():set("origin:icao",textout) end)
		imgui.SameLine()
		ng_imgui_in_ltfield("*Origin name:", 123*kb_font_scale, color_white, 100, "/", color_white,
			ng_getBriefPrefs():get("origin:name"), function (textout) ng_getBriefPrefs():set("origin:name",textout) end)
		
		imgui.SameLine()
		ng_imgui_in_ltfield("*Destination ICAO:", 38*kb_font_scale, color_orange, 5, "Arrival:", color_white, 
			ng_getBriefPrefs():get("destination:icao"), function (textout) ng_getBriefPrefs():set("destination:icao",textout) end)
		imgui.SameLine()
		ng_imgui_in_ltfield("*Destination name:", 123*kb_font_scale, color_white, 100, "/", color_white,
			ng_getBriefPrefs():get("destination:name"), function (textout) ng_getBriefPrefs():set("destination:name",textout) end)
		
		imgui.SameLine()
		ng_imgui_in_ltfield("*Alternate ICAO:", 38*kb_font_scale, color_orange, 5, "Alternate:", color_white, 
			ng_getBriefPrefs():get("alternate:icao"), function (textout) ng_getBriefPrefs():set("alternate:icao",textout) end)
		imgui.SameLine()
		ng_imgui_in_ltfield("*Alternate name:", 123*kb_font_scale, color_white, 100, "/", color_white,
			ng_getBriefPrefs():get("alternate:name"), function (textout) ng_getBriefPrefs():set("alternate:name",textout) end)

		imgui.Separator()

		-- CRUISE: [altitude]/FLxxx Times: OUT: 9999Z OFF: 9999Z ON: 9999Z IN: 9999Z Block time: 9999Z Air time: 9999Z
		-- Distances Air: 9999 nm Ground: 9999 nm  Average Wind: 999/999 W/C: +999 ISA: -009 FF/h: 99999 kgs/lbs 
		-- --------------------------------------------------------------------------------------
		ng_imgui_out_text(color_white,"Cruise altitude (level):")
		imgui.SameLine()
		ng_imgui_in_intfield("calt", 45*kb_font_scale, color_orange, 0, ng_getBriefPrefs():get("general:cruisealtitude"), 
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
		ng_imgui_in_tfield("origicao:", 38*kb_font_scale, 0xFF1b9af8, 5, 
			ng_getBriefPrefs():get("origin:icao"),function (textin) ng_getBriefPrefs():get("origin:icao",textin) end)
		imgui.SameLine()
		ng_imgui_in_tfield("origrwy:", 25*kb_font_scale, 0xFF1b9af8, 3,  
			ng_getBriefPrefs():get("origin:planrwy"),function (textin) ng_getBriefPrefs():get("origin:planrwy",textin) end)
		imgui.SameLine()
		ng_imgui_in_tfield("Route:", 715*kb_font_scale, 0xFF1b9af8, 255,ng_getBriefPrefs():get("general:route"), 
		function (textin) ng_getBriefPrefs():get("general:route",textin) end)		
		imgui.SameLine()
		ng_imgui_in_tfield("desticao:", 38*kb_font_scale, 0xFF1b9af8, 5,  
			ng_getBriefPrefs():get("destination:icao"),function (textin) ng_getBriefPrefs():get("destination:icao",textin) end)
		imgui.SameLine()
		ng_imgui_in_tfield("destrwy:", 25*kb_font_scale, 0xFF1b9af8, 3, 
			ng_getBriefPrefs():get("destination:planrwy"),function (textin) ng_getBriefPrefs():get("destination:planrwy",textin) end)

		imgui.Separator()
		imgui.Separator()

	end

-- -----------------------------------------------------------------------------------------
-- draw the Planning section FUEL
	local function render_fuel_block()
	
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
-- draw the Planning section Weights
	local function render_weights_block()
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
-- draw the Planning section Times
	local function render_times_block()
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
-- draw Flight tab preflight planning
	local function render_preflight_planning()
		
		-- block with fuel information
		render_fuel_block()

		-- render block with weights
		render_weights_block()
		
		-- render times block
		render_times_block()
	end

-- -----------------------------------------------------------------------------------------
-- draw the Flight tab origin 
	local function render_preflight_origin()
		imgui.BeginTable("airport",2)
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
				ng_imgui_out_text(color_white,"BARO Q/A")
				imgui.TableNextColumn()
				ng_imgui_out_text(color_green, string.format("Q%04.0f",1*ng_getBriefPrefs():get("takeoff:altimeter") * 33.86548913).." / "..string.format("A%5.2f",ng_getBriefPrefs():get("takeoff:altimeter")))

				imgui.TableNextRow()
				imgui.TableNextColumn()
				ng_imgui_out_text(color_white,"SURFACE CONDITION")
				imgui.TableNextColumn()
				ng_imgui_out_text(color_green, string.upper(ng_getBriefPrefs():get("takeoff:surfacecond")))

			end
			
			imgui.TableNextRow()
			imgui.TableNextColumn()
			ng_imgui_out_text(color_white,"DEPARTURE TYPE")
			imgui.TableNextColumn()
			local splitTitle = ng_split(ng_getBriefPrefs():find("origin:deptype"):getTitle(),"|")
			ng_imgui_in_combolist("odeptype", splitTitle, ng_getBriefPrefs():get("origin:deptype"), 
				function (textin) ng_getBriefPrefs():set("origin:deptype",textin) end, ddwidth)
				
			imgui.TableNextRow()
			imgui.TableNextColumn()
			ng_imgui_out_text(color_white,"DEPARTURE")
			imgui.TableNextColumn()
			ng_imgui_in_tfield("Odeparture", ddwidth, color_white, 10, ng_getBriefPrefs():get("origin:sid"), 
				function (textout) ng_getBriefPrefs():set("origin:sid",textout) end )

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
			local splitTitle = ng_split(ng_getAcfPrefs():find("controls:toflaps"):getTitle(),"|")
			ng_imgui_in_combolist("oflaps", splitTitle, ng_indexOf(ng_flaps_idx,ng_getBriefPrefs():get("takeoff:selectedflaps")), 
				function (textin) ng_getBriefPrefs():set("takeoff:selectedflaps",ng_flaps_name[textin]) end, ddwidth)
				
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
			local splitTitle = ng_split(ng_getAcfPrefs():find("aice:takeoffaice"):getTitle(),"|")
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

		imgui.EndTable()
	end

-- -----------------------------------------------------------------------------------------
-- draw the Flight tab destination		
	local function render_preflight_destination() -- destination
		imgui.BeginTable("airport",2)
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
			
-- only show if TLR takeoff section is available
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
				ng_imgui_out_text(color_white,"BARO Q/A")
				imgui.TableNextColumn()
				ng_imgui_out_text(color_green, string.format("Q%04.0f",1*ng_getBriefPrefs():get("landing:altimeter") * 33.86548913).." / "..string.format("A%5.2f",ng_getBriefPrefs():get("landing:altimeter")))

				imgui.TableNextRow()
				imgui.TableNextColumn()
				ng_imgui_out_text(color_white,"SURFACE CONDITION")
				imgui.TableNextColumn()
				ng_imgui_out_text(color_green, string.upper(ng_getBriefPrefs():get("landing:surfacecond")))

			end
			
			imgui.TableNextRow()
			imgui.TableNextColumn()
			ng_imgui_out_text(color_white,"ARRIVAL TYPE")
			imgui.TableNextColumn()
			local splitTitle = ng_split(ng_getBriefPrefs():find("destination:arrtype"):getTitle(),"|")
			ng_imgui_in_combolist("darrtype", splitTitle, ng_getBriefPrefs():get("destination:arrtype"), 
				function (textin) ng_getBriefPrefs():set("destination:arrtype",textin) end, ddwidth)
				
			imgui.TableNextRow()
			imgui.TableNextColumn()
			ng_imgui_out_text(color_white,"ARRIVAL")
			imgui.TableNextColumn()
			ng_imgui_in_tfield("darrival", ddwidth, color_white, 10, ng_getBriefPrefs():get("destination:star"), 
				function (textout) ng_getBriefPrefs():set("destination:star",textout) end )

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
			local splitTitle = ng_split(ng_getAcfPrefs():find("controls:ldflaps"):getTitle(),"|")
			-- ng_imgui_in_combolist("dflaps", splitTitle, ng_indexOf(ng_flaps_idx,ng_getBriefPrefs():get("landing:selectedflaps")), 
				-- function (textin) ng_getBriefPrefs():set("landing:selectedflaps",ng_flaps_name[textin]) end, ddwidth)
				
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
			local splitTitle = ng_split(ng_getAcfPrefs():find("aice:landingaice"):getTitle(),"|")
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
	end
			
-- -----------------------------------------------------------------------------------------
-- draw the Flight tab  tab
	local function render_main_tab_flight()
		imgui.BeginChild("#tab0")
			local fstate = ng_getBckVars():get("general:flightstate")
			render_status_block()
			imgui.Columns(3,"preflightcols",true)
				imgui.BeginChild("preflightcol1")
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
				if fstate < 7 then
					render_preflight_origin()
				elseif fstate >= 7 and fstate <= 12 then
					render_preflight_destination()
				elseif fstate > 12 then
				end
				imgui.EndChild()
			imgui.NextColumn()
				imgui.BeginChild("preflightcol3")
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
-- draw the Full SOP  tab
	local function render_main_tab_sop()
		imgui.BeginChild("#tab2")
			ng_get_active_sop():render("f")
		imgui.EndChild()		
	end

-- -----------------------------------------------------------------------------------------
-- draw the Settings tab
	local function render_main_tab_settings()
		imgui.BeginChild("#tab3")
			imgui.Columns(2,"settings",true)
				imgui.BeginChild("prefcol1")
					ng_imgui_in_button("loadapp", "LOAD", 70*kb_font_scale, 20*kb_font_scale, 
						function () ng_getAppPrefs():load() end)

					imgui.SameLine()
					ng_imgui_in_button("savebapp","SAVE", 70*kb_font_scale, 20*kb_font_scale,
						function () ng_getAppPrefs():save() end)

					ng_getAppPrefs():render("tree")
				imgui.EndChild()
			imgui.NextColumn()
				imgui.BeginChild("prefcol2")
					ng_imgui_in_button("loadbrief", "LOAD", 70*kb_font_scale, 20*kb_font_scale, 
						function () ng_getAcfPrefs():load() end)
	
					imgui.SameLine()
					ng_imgui_in_button("savebrief","SAVE", 70*kb_font_scale, 20*kb_font_scale,
						function () ng_getAcfPrefs():save() end)
	
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
	
	if FLYWITHLUA == false then imgui.Begin("KPCrewNG " .. kc_VERSION) end

	local tabsDef = {[0]="Flight", [1]="Full SOP", [2]="Settings"}
	local tabsNumber = (#tabsDef+1)
	local tabsSize = kb_wnd_width / tabsNumber - 4
	
	imgui.BeginGroup()
		for i = 0,#tabsDef,1 do ng_imgui_draw_add_main_tab(i, tabsSize, tabsDef[i]) end
	imgui.EndGroup()
	
	imgui.BeginGroup()
	if     ng_imgui_current_main_tab == 0 then render_main_tab_flight()
	elseif ng_imgui_current_main_tab == 1 then render_main_tab_sop() 
	elseif ng_imgui_current_main_tab == 2 then render_main_tab_settings()
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
		imgui.SetNextWindowSize({470,(15 + 2 ) * 23 + 12 + 27})
		imgui.SetNextWindowPos({ng_scrn_width-480,ng_scrn_height-((15 + 2 ) * 23 + 12 + 77)})
	end

	if FLYWITHLUA == false then imgui.Begin(ng_get_active_sop():getTitle()) end
		ng_get_active_sop():render("i")
	if FLYWITHLUA == false then imgui.End() end
end

-- -----------------------------------------------------------------------------------------
-- drawing function forctrl window
function ng_draw_ctrl_window()
	if FLYWITHLUA then
		-- imgui.SetNextWindowSize(700,50)
		imgui.SetNextWindowPos(ng_scrn_width-705,ng_scrn_height-46)
	else
		imgui.SetNextWindowSize({700,50})
		imgui.SetNextWindowPos({ng_scrn_width-705,ng_scrn_height-46})
	end
	
	local sop = ng_get_active_sop()
	local flow = sop:getActiveFlow() 
	
	if FLYWITHLUA == false then imgui.Begin("Control Window") end
	
	ng_imgui_in_button("ctrlprev","<<", 20*kb_font_scale, 20*kb_font_scale,
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
	-- ng_imgui_out_text(color, "", color, outtext, 0, 0)
	imgui.PushStyleColor(imgui.constant.Col.Button, color_black)
		imgui.PushStyleColor(imgui.constant.Col.Text, outcolor)
			ng_imgui_in_button("outtext",outtext, 420*kb_font_scale, 20*kb_font_scale, function () end)
		imgui.PopStyleColor()
	imgui.PopStyleColor()	
	
	imgui.SameLine()
	ng_imgui_in_button("ctrlnext",">>", 20*kb_font_scale, 20*kb_font_scale,
		function () ng_next_flow() end)

	imgui.SameLine()
	ng_imgui_in_button("ctrlmaster","MASTER", 50*kb_font_scale, 20*kb_font_scale,
		function () ng_master_action() end)		
		
	imgui.SameLine()
	imgui.PushStyleColor(imgui.constant.Col.Button, color_red)
		ng_imgui_in_button("ctrlreset","RESET", 50*kb_font_scale, 20*kb_font_scale,
			function () sop:reset() end)		
	imgui.PopStyleColor()



	
	if FLYWITHLUA == false then imgui.End() end
end