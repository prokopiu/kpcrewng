require "kpcrew.Addon.Preferences.PreferenceDataType"

local preferenceSet = require( "kpcrew.Addon.Preferences.PreferenceSet" )
local preferenceGroup = require( "kpcrew.Addon.Preferences.PreferenceGroup" )
local preference = require("kpcrew.Addon.Preferences.PreferenceItem")

local applicationPrefSet = preferenceSet:new("application","APPLICATION PREFERENCES",SCRIPT_DIRECTORY .. "../Modules/kpcrew_prefs/application.preferences")

local general = preferenceGroup:new("general","GENERAL PREFERENCES")
general:add(preference:new("assistance",false,ng_type_flag,"Assistance|On|Off"))
general:add(preference:new("jumpflow",false,ng_type_flag,"Jump to next flow|On|Off"))
general:add(preference:new("simbriefuser","",ng_type_text,"Simbrief Username|"))
general:add(preference:new("xpdrmode",1,ng_type_list,"VATSIM XPDR Mode|USA|Europe"))
general:add(preference:new("weightunit",1,ng_type_list,"Weight Unit|kgs|lbs"))
general:add(preference:new("barounit",1,ng_type_list,"Baro Unit|mb|inhg"))
general:add(preference:new("deftransalt",5000,ng_type_int,"Default Transalt|0"))
general:add(preference:new("deftranslvl",6000,ng_type_int,"Default Translvl|0"))
general:add(preference:new("mcpdefspd",100,ng_type_int,"MCP Initial Speed|0"))
general:add(preference:new("mcpdefhdg",1,ng_type_int,"MCP Initial Heading|0"))
general:add(preference:new("mcpdefalt",4900,ng_type_int,"MCP Initial Altitude|0"))
general:add(preference:new("startupapu",false,ng_type_flag,"APU @ start|On|Off"))
general:add(preference:new("startupgpu",true,ng_type_flag,"GPU @ start|On|Off"))

applicationPrefSet:addGroup(general)

function ng_getAppPrefs()
	return applicationPrefSet
end