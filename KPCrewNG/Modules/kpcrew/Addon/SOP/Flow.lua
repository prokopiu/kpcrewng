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
	classBackgroundFlow = "BackgroundFlow"
}

--- Instantiate a new Flow
-- @param string title - Title of the flow
-- @param string flightphase - the phase this flow belongs to
-- @@param string optional classname
-- @return Flow - the created flow object
function ngFlow:new(title, flightphase, classname)
    ngFlow.__index = ngFlow
    local obj = {}
    setmetatable(obj, ngFlow)

	obj.className = classname
	
    obj.title = title
	obj.state = ng_flowstate_new
	obj.flightphase = flightphase 
	obj.items = {} -- list of flow items
	obj.activeItem = 0
	obj.selected = false

	dprint("+ "..obj.className.." {"..obj.title.."}")
	
    return obj
end

--- get classname
-- @return string "Flow"
function ngFlow:getClassName() return self.className end

--- set classname
-- @param string classname
function ngFlow:setClassName(className) self.className = classname end

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
function ngFlow:getFlightPhase() return self.flightphase end

--- Set the flightphase of the Flow
-- @param int phase 
function ngFlow:setPhase(phase) self.flightphase = phase end

--- Add a flow item to Flow
-- @param FlowItem flowItem - flow item to be appended to flow
function ngFlow:appendFlowItem(flowItem) table.insert(self.items,flowItem) end

--- Insert a flow item at specific position
-- @param FlowItem flowItem - flow item to be inserted
-- @param int index - index at which to add
function ngFlow:insertFlowItem(flowItem, index) table.insert(self.items,index,flowItem) end
	
--- Get a specific flow item based on index
-- @param int index - flow item's' index in table
-- @return FlowItem - flow item at index
function ngFlow:getFlowItem(index) return self.items[index] end

--- Get filtered number of flow items
-- @param string filter - filter by classname (optional)
-- @return int - number of flow items
function ngFlow:getNumberItems(filter)
	local cnt = 0
	for k,v in pairs(self.items) do
	    if filter ~= nil and v:getClassName() == filter then cnt=cnt+1 end
	end
	return cnt
end

--- get table of flow items
-- @return table of flow items
function ngFlow:getItems() return self.items end

--- get the index of the active flow item
-- @return int index of active flow item
function ngFlow:getActiveItemIdx() return self.activeItem end

--- make flow item at index active
-- @param int index of flow item to activate
function ngFlow:setActiveItemIdx(idx) if idx <= #self.items then self.activeItem = idx end end

--- is this flow the selcted flow
-- @return bool true/false
function ngFlow:isSelected() return self.selected end

--- Set the selected flag of this flow
-- @param bool true/false
function ngFlow:setSelected(flag) self.selected = flag end

--- get the complete active flow item
-- @return table - active flow item or nil if none
function ngFlow:getActiveItem()
	if self.activeItem > 0 then return self.items[self.activeItem] end
	return nil
end

--- reset this flow by resetting all flow items
function ngFlow:reset() 
	if self.state ~= ng_flowstate_new then
		for k, item in ipairs(self.items) do item:setState(ng_flowstate_new) end
		self.state = ng_flowstate_new
		self.activeItem = 0
		ng_stateindex = 0
	end
end

-- Output and render functions

--- render the items of this flow
-- @param char "f"=SOP View 2 columns, "i"=SOP window view 
function ngFlow:render(type)
	if type == "f" then
		imgui.BeginTable(self:getTitle(),2,color_white)
		if FLYWITHLUA then
			imgui.TableHeadersRow()
		else
			imgui.TableSetupColumn("CM1",1)
			imgui.TableSetupColumn("CM2",1)
			imgui.TableHeadersRow()
		end
		for _, item in pairs(self.items) do
			if item:getItemNode().condition ~= nil then
				if loadstring("return "..item:getItemNode().condition)() then 
					item:render("f")
				end
			else
				item:render("f")
			end
		end
		imgui.EndTable()
	end
	if type == "i" then
		for _, item in pairs(self.items) do
			if item:getItemNode().condition ~= nil then
				if loadstring("return "..item:getItemNode().condition)() then 
					item:render("i")
				end
			else
				item:render("i")
			end
		end
	end
end

return ngFlow