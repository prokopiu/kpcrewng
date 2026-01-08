-- simulate x-plane and flywithlua functions and variables

SCRIPT_DIRECTORY = "/home/kosta/eclipse-workspace/KPCrewNG/Scripts/"
 
local dataref_local_store = {
	["sim/operation/prefs/text_out"] = 0,
	["sim/flightmodel/position/latitude"] = 48.124, 
	["sim/flightmodel/position/longitude"] = 10.43,
	["sim/cockpit2/autopilot/altitude_readout_preselector"] = 10000,
	["sim/time/zulu_time_sec"] = 12344,
	["sim/time/local_time_sec"] = 8977,
	["sim/version/xplane_internal_version"] = function () return 130000+1 end,
	["sim/graphics/view/window_width"] = 1920,
	["sim/graphics/view/window_height"] = 1080,
	["sim/graphics/view/window_width"] = 1920,
	["sim/graphics/view/window_height"] = 1080}

function get(datarefname, index)
	if index ~= nil then
		if type(dataref_local_store[datarefname.."["..index.."]"]) == 'function' then
			return dataref_local_store[datarefname.."["..index.."]"]()
		else
			return dataref_local_store[datarefname.."["..index.."]"]
		end
	else
		if type(dataref_local_store[datarefname]) == 'function' then
			return dataref_local_store[datarefname]()
		else
			return dataref_local_store[datarefname]
		end
		return dataref_local_store[datarefname]
	end
end

function dataref_table(datarefname, index)
	return 0
end

function dataref(datarefname, index)
	return 0
end

function set(datarefname, value)
	dataref_local_store[datarefname] = value
end
	
function set_array(datarefname, index, value)
	dataref_local_store[datarefname.."["..index.."]"] = value
end
	
function logMsg(text)
	print(text)
end

function dbgMsg(text)
	if DEBUGMODE then
		print(text)
	end
end

function renderDataRefs()
	dbgMsg("===== datarefs =====")
	for k, v in pairs(dataref_local_store) do
		if type(v) == 'function' then dbgMsg(k.."="..v()) else dbgMsg(k.."="..v) end  
	end
end


origmetar = "EDDM 030500Z 0306/0412 25010KT 9999 SCT015 TEMPO 0312/0316 25015G25KT"
destmetar = "METAR EDDS 030550Z AUTO 21004KT 170V250 CAVOK M03/M06 Q1005 NOSIG"
altnmetar = "EDDF 031250Z AUTO 21015KT 9999 SCT019 BKN031 BKN042 M00/M04 Q1003 NOSIG"