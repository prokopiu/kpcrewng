-- Enumeration of flow item states
-- @author Kosta Prokopiu
-- @copyright 2026 Kosta Prokopiu

ng_flowStates = {
	[1]	= "NEW"
}

-- flight phase index
ng_flowstate_new			= 1

--- get flow state string based on index
-- @param int index - index of state
-- @return string - flow state text
function ng_get_flowstate_title(key)
	return ng_flowStates[key] end
