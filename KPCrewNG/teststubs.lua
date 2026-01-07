-- simulate x-plane and flywithlua functions and variables

SCRIPT_DIRECTORY = "/home/kosta/eclipse-workspace/KPCrewNG/Scripts/" 

function get(datarefname, index)
	if datarefname == "sim/flightmodel/position/latitude" then return 48.124 
	elseif datarefname == "sim/flightmodel/position/longitude" then return 10.43
	elseif datarefname == "sim/cockpit2/autopilot/altitude_readout_preselector" then return 10000
	elseif datarefname == "sim/time/zulu_time_sec" then return 12344
	elseif datarefname == "sim/time/local_time_sec" then return 8977
	elseif datarefname == "sim/version/xplane_internal_version" then return 120001
	elseif datarefname == "sim/graphics/view/window_width" then return 1920
	elseif datarefname == "sim/graphics/view/window_height" then return 1080
	elseif datarefname == "sim/graphics/view/window_width" then return 1920
	elseif datarefname == "sim/graphics/view/window_height" then return 1080
	else return 0 end
end

function dataref_table(datarefname, index)
	return 0
end

function dataref(datarefname, index)
	return 0
end

function logMsg(text)
	print(text)
end

function dbgMsg(text)
	if DEBUGMODE then
		print(text)
	end
end

origmetar = "EDDM 030500Z 0306/0412 25010KT 9999 SCT015 TEMPO 0312/0316 25015G25KT"
destmetar = "METAR EDDS 030550Z AUTO 21004KT 170V250 CAVOK M03/M06 Q1005 NOSIG"
altnmetar = "EDDF 031250Z AUTO 21015KT 9999 SCT019 BKN031 BKN042 M00/M04 Q1003 NOSIG"