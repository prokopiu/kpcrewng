-- Enumeration of flow item states
-- @author Kosta Prokopiu
-- @copyright 2026 Kosta Prokopiu

ng_flowItemStates = {
	[0] = "UNDEFINED",
	[1]	= "NEW",
	[2] = "RUN",
	[3] = "END",
	[4] = "PAUSE",
	[5] = "ERROR",
	[6] = "CHECKED",
	[7] = "RESPONDED",
	[8] = "ACTIONED",
	[9] = "DELAYED",
	[10] = "WAIT FOR CPT"
}

-- flight phase index
ng_fistate_na			= 0
ng_fistate_new			= 1
ng_fistate_run			= 2
ng_fistate_end			= 3
ng_fistate_pause		= 4
ng_fistate_err			= 5
ng_fistate_chk			= 6
ng_fistate_res			= 7
ng_fistate_act			= 8
ng_fistate_del			= 9
ng_fistate_cpt			= 10

