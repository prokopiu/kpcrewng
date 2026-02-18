-- Base class for a Standard Operating Procedure 
-- A SOP will receive checklists and procedures in the sequence they are intended to be executed
--
-- @classmod ngSOP
-- @author Kosta Prokopiu
-- @copyright 2026 Kosta Prokopiu

require "kpcrew.Addon.SOP.FlightPhases"
require "kpcrew.Addon.SOP.SOPState"
local Flow = require("kpcrew.Addon.SOP.Flow")
local FlowItem = require("kpcrew.Addon.SOP.FlowItem")

local ngSOP = {}

local flowVisible = {}
local flowVisibleFull = {}

--- Instantiate a new SOP
-- @param string title - Name of the SOP (also used as title)
-- @param string filepath - Path of the SOP json definition
-- @return self object
function ngSOP:new(title, filepath)
    ngSOP.__index = ngSOP
    local obj = {}
    setmetatable(obj, ngSOP)

	obj.className = "SOP"
	
    obj.title = title
	obj.filepath = filepath
	
	obj.phase = ng_phase_flight_planning	
	obj.state = ng_sopstate_new
	obj.flows = {} -- all associated flows
	obj.activeFlow = 0

	print("+ "..obj.className.." {"..obj.title.."}")
	
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
function ngSOP:getFlightPhase() return self.phase end

--- set flight phase
-- @param int phase - set flight phase
function ngSOP:setFlightPhase(phase) self.phase = phase end

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
	    if filter ~= nil then
			if v:getClassName() == filter then cnt=cnt+1 end
		else cnt=cnt+1 end
	end
	return cnt
end

function ngSOP:getFlows() return self.flows end

function ngSOP:getActiveFlow() 
	if self.activeFlow > 0 then 
		return self.flows[self.activeFlow] 
	end
	return nil
end

function ngSOP:getActiveFlowIdx() return self.activeFlow end

function ngSOP:setActiveFlowIdx(idx) self.activeFlow = idx end

local function setFlowColor(flow)
	local mycolor = color_white

	-- basic color of flows
	if 	flow:getClassName() == "ProcedureFlow" then mycolor = color_flow_procedure
	elseif 	flow:getClassName() == "ChecklistFlow" then mycolor = color_flow_checklist
	end

	if flow:isSelected() then mycolor = color_flow_active end
	
	if flow:getState() == ng_flowstate_run then mycolor = color_flow_run end
	if flow:getState() == ng_flowstate_pause then mycolor = color_flow_pause end
	if flow:getState() == ng_flowstate_end then mycolor = color_flow_end end
	if flow:getState() == ng_flowstate_err then mycolor = color_flow_err end

	
	return mycolor
end

local function activateFlow(self,idx)
	if self.activeFlow > 0 then
		if self.flows[self.activeFlow] ~= ng_flowstate_run then
			self.flows[self.activeFlow]:setSelected(false)
			self.activeFlow = idx
			self.flows[self.activeFlow]:setSelected(true)
		end
	else
		self.activeFlow = idx
		self.flows[self.activeFlow]:setSelected(true)
	end
end

function ngSOP:reset() 
	for k, flow in ipairs(self.flows) do
		flow:setState(ng_flowstate_new)
		flow:reset()
	end
	activateFlow(self,1)
	ng_stateindex = 1
end

--- Load SOP
function ngSOP:load()
	if ng_file_exists(self.filepath) then
		local json = require "kpcrew.json"
		local file = io.open(self.filepath, "r")
		local jsonstr = ""
		for line in file:lines() do
		    jsonstr = jsonstr .. line
		end
		file:close()

		local sopjson = json.parse(jsonstr)
		
		self:setTitle(sopjson.sop.title)

		for _,flownode in pairs(sopjson.sop.flow) do
		    local flow = Flow:new(string.upper(flownode.title), loadstring("return "..flownode.phase)(), flownode.classname)
			local flowItems = flownode.flowitem
		    for _,itemnode in pairs(flownode.flowitem) do
		        local item = FlowItem:new(itemnode) --string.upper(itemnode.challenge), string.upper(itemnode.response), loadstring("return "..itemnode.role)(),
					-- itemnode.classname, itemnode.setelements, itemnode.checkelements)
		        flow:appendFlowItem(item)
		    end
		    self:appendFlow(flow)
		end
		self:reset()
	end
end

--- Output and render functions
-- @param type string - t=pure text, f=full display, i=for SOP window
function ngSOP:render(type)
	
	if type == "f" then 
		for k, flow in ipairs(self.flows) do
			if flowVisibleFull[k] == nil then flowVisibleFull[k] = true end 
			if flow:getFlightPhase() ~= nil and flow:getFlightPhase() >= 0 then
				if flow:getClassName() ~= "StateFlow" and flow:getClassName() ~= "BackgroundFlow" then 
					imgui.SetCursorPosY(imgui.GetCursorPosY() + 1)
					imgui.PushStyleColor(imgui.constant.Col.Button, setFlowColor(flow))
						imgui.PushStyleColor(imgui.constant.Col.ButtonActive, color_flow_active)
							imgui.PushStyleColor(imgui.constant.Col.ButtonHovered, color_flow_hovered)
								ng_imgui_in_button(flow:getClassName()..flow:getTitle(), 
								flow:getTitle() .. " [" .. ng_get_flight_phase_title(math.abs(flow:getFlightPhase())) .. "]", 
								950, 18, function() flowVisibleFull[k]= not flowVisibleFull[k] end)
								if flowVisibleFull[k] then flow:render("f") end
							imgui.PopStyleColor()
						imgui.PopStyleColor()
					imgui.PopStyleColor()
				end
			end
		end
	end		
	if type == "i" then 
		-- for k, flow in ipairs(self.flows) do
			-- if flow:getClassName() == "StateFlow" then -- states
				-- imgui.SetCursorPosY(imgui.GetCursorPosY() + 1)
				-- local color = color_flow_state
				-- imgui.PushStyleColor(imgui.constant.Col.Button, color)
					-- imgui.PushStyleColor(imgui.constant.Col.ButtonActive, color_flow_active)
						-- imgui.PushStyleColor(imgui.constant.Col.ButtonHovered, color_flow_hovered)
							-- ng_imgui_in_button(flow:getClassName()..flow:getTitle(), 
							-- flow:getTitle(), 445, 18, function() end)
						-- imgui.PopStyleColor()
					-- imgui.PopStyleColor()
				-- imgui.PopStyleColor()
				-- imgui.Separator()
			-- end
		-- end
		for k, flow in ipairs(self.flows) do
			if flowVisible[k] == nil then flowVisible[k] = false end 
			if flow:getFlightPhase() ~= nil and flow:getFlightPhase() >= 0 then
				if flow:getClassName() ~= "StateFlow" and flow:getClassName() ~= "BackgroundFlow" then 
					imgui.SetCursorPosY(imgui.GetCursorPosY() + 1)
					local color = setFlowColor(flow)
					ng_imgui_in_button(flow:getTitle().."toggle",flowVisible[k] and "-" or "+",15, 18, 
					function() flowVisible[k]= not flowVisible[k] end) imgui.SameLine()
					imgui.PushStyleColor(imgui.constant.Col.Button, color_red)
						ng_imgui_in_button(flow:getTitle().."reset","R",15, 18, 
						function() flow:reset() end)
					imgui.PopStyleColor()
					imgui.SameLine()
					imgui.PushStyleColor(imgui.constant.Col.Button, color)
						imgui.PushStyleColor(imgui.constant.Col.ButtonActive, color_flow_active)
							imgui.PushStyleColor(imgui.constant.Col.ButtonHovered, color_flow_hovered)
								ng_imgui_in_button(flow:getClassName()..flow:getTitle(), 
								flow:getTitle() .. " [" .. ng_get_flight_phase_title(math.abs(flow:getFlightPhase())) .. "]", 
								410, 18, function() activateFlow(self,k) end)
								if flowVisible[k] then flow:render("i") end
							imgui.PopStyleColor()
						imgui.PopStyleColor()
					imgui.PopStyleColor()
				end
			end
		end
	end		

end

return ngSOP