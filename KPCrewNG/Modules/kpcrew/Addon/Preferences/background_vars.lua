require "kpcrew.Addon.Preferences.PreferenceDataType"

local preferenceSet = require( "kpcrew.Addon.Preferences.PreferenceSet" )
local preferenceGroup = require( "kpcrew.Addon.Preferences.PreferenceGroup" )
local preference = require("kpcrew.Addon.Preferences.PreferenceItem")

local backgroundVarsSet = preferenceSet:new("bck","BACKGROUND VARIABLES",SCRIPT_DIRECTORY .. "../Modules/kpcrew_prefs/bck.preferences")

local general = preferenceGroup:new("general","GENERAL BCK VARS")
general:add(preference:new("flightstate", 1, ng_type_int, "Flight State|1"))
general:add(preference:new("weightunit", "kgs", ng_type_text, "Weight Unit|"))
general:add(preference:new("timeout", "--:--", ng_type_text, "Times OUT|"))
general:add(preference:new("timeoff", "--:--", ng_type_text, "Times OFF|"))
general:add(preference:new("timeon", "--:--", ng_type_text, "Times ON|"))
general:add(preference:new("timein", "--:--", ng_type_text, "Times IN|"))
general:add(preference:new("auxvar1", "", ng_type_text, "AUX Var 1|"))

backgroundVarsSet:addGroup(general)

function ng_getBckVars()
	return backgroundVarsSet
end