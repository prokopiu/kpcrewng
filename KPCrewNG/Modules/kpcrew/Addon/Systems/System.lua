-- System of addon systems
--
-- @classmod System
-- @author Kosta Prokopiu
-- @copyright 2026 Kosta Prokopiu

local ngSystem = {}

--- Instantiate a new system system
-- @param string name - name of system
-- @return System - the created system object
function ngSystem:new(name)
    ngSystem.__index = ngSystem
    local obj = {}
    setmetatable(obj, ngSystem)

	obj.className = "System"
	
    obj.name = name
	obj.elements = {} -- list of elements
	
	print("+ "..obj.className.." {"..obj.name.."}")

    return obj
end

--- get classname
-- @return string "System"
function ngSystem:getClassName() return self.className end

--- Get name of System
-- @return string - title of system
function ngSystem:getName() return self.name end

--- Set the name of the Category
-- @param string name - title for Flow
function ngSystem:setName(name) self.name = name end

--- Add a system to Category
-- @param System - system item to be appended to vategory
function ngSystem:appendElement(element) table.insert(self.elements,element) end

--- Insert a system item at specific position
-- @param system  - system to be inserted
-- @param int index - index at which to add
function ngSystem:insertElement(element, index) table.insert(self.elements,index,element) end
	
--- Get a specific system item based on index
-- @param int index - flow item's' index in table
-- @return System - flow item at index
function ngSystem:getElement(index) return self.elements[index] end

--- Get elements of system
-- @return SystemElements
function ngSystem:getElements() return self.elements end

--- Set elements table
-- @param SystemElement[] elements
function ngSystem:setElements(elements) self.elements = elements end

--- render System
function ngSystem:render()
	if self ~= nil then
		if imgui.TreeNode(self.name) then
			for _, element in ipairs(self.elements) do element:render() end		
		imgui.TreePop()
        end
	end
end

return ngSystem