-- Base class for a Standard Operating Procedure 
-- A SOP will receive checklists and procedures in the sequence they are intended to be executed
--
-- @classmod kcSOP
-- @author Kosta Prokopiu
-- @copyright 2026 Kosta Prokopiu

local kcSOP = {
}

local Flow				= require "kpcrew.Flow"

kcSopFlightPhase = { [1] = "Cold & Dark", 	[2] = "Prel Preflight", [3] = "Preflight/Cockpit Prep",[4] = "Before Start", 
 					 [5] = "After Start", 	[6] = "Taxi to Runway", [7] = "Before Takeoff", 	[8] = "Takeoff",
 					 [9] = "Climb", 		[10] = "Cruise", 		[11] = "Descent", 			[12] = "Arrival", 
 					 [13] = "Approach", 	[14] = "Landing", 		[15] = "Turnoff", 			[16] = "Taxi to Stand", 
 					 [17] = "Shutdown", 	[18] = "Turnaround", 	[19] = "Flight Planning", 	[20] = "Go Around",
 					 [0] = ""  }
 					 
 kc_phase_colddark			= 1
 kc_phase_prel_preflight	= 2
 kc_phase_preflight 		= 3
 kc_phase_before_start		= 4
 kc_phase_after_start		= 5
 kc_phase_taxi_rwy			= 6
 kc_phase_before_takeoff	= 7
 kc_phase_takeoff			= 8
 kc_phase_climb 			= 9
 kc_phase_enroute			= 10
 kc_phase_descent 			= 11
 kc_phase_arrival 			= 12
 kc_phase_approach 			= 13
 kc_phase_landing 			= 14
 kc_phase_afterland 		= 15
 kc_phase_taxi_stand 		= 16
 kc_phase_shutdown 			= 17
 kc_phase_turnaround 		= 18
 kc_phase_flight_plan		= 19
 kc_phase_go_around			= 20

--- Instantiate a new preference set
-- @param string name - Name of the SOP (also used as title)
-- @return self object
function kcSOP:new(name)
    kcSOP.__index = kcSOP
    local obj = {}
    setmetatable(obj, kcSOP)

    obj.name = name
    obj.checklists = {} -- separate list of only checklists
    obj.procedures = {} -- Separate list of only procedures
	obj.states = {} -- states
	obj.flows = {} -- combined list of flows (chkl & proc) in sequence
	obj.activeFlowIndex = 1
	obj.activeChecklistIndex = 1
	obj.activeProcedureIndex = 1
    obj.bgrOnDemandFlow = nil
	
    return obj
end

--- Get name/title of SOP
-- @return string - name of SOP
function kcSOP:getName()
    return self.name 
end

--- Set the name of the SOP
-- @param string newname - new name for SOP
function kcSOP:setName(newname)
    self.name = newname
end

--- Get the textual representation for the requested fligth phase
-- @param int phase - index of phase
-- @return string - phase name 
function kcSOP:getPhaseString(phase)
	if phase ~= nil and phase >= 0 then return kcSopFlightPhase[math.abs(phase)] end
	return "" -- if not found
end

--- Add a checklist object to checklists and flows
-- @param kcChecklist - checklist to add
function kcSOP:addChecklist(checklist)
    table.insert(self.checklists, checklist)
    table.insert(self.flows, checklist)
end

--- Add a procedure object to checklists and flows
-- @param kcProcedure - procedure to add
function kcSOP:addProcedure(procedure)
    table.insert(self.procedures, procedure)
    table.insert(self.flows, procedure)
end

--- Add a state 
-- @param kcState - state procedure 
function kcSOP:addState(state)
    table.insert(self.states, state)
    table.insert(self.flows, state)
end

--- Add the background procedure
-- @param kcBackground bflow - background procedure to add
function kcSOP:addBackground(bflow)
    self.bgrOnDemandFlow = bflow
end

--- Return all registered checklists in sequence
-- @return list of kcChecklist objects
function kcSOP:getAllChecklists()
    return self.checklists
end

--- Return all registered procedures in sequence
-- @return list of kcProcedure 
function kcSOP:getAllProcedures()
    return self.procedures
end

--- Return all registered states
-- @return list of kcProcedure for states
function kcSOP:getAllStates()
    return self.states
end

--- Return background flow
-- @return Background 
function kcSOP:getBackgroundFlow()
    return self.bgrOnDemandFlow
end

--- Return all registered flows (chkl & proc) in sequence
-- @return list of kcChecklist and kcProcedure objects
function kcSOP:getAllFlows()
	return self.flows
end

--- Return a list of flow titles to display
-- @return list of string
function kcSOP:getFlowNames()
	local names = {}
	for _, flow in ipairs(self.flows) do
		table.insert(names, flow:getName())
	end
	return names
end

--- Return a list of state titles to display
-- @return list of strings
function kcSOP:getStateNames()
	local names = {}
	for _, state in ipairs(self.states) do
		table.insert(names, state:getName())
	end
	return names
end

--- set the active flow index directly
-- @param int flowIndex - index of flow to activate
function kcSOP:setActiveFlowIndex(flowIndex)   
	if flowIndex >= 1 and flowIndex <= #self.flows then
		self.activeFlowIndex = flowIndex
	else
		return -1
    end
end

--- set the active checklist index directly
-- @param int flowIndex - index of checklist to activate
function kcSOP:setActiveChecklistIndex(flowIndex)   
	if flowIndex >= 1 and flowIndex <= #self.flows then
		self.activeChecklistIndex = flowIndex
	else
		return -1
    end	
end

--- set the active procedure index directly
-- @param int flowIndex - new index of procedure to activate 
function kcSOP:setActiveProcedureIndex(flowIndex)   
	if flowIndex >= 1 and flowIndex <= #self.flows then
		self.activeProcedureIndex = flowIndex
	else
		return -1
    end	
end

--- return the currently active flow in the SOP
-- @return kcProcedure or kcChecklist object
function kcSOP:getActiveFlow()
	return self.flows[self.activeFlowIndex]
end

--- get the index number of the active flow
-- @return int - index
function kcSOP:getActiveFlowIndex()
	return self.activeFlowIndex
end

--- get the flow at the index provided
-- @param int index - index of flow to return
-- @return kcFlow
function kcSOP:getFlow(index)
	return self.flows[index]
end

--- return the currently active checklist in the SOP
-- @return kcChecklist object
function kcSOP:getActiveChecklist()
	if self.checklists ~= nil then
		return self.checklists[self.activeChecklistIndex]
	end
end

--- return the currently active procedure in the SOP
-- @return kcProcedure object
function kcSOP:getActiveProcedure()
	return self.procedures[self.activeProcedureIndex]
end

--- get the number of registered flows
-- @return int - number of flow
function kcSOP:getNumberOfFlows()
	return table.getn(self.flows)
end

--- get the number of registered states
-- @return int - numner of states
function kcSOP:getNumberOfStates()
	return table.getn(self.states)
end

--- is there another item left or at end?
-- @return bool true if there still are flows in the sequence
function kcSOP:hasNextFlow()
    return self.activeFlowIndex < #self.flows
end

--- Take the next procedure item as active item
-- @return -1 if a problem 
function kcSOP:setNextFlowActive()
    if self:hasNextFlow() then
		self.activeFlowIndex = self.activeFlowIndex + 1
	else
		return -1
    end
end

--- reset the whole SOP and all its flows
function kcSOP:reset()
    self.activeFlowIndex = 1
	self.activeChecklistIndex = 1
	self.activeProcedureIndex = 1

    for _, flow in ipairs(self.flows) do
        flow:reset()
    end
end

-- ============ SOP specific UIs ================

-- render the SOP button list
function kcSOP:render()
	local states = self:getAllStates()
	local flows = self:getAllFlows()
	if table.getn(states) > 0 then
		for _, state in ipairs(states) do
			imgui.SetCursorPosY(imgui.GetCursorPosY() + 1)
			local color = color_state
			if state:getState() == Flow.FINISH then
				color = color_green
			end
			imgui.PushStyleColor(imgui.constant.Col.Button, color)
			imgui.PushStyleColor(imgui.constant.Col.ButtonActive, 0xFF001F9F)
			imgui.PushStyleColor(imgui.constant.Col.ButtonHovered, 0xFF001F9F)
			if imgui.Button("State: " .. state:getName(), self:getBtnWidth(), 18) then
				self:setActiveFlowIndex(table.getn(flows) - table.getn(states) + kc_indexOf(states,state))
			end
			imgui.PopStyleColor()
			imgui.PopStyleColor()
			imgui.PopStyleColor()
		end
		imgui.Separator()
	end
	
	imgui.PushStyleColor(imgui.constant.Col.Text, color_white)
	imgui.SetWindowFontScale(1.05)
	imgui.PushStyleColor(imgui.constant.Col.Button, 0xFF00007F)
	if imgui.Button("RESET", 50, 18) then
		self:reset()
	end
	imgui.PopStyleColor()
	for _, flow in ipairs(flows) do
		if flow:getFlightPhase() >= 0 then
			if flow:getClassName() ~= "State" then
				imgui.SetCursorPosY(imgui.GetCursorPosY() + 1)
				local color = color_procedure
				if flow:getClassName() == "Checklist" then	
					color = color_checklist
				end
				if flow:getState() == Flow.FINISH then
					color = color_green
				end
				if kc_indexOf(flows,flow) == self.activeFlowIndex then
					color = 0xFF001F9F
				end
				imgui.PushStyleColor(imgui.constant.Col.Button, color)
				imgui.PushStyleColor(imgui.constant.Col.ButtonActive, 0xFF001F9F)
				imgui.PushStyleColor(imgui.constant.Col.ButtonHovered, 0xFF004F9F)
				if imgui.Button(flow:getName() .. " [" .. self:getPhaseString(math.abs(flow:getFlightPhase())) .. "]", self:getBtnWidth(), 18) then
					self:setActiveFlowIndex(kc_indexOf(flows,flow))
				end
				imgui.PopStyleColor()
				imgui.PopStyleColor()
				imgui.PopStyleColor()
			end
		end
	end
    imgui.PopStyleColor()
end

-- get the calculated height for the window
function kcSOP:getWndHeight()
	return (kc_num_visible_sop_items +2 ) * 23 + 12 + 27
	-- return self:getNumberOfFlows() * 23 + 12 + 27
end

-- get the max width of buttons in the list based on labels
function kcSOP:getBtnWidth()
	local namelen = 0
	local flows = self:getAllFlows()
	for _, flow in ipairs(flows) do
		local nrchars = string.len(flow:getName() .. " [" .. self:getPhaseString(math.abs(flow:getFlightPhase())) .. "]")
		if nrchars > namelen then
			namelen = nrchars
		end
	end
	return namelen * 8
end

-- get the calculated width for the checklist window
function kcSOP:getWndWidth()
	return self:getBtnWidth() + 20
end

-- get the calculated X position based on window width
function kcSOP:getWndXPos()
	local win_width = get("sim/graphics/view/window_width")
	return win_width - self:getWndWidth() - activeBckVars:get("ui:sop_wnd_xoffset") --50
end

-- get the calculated Y position
function kcSOP:getWndYPos()
	return activeBckVars:get("ui:sop_wnd_ypos")
end

return kcSOP