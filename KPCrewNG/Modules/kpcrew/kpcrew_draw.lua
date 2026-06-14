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
local Systems 	= require("kpcrew.Addon.Systems.AddonSystems")

ng_imgui_current_main_tab = 0
ng_imgui_main_wnd_width = 960
ng_imgui_main_wnd_height = 950
ng_weightunit = "KGS"
ng_kgslbs = 1
ng_settings_icao = ng_acft_select(2)

ng_editor_system_title = ""
ng_editor_system_icao = ng_acft_select(2)
ng_editor_system_json = nil
ng_editor_system_newsystem = ""
ng_editor_system_newelement = ""
ng_editor_system_newelement2 = {}
ng_editor_system_error = ""
ng_editor_system_filter = ""
ng_editor_remove_element = false
ng_editor_remove_system = false
ng_editor_actions = { 
	undefined = { "", "chk", " "},
	dataref = { "", "on", "off", "tgl", "set", "chk", " "},
	onofftgl = { "", "on", "off", "tgl", "chk", " "},
	dialdref = { "", "up", "dn", "set", "chk", " "},
	dialcmd = { "", "up", "dn", "set", "chk", " "},
	custom = { "", "on", "off", "tgl", "set", "chk", " "}

}
ng_editor_types = { "", "dataref", "onofftgl", "dialdref", "dialcmd", "custom", "undefined", " " }

ng_editor_sop_title = ""
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
ng_editor_sop_flowcopy = nil
ng_editor_sop_flowcopyname = ""
ng_editor_sop_itemcopy = nil
ng_editor_sop_itemcopyname = ""
ng_editor_sop_error = ""
ng_editor_sop_filter = ""
ng_editor_sop_remove_flow = false
ng_editor_sop_remove_item = false
ng_editor_sop_remove_element = false

ng_preferences_error = ""

-- =========================================================================================
-- Main window rendering #mainwindow
-- =========================================================================================


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
-- Draw the Status block on top of briefing window #statusblock
	local function render_main_status()

		-- Load latest simbrief flight plan
		ng_imgui_in_button("SIMBRIEF", "SIMBRIEF", 70, 20, 
			function () ng_download_simbrief() ng_load_simbrief() end)

		imgui.SameLine()
		ng_imgui_in_button("loadbrief", "LOAD", 70, 20, 
			function () ng_getBriefPrefs():load() end)

		imgui.SameLine()
		ng_imgui_in_button("savebrief","SAVE", 70, 20,
			function () ng_getBriefPrefs():save() end)
			
		imgui.SameLine()
		ng_imgui_out_text(color_red, "Simbrief date/time generated: ", color_yellow, ng_getBriefPrefs():get("general:simbriefgentime"))

		imgui.SameLine()
		ng_imgui_out_text(color_white, "Current date/time: ", color_yellow, string.upper(os.date("%d.%m.%Y - %H:%M")))

		imgui.Separator()
		
		-- XP: vvvvvv Flight State: State of SOP Aircraft Type: type [XP ICAO: XXXX]
		-- ---------------------------------------------------------------------------------------
		ng_imgui_out_text(color_yellow,"XP:",color_white, ng_getBriefPrefs():get("general:simversion"))
		
		imgui.SameLine()
		ng_imgui_out_text(color_yellow, "Flight State:", color_white, 
			ng_flightphases[math.abs(ng_getBckVars():get("general:flightstate"))])

	    imgui.SameLine()
		ng_imgui_out_text(color_green, "Aircraft Type:", color_white, 
			ng_get_active_addon():getTitle() .. " - " .. ng_acf_icao .. " [XP ICAO: " .. PLANE_ICAO .. "] [SB ICAO: " .. ng_getBriefPrefs():get("general:acficao") .. "]")

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
		ng_imgui_in_tfield("Flight Number", 70, color_white, 8, 
			ng_getBriefPrefs():get("general:callsign"), function (textout) ng_getBriefPrefs():set("general:callsign",textout) end)

		imgui.SameLine()
		ng_imgui_in_ltfield("*Origin ICAO:", 38, color_white, 5, "Departure:", color_white,
			ng_getBriefPrefs():get("origin:icao"), function (textout) ng_getBriefPrefs():set("origin:icao",textout) end)
		imgui.SameLine()
		ng_imgui_in_ltfield("*Origin name:", 123, color_white, 100, "/", color_white,
			ng_getBriefPrefs():get("origin:name"), function (textout) ng_getBriefPrefs():set("origin:name",textout) end)
		
		imgui.SameLine()
		ng_imgui_in_ltfield("*Destination ICAO:", 38, color_white, 5, "Arrival:", color_white, 
			ng_getBriefPrefs():get("destination:icao"), function (textout) ng_getBriefPrefs():set("destination:icao",textout) end)
		imgui.SameLine()
		ng_imgui_in_ltfield("*Destination name:", 123, color_white, 100, "/", color_white,
			ng_getBriefPrefs():get("destination:name"), function (textout) ng_getBriefPrefs():set("destination:name",textout) end)
		
		imgui.SameLine()
		ng_imgui_in_ltfield("*Alternate ICAO:", 38, color_white, 5, "Alternate:", color_white, 
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
		ng_imgui_in_intfield("calt", 45, 0xFF1b9af8, 0, ng_getBriefPrefs():get("general:cruisealtitude"), 
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

-- -----------------------------------------------------------------------------------------
-- Flight modules display blocks #flightmodules
-- -----------------------------------------------------------------------------------------

-- -----------------------------------------------------------------------------------------
-- Draw the Planning section FUEL
	local function render_flight_fuel()

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
			ng_imgui_out_text(color_grey, string.format("%6.0f",ng_getBriefPrefs():get("fuel:enroute")*ng_kgslbs))
			imgui.TableNextColumn()
			ng_imgui_out_text(color_grey, os.date("!%H%M",ng_getBriefPrefs():get("times:estenroute")))

			imgui.TableNextRow()
			imgui.TableNextColumn()
			ng_imgui_out_text(color_white,"ALTERNATE")
			imgui.TableNextColumn()
			ng_imgui_out_text(color_grey, string.format("%6.0f",ng_getBriefPrefs():get("fuel:alternate")*ng_kgslbs))
			imgui.TableNextColumn()
			ng_imgui_out_text(color_grey, "")
			
			imgui.TableNextRow()
			imgui.TableNextColumn()
			ng_imgui_out_text(color_white,"FINAL RESERVE")
			imgui.TableNextColumn()
			ng_imgui_out_text(color_grey, string.format("%6.0f",ng_getBriefPrefs():get("fuel:alternate")*ng_kgslbs))
			imgui.TableNextColumn()
			ng_imgui_out_text(color_grey, os.date("!%H%M",ng_getBriefPrefs():get("times:reserve")))

			imgui.TableNextRow()
			imgui.TableNextColumn()
			ng_imgui_out_text(color_white,"TAXI FUEL")
			imgui.TableNextColumn()
			ng_imgui_out_text(color_grey, string.format("%6.0f",ng_getBriefPrefs():get("fuel:taxi")*ng_kgslbs))
			imgui.TableNextColumn()
			ng_imgui_out_text(color_grey, os.date("!%H%M",ng_getBriefPrefs():get("times:taxiout")))
			
			imgui.TableNextRow()
			imgui.TableNextColumn()
			ng_imgui_out_text(color_white,"MINIMUM BLOCK")
			imgui.TableNextColumn()
			ng_imgui_out_text(color_grey, string.format("%6.0f",ng_getBriefPrefs():get("fuel:mintakeoff")*ng_kgslbs))
			imgui.TableNextColumn()
			ng_imgui_out_text(color_grey, os.date("!%H%M",ng_getBriefPrefs():get("times:endurance")))

			imgui.TableNextRow()
			imgui.TableNextColumn()
			ng_imgui_out_text(color_white,"EXTRA FUEL")
			imgui.TableNextColumn()
			ng_imgui_out_text(color_grey, string.format("%6.0f",ng_getBriefPrefs():get("fuel:extra")*ng_kgslbs))
			imgui.TableNextColumn()
			ng_imgui_out_text(color_grey, os.date("!%H%M",ng_getBriefPrefs():get("times:extrafuel")))

			imgui.Separator()

			imgui.TableNextRow()
			imgui.TableNextColumn()
			ng_imgui_out_text(color_white,"PLAN BLOCK")
			imgui.TableNextColumn()
			ng_imgui_out_text(color_grey, string.format("%6.0f",ng_getBriefPrefs():get("fuel:plantakeoff")*ng_kgslbs))
			imgui.TableNextColumn()
			ng_imgui_out_text(color_grey, os.date("!%H%M",ng_getBriefPrefs():get("times:endurance")))
			
			imgui.Separator()
			imgui.Separator()

		imgui.EndTable()	
	
	end
-- -----------------------------------------------------------------------------------------

-- -----------------------------------------------------------------------------------------
-- Draw the Planning section Weights
	local function render_flight_weights()
	
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
			ng_imgui_out_text(color_grey, string.format("%6.0f",ng_getBriefPrefs():get("weights:estzfw")*ng_kgslbs))
			imgui.TableNextColumn()
			ng_imgui_out_text(color_grey, string.format("%6.0f MAX",ng_getBriefPrefs():get("weights:maxzfw")*ng_kgslbs))

			imgui.TableNextRow()
			imgui.TableNextColumn()
			ng_imgui_out_text(color_white,"EST TOW")
			imgui.TableNextColumn()
			ng_imgui_out_text(color_grey, string.format("%6.0f",ng_getBriefPrefs():get("weights:esttow")*ng_kgslbs))
			imgui.TableNextColumn()
			ng_imgui_out_text(color_grey, string.format("%6.0f MAX",ng_getBriefPrefs():get("weights:maxtow")*ng_kgslbs))

			imgui.TableNextRow()
			imgui.TableNextColumn()
			ng_imgui_out_text(color_white,"EST LDW")
			imgui.TableNextColumn()
			ng_imgui_out_text(color_grey, string.format("%6.0f",ng_getBriefPrefs():get("weights:estldw")*ng_kgslbs))
			imgui.TableNextColumn()
			ng_imgui_out_text(color_grey, string.format("%6.0f MAX",ng_getBriefPrefs():get("weights:maxldw")*ng_kgslbs))

			imgui.TableNextRow()
			imgui.TableNextColumn()
			ng_imgui_out_text(color_white,"EST LAND FUEL")
			imgui.TableNextColumn()
			ng_imgui_out_text(color_grey, string.format("%6.0f",ng_getBriefPrefs():get("fuel:planlanding")*ng_kgslbs))

			imgui.TableNextRow()
			imgui.TableNextColumn()
			ng_imgui_out_text(color_white,"CARGO WEIGHT")
			imgui.TableNextColumn()
			ng_imgui_out_text(color_grey, string.format("%6.0f",ng_getBriefPrefs():get("weights:cargo")*ng_kgslbs))
						
			imgui.TableNextRow()
			imgui.TableNextColumn()
			ng_imgui_out_text(color_white,"PAYLOAD")
			imgui.TableNextColumn()
			ng_imgui_out_text(color_grey, string.format("%6.0f",ng_getBriefPrefs():get("weights:payload")*ng_kgslbs))
			imgui.TableNextColumn()
			local pcolor = (ng_getBriefPrefs():get("weights:payload")*ng_kgslbs > ng_get_MaxPayload() and color_red or color_grey) 
			ng_imgui_out_text(pcolor, string.format("%6.0f MAX",ng_get_MaxPayload()))

			imgui.TableNextRow()
			imgui.TableNextColumn()
			ng_imgui_out_text(color_white,"FREIGHT ADDED")
			imgui.TableNextColumn()
			ng_imgui_out_text(color_grey, string.format("%6.0f",ng_getBriefPrefs():get("weights:freightadded")*ng_kgslbs))
						
			imgui.TableNextRow()
			imgui.TableNextColumn()
			ng_imgui_out_text(color_white,"PAX WGT/CNT")
			imgui.TableNextColumn()
			ng_imgui_out_text(color_grey, string.format("%6.0f / %3.0f", ng_getBriefPrefs():get("weights:paxweight")*ng_kgslbs, 
				ng_getBriefPrefs():get("weights:paxcount")))

			imgui.TableNextRow()
			imgui.TableNextColumn()
			ng_imgui_out_text(color_white,"BAG WGT/CNT")
			imgui.TableNextColumn()
			ng_imgui_out_text(color_grey, string.format("%6.0f / %3.0f",ng_getBriefPrefs():get("weights:bagweight")*ng_kgslbs, 
				ng_getBriefPrefs():get("weights:bagcount")))

			imgui.TableNextRow()
			imgui.TableNextColumn()
			ng_imgui_out_text(color_white,"DOW")
			imgui.TableNextColumn()
			ng_imgui_out_text(color_grey, string.format("%6.0f",ng_getBriefPrefs():get("weights:oew")*ng_kgslbs))
			imgui.TableNextColumn()
			ng_imgui_out_text(color_grey, string.format("%6.0f",ng_get_DOW()))
			
			imgui.TableNextRow()
			imgui.TableNextColumn()
			ng_imgui_out_text(color_white,"*BLOCK FUEL")
			imgui.TableNextColumn()
			ng_imgui_in_intfield("*BLOCK FUEL:", 50, color_white, 0, ng_getBriefPrefs():get("fuel:planramp")*ng_kgslbs, 
			function (textout) ng_getBriefPrefs():set("fuel:planramp",textout) end )
			imgui.TableNextColumn()
			ng_imgui_out_text(color_grey, string.format("%6.0f MAX",ng_getBriefPrefs():get("fuel:maxtanks")*ng_kgslbs))

			imgui.TableNextRow()
			imgui.TableNextColumn()
			ng_imgui_out_text(color_white,"ACT ZFW")
			imgui.TableNextColumn()
			ng_imgui_out_text(color_grey, string.format("%6.0f",ng_get_zfw()))
			imgui.TableNextColumn()
			ng_imgui_out_text(color_grey, string.format("%6.0f MAX",ng_getBriefPrefs():get("weights:maxzfw")*ng_kgslbs))

			imgui.TableNextRow()
			imgui.TableNextColumn()
			ng_imgui_out_text(color_white,"ACT WEIGHT")
			imgui.TableNextColumn()
			ng_imgui_out_text(color_grey, string.format("%6.0f",ng_get_gross_weight()))
			imgui.TableNextColumn()
			ng_imgui_out_text(color_grey, string.format("%6.0f MAX",ng_getBriefPrefs():get("weights:maxtow")*ng_kgslbs))
			
			imgui.Separator()

			imgui.TableNextRow()
			imgui.TableNextColumn()
			ng_imgui_out_text(color_white,"MAC CG")
			imgui.TableNextColumn()
			ng_imgui_out_text(color_grey, string.format("%6.2f",21.2)) --ng_getBriefPrefs():get("weights:paxweight")))
			
			imgui.Separator()
			imgui.Separator()
			
		imgui.EndTable()
	
	end
-- -----------------------------------------------------------------------------------------

-- -----------------------------------------------------------------------------------------
-- Draw the Planning section Times
	local function render_flight_times()
	
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
			ng_imgui_out_text(color_grey, os.date("!%H%M",ng_getBriefPrefs():get("times:estenroute")).." h")
			imgui.TableNextColumn()
			ng_imgui_out_text(color_grey, os.date("!%H%M",ng_getBriefPrefs():get("times:schedenroute")).." h")

			imgui.TableNextRow()
			imgui.TableNextColumn()
			ng_imgui_out_text(color_white,"OUT TIME")
			imgui.TableNextColumn()
			ng_imgui_out_text(color_grey, os.date("!%H%M",ng_getBriefPrefs():get("times:estout")).."Z")
			imgui.TableNextColumn()
			ng_imgui_out_text(color_grey, os.date("!%H%M",ng_getBriefPrefs():get("times:schedout")).."Z")

			imgui.TableNextRow()
			imgui.TableNextColumn()
			ng_imgui_out_text(color_white,"OFF TIME")
			imgui.TableNextColumn()
			ng_imgui_out_text(color_grey, os.date("!%H%M",ng_getBriefPrefs():get("times:estoff")).."Z")
			imgui.TableNextColumn()
			ng_imgui_out_text(color_grey, os.date("!%H%M",ng_getBriefPrefs():get("times:schedoff")).."Z")

			imgui.TableNextRow()
			imgui.TableNextColumn()
			ng_imgui_out_text(color_white,"ON TIME")
			imgui.TableNextColumn()
			ng_imgui_out_text(color_grey, os.date("!%H%M",ng_getBriefPrefs():get("times:eston")).."Z")
			imgui.TableNextColumn()
			ng_imgui_out_text(color_grey, os.date("!%H%M",ng_getBriefPrefs():get("times:schedon")).."Z")

			imgui.TableNextRow()
			imgui.TableNextColumn()
			ng_imgui_out_text(color_white,"IN TIME")
			imgui.TableNextColumn()
			ng_imgui_out_text(color_grey, os.date("!%H%M",ng_getBriefPrefs():get("times:estin")).."Z")
			imgui.TableNextColumn()
			ng_imgui_out_text(color_grey, os.date("!%H%M",ng_getBriefPrefs():get("times:schedin")).."Z")

			imgui.TableNextRow()
			imgui.TableNextColumn()
			ng_imgui_out_text(color_white,"BLOCK TIME")
			imgui.TableNextColumn()
			ng_imgui_out_text(color_grey, os.date("!%H%M",ng_getBriefPrefs():get("times:estblock")).." h")
			imgui.TableNextColumn()
			ng_imgui_out_text(color_grey, os.date("!%H%M",ng_getBriefPrefs():get("times:schedblock")).." h")

			imgui.TableNextRow()
			imgui.TableNextColumn()
			ng_imgui_out_text(color_white,"TAXI OUT TIME")
			imgui.TableNextColumn()
			ng_imgui_out_text(color_grey, os.date("!%H%M",ng_getBriefPrefs():get("times:taxiout")).." h")

			imgui.TableNextRow()
			imgui.TableNextColumn()
			ng_imgui_out_text(color_white,"TAXI IN TIME")
			imgui.TableNextColumn()
			ng_imgui_out_text(color_grey, os.date("!%H%M",ng_getBriefPrefs():get("times:taxiin")).." h")

			imgui.TableNextRow()
			imgui.TableNextColumn()
			ng_imgui_out_text(color_white,"RESERVE TIME")
			imgui.TableNextColumn()
			ng_imgui_out_text(color_grey, os.date("!%H%M",ng_getBriefPrefs():get("times:reserve")).." h")

			imgui.TableNextRow()
			imgui.TableNextColumn()
			ng_imgui_out_text(color_white,"ENDURANCE")
			imgui.TableNextColumn()
			ng_imgui_out_text(color_grey, os.date("!%H%M",ng_getBriefPrefs():get("times:endurance")).." h")

			imgui.TableNextRow()
			imgui.TableNextColumn()
			ng_imgui_out_text(color_white,"CONTINGENCY")
			imgui.TableNextColumn()
			ng_imgui_out_text(color_grey, os.date("!%H%M",ng_getBriefPrefs():get("times:contfuel")).." h")

			imgui.TableNextRow()
			imgui.TableNextColumn()
			ng_imgui_out_text(color_white,"EXTRA TIME")
			imgui.TableNextColumn()
			ng_imgui_out_text(color_grey, os.date("!%H%M",ng_getBriefPrefs():get("times:extrafuel")).." h")

		imgui.EndTable()
				
		imgui.Separator()
		imgui.Separator()
	end
-- -----------------------------------------------------------------------------------------
	
-- -----------------------------------------------------------------------------------------
-- Draw the Origin Airport information block
	local function render_flight_origin_info()

-- --------------------------------------------
-- ORIGIN					ICAO/NAME OF ARPT
-- --------------------------------------------
-- AIRPORT ELEVATION		9999 ft
-- TRANSITION ALT/LVL		99999 / FL99
-- METAR					METAR text....
-- [LD]
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
			ng_imgui_out_text(color_grey, ng_getBriefPrefs():get("origin:elevation").." ft")

			imgui.TableNextRow()
			imgui.TableNextColumn()
			ng_imgui_out_text(color_white,"TRANSITION ALT/LVL")
			imgui.TableNextColumn()
			ng_imgui_out_text(color_grey, ng_getBriefPrefs():get("origin:transalt").." / FL"..ng_getBriefPrefs():get("origin:translvl")/100)

			imgui.TableNextRow()
			imgui.TableNextColumn()
			ng_imgui_out_text(color_white,"METAR")  
			ng_imgui_in_button("ldoriginmetar", "LD", 20, 20, 
				function () 
					ng_getBriefPrefs():set("origin:metar",ng_get_xp_metar(ng_getBriefPrefs():get("origin:icao"))) 
					local qaltim = string.match(ng_getBriefPrefs():get("origin:metar"),"Q%d%d%d%d")
					local aaltim = string.match(ng_getBriefPrefs():get("origin:metar"),"A%d%d%d%d")
					if qaltim ~= nil then 
						ng_getBriefPrefs():set("takeoff:qaltimeter", string.sub(qaltim,2)) 
						ng_getBriefPrefs():set("takeoff:altimeter",(ng_getBriefPrefs():get("takeoff:qaltimeter") / 33.8639))
					end
					if aaltim ~= nil then 
						ng_getBriefPrefs():set("takeoff:altimeter", string.sub(aaltim,2,3).."."..string.sub(aaltim,4,5)) 
						ng_getBriefPrefs():set("takeoff:qaltimeter",(ng_getBriefPrefs():get("takeoff:altimeter") * 33.8639))
					end
					local wind = string.match(ng_getBriefPrefs():get("origin:metar"),"%d%d%d%d%dKT")
					if wind ~= nil then
						ng_getBriefPrefs():set("takeoff:windhdg", 0+string.sub(wind,1,3))
						ng_getBriefPrefs():set("takeoff:windspd", 0+string.sub(wind,4,5))
					end
					local temps = string.match(ng_getBriefPrefs():get("origin:metar"),"M%d%d/")
					if temps ~= nil then
						ng_getBriefPrefs():set("takeoff:temperature", 0-string.sub(temps,2,3))
					else
						local temps = string.match(ng_getBriefPrefs():get("origin:metar"),"%d%d/%d%d")
						if temps ~= nil then
							ng_getBriefPrefs():set("takeoff:temperature", 0+string.sub(temps,1,2))
						else
							local temps = string.match(ng_getBriefPrefs():get("origin:metar"),"%d%d/M")
							if temps ~= nil then
								ng_getBriefPrefs():set("takeoff:temperature", 0+string.sub(temps,1,2))
							end
						end
					end
					
				end)
			imgui.TableNextColumn()
			ng_imgui_out_text(color_grey, ng_getBriefPrefs():get("origin:metar"))

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
				-- build takeoff runway list
				local torwys = {""} for _, torwy in pairs(ng_briefing_to_rwys) do table.insert(torwys,torwy.identifier) end
				
				-- drop-down of runways with output function to change all runway related settings
				ng_imgui_in_combolist("orwys", torwys, ng_getBriefPrefs():get("origin:selectedrwy"), 
					function (textin) 
						-- change the takeoff runway related settings to the new runway
						ng_getBriefPrefs():set("origin:selectedrwy",textin) -- selectedrunway index to new index
						ng_getBriefPrefs():set("origin:planrwy",torwys[textin+1])
						
						-- takeoff flaps
						local splitTitle = ng_split(ng_getAcfPrefs():get("controls:toflapslbl"),"|")
						ng_getBriefPrefs():set("takeoff:selectedflaps",ng_indexOf(splitTitle,ng_briefing_to_rwys[textin].flap_setting)-1)

						-- takeoff thrust settings and flex temp
						if ng_getAcfPrefs():get("air:hastothrust") then
							local splitTitle = ng_split(ng_getAcfPrefs():get("engines:tothrust"),"|") 
							ng_getBriefPrefs():set("takeoff:selectedthrust",ng_indexOf(splitTitle,ng_briefing_to_rwys[textin].thrust_setting)-1) 
							ng_getBriefPrefs():set("takeoff:rwyflextemp",ng_briefing_to_rwys[textin].flex_temperature)
						end
						
						-- has engine bleeds
						if ng_getAcfPrefs():get("air:hasenginebleeds") then
							local splitTitle = ng_split(ng_getAcfPrefs():get("air:takeoffbleeds"),"|")
							ng_getBriefPrefs():set("takeoff:selectedbleed",ng_indexOf(splitTitle,ng_briefing_to_rwys[textin].bleed_setting)-1) 
						end 
						
						-- anti-ice settings
						local splitTitle = ng_split(ng_getAcfPrefs():get("aice:takeoffaice"),"|")
						if ng_briefing_to_rwys[textin].anti_ice_setting == "N/A" or ng_briefing_to_rwys[textin].anti_ice_setting == nil then 
							ng_briefing_to_rwys[textin].anti_ice_setting = "OFF"
						end
						ng_getBriefPrefs():set("takeoff:selectedaice",ng_indexOf(splitTitle,ng_briefing_to_rwys[textin].anti_ice_setting)-1)
						
						-- vspeeds
						ng_getBriefPrefs():set("takeoff:rwyv1",ng_briefing_to_rwys[textin].speeds_v1) 						
						ng_getBriefPrefs():set("takeoff:rwyvr",ng_briefing_to_rwys[textin].speeds_vr) 						
						ng_getBriefPrefs():set("takeoff:rwyv2",ng_briefing_to_rwys[textin].speeds_v2) 			
						
						-- initial heading runway
						ng_getBriefPrefs():set("takeoff:inithdg",ng_briefing_to_rwys[textin].magnetic_course)
						
					end, 
				ddwidth)
			else
				-- alternatively show planned runway as text field
				ng_imgui_in_tfield("orwy", ddwidth, color_white, 10, ng_getBriefPrefs():get("origin:planrwy"), 
					function (textout) ng_getBriefPrefs():set("origin:planrwy",textout) end )				
			end
-- -----------------------------------------------------------------------------------------
			
-- only show if TLR takeoff section is available
			if #ng_briefing_to_rwys > 0 then
			
				imgui.TableNextRow()
				imgui.TableNextColumn()
				ng_imgui_out_text(color_white,"LENGTH / TORA")
				imgui.TableNextColumn()
				ng_getBriefPrefs():set("takeoff:rwylength",ng_briefing_to_rwys[ng_getBriefPrefs():get("origin:selectedrwy")].length)
				ng_getBriefPrefs():set("takeoff:rwytora",ng_briefing_to_rwys[ng_getBriefPrefs():get("origin:selectedrwy")].length_tora)
				ng_imgui_out_text(color_grey, ng_getBriefPrefs():get("takeoff:rwylength").." ft / "..ng_getBriefPrefs():get("takeoff:rwytora").." ft")

				imgui.TableNextRow()
				imgui.TableNextColumn()
				ng_imgui_out_text(color_white,"RWY ELEVATION")
				imgui.TableNextColumn()
				ng_getBriefPrefs():set("takeoff:rwyelevation",ng_briefing_to_rwys[ng_getBriefPrefs():get("origin:selectedrwy")].elevation)
				ng_imgui_out_text(color_grey, ng_getBriefPrefs():get("takeoff:rwyelevation").." ft")

				imgui.TableNextRow()
				imgui.TableNextColumn()
				ng_imgui_out_text(color_white,"MAGNETIC COURSE")
				imgui.TableNextColumn()
				ng_getBriefPrefs():set("takeoff:rwycourse",ng_briefing_to_rwys[ng_getBriefPrefs():get("origin:selectedrwy")].magnetic_course)
				ng_imgui_out_text(color_grey, ng_getBriefPrefs():get("takeoff:rwycourse"))

				imgui.TableNextRow()
				imgui.TableNextColumn()
				ng_imgui_out_text(color_white,"HEAD / CROSS WIND")
				imgui.TableNextColumn()
				-- ng_getBriefPrefs():set("takeoff:rwyheadwind",ng_briefing_to_rwys[ng_getBriefPrefs():get("origin:selectedrwy")].headwind_component)
				-- ng_getBriefPrefs():set("takeoff:rwycrosswind",ng_briefing_to_rwys[ng_getBriefPrefs():get("origin:selectedrwy")].crosswind_component)
				-- ng_imgui_out_text(color_grey, ng_getBriefPrefs():get("takeoff:rwyheadwind").." kts / "..ng_getBriefPrefs():get("takeoff:rwycrosswind").." kts")
				ng_getBriefPrefs():set("takeoff:rwyheadwind",ng_calc_headwind_spd(ng_getBriefPrefs():get("takeoff:windhdg"),ng_getBriefPrefs():get("takeoff:windspd"),ng_getBriefPrefs():get("takeoff:rwycourse")))
				ng_getBriefPrefs():set("takeoff:rwycrosswind",ng_calc_crosswind_spd(ng_getBriefPrefs():get("takeoff:windhdg"),ng_getBriefPrefs():get("takeoff:windspd"),ng_getBriefPrefs():get("takeoff:rwycourse")))
				ng_imgui_out_text(color_grey, ng_getBriefPrefs():get("takeoff:rwyheadwind").." kts / "..ng_getBriefPrefs():get("takeoff:rwycrosswind").." kts")

				imgui.TableNextRow()
				imgui.TableNextColumn()
				ng_imgui_out_text(color_white,"WIND | TEMP")
				imgui.TableNextColumn()
				ng_imgui_out_text(color_grey, string.format("%03.0f",ng_getBriefPrefs():get("takeoff:windhdg")).."/"..string.format("%02.0f",ng_getBriefPrefs():get("takeoff:windspd")).." | "..ng_getBriefPrefs():get("takeoff:temperature").." C")

				imgui.TableNextRow()
				imgui.TableNextColumn()
				ng_imgui_out_text(color_white,"SURFACE CONDITION")
				imgui.TableNextColumn()
				local splitTitle = ng_split("|dry|wet","|")
				ng_imgui_in_combolist("osurfcond", splitTitle, ng_indexOf(splitTitle,ng_getBriefPrefs():get("takeoff:surfacecond"))-1, 
					function (textin) 
						ng_getBriefPrefs():set("takeoff:surfacecond",splitTitle[textin+1]) 
					end, ddwidth)

			end

		imgui.EndTable()
		imgui.Separator()
	
	end
-- -----------------------------------------------------------------------------------------

-- -----------------------------------------------------------------------------------------
-- Draw the Departure block
	local function render_flight_dep_info()

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
			ng_imgui_in_combolist("Odeptype", splitTitle, ng_getBriefPrefs():get("origin:deptype"), 
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

			if ng_getAcfPrefs():get("air:hastothrust") then
				imgui.TableNextRow()
				imgui.TableNextColumn()
				ng_imgui_out_text(color_white,"TAKEOFF THRUST")
				imgui.TableNextColumn()
				local splitTitle = ng_split(ng_getAcfPrefs():get("engines:tothrust"),"|")
				ng_imgui_in_combolist("othrust", splitTitle, ng_getBriefPrefs():get("takeoff:selectedthrust"), 
					function (textin) ng_getBriefPrefs():set("takeoff:selectedthrust",textin) end, ddwidth)
			end 

			if ng_getAcfPrefs():get("engines:hasflextemp") then 
				imgui.TableNextRow()
				imgui.TableNextColumn()
				ng_imgui_out_text(color_white,"TAKEOFF FLEX TEMP")
				imgui.TableNextColumn()
				ng_imgui_in_intfield("oflex", 30, color_white, 0, ng_getBriefPrefs():get("takeoff:rwyflextemp"), 
					function (textout) ng_getBriefPrefs():set("takeoff:rwyflextemp",textout) end )
			end		
				
			if ng_getAcfPrefs():get("air:hasenginebleeds") then
				imgui.TableNextRow()
				imgui.TableNextColumn()
				ng_imgui_out_text(color_white,"TAKEOFF BLEEDS")
				imgui.TableNextColumn()
				local splitTitle = ng_split(ng_getAcfPrefs():get("air:takeoffpacks"),"|")
				if ng_getBriefPrefs():get("takeoff:selectedpacks") == nil then ng_getBriefPrefs():set("takeoff:selectedpacks",1) end
				ng_imgui_in_combolist("opacks", splitTitle, ng_getBriefPrefs():get("takeoff:selectedpacks"), 
					function (textin) ng_getBriefPrefs():set("takeoff:selectedpacks",textin) end, ddwidth)
			end
			
			if ng_getAcfPrefs():get("air:haspacks") then
				imgui.TableNextRow()
				imgui.TableNextColumn()
				ng_imgui_out_text(color_white,"TAKEOFF PACKS")
				imgui.TableNextColumn()
				local splitTitle = ng_split(ng_getAcfPrefs():get("air:takeoffbleeds"),"|")
				ng_imgui_in_combolist("obleeds", splitTitle, ng_getBriefPrefs():get("takeoff:selectedbleed"), 
					function (textin) ng_getBriefPrefs():set("takeoff:selectedbleed",textin) end, ddwidth)
			end
			
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

-- -----------------------------------------------------------------------------------------
-- Draw the Origin Airport information block
	local function render_flight_destination_info()

-- --------------------------------------------
-- DESTINATION				ICAO/NAME OF ARPT
-- --------------------------------------------
-- AIRPORT ELEVATION		9999 ft
-- TRANSITION ALT/LVL		99999 / FL99
-- METAR					METAR text....
-- [LD]
-- LANDING RWY				[runway id v]
-- LENGTH / LDA				99999 ft / 99999 ft
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
			ng_imgui_out_text(color_grey, ng_getBriefPrefs():get("destination:elevation").." ft")

			imgui.TableNextRow()
			imgui.TableNextColumn()
			ng_imgui_out_text(color_white,"TRANSITION ALT/LVL")
			imgui.TableNextColumn()
			ng_imgui_out_text(color_grey, ng_getBriefPrefs():get("destination:transalt").." / FL"..ng_getBriefPrefs():get("destination:translvl")/100)

			imgui.TableNextRow()
			imgui.TableNextColumn()
			ng_imgui_out_text(color_white,"METAR")
			ng_imgui_in_button("lddestmetar", "LD", 20, 20, 
				function () 
					ng_getBriefPrefs():set("destination:metar",ng_get_xp_metar(ng_getBriefPrefs():get("destination:icao"))) 
					local qaltim = string.match(ng_getBriefPrefs():get("destination:metar"),"Q%d%d%d%d")
					local aaltim = string.match(ng_getBriefPrefs():get("destination:metar"),"A%d%d%d%d")
					if qaltim ~= nil then 
						ng_getBriefPrefs():set("landing:qaltimeter", string.sub(qaltim,2)) 
						ng_getBriefPrefs():set("landing:altimeter",(ng_getBriefPrefs():get("landing:qaltimeter") / 33.8639))
					end
					if aaltim ~= nil then 
						ng_getBriefPrefs():set("landing:altimeter", string.sub(aaltim,2,3).."."..string.sub(aaltim,4,5)) 
						ng_getBriefPrefs():set("landing:qaltimeter",(ng_getBriefPrefs():get("landing:altimeter") * 33.8639))
					end
					local wind = string.match(ng_getBriefPrefs():get("destination:metar"),"%d%d%d%d%dKT")
					if wind ~= nil then
						ng_getBriefPrefs():set("landing:windhdg", 0+string.sub(wind,1,3))
						ng_getBriefPrefs():set("landing:windspd", 0+string.sub(wind,4,5))
					end
					local temps = string.match(ng_getBriefPrefs():get("destination:metar"),"M%d%d/")
					if temps ~= nil then
						ng_getBriefPrefs():set("landing:temperature", 0-string.sub(temps,2,3))
					else
						local temps = string.match(ng_getBriefPrefs():get("destination:metar"),"%d%d/%d%d")
						if temps ~= nil then
							ng_getBriefPrefs():set("landing:temperature", 0+string.sub(temps,1,2))
						else
							local temps = string.match(ng_getBriefPrefs():get("destination:metar"),"%d%d/M")
							if temps ~= nil then
								ng_getBriefPrefs():set("landing:temperature", 0+string.sub(temps,1,2))
							end
						end
					end
				end)
			
			imgui.TableNextColumn()
			ng_imgui_out_text(color_grey, ng_getBriefPrefs():get("destination:metar"))

			imgui.TableNextRow()
			imgui.TableNextColumn()
			ng_imgui_out_text(color_white,"LANDING RWY")
			imgui.TableNextColumn()
			if #ng_briefing_ld_rwys > 0 then -- landing runways exist in sim
				
				local ldrwys = {""} for _, ldrwy in pairs(ng_briefing_ld_rwys) do table.insert(ldrwys,ldrwy.identifier) end
				ng_imgui_in_combolist("drwys", ldrwys, ng_getBriefPrefs():get("destination:selectedrwy"), 
					function 
						(textin) 
						ng_getBriefPrefs():set("destination:selectedrwy",textin) 
						ng_getBriefPrefs():set("destination:planrwy",ldrwys[textin+1])
						
						-- ng_getBriefPrefs():set("takeoff:rwyv2",ng_briefing_to_rwys[ng_getBriefPrefs():get("origin:selectedrwy")].speeds_v2) 						

					end, ddwidth)
			else
				ng_imgui_in_tfield("drwy", ddwidth, color_white, 10, ng_getBriefPrefs():get("destination:planrwy"), 
					function (textout) ng_getBriefPrefs():set("destination:planrwy",textout) end )				
			end
			
			if #ng_briefing_ld_rwys > 0 then
			
				imgui.TableNextRow()
				imgui.TableNextColumn()
				ng_imgui_out_text(color_white,"LENGTH / LDA")
				imgui.TableNextColumn()
				ng_getBriefPrefs():set("landing:rwylength",ng_briefing_ld_rwys[ng_getBriefPrefs():get("destination:selectedrwy")].length)
				ng_getBriefPrefs():set("landing:rwylda",ng_briefing_ld_rwys[ng_getBriefPrefs():get("destination:selectedrwy")].length_lda)
				ng_imgui_out_text(color_grey, ng_getBriefPrefs():get("landing:rwylength").." ft / "..ng_getBriefPrefs():get("landing:rwylda").." ft")

				imgui.TableNextRow()
				imgui.TableNextColumn()
				ng_imgui_out_text(color_white,"RWY ELEVATION")
				imgui.TableNextColumn()
				ng_getBriefPrefs():set("landing:rwyelevation",ng_briefing_ld_rwys[ng_getBriefPrefs():get("destination:selectedrwy")].elevation)
				ng_imgui_out_text(color_grey, ng_getBriefPrefs():get("landing:rwyelevation").." ft")

				imgui.TableNextRow()
				imgui.TableNextColumn()
				ng_imgui_out_text(color_white,"MAGNETIC COURSE")
				imgui.TableNextColumn()
				ng_getBriefPrefs():set("landing:rwycourse",ng_briefing_ld_rwys[ng_getBriefPrefs():get("destination:selectedrwy")].magnetic_course)
				ng_imgui_out_text(color_grey, ng_getBriefPrefs():get("landing:rwycourse"))

				imgui.TableNextRow()
				imgui.TableNextColumn()
				ng_imgui_out_text(color_white,"HEAD / CROSS WIND")
				imgui.TableNextColumn()
				ng_getBriefPrefs():set("landing:rwyheadwind",ng_calc_headwind_spd(ng_getBriefPrefs():get("landing:windhdg"),ng_getBriefPrefs():get("landing:windspd"),ng_getBriefPrefs():get("landing:rwycourse")))
				ng_getBriefPrefs():set("landing:rwycrosswind",ng_calc_crosswind_spd(ng_getBriefPrefs():get("landing:windhdg"),ng_getBriefPrefs():get("landing:windspd"),ng_getBriefPrefs():get("landing:rwycourse")))
				ng_imgui_out_text(color_grey, ng_getBriefPrefs():get("landing:rwyheadwind").." kts / "..ng_getBriefPrefs():get("landing:rwycrosswind").." kts")

				imgui.TableNextRow()
				imgui.TableNextColumn()
				ng_imgui_out_text(color_white,"WIND | TEMP")
				imgui.TableNextColumn()
				ng_imgui_out_text(color_grey, string.format("%03.0f",ng_getBriefPrefs():get("landing:windhdg")).."/"..string.format("%02.0f",ng_getBriefPrefs():get("landing:windspd")).." | "..ng_getBriefPrefs():get("landing:temperature").." C")

				imgui.TableNextRow()
				imgui.TableNextColumn()
				ng_imgui_out_text(color_white,"SURFACE CONDITION")
				imgui.TableNextColumn()
				local splitTitle = ng_split("|dry|wet","|")
				ng_imgui_in_combolist("osurfcond", splitTitle, ng_indexOf(splitTitle,ng_getBriefPrefs():get("landing:surfacecond"))-1, 
					function (textin) 
						ng_getBriefPrefs():set("landing:surfacecond",splitTitle[textin+1]) 
						
						local splitTitle = ng_split(ng_getAcfPrefs():get("controls:ldflapslbl"),"|")
						if ng_getBriefPrefs():get("landing:surfacecond") == "dry" then
							ng_getBriefPrefs():set("landing:selectedflaps",ng_indexOf(splitTitle,ng_getBriefPrefs():get("landing:dryflaps"))-1)
						else
							ng_getBriefPrefs():set("landing:selectedflaps",ng_indexOf(splitTitle,ng_getBriefPrefs():get("landing:wetflaps"))-1)
						end

						if ng_getAcfPrefs():get("general:hasautobrk") then 
							if ng_getBriefPrefs():get("landing:surfacecond") == "dry" then
								ng_getBriefPrefs():set("landing:selectedabrk",ng_indexOf(splitTitle,ng_getBriefPrefs():get("landing:drybrakes"))-1)
							else
								ng_getBriefPrefs():set("landing:selectedabrk",ng_indexOf(splitTitle,ng_getBriefPrefs():get("landing:wetbrakes"))-1)
							end
						end

						if ng_getBriefPrefs():get("landing:surfacecond") == "dry" then
							ng_getBriefPrefs():set("landing:rwyvref",ng_getBriefPrefs():get("landing:dryvref"))
							ng_getBriefPrefs():set("landing:rwyvapp",ng_getBriefPrefs():get("landing:dryvref")+5)
						else
							ng_getBriefPrefs():set("landing:rwyvref",ng_getBriefPrefs():get("landing:wetvref"))
							ng_getBriefPrefs():set("landing:rwyvapp",ng_getBriefPrefs():get("landing:wetvref")+5)
						end
						
					end, ddwidth)

				-- ng_imgui_out_text(color_grey, string.upper(ng_getBriefPrefs():get("landing:surfacecond")))

			end

		imgui.EndTable()
		imgui.Separator()
	
	end
-- -----------------------------------------------------------------------------------------

-- -----------------------------------------------------------------------------------------
-- draw the Flight tab destination		
	local function render_flight_arr_info() 

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
-- PARKING POSITION			[xxxx]
-- STAND TYPE				[type of stand v]
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
			ng_imgui_in_combolist("dflaps", splitTitle, ng_getBriefPrefs():get("landing:selectedflaps"), 
				function (textin) ng_getBriefPrefs():set("landing:selectedflaps",textin) end, ddwidth)

			if ng_getAcfPrefs():get("general:hasenginebleeds") then
				imgui.TableNextRow()
				imgui.TableNextColumn()
				ng_imgui_out_text(color_white,"LANDING BLEEDS")
				imgui.TableNextColumn()
				local splitTitle = ng_split(ng_getAcfPrefs():get("air:landingbleeds"),"|")
				ng_imgui_in_combolist("dbleeds", splitTitle, ng_getBriefPrefs():get("landing:selectedbleed"), 
					function (textin) ng_getBriefPrefs():set("landing:selectedbleed",textin) end, ddwidth)
			end
			
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
			ng_imgui_out_text(color_white,"DECISION HEIGHT/ALT")
			imgui.TableNextColumn()
			ng_imgui_in_intfield("ddh", 30, color_white, 0, ng_getBriefPrefs():get("landing:decisionheight"), 
				function (textout) ng_getBriefPrefs():set("landing:decisionheight",textout) end ) imgui.SameLine()
			ng_imgui_in_intfield("dda", 40, color_white, 0, ng_getBriefPrefs():get("landing:decisionalt"), 
				function (textout) ng_getBriefPrefs():set("landing:decisionalt",textout) end ) 
			
			imgui.TableNextRow()
			imgui.TableNextColumn()
			ng_imgui_out_text(color_white,"GO-AROUND HDG/ALT")
			imgui.TableNextColumn()
			ng_imgui_in_intfield("dgahdg", 30, color_white, 0, ng_getBriefPrefs():get("landing:gaheading"), 
				function (textout) ng_getBriefPrefs():set("landing:gaheading",textout) end ) imgui.SameLine()
			ng_imgui_in_intfield("dgaalt", 40, color_white, 0, ng_getBriefPrefs():get("landing:gaaltitude"), 
				function (textout) ng_getBriefPrefs():set("landing:gaaltitude",textout) end ) 

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
			
			imgui.TableNextRow()
			imgui.TableNextColumn()
			ng_imgui_out_text(color_white,"*BARO Q/A")
			imgui.TableNextColumn()
			ng_imgui_in_floatfield("lbaroq", 40, color_white, 0, "%04.0f",ng_getBriefPrefs():get("landing:qaltimeter"), 
				function (textout) ng_getBriefPrefs():set("landing:qaltimeter",textout) end ) imgui.SameLine()
			ng_imgui_in_button("lconvbaro", "<", 15, 20, 
				function () ng_getBriefPrefs():set("landing:qaltimeter",(ng_getBriefPrefs():get("landing:altimeter") * 33.8639)) end ) imgui.SameLine()
			ng_imgui_in_button("lconvbaro", ">", 15, 20, 
				function () ng_getBriefPrefs():set("landing:altimeter",(ng_getBriefPrefs():get("landing:qaltimeter") / 33.8639)) end ) imgui.SameLine()
			ng_imgui_in_floatfield("lbaroa", 40, color_white, 0, "%05.2f", ng_getBriefPrefs():get("landing:altimeter"), 
				function (textout) ng_getBriefPrefs():set("landing:altimeter",textout) end ) 

			
		imgui.EndTable()
		imgui.Separator()
	
	end
-- -----------------------------------------------------------------------------------------

-- -----------------------------------------------------------------------------------------
-- Draw the Alternate Airport information block
	local function render_flight_alt_info()

-- --------------------------------------------
-- ALTERNATE				ICAO/NAME OF ARPT
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

		imgui.BeginTable("alternateinfo",2)
		
			local ddwidth=146
			imgui.TableNextColumn()
			ng_imgui_out_text(color_yellow,"ALTERNATE")
			imgui.Separator()
			imgui.TableNextColumn()
			ng_imgui_out_text(color_yellow, ng_getBriefPrefs():get("alternate:icao").." / "..ng_getBriefPrefs():get("alternate:name"))		
			imgui.Separator()
			
			imgui.TableNextRow()
			imgui.TableNextColumn()
			ng_imgui_out_text(color_white,"AIRPORT ELEVATION")
			imgui.TableNextColumn()
			ng_imgui_out_text(color_grey, ng_getBriefPrefs():get("alternate:elevation").." ft")

			imgui.TableNextRow()
			imgui.TableNextColumn()
			ng_imgui_out_text(color_white,"TRANSITION ALT/LVL")
			imgui.TableNextColumn()
			ng_imgui_out_text(color_grey, ng_getBriefPrefs():get("alternate:transalt").." / FL"..ng_getBriefPrefs():get("alternate:translvl")/100)

			imgui.TableNextRow()
			imgui.TableNextColumn()
			ng_imgui_out_text(color_white,"METAR")
			ng_imgui_in_button("ldaltnmetar", "LD", 20, 20, 
				function () 
					ng_getBriefPrefs():set("alternate:metar",ng_get_xp_metar(ng_getBriefPrefs():get("alternate:icao"))) 
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
				end)
			
			imgui.TableNextColumn()
			ng_imgui_out_text(color_grey, ng_getBriefPrefs():get("alternate:metar"))

			imgui.TableNextRow()
			imgui.TableNextColumn()
			ng_imgui_out_text(color_white,"RUNWAY")
			imgui.TableNextColumn()
			ng_imgui_in_tfield("arwy", ddwidth, color_white, 10, ng_getBriefPrefs():get("alternate:planrwy"), 
				function (textout) ng_getBriefPrefs():set("alternate:planrwy",textout) end )				

			imgui.TableNextRow()
			imgui.TableNextColumn()
			ng_imgui_out_text(color_white,"WIND | TEMP")
			imgui.TableNextColumn()
			ng_imgui_out_text(color_grey, string.format("%03.0f",ng_getBriefPrefs():get("alternate:windhdg")).."/"..string.format("%02.0f",ng_getBriefPrefs():get("alternate:windspd")).." | "..ng_getBriefPrefs():get("alternate:temperature").." C")

			imgui.TableNextRow()
			imgui.TableNextColumn()
			ng_imgui_out_text(color_white,"HEAD / CROSS WIND")
			imgui.TableNextColumn()
			local rwyapphdg = 0
			if ng_getBriefPrefs():get("alternate:planrwy") ~= nil and string.len(ng_getBriefPrefs():get("alternate:planrwy")) >= 2 then
				rwyapphdg = string.match(ng_getBriefPrefs():get("alternate:planrwy"),"%d%d")+0*10
			end
			ng_getBriefPrefs():set("alternate:rwyheadwind",ng_calc_headwind_spd(ng_getBriefPrefs():get("alternate:windhdg"),ng_getBriefPrefs():get("alternate:windspd"),rwyapphdg))
			ng_getBriefPrefs():set("alternate:rwycrosswind",ng_calc_crosswind_spd(ng_getBriefPrefs():get("alternate:windhdg"),ng_getBriefPrefs():get("alternate:windspd"),rwyapphdg))
			ng_imgui_out_text(color_grey, ng_getBriefPrefs():get("alternate:rwyheadwind").." kts / "..ng_getBriefPrefs():get("alternate:rwycrosswind").." kts")

			imgui.TableNextRow()
			imgui.TableNextColumn()
			ng_imgui_out_text(color_white,"SURFACE CONDITION")
			imgui.TableNextColumn()
			local splitTitle = ng_split("|dry|wet","|")
			ng_imgui_in_combolist("asurfcond", splitTitle, ng_indexOf(splitTitle,ng_getBriefPrefs():get("alternate:surfacecond"))-1, 
					function (textin) ng_getBriefPrefs():set("alternate:surfacecond",splitTitle[textin+1]) end, ddwidth)

			imgui.TableNextRow()
			imgui.TableNextColumn()
			ng_imgui_out_text(color_white,"*BARO Q/A")
			imgui.TableNextColumn()
			ng_imgui_in_floatfield("abaroq", 40, color_white, 0, "%04.0f",ng_getBriefPrefs():get("alternate:qaltimeter"), 
				function (textout) ng_getBriefPrefs():set("alternate:qaltimeter",textout) end ) imgui.SameLine()
			ng_imgui_in_button("aconvbaro", "<", 15, 20, 
				function () ng_getBriefPrefs():set("alternate:qaltimeter",(ng_getBriefPrefs():get("alternate:altimeter") * 33.8639)) end ) imgui.SameLine()
			ng_imgui_in_button("aconvbaro", ">", 15, 20, 
				function () ng_getBriefPrefs():set("alternate:altimeter",(ng_getBriefPrefs():get("alternate:qaltimeter") / 33.8639)) end ) imgui.SameLine()
			ng_imgui_in_floatfield("abaroa", 40, color_white, 0, "%05.2f", ng_getBriefPrefs():get("alternate:altimeter"), 
				function (textout) ng_getBriefPrefs():set("alternate:altimeter",textout) end ) 

		imgui.EndTable()
		imgui.Separator()
	
	end
-- -----------------------------------------------------------------------------------------

-- -----------------------------------------------------------------------------------------
-- draw the threat based briefing tab
	local function render_briefing_departure() 

			ng_imgui_out_text(color_yellow,"DEPARTURE BRIEFING")
			imgui.Separator()
			ng_imgui_out_text(color_white,"[T]hreats (PM, PF)")
			ng_imgui_out_text(color_white,"[P]lan")
			ng_imgui_out_text(color_white,"  - Taxi, Departure Runway")
			ng_imgui_out_text(color_white,"  - Route (Clrnce, Flightplan, FMS XCHECK)")
			ng_imgui_out_text(color_white,"  - Return (Emergency, T/O alt)")
			ng_imgui_out_text(color_white,"  - Takeoff perf valid, perf/config issues")
			ng_imgui_out_text(color_white,"[C]onsiderations")
			imgui.Separator()
			imgui.BeginTable("departurebrief",3)
				imgui.TableNextColumn()
				imgui.TableNextColumn()
				ng_imgui_out_text(color_yellow,"THREATS")
				imgui.TableNextColumn()
				imgui.TableNextColumn()
				ng_imgui_out_text(color_yellow,"Airport/RWY")
				imgui.TableNextColumn()
				ng_imgui_out_text(color_yellow,"ATC")
				imgui.TableNextColumn()
				ng_imgui_out_text(color_yellow,"Aircraft")
				
				imgui.TableNextColumn()
				ng_imgui_out_text(color_white,"Contamination")
				imgui.TableNextColumn()
				ng_imgui_out_text(color_white,"Clnc/Re-Route")
				imgui.TableNextColumn()
				ng_imgui_out_text(color_white,"Systems")

				imgui.TableNextColumn()
				ng_imgui_out_text(color_white,"Construction")
				imgui.TableNextColumn()
				ng_imgui_out_text(color_white,"Arr/Dep amend")
				imgui.TableNextColumn()
				ng_imgui_out_text(color_white,"MELs")

				imgui.TableNextColumn()
				ng_imgui_out_text(color_white,"Hotspots")
				imgui.TableNextColumn()
				ng_imgui_out_text(color_white,"RWY Change")
				imgui.TableNextColumn()
				ng_imgui_out_text(color_white,"Automation")

				imgui.TableNextColumn()
				imgui.TableNextColumn()
				imgui.TableNextColumn()
				ng_imgui_out_text(color_white,"Performance")

				imgui.TableNextColumn()
				ng_imgui_out_text(color_yellow,"Adverse WX")
				imgui.TableNextColumn()
				ng_imgui_out_text(color_yellow,"OPS/Dispatch")
				imgui.TableNextColumn()
				ng_imgui_out_text(color_yellow,"Ground/Ramp")

				imgui.TableNextColumn()
				ng_imgui_out_text(color_white,"Visibility")
				imgui.TableNextColumn()
				ng_imgui_out_text(color_white,"Sched Press")
				imgui.TableNextColumn()
				ng_imgui_out_text(color_white,"Handling")

				imgui.TableNextColumn()
				ng_imgui_out_text(color_white,"Deicing")
				imgui.TableNextColumn()
				ng_imgui_out_text(color_white,"Delays")
				imgui.TableNextColumn()
				ng_imgui_out_text(color_white,"Congestion")

				imgui.TableNextColumn()
				ng_imgui_out_text(color_white,"Winds")
				imgui.TableNextColumn()
				ng_imgui_out_text(color_white,"Paperwork")
				imgui.TableNextColumn()
				ng_imgui_out_text(color_white,"Logbook")

				imgui.TableNextColumn()
				ng_imgui_out_text(color_white,"Precipitation")
				imgui.TableNextColumn()
				imgui.TableNextColumn()

				imgui.TableNextColumn()
				ng_imgui_out_text(color_yellow,"Environment")
				imgui.TableNextColumn()
				ng_imgui_out_text(color_yellow,"Physiology")
				imgui.TableNextColumn()
				ng_imgui_out_text(color_yellow,"Cabin")

				imgui.TableNextColumn()
				ng_imgui_out_text(color_white,"Terrain")
				imgui.TableNextColumn()
				ng_imgui_out_text(color_white,"Fatigue")
				imgui.TableNextColumn()
				ng_imgui_out_text(color_white,"Passengers")

				imgui.TableNextColumn()
				ng_imgui_out_text(color_white,"Night")
				imgui.TableNextColumn()
				ng_imgui_out_text(color_white,"Stress")
				imgui.TableNextColumn()
				ng_imgui_out_text(color_white,"Interruptions")

				imgui.TableNextColumn()
				ng_imgui_out_text(color_white,"Traffic")
				imgui.TableNextColumn()
				ng_imgui_out_text(color_white,"Hydration")
				imgui.TableNextColumn()

				imgui.TableNextColumn()
				imgui.TableNextColumn()
				ng_imgui_out_text(color_white,"Nutrition")
				imgui.TableNextColumn()

			imgui.EndTable()
		imgui.Separator()
	end
-- -----------------------------------------------------------------------------------------

-- -----------------------------------------------------------------------------------------
-- draw the threat based briefing tab
	local function render_briefing_arrival() 

		imgui.Separator()

			ng_imgui_out_text(color_yellow,"ARRIVAL BRIEFING")
			imgui.Separator()
			ng_imgui_out_text(color_white,"[T]hreats (PM, PF)")
			ng_imgui_out_text(color_white,"[P]lan")
			ng_imgui_out_text(color_white,"  - Route (STAR, Approach, M/A, Alt Fuel")
			ng_imgui_out_text(color_white,"  - Lnd RWY, Assessment, LTP, Exit, Taxi")
			ng_imgui_out_text(color_white,"  - Autobrakes, Reverse (if applicable)")
			ng_imgui_out_text(color_white,"  - Flaps, VREF, Target Speed")
			ng_imgui_out_text(color_white,"[C]onsiderations")
			imgui.Separator()
			imgui.BeginTable("arrivalbrief",3)
				imgui.TableNextColumn()
				imgui.TableNextColumn()
				ng_imgui_out_text(color_yellow,"THREATS")
				imgui.TableNextColumn()
				imgui.TableNextColumn()
				ng_imgui_out_text(color_yellow,"Airport/RWY")
				imgui.TableNextColumn()
				ng_imgui_out_text(color_yellow,"ATC")
				imgui.TableNextColumn()
				ng_imgui_out_text(color_yellow,"Aircraft")
				
				imgui.TableNextColumn()
				ng_imgui_out_text(color_white,"Contamination")
				imgui.TableNextColumn()
				ng_imgui_out_text(color_white,"Clnc/Re-Route")
				imgui.TableNextColumn()
				ng_imgui_out_text(color_white,"Systems")

				imgui.TableNextColumn()
				ng_imgui_out_text(color_white,"Construction")
				imgui.TableNextColumn()
				ng_imgui_out_text(color_white,"Arr/Dep amend")
				imgui.TableNextColumn()
				ng_imgui_out_text(color_white,"MELs")

				imgui.TableNextColumn()
				ng_imgui_out_text(color_white,"Hotspots")
				imgui.TableNextColumn()
				ng_imgui_out_text(color_white,"RWY Change")
				imgui.TableNextColumn()
				ng_imgui_out_text(color_white,"Automation")

				imgui.TableNextColumn()
				imgui.TableNextColumn()
				imgui.TableNextColumn()
				ng_imgui_out_text(color_white,"Performance")

				imgui.TableNextColumn()
				ng_imgui_out_text(color_yellow,"Adverse WX")
				imgui.TableNextColumn()
				ng_imgui_out_text(color_yellow,"OPS/Dispatch")
				imgui.TableNextColumn()
				ng_imgui_out_text(color_yellow,"Ground/Ramp")

				imgui.TableNextColumn()
				ng_imgui_out_text(color_white,"Visibility")
				imgui.TableNextColumn()
				ng_imgui_out_text(color_white,"Sched Press")
				imgui.TableNextColumn()
				ng_imgui_out_text(color_white,"Handling")

				imgui.TableNextColumn()
				ng_imgui_out_text(color_white,"Deicing")
				imgui.TableNextColumn()
				ng_imgui_out_text(color_white,"Delays")
				imgui.TableNextColumn()
				ng_imgui_out_text(color_white,"Congestion")

				imgui.TableNextColumn()
				ng_imgui_out_text(color_white,"Winds")
				imgui.TableNextColumn()
				ng_imgui_out_text(color_white,"Paperwork")
				imgui.TableNextColumn()
				ng_imgui_out_text(color_white,"Logbook")

				imgui.TableNextColumn()
				ng_imgui_out_text(color_white,"Precipitation")
				imgui.TableNextColumn()
				imgui.TableNextColumn()

				imgui.TableNextColumn()
				ng_imgui_out_text(color_yellow,"Environment")
				imgui.TableNextColumn()
				ng_imgui_out_text(color_yellow,"Physiology")
				imgui.TableNextColumn()
				ng_imgui_out_text(color_yellow,"Cabin")

				imgui.TableNextColumn()
				ng_imgui_out_text(color_white,"Terrain")
				imgui.TableNextColumn()
				ng_imgui_out_text(color_white,"Fatigue")
				imgui.TableNextColumn()
				ng_imgui_out_text(color_white,"Passengers")

				imgui.TableNextColumn()
				ng_imgui_out_text(color_white,"Night")
				imgui.TableNextColumn()
				ng_imgui_out_text(color_white,"Stress")
				imgui.TableNextColumn()
				ng_imgui_out_text(color_white,"Interruptions")

				imgui.TableNextColumn()
				ng_imgui_out_text(color_white,"Traffic")
				imgui.TableNextColumn()
				ng_imgui_out_text(color_white,"Hydration")
				imgui.TableNextColumn()

				imgui.TableNextColumn()
				imgui.TableNextColumn()
				ng_imgui_out_text(color_white,"Nutrition")
				imgui.TableNextColumn()

			imgui.EndTable()
		imgui.Separator()
	end
-- -----------------------------------------------------------------------------------------

-- -----------------------------------------------------------------------------------------
-- draw the threat based briefing tab
	local function render_briefing_flightstate() 
-- ----------------------------------------------
-- TIME OUT	HH:MM 	TIME OFF	HH:MM
-- TIME IN	HH:MM	TIME ON		HH:MM
-- -----
-- ACT ZFW	999999	ACT GROSS	999999
-- ACT FUEL	999999  -- FF/H
-------
-- AMB WIND	777/777	AMB TEMP	999
-- CURR ALT	999999  CURR SPEED	999 kts

			ng_imgui_out_text(color_yellow,"FLIGHT STATUS")
			imgui.Separator()
			imgui.BeginTable("flightstate",4)

				imgui.TableNextColumn()
				ng_imgui_out_text(color_white,"TIME OUT")
				imgui.TableNextColumn()
				ng_imgui_out_text(color_grey, ng_getBckVars():get("general:timeout"))
				imgui.TableNextColumn()
				ng_imgui_out_text(color_white,"TIME OFF")
				imgui.TableNextColumn()
				ng_imgui_out_text(color_grey, ng_getBckVars():get("general:timeoff"))
				imgui.TableNextColumn()
				ng_imgui_out_text(color_white,"TIME IN")
				imgui.TableNextColumn()
				ng_imgui_out_text(color_grey, ng_getBckVars():get("general:timein"))
				imgui.TableNextColumn()
				ng_imgui_out_text(color_white,"TIME ON")
				imgui.TableNextColumn()
				ng_imgui_out_text(color_grey, ng_getBckVars():get("general:timeon"))
			imgui.Separator()

				imgui.TableNextColumn()
				ng_imgui_out_text(color_white,"ACT ZFW")
				imgui.TableNextColumn()
				ng_imgui_out_text(color_yellow, string.format("%6.0f KG",get("sim/flightmodel/weight/m_total")-get("sim/flightmodel/weight/m_fuel_total")))
				imgui.TableNextColumn()
				ng_imgui_out_text(color_white,"ACT GROSS")
				imgui.TableNextColumn()
				ng_imgui_out_text(color_yellow, string.format("%6.0f KG",get("sim/flightmodel/weight/m_total")))
				
				imgui.TableNextColumn()
				ng_imgui_out_text(color_white,"ACT FUEL")
				imgui.TableNextColumn()
				ng_imgui_out_text(color_yellow, string.format("%6.0f KG",get("sim/flightmodel/weight/m_fuel_total")))
				imgui.TableNextColumn()
				ng_imgui_out_text(color_white,"FF KGS/H")
				imgui.TableNextColumn()
				ng_imgui_out_text(color_yellow,  string.format("%6.0f",get("sim/cockpit2/engine/indicators/fuel_flow_kg_sec",0)*3600))
			imgui.Separator()

				imgui.TableNextColumn()
				ng_imgui_out_text(color_white,"AMB WIND")
				imgui.TableNextColumn()
				ng_imgui_out_text(color_yellow, string.format("%03.0f/%02.0f",get("sim/weather/wind_direction_degt"),get("sim/weather/wind_speed_kt")))
				imgui.TableNextColumn()
				ng_imgui_out_text(color_white,"AMB TEMP")
				imgui.TableNextColumn()
				ng_imgui_out_text(color_yellow,  string.format("%4.1f C",get("sim/weather/temperature_ambient_c")))
			imgui.Separator()
				
				imgui.TableNextColumn()
				ng_imgui_out_text(color_white,"CURR ALT")
				imgui.TableNextColumn()
				ng_imgui_out_text(color_yellow, string.format("%6.0f",get("sim/flightmodel2/position/pressure_altitude")))
				imgui.TableNextColumn()
				ng_imgui_out_text(color_white,"GRND SPD")
				imgui.TableNextColumn()
				ng_imgui_out_text(color_yellow, string.format("%3.0f KTS",get("sim/flightmodel2/position/groundspeed")))
				

			imgui.EndTable()
		imgui.Separator()
	end
-- -----------------------------------------------------------------------------------------
	
-- -----------------------------------------------------------------------------------------
-- draw the Flight tab
	local function render_main_tab_flight()
		imgui.BeginChild("#tabmain")

			local fstate = ng_getBckVars():get("general:flightstate")
			render_main_status()

			imgui.Columns(3,"preflightcols",true)
				imgui.BeginChild("preflightcol1")
					
					-- change context depending on flight phase
					if fstate < 7 then
						render_flight_times()
						render_flight_fuel() 
						render_flight_weights() 
					elseif fstate >= 7 and fstate < 12 then
						render_flight_origin_info()
						render_flight_dep_info()
					elseif fstate >= 12 then
						render_flight_destination_info()
						render_flight_arr_info()
					end
				imgui.EndChild()
				
			imgui.NextColumn()
				
				imgui.BeginChild("preflightcol2")
					
					-- change context depending on flight phase
					if fstate < 7 then
						render_flight_origin_info()
						render_flight_dep_info()
					elseif fstate >= 7 and fstate < 12 then
						render_flight_times()
						render_flight_fuel() 
						render_briefing_flightstate()
					elseif fstate >= 12 then
						render_flight_times()
						render_flight_fuel() 
						render_briefing_flightstate()
					end
					
				imgui.EndChild()
				
			imgui.NextColumn()
			
				imgui.BeginChild("preflightcol3")
				
					-- change context depending on flight phase
					if fstate < 7 then
						render_flight_destination_info()
						render_briefing_departure()
					elseif fstate >= 7 and fstate < 12 then
						render_flight_destination_info()
						render_flight_alt_info()
					elseif fstate >= 12 then
						render_flight_alt_info()
						render_briefing_arrival()
					end
					
				imgui.EndChild()
			imgui.Columns()
		imgui.EndChild()		
	end
-- -----------------------------------------------------------------------------------------

-- -----------------------------------------------------------------------------------------
-- SOP / Systems Editor rendering
-- -----------------------------------------------------------------------------------------
-- draw the Full SOP tab
	local function render_main_tab_sop()
	
		imgui.BeginChild("#tab2")
			ng_get_active_sop():render("f")
		imgui.EndChild()		
		
	end
-- -----------------------------------------------------------------------------------------

-- -----------------------------------------------------------------------------------------
-- SOP / Systems Editor rendering
-- -----------------------------------------------------------------------------------------
-- draw the Editor tab

	local function render_main_tab_editor()
	
-- =========================================================================================
-- System Editor	
-- =========================================================================================

-- -----------------------------------------------------------------------------------------
-- render macros for system editor to reduce repeated code
-- -----------------------------------------------------------------------------------------

-- -----------------------------------------------------------------------------------------
--- draw a up/down buttons group
		local function sop_remove_buttons(label, what, item, nidx, width, flag)
			
			if flag == false then 
				imgui.PushStyleColor(imgui.constant.Col.Button, color_red)
					imgui.PushStyleColor(imgui.constant.Col.Text, color_black)
						ng_imgui_in_button(label.."del", "REMOVE "..what.." "..label, width, 20, 
							function () flag = true end) 
					imgui.PopStyleColor()
				imgui.PopStyleColor()
			else 
				imgui.PushStyleColor(imgui.constant.Col.Button, color_green)
					imgui.PushStyleColor(imgui.constant.Col.Text, color_black)
						ng_imgui_in_button(label.."yes", "YES ", width/2-2, 20, 
							function () table.remove(item, nidx) flag = false end) 
					imgui.PopStyleColor()
				imgui.PopStyleColor()
				imgui.SameLine()
				imgui.PushStyleColor(imgui.constant.Col.Button, color_red)
					imgui.PushStyleColor(imgui.constant.Col.Text, color_black)
						ng_imgui_in_button(label.."no", "NO ", width/2-2, 20, 
							function () flag = false end) 
					imgui.PopStyleColor()
				imgui.PopStyleColor()
			end
			return flag
		end
-- -----------------------------------------------------------------------------------------


-- -----------------------------------------------------------------------------------------
-- save & load & add new related logic
-- -----------------------------------------------------------------------------------------

-- -----------------------------------------------------------------------------------------
-- load system json with definitions of all systems
		local function systems_load()
			local path = SCRIPT_DIRECTORY.."../Modules/kpcrew/addons/"..ng_editor_system_icao.."_systems.json"
			if ng_editor_system_icao == "DFLT" then
				ng_editor_system_error = "DFLT not allowed - XXXX"
				-- return 
			end 
			if ng_file_exists(path) then
				local json = require "kpcrew.json"
				local file = io.open(path, "r")
				local jsonstr = ""
				for line in file:lines() do jsonstr = jsonstr .. line end
				file:close()
				ng_editor_system_json = json.parse(jsonstr)
				ng_editor_system_error = ""
			else
				ng_editor_system_error = "No file!"
			end
		end
-- -----------------------------------------------------------------------------------------
		
-- -----------------------------------------------------------------------------------------
-- save the edited system json 
		local function systems_save()
			local path = SCRIPT_DIRECTORY.."../Modules/kpcrew/addons/"..ng_editor_system_icao.."_systems.json"
			if ng_editor_system_icao == "DFLT" then 
				ng_editor_system_error = "DFLT not allowed - XXXX"
				-- return 
			end 
			local prettyprint = require ("kpcrew.json_pretty_print")
			local jsonout = prettyprint:pretty_print(ng_editor_system_json,nil,true)
			local filesystem = io.open(path, "w+")
			filesystem:write(jsonout)
			filesystem:close()
			ng_editor_system_error = ""
		end
-- -----------------------------------------------------------------------------------------

-- -----------------------------------------------------------------------------------------
-- add new system json based on DFLT
		local function systems_add(newicao)
			local newjson = SCRIPT_DIRECTORY.."../Modules/kpcrew/addons/"..newicao.."_systems.json"
			local dfltjson = SCRIPT_DIRECTORY.."../Modules/kpcrew/addons/DFLT_systems.json"
			-- ignore when already file exists
			if newicao == "DFLT" or ng_file_exists(newjson) then 
				ng_editor_system_error = "Exists!"
				return 
			end 
		
			-- read source DFLT
			local jsonin = require "kpcrew.json"
			local filein = io.open(dfltjson, "r")
			local jsonstrin = ""
			for line in filein:lines() do jsonstrin = jsonstrin .. line end
			filein:close()

			-- write to new
			local fileout = io.open(newjson, "w+")
			fileout:write(jsonstrin)
			fileout:close()
			ng_editor_system_error = ""
		end
-- -----------------------------------------------------------------------------------------

-- -----------------------------------------------------------------------------------------
-- appy current state to be active
		local function systems_apply()
			-- systems_save()
			local systems = Systems:new("Aircraft Systems",SCRIPT_DIRECTORY.."../Modules/kpcrew/addons/"..ng_editor_system_icao.."_systems.json")
			systems:load()
			ng_set_active_sys(systems)
			ng_editor_system_error = "Applied"
		end
-- -----------------------------------------------------------------------------------------

-- -----------------------------------------------------------------------------------------
-- render lowest level in systems hierarchy - individual elements
-- @param tablenode nelement current element node in system table
-- @param int ielement index of element node on parent systems table
-- @param tablenode nsystem parent system node for this element 
-- @param string category name
		local function systems_rnd_element(nelement, ielement, nsystem, category)

-- common part for all types
-- --------------------------------------------------------
-- name		| [                                           ]
-- type		| [<type list drop down>                     V]
-- title	| [                                           ]
-- dref		| [                                           ]
-- indx		| [                                     ][-][+]
-- acts		| [<act1 V][<act2 V][<act3 V][<act4 V][<act5 V]
-- check()	| [<code that returns true/false>             ]
-- trans()	| [<code that returns transformed value>      ]

			imgui.BeginGroup()
	
				imgui.Separator()
				
				local ename = nelement.name -- base name to use for imgui id 

-- name		| [                                           ]
				ng_imgui_out_text(color_white, "name") imgui.NextColumn()
				ng_imgui_in_tfield(ename.."name", 300, color_white, 255,  
					nelement.name, function (textout) nelement.name = textout end) imgui.NextColumn()

-- type		| [<type list drop down>                     V]
				ng_imgui_out_text(color_white, "type") imgui.NextColumn()
				if nelement.type ~= nil then
					ng_imgui_in_combolist(ename.."etype", ng_editor_types, ng_indexOf(ng_editor_types,nelement.type)-1, 
						function (textin) 
							nelement.type=ng_editor_types[textin+1]
							nelement.acts = nil
						end,
					300) imgui.NextColumn()
				else -- if empty draw the plus button
					nelement.type = "dataref" imgui.NextColumn()
				end
					
-- title	| [                                           ]				
				ng_imgui_out_text(color_white, "title") imgui.NextColumn()
				if nelement.title ~= nil then
					-- ng_imgui_in_button(ename.."niltitle", "-", 15, 20, 
						-- function () nelement.title = nil end) imgui.SameLine()
					if nelement.title ~= nil then
						ng_imgui_in_tfield(ename.."title", 300, color_white, 255,  
							nelement.title, function (textout) nelement.title = textout end) 
					end
					imgui.NextColumn()
				else
					nelement.title = "<title>"
				end
				
				if nelement.type ~= "undefined" then					
-- dref		| [                                           ]
					ng_imgui_out_text(color_white, "dref") imgui.NextColumn()
					if nelement.dref ~= nil then
						ng_imgui_in_button(ename.."nildref", "-", 15, 20, 
							function () nelement.dref = nil end) imgui.SameLine()
						if nelement.dref ~= nil then
							ng_imgui_in_tfield(ename.."dref", 278, color_white, 255,  
							nelement.dref, function (textout) nelement.dref = textout end) imgui.NextColumn()
						end
					else
						ng_imgui_in_button(ename.."adddref", "+", 15, 20, 
							function () nelement.dref = "" end) imgui.NextColumn()
					end
					
	-- indx		| [                                      ][-][+]
					ng_imgui_out_text(color_white, "indx") imgui.NextColumn()
					if nelement.indx ~= nil then
						ng_imgui_in_button(ename.."nilindx", "-", 15, 20, 
							function () nelement.indx = nil end) imgui.SameLine()
						if nelement.indx ~= nil then
							ng_imgui_in_intfield(ename.."indx", 278, color_white, 0, 
							nelement.indx, function (textout) if textout == -1 then 
								nelement.indx = nil else nelement.indx = textout end end) 
						end 
						imgui.NextColumn()
					else
						ng_imgui_in_button(ename.."addindx", "+", 15, 20, 
							function () nelement.indx = 0 end) imgui.NextColumn()
					end

	-- acts		| [<act1 V][<act2 V][<act3 V][<act4 V][<act5 V]
	-- up to 5 allowed actions for this element, blank action does nothing
					ng_imgui_out_text(color_white, "acts") imgui.NextColumn()
					
					if nelement.acts ~= nil then
						if #nelement.acts == 0 then for i=1,5 do nelement.acts[i] = " " end end
						if #nelement.acts > 0 then
							local lactions = ng_editor_actions[nelement.type]
							for nidx,nacts in pairs(nelement.acts) do 
								ng_imgui_in_combolist(ename.."acts"..nidx, lactions, ng_indexOf(lactions,nacts)-1, 
									function (textin) nelement.acts[nidx] = (lactions[textin+1] == " " and nil or lactions[textin+1]) end,54)
								if nidx < #nelement.acts then imgui.SameLine() end
							end
							for i=#nelement.acts+1,5,1 do
								imgui.SameLine()
								ng_imgui_in_combolist(ename.."nacts"..i, lactions, ng_indexOf(lactions," ")-1, 
									function (textin) nelement.acts[i] = lactions[textin] end,54)
							end
						
							imgui.NextColumn()
						end
					else
						ng_imgui_in_button(ename.."addacts", "+", 15, 20, 
							function () --", "dialdref", "dialcmd", "custom"
								if nelement.type == "dataref" then nelement.acts={"on","off","tgl","set","chk"} 
								elseif nelement.type == "onofftgl" then nelement.acts={"on","off","tgl","chk",""} 
								elseif nelement.type == "dialdref" then nelement.acts={"up","dn","set","chk",""} 
								elseif nelement.type == "dialcmd" then nelement.acts={"up","dn","chk","",""} 
								elseif nelement.type == "custom" then nelement.acts={"on","off","tgl","chk",""} 
								end
						end) imgui.NextColumn()					
					end

	-- check()	| [<code that returns true/false>             ]
	-- sth like return get(\"dataref/key\") == 1" for example
					ng_imgui_out_text(color_white, "check()") imgui.NextColumn()
					if nelement.fcheck ~= nil then
						ng_imgui_in_button(ename.."nilfcheck", "-", 15, 20, 
							function () nelement.fcheck = nil end) imgui.SameLine()
						if nelement.fcheck ~= nil then
							ng_imgui_in_tfield(ename.."funccheck", 281, color_white, 255, 
							nelement.fcheck, function (textout) nelement.fcheck = textout end) 
						end
						imgui.NextColumn()
					else
						ng_imgui_in_button(ename.."addfcheck", "+", 15, 20, 
							function () nelement.fcheck = "function (a) return true end" end) imgui.NextColumn()
					end

	-- trans()	| [<code that returns a transformed value>             ]
	-- transform the dataref to allow for special cases (e.g. math.ceil() by values)
					ng_imgui_out_text(color_white, "trans()") imgui.NextColumn()
					if nelement.ftrans ~= nil then
						ng_imgui_in_button(ename.."niltrans", "-", 15, 20, 
							function () nelement.ftrans = nil end) imgui.SameLine()
						if nelement.ftrans ~= nil then
							ng_imgui_in_tfield(ename.."ftrans", 281, color_white, 255, 
							nelement.ftrans, function (textout) nelement.ftrans = textout end) 
						end
						imgui.NextColumn()
					else
						ng_imgui_in_button(ename.."addftrans", "+", 15, 20, 
							function () nelement.ftrans = "function (a) a=x end" end) imgui.NextColumn()
					end
				end
				
-- ========== type specific fields to be added to common part
-- toggle and onoff elements
				if nelement.type == "onofftgl" then
				
-- cmdoff	| [                                           ]
-- x-plane command id string to execute with command_once() to turn sth OFF
					ng_imgui_out_text(color_white, "cmdoff") imgui.NextColumn()
					if nelement.cmdoff ~= nil then
						ng_imgui_in_button(ename.."nilcmdoff", "-", 15, 20, 
							function () nelement.cmdoff = nil end) imgui.SameLine()
						if nelement.cmdoff ~= nil then
							ng_imgui_in_tfield(ename.."cmdoff", 281, color_white, 255,  
							nelement.cmdoff, function (textout) nelement.cmdoff = textout end) 
						end 
						imgui.NextColumn()
					else
						ng_imgui_in_button(ename.."addcmdoff", "+", 15, 20, 
							function () nelement.cmdoff = "" end) imgui.NextColumn()
					end
						
-- cmdon	| [                                           ]
-- x-plane command id string to execute with command_once() to turn sth ON
					ng_imgui_out_text(color_white, "cmdon") imgui.NextColumn()
					if nelement.cmdon ~= nil then
						ng_imgui_in_button(ename.."nilcmdon", "-", 15, 20, 
							function () nelement.cmdon = nil end) imgui.SameLine()
						if nelement.cmdon ~= nil then
							ng_imgui_in_tfield(ename.."cmdon", 281, color_white, 255,  
							nelement.cmdon, function (textout) nelement.cmdon = textout end) 
						end
						imgui.NextColumn()
					else
						ng_imgui_in_button(ename.."addcmdon", "+", 15, 20, 
							function () nelement.cmdon = "" end) imgui.NextColumn()
					end
						
-- cmdtgl	| [                                           ]
-- x-plane command id string to execute with command_once() to toggle the switch
					ng_imgui_out_text(color_white, "cmdtgl") imgui.NextColumn()
					if nelement.cmdtgl ~= nil then
						ng_imgui_in_button(ename.."nilcmdtgl", "-", 15, 20, 
							function () nelement.cmdtgl = nil end) imgui.SameLine()
						if nelement.cmdtgl ~= nil then
							ng_imgui_in_tfield(ename.."cmdtgl", 281, color_white, 255,  
							nelement.cmdtgl, function (textout) nelement.cmdtgl = textout end) 
						end
						imgui.NextColumn()
					else
						ng_imgui_in_button(ename.."addcmdtgl", "+", 15, 20, 
							function () nelement.cmdtgl = "" end) imgui.NextColumn()
					end

				end

				-- dial elements
				if nelement.type == "dialdref" or nelement.type == "dialcmd" then

-- min		| [                                      ][-][+]
-- minimal value to dial/set
					ng_imgui_out_text(color_white, "min") imgui.NextColumn()
					if nelement.min ~= nil then
						ng_imgui_in_button(ename.."nilmin", "-", 15, 20, 
							function () nelement.min = nil end) imgui.SameLine()
						if nelement.min ~= nil then
							ng_imgui_in_intfield(ename.."min", 281, color_white, 1,
							nelement.min, function (textout) nelement.min = textout end) 
						end
						imgui.NextColumn()
					else
						nelement.min = 0 imgui.NextColumn()
					end
					
-- max		| [                                      ][-][+]
-- maximal value to dial/set
					ng_imgui_out_text(color_white, "max") imgui.NextColumn()
					if nelement.max ~= nil then
						ng_imgui_in_button(ename.."nilmax", "-", 15, 20, 
							function () nelement.max = nil end) imgui.SameLine()
						if nelement.max ~= nil then
							ng_imgui_in_intfield(ename.."max", 281, color_white, 1, 
							nelement.max, function (textout) nelement.max = textout end) 
						end
						imgui.NextColumn()
					else
						nelement.max = 999 imgui.NextColumn()
					end
					
					-- only for dialdref
					if nelement.type == "dialdref" or nelement.type == "dialcmd"  then

-- incr		| [                                      ][-][+]
-- increment for each step up/down
						ng_imgui_out_text(color_white, "incr") imgui.NextColumn()
						if nelement.incr ~= nil then
							ng_imgui_in_button(ename.."nilincr", "-", 15, 20, 
								function () nelement.incr = nil end) imgui.SameLine()
							if nelement.incr ~= nil then
								ng_imgui_in_intfield(ename.."incr", 300, color_white, 1, 
								nelement.incr, function (textout) nelement.incr = textout end) 
							end
							imgui.NextColumn()
						else
							nelement.incr = 1 imgui.NextColumn()
						end
						
					end 

					-- only for dialcmd
					if nelement.type == "dialcmd" then

-- cmddn	| [                                           ]
-- x-plane command id string to execute with command_once() decrease the value
						ng_imgui_out_text(color_white, "cmddn") imgui.NextColumn()
						if nelement.cmddn ~= nil then
							ng_imgui_in_button(ename.."nilcmddn", "-", 15, 20, 
								function () nelement.cmddn = nil end) imgui.SameLine()
							if nelement.cmddn ~= nil then
								ng_imgui_in_tfield(ename.."cmddn", 300, color_white, 255,  
								nelement.cmddn, function (textout) nelement.cmddn = textout end) 
							end
							imgui.NextColumn()
						else
							ng_imgui_in_button(ename.."addcmddn", "+", 15, 20, 
								function () nelement.cmddn = "" end) imgui.NextColumn()
						end
					
-- cmdup	| [                                           ]
-- x-plane command id string to execute with command_once() increase the value
						ng_imgui_out_text(color_white, "cmdup") imgui.NextColumn()
						if nelement.cmdup ~= nil then
							ng_imgui_in_button(ename.."nilcmdup", "-", 15, 20, 
								function () nelement.cmdup = nil end) imgui.SameLine()
							if nelement.cmdup ~= nil then
								ng_imgui_in_tfield(ename.."cmdup", 300, color_white, 255,  
								nelement.cmdup, function (textout) nelement.cmdup = textout end) 
							end
							imgui.NextColumn()
						else
							ng_imgui_in_button(ename.."addcmdup", "+", 15, 20, 
								function () nelement.cmdup = "" end) imgui.NextColumn()
						end

					end
				end

-- custom elements
				if nelement.type == "custom" then

-- on()		| [                                           ]
-- function triggering actions to set a switch which is not simple 1/0 or commands
					ng_imgui_out_text(color_white, "on()") imgui.NextColumn()
					if nelement.fon ~= nil then
						ng_imgui_in_button(ename.."nilfuncon", "-", 15, 20, 
							function () nelement.fon = nil end) imgui.SameLine()
						if nelement.fon ~= nil then
							ng_imgui_in_tfield(ename.."funcon", 281, color_white, 255, 
							nelement.fon, function (textout) nelement.fon = textout end) 
						end
						imgui.NextColumn()
					else
						ng_imgui_in_button(ename.."addfuncon", "+", 15, 20, 
							function () nelement.fon = "function (a) return xx end" end) imgui.NextColumn()
					end
-- off()	| [                                           ]
-- function triggering actions to set a switch which is not simple 1/0 or commands
					ng_imgui_out_text(color_white, "off()") imgui.NextColumn()
					if nelement.foff ~= nil then
						ng_imgui_in_button(ename.."nilfuncoff", "-", 15, 20, 
							function () nelement.foff = nil end) imgui.SameLine()
						if nelement.foff ~= nil then
							ng_imgui_in_tfield(ename.."funcoff", 281, color_white, 255,  
							nelement.foff, function (textout) nelement.foff = textout end) 
						end
						imgui.NextColumn()
					else
						ng_imgui_in_button(ename.."addfuncoff", "+", 15, 20, 
							function () nelement.foff = "function (a) return xx end" end) imgui.NextColumn()
					end

-- tgl()	| [                                           ]
-- function triggering actions to set a switch which is not simple 1/0 or commands
					ng_imgui_out_text(color_white, "tgl()") imgui.NextColumn()
					if nelement.ftgl ~= nil then
						ng_imgui_in_button(ename.."nilfunctgl", "-", 15, 20, 
							function () nelement.ftgl = nil end) imgui.SameLine()
						if nelement.ftgl ~= nil then
							ng_imgui_in_tfield(ename.."ftgl", 281, color_white, 255, 
							nelement.ftgl, function (textout) nelement.ftgl = textout end) 
						end
						imgui.NextColumn()
					else
						ng_imgui_in_button(ename.."addfunctgl", "+", 15, 20, 
							function () nelement.ftgl = "function (a) return xx end" end) imgui.NextColumn()
					end
-- set()	| [                                           ]
-- function triggering actions to set a switch which is not simple 1/0 or commands
					ng_imgui_out_text(color_white, "set()") imgui.NextColumn()
					if nelement.fset ~= nil then
						ng_imgui_in_button(ename.."nilfset", "-", 15, 20, 
							function () nelement.fset = nil end) imgui.SameLine()
						if nelement.fset ~= nil then
							ng_imgui_in_tfield(ename.."fset", 281, color_white, 255, 
							nelement.fset, function (textout) nelement.fset = textout end) 
						end
						imgui.NextColumn()
					else
						ng_imgui_in_button(ename.."addfset", "+", 15, 20, 
							function () nelement.fset = "function (a) return xx end" end) imgui.NextColumn()
					end
					
				end
					
					imgui.NextColumn() imgui.NextColumn() imgui.NextColumn()
					ng_editor_remove_element = sop_remove_buttons(ename, "ELEMENT", nsystem.elements, ielement, 300, ng_editor_remove_element)

				-- end 				
				
				imgui.Separator()
				
			imgui.EndGroup()
		end
-- -----------------------------------------------------------------------------------------

-- -----------------------------------------------------------------------------------------
-- render the system level of systems
-- @param tablenode nsystem system with elements to render
-- @param int ielement index of system in parent table
-- @param tablenode ncategory parent category
		local function systems_rnd_system(nsystem, isystem, ncategory)
					
			local newelement = { name="" }
			
			local sname = nsystem.name

			if imgui.TreeNode(sname) then
				
				-- imgui.Separator()
				
				-- only show for custom category (others are fixed)
				-- if string.lower(ncategory.name) == "custom" then
					
					ng_editor_remove_system = sop_remove_buttons(sname, "SYSTEM", ncategory.systems, isystem, 375, ng_editor_remove_system)

					ng_imgui_in_button(sname.."append", "Append Element", 115, 20, 
						function () if ng_editor_system_newelement ~= "" then newelement.name=ng_editor_system_newelement
							table.insert (nsystem.elements, newelement) ng_editor_system_newelement = "" end end) 
					imgui.SameLine() ng_imgui_in_tfield(sname.."name", 250, color_white, 285, 
						ng_editor_system_newelement, function (textout) ng_editor_system_newelement = textout end)
						
				-- end

				local function compareNames(a, b)
					return a.name < b.name
				end

				table.sort(nsystem.elements, compareNames)												
				
				-- render elements of this system
				if nsystem.elements ~= nil then
					
					for ielement,nelement in ipairs(nsystem.elements) do
						imgui.Columns(2, nsystem.name, true)					
							imgui.SetColumnWidth(0, 65)
							imgui.SetColumnWidth(1, 400)
							systems_rnd_element(nelement,ielement,nsystem,ncategory.name)				
						imgui.Columns(1)
					end

				end
			imgui.TreePop() end
		end
-- -----------------------------------------------------------------------------------------

-- -----------------------------------------------------------------------------------------
-- render the system category
-- @param tablenode ncategory
		local function systems_rnd_category(ncategory)
		
			-- Append system
			local newsystem = { name="", elements={} }

			if imgui.TreeNode(ncategory.name) then

				-- if string.lower(ncategory.name) == "custom" then
					
					ng_imgui_in_button(ncategory.name.."append", "Append System", 190, 20, 
						function () if ng_editor_system_newsystem ~= "" then newsystem.name=ng_editor_system_newsystem
							table.insert (ncategory.systems, newsystem) ng_editor_system_newsystem = "" end end) 
					imgui.SameLine() ng_imgui_in_tfield(ncategory.name.."name", 200, color_white, 270, 
						ng_editor_system_newsystem, function (textout) ng_editor_system_newsystem = textout end)
						
				-- end

				local function compareNames(a, b)
					return a.name < b.name
				end

				table.sort(ncategory.systems, compareNames)
				for isystems,nsystems in ipairs(ncategory.systems) do
					systems_rnd_system(nsystems,isystems,ncategory)
				end
				
			imgui.TreePop() end
		end
-- -----------------------------------------------------------------------------------------
		
-- -----------------------------------------------------------------------------------------
-- draw the systems editor
		local function render_systems_editor()
			if ng_editor_system_json ~= nil then
				
				imgui.SetNextItemOpen(true)
				
				local function compareNames(a, b)
					return a.name < b.name
				end
				table.sort(ng_editor_system_json.addonsystems.categories, compareNames)

				if imgui.TreeNode(ng_editor_system_json.title) then
					for nidx,ncategory in pairs(ng_editor_system_json.addonsystems.categories) do
						systems_rnd_category(ncategory)
					end
				imgui.TreePop() end
				
			end
		end
-- -----------------------------------------------------------------------------------------

-- =========================================================================================
-- SOP Editor 	
-- =========================================================================================

-- -----------------------------------------------------------------------------------------
-- render macros for SOP editor to reduce repeated code
-- -----------------------------------------------------------------------------------------

-- -----------------------------------------------------------------------------------------
-- save & load & add new related logic
-- -----------------------------------------------------------------------------------------

-- -----------------------------------------------------------------------------------------
--- load SOP json with definitions of all flows
		local function sop_load()
			local path = SCRIPT_DIRECTORY.."../Modules/kpcrew/addons/"..ng_editor_sop_icao.."_sop.json"
			if ng_editor_sop_icao == "DFLT" then 
				ng_editor_sop_error = "DFLT not allowed - XXXX"
				-- return 
			end 
			if ng_file_exists(path) then
				local json = require "kpcrew.json"
				local file = io.open(path, "r")
				local jsonstr = ""
				for line in file:lines() do jsonstr = jsonstr .. line end
				file:close()
				ng_editor_sop_json = json.parse(jsonstr)
				ng_editor_sop_error = ""
			else
				ng_editor_sop_error = "No file!"
			end
		end
-- -----------------------------------------------------------------------------------------
		
-- -----------------------------------------------------------------------------------------
--- save edited SOP
		local function sop_save()
			local path = SCRIPT_DIRECTORY.."../Modules/kpcrew/addons/"..ng_editor_sop_icao.."_sop.json"
			if ng_editor_sop_icao == "DFLT" then 
				ng_editor_sop_error = "DFLT not allowed - XXXX"
				-- return 
			end 
			local prettyprint = require ("kpcrew.json_pretty_print")
			local jsonout = prettyprint:pretty_print(ng_editor_sop_json,nil,true)
			local filesystem = io.open(path, "w+")
			filesystem:write(jsonout)
			filesystem:close()
			ng_editor_sop_error = ""
		end
-- -----------------------------------------------------------------------------------------

-- -----------------------------------------------------------------------------------------
-- add new sop json based on DFLT
		local function sop_add(newicao)
			local newjson = SCRIPT_DIRECTORY.."../Modules/kpcrew/addons/"..newicao.."_sop.json"
			local dfltjson = SCRIPT_DIRECTORY.."../Modules/kpcrew/addons/DFLT_sop.json"
			-- ignore when already file exists
			if newicao == "DFLT" or ng_file_exists(newjson) then 
				ng_editor_sop_error = "Exists!"
				return 
			end 
		
			-- read source DFLT
			local jsonin = require "kpcrew.json"
			local filein = io.open(dfltjson, "r")
			local jsonstrin = ""
			for line in filein:lines() do jsonstrin = jsonstrin .. line end
			filein:close()

			-- write to new
			local fileout = io.open(newjson, "w+")
			fileout:write(jsonstrin)
			fileout:close()
			ng_editor_sop_error = ""

		end
-- -----------------------------------------------------------------------------------------

-- -----------------------------------------------------------------------------------------
--- apply edited SOP
		local function sop_apply()
			-- sop_save()
			local sop = SOP:new("SOP Default Aircraft",SCRIPT_DIRECTORY.."../Modules/kpcrew/addons/"..ng_editor_sop_icao.."_sop.json")
			sop:load()
			ng_set_active_sop(sop)
			ng_editor_sop_error = "Applied"
		end
-- -----------------------------------------------------------------------------------------

-- -----------------------------------------------------------------------------------------
--- draw a group to add a system element
		local function sop_add_system_element(label, nitem )
			
			-- Append item
			local newelement = {element="" }

			-- -----------------------------------------------------------
			-- [Add Element] [<all elements sorted> V] [<filter for list>]
			-- -----------------------------------------------------------
			ng_imgui_in_button(label.."append", "Add Element", 90, 20, 
				function () if ng_editor_sop_newelement ~= "" then newelement.element=ng_editor_sop_newelement table.insert (nitem.setelements, newelement) ng_editor_sop_newelement= "" end end) 

			-- prefill drop down beginning with element groups (#xxxx) followed by annunciators (_xxxx) 
			-- and then individual elements alphanumerically sorted
			local categnames = {""} -- load a list of category names
			
			for k,n in pairs(ng_get_active_sys().categories) do 
				for l,m in pairs(n.systems) do 
					table.insert(categnames, "#"..m.name) 
					for i,o in pairs(m.elements) do 
						table.insert(categnames, o.name) 
					end
				end
			end
			table.sort(categnames) -- sort alphabetically
			local catindx = ng_indexOf(categnames,ng_editor_sop_newelement)
			if catindx == nil then catindx = 1 end

			imgui.SameLine() ng_imgui_in_combosearch(label.."categs", categnames, catindx-1,
				function (textin) 
					catindx = textin+1
					ng_editor_sop_newelement = categnames[catindx]
					ng_editor_sop_filter = ""
				end,130,ng_editor_sop_filter)

			imgui.SameLine() ng_imgui_in_tfield(label.."filter", 140, color_white, 100, 
				ng_editor_sop_filter, function (textout) ng_editor_sop_filter = textout end)
	end
-- -----------------------------------------------------------------------------------------
	
-- -----------------------------------------------------------------------------------------
--- draw a expand/compress buttons group
		local function sop_compress_expand(label, colvar, expvar)
			
			-- [--][++]
	
			ng_imgui_in_button(label.."expand", "++", 23, 20, 
				function () colvar = 3 expvar = true end) 

			imgui.SameLine() ng_imgui_in_button(label.."compress", "--", 23, 20, 
				function () colvar = 3 expvar = false end) 
				
			return colvar, expvar
				
		end
-- -----------------------------------------------------------------------------------------

-- -----------------------------------------------------------------------------------------
--- COPY button for copy/paste mecganism
		local function sop_copy_button(label, item, copyvar, namevar)
			
			-- [COPY]
			imgui.SameLine() ng_imgui_in_button(label.."copy", "COPY", 40, 20, 
				function () copyvar = item namevar = "" end) 
	
			return copyvar, namevar
				
		end
-- -----------------------------------------------------------------------------------------

-- -----------------------------------------------------------------------------------------
--- draw a up/down buttons group
		local function sop_up_down(label, item, nidx)
			
			-- [UP][DN]
			ng_imgui_in_button(label.."up", "UP", 23, 20, 
				function () if nidx > 1 then 
					table.insert(item, nidx-1, table.remove(item, nidx)) end end) 

			imgui.SameLine() ng_imgui_in_button(label.."dn", "DN", 23, 20, 
				function () if nidx < #item then table.insert(item, nidx+1, table.remove(item, nidx)) end end) 
				
		end
-- -----------------------------------------------------------------------------------------
		
-- -----------------------------------------------------------------------------------------
--- render a flow item (step)
-- @param tablenode item node
-- @param int itemnode index
-- @param tablenode parent flow
		local function sop_rnd_flowitem(nitem, nidx, nflow)

			local itemclasses = { "", "ProcedureItem", "ChecklistItem" }
			local roles = { "", "ng_firole_PF", "ng_firole_PNF", "ng_firole_PM", "ng_firole_BOTH", 
				"ng_firole_FO", "ng_firole_CPT", "ng_firole_LHS", "ng_firole_RHS", "ng_firole_FE", 
				"ng_firole_CM1", "ng_firole_CM2", "ng_firole_CM3", "ng_firole_ALL", "ng_firole_SYS" }
			local actions = { "", "on", "off", "set", "tgl", "up", "dn", "funct", "chk", " "}
		
			local nlabel = nflow.title..nitem.challenge..nidx

			imgui.BeginGroup()
				
				-- imgui.Separator()
				
					if imgui.TreeNode(nidx.." "..nitem.challenge) then

						sop_up_down(nlabel, nflow.flowitem, nidx)
						
						-- put item in the copy buffer to paste in any flow
						imgui.SameLine() ng_editor_sop_itemcopy, ng_editor_sop_itemcopyname = 
							sop_copy_button(nlabel, nitem, ng_editor_sop_itemcopy, ng_editor_sop_itemcopyname)

						-- delete the item
						imgui.SameLine()
						ng_editor_sop_remove_item = sop_remove_buttons(nlabel, "ITEM", nflow.flowitem, nidx, 265, ng_editor_sop_remove_item)

						-- Class of item (Procedure or Checklist item)
						ng_imgui_out_text(color_white, "Class    :") imgui.SameLine()
						if nitem.classname ~= nil then
							ng_imgui_in_combolist(nlabel.."class", itemclasses, ng_indexOf(itemclasses,nitem.classname)-1, 
								function (textin) nitem.classname=itemclasses[textin+1] end,295)
						else
							nitem.classname = "ProcedureItem"
						end
						
						-- Response text
						ng_imgui_out_text(color_white, "Response :") imgui.SameLine()
						if nitem.response ~= nil then
							ng_imgui_in_tfield(nlabel.."response", 295, color_white, 255, 
							nitem.response, function (textout) nitem.response = string.upper(textout) end)
						else
							nitem.response = " " 
						end
						
						-- Role for this item
						ng_imgui_out_text(color_white, "Role     :") imgui.SameLine()
						if nitem.role ~= nil then
							ng_imgui_in_combolist(nlabel.."role", roles, ng_indexOf(roles,nitem.role)-1, 
								function (textin) nitem.role=roles[textin+1] end,295)
						else
							nitem.role = "ng_firole_FO"
						end
						
						-- Condition contains a "return <condition resulting in true/false>"
						-- if you want to override then set to "return true"
						ng_imgui_out_text(color_white, "Condition:") imgui.SameLine()
						if nitem.condition ~= nil then
							ng_imgui_in_button(nlabel.."removecond", "-", 15, 20, 
								function () nitem.condition = nil end) imgui.SameLine()
							if nitem.condition ~= nil then
								ng_imgui_in_tfield(nlabel.."condition", 273, color_white, 255, 
									nitem.condition, function (textout) nitem.condition = textout end)
							end
						else
							ng_imgui_in_button(nlabel.."addcond", "+", 15, 20, 
								function () nitem.condition = "true" end) 
						end
						
						-- if nocheck is set and 1 the item will not be checked during execution
						ng_imgui_out_text(color_white, "No check :") imgui.SameLine()
						if nitem.nocheck ~= nil then
							ng_imgui_in_button(nlabel.."removenchk", "-", 15, 20, 
								function () nitem.nocheck = nil end) imgui.SameLine()
							if nitem.nocheck ~= nil then
								ng_imgui_in_intfield(nlabel.."nchk", 273, color_white, 0,   
									nitem.nocheck, function (textout) if textout == "--" then nitem.nocheck = nil else nitem.nocheck = textout end end) 
							end
						else
							ng_imgui_in_button(nlabel.."addncheck", "+", 15, 20, 
								function () nitem.nocheck = 1 end) 
						end

						-- values > 0 will wait n seconds before the next step
						ng_imgui_out_text(color_white, "Delay    :") imgui.SameLine()
						if nitem.delay ~= nil then
							ng_imgui_in_button(nlabel.."removedelay", "-", 15, 20, 
								function () nitem.delay = nil end) imgui.SameLine()
							if nitem.delay ~= nil then
								ng_imgui_in_intfield(nlabel.."delay", 273, color_white, 1, 
								nitem.delay, function (textout) nitem.delay = textout end)
							end
						else
							ng_imgui_in_button(nlabel.."adddelay", "+", 15, 20, 
								function () nitem.delay = 0 end) 
						end
						
						-- now list used systems and system elements
						ng_imgui_out_text(color_white, "Systems used:") 

-- -----------------------------------------------------------
-- [Add Element] [<all elements sorted> V] [<filter for list>]
-- -----------------------------------------------------------

						sop_add_system_element(nlabel, nitem)

						-- render added systems or system elements
						if nitem.setelements ~= nil then 
							
							for eidx,nelement in ipairs(nitem.setelements) do

								if nelement.element ~= nil then
									if imgui.TreeNode(eidx.." "..nelement.element) then

										if ng_editor_sop_expcol3 > 0 then imgui.SetNextItemOpen(ng_editor_sop_expand3) end

										sop_up_down(nelement.element, nitem.setelements, eidx)
										
										-- remove the system/element from flowitem
										imgui.SameLine()
										ng_editor_sop_remove_element = sop_remove_buttons(nelement.element, "ELEMENT", nitem.setelements, eidx, 295, ng_editor_sop_remove_element)
										
										-- Selected action
										ng_imgui_out_text(color_white, "Action   :") imgui.SameLine()
										if nelement.action ~= nil then
											ng_imgui_in_combolist(nlabel..nelement.element.."act", actions, ng_indexOf(actions,nelement.action)-1, 
												function (textin) nelement.action=actions[textin+1] end, 280)
										else
											nelement.action = "chk"
										end
										
										-- direct value to set (no logic)
										ng_imgui_out_text(color_white, "Value    :") imgui.SameLine()
										if nelement.value ~= nil then
											ng_imgui_in_button(nlabel..nelement.element.."removeval", "-", 15, 20, 
												function () nelement.value = nil end) imgui.SameLine()
											if nelement.value ~= nil then
												ng_imgui_in_floatfield(nlabel..nelement.element.."val", 258, color_white, 0, "%7.2f",  
													nelement.value, function (textout) nelement.value = textout end) 
											end
										else
											ng_imgui_in_button(nlabel..nelement.element.."addval", "+", 15, 20, 
												function () nelement.value = 0 end) 
										end
										
										-- fvalue code to set the value with lua statetement "return <a resulting value>"
										-- will be used for actioning the step or check system/elements of the step
										ng_imgui_out_text(color_white, "value()  :") imgui.SameLine()
										if nelement.fvalue ~= nil then
											ng_imgui_in_button(nlabel..nelement.element.."removefvalue", "-", 15, 20, 
												function () nelement.fvalue = nil end) imgui.SameLine()
											if nelement.fvalue ~= nil then
												ng_imgui_in_tfield(nlabel..nelement.element.."fvalue", 258, color_white, 255, 
												nelement.fvalue, function (textout) nelement.fvalue = textout end)
											end
										else
											ng_imgui_in_button(nlabel..nelement.element.."addfvalue", "+", 15, 20, 
												function () nelement.fvalue = "return \"\"" end) 
										end
												
										-- fset code to set the value with lua statetement "<code to do complex logic>"
										ng_imgui_out_text(color_white, "set()    :") imgui.SameLine()
										if nelement.fset ~= nil then
											ng_imgui_in_button(nlabel..nelement.element.."removefset", "-", 15, 20, 
												function () nelement.fset = nil end) imgui.SameLine()
											if nelement.fset ~= nil then
												ng_imgui_in_tfield(nlabel..nelement.element.."fset", 258, color_white, 255, 
												nelement.fset, function (textout) nelement.fset = textout end)
											end
										else
											ng_imgui_in_button(nlabel..nelement.element.."addfset", "+", 15, 20, 
												function () nelement.fset = "return \"\"" end) 
										end
												
										-- Condition to enable or disable the system/element.
										ng_imgui_out_text(color_white, "Condition:") imgui.SameLine()
										if nelement.condition ~= nil then
											ng_imgui_in_button(nlabel..nelement.element.."removecond", "-", 15, 20, 
												function () nelement.condition = nil end) imgui.SameLine()
											if nelement.condition ~= nil then
												ng_imgui_in_tfield(nlabel..nelement.element.."cond", 258, color_white, 255, 
												nelement.condition, function (textout) nelement.condition = textout end)							
											end
										else
											ng_imgui_in_button(nlabel..nelement.element.."addcond", "+", 15, 20, 
												function () nelement.condition = "true" end) 
										end
																								
										-- no check, when 1 then ignore the system/element during checks. Set 0 to enable checks again
										ng_imgui_out_text(color_white, "No check :") imgui.SameLine()
										if nelement.nocheck ~= nil then
											ng_imgui_in_button(nlabel..nelement.element.."removenchk", "-", 15, 20, 
												function () nelement.nocheck = nil end) imgui.SameLine()
											if nelement.nocheck ~= nil then
												ng_imgui_in_intfield(nlabel..nelement.element.."nchk", 258, color_white, 0,   
													nelement.nocheck, function (textout) nelement.nocheck = textout end)
											end
										else
											ng_imgui_in_button(nlabel..nelement.element.."addnchk", "+", 15, 20, 
												function () nelement.nocheck = 1 end) 
										end
										
										-- fcheck code to check the element with code "return <true/false logic>"
										ng_imgui_out_text(color_white, "check()  :") imgui.SameLine()
										if nelement.fcheck ~= nil then
											ng_imgui_in_button(nlabel..nelement.element.."removefcheck", "-", 15, 20, 
												function () nelement.fcheck = nil end) imgui.SameLine()
											if nelement.fcheck ~= nil then
												ng_imgui_in_tfield(nlabel..nelement.element.."fcheck", 258, color_white, 255, 
												nelement.fcheck, function (textout) nelement.fcheck = textout end)
											end
										else
											ng_imgui_in_button(nlabel..nelement.element.."addfcheck", "+", 15, 20, 
												function () nelement.fcheck = "function (a) return true end" end) 
										end
									imgui.TreePop() end
								end
								imgui.Separator()
														
							end
						end

					imgui.TreePop() end
				
				imgui.Separator()
				
			imgui.EndGroup()
		end
-- -----------------------------------------------------------------------------------------
		
-- -----------------------------------------------------------------------------------------
--- render a flow in the editor
-- @param tablenode flow
-- @param int index of flow 
-- @param int numflows number of flows in sop
		local function sop_rnd_flow(nflow, nidx, numflows)

			local phases = { "", "ng_phase_flight_planning", "ng_phase_colddark", "ng_phase_prel_preflight", 
				"ng_phase_preflight", "ng_phase_before_start", "ng_phase_after_start", "ng_phase_taxi_rwy", 
				"ng_phase_before_takeoff", "ng_phase_takeoff", "ng_phase_after_takeoff", "ng_phase_climb", 
				"ng_phase_enroute", "ng_phase_descent", "ng_phase_arrival", "ng_phase_approach", "ng_phase_landing", 
				"ng_phase_go_around", "ng_phase_afterland", "ng_phase_taxi_stand", "ng_phase_shutdown", "ng_phase_turnaround" }

			local flowclasses = { "", "ProcedureFlow", "ChecklistFlow", "BackgroundFlow" }

			local ntitle = nidx.." "..nflow.title
			
			if imgui.TreeNode(nidx.." "..nflow.title) then
				
				imgui.Separator()

				ng_editor_sop_expcol2, ng_editor_sop_expand2 = sop_compress_expand(ntitle, ng_editor_sop_expcol2, ng_editor_sop_expand2)
				
				imgui.SameLine() sop_up_down(ntitle, ng_editor_sop_json.sop.flow, nidx)
				
				imgui.SameLine() ng_editor_sop_flowcopy, ng_editor_sop_flowcopyname = 
					sop_copy_button(ntitle, nflow, ng_editor_sop_flowcopy, ng_editor_sop_flowcopyname)

				
				-- remove a flow
				imgui.SameLine()
				ng_editor_sop_remove_flow = sop_remove_buttons(ntitle, "FLOW", ng_editor_sop_json.sop.flow, nidx, 225, ng_editor_sop_remove_flow)

				ng_imgui_out_text(color_white, "Phase:") imgui.SameLine()
				ng_imgui_in_combolist(ntitle.."phase", phases, ng_indexOf(phases,nflow.phase)-1, 
					function (textin) nflow.phase=phases[textin+1] end, 345)

				ng_imgui_out_text(color_white, "Class:") imgui.SameLine()
				ng_imgui_in_combolist(ntitle.."class", flowclasses, ng_indexOf(flowclasses,nflow.classname)-1, 
					function (textin) nflow.classname=flowclasses[textin+1] end, 345)

				-- Append item
				local newitem = {challenge="", setelements = {  } }

				if ng_editor_sop_itemcopy ~= nil then
					ng_imgui_in_button(ntitle.."paste", "PASTE", 50, 20, 
					function () 
						if ng_editor_sop_itemcopyname ~= "" then 
							local copy = ng_deep_copy(ng_editor_sop_itemcopy)
							copy.challenge=string.upper(ng_editor_sop_itemcopyname) 
							table.insert (nflow.flowitem, copy) 
							ng_editor_sop_itemcopyname = ""
							ng_editor_sop_itemcopy = nil
						end
					end)
					
					imgui.SameLine() ng_imgui_out_text(color_white,"Title:")
					imgui.SameLine() ng_imgui_in_tfield(ntitle.."pastename", 290, color_white, 255, 
						ng_editor_sop_itemcopyname,
						function (textout) 
							if textout == "--" then
								ng_editor_sop_itemcopy = nil
								ng_editor_sop_itemcopyname = "" 
							else
								ng_editor_sop_itemcopyname = textout 
							end
						end)
				end 

				ng_imgui_in_button(ntitle.."append", "Append Item", 90, 20, 
					function () if ng_editor_sop_newitem ~= "" then newitem.challenge=string.upper(ng_editor_sop_newitem) table.insert (nflow.flowitem, newitem) ng_editor_sop_newitem = "" end end) 

				imgui.SameLine() ng_imgui_in_tfield(ntitle.."name", 300, color_white, 255, 
					ng_editor_sop_newitem, function (textout) ng_editor_sop_newitem = textout end)

				imgui.Separator()

				for nitemidx,nitem in ipairs(nflow.flowitem) do
					if ng_editor_sop_expcol2 > 0 then imgui.SetNextItemOpen(ng_editor_sop_expand2) end
					sop_rnd_flowitem(nitem,nitemidx,nflow)
				end
				imgui.Separator()
			imgui.TreePop() end
		end
-- -----------------------------------------------------------------------------------------
	
-- -----------------------------------------------------------------------------------------
--- render the SOP editor
		local function render_sop_editor()
			if ng_editor_sop_json ~= nil then
				
				-- Loop through all flows
				if imgui.TreeNode(ng_editor_sop_json.sop.title) then
					
					-- Append flow
					local newflow = {title="", phase="ng_phase_colddark", classname="ProcedureFlow", flowitem={  } }

					if ng_editor_sop_flowcopy ~= nil then
						ng_imgui_in_button(ng_editor_sop_json.sop.title.."paste", "PASTE", 50, 20, 
						function () 
							if ng_editor_sop_flowcopyname ~= "" then 
								local copy = ng_deep_copy(ng_editor_sop_flowcopy)
								copy.title=string.upper(ng_editor_sop_flowcopyname) 
								table.insert (ng_editor_sop_json.sop.flow, copy) 
								ng_editor_sop_flowcopyname = ""
								ng_editor_sop_flowcopy = nil
							end
						end)
						
						imgui.SameLine() ng_imgui_out_text(color_white,"Title:")

						imgui.SameLine() ng_imgui_in_tfield(ng_editor_sop_json.sop.title.."pastename", 280, color_white, 255, 
							ng_editor_sop_flowcopyname, 
							function (textout) 
								if textout == "--" then
									ng_editor_sop_flowcopy = nil
									ng_editor_sop_flowcopyname = "" 
								else
									ng_editor_sop_flowcopyname = textout 
								end
							end)
					end 

					ng_imgui_in_button(ng_editor_sop_json.sop.title.."append", "Append Flow", 90, 20, 
						function () if ng_editor_sop_newflow ~= "" then newflow.title=string.upper(ng_editor_sop_newflow) table.insert (ng_editor_sop_json.sop.flow, newflow) ng_editor_sop_newflow = "" end end) 

					imgui.SameLine() ng_imgui_in_tfield(ng_editor_sop_json.sop.title.."name", 280, color_white, 255, 
						ng_editor_sop_newflow, function (textout) ng_editor_sop_newflow = textout end)

					for nidx,nflow in ipairs(ng_editor_sop_json.sop.flow) do
						sop_rnd_flow(nflow,nidx,#ng_editor_sop_json.sop.flow)
					end

				imgui.TreePop() end
			end
		end
-- -----------------------------------------------------------------------------------------
	
		imgui.BeginChild("#tab4")

			-- editor columns
			imgui.Columns(2,"editorh",true)
			
				if FLYWITHLUA then imgui.BeginChild("editcolh1",0,70) else imgui.BeginChild("editcolh1",{0,70}) end
				
					ng_imgui_out_text(color_yellow,"=================== AIRCRAFT SYSTEMS EDITOR ==================")
				
					-- ICAO for systems
					ng_imgui_in_tfield("Systems for", 40, color_white, 10, ng_editor_system_icao, 
						function (textout) ng_editor_system_icao = string.upper(textout) end)

					-- load and save button to save after changes or load again
					imgui.SameLine()
					ng_imgui_in_button("loadsys", "LOAD", 43, 20, 
						function () 
							systems_load()
							ng_editor_system_title = ng_editor_system_json.title
						end)

					imgui.SameLine()
					ng_imgui_in_button("savesys","SAVE", 43, 20,
						function () systems_save() end)
					
					imgui.SameLine()
					ng_imgui_in_button("addsys","ADD", 43, 20,
						function () systems_add(ng_editor_system_icao) end)

					imgui.SameLine()
					ng_imgui_in_button("applysys","APPLY", 43, 20,
						function () systems_apply() end)

					imgui.SameLine()
					ng_imgui_out_text(color_red,ng_editor_system_error)
					
					ng_imgui_in_button("setsysname","SET", 43, 20,
					function () ng_editor_system_json.title = ng_editor_system_title end)
					imgui.SameLine() 
					ng_imgui_in_tfield("sysedittitle", 250, color_white, 100, 
						ng_editor_system_title, function (textout) ng_editor_system_title = textout end)

					imgui.Separator()

				imgui.EndChild()
				
			imgui.NextColumn()
			
				-- right tab with aircraft preferences
				if FLYWITHLUA then imgui.BeginChild("editcolh2",0,70) else imgui.BeginChild("editcolh2",{0,70}) end
				
					ng_imgui_out_text(color_yellow,"========================== SOP EDITOR ========================")

					-- ICAO for systems
					ng_imgui_in_tfield("SOP for", 40, color_white, 10, ng_editor_sop_icao, 
						function (textout) ng_editor_sop_icao = string.upper(textout) end)

					-- load and save button to save after changes or load again
					imgui.SameLine()
					ng_imgui_in_button("loadsop", "LOAD", 50, 20, 
						function () sop_load() ng_editor_sop_title = ng_editor_sop_json.sop.title end)
	
					imgui.SameLine()
					ng_imgui_in_button("savesop","SAVE", 50, 20,
						function () sop_save() end)

					imgui.SameLine()
					ng_imgui_in_button("addsop","ADD", 50, 20,
						function () sop_add(ng_editor_sop_icao) end)

					imgui.SameLine()
					ng_imgui_in_button("applysop","APPLY", 50, 20,
						function () sop_apply() end)

					imgui.SameLine()
					ng_imgui_out_text(color_red,ng_editor_sop_error)

					ng_imgui_in_button("setsopname","SET", 43, 20,
						function () ng_editor_sop_json.sop.title = ng_editor_sop_title end)
					imgui.SameLine() 
					ng_imgui_in_tfield("sopedittitle", 250, color_white, 100, 
						ng_editor_sop_title, function (textout) ng_editor_sop_title = textout end)

					imgui.Separator()
						
				imgui.EndChild()
			imgui.Columns()

			imgui.Columns(2,"editorc",true)
				imgui.BeginChild("editcolc1")
				
					imgui.SetNextItemOpen(true)
					render_systems_editor()
					
				imgui.EndChild()
				
			imgui.NextColumn()
			
				-- right tab with aircraft preferences
				imgui.BeginChild("editcolc2")
										
					render_sop_editor()
					if ng_editor_sop_expcol1 > 0 then ng_editor_sop_expcol1 = ng_editor_sop_expcol1 - 1 end
					if ng_editor_sop_expcol2 > 0 then ng_editor_sop_expcol2 = ng_editor_sop_expcol2 - 1 end
					if ng_editor_sop_expcol3 > 0 then ng_editor_sop_expcol3 = ng_editor_sop_expcol3 - 1 end

				imgui.EndChild()
			imgui.Columns()

		imgui.EndChild()		
		
	end
-- -----------------------------------------------------------------------------------------

-- -----------------------------------------------------------------------------------------
-- add new preference based on DFLT
		local function prefs_add(newicao)
		
			local newprefs = SCRIPT_DIRECTORY.."../Modules/kpcrew_prefs/"..newicao..".preferences"
			local dfltprefs = SCRIPT_DIRECTORY.."../Modules/kpcrew_prefs/DFLT.preferences"
			-- ignore when already file exists
			if newicao == "DFLT" or ng_file_exists(newprefs) then 
				ng_preferences_error = "Exists!"
				return 
			end 
		
			-- read source DFLT
			local filein = io.open(dfltprefs, "r")
			local prefsin = ""
			for line in filein:lines() do prefsin = prefsin .. line .. "\n" end
			filein:close()

			-- write to new
			local fileout = io.open(newprefs, "w+")
			fileout:write(prefsin)
			fileout:close()
			ng_editor_system_error = ""
		end
-- -----------------------------------------------------------------------------------------

-- -----------------------------------------------------------------------------------------
-- draw the Settings tab
	local function render_main_tab_settings()
	
		imgui.BeginChild("#tab3")
		
			imgui.Columns(2,"settingsh",true)
			
				-- left tab with app preferences			
				if FLYWITHLUA then imgui.BeginChild("prefscolh1",0,50) else imgui.BeginChild("prefscolh1",{0,50}) end
				
					ng_imgui_out_text(color_yellow,"===================== APPLICATION SETTINGS ===================")
				
					-- load and save button to save after changes or load again
					ng_imgui_in_button("loadapp", "LOAD", 70, 20, 
						function () ng_getAppPrefs():load() end)

					imgui.SameLine()
					ng_imgui_in_button("savebapp","SAVE", 70, 20,
						function () ng_getAppPrefs():save() end)
					
					imgui.Separator()

				imgui.EndChild() -- prefscolh1
				
			imgui.NextColumn() -- settingsh

				if ng_getAppPrefs():get("general:developer") then
					-- right tab with aircraft preferences
					if FLYWITHLUA then imgui.BeginChild("prefscolh2",0,50) else imgui.BeginChild("prefscolh2",{0,50}) end
						
						ng_imgui_out_text(color_yellow,"====================== AIRCRAFT SETTINGS =====================")
					
						-- ICAO for preferences
						ng_imgui_in_tfield("Settings for", 50, color_white, 10, ng_settings_icao, 
							function (textout) 
								ng_settings_icao = string.upper(textout) 
								ng_getAcfPrefs():setFilePath(SCRIPT_DIRECTORY .."../Modules/kpcrew_prefs/"..ng_settings_icao..".preferences")
							end)

						-- load and save button to save after changes or load again
						imgui.SameLine()
						ng_imgui_in_button("loadprefs", "LOAD", 70, 20, 
							function () ng_getAcfPrefs():load() end)
		
						imgui.SameLine()
						ng_imgui_in_button("saveprefs","SAVE", 70, 20,
							function () ng_getAcfPrefs():save() end)

						imgui.SameLine()
						ng_imgui_in_button("addprefs","ADD", 70, 20,
							function () prefs_add(ng_settings_icao) end)

						imgui.SameLine()
						ng_imgui_out_text(color_red,ng_preferences_error)
								
						imgui.Separator()
							
					imgui.EndChild() -- prefscolh2
				end
			imgui.Columns() -- settingsh
			
			imgui.Columns(2,"settingsc",true)
				imgui.BeginChild("settingscolc1")
				
					-- render preferences tree
					imgui.SetNextItemOpen(true)
					ng_getAppPrefs():render("tree")	
					
				imgui.EndChild()
				
			imgui.NextColumn()
			
				if ng_getAppPrefs():get("general:developer") then
					imgui.BeginChild("settingscolc2")
											
						-- render aircraft preferences tree
						imgui.SetNextItemOpen(true)
						ng_getAcfPrefs():render("tree")

					imgui.EndChild()
				end
			imgui.Columns()
								
		imgui.EndChild() -- #tab3	

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
	
	if FLYWITHLUA == false then imgui.Begin("KPCrewNG " .. ng_version) end

	local tabsDef = {}
	if ng_getAppPrefs():get("general:developer") then
		tabsDef = {[0]="Flight", [1]="Full SOP", [2]="Settings", [3]="Editor"}
	else
		tabsDef = {[0]="Flight", [1]="Full SOP", [2]="Settings"}
	end
	
	local tabsNumber = (#tabsDef+1)
	local tabsSize = kb_wnd_width / tabsNumber - 4
	
	imgui.BeginGroup()
		for i = 0,#tabsDef,1 do ng_imgui_draw_add_main_tab(i, tabsSize, tabsDef[i]) end
	imgui.EndGroup()
	
	imgui.BeginGroup()
	if     ng_imgui_current_main_tab == 0 then render_main_tab_flight()
	elseif ng_imgui_current_main_tab == 1 then render_main_tab_sop() 
	elseif ng_imgui_current_main_tab == 2 then render_main_tab_settings()
	elseif ng_imgui_current_main_tab == 3 and ng_getAppPrefs():get("general:developer") then render_main_tab_editor()
	end
	imgui.EndGroup()
	
	if FLYWITHLUA == false then imgui.End() end
		
end

-- =========================================================================================
-- SOP window rendering #sopwindow
-- =========================================================================================

-- -----------------------------------------------------------------------------------------
-- drawing function for SOP window
function ng_draw_sop_window()
	
	if FLYWITHLUA then
		-- imgui.SetNextWindowSize(460,(15 + 2 ) * 23 + 12 + 27)
		imgui.SetNextWindowPos(ng_scrn_width-455,ng_scrn_height-((15 + 2 ) * 23 + 12 + 77))
	else
		imgui.SetNextWindowSize({490,ng_get_active_sop():getNumberFlows()*25})
		imgui.SetNextWindowPos({ng_scrn_width-497, (60/17)*ng_get_active_sop():getNumberFlows()})
	end

	if FLYWITHLUA == false then imgui.Begin(ng_get_active_sop():getTitle()) end
		ng_get_active_sop():render("i")
	if FLYWITHLUA == false then imgui.End() end
	
end

-- =========================================================================================
-- Main window rendering
-- =========================================================================================

-- -----------------------------------------------------------------------------------------
--- Set up main window tabs with buttons
-- @param int index id of the tab (group) to be added
-- @param int size of tab in pixel
-- @param string name of tab/button  
function ng_imgui_draw_add_main_tab(index, tabsize, text)
	
	local tabwidth = tabsize
	local tabheight = 18
	
	imgui.PushStyleVar(12, 3)
	
	if index == 1 then imgui.SameLine(index * (tabwidth + 5))
	elseif index > 1 then imgui.SameLine(index * (tabwidth + 4 - index)) end
 
	if ng_imgui_current_main_tab == index then
		imgui.PushStyleColor(21, color_mcp_active)			
	else
		imgui.PushStyleColor(21, color_mcp_button)			
 	end 
	
	imgui.PushStyleColor(22, color_mcp_hover)
	imgui.PushStyleColor(23, color_orange)
	
	ng_imgui_in_button(text..index, text, tabwidth, tabheight, function () ng_imgui_current_main_tab=index end)
	
	imgui.PopStyleVar()
	imgui.PopStyleColor(3)
end

-- =========================================================================================
-- Control window rendering
-- =========================================================================================

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
			elseif flow:getState() == ng_flowstate_pause then outcolor = color_flow_pause
			end
			outtext = flow:getActiveItem():getLine(60)
		end
	end		
		 
	-- display line 
	imgui.PushStyleColor(imgui.constant.Col.ButtonHovered, color_black)
		imgui.PushStyleColor(imgui.constant.Col.Button, color_black)
			imgui.PushStyleColor(imgui.constant.Col.Text, outcolor)
				ng_imgui_in_button("outtext",outtext, 420, 20, function () end)
			imgui.PopStyleColor()
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