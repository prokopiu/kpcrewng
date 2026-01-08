-- Base class for a Standard Operating Procedure 
-- A SOP will receive checklists and procedures in the sequence they are intended to be executed
--
-- @classmod ngSOP
-- @author Kosta Prokopiu
-- @copyright 2026 Kosta Prokopiu

local ngSOP = {
	flightPhaseTitles = {
	[1] = "Cold & Dark", [2] = "Prel Preflight", [3] = "Preflight/Cockpit Prep",[4] = "Before Start", 
	[5] = "After Start", [6] = "Taxi to Runway", [7] = "Before Takeoff", 	[8] = "Takeoff",
	[9] = "Climb", 		[10] = "Cruise", 		[11] = "Descent", 			[12] = "Arrival", 
	[13] = "Approach", 	[14] = "Landing", 		[15] = "Turnoff", 			[16] = "Taxi to Stand", 
	[17] = "Shutdown", 	[18] = "Turnaround", 	[19] = "Flight Planning", 	[20] = "Go Around",
	[0] = ""  }
}

--- Instantiate a new SOP
-- @param string title - Name of the SOP (also used as title)
-- @return self object
function ngSOP:new(title)
    ngSOP.__index = ngSOP
    local obj = {}
    setmetatable(obj, ngSOP)

	obj.className = "SOP"
	
    obj.title = title
	
    return obj
end

--- get classname
-- @return string "SOP"
function ngSOP:getClassName() return self.className end

--- Get title of SOP
-- @return string - title of SOP
function ngSOP:getTitle() return self.title end

--- Set the title of the SOP
-- @param string title - title for SOP
function ngSOP:setTitle(title) self.title = title end

--- Get the fightphase title per phase index
-- @param int index - index of flightphase
function ngSOP:getFlightPhaseTitle(index) return self.flightPhaseTitles[index] end
	
return ngSOP