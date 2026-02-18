-- Enumeration of sop states
-- @author Kosta Prokopiu
-- @copyright 2026 Kosta Prokopiu

ng_sopStates = {
	[1]	= "NEW",
	[2] = "STARTED"
}

-- flight phase index
ng_sopstate_new			= 1
ng_sopstate_started		= 2

--- get sop state string based on index
-- @param int index - index of state
-- @return string - flow item state text
function ng_get_sopstate_title(key)
	return ng_sopStates[key] end
