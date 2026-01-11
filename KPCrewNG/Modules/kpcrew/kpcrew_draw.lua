-- Render windows for KPCrewNG
--
-- @author Kosta Prokopiu
-- @copyright 2026 Kosta Prokopiu

if FLYWITHLUA == false then -- for dev environment on Linux and cimgui
	local imgui = require "cimgui"
	local ffi = require "ffi"
	require "teststubs"
end

require "kpcrew.genutils"
require "kpcrew.imgui_utils"

local SOP = require("kpcrew.Addon.SOP.SOP")

kc_imgui_current_main_tab = 0
kc_imgui_main_wnd_width = 950
kc_imgui_main_wnd_height = 950

-- drawing function to be executed regularly
return function()

	-- render flight planning tab
	local function render_main_tab_0()
		imgui.BeginGroup()
		
		ng_get_active_addon():getSop():render(i)
		
		imgui.EndGroup()
	end

	-- render SOP tab
	local function render_main_tab_1()
		
		imgui.BeginGroup()
		
--		kc_imgui_in_button("flowprev", "<", 25, 30, 			function () if getActiveSOP():getActiveFlowIndex() > 1 then
--			getActiveSOP():setActiveFlowIndex(getActiveSOP():getActiveFlowIndex() -1)
--			end end) 
--		imgui.SameLine() 
--		kc_imgui_in_button("flownext", ">", 25, 30, function () 
--			if getActiveSOP():getActiveFlowIndex() < 20 then
--				getActiveSOP():setActiveFlowIndex(getActiveSOP():getActiveFlowIndex() +1)
--			end end) 
--
--			getActiveSOP():render()
----			getActiveSOP():getActiveFlow():render()
		imgui.EndGroup()
		
	end

	local function render_main_tab_2()
		imgui.BeginGroup()
			kc_imgui_out_text(color_white, "test3")
		imgui.EndGroup()
	end

	local function render_main_tab_3()
		imgui.BeginGroup()
			kc_imgui_out_text(color_white, "test4")
--			getActiveBriefings():render()
--			getActivePrefs():render()
		imgui.EndGroup()
	end
	
	-- get screen width from X-Plane
	kc_scrn_width = get("sim/graphics/view/window_width")
	kc_scrn_height = get("sim/graphics/view/window_height")
	
	imgui.SetNextWindowSize({kc_imgui_main_wnd_width,kc_imgui_main_wnd_height})

	imgui.Begin("KPCrewNG " .. kc_VERSION)

	local tabsDef = {[0]="Flight Planning", [1]="SOP",[2]="In-Flight", [3]="Settings"}
	local tabsNumber = (#tabsDef+1)
	local tabsSize = kb_wnd_width / tabsNumber - 4
	
	for i = 0,#tabsDef,1 do kc_imgui_draw_add_main_tab(i, tabsSize, tabsDef[i]) end
	
	if     kc_imgui_current_main_tab == 0 then render_main_tab_0()
	elseif kc_imgui_current_main_tab == 1 then render_main_tab_1() 
	elseif kc_imgui_current_main_tab == 2 then render_main_tab_2()
	elseif kc_imgui_current_main_tab == 3 then render_main_tab_3()
	end
	
	imgui.End()
	
	imgui.SetNextWindowSize({350,(15 + 2 ) * 23 + 12 + 27})
	imgui.SetNextWindowPos({kc_scrn_width-355,kc_scrn_height-((15 + 2 ) * 23 + 12 + 77)})
	imgui.Begin("SOP Window")
	
	imgui.End()
	
	imgui.SetNextWindowSize({700,50})
	imgui.SetNextWindowPos({kc_scrn_width-705,kc_scrn_height-46})
	imgui.Begin("Control Window")

	imgui.End()
	
end