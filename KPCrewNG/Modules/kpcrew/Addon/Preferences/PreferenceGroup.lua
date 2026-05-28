-- Group of preferences 
-- The group combines one or more preferences thematically 
-- Preferences can also be used for background variables to persist kpcrew specific states and values
--
-- @classmod PreferenceGroup
-- @author Kosta Prokopiu
-- @copyright 2026 Kosta Prokopiu

require "kpcrew.Addon.Preferences.PreferenceDataType"
local PreferenceItem = require("kpcrew.Addon.Preferences.PreferenceItem")

local ngPreferenceGroup = {
}

-- Instantiate a new preference group
-- @param string name Name of the set 
-- @param string title Title string to display in window
function ngPreferenceGroup:new(name, title)
    ngPreferenceGroup.__index = ngPreferenceGroup
    local obj = {}
    setmetatable(obj, ngPreferenceGroup)
	
	obj.className = "PreferenceGroup"

    obj.name = name
	obj.title = title
	obj.preferences = {}

	dprint("+ "..obj.className.." {"..obj.name..","..obj.title.." }")
	
    return obj
end

--- get Classname
-- @return string "PreferenceGroup"
function ngPreferenceGroup:getClassName() return self.className end

--- Get name of preference set
-- @return string name of set
function ngPreferenceGroup:getName() return self.name end

--- set name of preference set
-- @param string name - name of set
function ngPreferenceGroup:setName(name) self.name = name end

--- Get title of preference set
-- @return string title for display
function ngPreferenceGroup:getTitle() return self.title end

--- set title of preference set
-- @param string title - title of set
function ngPreferenceGroup:setTitle(title) self.title = title end

-- ====== Preference management functionality ======
--- Add a preference to the group
-- @param Preference preference to add
function ngPreferenceGroup:add(preference) table.insert(self.preferences,preference) end

--- remove preference from group
-- @param string key of preference to remove
function ngPreferenceGroup:remove(key) table.remove(self.preferences,self:getIndex(key)) end

--- Return all registered preferences from group
-- @return array Preference
function ngPreferenceGroup:getAllPreferences() return self.preferences end

--- Find a preference object in group
-- @param string inkey Key of preference to find
-- @return Preference found preference or nil
function ngPreferenceGroup:find(inkey)
	for _, pref in ipairs(self.preferences) do
--		print(inkey.."-->"..pref:getName())
		if pref:getName() == inkey then return pref end
	end
	return nil
end

--- Get a preference value
-- @param string inkey Key of preference to find
-- @return Preference found preference or nil
function ngPreferenceGroup:get(inkey)
	local pref = self:find(inkey)
	if pref ~= nil then return pref:getValue() end
	return nil
end

--- Get the index of a preferene in the group array
-- @param string inkey Key of preference to find
-- @return int index of pref or -1
function ngPreferenceGroup:getIndex(key)
	local cnt = 0
	for _, pref in ipairs(self.preferences) do
		if pref:getName() == key then return cnt end
	end
	return -1
end

-- Save all preferences of group prefix to .preferences file
function ngPreferenceGroup:save(filePref)
	for _, pref in ipairs(self.preferences) do
		local saveLine = pref:getSaveLine()
		if saveLine ~= "" then 
			filePref:write(self.name .. ":" .. pref:getSaveLine())
		end
	end
end	

-- Read all preferences from file
function ngPreferenceGroup:load(filePref)
	for line in filePref:lines() do
		local key = nil
	    local value = nil
		local splits = ng_split(line,":")
		if splits[1] == self.name then
			local delim = string.find(splits[2], "=")
			if delim and delim > 1 and delim < string.len(line) then
				local key = string.sub(splits[2], 1, delim - 1)
				local value = string.sub(splits[2], delim + 1)
				local pref = self:find(key)
				if pref ~= nil then
					if pref:getType() == ng_type_flag or pref:getType() == ng_type_toggle then
						if value == "true" then 
							pref:setValue(true)
						else
							pref:setValue(false)
						end
					elseif pref:getType() == ng_type_text or pref:getType() == ng_type_info then
						pref:setValue(string.gsub(value,"\"",""))
					else
						pref:setValue(tonumber(value))
					end
				end
			end
	     end
	 end
end

-- Overwrite preferences from Simbrief XML
function ngPreferenceGroup:sbLoad()
	for _, pref in ipairs(self.preferences) do
		if pref:getXpath() and pcall(function () loadstring("return xmlhandler.root.OFP."..pref:getXpath())() end) then
			local element = loadstring("return xmlhandler.root.OFP."..pref:getXpath())()
			if type(element) ~= "table" then pref:setValue(element) end	
		end
	end
end

-- ===== UI related functionality =====

--- Render all preferences and groups in imgui window
-- @param type "tree", 
function ngPreferenceGroup:render(type)
	if self ~= nil then
		if type == "tree" then
			if imgui.TreeNode(self.title) then
				for _, pref in pairs(self.preferences) do
					imgui.SetNextItemOpen(true)
					pref:render(type)
				end
				imgui.TreePop()
			end
		end
	end
end

return ngPreferenceGroup