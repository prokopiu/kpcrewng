-- Base class for Aircraft Systems
-- A System Set contains the definition and functionalities of all addon related system items
--
-- @classmod ngAddonSystems
-- @author Kosta Prokopiu
-- @copyright 2026 Kosta Prokopiu

local Category = require("kpcrew.Addon.Systems.SystemCategory")
local System = require("kpcrew.Addon.Systems.System")
local Element = require("kpcrew.Addon.Systems.SystemElement")
local JsonExport = require ("kpcrew.json_pretty_print")

local ngAddonSystems = {}

--- Instantiate a new Systems set
-- @param string title - Name of the Systems set
-- @param string filePath - Path of the systems json to load
-- @return self object
function ngAddonSystems:new(title, filePath)
    ngAddonSystems.__index = ngAddonSystems
    local obj = {}
    setmetatable(obj, ngAddonSystems)

	obj.className = "AddonSystems"
	
    obj.title = title
	obj.filePath = filePath
	
	obj.categories = {} -- all associated flows
	
	print("+ "..obj.className.." {"..obj.title.."}")
	
    return obj
end

--- get classname
-- @return string classname
function ngAddonSystems:getClassName() return self.className end

--- Get title of Systems
-- @return string - title of Systems
function ngAddonSystems:getTitle() return self.title end

--- Set the title of the Systems
-- @param string title - title for Systems
function ngAddonSystems:setTitle(title) self.title = title end

--- Add a system category to Systems
-- @param SystemCategory category - category to be appended to Systems flows
function ngAddonSystems:appendCategory(category) table.insert(self.categories,category) end

--- Insert a category at specific position
-- @param SystemCategory category - category to be appended to Systems flows
-- @param int index - index at which to add
function ngAddonSystems:insertCategory(category, index) table.insert(self.categories,index,category) end
	
--- Get a specific category based on index
-- @param int index - categories index in table
-- @return SystemCategory - category at index
function ngAddonSystems:getCategory(index) return self.categories[index] end

--- Get a all categories
-- @return SystemCategory - category at index
function ngAddonSystems:getCategories() return self.categories end

--- Set categories table
-- @param SystemCategory[] to set
function ngAddonSystems:setCategories(categories) self.categories = categories end

--- Find a system element object in all groups
-- key contains the group and the key such as general:flight_state
-- @param string inkey Key of system element to find
-- @return SystemElement found preference or nil
function ngAddonSystems:find(inkey)

	for _,catnode in pairs(self.categories) do
		local systems = catnode:getSystems()
		if systems ~= nil then
			for _,systemnode in pairs(systems) do
				local elements = systemnode:getElements()
				if elements ~= nil then
					for _,elemnode in pairs(elements) do
						if elemnode:getName() == inkey then
							return elemnode
						end
					end
				end
			end
		end
	end
	return nil
end

--- Find a system object in all groups
-- key contains the group and the key such as general:flight_state
-- @param string inkey Key of system element to find
-- @return SystemElement found preference or nil
function ngAddonSystems:findSystem(inkey)
	for _,catnode in pairs(self.categories) do
		local systems = catnode:getSystems()
		if systems ~= nil then
			for _,systemnode in pairs(systems) do
				if systemnode:getName() == inkey then
					return systemnode
				end
			end
		end
	end
	return nil
end

--- Load Systems
function ngAddonSystems:load()
	if ng_file_exists(self.filePath) then
		local json = require "kpcrew.json"
		local file = io.open(self.filePath, "r")
		local jsonstr = ""
		for line in file:lines() do
		    jsonstr = jsonstr .. line
		end
		file:close()

		local systems = json.parse(jsonstr)

		for catkey,catnode in pairs(systems.addonsystems.categories) do
		    local category = Category:new(catnode.name)
			local systems = catnode.systems
			if systems ~= nil then
			    for syskey,systemnode in pairs(systems) do
			        local system = System:new(systemnode.name)
			        category:appendSystem(system)
					local elements = systemnode.elements
					if elements ~= nil then
						for elemkey,elemnode in pairs(elements) do
							local element = Element:new(elemnode.name, elemnode.title, elemnode)
							system:appendElement(element)
						end
					end
			    end
			end
		    self:appendCategory(category)
		end
	end
end

--- save systems
function ngAddonSystems:save() 
	print(JsonExport:pretty_print(self.categories))
end
	
-- ===== UI related functionality =====

function ngAddonSystems:render()
	if self ~= nil then
		if imgui.TreeNode(self.title) then
			for _, category in ipairs(self.categories) do category:render() end		
		imgui.TreePop()
        end
	end
end

return ngAddonSystems