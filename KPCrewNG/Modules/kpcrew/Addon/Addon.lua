-- Base class for addon aircraft, covering all aspects like SOP, Flight, Briefing, Systems, ...
--
-- @classmod Addon
-- @author Kosta Prokopiu
-- @copyright 2026 Kosta Prokopiu

require "kpcrew.nggenutils"

local ngAddon = {
}

--- Instantiate a new Addon
-- @param string icao - icao of the addon for distinction
-- @param string title - Title of the addon
-- @return self object
function ngAddon:new(icao, title)
    ngAddon.__index = ngAddon
    local obj = {}
    setmetatable(obj, ngAddon)

	obj.className = "Addon"
	
    obj.title = title
	obj.icao = icao
	
	obj.sop = nil -- the SOP associated to this Addon
	obj.preferences = nil -- addon specific preferences
	obj.briefing = nil -- briefing
	obj.systems = nil -- systems

	if DEBUGMODE then logMsg("+ "..obj.className.." {"..obj.icao..","..obj.title.."}") end

    return obj
end

--- get classname
-- @return string "Addon"
function ngAddon:getClassName() return self.className end

--- Get title of Addon
-- @return string - title of Addon
function ngAddon:getTitle() return self.title end

--- Set the title of the Addon
-- @param string title - title for Addon
function ngAddon:setTitle(title) self.title = title end

--- Get icao of Addon
-- @return string - icao of Addon
function ngAddon:getIcao() return self.icao end

--- Set the icao of the Addon
-- @param string icao - icao for Addon
function ngAddon:setIcao(icao) self.icao = icao end

--- Get SOP of Addon
-- @return SOP - Associated SOP
function ngAddon:getSop() return self.sop end

--- Set the SOP of the Addon
-- @param SOP sop - SOP for Addon
function ngAddon:setSop(sop) self.sop = sop end

--- Get Aircraft Prefs
-- @return PreferenceSet - Associated preferences
function ngAddon:getPreferences() return self.preferences end

--- Set Aircraft preferences
-- @param PreferenceSet set - SOP for Addon
function ngAddon:setPreferences(set) self.preferences = set end

--- Get Briefing Prefs
-- @return PreferenceSet - Associated briefing
function ngAddon:getBriefing() return self.briefing end

--- Set Briefing preferences
-- @param PreferenceSet set - Briefing for Addon
function ngAddon:setBriefing(set) self.briefing = set end

--- Get Systems 
-- @return Systems - Associated acf systems
function ngAddon:getSystems() return self.systems end

--- Set Systems
-- @param Systems set - Systems for Addon
function ngAddon:setSystems(systems) self.systems = systems end
	
return ngAddon