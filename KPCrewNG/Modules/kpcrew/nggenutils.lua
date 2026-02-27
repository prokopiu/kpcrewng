--[[
	*** KPCREWNG 0.1 
	General utilities used in kpcrew
	Kosta Prokopiu, 2026
--]]

-- -------------- General functions -----------------

function dprint(text)
	if DEBUGMODE then print(text) end
end
		
-- ----------- Simulator functionality --------------

--- speak text but don't show in sim, speakMode is used to prevent repetitive playing
-- @param int speakMode - 1 will talk and show, 0 will only speak
-- @param string text - text to speak
function ng_speakNoText(speakMode, text)
	if text ~= "" and text ~= nil then
	
		if speakMode == 0 then
			set("sim/operation/prefs/text_out",0)
			XPLMSpeakString(text)
		else	
			set("sim/operation/prefs/text_out",1)
			XPLMSpeakString(text)
		end
	end
end

-- ----------- file related functions ---------------

--- check if external lua file exists
-- @param string name path and filename to search
-- @return true/false for existance
function ng_file_exists(name)
	local f=io.open(name,"r")
	if f~=nil then io.close(f) return true else return false end
end

-- ----------- coordinates related functions ---------------

--- convert a coordinate from x-plane to deg,min,sec format
-- @param float coordinate - x-plane coordinate
-- @return string coordinate string
function ng_toDegMinSec(coordinate) 
    local absolute = math.abs(coordinate);
    local degrees  = math.floor(absolute);
    local minutesNotTruncated = (absolute - degrees) * 60;
    local minutes  = math.floor(minutesNotTruncated);
    local seconds  = math.floor((minutesNotTruncated - minutes) * 60);

    return degrees .. "°" .. minutes .. "'" .. seconds .. "\"";
end

--- convert coordinates to CIVA INS format
-- @param float coordinate - x-plane coordinate
-- @return string coordinate string
function ng_toDMS1(coordinate) 
    local absolute = math.abs(coordinate);
    local degrees  = math.floor(absolute);
    local minutesNotTruncated = (absolute - degrees) * 60;
    local minutes  = math.floor(minutesNotTruncated);
    local seconds  = math.floor((minutesNotTruncated - minutes) * 60);

    return string.format("%2.2i%2.2i%1.1i",degrees,minutes,seconds/10);
end

--- convert a coordinate from x-plane to INS [N/S|E/W]ddmms format
-- @param float lat - x-plane coordinate latitude
-- @param float lng - x-plane coordinate longitude
-- @return string coordinate string
function ng_convertINS(lat, lng) 
    local latitude = ng_toDMS1(lat);
    local latitudeCardinal = (lat >= 0) and "N" or "S";

    local longitude = ng_toDMS1(lng);
    local longitudeCardinal = (lng >= 0) and "E" or "W";

    return string.format("%s%s %s%s",latitudeCardinal,latitude,longitudeCardinal,longitude);
end

--- convert position to full coordinate string with N/S and E/W
-- @param float lat - x-plane coordinate latitude
-- @param float lng - x-plane coordinate longitude
-- @return string coordinate string
function ng_convertDMS(lat, lng) 
    local latitude = ng_toDegMinSec(lat);
    local latitudeCardinal = (lat >= 0) and "N" or "S";

    local longitude = ng_toDegMinSec(lng);
    local longitudeCardinal = (lng >= 0) and "E" or "W";

    return latitude .. " " .. latitudeCardinal .. " - " .. longitude .. " " .. longitudeCardinal;
end

------------- time related functions ---------------

--- return a full time string from given time in seconds of day
-- @param int timeseconds
-- @return string time string
function ng_dispTimeFull(timeseconds)
	local lhours = math.floor(timeseconds/3600)
	local lminutes = math.floor((timeseconds - lhours * 3600)/60)
	local lsec = math.floor(timeseconds - (lhours * 3600) - (lminutes * 60))
	return string.format("%2.2i:%2.2i:%2.2i",lhours,lminutes,lsec)
end

--- return a hh:mm string from given time in seconds of day
-- @param int timeseconds
-- @return string time string
function ng_dispTimeHHMM(timeseconds)
	local lhours = math.floor(timeseconds/3600)
	local lminutes = math.floor((timeseconds - lhours * 3600)/60)
	return string.format("%2.2i:%2.2i",lhours,lminutes)
end

--- Gets the current time. (patrickl92)
-- The function uses the <code>gettime()</code> function of LuaSocket, which provides the current time with seconds resolution.
-- @treturn number The current time.
function ng_getPcTime()
	return socket.gettime()
end

--- is daylight = true
-- @return true if daylight, false if towards darkness
function ng_is_daylight()
	local lightthreshold = 0
	if ng_simversion > 120000 then
		lightthreshold = 0.1
	else
		lightthreshold = 0.1
	end
	if get("sim/private/stats/skyc/sun_amb_b") < lightthreshold then
		return false
	else
		return true
	end
end


-------------- Array/Table related functions -------------

--- Split string with delimiter
-- @param string s input string
-- @param string delimiter character
-- @return array string
function ng_split(s, delimiter)
    result = {};
    for match in (s..delimiter):gmatch("(.-)"..delimiter) do
        table.insert(result, match);
    end
    return result;
end

--- Split preference title | delimiter
-- @param string s input string
-- @return array string
function ng_pref_split(s)
	return ng_split(s,"|")
end

--- return index position of value in an array
-- @param array - the array
-- @param value - value to serach for in the array
-- @return int index
function ng_indexOf(array, value)
    for i, v in ipairs(array) do if v == value then return i end end
    return nil
end

function ng_pairsByKeys (t)
  local a = {}
  for k,n in pairs(t) do table.insert(a, k) end
  table.sort(a)
  local i = 0      -- iterator variable
  local iter = function ()   -- iterator function
    i = i + 1
    if a[i] == nil then return nil
    else return a[i], t[a[i]]
    end
  end
  return iter
end

function ng_tableCount (t)
	local count = 0
	for _,tn in pairs(t) do
		count = count + 1
	end
	return count
end 

--- see if a value is found in given array
-- @param array array, array to check vaöue in
-- @param object value, value to check against
-- @return book - true was found in table 
function ng_hasValue (array, value)
    for i, v in ipairs(array) do
        if v == value then
            return true
        end
    end
    return false
end

-------------- string related functions ------------------

--- parse string for function macros and replace for spoken text
-- @param string instring - string to unparse
function ng_unparse_string(instring)
	local outstring = ""
	local elements = ng_split(instring,"#")
	for _, item in ipairs(elements) do
		local pitem = ""
		if string.sub(item,1,6) == "spell|" then
			pitem = ng_split(item,"|")[2]
		elseif string.sub(item,1,5) == "nato|" then
			pitem = ng_split(item,"|")[2]
		elseif string.sub(item,1,4) == "rwy|" then
			pitem = ng_split(item,"|")[2]
		elseif string.sub(item,1,9) == "exchange|" then
			pitem = ng_split(item,"|")[2]
		else
			pitem = item
		end
		outstring = outstring .. pitem
	end
	return outstring
end

-------------- process variable related utilities ---------------

--- does procvar exist?
-- @param string procvarid - identifier for procvar
-- @return bool - true if exists
function ng_procvar_exists(procvarid)
	local procvar = getBckVars():find("procvars:" .. procvarid)
	if procvar == nil then return false else return true end
end
	
--- toggle a boolean procvar
-- @param string procvarid - identifier for procvar
function ng_procvar_toggle(procvarid)
	local procvar = getBckVars():find("procvars:" .. procvarid)
	if procvar:getValue() == true then 
		procvar:setValue(false)
	else
		procvar:setValue(true)
	end
end

--- set a procvar
-- @param string procvarid - identifier for procvar
-- @param string value - value to set
function ng_procvar_set(procvarid, value)
	local procvar = getBckVars():find("procvars:" .. procvarid)
	procvar:setValue(value)
end

--- initialize a boolean procvar
-- @param string procvarid - identifier for procvar
-- @param bool value - value to set
function ng_procvar_initialize_bool(procvarid, value)
	local procvar = getBckVars():find("procvars:" .. procvarid)
	if procvar == nil then 
		ng_global_procvars:add(kcPreference:new(procvarid,value,kcPreference.typeToggle,procvarid .. "|TRUE|FALSE"))
	else
		ng_procvar_set(procvarid,value)
	end
end

--- initialize a counter procvar
-- @param string procvarid - identifier for procvar
-- @param int value - value to set
function ng_procvar_initialize_count(procvarid, value)
	local procvar = getBckVars():find("procvars:" .. procvarid)
	if procvar == nil then 
		ng_global_procvars:add(kcPreference:new(procvarid,value,kcPreference.typeInt,procvarid .. "|0"))
	else
		ng_procvar_set(procvarid,value)
	end
end

--- initialize a string procvar
-- @param string procvarid - identifier for procvar
-- @param string value - value to set
function ng_procvar_initialize_string(procvarid, value)
	local procvar = getBckVars():find("procvars:" .. procvarid)
	if procvar == nil then 
		ng_global_procvars:add(kcPreference:new(procvarid,value,kcPreference.typeText,procvarid .. "|"))
	else
		ng_procvar_set(procvarid,value)
	end
end

--- get boolean procvar
-- @param string procvarid - identifier for procvar
-- @return bool - true or false
function ng_procvar_get(procvarid)
	local procvar = getBckVars():find("procvars:".. procvarid)
	return procvar:getValue()
end

---------------------- File related functions
--- find latest file in folder for XP12 weather
function ng_get_latest_filename(folder)
	local command = ""
	if SYSTEM == "IBM" then
    	command = 'dir /a-d /o-n /tc /b "'.. folder ..'" 2>nul:'
	else
		command = "ls -Art ".. folder .. " | tail -n 1 "
	end
    local pipe = io.popen(command)
    local filename = pipe:read()
    pipe:close()
    return filename
end

---------------------- Weather related function ------

-- pull the METAR from XP's METAR.wx when on real weather
-- sim/weather/use_real_weather_bool
function ng_get_xp_metar(icao)

    if not icao then return "-- NO ICAO --" end
	
	metarpath = "no"
	
	if ng_simversion > 120000 then
		if SYSTEM == "LIN" then
			latestwxfile = ng_get_latest_filename(SYSTEM_DIRECTORY .. "Output/real\\ weather/metar*")
		else
			latestwxfile = ng_get_latest_filename(SYSTEM_DIRECTORY .. "Output\\real weather\\metar*")
		end
		if latestwxfile == nil then return "-- NO FILES --" end
		if SYSTEM == "LIN" then
			metarpath = SYSTEM_DIRECTORY .. "Output/real\\ weather/" .. latestwxfile
		else
			metarpath = SYSTEM_DIRECTORY .. "Output\\real weather\\" .. latestwxfile
		end
	else
		metarpath = SYSTEM_DIRECTORY .. "METAR.rwx"
	end

    if not ng_file_exists(metarpath) then return "-- NO FILE --" end

    local words = {}
    --we read the lines
    if icao then
        for line in io.lines(metarpath) do
            if line then
                words[1] = line:match("(%w+)(.+)")
                if words[1] == icao then
                    wx = line
                    break
                end
            end 
        end 
        if wx == nil then return "-- NO DATA -- " end
		return wx
    else return "-- NO ICAO --" end
end 

