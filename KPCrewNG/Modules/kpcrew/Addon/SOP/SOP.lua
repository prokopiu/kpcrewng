-- Base class for a Standard Operating Procedure 
-- A SOP will receive checklists and procedures in the sequence they are intended to be executed
--
-- @classmod ngSOP
-- @author Kosta Prokopiu
-- @copyright 2026 Kosta Prokopiu

require "kpcrew.Addon.SOP.FlightPhases"
require "kpcrew.Addon.SOP.SOPState"

local ngSOP = {}

--- Instantiate a new SOP
-- @param string title - Name of the SOP (also used as title)
-- @return self object
function ngSOP:new(title)
    ngSOP.__index = ngSOP
    local obj = {}
    setmetatable(obj, ngSOP)

	obj.className = "SOP"
	
    obj.title = title
	
	obj.currentPhase = ng_phase_flight_planning	
	obj.state = ng_sopstate_new
	obj.flows = {} -- all associated flows
	
	dbgMsg("+ "..obj.className.." {"..obj.title.."}")
	
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

-- get the index of the current flightphase
-- @return int - index of current flightphase
function ngSOP:getFlightPhase() return self.currentPhase end

--- set flight phase
-- @param int phase - set flight phase
function ngSOP:setFlightPhase(phase) self.currentPhase = phase end

--- get state of sop
-- @return int state of sop
function ngSOP:getState() return self.state end

--- Set the state of the SOP
-- @param int state 
function ngSOP:setState(state) self.state = state end

--- Add a flow to SOP
-- @param Flow flow - flow to be appended to SOP flows
function ngSOP:appendFlow(flow) table.insert(self.flows,flow) end

--- Insert a flow at specific position
-- @param Flow flow - flow to be inserted to SOP flows
-- @param int index - index at which to add
function ngSOP:insertFlow(flow, index) table.insert(self.flows,index,flow) end
	
--- Get a specific flow based on index
-- @param int index - flows index in table
-- @return flow - flow at index
function ngSOP:getFlow(index) return self.flows[index] end

--- Get filtered number of flows
-- @param string filter - filter by classname (optional)
-- @return int - number of flows
function ngSOP:getNumberFlows(filter)
	local cnt = 0
	for k,v in pairs(self.flows) do
	    if filter ~= nil and v:getClassName() == filter then cnt=cnt+1 end
	end
	return cnt
end

-- Output and render functions

function ngSOP:render(type)
	local textout = ""
	if  type == "t" then
		textout = "SOP: "..self.title
		print(textout)
	else
		kc_imgui_out_text(color_white, "SOP: "..self.title)
	end
	for k,v in ipairs(self.flows) do
	    v:render(type)
	end
end

return ngSOP