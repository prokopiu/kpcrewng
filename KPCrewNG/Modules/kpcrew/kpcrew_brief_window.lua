-- =========================================================================================
-- Briefing window rendering #briefwindow
-- =========================================================================================

-- -----------------------------------------------------------------------------------------
-- Draw the Planning section Times
-- -----------------------------------------------------------------------------------------
function render_flight_times()
	
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
		
		imgui.TableNextRow()
		imgui.TableNextColumn()
		imgui.Separator()
		ng_imgui_out_text(color_white,"TRIP TIME")
		imgui.TableNextColumn()
		imgui.Separator()
		ng_imgui_out_text(color_bright_orange, os.date("!%H%M",ng_getBriefPrefs():get("times:estenroute")).." h")
		imgui.TableNextColumn()
		imgui.Separator()
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
		ng_imgui_out_text(color_bright_orange, os.date("!%H%M",ng_getBriefPrefs():get("times:estblock")).." h")
		imgui.TableNextColumn()
		ng_imgui_out_text(color_bright_orange, os.date("!%H%M",ng_getBriefPrefs():get("times:schedblock")).." h")

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
		ng_imgui_out_text(color_bright_orange, os.date("!%H%M",ng_getBriefPrefs():get("times:reserve")).." h")

		imgui.TableNextRow()
		imgui.TableNextColumn()
		ng_imgui_out_text(color_white,"ENDURANCE")
		imgui.TableNextColumn()
		ng_imgui_out_text(color_bright_orange, os.date("!%H%M",ng_getBriefPrefs():get("times:endurance")).." h")

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
-- Draw the Planning section FUEL
-- -----------------------------------------------------------------------------------------
function render_flight_fuel()

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
		imgui.Separator()
		ng_imgui_out_text(color_white,"TRIP FUEL")
		imgui.TableNextColumn()
		imgui.Separator()
		ng_imgui_out_text(color_grey, string.format("%6.0f",ng_getBriefPrefs():get("fuel:enroute")*ng_kgslbs))
		imgui.TableNextColumn()
		imgui.Separator()
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
		ng_imgui_out_text(color_bright_orange, string.format("%6.0f",ng_getBriefPrefs():get("fuel:reserve")*ng_kgslbs))
		imgui.TableNextColumn()
		ng_imgui_out_text(color_bright_orange, os.date("!%H%M",ng_getBriefPrefs():get("times:reserve")))

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
		ng_imgui_out_text(color_bright_orange, string.format("%6.0f",ng_getBriefPrefs():get("fuel:planramp")*ng_kgslbs))
		imgui.TableNextColumn()
		ng_imgui_out_text(color_bright_orange, os.date("!%H%M",ng_getBriefPrefs():get("times:endurance")))
		
	imgui.EndTable()	
	imgui.Separator()
	imgui.Separator()

end
-- -----------------------------------------------------------------------------------------

-- -----------------------------------------------------------------------------------------
-- Draw the Planning section Weights
function render_flight_weights()

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

		imgui.TableNextRow()
		imgui.TableNextColumn()
		imgui.Separator()
		ng_imgui_out_text(color_white,"EST ZFW")
		imgui.TableNextColumn()
		imgui.Separator()
		ng_imgui_out_text(color_grey, string.format("%6.0f",ng_getBriefPrefs():get("weights:estzfw")*ng_kgslbs))
		imgui.TableNextColumn()
		imgui.Separator()
		local pcolor = (ng_getBriefPrefs():get("weights:estzfw")*ng_kgslbs > ng_getBriefPrefs():get("weights:maxzfw")*ng_kgslbs and color_red or color_green) 
		ng_imgui_out_text(pcolor, string.format("%6.0f MAX",ng_getBriefPrefs():get("weights:maxzfw")*ng_kgslbs))

		imgui.TableNextRow()
		imgui.TableNextColumn()
		ng_imgui_out_text(color_white,"EST TOW")
		imgui.TableNextColumn()
		ng_imgui_out_text(color_grey, string.format("%6.0f",ng_getBriefPrefs():get("weights:esttow")*ng_kgslbs))
		imgui.TableNextColumn()
		local pcolor = (ng_getBriefPrefs():get("weights:esttow")*ng_kgslbs > ng_getBriefPrefs():get("weights:maxtow")*ng_kgslbs and color_red or color_green) 
		ng_imgui_out_text(pcolor, string.format("%6.0f MAX",ng_getBriefPrefs():get("weights:maxtow")*ng_kgslbs))

		imgui.TableNextRow()
		imgui.TableNextColumn()
		ng_imgui_out_text(color_white,"EST LDW")
		imgui.TableNextColumn()
		ng_imgui_out_text(color_grey, string.format("%6.0f",ng_getBriefPrefs():get("weights:estldw")*ng_kgslbs))
		imgui.TableNextColumn()
		local pcolor = (ng_getBriefPrefs():get("weights:estldw")*ng_kgslbs > ng_getBriefPrefs():get("weights:maxldw")*ng_kgslbs and color_red or color_green) 
		ng_imgui_out_text(pcolor, string.format("%6.0f MAX",ng_getBriefPrefs():get("weights:maxldw")*ng_kgslbs))

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
		local pcolor = (ng_getBriefPrefs():get("weights:payload")*ng_kgslbs > ng_get_MaxPayload() and color_red or color_green) 
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
		ng_imgui_out_text(color_white,"OEW")
		imgui.TableNextColumn()
		ng_imgui_out_text(color_grey, string.format("%6.0f",ng_getBriefPrefs():get("weights:oew")*ng_kgslbs))
		imgui.TableNextColumn()
		local pcolor = (ng_getBriefPrefs():get("weights:oew")*ng_kgslbs > ng_get_DOW() and color_red or color_green) 
		ng_imgui_out_text(pcolor, string.format("%6.0f",ng_get_DOW()))
		
		imgui.TableNextRow()
		imgui.TableNextColumn()
		ng_imgui_out_text(color_white,"PLANNED FUEL")
		imgui.TableNextColumn()
		ng_imgui_out_text(color_bright_orange, string.format("%6.0f", ng_getBriefPrefs():get("fuel:planramp")*ng_kgslbs))
		imgui.TableNextColumn()
		local pcolor = (ng_getBriefPrefs():get("fuel:planramp")*ng_kgslbs > ng_getBriefPrefs():get("fuel:maxtanks")*ng_kgslbs and color_red or color_green) 
		ng_imgui_out_text(pcolor, string.format("%6.0f MAX",ng_getBriefPrefs():get("fuel:maxtanks")*ng_kgslbs))

		imgui.TableNextRow()
		imgui.TableNextColumn()
		ng_imgui_out_text(color_white,"ACT FUEL")
		imgui.TableNextColumn()
		ng_imgui_out_text(color_bright_orange, string.format("%6.0f",get("sim/flightmodel/weight/m_fuel_total")*ng_kgslbs))
		imgui.TableNextColumn()
		local pcolor = (get("sim/flightmodel/weight/m_fuel_total")*ng_kgslbs < ng_getBriefPrefs():get("fuel:planramp")*ng_kgslbs and color_red or color_green) 
		ng_imgui_out_text(pcolor, string.format("%6.0f PLAN",ng_getBriefPrefs():get("fuel:planramp")*ng_kgslbs))

		imgui.TableNextRow()
		imgui.TableNextColumn()
		ng_imgui_out_text(color_white,"ACT ZFW")
		imgui.TableNextColumn()
		ng_imgui_out_text(color_bright_orange, string.format("%6.0f",ng_get_zfw()))
		imgui.TableNextColumn()
		local pcolor = (ng_get_zfw() > ng_getBriefPrefs():get("weights:maxzfw")*ng_kgslbs and color_red or color_green) 
		ng_imgui_out_text(pcolor, string.format("%6.0f MAX",ng_getBriefPrefs():get("weights:maxzfw")*ng_kgslbs))

		imgui.TableNextRow()
		imgui.TableNextColumn()
		ng_imgui_out_text(color_white,"ACT WEIGHT")
		imgui.TableNextColumn()
		ng_imgui_out_text(color_bright_orange, string.format("%6.0f",ng_get_gross_weight()))
		imgui.TableNextColumn()
		local pcolor = (ng_get_gross_weight() > ng_getBriefPrefs():get("weights:maxtow")*ng_kgslbs and color_red or color_green) 
		ng_imgui_out_text(pcolor, string.format("%6.0f MAX",ng_getBriefPrefs():get("weights:maxtow")*ng_kgslbs))
		
		imgui.TableNextRow()
		imgui.TableNextColumn()
		ng_imgui_out_text(color_white,"MAC CG")
		imgui.TableNextColumn()
		ng_imgui_out_text(color_grey, string.format("%6.2f",21.2)) --ng_getBriefPrefs():get("weights:paxweight")))
					
	imgui.EndTable()
	imgui.Separator()

end
-- -----------------------------------------------------------------------------------------

-- -----------------------------------------------------------------------------------------
-- draw the Flight status
-- -----------------------------------------------------------------------------------------
-- draw the threat based briefing tab
function render_briefing_flightstate() 
-- ----------------------------------------------
-- CALLSIGN    	[XXXXX]  	ORIGIN     [XXXX]
-- DESTINATION 	[XXXX]   	ALTERNATE  [XXXX]
-- SOP PHASE   	phase    	AIRCRAFT   DFLT / DFLT
--                          	       /ICAO
-- CRUISE ALT	[999999]	CRUISE LVL	FL999
-- DISTANCE		999			PAX			999
-- AVG WIND		999/99		WIND COMP	999
-- ISA DEV		99			TROPOPAUSE	99999
-- CI			99			EST FF/H	9999 KGS/H
-- ----------------------------------------------
-- DATE		   HH:MM 		TIME 		HH:MM
-- TIME OUT	   HH:MM 		TIME OFF	HH:MM
-- TIME IN	   HH:MM		TIME ON		HH:MM
-- TIMES       [RESET]
-- ----------------------------------------------
-- ACT ZFW	   999999		ACT GROSS	999999
-- ACT FUEL	   999999  		FF KGS/H	99999
-- ----------------------------------------------
-- AMB WIND		777/777		AMB TEMP	999
-- CURR ALT		999999  	CURR SPEED	999 kts
-- POSITION		N999999 			 	N9999999
--          	E999999					W9999999
-- ----------------------------------------------

	ng_imgui_out_text(color_yellow,"FLIGHT STATUS")
	imgui.Separator()
	imgui.BeginTable("flightstate",4)

-- CALLSIGN    [XXXXX]  ORIGIN     [XXXX]
		imgui.TableNextColumn()
		ng_imgui_out_text(color_white,"CALLSIGN")
		imgui.TableNextColumn()
		ng_imgui_in_tfield("Flight Number", 70, color_white, 8, 
			ng_getBriefPrefs():get("general:callsign"), function (textout) ng_getBriefPrefs():set("general:callsign",textout) end)

		imgui.TableNextColumn()
		ng_imgui_out_text(color_white,"ORIGIN")
		imgui.TableNextColumn()
		ng_imgui_in_ltfield("*Origin ICAO:", 38, color_white, 5, "", color_white,
			ng_getBriefPrefs():get("origin:icao"), function (textout) ng_getBriefPrefs():set("origin:icao",textout) end)

-- DESTINATION [XXXX]   ALTERNATE  [XXXX]
		imgui.TableNextColumn()
		ng_imgui_out_text(color_white,"DESTINATION")
		imgui.TableNextColumn()
		ng_imgui_in_ltfield("*Destination ICAO:", 38, color_white, 5, "", color_white, 
			ng_getBriefPrefs():get("destination:icao"), function (textout) ng_getBriefPrefs():set("destination:icao",textout) end)

		imgui.TableNextColumn()
		ng_imgui_out_text(color_white,"ALTERNATE")
		imgui.TableNextColumn()
		ng_imgui_in_ltfield("*Alternate ICAO:", 38, color_white, 5, "", color_white, 
			ng_getBriefPrefs():get("alternate:icao"), function (textout) ng_getBriefPrefs():set("alternate:icao",textout) end)

-- SOP PHASE   phase    AIRCRAFT   DFLT / DFLT
--                                 /ICAO
		imgui.TableNextColumn()
		ng_imgui_out_text(color_white,"SOP PHASE")
		imgui.TableNextColumn()
		ng_imgui_out_text(color_yellow, 
			ng_flightphases[math.abs(ng_getBckVars():get("general:flightstate"))])

		imgui.TableNextColumn()
		ng_imgui_out_text(color_white,"AIRCRAFT")
		imgui.TableNextColumn()
		ng_imgui_out_text(color_yellow, 
			ng_acf_icao .. " / " .. PLANE_ICAO .. " / " .. ng_getBriefPrefs():get("general:acficao"))

-- CRUISE ALT	[999999]	CRUISE LVL	FL999
		imgui.TableNextColumn()
		ng_imgui_out_text(color_white,"CRUISE ALT")
		imgui.TableNextColumn()
		ng_imgui_in_intfield("calt", 45, color_bright_orange, 0, ng_getBriefPrefs():get("general:cruisealtitude"), 
			function (textout) ng_getBriefPrefs():set("general:cruisealtitude",textout) end)
		imgui.TableNextColumn()
		ng_imgui_out_text(color_white,"CRUISE LVL")
		imgui.TableNextColumn()
		ng_imgui_out_text(color_green, "(FL" .. ng_getBriefPrefs():get("general:cruisealtitude")/100 .. ")" )

-- DISTANCE		999			PAX			999
		imgui.TableNextColumn()
		ng_imgui_out_text(color_white,"DISTANCE")
		imgui.TableNextColumn()
		ng_imgui_out_text(color_green, ""..ng_getBriefPrefs():get("general:routedistance").." nm")

		imgui.TableNextColumn()
		ng_imgui_out_text(color_white,"PAX")
		imgui.TableNextColumn()
		ng_imgui_out_text(color_green, ""..ng_getBriefPrefs():get("weights:paxcount"))
		
-- AVG WIND		999/99		WIND COMP	999
		imgui.TableNextColumn()
		ng_imgui_out_text(color_white,"AVG WIND")
		imgui.TableNextColumn()
		ng_imgui_out_text(color_green, ng_getBriefPrefs():get("general:averagewndhdg").."/"..ng_getBriefPrefs():get("general:averagewndspd"))

		imgui.TableNextColumn()
		ng_imgui_out_text(color_white,"WIND COMP")
		imgui.TableNextColumn()
		ng_imgui_out_text(color_green, (ng_getBriefPrefs():get("general:averagewndcmp") >= 0 and "P" or "M")..math.abs(ng_getBriefPrefs():get("general:averagewndcmp")))
		
-- ISA DEV		99			TROPOPAUSE	99999
		imgui.TableNextColumn()
		ng_imgui_out_text(color_white,"ISA DEV")
		imgui.TableNextColumn()
		ng_imgui_out_text(color_green, ""..ng_getBriefPrefs():get("general:averageisa"))

		imgui.TableNextColumn()
		ng_imgui_out_text(color_white,"TROPOPAUSE")
		imgui.TableNextColumn()
		ng_imgui_out_text(color_green, ""..ng_getBriefPrefs():get("general:tropopause"))
		
-- CI			99			EST FF/H	9999 KGS/H
		imgui.TableNextColumn()
		ng_imgui_out_text(color_white,"CI")
		imgui.TableNextColumn()
		ng_imgui_out_text(color_green, ""..ng_getBriefPrefs():get("general:costindex"))

		imgui.TableNextColumn()
		ng_imgui_out_text(color_white,"EST FF/H")
		imgui.TableNextColumn()
		ng_imgui_out_text(color_green, ""..ng_getBriefPrefs():get("fuel:avgfuelflow").." kgs/h")

		imgui.Separator()				

-- DATE		   HH:MM 	TIME 		HH:MM
		imgui.TableNextColumn()
		ng_imgui_out_text(color_white,"DATE")
		imgui.TableNextColumn()
		ng_imgui_out_text(color_bright_orange, string.upper(os.date("%d.%m.%Y")))

		imgui.TableNextColumn()
		ng_imgui_out_text(color_white,"TIME")
		imgui.TableNextColumn()
		ng_imgui_out_text(color_bright_orange, string.upper(os.date("%H:%M")))

-- TIME OUT	   HH:MM 	TIME OFF	HH:MM
		imgui.TableNextColumn()
		ng_imgui_out_text(color_white,"TIME OUT")
		imgui.TableNextColumn()
		ng_imgui_out_text(color_bright_orange, ng_getBckVars():get("general:timeout"))

		imgui.TableNextColumn()
		ng_imgui_out_text(color_white,"TIME OFF")
		imgui.TableNextColumn()
		ng_imgui_out_text(color_bright_orange, ng_getBckVars():get("general:timeoff"))

-- TIME IN	   HH:MM	TIME ON		HH:MM
		imgui.TableNextColumn()
		ng_imgui_out_text(color_white,"TIME IN")
		imgui.TableNextColumn()
		ng_imgui_out_text(color_bright_orange, ng_getBckVars():get("general:timein"))

		imgui.TableNextColumn()
		ng_imgui_out_text(color_white,"TIME ON")
		imgui.TableNextColumn()
		ng_imgui_out_text(color_bright_orange, ng_getBckVars():get("general:timeon"))

-- TIMES       [RESET]
		imgui.TableNextColumn()
		ng_imgui_out_text(color_white,"TIMES")
		imgui.Separator()	
		imgui.TableNextColumn()
		ng_imgui_in_button("allclear:", "RESET", 50, 20, 
			function () 
				ng_getBckVars():set("general:timeoff","==:==") 
				ng_getBckVars():set("general:timeout","==:==") 
				ng_getBckVars():set("general:timein","==:==") 
				ng_getBckVars():set("general:timeon","==:==") 
			end)
		imgui.TableNextColumn()
		imgui.TableNextColumn()

-- ACT ZFW	   999999	ACT GROSS	999999
		imgui.TableNextColumn()
		ng_imgui_out_text(color_white,"ACT ZFW")
		imgui.TableNextColumn()
		ng_imgui_out_text(color_bright_orange, string.format("%6.0f KG",get("sim/flightmodel/weight/m_total")-get("sim/flightmodel/weight/m_fuel_total")))

		imgui.TableNextColumn()
		ng_imgui_out_text(color_white,"ACT GROSS")
		imgui.TableNextColumn()
		ng_imgui_out_text(color_bright_orange, string.format("%6.0f KG",get("sim/flightmodel/weight/m_total")))
	
-- ACT FUEL	   999999  	FF KGS/H	99999
		imgui.TableNextColumn()
		ng_imgui_out_text(color_white,"ACT FUEL")
		imgui.Separator()				
		imgui.TableNextColumn()
		local pcolor = (get("sim/flightmodel/weight/m_fuel_total")*ng_kgslbs < (ng_getBriefPrefs():get("fuel:reserve")+(ng_getBriefPrefs():get("fuel:reserve")/2))*ng_kgslbs and color_red or color_bright_orange) 
		ng_imgui_out_text(pcolor, string.format("%6.0f KG",get("sim/flightmodel/weight/m_fuel_total")*ng_kgslbs))
		imgui.Separator()				

		imgui.TableNextColumn()
		ng_imgui_out_text(color_white,"FF KGS/H")
		imgui.Separator()				
		imgui.TableNextColumn()
		ng_imgui_out_text(color_bright_orange,  string.format("%6.0f",get("sim/cockpit2/engine/indicators/fuel_flow_kg_sec",0)*3600))
		imgui.Separator()				

-- AMB WIND	777/777	AMB TEMP	999
		imgui.TableNextColumn()
		ng_imgui_out_text(color_white,"AMB WIND")
		imgui.TableNextColumn()
		ng_imgui_out_text(color_bright_orange, string.format("%03.0f/%02.0f",get("sim/weather/wind_direction_degt"),get("sim/weather/wind_speed_kt")))

		imgui.TableNextColumn()
		ng_imgui_out_text(color_white,"AMB TEMP")
		imgui.TableNextColumn()
		ng_imgui_out_text(color_bright_orange,  string.format("%4.1f C",get("sim/weather/temperature_ambient_c")))
	
-- CURR ALT	999999  CURR SPEED	999 kts
		imgui.TableNextColumn()
		ng_imgui_out_text(color_white,"CURR ALT")
		imgui.TableNextColumn()
		ng_imgui_out_text(color_bright_orange, string.format("%6.0f",get("sim/flightmodel2/position/pressure_altitude")))

		imgui.TableNextColumn()
		ng_imgui_out_text(color_white,"GRND SPD")
		imgui.TableNextColumn()
		ng_imgui_out_text(color_bright_orange, string.format("%3.0f KTS",get("sim/flightmodel2/position/groundspeed")))

-- POSITION	N999999 		 	N9999999
--          E999999				W9999999
		imgui.TableNextColumn()
		ng_imgui_out_text(color_white,"POSITION")
		imgui.TableNextColumn()
		ng_imgui_out_text(color_bright_orange,ng_convertDMS(get("sim/flightmodel/position/latitude"),get("sim/flightmodel/position/longitude")))

		imgui.TableNextColumn()
		ng_imgui_out_text(color_white,"")
		imgui.TableNextColumn()
		ng_imgui_out_text(color_bright_orange,ng_convertINS(get("sim/flightmodel/position/latitude"),get("sim/flightmodel/position/longitude")))
				

	imgui.EndTable()

	imgui.Separator()
	imgui.Separator()
end
-- -----------------------------------------------------------------------------------------

-- -----------------------------------------------------------------------------------------
-- Draw the Origin Airport information block
-- -----------------------------------------------------------------------------------------
function render_flight_origin_info()
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
		imgui.TableNextColumn()
		ng_imgui_out_text(color_yellow, ng_getBriefPrefs():get("origin:icao").." / "..ng_getBriefPrefs():get("origin:name"))		
		
		imgui.TableNextRow()
		imgui.TableNextColumn()
		imgui.Separator()
		ng_imgui_out_text(color_white,"AIRPORT ELEVATION")
		imgui.TableNextColumn()
		imgui.Separator()
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
		ng_imgui_out_text(color_white,"STAND POWER")
		imgui.TableNextColumn()
		local splitTitle = ng_split(ng_getBriefPrefs():find("origin:standpower"):getTitle(),"|")
		ng_imgui_in_combolist("oparkpower", splitTitle, ng_getBriefPrefs():get("origin:standpower"), 
			function (textin) ng_getBriefPrefs():set("origin:standpower",textin) end, ddwidth)

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
		ng_imgui_out_text(color_bright_orange,"TAKEOFF RWY")
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
			ng_imgui_out_text(color_bright_orange, ng_getBriefPrefs():get("takeoff:rwycourse"))

			imgui.TableNextRow()
			imgui.TableNextColumn()
			ng_imgui_out_text(color_white,"HEAD / CROSS WIND")
			imgui.TableNextColumn()
			-- ng_getBriefPrefs():set("takeoff:rwyheadwind",ng_briefing_to_rwys[ng_getBriefPrefs():get("origin:selectedrwy")].headwind_component)
			-- ng_getBriefPrefs():set("takeoff:rwycrosswind",ng_briefing_to_rwys[ng_getBriefPrefs():get("origin:selectedrwy")].crosswind_component)
			-- ng_imgui_out_text(color_grey, ng_getBriefPrefs():get("takeoff:rwyheadwind").." kts / "..ng_getBriefPrefs():get("takeoff:rwycrosswind").." kts")
			ng_getBriefPrefs():set("takeoff:rwyheadwind",ng_calc_headwind_spd(ng_getBriefPrefs():get("takeoff:windhdg"),ng_getBriefPrefs():get("takeoff:windspd"),ng_getBriefPrefs():get("takeoff:rwycourse")))
			ng_getBriefPrefs():set("takeoff:rwycrosswind",ng_calc_crosswind_spd(ng_getBriefPrefs():get("takeoff:windhdg"),ng_getBriefPrefs():get("takeoff:windspd"),ng_getBriefPrefs():get("takeoff:rwycourse")))
			ng_imgui_out_text(color_bright_orange, ng_getBriefPrefs():get("takeoff:rwyheadwind").." kts / "..ng_getBriefPrefs():get("takeoff:rwycrosswind").." kts")

			imgui.TableNextRow()
			imgui.TableNextColumn()
			ng_imgui_out_text(color_white,"WIND | TEMP")
			imgui.TableNextColumn()
			ng_imgui_out_text(color_bright_orange, string.format("%03.0f",ng_getBriefPrefs():get("takeoff:windhdg")).."/"..string.format("%02.0f",ng_getBriefPrefs():get("takeoff:windspd")).." | "..ng_getBriefPrefs():get("takeoff:temperature").." C")

			imgui.TableNextRow()
			imgui.TableNextColumn()
			ng_imgui_out_text(color_white,"SURFACE CONDITION")
			imgui.TableNextColumn()
			local splitTitle = ng_split("|DRY|WET","|")
			ng_imgui_in_combolist("osurfcond", splitTitle, ng_indexOf(splitTitle,string.upper(ng_getBriefPrefs():get("takeoff:surfacecond")))-1, 
				function (textin) 
					ng_getBriefPrefs():set("takeoff:surfacecond",splitTitle[textin+1]) 
				end, ddwidth)

		end

	imgui.EndTable()

	imgui.Separator()
	imgui.Separator()

end
-- -----------------------------------------------------------------------------------------

-- -----------------------------------------------------------------------------------------
-- Draw the Departure block
-- -----------------------------------------------------------------------------------------
function render_flight_dep_info()

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
		imgui.Separator()
		ng_imgui_out_text(color_white,"DEPARTURE TYPE")
		imgui.TableNextColumn()
		imgui.Separator()
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
		ng_imgui_in_tfield("Osquawk", ddwidth, color_bright_orange, 5, string.format("%04.0f",ng_getBriefPrefs():get("origin:squawk")), 
			function (textout) ng_getBriefPrefs():set("origin:squawk",textout) end )

		imgui.TableNextRow()
		imgui.TableNextColumn()
		ng_imgui_out_text(color_bright_orange,"TAKEOFF FLAPS")
		imgui.TableNextColumn()
		local splitTitle = ng_split(ng_getAcfPrefs():get("controls:toflapslbl"),"|")
		ng_imgui_in_combolist("oflaps", splitTitle, ng_getBriefPrefs():get("takeoff:selectedflaps"), 
			function (textin) ng_getBriefPrefs():set("takeoff:selectedflaps",textin) end, ddwidth)
			
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

		if ng_getAcfPrefs():get("engines:hastothrust") then
			imgui.TableNextRow()
			imgui.TableNextColumn()
			ng_imgui_out_text(color_white,"TAKEOFF THRUST/TEMP")
			imgui.TableNextColumn()
			ng_imgui_in_tfield("othrust", 50, color_white, 8, ng_getBriefPrefs():get("takeoff:rwythrust"), 
				function (textout) ng_getBriefPrefs():set("takeoff:rwythrust",textout) end )
			imgui.SameLine()
			ng_imgui_in_intfield("oflex", 40, color_white, 0, ng_getBriefPrefs():get("takeoff:rwyflextemp"), 
				function (textout) ng_getBriefPrefs():set("takeoff:rwyflextemp",textout) end )
		end 

		imgui.TableNextRow()
		imgui.TableNextColumn()
		ng_imgui_out_text(color_white,"TAKEOFF V1,VR,V2")
		imgui.TableNextColumn()
		ng_imgui_in_intfield("ov1", 30, color_bright_orange, 0, ng_getBriefPrefs():get("takeoff:rwyv1"), 
			function (textout) ng_getBriefPrefs():set("takeoff:rwyv1",textout) end ) imgui.SameLine()
		ng_imgui_in_intfield("ovr", 30, color_bright_orange, 0, ng_getBriefPrefs():get("takeoff:rwyvr"), 
			function (textout) ng_getBriefPrefs():set("takeoff:rwyvr",textout) end ) imgui.SameLine()
		ng_imgui_in_intfield("ov2", 30, color_bright_orange, 0, ng_getBriefPrefs():get("takeoff:rwyv2"), 
			function (textout) ng_getBriefPrefs():set("takeoff:rwyv2",textout) end ) imgui.SameLine()

		imgui.TableNextRow()
		imgui.TableNextColumn()
		ng_imgui_out_text(color_white,"INITIAL HDG/ALT")
		imgui.TableNextColumn()
		if #ng_briefing_to_rwys > 0 then
			ng_getBriefPrefs():set("takeoff:inithdg",ng_getBriefPrefs():get("takeoff:rwycourse"))
		end
		ng_imgui_in_intfield("ohdg", 30, color_bright_orange, 0, ng_getBriefPrefs():get("takeoff:inithdg"), 
			function (textout) ng_getBriefPrefs():set("takeoff:inithdg",textout) end ) imgui.SameLine()
		
		ng_imgui_in_intfield("oinitalt", 70, color_bright_orange, 0, ng_getBriefPrefs():get("takeoff:initalt"), 
			function (textout) ng_getBriefPrefs():set("takeoff:initalt",textout) end ) imgui.SameLine()					

		imgui.TableNextRow()
		imgui.TableNextColumn()
		ng_imgui_out_text(color_white,"*BARO Q/A")
		imgui.TableNextColumn()
		ng_imgui_in_floatfield("baroq", 40, color_bright_orange, 0, "%04.0f",ng_getBriefPrefs():get("takeoff:qaltimeter"), 
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
-- draw the threat based briefing tab
function render_briefing_departure() 

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
-- Draw the Origin Airport information block
-- -----------------------------------------------------------------------------------------
function render_flight_destination_info()

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
		imgui.TableNextColumn()
		ng_imgui_out_text(color_yellow, ng_getBriefPrefs():get("destination:icao").." / "..ng_getBriefPrefs():get("destination:name"))		
		
		imgui.TableNextRow()
		imgui.TableNextColumn()
		imgui.Separator()
		ng_imgui_out_text(color_white,"AIRPORT ELEVATION")
		imgui.TableNextColumn()
		imgui.Separator()
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
		ng_imgui_out_text(color_bright_orange,"LANDING RUNWAY")
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
			ng_imgui_out_text(color_white, ng_getBriefPrefs():get("landing:rwycourse"))

			imgui.TableNextRow()
			imgui.TableNextColumn()
			ng_imgui_out_text(color_white,"HEAD / CROSS WIND")
			imgui.TableNextColumn()
			ng_getBriefPrefs():set("landing:rwyheadwind",ng_calc_headwind_spd(ng_getBriefPrefs():get("landing:windhdg"),ng_getBriefPrefs():get("landing:windspd"),ng_getBriefPrefs():get("landing:rwycourse")))
			ng_getBriefPrefs():set("landing:rwycrosswind",ng_calc_crosswind_spd(ng_getBriefPrefs():get("landing:windhdg"),ng_getBriefPrefs():get("landing:windspd"),ng_getBriefPrefs():get("landing:rwycourse")))
			ng_imgui_out_text(color_bright_orange, ng_getBriefPrefs():get("landing:rwyheadwind").." kts / "..ng_getBriefPrefs():get("landing:rwycrosswind").." kts")

			imgui.TableNextRow()
			imgui.TableNextColumn()
			ng_imgui_out_text(color_white,"WIND | TEMP")
			imgui.TableNextColumn()
			ng_imgui_out_text(color_bright_orange, string.format("%03.0f",ng_getBriefPrefs():get("landing:windhdg")).."/"..string.format("%02.0f",ng_getBriefPrefs():get("landing:windspd")).." | "..ng_getBriefPrefs():get("landing:temperature").." C")

			imgui.TableNextRow()
			imgui.TableNextColumn()
			ng_imgui_out_text(color_white,"SURFACE CONDITION")
			imgui.TableNextColumn()
			local splitTitle = ng_split("|DRY|WET","|")
			ng_imgui_in_combolist("osurfcond", splitTitle, ng_indexOf(splitTitle,string.upper(ng_getBriefPrefs():get("landing:surfacecond")))-1, 
				function (textin) 
					ng_getBriefPrefs():set("landing:surfacecond",splitTitle[textin+1]) 
					
					local splitTitle = ng_split(ng_getAcfPrefs():get("controls:ldflapslbl"),"|")
					if string.upper(ng_getBriefPrefs():get("landing:surfacecond")) == "DRY" then
						ng_getBriefPrefs():set("landing:selectedflaps",ng_indexOf(splitTitle,ng_getBriefPrefs():get("landing:dryflaps"))-1)
					else
						ng_getBriefPrefs():set("landing:selectedflaps",ng_indexOf(splitTitle,ng_getBriefPrefs():get("landing:wetflaps"))-1)
					end

					if ng_getAcfPrefs():get("general:hasautobrk") then 
						if string.upper(ng_getBriefPrefs():get("landing:surfacecond")) == "DRY" then
							ng_getBriefPrefs():set("landing:selectedabrk",ng_indexOf(splitTitle,ng_getBriefPrefs():get("landing:drybrakes"))-1)
						else
							ng_getBriefPrefs():set("landing:selectedabrk",ng_indexOf(splitTitle,ng_getBriefPrefs():get("landing:wetbrakes"))-1)
						end
					end

					if string.upper(ng_getBriefPrefs():get("landing:surfacecond")) == "DRY" then
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
-- draw the threat based briefing tab
function render_briefing_arrival() 

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
-- draw the Flight tab destination		
-- -----------------------------------------------------------------------------------------
function render_flight_arr_info() 

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
		ng_imgui_out_text(color_bright_orange,"LANDING FLAPS")
		imgui.TableNextColumn()
		local splitTitle = ng_split(ng_getAcfPrefs():get("controls:ldflapslbl"),"|")
		ng_imgui_in_combolist("dflaps", splitTitle, ng_getBriefPrefs():get("landing:selectedflaps"), 
			function (textin) ng_getBriefPrefs():set("landing:selectedflaps",textin) end, ddwidth)

		imgui.TableNextRow()
		imgui.TableNextColumn()
		ng_imgui_out_text(color_white,"APPROACH TYPE")
		imgui.TableNextColumn()
		local splitTitle = ng_split(ng_getBriefPrefs():find("landing:approachtype"):getTitle(),"|")
		ng_imgui_in_combolist("dapprtype", splitTitle, ng_getBriefPrefs():get("landing:approachtype"), 
			function (textin) ng_getBriefPrefs():set("landing:approachtype",textin) end, ddwidth)

		if ng_getBriefPrefs():get("landing:approachtype") == 1 then
			imgui.TableNextColumn()
			ng_imgui_out_text(color_bright_orange,"ILS FREQ")
			imgui.TableNextColumn()
			ng_imgui_in_tfield("dilsfreq", ddwidth, color_white, 10, ng_getBriefPrefs():get("landing:rwyilsfreq"), 
				function (textout) ng_getBriefPrefs():set("landing:rwyilsfreq",textout) end )	
		end 

		imgui.TableNextRow()
		imgui.TableNextColumn()
		ng_imgui_out_text(color_white,"LANDING CRS1,CRS2")
		imgui.TableNextColumn()
		ng_imgui_in_intfield("dcrs1", 30, color_bright_orange, 0, ng_getBriefPrefs():get("landing:rwycourse"), 
			function (textout) ng_getBriefPrefs():set("landing:rwycourse",textout) end ) imgui.SameLine()
		ng_imgui_in_intfield("dcrs2", 30, color_bright_orange, 0, ng_getBriefPrefs():get("landing:rwycourse2"), 
			function (textout) ng_getBriefPrefs():set("landing:rwycourse2",textout) end ) 
		
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
		ng_imgui_in_intfield("dvref", 30, color_bright_orange, 0, ng_getBriefPrefs():get("landing:rwyvref"), 
			function (textout) ng_getBriefPrefs():set("landing:rwyvref",textout) end ) imgui.SameLine()
		ng_imgui_in_intfield("dvapp", 30, color_bright_orange, 0, ng_getBriefPrefs():get("landing:rwyvapp"), 
			function (textout) ng_getBriefPrefs():set("landing:rwyvapp",textout) end ) 

		if ng_getAcfPrefs():get("general:hasautobrk") then
			imgui.TableNextRow()
			imgui.TableNextColumn()
			ng_imgui_out_text(color_bright_orange,"AUTOBRAKE")
			imgui.TableNextColumn()
			local splitTitle = ng_split(ng_getAcfPrefs():get("general:abrkmodelblt"),"|")
			ng_imgui_in_combolist("abrkset", splitTitle, ng_getBriefPrefs():get("landing:selectedabrk"), 
				function (textin) ng_getBriefPrefs():set("landing:selectedabrk",textin) end, ddwidth)
		end

		imgui.TableNextRow()
		imgui.TableNextColumn()
		ng_imgui_out_text(color_white,"DECISION HEIGHT/ALT")
		imgui.TableNextColumn()
		ng_imgui_in_intfield("ddh", 30, color_bright_orange, 0, ng_getBriefPrefs():get("landing:decisionheight"), 
			function (textout) ng_getBriefPrefs():set("landing:decisionheight",textout) end ) imgui.SameLine()
		ng_imgui_in_intfield("dda", 40, color_bright_orange, 0, ng_getBriefPrefs():get("landing:decisionalt"), 
			function (textout) ng_getBriefPrefs():set("landing:decisionalt",textout) end ) 
		
		imgui.TableNextRow()
		imgui.TableNextColumn()
		ng_imgui_out_text(color_white,"GO-AROUND HDG/ALT")
		imgui.TableNextColumn()
		ng_imgui_in_intfield("dgahdg", 30, color_bright_orange, 0, ng_getBriefPrefs():get("landing:gaheading"), 
			function (textout) ng_getBriefPrefs():set("landing:gaheading",textout) end ) imgui.SameLine()
		ng_imgui_in_intfield("dgaalt", 40, color_bright_orange, 0, ng_getBriefPrefs():get("landing:gaaltitude"), 
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
		ng_imgui_out_text(color_white,"STAND POWER")
		imgui.TableNextColumn()
		local splitTitle = ng_split(ng_getBriefPrefs():find("destination:standpower"):getTitle(),"|")
		ng_imgui_in_combolist("dparkpower", splitTitle, ng_getBriefPrefs():get("destination:standpower"), 
			function (textin) ng_getBriefPrefs():set("destination:standpower",textin) end, ddwidth)

		imgui.TableNextRow()
		imgui.TableNextColumn()
		ng_imgui_out_text(color_white,"*BARO Q/A")
		imgui.TableNextColumn()
		ng_imgui_in_floatfield("lbaroq", 40, color_bright_orange, 0, "%04.0f",ng_getBriefPrefs():get("landing:qaltimeter"), 
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
-- -----------------------------------------------------------------------------------------
function render_flight_alt_info()

-- --------------------------------------------
-- ALTERNATE				ICAO/NAME OF ARPT
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

	imgui.BeginTable("alternateinfo",2)
	
		local ddwidth=146
		imgui.TableNextColumn()
		ng_imgui_out_text(color_yellow,"ALTERNATE")
		imgui.TableNextColumn()
		ng_imgui_out_text(color_yellow, ng_getBriefPrefs():get("alternate:icao").." / "..ng_getBriefPrefs():get("alternate:name"))		
		
		imgui.TableNextRow()
		imgui.TableNextColumn()
		imgui.Separator()
		ng_imgui_out_text(color_white,"AIRPORT ELEVATION")
		imgui.TableNextColumn()
		imgui.Separator()
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
		ng_imgui_out_text(color_bright_orange,"LANDING RUNWAY")
		imgui.TableNextColumn()
		ng_imgui_in_tfield("arwy", ddwidth, color_white, 10, ng_getBriefPrefs():get("alternate:planrwy"), 
			function (textout) ng_getBriefPrefs():set("alternate:planrwy",textout) end )				

		imgui.TableNextRow()
		imgui.TableNextColumn()
		ng_imgui_out_text(color_white,"WIND | TEMP")
		imgui.TableNextColumn()
		ng_imgui_out_text(color_bright_orange, string.format("%03.0f",ng_getBriefPrefs():get("alternate:windhdg")).."/"..string.format("%02.0f",ng_getBriefPrefs():get("alternate:windspd")).." | "..ng_getBriefPrefs():get("alternate:temperature").." C")

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
		ng_imgui_out_text(color_bright_orange, ng_getBriefPrefs():get("alternate:rwyheadwind").." kts / "..ng_getBriefPrefs():get("alternate:rwycrosswind").." kts")

		imgui.TableNextRow()
		imgui.TableNextColumn()
		ng_imgui_out_text(color_white,"SURFACE CONDITION")
		imgui.TableNextColumn()
		local splitTitle = ng_split(ng_getBriefPrefs():find("alternate:surfacecond"):getTitle(),"|")
		ng_imgui_in_combolist("altsurfcond", splitTitle, ng_getBriefPrefs():get("alternate:surfacecond"), 
				function (textin) ng_getBriefPrefs():set("alternate:surfacecond",textin) end, ddwidth, color_bright_orange)

		imgui.TableNextRow()
		imgui.TableNextColumn()
		ng_imgui_out_text(color_white,"*BARO Q/A")
		imgui.TableNextColumn()
		ng_imgui_in_floatfield("abaroq", 40, color_bright_orange, 0, "%04.0f",ng_getBriefPrefs():get("alternate:qaltimeter"), 
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
-- draw the Alternate arrival		
-- -----------------------------------------------------------------------------------------
function render_alternate_arr_info() 

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

	imgui.BeginTable("altarrivalinfo",2)
	
		local ddwidth=146
		
		imgui.TableNextColumn()
		ng_imgui_out_text(color_yellow,"ARRIVAL")
		imgui.TableNextColumn()
		ng_imgui_in_tfield("altarrival", ddwidth, color_bright_orange, 10, ng_getBriefPrefs():get("alternate:star"), 
			function (textout) ng_getBriefPrefs():set("alternate:star",textout) end )	
			
		imgui.TableNextRow()
		imgui.TableNextColumn()
		ng_imgui_out_text(color_white,"ARRIVAL TYPE")
		imgui.TableNextColumn()
		local splitTitle = ng_split(ng_getBriefPrefs():find("alternate:arrtype"):getTitle(),"|")
		ng_imgui_in_combolist("altarrtype", splitTitle, ng_getBriefPrefs():get("alternate:arrtype"), 
			function (textin) ng_getBriefPrefs():set("alternate:arrtype",textin) end, ddwidth, color_bright_orange)

		imgui.TableNextRow()
		imgui.TableNextColumn()
		ng_imgui_out_text(color_white,"TRANSITION")
		imgui.TableNextColumn()
		ng_imgui_in_tfield("alttransition", ddwidth, color_bright_orange, 10, ng_getBriefPrefs():get("alternate:startransition"), 
			function (textout) ng_getBriefPrefs():set("alternate:startransition",textout) end )
			
		imgui.TableNextRow()
		imgui.TableNextColumn()
		ng_imgui_out_text(color_bright_orange,"LANDING FLAPS")
		imgui.TableNextColumn()
		local splitTitle = ng_split(ng_getAcfPrefs():get("controls:ldflapslbl"),"|")
		ng_imgui_in_combolist("altflaps", splitTitle, ng_getBriefPrefs():get("landing:selectedflaps"), 
			function (textin) ng_getBriefPrefs():set("landing:selectedflaps",textin) end, ddwidth, color_bright_orange)

		imgui.TableNextRow()
		imgui.TableNextColumn()
		ng_imgui_out_text(color_white,"APPROACH TYPE")
		imgui.TableNextColumn()
		local splitTitle = ng_split(ng_getBriefPrefs():find("alternate:approachtype"):getTitle(),"|")
		ng_imgui_in_combolist("altapprtype", splitTitle, ng_getBriefPrefs():get("alternate:approachtype"), 
			function (textin) ng_getBriefPrefs():set("alternate:approachtype",textin) end, ddwidth, color_bright_orange)

		if ng_getBriefPrefs():get("alternate:approachtype") == 1 then
			imgui.TableNextColumn()
			ng_imgui_out_text(color_bright_orange,"ILS FREQ")
			imgui.TableNextColumn()
			ng_imgui_in_tfield("altilsfreq", ddwidth, color_bright_orange, 10, ng_getBriefPrefs():get("alternate:rwyilsfreq"), 
				function (textout) ng_getBriefPrefs():set("alternate:rwyilsfreq",textout) end )	
		end 

		imgui.TableNextRow()
		imgui.TableNextColumn()
		ng_imgui_out_text(color_bright_orange,"LANDING CRS1,CRS2")
		imgui.TableNextColumn()
		ng_imgui_in_intfield("altcrs1", 30, color_bright_orange, 0, ng_getBriefPrefs():get("landing:rwycourse"), 
			function (textout) ng_getBriefPrefs():set("landing:rwycourse",textout) end ) imgui.SameLine()
		ng_imgui_in_intfield("altcrs2", 30, color_bright_orange, 0, ng_getBriefPrefs():get("landing:rwycourse2"), 
			function (textout) ng_getBriefPrefs():set("landing:rwycourse2",textout) end ) 
		
		if ng_getAcfPrefs():get("general:hasenginebleeds") then
			imgui.TableNextRow()
			imgui.TableNextColumn()
			ng_imgui_out_text(color_bright_orange,"LANDING BLEEDS")
			imgui.TableNextColumn()
			local splitTitle = ng_split(ng_getAcfPrefs():get("air:landingbleeds"),"|")
			ng_imgui_in_combolist("altbleeds", splitTitle, ng_getBriefPrefs():get("landing:selectedbleed"), 
				function (textin) ng_getBriefPrefs():set("landing:selectedbleed",textin) end, ddwidth, color_bright_orange)
		end
		
		imgui.TableNextRow()
		imgui.TableNextColumn()
		ng_imgui_out_text(color_bright_orange,"LANDING ANTI-ICE")
		imgui.TableNextColumn()
		local splitTitle = ng_split(ng_getAcfPrefs():get("aice:landingaice"),"|")
		ng_imgui_in_combolist("altaice", splitTitle, ng_getBriefPrefs():get("landing:selectedaice"), 
			function (textin) ng_getBriefPrefs():set("landing:selectedaice",textin) end, ddwidth, color_bright_orange)

		imgui.TableNextRow()
		imgui.TableNextColumn()
		ng_imgui_out_text(color_bright_orange,"LANDING VREF,VAPP")
		imgui.TableNextColumn()
		ng_imgui_in_intfield("altvref", 30, color_bright_orange, 0, ng_getBriefPrefs():get("landing:rwyvref"), 
			function (textout) ng_getBriefPrefs():set("landing:rwyvref",textout) end ) imgui.SameLine()
		ng_imgui_in_intfield("altvapp", 30, color_bright_orange, 0, ng_getBriefPrefs():get("landing:rwyvapp"), 
			function (textout) ng_getBriefPrefs():set("landing:rwyvapp",textout) end ) 

		if ng_getAcfPrefs():get("general:hasautobrk") then
			imgui.TableNextRow()
			imgui.TableNextColumn()
			ng_imgui_out_text(color_bright_orange,"AUTOBRAKE")
			imgui.TableNextColumn()
			local splitTitle = ng_split(ng_getAcfPrefs():get("general:abrkmodelblt"),"|")
			ng_imgui_in_combolist("altabrkset", splitTitle, ng_getBriefPrefs():get("landing:selectedabrk"), 
				function (textin) ng_getBriefPrefs():set("landing:selectedabrk",textin) end, ddwidth, color_bright_orange)
		end

		imgui.TableNextRow()
		imgui.TableNextColumn()
		ng_imgui_out_text(color_bright_orange,"DECISION HEIGHT/ALT")
		imgui.TableNextColumn()
		ng_imgui_in_intfield("altdh", 30, color_bright_orange, 0, ng_getBriefPrefs():get("landing:decisionheight"), 
			function (textout) ng_getBriefPrefs():set("landing:decisionheight",textout) end ) imgui.SameLine()
		ng_imgui_in_intfield("altda", 40, color_bright_orange, 0, ng_getBriefPrefs():get("landing:decisionalt"), 
			function (textout) ng_getBriefPrefs():set("landing:decisionalt",textout) end ) 
		
		imgui.TableNextRow()
		imgui.TableNextColumn()
		ng_imgui_out_text(color_bright_orange,"GO-AROUND HDG/ALT")
		imgui.TableNextColumn()
		ng_imgui_in_intfield("altgahdg", 30, color_bright_orange, 0, ng_getBriefPrefs():get("landing:gaheading"), 
			function (textout) ng_getBriefPrefs():set("landing:gaheading",textout) end ) imgui.SameLine()
		ng_imgui_in_intfield("altgaalt", 40, color_bright_orange, 0, ng_getBriefPrefs():get("landing:gaaltitude"), 
			function (textout) ng_getBriefPrefs():set("landing:gaaltitude",textout) end ) 

		imgui.TableNextRow()
		imgui.TableNextColumn()
		ng_imgui_out_text(color_white,"PARKING POSITION")
		imgui.TableNextColumn()
		ng_imgui_in_tfield("altPARKPOS", ddwidth, color_bright_orange, 10, ng_getBriefPrefs():get("destination:stand"), 
			function (textout) ng_getBriefPrefs():set("destination:stand",textout) end )

		imgui.TableNextRow()
		imgui.TableNextColumn()
		ng_imgui_out_text(color_bright_orange,"STAND TYPE")
		imgui.TableNextColumn()
		local splitTitle = ng_split(ng_getBriefPrefs():find("destination:standtype"):getTitle(),"|")
		ng_imgui_in_combolist("altparktype", splitTitle, ng_getBriefPrefs():get("destination:standtype"),
			function (textin) ng_getBriefPrefs():set("destination:standtype",textin) end, ddwidth, color_bright_orange)
		
		imgui.TableNextRow()
		imgui.TableNextColumn()
		ng_imgui_out_text(color_bright_orange,"STAND POWER")
		imgui.TableNextColumn()
		local splitTitle = ng_split(ng_getBriefPrefs():find("destination:standpower"):getTitle(),"|")
		ng_imgui_in_combolist("altparkpower", splitTitle, ng_getBriefPrefs():get("destination:standpower"), 
			function (textin) ng_getBriefPrefs():set("destination:standpower",textin) end, ddwidth, color_bright_orange)

		imgui.TableNextRow()
		imgui.TableNextColumn()
		ng_imgui_out_text(color_white,"*BARO Q/A")
		imgui.TableNextColumn()
		ng_imgui_in_floatfield("lbaroq", 40, color_bright_orange, 0, "%04.0f",ng_getBriefPrefs():get("landing:qaltimeter"), 
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
-- SIMBRIEF route display
-- -----------------------------------------------------------------------------------------
function render_simbrief_flight_plan()

	ng_imgui_in_button("SIMBRIEF", "SIMBRIEF", 70, 20, 
		function () ng_download_simbrief() ng_load_simbrief() end)

	imgui.SameLine()
	ng_imgui_in_button("loadbrief", "LOAD", 70, 20, 
		function () ng_getBriefPrefs():load() end)

	imgui.SameLine()
	ng_imgui_in_button("savebrief","SAVE", 70, 20,
		function () ng_getBriefPrefs():save() end)
		
	imgui.SameLine()
	ng_imgui_out_text(color_red, "Simbrief date: ", color_yellow, ng_getBriefPrefs():get("general:simbriefgentime"))

	imgui.Separator()

	-- --------------------------------------------------------------------------------------
	-- [ICAO] [RWY] [ROUTE...] [RWY] [ICAO]
	-- --------------------------------------------------------------------------------------
	ng_imgui_in_tfield("origicao:", 38, 0xFF1b9af8, 5, 
		ng_getBriefPrefs():get("origin:icao"),function (textin) ng_getBriefPrefs():set("origin:icao",textin) end)
	imgui.SameLine()
	ng_imgui_in_tfield("origrwy:", 25, 0xFF1b9af8, 3, 
		ng_getBriefPrefs():get("origin:planrwy"),function (textin) ng_getBriefPrefs():set("origin:planrwy",textin) end)
	imgui.SameLine()
	ng_imgui_in_tfield("Route:", 545, 0xFF1b9af8, 255,ng_getBriefPrefs():get("general:route"), 
		function (textin) ng_getBriefPrefs():set("general:route",textin) end)		
	imgui.SameLine()
	ng_imgui_in_tfield("destrwy:", 25, 0xFF1b9af8, 3, 
		ng_getBriefPrefs():get("destination:planrwy"),function (textin) ng_getBriefPrefs():set("destination:planrwy",textin) end)
	imgui.SameLine()
	ng_imgui_in_tfield("desticao:", 38, 0xFF1b9af8, 5,  
		ng_getBriefPrefs():get("destination:icao"),function (textin) ng_getBriefPrefs():set("destination:icao",textin) end)
		
end
-- -----------------------------------------------------------------------------------------

-- -----------------------------------------------------------------------------------------
-- SIMBRIEF alternate route display
-- -----------------------------------------------------------------------------------------
function render_simbrief_alternate_plan()

	ng_imgui_in_button("SIMBRIEF", "SIMBRIEF", 70, 20, 
		function () ng_download_simbrief() ng_load_simbrief() end)

	imgui.SameLine()
	ng_imgui_in_button("loadbrief", "LOAD", 70, 20, 
		function () ng_getBriefPrefs():load() end)

	imgui.SameLine()
	ng_imgui_in_button("savebrief","SAVE", 70, 20,
		function () ng_getBriefPrefs():save() end)
		
	imgui.SameLine()
	ng_imgui_out_text(color_red, "Simbrief date: ", color_yellow, ng_getBriefPrefs():get("general:simbriefgentime"))

	imgui.Separator()

	-- --------------------------------------------------------------------------------------
	-- [ICAO] [RWY] [ROUTE...] [RWY] [ICAO]
	-- --------------------------------------------------------------------------------------
	ng_imgui_in_tfield("desticao:", 38, 0xFF1b9af8, 5,  
		ng_getBriefPrefs():get("destination:icao"),function (textin) ng_getBriefPrefs():set("destination:icao",textin) end)
	imgui.SameLine()
	ng_imgui_in_tfield("destrwy:", 25, 0xFF1b9af8, 3,  
		ng_getBriefPrefs():get("destination:planrwy"),function (textin) ng_getBriefPrefs():set("destination:planrwy",textin) end)
	imgui.SameLine()
	ng_imgui_in_tfield("altnroute", 545, 0xFF1b9af8, 255,ng_getBriefPrefs():get("alternate:route"), 
		function (textin) ng_getBriefPrefs():set("alternate:route",textin) end)		
	imgui.SameLine()
	ng_imgui_in_tfield("altnrwy:", 25, 0xFF1b9af8, 3, 
		ng_getBriefPrefs():get("alternate:planrwy"),function (textin) ng_getBriefPrefs():set("alternate:planrwy",textin) end)
	imgui.SameLine()
	ng_imgui_in_tfield("altnicao:", 38, 0xFF1b9af8, 5, 
		ng_getBriefPrefs():get("alternate:icao"),function (textin) ng_getBriefPrefs():set("alternate:icao",textin) end)
		
end
-- -----------------------------------------------------------------------------------------

-- -----------------------------------------------------------------------------------------
-- drawing Briefing FLIGHT tab
-- -----------------------------------------------------------------------------------------
function render_brief_tab_flight()

	imgui.BeginChild("#tabbriefflight")

		render_simbrief_flight_plan()
		
		imgui.Columns(2,"#brieflightcols",true)

			imgui.BeginChild("#briefflightleft")
				render_briefing_flightstate()
				render_flight_times()
				render_flight_fuel()
			imgui.EndChild()

		imgui.NextColumn()

			imgui.BeginChild("#briefflightright")
				render_flight_origin_info()
				render_flight_destination_info()
				render_flight_alt_info()
			imgui.EndChild()

		imgui.Columns()

	imgui.EndChild()
	
end
-- -----------------------------------------------------------------------------------------

-- -----------------------------------------------------------------------------------------
-- drawing Briefing ARR tab
-- -----------------------------------------------------------------------------------------
function render_brief_tab_dep()

	imgui.BeginChild("#tabbriefdep")

		render_simbrief_flight_plan()
		
		imgui.Separator()

		imgui.Columns(2,"#briefdepcols",true)

			imgui.BeginChild("#briefdepleft")
				render_flight_origin_info()
				render_flight_dep_info()
				render_flight_times()
			imgui.EndChild()

		imgui.NextColumn()

			imgui.BeginChild("#briefdepright")
				render_flight_fuel()
				render_flight_weights()
				render_briefing_departure()
			imgui.EndChild()

		imgui.Columns()
	imgui.EndChild()
	
end

-- -----------------------------------------------------------------------------------------
-- drawing Briefing ARR tab
-- -----------------------------------------------------------------------------------------
function render_brief_tab_arr()

	imgui.BeginChild("#tabbriefarr")

		render_simbrief_flight_plan()

		imgui.Separator()

		imgui.Columns(2,"#briefarrcols",true)

			imgui.BeginChild("#briefarrleft")
				render_flight_destination_info()
				render_flight_arr_info()
				render_flight_times()
			imgui.EndChild()

		imgui.NextColumn()

			imgui.BeginChild("#briefarrright")
				render_briefing_flightstate()
				render_briefing_arrival()
			imgui.EndChild()

		imgui.Columns()
	imgui.EndChild()
	
end

-- -----------------------------------------------------------------------------------------
-- drawing Briefing ALT tab
-- -----------------------------------------------------------------------------------------
function render_brief_tab_alt()

	imgui.BeginChild("#tabbriefalt")

		render_simbrief_alternate_plan()
		
		imgui.Separator()

		imgui.Columns(2,"#briefaltcols",true)

			imgui.BeginChild("#briefaltleft")
				render_flight_alt_info()
				render_alternate_arr_info()
				render_flight_times()
			imgui.EndChild()

		imgui.NextColumn()

			imgui.BeginChild("#briefaltright")
				render_briefing_flightstate()
				render_briefing_arrival()
			imgui.EndChild()

		imgui.Columns()
	imgui.EndChild()
	
end

-- -----------------------------------------------------------------------------------------
-- drawing Briefing OPS tab
-- -----------------------------------------------------------------------------------------
-- -----------------------------------------------------------------------------------------
--- Set up brief window tabs with buttons
-- @param int index id of the tab (group) to be added
-- @param int size of tab in pixel
-- @param string name of tab/button  
function ng_imgui_draw_add_brief_tab(index, tabsize, text)
	
	local tabwidth = tabsize
	local tabheight = 18
	
	imgui.PushStyleVar(12, 3)
	
	if index == 1 then imgui.SameLine(index * (tabwidth + 5))
	elseif index > 1 then imgui.SameLine(index * (tabwidth + 4 - index)) end
 
	if ng_imgui_current_brief_tab == index then
		imgui.PushStyleColor(21, color_mcp_active)			
	else
		imgui.PushStyleColor(21, color_mcp_button)			
 	end 
	
	imgui.PushStyleColor(22, color_mcp_hover)
	imgui.PushStyleColor(23, color_orange)
	
	ng_imgui_in_button(text..index, text, tabwidth, tabheight, function () ng_imgui_current_brief_tab=index end)
	
	imgui.PopStyleVar()
	imgui.PopStyleColor(3)
end

-- -----------------------------------------------------------------------------------------
-- drawing function for Briefing window
-- -----------------------------------------------------------------------------------------
function ng_draw_brief_window()

	if ng_imgui_initial_brief_set == false then
		if FLYWITHLUA then
			-- float_wnd_set_position(ng_brief_wnd, ng_imgui_initial_pref_xpos, ng_imgui_initial_pref_ypos)
			ng_imgui_initial_brief_set = true
		else
			imgui.SetNextWindowSize({ng_imgui_initial_brief_width,ng_imgui_initial_brief_height})
			imgui.SetNextWindowPos({ng_imgui_initial_pref_xpos, ng_imgui_initial_pref_ypos})
			ng_imgui_initial_brief_set = true
		end
	end
	
	if FLYWITHLUA == false then imgui.Begin("BRIEFING") end

		local tabsDef = {[0]="FLIGHT", [1]="DEP", [2]="ARR", [3]="ALT"}
		
		local tabsNumber = (#tabsDef+1)
		local tabsSize = 720 / tabsNumber - 4
		
		imgui.BeginGroup()
			for i = 0,#tabsDef,1 do ng_imgui_draw_add_brief_tab(i, tabsSize, tabsDef[i]) end
		imgui.EndGroup()
		
		imgui.BeginGroup()
		if     ng_imgui_current_brief_tab == 0 then render_brief_tab_flight()
		elseif ng_imgui_current_brief_tab == 1 then render_brief_tab_dep() 
		elseif ng_imgui_current_brief_tab == 2 then render_brief_tab_arr()
		elseif ng_imgui_current_brief_tab == 3 then render_brief_tab_alt()
		end
		imgui.EndGroup()


	if FLYWITHLUA == false then imgui.End() end

end