--[[
	*** KPCREWNG
	Select the loaded aircraft based on icao and tail registration
	Kosta Prokopiu, January 2026
--]]

--- Return the matching KPCrew addon icao code
-- @param int 0 = both, 1 = sop only, 2 = systems only
function ng_acft_select(component)

	if component == nil then component = 0 end
	
	local icao = "DFLT" -- active addon aircraft ICAO code (DFLT when nothing found)
	local sopicao = "DFLT" 

	-- ====== Select the addon modules based on ICAO code
	if PLANE_ICAO == "B738" and PLANE_TAILNUMBER == "ZB738" then
		icao = "B737" -- Zibo B738
		sopicao = "DFLT"
	elseif PLANE_ICAO == "B739" then
		icao = "B737" -- LevelUp B739
		sopicao = "DFLT"
	elseif PLANE_ICAO == "B736" then
		icao = "B737" -- LevelUp B736
		sopicao = "DFLT"
	elseif PLANE_ICAO == "B737" then
		icao = "B737" -- LevelUp B737
		sopicao = "DFLT"
	elseif PLANE_ICAO == "B738" and PLANE_TAILNUMBER == "B738" then
		icao = "B737" -- LevelUp B738
		sopicao = "DFLT"

	-- Epic Victory Aerobask
	elseif PLANE_ICAO == "EVIC" then
		icao = "EVIC"
		sopicao = "DFLT"

	-- Epic E1000 Aerobask
	elseif PLANE_ICAO == "EPIC" then
		icao = "EPIC"
		sopicao = "DFLT"

	-- Vskylabs C510
	elseif PLANE_ICAO == "C510" then
		icao = "C510"
		sopicao = "DFLT"

	-- Aeroworx DC-3 Freeware
	elseif PLANE_ICAO == "DC3" then
		icao = "ADC3"
		sopicao = "DFLT"
		
	-- Thranda PC12
	elseif PLANE_ICAO == "PC12" then
		icao = "PC12"
		sopicao = "DFLT"
		
	-- FF A350
	elseif PLANE_ICAO == "A359" then
		icao = "A359"	
		sopicao = "DFLT"
	
	-- SSG B748
	elseif PLANE_ICAO == "B748" then
		icao = "B748"
		sopicao = "DFLT"

	-- Laminar SF50
	elseif PLANE_ICAO == "SF50" then
		icao = "SF50"
		sopicao = "SF50"
		
	-- XP12 Citation X
	elseif PLANE_ICAO == "C750" and PLANE_TAILNUMBER == "N750XP" then
		icao = "C750"
		sopicao = "DFLT"
		
	-- XP12 A330-300 Laminar
	elseif PLANE_ICAO == "A333" then
		icao = "A33L"
		sopicao = "A33L"
		
	-- X-Works A330-200 (Laminar A330 until found otherwise)
	elseif PLANE_ICAO == "A332" or PLANE_ICAO == "A332F" then
		icao = "A33L"
		sopicao = "DFLT"
		
	-- FlightFactor A320
	elseif PLANE_ICAO == "A320" then
		icao = "A320"
		sopicao = "DFLT"
		
	-- Inibuilds A300
	elseif PLANE_ICAO == "A306" then
		icao = "A306"
		sopicao = "DFLT"

	-- FF 7x7
	elseif PLANE_ICAO == "B762" or PLANE_ICAO == "B763" or PLANE_ICAO == "B764" or PLANE_ICAO == "B752" or PLANE_ICAO == "B753" then
		icao = "B7x7"
		sopicao = "DFLT"
		
	-- Rotate MD-11
	elseif PLANE_ICAO == "MD11" then
		icao = "MD11"
		sopicao = "DFLT"
		
	-- Magknight B787
	elseif PLANE_ICAO == "B788" or PLANE_ICAO == "B789" then
		icao = "B787"
		sopicao = "DFLT"

	-- Airfoillabs Kingair
	elseif PLANE_ICAO == "B350" then
		icao = "B350"
		sopicao = "DFLT"

	-- Thranda Caravan
	elseif PLANE_ICAO == "C208" then
		icao = "C208"
		sopicao = "DFLT"

	-- Airsim3D C-560XL
	elseif PLANE_TAILNUM == "C-DVMC" then
		icao = "C560"
		sopicao = "DFLT"

	-- Coolimata Concorde
	elseif PLANE_TAILNUM == "CONC" then
		icao = "CONC"
		sopicao = "DFLT"

	-- AD-Sim CRJs
	elseif PLANE_ICAO == "CRJ7" or PLANE_ICAO == "CRJ900" then
		icao = "CRJx"
		sopicao = "DFLT"

	-- IXEG 737
	elseif PLANE_ICAO == "B733" then
		icao = "B733"
		sopicao = "DFLT"

	-- Felis 747-200
	elseif PLANE_ICAO == "B742" then
		icao = "B742"
		sopicao = "DFLT"
			
	-- X-CRAFTS E-JET FAMILIY XP12 (E1XX)
	-- E-JET FAM 170  170/170
	-- E-JET FAM 175  175/175
	-- E-JET FAM 190  190/190
	-- E-JET FAM 195  195/195
	-- LINEAGE 1000
	elseif PLANE_ICAO == "E170" and PLANE_TAILNUMBER == "E170" then
		icao = "E1XX"
		sopicao = "DFLT"
	elseif PLANE_ICAO == "E175" and PLANE_TAILNUMBER == "E175" then
		icao = "E1XX"
		sopicao = "DFLT"
	elseif PLANE_ICAO == "E190" and PLANE_TAILNUMBER == "E190" then
		icao = "E1XX"
		sopicao = "DFLT"
	elseif PLANE_ICAO == "E195" and PLANE_TAILNUMBER == "E195" then
		icao = "E1XX"
		sopicao = "DFLT"
	elseif PLANE_ICAO == "E19L" then
		icao = "E1XX"
		sopicao = "DFLT"
		
	-- X-CRAFTS FREE E-JETS XP12 (E1FF)
	-- Free 175       170/175
	-- Free 195       190/195
	elseif PLANE_ICAO == "E170" and PLANE_TAILNUMBER == "E175" then
		icao = "E1FF"
		sopicao = "E1FF"
	elseif PLANE_ICAO == "E190" and PLANE_TAILNUMBER == "E195" then
		icao = "E1FF"
		sopicao = "E1FF"

	-- FPS E-JETS
	-- 175 - not sure - do not have that aircraft
	-- 195
	elseif PLANE_ICAO == "E195" and PLANE_TAILNUMBER == "PP-FPS" then
		icao = "E1FP"
		sopicao = "DFLT"
	elseif PLANE_ICAO == "E175" and PLANE_TAILNUMBER == "PP-FPS" then
		icao = "E1FP"
		sopicao = "DFLT"

	-- X-CRAFTS ERJ FAMILIY XP12 (ER1X)
	-- ERJ 135
	-- ERJ 140
	-- ERJ 145
	-- ERJ 145XR
	-- LEGACY Business jet
	elseif PLANE_ICAO == "E135" then
		icao = "ER1X"
		sopicao = "DFLT"
	elseif PLANE_ICAO == "E140" then
		icao = "ER1X"
		sopicao = "DFLT"
	elseif PLANE_ICAO == "E145" then
		icao = "ER1X"
		sopicao = "DFLT"
	elseif PLANE_ICAO == "E45X" then
		icao = "ER1X"
		sopicao = "DFLT"
	elseif PLANE_ICAO == "E35L" then
		icao = "ER1X"
		sopicao = "DFLT"

	-- JUSTFLIGHT BAE SERIES
	-- B463
	-- B462
	-- B461
	elseif PLANE_ICAO == "B461" then
		icao = "B46X"
		sopicao = "DFLT"
	elseif PLANE_ICAO == "B462" then
		icao = "B46X"
		sopicao = "DFLT"
	elseif PLANE_ICAO == "B463" then
		icao = "B46X"
		sopicao = "DFLT"
		
	-- ToLiss Airbusses
	elseif PLANE_ICAO == "A319" and PLANE_TAILNUMBER == "C-GTLS" then
		icao = "A3TL"
		sopicao = "DFLT"
	elseif PLANE_ICAO == "A20N" and PLANE_TAILNUMBER == "C-GTLT" then
		icao = "A3TL"
		sopicao = "DFLT"
	elseif PLANE_ICAO == "A321" then
		icao = "A3TL"
		sopicao = "DFLT"
	elseif PLANE_ICAO == "A21N" then
		icao = "A3TL"
		sopicao = "DFLT"
	elseif PLANE_ICAO == "A339" then
		icao = "A3TL"
		sopicao = "DFLT"
	elseif PLANE_ICAO == "A346" then
		icao = "A3TL"
		sopicao = "DFLT"
		
	-- Laminar MD-82
	elseif PLANE_ICAO == "MD82" and PLANE_TAILNUMBER == "N552AA" then
		icao = "MD82"
		sopicao = "DFLT"
		
	-- RotateSim MD-88
	elseif PLANE_ICAO == "MD88" then
		icao = "MD88"
		sopicao = "DFLT"
		
	-- LES Saab SF34
	elseif PLANE_ICAO == "SF34" then
		icao = "SF34"
		sopicao = "DFLT"
		
	-- MSparks B747
	elseif PLANE_ICAO == "B744" or PLANE_ICAO == "B744F" then
		icao = "B744"
		sopicao = "DFLT"
		
	-- Aerobask Phenom 300
	elseif PLANE_ICAO == "E55P" then
		icao = "E55P"
		sopicao = "DFLT"
	
	-- Riviere Dash-8
	-- DHC8A Dash 8-Q100
	elseif PLANE_ICAO == "DH8AA" then
		icao = "DHC8"
		sopicao = "DFLT"
		
	-- FlyJsim Dash
	elseif PLANE_ICAO == "DH8D" then
		icao = "DH8D"
		sopicao = "DFLT"
	
	-- X-Aviation CL650
	elseif PLANE_ICAO == "CL60" then
		icao = "CL60"
		sopicao = "DFLT"
	else
		icao = "DFLT"
		sopicao = "DFLT"		
	end

	if component == 1 then -- return only sop icao
		if ng_file_exists(SCRIPT_DIRECTORY.."../Modules/kpcrew/addons/"..sopicao.."_sop.json") then 
			return sopicao
		else
			print(sopicao.." files not complete in addons folder! Taking DFLT")
			return "DFLT"
		end
	elseif component == 2 then -- system icao
		if ng_file_exists(SCRIPT_DIRECTORY.."../Modules/kpcrew/addons/"..icao.."_systems.json") then
			return icao
		else
			print(icao.." files not complete in addons folder! Taking DFLT")
			return "DFLT"
		end
	else
		if ng_file_exists(SCRIPT_DIRECTORY.."../Modules/kpcrew/addons/"..icao.."_sop.json") and 
		   ng_file_exists(SCRIPT_DIRECTORY.."../Modules/kpcrew/addons/"..icao.."_systems.json") then
			return icao
		else
			print(icao.." files not complete in addons folder! Taking DFLT")
			return "DFLT"
		end
	end
end