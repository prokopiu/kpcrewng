-- A element item individual system elements
--
-- @classmod SystemElement
-- @author Kosta Prokopiu
-- @copyright 2026 Kosta Prokopiu

local JsonExport = require ("kpcrew.json_pretty_print")

local ngAssignmentElement = {}

--- Instantiate a new Element
-- @param string name  
-- @param string title 
-- @param string elementnode from json 
-- @return SystemElement - the created SystemElement object
function ngAssignmentElement:new(name, planeicao, planetailnum, elementNode)
    ngAssignmentElement.__index = ngAssignmentElement
    local obj = {}
    setmetatable(obj, ngAssignmentElement)

	obj.className = "SystemElement"
	
    obj.name = name
	obj.planeicao = planeicao
	obj.planetailnum = planetailnum
	obj.elementNode = elementNode
	
	dprint("+ "..obj.className.." {"..obj.name.."}")

    return obj
end

--- get classname
-- @return string className
function ngAssignmentElement:getClassName() return self.className end

--- get name string
-- @return string - name text
function ngAssignmentElement:getName() return self.name end

--- set name
-- @param string name
function ngAssignmentElement:setName(name) self.name = name end

--- get planeicao string
-- @return string - planeicao text
function ngAssignmentElement:getPlaneicao() return self.planeicao end

--- set planeicao
-- @param string planeicao
function ngAssignmentElement:setPlaneicao(planeicao) self.planeicao = planeicao end

--- get planetailnum string
-- @return string - planetailnum text
function ngAssignmentElement:getPlanetailnum() return self.planetailnum end

--- set planetailnum
-- @param string planetailnum
function ngAssignmentElement:setPlanetailnum(planetailnum) self.planetailnum = planetailnum end

--- set element node
-- @param table elementNode
function ngAssignmentElement:setElementNode(elementNode) self.elementNode = elementNode end

--- get element node
-- @return table elementNode
function ngAssignmentElement:getElementNode() return self.elementNode end

function ngAssignmentElement:render()
	if self ~= nil then
		
		-- ng_imgui_out_text(color_white,"Name/Title:") imgui.SameLine() ng_imgui_out_text(color_white, self.name .."/"..self.title)
		-- if self.elementNode.type ~= nil then 		
			-- ng_imgui_out_text(color_white,"Type:") imgui.SameLine() ng_imgui_out_text(color_white, self.elementNode.type) 
		-- end
		-- ng_imgui_out_text(color_white,"Actions:") imgui.SameLine() ng_imgui_out_text(color_white, JsonExport:pretty_print(self.elementNode.acts))
		-- if self.elementNode.dref ~= nil then 		
			-- ng_imgui_out_text(color_white,"Dref:") imgui.SameLine() ng_imgui_out_text(color_white, self.elementNode.dref) 
		-- end
		-- if self.elementNode.indx ~= nil then 		
			-- ng_imgui_out_text(color_white,"Indx:") imgui.SameLine() ng_imgui_out_text(color_white, self.elementNode.indx)
		-- end
	end
end


return ngAssignmentElement