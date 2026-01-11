-- A flow item is a single step in a flow (checklist, ....)
--
-- @classmod FlowItem
-- @author Kosta Prokopiu
-- @copyright 2026 Kosta Prokopiu

require "kpcrew.Addon.SOP.FlowItemState"
require "kpcrew.Addon.SOP.FlowItemRole"

local ngFlowItem = {
	classFlowItem 			= "FlowItem",
	classChecklistItem 		= "ChecklistItem",
	classProcedureItem 		= "ProcedureItem",
	classBackgroundItem 	= "BackgroundItem",
	classStateItem 			= "StateItem",
}

--- Instantiate a new FlowItem
-- @param string challenge - left side of the item
-- @param string response - right side of the item
-- @param int role - Role index
-- @return FlowItem - the created flowItem object
function ngFlowItem:new(challenge, response, role, className)
    ngFlowItem.__index = ngFlowItem
    local obj = {}
    setmetatable(obj, ngFlowItem)

	if classname == nil then
		obj.className = "ProcedureItem"
	else
		obj.className = className
	end
	
    obj.challenge = challenge
	obj.response = response
	obj.role = role 
		
	obj.state = ng_fistate_new
	
	dbgMsg("+ "..obj.className.." {"..obj.challenge..".."..obj.response.."}")

    return obj
end

--- get classname
-- @return string className
function ngFlowItem:getClassName() return self.className end

--- set classname
-- @param string classname
function ngFlowItem:setClassName(className) self.className = className end

--- get challenge string
-- @return string - challenge text
function ngFlowItem:getChallenge() return self.challenge end

--- set challenge string
-- @param string text - challenge text
function ngFlowItem:setChallenge(text) self.challenge = text end

--- get response string
-- @return string - response text
function ngFlowItem:getResponse() return self.response end

--- set response string
-- @param string text - response text
function ngFlowItem:setResponse(text) self.response = text end

--- get state of flow
-- @return int state of flowItem
function ngFlowItem:getState() return self.state end

--- Set the state of the FlowItem
-- @param int state 
function ngFlowItem:setState(state) self.state = state end

--- get role of flowItem
-- @return string role
function ngFlowItem:getRole() return self.role end

--- Set the role of the FlowItem
-- @param string role 
function ngFlowItem:setRole(role) self.role = role end

--- Is the role the sim user CPT/CM1/PF....
-- @return bool - is LHS/CPT
function ngFlowItem:isSimUser() 
	if self.role == actorPF or
	   self.role == actorCPT or
	   self.role == actorBoth or
	   self.role == actorLHS or
	   self.role == actorCM1 or
	   self.role == actorALL then return true else return false end
end

-- Output and render functions

function ngFlowItem:render(type)
	local textout = ""
	if type == "t" then
		textout = "FlowItem: "..self.challenge.."..........."..self.response
		print(textout)
	else
		kc_imgui_out_text(color_white, "FlowItem: "..self.challenge.."..........."..self.response.." ("..ng_get_firole(self.role)..")")
	end
end

return ngFlowItem