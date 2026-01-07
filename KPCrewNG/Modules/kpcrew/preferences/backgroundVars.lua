-- Backgrond variables for use by KPCrew internally
--
-- @author Kosta Prokopiu
-- @copyright 2026 Kosta Prokopiu

activeBckVars = kcPreferenceSet:new("BackgroundVars")

local general = kcPreferenceGroup:new("general","General variables")
general:add(kcPreference:new("simversion", " ",	kcPreference.typeText, "Simversion|"))
general:add(kcPreference:new("flight_state", 1, kcPreference.typeInt, "Flight State|1"))
general:add(kcPreference:new("weight_unit", "kgs", kcPreference.typeText, "Weight Unit|"))


local ui = kcPreferenceGroup:new("ui","UI Settings")
ui:add(kcPreference:new("fontscale", 1.0, kcPreference.typeFloat, "Font Scale|0.1"))
ui:add(kcPreference:new("main_wnd_width", 950, kcPreference.typeInt, "Main Window Width|"))
ui:add(kcPreference:new("main_wnd_height", 950, kcPreference.typeInt, "Main Window Height|"))
ui:add(kcPreference:new("main_wnd_xpos", 70, kcPreference.typeInt, "Main Window X Pos|"))
ui:add(kcPreference:new("main_wnd_ypos", 50, kcPreference.typeInt, "Main Window Y Pos|"))

activeBckVars:addGroup(general)
activeBckVars:addGroup(ui)
activeBckVars:addGroup(kc_global_procvars)

function getBckVars()
	return activeBckVars
end

return backgroundVars