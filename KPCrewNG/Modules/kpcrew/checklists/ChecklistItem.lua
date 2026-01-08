-- Standard checklist Item to be added to procedures
--
-- @classmod ChecklistItem inherits from FlowItem
-- @author Kosta Prokopiu
-- @copyright 2026 Kosta Prokopiu

local kcChecklistItem = {
}

local FlowItem 			= require "kpcrew.FlowItem"

--- Instantiate a new ChecklistItem
-- @param string challengeText - the left hand text on the checklist 
-- @param string responseText - right side of the checklist with response
-- @param string actor - actor code for the item
-- @param int waittime - waiting time for item in seconds during execution 
-- @param function() validFunc - shall return true or false to verify if condition is met or not
-- @param function() actionFunc - will be executed and make changes to aircraft settings
-- @param function() skipFunc - if true will skip the item and not display in list
-- @return obj - new checklist item
function kcChecklistItem:new(challengeText,responseText,actor,waittime,validFunc,actionFunc,skipFunc)
    kcChecklistItem.__index = kcChecklistItem
	setmetatable(kcChecklistItem, { __index = FlowItem })
    local obj = FlowItem:new(challengeText,responseText,actor,waittime,validFunc,actionFunc,skipFunc)
    setmetatable(obj, kcChecklistItem)

	obj.className = "ChecklistItem"

    return obj
end

--- get wait time depending on sound output (wav play takes time)
-- @return int waittime
function kcChecklistItem:getWaitTime()
	if getActivePrefs():get("general:assistance") < 2 then return 0 else return self.waittime end
end

--- speak the challenge text
function kcChecklistItem:speakChallengeText()
	if getActivePrefs():get("general:assistance") > 1 then
		if not self:isUserRole() or self:getActor()	== FlowItem.actorBOTH then
			if self:isValid() then
				kc_speakNoText(0,kc_parse_string(self:getChallengeText() .. ".    " .. self:getResponseText()))
			else
				kc_speakNoText(0,kc_parse_string(self:getChallengeText() .. ". Please check! Should be ".. self:getResponseText()))
			end
		else
			kc_speakNoText(0,kc_parse_string(self:getChallengeText()))
		end
	end	
end

return kcChecklistItem