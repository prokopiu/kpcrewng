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
	classInfoLine			= "InfoLine"
}

--- Instantiate a new FlowItem
-- @param table flowitem - Role index
-- @return FlowItem - the created flowItem object
function ngFlowItem:new(flowitem)
    ngFlowItem.__index = ngFlowItem
    local obj = {}
    setmetatable(obj, ngFlowItem)

	-- default classname ProcedureItem
	obj.className = "ProcedureItem"
	if flowitem.classname ~= nil then
		obj.className = flowitem.classname
	end
	
	obj.item = flowitem
	obj.delay = 0
		
	obj.state = ng_fistate_new

	dprint("+ "..obj.className.." {"..obj.item.challenge.."}")
	
    return obj
end

--- get classname
-- @return string className
function ngFlowItem:getClassName() return self.className end

--- set classname
-- @param string classname
function ngFlowItem:setClassName(className) self.classname = className end

--- get challenge string
-- @return string - challenge text
function ngFlowItem:getChallenge() return self.item.challenge end

--- set challenge string
-- @param string text - challenge text
function ngFlowItem:setChallenge(text) self.item.challenge = text end

--- get response string
-- @return string - response text
function ngFlowItem:getResponse() return self.item.response end

--- set response string
-- @param string text - response text
function ngFlowItem:setResponse(text) self.item.response = text end

--- get state of flow
-- @return int state of flowItem
function ngFlowItem:getState() return self.state end

--- Set the state of the FlowItem
-- @param int state 
function ngFlowItem:setState(state) self.state = state end

--- get role of flowItem
-- @return string role
function ngFlowItem:getRole() return loadstring(self.item.role) end

function ngFlowItem:getSetElements() return self.item.setElements end

function ngFlowItem:getCheckElements() return self.item.checkElements end

function ngFlowItem:setItemNode(item) self.item = item end

function ngFlowItem:getItemNode(item) return self.item end

--- Get delays after this step in seconds
-- @return int delay seconds
function ngFlowItem:getDelay() return self.delay end

--- Set delay of item in seconds
-- @param int delay in seconds
function ngFlowItem:setDelay(delay) self.delay = delay end

--- Determine if the item must be skipped due to condition set
-- @return true skip during execution
function ngFlowItem:isToSkip() 
	if self.item.condition ~= nil then
		return loadstring(self.item.condition)() == false
	else
		return false
	end
end

--- Is the role the sim user CPT/CM1/PF....
-- @return bool - is LHS/CPT
function ngFlowItem:isSimUser() 
	if self.item.role == "ng_firole_PF" or
	   self.item.role == "ng_firole_CPT" or
	   self.item.role == "ng_firole_BOTH" or
	   self.item.role == "ng_firole_LHS" or
	   self.item.role == "ng_firole_CM1" or
	   self.item.role == "ng_firole_ALL" then return true else return false end
end

-- Output and render functions

--- return the visual line of text to put in a checklist displays
-- @param FlowItem flowItem - item from which to get the line
-- @param int linelength in chars - needed to calculate dots 
function ngFlowItem:getLine(lineLength)
	local line = {}
	local unparsedChallengeText = ng_unparse_string(self.item.challenge)
	local unparsedResponseText = ng_unparse_string(self.item.response)
	local dots = lineLength - string.len(unparsedChallengeText) - string.len(unparsedResponseText) - 7
	line[#line + 1] = unparsedChallengeText
	local dotchar = "."
	if unparsedResponseText == "" then dotchar = " " end
	for i=0,dots-1,1 do line[#line + 1] = dotchar end
	line[#line + 1] = unparsedResponseText
	if self.role ~= 0 then
		line[#line + 1] = " (" 
		line[#line + 1] = ng_flowItemRoles[loadstring("return "..self.item.role)()]
		line[#line + 1] = ")"
	end
	
	return table.concat(line)
end

local function setItemColor(item)
	
	local mycolor = color_white
	if item:getClassName() == "ProcedureItem" then mycolor = color_step_procitem 
	elseif item:getClassName() == "ChecklistItem" then mycolor = color_step_checkitem 
	end
	
	if item:getState() == ng_fistate_run then mycolor = color_flow_run end
	if item:getState() == ng_fistate_end then mycolor = color_flow_end end
	if item:getState() == ng_fistate_pause then mycolor = color_flow_pause end
	if item:getState() == ng_fistate_err then mycolor = color_red end

	return mycolor
end

function ngFlowItem:getColor()
	return setItemColor()
end


function ngFlowItem:render(type)
	if type == "f" then
		imgui.TableNextRow();
		if self:isSimUser() then
			imgui.TableSetColumnIndex(0) ng_imgui_out_text(setItemColor(self), self:getLine(60))
			imgui.TableSetColumnIndex(1) ng_imgui_out_text(setItemColor(self), "")
		else
			imgui.TableSetColumnIndex(1) ng_imgui_out_text(setItemColor(self), self:getLine(60))
			imgui.TableSetColumnIndex(0) ng_imgui_out_text(setItemColor(self), "")
		end
	end
	if type == "i" then
		if self:isSimUser() then
			ng_imgui_out_text(setItemColor(self), self:getLine(59))
		else
			ng_imgui_out_text(setItemColor(self), "  "..self:getLine(59))
		end
	end 
end

return ngFlowItem