require "kpcrew.Addon.Preferences.PreferenceDataType"

local preferenceSet = require( "kpcrew.Addon.Preferences.PreferenceSet" )
local preferenceGroup = require( "kpcrew.Addon.Preferences.PreferenceGroup" )
local preference = require("kpcrew.Addon.Preferences.PreferenceItem")

local applicationPrefSet = preferenceSet:new("application","APPLICATION PREFERENCES",SCRIPT_DIRECTORY .. "../Modules/kpcrew_prefs/application.preferences")

local general = preferenceGroup:new("general","GENERAL PREFERENCES")
general:add(preference:new("assistance",	false,ng_type_flag,"Assistance|On|Off"))
general:add(preference:new("usechecklist",	true,ng_type_flag,"Use Checklists|Yes|No"))
general:add(preference:new("showstars",		true,ng_type_flag,"Show * Items|Yes|No"))
general:add(preference:new("jumpflow",		false,ng_type_flag,"Jump to next flow|On|Off"))
general:add(preference:new("simbriefuser",	"",ng_type_text,"Simbrief Username|"))
general:add(preference:new("xpdrmode",		1,ng_type_list,"VATSIM XPDR Mode|USA|Europe"))
general:add(preference:new("weightunit",	1,ng_type_list,"Weight Unit|kgs|lbs"))
general:add(preference:new("barounit",		1,ng_type_list,"Baro Unit|mb|inhg"))
general:add(preference:new("deftransalt",	5000,ng_type_int,"Default Transalt|0"))
general:add(preference:new("deftranslvl",	6000,ng_type_int,"Default Translvl|0"))
general:add(preference:new("opensam",		false,ng_type_flag,"Use OpenSAM|On|Off"))

local kphwng = preferenceGroup:new("kphwng","KPHardware specific settings")
-- level of exposure (to save memory and ressources
-- 1 = basic (a/p, basic functions (gear, flaps etc...)
-- 2 = full (everything filtered)
kphwng:add(preference:new("levelfull",		false,ng_type_flag,	"Full Support?|Yes|No"))
kphwng:add(preference:new("extlights",		false,ng_type_flag,	"Extended Lights?|Yes|No"))
kphwng:add(preference:new("efis",			false,ng_type_flag,	"Support EFIS?|Yes|No",
	nil,"return ng_getAppPrefs():get(\"kphwng:levelfull\")"))
kphwng:add(preference:new("extap",			false,ng_type_flag,	"Extended Autopilot?|Yes|No",
	nil,"return ng_getAppPrefs():get(\"kphwng:levelfull\")"))
kphwng:add(preference:new("lightann",		false,ng_type_flag,	"Light Annunciators?|Yes|No",
	nil,"return ng_getAppPrefs():get(\"kphwng:levelfull\")"))
kphwng:add(preference:new("extmcp",			false,ng_type_flag,	"Extended MCP?|Yes|No",
	nil,"return ng_getAppPrefs():get(\"kphwng:levelfull\")"))

kphwng:add(preference:new("bravo",			false,ng_type_flag,"Support Bravo Throttle|Yes|No"))
kphwng:add(preference:new("alpha",			false,ng_type_flag,"Support Alpha Yoke|Yes|No"))
kphwng:add(preference:new("thryoke",		false,ng_type_flag,"Support THR Boeing Yoke|Yes|No"))
kphwng:add(preference:new("thrwarthog",		false,ng_type_flag,"Support THR Warthog Stick|Yes|No"))
kphwng:add(preference:new("thrwarthog",		false,ng_type_flag,"Support THR Warthog Stick|Yes|No"))

local kpcrew = preferenceGroup:new("kpcrew","KPCrew internal settings")
kpcrew:add(preference:new("developer",		false,ng_type_flag,"Show Editors|On|Off"))
kpcrew:add(preference:new("syshiderem",		true,ng_type_flag,"Hide Sys Add/Remove|On|Off"))

applicationPrefSet:addGroup(general)
applicationPrefSet:addGroup(kphwng)
applicationPrefSet:addGroup(kpcrew)

function ng_getAppPrefs()
	return applicationPrefSet
end