--[[
	*** KPCREWNG 0.1 
	General utilities used in kpcrew
	Kosta Prokopiu, 2026
--]]

local TwoStateDrefSwitch 	= require "kpcrew.systems.TwoStateDrefSwitch"
local TwoStateCmdSwitch	 	= require "kpcrew.systems.TwoStateCmdSwitch"
local TwoStateCustomSwitch 	= require "kpcrew.systems.TwoStateCustomSwitch"
local SwitchGroup  			= require "kpcrew.systems.SwitchGroup"
local SimpleAnnunciator 	= require "kpcrew.systems.SimpleAnnunciator"
local CustomAnnunciator 	= require "kpcrew.systems.CustomAnnunciator"
local TwoStateToggleSwitch	= require "kpcrew.systems.TwoStateToggleSwitch"
local MultiStateCmdSwitch 	= require "kpcrew.systems.MultiStateCmdSwitch"
local InopSwitch 			= require "kpcrew.systems.InopSwitch"
local KeepPressedSwitchCmd	= require "kpcrew.systems.KeepPressedSwitchCmd"

------------- file related functions ---------------

--- check if external lua file exists
-- @param string name path and filename to search
-- @return true/false for existance
function kc_file_exists(name)
	local f=io.open(name,"r")
	if f~=nil then 
		io.close(f) 
		return true 
	else 
		return false 
	end
end

-------------- Array related functions -------------

--- Split string with delimiter
-- @param string s input string
-- @param string delimiter character
-- @return array string
function kc_split(s, delimiter)
    result = {};
    for match in (s..delimiter):gmatch("(.-)"..delimiter) do
        table.insert(result, match);
    end
    return result;
end

--- Split preference title | delimiter
-- @param string s input string
-- @return array string
function kc_pref_split(s)
	return kc_split(s,"|")
end

-------------- process variable related utilities ---------------

--- does procvar exist?
-- @param string procvarid - identifier for procvar
-- @return bool - true if exists
function kc_procvar_exists(procvarid)
	local procvar = getBckVars():find("procvars:" .. procvarid)
	if procvar == nil then return false else return true end
end
	
--- toggle a boolean procvar
-- @param string procvarid - identifier for procvar
function kc_procvar_toggle(procvarid)
	local procvar = getBckVars():find("procvars:" .. procvarid)
	if procvar:getValue() == true then 
		procvar:setValue(false)
	else
		procvar:setValue(true)
	end
end

--- set a procvar
-- @param string procvarid - identifier for procvar
-- @param string value - value to set
function kc_procvar_set(procvarid, value)
	local procvar = getBckVars():find("procvars:" .. procvarid)
	procvar:setValue(value)
end

--- initialize a boolean procvar
-- @param string procvarid - identifier for procvar
-- @param bool value - value to set
function kc_procvar_initialize_bool(procvarid, value)
	local procvar = getBckVars():find("procvars:" .. procvarid)
	if procvar == nil then 
		kc_global_procvars:add(kcPreference:new(procvarid,value,kcPreference.typeToggle,procvarid .. "|TRUE|FALSE"))
	else
		kc_procvar_set(procvarid,value)
	end
end

--- initialize a counter procvar
-- @param string procvarid - identifier for procvar
-- @param int value - value to set
function kc_procvar_initialize_count(procvarid, value)
	local procvar = getBckVars():find("procvars:" .. procvarid)
	if procvar == nil then 
		kc_global_procvars:add(kcPreference:new(procvarid,value,kcPreference.typeInt,procvarid .. "|0"))
	else
		kc_procvar_set(procvarid,value)
	end
end

--- initialize a string procvar
-- @param string procvarid - identifier for procvar
-- @param string value - value to set
function kc_procvar_initialize_string(procvarid, value)
	local procvar = getBckVars():find("procvars:" .. procvarid)
	if procvar == nil then 
		kc_global_procvars:add(kcPreference:new(procvarid,value,kcPreference.typeText,procvarid .. "|"))
	else
		kc_procvar_set(procvarid,value)
	end
end

--- get boolean procvar
-- @param string procvarid - identifier for procvar
-- @return bool - true or false
function kc_procvar_get(procvarid)
	local procvar = getBckVars():find("procvars:".. procvarid)
	return procvar:getValue()
end

---------------------- SOP related functions ---------

--- generically set up a system element (switch) for more generic setup
-- @param table eDef - definition of system element 
function kc_setup_element(eDef)
	if eDef.etype == kc_swtype_2StateCmd then
		return TwoStateCmdSwitch:new(eDef.name,eDef.drefName,eDef.drefIndex,eDef.cmd1,eDef.cmd2,eDef.cmd3)
	elseif eDef.etype == kc_swtype_toggleCmd then
		return TwoStateToggleSwitch:new(eDef.name,eDef.drefName,eDef.drefIndex,eDef.cmd1)
	elseif eDef.etype == kc_swtype_multistate then
		return MultiStateCmdSwitch:new(eDef.name,eDef.drefName,eDef.drefIndex,eDef.cmd1,eDef.cmd2,eDef.msMin,eDef.msMax,eDef.msRead,eDef.msDiff)
	elseif eDef.etype == kc_swtype_dref then
		return TwoStateDrefSwitch:new(eDef.name,eDef.drefName,eDef.drefIndex)
	elseif eDef.etype == kc_swtype_inop then 
		return InopSwitch:new(eDef.name)
	elseif eDef.etype == kc_swtype_customCmd then 
		return TwoStateCustomSwitch:new(eDef.name,eDef.drefName,eDef.drefIndex,eDef.funcOn,eDef.funcOff,eDef.funcTgl,eDef.funcStat,eDef.funcStep,eDef.funcSet)
	elseif eDef.etype == kc_swtype_annunciator then 
		return SimpleAnnunciator:new(eDef.name,eDef.drefName,eDef.drefIndex)
	elseif eDef.etype == kc_swtype_customAnn then 
		return CustomAnnunciator:new(eDef.name,eDef.funcOn)
	end
end