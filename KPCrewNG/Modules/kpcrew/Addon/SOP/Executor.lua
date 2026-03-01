ng_stateindex = 0

-- -----------------------------------------------------------------------------------------
-- execute all actions for a Flow step(item)
-- @param FlowItem procstep - procedure step
function ng_execute_step_actions(procstep)
print(procstep)
	if procstep ~= nil then -- ignore if step failed
print("ng_execute_step_actions: "..procstep:getChallenge())
		-- check role and if simuser (cpt) then check automation flag and skip
		if procstep:isSimUser() and ng_getAppPrefs():get("general:assistance") == false then 
print("skipped")
			return 
		end
			
		-- find the systems or system elements to be triggered
		if procstep:getItemNode().setelements ~= nil then
		
			-- extract the individual elements on which to act
			for _,step in pairs(procstep:getItemNode().setelements) do
				
				-- # means it is a system not a system element
				if string.find(step.element,"#") ~= nil then
					ng_action_system(string.sub(step.element,2),step.action, step.value, step.condition, step.fset, step.fcheck)
				else
					ng_action_element(step.element, step.action, step.value, step.condition, step.fset, step.fcheck)
				end
				
			end
			
		end
		
	end
	
end	

-- -----------------------------------------------------------------------------------------
-- Execute all elements in a system (group of elements)
-- @param string systemname - name of system to execute (lowercase)
-- @param string action - standardized action name (lowercase)
-- @param value - value to use when non-standard
function ng_action_system(systemname, action, value, condition, fset, fcheck)
	local system = ng_get_active_systems():findSystem(string.lower(systemname))
	if system ~= nil then
		for _,element in pairs(system.elements) do
print("ng_action_system: "..element.name)
			ng_action_element(element.name, string.lower(action), value, condition, fset, fcheck)
		end
	end
end

-- -----------------------------------------------------------------------------------------
-- Execute action for a specific system element
-- @param string elementname - name of element to execute (lowercase)
-- @param string action - standardized action name (lowercase)
-- @param value - value to use when non-standard
function ng_action_element(elementname, action, value, condition, fset, fcheck)
	
	if ng_get_active_systems():find(elementname) ~= nil then
		local element = ng_get_active_systems():find(elementname):getElementNode()
print("ng_action_element: "..element.title)
		local dref = element.dref
		local idx = element.indx
		local etype = string.lower(element.type)
		local getdref = function () if idx ~= nil then return get(dref,idx) else return get(dref) end end
		local setdref = function (invalue) if idx ~= nil then set_array(dref,idx,invalue) else set(dref,invalue) end end
		local function getvalue()
			local result = nil
			if fset ~= nil then
				result = loadstring(fset)()
			else
				result = value
			end
			return result
		end

		-- check if there is a condition and skip element
		if condition ~= nil then
			if loadstring(condition)() == false then 
				return
			end
		end
		-- ======= dataref driven elements
		if etype == "dataref" then
			
			local found = 0
			-- check if action is allowed for the element
			for _,defaction in pairs(element.acts) do
				if (defaction == action) then found = 1 end
			end
			
			-- if allowed because found then continue, otherwise skip
			if found == 1 then
				
				if action == "on" then
					if value == nil then value = 1 end 
					setdref(value)
						
				elseif action == "off" then
					if value == nil then value = 0 end 
					setdref(value)
						
				elseif action == "set" then
					if getvalue() == nil then 
						print("Value missing for set action")
					else
						setdref(getvalue())
					end
					
				elseif action == "toggle" then -- toggle always 0 and 1
					if get(element.dref) == 0 then setdref(1) else setdref(0) end
				end
			else
				print("Action not allowed: "..action)
			end
			
		-- ======= toggle only switch with 1 dref and 1 command
		elseif etype == "toggle" then
			
			local found = 0
			-- check if action is allowed for the element
			for _,defaction in pairs(element.acts) do
				if (defaction == action) then found = 1 end
			end
			
			-- if allowed because found then continue, otherwise skip
			if found == 1 then
				
				if action == "on" then
					if getdref() == 0 then command_once(element.cmdtgl) end
					
				elseif action == "off" then
					if getdref()  == 1 then command_once(element.cmdtgl) end
					
				elseif action == "toggle" then -- toggle always 0 and 1
					command_once(element.cmdtgl)
				end
			else
				print("Action not allowed: "..action)
			end
			
		-- ======= ON/OFF switch
		elseif etype == "onoff" then
			
			local found = 0
			-- check if action is allowed for the element
			for _,defaction in pairs(element.acts) do
				if (defaction == action) then found = 1 end
			end
			
			-- if allowed because found then continue, otherwise skip
			if found == 1 then
				
				if action == "on" then
					command_once(element.cmdon)
					
				elseif action == "off" then
					command_once(element.cmdoff)
					
				elseif action == "toggle" then 
					command_once(element.cmdtgl)
				end
			else
				print("Action not allowed: "..action)
			end
			
		-- ======= function switch
		elseif etype == "function" then
			
			local found = 0
			-- check if action is allowed for the element
			for _,defaction in pairs(element.acts) do
				if (defaction == action) then found = 1 end
			end
			
			-- if allowed because found then continue, otherwise skip
			if found == 1 then
				
				if action == "on" then
					if element.funcon ~= nil then loadstring(element.funcon)() end
				elseif action == "off" then
					if element.funcoff ~= nil then loadstring(element.funcoff)() end					
				elseif action == "toggle" then 
					if element.functgl ~= nil then loadstring(element.functgl)() end
				end
			else
				print("Action not allowed: "..action)
			end
			
		-- ======= Multistate switch
		elseif etype == "multistate" then

			local function setvalue(value)
				if value ~= nil then
					if value >= element.min and value <= element.max and value ~= getdref() then
						if value > getdref() then
							for i = getdref(), value-1, 1 do
								command_once(element.cmdup)
							end
						elseif value < getdref() then
							for i = getdref(), value+1, -1 do
								command_once(element.cmddn)
							end
						end
					end
				end
			end 
			
			local found = 0
			-- check if action is allowed for the element
			for _,defaction in pairs(element.acts) do
				if (defaction == action) then found = 1 end
			end
			
			-- if allowed because found then continue, otherwise skip
			if found == 1 then
				if action == "set" then
					setvalue(getvalue())
				elseif action == "on" then
					local value = getvalue()
					if value == nil then value = 1 end 
					setvalue(value)
				elseif action == "off" then
					local value = getvalue()
					if value == nil then value = 0 end 
					setvalue(value)
				elseif action == "toggle" then
					if get(element.dref) == 0 then setvalue(1) else setvalue(0) end
				end
			else
				print("Action not allowed: "..action)
			end
			
		-- ======= Dial switch
		elseif etype == "dial" then
			local function setvalue(value)
				if value ~= nil then
					if value >= element.min and value <= element.max and value ~= getdref() then
						if value > getdref() then
							for i = getdref(), value-element.incr, element.incr do
								command_once(element.cmdup)
							end
						elseif value < getdref() then
							for i = getdref(), value+element.incr, -element.incr do
								command_once(element.cmddn)
							end
						end
					end
				end
			end 
			
			local found = 0
			-- check if action is allowed for the element
			for _,defaction in pairs(element.acts) do
				if (defaction == action) then found = 1 end
			end
			
			-- if allowed because found then continue, otherwise skip
			if found == 1 then
				if action == "set" then
					setvalue(getvalue())
				elseif action == "up" then
					command_once(element.cmdup)
				elseif action == "dn" then
					command_once(element.cmddn)
				elseif action == "function" then
					loadstring(fset)()
				end
			else
				print("Action not allowed: "..action)
			end

		else
			print("Unkown element type: "..etype)
		end
		
	else
		print("!! Undefined system element: " .. elementname)
	end
end	

-- -----------------------------------------------------------------------------------------
-- Check  all elements in a system (group of elements)
-- @param string systemname - name of system to execute (lowercase)
-- @param string action - standardized action name (lowercase)
-- @param value - value to use when non-standard
-- @return combined true/false - all true means system checks out
function ng_check_system(systemname, action, value, fset, fcheck)
	
	local system = ng_get_active_systems():findSystem(systemname)
	
	if system ~= nil then
		local nelements = #system.elements
		local cnt = 0
		
		-- count the trues and if less trues then elements then return false
		for _,element in pairs(system.elements) do
			if ng_check_element(element.name, action, value, fset, fcheck) then 
				cnt = cnt +1
			end
		end
		return cnt == nelements
		
	else
		
		return false
		
	end
end

-- -----------------------------------------------------------------------------------------
-- Check  an element 
-- @param string elementname - name of system to execute (lowercase)
-- @param string action - standardized action name (lowercase)
-- @param value - value to use when non-standard
-- @param string fset function code frm procstep
-- @return boolean true/false
function ng_check_element(elementname, action, value, fset, fcheck)
	
	if ng_get_active_systems():find(elementname) ~= nil then
		local element = ng_get_active_systems():find(elementname):getElementNode()
		local dref = element.dref
		local idx = element.indx
		local etype = string.lower(element.type)
		local setdref = function (invalue) if idx ~= nil then set_array(element.dref,idx,invalue) else set(element.dref,invalue) end end

		local function getdref() 
			local result = nil
			-- if fcheck in element then use function else read dataref
			if fcheck ~= nil then -- fcheck from function
				result = loadstring(fcheck)()
			elseif element.fcheck ~= nil then
				result = loadstring(element.fcheck)()
			else
				if idx ~= nil then result = get(element.dref,idx) else result = get(element.dref) end
			end
			return result
		end
		
		-- ======= dataref driven elements
		if etype == "dataref" then
			print("dataref")
			local found = 0
			-- check if action is allowed for the element
			for _,defaction in pairs(element.acts) do
				if (defaction == action) then found = 1 end
			end
			
			-- if allowed because found then continue, otherwise skip
			if found == 1 then

				if action == "on" then
				print("on")
					if value == nil then value = 1 end 
					return getdref() == value
					
				elseif action == "off" then
					if value == nil then value = 0 end 
					return getdref() == value

				elseif action == "set" then
					if value == nil then 
						print("Value missing for set action")
					else
						return getdref() == value
					end
				else
					print("Action not allowed: "..action)
				end
			end
			
		-- ======= function check
		elseif etype == "function" then
			if fcheck ~= nil then 
				return loadstring(fcheck)()
			elseif element.fcheck ~= nil then 
				return loadstring(element.fcheck)() 
			else
				return true
			end
				
		-- ======= onoff switch	
		elseif etype == "onoff" then
			print("onoff")
			local found = 0
			-- check if action is allowed for the element
			for _,defaction in pairs(element.acts) do
				if (defaction == action) then found = 1 end
			end
			
			-- if allowed because found then continue, otherwise skip
			if found == 1 then

				if action == "on" then
					if value == nil then value = 1 end 
					return getdref() == value
					
				elseif action == "off" then
					if value == nil then value = 0 end 
					return getdref() == value
					
				elseif action == "set" then
					if value == nil then 
						print("Value missing for set action")
					else
						return getdref() == value
					end
				else
					print("Action not allowed: "..action)
				end
			end
			
		-- ======= toggle switch	
		elseif element.type == "toggle" then
		
			local found = 0
			-- check if action is allowed for the element
			for _,defaction in pairs(element.acts) do
				if (defaction == action) then found = 1 end
			end
			
			-- if allowed because found then continue, otherwise skip
			if found == 1 then

				if action == "on" then
					if value == nil then value = 1 end 
					return getdref() == value
					
				elseif action == "off" then
					print(getdref())
					if value == nil then value = 0 end 
					return getdref() == value
					
				elseif action == "set" then
					if value == nil then 
						print("Value missing for set action")
					else
						return getdref() == value
					end
				else
					print("Action not allowed: "..action)
				end
			end
				
		-- ======= multistate switch	
		elseif element.type == "multistate" then
			
			local found = 0
			-- check if action is allowed for the element
			for _,defaction in pairs(element.acts) do
				if (defaction == action) then found = 1 end
			end
			
			-- if allowed because found then continue, otherwise skip
			if found == 1 then

				if action == "set" then
					if value == nil then 
						print("Value missing for set action")
					else
						return getdref() == value
					end
				else
					print("Action not allowed: "..action)
				end
			end
				
		-- ======= dial
		elseif element.type == "dial" then
			
			local found = 0
			-- check if action is allowed for the element
			for _,defaction in pairs(element.acts) do
				if (defaction == action) then found = 1 end
			end
			
			local function getvalue()
				local result = nil
				if fcheck ~= nil then
					result = loadstring(fcheck)()
				elseif fset ~= nil then
					result = loadstring(fset)()
				else
					result = value
				end
				return result
			end

			-- if allowed because found then continue, otherwise skip
			if found == 1 then

				if action == "up" then
					if getvalue() == nil then 
						print("Value missing for set action")
					else
						return getdref() == getvalue()
					end					
				elseif action == "dn" then
					if getvalue() == nil then 
						print("Value missing for set action")
					else
						return getdref() == getvalue()
					end
				elseif action == "set" then
					if getvalue() == nil then 
						print("Value missing for set action")
					else
						return getdref() == getvalue()
					end
				elseif action == "function" then
						return getdref() == getvalue()
				else
					print("Action not allowed: "..action)
				end
			end
			
		else
			print("unknown type")
		end
	else
		print("!! Undefined system element")
	end
end	

-- -----------------------------------------------------------------------------------------
-- Perform checks on a flow steo
-- @param FlowItem procstep - procedure step
function ng_check_step(procstep)

	if procstep ~= nil then

		-- find the system or system element to be triggered
		-- skip if the step as a whole is set to nocheck
		if procstep:getItemNode().nocheck == nil then
			
			-- extract the step elements/systems to check if available
			if procstep:getItemNode().setelements ~= nil then
				
				local accresult = false
				for _,step in pairs(procstep:getItemNode().setelements) do
					-- check if the element is on nocheck and skip
					if step.nocheck == nil then 
						-- # means it is a system not a system element
						if string.find(step.element,"#") ~= nil then
							accresult = ng_check_system(string.sub(step.element,2),step.action,step.value, step.fset, step.fcheck)
						else
							accresult = ng_check_element(step.element, step.action, step.value, step.fset, step.fcheck)
						end
					else
						accresult = true
					end
				end
				return accresult
			end
			
		else
			return true
		end
	end
	
end	

-- -----------------------------------------------------------------------------------------
-- Switch to next flow
function ng_next_flow()
	
	local sop = ng_get_active_sop() -- get active SOP
	local function incrflowidx() sop:setActiveFlowIdx(math.min(sop:getActiveFlowIdx()+1,#sop:getFlows())) end
	
	if sop:getActiveFlowIdx() > 0 then 
		local flow = sop:getActiveFlow() -- current one
		if flow:isSelected() then 
			flow:setSelected(false) 
			incrflowidx() 
			flow = sop:getActiveFlow()
			flow:setSelected(true) 
		end
	else -- initially
		incrflowidx()
		local flow = sop:getActiveFlow()
		flow:setSelected(true)
	end
	
end		

-- -----------------------------------------------------------------------------------------
-- Switch to previous flow
function ng_prev_flow()
	
	local sop = ng_get_active_sop()
	local function decrflowidx() sop:setActiveFlowIdx(math.max(sop:getActiveFlowIdx()-1,1)) end
	
	if sop:getActiveFlowIdx() > 0 then 
		local flow = sop:getActiveFlow() -- current one
		if flow:isSelected() then 
			flow:setSelected(false) 
			decrflowidx() 
			flow = sop:getActiveFlow()
			flow:setSelected(true) 
		end
	else
		incrflowidx()
		local flow = sop:getActiveFlow() -- current one
		flow:setSelected(true)
	end
	
end		

-- -----------------------------------------------------------------------------------------
-- master action
function ng_master_action()
	local sop = ng_get_active_sop()
	
	-- look at active flow
	local aflow = nil
	local idxaflow = sop:getActiveFlowIdx()
	
	-- active flow set
	if idxaflow > 0 then
		
		aflow = sop:getActiveFlow()
		
		-- if new then set flow to start mode
		if aflow:getState() == ng_flowstate_new then
			aflow:setState(ng_flowstate_start)
		end
		
		-- if in run mode then pause - in pause run again
		if aflow:getState() == ng_flowstate_run then
			aflow:setState(ng_flowstate_pause)
			aflow:getActiveItem():setState(ng_fistate_pause)
			ng_stateindex = 60
			dprint("State ["..ng_stateindex.."]")
		elseif aflow:getState() == ng_flowstate_pause then
			aflow:setState(ng_flowstate_run)
			aflow:getActiveItem():setState(ng_fistate_run)
			if ng_stateindex == 61 then
				ng_stateindex = 9
			else
				ng_stateindex = 8
			end
			dprint("State ["..ng_stateindex.."]")
		end

		if aflow:getState() == ng_flowstate_end then
			aflow:setState(ng_flowstate_start)
			aflow:setActiveItemIdx(0)
		end

		if ng_stateindex == 30 then ng_stateindex = 9 end
		
	end
end

-- -----------------------------------------------------------------------------------------
-- background executor running in constant loop 1/sec
function ng_flow_executor()
	
	-- ============ State 0 - SOP initialized, nothing selected =============
	-- look at the active SOP and get active flow and step 
	local sop = ng_get_active_sop()
	
	-- initialize the active flow
	local aflow = nil -- initialize the active flow
	local indxaflow = 0
	if sop ~= nil then indxaflow = sop:getActiveFlowIdx() end -- check the index, if 0 then SOP is newly loaded
	if indxaflow > 0 then aflow = sop:getActiveFlow() end -- if index >0 then set as active Flow
	local aflowstate = ng_flowstate_na
	if aflow ~= nil then aflowstate = aflow:getState() end

	if ng_stateindex == 0 and aflow ~= nil then ng_stateindex = 1 dprint("State ["..ng_stateindex.."]") end
	
	-- initialize the active step
	local astep = nil -- initialize the active step
	local indxastep = 0 -- 0 means flow just loaded but not active
	if aflow ~= nil then indxastep = aflow:getActiveItemIdx() end -- get the index of the active step
	if indxastep > 0 then astep = aflow:getActiveItem() end -- get the active step
	local astepstate = 0
	if astep ~= nil then astepstate = astep:getState() end 

	if ng_stateindex == 1 and aflowstate == ng_flowstate_start then ng_stateindex = 3 dprint("State ["..ng_stateindex.."]") end

	-- State 0: inital state all new, no flow and item
	-- State 1: flow defined; step Undefined
	-- State 2: not used
	-- State 3: flow in start mode

	-- stop this executor run as there is nothing to do
	if aflowstate == ng_flowstate_na then return end

	-- ============ ========================================== =============
	if ng_stateindex == 3 then -- flight phase set and flow into run mode
		-- set the sop flightphase and the briefing phase from the flow phase
		sop:setFlightPhase(aflow:getFlightPhase())
		ng_getBckVars():set("general:flightstate",aflow:getFlightPhase())
		-- set flow to state run for executions to start
		aflow:setState(ng_flowstate_run)
		aflowstate = ng_flowstate_run
		ng_stateindex = 4
		dprint("State ["..ng_stateindex.."]")
	end

	if ng_stateindex == 4 then -- at start of flow set 1 item to active
		aflow:setActiveItemIdx(1)
		indxastep = 1
		astep = aflow:getActiveItem()
		if astep:getItemNode().condition ~= nil then
			if loadstring(astep:getItemNode().condition)() == false then
				indxastep = 2
				aflow:setActiveItemIdx(2)
				astep = aflow:getActiveItem()
			end
		end
		astepstate = ng_fistate_new
		astep:setState(ng_fistate_new)
		ng_stateindex = 5
		dprint("State ["..ng_stateindex.."]")
	end

	if ng_stateindex == 5 then -- set current item to run mode
		astep:setState(ng_fistate_run)
		astepstate = ng_fistate_run
		ng_stateindex = 6
		dprint("State ["..ng_stateindex.."]")
	end

	if ng_stateindex == 30 then -- error occurred in previous loop - check again until checked
		local checked = ng_check_step(astep)
		if checked then 
			astep:setState(ng_fistate_chk)
			astepstate = ng_fistate_chk
			aflow:setState(ng_flowstate_run)
			aflowstate = ng_flowstate_run --resume execution
			ng_stateindex = 9
			dprint("State ["..ng_stateindex.."]")			
		end
	end

	if ng_stateindex == 51 then -- third loop after response in checklist
		astep:setState(ng_fistate_end)
		astepstate = ng_fistate_end
		ng_stateindex = 10
		dprint("State ["..ng_stateindex.."]")
	end 
	
	if ng_stateindex == 50 then -- second loop after response in checklist
		if astep:isSimUser() == false then ng_speakNoText(0, astep:getResponse()) end
		ng_stateindex = 51
		dprint("State ["..ng_stateindex.."]")
	end 

	if ng_stateindex == 60 then -- loop while paused
		return
	end 
	
	if ng_stateindex == 61 then -- loop while paused
		return
	end 
	
	if ng_stateindex == 20 then -- if in delay reduce the counter next loop and when 0 jump to 8
		if astep ~= nil then
			if astep:getDelay() ~= nil  then
				if astep:getDelay() > 0 then
					astep:setDelay(astep:getDelay()-1)
					return
				else
					ng_stateindex = 8
					dprint("State ["..ng_stateindex.."]")
				end
			end
		end
	end

	if ng_stateindex == 6 then -- procedure items get actioned, checklistitem speaks challenge
		-- action the item
		if astep:getClassName() == "ProcedureItem" then ng_execute_step_actions(astep) end
		if astep:getClassName() == "ChecklistItem" then 
			ng_speakNoText(0, astep:getChallenge()) 
		end
		astep:setState(ng_fistate_act)
		astepstate = ng_fistate_act
		ng_stateindex = 7
		print("State ["..ng_stateindex.."]")
	end

	if ng_stateindex == 7 then -- if a delay is defined for step set delay and go to waiting loop
		-- if defined set the delay
		if astep:getItemNode().delay ~= nil  then
			if astep:getDelay() == 0 then
				astep:setDelay(astep:getItemNode().delay)
				astep:setState(ng_fistate_del)
				astepstate = ng_fistate_del
				ng_stateindex = 20
				dprint("State ["..ng_stateindex.."]")
				return
			end
		end
		ng_stateindex = 8
		dprint("State ["..ng_stateindex.."]")
	end

	if ng_stateindex == 8 then -- check the item
		local checked = true
		if astep:getItemNode().nocheck == nil then
			checked = ng_check_step(astep)
		end
		if checked then 
			astep:setState(ng_fistate_chk)
			astepstate = ng_fistate_chk
			if astep:isSimUser() and astep:getClassName() == "ChecklistItem" then
				aflow:setState(ng_flowstate_pause)
				-- astep:setState(ng_fistate_pause)
				ng_stateindex = 61
				dprint("State ["..ng_stateindex.."]")
				return
			end
			ng_stateindex = 9
			dprint("State ["..ng_stateindex.."]")
		else
			astep:setState(ng_fistate_err)
			astepstate = ng_fistate_err
			aflow:setState(ng_flowstate_err)
			aflowstate = ng_flowstate_err
			-- print("Current execution stopped due to validation error")
			ng_stateindex = 30
			dprint("State ["..ng_stateindex.."]")
		end				
	end

	if ng_stateindex == 9 then -- if checklist say response and have another loop otherwise end item
		if astep:getClassName() == "ChecklistItem" then 
			ng_stateindex = 50
			astep:setState(ng_fistate_end)
			astepstate = ng_fistate_end
			return
		end 
		astep:setState(ng_fistate_end)
		astepstate = ng_fistate_end
		ng_stateindex = 10
		dprint("State ["..ng_stateindex.."]")
	end
	
	if ng_stateindex == 10 then -- if last item end flow otherwise increase step
		if indxastep >= #aflow:getItems() then
			aflow:setState(ng_flowstate_end)
			aflowstate = ng_flowstate_end
			ng_stateindex = 40
			dprint("State ["..ng_stateindex.."]")
		else
			indxastep = indxastep + 1
			aflow:setActiveItemIdx(indxastep)
			astep = aflow:getActiveItem()
			while astep:isToSkip() and indxastep < #aflow:getItems() do
				indxastep = indxastep + 1
				aflow:setActiveItemIdx(indxastep)
				astep = aflow:getActiveItem()
			end
			astep:setState(ng_fistate_run)
			astepstate = ng_fistate_run
			ng_stateindex = 5 -- return with next execution
			dprint("State ["..ng_stateindex.."]")
		end
	end

	if ng_stateindex == 40 then
		ng_stateindex = 1
		if ng_getAppPrefs():get("general:jumpflow") then
			ng_next_flow()
		end
		return 
	end
end
