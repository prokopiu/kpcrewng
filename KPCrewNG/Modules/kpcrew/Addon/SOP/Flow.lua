-- Flow of activities during a specific phase of flight (checklist or procedure)
-- A procedure registers a number of activities/tasks to be executed and checked
--
-- @classmod Flow
-- @author Kosta Prokopiu
-- @copyright 2026 Kosta Prokopiu

local ngFlow = {}

--- Instantiate a new Flow
-- @param string title - Title of the flow
-- @return Flow - the created flow object
function ngFlow:new(title)
    ngFlow.__index = ngFlow
    local obj = {}
    setmetatable(obj, ngFlow)

	obj.className = "Flow"
	
    obj.title = title
	
    return obj
end

--- get classname
-- @return string "SOP"
function ngFlow:getClassName() return self.className end


--- Get title of Flow
-- @return string - title of Flow
function ngFlow:getTitle() return self.title end

--- Set the title of the Flow
-- @param string title - title for Flow
function ngFlow:setTitle(title) self.title = title end

return ngFlow