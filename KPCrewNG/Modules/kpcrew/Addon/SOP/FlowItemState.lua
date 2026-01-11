-- Enumeration of flow item states
-- @author Kosta Prokopiu
-- @copyright 2026 Kosta Prokopiu

ng_flowItemStates = {
	[1]	= "NEW"
}

-- flight phase index
ng_fistate_new			= 1

--- get fi state string based on index
-- @param int index - index of state
-- @return string - flow item state text
function ng_get_fistate_title(key)
	return ng_flowItemStates[key] end
