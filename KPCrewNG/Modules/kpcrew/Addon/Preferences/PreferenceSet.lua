-- Set of preferences 
-- The set combines one or more preference groups, each group containing one to many single preferences
-- Preferences can also be used for background variables to persist kpcrew specific states and values
--
-- @classmod PreferenceSet
-- @author Kosta Prokopiu
-- @copyright 2026 Kosta Prokopiu

require "kpcrew.Addon.Preferences.PreferenceDataType"

PreferenceGroup = require("kpcrew.Addon.Preferences.PreferenceGroup")

local xml2lua = require("kpcrew/xml2lua")
xmlhandler = require("kpcrew/xmlhandler.tree")

local ngPreferenceSet = {
}

--- Instantiate a new preference set
-- @param string name - Name of the set
-- @param string title - title of set
-- @return PreferenceSet - the created preference set object 
function ngPreferenceSet:new(name, title, filePath)
    ngPreferenceSet.__index = ngPreferenceSet
    local obj = {}
    setmetatable(obj, ngPreferenceSet)

	obj.className = "PreferenceSet"
	
    obj.name = name
	obj.title = title
	obj.groups = {}
	obj.filePath = filePath
	
    return obj
end

--- get classname
-- @return string "PreferenceSet"
function ngPreferenceSet:getClassName() return self.className end

--- Get name of preference set
-- @return string name of set
function ngPreferenceSet:getName() return self.name end

--- Set name of preference set
-- @param string name - name of set
function ngPreferenceSet:setName(name) self.name = name end

--- Get title of preference set
-- @return string title of set
function ngPreferenceSet:getTitle() return self.title end

--- Set title of preference set
-- @param string title - title of set
function ngPreferenceSet:setTitle(title) self.title = title end

--- Get filePath of preference set file
-- @return string filePath of set
function ngPreferenceSet:getFilePath() return self.filePath end

--- set filePath of preference set file
-- @param string path - filePath of set
function ngPreferenceSet:setFilePath(path) self.filePath = path end

--- Add a preference group to the set
-- @param PreferenceGroup group to add
function ngPreferenceSet:addGroup(group) table.insert(self.groups, group) end

--- Return all registered groups from set
-- @treturn array PreferenceGroup
function ngPreferenceSet:getAllGroups() return self.groups end

--- Find a preference object in all groups
-- key contains the group and the key such as general:flight_state
-- @param string inkey Key of preference to find
-- @return PreferenceItem found preference or nil
function ngPreferenceSet:find(inkey)
	local splits = ng_split(inkey,":")
	for _, ngroup in ipairs(self.groups) do
		if ngroup ~= nil and splits[1] == ngroup:getName() then
			local found = ngroup:find(splits[2])
			if found ~= nil then return found end
		end
	end
	return nil
end

--- Get the value of a preference object
-- key contains the group and the key such as general:flight_state
-- @param string inkey Key of preference to find
-- @return object value of preference 
function ngPreferenceSet:get(inkey)
	local pref = self:find(inkey)
	if pref ~= nil then
		if pref:getType() == ng_type_int then
			return tonumber(pref:getValue())
		elseif pref:getType() == ng_type_float then
			return pref:getValue() + 0.0
		else
			return pref:getValue()
		end
	end
end

--- set the value of a preference object
-- key contains the group and the key such as general:flight_state
-- @param string inkey Key of preference to find
-- @param object value to set
function ngPreferenceSet:set(inkey, value)
	local pref = self:find(inkey)
	if pref ~= nil then
		return pref:setValue(value)
	end
end

--- Save all preferences with group prefix to .preferences file
function ngPreferenceSet:save()
	local filePrefs = io.open(self.filePath, "w+")
	for _, group in ipairs(self.groups) do
		group:save(filePrefs)
	end
	filePrefs:close()
end

--- Read all groups:preferences from file
function ngPreferenceSet:load()
	for _, group in ipairs(self.groups) do
		local filePrefs = io.open(self.filePath, "r")
		if filePrefs then
			group:load(filePrefs)
			filePrefs:close()
		end
	end
end	

--- Read values from simbrief xml
-- @param xml2lua handler
function ngPreferenceSet:sbLoad()
	for _, group in ipairs(self.groups) do
		if xmlhandler then
			group:sbLoad(xmlhandler)
		end
	end
end	

-- ===== UI related functionality =====

--- Render all preferences and groups in imgui window
-- @param type "tree"
function ngPreferenceSet:render(type)
	if self ~= nil then
		if type == "tree" then
			if imgui.TreeNode(self.title) then
				for _, group in ipairs(self.groups) do
					group:render(type)
				end		
			imgui.TreePop()
	        end
		end
	end
end

return ngPreferenceSet