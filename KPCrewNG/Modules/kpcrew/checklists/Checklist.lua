-- Checklist with checklist items
-- A checklist registers a number of checklist challenge/response items
--
-- @classmod Checklist
-- @author Kosta Prokopiu
-- @copyright 2026 Kosta Prokopiu

local kcChecklist = {
}

local Flow				= require "kpcrew.Flow"

--- Instantiate a new Checklist
-- @param string name Name of the set (also used as title)
-- @return new checklist object
function kcChecklist:new(name, speakname, finalstatement)
    kcChecklist.__index = kcChecklist
    setmetatable(kcChecklist, {
        __index = Flow
    })
    local obj = Flow:new(name, speakname, finalStatement)
    setmetatable(obj, kcChecklist)

	obj.className = "Checklist"
	obj.finalStatement = finalstatement
	obj.spokenName = speakname
	
    return obj
end

return kcChecklist