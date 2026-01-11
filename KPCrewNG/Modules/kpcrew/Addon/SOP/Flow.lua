-- Flow of activities during a specific phase of flight (checklist or procedure)
-- A flow registers a number of activities/tasks to be executed and checked
--
-- @classmod Flow
-- @author Kosta Prokopiu
-- @copyright 2026 Kosta Prokopiu

require "kpcrew.Addon.SOP.FlowState"
require "kpcrew.Addon.SOP.FlightPhases"
local FlowItem = require "kpcrew.Addon.SOP.FlowItem"

local ngFlow = {
	classFlow = "Flow",
	classChecklistFlow = "ChecklistFlow",
	classProcedureFlow = "ProcedureFlow",
	classBackgroundFlow = "BackgroundFlow",
	classStateFlow = "StateFlow"
}

--- Instantiate a new Flow
-- @param string title - Title of the flow
-- @param string flightPhase - the phase this flow belongs to
-- @return Flow - the created flow object
function ngFlow:new(title, flightPhase, className)
    ngFlow.__index = ngFlow
    local obj = {}
    setmetatable(obj, ngFlow)

	obj.className = className
	
    obj.title = title
	obj.state = ng_flowstate_new
	obj.flightPhase = flightPhase 
	obj.flowItems = {} -- list of FlowItems
	
	dbgMsg("+ "..obj.className.." {"..obj.title.."}")

    return obj
end

--- get classname
-- @return string "Flow"
function ngFlow:getClassName() return self.className end

--- set classname
-- @param string classname
function ngFlow:setClassName(className) self.className = className end

--- Get title of Flow
-- @return string - title of Flow
function ngFlow:getTitle() return self.title end

--- Set the title of the Flow
-- @param string title - title for Flow
function ngFlow:setTitle(title) self.title = title end

--- get state of flow
-- @return int state of flow
function ngFlow:getState() return self.state end

--- Set the state of the Flow
-- @param int state 
function ngFlow:setState(state) self.state = state end

--- get associated flightphase
-- @return int flightphase of flow
function ngFlow:getFlightPhase() return self.flightPhase end

--- Set the flightphase of the Flow
-- @param int phase 
function ngFlow:setState(phase) self.flightPhase = phase end

--- Add a flow item to Flow
-- @param FlowItem flowItem - flow item to be appended to flow
function ngFlow:appendFlowItem(flowItem) table.insert(self.flowItems,flowItem) end

--- Insert a flow item at specific position
-- @param FlowItem flowItem - flow item to be inserted
-- @param int index - index at which to add
function ngFlow:insertFlowItem(flowItem, index) table.insert(self.flowItems,index,flowItem) end
	
--- Get a specific flow item based on index
-- @param int index - flow item's' index in table
-- @return FlowItem - flow item at index
function ngFlow:getFlowItem(index) return self.items[index] end

--- Get filtered number of flow items
-- @param string filter - filter by classname (optional)
-- @return int - number of flow items
function ngFlow:getNumberFlowItems(filter)
	local cnt = 0
	for k,v in pairs(self.flowItems) do
	    if filter ~= nil and v:getClassName() == filter then cnt=cnt+1 end
	end
	return cnt
end

-- Output and render functions

function ngFlow:render(type)
	local textout = ""
	if type == "t" then
		textout = "Flow: "..self.title
		print(textout)
	else
		kc_imgui_out_text(color_white, "Flow: "..self.title)
	end
	for k,v in pairs(self.flowItems) do
	    v:render(type)
	end
end

return ngFlow