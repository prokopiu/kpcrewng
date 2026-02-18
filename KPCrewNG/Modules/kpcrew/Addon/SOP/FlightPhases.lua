-- Enumeration of flight phases
-- @author Kosta Prokopiu
-- @copyright 2026 Kosta Prokopiu

ng_flightphases = {
	[1]  	= "Flight Planning",
	[2] 	= "Cold & Dark",
	[3] 	= "Prel Preflight",
	[4] 	= "Preflight/Cockpit Prep",
	[5] 	= "Before Start",
	[6] 	= "After Start",
	[7] 	= "Taxi to Runway",
	[8] 	= "Before Takeoff",
	[9] 	= "Takeoff",
	[10] 	= "After Takeoff",
	[11] 	= "Climb",
	[12] 	= "Cruise",
	[13] 	= "Descent",
	[14] 	= "Arrival",
	[15] 	= "Approach",
	[16] 	= "Landing",
	[17] 	= "Go Around",
	[18] 	= "Turnoff",
	[19] 	= "Taxi to Stand",
	[20] 	= "Shutdown",
	[21] 	= "Turnaround"
}

-- flight phase index
ng_phase_flight_planning = 1
ng_phase_colddark	 	= 2
ng_phase_prel_preflight	= 3
ng_phase_preflight 	 	= 4
ng_phase_before_start 	= 5
ng_phase_after_start 	= 6
ng_phase_taxi_rwy	 	= 7
ng_phase_before_takeoff	= 8
ng_phase_takeoff	 	= 9
ng_phase_after_takeoff 	= 10
ng_phase_climb 		 	= 11
ng_phase_enroute	 	= 12
ng_phase_descent 	 	= 13
ng_phase_arrival 	 	= 14
ng_phase_approach 	 	= 15
ng_phase_landing 	 	= 16
ng_phase_go_around	 	= 17
ng_phase_afterland 	 	= 18
ng_phase_taxi_stand  	= 19
ng_phase_shutdown 	 	= 20
ng_phase_turnaround  	= 21

--- get phase string based on index
-- @param int index - index of phase
-- @return string - flight phase title
function ng_get_flight_phase_title(key)
	return ng_flightphases[key] end
