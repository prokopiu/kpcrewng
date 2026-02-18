-- Enumeration of flow item states
-- @author Kosta Prokopiu
-- @copyright 2026 Kosta Prokopiu

ng_flowStates = {
	[0] = "UNDEFINED",
	[1]	= "NEW",
	[2] = "START",
	[3] = "RUN",
	[4] = "END",
	[5] = "PAUSE",
	[6] = "ERR"
}

-- flight phase index
ng_flowstate_na		= 0
ng_flowstate_new	= 1
ng_flowstate_start	= 2
ng_flowstate_run	= 3
ng_flowstate_end	= 4
ng_flowstate_pause 	= 5
ng_flowstate_err 	= 6

