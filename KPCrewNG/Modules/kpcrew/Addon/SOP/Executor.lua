ng_stateindex = 0

-- -----------------------------------------------------------------------------------------
-- execute all actions for a Flow step(item)
-- @param FlowItem procstep - procedure step
function ng_execute_step_actions(procstep)
	if procstep ~= nil then -- ignore if step failed
dprint("ng_execute_step_actions: "..procstep:getChallenge())
		-- check role and if simuser (cpt) then check automation flag and skip
		if procstep:isSimUser() and ng_getAppPrefs():get("general:assistance") == false then 
			return 
		end
			
		-- find the systems or system elements to be triggered
		if procstep:getItemNode().setelements ~= nil then
		
			-- extract the individual elements on which to act
			for _,step in pairs(procstep:getItemNode().setelements) do
				
				-- # means it is a system not a system element
				if string.find(step.element,"#") ~= nil then
					ng_action_system(string.sub(step.element,2),step.action, step.value, step.condition, step.fset, step.fcheck, step.fvalue)
				else
					ng_action_element(step.element, step.action, step.value, step.condition, step.fset, step.fcheck, step.fvalue)
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
-- @param bool condition - step level condition
-- @param function fset - step level set value function
-- @param function fcheck - step level check function
function ng_action_system(systemname, action, value, condition, fset, fcheck, fvalue)
	local system = ng_get_active_sys():findSystem(string.lower(systemname))
	if system ~= nil then
		for _,element in pairs(system.elements) do
dprint("ng_action_system: "..element.name)
			ng_action_element(element.name, string.lower(action), value, condition, fset, fcheck, fvalue)
		end
	end
end

-- -----------------------------------------------------------------------------------------
-- Execute action for a specific system element
-- @param string elementname - name of element to execute (lowercase)
-- @param string action - standardized action name (lowercase)
-- @param value - value to use when non-standard
-- @param bool condition - step level condition
-- @param function fset - step level set value function
-- @param function fcheck - step level check function
function ng_action_element(elementname, action, value, condition, fset, fcheck, fvalue)
	
	if ng_get_active_sys():find(elementname) ~= nil then
		
		local element = ng_get_active_sys():find(elementname):getElementNode()
dprint("ng_action_element: "..element.title)

		local dref 	= element.dref
		local idx 	= element.indx
		local etype = string.lower(element.type)
		local incr  = element.incr
		if incr == nil then incr = 1 end
		local maxval = element.max
		if maxval == nil then maxval = 999 end
		local minval = element.min
		if minval == nil then minval = 1 end
		local cmddn = element.cmddn
		if cmddn == nil then cmddn = "" end
		local cmdup = element.cmdup
		if cmdup == nil then cmdup = "" end
		
		-- get dataref from array or single value
		-- local getdref = function () if idx ~= nil then return get(dref,idx) else return get(dref) end end
		local function getdref() 
			local result = nil
			if dref ~= nil then 
				if idx ~= nil then result = get(element.dref,idx) else result = get(element.dref) end
				if element.ftrans ~= nil then 
					local func = loadstring("return "..element.ftrans)()
					result = func(result)
				end
			end
			return result
		end

		-- set dataref either single value or indexed
		local setdref = function (invalue) if idx ~= nil then set_array(dref,idx,invalue) else set(dref,invalue) end end

		-- get the value to action
		local function getvalue()
			local result = nil
			-- either use the SOP value directly or the fvalue code
			if fvalue ~= nil then
				result = loadstring("return "..fvalue)()
			else
				result = value
			end
			return result
		end

		-- check if there is a condition and skip this element's actions
		if condition ~= nil then
			if loadstring("return "..condition)() == false then 
				return
			end
		end

		-- ======= undefined element just skip
		if etype == "undefined" then
			print("Action: "..elementname.." is of type undefined")
		
		-- ======= annunciator without action
		elseif etype == "annunciator" then
		
		-- ======= dataref driven elements
		elseif etype == "dataref" then
		
			local found = 0
			-- check if action is allowed for the element
			for _,defaction in pairs(element.acts) do
				if (defaction == action) then found = 1 end
			end
			
			-- if allowed because found then continue, otherwise skip
			if found == 1 then
				
				if action == "on" then -- fixed value 1
					if value == nil then value = 1 end 
					setdref(value)
						
				elseif action == "off" then -- fixed value 0
					if value == nil then value = 0 end 
					setdref(value)
						
				elseif action == "tgl" then -- toggle always 0 and 1
					if getdref() == 0 then setdref(1) else setdref(0) end
									
				elseif action == "set" then -- set dref with value
					if getvalue() == nil then 
						print("Value missing for set action in "..elementname)
					else
						setdref(getvalue())
					end
					
				elseif action == "chk" then 
					-- don't action, just check
				end
				
			else
				print("Action not allowed: "..action.." in "..elementname)
			end
			
		-- ======= on/off/toggle switch 
		elseif etype == "onofftgl" then

			local found = 0
			-- check if action is allowed for the element
			for _,defaction in pairs(element.acts) do
				if (defaction == action) then found = 1 end
			end
								
			-- if allowed because found then continue, otherwise skip
			if found == 1 then
				
				if action == "on" then 
					if element.cmdon == nil then
						if getdref() == 0 then command_once(element.cmdtgl) end
					else
						command_once(element.cmdon)
					end
					
				elseif action == "off" then 
					if element.cmdoff == nil then
						if getdref() == 1 then command_once(element.cmdtgl) end
					else
						command_once(element.cmdoff)
					end
					
				elseif action == "tgl" then command_once(element.cmdtgl) 
					
				end
				
			else
				print("Action not allowed: "..action)
			end
			
		-- ======= Dial dataref switch
		elseif etype == "dialdref" then
			
			local found = 0
			-- check if action is allowed for the element
			for _,defaction in pairs(element.acts) do
				if (defaction == action) then found = 1 end
			end
			
			-- if allowed because found then continue, otherwise skip
			if found == 1 then
				if action == "up" then
					if getdref() < maxval then setdref(getdref() + incr) end

				elseif action == "dn" then
					if getdref() > minval then setdref(getdref() - incr) end

				elseif action == "set" then -- set dref with value
					if getvalue() == nil then 
						print("Value missing for set action in "..elementname)
					else
						setdref(getvalue())
					end
					
				end
			else
				print("Action not allowed: "..action.." in "..elementname)
			end
			
		-- ======= Dial cmd switch
		elseif etype == "dialcmd" then

			local function setvalue(lvalue)
				if lvalue ~= nil then
					if lvalue >= minval and lvalue <= maxval and lvalue ~= getdref() then
						if lvalue > getdref() then
							for i = getdref(), lvalue-1, 1 do
								command_once(cmdup)
							end
						elseif lvalue < getdref() then
							for i = getdref(), lvalue+1, -1 do
								command_once(cmddn)
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

				if action == "up" then
					if getdref() < maxval then command_once(cmdup) end

				elseif action == "dn" then
					if getdref() > minval then command_once(cmddn) end

				elseif action == "set" then
					setvalue(getvalue())
					
				end
			else
				print("Action not allowed: "..action.." in "..elementname)
			end
			
		-- ======= function switch
		elseif etype == "custom" then
			
			local found = 0
			-- check if action is allowed for the element
			for _,defaction in pairs(element.acts) do
				if (defaction == action) then found = 1 end
			end
			
			-- if allowed because found then continue, otherwise skip
			if found == 1 then
				
				if action == "on" then
					if element.fon ~= nil then 
						local funcon = loadstring("return "..element.fon)() 
						funcon(getdref())
					end
				elseif action == "off" then
					if element.foff ~= nil then 
						local funcoff = loadstring("return "..element.foff)() 
						funcoff(getdref())
					end
				elseif action == "tgl" then 
					if element.ftgl ~= nil then 
						local functgl = loadstring("return "..element.ftgl)() 
						functgl(getdref())
					end
				elseif action == "set" then 
					if element.fset ~= nil then 
						local funcset = loadstring("return "..element.fset)() 
						funcset(getdref())
					end
				end
			else
				print("Action not allowed: "..action.." in "..elementname)
			end
			
		else
			print("Unknown element type: "..etype.." in "..elementname)
		end
		
	else
		-- print("!! Undefined system element: " .. elementname)
	end
end	

-- -----------------------------------------------------------------------------------------
-- Check  all elements in a system (group of elements)
-- @param string systemname - name of system to execute (lowercase)
-- @param string action - standardized action name (lowercase)
-- @param value - value to use when non-standard
-- @param function fset step level set value function
-- @param function fcheck step level check function
-- @return combined true/false - all true means system checks out
function ng_check_system(systemname, action, value, fset, fcheck, fvalue)
	
	local system = ng_get_active_sys():findSystem(systemname)
	
	if system ~= nil then
		local nelements = #system.elements
		local accresult = true
		local currresult = false
		
		-- count the trues and if less trues then elements then return false
		for _,element in pairs(system.elements) do
			currresult = ng_check_element(element.name, action, value, fset, fcheck, fvalue) 
			accresult = accresult and currresult
		end
		return accresult
		
	else
		
		return false
		
	end
end

-- -----------------------------------------------------------------------------------------
-- Check  an element 
-- @param string elementname - name of system to execute (lowercase)
-- @param string action - standardized action name (lowercase)
-- @param value - value to use when non-standard
-- @param function fset step level set value function
-- @param function fcheck step level check function
-- @return boolean true/false
function ng_check_element(elementname, action, value, fset, fcheck, fvalue)

	if ng_get_active_sys():find(elementname) ~= nil then
	
		local element = ng_get_active_sys():find(elementname):getElementNode()
		local dref = element.dref
		local idx = element.indx
		local etype = string.lower(element.type)
		local efcheck = element.fcheck

		-- pull from the dataref either single value or array value with indx
		local function getdref() 
			local result = nil
			if dref ~= nil then 
				if idx ~= nil then result = get(element.dref,idx) else result = get(element.dref) end
				if element.ftrans ~= nil then 
					local func = loadstring("return "..element.ftrans)()
					result = func(result)
				end
			end
			return result
		end
		
		-- get either the value directly from the SOP step, fset() or fcheck()
		local function getvalue()
			local result = nil
			if fvalue ~= nil then
				result = loadstring("return "..fvalue)()
			else
				result = value
			end
			return result
		end

		-- ======= undefine skip
		if etype == "undefined" then
			print("Check: "..elementname.." is of type undefined")
			return false
		
		-- ======= dataref driven elements
		elseif etype == "dataref" then

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

				elseif action == "set" or action == "chk" then
					if efcheck ~= nil then
						local func = loadstring("return "..efcheck)()
						return func(getdref())
					elseif fcheck ~= nil then
						local func = loadstring("return "..fcheck)()
						return func(getdref())
					else	
						if getvalue() == nil then 
							print("Value missing for set action in ".. elementname)
						else
							return getdref() == getvalue()
						end
					end
					
				else
					print("Check: Action not allowed: "..action.." in "..elementname)
				end
			end
			
				
		-- ======= onoff switch	
		elseif etype == "onofftgl" then
		
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
					
				elseif action == "tgl" then -- cannot be checked -> true
					return true
					
				elseif action == "chk" then
					if efcheck ~= nil then
						local func = loadstring("return "..efcheck)()
						return func(getdref())
					elseif fcheck ~= nil then
						local func = loadstring("return "..fcheck)()
						return func(getdref())
					else	
						if getvalue() == nil then 
							print("Value missing for chk action in ".. elementname)
						else
							return getdref() == getvalue()
						end
					end

				else
					print("Check: Action not allowed: "..action.." in "..elementname)
					return true
				end
			end

		-- ======= dial dataref
		elseif element.type == "dialdref" then
			
			local found = 0
			-- check if action is allowed for the element
			for _,defaction in pairs(element.acts) do
				if (defaction == action) then found = 1 end
			end
			
			-- if allowed because found then continue, otherwise skip
			if found == 1 then

				if action == "up" then
					return true

				elseif action == "dn" then
					return true

				elseif action == "set" or action == "chk" then
					
					if efcheck ~= nil then
						local func = loadstring("return "..efcheck)()
						return func(getdref())
					elseif fcheck ~= nil then
						local func = loadstring("return "..fcheck)()
						return func(getdref())
					else	
						if getvalue() == nil then 
							print("Value missing for set action in ".. elementname)
						else
							return getdref() == getvalue()
						end
					end
					
				else
					print("Check: Action not allowed: "..action.." in "..elementname)
				end
			end

		-- ======= dial cmd
		elseif element.type == "dialcmd" then
			
			local found = 0
			-- check if action is allowed for the element
			for _,defaction in pairs(element.acts) do
				if (defaction == action) then found = 1 end
			end
			
			-- if allowed because found then continue, otherwise skip
			if found == 1 then

				if action == "up" then
					return true

				elseif action == "dn" then
					return true

				elseif action == "set" or action == "chk" then
					
					if efcheck ~= nil then
						local func = loadstring("return "..efcheck)()
						return func(getdref())
					elseif fcheck ~= nil then
						local func = loadstring("return "..fcheck)()
						return func(getdref())
					else	
						if getvalue() == nil then 
							print("Value missing for set action in ".. elementname)
						else
							return getdref() == getvalue()
						end
					end
					
				else
					print("Check: Action not allowed: "..action.." in "..elementname)
				end
			end

		-- ======= custom check
		elseif etype == "custom" then
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

				elseif action == "set" or action == "chk" then
					if efcheck ~= nil then
						local func = loadstring("return "..efcheck)()
						return func(getdref())
					elseif fcheck ~= nil then
						local func = loadstring("return "..fcheck)()
						return func(getdref())
					else	
						if getvalue() == nil then 
							print("Value missing for chk action in ".. elementname)
						else
							return getdref() == getvalue()
						end
					end
					
				else
					print("Check: Action not allowed: "..action.." in "..elementname)
				end
			end			
							
		else
			
			print("Check: Unknown type ".. element.type .." in "..elementname)
		end
	else
		-- print("Check: !! Undefined system element "..elementname)
	end
end	

-- -----------------------------------------------------------------------------------------
-- Perform checks on a flow step
-- @param FlowItem procstep - procedure step
function ng_check_step(procstep)

	if procstep ~= nil then

		-- find the system or system element to be triggered
		-- skip if the step as a whole is set to nocheck
		if procstep:getItemNode().nocheck == nil then
			
			-- extract the step elements/systems to check if available
			if procstep:getItemNode().setelements ~= nil then
				
				local nractiveelem = 0

				for _,selement in pairs(procstep:getItemNode().setelements) do
					if selement.condition ~= nil then 
						if loadstring("return "..selement.condition)() and selement.nocheck == nil then
							nractiveelem = nractiveelem + 1
						end
					else
						if selement.nocheck == nil then nractiveelem = nractiveelem + 1 end
					end
				end

				local nrchecked = 0
				for _,selement in pairs(procstep:getItemNode().setelements) do

					-- if filtered by condition skip the element
					local bdocheck = false

					if selement.condition ~= nil then 
						if loadstring("return "..selement.condition)() and selement.nocheck == nil then
							bdocheck = true
						end
					else
						if selement.nocheck == nil then bdocheck = true end
					end

					-- check if the element is on nocheck and skip
					if bdocheck then
						-- # means it is a system not a system element
						if string.find(selement.element,"#") ~= nil then
							if ng_check_system(string.sub(selement.element,2), selement.action, selement.value, selement.fset, selement.fcheck, selement.fvalue) then
								nrchecked = nrchecked + 1
							end
						else
							if ng_check_element(selement.element, selement.action, selement.value, selement.fset, selement.fcheck, selement.fvalue) then
								nrchecked = nrchecked + 1
							end
						end
					end

				end
				return nractiveelem == nrchecked
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
			if loadstring("return "..astep:getItemNode().condition)() == false then
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
		dprint("State ["..ng_stateindex.."]")
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
