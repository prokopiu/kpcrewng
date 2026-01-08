-- Flow of activities during a specific phase of flight (checklist or procedure)
-- A procedure registers a number of activities/tasks to be executed and checked
--
-- @classmod Flow
-- @author Kosta Prokopiu
-- @copyright 2026 Kosta Prokopiu

local FlowItem 			= require "kpcrew.FlowItem"

local kcFlow = {
    NEW 			= 0, -- Ready to start flow
    START 			= 1, -- Flow starting
    RUN 			= 2, -- Flow running
    PAUSE  			= 3, -- Flow paused
	WAIT			= 4, -- Flow waiting
	FINISH			= 5, -- Flow finished
	HALT			= 6, -- Flow halted

	states		= { "NEW", "START", "RUN", "PAUSE", "WAIT", "FINISH", "HALT" }, 
	
	colorNotStarted	= color_white,
	colorInProgress = color_left_display,
	colorPaused		= color_orange,
	colorCompleted 	= color_dark_green
}

--- Instantiate a new Flow
-- @param string name - Name of the flow
-- @param string speakStart - text to speak at start ("" will not speak)
-- @param string speakEnd - text to speak at end of flow
-- @return Flow - the created flow object
function kcFlow:new(name, speakStart, speakEnd)
    kcFlow.__index = kcFlow
    local obj = {}
    setmetatable(obj, kcFlow)

	obj.className = "Flow"
	
    obj.name = name
	obj.speakStart = speakStart
	obj.speakEnd = speakEnd
	
    obj.items = {} -- collection of FlowItem
	obj.state = self.NEW -- always start as new
    obj.activeItemIndex = 0 -- currently active FlowItem
	obj.resize = true -- is resizing of window allowed
	obj.startSpoken = false -- spoken at beginning
	obj.finalSpoken = false -- spoken at end of flow
	obj.flightPhase = 0 -- flight phase index this flow belongs
	
    return obj
end

--- return the type of flow for distinction later
-- @return string "Flow" or "Procedure" or "Checklist"
function kcFlow:getClassName() return self.className end

--- Get name/title of flow
-- @return string name - name of flow
function kcFlow:getName() return self.name end

--- Set name/title of flow
-- @param string name - name of set
function kcFlow:setName(name) self.name = name end

--- Get text to speak at start of flow
-- @return string - text to be spoken
function kcFlow:getSpeakStart() return self.speakStart end

--- Set text to speak at start of flow
-- @param string text - text to be spoken
function kcFlow:setSpeakStart(text) self.speakStart = text end

--- speak the at the start of the flow
function kcFlow:speakAtStart()
	if self.speakStart ~= nil and self.startSpeak == false then kc_speakNoText(0,self.speakStart) end
	self.startSpoken = true
end

--- Get text to speak at end of flow
-- @return string - text to be spoken
function kcFlow:getSpeakEnd() return self.speakEnd end

--- Set text to speak at start of flow
-- @param string text - text to be spoken
function kcFlow:setSpeakEnd(text)
	self.speakEnd = text
end

--- speak the final statement of flow
function kcFlow:speakAtEnd() 
	if self.speakEnd ~= nil and self.finalSpoken == false then kc_speakNoText(0,self.speakEnd) end
	self.finalSpoken = true
end

--- get the current flight phase index
-- @return int - flight phase index
function kcFlow:getFlightPhase() return self.flightPhase end

--- set flight phase index
-- @param int phase - index of phase in SOP
function kcFlow:setFlightPhase(phase) self.flightPhase = phase end

--- get the resize allowed flag
-- @return boolean - resize flag true=may resize window
function kcFlow:getResize() return self.resize end

--- set the resize allowed flag
-- @param boolean - true enable resizing
function kcFlow:setResize(flag) self.resize = flag end

--- get state of procedure
-- @return int - state of flow
function kcFlow:getState() return self.state end

--- set state of procedure
-- @param int state - current state of flow (see list above)
function kcFlow:setState(state) self.state = state end

--- return the color code linked to the state
-- @return int - color code matching the state
function kcFlow:getStateColor()
	local statecolors = { self.colorNotStarted, self.colorInProgress, self.colorPaused, self.colorPaused, self.colorCompleted, self.colorPaused }
	return statecolors[self.state + 1]
end

-- -------------- Flow management functions

--- add a new flow item at the end of flow
-- @param FlowItem item - new flowitem to add at the end
function kcFlow:addItem(item) table.insert(self.items, item) end

--- get all flow items
-- @return array of flow items
function kcFlow:getAllItems() return self.items end

--- return number of active procedure items
-- @return int - number of items in flow
function kcFlow:getNumberOfItems()
	local cnt = 0
	for _, item in ipairs(self.items) do
		if item:getState() ~= FlowItem.SKIP then cnt = cnt + 1 end
	end
	return cnt
end

--- get the currently active flow item
-- @return FlowItem - current index
function kcFlow:getActiveItem()
	if self.activeItemIndex == 0 then return self.items[1] else return self.items[self.activeItemIndex] end
end

--- get a specific FlowItem by index
-- @param int index - index of flow item
-- @return FlowItem - item at index
function kcFlow:getFlowItem(index) return self.items[index] end

--- overwrite specific flow item
-- @param int index - index of flow item
-- @param FlowItem item - to overwrite on that index
function kcFlow:setFlowItem(index,flowitem) if flowitem ~= nil then self.items[index] = flowitem end end

--- set the active procedure item
-- @param int index - index of next item to work on
function kcFlow:setActiveItemIndex(item)
    if index >= 1 and index <= #self.items then self.activeItemIndex = index else return -1 end end

--- get the index of the active flow item
-- @return int - index of currently active item
function kcFlow:getActiveItemIndex() return self.activeItemIndex end 

--- is there another item left or at end?
-- @return boolean - true if still items available
function kcFlow:hasNextItem() return self.activeItemIndex < #self.items end

-- Take the next procedure item as active item
-- @return int - index of next item to execute, -1 if at end
function kcFlow:setNextItemActive()
	if self:hasNextItem() then self.activeItemIndex = self.activeItemIndex + 1 end
    while self:hasNextItem() 
	and (self.items[self.activeItemIndex]:getClassName() == "SimpleProcedureItem"
			or self.items[self.activeItemIndex]:getClassName() == "SimpleChecklistItem"
			or self.items[self.activeItemIndex]:getState() == FlowItem.SKIP) do
		self.activeItemIndex = self.activeItemIndex + 1
	end
	if self.activeItemIndex <= #self.items then return self.activeItemIndex else return -1 end
end

--- reset procedure and all below items
function kcFlow:reset()
    self:setState(kcFlow.NEW)
    self.activeItemIndex = 0
	self.nameSpoken = false
	self.finalSpoken = false
	-- reset all items in procedure
    for _, item in ipairs(self.items) do item:reset() end
end

-- ===== UI related functions =====

--- get line length of procedure
-- @return int - needed length for textline 
function kcFlow:getLineLength() return activeBckVars:get("ui:flow_line_length") end

--- return the procedure headline with its name and "="
-- @return string - text of headline/button for flow
function kcFlow:getHeadline()
	local eqsigns = self:getLineLength() - string.len(self.name) - 2
	local line = {}
	
	for i=0,math.floor((eqsigns / 2) + 0.5) - 1,1 do line[#line + 1] = "=" end
	
	line[#line + 1] = " "
	line[#line + 1] = self.name
	line[#line + 1] = " "
	
	for i=0,(eqsigns / 2) - 1,1 do line[#line + 1] = "=" end
	return table.concat(line)
end

--- return the procedure bottom line
function kcFlow:getBottomline()
	local bottomText = self.name .. " COMPLETED"
	local eqsigns = self:getLineLength() - string.len(bottomText) - 2
	local line = {}
	
	for i=0,math.floor((eqsigns / 2) + 0.5) - 1,1 do line[#line + 1] = "=" end
	
	line[#line + 1] = " "
	line[#line + 1] = bottomText
	line[#line + 1] = " "
	
	for i=0,(eqsigns / 2) - 1,1 do line[#line + 1] = "=" end
	return table.concat(line)
end

-- Render all procedure items as text lines in window
function kcFlow:render()
	local items = self:getAllItems()
	imgui.BeginTable(self:getName(),2)
	imgui.TableSetupColumn("CM1")
	imgui.TableSetupColumn("CM2")
	imgui.TableHeadersRow()
	for _, item in ipairs(items) do
		item:render(true)
--		if item:isValid() ~= true then
--			imgui.TableNextRow();
--			if item:isUserRole() then
--				imgui.TableSetColumnIndex(0) imgui.Text(item:getLine(item,60));
--				imgui.TableSetColumnIndex(1) imgui.Text("");
--			else
--				imgui.TableSetColumnIndex(1) imgui.Text(item:getLine(item,60));
--				imgui.TableSetColumnIndex(0) imgui.Text("");
--			end
--			kc_imgui_out_text(color_white, item:getLine(item,60))
--		end
	end
	imgui.EndTable()
end

-- get calculated window height
function kcFlow:getWndHeight() return (self:getNumberOfItems() + 2) * 22 + 40 end

-- get calculated winow width
function kcFlow:getWndWidth() return self:getLineLength() * 7 + 50 end

-- get calculated window x position
function kcFlow:getWndXPos() return activeBckVars:get("ui:flow_wnd_xpos") end

-- get calculated window y position
function kcFlow:getWndYPos() return activeBckVars:get("ui:flow_wnd_ypos") end

return kcFlow