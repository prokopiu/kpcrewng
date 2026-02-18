-- Category of addon systems
--
-- @classmod SystemCategory
-- @author Kosta Prokopiu
-- @copyright 2026 Kosta Prokopiu

local System = require("kpcrew.Addon.Systems.System")

local ngSystemCategory = {}

--- Instantiate a new system category
-- @param string name - name of category
-- @return Category - the created category object
function ngSystemCategory:new(name)
    ngSystemCategory.__index = ngSystemCategory
    local obj = {}
    setmetatable(obj, ngSystemCategory)

	obj.className = "SystemCategory"
	
    obj.name = name
	obj.systems = {} -- list of systems
	
	print("+ "..obj.className.." {"..obj.name.."}")

    return obj
end

--- get classname
-- @return string "Category"
function ngSystemCategory:getClassName() return self.className end

--- set classname
-- @param string classname
function ngSystemCategory:setClassName(className) self.className = className end

--- Get name of Category
-- @return string - title of category
function ngSystemCategory:getName() return self.name end

--- Set the name of the Category
-- @param string name - title for Flow
function ngSystemCategory:setName(name) self.name = name end

--- Add a system to Category
-- @param System - system item to be appended to vategory
function ngSystemCategory:appendSystem(system) table.insert(self.systems,system) end

--- Insert a system item at specific position
-- @param system  - system to be inserted
-- @param int index - index at which to add
function ngSystemCategory:insertSystem(system, index) table.insert(self.systems,index,system) end
	
--- Get a specific system item based on index
-- @param int index - flow item's' index in table
-- @return System - flow item at index
function ngSystemCategory:getSystem(index) return self.systems[index] end

function ngSystemCategory:getSystems() return self.systems end

function ngSystemCategory:render()
	if self ~= nil then
		if imgui.TreeNode(self.name) then
			for _, system in ng_pairsByKeys(self.systems) do system:render() end		
		imgui.TreePop()
        end
	end
end

return ngSystemCategory