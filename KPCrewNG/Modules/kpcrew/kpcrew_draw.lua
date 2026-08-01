-- Render windows for KPCrewNG
--
-- @author Kosta Prokopiu
-- @copyright 2026 Kosta Prokopiu

if FLYWITHLUA == false then -- for dev environment on Linux and cimgui
	local imgui = require "cimgui"
	local ffi = require "ffi"
	require "teststubs"
end

require "kpcrew.nggenutils"
require "kpcrew.imgui_utils"
require "kpcrew.acft_select"

-- SOP 		= require("kpcrew.Addon.SOP.SOP")
-- Systems 	= require("kpcrew.Addon.Systems.AddonSystems")

-- control window flags/vars
ng_imgui_initial_ctrl_set 		= false
ng_imgui_initial_ctrl_width 	= 700
ng_imgui_initial_ctrl_height 	= 40

-- briefing window flags/vars
ng_imgui_initial_brief_set 		= false
ng_imgui_current_brief_tab 		= 0
ng_imgui_initial_brief_width 	= 730
ng_imgui_initial_brief_height 	= 990
ng_imgui_initial_brief_xpos 	= 30
ng_imgui_initial_brief_ypos 	= 10

-- SOP window flags/variables
ng_imgui_initial_sop_set 		= false
ng_imgui_initial_sop_width 		= 530
ng_imgui_initial_sop_height 	= 27
ng_imgui_initial_sop_xpos 	    = 450
ng_imgui_initial_sop_ypos 	    = 10

-- Preference window flags/variables
ng_imgui_initial_pref_set 		= false
ng_imgui_initial_pref_width 	= 410
ng_imgui_initial_pref_height 	= 600
ng_imgui_initial_pref_xpos 		= 850
ng_imgui_initial_pref_ypos 		= 310

-- editor window flags/vars
ng_imgui_initial_edit_set 		= false
ng_imgui_current_edit_tab 		= 0
ng_imgui_initial_edit_width 	= 490
ng_imgui_initial_edit_height 	= 940
ng_imgui_initial_edit_xpos 		= 30
ng_imgui_initial_edit_ypos 		= 40

ng_imgui_current_main_tab = 0
ng_imgui_main_wnd_width = 960
ng_imgui_main_wnd_height = 950
ng_weightunit = "KGS"
ng_kgslbs = 1
ng_settings_icao = ng_acft_select(2)

ng_sop_flows_visible = false

ng_editor_system_title = ""
ng_editor_system_icao = ng_acft_select(2)
ng_editor_system_json = nil
ng_editor_system_newsystem = ""
ng_editor_system_newelement = ""
ng_editor_system_newelement2 = {}
ng_editor_system_error = ""
ng_editor_system_filter = ""
ng_editor_remove_element = false
ng_editor_remove_system = false
ng_editor_actions = { 
	undefined = { "", "chk", " "},
	dataref = { "", "on", "off", "tgl", "set", "chk", " "},
	onofftgl = { "", "on", "off", "tgl", "chk", " "},
	dialdref = { "", "up", "dn", "set", "chk", " "},
	dialcmd = { "", "up", "dn", "set", "chk", " "},
	custom = { "", "on", "off", "tgl", "set", "chk", " "}
}
ng_editor_types = { "", "dataref", "onofftgl", "dialdref", "dialcmd", "custom", "undefined", " " }

ng_editor_sop_title = ""
ng_editor_flow_title = ""
ng_editor_step_title = ""

ng_editor_sop_icao = ng_acft_select(1)
ng_editor_sop_json = nil
ng_editor_sop_expand1 = false
ng_editor_sop_expcol1 = 0
ng_editor_sop_expand2 = false
ng_editor_sop_expcol2 = 0
ng_editor_sop_expand3 = false
ng_editor_sop_expcol3 = 0
ng_editor_sop_newflow = ""
ng_editor_sop_newitem = ""
ng_editor_sop_newelement = ""
ng_editor_sop_flowcopy = nil
ng_editor_sop_flowcopyname = ""
ng_editor_sop_itemcopy = nil
ng_editor_sop_itemcopyname = ""
ng_editor_sop_error = ""
ng_editor_sop_filter = ""
ng_editor_sop_remove_flow = false
ng_editor_sop_remove_item = false
ng_editor_sop_remove_element = false

-- ng_debug_window_str = "DEBUG"

ng_preferences_error = ""

require "kpcrew.kpcrew_ctrl_window"

require "kpcrew.kpcrew_sop_window"

require "kpcrew.kpcrew_pref_window"

require "kpcrew.kpcrew_brief_window"

require "kpcrew.kpcrew_editor_window"