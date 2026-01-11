-- Enumeration of flow item roles
-- @author Kosta Prokopiu
-- @copyright 2026 Kosta Prokopiu

ng_flowItemRoles = {
	[1]  = "PF",	-- pilot flying (you)
	[2]  = "PNF",	-- pilot not flying (virtual)
	[3]  = "PM",	-- pilot monitoring (virtual)
	[4]  = "BOTH",	-- both have responses
	[5]  = "F/O",	-- first officer (virtual)
	[6]  = "CPT",	-- captain (you)
	[7]  = "LHS",	-- left hand seat (you)
	[8]  = "RHS",	-- right hand seat (virtual)
	[9]  = "FE",	-- flight engineer on some aircraft (virtual)
	[10] = "CM1",	-- Crew Management 1 = Captain
	[11] = "CM2",	-- Crew Management 2 = FO
	[12] = "CM3",	-- Crew Management 3 = FE
	[13] = "ALL"	-- All crew members
}

-- flight phase index
ng_firole_PF  	= 1  
ng_firole_PNF 	= 2  
ng_firole_PM  	= 3  	
ng_firole_BOTH 	= 4  
ng_firole_FO 	= 5  
ng_firole_CPT 	= 6  
ng_firole_LHS 	= 7  
ng_firole_RHS 	= 8  
ng_firole_FE 	= 9 
ng_firole_CM1 	= 10
ng_firole_CM2 	= 11
ng_firole_CM3 	= 12
ng_firole_ALL 	= 13

--- get fi role string based on index
-- @param int index - index of role
-- @return string - flow item role text
function ng_get_firole(key) return ng_flowItemRoles[key] end
