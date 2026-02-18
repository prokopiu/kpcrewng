-- A preferences 
-- Preferences can also be used for background variables to persist kpcrew specific states and values
--
-- @classmod PreferenceItem
-- @author Kosta Prokopiu
-- @copyright 2026 Kosta Prokopiu

require "kpcrew.Addon.Preferences.PreferenceDataType"

local ngPreferenceItem = {
}

--- Instantiate a new preference item
-- @param string name -  Key of preference
-- @param object value of preference
-- @param int datatype 
-- @param string title 
function ngPreferenceItem:new(name, value, datatype, title, xpath)
    ngPreferenceItem.__index = ngPreferenceItem
    local obj = {}
    setmetatable(obj, ngPreferenceItem)

	obj.className = "PreferenceItem"
	
	obj.name = name -- = key
	obj.value = value
	obj.type = datatype
	obj.title = title
	obj.xpath = xpath -- optional xpath

    return obj
end

--- get Classname
-- @return string "PreferenceItem"
function ngPreferenceItem:getClassName() return self.className end

--- get name of preference
-- @return string name
function ngPreferenceItem:getName() return self.name end

--- set name of preference
-- @param string name
function ngPreferenceItem:setName(name) self.name = name end

--- get xpath of preference
-- @return string xpath
function ngPreferenceItem:getXpath() return self.xpath end

--- set xpath of preference
-- @param string xpath
function ngPreferenceItem:setXpath(xpath) self.xpath = xpath end

--- get value of preference
-- @return object value
function ngPreferenceItem:getValue()
	if type(self.value) == 'function' then
		return self.value()
	else
		return self.value
	end
end

--- set value of preference
-- @tparam object 
function ngPreferenceItem:setValue(value)
	if type(self.value) ~= 'function' then
		self.value = value
	end
end

--- get data type of preference
-- @return int datatype
function ngPreferenceItem:getType()
    return self.type
end

--- set type of preference
-- @param int datatype 
function ngPreferenceItem:setType(datatype)
    self.type = datatype
end

--- get title of preference
-- @return string title
function ngPreferenceItem:getTitle()
	if type(self.title) == 'function' then
		return self.title()
	else
		return self.title
	end
end

--- set title of preference
-- @tparam string title 
function ngPreferenceItem:setTitle(title)
	if type(self.title) ~= 'function' then
		self.title = title
	end
end

-- ===== UI related functionality =====

-- Render preference in imgui window
function ngPreferenceItem:render(type)
	if self ~= nil then
		local splitTitle = ng_split(self:getTitle(),"|")
		if type == "tree" then
			if self.type == ng_type_int then
				ng_imgui_in_lintfield(self:getName(), 10+string.len(self:getValue())*7, color_orange, tonumber(splitTitle[2]), splitTitle[1], color_white, 
				tonumber(self:getValue()), function (textin) self:setValue(textin) end, 200)
			end
			if self.type == ng_type_float then
				ng_imgui_in_lfloatfield(self:getName(), 25+string.len(self:getValue())*7, color_orange, tonumber(splitTitle[2]), splitTitle[3], splitTitle[1], color_white, 
				tonumber(self:getValue()), function (textin) self:setValue(textin) end, 200)
			end
			if self.type == ng_type_text then
				ng_imgui_in_ltfield(self:getName(), 10+string.len(self:getValue())*7, color_orange, 255, splitTitle[1], color_white, 
				self:getValue(), function (textin) self:setValue(textin) end, 200)
			end
			if self.type == ng_type_divider then
				imgui.PushTextWrapPos(330)
				imgui.PopTextWrapPos()
			end
			if self.type == ng_type_info then
				if splitTitle[2] == nil or splitTitle[2] == "" then splitTitle[2] = 0xFF95C857 end
				ng_imgui_out_text(splitTitle[2], splitTile[1], color_white, ""..self.name.."="..tostring(self.value),200)
			end
			if self.type == ng_type_flag then
				ng_imgui_out_text(color_white, splitTitle[1]) imgui.SameLine(200)
				imgui.PushID(splitTitle[1])
					ng_imgui_in_rbtoggle(splitTitle[2], splitTitle[3], self:getValue(), function (textin) self:setValue(textin) end)
				imgui.PopID()
			end
			if self.type == ng_type_list then
				ng_imgui_out_text(color_white, splitTitle[1]) imgui.SameLine(200)
				local function ff(a,...)x=...and f(...)return x and#x>#a and x or a end
				ng_imgui_in_combolist(splitTitle[1], splitTitle, self:getValue(), function (textin) self:setValue(textin) end, 100)
			end
			if self.datatype == ng_type_comfreq then
				ng_imgui_in_floatfield(splitTitle[1], 0, color_orange, 0.005, "%6.3f",
				tonumber(self:getValue()), function (textin) self:setValue(textin) end)
				imgui.SameLine(200)
				ng_imgui_in_button(splitTitle[1].."btn", "<->", 20, 15, 
					function () set("sim/cockpit2/radios/actuators/com1_frequency_hz_833",self:getValue()*1000) end)
			end
			if self.datatype == ng_type_navfreq then
				ng_imgui_in_floatfield(splitTitle[1], 0, color_orange, 0.05, "%5.2f",
				tonumber(self:getValue()), function (textin) self:setValue(textin) end)
				imgui.SameLine(200)
				ng_imgui_in_button(splitTitle[1].."btn", "<->", 20, 15, 
					function ()
						if splitTitle[2] ~= "2" then 
							set("sim/cockpit2/radios/actuators/nav1_frequency_hz",self:getValue()*100) 
						else
							set("sim/cockpit2/radios/actuators/nav2_frequency_hz",self:getValue()*100) 
						end 
					end)
			end

		end
	end
end

--
--	if self.datatype == self.typeExecButton then
--		imgui.PushID(splitTitle[1])
--			if imgui.Button(splitTitle[2]) then
--				local fnct = loadstring(splitTitle[3])
--				fnct()
--			end
--		imgui.PopID()
--	end
--		end
--	end
--end

-- return the line to be written into the .preferences file
function ngPreferenceItem:getSaveLine()
	
	if self.type == ng_type_int or self.type == ng_type_float or self.type == ng_type_list or self.type == ng_type_comfreq or self.type == ng_type_navfreq then
		return self.name .. "=" .. self.value .. "\n"
	end
	if self.type == ng_type_flag or self.type == ng_type_toggle then
		if self.value then
			return self.name .. "=true\n"
		else
			return self.name .. "=false\n"
		end
	end
	if self.type == ng_type_text then
		return self.name .. "=\"" .. self.value .. "\"\n"
	end
	return "" 
end

return ngPreferenceItem